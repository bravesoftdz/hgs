unit UnitHGSCertData;

interface

uses System.Classes, UnitEnumHelper;

type
  TCertQueryDateType = (cqdtNull, cqdtTrainedPeriod, cqdtValidityUntilDate,
    cqdtCertIssueDate, cqdtAPTServiceDate, cqdtFinal);


const
  HGS_CERT_DB_NAME = 'HGSCertMaster.sqlite';
  HGS_VDRLIST_DB_NAME = 'HGSVDRList.sqlite';

  R_CertQueryDateType : array[Low(TCertQueryDateType)..High(TCertQueryDateType)] of string =
    ('', 'Trained Period', 'Validity Until Date', 'Cert. Issue Date',


    ('', 'Education', 'APT Service', 'Product Approval', '');

    ('', 'E', 'S', 'A', '');

var
  g_CertQueryDateType: TLabelledEnum<TCertQueryDateType>;
  g_HGSCertType: TLabelledEnum<THGSCertType>;
  g_HGSCertTypeCode: TLabelledEnum<THGSCertType>;

implementation

initialization
  g_CertQueryDateType.InitArrayRecord(R_CertQueryDateType);
  g_HGSCertType.InitArrayRecord(R_HGSCertType);
  g_HGSCertTypeCode.InitArrayRecord(R_HGSCertTypeCode);

end.