unit CommonData;

interface

uses System.Classes, Outlook2010, Vcl.StdCtrls, FSMClass_Dic, FSMState;

type
  TGUIDFileName = record
    HasInput: boolean;
    FileName: string[255];
  end;

  TOLMsgFile4STOMP = record
    FHost, FUserId, FPasswd: string;
    FMsgFile: string;
  end;

  TEntryIdRecord = record
    FEntryId,
    FStoreId,
    FStoreId4Move,
    FFolderPath,
    FNewEntryId,
    FSubject,
    FTo,
    FHTMLBody,
    FHullNo,
    FAttached,
    FAttachFileName: string;
    FIgnoreReceiver2pjh: Boolean; //True = �����ڰ� pjh�ΰ� ������ ����
    FIgnoreEmailMove2WorkFolder: Boolean; //True = Working Folder�� �̵� ����
    //True = Move�ϰ��� ������ ���� �Ʒ��� HullNo Folder ���� �� ������ ������ ���� �̵� ��
    FIsCreateHullNoFolder: Boolean;
//    FIsShowMailContents: Boolean; //True = Mail Display
  end;

  TOLMsgFileRecord = record
    FEntryId,
    FStoreId,
    FSender,
    FReceiver,
    FCarbonCopy,
    FBlindCC,
    FSubject,
    FUserEmail,
    FUserName: string;
    FMailItem: MailItem;
    FReceiveDate: TDateTime;

    procedure Clear;
  end;

  TQueryDateType = (qdtNull, qdtInqRecv, qdtInvoiceIssue, qdtQTNInput,
    qdtOrderInput, qdtFinal);
  TElecProductType = (eptNull, eptEB, eptEC, eptEG, eptEM, eptER, eptFinal);
  TGSDocType = (dtNull,
              dtQuote2Cust4Material, dtQuote2Cust4Service, dtQuoteFromSubCon,
              dtPOFromCustomer, dtPO2SubCon,
              dtInvoice2Customer, dtInvoiceFromSubCon,
              dtSRFromSubCon,
              dtTaxBill2Customer, dtTaxBillFromSubCon,
              dtCompanySelection, dtConfirmComplete, dtBudgetApproval,
              dtContract, dtFinal);
  TGSInvoiceItemType = (iitNull, iitServiceReport, iitWorkDay, iitTravellingDay,
              iitMaterials, iitAirFare, iitAccommodation, iitTransportation,
              iitMeal, iitEtc, iitFinal);

  TCompanyType = (ctNull, ctNewCompany, ctMaker, ctOwner, ctAgent, ctCorporation, ctFinal);
  TSalesProcess = (spNone, spQtnReqRecvFromCust, spQtnReq2SubCon, spQtnRecvFromSubCon, spQtnSend2Cust,
    spSEAttendReqFromCust, spVslSchedReq2Cust, spSECanAvail2SubCon, spSEAvailRecvFromSubCon,
    spSECanAttend2Cust, spSEAttendConfirmFromCust, spPOReq2Cust, spPORecvFromCust, spSEDispatchReq2SubCon,//13
    spQtnInput, spQtnApproval, spOrderInput, spOrderApproval, spPORCreate, spPORCheck4HiPRO,//19
    spShipInstruct, spDelivery, spAWBRecv, spAWBSend2Cust, spSRRecvFromSubCon, //24
    spSRSend2Cust, spInvoiceRecvFromSubCon, spInvoiceSend2Cust, spInvoiceConfirmFromCust,//28
    spOrderPriceModify, spModifiedOrderApproval, spSalesPriceConfirm,
    spTaxBillReq2SubCon, spTaxBillIssue2Cust, spTaxBillRecvFromSubCon, spTaxBillSend2GeneralAffair, //35
    spSaleReq2GeneralAffair, spFinal //37
  );
  TSalesProcessType = (sptNone, sptForeignCustOnlyService, sptDomesticCustOnlyService,
    sptForeignCustOnlyMaterial,  sptDomesticCustOnlyMaterial,
    sptForeignCustWithServiceNMaterial, sptDomesticCustWithServiceNMaterial,
    sptForeignCustOnlyService4FieldService, sptDomesticCustOnlyService4FieldService,
    sptForeignCustWithServiceNMaterial4FieldService,
    sptDomesticCustWithServiceNMaterial4FieldService,
    sptFinal);
  TProcessDirection = (pdNone, pdToCustomer, pdFromCustomer, pdToSubCon, pdFromSubCon,
    pdToHElec, pdFromHElec, pdToHGS, pdFromHGS, pdFinal);
  TContainData4Mail = (cdmNone, cdmServiceReport,cdmQtn2Cust, cdmQtnFromSubCon,
    cdmPoFromCust, cdmPo2SubCon,cdmInvoice2Cust, cdmInvoiceFromSubCon,
    cdmTaxBillFromSubCon, cdmTaxBill2Cust, cdmFinal
  );
  TEngineerAgency = (eaNone, eaSubCon, eaHGS, eaHELEC);//�����Ͼ� �Ҽӻ�
  TCurrencyKind = (KW,USD,EUR);

