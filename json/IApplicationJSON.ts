
// NFTのメタデータ構造。
export interface IApplicationJSON {
    name: string;
    discription: string;
    image: string;
    // applicationへの電子署名
    fingerprint: string;
    application: {
        // この申請書発行元のコントラクトアドレス
        applicationAddr: string;
        // この申請書のトークン番号
        applicationId: number;
        // 契約の名前
        name: string;
        // 契約の文言など
        discription: string;
        // 支払う料金
        licenseFees: number;
        //
        work: {
            // 使用するWork発行元のコントラクトアドレス
            workAddr: string;
            // 使用するWorkのトークン番号
            workId: number;
            // 著作者名
            leadAuthorName: string;
            // 著作者のウォレットアドレス
            leadAuthorAddr: string;
            // 作品のタイトル
            workTitle: string;
        }
        //
        applicant: {
            // この申請書に署名する公開鍵(申請者のウォレットアドレス)
            address: string;
            // 使用者の名前
            name: string;
            // 使用者の連絡先(email or phone number, etc...)
            contact: string;
        },
        //
        objects: {
            // 使用する場所(web site or address, etc...)
            useLocation: string;
            // 使用目的(DJ, Radio, cover song, etc...)
            details: string;
        },
        //
        date: {
            // Unixtimeを使用。フロントではISO8601拡張形式(YYYY-MM-DDThh:mm:ss)
            // 使用する期間
            startDate: number;
            endDate: number;
            // 申請を引き下げる日時
            // 誰も承認しなければ自動的に`licenseFees`を返金する。
            cancellationDate: number;
            createdDate: number;
        }
    }

}