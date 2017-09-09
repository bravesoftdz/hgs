unit UnitFrameDataSaveAll;
{�� Frame�� TForm�� �����Ҷ� TForm.OnCreat �Լ���
  FOwnerForm := Self;
  FStatusBar := jvStatusBar;
�� �ݵ�� �߰� �� ��}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls,
  Vcl.ComCtrls, iniFiles, SynCommons, DataSave2FileThread, UnitFrameIPCMonitorAll,
  DataSave2DBThread, DataSave2MongoDBThread, DeCAL, commonUtil, DataSaveAll_Const,
  DataSaveAll_ConfigUnit, TimerPool, HiMECSConst, EngineParameterClass,
  IPCThrd_HiMECS_MDI, JvFormPlacement, JvComponentBase, JvAppStorage,
  JvAppIniStorage, JvStatusBar, Vcl.CheckLst, CopyData, ElecPowerCalcClass,
  UnitSynLog,SynLog, mORMot;

type
  TDisplayTarget = (dtSendMemo, dtStatusBar);

  TFrameDataSaveAll = class(TFrame)
    Panel1: TPanel;
    Label2: TLabel;
    CB_Active: TCheckBox;
    RunHourPanel: TPanel;
    Protocol: TMemo;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    CB_DBlogging: TCheckBox;
    CB_CSVlogging: TCheckBox;
    ED_csv: TEdit;
    RB_bydate: TRadioButton;
    RB_byfilename: TRadioButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    RB_byevent: TRadioButton;
    RB_byinterval: TRadioButton;
    ED_interval: TEdit;
    MainMenu1: TMainMenu;
    FILE1: TMenuItem;
    Connect1: TMenuItem;
    Disconnect1: TMenuItem;
    N1: TMenuItem;
    Close1: TMenuItem;
    HELP1: TMenuItem;
    Option1: TMenuItem;
    Help2: TMenuItem;
    About1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Actionsave1: TMenuItem;
    ActionLoadFromFile1: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    JvFormStorage1: TJvFormStorage;
    JvAppIniFileStorage1: TJvAppIniFileStorage;
    N2: TMenuItem;
    ShowEventName1: TMenuItem;
    AutoStartCheck: TCheckBox;
    ShowTagNameHeader1: TMenuItem;
    ShowParamCount1: TMenuItem;
    Show0thTagValue1: TMenuItem;
    ShowEvendDataListCount1: TMenuItem;
    ShowEventDataListUniqName1: TMenuItem;
    ShowBulkMode1: TMenuItem;
    ShowSaveInterval1: TMenuItem;
    procedure CB_ActiveClick(Sender: TObject);
    procedure RB_bydateClick(Sender: TObject);
    procedure RB_byfilenameClick(Sender: TObject);
    procedure Connect1Click(Sender: TObject);
    procedure Option1Click(Sender: TObject);
    procedure Actionsave1Click(Sender: TObject);
    procedure ActionLoadFromFile1Click(Sender: TObject);
    procedure RB_byintervalClick(Sender: TObject);
    procedure RB_byeventClick(Sender: TObject);
    procedure ShowEventName1Click(Sender: TObject);
    procedure AutoStartCheckClick(Sender: TObject);
    procedure ShowTagNameHeader1Click(Sender: TObject);
    procedure ShowParamCount1Click(Sender: TObject);
    procedure Show0thTagValue1Click(Sender: TObject);
    procedure ShowEvendDataListCount1Click(Sender: TObject);
    procedure ShowEventDataListUniqName1Click(Sender: TObject);
    procedure ShowBulkMode1Click(Sender: TObject);
    procedure ShowSaveInterval1Click(Sender: TObject);
  private
    //CSV ���� ������ ���� ���������///////////////////////////////////////////
    FLogStart: Boolean;  //Log save Start sig.
    FTagNameBuf: string;  //���Ͽ� ������ �����ϱ� ���� ����
    FSaveFileName: string; //����Ÿ�� ������ File �̸�(������ ���� �����)
    FSaveDataBuf: string; //���Ͽ� ������ ����Ÿ�� �����ϴ� ����
    FSaveDBDataBuf: string; //DB�� ������ ����Ÿ�� �����ϴ� ����
    FSaveMongoAnalogDataBuf,
    FSaveMongoAnalogDataBuf2: string;
    FSaveMongoDigitalDataBuf,
    FSaveMongoDigitalDataBuf2,
    FSaveMongoDigitalDataBuf3: string;

    //Engineparameter IsSaveItem�� True �̸� Save Only When True Option��
    //����ǹǷ� Items[ParamIndex].value ���� 0 ���� Ŭ ��쿡�� ������ ���� ��
    //�� ������ �����ϰų� IsSaveItem�� False�̸� FIsxxSave = True �̰� ������ ������
    FIsAnalogSave,
    FIsDigitalSave,
    FIsDigital2Save,
    FSaveOnlyConditionTrue: Boolean;

    FFileName_Convention: TFileName_Convetion;//���Ͽ� ����ÿ� �����̸��ο� ���
    FDataSave2FileThread: TDataSave2FileThread;//���Ͽ� ����Ÿ �����ϴ� ��ü
    FCSVHeader: string;
    FDynamoHeader:string;
    FDynamoCSVData: string;

    FMapFileName: string;
    FParamFileName: string;
    FPowerMeterSMM: string;
    FECSSMM: string;
    FDynamoSMM: string;
    FEngParamEncrypt: Boolean;
    FEngParamFileFormat: integer;

    FDataSaveTimerHandle: integer;
    FRunHourCalcTimerHandle: integer;
    FRunHourSaveTimerHandle: integer;
    FDBReConnectTimerHandle: integer;
    FRunHourSaveInterval: integer;
    FAutoStartAfter: integer;
    FRunHourValue: LongInt;//Run Hour Value by Seconds
    FRunHourValueFromini: LongInt;//Run Hour Value by Seconds from ini
    FSemaphoreHandle: THandle;//Run hour ���� �ٸ� ���μ������� �ߺ� ���� ����
    FIsDisplySavedRawData: Boolean;

    FDestroying: Boolean;   //�������̸� True(����� ���� ������ �߰���)
    FSaveInterval: integer;
    FConfigModified: Boolean;

    //TFrameIPCMonitorAll1.FEngineParameter.EngineParameterCollect.Items[FParamIndex].Value ���� 0�� �ƴ� ��쿡��
    //�����͸� ������(FIsSaveOnly = True)
    FIsSaveOnly: boolean;
    FIsSaveRunHour: boolean;
    FAutoChangeSaveFileName: boolean;
    FParamIndex: Integer;
    FParamRunHourIndex: integer;
    FActionDataIni: string;//Action data ���� �� ini file name: param���� �Է� ����

    //IPC Thread -->
    Flags: TClientFlags;
    IPCClient_HiMECS_MDI: TIPCClient_HiMECS_MDI;
    FElecPowerCalcBase: TElecPowerCalcBase;

    procedure OnConnect(Sender: TIPCThread_HiMECS_MDI; Connecting: Boolean);
    procedure OnSignal(Sender: TIPCThread_HiMECS_MDI; Data: TEventData_HiMECS_MDI);
    procedure UpdateStatusBar(var Msg: TMessage); message WM_UPDATESTATUS_HiMECS_MDI;
    //IPC Thread <--

    procedure WMCopyData(var Msg: TMessage); message WM_COPYDATA;
    procedure WMDBDisconnected(var Msg: TMessage); message WM_DB_DISCONNECTED;
    //ini ���� ������ ������ ���� �Լ� �����
    procedure LoadConfigDataini2Form(FSaveConfigF: TFrmDataSaveAllConfig);
    procedure SaveConfigDataForm2ini(FSaveConfigF: TFrmDataSaveAllConfig);
    //procedure SaveConfigDataParam2ini;
    procedure AdjustConfigData(AParamModified: Boolean = True);
    procedure SaveRunHour2ini;
    procedure SaveActionData2ini(AFileName: string='');
    procedure ApplyActionData;
    procedure MonitorStart;

    procedure InitVar;
    procedure IPCAll_Init;
    procedure IPCAll_Final;

    procedure MakeCSVHeader(AParamFileNameChanged: Boolean);

    procedure OnDataSave(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);
    procedure OnReconnectWhenDBDisconnect(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);
    procedure OnRunHourCalc(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);
    procedure OnRunHourSave(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);
    procedure OnDataSaveOnce(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);
    procedure OnAutoStartServer(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt); virtual;
  protected
    procedure WatchValue2Screen_Analog(Name: string; AValue: string;
                                AEPIndex: integer);
    //������ ���߰ų� ���α׷� ����� 100�� ������ DataList�� Data�� ������ ��
    //ADataStopping = True
    procedure Proc_DataSave(ADataStopping: Boolean);
    procedure Proc_DataSave_Always;
    procedure Proc_DataSave_Always_PMS;
    procedure AddDate2MongoData(var AData: string);
    procedure ParamSource2LB(AListBox: TCheckListBox; AList: TStringList; AIni: TIniFile = nil);
    function SetParamSourceList(var AList: TStringList; AEP: TEngineParameter): string;
    procedure UniqueParamSource2LB(AListBox: TCheckListBox; AList: TStringList; AIni: TIniFile = nil);
  public
    //DB�� ������ ������ ���� ���������
    FDataSave2OracleDBThread: TDataSave2DBThread; //DB�� ����Ÿ �����ϴ� ��ü
    FDataSave2MongoDBThread: TDataSave2MongoDBThread; //DB�� ����Ÿ �����ϴ� ��ü
    FIPCMonitorAll: TFrameIPCMonitor;
    FOwnerForm: TForm;
    FStatusBar: TjvStatusBar;

    FFilePath: string;      //������ ������ ���
    FIniFileName: string;   //ini File name
    FMonitorStart: Boolean; //Ÿ�̸� ���� �Ϸ��ϸ� True
    //DB ����� ��� ������ ���� �� DB �Է��ؾ� �ϹǷ� ���� ���ŵ� Block No�� �ʿ�
    FCurrentBlockNo: integer;
    FLastBlockNo: integer;
    FPJHTimerPool: TPJHTimerPool;

    FParameterSourceList,
    //Config�� ó�� ������ Parameter Source ����Ʈ�� �����ֱ� ����
    FParameterOriginalList: TStringList;
    FIsAutoRun: Boolean;
    FRunHourEnable: Boolean;//Run hour�� ���Ͽ� ������ �� ���: True�� ��쿡�� ����
    FAutoStartTimerHandle: integer;

    FDBEnable: Bool; //������ ���̽��� �ڷ� ����� ����
    FDBType: TDBType; //DT_ORACLE, DT_MONGODB

    //Oracle DB
    FHostName: string;//DB Host Name(IP address)
    FDBName: string;  //DB Name(Mysql�� DB Name)
    FLoginID: string;   //Login Name
    FPasswd: string;  //Password
    FSaveTableName: string;
    FConnectedOracleDB: Boolean;
    FReConnectInterval: integer;

    //Mongo DB
    FMongoHostName: string;//Mongo DB Host Name(IP address)
    FMongoDBName: string;  //Mongo DB Name(Mysql�� DB Name)
    FMongoLoginID: string; //Mongo Login Name
    FMongoPasswd: string;  //Mongo Password
    FMongoCollectionName,  //Mongo Collection Name
    FMongoCollectionName2,
    FMongoCollectionName3: string;//3���� Collection�� Insert �Ҷ� �ʿ���(1���� ����Ҷ��� �ݵ�� ''�� �Ұ�)
    FConnectedMongoDB: Boolean;
    FMongoReConnect: integer;

    FAppendStr: string;
    FBulkDataMode: Boolean; //���Interval�� 200ms �����̸� True(100�Ǿ� ���Ͽ� ������)

    FToggleBackground: Boolean;
    FDataSaveStopping: Boolean;
    FEventName: string;

    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;

    procedure ParamSource2CLBFromFile(AListBox: TCheckListBox; AFileName: string;
      AEngParamFileFormat: integer; AEncrypt: Boolean);
    procedure UniqueParamSource2CLBFromFile(AListBox: TCheckListBox; AFileName: string;
      AEngParamFileFormat: integer; AEncrypt: Boolean);
    function LoadParamFile(AFileName: string; AEP: TEngineParameter;
      AEngParamFileFormat: integer; AEncrypt: Boolean): boolean;
    procedure SaveData2DB(AParamSource: string = '');
    procedure SaveData2OracleDB;
    procedure SaveData2MongoDB(AParamSource: string = '');
    procedure SaveData2File;
    procedure SetSaveDataBuf(AData: string);
    procedure SetTagBuf(ATag: string);
    procedure CreateSave2DBThread;
    procedure CreateSave2OracleDBThread;
    procedure CreateSave2MongoDBThread;
    procedure CreateSave2FileThread;
    procedure DisplayMessage(msg: string; ADspNo: Integer);
    procedure DisplayMessage2SB(Msg: string);
    procedure DestroySave2FileThread;
    procedure DestroySave2DBThread;
    procedure AdjustBulkMode;
    procedure LoadConfigDataini2Var(AFileName: string='');
    procedure LoadActionDataFromini(AFileName: string='');
    procedure LoadRunHourFromini;
    function IsRunHourEnable: Boolean;
    procedure SetOnAutoStartServer(AInterval: integer = 1000);

    procedure SetFileNameConvention(AValue: TFileName_Convetion);
    procedure SetSaveFileName(AName: string);
    procedure SetParamFileName(AName: string);
    function GetIniFileName: string;
  end;

