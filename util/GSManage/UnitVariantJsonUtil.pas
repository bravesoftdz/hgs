unit UnitVariantJsonUtil;

interface

uses System.Classes, Dialogs, System.Rtti,
  NxColumnClasses, NxColumns, NxScrollControl, NxCustomGridControl, NxCustomGrid, NxGrid,
  Cromis.Comm.Custom, Cromis.Comm.IPC, Cromis.Threading, Cromis.AnyValue,
  CommonData, SynCommons, mORMot, DateUtils, System.SysUtils, UElecDataRecord,
  mORMotHttpClient, Winapi.ActiveX, Generics.Collections;

function MakeRawUTF8ToBin64(AUTF8: RawUTF8; AIsCompress: Boolean = True): string;
function MakeRawByteStringToBin64(ARaw: RawByteString; AIsCompress: Boolean = True): string;
function MakeBin64ToRawByteString(AStr: string; AIsCompress: Boolean = True): RawByteString;
function MakeEmailHTMLBody(ATask: TSQLGSTask; AMailType: integer;
  ASalesPICSig, ATaskAShippingPICSig, AFieldServicePICSig, AElecHullRegPICSig, AMyNameSig: string): string;
function MakeSalesReqEmailBody(ATask: TSQLGSTask; ASalesPICSig, AMyNameSig: string): string;
function MakeInvoiceEmailBody(ATask: TSQLGSTask): string;
function MakeDirectShippingEmailBody(ATask: TSQLGSTask): string;
function MakeForeignRegEmailBody(ATask: TSQLGSTask): string;
function MakeElecHullRegReqEmailBody(ATask: TSQLGSTask; AElecHullRegPICSig, AMyNameSig: string): string;
function MakePOReqEmailBody(ATask: TSQLGSTask): string;
function MakeShippingReqEmailBody(ATask: TSQLGSTask; AShippingPICSig, AMyNameSig: string): string;
function MakeForwardFieldServiceEmailBody(ATask: TSQLGSTask; AFieldServicePICSig, AMyNameSig: string): string;
function MakeForwardPayCheckSubConEmailBody(ATask: TSQLGSTask; AMyNameSig: string): string;
function MakeSubConQuotationReqEmailBody(ATask: TSQLGSTask; ASubConPICEMailAddr, ASubConPICSig, AMyNameSig: string): string;
function MakeForwardSubConPaymentReqEmailBody(ATask: TSQLGSTask; ASubConPaymentPICSig, AMyNameSig: string): string;
function MakeSubConServiceOrderReqEmailBody(ATask: TSQLGSTask; ASubConPICEMailAddr, ASubConPICSig, AMyNameSig: string): string;

function MakeTaskInfoEmailAttached(ATask: TSQLGSTask; var AFileName: string): string;
function MakeInvoiceTaskInfo2JSON(ATask: TSQLInvoiceTask; var AFileName: string): string;
function MakeInvoiceItemFromVar(ADoc: variant): string;

procedure GetInvoiceItem2Var(ADelimitedStr: string; var ADoc: variant);
function GetTaskInfoAttachedFileName(AVar: variant): string;
function GetInvoiceTaskInfoAttachedFileName(AVar: variant): string;
procedure LoadInvoiceTaskFromVariant(ATask:TSQLInvoiceTask; ADoc: variant);
procedure LoadInvoiceItemListFromVariant(ADoc: variant; AItemList: TObjectList<TSQLInvoiceItem>);
procedure LoadInvoiceItemFromVariant(AItem:TSQLInvoiceItem; ADoc: variant);
procedure LoadInvoiceFileListFromVariant(ADoc: variant; AFileList: TObjectList<TSQLInvoiceFile>);
procedure LoadInvoiceFileFromVariant(AFile:TSQLInvoiceFile; ADoc: variant);
procedure LoadInvoiceFileFromJSON(AFile:TSQLInvoiceFile; AJson: RawUTF8);

function GetMustacheJSONFromFile(ADoc: variant; AMustacheFile: string): string;
function GetMustacheJSONFromStr(ADoc: variant; AMustacheStr: string): string;
function MakeMailSubject(ATask: TSQLGSTask; AMailType: integer): string;

