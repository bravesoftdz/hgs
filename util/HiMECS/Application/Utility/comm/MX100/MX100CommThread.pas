unit MX100CommThread;

interface

uses Windows, SysUtils, classes, Forms, MyKernelObject, CopyData, Dialogs,
    UnitDAQMX;

type
  TMX100CommThread = class(TThread)
    FOwner: TForm;
    //FStoreType: TStoreType; //������(ini or registry)
    FQueryInterval: integer;//��� Query ����(mSec)
    FStopComm: Boolean;//��� �Ͻ� ���� = True
    FTimeOut: integer;//��� Send�� ���� Send���� ����ϴ� �ð�(mSec) - INFINITE
    FErrorMessage: TStringList;

    procedure SetStopComm(Value: Boolean);
    procedure SetTimeOut(Value: integer);
    procedure SetQueryInterval(Value: integer);

  protected
    procedure Execute; override;

  public
    FEventHandle: TEvent;//Send�� �� Receive�Ҷ����� Wait�ϴ� Event
    FSendCommandList: TStringList;//MX100 ��� ��� ����Ʈ
    FMX100Connection: TMX100Connection;
    FMX100Connected: boolean;//MX100 ���� ���� ����
    FMX100ID: integer; //MX100 ��ſ� �ʿ��� ID
    FPingOK: boolean;//ping ������ true
    FIsInitExec: Boolean;//�ʱ�ȭ ���� ����

    FStartNo1  : MXDataNo;
    FEndNo1    : MXDataNo;
    FDataNo1   : MXDataNo;
    FChinfo1   : MXChInfo;
    FDatainfo1 : MXDataInfo;
    FDatetime1 : MXDateTime;
    FUserTime1 : MXUserTime;
    FFlag: LongInt;

    constructor Create(AOwner: TForm; AIpAddress: Ansistring; AUserName: Ansistring);
    destructor Destroy; override;
    procedure SendQuery;
    function QueryData(AMaxLength: integer; AMsg: Ansistring; var Abuf: array of Ansichar):Boolean;
    procedure InitVar(APMID: integer);
    procedure SendItemSettings;
    procedure DispMX100Error(AErrNo: integer);
    procedure InitErrorMsg;
    function GetMX100Data(AHandle: integer): boolean;
  published
    property StopComm: Boolean read FStopComm write SetStopComm;
    property TimeOut: integer read FTimeOut write SetTimeOut;
    property QueryInterval: integer read FQueryInterval write SetQueryInterval;
  end;

implementation

uses MX100Const;

{ TMX100CommThread }

constructor TMX100CommThread.Create(AOwner: TForm;AIpAddress: Ansistring; AUserName: Ansistring);
begin
  inherited Create(True);

  FMX100Connection := TMX100Connection.Create(0,'');
  FMX100Connection.IpAddress := AIpAddress;
  {$IFDEF WT500}
  FMX100Connection.ConnectAddress := FMX100Connection.IpAddress;
  FMX100Connection.ConnectType := 8;//4; (for MX100)
  {$ELSE}
  FMX100Connection.ConnectAddress := FMX100Connection.IpAddress + ',' + AUserName + ',';//(for MX100)
  FMX100Connection.ConnectType := 4;//TM_CTL_ETHER;//8;//4; (for MX100)
  {$ENDIF}

  FOwner := AOwner;
  FStopComm := False;
  FEventHandle := TEvent.Create('MX100CommEvent'+FMX100Connection.IpAddress,False);
  SendCopyData2(FOwner.Handle, 'FEventHandle: ' + FMX100Connection.IpAddress, 1);
  FSendCommandList := TStringList.Create;
  FErrorMessage := TStringList.Create;
  FTimeOut := INFINITE;//3000; //3�� ��ٸ� �Ŀ� ��� ����� ������(Default = INFINITE)
  FIsInitExec := False;
  FQueryInterval := 0;