const
  R_QueryDateType : array[qdtNull..qdtFinal] of record
    Description : string;
    Value       : TQueryDateType;
  end = ((Description : '';                        Value : qdtNull),
         (Description : 'Inq ������ ����';         Value : qdtInqRecv),
         (Description : 'Invoice ������ ����';     Value : qdtInvoiceIssue),
         (Description : 'QTN �Է��� ����';         Value : qdtQTNInput),
         (Description : '�����뺸�� �Է��� ����';  Value : qdtOrderInput),
         (Description : '';                        Value : qdtFinal)
         );

  R_ElecProductType : array[eptNull..eptFinal] of record
    Description : string;
    Value       : TElecProductType;
  end = ((Description : '';                   Value : eptNull),
         (Description : 'EB-���ܱ�';          Value : eptEB),
         (Description : 'EC-�����ڵ�ȭ';      Value : eptEC),
         (Description : 'EG-���庯�б�';      Value : eptEG),
         (Description : 'EM-������';          Value : eptEM),
         (Description : 'ER-������';          Value : eptER),
         (Description : 'ER-������';          Value : eptFinal)
         );

  R_GSDocType : array[dtNull..dtFinal] of record
    Description : string;
    Value       : TGSDocType;
  end = ((Description : '';                           Value : dtNull),
         (Description : '��ǰ ������(To ��)';       Value : dtQuote2Cust4Material),
         (Description : '���� ������(To ��)';     Value : dtQuote2Cust4Service),
         (Description : '��ǰ ������(From ���»�)';   Value : dtQuoteFromSubCon),
         (Description : 'PO(From ��)';              Value : dtPOFromCustomer),
         (Description : 'PO(To ���»�)';              Value : dtPO2SubCon),
         (Description : 'Invoice(To ��)';           Value : dtInvoice2Customer),
         (Description : 'Invoice(From ���»�)';       Value : dtInvoiceFromSubCon),
         (Description : 'Service Report';             Value : dtSRFromSubCon),
         (Description : '���ݰ�꼭(To ��)';        Value : dtTaxBill2Customer),
         (Description : '���ݰ�꼭(From ���»�)';    Value : dtTaxBillFromSubCon),
         (Description : '��ü����ǰ�Ǽ�';             Value : dtCompanySelection),
         (Description : '����Ϸ�Ȯ�μ�';             Value : dtConfirmComplete),
         (Description : '�������ǰ�Ǽ�';             Value : dtBudgetApproval),
         (Description : '��༭';                     Value : dtContract),
         (Description : '';                           Value : dtFinal)
         );

  R_CompanyType : array[ctNull..ctFinal] of record
    Description : string;
    Value       : TCompanyType;
  end = ((Description : '';                   Value : ctNull),
         (Description : '1.New Company';      Value : ctNewCompany),
         (Description : '3.Maker';            Value : ctMaker),
         (Description : '4.Owner';            Value : ctOwner),
         (Description : '6.Agent';            Value : ctAgent),
         (Description : 'B.����';             Value : ctCorporation),
         (Description : '';                   Value : ctFinal)
         );

  R_SalesProcess : array[spNone..spFinal] of record
    Description : string;
    Value       : TSalesProcess;
  end = ((Description : '';                         Value : spNone),
         (Description : '������û���� <- ��';     Value : spQtnReqRecvFromCust),
         (Description : '������û -> ���»�';       Value : spQtnReq2SubCon),
         (Description : '�������Լ� <- ���»�';     Value : spQtnRecvFromSubCon),
         (Description : '�������ۺ� -> ��';       Value : spQtnSend2Cust),
         (Description : 'SE�İ߿�û���� <- ��';   Value : spSEAttendReqFromCust),
         (Description : '���ڽ������û -> ��';   Value : spVslSchedReq2Cust),
         (Description : 'SE�İ߰��ɹ��� -> ���»�'; Value : spSECanAvail2SubCon),
         (Description : 'SE�İ߰���Ȯ�� <- ���»�'; Value : spSEAvailRecvFromSubCon),
         (Description : 'SE�İ߰����뺸 -> ��';   Value : spSECanAttend2Cust),
         (Description : 'PO�����û -> ��';       Value : spPOReq2Cust),
         (Description : 'SE�İ߿�ûȮ�� <- ��';   Value : spSEAttendConfirmFromCust),
         (Description : 'PO�Լ� <- ��';           Value : spPORecvFromCust),
         (Description : 'SE�İ߿�û -> ���»�';     Value : spSEDispatchReq2SubCon),
         (Description : 'QUOTATION�Է� -> MAPS';    Value : spQtnInput),
         (Description : 'QUOTATION���� -> MAPS';    Value : spQtnApproval),
         (Description : '�����뺸���Է� -> MAPS';   Value : spOrderInput),
         (Description : '�����뺸������ -> MAPS';   Value : spOrderApproval),
         (Description : 'POR ���� -> MAPS(POR����)';   Value : spPORCreate),
         (Description : 'POR����Ȯ�� -> Hi-PRO';    Value : spPORCheck4HiPRO),
         (Description : '�������õ�� -> MAPS';     Value : spShipInstruct),
         (Description : '������ -> �ù�';         Value : spDelivery),
         (Description : 'AWB�Լ� <- �ù�';          Value : spAWBRecv),
         (Description : 'AWB�ۺ� -> ��';          Value : spAWBSend2Cust),
         (Description : 'SR�Լ� <- ���»�';         Value : spSRRecvFromSubCon),
         (Description : 'SR�ۺ� -> ��';           Value : spSRSend2Cust),
         (Description : 'Invoice�Լ� <- ���»�';    Value : spInvoiceRecvFromSubCon),
         (Description : 'Invoice�ۺ� -> ��';      Value : spInvoiceSend2Cust),
         (Description : 'InvoiceȮ�� <- ��';      Value : spInvoiceConfirmFromCust),
         (Description : '�����뺸���ݾ׼��� -> MAPS';   Value : spOrderPriceModify),
         (Description : '�����뺸������� -> MAPS';     Value : spModifiedOrderApproval),
         (Description : '����ݾ�Ȯ�� -> MAPS(���������������)';   Value : spSalesPriceConfirm),
         (Description : '���ݰ�꼭�����û -> ���»�'; Value : spTaxBillReq2SubCon),
         (Description : '���ݰ�꼭���� -> ������';   Value : spTaxBillIssue2Cust),
         (Description : '���ݰ�꼭�Լ� <- ���»�'; Value : spTaxBillRecvFromSubCon),
         (Description : '���ݰ�꼭���� -> �����'; Value : spTaxBillSend2GeneralAffair),
         (Description : '����ó����û -> �����';   Value : spSaleReq2GeneralAffair),
         (Description : '�۾��Ϸ�';                 Value : spFinal));

  R_SalesProcessType : array[sptNone..sptFinal] of record
    Description : string;
    Value       : TSalesProcessType;
  end = ((Description : '';                           Value : sptNone),
         (Description : '����뿪-�ؿܰ�';          Value : sptForeignCustOnlyService),
         (Description : '���籸��-�ؿܰ�';          Value : sptForeignCustOnlyMaterial),
         (Description : '����뿪-������';          Value : sptDomesticCustOnlyService),
         (Description : '���籸��-������';          Value : sptDomesticCustOnlyMaterial),
         (Description : '����뿪/���籸��-�ؿܰ�'; Value : sptForeignCustWithServiceNMaterial),
         (Description : '����뿪/���籸��-������'; Value : sptDomesticCustWithServiceNMaterial),
         (Description : '����뿪-�ؿܰ�(Field Service)';          Value : sptForeignCustOnlyService4FieldService),
         (Description : '����뿪-������(Field Service)';          Value : sptDomesticCustOnlyService4FieldService),
         (Description : '����뿪/���籸��-�ؿܰ�(Field Service)'; Value : sptForeignCustWithServiceNMaterial4FieldService),
         (Description : '����뿪/���籸��-������(Field Service)'; Value : sptDomesticCustWithServiceNMaterial4FieldService),
         (Description : ''; Value : sptFinal)
  );

  R_ProcessDirection : array[pdNone..pdFinal] of record
    Description : string;
    Value       : TProcessDirection;
  end = ((Description : '';                 Value : pdNone),
         (Description : 'To ��';          Value : pdToCustomer),
         (Description : 'From ��';        Value : pdFromCustomer),
         (Description : 'To ���»�';        Value : pdToSubCon),
         (Description : 'From ���»�';      Value : pdFromSubCon),
         (Description : 'To �����Ϸ�Ʈ��';  Value : pdToHElec),
         (Description : 'From �����Ϸ�Ʈ��';Value : pdFromHElec),
         (Description : 'To HGS';           Value : pdToHGS),
         (Description : 'From HGS';         Value : pdToHGS),
         (Description : '';                 Value : pdFinal)
  );

  R_ContainData4Mail : array[cdmNone..cdmFinal] of record
    Description : string;
    Value       : TContainData4Mail;
  end = ((Description : '';                         Value : cdmNone),
         (Description : 'Service Report';             Value : cdmServiceReport),
         (Description : 'Quotation -> Customer';           Value : cdmQtn2Cust),
         (Description : 'Quotation <- SubCon';         Value : cdmQtnFromSubCon),
         (Description : 'PO <- Customer';               Value : cdmPoFromCust),
         (Description : 'PO <- SubCon';             Value : cdmPo2SubCon),
         (Description : 'Invoice -> Customer';          Value : cdmInvoice2Cust),
         (Description : 'Invoice <- SubCon';        Value : cdmInvoiceFromSubCon),
         (Description : 'Tax Bill <- SubCon';     Value : cdmTaxBillFromSubCon),
         (Description : 'Tax Bill -> Customer';       Value : cdmTaxBill2Cust),
         (Description : 'Tax Bill -> Customer';       Value : cdmFinal)
  );

  R_GSInvoiceItemType : array[iitNull..iitFinal] of record
    Description : string;
    Value       : TGSInvoiceItemType;
  end = ((Description : '';                         Value : iitNull),
         (Description : 'Service Report';           Value : iitServiceReport),
         (Description : 'Work Day';                 Value : iitWorkDay),
         (Description : 'Trevelling Day';           Value : iitTravellingDay),
         (Description : 'Materials';                Value : iitMaterials),
         (Description : 'Ex(Airfare)';        Value : iitAirFare),
         (Description : 'Ex(Accommodation)';  Value : iitAccommodation),
         (Description : 'Ex(Transportation)'; Value : iitTransportation),
         (Description : 'Ex(Meal)';           Value : iitMeal),
         (Description : 'Ex(Etc)';            Value : iitEtc),
         (Description : '';                         Value : iitFinal)
  );

  gpSHARED_DATA_NAME = 'SharedData_{BCB1C40A-3B72-44FC-9E72-91E5FF498924}';
  SHARED_DATA_NAME = 'SharedData_{32EF1528-1D5E-48AE-B8AF-341309C303FA}';

  CONSUME_EVENT_NAME = SHARED_DATA_NAME + '_ConsumeEvent';
  PRODUCE_EVENT_NAME = SHARED_DATA_NAME + '_ProduceEvent';

  EMAIL_TOPIC_NAME = '/topic/emailtopic';
  FOLDER_LIST_FILE_NAME = 'FolderList';
  IPC_SERVER_NAME_4_OUTLOOK = 'Mail2CromisIPCServer';
  //Response�� �ʿ��Ҷ� ���Ǵ� ������, �񵿱� ����� �ƴ�(�񵿱� ����� Response�� �ȵ�)
  IPC_SERVER_NAME_4_OUTLOOK2 = 'Mail2CromisIPCServer2';
  IPC_SERVER_NAME_4_INQMANAGE = 'Mail2CromisIPCClient';

  CMD_LIST = 'CommandList';
  CMD_SEND_MAIL_ENTRYID = 'Send Mail Entry Id';
  CMD_SEND_MAIL_ENTRYID2 = 'Send Mail Entry Id2';
  CMD_SEND_FOLDER_STOREID = 'Send Folder Store Id';
  CMD_RESPONDE_MOVE_FOLDER_MAIL = 'Resonse for Move Mail to Folder';
  CMD_REQ_MAIL_VIEW = 'Request Mail View';
  CMD_REQ_MAILINFO_SEND = 'Request Mail-Info to Send';
  //���ϸ���Ʈ���� ����, TaskID�� �ڵ����� ��
  CMD_REQ_MAILINFO_SEND2 = 'Request Mail-Info to Send2';
  CMD_REQ_MOVE_FOLDER_MAIL = 'Request Move Mail to Folder';
  CMD_REQ_REPLY_MAIL = 'Request Reply Mail';
  CMD_REQ_CREATE_MAIL = 'Request Create Mail';
  CMD_REQ_ADD_APPOINTMENT = 'Request Add Appointment';

  SALES_DIRECTOR_EMAIL_ADDR = 'shjeon@hyundai-gs.com';//����ó�������
  MATERIAL_INPUT_EMAIL_ADDR = 'geunhyuk.lim@pantos.com';//���������Կ�û
  FOREIGN_INPUT_EMAIL_ADDR = 'seryeongkim@hyundai-gs.com';//�ؿܰ���ü���
  ELEC_HULL_REG_EMAIL_ADDR = 'seryeongkim@hyundai-gs.com';//������ǥ�ذ��� ���� ��û
  PO_REQ_EMAIL_ADDR = 'seryeongkim@hyundai-gs.com';//PO ��û
  SHIPPING_REQ_EMAIL_ADDR = 'yungem.kim@pantos.com';//���� ��û

  MY_EMAIL_SIG = '��ǰ����2�� ������ ����';
  SHIPPING_MANAGER_SIG = '���佺 ������ ���Ӵ�';
  SALES_MANAGER_SIG = '��ǰ����1�� ������ �����';
  FIELDSERVICE_MANAGER_SIG = '�ʵ弭���� �̿��� �����';

  //Task�� Outlook ÷�����Ϸ� ���鶧 �ν��ϱ� ���� ���ڿ�
  TASK_JSON_DRAG_SIGNATURE = '{274C083F-EB64-49D8-ADE7-8804CFD0D030}';
  INVOICETASK_JSON_DRAG_SIGNATURE = '{144B4D16-A8E7-4E9A-89C1-994FE6AEC793}';