implementation

uses SynMustache, UnitMakeReport, UnitStringUtil, StrUtils;

function MakeDirectShippingEmailBody(ATask: TSQLGSTask): string;
var
  LDoc: variant;
  LSQLMaterial: TSQLMaterial4Project;
  LJSON: RawUTF8;
  LMustache: TSynMustache;
  LFile: RawByteString;
begin
  TDocVariant.New(LDoc);
  LDoc.OrderNo := ATask.ShipName;

  LSQLMaterial := GetMaterial4ProjFromTask(ATask);
  try
    LDoc.PorNo := LSQLMaterial.PORNo;
  finally
    FreeAndNil(LSQLMaterial);
  end;

  Result := GetMustacheJSONFromFile(LDoc, DOC_DIR + DIRECT_SHIPPING_MUSTACHE_FILE_NAME);
end;

function MakeElecHullRegReqEmailBody(ATask: TSQLGSTask; AElecHullRegPICSig, AMyNameSig: string): string;
var
  LDoc: variant;
  LJSON: RawUTF8;
  LMustache: TSynMustache;
  LFile: RawByteString;
  LSQLCustomer: TSQLCustomer;
begin
  TDocVariant.New(LDoc);
  LDoc.To := AElecHullRegPICSig;
  LDoc.From := AMyNameSig;
  LDoc.HullNo := ATask.HullNo;
  LDoc.Summary := ATask.WorkSummary;
  LDoc.ProductType := ATask.ProductType;

  LSQLCustomer := GetCustomerFromTask(ATask);
  try
    LDoc.CompanyName := LSQLCustomer.CompanyName;
    LDoc.CompanyCode := LSQLCustomer.CompanyCode;
  finally
    FreeAndNil(LSQLCustomer);
  end;

  Result := GetMustacheJSONFromFile(LDoc, DOC_DIR + ELEC_HULLNO_REG_REQ_MUSTACHE_FILE_NAME);
end;

function MakeForeignRegEmailBody(ATask: TSQLGSTask): string;
var
  LDoc: variant;
  LJSON: RawUTF8;
  LMustache: TSynMustache;
  LFile: RawByteString;
begin
  TDocVariant.New(LDoc);
  LDoc.CompanyName := ATask.ShipOwner;

  Result := GetMustacheJSONFromFile(LDoc, DOC_DIR + FOREIGN_REG_MUSTACHE_FILE_NAME);
end;

function MakeRawUTF8ToBin64(AUTF8: RawUTF8; AIsCompress: Boolean = True): string;
var
  LRaw: RawByteString;
begin
  LRaw := AUTF8;
  Result := MakeRawByteStringToBin64(LRaw, AIsCompress);
end;

function MakeRawByteStringToBin64(ARaw: RawByteString; AIsCompress: Boolean = True): string;
var
  LUTF8 : RawUTF8;
begin
  if AIsCompress then
    ARaw := SynLZCompress(ARaw);

  LUTF8 := BinToBase64(ARaw);
  Result := UTF8ToString(LUTF8);
end;

function MakeBin64ToRawByteString(AStr: string; AIsCompress: Boolean = True): RawByteString;
var
  LUTF8 : RawUTF8;
begin
  LUTF8 := StringToUTF8(AStr);
  Result := Base64ToBin(LUTF8);

  if AIsCompress then
    Result := SynLZDecompress(Result);
end;

function MakeEmailHTMLBody(ATask: TSQLGSTask; AMailType: integer;
  ASalesPICSig, ATaskAShippingPICSig, AFieldServicePICSig, AElecHullRegPICSig,
  AMyNameSig: string): string;
begin
  case AMailType of
    1: Result := MakeInvoiceEmailBody(ATask);
    2: Result := MakeSalesReqEmailBody(ATask, ASalesPICSig, AMyNameSig);
    3: Result := MakeDirectShippingEmailBody(ATask);
    4: Result := MakeForeignRegEmailBody(ATask);
    5: Result := MakeElecHullRegReqEmailBody(ATask, AElecHullRegPICSig, AMyNameSig);
    6: Result := MakePOReqEmailBody(ATask);
    7: Result := MakeShippingReqEmailBody(ATask, ATaskAShippingPICSig, AMyNameSig);
    8: Result := MakeForwardFieldServiceEmailBody(ATask, AFieldServicePICSig, AMyNameSig);
    9: Result := MakeForwardPayCheckSubConEmailBody(ATask, AMyNameSig);
