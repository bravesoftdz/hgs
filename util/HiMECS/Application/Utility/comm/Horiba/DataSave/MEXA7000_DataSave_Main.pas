unit MEXA7000_DataSave_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Menus, IPCThrdMonitor_MEXA7000, DataSaveConst, ComCtrls,
  IPCThrd_MEXA7000, DataSave2FileThread, DataSave2DBThread, SyncObjs,inifiles,
  DataSaveConfig;

const
  INIFILENAME = '.\DatasaveConfig_';
  DeviceName = 'Horiba-MEXA-7000';
  DATASAVE_SECTION = 'Datasave';

type
  TDisplayTarget = (dtSendMemo, dtRecvMemo, dtStatusBar);
  TDataSaveMain = class(TForm)
    MainMenu1: TMainMenu;
    FILE1: TMenuItem;
    HELP1: TMenuItem;
    Timer1: TTimer;
    Protocol: TMemo;
    StatusBar1: TStatusBar;
    CB_Active: TCheckBox;
    Connect1: TMenuItem;
    Disconnect1: TMenuItem;
    Close1: TMenuItem;
    Option1: TMenuItem;
    Help2: TMenuItem;
    N1: TMenuItem;
    About1: TMenuItem;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RB_byevent: TRadioButton;
    CB_DBlogging: TCheckBox;
    CB_CSVlogging: TCheckBox;
    RB_byinterval: TRadioButton;
    ED_interval: TEdit;
    ED_csv: TEdit;
    Label1: TLabel;
    RB_bydate: TRadioButton;
    RB_byfilename: TRadioButton;
    Timer2: TTimer;
//    GLUserShader1: TGLUserShader;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CB_ActiveClick(Sender: TObject);
    procedure Connect1Click(Sender: TObject);
    procedure Disconnect1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure RB_bydateClick(Sender: TObject);
    procedure RB_byfilenameClick(Sender: TObject);
    procedure RB_byeventClick(Sender: TObject);
    procedure RB_byintervalClick(Sender: TObject);
    procedure Option1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);

  private
    { Private declarations }

    //DB�� ������������ ���� ���������
    FDataSave2DBThread: TDataSave2DBThread; //DB�� ����Ÿ �����ϴ� ��ü
    FHostName: string;//DB Host Name(IP address)
    FDBName: string;  //DB Name(Mysql�� DB Name)
    FLoginID: string;   //Login Name
    FPasswd: string;  //Password
    FSaveDataBuf_CO2: Double;
    FSaveDataBuf_CO_L: Double;
    FSaveDataBuf_O2: Double;
    FSaveDataBuf_NOX: Double;
    FSaveDataBuf_THC: Double;
    FSaveDataBuf_CH4: Double;
    FSaveDataBuf_non_CH4: Double;
    FSaveDataBuf_collected: Double;

    //CSV ���� ������ ���� ���������///////////////////////////////////////////
    FLogStart: Boolean;  //Log save Start sig.
    FTagNameBuf: string;  //���Ͽ� ������ �����ϱ� ���� ����
    FSaveFileName: string; //����Ÿ�� ������ File �̸�(������ ���� �����)
    FSaveDataBuf: string; //���Ͽ� ������ ����Ÿ�� �����ϴ� ����
    FFileName_Convention: TFileName_Convetion;//���Ͽ� ����ÿ� �����̸��ο� ���
    FDataSave2FileThread: TDataSave2FileThread;//���Ͽ� ����Ÿ �����ϴ� ��ü

    //��հ���� ���� ���������////////////////////////////////////////////////
    Sumof_CO2: Double;
    Sumof_CO_L: Double;
    Sumof_O2: Double;
    Sumof_NOX: Double;
    Sumof_THC: Double;
    Sumof_CH4: Double;
    Sumof_non_CH4: Double;
    Sumof_collected: Double;
    TotalDataNo: Integer;

    //Critical Section ���������///////////////////////////////////////////////
    FCriticalSection: TCriticalSection;

    procedure OnSignal(Sender: TIPCThread_MEXA7000; Data: TEventData_MEXA7000);
    procedure LoadConfigDataini2Form(FSaveConfigF: TSaveConfigF);
    procedure SaveConfigDataForm2ini(FSaveConfigF: TSaveConfigF);
    procedure LoadConfigDataini2Var;

  public
    { Public declarations }
    FFilePath: string;      //������ ������ ���
    FIPCMonitor: TIPCMonitor_MEXA7000;//���� �޸� �� �̺�Ʈ ��ü
    FMonitorStart: Boolean; //Ÿ�̸� ���� �Ϸ��ϸ� True
    FSharedMMName: string;  //���� �޸� �̸�
    procedure SaveData2DB;
    procedure SaveData2File;
    procedure SaveDataAverage2File;
    procedure CreateSave2DBThread;
    procedure CreateSave2FileThread;
    procedure DisplayMessage(msg: string; ADspNo: TDisplayTarget);
    procedure DestroySave2FileThread;
    procedure DestroySave2DBThread;

  end;

