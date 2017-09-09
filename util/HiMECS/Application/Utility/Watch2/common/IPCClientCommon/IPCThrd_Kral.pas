unit IPCThrd_Kral;

{
  IPCThrd Unit���� ������ �߰���
  1. IPCThread ���� Create�� ��ɼ���(Shared Memeory ������ �̸��� �Ű������� �Ҵ���)
}

interface

uses
  SysUtils, Classes, Windows, MyKernelObject, IPCThrdConst_Kral;

{$MINENUMSIZE 4}  { DWORD sized enums to keep TEventInfo DWORD aligned }


const
  BUF_SIZE = 1 * 1024;

{ IPC Classes }

{ These are the classes used by the Monitor and Client to perform the
  inter-process communication }

type

  EMonitorActive = class(Exception);

  TIPCThread_Kral = class;

{ TIPCEvent_Kral }

{ Win32 events are very basic.  They are either signaled or non-signaled.
  The TIPCEvent2 class creates a "typed" TEvent, by using a block of shared
  memory to hold an "EventKind" property.  The shared memory is also used
  to hold an ID, which is important when running multiple clients, and
  a Data area for communicating data along with the event }

  TEventKind_Kral = (
    evMonitorSignal,    // Monitor signaling client
    evClientSignal,     // Client signaling monitor
    evClientExit        // Client is exiting
  );

  // �ٸ� ������Ʈ�� ����� �� �κ��� �����ؾ� ��. (change)
  // �ݵ�� �ش� ���丮�� �����Ͽ� ����� ��.
  TClientFlag_Kral = (cfError, cfModBusCom);
  TClientFlag_Krals = set of TClientFlag_Kral;

  PEventData_Kral = ^TEventData_Kral;
  TEventData_Kral = packed record
    InpDataBuf: array[0..255] of integer;
    InpDataBuf2: array[0..255] of Byte;
    InpDataBuf_double: array[0..255] of double;
    NumOfData: integer;//����Ÿ ���� �ݳ�
    NumOfBit: integer;//Bit ���� �ݳ�(01 function �� ��� Bit ������ ���޵Ǳ� ������)
    //Block Mode �ϰ�� Modbus Block Start Address,
    //Individual Mode�ϰ�� Modbus Address
    ModBusFunctionCode: integer;
    ModBusAddress: string[5];//String ������ �����޸𸮿� ��� �Ұ���
    //ModBusAddress: array[0..19] of char;//String ������ �����޸𸮿� ��� �Ұ���
    //ASCII Mode = 0, RTU Mode = 1, RTU mode simulation = 3;
    ModBusMode: integer;
    BlockNo: integer;
  end;

  TIPCNotifyEvent_Kral = procedure (Sender: TIPCThread_Kral; Data: TEventData_Kral) of Object;

  PIPCEventInfo_Kral = ^TIPCEventInfo_Kral;
  TIPCEventInfo_Kral = record
    FID: Integer;
    FKind: TEventKind_Kral;
    FData: TEventData_Kral;
  end;

  TIPCEvent_Kral = class(TEvent)
  private
    FOwner: TIPCThread_Kral;
    FOwnerID: Integer;
    FSharedMem: TSharedMem;
    function GetID: Integer;
    procedure SetID(Value: Integer);
    function GetKind: TEventKind_Kral;
    procedure SetKind(Value: TEventKind_Kral);
    function GetData: TEventData_Kral;
    procedure SetData(Value: TEventData_Kral);
  public
    FEventInfo: PIPCEventInfo_Kral;

    constructor Create(AOwner: TIPCThread_Kral; const Name: string; Manual: Boolean);
    destructor Destroy; override;
    procedure Signal(Kind: TEventKind_Kral);
    procedure SignalID(Kind: TEventKind_Kral; ID: Integer);
    procedure SignalData(Kind: TEventKind_Kral; ID: Integer; Data: TEventData_Kral);
    procedure PulseData(Kind: TEventKind_Kral; ID: Integer; Data: TEventData_Kral);
    function WaitFor(TimeOut, ID: Integer; Kind: TEventKind_Kral): Boolean;
    property ID: Integer read GetID write SetID;
    property Kind: TEventKind_Kral read GetKind write SetKind;
    property Data: TEventData_Kral read GetData write SetData;
    property OwnerID: Integer read FOwnerID write FOwnerID;
  end;

{ TIPCThread_Kral }