end;

destructor TMX100CommThread.Destroy;
begin
  FreeAndNil(FErrorMessage);
  SendCopyData2(FOwner.Handle, 'FreeAndNil(FErrorMessage)', 1);
  FreeAndNil(FEventHandle);//.Free;
  SendCopyData2(FOwner.Handle, 'FreeAndNil(FEventHandle)', 1);
  FreeAndNil(FSendCommandList);//.Free;
  SendCopyData2(FOwner.Handle, 'FreeAndNil(FSendCommandList)', 1);
  //FMX100Connection.Finish;
  //SendCopyData2(FOwner.Handle, 'FMX100Connection.Finish', 2);
  //FreeAndNil(FMX100Connection);//.Finish;
  FMX100Connection.destroy;
  SendCopyData2(FOwner.Handle, 'FreeAndNil(FMX100Connection)', 1);
  //ShowMessage('bbb');
  //inherited;

end;

procedure TMX100CommThread.InitVar(APMID: integer);
begin
  InitErrorMsg;

  if FMX100Connected then
  begin
    FMX100Connected := False;
    FMX100Connection.Finish;
  end;

  FMX100Connection.ConnectID := APMID;

  if FPingOK then
  begin
    if FMX100Connection.Initialize = 0 then
    begin
      FMX100Connected := True;
      SendCopyData2(FOwner.Handle, 'MX100 Connect Succeed',1);
    end
    else
    begin
      FMX100Connected := False;
      FMX100Connection.Finish;
      SendCopyData2(FOwner.Handle, 'MX100 Connect Failed', 2);
      exit;
    end;//else
  end;
end;

procedure TMX100CommThread.SendItemSettings;
var
  Li: integer;
  LMsg: Ansistring;
  LBuf: TDynaArray;
begin
  if FPingOK and FMX100Connected then
  begin
    LMsg := Ansistring(':NUMERIC:FORMAT ASCII');
    SendCopyData2(FOwner.Handle,LMsg,0);
    Li := FMX100Connection.Send(LMsg);

    if Li <> 0 then
      DispMX100Error(FMX100Connection.GetLastError());

    LMsg := Ansistring(':NUMERIC:NORMAL:NUMBER 12');
    SendCopyData2(FOwner.Handle,LMsg,0);
    Li := FMX100Connection.Send(LMsg);

    if Li <> 0 then
      DispMX100Error(FMX100Connection.GetLastError());

    //LMsg := Ansistring(':NUMERIC:NORMAL:ITEM1 URMS,1;ITEM2 URMS,2;ITEM3 URMS,3;ITEM4 IRMS,1;ITEM5 IRMS,2;ITEM6 IRMS,3;ITEM7 FU,1;ITEM8 LAMBDA,1;ITEM9 P,SIGMA;ITEM10 S,SIGMA;ITEM11 Q,SIGMA');
    LMsg := Ansistring(':NUMERIC:NORMAL:ITEM1 URMS,1;ITEM2 URMS,2;ITEM3 URMS,3;ITEM4 IRMS,1;ITEM5 IRMS,2;ITEM6 IRMS,3;ITEM7 FU,1;ITEM8 LAMBDA,SIGMA;ITEM9 P,SIGMA;ITEM10 S,SIGMA;ITEM11 Q,SIGMA;ITEM12 F1');
    SendCopyData2(FOwner.Handle,LMsg,0);
    Li := FMX100Connection.Send(LMsg);

    if Li <> 0 then
      DispMX100Error(FMX100Connection.GetLastError());
  end
  else
    SendCopyData2(FOwner.Handle, 'SendItemSettings: MX100 not connected!', 2);
end;

