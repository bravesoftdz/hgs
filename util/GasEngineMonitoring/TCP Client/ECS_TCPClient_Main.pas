unit ECS_TCPClient_Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, StdCtrls,
  IPCThrd_ECS_avat, IPCThrdClient_ECS_avat, TCPConfig, ExtCtrls, inifiles, Menus,
  DataSave2FileThread, DataSaveConst, ComCtrls, ECS_avat_TCPUtil, JvDialogs;

const
  INIFILENAME = '.\TCPClient_Avat';
  TCPCLIENT_SECTION = 'TCP Client Avat';

type

  TClientFrmMain = class(TForm)
    IncomingMessages: TMemo;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    N5: TMenuItem;
    MenuItem4: TMenuItem;
    IdTCPClient1: TIdTCPClient;
    SimulateCommunication1: TMenuItem;
    N6: TMenuItem;
    JvOpenDialog1: TJvOpenDialog;
    SimulateCommunicationwithstep1: TMenuItem;
    Panel1: TPanel;
    CBClientActive: TCheckBox;
    Label5: TLabel;
    Label7: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Button1: TButton;
    Button3: TButton;
    Button2: TButton;
    Splitter1: TSplitter;
    Label1: TLabel;
    Label2: TLabel;

    procedure CBClientActiveClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure SimulateCommunication1Click(Sender: TObject);
    procedure SimulateCommunicationwithstep1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

  private
    FSaveFileName: string; //����Ÿ�� ������ File �̸�(������ ���� �����)
    FTagNameBuf: string;  //���Ͽ� ������ �����ϱ� ���� ����
    FDataSaveStart: Boolean; //������ �ð��� ��� �Ǿ����� True(Save������)
    FSaveDataBuf: string; //���Ͽ� ������ ����Ÿ�� �����ϴ� ����
    FLogStart: Boolean;  //Log save Start sig.
    FDataSave2FileThread: TDataSave2FileThread;//���Ͽ� ����Ÿ �����ϴ� ��ü
    FFileName_Convention: TFileName_Convetion;//���Ͽ� ����ÿ� �����̸��ο� ���
    FECSData: TEventData_ECS_avat;//RTU simulate�� ���Ǵ� Buffer
    FECSDataList: TStringList;//RTU simulate�� ���Ǵ� List
    FBufferIndex: integer;

    procedure LoadDataFromFile(AFileName: string);
    function PrepareSimulate(AFileName: string): Boolean;
    procedure ProcessSimulateOneStep;

    procedure LoadConfigDataini2Form(ConfigForm:TTCPConfigF);
    procedure LoadConfigDataini2Var;
    procedure SaveConfigDataForm2ini(ConfigForm:TTCPConfigF);
    procedure AdjustConfigData;

  public
    FIPCClient: TIPCClient_ECS_avat;//���� �޸� �� �̺�Ʈ ��ü
    FPortNum: integer;
    FLocalIP: string;
    FHostIP: string;
    FFilePath: string;      //������ ������ ���
    FSharedMMName: string;  //���� �޸� �̸�
    FSimStep: integer;
    FFirstTime: boolean;
    FRecvString: string;
    procedure DisplayMessage(msg: string);
  end;

  TClientHandleThread = class(TThread)
  private
    CB: TCommBlock;
    FData: TEventData_ECS_avat;
    FStream: TMemoryStream;
    FDataSave2FileThread: TDataSave2FileThread;//���Ͽ� ����Ÿ �����ϴ� ��ü
    procedure HandleInput;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TForm);
    destructor Destroy();override;
  end;

var
  ClientFrmMain: TClientFrmMain;
  ClientHandleThread: TClientHandleThread;   // variable (type see above)

implementation

uses CommonUtil;

{$R *.DFM}

procedure TClientFrmMain.FormCreate(Sender: TObject);
begin
  FFirstTime := True;
  FECSDataList := TStringList.Create;
end;

procedure TClientFrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FECSDataList);

  if Assigned(ClientHandleThread) then
    ClientHandleThread.Terminate;
  IdTCPClient1.Disconnect;
  FreeAndNil(FIPCClient);
//  DestroySave2FileThread;
end;