//    10: Result := '[���� ���� ���� �� ȸ�� ��û] / ' + ATask.HullNo + ', �����ȣ: ' + ATask.Order_No;
//    11: Result := '[��ü �⼺ ó�� ��û] / ' + ATask.HullNo + ', �����ȣ: ' + ATask.Order_No;
  end;
end;

function MakeInvoiceEmailBody(ATask: TSQLGSTask): string;
var
  LDoc: variant;
  LSQLCustomer: TSQLCustomer;
begin
  TDocVariant.New(LDoc);
  LDoc.VesselName := ATask.ShipName;
  LDoc.HullNo := ATask.HullNo;
  LDoc.PONO := ATask.PO_No;
  LDoc.Location := ATask.NationPort;

  LSQLCustomer := GetCustomerFromTask(ATask);
  try
    LDoc.Name := LSQLCustomer.ManagerName;
  finally
    FreeAndNil(LSQLCustomer);
  end;

  Result := GetMustacheJSONFromFile(LDoc, DOC_DIR + INVOICE_SEND_MUSTACHE_FILE_NAME);
end;

function MakeMailSubject(ATask: TSQLGSTask; AMailType: integer): string;
begin
  case AMailType of
    1: Result := 'Send Invouice';
    2: Result := '[����ó�� ��û ��] ' + ATask.Order_No;
    3: Result := '�԰� ó�� ��û';
    4: Result := '�ؿܸ��� ���� �ŷ�ó ��� ��û�� ��';
    5: Result := '���� ��ǥ�� ���� ���� ��û �� (' + ATask.HullNo + ')';
    6: Result := MakeDirectShippingEmailBody(ATask);
    7: Result := '[���� ��û ��] / ' + ATask.ShippingNo;
    8: Result := '[�ʵ弭���� ���� ��û] / ' + ATask.HullNo + ', PO: ' + ATask.PO_No;
    9: Result := '[��ü �⼺ Ȯ�� ��û] / ' + ATask.HullNo + ', �����ȣ: ' + ATask.Order_No;
    10: Result := '[���� ���� ���� �� ȸ�� ��û] / ' + ATask.HullNo + ', �����ȣ: ' + ATask.Order_No;
    11: Result := '[��ü �⼺ ó�� ��û] / ' + ATask.HullNo + ', �����ȣ: ' + ATask.Order_No;
  end;
end;

function MakePOReqEmailBody(ATask: TSQLGSTask): string;
var
  LDoc: variant;
  LJSON: RawUTF8;
  LMustache: TSynMustache;
  LFile: RawByteString;
  LSQLCustomer: TSQLCustomer;
begin
  TDocVariant.New(LDoc);
  LDoc.HullNo := ATask.HullNo;
  LDoc.Summary := ATask.WorkSummary;
  LDoc.ProductType := ATask.ProductType;

  LSQLCustomer := GetCustomerFromTask(ATask);
  try
    LDoc.CompanyName := LSQLCustomer.CompanyName;
    LDoc.CompanyCode := LSQLCustomer.CompanyCode;
  finally
    FreeAndNil(LSQLCustomer);
  end;

  Result := GetMustacheJSONFromFile(LDoc, DOC_DIR + PO_REQ_MUSTACHE_FILE_NAME);
end;

function MakeSalesReqEmailBody(ATask: TSQLGSTask; ASalesPICSig, AMyNameSig: string): string;
var
  LDoc: variant;
  LSQLCustomer: TSQLCustomer;
  LDate: TDate;
  LPrice: string;
