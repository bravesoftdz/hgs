unit MEXA7000_TCPClient_Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, StdCtrls,
  IPCThrd2, IPCThrdClient2, TCPConfig, ExtCtrls, inifiles, Menus,
  MEXA7000_TCPUtil, DataSave2FileThread, DataSaveConst, ComCtrls, CoolTrayIcon;

const
  INIFILENAME = '.\TCPClient';
  TCPCLIENT_SECTION = 'TCP Client';

type

  TClientFrmMain = class(TForm)
    CBClientActive: TCheckBox;
    IncomingMessages: TMemo;
    Label1: TLabel;
    Client: TIdTCPClient;
    Timer1: TTimer;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    StatusBar1: TStatusBar;
    TrayIcon1: TCoolTrayIcon;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    N5: TMenuItem;
    MenuItem4: TMenuItem;
    Button1: TButton;

    procedure CBClientActiveClick(Sender: TObject);
    procedure ButtonSendClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);

  private
    FSaveFileName: string; //����Ÿ�� ������ File �̸�(������ ���� �����)
    FTagNameBuf: string;  //���Ͽ� ������ �����ϱ� ���� ����
    FDataSaveStart: Boolean; //������ �ð��� ��� �Ǿ����� True(Save������)
    FSaveDataBuf: string; //���Ͽ� ������ ����Ÿ�� �����ϴ� ����
    FLogStart: Boolean;  //Log save Start sig.
    FDataSave2FileThread: TDataSave2FileThread;//���Ͽ� ����Ÿ �����ϴ� ��ü
    FFileName_Convention: TFileName_Convetion;//���Ͽ� ����ÿ� �����̸��ο� ���

    procedure LoadConfigDataini2Form(ConfigForm:TTCPConfigF);
    procedure LoadConfigDataini2Var;
    procedure SaveConfigDataForm2ini(ConfigForm:TTCPConfigF);
    procedure AdjustConfigData;

  public
    FIPCClient: TIPCClient2;//���� �޸� �� �̺�Ʈ ��ü
    FPortNum: integer;
    FHostIP: string;
    FFilePath: string;      //������ ������ ���
    FSharedMMName: string;  //���� �޸� �̸�
    FFirstTime: boolean;
    FRecvString: string;
    procedure CreateSave2FileThread;
    procedure DestroySave2FileThread;
    procedure SaveData(BlockNo: integer);
    procedure SaveData2File;
    procedure DisplayMessage(msg: string);
  end;

  TClientHandleThread = class(TThread)
  private
    CB: TCommBlock;
    FData: TEventData2;
    FDataSave2FileThread: TDataSave2FileThread;//���Ͽ� ����Ÿ �����ϴ� ��ü
    procedure HandleInput;
  protected
    procedure Execute; override;
  end;

var
  ClientFrmMain: TClientFrmMain;
  ClientHandleThread: TClientHandleThread;   // variable (type see above)

implementation

{$R *.DFM}

procedure TClientFrmMain.FormCreate(Sender: TObject);
begin
  FFirstTime := True;
end;

procedure TClientFrmMain.FormDestroy(Sender: TObject);
begin
  if Assigned(ClientHandleThread) then
    ClientHandleThread.Terminate;
  Client.Disconnect;

  FreeAndNil(FIPCClient);
  DestroySave2FileThread;
end;

////////////////////////////////////////////////////////////////////////////////
//���α׷� �ʱ�ȭ �Լ�//////////////////////////////////////////////////////////
procedure TClientFrmMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  try
    if FFirstTime then
    begin
      FFirstTime := False;
      FFilePath := ExtractFilePath(Application.ExeName); //�ǳ��� '\' ���Ե�
      LoadConfigDataini2Var;
      AdjustConfigData;
      //IPC �Լ� �ʱ�ȭ ����////////////////////////////////////////////////////
      FIPCClient := TIPCClient2.Create(0, FSharedMMName, True);
      //////////////////////////////////////////////////////////////////////////
      Label7.Caption := GetLocalIP;
      Caption := FHostIP + ' ==> ' + FSharedMMName;
      //DisplayMessage('Receive Data : ' + IntToStr(SizeOf(ClientHandleThread.FData)));
    end
    else
    begin
    end;
  finally
   Timer1.Enabled := True;
  end;
