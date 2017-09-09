program weather_cli;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  FastMM4,
  SysUtils, ZeroMQ;

procedure Run;

  procedure Decode(const S: string; out Zip, Temp, Humidity: Integer);
  var
    P, X: PChar;

    function NextInt: Integer;
    var
      B: string;
    begin
{$IFDEF UNICODE}
      while not CharInSet(X^, [' ', #0]) do
{$ELSE}
      while not (X^ in [' ', #0]) do
{$ENDIF}
        Inc(X);
      SetString(B, P, X - P);
      Result := StrToInt(B);
      Inc(X);
      P := X;
    end;

  begin
    P := PChar(S);
    X := P;
    Zip := NextInt;
    Temp := NextInt;
    Humidity := NextInt;
  end;

var
  Z: IZeroMQ;
  S: IZMQPair;
  filter: string;
  update_count: Integer;
  total_temp: Integer;
  update: string;
  zipcode, temperature, relhumidity: Integer;
begin
  Z := TZeroMQ.Create;
  S := Z.Start(ZMQSocket_Subscriber);

  // Socket to talk to server
  Writeln('Collecting updates from weather server...');
  S.Connect('tcp://localhost:5556');

  // Subscribe to zipcode, default is NYC, 10001
  filter := '10001';
  if ParamCount > 0 then
    filter := IntToStr(StrToInt(Trim(ParamStr(1))));

  S.Subscribe(filter + ' ');

  // Process 100 updates
  update_count := 0;
  total_temp := 0;
  while update_count < 100 do
  begin
    Inc(update_count);
    update := S.ReceiveString;
    Decode(update, zipcode, temperature, relhumidity);
    total_temp := total_temp + temperature;
  end;

  Writeln('Average temperature for zipcode ', zipcode, ' was ', Trunc(total_temp / update_count), '�F');
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
