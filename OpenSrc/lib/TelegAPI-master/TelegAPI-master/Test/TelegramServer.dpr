program TelegramServer;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  TelegaPi.Bot,
  TelegaPi.Types,
  System.SysUtils;

var
  Telegram: TTelegramBot;

Procedure UpdateHandler(Const Update: TTelegaUpdate);
var
  InputMessage: String;
Begin
  Writeln('--> ', Update.Message.Text);
  if Update.Message.Text.ToLower.Contains('������') then
    Telegram.sendTextMessage(Update.Message.Chat.ID, '� ���� ������!')
End;

procedure ReadUpdates;

var
  Updates: TArray<TTelegaUpdate>;
  MessageOffset: Integer;
  Update: TTelegaUpdate;
Begin
  MessageOffset := 0;
  while True do
  begin
    (* �������� ����� �������� �� ������ *)
    Sleep(1000);
    (* ����������� ���������� � ������� *)
    Updates := Telegram.getUpdates(MessageOffset, 100, 1000);
    (* ���� ���������� ��� - ����������� ������ *)
    if Length(Updates) = 0 then
      Continue;
    (* ��� ���������� �������� � ��������� UpdateHandler *)
    for Update in Updates do
    begin
      UpdateHandler(Update);
    end;
    MessageOffset := Update.ID + 1;
  end;
End;

begin
  Telegram := TTelegramBot.Create({$I telegaToken.inc});
  try
    { TODO -oUser -cConsole Main : Insert code here }

    ReadUpdates;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
  Telegram.Free;

end.
