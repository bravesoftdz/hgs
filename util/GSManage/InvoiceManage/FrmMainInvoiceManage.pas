unit FrmMainInvoiceManage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.SyncObjs, WinApi.ActiveX,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, AeroButtons, Vcl.ExtCtrls,
  Vcl.ImgList, NxColumnClasses, NxColumns, NxScrollControl, NxCustomGridControl,
  NxCustomGrid, NxGrid, AdvOfficeTabSet, Vcl.ComCtrls, AdvGroupBox,
  AdvOfficeButtons, JvExControls, JvLabel, CurvyControls,
  OtlCommon, OtlComm, OtlTaskControl, OtlContainerObserver, otlTask, otlParallel,
  DragDropInternet,DropSource,DragDropFile,DragDropFormats, DragDrop, DropTarget,
  mORMot, SynCommons, SynSqlite3Static, CommonData, UElecDataRecord,
  FSMClass_Dic, FSMState, Vcl.Menus;

type
  TInvoiceManageF = class(TForm)
    CurvyPanel1: TCurvyPanel;
    JvLabel2: TJvLabel;
    JvLabel5: TJvLabel;
    JvLabel6: TJvLabel;
    JvLabel7: TJvLabel;
    PeriodPanel: TCurvyPanel;
    Label4: TLabel;
    rg_period: TAdvOfficeRadioGroup;
    dt_begin: TDateTimePicker;
    dt_end: TDateTimePicker;
    ComboBox1: TComboBox;
    SubjectEdit: TEdit;
    HullNoEdit: TEdit;
    ShipNameEdit: TEdit;
    TaskTab: TAdvOfficeTabSet;
    grid_Req: TNextGrid;
    NxIncrementColumn1: TNxIncrementColumn;
    HullNo: TNxTextColumn;
    ShipName: TNxTextColumn;
    Subject: TNxTextColumn;
    Status: TNxTextColumn;
    NextProcess: TNxTextColumn;
    RecvDate: TNxDateColumn;
    Email: TNxButtonColumn;
    EMailID: TNxTextColumn;
    PONo: TNxTextColumn;
    QtnNo: TNxTextColumn;
    OrderNo: TNxTextColumn;
    CustomerName: TNxTextColumn;
    QtnInputDate: TNxDateColumn;
    OrderInputDate: TNxDateColumn;
    InvoiceInputDate: TNxDateColumn;
    CustomerAddress: TNxMemoColumn;
    imagelist24x24: TImageList;
    ImageList32x32: TImageList;
    ImageList16x16: TImageList;
    Panel1: TPanel;
    btn_Search: TAeroButton;
    btn_Close: TAeroButton;
    AeroButton1: TAeroButton;
    JvLabel9: TJvLabel;
    OrderNoEdit: TEdit;
    DropEmptyTarget1: TDropEmptyTarget;
    DataFormatAdapterOutlook: TDataFormatAdapter;
    DataFormatAdapterTarget: TDataFormatAdapter;
    DataFormatAdapter1: TDataFormatAdapter;
    DropEmptySource1: TDropEmptySource;
    DataFormatAdapter2: TDataFormatAdapter;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Close1: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    Items1: TMenuItem;
    Delete1: TMenuItem;

    procedure btn_SearchClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DropEmptyTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      APoint: TPoint; var Effect: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure grid_ReqCellDblClick(Sender: TObject; ACol, ARow: Integer);
    procedure btn_CloseClick(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure grid_ReqMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Delete1Click(Sender: TObject);
  private
    FStopEvent    : TEvent;
    FAsyncMQ: TOmniMessageQueue;
    FTaskJson: String;
    FFileContent: RawByteString;

    procedure AsyncProcessMQ;
    procedure OnGetStream(Sender: TFileContentsStreamOnDemandClipboardFormat;
      Index: integer; out AStream: IStream);

    function GetSqlWhereFromQueryDate(AQueryDate: TQueryDateType): string;
    function ProcessInvoiceTaskJson(AJson: String): Boolean;
    function GetTaskIdFromGrid(ARow: integer): TID;
    function SaveCurrentTask2File(AFileName: string = '') : string;
    function GetTask: TSQLInvoiceTask;
  public
    procedure DisplayTaskInfo2Grid(AFrom,ATo: TDateTime; AQueryDate: TQueryDateType;
      AHullNo, AShipName, ASubject, AOrderNo: string);
    procedure LoadTaskVar2Grid(AVar: TSQLInvoiceTask; AGrid: TNextGrid;
      ARow: integer = -1);

    procedure ShowInvoiceTaskEditFormFromGrid(ARow: integer);overload;
  end;

var
  InvoiceManageF: TInvoiceManageF;

implementation

uses VarRecUtils, UnitDragUtil, UnitVariantJsonUtil, FrmInvoiceEdit;

{$R *.dfm}

procedure TInvoiceManageF.AsyncProcessMQ;
begin
  Parallel.Async(
    procedure (const task: IOmniTask)
    var
      i: integer;
      handles: array [0..1] of THandle;
      msg    : TOmniMessage;
      rec    : TOLMsgFileRecord;
      LID: TID;
      LTaskIds: TIDDynArray;
      LIsAddTask,  //True=�ű� Task ���
      LIsProcessJson: Boolean; //Task������ Json���Ϸ� ����
      LStr: string;
    begin
      handles[0] := FStopEvent.Handle;
      handles[1] := FAsyncMQ.GetNewMessageEvent;

      while WaitForMultipleObjects(2, @handles, false, INFINITE) = (WAIT_OBJECT_0 + 1) do
      begin
        while FAsyncMQ.TryDequeue(msg) do
        begin
          rec := msg.MsgData.ToRecord<TOLMsgFileRecord>;

          if msg.MsgID = 1 then
          begin
            LStr := rec.FSubject;
            LIsProcessJson := True;
          end
          else
          if msg.MsgID = 2 then
          begin
          end
          else
          if msg.MsgID = 3 then
          begin
          end;

          task.Invoke(
            procedure
            begin
              if LIsAddTask then
              begin
              end;

              if LIsProcessJson then
              begin
                ProcessInvoiceTaskJson(LStr);
              end;
            end
          );
        end;//while
      end;//while
    end,

    Parallel.TaskConfig.OnMessage(Self).OnTerminated(
      procedure
      begin
//        FreeAndNil(LEmailMsg);
      end
    )
  );

end;

procedure TInvoiceManageF.btn_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TInvoiceManageF.btn_SearchClick(Sender: TObject);
var
  LQueryDateType: TQueryDateType;
begin
  if ComboBox1.ItemIndex = -1 then
    LQueryDateType := qdtNull
  else
    LQueryDateType := R_QueryDateType[TQueryDateType(ComboBox1.ItemIndex)].Value;

  DisplayTaskInfo2Grid(dt_Begin.Date, dt_end.Date, LQueryDateType,
    HullNoEdit.Text, ShipNameEdit.Text, SubjectEdit.Text, OrderNoEdit.Text);
end;

procedure TInvoiceManageF.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TInvoiceManageF.Delete1Click(Sender: TObject);
var
  LIdList: TIDList;
begin
  if grid_Req.SelectedRow = -1 then
    exit;

  if grid_Req.Row[grid_Req.SelectedRow].Data <> nil then
  begin
    LIdList := TIDList(grid_Req.Row[grid_Req.SelectedRow].Data);
    DeleteInvoiceTaskFromID(LIdList.TaskId);
    btn_SearchClick(nil);
  end;
end;

procedure TInvoiceManageF.DisplayTaskInfo2Grid(AFrom, ATo: TDateTime;
  AQueryDate: TQueryDateType; AHullNo, AShipName, ASubject, AOrderNo: string);
var
  ConstArray: TConstArray;
  LWhere, LStr: string;
  LSQLInvoiceTask: TSQLInvoiceTask;
  LFrom, LTo: TTimeLog;
begin
  LWhere := '';
  ConstArray := CreateConstArray([]);
  try
    if AQueryDate <> qdtNull then
    begin
      if AFrom <= ATo then
      begin
        LFrom := TimeLogFromDateTime(AFrom);
        LTo := TimeLogFromDateTime(ATo);

        if AQueryDate <> qdtNull then
        begin
          AddConstArray(ConstArray, [LFrom, LTo]);
          LWhere := GetSqlWhereFromQueryDate(AQueryDate);
        end;
      end;
    end;

    if AHullNo <> '' then
    begin
      AddConstArray(ConstArray, ['%'+AHullNo+'%']);
      if LWhere <> '' then
        LWhere := LWhere + ' and ';
      LWhere := LWhere + 'HullNo LIKE ? ';
    end;

    if AShipName <> '' then
    begin
      AddConstArray(ConstArray, ['%'+AShipName+'%']);
      if LWhere <> '' then
        LWhere := LWhere + ' and ';
      LWhere := LWhere + ' ShipName LIKE ? ';
    end;

    if ASubject <> '' then
    begin
      AddConstArray(ConstArray, ['%'+ASubject+'%']);
      if LWhere <> '' then
        LWhere := LWhere + ' and ';
      LWhere := LWhere + ' WorkSummary LIKE ? ';
    end;

    if AOrderNo <> '' then
    begin
      AddConstArray(ConstArray, ['%'+AOrderNo+'%']);
      if LWhere <> '' then
        LWhere := LWhere + ' and ';
      LWhere := LWhere + ' Order_No LIKE ? ';
    end;

    if LWhere = '' then
    begin
      //�Ϸ���� ���� ��� Task�� ������
      AddConstArray(ConstArray, [-1]);
      LWhere := 'ID <> ?';
//      ShowMessage('��ȸ ������ �����ϼ���.');
//      exit;
    end;

    LSQLInvoiceTask := TSQLInvoiceTask.CreateAndFillPrepare(g_InvoiceProjectDB, Lwhere, ConstArray);

    try
      grid_Req.ClearRows;

      while LSQLInvoiceTask.FillOne do
      begin
        grid_Req.BeginUpdate;
        try
          LoadTaskVar2Grid(LSQLInvoiceTask, grid_Req);
        finally
          grid_Req.EndUpdate;
        end;
      end;
    finally
      LSQLInvoiceTask.Free;
    end;
  finally
    FinalizeConstArray(ConstArray);
  end;
end;

procedure TInvoiceManageF.DropEmptyTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; APoint: TPoint; var Effect: Integer);
var
  LTargetStream: TStream;
  LStr: RawByteString;
  LProcessOK: Boolean;
  LFileName: string;
  rec    : TOLMsgFileRecord;
  LOmniValue: TOmniValue;