begin
  TDocVariant.New(LDoc);
  LDoc.To := ASalesPICSig;// SALES_MANAGER_SIG;
  LDoc.From := AMyNameSig;//MY_EMAIL_SIG;
  LDoc.OrderNo := ATask.Order_No;
  LPrice := UTF8ToString(ATask.SalesPrice);

  if not ContainsText(LPrice, ',') then
    LPrice := AddThousandSeparator(LPrice,',');

  LDoc.SalesPrice :=
    TRttiEnumerationType.GetName<TCurrencyKind>(TCurrencyKind(ATask.CurrencyKind)) +
     ' ' + LPrice;
  LDoc.ShippingNo := ATask.ShippingNo;

  LDate := TimeLogToDateTime(ATask.SalesReqDate);

  if YearOf(LDate) > 1900 then
    LDoc.SalesReqDate := FormatDateTime('yyyy-mm-dd',LDate)
  else
    LDoc.SalesReqDate := 'NIL';

  LSQLCustomer := GetCustomerFromTask(ATask);
  try
    LDoc.CustName := LSQLCustomer.CompanyName;
    LDoc.CustNo := LSQLCustomer.CompanyCode;
  finally
    FreeAndNil(LSQLCustomer);
  end;

  Result := GetMustacheJSONFromFile(LDoc, DOC_DIR + SALES_MUSTACHE_FILE_NAME);
//  QuotedStrJSON(VariantToUTF8(LDoc), LJSON);
end;

function MakeShippingReqEmailBody(ATask: TSQLGSTask;
  AShippingPICSig, AMyNameSig: string): string;
var
  LDoc: variant;
  LSQLMaterial4Project: TSQLMaterial4Project;
  LDate: TDate;
begin
  TDocVariant.New(LDoc);
  LDoc.To := AShippingPICSig;// SHIPPING_MANAGER_SIG;
  LDoc.From := AMyNameSig;// MY_EMAIL_SIG;
  LDoc.ShippingNo := ATask.ShippingNo; //�������ù�ȣ
  LDoc.OrderNo := ATask.Order_No;//�������ù�ȣ
  LDoc.PONo := ATask.PO_No;
  LDoc.ShipName := ATask.ShipName;

  LSQLMaterial4Project := GetMaterial4ProjFromTask(ATask);
  try
    LDoc.DeliveryAddr := LSQLMaterial4Project.DeliveryAddress;
  finally
    FreeAndNil(LSQLMaterial4Project);
  end;

  Result := GetMustacheJSONFromFile(LDoc, DOC_DIR + SHIPPING_MUSTACHE_FILE_NAME);
end;

function MakeForwardFieldServiceEmailBody(ATask: TSQLGSTask;
  AFieldServicePICSig, AMyNameSig: string): string;
var
  LDoc: variant;
  LSQLCustomer: TSQLCustomer;
  LDate: TDate;
begin
  TDocVariant.New(LDoc);
  LDoc.To := AFieldServicePICSig;// FIELDSERVICE_MANAGER_SIG;
  LDoc.From := AMyNameSig;//MY_EMAIL_SIG;
  LDoc.Summary := ATask.WorkSummary;
  LDoc.WorkDay := FormatDateTime('yyyy-mm-dd', TimeLogToDateTime(ATask.WorkBeginDate));
  LDoc.Port := ATask.NationPort;
  LDoc.WorkOrder := ATask.Order_No;

  if ATask.ID <> 0 then
  begin
    LSQLCustomer := GetCustomerFromTask(ATask);
    try
      LDoc.LocalAgent := LSQLCustomer.AgentInfo;
    finally
      FreeAndNil(LSQLCustomer);
    end;
  end
  else
    LDoc.LocalAgent := ATask.EtcContent;

  Result := GetMustacheJSONFromFile(LDoc, DOC_DIR + FORWARD_FIELDSERVICE_MUSTACHE_FILE_NAME);
end;

function MakeForwardPayCheckSubConEmailBody(ATask: TSQLGSTask; AMyNameSig: string): string;
var
  LDoc: variant;
  LSQLMaterial4Project: TSQLMaterial4Project;
  LDate: TDate;