implementation

{$R *.dfm}

//24�ð��� �ʰ��� ��쿡�� hhh:mm:ss�� ǥ�� ����
//V: second
Function FORMAT_TIME (V : Integer) : string; { format time as hh:mm:ss }
Var
  Hour,Min,Sec : Integer;
  str1: string;
begin
  FORMAT_TIME := '';

  if V < 0 then
    exit;

  Hour := V div 3600;
  V := V mod 3600;               { process hours }

  Min := V div 60;
  Sec := V mod 60;                 { process minutes }

  FORMAT_TIME := Format('%d:%.2d:%.2d',[Hour,Min,Sec]);
end;

{ TFrame2 }

procedure TFrameDataSaveAll.ActionLoadFromFile1Click(Sender: TObject);
begin
  OpenDialog1.InitialDir := FFilePath;
  if OpenDialog1.Execute then
  begin
    if OpenDialog1.FileName <> '' then
    begin
      LoadActionDataFromini(OpenDialog1.FileName);
    end;
  end;
end;

procedure TFrameDataSaveAll.Actionsave1Click(Sender: TObject);
begin
  SaveActionData2ini;
end;

procedure TFrameDataSaveAll.AddDate2MongoData(var AData: string);
var
  i: integer;
begin
  i := PosRev(',', AData);

//  if i = Length(AData) - 1 then
    System.Delete(AData,i,1);

  AData := '{ "SavedTime": new Date(), ' + AData + '}';
end;

procedure TFrameDataSaveAll.AdjustBulkMode;
begin
  if not Assigned(FDataSave2FileThread) then
    exit;

  if FBulkDataMode then
  begin
    FStatusBar.Panels[0].Text := 'Bulk Mode';

    if not Assigned(FDataSave2FileThread.FDataList) then
      FDataSave2FileThread.FDataList := TStringList.Create;
  end
  else
  begin
    FStatusBar.Panels[0].Text := '';

    if Assigned(FDataSave2FileThread.FDataList) then
      FreeAndNil(FDataSave2FileThread.FDataList);
  end;
end;

procedure TFrameDataSaveAll.AdjustConfigData(AParamModified: Boolean);
begin
  if AParamModified then //Parameter File Name�� ���� �Ǿ��� ��쿡�� True
  begin
    LoadParamFile(FParamFileName, FIPCMonitorAll.FEngineParameter, FEngParamFileFormat, FEngParamEncrypt);
    MakeCSVHeader(AParamModified);

    AutoStartCheck.Caption :=  'Auto start after ' + IntToStr(FAutoStartAfter) + ' mili-Seconds';
    Label2.Visible := FIsSaveRunHour;
    RunHourPanel.Visible := FIsSaveRunHour;
  end
  else
    MakeCSVHeader(AParamModified);

  FBulkDataMode := FSaveInterval <= 200;
  AdjustBulkMode;
end;

procedure TFrameDataSaveAll.ApplyActionData;
begin
  CB_Active.Checked := True;

  CB_ActiveClick(nil);
end;

procedure TFrameDataSaveAll.AutoStartCheckClick(Sender: TObject);
begin
  if CB_Active.Checked then
    exit;

  if AutoStartCheck.Checked then
    FAutoStartTimerHandle := FPJHTimerPool.Add(OnAutoStartServer, 1000);//FAutoStartAfter);
end;

