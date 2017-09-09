unit IPCThrd_RMIS;

{
  IPCThrd Unit���� ������ �߰���
  1. IPCThread ���� Create�� ��ɼ���(Shared Memeory ������ �̸��� �Ű������� �Ҵ���)
}

interface

uses
  SysUtils, Classes, Windows, MyKernelObject4GpSharedMem, IPC_BWQry_Const;

{$MINENUMSIZE 4}  { DWORD sized enums to keep TEventInfo DWORD aligned }


const
  BUF_SIZE = 1 * 1024;

{ IPC Classes }

{ These are the classes used by the Monitor and Client to perform the
  inter-process communication }

type

  EMonitorActive = class(Exception);

  TIPCThread_RMIS = class;

{ TIPCEvent_RMIS }

{ Win32 events are very basic.  They are either signaled or non-signaled.
  The TIPCEvent2 class creates a "typed" TEvent, by using a block of shared
  memory to hold an "EventKind" property.  The shared memory is also used
  to hold an ID, which is important when running multiple clients, and
  a Data area for communicating data along with the event }

  TEventKind_RMIS = (
    evMonitorSignal,    // Monitor signaling client
    evClientSignal,     // Client signaling monitor
    evClientExit        // Client is exiting
  );

  // �ٸ� ������Ʈ�� ����� �� �κ��� �����ؾ� ��. (change)
  // �ݵ�� �ش� ���丮�� �����Ͽ� ����� ��.
  TClientFlag_RMIS = (cfError, cfModBusCom);
  TClientFlag_RMISs = set of TClientFlag_RMIS;

  TIPCNotifyEvent_RMIS = procedure (Sender: TIPCThread_RMIS; Data: TEventData_BWQry) of Object;

  PIPCEventInfo_RMIS = ^TIPCEventInfo_RMIS;
  TIPCEventInfo_RMIS = record
    FID: Integer;
    FKind: TEventKind_RMIS;
    FData: TEventData_BWQry;
  end;

  TIPCEvent_RMIS = class(TEvent)
  private
    FOwner: TIPCThread_RMIS;
    FOwnerID: Integer;
    FSharedMem: TSharedMem;
    function GetID: Integer;
    procedure SetID(Value: Integer);
    function GetKind: TEventKind_RMIS;
    procedure SetKind(Value: TEventKind_RMIS);
    function GetData: TEventData_BWQry;
    procedure SetData(Value: TEventData_BWQry);
  public
    FEventInfo: PIPCEventInfo_RMIS;

    constructor Create(AOwner: TIPCThread_RMIS; const Name: string; Manual: Boolean);
    destructor Destroy; override;
    procedure Signal(Kind: TEventKind_RMIS);
    procedure SignalID(Kind: TEventKind_RMIS; ID: Integer);
    procedure SignalData(Kind: TEventKind_RMIS; ID: Integer; Data: TEventData_BWQry);
    procedure PulseData(Kind: TEventKind_RMIS; ID: Integer; Data: TEventData_BWQry);
    function WaitFor(TimeOut, ID: Integer; Kind: TEventKind_RMIS): Boolean;
    property ID: Integer read GetID write SetID;
    property Kind: TEventKind_RMIS read GetKind write SetKind;
    property Data: TEventData_BWQry read GetData write SetData;
    property OwnerID: Integer read FOwnerID write FOwnerID;
  end;

{ TIPCThread_RMIS }

{ The TIPCThread_RMIS class implements the functionality which is common between
  the monitor and client thread classes. }

  TIPCThread_RMIS = class(TThread)
  protected
    FID: Integer;
    FName: string;
    FClientEvent: TIPCEvent_RMIS;
    FOnSignal: TIPCNotifyEvent_RMIS;
  public
    FMonitorEvent: TIPCEvent_RMIS;

    constructor Create(AID: Integer; const AName: string; AMalual: Boolean);
    destructor Destroy; override;
    procedure DbgStr(const S: string);
  published
    property OnSignal: TIPCNotifyEvent_RMIS read FOnSignal write FOnSignal;
  end;