begin
  TDocVariant.New(LDoc);
  LDoc.To := '���� ����ڴ�';// SHIPPING_MANAGER_SIG;
  LDoc.From := AMyNameSig;// MY_EMAIL_SIG;
  LDoc.HullNo := ATask.HullNo; //ȣ����ȣ
  LDoc.OrderNo := ATask.Order_No;//�������ù�ȣ
  LDoc.ShipName := ATask.ShipName;

  Result := GetMustacheJSONFromFile(LDoc, DOC_DIR + PAYCHECK_SUBCON_MUSTACHE_FILE_NAME);
end;

function MakeSubConQuotationReqEmailBody(ATask: TSQLGSTask; ASubConPICEMailAddr, ASubConPICSig, AMyNameSig: string): string;
begin

end;

function MakeForwardSubConPaymentReqEmailBody(ATask: TSQLGSTask; ASubConPaymentPICSig, AMyNameSig: string): string;
begin

end;

function MakeSubConServiceOrderReqEmailBody(ATask: TSQLGSTask; ASubConPICEMailAddr, ASubConPICSig, AMyNameSig: string): string;
begin

end;

function MakeTaskInfoEmailAttached(ATask: TSQLGSTask; var AFileName: string): string;
var
  LUtf8: RawUTF8;
  LDynArr: TDynArray;
  LCount: integer;
  LCustomer: TSQLCustomer;
  LSubCon: TSQLSubCon;
  LMat4Proj: TSQLMaterial4Project;
  LV,LV2,LV3: variant;
  LRaw: RawByteString;
begin
  TDocVariant.New(LV);
  LV.TaskJsonDragSign := TASK_JSON_DRAG_SIGNATURE;
  try
    LUtf8 := ATask.GetJSONValues(true, true, soSelect);
    LV.Task := _JSON(LUtf8);

    LCustomer := GetCustomerFromTask(ATask);
    LUtf8 := LCustomer.GetJSONValues(true, true, soSelect);
    LV.Customer := _JSON(LUtf8);

    LSubCon := GetSubConFromTask(ATask);
    LUtf8 := LSubCon.GetJSONValues(true, true, soSelect);
    LV.SubCon := _JSON(LUtf8);;

    LMat4Proj := GetMaterial4ProjFromTask(ATask);
    LUtf8 := LMat4Proj.GetJSONValues(true, true, soSelect);
    LV.Mat4Proj := _JSON(LUtf8);

//    LUtf8 := VariantSaveJSON(LV);
    LUtf8 := LV;
//    LRaw := UTF8ToAnsi(LUtf8);
    Result := MakeRawUTF8ToBin64(LUtf8);
//    LRaw := LUtf8;
//    LRaw := SynLZCompress(LRaw);
//    LUtf8 := BinToBase64(LRaw);
//    Result := UTF8ToString(LUtf8);
    AFileName := GetTaskInfoAttachedFileName(LV);
  finally
    FreeAndNil(LCustomer);
    FreeAndNil(LSubCon);
    FreeAndNil(LMat4Proj);
  end;
end;

function MakeInvoiceTaskInfo2JSON(ATask: TSQLInvoiceTask; var AFileName: string): string;
var
  LUtf8: RawUTF8;
  LDynUtf8: TRawUTF8DynArray;
  LDynArr: TDynArray;
  LCount, i: integer;
  LInvoiceItem: TSQLInvoiceItem;
  LInvoiceFile: TSQLInvoiceFile;
  LV,LV2,LV3: variant;
  LRaw: RawByteString;
  LResult: Boolean;
begin
  TDocVariant.New(LV);
  LV.TaskJsonDragSign := TASK_JSON_DRAG_SIGNATURE;
  LV.InvoiceTaskJsonDragSign := INVOICETASK_JSON_DRAG_SIGNATURE;

  LDynArr.Init(TypeInfo(TRawUTF8DynArray), LDynUtf8);
  try
    LUtf8 := ATask.GetJSONValues(true, true, soSelect);
    LV.Task := _JSON(LUtf8);

    LInvoiceItem := GetItemsFromInvoiceTask(ATask);

    while LInvoiceItem.FillOne do
    begin
      LUtf8 := LInvoiceItem.GetJSONValues(true, true, soSelect);
      LDynArr.Add(LUtf8);
    end;

    LUtf8 := LDynArr.SaveToJSON;
    LV.InvoiceItem := _JSON(LUtf8);

    LDynArr.Clear;
    LInvoiceFile := GetFilesFromInvoiceTask(ATask);

    while LInvoiceFile.FillOne do
    begin
