﻿unit TelegAPi.RegisterIDE;

interface

procedure Register;

implementation

{ /$DEFINE REG_IN_LOAD }

uses
{$IFDEF REG_IN_LOAD}
  VCL.Graphics,
  ToolsAPI,
{$ENDIF}
  System.Classes,
  {Add new components here}

  TelegAPi.Bot;

{$IFDEF REG_IN_LOAD}
{$ENDIF}

procedure Register;
Begin
{$IFDEF REG_IN_LOAD}
  RegisterWithSplashScreen;
{$ENDIF}
  RegisterComponents('Telegram', [TTelegramBot]);
End;

end.