var
  DataSaveMain: TDataSaveMain;
//  DataSave_Start: Boolean;

implementation

{$R *.dfm}
procedure TDataSaveMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FCriticalSection.Enter;
  FMonitorStart := False;
  try
    if Assigned(FDataSave2FileThread) then
    begin
      FDataSave2FileThread.Terminate;
      FDataSave2FileThread.FDataSaveEvent.Pulse;
      FDataSave2FileThread.Free;
    end;//if

    if Assigned(FDataSave2DBThread) then
    begin
      FDataSave2DBThread.Terminate;
      FDataSave2DBThread.FDataSaveEvent.Pulse;
      FDataSave2DBThread.Free;
    end;//if

    FIPCMonitor.FMonitorEvent.Pulse;
    FIPCMonitor.Terminate;
  finally
    FCriticalSection.Leave;
  end;//try

  FCriticalSection.Free;
end;

////////////////////////////////////////////////////////////////////////////////
//���α׷� �ʱ�ȭ Timer1Timer ����
procedure TDataSaveMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  ED_CSV.Text := FormatDatetime('yyyymmdd',date)+'.'+'CSV';
  FFilePath := ExtractFilePath(Application.ExeName);

  LoadConfigDataini2Var;

  //IPC Monitor �Լ� �ʱ�ȭ ����
  FIPCMonitor := TIPCMonitor_MEXA7000.Create(0, FSharedMMName, True);
  FIPCMonitor.FreeOnTerminate := True;
  FIPCMonitor.OnSignal := OnSignal;
  DisplayMessage('Shared Memory: ' + FSharedMMName + ' Created!', dtSendMemo);

  //�������� �ջ��� �ʱ�ȭ �ϱ� ���� �κ�
  Sumof_CO2 := 0.0;
  Sumof_CO_L := 0.0;
  Sumof_O2 := 0.0;
  Sumof_NOx := 0.0;
  Sumof_THC := 0.0;
  Sumof_CH4 := 0.0;
  Sumof_non_CH4 := 0.0;
  Sumof_Collected := 0.0;
  TotalDataNo := 0;


  CreateSave2FileThread;
//  FDataSave2FileThread.FName_Convention := FC_YMD;

end;






////////////////////////////////////////////////////////////////////////////////
//���θ޴�-Connect ��ư
procedure TDataSaveMain.Connect1Click(Sender: TObject);
begin
//  CreateSave2DBThread;
end;
//���θ޴�-Disconnect ��ư
procedure TDataSaveMain.Disconnect1Click(Sender: TObject);
begin
//  FDataSave2DBThread.ZConnection1.Connected := False;
//  DisplayMessage('Server Disconnected'+#13#10, dtSendMemo);
end;
//���θ޴�-Close ��ư
procedure TDataSaveMain.Close1Click(Sender: TObject);
begin
  Close;
end;
//���θ޴�-Option ��ư
procedure TDataSaveMain.Option1Click(Sender: TObject);
var
  FSaveConfigF: TSaveConfigF;
begin
  FSaveConfigF := TSaveConfigF.Create(Application);

  with FSaveConfigF do
  begin
    try
      LoadConfigDataini2Form(FSaveConfigF);
      if ShowModal = mrOK then
      begin
        SaveConfigDataForm2ini(FSaveConfigF);
{        LoadConfigDataini2Var;
        AdjustConfigData;
}      end;
    finally
      Free;
    end;
  end;