procedure TFrameDataSaveAll.CB_ActiveClick(Sender: TObject);
begin
  if not FMonitorStart then
  begin
    AutoStartCheck.Checked := False;
    MonitorStart;
  end;

  if CB_Active.Checked then
  begin
    DisplayMessage (#13#10+ '#####################' +#13#10+ TimeToStr(Time)+' Start Data Receiving', Ord(dtSendMemo));
    //CSV ���Ͽ� Data Save�� ���
    if CB_CSVlogging.Checked then
    begin
      FSaveFileName := ED_csv.Text;
      FPJHTimerPool.RemoveAll;
      CreateSave2FileThread;
      FDataSaveTimerHandle := FPJHTimerPool.Add(OnDataSave, FSaveInterval);
    end;

    //Database�� Data Save�� ���
    if CB_DBlogging.Checked then
    begin
      FPJHTimerPool.RemoveAll;
      CreateSave2DBThread;
      FDataSaveTimerHandle := FPJHTimerPool.Add(OnDataSave, FSaveInterval);
    end;
  end
  else
  begin
    FMonitorStart := False;
    DisplayMessage (TimeToStr(Time)+#13#10+' Processing terminated', Ord(dtSendMemo));
    FPJHTimerPool.RemoveAll;

    if FIsSaveRunHour then
    begin
      if FRunHourCalcTimerHandle <> -1 then
      begin
        FPJHTimerPool.Remove(FRunHourCalcTimerHandle);
        FRunHourCalcTimerHandle := -1;
        FPJHTimerPool.Remove(FRunHourSaveTimerHandle);
        FRunHourSaveTimerHandle := -1;
        SaveRunHour2ini;
      end;
    end;
  end;
end;

procedure TFrameDataSaveAll.Connect1Click(Sender: TObject);
begin
  CreateSave2OracleDBThread;
end;

constructor TFrameDataSaveAll.Create(AOwner: TComponent);
begin
  inherited;

  GetIniFileName;
  InitVar;
end;

procedure TFrameDataSaveAll.CreateSave2OracleDBThread;
begin
  if not Assigned(FDataSave2OracleDBThread) then
  begin
    FDataSave2OracleDBThread := TDataSave2DBThread.Create(FOwnerForm);
    with FDataSave2OracleDBThread do
    begin
      //FHostName := Self.FHostName;
      //FDBName := Self.FDBName;
      //FLoginID := Self.FLoginID;
      //FPasswd := Self.FPasswd;
      if FDataSave2OracleDBThread.FOraSession1.Connected then
      begin
        FDataSave2OracleDBThread.Create_InsertSQL(FSaveTableName);
        DisplayMessage ('Server Connected', Ord(dtSendMemo));
        Resume;
      end
    end;//with
  end;//if

  if not FDataSave2OracleDBThread.FOraSession1.Connected then
  begin
    FDataSave2OracleDBThread.ConnectDB;
    FDataSave2OracleDBThread.Create_InsertSQL(FSaveTableName);
    FDataSave2OracleDBThread.Resume;
    if FDataSave2OracleDBThread.FOraSession1.Connected then
      DisplayMessage ('Server Re-Connected', Ord(dtSendMemo));
  end;
end;

procedure TFrameDataSaveAll.CreateSave2DBThread;
begin
  if not FDBEnable then
    exit;

  if FDBType = DT_ORACLE then
    CreateSave2OracleDBThread
  else
  if FDBType = DT_MONGODB then
    CreateSave2MongoDBThread;
end;

procedure TFrameDataSaveAll.CreateSave2FileThread;
begin
  if not Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread := TDataSave2FileThread.Create(FOwnerForm);
    AdjustBulkMode;
    FDataSave2FileThread.Resume;
  end;
end;

procedure TFrameDataSaveAll.CreateSave2MongoDBThread;
var
  LDoc: Variant;
  LpDoc: PDocVariantData;
begin
  if not Assigned(FDataSave2MongoDBThread) then
  begin
    FDataSave2MongoDBThread := TDataSave2MongoDBThread.Create(TForm(Self));
    FDataSave2MongoDBThread.FFrameDataSaveAll := Self;
  end;

  if not FConnectedMongoDB then
  begin
    FConnectedMongoDB := FDataSave2MongoDBThread.ConnectDB;
    FDataSave2MongoDBThread.FMongoCollectName := Self.FMongoCollectionName;
    FDataSave2MongoDBThread.FMongoCollectName2 := Self.FMongoCollectionName2;
    FDataSave2MongoDBThread.FMongoCollectName3 := Self.FMongoCollectionName3;
    FDataSave2MongoDBThread.Resume;

    if FConnectedMongoDB then
      DisplayMessage ('Server Connected', 0);
  end;

  if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[0].ParameterSource = psPMSOPC then
  begin
    LDoc := FDataSave2MongoDBThread.GetkWhFromDB(FElecPowerCalcBase.FkWhRecord.FYear,
      FElecPowerCalcBase.FkWhRecord.FMonth, FElecPowerCalcBase.FkWhRecord.FDay);
    if LDoc <> null then
    begin
      LpDoc := DocVariantData(Ldoc);

      if LpDoc <> nil then
      begin
        FElecPowerCalcBase.FkWhRecord.FInCome1kWh := LpDoc.Values[0].kWh.InCome1;
        FElecPowerCalcBase.FkWhRecord.FInCome2kWh := LpDoc.Values[0].kWh.InCome2;
        FElecPowerCalcBase.FkWhRecord.FInCome3kWh := LpDoc.Values[0].kWh.InCome3;
        FElecPowerCalcBase.FkWhRecord.FVCBF1kWh := LpDoc.Values[0].kWh.InCome1;
        FElecPowerCalcBase.FkWhRecord.FVCBF2kWh := LpDoc.Values[0].kWh.InCome1;
        FElecPowerCalcBase.FkWhRecord.FVCBG7AkWh := LpDoc.Values[0].kWh.InCome1;
      end;
    end;
  end;

end;

destructor TFrameDataSaveAll.Destroy;
begin
  FDestroying := True;

  FElecPowerCalcBase.Free;

  if CB_Active.Checked then
  begin
    FMonitorStart := False;
    DisplayMessage (TimeToStr(Time)+#13#10+' Processing terminated', Ord(dtSendMemo));
    FPJHTimerPool.RemoveAll;

    if FIsSaveRunHour then
      SaveRunHour2ini;
  end;

  if FSemaphoreHandle <> 0 then
    CloseHandle(FSemaphoreHandle);

  FMonitorStart := False;

  IPCAll_Final;
  DestroySave2FileThread;
  DestroySave2DBThread;

//  IPCClient_HiMECS_MDI.Free;
  FParameterSourceList.Free;
  FParameterOriginalList.Free;
  FPJHTimerPool.RemoveAll;
  FPJHTimerPool.Free;

  inherited Destroy;
end;

procedure TFrameDataSaveAll.DestroySave2DBThread;
begin
  if Assigned(FDataSave2OracleDBThread) then
  begin
    FDataSave2OracleDBThread.FDestroying := True;
    FDataSave2OracleDBThread.Terminate;
    FDataSave2OracleDBThread.FDataSaveEvent.Signal;
//    FDataSave2OracleDBThread.Free;
//    FDataSave2OracleDBThread := nil;
  end;//if

  if Assigned(FDataSave2MongoDBThread) then
  begin
    FDataSave2MongoDBThread.FDestroying := True;
    FDataSave2MongoDBThread.Terminate;
    FDataSave2MongoDBThread.FDataSaveEvent.Signal;
//    FDataSave2MongoDBThread.Free;
//    FDataSave2MongoDBThread := nil;
  end;//if

end;

procedure TFrameDataSaveAll.DestroySave2FileThread;
begin
  if Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread.FDestroying := True;
    FDataSave2FileThread.Terminate;
    FDataSave2FileThread.FDataSaveEvent.Signal;
//    FDataSave2FileThread.Free;
//    FDataSave2FileThread := nil;
  end;//if
end;

procedure TFrameDataSaveAll.DisplayMessage(msg: string; ADspNo: Integer);
begin
  if FToggleBackground then
    Protocol.Color := $0080FF80
  else
    Protocol.Color := clWhite;

  case TDisplayTarget(ADspNo) of
    dtSendMemo : begin
      if msg = ' ' then
      begin
        exit;
      end
      else
        ;

      with Protocol do
      begin
        if Lines.Count > 100 then
          Clear;

        Lines.Add(msg);
      end;//with
    end;//dtSendMemo

    dtStatusBar: begin
       FStatusBar.SimplePanel := True;
       FStatusBar.SimpleText := msg;
    end;//dtStatusBar
  end;//case
end;

procedure TFrameDataSaveAll.DisplayMessage2SB(Msg: string);
begin
  FStatusBar.SimplePanel := True;
  FStatusBar.SimpleText := Msg;
end;

function TFrameDataSaveAll.GetIniFileName: string;
var
  LStr: string;
  i: integer;
begin
  if ParamCount > 0 then
  begin
    LStr := ParamStr(1);
    i := Pos('/A', UpperCase(LStr)); //Automatic Start
    if i > 0 then  //A ����
    begin
      FIniFileName := '.\'+ Copy(LStr, i+2, Length(LStr)-i-1);//ȯ������ �����̸�
    end;
  end
  else
  begin
    FIniFileName := '.\' + ChangeFileExt(ExtractFileName(Application.ExeName), '.ini');
  end;

  Result := FIniFileName;
end;

procedure TFrameDataSaveAll.InitVar;
var
  LYear, LMonth, LDay: word;
begin
  FFilePath := ExtractFilePath(Application.ExeName); //�ǳ��� '\' ���Ե�
  FPJHTimerPool := TPJHTimerPool.Create(nil);
  FRunHourCalcTimerHandle := -1;
  FRunHourSaveTimerHandle := -1;
  FDBReConnectTimerHandle := -1;
  FRunHourValueFromini := -1;
  FParameterOriginalList := TStringList.Create;
  FParameterSourceList := TStringList.Create;
  FMonitorStart := False;
  FDestroying := False;
  FElecPowerCalcBase := TElecPowerCalcBase.Create(self);
  DecodeDate(now, LYear, LMonth, LDay);
  FElecPowerCalcBase.FkWhRecord.FYear := LYear;
  FElecPowerCalcBase.FkWhRecord.FMonth := LMonth;
  FElecPowerCalcBase.FkWhRecord.FDay := LDay;
  InitSynLog;
end;

procedure TFrameDataSaveAll.IPCAll_Final;
begin
  FIPCMonitorAll.DestroyIPCMonitorAll;
  DisplayMessage('All IPCMonitor is destroyed.', Ord(dtSendMemo));
end;

procedure TFrameDataSaveAll.IPCAll_Init;
var
  LStr: string;
  i: integer;
  LEPItem: TEngineParameterItem;
  LEventName: string;
begin
  FStatusBar.Panels[1].Text := '';

  for i := 0 to FParameterSourceList.Count - 1 do
  begin
    LEPItem := TEngineParameterItem(FParameterSourceList.Objects[i]);
    if (LEPItem.ParameterSource = psECS_AVAT) or
      (LEPItem.ParameterSource = psECS_kumo) or
      (LEPItem.ParameterSource = psECS_kumo2) then
    begin
//      if FMapFileName <> '' then
//        FIPCMonitorAll.SetModbusMapFileName(FMapFileName, LEPItem.ParameterSource);
    end;

    LStr := FIPCMonitorAll.CreateIPCMonitor_xx(LEPItem.ParameterSource, LEPItem.SharedName,
      LEPItem.ProjNo, LEPItem.EngNo);

    if LEventName <> '' then
      LEventName := LEventName + #13#10;

    LEventName := LEventName + LEPItem.SharedName + '_' + ParameterSource2SharedMN(LEPItem.ParameterSource);

    DisplayMessage(LStr + ' Created.', Ord(dtSendMemo));
    if FStatusBar.Panels[1].Text = '' then
      FStatusBar.Panels[1].Text := LStr
    else
      FStatusBar.Panels[1].Text := FStatusBar.Panels[1].Text + ', ' + LStr;
  end;

  FEventName := LEventName;
end;

function TFrameDataSaveAll.IsRunHourEnable: Boolean;
var
    hSem: THANDLE;
begin
  hSem := CreateSemaphore(nil, 0, 1, RUNHOUR_SEMAPHORENAME);
  // ��ȣ�Ӽ� = NULL, �ʱ� ī��Ʈ = 0, �ִ� ī��Ʈ = 1, �������� �̸� = RUNHOUR_SEMAPHORENAME
  if (hSem <> 0) and (GetLastError() = ERROR_ALREADY_EXISTS) then
  begin
    // �̹� �������  ������� �ִ� ��쿡 False Return
    CloseHandle(hSem);
    Result := False;
    exit;
  end;

  FSemaphoreHandle := hSem;
  Result := True;
end;

procedure TFrameDataSaveAll.LoadActionDataFromini(AFileName: string);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);

  if AFileName = '' then
    FActionDataIni := ExtractFileName(Application.ExeName)+'ActionData.ini'
  else
  begin
    FActionDataIni := AFileName;
  end;

  LoadConfigDataini2Var(FActionDataIni);

  iniFile := nil;
  iniFile := TInifile.create(FActionDataIni);

  try
    with iniFile do
    begin
      CB_DBLogging.Checked := ReadBool(ACTIONSAVE_SECTION, 'DB Logging', False);
      CB_CSVLogging.Checked := ReadBool(ACTIONSAVE_SECTION, 'CSV Logging', False);
      RB_Bydate.Checked := ReadBool(ACTIONSAVE_SECTION, 'By Date', False);
      RB_ByFileName.Checked := ReadBool(ACTIONSAVE_SECTION, 'By File Name', False);

      if RB_Bydate.Checked then
        RB_bydateClick(nil);

      if RB_ByFileName.Checked then
        ED_csv.Text := ReadString(ACTIONSAVE_SECTION, 'CSV File Name', '');

      RB_ByEvent.Checked := ReadBool(ACTIONSAVE_SECTION, 'By Event', False);
      RB_ByInterval.Checked := ReadBool(ACTIONSAVE_SECTION, 'By Interval', False);
      ED_interval.Text := ReadString(ACTIONSAVE_SECTION, 'Interval', '');
    end;//with

    DisplayMessage(#13#10+'Action Data Loaded'+#13#10, Ord(dtSendMemo));

  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TFrameDataSaveAll.LoadConfigDataini2Form(FSaveConfigF: TFrmDataSaveAllConfig);
var
  iniFile: TIniFile;
  LStr, LFileName: string;
  i: integer;
  LStrList: TStringList;
begin
  SetCurrentDir(FFilePath);

  if FIsAutoRun then
    LFileName := FActionDataIni
  else
    LFileName := GetIniFileName;

  FSaveConfigF.Caption := FSaveConfigF.Caption + ' (' + LFileName + ' )';
  iniFile := nil;
  iniFile := TInifile.create(LFileName);
  try
    with iniFile, FSaveConfigF do
    begin
      MapFilenameEdit.FileName := ReadString(DATASAVE_SECTION, 'Modbus Map File Name1', '');
      ParaFilenameEdit.FileName := ReadString(DATASAVE_SECTION, 'Parameter File Name', '');
      BlockNoEdit.Text := ReadString(DATASAVE_SECTION, 'Block No', '1');
      IntervalSE.Value := ReadInteger(DATASAVE_SECTION, 'Save Interval', 1000);
      SaveDB_ChkBox.Checked := ReadBool(DATASAVE_SECTION, 'DB Enable', False);
      DB_Type_RG.ItemIndex := ReadInteger(DATASAVE_SECTION, 'DB Type', Ord(DT_ORACLE));

      ServerEdit.Text := ReadString(ORACLE_SECTION, 'DB Server', '10.100.23.114:1521:TBACS');
      UserEdit.Text := ReadString(ORACLE_SECTION, 'User ID', 'TBACS');
      PasswdEdit.Text := ReadString(ORACLE_SECTION, 'Passwd', 'TBACS');
      TableNameCombo.Text := ReadString(ORACLE_SECTION, 'Table Name', 'BF1562_18H3240V_ANALOG_DATA');
      ReConnectIntervalEdit.Value := ReadInteger(ORACLE_SECTION, 'Reconnect Interval', 10000);

      MongoServerEdit.Text := ReadString(MONGODB_SECTION, 'DB Server Address', '10.100.23.114');
      MongoUserEdit.Text := ReadString(MONGODB_SECTION, 'User ID', 'TBACS');
      MongoPasswdEdit.Text := ReadString(MONGODB_SECTION, 'Passwd', 'TBACS');
      MongoDBNameCombo.Text := ReadString(MONGODB_SECTION, 'DataBase Name', 'PMS_DB');
      MongoCollNameCombo.Text := ReadString(MONGODB_SECTION, 'Collection Name', 'PMS_COLL');
      MongoCollNameCombo2.Text := ReadString(MONGODB_SECTION, 'Collection Name 2', '');
      MongoCollNameCombo3.Text := ReadString(MONGODB_SECTION, 'Collection Name 3', '');
      MongoReConnectEdit.Value := ReadInteger(MONGODB_SECTION, 'Reconnect Interval', 10000);

      EngParamEncryptCB.Checked := ReadBool(DATASAVE_SECTION, 'Parameter Encrypt', False);
      ConfFileFormatRG.ItemIndex := ReadInteger(DATASAVE_SECTION, 'Param File Format', 0);
      AppendStrEdit.Text := ReadString(DATASAVE_SECTION, 'Append String To CSV FileName', '');

      SaveOnlyCB.Checked := ReadBool(DATASAVE_SECTION, 'Save Only', False);
      SaveRunHourCB.Checked := ReadBool(DATASAVE_SECTION, 'Save Run Hour', False);
      ParamIndexEdit.Text := ReadString(DATASAVE_SECTION, 'Parameter Index', '');
      RunHourIndexEdit.Text := ReadString(DATASAVE_SECTION, 'Run Hour Index', '');
      RHIntervalSE.Value := ReadInteger(DATASAVE_SECTION, 'Run Hour Save Interval', 60000);
      AutoStartAfterEdit.Text := ReadString(DATASAVE_SECTION, 'Auto Start After', '60000');

      FNameType_RG.ItemIndex := Readinteger(DATASAVE_SECTION, 'SaveFileName Change Type', 0);
      DisplySavedRawDataCB.Checked := ReadBool(DATASAVE_SECTION, 'Display Saved Raw Data', False);

      ParamSourceCLB.Clear;
      UniqueParamSource2LB(ParamSourceCLB, nil, iniFile); //FParameterOriginalList
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TFrameDataSaveAll.LoadConfigDataini2Var(AFileName: string);
var
  iniFile: TIniFile;
  LStr, LFileName: string;
  i,j: integer;
  LBool: Boolean;
  LStrList: TStringList;
begin
  SetCurrentDir(FFilePath);

  if AFileName = '' then
    LFileName := GetIniFileName
  else
    LFileName := AFileName;

  iniFile := nil;
  iniFile := TInifile.create(LFileName);
  try
    with iniFile do
    begin
      //FPowerMeterSMM := ReadString(DATASAVE_SECTION, 'Power Meter Shared Memory Name', '192.168.0.48');
      //FECSSMM := ReadString(DATASAVE_SECTION, 'ECS Shared Memory Name', '');
      //FDynamoSMM := ReadString(DATASAVE_SECTION, 'Dynamo Shared Memory Name', '');

      FMapFileName := ReadString(DATASAVE_SECTION, 'Modbus Map File Name1', '');
      LStr := ReadString(DATASAVE_SECTION, 'Parameter File Name', '');
      FConfigModified := False;

      if (FParamFileName <> LStr) or (LStr = '') then
      begin
        FParamFileName := LStr;
        FConfigModified := True;
      end;

      FLastBlockNo := ReadInteger(DATASAVE_SECTION, 'Block No', 1);
      FSaveInterval := ReadInteger(DATASAVE_SECTION, 'Save Interval', 1000);
      FEngParamEncrypt := ReadBool(DATASAVE_SECTION, 'Parameter Encrypt', false);
      FEngParamFileFormat := ReadInteger(DATASAVE_SECTION, 'Param File Format', 0);
      FReConnectInterval := ReadInteger(DATASAVE_SECTION, 'Reconnect Interval', 10000);

      FAppendStr := ReadString(DATASAVE_SECTION, 'Append String To CSV FileName', '');
      FDBEnable := ReadBool(DATASAVE_SECTION, 'DB Enable', False);
      FDBType := TDBType(ReadInteger(DATASAVE_SECTION, 'DB Type', 0));

      FHostName := ReadString(ORACLE_SECTION, 'DB Server', '10.100.23.114:1521:TBACS');
      FLoginID := ReadString(ORACLE_SECTION, 'User ID', 'TBACS');
      FPasswd := ReadString(ORACLE_SECTION, 'Passwd', 'TBACS');
      FSaveTableName := ReadString(ORACLE_SECTION, 'Table Name', '');
      FReConnectInterval := ReadInteger(ORACLE_SECTION, 'Reconnect Interval', 10000);

      FMongoHostName := ReadString(MONGODB_SECTION, 'DB Server Address', '10.100.23.114');
      FMongoDBName := ReadString(MONGODB_SECTION, 'DataBase Name', 'PMS_DB');
      FMongoLoginID := ReadString(MONGODB_SECTION, 'User ID', 'TBACS');
      FMongoPasswd := ReadString(MONGODB_SECTION, 'Passwd', 'TBACS');
      FMongoCollectionName := ReadString(MONGODB_SECTION, 'Collection Name', 'PMS_COLL');
      FMongoCollectionName2 := ReadString(MONGODB_SECTION, 'Collection Name 2', '');
      FMongoCollectionName3 := ReadString(MONGODB_SECTION, 'Collection Name 3', '');
      FMongoReConnect := ReadInteger(MONGODB_SECTION, 'Reconnect Interval', 10000);

      FIsSaveOnly := ReadBool(DATASAVE_SECTION, 'Save Only', False);
      FIsSaveRunHour := ReadBool(DATASAVE_SECTION, 'Save Run Hour', False);
      FParamIndex := ReadInteger(DATASAVE_SECTION, 'Parameter Index', -1);
      FParamRunHourIndex := ReadInteger(DATASAVE_SECTION, 'Run Hour Index', -1);
      FRunHourSaveInterval := ReadInteger(DATASAVE_SECTION, 'Run Hour Save Interval', 60000);
      FAutoStartAfter :=  ReadInteger(DATASAVE_SECTION, 'Auto Start After', 60000);
      FIsDisplySavedRawData := ReadBool(DATASAVE_SECTION, 'Display Saved Raw Data', False);

      i := ReadInteger(DATASAVE_SECTION, 'SaveFileName Change Type', 0);
      FAutoChangeSaveFileName := (i = 0);

      AdjustConfigData(FConfigModified);

      //Parameter File �� ParameterSource�� ��� ������
      FIPCMonitorAll.GetParameterSourceList(FParameterSourceList);

      LStrList := TStringList.Create;
      try
        ReadSectionValues(PARAM_SECTION, LStrList);
        //Ini File���� True �� Parameter Source�� FParameterSourceList�� ���ܵΰ� ������ ����
        for i := 0 to LStrList.Count - 1 do
        begin
          if not StrToBool(LStrList.ValueFromIndex[i]) then
          begin
            j := FParameterSourceList.IndexOf(LStrList.Names[i]);
            if j <> -1 then
              FParameterSourceList.Delete(j);
          end;
        end;
      finally
        LStrList.Free;
      end;

    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

function TFrameDataSaveAll.LoadParamFile(AFileName: string;
  AEP: TEngineParameter; AEngParamFileFormat: integer; AEncrypt: Boolean): boolean;
begin
  Result := False;

  SetCurrentDir(FFilePath);

  if FileExists(AFileName) then
  begin
    AEP.EngineParameterCollect.Clear;
    if AEngParamFileFormat = 0 then //XML File Format
      AEP.LoadFromFile(AFileName, ExtractFileName(AFileName), AEncrypt)
    else
    if AEngParamFileFormat = 1 then //JSON File Format
      AEP.LoadFromJSONFile(AFileName, ExtractFileName(AFileName), AEncrypt);

    Result := True;
  end
  else
    ShowMessage('Not exist parameter file: ' + AFileName);
end;

procedure TFrameDataSaveAll.LoadRunHourFromini;
var
  iniFile: TIniFile;
  LStr: string;
begin
  SetCurrentDir(FFilePath);
  LStr := ExtractFilename(FParamFileName);
  LStr := ChangeFileExt(LStr, '');
  iniFile := TInifile.create('.\'+LStr+'_'+SAVERUNHOURINIFILENAME);
  try
    with iniFile do
    begin
      FRunHourValue := Readinteger('Run Hour', 'Value', 0);
      RunHourPanel.Caption := FORMAT_TIME(FRunHourValue);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TFrameDataSaveAll.MakeCSVHeader(AParamFileNameChanged: Boolean);
var
  i: integer;
  LStr, LName: string;
begin
  LStr := formatDateTime('yyyy-mm-dd hh:nn:ss:zzz',now);

  if AParamFileNameChanged then
  begin
    FParameterSourceList.Clear;
    FParameterOriginalList.Clear;

    LStr := LStr + SetParamSourceList(FParameterOriginalList, FIPCMonitorAll.FEngineParameter);

    if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count > 0 then
    begin
      i := 0;
      LName := '';

      //Kral �� ��� 2�� �ʵ带 �Ѱ��� ������ �����
      if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].ParameterSource = psFlowMeterKral then
      begin
        while (i < FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count - 1) do
        begin
          LName := LName + ',' + replaceString(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Description, ',', '', False);//FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Description;
          i := i + 2;
        end;//while

        LStr := LName;
      end;
    end;

  end
  else
  begin
    if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count > 0 then
    begin
      i := 0;
      LName := '';

      if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].ParameterSource = psFlowMeterKral then
      begin
        while (i < FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count - 1) do
        begin
          LName := LName + ',' + replaceString(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Description, ',', '', False);//FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Description;
          i := i + 2;
        end;//while

        LStr := LName;
      end;
    end
    else
    begin
      for i := 0 to FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count - 1 do
      begin
        LName := ParameterSource2String(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].ParameterSource);

        if FParameterSourceList.IndexOf(LName) > -1 then
        begin
          LStr := LStr + ',' + replaceString(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Description, ',', '', False);//FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Description;
        end;
      end;
    end;
  end;

  FTagNameBuf := LStr;
end;

procedure TFrameDataSaveAll.MonitorStart;
begin
  IPCAll_Init;

  FMonitorStart := True;

//  if FIsAutoRun then
    ApplyActionData;

  if FActionDataIni <> '' then
    Self.Caption := FActionDataIni;
end;

procedure TFrameDataSaveAll.OnAutoStartServer(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  if FDestroying then
    exit;

  if AutoStartCheck.Checked then
  begin
    if ElapsedTime > FAutoStartAfter then
    begin
      FPJHTimerPool.Remove(FAutoStartTimerHandle);
      FAutoStartTimerHandle := -1;
      MonitorStart;
      AutoStartCheck.Caption := AutoStartCheck.Caption + '(Server start done.)';
    end
    else
    begin
      AutoStartCheck.Caption := 'Auto start after ' + IntToStr((FAutoStartAfter - ElapsedTime) div 1000) + ' seconds';
    end;
  end;
end;

procedure TFrameDataSaveAll.OnConnect(Sender: TIPCThread_HiMECS_MDI; Connecting: Boolean);
begin
  PostMessage(Handle, WM_UPDATESTATUS_HiMECS_MDI, WPARAM(Connecting), 0);
end;

procedure TFrameDataSaveAll.OnDataSave(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
var
  i,j: integer;
  LStr, LValue, LName: string;
  Le: Double;
  LEPItem: TEngineParameterItem;
  ILog: ISynLog;
begin
  if FIPCMonitorAll.FCommDisconnected then
  begin
    ILog := TSQLLog.Enter;
    ILog.Log(sllInfo,'OnDataSave : FIPCMonitorAll.FCommDisconnected');
    exit;
  end;

  if FDestroying then
  begin
    ILog := TSQLLog.Enter;
    ILog.Log(sllInfo,'OnDataSave : FDestroying');
    exit;
  end;

  if FIsSaveRunHour then
  begin
    with FIPCMonitorAll.FEngineParameter.EngineParameterCollect do
    begin
      if (FParamRunHourIndex >= 0) and
        (FParamRunHourIndex < Count) then
      begin
        if StrToIntDef(Items[FParamRunHourIndex].Value, -1) > 0 then
        begin
          if FRunHourCalcTimerHandle = -1 then
          begin
            FRunHourCalcTimerHandle := FPJHTimerPool.Add(OnRunHourCalc, 1000);
            FRunHourSaveTimerHandle := FPJHTimerPool.Add(OnRunHourSave, FRunHourSaveInterval);

            if FRunHourValueFromini = -1 then
              LoadRunHourFromini;
            FRunHourValueFromini := FRunHourValue;
          end;
        end
        else
        begin
          if FRunHourCalcTimerHandle <> -1 then
          begin
            FPJHTimerPool.Remove(FRunHourCalcTimerHandle);
            FRunHourCalcTimerHandle := -1;
            FPJHTimerPool.Remove(FRunHourSaveTimerHandle);
            FRunHourSaveTimerHandle := -1;
            SaveRunHour2ini;
          end;
        end;
      end;
    end;//with
  end;

  Proc_DataSave_Always;

  //Ư�� �ʵ��� ���� > 0 �϶��� ������
  if FIsSaveOnly then
  begin
    with FIPCMonitorAll.FEngineParameter.EngineParameterCollect do
    begin
      if (FParamIndex >= 0) and
        (FParamIndex < Count) then
      begin
        LValue := Items[FParamIndex].Value;

        if Pos('.', LValue) = 0 then //.(��)�� ������ ������ �Ǵ���
          j := StrToIntDef(LValue, 0)
        else
          j := Round(StrToFloatDef(LValue, 0.0));

        if j = 0 then
        begin
          if FDataSaveStopping then
            FPJHTimerPool.AddOneShot(OnDataSaveOnce, 100);
          exit;
        end;
      end;
    end;
  end;

  FDataSaveStopping := True;

  if FAutoChangeSaveFileName then
  begin
    LStr := FormatDatetime('yyyymmdd',date)+'.'+'CSV';

    if FSaveFileName <> LStr then
      if (CB_CSVlogging.Checked) and (FFileName_Convention = FC_YMD) then
        FSaveFileName := LStr;
  end;

  Proc_DataSave(False); //BulkMode = True�� ��� DataList�� 100�� ä������ ������. = False
end;

procedure TFrameDataSaveAll.OnDataSaveOnce(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  if FDestroying then
    exit;

  FDataSaveStopping := False;
  Proc_DataSave(True); //DataList�� 100�� ���Ͽ��� ������. = True
end;

procedure TFrameDataSaveAll.OnReconnectWhenDBDisconnect(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  if FDestroying then
    exit;

  FStatusBar.SimplePanel := true;
  FStatusBar.SimpleText := FormatDateTime('yyyy-mm-dd hh:mi:ss:zzz', now) + ' => ' + 'DB Try Reconnect';

  FDataSave2OracleDBThread.DisConnectDB;
  FDataSave2OracleDBThread.ConnectDB;

  if FDataSave2OracleDBThread.FOraSession1.Connected then
  begin
    FPJHTimerPool.Remove(FDBReConnectTimerHandle);
    FDBReConnectTimerHandle := -1;
  end;
end;

procedure TFrameDataSaveAll.OnRunHourCalc(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  if FDestroying then
    exit;

  FRunHourValue := FRunHourValueFromini + FPJHTimerPool.ElapsedTimeSec[FRunHourCalcTimerHandle];
  RunHourPanel.Caption := FORMAT_TIME(FRunHourValue);
end;

procedure TFrameDataSaveAll.OnRunHourSave(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  if FDestroying then
    exit;

  SaveRunHour2ini;
end;

procedure TFrameDataSaveAll.OnSignal(Sender: TIPCThread_HiMECS_MDI;
  Data: TEventData_HiMECS_MDI);
begin
  Flags := Data.Flags;
end;

procedure TFrameDataSaveAll.Option1Click(Sender: TObject);
var
  FSaveConfigF: TFrmDataSaveAllConfig;
begin
  FSaveConfigF := TFrmDataSaveAllConfig.Create(Self);
  FPJHTimerPool.Enabled[FDataSaveTimerHandle] := False;

  try
    with FSaveConfigF do
    begin
      LoadConfigDataini2Form(FSaveConfigF);

      if ShowModal = mrOK then
      begin
        SaveConfigDataForm2ini(FSaveConfigF);

        if FIsAutoRun then
        begin
          LoadConfigDataini2Var(FActionDataIni);
          SaveActionData2ini(FActionDataIni);
          IPCAll_Final;
//          IPCAll_Init; Start Ŭ�� �� MonitorStart �Լ����� ������
          ApplyActionData;
        end
        else
          LoadConfigDataini2Var;
        //AdjustConfigData(FConfigModified);
      end;
    end;
  finally
    FSaveConfigF.Free;
    FPJHTimerPool.Enabled[FDataSaveTimerHandle] := True;
  end;
end;

procedure TFrameDataSaveAll.ParamSource2CLBFromFile(AListBox: TCheckListBox;
  AFileName: string; AEngParamFileFormat: integer; AEncrypt: Boolean);
var
  LEP: TEngineParameter;
  LStrList: TStringList;
begin
  LEP := TEngineParameter.Create(nil);
  LStrList := TStringList.Create;

  try
    if LoadParamFile(AFileName, LEP, AEngParamFileFormat, AEncrypt) then
    begin
      SetParamSourceList(LStrList,LEP);
      ParamSource2LB(AListBox, LStrList);
    end;

  finally
    LStrList.Free;
    LEP.Free;
  end;
end;

procedure TFrameDataSaveAll.ParamSource2LB(AListBox: TCheckListBox;
  AList: TStringList; AIni: TIniFile);
var
  LStrList: TStringList;
  i: integer;
begin
  //parameter file���� Item�� ���� �� �����ϴ� Item Check Box�� Enable ��
  LStrList := TStringList.Create;
  try
    ParameterSource2Strings(LStrList);
    AListBox.Items.AddStrings(LStrList);

    for i := 0 to AListBox.Items.Count - 1 do
    begin
      if AList.IndexOf(AListBox.Items.Strings[i]) = -1 then
      begin
        AListBox.ItemEnabled[i] := False;
        AListBox.State[i] := cbGrayed;
      end;

      if AListBox.ItemEnabled[i] then
        if Assigned(AIni) then
          AListBox.Checked[i] := AIni.ReadBool(PARAM_SECTION, AListBox.Items.Strings[i], False);
    end;
  finally
    LStrList.Free;
  end;
end;

procedure TFrameDataSaveAll.Proc_DataSave(ADataStopping: Boolean);
var
  i,j,k,m: integer;
  LStr, LName: String;
  ILog: ISynLog;
begin
  i := 0;
  j := 0;
  k := 0;
  m := 0;
  LStr := '';

  if FIPCMonitorAll.FCommDisconnected then
  begin
    ILog := TSQLLog.Enter;
    ILog.Log(sllInfo,'FIPCMonitorAll.FCommDisconnected');
    exit;
  end;

  if Assigned(FIPCMonitorAll.FEngineParameter) then
  begin
    if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count = 0 then
    begin
      ILog := TSQLLog.Enter;
      ILog.Log(sllInfo,'FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count = 0');
      exit;
    end;
  end;

//  ILog := TSQLLog.Enter;
//  ILog.Log(sllInfo,'Proc_DataSave Start');

  if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].ParameterSource = psFlowMeterKral then
  begin
    if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count > 0 then
    begin
      while (i < FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count - 1) do
      begin
        j := StrToIntDef(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value,0);
        j := (j shl 16) or StrToIntDef(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i+1].Value,0);
        LStr := LStr + ',' + FloatToStr(j/10);
        i := i + 2;
      end;
    end;
  end
  else
  if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].ParameterSource = psPMSOPC then
  begin
    FSaveMongoAnalogDataBuf := '';
    FSaveMongoDigitalDataBuf := '';
    FSaveMongoDigitalDataBuf2 := '';

    for i := 0 to FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count - 1 do
    begin
      if UpperCase(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].TagName) = 'DUMMY' then
      begin
        ILog := TSQLLog.Enter;
        ILog.Log(sllInfo,'FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].TagName) = ''psPMSOPC''');
        continue;
      end;

      LName := ParameterSource2String(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].ParameterSource);

      if FParameterSourceList.IndexOf(LName) > -1 then
      begin
        if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value = '' then
          FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value := '0';

        case FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].BlockNo of
          1: begin
            FIsAnalogSave := FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].IsSaveItem and FSaveOnlyConditionTrue;

            if not FIsAnalogSave then
              FIsAnalogSave := not FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].IsSaveItem;

            FSaveMongoAnalogDataBuf := FSaveMongoAnalogDataBuf + '"' + FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Address + '":"' +
              FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value + '",';
            Inc(j);
          end;
          2: begin
            FIsDigitalSave := FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].IsSaveItem and FSaveOnlyConditionTrue;

            if not FIsDigitalSave then
              FIsDigitalSave := not FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].IsSaveItem;

            FSaveMongoDigitalDataBuf := FSaveMongoDigitalDataBuf + '"' + FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Address + '":"' +
              FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value + '",';
            Inc(k);
          end;
          3: begin
            FIsDigital2Save := FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].IsSaveItem and FSaveOnlyConditionTrue;

            if not FIsDigital2Save then
              FIsDigital2Save := not FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].IsSaveItem;

            FSaveMongoDigitalDataBuf2 := FSaveMongoDigitalDataBuf2 + '"' + FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Address + '":"' +
              FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value + '",';
            Inc(m);
          end;
        end;

        LStr := LStr + ',' + FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value;
      end;
    end;//for

    FDataSave2MongoDBThread.SetRecordCount(j);//TFrameIPCMonitorAll1.FEngineParameter.EngineParameterCollect.Count);
    FDataSave2MongoDBThread.SetRecordCount2(k);
    FDataSave2MongoDBThread.SetRecordCount3(m);
    AddDate2MongoData(FSaveMongoAnalogDataBuf);
    AddDate2MongoData(FSaveMongoDigitalDataBuf);
    AddDate2MongoData(FSaveMongoDigitalDataBuf2);
  end
  else
  begin
    for i := 0 to FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count - 1 do
    begin
      if UpperCase(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].TagName) = 'DUMMY' then
      begin
        continue;
      end;

