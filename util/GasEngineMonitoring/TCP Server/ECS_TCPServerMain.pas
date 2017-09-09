unit ECS_TCPServerMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IdTCPServer, IdBaseComponent, IdStreamVCL,
  IdComponent, IdStack, IPCThrd_ECS_avat, Menus, ExtCtrls, iniFiles,
  TCPConfig, TCPServerConst, ComCtrls, SyncObjs, IPCThrdMonitor_ECS_avat,
  IdContext, IdCustomTCPServer, JvComponentBase, JvTrayIcon, JvExControls,
  JvXPCore, JvXPButtons, SynEdit, SynMemo;

const
  INIFILENAME = '.\TCPServer';
  TCPSERVER_SECTION = 'TCP Server';

type
  TDisplayTarget = (dtSystemLog, dtConnectLog, dtCommLog, dtStatusBar);

  PClient   = ^TClient;
  TClient   = record  // Object holding data of client (see events)
    DNS         : String[20];            { Hostname }
    Connected,                           { Time of connect }
    LastAction  : TDateTime;             { Time of last transaction }
    Thread      : Pointer;               { Pointer to thread }
  end;

  TServerFrmMain = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    Timer1: TTimer;
    Panel1: TPanel;
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
    JvTrayIcon1: TJvTrayIcon;
    IdTCPServer1: TIdTCPServer;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    lvConnections: TListView;
    TabSheet2: TTabSheet;
    Splitter2: TSplitter;
    SendMemo: TRichEdit;
    Recvmemo: TRichEdit;
    TabSheet3: TTabSheet;
    PageControl2: TPageControl;
    TabSheet4: TTabSheet;
    SMUDPSysLog: TSynMemo;
    TabSheet5: TTabSheet;
    SMUDPConnectLog: TSynMemo;
    TabSheet6: TTabSheet;
    SMCommLog: TSynMemo;
    Panel2: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LblPort: TLabel;
    LblCurConnent: TLabel;
    LblMaxConn: TLabel;
    Label8: TLabel;
    LblIP: TLabel;
    JvXPButton1: TJvXPButton;
    JvXPButton2: TJvXPButton;
    JvXPButton3: TJvXPButton;
    JvXPButton4: TJvXPButton;
    JvXPButton5: TJvXPButton;
    JvXPButton6: TJvXPButton;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;

    procedure CBServerActiveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N4Click(Sender: TObject);

    procedure WMAVATECSData(var Msg: TMessage); message WM_EVENT_ECS;
    procedure StopMonitor1Click(Sender: TObject);
    procedure StartMonitor1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
    procedure JvXPButton1Click(Sender: TObject);
    procedure JvXPButton2Click(Sender: TObject);
  private
    procedure ECS_OnSignal(Sender: TIPCThread_ECS_avat; Data: TEventData_ECS_avat);
    procedure LoadConfigDataini2Form(ConfigForm:TTCPConfigF);
    procedure LoadConfigDataini2Var;
    procedure SaveConfigDataForm2ini(ConfigForm:TTCPConfigF);
    procedure AdjustConfigData;
  public
    FPortNum: integer;
    FFilePath: string;      //������ ������ ���
    FSharedMMName: string;  //���� �޸� �̸�
    FMonitorStart: Boolean; //Ÿ�̸� ���� �Ϸ��ϸ� True
    FDestroying: Boolean;   //�������̸� True(����� ���� ������ �߰���)
    FCriticalSection: TCriticalSection;

    FIPCMonitor_ECS_avat: TIPCMonitor_ECS_avat;//AVAT ECS
    FIPAddress: string;
    FEventData_ECS_avat: TEventData_ECS_avat; //�����޸𸮷κ��� ���� ������ ����(smh)

    procedure DisplayMessage(msg: string; ADspNo: TDisplayTarget);
    procedure InitVar;
    procedure DisconnectAll;
  end;

var
  ServerFrmMain   : TServerFrmMain;
  Clients         : TList;     // Holds the data of all clients
  GStack: TIdStack = nil;

implementation

uses ECS_avat_TCPUtil, TCPServer_Util;

{$R *.DFM}

procedure TServerFrmMain.FormCreate(Sender: TObject);
begin
  Clients := TList.Create;
  InitVar;
end;