begin
  LFileName := '';
  // ������ Ž���⿡�� Drag ���� ���
  if (DataFormatAdapter1.DataFormat <> nil) then
  begin
    LFileName := (DataFormatAdapter1.DataFormat as TFileDataFormat).Files.Text;

    if LFileName <> '' then
    begin
      if ExtractFileExt(LFileName) <> '.hgs' then
      begin
        ShowMessage('This file is not auto created by HGS from explorer');
        exit;
      end;

      LStr := StringFromFile(LFileName);
      rec.FSubject := LStr;
      LOmniValue := TOmniValue.FromRecord<TOLMsgFileRecord>(rec);
      FAsyncMQ.Enqueue(TOmniMessage.Create(1, LOmniValue));
      exit;
    end;
  end;

  // OutLook���� ÷�������� Drag ���� ���
  if (TVirtualFileStreamDataFormat(DataFormatAdapterTarget.DataFormat).FileNames.Count > 0) then
  begin
    LFileName := TVirtualFileStreamDataFormat(DataFormatAdapterTarget.DataFormat).FileNames[0];

    if ExtractFileExt(LFileName) <> '.msg' then
    begin
      if ExtractFileExt(LFileName) <> '.hgs' then
      begin
        ShowMessage('This file is not auto created by HGS');
        exit;
      end;

      LTargetStream := GetStreamFromDropDataFormat(TVirtualFileStreamDataFormat(DataFormatAdapterTarget.DataFormat));
      try
        if not Assigned(LTargetStream) then
          ShowMessage('Not Assigned');

        LStr := StreamToRawByteString(LTargetStream);

        rec.FSubject := LStr;
        LOmniValue := TOmniValue.FromRecord<TOLMsgFileRecord>(rec);
        FAsyncMQ.Enqueue(TOmniMessage.Create(1, LOmniValue));
        exit;
      finally
        if Assigned(LTargetStream) then
          LTargetStream.Free;
      end;
    end;
  end;