//      LName := ParameterSource2String(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].ParameterSource);
      LName := FIPCMonitorAll.FEngineParameter.EngineParameterCollect.GetUniqueParamSourceName(i);

      if FParameterSourceList.IndexOf(LName) > -1 then
        LStr := LStr + ',' + FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value;

      //binary data�� ��� -> 0�̸� False, 0�� �ƴϸ� False�� ��
      {if not FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Alarm then
      begin
        if StrToIntDef(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value,0) = 0 then
          LValue := 'False'
        else
          LValue := 'True';
      end
      else
        LValue := FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value;
      }
    end;//for
  end;

  if FParameterSourceList.Count = 0 then
  begin
    DisplayMessage('Proc_DataSave �Լ����� Monitor Item �׸��� Null ��', Ord(dtSendMemo));
    exit;
  end;

  if LStr = '' then
  begin
    DisplayMessage('Proc_DataSave �Լ����� Data ���� Null ��', Ord(dtSendMemo));
    exit;
  end;

  if LStr[Length(LStr)] = ',' then
    System.Delete(LStr,Length(LStr),1);

  FSaveDataBuf := LStr;

  if CB_DBlogging.Checked then
    SaveData2DB(LName);

  if FBulkDataMode then
  begin
//    ILog := TSQLLog.Enter;
//    ILog.Log(sllInfo,'FBulkDataMode');
    LStr := formatDateTime('yyyy-mm-dd hh:nn:ss:zzz',now) + LStr;
    FDataSave2FileThread.FDataList.Add(LStr);
    if FDataSave2FileThread.FDataList.Count < 100 then
    begin
      if ADataStopping then
        if CB_CSVlogging.Checked then
          SaveData2File;
      exit
    end
    else
      FToggleBackground := not FToggleBackground;
  end
  else
  begin
    FToggleBackground := not FToggleBackground;
  end;

  if CB_CSVlogging.Checked then
  begin
