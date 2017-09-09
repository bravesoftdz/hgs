unit UnitBWQuery;

interface

uses System.SysUtils, System.StrUtils, SynCommons, Generics.Collections,MSHTML,Activex,
  OtlTask, OtlCommon, OtlCollections, OtlParallel, OtlTaskControl, TimerPool,
  OmniXML, OmniXMLUtils, OmniXMLXPath,
  AdvGrid, IdHTTP, DateUtils, BW_Query_Class, mORMot, UnitFrameCommServer,
  RMISConst, Dialogs, BW_Query_Data_Class;

type
  TBWQuery = class
    FPJHTimerPool: TPJHTimerPool;
    FXMLFromQry: string;
    FCurQryKey: String;//FBWQryList�߿��� ���� ���� ���� Query Key string�� ������
    FQryCount: integer;
    FGetBWQryFuture: IOmniFuture<Boolean>;
    FGetQrying: Boolean;

    procedure ProcessQueryXML(AXMLString: string; const task: IOmniTask);
    procedure LoadQueryListFromTxt;
    procedure LoadInquiryList(ABWQryClass: TBWQryClass);
    procedure ClearInqryList;
    function GetCurQryClass: TBWQryClass;
    function GetQueryType(AQueryName: string): integer;
    procedure ChangeDataFormat;

    procedure OnGetBWQuery(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);

    procedure OnGetBWQueryCompleted(const task: IOmniTaskControl);
    procedure OnGetOrderPlanPerProductCompleted(const task: IOmniTaskControl);
    procedure OnGetSalesPlanPerProductCompleted(const task: IOmniTaskControl);
    procedure OnGetProfitPlanPerProductCompleted(const task: IOmniTaskControl);

    function GetBWQuery(const task: IOmniTask): boolean;
    function SetQryParamType(AQryText: string; const AParamName: string;
      AParamType: TQryParameterType; AParamDir: TQryParameterDir; ADate: TDate): string;
    function GetEndOfMonth(ADate: TDate): string;
    function GetOrderPlanPerProduct(const task: IOmniTask): boolean;
    //ARow: ���� ��ȹ�� ��� ��ǰ��(����/����/������ ��)�� �������Ƿ� �濵��ȹ�� �ִ� ��(ARow)�� ���� ��
    //      ����/������ ��� ��ǰ���� �ƴ� �ι���(�ڿ�/����/�κ� ��) �̹Ƿ� ARow = 0���� ó����.
    //AExcludeRow: ���� ū Row�� �ǳʶ�
    procedure _GetBizPlanPerProduct(AQryName: string; ARow: integer; ACollect: TBWQryCellDataCollect; AExcludeRow: integer = -1);
    function GetSalesPlanPerProduct(const task: IOmniTask): boolean;
    function GetProfitPlanPerProduct(const task: IOmniTask): boolean;

    function getContent(url: String): String;
    procedure HeaderData2Grid(ABWQryClass: TBWQryClass; AGrid: TAdvStringGrid);
    //���� �Ϻ� �ι���;ZKA_ZKSDINM01_D_L_Q201 �������� �ش� ��
    procedure RowHeaderNCellData2Grid(ABWQryClass: TBWQryClass; AGrid: TAdvStringGrid);
    procedure ColumnHeaderNCellData2Grid(ABWQryClass: TBWQryClass; AGrid: TAdvStringGrid);

  public
    FExeFilePath: string;
    FIsFirstDataArrived: Boolean;//���� ���� �Ϸ� �� True ��
    FBWQryDataClass: TBWQryDataClass;

    constructor Create;
    destructor Destroy;

    procedure QryData2DataView(AQueryName: string);
    function GetColumnHeaderDataAll: Boolean;
    function GetRowHeaderDataAll: Boolean;
    function GetQueryClass(AQueryName: string): TBWQryClass;

  end;

implementation

uses UnitDataView;

{ TBWQuery }

procedure TBWQuery.ChangeDataFormat;
var
  LKey, LStr: string;
  LBWQryClass: TBWQryClass;
  i: integer;
  Ldouble: double;
begin
  for LKey in FBWQryDataClass.FBWQryList.Keys do
  begin
    LBWQryClass := FBWQryDataClass.FBWQryList.Items[LKey];
    for i := 0 to LBWQryClass.BWQryCellDataCollect.Count - 1 do
    begin
      LStr := LBWQryClass.BWQryCellDataCollect.Items[i].CellData;

      if (LStr <> '') and (Pos('.', LStr) = 0) and (Pos(',', LStr) = 0)then
      begin
        Ldouble := StrToFloatDef(LStr,0.0);
        LBWQryClass.BWQryCellDataCollect.Items[i].CellData := FormatFloat('#,##0', Ldouble);
      end;
    end;
  end;
end;

procedure TBWQuery.ClearInqryList;
var
  LKey: integer;
begin
  for LKey in FBWQryDataClass.FInquiryList.Keys do
    TInquiryInfo(FBWQryDataClass.FInquiryList.Items[LKey]).Free;

  FBWQryDataClass.FInquiryList.Clear;
end;


procedure TBWQuery.ColumnHeaderNCellData2Grid(ABWQryClass: TBWQryClass;
  AGrid: TAdvStringGrid);
var
  i, LCol, LRow: integer;
begin
  AGrid.ColCount := ABWQryClass.BWQryColumnHeaderCollect.Count;
  AGrid.FixedRows := ABWQryClass.BWQryColumnHeaderCollect.FixedColumnCount;
  AGrid.FixedCols := ABWQryClass.BWQryRowHeaderCollect.ColCountOfRow+1;

  for i := 0 to ABWQryClass.BWQryCellDataCollect.Count - 1 do
  begin
    LCol := ABWQryClass.BWQryCellDataCollect.Items[i].Col + AGrid.FixedCols;
    LRow := ABWQryClass.BWQryCellDataCollect.Items[i].Row + AGrid.FixedRows;
    AGrid.Cells[LCol, LRow] := ABWQryClass.BWQryCellDataCollect.Items[i].CellData;
  end;
end;

constructor TBWQuery.Create;
begin
  FPJHTimerPool := TPJHTimerPool.Create(nil);
  FBWQryDataClass := TBWQryDataClass.Create;

  LoadQueryListFromTxt;
  FPJHTimerPool.AddOneShot(OnGetBWQuery, 500);
  FIsFirstDataArrived := False;
end;

destructor TBWQuery.Destroy;
begin
  FPJHTimerPool.RemoveAll;
  FPJHTimerPool.Free;
  FBWQryDataClass.Free;
  ClearInqryList;
end;

function TBWQuery.GetBWQuery(const task: IOmniTask): boolean;
var
  WaitResult: Integer;
  LKey, LQryTxt, LNewQryTxt: string;
  LQryParamType: TQryParameterType;
begin
//  QProgress1.Active := True;
//  FQryRunning := True;
//  Panel1.Caption := '�ڷ� ���� ��...';
  {$IFDEF USECODESITE}
  CodeSite.EnterMethod('TMainForm.GetBWQuery Begin ===>');
  try
//    CodeSite.Send('Msg.WParam', Ord(LDragCopyMode));
  finally
    CodeSite.ExitMethod('TTMainForm.GetBWQuery <===');
  end;
  {$ENDIF}

  FGetQrying := True;
  FQryCount := 0;

  for LKey in FBWQryDataClass.FBWQryList.Keys do
  begin
    if task.CancellationToken.IsSignalled then
      break;

    LQryTxt := FBWQryDataClass.FBWQryList.Items[LKey].QueryText;
    LQryParamType := FBWQryDataClass.FBWQryList.Items[LKey].QryParamType;

    if Pos('VAR_VALUE_LOW_EXT_2=', LQryTxt) > 0  then
    begin
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_LOW_EXT_2=', LQryParamType, qpdBegin, Date);
//      LNewQryTxt :=  + FormatDateTime('yyyy', Date) + '0101';
//      LQryTxt := StringReplace(LQryTxt, 'VAR_VALUE_LOW_EXT_2=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
    end;

    if Pos('VAR_VALUE_HIGH_EXT_2=', LQryTxt) > 0  then
    begin
//      LNewQryTxt := 'VAR_VALUE_HIGH_EXT_2=' + FormatDateTime('yyyymmdd', now);
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_HIGH_EXT_2=', LQryParamType, qpdCustom, Date);
//      StringReplace(LQryTxt, 'VAR_VALUE_HIGH_EXT_2=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
    end;

    if Pos('VAR_VALUE_EXT_1=', LQryTxt) > 0  then
    begin
//      LNewQryTxt := 'VAR_VALUE_EXT_1=' + FormatDateTime('yyyymmdd', now);
//      LQryTxt := StringReplace(LQryTxt, 'VAR_VALUE_EXT_1=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_EXT_1=', LQryParamType, qpdCustom, Date);
    end;

    if Pos('VAR_VALUE_LOW_EXT_1=', LQryTxt) > 0  then
    begin
//      LNewQryTxt := 'VAR_VALUE_LOW_EXT_1=' + FormatDateTime('yyyymmdd', now-1);
//      LQryTxt := StringReplace(LQryTxt, 'VAR_VALUE_LOW_EXT_1=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_LOW_EXT_1=', LQryParamType, qpdBegin, Date-1);
    end;

    if Pos('VAR_VALUE_HIGH_EXT_1=', LQryTxt) > 0  then
    begin
