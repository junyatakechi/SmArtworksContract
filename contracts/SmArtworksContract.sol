// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./struct/Artwork.sol";
import "./struct/Guideline.sol";

//
contract SmArtworksContract is ERC721, Ownable{
    string public constant name = "takechy";
    string public constant description = "This contract is used to manage Licensing for Artwork.";
    string public image = "ar://ayw5dMibF5pymMXps2k9JxHKNMZOkv7lCQ9dwMwK-6Q";

    uint256 private currentWorkId;
    mapping(uint256 => Artwork) public artworks;
     
    uint256 public currentVersion;
    mapping(uint256 => Guideline) public guidelines;

    // TODO: トークンIDと紐づくSecondCreativeRequestのJSONを生成するために必要なデータ群
    mapping(uint => Application) private _applicationMap; 
    uint public applicationIdCount = 0;
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
        string memory signerAddress = Strings.toHexString(uint256(uint160(msg.sender)));
        return string(abi.encodePacked(
            "{",
            '"applicationAddress":', '"', Strings.toHexString(uint256(uint160(address(this)))), '",',
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

    function mint() external{

    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        // TODO: Update the parameters accordingly
        string memory signerName = "Signer Name Here";
        string memory purpose = "Purpose Here";
        string memory location = "Location Here";
        uint256 startDate = 0;
        uint256 endDate = 0;
        uint256 value = 0;
        uint256 guildLineVerId = 0;
        string memory signature = "Signature Here";

        string memory json = _createSecondCreativeRequest(
            tokenId,
            msg.sender,
            signerName,
            purpose,
            location,
            startDate,
            endDate,
            value,
            guildLineVerId,
            signature
        );

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
                message
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
        currentWorkId++;
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
        artworks[currentWorkId] = newWork;
    }

    function deactivateWork(uint256 _artworkId) external onlyOwner {
        require(artworks[_artworkId].deactivatedAt == 0, "This Artwork is already inactive.");
        artworks[_artworkId].deactivatedAt = block.timestamp;
    }

    function addGuideline(string memory _url, string memory _digest) external onlyOwner {
        currentVersion++;
        guidelines[currentVersion] = Guideline(_url, _digest, block.timestamp);
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

    // metadata for NFT
    function _createSecondCreativeRequest(
        uint256 _artworkId,
        address _signerAddress,
        string memory _signerName,
        string memory _purpose,
        string memory _location,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _value,
        uint256 _guildLineVerId,
        string memory _signature  // Signature has been added
    ) internal view returns (string memory){
        Artwork memory artwork = getWork(_artworkId);
        string memory applicationAddress = Strings.toHexString(uint256(uint160(address(this))));
        string memory signerAddress = Strings.toHexString(uint256(uint160(_signerAddress)));
        string memory applicationId = "TODO";  // Update with actual value

        return string(abi.encodePacked(
            "{",
            '"name": "', name, '",',
            '"description": "', description, '",',
            '"image": "', image, '",',
            '"applicationAddress": "', applicationAddress, '",',
            '"applicationId": "', applicationId, '",',
            '"artworkId":', Strings.toString(_artworkId), ',',
            '"signerName": "', _signerName, '",',
            '"signerAddress": "', signerAddress, '",',
            '"purpose": "', _purpose, '",',
            '"location": "', _location, '",',
            '"startDate":', Strings.toString(_startDate), ',',
            '"endDate":', Strings.toString(_endDate), ',',
            '"value":', Strings.toString(_value), ',',
            '"guildLineVerId": "', Strings.toString(_guildLineVerId), '",',
            '"signature": "', _signature, '"',
            "}"
        ));
    }

}