//      LUtf8 := LInvoiceFile.GetJSONValues(true, true, soSelect);
//      LDynArr.Add(LUtf8);
      LUtf8 := ObjectToJson(LInvoiceFile);
      LDynArr.Add(LUtf8);
//      LDynArr.SaveTo.Add(LRaw);
    end;

    LUtf8 := LDynArr.SaveToJSON;
    LV.InvoiceFile := _JSON(LUtf8);;
//    LUtf8 := VariantSaveJSON(LV);
    LUtf8 := LV;

//    LDynArr.LoadFromJSON(Pointer(LUtf8));
//    LUtf8 := LDynUtf8[i];
//    LInvoiceFile.DynArray('Files').Clear;
//    JsonToObject(LInvoiceFile, PUtf8Char(LUtf8), LResult);

//    LRaw := UTF8ToAnsi(LUtf8);
    LRaw := LUtf8;
//    ShowMessage(IntToStr(Length(LRaw)));
    LRaw := SynLZCompress(LRaw);
//    ShowMessage(IntToStr(Length(LRaw)));
    LUtf8 := BinToBase64(LRaw);
    Result := UTF8ToString(LUtf8);
    AFileName := GetInvoiceTaskInfoAttachedFileName(LV);
  finally
    FreeAndNil(LInvoiceItem);
    FreeAndNil(LInvoiceFile);
  end;
end;

function MakeInvoiceItemFromVar(ADoc: variant): string;
var
  LInvoiceItemType: TGSInvoiceItemType;
  LItemStr: string;
begin
  LInvoiceItemType := String2GSInvoiceItemType(ADoc.ItemType);

  case LInvoiceItemType of
    iitWorkDay: LItemStr := INVOICE_ITEM_SE_CHARGE;
    iitTravellingDay: LItemStr := INVOICE_ITEM_TRAVELLING_CHARGE;
    iitMaterials: LItemStr := INVOICE_ITEM_MATERIAL_CHARGE;
    iitAirFare: LItemStr := INVOICE_ITEM_FLIGHT_FEE;
    iitAccommodation: LItemStr := INVOICE_ITEM_ACCOMMODATION_FEE;
    iitTransportation: LItemStr := INVOICE_ITEM_TRANSPORTATION_FEE;
    iitMeal: LItemStr := INVOICE_ITEM_MEAL_FEE;
  end;

  Result := GetMustacheJSONFromStr(ADoc, LItemStr);
end;

procedure GetInvoiceItem2Var(ADelimitedStr: string; var ADoc: variant);
begin
  ADoc.ItemType := strToken(ADelimitedStr, ';');
  ADoc.NumOfWorker := strToken(ADelimitedStr, ';');
  ADoc.Qty := strToken(ADelimitedStr, ';');
  ADoc.FUnit := strToken(ADelimitedStr, ';');
  ADoc.UnitPrice := strToken(ADelimitedStr, ';');
  ADoc.TotalPrice := strToken(ADelimitedStr, ';');
end;

function GetTaskInfoAttachedFileName(AVar: variant): string;
begin
  Result := AVar.Task.HullNo + '_' + AVar.Task.ShipName;

  if AVar.Task.PO_No <> '' then
    Result := Result + '(' + AVar.Task.PO_No + ')';

  Result := StringReplace(Result, '/', '_', [rfReplaceAll]);
  Result := StringReplace(Result, ' ', '_', [rfReplaceAll]) + '.hgs';
end;

function GetInvoiceTaskInfoAttachedFileName(AVar: variant): string;
begin
  Result := AVar.Task.HullNo + '_' + AVar.Task.ShipName;

  if AVar.Task.Order_No <> '' then
    Result := Result + '(' + AVar.Task.Order_No + ')';

  Result := StringReplace(Result, '/', '_', [rfReplaceAll]);
  Result := StringReplace(Result, ' ', '_', [rfReplaceAll]) + '.hgs';
end;