//      LNewQryTxt := 'VAR_VALUE_HIGH_EXT_1=' + FormatDateTime('yyyymmdd', now);
//      LQryTxt := StringReplace(LQryTxt, 'VAR_VALUE_HIGH_EXT_1=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_HIGH_EXT_1=', LQryParamType, qpdEnd, Date);
    end;

    FXMLFromQry := GetContent(LQryTxt);

    task.Invoke(
      procedure
      begin
        g_DisplayMessage2MainForm(LQryTxt + #13#10);
        g_DisplayMessage2MainForm('============================================================================');
        g_DisplayMessage2MainForm(FXMLFromQry);
        g_DisplayMessage2MainForm('============================================================================');
      end);
    FCurQryKey := LKey;
    ProcessQueryXML(FXMLFromQry, task);

    Inc(FQryCount);
  end;

  TMonitor.Enter(Self);
  try
    if not FIsFirstDataArrived then
    begin
      FIsFirstDataArrived := True;
//      FBWQryDataClass.GetCellDataAll;
    end;

    FBWQryDataClass.GetCellDataAll('GET_BWQRY_CELL_DATA_ALL');
  finally
    TMonitor.Exit(Self);
  end;

  {$IFDEF USECODESITE}
  CodeSite.EnterMethod('TMainForm.GetBWQuery End ===>');
  try
//    CodeSite.Send('Msg.WParam', Ord(LDragCopyMode));
  finally
    CodeSite.ExitMethod('TMainForm.GetBWQuery <===');
  end;
  {$ENDIF}
end;

function TBWQuery.GetColumnHeaderDataAll : Boolean;
begin
  TMonitor.Enter(Self);
  Result := False;
  try
    if FIsFirstDataArrived then
    begin
      FBWQryDataClass.GetCellDataAll('Column Header');
      Result := True;
    end;
  finally
    TMonitor.Exit(Self);
  end;
end;

function TBWQuery.getContent(url: String): String;
var
  LIdHTTP: TIdHTTP;
begin
  LIdHTTP := TIdHTTP.Create(nil);
  LIdHTTP.HandleRedirects := True;
  try
    try
      Result := LIdHTTP.Get(url);
    except

    end;
  finally
    LIdHTTP.Free;
  end;
end;

function TBWQuery.GetCurQryClass: TBWQryClass;
var
  LKey: string;
begin
  for LKey in FBWQryDataClass.FBWQryList.Keys do
  begin
    if FCurQryKey = FBWQryDataClass.FBWQryList.Items[LKey].QueryName then
    begin
      Result :=FBWQryDataClass.FBWQryList.Items[LKey];
      break;
    end;
  end;
end;

function TBWQuery.GetEndOfMonth(ADate: TDate): string;
begin
  Result := IntToStr(MonthDays[IsLeapYear(YearOf(ADate)), MonthOf(ADate)]);
end;

function TBWQuery.GetOrderPlanPerProduct(const task: IOmniTask): boolean;
begin
  if FQryCount = 0 then
    exit;

  FBWQryDataClass.FOrderPlanPerProduct.Clear;

  //�ڿ� �濵 ��ȹ
  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q201_201601', 7, FBWQryDataClass.FOrderPlanPerProduct);//ZKA_ZKSDSOM01_D_C_Q201�� ������
  //�������� �濵 ��ȹ
  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q203', 7, FBWQryDataClass.FOrderPlanPerProduct);
  //���������/��ȹ �����Ϳ��� "���ڽ�" �׸��� ���� ���� ARow���� 4->3���� ������
  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q206_201601', 3, FBWQryDataClass.FOrderPlanPerProduct);//ZKA_ZKSDSOM01_D_C_Q206�� ������
  //�κ� �濵��ȹ�̹Ƿ� ����
//  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q208', 6, FBWQryDataClass.FOrderPlanPerProduct);
  //�Ż�� �濵��ȹ
  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q401_201601', 2, FBWQryDataClass.FOrderPlanPerProduct);
  //�۷ι����� �濵��ȹ
  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q218_1', 5, FBWQryDataClass.FOrderPlanPerProduct);
end;

function TBWQuery.GetProfitPlanPerProduct(const task: IOmniTask): boolean;
begin
  if FQryCount = 0 then
    exit;

  FBWQryDataClass.FProfitPlanPerProduct.Clear;

  _GetBizPlanPerProduct('ZKA_ZKEISM003_D_C_Q001_1', 0, FBWQryDataClass.FProfitPlanPerProduct,6);
end;

function TBWQuery.GetQueryClass(AQueryName: string): TBWQryClass;
var
  LKey: string;
begin
  Result := nil;

  for LKey in FBWQryDataClass.FBWQryList.Keys do
  begin
//    if FBWQryList.Items[LKey].QueryName = AQueryName then
    if LKey = AQueryName then
    begin
      FCurQryKey := LKey;
      Result := GetCurQryClass;
      exit;
    end;
  end;
end;

function TBWQuery.GetQueryType(AQueryName: string): integer;
var
  LKey: string;
begin
  for LKey in FBWQryDataClass.FBWQryList.Keys do
  begin
    if FCurQryKey = FBWQryDataClass.FBWQryList.Items[LKey].QueryName then
    begin
      Result := FBWQryDataClass.FBWQryList.Items[LKey].QueryType;
      break;
    end;
  end;
end;

function TBWQuery.GetRowHeaderDataAll:Boolean;
begin
  TMonitor.Enter(Self);
  Result := False;
  try
    if FIsFirstDataArrived then
    begin
      FBWQryDataClass.GetCellDataAll('Row Header');
      Result := True;
    end;
  finally
    TMonitor.Exit(Self);
  end;
end;

function TBWQuery.GetSalesPlanPerProduct(const task: IOmniTask): boolean;
begin
  if FQryCount = 0 then
    exit;

  FBWQryDataClass.FSalesPlanPerProduct.Clear;

  _GetBizPlanPerProduct('ZKA_ZKSDBIM01_D_C_Q225_1', 0, FBWQryDataClass.FSalesPlanPerProduct, 5);
end;

procedure TBWQuery.HeaderData2Grid(ABWQryClass: TBWQryClass;
  AGrid: TAdvStringGrid);
var
  i, j, LCount, LCol, LRow: integer;
  LColX, LRowX, LSpanY: integer;
  LColX2, LRowX2, LSpanY2: integer;
  LStr, LMerge1, LMerge2: string;
begin
  LCount := ABWQryClass.BWQryRowHeaderCollect.ColCountOfRow;
  AGrid.ColCount := ABWQryClass.BWQryColumnHeaderCollect.Count+LCount;
  AGrid.RowCount := ABWQryClass.BWQryRowHeaderCollect.Count;
  AGrid.FixedCols := LCount;
  AGrid.FixedRows := 1;

  for i := 0 to ABWQryClass.BWQryColumnHeaderCollect.Count - 1 do
  begin
    LCol := LCount + i;
    LRow := 0;
    LStr := ABWQryClass.BWQryColumnHeaderCollect.Items[i].ColumnHeaderData;
    LStr := StringReplace(LStr, '���־�-', '', [rfReplaceAll, rfIgnoreCase]);
    AGrid.Cells[LCol, LRow] := LStr;
  end;

  LRowX := 1;
  LColX := 0;
  LMerge1 := 'A';
  LRowX2 := 1;
  LColX2 := 1;
  LMerge2 := 'AE';
  LSpanY := 0;
  LSpanY2 := 0;

  for i := 0 to ABWQryClass.BWQryRowHeaderCollect.Count - 1 do
  begin
    LStr := ABWQryClass.BWQryRowHeaderCollect.Items[i].RowHeaderData;

    for j := 0 to LCount - 1 do
    begin
      LCol := j;
      LRow := i+1;
      AGrid.Cells[LCol, LRow] := strToken(LStr, ';');

      if j = 0 then
      begin
        if LMerge1 <> AGrid.Cells[LCol, LRow] then
        begin
          AGrid.MergeCells(LColX, LRowX, 1, LSpanY);
          LSpanY := 1;
          LRowX := LRow;
          LColX := j;
          LMerge1 := AGrid.Cells[LCol, LRow];
        end
        else
        begin
          Inc(LSpanY);
        end;
      end
      else
      if j = 1 then
      begin
        if LMerge2 <> AGrid.Cells[LCol, LRow] then
        begin
          AGrid.MergeCells(LColX2, LRowX2, 1, LSpanY2);
          LSpanY2 := 1;
          LRowX2 := LRow;
          LColX2 := j;
          LMerge2 := AGrid.Cells[LCol, LRow];
        end
        else
        begin
          Inc(LSpanY2);
        end;
      end;
    end;
  end;
end;

procedure TBWQuery.LoadInquiryList(ABWQryClass: TBWQryClass);
var
  LInquiryInfo: TInquiryInfo;
  i, LRow, LCount: integer;
  LStr: string;
begin
  ClearInqryList;
  LCount := ABWQryClass.BWQryRowHeaderCollect.ColCountOfRow;

  for i := 0 to ABWQryClass.BWQryRowHeaderCollect.Count - 1 do
  begin
    LStr := ABWQryClass.BWQryRowHeaderCollect.Items[i].RowHeaderData;

    LInquiryInfo := TInquiryInfo.Create;
    LInquiryInfo.FRow := i+1;
    LInquiryInfo.ProductCategory := strToken(LStr, ';');
    LInquiryInfo.ProjectName := strToken(LStr, ';');
    LInquiryInfo.ShipNo := strToken(LStr, ';');
    LInquiryInfo.ProductType := strToken(LStr, ';');
    LInquiryInfo.ContractDate := strToken(LStr, ';');
    LInquiryInfo.DueDate := strToken(LStr, ';');
    LInquiryInfo.CustomerName := strToken(LStr, ';');
    LInquiryInfo.CustomerNation := strToken(LStr, ';');
    LInquiryInfo.InqNo := strToken(LStr, ';');
    LInquiryInfo.InquiryRecvDate := strToken(LStr, ';');

    FBWQryDataClass.FInquiryList.Add(LInquiryInfo.FRow, LInquiryInfo);
  end;

  for i := 0 to ABWQryClass.BWQryCellDataCollect.Count - 1 do
  begin
    LRow := ABWQryClass.BWQryCellDataCollect.Items[i].Row+1;
    LInquiryInfo := FBWQryDataClass.FInquiryList.Items[LRow];

    if LInquiryInfo.FRow = LRow then
    begin
      case (i mod 2) of
        0: LInquiryInfo.ProductCount := ABWQryClass.BWQryCellDataCollect.Items[i].CellData;
        1: LInquiryInfo.Price := ABWQryClass.BWQryCellDataCollect.Items[i].CellData;
      end;
    end;
  end;
end;

procedure TBWQuery.LoadQueryListFromTxt;
var
  LBWQryListClass: TBWQryListClass;
  LBWQryClass: TBWQryClass;
  i: integer;
begin
  LBWQryListClass := TBWQryListClass.Create(nil);

  try
    LBWQryListClass.LoadFromTxt('BWQuery_r2.txt');

    for i := 0 to LBWQryListClass.BWQryCollect.Count - 1 do
    begin
      LBWQryClass := TBWQryClass.Create(nil);
      LBWQryClass.Description := LBWQryListClass.BWQryCollect.Items[i].Description;
      LBWQryClass.QueryName := LBWQryListClass.BWQryCollect.Items[i].QueryName;
      LBWQryClass.QueryText := LBWQryListClass.BWQryCollect.Items[i].QueryText;
      LBWQryClass.QueryType := LBWQryListClass.BWQryCollect.Items[i].QueryType;
      LBWQryClass.QryParamType := LBWQryListClass.BWQryCollect.Items[i].QryParamType;

      FBWQryDataClass.FBWQryList.Add(LBWQryClass.QueryName, LBWQryClass);
    end;
  finally
    LBWQryListClass.Free;
  end;
end;

procedure TBWQuery.OnGetBWQuery(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  g_ClearMessage;
  g_DisplayMessage2MainForm(FormatDateTime('mm�� dd��, hh:nn:ss => ', now) + '=================');

  FGetBWQryFuture := Parallel.Future<Boolean>(GetBWQuery, Parallel.TaskConfig.OnTerminated(OnGetBWQueryCompleted));
//  Parallel.Async(GetBWQuery, Parallel.TaskConfig.OnTerminated(OnGetBWQueryCompleted));
end;

procedure TBWQuery.OnGetBWQueryCompleted(const task: IOmniTaskControl);
var
  LStr: string;
begin
//  QProgress1.Active := False;
//  FQryRunning := False;
  LStr := g_GetFormCaption;
  LStr := Copy(LStr, 1, Pos(' => ', LStr) - 1);

  if LStr = '' then
    LStr := g_GetFormCaption;

  g_SetFormCaption(LStr + ' => ' + IntToStr(FQryCount) + ' Query Updated: ' + FormatDateTime('mm�� dd��, hh:nn:ss', now));

  FPJHTimerPool.AddOneShot(OnGetBWQuery, 1800000);//1800000

  if FBWQryDataClass.FOrderPlanPerProduct.Count = 0 then
    Parallel.Future<Boolean>(GetOrderPlanPerProduct, Parallel.TaskConfig.OnTerminated(OnGetOrderPlanPerProductCompleted));

  if FBWQryDataClass.FSalesPlanPerProduct.Count = 0 then
    Parallel.Future<Boolean>(GetSalesPlanPerProduct, Parallel.TaskConfig.OnTerminated(OnGetSalesPlanPerProductCompleted));

  if FBWQryDataClass.FProfitPlanPerProduct.Count = 0 then
    Parallel.Future<Boolean>(GetProfitPlanPerProduct, Parallel.TaskConfig.OnTerminated(OnGetProfitPlanPerProductCompleted));

  FGetQrying := False;
end;

procedure TBWQuery.OnGetOrderPlanPerProductCompleted(
  const task: IOmniTaskControl);
var
  i: integer;
  LStr: string;
begin
  for i := 0 to FBWQryDataClass.FOrderPlanPerProduct.Count - 1 do
  begin
    LStr := LStr + IntToStr(FBWQryDataClass.FOrderPlanPerProduct.Items[i].Col) + ',' +
          IntToStr(FBWQryDataClass.FOrderPlanPerProduct.Items[i].Row) + ',' +
          FBWQryDataClass.FOrderPlanPerProduct.Items[i].CellData + #13#10;
  end;

  g_DisplayMessage2MainForm('========OnGetOrderPlanPerProductCompleted===================================');
  g_DisplayMessage2MainForm(LStr);
  g_DisplayMessage2MainForm('============================================================================');
end;

procedure TBWQuery.OnGetProfitPlanPerProductCompleted(
  const task: IOmniTaskControl);
var
  i: integer;
  LStr: string;
begin
  for i := 0 to FBWQryDataClass.FProfitPlanPerProduct.Count - 1 do
  begin
    LStr := LStr + IntToStr(FBWQryDataClass.FProfitPlanPerProduct.Items[i].Col) + ',' +
          IntToStr(FBWQryDataClass.FProfitPlanPerProduct.Items[i].Row) + ',' +
          FBWQryDataClass.FProfitPlanPerProduct.Items[i].CellData + #13#10;
  end;

  g_DisplayMessage2MainForm('================OnGetProfitPlanPerProductCompleted==========================');
  g_DisplayMessage2MainForm(LStr);
  g_DisplayMessage2MainForm('============================================================================');
end;

procedure TBWQuery.OnGetSalesPlanPerProductCompleted(
  const task: IOmniTaskControl);
var
  i: integer;
  LStr: string;
begin
  for i := 0 to FBWQryDataClass.FSalesPlanPerProduct.Count - 1 do
  begin
    LStr := LStr + IntToStr(FBWQryDataClass.FSalesPlanPerProduct.Items[i].Col) + ',' +
          IntToStr(FBWQryDataClass.FSalesPlanPerProduct.Items[i].Row) + ',' +
          FBWQryDataClass.FSalesPlanPerProduct.Items[i].CellData + #13#10;
  end;

  g_DisplayMessage2MainForm('==============OnGetSalesPlanPerProductCompleted=============================');
  g_DisplayMessage2MainForm(LStr);
  g_DisplayMessage2MainForm('============================================================================');
end;

procedure TBWQuery.ProcessQueryXML(AXMLString: string; const task: IOmniTask);
var
  LXMLDoc: IXMLDocument;
  LRootNode, LSubNode, LLeafNode, LLeafNode2: IXMLNode;
  LBWQryClass: TBWQryClass;
  LBWQryCellDataItem: TBWQryCellDataItem;
  LBWQryRowHeaderItem: TBWQryRowHeaderItem;
  LBWQryColumnHeaderItem: TBWQryColumnHeaderItem;
  i,j,k: integer;
  LCol, LRow: integer;
begin
  LXMLDoc := CreateXMLDoc;
  try
    LXMLDoc.LoadXML(AXMLString);

    if LXMLDoc.DocumentElement <> nil then
    begin
      LRootNode := LXMLDoc.DocumentElement;

      for i := 0 to LRootNode.ChildNodes.Length - 1 do
      begin
        if task.CancellationToken.IsSignalled then
          break;

        LSubNode := LRootNode.ChildNodes.Item[i];

        if LSubNode.NodeName = 'variable' then
        begin
          if LSubNode.Attributes.Length > 0 then
          begin
            if LSubNode.Attributes.Item[0].NodeValue = 'colHeader' then
            begin
              LBWQryClass := GetCurQryClass;
              LBWQryClass.BWQryColumnHeaderCollect.Clear;

              for j := 0 to LSubNode.ChildNodes.Length - 1 do
              begin
                LSubNode := LSubNode.ChildNodes.Item[j];

                if LSubNode.NodeName = 'row' then
                begin
                  for k := 0 to LSubNode.ChildNodes.Length - 1 do
                  begin
                    LLeafNode2 := LSubNode.ChildNodes.Item[k];

                    if LLeafNode2.NodeName = 'column' then
                    begin
                      if LLeafNode2.HasChildNodes then
                      begin
                        LBWQryColumnHeaderItem := LBWQryClass.BWQryColumnHeaderCollect.Add;
                        LLeafNode2 := LLeafNode2.ChildNodes.Item[0];//CDATA Section
                        LBWQryColumnHeaderItem.ColumnHeaderData := LBWQryColumnHeaderItem.ColumnHeaderData +
                                        LLeafNode2.NodeValue + ';';
                        LBWQryColumnHeaderItem.ColumnHeaderLevel := j;
                      end;
                    end;
                  end;//for
                end;
              end;//for

              LBWQryClass.BWQryColumnHeaderCollect.FixedColumnCount := j;
            end
            else
            if LSubNode.Attributes.Item[0].NodeValue = 'rowHeader' then
            begin
              LBWQryClass := GetCurQryClass;
              LBWQryClass.BWQryRowHeaderCollect.Clear;

              for j := 0 to LSubNode.ChildNodes.Length - 1 do
              begin
                LLeafNode := LSubNode.ChildNodes.Item[j];

                if LLeafNode.NodeName = 'row' then
                begin
                  LBWQryRowHeaderItem := LBWQryClass.BWQryRowHeaderCollect.Add;

                  for k := 0 to LLeafNode.ChildNodes.Length - 1 do //row ���� column �� ���O �ݺ�
                  begin
                    LLeafNode2 := LLeafNode.ChildNodes.Item[k];

                    if LLeafNode2.NodeName = 'column' then
                    begin
                      if LLeafNode2.HasChildNodes then
                      begin
                        LLeafNode2 := LLeafNode2.ChildNodes.Item[0];//CDATA Section
                        LBWQryRowHeaderItem.RowHeaderData := LBWQryRowHeaderItem.RowHeaderData + LLeafNode2.NodeValue + ';';
                      end;
                    end;
                  end;//for

                  LBWQryClass.BWQryRowHeaderCollect.ColCountOfRow := LLeafNode.ChildNodes.Length;
                end;
              end;//for
            end
            else
            if LSubNode.Attributes.Item[0].NodeValue = 'cellData' then
            begin
              LBWQryClass := GetCurQryClass;
              LBWQryClass.BWQryCellDataCollect.Clear;

              for j := 0 to LSubNode.ChildNodes.Length - 1 do
              begin
                LLeafNode := LSubNode.ChildNodes.Item[j];

                if LLeafNode.NodeName = 'row' then
                begin
                  for k := 0 to LLeafNode.ChildNodes.Length - 1 do
                  begin
                    LLeafNode2 := LLeafNode.ChildNodes.Item[k];

                    if LLeafNode2.NodeName = 'column' then
                    begin
                      if LLeafNode2.HasChildNodes then
                      begin
                        LLeafNode2 := LLeafNode2.ChildNodes.Item[0];//CDATA Section
                        LBWQryCellDataItem := LBWQryClass.BWQryCellDataCollect.Add;
                        LBWQryCellDataItem.Row := j;
                        LBWQryCellDataItem.Col := k;
                        LBWQryCellDataItem.CellData := LLeafNode2.NodeValue
                      end;
                    end;
                  end;//for
                end;
              end;
            end
          end;
        end;
      end;
    end;
  finally
    ChangeDataFormat;

    LBWQryClass := GetCurQryClass;
    if LBWQryClass.QueryName = 'ZKA_ZKSDINM01_D_L_Q201' then
      LoadInquiryList(LBWQryClass);

    LXMLDoc := nil;
  end;
end;

procedure TBWQuery.QryData2DataView(AQueryName: string);
var
  LBWQryClass: TBWQryClass;
  LDataViewF: TDataViewF;
  LXlsFileName: string;
  i, LCol, LRow, LFixedColCount: integer;
  LQryType: integer;
begin
  LBWQryClass := nil;
  LBWQryClass := GetQueryClass(AQueryName);

  if Assigned(LBWQryClass) then
  begin
    LDataViewF := TDataViewF.Create(nil);
    try
      LXlsFileName := FExeFilePath + '..\Maps\' + AQueryName + '.xls';

      if FileExists(LXlsFileName) then
      begin
        LQryType := GetQueryType(AQueryName);
        case LQryType of
          0: LDataViewF.AdvGridExcelIO1.XLSImport(LXlsFileName);
          1: begin
            LDataViewF.AdvGridExcelIO1.XLSImport(LXlsFileName);
            RowHeaderNCellData2Grid(LBWQryClass, LDataViewF.AdvGridWorkbook1.Grid);
          end;
          2: begin
            LDataViewF.AdvGridExcelIO1.XLSImport(LXlsFileName);
            ColumnHeaderNCellData2Grid(LBWQryClass, LDataViewF.AdvGridWorkbook1.Grid);
          end;
        end;
      end
      else
        HeaderData2Grid(LBWQryClass, LDataViewF.AdvGridWorkbook1.Grid);

      if LQryType <> 2 then
      begin
        LFixedColCount := LBWQryClass.BWQryRowHeaderCollect.ColCountOfRow;

        for i := 0 to LBWQryClass.BWQryCellDataCollect.Count - 1 do
        begin
          LCol := LBWQryClass.BWQryCellDataCollect.Items[i].Col+LFixedColCount;
          LRow := LBWQryClass.BWQryCellDataCollect.Items[i].Row+1;
          LDataViewF.AdvGridWorkbook1.Grid.Cells[LCol, LRow] := LBWQryClass.BWQryCellDataCollect.Items[i].CellData;
        end;
      end;

      LDataViewF.Panel1.Caption := LBWQryClass.Description + ' (' + AQueryName + ' )';
      LDataViewF.ShowModal;
    finally
      LDataViewF.Free;
    end;
  end;
end;

procedure TBWQuery.RowHeaderNCellData2Grid(ABWQryClass: TBWQryClass;
  AGrid: TAdvStringGrid);
var
  i, j, LCount, LCol, LRow: integer;
  LStr: string;
begin
  LCount := ABWQryClass.BWQryRowHeaderCollect.ColCountOfRow;
  AGrid.ColCount := ABWQryClass.BWQryColumnHeaderCollect.Count + LCount;
  AGrid.RowCount := ABWQryClass.BWQryRowHeaderCollect.Count;
  AGrid.FixedRows := 1;
  AGrid.FixedCols := 0;

  for i := 0 to ABWQryClass.BWQryRowHeaderCollect.Count - 1 do
  begin
    LStr := ABWQryClass.BWQryRowHeaderCollect.Items[i].RowHeaderData;

    for j := 0 to LCount - 1 do
    begin
      LCol := j;
      LRow := i+1;
      AGrid.Cells[LCol, LRow] := strToken(LStr, ';');
    end;
  end;
end;

function TBWQuery.SetQryParamType(AQryText: string; const AParamName: string;
  AParamType: TQryParameterType; AParamDir: TQryParameterDir;
  ADate: TDate): string;
var
  LNewQryTxt: string;
begin
  case AParamType of
    qptYear: begin
      if AParamDir = qpdBegin then
        LNewQryTxt := AParamName + FormatDateTime('yyyy', ADate) + '0101'
      else
      if AParamDir = qpdCustom then
        LNewQryTxt := AParamName + FormatDateTime('yyyymmdd', ADate)
      else
      if AParamDir = qpdEnd then
        LNewQryTxt := AParamName + FormatDateTime('yyyy', ADate) + '1231';
    end;

    qptMonth: begin
      if AParamDir = qpdBegin then
        LNewQryTxt := AParamName + FormatDateTime('yyyymm', ADate) + '01'
      else
      if AParamDir = qpdCustom then
        LNewQryTxt := AParamName + FormatDateTime('yyyymmdd', ADate)
      else
      if AParamDir = qpdEnd then
        LNewQryTxt := AParamName + FormatDateTime('yyyymm', ADate) + GetEndOfMonth(ADate);
    end;

    qptDay: begin
      LNewQryTxt := AParamName + FormatDateTime('yyyymmdd', ADate)
    end;
  end;

  Result := StringReplace(AQryText, AParamName, LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
end;

procedure TBWQuery._GetBizPlanPerProduct(AQryName: string; ARow: integer;
  ACollect: TBWQryCellDataCollect; AExcludeRow: integer);
var
  LBWQryClass: TBWQryClass;
  i, LCol, LRow: integer;
begin
  LBWQryClass := nil;
  LBWQryClass := GetQueryClass(AQryName);

  if Assigned(LBWQryClass) then
  begin
    for i := 0 to LBWQryClass.BWQryCellDataCollect.Count - 1 do
    begin
      LCol := LBWQryClass.BWQryCellDataCollect.Items[i].Col;
      LRow := LBWQryClass.BWQryCellDataCollect.Items[i].Row;

      if AExcludeRow <> -1 then
        if AExcludeRow <= LRow then
          continue;

      if ARow = 0 then
      begin
        with ACollect.Add do
        begin
          Col := LCol;
          Row := LRow;
          CellData := LBWQryClass.BWQryCellDataCollect.Items[i].CellData;
//          DataName := LBWQryClass.BWQryCellDataCollect.Items[i].DataName;
        end;
      end
      else
      if LRow = ARow then
      begin
        with ACollect.Add do
        begin
          Col := LCol;
          Row := LRow;
          CellData := LBWQryClass.BWQryCellDataCollect.Items[i].CellData;
//          DataName := LBWQryClass.BWQryCellDataCollect.Items[i].DataName;
        end;
      end;
    end;
  end;
end;

end.
=======
unit UnitBWQuery;

interface

uses System.SysUtils, System.StrUtils, SynCommons, Generics.Collections,MSHTML,Activex,
  OtlTask, OtlCommon, OtlCollections, OtlParallel, OtlTaskControl, TimerPool,
  OmniXML, OmniXMLUtils, OmniXMLXPath,
  AdvGrid, IdHTTP, DateUtils, BW_Query_Class, mORMot, UnitFrameCommServer,
  RMISConst, Dialogs;

type
  TBWQuery = class
    FBWQryList: TDictionary<string, TBWQryClass>;
    FInquiryList: TDictionary<integer, TInquiryInfo>;
    FPJHTimerPool: TPJHTimerPool;
    FXMLFromQry: string;
    FCurQryKey: String;//FBWQryList�߿��� ���� ���� ���� Query Key string�� ������
    FQryCount: integer;
    FGetBWQryFuture: IOmniFuture<Boolean>;
    FGetQrying: Boolean;

    procedure ProcessQueryXML(AXMLString: string; const task: IOmniTask);
    procedure LoadQueryListFromTxt;
    procedure LoadInquiryList(ABWQryClass: TBWQryClass);
    procedure ClearInqryList;
    function GetCurQryClass: TBWQryClass;
    function GetQueryType(AQueryName: string): integer;
    procedure ChangeDataFormat;

    procedure OnGetBWQuery(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);

    procedure OnGetBWQueryCompleted(const task: IOmniTaskControl);
    procedure OnGetOrderPlanPerProductCompleted(const task: IOmniTaskControl);
    procedure OnGetSalesPlanPerProductCompleted(const task: IOmniTaskControl);
    procedure OnGetProfitPlanPerProductCompleted(const task: IOmniTaskControl);

    function GetBWQuery(const task: IOmniTask): boolean;
    function SetQryParamType(AQryText: string; const AParamName: string;
      AParamType: TQryParameterType; AParamDir: TQryParameterDir; ADate: TDate): string;
    function GetEndOfMonth(ADate: TDate): string;
    function GetOrderPlanPerProduct(const task: IOmniTask): boolean;
    //ARow: ���� ��ȹ�� ��� ��ǰ��(����/����/������ ��)�� �������Ƿ� �濵��ȹ�� �ִ� ��(ARow)�� ���� ��
    //      ����/������ ��� ��ǰ���� �ƴ� �ι���(�ڿ�/����/�κ� ��) �̹Ƿ� ARow = 0���� ó����.
    //AExcludeRow: ���� ū Row�� �ǳʶ�
    procedure _GetBizPlanPerProduct(AQryName: string; ARow: integer; ACollect: TBWQryCellDataCollect; AExcludeRow: integer = -1);
    function GetSalesPlanPerProduct(const task: IOmniTask): boolean;
    function GetProfitPlanPerProduct(const task: IOmniTask): boolean;

    function getContent(url: String): String;
    procedure HeaderData2Grid(ABWQryClass: TBWQryClass; AGrid: TAdvStringGrid);
    //���� �Ϻ� �ι���;ZKA_ZKSDINM01_D_L_Q201 �������� �ش� ��
    procedure RowHeaderNCellData2Grid(ABWQryClass: TBWQryClass; AGrid: TAdvStringGrid);
    procedure ColumnHeaderNCellData2Grid(ABWQryClass: TBWQryClass; AGrid: TAdvStringGrid);

  public
    FExeFilePath: string;
    FOrderPlanPerProduct: TBWQryCellDataCollect; //��ǰ�� ���� �濵��ȹ
    FSalesPlanPerProduct: TBWQryCellDataCollect; //��ǰ�� ���� �濵��ȹ
    FProfitPlanPerProduct: TBWQryCellDataCollect;//��ǰ�� ���� �濵��ȹ
    FCellDataAllCollect: TBWQryCellDataAllCollect;

    constructor Create;
    destructor Destroy;

    procedure QryData2DataView(AQueryName: string);
    function GetCellDataAll: TRawUTF8DynArray;
    function GetInquiryPerProdPerGrade: TRawUTF8DynArray; //��޺� ��ǰ�� Inquiry �ݾ�
    function GetQueryClass(AQueryName: string): TBWQryClass;

  end;

implementation

uses UnitDataView;

{ TBWQuery }

procedure TBWQuery.ChangeDataFormat;
var
  LKey, LStr: string;
  LBWQryClass: TBWQryClass;
  i: integer;
  Ldouble: double;
begin
  for LKey in FBWQryList.Keys do
  begin
    LBWQryClass := FBWQryList.Items[LKey];
    for i := 0 to LBWQryClass.BWQryCellDataCollect.Count - 1 do
    begin
      LStr := LBWQryClass.BWQryCellDataCollect.Items[i].CellData;

      if (LStr <> '') and (Pos('.', LStr) = 0) and (Pos(',', LStr) = 0)then
      begin
        Ldouble := StrToFloatDef(LStr,0.0);
        LBWQryClass.BWQryCellDataCollect.Items[i].CellData := FormatFloat('#,##0', Ldouble);
      end;
    end;
  end;
end;

procedure TBWQuery.ClearInqryList;
var
  LKey: integer;
begin
  for LKey in FInquiryList.Keys do
    TInquiryInfo(FInquiryList.Items[LKey]).Free;

  FInquiryList.Clear;
end;


procedure TBWQuery.ColumnHeaderNCellData2Grid(ABWQryClass: TBWQryClass;
  AGrid: TAdvStringGrid);
var
  i, LCol, LRow: integer;
begin
  AGrid.ColCount := ABWQryClass.BWQryColumnHeaderCollect.Count;
  AGrid.FixedRows := ABWQryClass.BWQryColumnHeaderCollect.FixedColumnCount;
  AGrid.FixedCols := ABWQryClass.BWQryRowHeaderCollect.ColCountOfRow+1;

  for i := 0 to ABWQryClass.BWQryCellDataCollect.Count - 1 do
  begin
    LCol := ABWQryClass.BWQryCellDataCollect.Items[i].Col + AGrid.FixedCols;
    LRow := ABWQryClass.BWQryCellDataCollect.Items[i].Row + AGrid.FixedRows;
    AGrid.Cells[LCol, LRow] := ABWQryClass.BWQryCellDataCollect.Items[i].CellData;
  end;
end;

constructor TBWQuery.Create;
begin
  FPJHTimerPool := TPJHTimerPool.Create(nil);

  FBWQryList := TDictionary<string, TBWQryClass>.Create;
  FInquiryList := TDictionary<integer, TInquiryInfo>.Create;

  FOrderPlanPerProduct := TBWQryCellDataCollect.Create(TBWQryCellDataItem);
  FSalesPlanPerProduct := TBWQryCellDataCollect.Create(TBWQryCellDataItem);
  FProfitPlanPerProduct := TBWQryCellDataCollect.Create(TBWQryCellDataItem);
  FCellDataAllCollect := TBWQryCellDataAllCollect.Create(TBWQryCellDataAllItem);

  TJSONSerializer.RegisterCollectionForJSON(TBWQryColumnHeaderCollect, TBWQryColumnHeaderItem);
  TJSONSerializer.RegisterCollectionForJSON(TBWQryRowHeaderCollect, TBWQryRowHeaderItem);
  TJSONSerializer.RegisterCollectionForJSON(TBWQryCellDataCollect, TBWQryCellDataItem);
  TJSONSerializer.RegisterCollectionForJSON(TBWQryCellDataAllCollect, TBWQryCellDataAllItem);

  LoadQueryListFromTxt;
  FPJHTimerPool.AddOneShot(OnGetBWQuery, 500);

end;

destructor TBWQuery.Destroy;
var
  LKey: string;
begin
  FPJHTimerPool.RemoveAll;
  FPJHTimerPool.Free;

  ClearInqryList;
  FInquiryList.Free;

  for LKey in FBWQryList.Keys do
    TBWQryClass(FBWQryList.Items[LKey]).Free;

  FBWQryList.Free;
  FOrderPlanPerProduct.Free;
  FSalesPlanPerProduct.Free;
  FProfitPlanPerProduct.Free;
  FCellDataAllCollect.Free;
end;

function TBWQuery.GetBWQuery(const task: IOmniTask): boolean;
var
  WaitResult: Integer;
  LKey, LQryTxt, LNewQryTxt: string;
  LQryParamType: TQryParameterType;
begin
//  QProgress1.Active := True;
//  FQryRunning := True;
//  Panel1.Caption := '�ڷ� ���� ��...';
  {$IFDEF USECODESITE}
  CodeSite.EnterMethod('TMainForm.GetBWQuery Begin ===>');
  try
//    CodeSite.Send('Msg.WParam', Ord(LDragCopyMode));
  finally
    CodeSite.ExitMethod('TTMainForm.GetBWQuery <===');
  end;
  {$ENDIF}

  FGetQrying := True;
  FQryCount := 0;

  for LKey in FBWQryList.Keys do
  begin
    if task.CancellationToken.IsSignalled then
      break;

    LQryTxt := FBWQryList.Items[LKey].QueryText;
    LQryParamType := FBWQryList.Items[LKey].QryParamType;

    if Pos('VAR_VALUE_LOW_EXT_2=', LQryTxt) > 0  then
    begin
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_LOW_EXT_2=', LQryParamType, qpdBegin, Date);
//      LNewQryTxt :=  + FormatDateTime('yyyy', Date) + '0101';
//      LQryTxt := StringReplace(LQryTxt, 'VAR_VALUE_LOW_EXT_2=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
    end;

    if Pos('VAR_VALUE_HIGH_EXT_2=', LQryTxt) > 0  then
    begin
//      LNewQryTxt := 'VAR_VALUE_HIGH_EXT_2=' + FormatDateTime('yyyymmdd', now);
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_HIGH_EXT_2=', LQryParamType, qpdCustom, Date);
//      StringReplace(LQryTxt, 'VAR_VALUE_HIGH_EXT_2=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
    end;

    if Pos('VAR_VALUE_EXT_1=', LQryTxt) > 0  then
    begin
//      LNewQryTxt := 'VAR_VALUE_EXT_1=' + FormatDateTime('yyyymmdd', now);
//      LQryTxt := StringReplace(LQryTxt, 'VAR_VALUE_EXT_1=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_EXT_1=', LQryParamType, qpdCustom, Date);
    end;

    if Pos('VAR_VALUE_LOW_EXT_1=', LQryTxt) > 0  then
    begin
//      LNewQryTxt := 'VAR_VALUE_LOW_EXT_1=' + FormatDateTime('yyyymmdd', now-1);
//      LQryTxt := StringReplace(LQryTxt, 'VAR_VALUE_LOW_EXT_1=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_LOW_EXT_1=', LQryParamType, qpdBegin, Date-1);
    end;

    if Pos('VAR_VALUE_HIGH_EXT_1=', LQryTxt) > 0  then
    begin
//      LNewQryTxt := 'VAR_VALUE_HIGH_EXT_1=' + FormatDateTime('yyyymmdd', now);
//      LQryTxt := StringReplace(LQryTxt, 'VAR_VALUE_HIGH_EXT_1=', LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
      LQryTxt := SetQryParamType(LQryTxt, 'VAR_VALUE_HIGH_EXT_1=', LQryParamType, qpdEnd, Date);
    end;

    FXMLFromQry := GetContent(LQryTxt);

    task.Invoke(
      procedure
      begin
        g_DisplayMessage2MainForm(LQryTxt + #13#10);
        g_DisplayMessage2MainForm('============================================================================');
        g_DisplayMessage2MainForm(FXMLFromQry);
        g_DisplayMessage2MainForm('============================================================================');
      end);
    FCurQryKey := LKey;
    ProcessQueryXML(FXMLFromQry, task);

    Inc(FQryCount);
  end;
  {$IFDEF USECODESITE}
  CodeSite.EnterMethod('TMainForm.GetBWQuery End ===>');
  try
//    CodeSite.Send('Msg.WParam', Ord(LDragCopyMode));
  finally
    CodeSite.ExitMethod('TMainForm.GetBWQuery <===');
  end;
  {$ENDIF}
end;

function TBWQuery.GetCellDataAll: TRawUTF8DynArray;
var
  LKey: string;
  LCount: integer;
  LDynArr: TDynArray;
  LValue: RawUTF8;
  LItem: TBWQryCellDataAllItem;
begin
  LDynArr.Init(TypeInfo(TRawUTF8DynArray), Result, @LCount);
  FCellDataAllCollect.Clear;

  for LKey in FBWQryList.Keys do
  begin
    LValue := ObjectToJSon(FBWQryList.Items[LKey].BWQryCellDataCollect);
    LItem := FCellDataAllCollect.Add;
    LItem.ObjectJSON := UTF8ToString(LValue);
    LItem.QryName := LKey;
    LDynArr.Add(LValue);
  end;
end;

function TBWQuery.getContent(url: String): String;
var
  LIdHTTP: TIdHTTP;
begin
  LIdHTTP := TIdHTTP.Create(nil);
  LIdHTTP.HandleRedirects := True;
  try
    try
      Result := LIdHTTP.Get(url);
    except

    end;
  finally
    LIdHTTP.Free;
  end;
end;

function TBWQuery.GetCurQryClass: TBWQryClass;
var
  LKey: string;
begin
  for LKey in FBWQryList.Keys do
  begin
    if FCurQryKey = FBWQryList.Items[LKey].QueryName then
    begin
      Result := FBWQryList.Items[LKey];
      break;
    end;
  end;
end;

function TBWQuery.GetEndOfMonth(ADate: TDate): string;
begin
  Result := IntToStr(MonthDays[IsLeapYear(YearOf(ADate)), MonthOf(ADate)]);
end;

function TBWQuery.GetInquiryPerProdPerGrade: TRawUTF8DynArray;
const
  ExchangeRate4USD = 1080;
var
  LBWQryClass: TBWQryClass;
  LCount: integer;
  LDynArr: TDynArray;
  LValue: RawUTF8;
  i,j: integer;
  LSum : array of array of extended; //�ڿ��� ��޺� ���� �ݾ�
  LStr: string;
begin
  LDynArr.Init(TypeInfo(TRawUTF8DynArray),Result,@LCount);

  LBWQryClass := nil;
  LBWQryClass := GetQueryClass('ZKA_ZKSDINM01_D_T_Q201_1');

  if Assigned(LBWQryClass) then
  begin
    SetLength(LSum, 4, 9);
//    FillChar(LSum, Length(LSum), 0);  //���� ��, ���� ��(�ʱ�ȭ�� �ڵ����� ��)
    try
      for i := 0 to LBWQryClass.BWQryCellDataCollect.Count - 1 do
      begin
        if LBWQryClass.BWQryCellDataCollect.Items[i].CellData = '' then
          continue;

        //�ڿ���
        if ((LBWQryClass.BWQryCellDataCollect.Items[i].Row >= 1) and (LBWQryClass.BWQryCellDataCollect.Items[i].Row <= 6)) then
        begin
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 5) then
            LSum[0,0] := LSum[0,0] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//A ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 11) then
            LSum[0,1] := LSum[0,1] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//A2 ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 17) then
            LSum[0,2] := LSum[0,2] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//B ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 23) then
            LSum[0,3] := LSum[0,3] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//B1 ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 29) then
            LSum[0,4] := LSum[0,4] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//C ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 35) then
            LSum[0,5] := LSum[0,5] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//D ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 41) then
            LSum[0,6] := LSum[0,6] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//FO ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 47) then
            LSum[0,7] := LSum[0,7] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//S ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 53) then
            LSum[0,8] := LSum[0,8] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0);//��Ÿ ��� �⴩��($)
        end
        else//��������
        if ((LBWQryClass.BWQryCellDataCollect.Items[i].Row >= 7) and (LBWQryClass.BWQryCellDataCollect.Items[i].Row <= 12)) then
        begin
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 5) then
            LSum[1,0] := LSum[1,0] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//A ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 11) then
            LSum[1,1] := LSum[1,1] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//A2 ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 17) then
            LSum[1,2] := LSum[1,2] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//B ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 23) then
            LSum[1,3] := LSum[1,3] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//B1 ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 29) then
            LSum[1,4] := LSum[1,4] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//C ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 35) then
            LSum[1,5] := LSum[1,5] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//D ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 41) then
            LSum[1,6] := LSum[1,6] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//FO ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 47) then
            LSum[1,7] := LSum[1,7] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//S ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 53) then
            LSum[1,8] := LSum[1,8] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0);//��Ÿ ��� �⴩��($)
        end
        else//������
        if ((LBWQryClass.BWQryCellDataCollect.Items[i].Row >= 13) and (LBWQryClass.BWQryCellDataCollect.Items[i].Row <= 15)) then
        begin
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 5) then
            LSum[2,0] := LSum[2,0] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//A ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 11) then
            LSum[2,1] := LSum[2,1] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//A2 ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 17) then
            LSum[2,2] := LSum[2,2] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//B ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 23) then
            LSum[2,3] := LSum[2,3] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//B1 ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 29) then
            LSum[2,4] := LSum[2,4] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//C ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 35) then
            LSum[2,5] := LSum[2,5] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//D ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 41) then
            LSum[2,6] := LSum[2,6] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//FO ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 47) then
            LSum[2,7] := LSum[2,7] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//S ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 53) then
            LSum[2,8] := LSum[2,8] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0);//��Ÿ ��� �⴩��($)
        end
        else//�κ��ý���
        if ((LBWQryClass.BWQryCellDataCollect.Items[i].Row >= 16) and (LBWQryClass.BWQryCellDataCollect.Items[i].Row <= 20)) then
        begin
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 5) then
            LSum[3,0] := LSum[3,0] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//A ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 11) then
            LSum[3,1] := LSum[3,1] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//A2 ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 17) then
            LSum[3,2] := LSum[3,2] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//B ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 23) then
            LSum[3,3] := LSum[3,3] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//B1 ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 29) then
            LSum[3,4] := LSum[3,4] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//C ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 35) then
            LSum[3,5] := LSum[3,5] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//D ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 41) then
            LSum[3,6] := LSum[3,6] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//FO ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 47) then
            LSum[3,7] := LSum[3,7] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0)//S ��� �⴩��($)
          else
          if (LBWQryClass.BWQryCellDataCollect.Items[i].Col = 53) then
            LSum[3,8] := LSum[3,8] + StrToFloatDef(LBWQryClass.BWQryCellDataCollect.Items[i].CellData, 0.0);//��Ÿ ��� �⴩��($)
        end
      end;

      for i := Low(LSum) to High(LSum) do
      begin
        for j := Low(LSum[0]) to High(LSum[0]) do
        begin
          LValue := StringToUTF8(FormatFloat(',0', LSum[i,j]/100000000 * ExchangeRate4USD));  //���� ���
          LDynArr.Add(LValue);
        end;
      end;
    finally
      LSum := nil;
    end;