procedure TServerFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FMonitorStart := False;
  FDestroying := True;
  FreeAndNil(FIPCMonitor_ECS_avat);

  DisconnectAll;
  IdTCPServer1.Active := False;
  Clients.Free;
  FCriticalSection.Free;
end;

////////////////////////////////////////////////////////////////////////////////
//���α׷� �ʱ�ȣ Timer1Timer ����
procedure TServerFrmMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  FFilePath := ExtractFilePath(Application.ExeName); //�ǳ��� '\' ���Ե�
  LoadConfigDataini2Var;
  AdjustConfigData;


  //ECS-IPC Monitor �Լ� �ʱ�ȭ ����
  FIPCMonitor_ECS_avat := TIPCMonitor_ECS_avat.Create(0, FSharedMMName, True);
  FIPCMonitor_ECS_avat.OnSignal := ECS_OnSignal;
  FIPCMonitor_ECS_avat.Resume;

  //////////////////////////////////////////////////////////////////////////////
  DisplayMessage('Shared Memory: ' + FSharedMMName + ' Created!', dtSystemLog);
  FMonitorStart := True;

  LblPort.Caption := IntToStr(FPortNum);
  LblIP.Caption := FIPAddress;
  Caption := DeviceName + ' ==> ';// + FIPAddress[Li];
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
      HostIpCB.Text := ReadString(TCPSERVER_SECTION, 'IP', '10.14.23.11');
      PortEdit.Text := ReadString(TCPSERVER_SECTION, 'Port', '47110');
      SharedMMNameEdit.Text := ReadString(TCPSERVER_SECTION, 'Shared Memory Name', 'TCP_'+DeviceName);
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
      FIPAddress := ReadString(TCPSERVER_SECTION, 'IP', '10.14.23.11');
      FPortNum := StrToInt(ReadString(TCPSERVER_SECTION, 'Port', '47110'));
      FSharedMMName := ReadString(TCPSERVER_SECTION, 'Shared Memory Name', 'TCP_'+DeviceName);
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

procedure TServerFrmMain.MenuItem3Click(Sender: TObject);
begin
  ShowMessage('AVAT ECS TCP Server!');
end;

procedure TServerFrmMain.MenuItem4Click(Sender: TObject);
begin
  application.Terminate;
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
      WriteString(TCPSERVER_SECTION, 'IP', HostIPCB.Text);
      WriteString(TCPSERVER_SECTION, 'Port', PortEdit.Text);
      WriteString(TCPSERVER_SECTION, 'Shared Memory Name', SharedMMNameEdit.Text);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//�ý��� �ʱ� �� ����///////////////////////////////////////////////////////////
procedure TServerFrmMain.IdTCPServer1Connect(AContext: TIdContext);
var
  NewClient: PClient;
  LListItem: TListitem;
begin
  GetMem(NewClient, SizeOf(TClient));

  NewClient.DNS         := AContext.Connection.Socket.Binding.PeerIP;// .LocalName;
  NewClient.Connected   := Now;
  NewClient.LastAction  := NewClient.Connected;
  NewClient.Thread      :=AContext;

  AContext.Data:=TObject(NewClient);
  //AContext.Connection.IOHandler.ReadTimeout := 500;
  try
    Clients.Add(NewClient);
    LListItem := lvConnections.Items.Add;
    LListItem.Caption := NewClient.DNS;
    LListItem.SubItems.Add('connected');
    LListItem.SubItems.Add(DateTimeToStr(now));
    LListItem.SubItems.Add(IntToStr(AContext.Connection.Socket.Binding.PeerPort));
    LblCurConnent.Caption := IntToStr(Clients.Count);
  finally
    //Clients.UnlockList;
  end;

  DisplayMessage(DateTimeToStr(now)+' Connection from "'+NewClient.DNS+'"', dtConnectLog);
end;

procedure TServerFrmMain.IdTCPServer1Disconnect(AContext: TIdContext);
var
  ActClient: PClient;
  Li: integer;
