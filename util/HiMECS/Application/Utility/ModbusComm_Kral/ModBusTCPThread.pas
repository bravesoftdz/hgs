unit ModBusTCPThread;

interface

uses Windows, sysutils, classes, Forms, CPort, ModbusComConst, MyKernelObject,
  CopyData, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdModBusClient;

Type
  TModBusTCPThread = class(TThread)
    FOwner: TForm;
    FStoreType: TStoreType; //������(ini or registry)
    FModBusMode: TModBusMode;//ASCII, RTU mode, TCP_WAGO_MODE
    FQueryInterval: integer;//ModBus Query ����(mSec)
    FStopComm: Boolean;//��� �Ͻ� ���� = True
    FTimeOut: integer;//��� Send�� ���� Send���� ����ϴ� �ð�(mSec) - INFINITE
    FRequestTimeOut: integer;//Connect �� ���� ��� �ð�
    FBufStr: String;//ASCII Mode���� ���Ǵ� ���Ź���
    FReqByteCount: integer;//RTU Mode�϶� Send�ÿ� �䱸 ����Ʈ ���� �˾ƾ� üũ����
    FConnected: Boolean;//TCP ����Ǹ� True
    procedure SetStopComm(Value: Boolean);
    procedure SetTimeOut(Value: integer);
    procedure SetQueryInterval(Value: integer);

  protected
    FIdModBusClient: TIdModBusClient;

    procedure Execute; override;

  public
    FIP: string;
    FPort: integer;

    FEventHandle: TEvent;//Send�� �� Receive�Ҷ����� Wait�ϴ� Event
    FSendCommandList: TStringList;//Modbus ��� ��� ����Ʈ

    constructor Create(AOwner: TForm; AIP: string; APort, AQueryInterval: integer);
    destructor Destroy; override;
    procedure InitComPort(AIP: string; APort: integer; AModBusMode: TModBusMode; AQueryInterval: integer);
    procedure SendQuery;

    procedure DisconnectTCP;
  published
    property StopComm: Boolean read FStopComm write SetStopComm;
    property TimeOut: integer read FTimeOut write SetTimeOut;
    property QueryInterval: integer read FQueryInterval write SetQueryInterval;
  end;

implementation

uses ModbusCom_multidrop, CommonUtil;

{ TModBusComThread }

constructor TModBusTCPThread.Create(AOwner: TForm; AIP: string; APort, AQueryInterval: integer);
begin
  inherited Create(True);

  FOwner := AOwner;
  FStopComm := False;
  FEventHandle := TEvent.Create('',False);
  FSendCommandList := TStringList.Create;
  FTimeOut := 3000; //3�� ��ٸ� �Ŀ� ��� ����� ������(Default = INFINITE)
  FBufStr := '';
  QueryInterval := AQueryInterval;
  FModBusMode := MODBUSTCP_MODE;
  FIdModBusClient := TIdModBusClient.Create(AOwner);
  //InitComPort(AIP, APort, FModBusMode, 1000);
  //Resume;
end;

destructor TModBusTCPThread.Destroy;
begin
  DisconnectTCP;
  FreeAndNil(FIdModBusClient);
  FEventHandle.Free;
  FSendCommandList.Free;

  inherited;
end;

procedure TModBusTCPThread.DisconnectTCP;
begin
  if FConnected then
  begin
    FIdModBusClient.Disconnect;
    FConnected := False;
  end;
end;

procedure TModBusTCPThread.Execute;
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
//ModBusMode = TCP_WAGO_MODE
procedure TModBusTCPThread.InitComPort(AIP: string; APort: integer; AModBusMode: TModBusMode; AQueryInterval: integer);
var ret: LongInt;
begin
  Suspend;

  FIP :=AIP;
  FModBusMode := AModBusMode;
  FPort:= APort;

  FStoreType := stIniFile;
  FQueryInterval := AQueryInterval;

  if FConnected then
    DisconnectTCP;

  //��� ����
  if AIP = '' then
  begin
    SendCopyData2(FOwner.Handle, 'IP �ּҰ� ����!', 1);
    exit;
  end;

  FIdModBusClient.Host := FIP;
  //Modbustcp Default Port = 502
  if FPort <> 0 then
    FIdModBusClient.Port := FPort;

  SendCopyData2(FOwner.Handle, 'TCP Init...', 1);

  FIdModBusClient.Connect;

  FIdModBusClient.BaseRegister := 0;

  FConnected := True;
  SendCopyData2(FOwner.Handle, 'TCP Connect Success!', 1);

  resume;
