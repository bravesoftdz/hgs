unit IPCThrdClient_PMS;
{
  IPCThrdClient Unit���� ������ �߰���
  1. ����͸� �̿��� ���� ��� ������(debug, client directory��)
  2. FState ���� ����
}

interface

uses Windows, SysUtils, IPCThrd_PMS;

Type
{ TIPCClient2 }

  TIPCClient_PMS = class(TIPCThread_PMS)
  private
    FWaitEvent: TIPCEvent_PMS;
  protected
    procedure Execute; override;
  public
    procedure SignalMonitor(Data: TEventData_PMS);
    procedure PulseMonitor(Data: TEventData_PMS);
  end;

implementation

{ TIPCClient2 }

procedure TIPCClient_PMS.Execute;
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

procedure TIPCClient_PMS.SignalMonitor(Data: TEventData_PMS);
begin
  DbgStr('Signaling Monitor');
  FMonitorEvent.SignalData(evClientSignal, FID, Data);
end;

procedure TIPCClient_PMS.PulseMonitor(Data: TEventData_PMS);
begin
  DbgStr('Pulse Monitor');
  FMonitorEvent.PulseData(evClientSignal, FID, Data);
end;

end.
 