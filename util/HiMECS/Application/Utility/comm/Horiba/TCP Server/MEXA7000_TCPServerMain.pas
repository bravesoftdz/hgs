unit MEXA7000_TCPServerMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IdTCPServer, IdThreadMgr, IdThreadMgrDefault, IdBaseComponent,
  IdComponent, IdStack, IPCThrd2, IPCThrdMonitor2, Menus, ExtCtrls, iniFiles,
  TCPConfig, TCPServerConst, ComCtrls, SyncObjs, CoolTrayIcon, IdContext,
  IdCustomTCPServer;

const
  INIFILENAME = '.\TCPServer';
  TCPSERVER_SECTION = 'TCP Server';

type
  TDisplayTarget = (dtSendMemo, dtRecvMemo, dtStatusBar);

  PClient   = ^TClient;
  TClient   = record  // Object holding data of client (see events)
    DNS         : String[20];            { Hostname }
    Connected,                           { Time of connect }
    LastAction  : TDateTime;             { Time of last transaction }
    Thread      : Pointer;               { Pointer to thread }
  end;

  TServerFrmMain = class(TForm)
    Protocol: TMemo;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    CBServerActive: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    rlsmd1: TMenuItem;
    StopMonitor1: TMenuItem;
    StartMonitor1: TMenuItem;
    Button1: TButton;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    N5: TMenuItem;
    MenuItem4: TMenuItem;
    IdTCPServer1: TIdTCPServer;

    procedure CBServerActiveClick(Sender: TObject);
    procedure ServerConnect(AThread: TIdPeerThread);
    procedure ServerExecute(AThread: TIdPeerThread);
    procedure ServerDisconnect(AThread: TIdPeerThread);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N4Click(Sender: TObject);

    procedure WMMEXA7000Data(var Msg: TMessage); message WM_MEXA7000_DATA;
    procedure StopMonitor1Click(Sender: TObject);
    procedure StartMonitor1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  private
    procedure OnSignal(Sender: TIPCThread2; Data: TEventData2);
    procedure LoadConfigDataini2Form(ConfigForm:TTCPConfigF);
    procedure LoadConfigDataini2Var;
    procedure SaveConfigDataForm2ini(ConfigForm:TTCPConfigF);
    procedure AdjustConfigData;
  public
    FPortNum: integer;
    FFilePath: string;      //������ ������ ���
    FSharedMMName: string;  //���� �޸� �̸�
    FMonitorStart: Boolean; //Ÿ�̸� ���� �Ϸ��ϸ� True
    FCriticalSection: TCriticalSection;

    FIPCMonitor: TIPCMonitor2;//���� �޸� �� �̺�Ʈ ��ü
    FIPAddress: string;
    FMEXA7000Data: TEventData2; //�����޸𸮷κ��� ���� ������ ����
    FEventData: TEventData2; //�����޸𸮷κ��� ���� ������ ����(smh)

    procedure DisplayMessage(msg: string; ADspNo: TDisplayTarget);
    procedure InitVar;
  end;

var
  ServerFrmMain   : TServerFrmMain;
  Clients         : TThreadList;     // Holds the data of all clients

implementation

uses MEXA7000_TCPUtil, TCPServer_Util;

{$R *.DFM}

procedure TServerFrmMain.FormCreate(Sender: TObject);
begin
  Clients := TThreadList.Create;
  InitVar;
end;

procedure TServerFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FMonitorStart := False;

  FreeAndNil(FIPCMonitor);

  Server.Active := False;
  Clients.Free;
  FCriticalSection.Free;
end;

////////////////////////////////////////////////////////////////////////////////
//���α׷� �ʱ�ȣ Timer1Timer ����//////////////////////////////////////////////
procedure TServerFrmMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  FFilePath := ExtractFilePath(Application.ExeName); //�ǳ��� '\' ���Ե�
  LoadConfigDataini2Var;
  AdjustConfigData;
  //IPC Monitor �Լ� �ʱ�ȭ ����////////////////////////////////////////////////
  FIPCMonitor := TIPCMonitor2.Create(0, FSharedMMName, True);
  FIPCMonitor.OnSignal := OnSignal;
  FIPCMonitor.Resume;
  //////////////////////////////////////////////////////////////////////////////
  DisplayMessage('Shared Memory: ' + FSharedMMName + ' Created!', dtSendMemo);
  FMonitorStart := True;

  Label2.Caption := GetLocalIP;
  Caption := DeviceName + ' ==> ' + Label2.Caption;// + FIPAddress[Li];
end;