end;

procedure TClientFrmMain.TrayIcon1DblClick(Sender: TObject);
begin
  application.Restore;
  ShowWindow(Application.Handle, SW_HIDE);
  Show;

end;

//ini ���Ͽ��� �ʱ�ȭ������ �о� ���α׷����� ����ϴ� ������ �����ϴ� �Լ�/////
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
      //CSV ���Ϸ� ������ �� ���ϸ��� �����ϴ� ��� ����
      FFileName_Convention := TFileName_Convetion(ReadInteger(TCPCLIENT_SECTION, 'File Name Type', 0));
      //���ϸ����(�ǹ� ���� �� ����->Ȯ���ʿ�)
      FSaveFileName := ReadString(TCPCLIENT_SECTION, 'File Name', 'abc');
      FPortNum := StrToInt(ReadString(TCPCLIENT_SECTION, 'Port', '47110'));
      FHostIP := ReadString(TCPCLIENT_SECTION, 'Host IP', '10.14.23.40');
      FSharedMMName := ReadString(TCPCLIENT_SECTION, 'Shared Memory Name', DeviceName);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
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

//ini���Ϸ� Host�� Port, IP �ּҸ� �����ϴ� �Լ� ///////////////////////////////
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
      WriteString(TCPCLIENT_SECTION, 'Port', PortEdit.Text);
      WriteString(TCPCLIENT_SECTION, 'Host IP', HostIPEdit.Text);
      WriteString(TCPCLIENT_SECTION, 'Shared Memory Name', SharedMMNameEdit.Text);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;
//Client �����忡 Host�� IP �ּҿ� Port�� ������ �ִ� �Լ�//////////////////////
procedure TClientFrmMain.AdjustConfigData;
begin
  if Client.Connected then
  begin
    ShowMessage('Server�� ������ �� ȯ�漳����...');
    exit;
  end
  else
  begin
    Client.Port := FPortNum;
    Client.Host := FHostIP;
    Label8.Caption := FHostIP;
    Label10.Caption := IntToStr(FPortNum);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//Acive ��ư Ŭ�� �� ���� �Լ�//////////////////////////////////////////////////
procedure TClientFrmMain.CBClientActiveClick(Sender: TObject);
begin
  if CBClientActive.Checked then
  begin
    try
{      FLogStart := True;
      FSaveDataBuf :=#13#10+'START DATA LOGGING'+#13#10+'Time,CO2,CO_L,O2,NOx,THC,CH4,non_CH4';
      SaveData2File;
}
      //Client�� ��ſ����ϴ� �Լ� (Thread ����)
      Client.Connect();  // in Indy < 8.1 leave the parameter away
      ClientHandleThread := TClientHandleThread.Create(True);
      ClientHandleThread.FreeOnTerminate:=True;
      ClientHandleThread.Resume;

    except
      on E: Exception do MessageDlg ('Error while connecting:'+#13+E.Message,
                                      mtError, [mbOk], 0);
    end;
  end
  else
  begin
    ClientHandleThread.Terminate;
    Client.Disconnect;
  end;

//  ButtonSend.Enabled := Client.Connected;
  CBClientActive.Checked := Client.Connected;
end;
//������ execute(ReadBuffer �������)///////////////////////////////////////////
procedure TClientHandleThread.Execute;
var tmpStr: String;
begin
  while not Terminated do
  begin
    if not ClientFrmMain.Client.Connected then
      Terminate
    else
    try
      tmpStr := '';

      ClientFrmMain.Client.ReadBuffer(FData, SizeOf(FData));
      Synchronize(HandleInput);
    except
    end;
  end;
end;

