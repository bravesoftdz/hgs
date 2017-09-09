program hello_srv1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
//  madExcept,
  System.SysUtils, ZeroMQ;

procedure Run;
var
  Z: IZeroMQ;
  R: IZMQPair;
  S: string;
begin
  Z := TZeroMQ.Create;
  R := Z.Start(ZMQSocket.Responder);
  R.Bind('tcp://*:5555');
  Writeln('Started hello world server (TCP/5555)...');

  while True do
  begin
    S := R.ReceiveString;
    WriteLn('Received ', S);
    Sleep(10);
    WriteLn(' Sending World');
    R.SendString('World');
  end;
end;

begin
  try
    Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
