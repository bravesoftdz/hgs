unit IPCThrdClient_EngineParam_before_generic;
{
  IPCThrdClient Unit���� ������ �߰���
  1. ����͸� �̿��� ���� ��� ������(debug, client directory��)
  2. FState ���� ����
}

interface

uses Windows, SysUtils, IPCThrd_EngineParam;

Type
{ TIPCClient2 }

  TIPCClient_EngineParam = class(TIPCThread_EngineParam)
  private
    FWaitEvent: TIPCEvent_EngineParam;
  protected
    procedure Execute; override;
  public
    procedure SignalMonitor(Data: TEventData_EngineParam);
    procedure PulseMonitor(Data: TEventData_EngineParam);
  end;

implementation

{ TIPCClient2 }

procedure TIPCClient_EngineParam.Execute;
begin
  DbgStr(FName + ' Activated');

  while not Terminated do
  try
    if WaitForSingleObject(FWaitEvent.Handle, INFINITE) <> WAIT_OBJECT_0 then Break;

    case FWaitEvent.Kind of
      evMonitorSignal: if Assigned(FOnSignal) then FOnSignal(Self, FWaitEvent.Data);
    end;
  except
    on E:Exception do
      DbgStr(Format('Exception raised in Thread Handler: %s at %X', [E.Message, ExceptAddr]));
  end;

  DbgStr('Thread Handler Exited');
end;

procedure TIPCClient_EngineParam.SignalMonitor(Data: TEventData_EngineParam);
begin
  DbgStr('Signaling Monitor');
  FMonitorEvent.SignalData(evClientSignal, FID, Data);
end;

procedure TIPCClient_EngineParam.PulseMonitor(Data: TEventData_EngineParam);
begin
  DbgStr('Pulse Monitor');
  FMonitorEvent.PulseData(evClientSignal, FID, Data);
end;

end.

