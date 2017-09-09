unit IPCThrdClient2;
{
  IPCThrdClient Unit���� ������ �߰���
  1. ����͸� �̿��� ���� ��� ������(debug, client directory��)
  2. FState ���� ����
}

interface

uses Windows, SysUtils, IPCThrd2;

Type
{ TIPCClient2 }

  TIPCClient2 = class(TIPCThread2)
  private
    FWaitEvent: TIPCEvent2;
  protected
    procedure Execute; override;
  public
    procedure SignalMonitor(Data: TEventData2);
    procedure PulseMonitor(Data: TEventData2);
  end;

implementation

{ TIPCClient2 }

procedure TIPCClient2.Execute;
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

procedure TIPCClient2.SignalMonitor(Data: TEventData2);
begin
  DbgStr('Signaling Monitor');
  FMonitorEvent.SignalData(evClientSignal, FID, Data);
end;

procedure TIPCClient2.PulseMonitor(Data: TEventData2);
begin
  DbgStr('Pulse Monitor');
  FMonitorEvent.PulseData(evClientSignal, FID, Data);
end;

end.
 