//    ILog := TSQLLog.Enter;
//    ILog.Log(sllInfo,'CB_CSVlogging.Checked');
    SaveData2File;
  end;
end;

procedure TFrameDataSaveAll.Proc_DataSave_Always;
begin
  Proc_DataSave_Always_PMS;
end;

procedure TFrameDataSaveAll.Proc_DataSave_Always_PMS;
var
  i, j: integer;
  LName, LTag, LValue: string;
  LYear, LMonth, LDay: word;
begin
  if Assigned(FIPCMonitorAll.FEngineParameter) then
  begin
    if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count = 0 then
      exit;
  end;

  //PMS �������� ��� ���� ���϶��� ���� ������ �Ͽ����� ��� ����͸��� �ʿ��� �׸�(��������� ���� ����͸�)��
  //������ ������� DB�� ���� �Ǿ�� ��.(AbsoluteIndex ���� 0�� �ƴ� ���� ��� ��� ������)
  if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[0].ParameterSource = psPMSOPC then
  begin
    if not Assigned(FDataSave2MongoDBThread) then
    begin
      exit;
    end;

    FSaveMongoAnalogDataBuf2 := '';
    j := 0;

    for i := 0 to FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count - 1 do
    begin
      if UpperCase(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].TagName) = 'DUMMY' then
        continue;

      LName := ParameterSource2String(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].ParameterSource);

      if FParameterSourceList.IndexOf(LName) > -1 then
      begin
        if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].AbsoluteIndex <> 0 then
        begin
          if FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value = '' then
            FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value := '0';

          FElecPowerCalcBase.AddkW2Var(LTag, LValue);
          LTag := FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Address;
          LValue := FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[i].Value;
          FSaveMongoAnalogDataBuf2 := FSaveMongoAnalogDataBuf2 + '"' + LTag + '":"' + LValue + '",';
          Inc(j);
        end;
      end;
    end;//for

    DecodeDate(now, LYear, LMonth, LDay);
    if (FElecPowerCalcBase.FkWhRecord.FYear <> LYear) or
      (FElecPowerCalcBase.FkWhRecord.FMonth <> LMonth) or
      (FElecPowerCalcBase.FkWhRecord.FDay <> LDay) then
      FElecPowerCalcBase.ResetkWhAll(LYear, LMonth, LDay);

    FDataSave2MongoDBThread.InsertOrUpdateEngDivkWh2DB(LYear, LMonth, LDay,
      FElecPowerCalcBase.InCome1kWh, FElecPowerCalcBase.InCome2kWh,
      FElecPowerCalcBase.InCome3kWh, FElecPowerCalcBase.VCBF1kWh,
      FElecPowerCalcBase.VCBF2kWh,   FElecPowerCalcBase.VCBG7AkWh);
    FDataSave2MongoDBThread.SetRecordCount(j);//TFrameIPCMonitorAll1.FEngineParameter.EngineParameterCollect.Count);
    AddDate2MongoData(FSaveMongoAnalogDataBuf2);

    if CB_DBlogging.Checked then
      SaveData2DB(LName);

    FSaveMongoAnalogDataBuf2 := '';
    FToggleBackground := not FToggleBackground;
  end
