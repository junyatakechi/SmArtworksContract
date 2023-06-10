// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./struct/Artwork.sol";
import "./struct/Guideline.sol";
import "./struct/RequestInfo.sol";

//
contract SmArtworksContract is ERC721, Ownable{
    string public description;
    string public image;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _description, // "This contract is used to manage Licensing for Artwork."
        string memory _image        //"ar://ayw5dMibF5pymMXps2k9JxHKNMZOkv7lCQ9dwMwK-6Q"
    ) ERC721(_name, _symbol){
        image = _image;
        description = _description;
    }

    uint256 private currentArtworkId;
    mapping(uint256 => Artwork) public artworks;
     
    uint256 public currentVersion;
    mapping(uint256 => Guideline) public guidelines;

    // tokenIdと直接結びつくデータ群
    mapping(uint => RequestInfo) private _requestInfoMap; 
    uint public tokenIdCount = 0;
    uint private _mintedAmount = 0;
    uint private _burnedAmount = 0;

    // 持ってるtokenIdを記録
    mapping (address => uint[]) public ownerTokenIdMap;

    // 
    event Minted(address indexed account, uint tokenId);

    function getWork(uint256 _artworkId) public view returns (Artwork memory) {
        require(artworks[_artworkId].deactivatedAt == 0, "This Artwork is inactive.");
        return artworks[_artworkId];
    }

    function getCurrentGuideline() public view returns (Guideline memory) {
        require(currentVersion > 0, "No guideline is available.");
        return guidelines[currentVersion];
    }

    function getGuideline(uint256 version) external view returns (Guideline memory) {
        return guidelines[version];
    }

    // ガイドライン検証
    function validateGuideline(uint256 _guidelineVersion, string memory _guidelineContent) public view returns(bool){
        Guideline memory guideline = guidelines[_guidelineVersion];
        
        // Compute the content hash
        bytes32 contentHash = _computeContentHash(_guidelineContent);
        
        // Compare the computed hash with the stored digest
        return guideline.digest == contentHash; // 変更: digestをエンコードせず直接比較
    }


    // 署名する文章作成
    function createCreativeAgreement(
        uint256 _artworkId,
        string memory _signerName,
        string memory _purpose,
        string memory _location,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _value,
        uint256 _guildLineVerId,
        string memory _guidlineContent
    ) public view returns (string memory){
        
        require(validateGuideline(_guildLineVerId, _guidlineContent), "Invalid Guideline");

        string memory signerAddress = Strings.toHexString(uint256(uint160(msg.sender)));
        return string(abi.encodePacked(
            "{",
            '"contractAddress":', '"', Strings.toHexString(uint256(uint160(address(this)))), '",',
            '"artworkId":', Strings.toString(_artworkId), ',',
            '"signerName":', '"', _signerName, '",',
            '"signerAddress":', '"', signerAddress, '",',
            '"purpose":', '"', _purpose, '",',
            '"location":', '"', _location, '",',
            '"startDate":', Strings.toString(_startDate), ',',
            '"endDate":', Strings.toString(_endDate), ',',
            '"value":', Strings.toString(_value), ',',
            '"guildLineVerId":', '"', Strings.toString(_guildLineVerId), '",',
            '"guidlineContent":', '"', _guidlineContent, '"',
            "}"
        ));
    }

    function mint(
        string memory _signerName,
        uint256 _artworkId,
        string memory _purpose,
        string memory _location,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _guildLineVerId,
        bytes memory _signature,
        string memory _guidlineContent
    ) external payable {
        require(artworks[_artworkId].deactivatedAt == 0, "This Artwork is inactive.");

        // Create the agreement text
        string memory agreement = createCreativeAgreement(
            _artworkId,
            _signerName,
            _purpose,
            _location,
            _startDate,
            _endDate,
            msg.value,
            _guildLineVerId,
            _guidlineContent
        );
        
        // Verify the signature
        address signer = extractSigner(agreement, _signature);
        require(signer == msg.sender, "Invalid signature");

        tokenIdCount++;
        _safeMint(_msgSender(), tokenIdCount);
        ownerTokenIdMap[_msgSender()].push(tokenIdCount);

        // Create a new RequestInfo object
        RequestInfo memory request = RequestInfo({
            isActive: true,
            signerName: _signerName,
            signerAddress: msg.sender,
            artworkId: _artworkId,
            purpose: _purpose,
            location: _location,
            startDate: _startDate,
            endDate: _endDate,
            createdDate: block.timestamp,
            value: msg.value,
            guildLineVerId: _guildLineVerId,
            signature: _signature
        });

        // Store the request info
        _requestInfoMap[tokenIdCount] = request;

        _mintedAmount++;

        emit Minted(msg.sender, tokenIdCount);
    }



    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        
        RequestInfo storage request = _requestInfoMap[tokenId];
        
        string memory json = _createSecondCreativeRequest(tokenId, request);

        string memory dataURI = string(abi.encodePacked(
            "data:application/json;base64,", 
            Base64.encode(bytes(json))
        ));

        return dataURI;
    }

    
   // 検証
    function extractSigner(
        string memory creativeAgreement,
        bytes memory signature
    ) public pure returns (address) {
        // signatureの長さが65バイトであることを確認します。
        require(signature.length == 65, "Invalid signature length");

        // signatureからv, r, sを抽出します。
        bytes32 r;
        bytes32 s;
        uint8 v;

        //
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // vが27または28であることを確認し、適切な値に設定します。
        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid v value");

        // メッセージハッシュを計算します。
        // ERC-191: フロント側でも同じ規格を使用する。
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n",
                Strings.toString(uint256(bytes(creativeAgreement).length)),
                creativeAgreement
            )
        );

        // 署名の検証を行い、結果を返します。
        address recoveredSigner = ECDSA.recover(messageHash, v, r, s);
        return recoveredSigner;
    }

    // burn
    function burn(uint256 tokenId) external{
        address tokenOwner = ERC721.ownerOf(tokenId);
        require(_msgSender() == tokenOwner, "Not Owner");
        _burn(tokenId);
        _burnedAmount++;
        _removeFromOwnerTokenIdMap(tokenOwner, tokenId);
    }

    // mintで加算。burnで減算。
    function totalSupply() public view returns(uint256){
        return _mintedAmount - _burnedAmount;
    }

    // TODO: withdraw

    /// For Artist /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function addWork(
        string memory _title, 
        string[] memory _authors,
        string memory _mediaURL,
        string memory _mediaDigest,
        uint256 _minValue,
        uint256 _maxValue,
        uint256 _maxDate
    ) external onlyOwner{
        currentArtworkId++;
        Artwork memory newWork = Artwork({
            title: _title,
            authors: _authors,
            createdAt: block.timestamp,
            deactivatedAt: 0,
            mediaURL: _mediaURL,
            mediaDigest: _mediaDigest,
            minValue: _minValue,
            maxValue: _maxValue,
            maxDate: _maxDate
        });
        artworks[currentArtworkId] = newWork;
    }

    function deactivateWork(uint256 _artworkId) external onlyOwner {
        require(artworks[_artworkId].deactivatedAt == 0, "This Artwork is already inactive.");
        artworks[_artworkId].deactivatedAt = block.timestamp;
    }

    function addGuideline(string memory _url, string memory _content) external onlyOwner {
        // Compute the content hash
        bytes32 contentHash = _computeContentHash(_content);
        
        currentVersion++;
        guidelines[currentVersion] = Guideline(_url, contentHash, block.timestamp);
    }
    
    //
    function forceBurn(uint256 tokenId) external onlyOwner{
        address tokenOwner = ERC721.ownerOf(tokenId);
        _burn(tokenId);
        _burnedAmount++;
        _removeFromOwnerTokenIdMap(tokenOwner, tokenId);
    }

    // internal ////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // 転送不可SBT 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId, /* firstTokenId */
        uint256 batchSize
    ) internal virtual override(ERC721){
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        require(
            from == address(0) || to == address(0),
            "Not allowed to transfer token"
        );
    }

    // burn時にtokenMapを更新
    function _removeFromOwnerTokenIdMap(address owner, uint256 tokenId) internal {
        uint256[] storage ownedTokens = ownerTokenIdMap[owner];
        uint256 indexToRemove = 0;
        bool found = false;

        for (uint256 i = 0; i < ownedTokens.length; i++) {
            if (ownedTokens[i] == tokenId) {
                indexToRemove = i;
                found = true;
                break;
            }
        }

        require(found, "Token ID not found in owner's list");

        // Move the last element to the indexToRemove and then pop the last element
        ownedTokens[indexToRemove] = ownedTokens[ownedTokens.length - 1];
        ownedTokens.pop();
    }

    function _computeContentHash(string memory _content) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_content));
    }

    // metadata for NFT
    // TODO: ユーザーが見るところだからもっと詳細に書いた方が良い?
    function _createSecondCreativeRequest(
        uint tokenId,
        RequestInfo storage request 
    ) internal view returns (string memory){
        string memory contractAddress = Strings.toHexString(uint256(uint160(address(this))));
        string memory signerAddress = Strings.toHexString(uint256(uint160(request.signerAddress)));

        return string(abi.encodePacked(
            "{",
            '"name": "', name(), '",',
            '"description": "', description, '",',
            '"image": "', image, '",',
            '"contractAddress": "', contractAddress, '",',
            '"tokenId": "', tokenId, '",',
            '"artworkId":', Strings.toString(request.artworkId), ',',
            '"signerName": "', request.signerName, '",',
            '"signerAddress": "', signerAddress, '",',
            '"purpose": "', request.purpose, '",',
            '"location": "', request.location, '",',
            '"startDate":', Strings.toString(request.startDate), ',',
            '"endDate":', Strings.toString(request.endDate), ',',
            '"createdDate":', Strings.toString(request.createdDate), ',',
            '"value":', Strings.toString(request.value), ',',
            '"guildLineVerId": "', Strings.toString(request.guildLineVerId), '",',
            '"signature": "', request.signature, '"',
            "}"
        ));
    }

}