////////////////////////////////////////////////////////////////////////////////
//���α׷� �ʱ�ȭ �Լ�
procedure TClientFrmMain.Timer1Timer(Sender: TObject);
begin
  try
    if FFirstTime then
    begin
      FFirstTime := False;
      FFilePath := ExtractFilePath(Application.ExeName); //�ǳ��� '\' ���Ե�
      LoadConfigDataini2Var;
      AdjustConfigData;
      //IPC �Լ� �ʱ�ȭ ����////////////////////////////////////////////////////
      FIPCClient := TIPCClient_ECS_avat.Create(0, FSharedMMName, True);
      //////////////////////////////////////////////////////////////////////////
      Label7.Caption := FLocalIP;
      Caption := DeviceName + ' ==> ' + FSharedMMName;
    end;

    if SimulateCommunicationwithstep1.Checked then
    begin
      ProcessSimulateOneStep;
    end
    else
      Timer1.Enabled := False;
  finally
   //Timer1.Enabled := True;
  end;
end;

procedure TClientFrmMain.TrayIcon1DblClick(Sender: TObject);
begin
  application.Restore;
  ShowWindow(Application.Handle, SW_HIDE);
  Show;
end;

////////////////////////////////////////////////////////////////////////////////
//ini ���Ͽ��� �ʱ�ȭ������ �о� ���α׷����� ����ϴ� ������ �����ϴ� �Լ�
procedure TClientFrmMain.LoadConfigDataini2Var;
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile do
    begin
      //CreateSave2FileThread;  //CSV ���Ϸ� �����ϴ� Thread create ���
      //FFileName_Convention := TFileName_Convetion(ReadInteger(TCPCLIENT_SECTION, 'File Name Type', 0));
      //FSaveFileName := ReadString(TCPCLIENT_SECTION, 'File Name', 'abc');
      FLocalIP := ReadString(TCPCLIENT_SECTION, 'Local IP', '10.14.16.80');
      FPortNum := StrToInt(ReadString(TCPCLIENT_SECTION, 'Port', '47110'));
      FHostIP := ReadString(TCPCLIENT_SECTION, 'Host IP', '10.14.23.40');
      FSharedMMName := ReadString(TCPCLIENT_SECTION, 'Shared Memory Name', '192.168.0.40');
      FSimStep := ReadInteger(TCPCLIENT_SECTION, 'Simulate Step', 1000);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TClientFrmMain.LoadDataFromFile(AFileName: string);
var
  LStr: TStringList;
  LStr2,LStr3,LStr4: string;
  i,j,k,LColumnCount: integer;
  tmpdouble2, tmpdouble: double;