//������� ���� ������ ó���ϴ� ������ /////////////////////////////////////////
procedure TClientHandleThread.HandleInput;
begin
  ClientFrmMain.DisplayMessage(TimeToStr(Time) + ': Receive Data');
{  ClientFrmMain.DisplayMessage(': CO2 ' + FData.CO2 +': CO_L');
  ClientFrmMain.FLogStart := True;
  ClientFrmMain.FSaveDataBuf :=TimeToStr(Time)+','+FData.CO2+','+FData.CO_L+','+FData.O2+','+FData.NOx+','+FData.THC+','+FData.CH4+','+FData.non_CH4;
  ClientFrmMain.SaveData2File;}
  //�����޸𸮿� ������(FData)�� �����ϴ� ����//////////////////////////////////
  ClientFrmMain.FIPCClient.PulseMonitor(FData);
  //////////////////////////////////////////////////////////////////////////////
{
  if CB.Command = 'MESSAGE' then
    ClientFrmMain.DisplayMessage (CB.MyUserName + ': ' + CB.Msg)
  else
  if CB.Command = 'DIALOG' then
    MessageDlg ('"'+CB.MyUserName+'" sends you this message:'+#13+CB.Msg, mtInformation, [mbOk], 0)
  else ; // unknown command
}
end;




////////////////////////////////////////////////////////////////////////////////
//CSV ���� ���� ��� �Լ� //////////////////////////////////////////////////////
procedure TClientFrmMain.SaveData2File;
begin
  with FDataSave2FileThread do
  begin
    FStrData := FSaveDataBuf; //������ ������(FSaveDataBuf)�� ����(FStrData)�� �Է�
    FTagData := FTagNameBuf;  //���ʿ� �������� ���� �� ���(�Ӹ���) �Է�
    FName_Convention := FFileName_Convention; //���ϸ��� �������ִ� �������
    FFileName := FSaveFileName; //�Ⱦ��� �����
    if not FSaving then
      FDataSaveEvent.Signal;
  end;//with
end;
//CSV ���� ���� ������ ���� �Լ�////////////////////////////////////////////////
procedure TClientFrmMain.CreateSave2FileThread;
begin
  if not Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread := TDataSave2FileThread.Create(Self);
    FDataSave2FileThread.Resume;
  end;
end;
//CSV ���� ���� ������ ���� �Լ�////////////////////////////////////////////////
procedure TClientFrmMain.DestroySave2FileThread;
begin
  if Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread.Terminate;
    FDataSave2FileThread.FDataSaveEvent.Signal;
    FDataSave2FileThread.Free;
    FDataSave2FileThread := nil;
  end;//if
end;

//������ ����� 'Ÿ�̸�' ��� �Լ�///////////////////////////////////////////////
procedure TClientFrmMain.SaveData(BlockNo: integer);
begin
{  if (FLogStart = True) then
  begin
    WMSaveData(BlockNo);
    if (FLogStartTime + StrToTime(ed_LogHour.Text + ':' + ed_LogMin.Text + ':' + ed_LogSec.Text))< Time then
      Button3Click(Self);
  end;}
end;





////////////////////////////////////////////////////////////////////////////////
//����â�� �����ִ� ��ư Ŭ���� �����ϴ� �Լ�///////////////////////////////////
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
      PortEdit.Text := ReadString(TCPCLIENT_SECTION, 'Port', '47110');
      HostIPEdit.Text := ReadString(TCPCLIENT_SECTION, 'Host IP', '10.14.16.80');
      SharedMMNameEdit.Text := ReadString(TCPCLIENT_SECTION, 'Shared Memory Name', 'ModBusCom_'+DeviceName);
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

//���� ���α׷�(MEXA_7000_TCPClient_Main)������ ���� �ʴ� �Լ�//////////////////
procedure TClientFrmMain.Button1Click(Sender: TObject);
begin
  Hide;
end;

procedure TClientFrmMain.ButtonSendClick(Sender: TObject);
var
  CommBlock : TCommBlock;

begin
{  if Client.Connected then
  begin
    CommBlock.Command      := EditCommand.Text;         // assign the data
    CommBlock.MyUserName   := Client.Socket.Binding.IP;//Client.Socket.;// .LocalName;
    CommBlock.Msg          := EditMessage.Text;
    CommBlock.ReceiverName := EditRecipient.Text;

    Client.WriteBuffer (CommBlock, SizeOf (CommBlock), true);

    if Assigned(FIPCClient) then
      FreeAndNil(FIPCClient);

    FSharedMMName := DeviceName;
    Caption := DeviceName + ' ==> ' + FSharedMMName;
    FIPCClient := TIPCClient2.Create(0, FSharedMMName, True);
  end
  else
    ShowMessage('Server�� ���� �ȵ�!!'); }
end;


end.