end;

procedure TFrameDataSaveAll.RB_bydateClick(Sender: TObject);
begin
  FFileName_Convention := FC_YMD;
  ED_CSV.Text := FormatDatetime('yyyymmdd',date)+'.'+'CSV';
  ED_csv.enabled := False;
end;

procedure TFrameDataSaveAll.RB_byeventClick(Sender: TObject);
begin
  ED_interval.Enabled := False;
  ED_interval.Text := '';
//  FConfigOption.SelDisplayInterval := 0;
end;

procedure TFrameDataSaveAll.RB_byfilenameClick(Sender: TObject);
begin
  FFileName_Convention := FC_FIXED;
  ED_csv.enabled := True;
end;

procedure TFrameDataSaveAll.RB_byintervalClick(Sender: TObject);
begin
  ED_interval.Enabled := True;
  ED_interval.Text := '1000';
//  FConfigOption.SelDisplayInterval := 1;
end;

procedure TFrameDataSaveAll.SaveActionData2ini(AFileName: string);
var
  iniFile: TIniFile;
  i: integer;
  LStrList: TStringList;
begin
  if AFileName = '' then
  begin
    SaveDialog1.InitialDir := FFilePath;

    if SaveDialog1.Execute then
    begin
      AFileName := ExtractRelativePath(FFilePath, SaveDialog1.FileName);

      if FileExists(AFileName) then
      begin
        if MessageDlg('File is already exist. Are you overwrite? if No press, then save is cancelled.',
                                  mtConfirmation, [mbYes, mbNo], 0)= mrNo then
          exit
        else
        begin
          //AssignFile(F, LFileName);
          //Rewrite(F);
          //CloseFile(F);
        end;
      end;
    end;
  end;

  FActionDataIni := AFileName;

  if FActionDataIni = '' then
    FActionDataIni := ExtractFileName(Application.ExeName)+'ActionData.ini';

  if (Pos(':', FActionDataIni) = 0) and (Pos('.\', FActionDataIni) = 0) then
    FActionDataIni := '.\' + FActionDataIni;

  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(FActionDataIni);
  try
    with iniFile do
    begin
      WriteBool(ACTIONSAVE_SECTION, 'DB Logging', CB_DBLogging.Checked);
      WriteBool(ACTIONSAVE_SECTION, 'CSV Logging', CB_CSVLogging.Checked);
      WriteBool(ACTIONSAVE_SECTION, 'By Date', RB_Bydate.Checked);
      WriteBool(ACTIONSAVE_SECTION, 'By File Name', RB_ByFileName.Checked);
      WriteString(ACTIONSAVE_SECTION, 'CSV File Name', ED_csv.Text);
      WriteBool(ACTIONSAVE_SECTION, 'By Event', RB_ByEvent.Checked);
      WriteBool(ACTIONSAVE_SECTION, 'By Interval', RB_ByInterval.Checked);
      WriteString(ACTIONSAVE_SECTION, 'Interval', ED_interval.Text);
    end;//with

    DisplayMessage(#13#10+'Action Data Saved'+#13#10, Ord(dtSendMemo));
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TFrameDataSaveAll.SaveConfigDataForm2ini(FSaveConfigF: TFrmDataSaveAllConfig);
var
  iniFile: TIniFile;
  LStr,LFileName: string;
  LBool: Boolean;
  i: integer;
begin
  SetCurrentDir(FFilePath);
  DisplayMessage(#13#10+'System configuration changed'+#13#10+'Please restart program...' , Ord(dtSendMemo));

  if FIsAutoRun then
    LFileName := FActionDataIni
  else
    LFileName := GetIniFileName;

  if (Pos(':', LFileName) = 0) and (Pos('.\', LFileName) = 0) then
    LFileName := '.\' + LFileName;

  iniFile := nil;
  iniFile := TInifile.create(LFileName);
  try
    with iniFile, FSaveConfigF do
    begin
      //WriteString(DATASAVE_SECTION, 'Power Meter Shared Memory Name', Ed_PowerMeterMM.Text);
      //WriteString(DATASAVE_SECTION, 'ECS Shared Memory Name', Ed_sharedmemory.Text);
      //WriteString(DATASAVE_SECTION, 'Dynamo Shared Memory Name', Ed_DynamoMM.Text);

      WriteString(DATASAVE_SECTION, 'Modbus Map File Name1', ExtractRelativePath(FFilepath, MapFilenameEdit.FileName));
      WriteString(DATASAVE_SECTION, 'Parameter File Name', ExtractRelativePath(FFilepath, ParaFilenameEdit.FileName));
      WriteString(DATASAVE_SECTION, 'Block No', BlockNoEdit.Text);
      WriteInteger(DATASAVE_SECTION, 'Save Interval', IntervalSE.Value);
      WriteBool(DATASAVE_SECTION, 'DB Enable', SaveDB_ChkBox.Checked);

      WriteInteger(DATASAVE_SECTION, 'DB Type', DB_Type_RG.ItemIndex);

      WriteString(ORACLE_SECTION, 'DB Server', ServerEdit.Text);
      WriteString(ORACLE_SECTION, 'User ID', UserEdit.Text);
      WriteString(ORACLE_SECTION, 'Passwd', PasswdEdit.Text);
      WriteString(ORACLE_SECTION, 'Table Name', TableNameCombo.Text);
      WriteInteger(ORACLE_SECTION, 'Reconnect Interval', ReConnectIntervalEdit.Value);

      WriteString(MONGODB_SECTION, 'DB Server Address', MongoServerEdit.Text);
      WriteString(MONGODB_SECTION, 'User ID', MongoUserEdit.Text);
      WriteString(MONGODB_SECTION, 'Passwd', MongoPasswdEdit.Text);
      WriteString(MONGODB_SECTION, 'DataBase Name', MongoDBNameCombo.Text);
      WriteString(MONGODB_SECTION, 'Collection Name', MongoCollNameCombo.Text);
      WriteString(MONGODB_SECTION, 'Collection Name 2', MongoCollNameCombo2.Text);
      WriteString(MONGODB_SECTION, 'Collection Name 3', MongoCollNameCombo3.Text);
      WriteInteger(MONGODB_SECTION, 'Reconnect Interval', MongoReConnectEdit.Value);

      WriteBool(DATASAVE_SECTION, 'Parameter Encrypt', EngParamEncryptCB.Checked);
      WriteInteger(DATASAVE_SECTION, 'Param File Format', ConfFileFormatRG.ItemIndex);
      WriteString(DATASAVE_SECTION, 'Append String To CSV FileName', AppendStrEdit.Text);

      WriteBool(DATASAVE_SECTION, 'Save Only', SaveOnlyCB.Checked);
      WriteBool(DATASAVE_SECTION, 'Save Run Hour', SaveRunHourCB.Checked);

      WriteString(DATASAVE_SECTION, 'Parameter Index', ParamIndexEdit.Text);
      WriteString(DATASAVE_SECTION, 'Run Hour Index', RunHourIndexEdit.Text);
      WriteInteger(DATASAVE_SECTION, 'Run Hour Save Interval', RHIntervalSE.Value);
      Writeinteger(DATASAVE_SECTION, 'SaveFileName Change Type', FNameType_RG.ItemIndex);
      WriteString(DATASAVE_SECTION, 'Auto Start After', AutoStartAfterEdit.Text);
      WriteBool(DATASAVE_SECTION, 'Display Saved Raw Data', DisplySavedRawDataCB.Checked);

      for i := 0 to ParamSourceCLB.Items.Count - 1 do
      begin
        WriteBool(PARAM_SECTION, ParamSourceCLB.Items.Strings[i], ParamSourceCLB.Checked[i]);
      end;
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TFrameDataSaveAll.SaveData2DB(AParamSource: string);
begin
  if not FDBEnable then
    exit;

  if FDBType = DT_ORACLE then
    SaveData2OracleDB
  else
  if FDBType = DT_MONGODB then
    SaveData2MongoDB(AParamSource);
end;

procedure TFrameDataSaveAll.SaveData2File;
//var
//  ILog: ISynLog;
begin
  with FDataSave2FileThread do
  begin
    FStrData := formatDateTime('yyyy-mm-dd hh:nn:ss:zzz',now) + FSaveDataBuf; //������ ������(FSaveDataBuf)�� ����(FStrData)�� �Է�
    FTagData := FTagNameBuf;  //���ʿ� �������� ���� �� ���(�Ӹ���) �Է�
    FName_Convention := FFileName_Convention; //���ϸ��� �������ִ� �������
    FFileName := FSaveFileName; //���ϸ� ���� (FName_Convention�� FC_Fixed������ ���)
    FAppendString2FileName := FAppendStr;

    if FAppendString2FileName = '' then
      FAppendString2FileName := 'csv'
    else
      FAppendString2FileName := FAppendString2FileName + '.csv';

    if not FSaving then
    begin
      DisplayMessage(TimeToStr(Time)+' => ' + FormatDatetime('yyyymmdd',date) + '.' + FAppendString2FileName + ' data saved.', Ord(dtSendMemo));

      if FIsDisplySavedRawData then
        DisplayMessage(FStrData, Ord(dtSendMemo));
    end;
    FDataSaveEvent.Signal;
  end;//with

  FSaveDataBuf := '';
end;

procedure TFrameDataSaveAll.SaveData2MongoDB(AParamSource: string);
begin
  if not FConnectedMongoDB then
  begin
    FDataSave2MongoDBThread.DisConnectDB;
    FConnectedMongoDB := FDataSave2MongoDBThread.ConnectDB;

    if not FConnectedMongoDB then
    begin
      DisplayMessage(DateTimeToStr(now)+' Database is disconnected', 0);
      exit;
    end;
  end;

  with FDataSave2MongoDBThread do
  begin
//    FSaveDBDataBuf := FSaveDataBuf;
//    FStrData := formatDateTime('yyyymmddhhnnsszzz',now) + FSaveDBDataBuf; //������ ������(FSaveDataBuf)�� ����(FStrData)�� �Է�
    FMongoAnalogData := '';
    FMongoDigitalData := '';
    FMongoDigitalData2 := '';

    if AParamSource = ParameterSource2String(psPMSOPC) then
    begin
      //Param File�� Absolute Index�� 0�� �ƴϸ� �Ʒ� ������ ������
      if FSaveMongoAnalogDataBuf2 <> '' then
      begin
        FMongoAnalogData := FSaveMongoAnalogDataBuf2;
        FMongoCollectName := Self.FMongoCollectionName;
      end
      else
      if FIsAnalogSave then
      begin
        FMongoAnalogData := FSaveMongoAnalogDataBuf;
        FMongoCollectName := Self.FMongoCollectionName;
      end;

      if FIsDigitalSave then
      begin
        FMongoDigitalData := FSaveMongoDigitalDataBuf;
        FMongoCollectName2 := Self.FMongoCollectionName2;
      end;

      if FIsDigital2Save then
      begin
        FMongoDigitalData2 := FSaveMongoDigitalDataBuf2;
        FMongoCollectName3 := Self.FMongoCollectionName3;
      end;
    end;

    if not FSaving then
      FDataSaveEvent.Signal;
  end;//with
end;

procedure TFrameDataSaveAll.SaveData2OracleDB;
begin
  if not FConnectedOracleDB then
  begin
    FDataSave2OracleDBThread.DisConnectDB;
    FConnectedOracleDB := FDataSave2OracleDBThread.ConnectDB;

    if not FConnectedOracleDB then
    begin
      DisplayMessage(TimeToStr(Time)+' Database is disconnected', Ord(dtSendMemo));
      exit;
    end;
  end;

  with FDataSave2OracleDBThread do
  begin
    FSaveDBDataBuf := FSaveDataBuf;
    //FStrData := FloatToStr(now) + FSaveDBDataBuf; //������ ������(FSaveDataBuf)�� ����(FStrData)�� �Է�
    FStrData := formatDateTime('yyyymmddhhnnsszzz',now) + FSaveDBDataBuf; //������ ������(FSaveDataBuf)�� ����(FStrData)�� �Է�

    if not FSaving then
      FDataSaveEvent.Signal;
  end;//with
end;

procedure TFrameDataSaveAll.SaveRunHour2ini;
var
  iniFile: TIniFile;
  LStr: string;
begin
  if not FRunHourEnable then
    exit;

  SetCurrentDir(FFilePath);
  LStr := ExtractFilename(FParamFileName);
  LStr := ChangeFileExt(LStr, '');
  iniFile := TInifile.create('.\'+LStr+'_'+SAVERUNHOURINIFILENAME);
  try
    with iniFile do
    begin
      Writeinteger('Run Hour', 'Value', FRunHourValue);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TFrameDataSaveAll.SetFileNameConvention(AValue: TFileName_Convetion);
begin
  FFileName_Convention := AValue;
end;

procedure TFrameDataSaveAll.SetOnAutoStartServer(AInterval: integer);
begin
  FAutoStartTimerHandle := FPJHTimerPool.Add(OnAutoStartServer, AInterval);//FAutoStartAfter);
end;

procedure TFrameDataSaveAll.SetParamFileName(AName: string);
begin
  FParamFileName := AName;
end;

function TFrameDataSaveAll.SetParamSourceList(var AList: TStringList;
  AEP: TEngineParameter): string;
var
  i: integer;
  LName: string;
begin
  Result := '';

  for i := 0 to AEP.EngineParameterCollect.Count - 1 do
  begin
    if UpperCase(AEP.EngineParameterCollect.Items[i].TagName) = 'DUMMY' then
      continue;

    if AEP.EngineParameterCollect.Items[i].ParameterSource = psManualInput then
      continue;

    Result := Result + ',' + replaceString(AEP.EngineParameterCollect.Items[i].Description, ',', '', False);

//    LName := ParameterSource2String(AEP.EngineParameterCollect.Items[i].ParameterSource);
    LName := AEP.EngineParameterCollect.GetUniqueParamSourceName(i);

    if AList.IndexOf(LName) = -1 then
      AList.AddObject(LName, AEP.EngineParameterCollect.Items[i]);
  end;
end;

procedure TFrameDataSaveAll.SetSaveDataBuf(AData: string);
begin
  FSaveDataBuf := AData;
end;

procedure TFrameDataSaveAll.SetSaveFileName(AName: string);
begin
  FSaveFileName := AName;
end;

procedure TFrameDataSaveAll.SetTagBuf(ATag: string);
begin
  FTagNameBuf := ATag;
end;

procedure TFrameDataSaveAll.Show0thTagValue1Click(Sender: TObject);
begin
  ShowMessage(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Items[0].Value);
end;

procedure TFrameDataSaveAll.ShowBulkMode1Click(Sender: TObject);
begin
  ShowMessage(BoolToStr(FBulkDataMode));
end;

procedure TFrameDataSaveAll.ShowEvendDataListCount1Click(Sender: TObject);
begin
  ShowMessage(IntToStr(FIPCMonitorAll.GetEventData_PLCMODBUS_ListCount));
end;

procedure TFrameDataSaveAll.ShowEventDataListUniqName1Click(Sender: TObject);
begin
  ShowMessage(FIPCMonitorAll.GetEventData_PLCMODBUS_ListName);
end;

procedure TFrameDataSaveAll.ShowEventName1Click(Sender: TObject);
begin
  ShowMessage(FEventName);
end;

procedure TFrameDataSaveAll.ShowParamCount1Click(Sender: TObject);
begin
  ShowMessage(IntToStr(FIPCMonitorAll.FEngineParameter.EngineParameterCollect.Count));
end;

procedure TFrameDataSaveAll.ShowSaveInterval1Click(Sender: TObject);
begin
  ShowMessage(IntToStr(FSaveInterval));
end;

procedure TFrameDataSaveAll.ShowTagNameHeader1Click(Sender: TObject);
begin
  ShowMessage(FTagNameBuf);
end;

procedure TFrameDataSaveAll.UniqueParamSource2CLBFromFile(
  AListBox: TCheckListBox; AFileName: string; AEngParamFileFormat: integer;
  AEncrypt: Boolean);
var
  LEP: TEngineParameter;
  LStrList: TStringList;
begin
  LEP := TEngineParameter.Create(nil);
  LStrList := TStringList.Create;

  try
    if LoadParamFile(AFileName, LEP, AEngParamFileFormat, AEncrypt) then
    begin
      SetParamSourceList(LStrList, LEP);
      UniqueParamSource2LB(AListBox, LStrList);
    end;

  finally
    LStrList.Free;
    LEP.Free;
  end;
end;

procedure TFrameDataSaveAll.UniqueParamSource2LB(AListBox: TCheckListBox;
  AList: TStringList; AIni: TIniFile);
var
  LStrList: TStringList;
  i: integer;
begin
  LStrList := nil;

  if not Assigned(AList) then
  begin
    LStrList := TStringList.Create;
    FIPCMonitorAll.GetParameterSourceList(LStrList);
    AListBox.Items.AddStrings(LStrList);
  end
  else
    AListBox.Items.AddStrings(AList);

  try

    for i := 0 to AListBox.Items.Count - 1 do
    begin
//      if AList.IndexOf(AListBox.Items.Strings[i]) = -1 then
//      begin
//        AListBox.ItemEnabled[i] := False;
//        AListBox.State[i] := cbGrayed;
//      end;

      if AListBox.ItemEnabled[i] then
        if Assigned(AIni) then
          AListBox.Checked[i] := AIni.ReadBool(PARAM_SECTION, AListBox.Items.Strings[i], False);
    end;
  finally
    if Assigned(LStrList) then
      LStrList.Free;
  end;
end;

procedure TFrameDataSaveAll.UpdateStatusBar(var Msg: TMessage);
const
  ConnectStr: Array[Boolean] of PChar = ('Not Connected', 'Connected');
begin
  FStatusBar.SimpleText := ConnectStr[Boolean(Msg.WParam)];
end;

procedure TFrameDataSaveAll.WatchValue2Screen_Analog(Name, AValue: string;
  AEPIndex: integer);
begin
;
end;

procedure TFrameDataSaveAll.WMCopyData(var Msg: TMessage);
begin
  case Msg.WParam of //Echo
    WParam_DISPLAYMSG: begin
      DisplayMessage(PRecToPass(PCopyDataStruct(Msg.LParam)^.lpData)^.StrMsg,
             PRecToPass(PCopyDataStruct(Msg.LParam)^.lpData)^.iHandle);
    end;
  end;
end;

procedure TFrameDataSaveAll.WMDBDisconnected(var Msg: TMessage);
begin
  FStatusBar.SimplePanel := true;
  FStatusBar.SimpleText := FormatDateTime('yyyy-mm-dd hh:mi:ss:zzz', now) + ' => ' + 'DB Disconnected';

  if FDBReConnectTimerHandle = -1 then
    FDBReConnectTimerHandle := FPJHTimerPool.Add(OnReconnectWhenDBDisconnect,FReConnectInterval);
end;

end.