procedure OLMsgFileRecordClear;
function QueryDateType2String(AQueryDateType:TQueryDateType) : string;
function String2QueryDateType(AQueryDateType:string): TQueryDateType;
procedure QueryDateType2Combo(AComboBox:TComboBox);
function ElecProductType2String(AElecProductType:TElecProductType) : string;
function String2ElecProductType(AElecProductType:string): TElecProductType;
procedure ElecProductType2Combo(AComboBox:TComboBox);
function GSDocType2String(AGSDocType:TGSDocType) : string;
function String2GSDocType(AGSDocType:string): TGSDocType;
procedure GSDocType2Combo(AComboBox:TComboBox);
function CompanyType2String(ACompanyType:TCompanyType) : string;
function String2CompanyType(ACompanyType:string): TCompanyType;
procedure CompanyType2Combo(AComboBox:TComboBox);
function SalesProcess2String(ASalesProcess:TSalesProcess) : string;
function String2SalesProcess(ASalesProcess:string): TSalesProcess;
procedure SalesProcess2Combo(AComboBox:TComboBox);
function SalesProcessType2String(ASalesProcessType:TSalesProcessType) : string;
function String2SalesProcessType(ASalesProcessType:string): TSalesProcessType;
procedure SalesProcessType2Combo(AComboBox:TComboBox);
function ContainData4Mail2String(AContainData4Mail:TContainData4Mail) : string;
function String2ContainData4Mail(AContainData4Mail:string): TContainData4Mail;
procedure ContainData4Mail2Combo(AComboBox:TComboBox);
function ProcessDirection2String(AProcessDirection:TProcessDirection) : string;
function String2ProcessDirection(AProcessDirection:string): TProcessDirection;
procedure ProcessDirection2Combo(AComboBox:TComboBox);
procedure SalesProcess2List(AList: TStringList; AFSMState: TFSMState);
function GSInvoiceItemType2String(AGSInvoiceItemType:TGSInvoiceItemType) : string;
function String2GSInvoiceItemType(AGSInvoiceItemType:string): TGSInvoiceItemType;
procedure GSInvoiceItemType2Combo(AComboBox:TComboBox);

