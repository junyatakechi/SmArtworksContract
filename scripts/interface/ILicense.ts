import { IApplication } from "./IApplication";

// 許諾承認時に署名する文章。
export interface ILicense{
    licenseAddr: string;
    licenseId: number;
    applicationAddr: string;
    applicationId: number
    applicationMessageDigest: string;
    application: IApplication;
    approver: string;
    approverName: string;
    approverInfo: string;
    approverDate: string;
}