end;

procedure TModBusTCPThread.SendQuery;
var
  BufWord: Array[0..255] of Word;
  BufBool: Array[0..255] of Boolean;
  i,j, SendLength: integer;
  tmpStr: string;
  LFunctionCode,
  LAddress,
  LCount: integer;
  LBool: Boolean;
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

    //MODBUSTCP Mode�� ���
    if FModBusMode = MODBUSTCP_MODE then
    begin
      //tmpStr := FSendCommandList.Strings[i];
      //LFunctionCode := StrToInt(Copy(tmpStr, 4,2));
      //LAddress := HexToInt(Copy(tmpStr, 6,4));
      //LCount := HexToInt(Copy(tmpStr, 10,4));

      //���� �ʱ�ȭ
      FillChar(BufWord, SizeOf(BufWord),0);
      FIdModBusClient.UnitID := TModbusTCP_Command(FSendCommandList.Objects[i]).FSlaveAddress;
      LFunctionCode := TModbusTCP_Command(FSendCommandList.Objects[i]).FFunctionCode;
      LAddress := TModbusTCP_Command(FSendCommandList.Objects[i]).FStartAddress;
      LCount := TModbusTCP_Command(FSendCommandList.Objects[i]).FDataCountWord;

      TModbusComF(FOwner).FRecvWordBuf[0] := LFunctionCode;//Function Code
      TModbusComF(FOwner).FRecvWordBuf[1] := LCount;//Data Count
      SendCopyData2(FOwner.Handle, FSendCommandList.Strings[i], 1);

      case LFunctionCode of
        1 :FIdModBusClient.ReadCoils(LAddress, LCount, BufBool);
        2 :FIdModBusClient.ReadInputBits(LAddress, LCount, BufBool);
        3 :FIdModBusClient.ReadHoldingRegisters(LAddress, LCount, BufWord);
        4 :FIdModBusClient.ReadInputRegisters(LAddress, LCount, BufWord);
        16:begin
          if TModbusTCP_Command(FSendCommandList.Objects[i]).FRepeatCount = -1 then
            FIdModBusClient.WriteRegisters(LAddress, TModbusTCP_Command(FSendCommandList.Objects[i]).FBufferWord)
          else
          if TModbusTCP_Command(FSendCommandList.Objects[i]).FRepeatCount > 0 then
          begin
            FIdModBusClient.WriteRegisters(LAddress, TModbusTCP_Command(FSendCommandList.Objects[i]).FBufferWord);
            Dec(TModbusTCP_Command(FSendCommandList.Objects[i]).FRepeatCount);
          end
          else
          if TModbusTCP_Command(FSendCommandList.Objects[i]).FRepeatCount = 0 then
          begin
            TModbusTCP_Command(FSendCommandList.Objects[i]).Free;
            FSendCommandList.Delete(i);
          end;
        end;
      end;

      LFunctionCode := TModbusTCP_Command(FSendCommandList.Objects[i]).FFunctionCode;
      LCount := TModbusTCP_Command(FSendCommandList.Objects[i]).FDataCountWord;

      if (LFunctionCode = 1) or (LFunctionCode = 2) then
      begin
        SendLength := LCount div 16;
        if (LCount mod 16) > 0 then
          inc(SendLength);

        for j := 0 to LCount - 1 do
          TModbusComF(FOwner).FRecvBoolBuf[j] := BufBool[j];
      end
      else
      if (LFunctionCode = 3) or (LFunctionCode = 4) then
      begin
        for j := 2 to LCount + 1 do
          TModbusComF(FOwner).FRecvWordBuf[j] := BufWord[j-2];
      end;

      TModbusComF(FOwner).CurrentCommandIndex := i;
      //��û�� ������ŭ ���ۿ� ���� Main ���� �޼��� ����
      SendMessage(TModbusComF(FOwner).Handle,WM_RECEIVEWORD_TCP, 0, 0);
    end;

    if FEventHandle.Wait(FTimeOut) then
    begin
      if terminated then
       exit;
    end
    else
      Continue;

    Sleep(FQueryInterval);
  end;//for

end;

procedure TModBusTCPThread.SetQueryInterval(Value: integer);
begin
  if FQueryInterval <> Value then
    FQueryInterval := Value;
end;

procedure TModBusTCPThread.SetStopComm(Value: Boolean);
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

procedure TModBusTCPThread.SetTimeOut(Value: integer);
begin
  if FTimeOut <> Value then
    FTimeOUt := Value;
end;

end.