begin
  if FDestroying then
    exit;

  ActClient := PClient(AContext.Data);
  DisplayMessage (DateTimeToStr(now)+' Disconnect from "'+ActClient^.DNS+'"', dtConnectLog);
  if Assigned(lvConnections) then
  begin
    for Li := 0 to lvConnections.Items.Count - 1 do
    begin
      if (ActClient.DNS = lvConnections.Items[Li].Caption) and
        (IntToStr(AContext.Binding.PeerPort) = lvConnections.Items[Li].SubItems.Strings[2]) then
      begin
        lvConnections.Items.Delete(Li);
        break;
      end;
    end;
  end;

  try
    Clients.Remove(ActClient);
    if Assigned(LblCurConnent) then
      LblCurConnent.Caption := IntToStr(Clients.Count);
  finally
    //Clients.UnlockList;
  end;
  FreeMem(ActClient);
  AContext.Data := nil;
end;

////////////////////////////////////////////////////////////////////////////////
//Client���� ���� connect�� ����ϴ� �Լ�///////////////////////////////////////
//RecThread�� Client�� ����� �����ϴ� (�ߺ����� �ʵ���) �Լ�///////////////////
procedure TServerFrmMain.IdTCPServer1Execute(AContext: TIdContext);
var
  ActClient, RecClient: PClient;
  CommBlock, NewCommBlock: TCommBlock;
  LStream: TMemoryStream;
  RecThread: TIdContext;
  i: Integer;
begin
{  if AContext.Connection.Connected then
  begin
    LStream := TMemoryStream.Create;
    try
      //AContext.Connection.IOHandler.ReadBytes(CommBlock, SizeOf (CommBlock));
      AContext.Connection.IOHandler.ReadStream(LStream, SizeOf (CommBlock));
      CommBlock := ReadComBlockFromStream(LStream);
      ActClient := PClient(AContext.Data);
      ActClient.LastAction := Now;  // update the time of last action

      DisplayMessage(DateTimeToStr(now)+'ServerExecute: ' + CommBlock.MyUserName, dtSystemLog);

      NewCommBlock := CommBlock; // again: nothing to change ;-))
      DisplayMessage(DateTimeToStr(now)+' Sending '+CommBlock.Command+' to "'+CommBlock.ReceiverName+'": "'+CommBlock.Msg+'"', dtCommLog);
      with Clients.LockList do
      try
        for i := 0 to Count-1 do
        begin
          RecClient:=Items[i];
          if RecClient.DNS=CommBlock.MyUserName then  // we don't have a login function so we have to use the DNS (Hostname)
          begin
            //RecThread:=RecClient.Thread;
            //RecThread.Connection.WriteBuffer(NewCommBlock, SizeOf(NewCommBlock), True);
            DisplayMessage(DateTimeToStr(now)+' ' + 'RecClient.DNS: ' + RecClient.DNS, dtCommLog);
          end;
        end;
      finally
        Clients.UnlockList;
      end;
    finally
      LStream.Free;
    end;
  end;
}
end;

procedure TServerFrmMain.InitVar;
begin
  FCriticalSection := TCriticalSection.Create;

  FMonitorStart := False;

  FDestroying := False;
end;

procedure TServerFrmMain.JvXPButton1Click(Sender: TObject);
begin
  IdTCPServer1.Active := True;
  JvXPButton1.Enabled := False;
  JvXPButton2.Enabled := True;
  DisplayMessage(DateTimeToStr(now)+'TCP Server Start...', dtSystemLog);
end;

procedure TServerFrmMain.JvXPButton2Click(Sender: TObject);
begin
  IdTCPServer1.Active := False;
  JvXPButton1.Enabled := true;
  JvXPButton2.Enabled := false;
  DisplayMessage(DateTimeToStr(now)+'TCP Server Stoped!', dtSystemLog);
end;

//Client ����� ��� ���۹�ư///////////////////////////////////////////////////
procedure TServerFrmMain.StartMonitor1Click(Sender: TObject);
begin
  FIPCMonitor_ECS_avat.FMonitorEvent.Pulse;
  FIPCMonitor_ECS_avat.Resume;
  DisplayMessage('FIPCMonitor: ' + FIPAddress + ' Resume!', dtSystemLog);
end;

//Client ����� ��� ������ư///////////////////////////////////////////////////
procedure TServerFrmMain.StopMonitor1Click(Sender: TObject);
begin
  FIPCMonitor_ECS_avat.FMonitorEvent.Pulse;
  FIPCMonitor_ECS_avat.Suspend;
  DisplayMessage('FIPCMonitor: ' + FIPAddress + ' Suspended!', dtSystemLog);
end;