//      LStr := IntToStr(LBWQryClass.BWQryCellDataCollect.Items[i].Col) + ':' +
//      IntToStr(LBWQryClass.BWQryCellDataCollect.Items[i].Row) + ' = ' +
//      LBWQryClass.BWQryCellDataCollect.Items[i].CellData;
//      Memo1.Lines.Add(LStr);

  end;

  g_DisplayMessage2FCS(DateTimeToStr(Now) + ' : GetInquiryPerProdPerGrade [ ' + IntToStr(LDynArr.Count) + ' �� ������ ���� ]', 2);//dtCommLog
end;

function TBWQuery.GetOrderPlanPerProduct(const task: IOmniTask): boolean;
begin
  if FQryCount = 0 then
    exit;

  FOrderPlanPerProduct.Clear;

  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q201', 7, FOrderPlanPerProduct);
  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q203', 7, FOrderPlanPerProduct);
  //���������/��ȹ �����Ϳ��� "���ڽ�" �׸��� ���� ���� ARow���� 4->3���� ������
  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q206', 3, FOrderPlanPerProduct);
  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q208', 6, FOrderPlanPerProduct);
  _GetBizPlanPerProduct('ZKA_ZKSDSOM01_D_C_Q218_1', 5, FOrderPlanPerProduct);