end;

procedure TInvoiceManageF.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FStopEvent.SetEvent;
end;

procedure TInvoiceManageF.FormCreate(Sender: TObject);
begin
  InitClient4InvoiceManage;
  FAsyncMQ := TOmniMessageQueue.Create(1000);
  FStopEvent := TEvent.Create;
  (DataFormatAdapter2.DataFormat as TVirtualFileStreamDataFormat).OnGetStream := OnGetStream;

  AsyncProcessMQ;
end;

procedure TInvoiceManageF.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FStopEvent);
  FAsyncMQ.Free;
end;

function TInvoiceManageF.GetSqlWhereFromQueryDate(AQueryDate: TQueryDateType): string;
begin
  case AQueryDate of
    qdtInqRecv: Result := 'InqRecvDate >= ? and InqRecvDate <= ? ';
    qdtInvoiceIssue: Result := 'InvoiceIssueDate >= ? and InvoiceIssueDate <= ? ';
  end;
end;

function TInvoiceManageF.GetTask: TSQLInvoiceTask;
var
  LTaskID: TID;
begin
  LTaskID := GetTaskIdFromGrid(grid_Req.SelectedRow);
  Result := GetInvoiceTaskFromID(LTaskID);
end;

function TInvoiceManageF.GetTaskIdFromGrid(ARow: integer): TID;
begin
  if Assigned(grid_Req.Row[ARow].Data) then
    Result := TIDList4Invoice(grid_Req.Row[ARow].Data).fTaskId
  else
    Result := -1;