implementation

procedure OLMsgFileRecordClear;
begin
end;

{ TOLMsgFileRecord }

procedure TOLMsgFileRecord.Clear;
begin
  FEntryId := '';
  FStoreId := '';
  FSender := '';
  FReceiver := '';
  FCarbonCopy := '';
  FBlindCC := '';
  FSubject := '';
  FReceiveDate := 0;
  FMailItem := nil;
end;

function QueryDateType2String(AQueryDateType:TQueryDateType) : string;
begin
  if AQueryDateType <= High(TQueryDateType) then
    Result := R_QueryDateType[AQueryDateType].Description;
end;

function String2QueryDateType(AQueryDateType:string): TQueryDateType;
var Li: TQueryDateType;
begin
  for Li := qdtNull to qdtFinal do
  begin
    if R_QueryDateType[Li].Description = AQueryDateType then
    begin
      Result := R_QueryDateType[Li].Value;
      exit;
    end;
  end;
end;

procedure QueryDateType2Combo(AComboBox:TComboBox);
var Li: TQueryDateType;
begin
  AComboBox.Clear;

  for Li := qdtNull to Pred(qdtFinal) do
  begin
    AComboBox.Items.Add(R_QueryDateType[Li].Description);
  end;
end;

function ElecProductType2String(AElecProductType:TElecProductType) : string;
begin
  if AElecProductType <= High(TElecProductType) then
    Result := R_ElecProductType[AElecProductType].Description;
