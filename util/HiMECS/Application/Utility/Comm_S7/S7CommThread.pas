unit S7CommThread;

interface

uses Windows, classes, Forms, S7CommConst, MyKernelObject, CopyData,
  NoDaveComponent;

Type
  TS7CommThread = class(TThread)
    FOwner: TForm;
    FQueryInterval: integer;//ModBus Query ����(mSec)
    FStopComm: Boolean;//��� �Ͻ� ���� = True
    FTimeOut: integer;//��� Send�� ���� Send���� ����ϴ� �ð�(mSec) - INFINITE
    FSendBuf: array[0..255] of byte;//RTU Mode���� ����ϴ� �۽� ����
    FBufStr: String;//ASCII Mode���� ���Ǵ� ���Ź���
    FReqByteCount: integer;//RTU Mode�϶� Send�ÿ� �䱸 ����Ʈ ���� �˾ƾ� üũ����

    procedure OnNoDaveRead(Sender: TObject);
    procedure SetStopComm(Value: Boolean);
    procedure SetTimeOut(Value: integer);
    procedure SetQueryInterval(Value: integer);
  protected
    procedure Execute; override;

  public
    FEventHandle: TEvent;//Send�� �� Receive�Ҷ����� Wait�ϴ� Event
    FSendCommandList: TStringList;//Modbus ��� ��� ����Ʈ
    FNoDave: TNoDave;

    constructor Create(AOwner: TForm);
    destructor Destroy; override;
    procedure InitS7Comm;
    procedure SendQuery;
    procedure SendQuery2;
    procedure SendBufClear;
    procedure SetCommParam(AIndex: integer);
  published
    property StopComm: Boolean read FStopComm write SetStopComm;
    property TimeOut: integer read FTimeOut write SetTimeOut;
    property QueryInterval: integer read FQueryInterval write SetQueryInterval;
  end;

implementation

uses CommonUtil, HiMECSConst;

{ TModBusComThread }

constructor TS7CommThread.Create(AOwner: TForm);
begin
  inherited Create(True);

  FOwner := AOwner;
  FStopComm := False;
  FEventHandle := TEvent.Create('',False);
  FSendCommandList := TStringList.Create;
  FTimeOut := 3000; //3�� ��ٸ� �Ŀ� ��� ����� ������(Default = INFINITE)
  FBufStr := '';

  //Resume;
end;

destructor TS7CommThread.Destroy;
begin
  FEventHandle.Free;
  FSendCommandList.Free;

  inherited;
end;

procedure TS7CommThread.Execute;
begin
  while not terminated do
  begin
    if FStopComm then
      Suspend;

    Sleep(FQueryInterval);
    SendQuery;
  end;//while
end;

//�����Ʈ �ʱ�ȭ
//PortName = 'Com1'
//ModBusMode = ASCII_MODE
procedure TS7CommThread.InitS7Comm;
begin
  FQueryInterval := QueryInterval;

  FNoDave.OnRead := OnNoDaveRead;
end;

procedure TS7CommThread.OnNoDaveRead(Sender: TObject);
begin
  SendMessage(FOwner.Handle,WM_RECEIVENODAVE, 0, 0);
  //FEventHandle.Pulse;
end;

procedure TS7CommThread.SendBufClear;
begin
  FillChar(FSendBuf, Length(FSendBuf), #0);
end;

procedure TS7CommThread.SendQuery;
var
  i, SendLength, j: integer;
  tmpStr: string;
begin
  //Thread�� Suspend�Ǹ� ����ÿ� Resume�� �ѹ� �� �ֹǷ�
  //����ÿ� �� ��ƾ�� ������� �ʰ� �ϱ� ����
  if StopComm then
    exit;

  for i := 0 to FSendCommandList.Count - 1 do
  begin
    if StopComm then
      exit;

    SendCopyData2(FOwner.Handle, ' ', 1);

    FNoDave.Active := False;
    FNoDave.RepeatReadCount := 1;
    FOwner.Tag := i;
    SetCommParam(i);
    FNoDave.Active := True;
    //FEventHandle.Wait(INFINITE);

    SendCopyData2(FOwner.Handle, FSendCommandList.Strings[i], 1);

    if FEventHandle.Wait(FTimeOut) then
    begin
      if terminated then
        exit;
    end
    else
      Continue;

    //Sleep(FQueryInterval);
  end;//for

end;

procedure TS7CommThread.SendQuery2;
begin
  FNoDave.Active := True;
end;

procedure TS7CommThread.SetCommParam(AIndex: integer);
begin
  with FNoDave do
  begin
    Area := TNoDaveArea(TS7CommBlock(FSendCommandList.Objects[AIndex]).FS7Area);
    DBNumber := TS7CommBlock(FSendCommandList.Objects[AIndex]).FS7DBAddress;
    BufLen := GetDataSize(TS7CommBlock(FSendCommandList.Objects[AIndex]).FS7DataType)*
              TS7CommBlock(FSendCommandList.Objects[AIndex]).FS7Count;
    BufOffs := TS7CommBlock(FSendCommandList.Objects[AIndex]).FS7StartOffset;
  end;
end;

procedure TS7CommThread.SetQueryInterval(Value: integer);
begin
  if FQueryInterval <> Value then
    FQueryInterval := Value;
end;

procedure TS7CommThread.SetStopComm(Value: Boolean);
begin
  if FStopComm <> Value then
  begin
    FStopComm := Value;

    if FStopComm then
      //Suspend
    else
      if Suspended then
        Resume;
  end;
end;

procedure TS7CommThread.SetTimeOut(Value: integer);
begin
  if FTimeOut <> Value then
    FTimeOUt := Value;
end;

end.