implementation

uses TypInfo;

{ TIPCEvent_RMIS }

constructor TIPCEvent_RMIS.Create(AOwner: TIPCThread_RMIS; const Name: string;
  Manual: Boolean);
begin
  inherited Create(Name, Manual);
  FOwner := AOwner;
  FSharedMem := TSharedMem.Create(Format('%s.Data', [Name]), SizeOf(TIPCEventInfo_RMIS));
  FEventInfo := FSharedMem.Buffer;
end;

destructor TIPCEvent_RMIS.Destroy;
begin
  FSharedMem.Free;
  inherited Destroy;
end;

function TIPCEvent_RMIS.GetID: Integer;
begin
  Result := FEventInfo.FID;
end;

procedure TIPCEvent_RMIS.SetID(Value: Integer);
begin
  FEventInfo.FID := Value;
end;

function TIPCEvent_RMIS.GetKind: TEventKind_RMIS;
begin
  Result := FEventInfo.FKind;
end;

procedure TIPCEvent_RMIS.SetKind(Value: TEventKind_RMIS);
begin
  FEventInfo.FKind := Value;
end;

function TIPCEvent_RMIS.GetData: TEventData_BWQry;
begin
  Result := FEventInfo.FData;
end;

procedure TIPCEvent_RMIS.SetData(Value: TEventData_BWQry);
begin
  FEventInfo.FData := Value;
end;

procedure TIPCEvent_RMIS.Signal(Kind: TEventKind_RMIS);
begin
  FEventInfo.FID := FOwnerID;
  FEventInfo.FKind := Kind;
  inherited Signal;
end;

procedure TIPCEvent_RMIS.SignalID(Kind: TEventKind_RMIS; ID: Integer);
begin
  FEventInfo.FID := ID;
  FEventInfo.FKind := Kind;
  inherited Signal;
end;

procedure TIPCEvent_RMIS.SignalData(Kind: TEventKind_RMIS; ID: Integer; Data: TEventData_BWQry);
begin
  FEventInfo.FID := ID;
  FEventInfo.FData := Data;
  FEventInfo.FKind := Kind;
  inherited Signal;
end;

procedure TIPCEvent_RMIS.PulseData(Kind: TEventKind_RMIS; ID: Integer; Data: TEventData_BWQry);
begin
  FEventInfo.FID := ID;
  FEventInfo.FData := Data;
  FEventInfo.FKind := Kind;
  inherited Pulse;
end;

function TIPCEvent_RMIS.WaitFor(TimeOut, ID: Integer; Kind: TEventKind_RMIS): Boolean;
begin
  Result := Wait(TimeOut);
  if Result then
    Result := (ID = FEventInfo.FID) and (Kind = FEventInfo.FKind);
end;

{ TIPCThread_RMIS }

constructor TIPCThread_RMIS.Create(AID: Integer; const AName: string; AMalual: Boolean);
begin
  inherited Create(True);
  FID := AID;
  FName := AName;
  FMonitorEvent := TIPCEvent_RMIS.Create(Self, AName+'_'+MONITOR_EVENT_NAME, AMalual);
end;

destructor TIPCThread_RMIS.Destroy;
begin
  Terminate;
  //FMonitorEvent.Signal(TEventKind_RMIS(0));
  //Client ����� Monitor���� FMonitorEvent �� ��� Signaled ���·� �����־
  //CPU �������� ����ϴ� ���� �ذ� ���� �Ʒ� �ڵ�� ��ü��
  FMonitorEvent.Pulse;
  inherited Destroy;
  FMonitorEvent.Free;
end;

{ This procedure is called all over the place to keep track of what is
  going on }

procedure TIPCThread_RMIS.DbgStr(const S: string);
begin
{$IFDEF DEBUG}
  //FTracer.Add(PChar(S));
{$ENDIF}
end;

end.