end;

function String2ElecProductType(AElecProductType:string): TElecProductType;
var Li: TElecProductType;
begin
  for Li := eptNull to eptFinal do
  begin
    if R_ElecProductType[Li].Description = AElecProductType then
    begin
      Result := R_ElecProductType[Li].Value;
      exit;
    end;
  end;
end;

procedure ElecProductType2Combo(AComboBox:TComboBox);
var Li: TElecProductType;
begin
  AComboBox.Clear;

  for Li := eptNull to Pred(eptFinal) do
  begin
    AComboBox.Items.Add(R_ElecProductType[Li].Description);
  end;
end;

function GSDocType2String(AGSDocType:TGSDocType) : string;
begin
  if AGSDocType <= High(TGSDocType) then
    Result := R_GSDocType[AGSDocType].Description;
end;

function String2GSDocType(AGSDocType:string): TGSDocType;
var Li: TGSDocType;
begin
  for Li := dtNull to dtFinal do
  begin
    if R_GSDocType[Li].Description = AGSDocType then
    begin
      Result := R_GSDocType[Li].Value;
      exit;
    end;
  end;
end;

procedure GSDocType2Combo(AComboBox:TComboBox);
var Li: TGSDocType;
begin
  AComboBox.Clear;

  for Li := dtNull to Pred(dtFinal) do
  begin
    AComboBox.Items.Add(R_GSDocType[Li].Description);
  end;
