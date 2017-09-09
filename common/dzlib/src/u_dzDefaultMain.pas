{GXFormatter.config=twm}
unit u_dzDefaultMain;

{$I jedi.inc}

// If you define ConsoleOnly, the usage and parameter error messages will only be written
// to the console window and not also shown as a message box.
// This only has any effect, if the cond. define Console is also defined. }
{.define ConsoleOnly}

// Regarding the usage of {$IFDEF CONSOLE} and the IsConsole function, see
// http://blog.dummzeuch.de/2014/04/10/delphi-console-applications/

interface

uses
  Windows,
  SysUtils,
  Classes,
  u_dzTranslator,
  u_dzGetOpt;

type
  {: An "application" class for console programs.
     To use this class, assign a descendant of TDefaultMain to the MainClass variable and
     call Main in the project's project file like this:
     @longcode(
     begin
       Application.Initialize;
       Application.MainFormOnTaskbar := true; // optional for Delphi >= 2007
       Application.Title := '<your application's title here>';
       MainClass := TMyProgMain;
       System.ExitCode := Main;
     end.
     )
     Your descendant should override at least the following methods
     * InitCmdLineParser
     * doExecute
     @longcode(
     type
       TMyProgMain = class(TDefaultMain)
       protected
         procedure InitCmdLineParser; override;
         function doExecute: integer; override;
       end;
     ) }
  TDefaultMain = class
  private
    function GetProgName: string;
    function GetExeName: string;
    procedure ShowCmdLine;
    procedure doUsage(const _Error: string = '');
  protected
    ///<symmary>
    /// stores the exit code </summary>
    FExitCode: integer;
    ///<summary>
    /// Created in InitCmdLineParser, allows reading the parameters </summary>
    FGetOpt: TGetOpt;
    ///<summary>
    /// Initializes FGetOpt with a parser, should be overridden, but make
    /// sure you call inherited if you want to have the --help option </summary>
    procedure InitCmdLineParser; virtual;
    ///<summary>
    /// Shows a short help generated by the TGetOpt and exits the program by calling
    /// SysUtils.Abort.
    /// @param Error is an optional error message, which is displayed if not empty </summary>
    procedure Usage(const _Error: string = ''); virtual;
    ///<summary>
    /// Calls the Parse method of the commandline parser. Afterwards the parameters
    /// and options can be accessed using the FGetOpt methods and properties.
    /// If there is an error during parsing it automatically calls Usage with
    /// the error message. If a help option (-?, -h or -Help) is found, usage
    /// will be called without an error message. </summary>
    procedure ParseCmdLine; virtual;
    ///<summary>
    /// This method should be overridden to implement the actual program functionality.
    /// It is called after the commandline has ben parsed so you can be sure that
    /// the parameters are OK.
    /// @returns the exit code for the program </summary>
    function doExecute: integer; virtual;
  public
    ///<summary>
    /// Creates a TDefaultMain instance and sets the exit code to 1 (=error)
    /// Also does a very simple parsing of the commandline to determine whether
    /// the --StartupLog option was given and initializes logging, if it was </summary>
    constructor Create; virtual;
    ///<summary>
    /// Frees a TDefaultMain instance and writes the program end into the log </summary>
    destructor Destroy; override;
    ///<summary>
    /// Call this method after the instance of TDefaultMain has been created.
    /// It initializes the commandline parser, executes it on the given
    /// commandline and calls doExecute within a try..except block.
    /// If doExecute raises an exception it will write an error message to the
    /// console or show an error dialog and set the exit code to 1 (=error).
    /// If doExecute exits normally it uses the result as exit code.
    /// @returns the exit code for the program </summary>
    function Execute: integer; virtual;
    ///<summary>
    /// The programm name that was used to start this application </summary>
    property ProgName: string read GetProgName;
    ///<summary>
    /// The full name of the exectutable </summary>
    property ExeName: string read GetExeName;
  end;

type
  ///<summary>
  /// Class-Type for the global variable MainClass </summary>
  TMainClass = class of TDefaultMain;

var
  ///<summary>
  /// Global variable that points to the main class. This variable is used in
  /// @link(Main) to create a TDefaultMain descendant and exeute it. </summary>
  MainClass: TMainClass = TDefaultMain;

  ///<summary>
  /// Creates an instance of MainClass, calls its execute method and returns
  /// the exit code.
  /// @returns the exit code for the program </summary>
function Main: integer;

implementation

uses
{$IFNDEF CONSOLE}
  Dialogs,
  Forms,
  w_dzDialog, // libs\dzlib\forms
  w_dzUsage,
{$ENDIF CONSOLE}
  u_dzOsUtils,
  u_dzLogging;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

constructor TDefaultMain.Create;
const
  STARTUP_LOG = '--startuplog=';
var
  s: string;
  p: integer;
begin
  inherited;
  // default: error
  FExitCode := 1;

  s := GetCommandLine;
  s := LowerCase(s);
  p := Pos(STARTUP_LOG, s);
  if p > 0 then begin
    s := Copy(s, p + Length(STARTUP_LOG));
    p := Pos(' ', s);
    if p > 0 then
      s := Copy(s, 1, p - 1);
    SetGlobalLogger(TFileLogger.Create(s));
  end;
  FGetOpt := TGetOpt.Create();
end;