end;

procedure TInvoiceManageF.grid_ReqCellDblClick(Sender: TObject; ACol,
  ARow: Integer);
var
  LTask: TSQLInvoiceTask;
begin
  if ARow = -1 then
    Exit;

  ShowInvoiceTaskEditFormFromGrid(ARow);
end;

procedure TInvoiceManageF.grid_ReqMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  LFileName: string;
begin
  if (DragDetectPlus(grid_Req.Handle, Point(X,Y))) then
  begin
    if grid_Req.SelectedRow = -1 then
      exit;

    TVirtualFileStreamDataFormat(DataFormatAdapter2.DataFormat).FileNames.Clear;
    LFileName := SaveCurrentTask2File;

    if LFileName <> '' then
      //���� �̸��� ������ ���� OnGetStream �Լ��� �� Ž
      TVirtualFileStreamDataFormat(DataFormatAdapter2.DataFormat).
            FileNames.Add(LFileName);

    DropEmptySource1.Execute;
  end;
end;

procedure TInvoiceManageF.LoadTaskVar2Grid(AVar: TSQLInvoiceTask; AGrid: TNextGrid;
  ARow: integer);
var
  LIds: TIDDynArray;
begin
  if not Assigned(AVar) then
    exit;

  if ARow = -1 then
  begin
    ARow := AGrid.AddRow;
    AGrid.Row[ARow].Data := TIDList4Invoice.Create;
    TIDList4Invoice(AGrid.Row[ARow].Data).TaskId := AVar.ID;
  end;

  with AVar, AGrid do
  begin
    CellByName['HullNo', ARow].AsString := HullNo;
    CellByName['ShipName', ARow].AsString := ShipName;
    CellByName['Subject', ARow].AsString := WorkSummary;
    CellByName['OrderNo', ARow].AsString := Order_No;
    CellByName['RecvDate', ARow].AsDateTime := TimeLogToDateTime(InqRecvDate);
    CellByName['InvoiceInputDate', ARow].AsDateTime := TimeLogToDateTime(InvoiceIssueDate);
  end;
