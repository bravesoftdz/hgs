program json_time_cli;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  FastMM4,
  Windows,
  SysUtils,
  Types,
  ZeroMQ,
  SuperObject;

procedure Run;
var
  Z: IZeroMQ;
  Subscriber: IZMQPair;
  Json: TStringDynArray;
  O: ISuperObject;
  T: Cardinal;
begin
  Z := TZeroMQ.Create;
  Subscriber := Z.Start(ZMQSocket_Subscriber);
  Subscriber.Connect('tcp://localhost:5550');
  Subscriber.Subscribe('');

  repeat
    T := GetTickCount;
    Json := Subscriber.ReceiveStrings;
    if (Length(Json) = 2) and (Json[0] = 'application/json') then
    begin
      O := TSuperObject.ParseString(PWideChar(WideString(Json[1])), True);
      Writeln('Duration ', GetTickCount - T, 'ms');
      WriteLn('We are ', DateTimeToStr(JavaToDelphiDateTime(O.I['time'])));
    end
    else
      WriteLn('Bad message');
  until (Length(Json) = 2) and (Json[0] = 'application/json');
end;

begin
  try
    Run;
    WriteLn;
    WriteLn('Press a key to continue...');
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