procedure LoadInvoiceTaskFromVariant(ATask:TSQLInvoiceTask; ADoc: variant);
begin
  if ADoc = null then
    exit;

  ATask.HullNo := ADoc.HullNo;
  ATask.ShipName := ADoc.ShipName;
  ATask.Order_No := ADoc.Order_No;
  ATask.WorkSummary := ADoc.WorkSummary;
  ATask.NationPort := ADoc.NationPort;
  ATask.EtcContent := ADoc.EtcContent;
  ATask.ShipOwner := ADoc.ShipOwner;
  ATask.ChargeInPersonId := ADoc.ChargeInPersonId;

  ATask.SEList := ADoc.SEList;

  ATask.InqRecvDate := ADoc.InqRecvDate;
  ATask.InvoiceIssueDate := ADoc.InvoiceIssueDate;
  ATask.AttendScheduled := ADoc.AttendScheduled;
  ATask.WorkBeginDate := ADoc.WorkBeginDate;
  ATask.WorkEndDate := ADoc.WorkEndDate;
  ATask.UniqueTaskID := ADoc.UniqueTaskID;

  if ADoc.CustCompanyCode <> '' then
    ATask.CustCompanyCode := ADoc.CustCompanyCode;
  ATask.CustEMail := ADoc.CustEMail;
  ATask.CustCompanyName := ADoc.CustCompanyName;
  ATask.CustMobilePhone := ADoc.CustMobilePhone;
  ATask.CustOfficePhone := ADoc.CustOfficePhone;
  ATask.CustCompanyAddress := ADoc.CustCompanyAddress;
  ATask.CustPosition := ADoc.CustPosition;
  ATask.CustManagerName := ADoc.CustManagerName;
  ATask.CustNation := ADoc.CustNation;
  ATask.CustAgentInfo := ADoc.CustAgentInfo;

  ATask.SubConCompanyCode := ADoc.SubConCompanyCode;
  ATask.SubConEMail := ADoc.SubConEMail;
  ATask.SubConCompanyName := ADoc.SubConCompanyName;
  ATask.SubConMobilePhone := ADoc.SubConMobilePhone;
  ATask.SubConOfficePhone := ADoc.SubConOfficePhone;
  ATask.SubConCompanyAddress := ADoc.SubConCompanyAddress;
  ATask.SubConPosition := ADoc.SubConPosition;
  ATask.SubConManagerName := ADoc.SubConManagerName;
  ATask.SubConNation := ADoc.SubConNation;
end;

procedure LoadInvoiceItemListFromVariant(ADoc: variant; AItemList: TObjectList<TSQLInvoiceItem>);
var
  LDynUtf8: TRawUTF8DynArray;
  LDynArr: TDynArray;
  LUtf8: RawUTF8;
  i: integer;
  LDoc: variant;
  LItem: TSQLInvoiceItem;
  LTaskID, LItemID: TID;
  LUniqueItemID: RawUTF8;
begin
  if ADoc = null then
    exit;

  LUtf8 := ADoc;
  LDynArr.Init(TypeInfo(TRawUTF8DynArray), LDynUtf8);
  LDynArr.LoadFromJSON(PUTF8Char(LUtf8));

  for i := 0 to LDynArr.Count - 1 do
  begin
//    LItem := TSQLInvoiceItem.Create;
    LDoc := _JSON(LDynUtf8[i]);
    LTaskID := LDoc.TaskID;
    LItemID := LDoc.ItemID;
    LUniqueItemID := LDoc.UniqueItemID;

//    LItem := GetInvoiceItemFromID(LTaskID, LItemID);
    LItem := GetInvoiceItemFromUniqueID(LUniqueItemID);
    LItem.IsUpdate := LItem.FillOne;

    AItemList.Add(LItem);

    LoadInvoiceItemFromVariant(LItem, LDoc);
  end;
end;

procedure LoadInvoiceItemFromVariant(AItem:TSQLInvoiceItem; ADoc: variant);
begin
  AItem.UniqueItemID := ADoc.UniqueItemID;
  AItem.ItemID := ADoc.RowID;
  AItem.TaskID := ADoc.TaskID;
  AItem.ItemDesc := ADoc.ItemDesc;
  AItem.Qty := ADoc.Qty;
  AItem.fUnit := ADoc.fUnit;
  AItem.UnitPrice := ADoc.UnitPrice;
  AItem.TotalPrice := ADoc.TotalPrice;
  AItem.InvoiceItemType := ADoc.InvoiceItemType;
