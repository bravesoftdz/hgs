unit IPCThrdMonitor2;
{
  IPCThrdMonitor Unit에서 다음이 추가됨
  1. 모니터링 이외의 사항 모두 삭제함(debug, client directory등)
  2. FState 관련 삭제
}

interface

uses Windows, Classes, SysUtils, IPCThrd2, IPCThrdConst;

Type
{ TIPCMonitor2 }

  TIPCMonitor2 = class(TIPCThread2)
  protected
    procedure DoOnSignal;
    procedure Execute; override;
  public
    constructor Create(AID: Integer; const AName: string; AManual: Boolean);
  end;

implementation

{ TIPCMonitor2 }

constructor TIPCMonitor2.Create(AID: Integer; const AName: string; AManual: Boolean);
begin
  inherited Create(AID, AName, AManual);
end;

procedure TIPCMonitor2.Execute;
var
  WaitResult: Integer;
begin
  DbgStr(FName + ' Activated');
  while not Terminated do
  try
    WaitResult := WaitForSingleObject(FMonitorEvent.Handle, INFINITE);
    if WaitResult = WAIT_OBJECT_0 then          { Monitor Event }
    begin
      case FMonitorEvent.Kind of
        evClientSignal: //Client로 부터 오는 Signal을 뜻함
          DoOnSignal;
      end;
    end
    else
      DbgStr(Format('Unexpected Wait Return Code: %d', [WaitResult]));
  except
    on E:Exception do
      DbgStr(Format('Exception raised in Thread Handler: %s at %X', [E.Message, ExceptAddr]));
  end;
  DbgStr('Thread Handler Exited');
end;

{ This method is called when the client has new data for us }

procedure TIPCMonitor2.DoOnSignal;
begin
  if Assigned(FOnSignal) then//and (FMonitorEvent.ID = FClientID) then
    FOnSignal(Self, FMonitorEvent.Data);
end;

end.