procedure TMX100CommThread.Execute;
begin
  while not terminated do
  begin

    if terminated then
      exit;

    if FStopComm then
      Suspend;

    if FEventHandle.Wait(FTimeOut) then
    begin
      if terminated then
        exit;

      if not FPingOK then
      begin
        SendCopyData2(FOwner.Handle, 'FPingOK Failure!!!', 2);
        continue;
      end;

      if FIsInitExec then
      begin
        InitVar(1);//FMX100ID

        if FMX100Connected then
        begin
          SendItemSettings;
          FIsInitExec := False;
        end;//if
      end;//if

      //Sleep(FQueryInterval);
      if FMX100Connected then
        SendQuery
      else
        SendCopyData2(FOwner.Handle, 'Not connect to MX100', 1);
    end;
  end;//while
end;

function TMX100CommThread.GetMX100Data(AHandle: integer): boolean;
var
  LErrorCode1, LErrorCode2, i: integer;
  LValue1: integer;
  LChNo1: string;
begin
  if FStopComm then exit;

  LErrorCode1 := getFIFODataNoMX(AHandle, FIFONO, FStartNo1, FEndNo1);

  if (isDataNoVBMX(FStartNo1) and isDataNoVBMX(FEndNo1)) = 1 then
  begin
    LErrorCode1 := talkFIFODataVBMX(AHandle, FIFONO, FStartNo1, FEndNo1);

    while (FFlag and DAQMX_FlAG_ENDDATA) = 0 do
    begin
      if FStopComm then exit;

      LErrorCode1 := getTimeDataMX(AHandle, FDataNo1, FDatetime1, FUserTime1, FFlag);

      if LErrorCode1 <> 0 then
      begin
          Break;
      end;

      Application.ProcessMessages;
    end;

    FFlag := 0;

      //while (giFlag and DAQMX_FlAG_ENDDATA) = 0 do
      for i := 1 to 60 do
      begin
        if FStopComm then exit;

        LErrorCode2 := getChDataMX(AHandle, FDataNo1, FChinfo1, FDatainfo1, FFlag);

        if LErrorCode2 <> 0 then
        begin
            //WriteDebugString( Format('MX100-Error2:%d', [giErrorCode2]) );
            Break;
        end;

        if FChinfo1.aFIFOIndex = INDEXNO Then
        begin
          LValue1 := FDatainfo1.aValue;

          if LValue1 >= 32767 then
          begin
            LValue1 := 0
          end
          else if LValue1 <= -32767 then
          begin
            LValue1 := 0;
          end;

          try
            LChNo1 := Format('%.2d', [FChinfo1.aChID.aChNo]);
            if FChinfo1.aChID.aChNo = I  then
              stringList.Add(varToStr(LValue1))
            else
              stringList.Add('0');
            //gStringList1.Values['[' + nowDT + ']' + sChNo1 ] := Format('%d', [nValue1]);
            //gStringList.Add( Format('%s=%d', [sChNo, nValue]) );
          except

          end;
        end;

        Application.ProcessMessages;
        //Sleep(5);
      end;

      FFlag := 0;
    end;

    if FStopComm then exit;

    Result :=  (not (LErrorCode1 in [0, 11])) or (not (LErrorCode2 in [0, 11]));
end;

//FSendCommandList �� �ִ� ��ɾ MX100�� ������
procedure TMX100CommThread.SendQuery;
var
  i: integer;
  LMsg: Ansistring;
  //LBuf: TDynaArray;