end;

procedure LoadInvoiceFileListFromVariant(ADoc: variant; AFileList: TObjectList<TSQLInvoiceFile>);
var
  LDynUtf8: TRawUTF8DynArray;
  LDynArr: TDynArray;
  LUtf8: RawUTF8;
  i: integer;
  LDoc: variant;
  LFile: TSQLInvoiceFile;
  LTaskID, LItemID: TID;
begin
  if ADoc = null then
    exit;

  LUtf8 := ADoc;
  LDynArr.Init(TypeInfo(TRawUTF8DynArray), LDynUtf8);
  LDynArr.LoadFromJSON(PUTF8Char(LUtf8));

  for i := 0 to LDynArr.Count - 1 do
  begin
//    LFile := TSQLInvoiceFile.Create;
    LDoc := _JSON(LDynUtf8[i]);
    LUtf8 := LDynUtf8[i];
    LTaskID := LDoc.TaskID;
    LItemID := LDoc.ItemID;
    LFile := GetInvoiceFileFromID(LTaskID, LItemID);
    LFile.FillOne;
    AFileList.Add(LFile);

    LoadInvoiceFileFromJSON(LFile, LUtf8);
//    LoadInvoiceFileFromVariant(LFile, LDoc);
  end;
end;

procedure LoadInvoiceFileFromVariant(AFile:TSQLInvoiceFile; ADoc: variant);
var
  LUtf8 : RawUTF8;
  LRaw, LRaw2: RawByteString;
  LFile: TSQLInvoiceFile;
  LDynArr: TDynArray;
  LResult: Boolean;
begin
  if ADoc = null then
    exit;

//  AFile.TaskID := ADoc.TaskID;
//  AFile.ItemID := ADoc.ItemID;
//  AFile.ItemIndex := ADoc.ItemIndex;

  LUtf8 := ADoc;
//  LFile := TSQLInvoiceFile.Create;
  AFile.DynArray('Files').Clear;
  LUtf8 := JsonToObject(AFile, PUtf8Char(LUtf8), LResult);
//  LFile.Free;

//  AFile.DynArray('Files').Clear;
//  LUtf8 := ADoc.Files;
//  LDynArr.Init(TypeInfo(TSQLInvoiceFileRecs), LFiles);
//  DynArrayLoadJson(LFiles, Pointer(LUtf8), TypeInfo(TSQLInvoiceFileRecs));

//  AFile.DynArray('Files').Copy(LDynArr);
//  .AddArray(LFiles);
//  AFile.DynArray('Files').LoadFromJSON(PUTF8Char(LUTF8));
//  AFile.Files := ADoc.Files;
end;

procedure LoadInvoiceFileFromJSON(AFile:TSQLInvoiceFile; AJson: RawUTF8);
var
  LUtf8 : RawUTF8;
  LResult: Boolean;
begin
  AFile.DynArray('Files').Clear;
  LUtf8 := JsonToObject(AFile, PUtf8Char(AJson), LResult);
end;

function GetMustacheJSONFromFile(ADoc: variant;
  AMustacheFile: string): string;
var
  LJSON: RawUTF8;
  LMustache: TSynMustache;
  LFile: RawByteString;
begin
  LJSON := Utf8ToString(VariantSaveJson(ADoc));
  LFile := StringFromFile(AMustacheFile);
  LMustache := TSynMustache.Parse(LFile);
  Result := Utf8ToString(BinToBase64(LMustache.RenderJSON(LJSON)));
end;

function GetMustacheJSONFromStr(ADoc: variant; AMustacheStr: string): string;
var
  LJSON: RawUTF8;
  LMustache: TSynMustache;
//  LStr: RawUTF8;
begin
  LJSON := Utf8ToString(VariantSaveJson(ADoc));
  LMustache := TSynMustache.Parse(AMustacheStr);
  Result := LMustache.RenderJSON(LJSON);
end;

end.
