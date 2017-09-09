unit IPCThrdClient_ECS_Avat;
{
  IPCThrdClient Unit���� ������ �߰���
  1. ����͸� �̿��� ���� ��� ������(debug, client directory��)
  2. FState ���� ����
}

interface

uses Windows, SysUtils, IPCThrd_ECS_Avat;

Type
{ TIPCClient2 }

  TIPCClient_ECS_Avat = class(TIPCThread_ECS_Avat)
  private
    FWaitEvent: TIPCEvent_ECS_Avat;
  protected
    procedure Execute; override;
  public
    procedure SignalMonitor(Data: TEventData_ECS_Avat);
    procedure PulseMonitor(Data: TEventData_ECS_Avat);
  end;

implementation

{ TIPCClient2 }

procedure TIPCClient_ECS_Avat.Execute;
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

procedure TIPCClient_ECS_Avat.SignalMonitor(Data: TEventData_ECS_Avat);
begin
  DbgStr('Signaling Monitor');
  FMonitorEvent.SignalData(evClientSignal, FID, Data);
end;

procedure TIPCClient_ECS_Avat.PulseMonitor(Data: TEventData_ECS_Avat);
begin
  DbgStr('Pulse Monitor');
  FMonitorEvent.PulseData(evClientSignal, FID, Data);
end;

end.
 