////////////////////////////////////////////////////////////////////////////////
//AVAT ECS���� ������ onsignal�� �������� �ν��ϰ� Client�� �ִ��� �ľ��Ͽ�///
//WMMEXA7000Data �Լ��� ������Ű�� �Լ�/////////////////////////////////////////
procedure TServerFrmMain.ECS_OnSignal(Sender: TIPCThread_ECS_avat; Data: TEventData_ECS_avat);
var
  i: Integer;
begin
  if not FMonitorStart then
    exit;

  //DisplayMessage (TimeToStr(Time) +' read' + ': NumOfData :'+ IntToStr(Data.NumOfData), dtSendMemo);
  System.Move(Data, FEventData_ECS_avat, SizeOf(TEventData_ECS_avat));
  //DisplayMessage (TimeToStr(Time) +' move' + ': NumOfData :'+ IntToStr(FEventData_ECS_avat.NumOfData), dtSendMemo);
  SendMessage(Handle, WM_EVENT_ECS, 0,0);
end;

//Client����  ECS���� ���� �����͸� TCP/IP�� �����ϴ� �Լ�///////////////
procedure TServerFrmMain.WMAVATECSData(var Msg: TMessage);
var
  RecClient: PClient;
  RecThread: TIdContext;
  Li: integer;
  LStream: TMemoryStream;
begin
  LStream := TMemoryStream.Create;
  WriteEventData2Stream(FEventData_ECS_avat, LStream);
  try
    with Clients do
    try
      for Li := 0 to Count-1 do  // iterate through client-list
      begin
        RecClient := Items[Li];  // get client-object
        RecThread := RecClient.Thread;     // get client-thread out of it
        DisplayMessage (DateTimeToStr(now) + ': Send To "' + RecClient^.DNS,dtCommLog);
        RecThread.Connection.IOHandler.Write(LStream, LStream.Size);  // send the stuff
        Application.ProcessMessages;
      end;
    finally
      //Clients.UnlockList;
    end;
  finally
    LStream.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//���� ��� Object�� Ȱ��ȭ��Ű�� üũ��ư//////////////////////////////////////
procedure TServerFrmMain.CBServerActiveClick(Sender: TObject);
begin
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
  if IdTCPServer1.Active then
  begin
    ShowMessage('Server�� ������ �� ȯ�漳����...');
    exit;
  end
  else
  begin
    IdTCPServer1.Bindings.Clear;
    IdTCPServer1.Bindings.Add.ip := FIPAddress;
    IdTCPServer1.Bindings.Add.Port := FPortNum;
    IdTCPServer1.DefaultPort := FPortNum;
    LblPort.Caption := IntToStr(FPortNum);
    LblIP.Caption := FIPAddress;
    JvXPButton1Click(nil);
  end;
end;

//���α׷� ���� ��ư////////////////////////////////////////////////////////////
procedure TServerFrmMain.N4Click(Sender: TObject);
begin
  Close;
end;

procedure TServerFrmMain.DisconnectAll;
var
  RecClient: PClient;
  Li: integer;
begin
  for Li := Clients.Count - 1 downto 0 do
  begin
    RecClient := Clients.Items[Li];  // get client-object
    FreeMem(RecClient);
    Clients.Remove(RecClient);
  end;

  try
    LblCurConnent.Caption := IntToStr(Clients.Count);
  finally
    //Clients.UnlockList;
  end;
end;

//�޽����� ȭ�鿡 ǥ���ϴ� �Լ� ////////////////////////////////////////////////
procedure TServerFrmMain.DisplayMessage(msg: string; ADspNo: TDisplayTarget);
begin
  if msg = ' ' then
  begin
    exit;
  end;

  case ADspNo of
    dtSystemLog : begin
      with SMUDPSysLog do
      begin
        if Lines.Count > 100 then
          Clear;
        Lines.Add(msg);
      end;//with
    end;//dtSystemLog
    dtConnectLog: begin
      with SMUDPConnectLog do
      begin
        if Lines.Count > 100 then
          Clear;
        Lines.Add(msg);
      end;//with
    end;//dtConnectLog
    dtCommLog: begin
      with SMCommLog do
      begin
        if Lines.Count > 100 then
          Clear;
        Lines.Add(msg);
      end;//with
    end;//dtCommLog

    dtStatusBar: begin
       StatusBar1.SimplePanel := True;
       StatusBar1.SimpleText := msg;
    end;//dtStatusBar
  end;//case
end;

end.