begin
  LStr:= TStringList.Create;
  try
    LStr.LoadFromFile(AFileName,TEncoding.UTF8);

    if LStr.Count = 0 then //�������� ��� �ٽ� �о� ����
    begin
      LStr.LoadFromFile(AFileName);
    end;

    if LStr.Count > 0 then
    begin
      LStr2 := LStr.Strings[0]; //Head Read
      GetTokenWithComma(LStr2); //�ð��� ���� �о ����

      LColumnCount := strTokenCount(LStr.Strings[0], ',');

      for i := 1 to LStr.Count - 1 do
      begin
        LStr2 := LStr.Strings[i];
        LStr3 := GetTokenWithComma(LStr2);
        tmpdouble2 := StrToDateTime(LStr3);
        FillChar(FECSData.InpDataBuf_double[0], High(FECSData.InpDataBuf_double) - 1, #0);
        FECSData.ModBusFunctionCode := 4;
        FECSData.ModBusMode := 3;
        FECSData.NumOfData := LColumnCount - 2;

        for j := 0 to LColumnCount - 2 do
        begin
          LStr3 := GetTokenWithComma(LStr2);
          if LStr3 = 'FALSE' then
            tmpdouble := 0.0
          else if LStr3 = 'TRUE' then
            tmpdouble := $FFFF
          else
            tmpdouble := StrToFloatDef(LStr3,0.0);

          FECSData.InpDataBuf_double[j] := tmpdouble;
        end;//for

        FIPCClient.PulseMonitor(FECSData);
      end;//for
    end;
  finally
    FreeAndNil(LStr);
  end;
end;

procedure TClientFrmMain.MenuItem1Click(Sender: TObject);
begin
  application.Restore;
  ShowWindow(Application.Handle, SW_HIDE);
  Show;
end;

procedure TClientFrmMain.MenuItem4Click(Sender: TObject);
begin
  Close;
end;

//ini���Ϸ� Host�� Port, IP �ּҸ� �����ϴ� �Լ�
procedure TClientFrmMain.SaveConfigDataForm2ini(ConfigForm: TTCPConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile, ConfigForm do
    begin
      WriteString(TCPCLIENT_SECTION, 'Local IP', HostIPCB.Text);
      WriteString(TCPCLIENT_SECTION, 'Port', PortEdit.Text);
      WriteString(TCPCLIENT_SECTION, 'Host IP', HostIPEdit.Text);
      WriteString(TCPCLIENT_SECTION, 'Shared Memory Name', SharedMMNameEdit.Text);
      WriteString(TCPCLIENT_SECTION, 'Simulate Step', SimStepEdit.Text);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TClientFrmMain.SimulateCommunication1Click(Sender: TObject);
var
  LFileName: string;
  i: integer;
  LIsFirst: Boolean;
begin
  SimulateCommunication1.Checked := not SimulateCommunication1.Checked;

  if SimulateCommunication1.Checked then
  begin
    CBClientActive.Checked := False;
    CBClientActiveClick(nil); //TCP Disconnect

    JvOpenDialog1.Options := JvOpenDialog1.Options + [ofAllowMultiSelect];
    JvOpenDialog1.InitialDir := FFilePath;
    if JvOpenDialog1.Execute then
    begin
      for i := 0 to JvOpenDialog1.Files.Count - 1 do
      begin
        LIsFirst := i = 0;
        LFileName := JvOpenDialog1.Files[i];

        LoadDataFromFile(LFileName);
      end;
    end
    else
      SimulateCommunication1.Checked := not SimulateCommunication1.Checked;

  end;
end;

//�������� ��� Simulation file�� ������ �ݵ�� �ּ��� ������ ���� �Ǿ� �־�� ��.
procedure TClientFrmMain.SimulateCommunicationwithstep1Click(Sender: TObject);
var
  LFileName: string;
  i: integer;
  LIsFirst: Boolean;
begin
  SimulateCommunicationwithstep1.Checked := not SimulateCommunicationwithstep1.Checked;
  Button2.Enabled := SimulateCommunicationwithstep1.Checked;

  if SimulateCommunicationwithstep1.Checked then
  begin
    CBClientActive.Checked := False;
    CBClientActiveClick(nil); //TCP Disconnect
    FBufferIndex := 0;

    JvOpenDialog1.Options := JvOpenDialog1.Options + [ofAllowMultiSelect];
    JvOpenDialog1.InitialDir := FFilePath;
    JvOpenDialog1.Filter := '*.csv||*.*';
    if JvOpenDialog1.Execute then
    begin
      for i := 0 to JvOpenDialog1.Files.Count - 1 do
      begin
        LIsFirst := i = 0;
        LFileName := JvOpenDialog1.Files[i];

        if PrepareSimulate(LFileName) then
        begin
          Timer1.Interval := FSimStep;
          Timer1.Enabled := True;
        end
        else
        begin
          ShowMessage('Simulation Fail!');
          SimulateCommunicationwithstep1.Checked := not SimulateCommunicationwithstep1.Checked;
        end;
      end;
    end
    else
      SimulateCommunicationwithstep1.Checked := not SimulateCommunicationwithstep1.Checked;
  end;
end;

//Client �����忡 Host�� IP �ּҿ� Port�� ������ �ִ� �Լ�
procedure TClientFrmMain.AdjustConfigData;
begin
  if IdTCPClient1.Connected then
  begin
    ShowMessage('Server�� ������ �� ȯ�漳����...');
    exit;
  end
  else
  begin
    IdTCPClient1.BoundIP := FLocalIP;
    IdTCPClient1.Port := FPortNum;
    IdTCPClient1.Host := FHostIP;
    Label7.Caption := FLocalIP;
    Label8.Caption := FHostIP;
    Label10.Caption := IntToStr(FPortNum);
    Timer1.Interval := FSimStep;

    if Assigned(FIPCClient) then
    begin
      FreeAndNil(FIPCClient);
      FIPCClient := TIPCClient_ECS_avat.Create(0, FSharedMMName, True);
    end;

  end;
end;

////////////////////////////////////////////////////////////////////////////////
//Acive ��ư Ŭ�� �� ���� �Լ�
procedure TClientFrmMain.Button1Click(Sender: TObject);
begin
  Hide;
end;

procedure TClientFrmMain.Button2Click(Sender: TObject);
begin
  Timer1.Enabled := not Timer1.Enabled;
  Button3.Enabled := not Timer1.Enabled;

  if Timer1.Enabled then
  begin
    Button2.Caption := 'Pause';
  end
  else
  begin
    Button2.Caption := 'Start';
  end;
end;

procedure TClientFrmMain.Button3Click(Sender: TObject);
begin
  ProcessSimulateOneStep;
end;

procedure TClientFrmMain.CBClientActiveClick(Sender: TObject);
begin
  if CBClientActive.Checked then
  begin
    try
      //Client�� ��ſ����ϴ� �Լ� (Thread ����)
      IdTCPClient1.Connect();  // in Indy < 8.1 leave the parameter away
      ClientHandleThread := TClientHandleThread.Create(Self);
      ClientHandleThread.FreeOnTerminate:=True;
      ClientHandleThread.Resume;

    except
      on E: Exception do MessageDlg ('Error while connecting:'+#13+E.Message,
                                      mtError, [mbOk], 0);
    end;
  end
  else
  begin
    if Assigned(ClientHandleThread) then
      ClientHandleThread.Terminate;
    IdTCPClient1.Disconnect;
  end;

//  ButtonSend.Enabled := Client.Connected;
  CBClientActive.Checked := IdTCPClient1.Connected;
end;

//������ execute �Լ� (ReadBuffer �������)
constructor TClientHandleThread.Create(AOwner: TForm);
begin
  inherited Create(true);

  FStream := TMemoryStream.Create;
end;

destructor TClientHandleThread.Destroy;
begin
  FreeAndNil(FStream);
  inherited Destroy();
end;

procedure TClientHandleThread.Execute;
var
  tmpStr: String;
begin
  while not Terminated do
  begin
    if not ClientFrmMain.IdTCPClient1.Connected then
      Terminate
    else
    begin
      try
        tmpStr := '';
        FStream.Position := 0;
        ClientFrmMain.IdTCPClient1.IOHandler.ReadStream(FStream, SizeOf(FData));

        if FStream.Size > 0 then
        begin
          FData := ReadEventDataFromStream(FStream);
          ClientFrmMain.FIPCClient.PulseMonitor(FData);
          Synchronize(HandleInput);
        end;
      finally
      end;
    end;
  end;
end;

//������� ���� ������ ó���ϴ� ������(HandleInput) �Լ�
procedure TClientHandleThread.HandleInput;
begin
  ClientFrmMain.DisplayMessage(TimeToStr(Time) + ': Receive Data');
  ClientFrmMain.DisplayMessage(#13#10+IntToStr(FData.NumOfData));
  ClientFrmMain.FIPCClient.PulseMonitor(FData); //�����޸𸮿� ������(FData)�� �����ϴ� ����
end;

////////////////////////////////////////////////////////////////////////////////
//����â�� �����ִ� ��ư Ŭ���� �����ϴ� �Լ�
procedure TClientFrmMain.N2Click(Sender: TObject);
var
  TCPConfigF: TTCPConfigF;
begin
  TCPConfigF := TTCPConfigF.Create(Application);

  with TCPConfigF do
  begin
    try
      Label1.Visible := True;
      HostIPEdit.Visible := True;

      LoadConfigDataini2Form(TCPConfigF);

      if ShowModal = mrOK then
      begin
        SaveConfigDataForm2ini(TCPConfigF);
        LoadConfigDataini2Var;
        AdjustConfigData;
      end;
    finally
      Free;
    end;
  end;
end;

//ini ���Ͽ� �ִ� Host IP, Port�� Form�� ǥ���ϴ� �Լ� /////////////////////////
procedure TClientFrmMain.LoadConfigDataini2Form(ConfigForm: TTCPConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile, ConfigForm do
    begin
      PortEdit.Text := ReadString(TCPCLIENT_SECTION, 'Port', '47113');
      HostIPEdit.Text := ReadString(TCPCLIENT_SECTION, 'Host IP', '10.14.16.80');
      HostIpCB.Text := ReadString(TCPCLIENT_SECTION, 'Local IP', '10.14.16.80');
      SharedMMNameEdit.Text := ReadString(TCPCLIENT_SECTION, 'Shared Memory Name', 'ModBusCom_'+DeviceName);
      SimStepEdit.Text := ReadString(TCPCLIENT_SECTION, 'Simulate Step', '1000');
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//�޽����� ȭ�鿡 ǥ���ϴ� �Լ� ////////////////////////////////////////////////
procedure TClientFrmMain.DisplayMessage(msg: string);
begin
  with IncomingMessages do
  begin
    if Lines.Count > 100 then
      Clear;

    Lines.Add(msg);
  end;//with
end;

//���α׷� ���� ��ư////////////////////////////////////////////////////////////
procedure TClientFrmMain.N4Click(Sender: TObject);
begin
  Close;
end;

function TClientFrmMain.PrepareSimulate(AFileName: string): Boolean;
var
  LColumnCount,i: integer;
  LStr2: string;
begin
  Result := False;

  FECSDataList.Clear;

  try
    FECSDataList.LoadFromFile(AFileName,TEncoding.UTF8);

    if FECSDataList.Count = 0 then //�������� ��� �ٽ� �о� ����
    begin
      FECSDataList.LoadFromFile(AFileName);
    end;

    if FECSDataList.Count > 0 then
    begin
      i := 0;
      while FECSDataList.Strings[i] = '' do
        inc(i);

      LStr2 := FECSDataList.Strings[i]; //Head Read
      GetTokenWithComma(LStr2); //�ð��� ���� �о ����

      LColumnCount := strTokenCount(FECSDataList.Strings[i], ',');
      FECSData.ModBusFunctionCode := 4;
      FECSData.ModBusMode := 3;
      FECSData.NumOfData := LColumnCount - 2;
      Label2.Caption := IntToStr(FECSDataList.Count);
      Result := True;
    end;
  finally

  end;
end;

procedure TClientFrmMain.ProcessSimulateOneStep;
var
  i: integer;
  LStr2,LStr3: string;
  tmpdouble,tmpdouble2: double;
begin
  inc(FBufferIndex); //1 ���� �����ؾ� ��.(����� �ǳʶٱ� ����)
  if FBufferIndex >= FECSDataList.Count then
  begin
    SimulateCommunicationwithstep1.Checked := False;
    DisplayMessage(DateTimeToStr(now) + '>>> Finished: '+IntToStr(FBufferIndex));

    exit;
  end;

  LStr2 := FECSDataList.Strings[FBufferIndex];
  LStr3 := GetTokenWithComma(LStr2);
  tmpdouble2 := StrToDateTime(LStr3);
  FillChar(FECSData.InpDataBuf_double[0], High(FECSData.InpDataBuf_double) - 1, #0);

  for i := 0 to FECSData.NumOfData do
  begin
    LStr3 := GetTokenWithComma(LStr2);
    if LStr3 = 'FALSE' then
      tmpdouble := 0.0
    else if LStr3 = 'TRUE' then
      tmpdouble := $FFFF
    else
      tmpdouble := StrToFloatDef(LStr3,0.0);

    FECSData.InpDataBuf_double[i] := tmpdouble;
  end;

  FIPCClient.PulseMonitor(FECSData);
  LStr2 := DateTimeToStr(now) + '>>> Pulse Data Count: ';
  LStr2 := LStr2 + IntToStr(FECSData.NumOfData) + ',,, Buffer Index: ';
  LStr2 := LStr2 + IntToStr(FBufferIndex);
  DisplayMessage(LStr2);
end;

end.