begin
  //Thread�� Suspend�Ǹ� ����ÿ� Resume�� �ѹ� �� �ֹǷ�
  //����ÿ� �� ��ƾ�� ������� �ʰ� �ϱ� ����
  if StopComm then
    exit;

  if FPingOK and FMX100Connected then
  begin
    for i := 0 to FSendCommandList.Count - 1 do
    begin
      if StopComm then
        exit;

      //LBuf := nil;
      //SetLength(LBuf, 15*11);
      SendCopyData2(FOwner.Handle, FSendCommandList.Strings[i], 0);
      LMsg := FSendCommandList.Strings[i];
      if not QueryData(15*11, LMsg, FMX100Connection.m_aData) then
      //if false then
      begin
        SendCopyData2(FOwner.Handle, 'QueryData Failure!!!', 1);
        FIsInitExec := True;
        //LBuf := nil;
        exit;
      end;//if
      LMsg := Ansistring(FMX100Connection.m_aData);//LBuf);
      LMsg := GetToken(LMsg, #10);
      //data�� ��쿡�� ������ �Ķ���Ϳ� 4�� ������.
      SendCopyData2(FOwner.Handle, LMsg, 4);
      //LBuf :=nil;
      {if FEventHandle.Wait(FTimeOut) then
      begin
        if terminated then
          exit;
      end
      else
        Continue;
      }
      Sleep(FQueryInterval);
    end;//for
  end
  else
  begin
{    SetLength(LBuf, 15*11);
    FillChar(LBuf,15*11, '0');
    LMsg := String(LBuf);
    LMsg := GetToken(LMsg, #10); }
    //MX100�� ������ �ȵ� ��쿡�� ������ �Ķ���Ϳ� 5�� ������.(����Ÿ �ʱ�ȭ ������)
    SendCopyData2(FOwner.Handle, 'Can''t connect to MX100', 5);
    SendCopyData2(FOwner.Handle, 'Can''t connect to MX100', 1);
  end;
end;

//AMsg ��ɾ MX100�� ������
function TMX100CommThread.QueryData(AMaxLength: integer; AMsg: Ansistring; var Abuf: array of Ansichar):Boolean;
var
  Li: integer;
  LRealLength: integer;
begin
  //Send Command.
  Li := FMX100Connection.Send(AMsg);

  if Li <> 0 then
  begin
    DispMX100Error(Li);
    Result := False;
    exit;
  end;//if

  //Queries Data.
  //SetLength(Abuf, AMaxLength);
  Li := FMX100Connection.Receive(@Abuf[0], AMaxLength, @LRealLength );

  if Li <> 0 then
  begin
    DispMX100Error(Li);
    Result := False;
    exit;
  end;//if
  Result := True;
end;

procedure TMX100CommThread.SetQueryInterval(Value: integer);
begin
  if FQueryInterval <> Value then
    FQueryInterval := Value;
end;

procedure TMX100CommThread.SetStopComm(Value: Boolean);
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

procedure TMX100CommThread.SetTimeOut(Value: integer);
begin
  if FTimeOut <> Value then
    FTimeOUt := Value;
end;

procedure TMX100CommThread.DispMX100Error(AErrNo: integer);
var
  Li: integer;
begin
  Li := 0;

  if AErrNo = 0 then
    SendCopyData2(FOwner.Handle, 'getting detail error failed.', 1)
  else
  begin
    //while ((2 shl Li) <> AErrNo) do
    //  inc(Li);

    SendCopyData2(FOwner.Handle, FErrorMessage.Strings[AErrNo], 1);
  end;
end;

procedure TMX100CommThread.InitErrorMsg;
begin
  FErrorMessage.Add('Device not found: Check the wiring.');
  FErrorMessage.Add('Connection to device failed: Check the wiring.');
  FErrorMessage.Add('Device not connected: Connect the device using the initialization function.');
  FErrorMessage.Add('Device already connected: Two connections cannot be opened.');
  FErrorMessage.Add('Incompatible PC: Check the hardware you are using.');
  FErrorMessage.Add('Illegal parameter: Check parameter type etc.');
  FErrorMessage.Add('');
  FErrorMessage.Add('Send error: Check the wiring, address, and ID.');
  FErrorMessage.Add('Receive error: Check whether an error occurred on the device.');
  FErrorMessage.Add('Received data not block data');
  FErrorMessage.Add('System error: There is a problem with the operating environment.');
  FErrorMessage.Add('Illegal device ID: Use the ID of the device acquired by the initialization function.');
end;

end.