destructor TDefaultMain.Destroy;
begin
  FreeAndNil(FGetOpt);
  LogInfo('Program finished.');
  inherited;
end;

function TDefaultMain.doExecute: integer;
begin
  Windows.MessageBox(0, PChar(_('This program does nothing yet.')), PChar(ProgName), MB_ICONINFORMATION + MB_OK);
  Result := 0;
end;

procedure TDefaultMain.doUsage(const _Error: string = '');
var
  s: string;
  Examples: string;
  i: Integer;
  Msg: string;
begin
  Examples := '';
  for i := 0 to FGetOpt.ExampleCount - 1 do begin
    Examples := Examples
      + Format(_('Example %d:'), [i + 1]) + #13#10
      + FGetOpt.GetExample(i) + #13#10
      + #13#10;
  end;
  if _Error <> '' then begin
    s := Format(_('Error: %s'), [_Error]) + #13#10
      + _('When called as:') + #13#10
      + FGetOpt.CmdLine + #13#10
      + #13#10
      + _('Help follows:') + #13#10
      + #13#10;
    LogError(_Error);
  end;
  Msg := s + Format(
    _('Synopsis: %s %s') + #13#10#13#10
    + _('Parameters:') + #13#10
    + '%s'#13#10#13#10
    + _('Options:') + #13#10
    + '%s'#13#10
    + '%s',
    [FGetOpt.ProgName, FGetOpt.GetCmdLineDesc, FGetOpt.GetParamHelp, FGetOpt.GetOptionHelp,
    Examples]);
{$IFDEF CONSOLE}
  WriteLn(ErrOutput, CharToOem(Msg));
{$IFNDEF ConsoleOnly}
  Windows.MessageBox(0, PChar(Msg), PChar(ProgName), MB_ICONEXCLAMATION + MB_OK);
{$ENDIF}
{$ELSE}
  Tf_dzUsage.Execute(nil, Application.Title, _Error, FGetOpt.CmdLine,
    FGetOpt.ProgName + ' ' + FGetOpt.GetCmdLineDesc,
    FGetOpt.GetParamHelp, FGetOpt.GetOptionHelp, Examples);
{$ENDIF}
end;

procedure TDefaultMain.Usage(const _Error: string = '');
begin
  doUsage(_Error);
  FExitCode := 1;
  SysUtils.Abort;
end;

{.$DEFINE console}

procedure TDefaultMain.ShowCmdLine;
begin
  doUsage('--ShowCmdLine was passed (no error)');
end;

procedure TDefaultMain.InitCmdLineParser;
begin
  FGetOpt.RegisterHelpOptions;
  FGetOpt.RegisterOption('StartupLog', _('Write a startup log to the given file.'), true);
  FGetOpt.RegisterOption('ShowCmdLine', _('Show command line as passed to the program.'));
end;

procedure TDefaultMain.ParseCmdLine;
begin
  LogDebug('Cmdline: ' + System.CmdLine);
  try
    FGetOpt.Parse;
  except
    on e: exception do
      Usage(e.Message);
  end;
  if FGetOpt.HelpOptionFound then
    Usage;
  if FGetOpt.OptionPassed('ShowCmdLine') then
    ShowCmdLine;
end;

function TDefaultMain.Execute: integer;
var
  s: string;
begin
  InitCmdLineParser;
  ParseCmdLine;
  try
    FExitCode := DoExecute;
  except
    on e: EAbort do begin
      // we do not want to show an error if the code called Abort because this
      // is supposed to be a silent exception. So we log it and terminate with
      // an exit code of 1
      LogError(e.Message + '(' + e.ClassName + ')');
      FExitCode := 1;
    end;
    on e: Exception do begin
      s := 'Exception: ' + e.Message + ' (' + e.ClassName + ')';
      LogError(s);
{$IFDEF CONSOLE}
      WriteLn(s);
{$ELSE}
      if not IsConsole then
        Tf_dzDialog.ShowException(e)
      else
        WriteLn(ErrOutput, s);
{$ENDIF CONSOLE}
      FExitCode := 1;
    end;
  end;
  Result := FExitCode;
end;

function TDefaultMain.GetExeName: string;
var
  ModuleName: AnsiString;
begin
  SetLength(ModuleName, 255);
  GetModuleFileNameA(MainInstance, PAnsiChar(ModuleName), Length(ModuleName));
  OemToAnsi(PAnsiChar(ModuleName), PAnsiChar(ModuleName));
  ModuleName := PAnsiChar(ModuleName);
  Result := string(ModuleName);
end;

function TDefaultMain.GetProgName: string;
begin
  Result := FGetOpt.ProgName;
end;

function Main: integer;
var
  MainObj: TDefaultMain;
begin
  Result := 1;
  try
    MainObj := MainClass.Create;
    try
      Result := MainObj.Execute;
    finally
      FreeAndNil(MainObj);
    end;
  except
    // Exception handling is done within the MainObj. If something gets here
    // it cannot be handled anyway.
    // - but maybe log it? -- AS
    on e: Exception do begin
      LogError('Exception in function Main: ' + e.Message + ' ' + e.ClassName);
    end;
  end;
  if (DebugHook <> 0) and IsConsole then begin
    Write('Exit Code: ', Result, ' -- press Enter');
    Readln;
  end;
end;

end.