end;

function TBWQuery.GetProfitPlanPerProduct(const task: IOmniTask): boolean;
begin
  if FQryCount = 0 then
    exit;

  FProfitPlanPerProduct.Clear;

  _GetBizPlanPerProduct('ZKA_ZKEISM003_D_C_Q001_1', 0, FProfitPlanPerProduct,6);
end;

function TBWQuery.GetQueryClass(AQueryName: string): TBWQryClass;
var
  LKey: string;
begin
  for LKey in FBWQryList.Keys do
  begin
//    if FBWQryList.Items[LKey].QueryName = AQueryName then
    if LKey = AQueryName then
    begin
      FCurQryKey := LKey;
      Result := GetCurQryClass;
      exit;
    end;
  end;
end;

function TBWQuery.GetQueryType(AQueryName: string): integer;
var
  LKey: string;
begin
  for LKey in FBWQryList.Keys do
  begin
    if FCurQryKey = FBWQryList.Items[LKey].QueryName then
    begin
      Result := FBWQryList.Items[LKey].QueryType;
      break;
    end;
  end;
end;

function TBWQuery.GetSalesPlanPerProduct(const task: IOmniTask): boolean;
begin
  if FQryCount = 0 then
    exit;

  FSalesPlanPerProduct.Clear;

  _GetBizPlanPerProduct('ZKA_ZKSDBIM01_D_C_Q225_1', 0, FSalesPlanPerProduct, 5);