end;
//���θ޴�-About ��ư
procedure TDataSaveMain.About1Click(Sender: TObject);
begin
  DisplayMessage (
  #13#10+#13#10
  +'#######################'+#13#10
  +'DataSave Program'+#13#10
  +'for Horiba Mexa 7000'+#13#10
  +'2010.4.29'+#13#10
  +'#######################'+#13#10, dtSendMemo);
end;

//Active ��ư Ŭ��
procedure TDataSaveMain.CB_ActiveClick(Sender: TObject);
begin
//  if not Assigned(FDataSave2DBThread) then
//    CreateSave2DBThread;

  //Data save�� �������� ���
  if CB_Active.Checked then
  begin
    FMonitorStart := True;
    DisplayMessage (#13#10+ '#####################' +#13#10+ TimeToStr(Time)+' Start Data Receiving', dtSendMemo);
    FLogStart := True;

    //CSV ���Ͽ� Data Save�� ���
    if CB_CSVlogging.Checked then
    begin
      FSaveDataBuf :=#13#10+TimeToStr(Time)+','+'START DATA LOGGING'+#13#10+'Time,CO2,CO_L,O2,NOx,THC,CH4,non_CH4,Collected';
      FSaveFileName := ED_csv.Text;
      SaveData2File;
    end;

    //�����޸� ����;����� ���� ����
    FIPCMonitor.Resume;

    //Data save ���߿� ���ú��� �Ұ�
    CB_DBlogging.Enabled := False;
    CB_CSVlogging.Enabled := False;
    RB_bydate.Enabled := False;
    RB_byfilename.Enabled := False;
    ED_csv.Enabled := False;
    RB_byevent.Enabled := False;
    RB_byinterval.Enabled := False;
    ED_interval.Enabled := False;
  end

  //Data save�� ������ ���
  else
  begin
    if CB_CSVlogging.Checked then
    begin
      SaveDataAverage2File;   //CSV ���Ͽ� ������ ��, �� ��ġ�� ��հ� �Է�
    end;
    FMonitorStart := False;
    DisplayMessage (TimeToStr(Time)+' Processing terminated', dtSendMemo);
    FlogStart := False;
    FIPCMonitor.Suspend;    //�����޸� ����;����� ���� ����

    //Data save������ ���ÿ� �� ��ư ���ú���Ұ� ����
    CB_DBlogging.Enabled := True;
    CB_CSVlogging.Enabled := True;
    RB_bydate.Enabled := True;
    RB_byfilename.Enabled := True;
    if RB_byfilename.Checked then
    begin
      ED_csv.Enabled := True;
    end;
    RB_byevent.Enabled := True;
    RB_byinterval.Enabled := True;
    if RB_byinterval.Checked then
    begin
      ED_interval.Enabled := True;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//Save by date ���� ��ư
procedure TDataSaveMain.RB_bydateClick(Sender: TObject);
begin
  FFileName_Convention := FC_YMD;
  ED_CSV.Text := FormatDatetime('yyyymmdd',date)+'.'+'CSV';
  ED_csv.enabled := False;
end;
//Save by filename ���� ��ư
procedure TDataSaveMain.RB_byfilenameClick(Sender: TObject);
begin
  FFileName_Convention := FC_FIXED;
  ED_csv.enabled := True;
end;
//Save by interval ���� ��ư//////////////////////////////////////////////////
procedure TDataSaveMain.RB_byintervalClick(Sender: TObject);
begin
  ED_interval.Enabled := True;
  ED_interval.Text := '1000';
end;
//Save by event ���� ��ư/////////////////////////////////////////////////////
procedure TDataSaveMain.RB_byeventClick(Sender: TObject);
begin
  ED_interval.Enabled := False;
  ED_interval.Text := '';
end;

////////////////////////////////////////////////////////////////////////////////
//TCPClient ���α׷����� ������ onsignal�� �������� �ν��Ͽ� Data Save �Լ���
//������Ű�� �Լ�
procedure TDataSaveMain.OnSignal(Sender: TIPCThread_MEXA7000; Data: TEventData_MEXA7000);
begin
  DisplayMessage(#13#10+TimeToStr(Time)+' Data Received', dtSendMemo);

  if not FMonitorStart then
    exit;

  if CB_CSVlogging.Checked then
  begin
    FSaveDataBuf :=TimeToStr(Time)+','+Data.CO2+','+Data.CO_L+','+Data.O2+','+Data.NOx+','+Data.THC+','+Data.CH4+','+Data.non_CH4+','+FloatToStr(Data.CollectedValue);
    SaveData2File;

    //�������� ��հ��� ���ϱ� ���� �κ�
    Sumof_CO2 := Sumof_CO2 + StrToFloat(Data.CO2);
    Sumof_CO_L := Sumof_CO_L + StrToFloat(Data.CO_L);
    Sumof_O2 := Sumof_O2 + StrToFloat(Data.O2);
    Sumof_NOx := Sumof_NOx + StrToFloat(Data.NOx);
    Sumof_THC := Sumof_THC + StrToFloat(Data.THC);
    Sumof_CH4 := Sumof_CH4 + StrToFloat(Data.CH4);
    Sumof_non_CH4 := Sumof_non_CH4 + StrToFloat(Data.non_CH4);
    Sumof_Collected := Sumof_Collected + Data.CollectedValue;
    TotalDataNo := TotalDataNo+1;

  end;
  if CB_DBlogging.Checked then
  begin
    if not Assigned(FDataSave2DBThread) then
    begin
      DisplayMessage('DataBase is not connected', dtSendMemo);
      exit;
    end;

    {if FDataSave2DBThread.ZConnection1.Connected then
    begin
      FSaveDataBuf_CO2 := StrToFloat(Data.CO2);
      FSaveDataBuf_CO_L := StrToFloat(Data.CO_L);
      FSaveDataBuf_O2 := StrToFloat(Data.O2);
      FSaveDataBuf_NOX := StrToFloat(Data.NOX);
      FSaveDataBuf_THC := StrToFloat(Data.THC);
      FSaveDataBuf_CH4 := StrToFloat(Data.CH4);
      FSaveDataBuf_non_CH4 := StrToFloat(Data.non_CH4);
      FSaveDataBuf_Collected := Data.Collectedvalue;
      SaveData2DB;
    end
    else if not FDataSave2DBThread.ZConnection1.Connected then
    begin
      DisplayMessage('Server Disconnected! Please Connect Again', dtSendMemo);
    end;  }
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//DB ���� ������ ���� �Լ�
procedure TDataSaveMain.CreateSave2DBThread;
begin
{  if not Assigned(FDataSave2DBThread) then
  begin
    FDataSave2DBThread := TDataSave2DBThread.Create(Self);
    with FDataSave2DBThread do
    begin
      FHostName := Self.FHostName;
      FDBName := Self.FDBName;
      FLoginID := Self.FLoginID;
      FPasswd := Self.FPasswd;
      if FDataSave2DBThread.ZConnection1.Connected then
      begin
//      ALed1.Value := True;
//      CreateDBParam(INSERT_FILE_NAME,'pps_monitor');
        DisplayMessage ('Server Connected', dtSendMemo);
        Resume;
      end
      else
//        ALed1.Value := False;
    end;//with
  end//if
  else if not FDataSave2DBThread.ZConnection1.Connected then
  begin
    FDataSave2DBThread.ZConnection1.Connected := True;
    if FDataSave2DBThread.ZConnection1.Connected then
      DisplayMessage ('Server Re-Connected', dtSendMemo);
  end; }
end;
//DB ���� ������ ��� �Լ�
procedure TDataSaveMain.SaveData2DB;
begin
  with FDataSave2DBThread do
  begin
    FStrData_CO2 := FSaveDataBuf_CO2;
    FStrData_CO_L := FSaveDataBuf_CO_L;
    FStrData_O2 := FSaveDataBuf_O2;
    FStrData_NOX := FSaveDataBuf_NOX;
    FStrData_THC := FSaveDataBuf_THC;
    FStrData_CH4 := FSaveDataBuf_CH4;
    FStrData_non_CH4 := FSaveDataBuf_non_CH4;
    FStrData_Collected := FSaveDataBuf_Collected;

    if not FSaving then
      FDataSaveEvent.Pulse;
  end;//with
end;
//DB ���� ������ ���� �Լ�
procedure TDataSaveMain.DestroySave2DBThread;
begin
  if Assigned(FDataSave2DBThread) then
  begin
    FDataSave2DBThread.Terminate;
    FDataSave2DBThread.FDataSaveEvent.Pulse;
    FDataSave2DBThread.Free;
    FDataSave2DBThread := nil;
  end;//if

end;

////////////////////////////////////////////////////////////////////////////////
//CSV ���� ���� ������  ���� �Լ�
procedure TDataSaveMain.CreateSave2FileThread;
begin
  if not Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread := TDataSave2FileThread.Create(Self);
    FDataSave2FileThread.Resume;
  end;
end;
//CSV ���� ���� ��� �Լ�
procedure TDataSaveMain.SaveData2File;
begin
  with FDataSave2FileThread do
  begin
    FStrData := FSaveDataBuf; //������ ������(FSaveDataBuf)�� ����(FStrData)�� �Է�
    FTagData := FTagNameBuf;  //���ʿ� �������� ���� �� ���(�Ӹ���) �Է�
    FName_Convention := FFileName_Convention; //���ϸ��� �������ִ� �������
    FFileName := FSaveFileName; //���ϸ� ���� (FName_Convention�� FC_Fixed������ ���)
    if not FSaving then
      DisplayMessage(TimeToStr(Time)+' Processing DataSave to CSV file', dtSendMemo);
    FDataSaveEvent.Pulse;
  end;//with
end;
//CSV ���� ���� ������ ���� �Լ�
procedure TDataSaveMain.DestroySave2FileThread;
begin
  if Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread.Terminate;
    FDataSave2FileThread.FDataSaveEvent.Pulse;
    FDataSave2FileThread.Free;
    FDataSave2FileThread := nil;
  end;//if
end;

//CSV ���� ��հ�� �Լ�
procedure TDataSaveMain.SaveDataAverage2File;
begin
  if TotalDataNo = 0 then
  begin
    FSaveDataBuf :=#13#10+'Average'+',0,0,0,0,0,0,0,0'+#13#10+#13#10+#13#10;
  end
  else
  begin
    FSaveDataBuf :=#13#10+'Average'
    +','+FloatToStr(Sumof_CO2/TotalDataNo)
    +','+FloatToStr(Sumof_CO_L/TotalDataNo)
    +','+FloatToStr(Sumof_O2/TotalDataNo)
    +','+FloatToStr(Sumof_NOx/TotalDataNo)
    +','+FloatToStr(Sumof_THC/TotalDataNo)
    +','+FloatToStr(Sumof_CH4/TotalDataNo)
    +','+FloatToStr(Sumof_non_CH4/TotalDataNo)
    +','+FloatToStr(Sumof_Collected/TotalDataNo)
    +#13#10+#13#10+#13#10;
  end;
  SaveData2File;

  //�������� �ջ��� �ʱ�ȭ �ϱ� ���� �κ�
  Sumof_CO2 := 0.0;
  Sumof_CO_L := 0.0;
  Sumof_O2 := 0.0;
  Sumof_NOx := 0.0;
  Sumof_THC := 0.0;
  Sumof_CH4 := 0.0;
  Sumof_non_CH4 := 0.0;
  Sumof_Collected := 0.0;
  TotalDataNo := 0;
end;

////////////////////////////////////////////////////////////////////////////////
//�޽����� ȭ�鿡 ǥ���ϴ� �Լ� ////////////////////////////////////////////////
procedure TDataSaveMain.DisplayMessage(msg: string; ADspNo: TDisplayTarget);
begin
  case ADspNo of
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
       StatusBar1.SimplePanel := True;
       StatusBar1.SimpleText := msg;
    end;//dtStatusBar
  end;//case
end;

//ini ���Ͽ� �ִ� Host IP, Port�� Form�� ǥ���ϴ� �Լ� /////////////////////////
procedure TDataSaveMain.LoadConfigDataini2Form(FSaveConfigF: TSaveConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile, FSaveConfigF do
    begin
      Ed_sharedmemory.Text := ReadString(DATASAVE_SECTION, 'IPCCLIENTNAME1', 'Horiba_MEXA_7000_Client');
      Ed_hostname.Text := ReadString(DATASAVE_SECTION, 'SAVEDATA_HOSTNAME', '10.100.23.114');
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//ini���Ϸ� Host�� Port, IP �ּҸ� �����ϴ� �Լ� ///////////////////////////////
procedure TDataSaveMain.SaveConfigDataForm2ini(FSaveConfigF: TSaveConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  DisplayMessage(#13#10+'System configuration changed'+#13#10+'Please restart program...' , dtSendMemo);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile, FSaveConfigF do
    begin
      WriteString(DATASAVE_SECTION, 'IPCCLIENTNAME1', Ed_sharedmemory.Text);
      WriteString(DATASAVE_SECTION, 'SAVEDATA_HOSTNAME', Ed_hostname.Text);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//ini ���Ͽ��� �ʱ�ȭ������ �о� ���α׷����� ����ϴ� ������ �����ϴ� �Լ�/////
procedure TDataSaveMain.LoadConfigDataini2Var;
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile do
    begin
      //DB �������� �ʱ�ȭ ����
      FSharedMMName := ReadString(DATASAVE_SECTION, 'IPCCLIENTNAME1', 'Horiba_MEXA_7000_Client');
      FHostName := ReadString(DATASAVE_SECTION, 'SAVEDATA_HOSTNAME', 'Horiba_MEXA_7000_Client');
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

end.