procedure TServerFrmMain.TrayIcon1DblClick(Sender: TObject);
begin
  application.Restore;
  ShowWindow(Application.Handle, SW_HIDE);
  Show;
end;

//ini ���Ͽ��� �ʱ�ȭ������ �о� Form���� �ѷ��ִ� �Լ�/////////////////////////
procedure TServerFrmMain.LoadConfigDataini2Form(ConfigForm: TTCPConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile, ConfigForm do
    begin
      PortEdit.Text := ReadString(TCPSERVER_SECTION, 'Port', '47110');
      SharedMMNameEdit.Text := ReadString(TCPSERVER_SECTION, 'Shared Memory Name', IPCCLIENTNAME1);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//ini ���Ͽ��� �ʱ�ȭ������ �о� ���α׷����� ����ϴ� ������ �����ϴ� �Լ�/////
procedure TServerFrmMain.LoadConfigDataini2Var;
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile do
    begin
      FPortNum := StrToInt(ReadString(TCPSERVER_SECTION, 'Port', '47110'));
      FSharedMMName := ReadString(TCPSERVER_SECTION, 'Shared Memory Name', IPCCLIENTNAME1);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TServerFrmMain.MenuItem1Click(Sender: TObject);
begin
  application.Restore;
  ShowWindow(Application.Handle, SW_HIDE);
  Show;
end;

procedure TServerFrmMain.MenuItem4Click(Sender: TObject);
begin
  Close;
end;

//ini���Ϸ� Host�� Port, IP �ּҸ� �����ϴ� �Լ� ///////////////////////////////
procedure TServerFrmMain.SaveConfigDataForm2ini(ConfigForm: TTCPConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile, ConfigForm do
    begin
      WriteString(TCPSERVER_SECTION, 'Port', PortEdit.Text);
      WriteString(TCPSERVER_SECTION, 'Shared Memory Name', SharedMMNameEdit.Text);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//�ý��� �ʱ� �� ����///////////////////////////////////////////////////////////
procedure TServerFrmMain.InitVar;
begin
  FCriticalSection := TCriticalSection.Create;

  FMonitorStart := False;

  FIPAddress := '192.168.0.70';
end;




////////////////////////////////////////////////////////////////////////////////
//Client���� ���� connect�� ����ϴ� �Լ�///////////////////////////////////////
procedure TServerFrmMain.ServerConnect(AThread: TIdPeerThread);
var
  NewClient: PClient;

begin
  GetMem(NewClient, SizeOf(TClient));

  NewClient.DNS         := AThread.Connection.Socket.Binding.PeerIP;// .LocalName;
  NewClient.Connected   := Now;
  NewClient.LastAction  := NewClient.Connected;
  NewClient.Thread      :=AThread;

  AThread.Data:=TObject(NewClient);

  try
    Clients.LockList.Add(NewClient);
  finally
    Clients.UnlockList;
  end;

  DisplayMessage(DateTimeToStr(now)+' Connection from "'+NewClient.DNS+'"', dtSendMemo);
end;
//RecThread�� Client�� ����� �����ϴ� (�ߺ����� �ʵ���) �Լ�///////////////////
procedure TServerFrmMain.ServerExecute(AThread: TIdPeerThread);
var
  ActClient, RecClient: PClient;
  CommBlock, NewCommBlock: TCommBlock;
  RecThread: TIdPeerThread;
  i: Integer;

begin
  if not AThread.Terminated and AThread.Connection.Connected then
  begin
    AThread.Connection.ReadBuffer (CommBlock, SizeOf (CommBlock));
    ActClient := PClient(AThread.Data);
    ActClient.LastAction := Now;  // update the time of last action

    DisplayMessage(DateTimeToStr(now)+'ServerExecute: ' + CommBlock.MyUserName, dtSendMemo);

    NewCommBlock := CommBlock; // again: nothing to change ;-))
    DisplayMessage(DateTimeToStr(now)+' Sending '+CommBlock.Command+' to "'+CommBlock.ReceiverName+'": "'+CommBlock.Msg+'"', dtSendMemo);
    with Clients.LockList do
    try
      for i := 0 to Count-1 do
      begin
        RecClient:=Items[i];
        if RecClient.DNS=CommBlock.ReceiverName then  // we don't have a login function so we have to use the DNS (Hostname)
        begin
          RecThread:=RecClient.Thread;
          //RecThread.Connection.WriteBuffer(NewCommBlock, SizeOf(NewCommBlock), True);
        end;
      end;
    finally
      Clients.UnlockList;
    end;
  end;
end;
//Client ����� ��� ���۹�ư///////////////////////////////////////////////////
procedure TServerFrmMain.StartMonitor1Click(Sender: TObject);
begin
  FIPCMonitor.FMonitorEvent.Pulse;
  FIPCMonitor.Resume;
  DisplayMessage('FIPCMonitor: ' + FIPAddress + ' Resume!', dtSendMemo);
end;
//Client ����� ��� ������ư///////////////////////////////////////////////////
procedure TServerFrmMain.StopMonitor1Click(Sender: TObject);
begin
  FIPCMonitor.FMonitorEvent.Pulse;
  FIPCMonitor.Suspend;
  DisplayMessage('FIPCMonitor: ' + FIPAddress + ' Suspended!', dtSendMemo);
end;
//Client�� Disconnect�� ���////////////////////////////////////////////////////
procedure TServerFrmMain.ServerDisconnect(AThread: TIdPeerThread);
var
  ActClient: PClient;

begin
  ActClient := PClient(AThread.Data);
  DisplayMessage (DateTimeToStr(now)+' Disconnect from "'+ActClient^.DNS+'"', dtSendMemo);
  try
    Clients.LockList.Remove(ActClient);
  finally
    Clients.UnlockList;
  end;
  FreeMem(ActClient);
  AThread.Data := nil;
end;

////////////////////////////////////////////////////////////////////////////////
//MEXA-7000p���� ������ onsignal�� �������� �ν��ϰ� Client�� �ִ��� �ľ��Ͽ�///
//WMMEXA7000Data �Լ��� ������Ű�� �Լ�/////////////////////////////////////////
procedure TServerFrmMain.OnSignal(Sender: TIPCThread2; Data: TEventData2);
begin
  if not FMonitorStart then
    exit;
  //DisplayMessage (TimeToStr(Time) +' read' + ': CO2 :'+ Data.CO2 + ' : non CH4 :' + Data.non_CH4 , dtSendMemo);
  System.Move(Data, FEventData, SizeOf(TEventData2));
  SendMessage(Handle, WM_MEXA7000_DATA, 0,0);
end;

//Client����  MEXA-7000p���� ���� �����͸� TCP/IP�� �����ϴ� �Լ�///////////////
procedure TServerFrmMain.WMMEXA7000Data(var Msg: TMessage);
var
  i: Integer;
  RecClient: PClient;
  RecThread: TIdPeerThread;
begin
  with Clients.LockList do
  try
    for i := 0 to Count-1 do  // iterate through client-list
    begin
      RecClient := Items[i];           // get client-object
      RecThread := RecClient.Thread;     // get client-thread out of it
      DisplayMessage (DateTimeToStr(now) + ': Send To "' + RecClient^.DNS,dtSendMemo);
      RecThread.Connection.WriteBuffer(FEventData,SizeOf(FEventData), True);  // send the stuff
      Application.ProcessMessages;
    end;
  finally
    Clients.UnlockList;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//���� ��� Object�� Ȱ��ȭ��Ű�� üũ��ư//////////////////////////////////////
procedure TServerFrmMain.CBServerActiveClick(Sender: TObject);
begin
  Server.Active := CBServerActive.Checked;
end;
//����͸� �ʱ�ȭ(reset) ��ư �����Լ�//////////////////////////////////////////
procedure TServerFrmMain.Button1Click(Sender: TObject);
begin
  Hide;
end;
//���� â�� Ȱ��ȭ �����ִ� ��ư ���� �Լ�//////////////////////////////////////
procedure TServerFrmMain.N2Click(Sender: TObject);
var
  TCPConfigF: TTCPConfigF;
begin
  TCPConfigF := TTCPConfigF.Create(Application);

  with TCPConfigF do
  begin
    try
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
//������ ��������ִ� �Լ�//////////////////////////////////////////////////////
procedure TServerFrmMain.AdjustConfigData;
begin
  if Server.Active then
  begin
    ShowMessage('Server�� ������ �� ȯ�漳����...');
    exit;
  end
  else
  begin
    Server.DefaultPort := FPortNum;
    Server.Active := true ;
    CBServerActive.Checked := True;
    Label4.Caption := IntToStr(FPortNum);
  end;
end;
//���α׷� ���� ��ư////////////////////////////////////////////////////////////
procedure TServerFrmMain.N4Click(Sender: TObject);
begin
  Close;
end;
//�޽����� ȭ�鿡 ǥ���ϴ� �Լ� ////////////////////////////////////////////////
procedure TServerFrmMain.DisplayMessage(msg: string; ADspNo: TDisplayTarget);
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

end.