end;

procedure TBWQuery.HeaderData2Grid(ABWQryClass: TBWQryClass;
  AGrid: TAdvStringGrid);
var
  i, j, LCount, LCol, LRow: integer;
  LColX, LRowX, LSpanY: integer;
  LColX2, LRowX2, LSpanY2: integer;
  LStr, LMerge1, LMerge2: string;
begin
  LCount := ABWQryClass.BWQryRowHeaderCollect.ColCountOfRow;
  AGrid.ColCount := ABWQryClass.BWQryColumnHeaderCollect.Count+LCount;
  AGrid.RowCount := ABWQryClass.BWQryRowHeaderCollect.Count;
  AGrid.FixedCols := LCount;
  AGrid.FixedRows := 1;

  for i := 0 to ABWQryClass.BWQryColumnHeaderCollect.Count - 1 do
  begin
    LCol := LCount + i;
    LRow := 0;
    LStr := ABWQryClass.BWQryColumnHeaderCollect.Items[i].ColumnHeaderData;
    LStr := StringReplace(LStr, '���־�-', '', [rfReplaceAll, rfIgnoreCase]);
    AGrid.Cells[LCol, LRow] := LStr;
  end;

  LRowX := 1;
  LColX := 0;
  LMerge1 := 'A';
  LRowX2 := 1;
  LColX2 := 1;
  LMerge2 := 'AE';
  LSpanY := 0;
  LSpanY2 := 0;

  for i := 0 to ABWQryClass.BWQryRowHeaderCollect.Count - 1 do
  begin
    LStr := ABWQryClass.BWQryRowHeaderCollect.Items[i].RowHeaderData;

    for j := 0 to LCount - 1 do
    begin
      LCol := j;
      LRow := i+1;
      AGrid.Cells[LCol, LRow] := strToken(LStr, ';');

      if j = 0 then
      begin
        if LMerge1 <> AGrid.Cells[LCol, LRow] then
        begin
          AGrid.MergeCells(LColX, LRowX, 1, LSpanY);
          LSpanY := 1;
          LRowX := LRow;
          LColX := j;
          LMerge1 := AGrid.Cells[LCol, LRow];
        end
        else
        begin
          Inc(LSpanY);
        end;
      end
      else
      if j = 1 then
      begin
        if LMerge2 <> AGrid.Cells[LCol, LRow] then
        begin
          AGrid.MergeCells(LColX2, LRowX2, 1, LSpanY2);
          LSpanY2 := 1;
          LRowX2 := LRow;
          LColX2 := j;
          LMerge2 := AGrid.Cells[LCol, LRow];
        end
        else
        begin
          Inc(LSpanY2);
        end;
      end;
    end;
  end;