{ The TIPCThread_Kral class implements the functionality which is common between
  the monitor and client thread classes. }

  TIPCThread_Kral = class(TThread)
  protected
    FID: Integer;
    FName: string;
    FClientEvent: TIPCEvent_Kral;
    FOnSignal: TIPCNotifyEvent_Kral;
  public
    FMonitorEvent: TIPCEvent_Kral;

    constructor Create(AID: Integer; const AName: string; AMalual: Boolean);
    destructor Destroy; override;
    procedure DbgStr(const S: string);
  published
    property OnSignal: TIPCNotifyEvent_Kral read FOnSignal write FOnSignal;
  end;

implementation

uses TypInfo;

{ TIPCEvent_Kral }

constructor TIPCEvent_Kral.Create(AOwner: TIPCThread_Kral; const Name: string;
  Manual: Boolean);
begin
  inherited Create(Name, Manual);
  FOwner := AOwner;
  FSharedMem := TSharedMem.Create(Format('%s.Data', [Name]), SizeOf(TIPCEventInfo_Kral));
  FEventInfo := FSharedMem.Buffer;
end;

destructor TIPCEvent_Kral.Destroy;
begin
  FSharedMem.Free;
  inherited Destroy;
end;

function TIPCEvent_Kral.GetID: Integer;
begin
  Result := FEventInfo.FID;
end;

procedure TIPCEvent_Kral.SetID(Value: Integer);
begin
  FEventInfo.FID := Value;
end;

function TIPCEvent_Kral.GetKind: TEventKind_Kral;
begin
  Result := FEventInfo.FKind;
end;

procedure TIPCEvent_Kral.SetKind(Value: TEventKind_Kral);
begin
  FEventInfo.FKind := Value;
end;

function TIPCEvent_Kral.GetData: TEventData_Kral;
begin
  Result := FEventInfo.FData;
end;

procedure TIPCEvent_Kral.SetData(Value: TEventData_Kral);
begin
  FEventInfo.FData := Value;
end;

procedure TIPCEvent_Kral.Signal(Kind: TEventKind_Kral);
begin
  FEventInfo.FID := FOwnerID;
  FEventInfo.FKind := Kind;
  inherited Signal;
end;

procedure TIPCEvent_Kral.SignalID(Kind: TEventKind_Kral; ID: Integer);
begin
  FEventInfo.FID := ID;
  FEventInfo.FKind := Kind;
  inherited Signal;
end;

procedure TIPCEvent_Kral.SignalData(Kind: TEventKind_Kral; ID: Integer; Data: TEventData_Kral);
begin
  FEventInfo.FID := ID;
  FEventInfo.FData := Data;
  FEventInfo.FKind := Kind;
  inherited Signal;
end;

procedure TIPCEvent_Kral.PulseData(Kind: TEventKind_Kral; ID: Integer; Data: TEventData_Kral);
begin
  FEventInfo.FID := ID;
  FEventInfo.FData := Data;
  FEventInfo.FKind := Kind;
  inherited Pulse;
end;

function TIPCEvent_Kral.WaitFor(TimeOut, ID: Integer; Kind: TEventKind_Kral): Boolean;
begin
  Result := Wait(TimeOut);
  if Result then
    Result := (ID = FEventInfo.FID) and (Kind = FEventInfo.FKind);
end;

{ TIPCThread_Kral }

constructor TIPCThread_Kral.Create(AID: Integer; const AName: string; AMalual: Boolean);
begin
  inherited Create(True);
  FID := AID;
  FName := AName;
  FMonitorEvent := TIPCEvent_Kral.Create(Self, AName+'_'+MONITOR_EVENT_NAME, AMalual);
end;

destructor TIPCThread_Kral.Destroy;
begin
  Terminate;
  //FMonitorEvent.Signal(TEventKind_Kral(0));
  //Client ����� Monitor���� FMonitorEvent �� ��� Signaled ���·� �����־
  //CPU �������� ����ϴ� ���� �ذ� ���� �Ʒ� �ڵ�� ��ü��
  FMonitorEvent.Pulse;
  inherited Destroy;
  FMonitorEvent.Free;
end;

{ This procedure is called all over the place to keep track of what is
  going on }

procedure TIPCThread_Kral.DbgStr(const S: string);
begin
{$IFDEF DEBUG}
  //FTracer.Add(PChar(S));
{$ENDIF}
end;

end.