end;

function CompanyType2String(ACompanyType:TCompanyType) : string;
begin
  if ACompanyType <= High(TCompanyType) then
    Result := R_CompanyType[ACompanyType].Description;
end;

function String2CompanyType(ACompanyType:string): TCompanyType;
var Li: TCompanyType;
begin
  for Li := ctNull to ctFinal do
  begin
    if R_CompanyType[Li].Description = ACompanyType then
    begin
      Result := R_CompanyType[Li].Value;
      exit;
    end;
  end;
end;

procedure CompanyType2Combo(AComboBox:TComboBox);
var Li: TCompanyType;
begin
  AComboBox.Clear;

  for Li := ctNull to Pred(ctFinal) do
  begin
    AComboBox.Items.Add(R_CompanyType[Li].Description);
  end;
end;

function SalesProcess2String(ASalesProcess:TSalesProcess) : string;
begin
  if ASalesProcess <= High(TSalesProcess) then
    Result := R_SalesProcess[ASalesProcess].Description;
end;

function String2SalesProcess(ASalesProcess:string): TSalesProcess;
var Li: TSalesProcess;
begin
  for Li := spNone to spFinal do
  begin
    if R_SalesProcess[Li].Description = ASalesProcess then
    begin
      Result := R_SalesProcess[Li].Value;
      exit;
    end;
  end;
end;

procedure SalesProcess2Combo(AComboBox:TComboBox);
var
  Li: TSalesProcess;
  i: integer;