end;

procedure TBWQuery.LoadInquiryList(ABWQryClass: TBWQryClass);
var
  LInquiryInfo: TInquiryInfo;
  i, LRow, LCount: integer;
  LStr: string;
begin
  ClearInqryList;
  LCount := ABWQryClass.BWQryRowHeaderCollect.ColCountOfRow;

  for i := 0 to ABWQryClass.BWQryRowHeaderCollect.Count - 1 do
  begin
    LStr := ABWQryClass.BWQryRowHeaderCollect.Items[i].RowHeaderData;

    LInquiryInfo := TInquiryInfo.Create;
    LInquiryInfo.FRow := i+1;
    LInquiryInfo.ProductCategory := strToken(LStr, ';');
    LInquiryInfo.ProjectName := strToken(LStr, ';');
    LInquiryInfo.ShipNo := strToken(LStr, ';');
    LInquiryInfo.ProductType := strToken(LStr, ';');
    LInquiryInfo.ContractDate := strToken(LStr, ';');
    LInquiryInfo.DueDate := strToken(LStr, ';');
    LInquiryInfo.CustomerName := strToken(LStr, ';');
    LInquiryInfo.CustomerNation := strToken(LStr, ';');
    LInquiryInfo.InqNo := strToken(LStr, ';');
    LInquiryInfo.InquiryRecvDate := strToken(LStr, ';');

    FInquiryList.Add(LInquiryInfo.FRow, LInquiryInfo);
  end;

  for i := 0 to ABWQryClass.BWQryCellDataCollect.Count - 1 do
  begin
    LRow := ABWQryClass.BWQryCellDataCollect.Items[i].Row+1;
    LInquiryInfo := FInquiryList.Items[LRow];

    if LInquiryInfo.FRow = LRow then
    begin
      case (i mod 2) of
        0: LInquiryInfo.ProductCount := ABWQryClass.BWQryCellDataCollect.Items[i].CellData;
        1: LInquiryInfo.Price := ABWQryClass.BWQryCellDataCollect.Items[i].CellData;
      end;
    end;
  end;