end;

procedure TInvoiceManageF.New1Click(Sender: TObject);
begin
  ProcessInvoiceTaskJson('');
end;

procedure TInvoiceManageF.OnGetStream(
  Sender: TFileContentsStreamOnDemandClipboardFormat; Index: integer;
  out AStream: IStream);
var
  Data: AnsiString;
  LStream: TStringStream;
begin
  LStream := TStringStream.Create;
  try
    LStream.WriteString(FTaskJson);
    AStream := nil;
    AStream := TFixedStreamAdapter.Create(LStream, soOwned);
  except
    raise;
  end;
end;

procedure TInvoiceManageF.Open1Click(Sender: TObject);
var
  LStr: string;
begin
  if OpenDialog1.Execute then
  begin
    if FileExists(OpenDialog1.FileName) then
    begin
      LStr := StringFromFile(OpenDialog1.FileName);
      ProcessInvoiceTaskJson(LStr);
    end;
  end;
end;

function TInvoiceManageF.ProcessInvoiceTaskJson(AJson: String): Boolean;
var
  LDoc: variant;
  LTask: TSQLInvoiceTask;
  LUTF8: RawUTF8;
  LRaw: RawByteString;
  LRow: integer;
begin
  if AJson <> '' then
  begin
    TDocVariant.New(LDoc);
    LRaw := Base64ToBin(StringToUTF8(AJson));
    LRaw := SynLZDecompress(LRaw);
    //AnsiToUTF8(LRaw)�� ����ϸ� ÷������ ù���ڰ� ����Ǿ� ������
    LUTF8 := LRaw;
//    LUTF8 := AnsiToUTF8(LRaw);
    LDoc := _JSON(LUTF8);
    //InqManage.exe���� ������� *.hgs ������ ���
    Result := LDoc.TaskJsonDragSign = TASK_JSON_DRAG_SIGNATURE;

    if Result then
    begin
      LTask := GetInvoiceTaskFromUniqueID(LDoc.Task.UniqueTaskID);
      try
        if FrmInvoiceEdit.DisplayInvoiceTaskInfo2EditForm(LTask, LDoc) then
        begin
          if not LTask.IsUpdate then
          begin
            LoadTaskVar2Grid(LTask, grid_Req);
          end;
        end;
      finally
        if Assigned(LTask) then
          FreeAndNil(LTask);
      end;
    end
    else
      ShowMessage('Signature is not correct');
  end
  else
  begin
    LTask := GetInvoiceTaskFromHullNoNOrderNo('', '');
    try
      if FrmInvoiceEdit.DisplayInvoiceTaskInfo2EditForm(LTask, null) then
      begin
        if not LTask.IsUpdate then
        begin
          LoadTaskVar2Grid(LTask, grid_Req);
        end;
      end;
    finally
      if Assigned(LTask) then
        FreeAndNil(LTask);
    end;
  end;
end;

function TInvoiceManageF.SaveCurrentTask2File(AFileName: string): string;
var
  LTask: TSQLInvoiceTask;
  LFileName, LStr: string;
begin
  Result := '';
  LTask := GetTask;
  try
    if LTask.IsUpdate then
    begin
      FTaskJson := MakeInvoiceTaskInfo2JSON(LTask, LFileName);

      if AFileName = '' then
      begin
        AFileName := LFileName;
      end;

      Result := AFileName;
    end;
  finally
    LTask.Free;
  end;
end;

procedure TInvoiceManageF.ShowInvoiceTaskEditFormFromGrid(ARow: integer);
var
  LIdList: TIDList4Invoice;
  LTask: TSQLInvoiceTask;
begin
  if grid_Req.Row[ARow].Data <> nil then
  begin
    LIdList := TIDList4Invoice(grid_Req.Row[ARow].Data);
    LTask:= CreateOrGetLoadInvoiceTask(LIdList.fTaskId);

    if DisplayInvoiceTaskInfo2EditForm(LTask, null) then
    begin
      LoadTaskVar2Grid(LTask, grid_Req, ARow);
    end;
  end;
end;

end.