begin
  i := AComboBox.ItemIndex;
  AComboBox.Clear;

  for Li := spNone to spFinal do
  begin
    AComboBox.Items.Add(R_SalesProcess[Li].Description);
  end;

  AComboBox.ItemIndex := i;
end;

function SalesProcessType2String(ASalesProcessType:TSalesProcessType) : string;
begin
  if ASalesProcessType <= High(TSalesProcessType) then
    Result := R_SalesProcessType[ASalesProcessType].Description;
end;

function String2SalesProcessType(ASalesProcessType:string): TSalesProcessType;
var Li: TSalesProcessType;
begin
  for Li := sptNone to sptFinal do
  begin
    if R_SalesProcessType[Li].Description = ASalesProcessType then
    begin
      Result := R_SalesProcessType[Li].Value;
      exit;
    end;
  end;
end;

procedure SalesProcessType2Combo(AComboBox:TComboBox);
var Li: TSalesProcessType;
begin
  AComboBox.Clear;

  for Li := sptNone to Pred(sptFinal) do
  begin
    AComboBox.Items.Add(R_SalesProcessType[Li].Description);
  end;
end;

function ContainData4Mail2String(AContainData4Mail:TContainData4Mail) : string;
begin
  if AContainData4Mail <= High(TContainData4Mail) then
    Result := R_ContainData4Mail[AContainData4Mail].Description;
end;

function String2ContainData4Mail(AContainData4Mail:string): TContainData4Mail;
var Li: TContainData4Mail;
begin
  for Li := cdmNone to cdmFinal do
  begin
    if R_ContainData4Mail[Li].Description = AContainData4Mail then
    begin
      Result := R_ContainData4Mail[Li].Value;
      exit;
    end;
  end;
end;

procedure ContainData4Mail2Combo(AComboBox:TComboBox);
var Li: TContainData4Mail;
begin
  AComboBox.Clear;

  for Li := cdmNone to Pred(cdmFinal) do
  begin
    AComboBox.Items.Add(R_ContainData4Mail[Li].Description);
  end;
end;

function ProcessDirection2String(AProcessDirection:TProcessDirection) : string;
begin
  if AProcessDirection <= High(TProcessDirection) then
    Result := R_ProcessDirection[AProcessDirection].Description;
end;

function String2ProcessDirection(AProcessDirection:string): TProcessDirection;
var Li: TProcessDirection;
begin
  for Li := pdNone to pdFinal do
  begin
    if R_ProcessDirection[Li].Description = AProcessDirection then
    begin
      Result := R_ProcessDirection[Li].Value;
      exit;
    end;
  end;
end;

procedure ProcessDirection2Combo(AComboBox:TComboBox);
var Li: TProcessDirection;
begin
  AComboBox.Clear;

  for Li := pdNone to Pred(pdFinal) do
  begin
    AComboBox.Items.Add(R_ProcessDirection[Li].Description);
  end;
end;

procedure SalesProcess2List(AList: TStringList; AFSMState: TFSMState);
var
  LIntArr: TIntegerArray;
  i: integer;
begin
  AList.Clear;
  AList.Add('');
  LIntArr := AFSMState.GetOutputs;

  for i := Low(LIntArr) to High(LIntArr) do
    AList.Add(SalesProcess2String(TSalesProcess(LIntArr[i])));
end;

function GSInvoiceItemType2String(AGSInvoiceItemType: TGSInvoiceItemType) : string;
begin
  if AGSInvoiceItemType <= High(TGSInvoiceItemType) then
    Result := R_GSInvoiceItemType[AGSInvoiceItemType].Description;
end;

function String2GSInvoiceItemType(AGSInvoiceItemType: string): TGSInvoiceItemType;
var Li: TGSInvoiceItemType;
begin
  for Li := iitNull to iitFinal do
  begin
    if R_GSInvoiceItemType[Li].Description = AGSInvoiceItemType then
    begin
      Result := R_GSInvoiceItemType[Li].Value;
      exit;
    end;
  end;
end;

procedure GSInvoiceItemType2Combo(AComboBox: TComboBox);
var Li: TGSInvoiceItemType;
begin
  AComboBox.Clear;

  for Li := iitNull to Pred(iitFinal) do
  begin
    AComboBox.Items.Add(R_GSInvoiceItemType[Li].Description);
  end;
end;

end.