end;

procedure TBWQuery.LoadQueryListFromTxt;
var
  LBWQryListClass: TBWQryListClass;
  LBWQryClass: TBWQryClass;
  i: integer;
begin
  LBWQryListClass := TBWQryListClass.Create(nil);

  try
    LBWQryListClass.LoadFromTxt('BWQuery.txt');

    for i := 0 to LBWQryListClass.BWQryCollect.Count - 1 do
    begin
      LBWQryClass := TBWQryClass.Create(nil);
      LBWQryClass.Description := LBWQryListClass.BWQryCollect.Items[i].Description;
      LBWQryClass.QueryName := LBWQryListClass.BWQryCollect.Items[i].QueryName;
      LBWQryClass.QueryText := LBWQryListClass.BWQryCollect.Items[i].QueryText;
      LBWQryClass.QueryType := LBWQryListClass.BWQryCollect.Items[i].QueryType;
      LBWQryClass.QryParamType := LBWQryListClass.BWQryCollect.Items[i].QryParamType;

      FBWQryList.Add(LBWQryClass.QueryName, LBWQryClass);
    end;
  finally
    LBWQryListClass.Free;
  end;
end;

procedure TBWQuery.OnGetBWQuery(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  g_ClearMessage;
  g_DisplayMessage2MainForm(FormatDateTime('mm�� dd��, hh:nn:ss => ', now) + '=================');

  FGetBWQryFuture := Parallel.Future<Boolean>(GetBWQuery, Parallel.TaskConfig.OnTerminated(OnGetBWQueryCompleted));
//  Parallel.Async(GetBWQuery, Parallel.TaskConfig.OnTerminated(OnGetBWQueryCompleted));
end;

procedure TBWQuery.OnGetBWQueryCompleted(const task: IOmniTaskControl);
var
  LStr: string;
begin
//  QProgress1.Active := False;
//  FQryRunning := False;
  LStr := g_GetFormCaption;
  LStr := Copy(LStr, 1, Pos(' => ', LStr) - 1);

  if LStr = '' then
    LStr := g_GetFormCaption;

  g_SetFormCaption(LStr + ' => ' + IntToStr(FQryCount) + ' Query Updated: ' + FormatDateTime('mm�� dd��, hh:nn:ss', now));

  FPJHTimerPool.AddOneShot(OnGetBWQuery, 1800000);//1800000

  if FOrderPlanPerProduct.Count = 0 then
    Parallel.Future<Boolean>(GetOrderPlanPerProduct, Parallel.TaskConfig.OnTerminated(OnGetOrderPlanPerProductCompleted));

  if FSalesPlanPerProduct.Count = 0 then
    Parallel.Future<Boolean>(GetSalesPlanPerProduct, Parallel.TaskConfig.OnTerminated(OnGetSalesPlanPerProductCompleted));

  if FProfitPlanPerProduct.Count = 0 then
    Parallel.Future<Boolean>(GetProfitPlanPerProduct, Parallel.TaskConfig.OnTerminated(OnGetProfitPlanPerProductCompleted));

  FGetQrying := False;
end;

procedure TBWQuery.OnGetOrderPlanPerProductCompleted(
  const task: IOmniTaskControl);
var
  i: integer;
  LStr: string;
begin
  for i := 0 to FOrderPlanPerProduct.Count - 1 do
  begin
    LStr := LStr + IntToStr(FOrderPlanPerProduct.Items[i].Col) + ',' +
          IntToStr(FOrderPlanPerProduct.Items[i].Row) + ',' + FOrderPlanPerProduct.Items[i].CellData + #13#10;
  end;

  g_DisplayMessage2MainForm('============================================================================');
  g_DisplayMessage2MainForm(LStr);
  g_DisplayMessage2MainForm('============================================================================');
end;

procedure TBWQuery.OnGetProfitPlanPerProductCompleted(
  const task: IOmniTaskControl);
var
  i: integer;
  LStr: string;
begin
  for i := 0 to FProfitPlanPerProduct.Count - 1 do
  begin
    LStr := LStr + IntToStr(FProfitPlanPerProduct.Items[i].Col) + ',' +
          IntToStr(FProfitPlanPerProduct.Items[i].Row) + ',' + FProfitPlanPerProduct.Items[i].CellData + #13#10;
  end;

  g_DisplayMessage2MainForm('============================================================================');
  g_DisplayMessage2MainForm(LStr);
  g_DisplayMessage2MainForm('============================================================================');
end;

procedure TBWQuery.OnGetSalesPlanPerProductCompleted(
  const task: IOmniTaskControl);
var
  i: integer;
  LStr: string;
begin
  for i := 0 to FSalesPlanPerProduct.Count - 1 do
  begin
    LStr := LStr + IntToStr(FSalesPlanPerProduct.Items[i].Col) + ',' +
          IntToStr(FSalesPlanPerProduct.Items[i].Row) + ',' + FSalesPlanPerProduct.Items[i].CellData + #13#10;
  end;

  g_DisplayMessage2MainForm('============================================================================');
  g_DisplayMessage2MainForm(LStr);
  g_DisplayMessage2MainForm('============================================================================');
end;

procedure TBWQuery.ProcessQueryXML(AXMLString: string; const task: IOmniTask);
var
  LXMLDoc: IXMLDocument;
  LRootNode, LSubNode, LLeafNode, LLeafNode2: IXMLNode;
  LBWQryClass: TBWQryClass;
  LBWQryCellDataItem: TBWQryCellDataItem;
  LBWQryRowHeaderItem: TBWQryRowHeaderItem;
  LBWQryColumnHeaderItem: TBWQryColumnHeaderItem;
  i,j,k: integer;
  LCol, LRow: integer;
begin
  LXMLDoc := CreateXMLDoc;
  try
    LXMLDoc.LoadXML(AXMLString);

    if LXMLDoc.DocumentElement <> nil then
    begin
      LRootNode := LXMLDoc.DocumentElement;

      for i := 0 to LRootNode.ChildNodes.Length - 1 do
      begin
        if task.CancellationToken.IsSignalled then
          break;

        LSubNode := LRootNode.ChildNodes.Item[i];

        if LSubNode.NodeName = 'variable' then
        begin
          if LSubNode.Attributes.Length > 0 then
          begin
            if LSubNode.Attributes.Item[0].NodeValue = 'colHeader' then
            begin
              LBWQryClass := GetCurQryClass;
              LBWQryClass.BWQryColumnHeaderCollect.Clear;

              for j := 0 to LSubNode.ChildNodes.Length - 1 do
              begin
                LSubNode := LSubNode.ChildNodes.Item[j];

                if LSubNode.NodeName = 'row' then
                begin
                  for k := 0 to LSubNode.ChildNodes.Length - 1 do
                  begin
                    LLeafNode2 := LSubNode.ChildNodes.Item[k];

                    if LLeafNode2.NodeName = 'column' then
                    begin
                      if LLeafNode2.HasChildNodes then
                      begin
                        LBWQryColumnHeaderItem := LBWQryClass.BWQryColumnHeaderCollect.Add;
                        LLeafNode2 := LLeafNode2.ChildNodes.Item[0];//CDATA Section
                        LBWQryColumnHeaderItem.ColumnHeaderData := LBWQryColumnHeaderItem.ColumnHeaderData +
                                        LLeafNode2.NodeValue + ';';
                        LBWQryColumnHeaderItem.ColumnHeaderLevel := j;
                      end;
                    end;
                  end;//for
                end;
              end;//for

              LBWQryClass.BWQryColumnHeaderCollect.FixedColumnCount := j;
            end
            else
            if LSubNode.Attributes.Item[0].NodeValue = 'rowHeader' then
            begin
              LBWQryClass := GetCurQryClass;
              LBWQryClass.BWQryRowHeaderCollect.Clear;

              for j := 0 to LSubNode.ChildNodes.Length - 1 do
              begin
                LLeafNode := LSubNode.ChildNodes.Item[j];

                if LLeafNode.NodeName = 'row' then
                begin
                  LBWQryRowHeaderItem := LBWQryClass.BWQryRowHeaderCollect.Add;

                  for k := 0 to LLeafNode.ChildNodes.Length - 1 do //row ���� column �� ���O �ݺ�
                  begin
                    LLeafNode2 := LLeafNode.ChildNodes.Item[k];

                    if LLeafNode2.NodeName = 'column' then
                    begin
                      if LLeafNode2.HasChildNodes then
                      begin
                        LLeafNode2 := LLeafNode2.ChildNodes.Item[0];//CDATA Section
                        LBWQryRowHeaderItem.RowHeaderData := LBWQryRowHeaderItem.RowHeaderData + LLeafNode2.NodeValue + ';';
                      end;
                    end;
                  end;//for

                  LBWQryClass.BWQryRowHeaderCollect.ColCountOfRow := LLeafNode.ChildNodes.Length;
                end;
              end;//for
            end
            else
            if LSubNode.Attributes.Item[0].NodeValue = 'cellData' then
            begin
              LBWQryClass := GetCurQryClass;
              LBWQryClass.BWQryCellDataCollect.Clear;

              for j := 0 to LSubNode.ChildNodes.Length - 1 do
              begin
                LLeafNode := LSubNode.ChildNodes.Item[j];

                if LLeafNode.NodeName = 'row' then
                begin
                  for k := 0 to LLeafNode.ChildNodes.Length - 1 do
                  begin
                    LLeafNode2 := LLeafNode.ChildNodes.Item[k];

                    if LLeafNode2.NodeName = 'column' then
                    begin
                      if LLeafNode2.HasChildNodes then
                      begin
                        LLeafNode2 := LLeafNode2.ChildNodes.Item[0];//CDATA Section
                        LBWQryCellDataItem := LBWQryClass.BWQryCellDataCollect.Add;
                        LBWQryCellDataItem.Row := j;
                        LBWQryCellDataItem.Col := k;
                        LBWQryCellDataItem.CellData := LLeafNode2.NodeValue
                      end;
                    end;
                  end;//for
                end;
              end;
            end
          end;
        end;
      end;
    end;
  finally
    ChangeDataFormat;

    LBWQryClass := GetCurQryClass;
    if LBWQryClass.QueryName = 'ZKA_ZKSDINM01_D_L_Q201' then
      LoadInquiryList(LBWQryClass);

    LXMLDoc := nil;
  end;
end;

procedure TBWQuery.QryData2DataView(AQueryName: string);
var
  LBWQryClass: TBWQryClass;
  LDataViewF: TDataViewF;
  LXlsFileName: string;
  i, LCol, LRow, LFixedColCount: integer;
  LQryType: integer;
begin
  LBWQryClass := nil;
  LBWQryClass := GetQueryClass(AQueryName);

  if Assigned(LBWQryClass) then
  begin
    LDataViewF := TDataViewF.Create(nil);
    try
      LXlsFileName := FExeFilePath + '..\Maps\' + AQueryName + '.xls';

      if FileExists(LXlsFileName) then
      begin
        LQryType := GetQueryType(AQueryName);
        case LQryType of
          0: LDataViewF.AdvGridExcelIO1.XLSImport(LXlsFileName);
          1: begin
            LDataViewF.AdvGridExcelIO1.XLSImport(LXlsFileName);
            RowHeaderNCellData2Grid(LBWQryClass, LDataViewF.AdvGridWorkbook1.Grid);
          end;
          2: begin
            LDataViewF.AdvGridExcelIO1.XLSImport(LXlsFileName);
            ColumnHeaderNCellData2Grid(LBWQryClass, LDataViewF.AdvGridWorkbook1.Grid);
          end;
        end;
      end
      else
        HeaderData2Grid(LBWQryClass, LDataViewF.AdvGridWorkbook1.Grid);

      if LQryType <> 2 then
      begin
        LFixedColCount := LBWQryClass.BWQryRowHeaderCollect.ColCountOfRow;

        for i := 0 to LBWQryClass.BWQryCellDataCollect.Count - 1 do
        begin
          LCol := LBWQryClass.BWQryCellDataCollect.Items[i].Col+LFixedColCount;
          LRow := LBWQryClass.BWQryCellDataCollect.Items[i].Row+1;
          LDataViewF.AdvGridWorkbook1.Grid.Cells[LCol, LRow] := LBWQryClass.BWQryCellDataCollect.Items[i].CellData;
        end;
      end;

      LDataViewF.Panel1.Caption := LBWQryClass.Description;
      LDataViewF.ShowModal;
    finally
      LDataViewF.Free;
    end;
  end;
end;

procedure TBWQuery.RowHeaderNCellData2Grid(ABWQryClass: TBWQryClass;
  AGrid: TAdvStringGrid);
var
  i, j, LCount, LCol, LRow: integer;
  LStr: string;
begin
  LCount := ABWQryClass.BWQryRowHeaderCollect.ColCountOfRow;
  AGrid.ColCount := ABWQryClass.BWQryColumnHeaderCollect.Count + LCount;
  AGrid.RowCount := ABWQryClass.BWQryRowHeaderCollect.Count;
  AGrid.FixedRows := 1;
  AGrid.FixedCols := 0;

  for i := 0 to ABWQryClass.BWQryRowHeaderCollect.Count - 1 do
  begin
    LStr := ABWQryClass.BWQryRowHeaderCollect.Items[i].RowHeaderData;

    for j := 0 to LCount - 1 do
    begin
      LCol := j;
      LRow := i+1;
      AGrid.Cells[LCol, LRow] := strToken(LStr, ';');
    end;
  end;
end;

function TBWQuery.SetQryParamType(AQryText: string; const AParamName: string;
  AParamType: TQryParameterType; AParamDir: TQryParameterDir;
  ADate: TDate): string;
var
  LNewQryTxt: string;
begin
  case AParamType of
    qptYear: begin
      if AParamDir = qpdBegin then
        LNewQryTxt := AParamName + FormatDateTime('yyyy', ADate) + '0101'
      else
      if AParamDir = qpdCustom then
        LNewQryTxt := AParamName + FormatDateTime('yyyymmdd', ADate)
      else
      if AParamDir = qpdEnd then
        LNewQryTxt := AParamName + FormatDateTime('yyyy', ADate) + '1231';
    end;

    qptMonth: begin
      if AParamDir = qpdBegin then
        LNewQryTxt := AParamName + FormatDateTime('yyyymm', ADate) + '01'
      else
      if AParamDir = qpdCustom then
        LNewQryTxt := AParamName + FormatDateTime('yyyymmdd', ADate)
      else
      if AParamDir = qpdEnd then
        LNewQryTxt := AParamName + FormatDateTime('yyyymm', ADate) + GetEndOfMonth(ADate);
    end;

    qptDay: begin
      LNewQryTxt := AParamName + FormatDateTime('yyyymmdd', ADate)
    end;
  end;

  Result := StringReplace(AQryText, AParamName, LNewQryTxt, [rfReplaceAll, rfIgnoreCase]);
end;

procedure TBWQuery._GetBizPlanPerProduct(AQryName: string; ARow: integer;
  ACollect: TBWQryCellDataCollect; AExcludeRow: integer);
var
  LBWQryClass: TBWQryClass;
  i, LCol, LRow: integer;
begin
  LBWQryClass := nil;
  LBWQryClass := GetQueryClass(AQryName);

  if Assigned(LBWQryClass) then
  begin
    for i := 0 to LBWQryClass.BWQryCellDataCollect.Count - 1 do
    begin
      LCol := LBWQryClass.BWQryCellDataCollect.Items[i].Col;
      LRow := LBWQryClass.BWQryCellDataCollect.Items[i].Row;

      if AExcludeRow <> -1 then
        if AExcludeRow <= LRow then
          continue;

      if ARow = 0 then
      begin
        with ACollect.Add do
        begin
          Col := LCol;
          Row := LRow;
          CellData := LBWQryClass.BWQryCellDataCollect.Items[i].CellData;
//          DataName := LBWQryClass.BWQryCellDataCollect.Items[i].DataName;
        end;
      end
      else
      if LRow = ARow then
      begin
        with ACollect.Add do
        begin
          Col := LCol;
          Row := LRow;
          CellData := LBWQryClass.BWQryCellDataCollect.Items[i].CellData;
//          DataName := LBWQryClass.BWQryCellDataCollect.Items[i].DataName;
        end;
      end;
    end;
  end;
end;

end.
>>>>>>> .r1752
