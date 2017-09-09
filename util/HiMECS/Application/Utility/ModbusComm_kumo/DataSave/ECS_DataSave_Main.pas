unit ECS_DataSave_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Menus, DataSaveConst, ComCtrls,
  IPCThrd_ECS_kumo, DataSave2FileThread, DataSave2DBThread, SyncObjs,inifiles,
  DataSaveConfig, IPCThrdMonitor_ECS_kumo, IPCThrdMonitor_Dynamo, DeCAL,
  janSQL, commonUtil, IPCThrd_dynamo;

type
  TDisplayTarget = (dtSendMemo, dtRecvMemo, dtStatusBar);
  TDataSaveMain = class(TForm)
    MainMenu1: TMainMenu;
    FILE1: TMenuItem;
    HELP1: TMenuItem;
    Timer1: TTimer;
    Protocol: TMemo;
    StatusBar1: TStatusBar;
    CB_Active: TCheckBox;
    Connect1: TMenuItem;
    Disconnect1: TMenuItem;
    Close1: TMenuItem;
    Option1: TMenuItem;
    Help2: TMenuItem;
    N1: TMenuItem;
    About1: TMenuItem;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RB_byevent: TRadioButton;
    CB_DBlogging: TCheckBox;
    CB_CSVlogging: TCheckBox;
    RB_byinterval: TRadioButton;
    ED_interval: TEdit;
    ED_csv: TEdit;
    Label1: TLabel;
    RB_bydate: TRadioButton;
    RB_byfilename: TRadioButton;
//    GLUserShader1: TGLUserShader;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CB_ActiveClick(Sender: TObject);
    procedure Connect1Click(Sender: TObject);
    procedure Disconnect1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure RB_bydateClick(Sender: TObject);
    procedure RB_byfilenameClick(Sender: TObject);
    procedure RB_byeventClick(Sender: TObject);
    procedure RB_byintervalClick(Sender: TObject);
    procedure Option1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure CB_DBloggingClick(Sender: TObject);
  private
    //DB�� ������������ ���� ���������
    FDataSave2DBThread: TDataSave2DBThread; //DB�� ����Ÿ �����ϴ� ��ü
    FHostName: string;//DB Host Name(IP address)
    FDBName: string;  //DB Name(Mysql�� DB Name)
    FLoginID: string;   //Login Name
    FPasswd: string;  //Password
    FSaveDataBuf_Value1: double;
    FSaveDataBuf_Value2: double;

    //CSV ���� ������ ���� ���������///////////////////////////////////////////
    FLogStart: Boolean;  //Log save Start sig.
    FTagNameBuf: string;  //���Ͽ� ������ �����ϱ� ���� ����
    FSaveFileName: string; //����Ÿ�� ������ File �̸�(������ ���� �����)
    FSaveDataBuf: string; //���Ͽ� ������ ����Ÿ�� �����ϴ� ����
    FSaveDBDataBuf: string; //DB�� ������ ����Ÿ�� �����ϴ� ����
    FFileName_Convention: TFileName_Convetion;//���Ͽ� ����ÿ� �����̸��ο� ���
    FDataSave2FileThread: TDataSave2FileThread;//���Ͽ� ����Ÿ �����ϴ� ��ü
    FCSVHeader: string;
    FDynamoHeader:string;
    FDynamoCSVData: string;

    //ECS�� ���� ���� �����
    FECSData: TEventData_ECS_kumo;
    FMapFileName: string;   //Modbus Map ���� �̸�
    FMapFilePath: string;   //Map�� �ִ����� ���
    FAddressMap: DMap;      //Modbus Map ����Ÿ ���� ����ü
    FjanDB : TjanSQL; //text ��� SQL DB
    FHiMap: THiMap;         //Modbus Address ����ü -> �������� ������

    //Dynamo�� ���� ���� �����
    FDynamoData: TEventData_Dynamo;

    //Critical Section ���������///////////////////////////////////////////////
    FCriticalSection: TCriticalSection;

    //ECS�� ���� �Լ� �����
    procedure ReadMapAddress(AddressMap: DMap; MapFileName: string);
    procedure ECS_OnSignal(Sender: TIPCThread_ECS_kumo; Data: TEventData_ECS_kumo);
    procedure Dynamo_OnSignal(Sender: TIPCThread_Dynamo; Data: TEventData_Dynamo);
    procedure UpdateTrace_ECS_kumo(var Msg: TEventData_ECS_kumo); message WM_EVENT_ECS;
    procedure UpdateTrace_Dynamo(var Msg: TEventData_Dynamo); message WM_EVENT_DYNAMO;
    procedure Value2Screen(BlockNo: integer);
    procedure Value2Screen_Analog(Name: string; AValue: Integer; AMaxVal: real);
    procedure Value2Screen_Digital(Name: string; AValue: Integer;
                                    AMaxVal: real; AContact: integer);

    //ini ���� ������ ������ ���� �Լ� �����
    procedure LoadConfigDataini2Form(FSaveConfigF: TSaveConfigF);
    procedure SaveConfigDataForm2ini(FSaveConfigF: TSaveConfigF);
    procedure LoadConfigDataini2Var;
  public
    { Public declarations }
    FFilePath: string;      //������ ������ ���
    FIPCMonitor_ECS_kumo: TIPCMonitor_ECS_kumo;//���� �޸� �� �̺�Ʈ ��ü
    FIPCMonitor_Dynamo: TIPCMonitor_Dynamo;//���� �޸� �� �̺�Ʈ ��ü
    FMonitorStart: Boolean; //Ÿ�̸� ���� �Ϸ��ϸ� True
    FSharedMMName: string;  //���� �޸� �̸�
    FDynamoSharedMMName: string;// Dynamo �����޸� �̸�
    //DB ����� ��� ������ ���� �� DB �Է��ؾ� �ϹǷ� ���� ���ŵ� Block No�� �ʿ�
    FCurrentBlockNo: integer;
    FLastBlockNo: integer;

    procedure SaveData2DB;
    procedure SaveData2File;
    procedure CreateSave2DBThread;
    procedure CreateSave2FileThread;
    procedure DisplayMessage(msg: string; ADspNo: TDisplayTarget);
    procedure DisplayMessage2SB(Msg: string);
    procedure DestroySave2FileThread;
    procedure DestroySave2DBThread;
  end;

var
  DataSaveMain: TDataSaveMain;
//  DataSave_Start: Boolean;

implementation

uses HiMECSConst;

{$R *.dfm}

procedure TDataSaveMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FCriticalSection.Enter;
  FMonitorStart := False;
  try
    if Assigned(FDataSave2FileThread) then
    begin
      FDataSave2FileThread.Terminate;
      FDataSave2FileThread.FDataSaveEvent.Signal;
      FDataSave2FileThread.Free;
    end;//if

    if Assigned(FDataSave2DBThread) then
    begin
      FDataSave2DBThread.Terminate;
      FDataSave2DBThread.FDataSaveEvent.Signal;
      FDataSave2DBThread.Free;
    end;//if

    ObjFree(FAddressMap);
    FAddressMap.free;
    FIPCMonitor_ECS_kumo.Free;
    FIPCMonitor_Dynamo.Free;

  finally
    FCriticalSection.Leave;
  end;//try

  FCriticalSection.Free;
end;

////////////////////////////////////////////////////////////////////////////////
//���α׷� �ʱ�ȭ Timer1Timer ����
procedure TDataSaveMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  ED_CSV.Text := FormatDatetime('yyyymmdd',date)+'.'+'CSV';
  FFilePath := ExtractFilePath(Application.ExeName);

  LoadConfigDataini2Var;

  //IPC Monitor �Լ� �ʱ�ȭ ����
  FIPCMonitor_ECS_kumo := TIPCMonitor_ECS_kumo.Create(0, FSharedMMName, True);
  FIPCMonitor_ECS_kumo.OnSignal := ECS_OnSignal;
  DisplayMessage('Shared Memory: ' + FSharedMMName + ' Created!', dtSendMemo);

  FIPCMonitor_Dynamo := TIPCMonitor_Dynamo.Create(0, FDynamoSharedMMName, True);
  FIPCMonitor_Dynamo.OnSignal := Dynamo_OnSignal;
  DisplayMessage('Shared Memory: ' + FDynamoSharedMMName + ' Created!', dtSendMemo);

  FAddressMap := DMap.Create;
  ReadMapAddress(FAddressMap,FMapFileName);

  CreateSave2FileThread;
end;

//Map address �б� �Լ�
procedure TDataSaveMain.ReadMapAddress(AddressMap: DMap; MapFileName: string);
var
  sqltext: string;
  sqlresult, reccnt, fldcnt: integer;
  i: integer;
  filename, fcode: string;
begin
  if fileexists(MapFileName) then //FFilePath
  begin
    Filename := ExtractFileName(MapFileName);
    FileName := Copy(Filename,1, Pos('.',Filename) - 1);
    FMapFilePath := ExtractFilePath(MapFileName);
    FjanDB :=TjanSQL.create;
    try
      sqltext := 'connect to ''' + FMapFilePath + '''';

      sqlresult := FjanDB.SQLDirect(sqltext);
      //Connect ����
      if sqlresult <> 0 then
      begin
        with FjanDB do
        begin
          sqltext := 'select * from ' + FileName + ' group by cnt';
          sqlresult := SQLDirect(sqltext);
          //Query ����
          if sqlresult <> 0 then
          begin
            //����Ÿ �Ǽ��� 1�� �̻� ������
            if sqlresult>0 then
            begin
              fldcnt := RecordSets[sqlresult].FieldCount;
              //Field Count�� 0 �̸�
              if fldcnt = 0 then exit;

              reccnt := RecordSets[sqlresult].RecordCount;
              //Record Count�� 0 �̸�
              if reccnt = 0 then exit;

              for i := 0 to reccnt - 1 do
              begin
                FHiMap := THiMap.Create;
                with FHiMap, RecordSets[SqlResult].Records[i] do
                begin
                  FName := Fields[0].Value;
                  FDescription := Fields[1].Value;
                  FSid := StrToInt(Fields[2].Value);
                  FAddress := Fields[3].Value;
                  FBlockNo := StrToInt(Fields[4].Value);
                  //kumo ECS�� Value2Screen_ECS_kumo �Լ����� ó���ϱ� ����
                  FUnit := Fields[5].Value;
                  
                  if Fields[5].Value = 'FALSE' then
                  begin
                    FAlarm := False;
                    fcode := '1';
                  end
                  else if Fields[5].Value = 'TRUE4' then
                  begin
                    FAlarm := True;
                    fcode := '4';
                  end
                  else if Fields[5].Value = 'TRUE' then
                  begin
                    FAlarm := True;
                    fcode := '3';
                  end
                  else if Fields[5].Value = 'FALSE3' then
                  begin
                    FAlarm := False;
                    fcode := '3';
                  end;

                  FMaxval := StrToFloatDef(Fields[6].Value, 0.0);
                  FContact := StrToIntDef(Fields[7].Value, 0);
                  FUnit := '';
                  if Uppercase(FName) <> 'DUMMY' then
                    FCSVHeader := FCSVHeader + ',' + FName;
                end;//with
                AddressMap.PutPair([fcode + FHiMap.FAddress,FHiMap]);
              end;//for
            end;

            FDynamoHeader := ',Power,Torque,RPM,Bearing TB Temp,Bearing MTR Temp,';
            FDynamoHeader := FDynamoHeader + 'Water Inlet Temp,Water Outlet Temp,Body1 Press,Body2 Press,';
            FDynamoHeader := FDynamoHeader + 'Inlet Open 1,Inlet Open 2, Outlet Open1, Outlet Open2';
          end
          else
            DisplayMessage(FjanDB.Error, dtSendMemo);
        end;//with
      end
      else
        Application.MessageBox('Connect ����',
            PChar('���� ' + FFilePath + ' �� ���� �� �ٽ� �Ͻÿ�'),MB_ICONSTOP+MB_OK);
    finally
      FjanDB.Free;
    end;
  end
  else
  begin
    sqltext := FileName + '������ ���� �Ŀ� �ٽ� �Ͻÿ�';
    Application.MessageBox('Data file does not exist!', PChar(sqltext) ,MB_ICONSTOP+MB_OK);
  end;
end;
//On signal - Client ���α׷��� ���� �޸𸮿� ������ ����Ȯ��
procedure TDataSaveMain.ECS_OnSignal(Sender: TIPCThread_ECS_kumo; Data: TEventData_ECS_kumo);
var
  i,dcount: integer;
begin
  if not FMonitorStart then
    exit;

  FillChar(FECSData.InpDataBuf[0], High(FECSData.InpDataBuf) - 1, #0);
  FECSData.ModBusMode := Data.ModBusMode;
  
  if Data.ModBusMode = 0 then //ASCII Mode�̸�
  begin
    //ModePanel.Caption := 'ASCII Mode';
    dcount := Data.NumOfData;
    FECSData.NumOfBit := Data.NumOfBit;

    for i := 0 to dcount - 1 do
      FECSData.InpDataBuf[i] := Data.InpDataBuf[i];
  end
  else
  if Data.ModBusMode = 1 then// RTU Mode �̸�
  begin
    //ModePanel.Caption := 'RTU Mode';
    dcount := Data.NumOfData div 2;
    FECSData.NumOfBit := Data.NumOfBit;

    if dcount = 0 then
      Inc(dcount);

    for i := 0 to dcount - 1 do
    begin
      FECSData.InpDataBuf[i] := Data.InpDataBuf2[i*2] ;
      FECSData.InpDataBuf[i] := FECSData.InpDataBuf[i] shl 8 + Data.InpDataBuf2[i*2 + 1];
//      FModBusData.InpDataBuf[i] :=  ;
    end;

    if (Data.NumOfData mod 2) > 0 then
      FECSData.InpDataBuf[i] := Data.InpDataBuf2[i*2] ;
  end;//else

  FECSData.ModBusAddress := Data.ModBusAddress;

  FECSData.NumOfData := dcount;
  FECSData.ModBusFunctionCode := Data.ModBusFunctionCode;

  DisplayMessage2SB(FECSData.ModBusAddress + ' ����Ÿ ����');

  SendMessage(Handle, WM_EVENT_ECS, 0,0);
end;
//On signal���� ���� ������ ����
procedure TDataSaveMain.UpdateTrace_Dynamo(var Msg: TEventData_Dynamo);
begin
  FDynamoCSVData := FloatToStr(FDynamoData.FPower);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FTorque);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FRevolution);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FBrgTBTemp);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FBrgMTRTemp);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FWaterInletTemp);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FWaterOutletTemp);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FBody1Press);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FBody2Press);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FInletOpen1);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FInletOpen2);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FOutletOpen1);
  FDynamoCSVData := FDynamoCSVData + ',' + FloatToStr(FDynamoData.FOutletOpen2);

  DisplayMessage2SB('Dynamo Data ó����...');
end;

procedure TDataSaveMain.UpdateTrace_ECS_kumo(var Msg: TEventData_ECS_kumo);
var
  it: DIterator;
  pHiMap: THiMap;
  i, j, BlockNo: integer;
  tmpStr: string;
  tmpByte, ProcessBitCnt: Byte;
  IsFirst, IsSecond: Boolean;
begin
  BlockNo := 0;
  i := 0;
  j := 0;
  ProcessBitCnt := 0;

  IsFirst := True;
  IsSecond := False;

  tmpStr := IntToStr(FECSData.ModBusFunctionCode) + FECSData.ModBusAddress;
  it := FAddressMap.locate( [tmpStr] );
  SetToValue(it);

  while not atEnd(it) do
  begin
    if i > FECSData.NumOfData - 1 then
      break;

    pHiMap := GetObject(it) as THiMap;

    if (FECSData.ModBusFunctionCode = 3) or (FECSData.ModBusFunctionCode = 4) then
    begin
      pHiMap.FValue := FECSData.InpDataBuf[i];
      Inc(i);
      BlockNo := pHiMap.FBlockNo;
      Advance(it);
    end
    else
    begin
      BlockNo := pHiMap.FBlockNo;
      for i := 0 to FECSData.NumOfData - 1 do
      begin
        tmpByte := Hi(FECSData.InpDataBuf[i]);
        for j := 0 to 7 do
        begin
          pHiMap := GetObject(it) as THiMap;
          if not atEnd(it) then
          begin
            pHiMap.FValue := GetBitVal(tmpByte, j);
            Inc(ProcessBitCnt);
            Advance(it);
          end;
        end;

        tmpByte := Lo(FECSData.InpDataBuf[i]);
        for j := 0 to 7 do
        begin
          pHiMap := GetObject(it) as THiMap;
          if not atEnd(it) then
          begin
            pHiMap.FValue := GetBitVal(tmpByte, j);
            Inc(ProcessBitCnt);
            Advance(it);
          end;
        end;
      end;

      if ((FECSData.NumOfBit div 8) mod 2) > 0 then
      begin
        tmpByte := Lo(FECSData.InpDataBuf[i]);
        for j := 0 to 7 do
        begin
          pHiMap := GetObject(it) as THiMap;
          if not atEnd(it) then
          begin
            pHiMap.FValue := GetBitVal(tmpByte, j);
            Inc(ProcessBitCnt);
            Advance(it);
          end;
        end;
      end;
    end;

  end;//while

  DisplayMessage2SB(FECSData.ModBusAddress + ' ó����...');

  //���ŵ� ����Ÿ�� ȭ�鿡 �ѷ���
  Value2Screen(BlockNo);
end;
//�������� ����
procedure TDataSaveMain.Value2Screen(BlockNo: integer);
var
  it: DIterator;
  pHiMap: THiMap;
  Lstr: string;
begin
  if BlockNo = 0 then
    exit;

  //ù��° ������ ��� 1 Cycle skip(�߰����� ����� �� �����Ƿ�)
  if FlogStart then
  begin
    if FLastBlockNo > BlockNo then
    begin
      exit;
    end
    else //BlockNo == 5
    begin
      FlogStart := False;
      exit;
    end;
  end;

  FCurrentBlockNo := BlockNo;

  it := FAddressMap.start;

  DisplayMessage(#13#10+TimeToStr(Time)+' Data Received', dtSendMemo);
  //FSaveDataBuf := TimeToStr(Time);

  while not atEnd(it) do
  begin
    pHiMap := GetObject(it) as THiMap;

    if pHiMap.FBlockNo = BlockNo then
    begin
      //CSV�� ������ ����
      if CB_CSVlogging.Checked then
      begin
        if UpperCase(pHiMap.FName) <> 'DUMMY' then
        begin
          if pHiMap.FAlarm then
          begin
            if pHiMap.FMaxval > 0.0 then
            begin
              if (UpperCase(pHiMap.FName) = 'AI_TC_A_RPM') or
                (UpperCase(pHiMap.FName) = 'AI_TC_B_RPM') then
                FSaveDataBuf := FSaveDataBuf+ ',' + FloatToStr(pHiMap.FValue * pHiMap.FMaxval)
              else
                FSaveDataBuf := FSaveDataBuf+ ',' + FloatToStr(pHiMap.FValue / pHiMap.FMaxval);
            end
            else
              FSaveDataBuf := FSaveDataBuf+ ',' + FloatToStr(pHiMap.FValue);

            //FSaveDataBuf := FSaveDataBuf+ ',' + FloatToStr(pHiMap.FValue * pHiMap.FMaxval / 4095);
            //FSaveDBDataBuf := FSaveDBDataBuf+ ',' + FloatToStr(pHiMap.FValue * pHiMap.FMaxval / 4095);
          end
          else
          begin
            if pHiMap.FValue > 0 then
              Lstr := 'TRUE'
            else
              Lstr := 'FALSE';

            FSaveDataBuf := FSaveDataBuf+ ',' + LStr;
            FSaveDBDataBuf := FSaveDBDataBuf+ ',' + LStr;
          end;
        end;//if
      end;//if
    end;//if

    Advance(it);

  end;//while

  if CB_CSVlogging.Checked then
  begin
    if FLastBlockNo = FCurrentBlockNo then
    begin
      FSaveDataBuf := FSaveDataBuf+ ',' + FDynamoCSVData;
      SaveData2File;    //CSV ���Ͽ� ����
    end;
  end;

  if CB_DBlogging.Checked then
  begin
    SaveData2DB;      //DB�� ����
  end;
end;//begin

//Analog �������� ����
procedure TDataSaveMain.Value2Screen_Analog(Name: string; AValue: Integer;
  AMaxVal: real);
begin
{  DisplayMessage(#13#10+TimeToStr(Time)+' Data Received', dtSendMemo);

  //CSV ���Ͽ� ������ ���
  if CB_CSVlogging.Checked then
  begin
    if (Name = '0106') then
    begin
      FSaveDataBuf :=TimeToStr(Time)+','+Name+','+FloatToStr(AValue * AMaxVal);
      SaveData2File;
    end
    else
    begin
      FSaveDataBuf :=TimeToStr(Time)+','+Name+','+FloatToStr(AValue * AMaxVal);
      SaveData2File;
    end;
  end;

  //����Ŭ ������ ���̽��� ������ ���
  if CB_DBlogging.Checked then
  begin
    if not Assigned(FDataSave2DBThread) then
    begin
      DisplayMessage('DataBase is not connected', dtSendMemo);
      exit;
    end;

    if (Name = '0106') then
    begin
      if FDataSave2DBThread.ZConnection1.Connected then
      begin
        FSaveDataBuf_Name := Name;
        FSaveDataBuf_Value := AValue * AMaxVal;
      end
      else
      begin
        FSaveDataBuf_Name := Name;
        FSaveDataBuf_Value := AValue * AMaxVal;
      end;
    end
    else if not FDataSave2DBThread.ZConnection1.Connected then
    begin
      DisplayMessage('Server Disconnected! Please Connect Again', dtSendMemo);
    end;
  end;
}
end;

//Digital �������� ����
procedure TDataSaveMain.Value2Screen_Digital(Name: string; AValue: Integer;
  AMaxVal: real; AContact: integer);
begin
;
end;

////////////////////////////////////////////////////////////////////////////////
//���θ޴�-Connect ��ư
procedure TDataSaveMain.Connect1Click(Sender: TObject);
begin
  CreateSave2DBThread;
end;
//���θ޴�-Disconnect ��ư
procedure TDataSaveMain.Disconnect1Click(Sender: TObject);
begin
  FDataSave2DBThread.DisConnectDB;
  DisplayMessage('Server Disconnected'+#13#10, dtSendMemo);
end;
//���θ޴�-Close ��ư
procedure TDataSaveMain.Close1Click(Sender: TObject);
begin
  Close;
end;
//���θ޴�-Option ��ư
procedure TDataSaveMain.Option1Click(Sender: TObject);
var
  FSaveConfigF: TSaveConfigF;
begin
  FSaveConfigF := TSaveConfigF.Create(Application);

  with FSaveConfigF do
  begin
    try
      SharedName2Combo(Ed_sharedmemory);
      SharedName2Combo(Ed_DynamoMM);

      LoadConfigDataini2Form(FSaveConfigF);
      if ShowModal = mrOK then
      begin
        SaveConfigDataForm2ini(FSaveConfigF);
        LoadConfigDataini2Var;
      end;
    finally
      Free;
    end;
  end;
end;
//���θ޴�-About ��ư
procedure TDataSaveMain.About1Click(Sender: TObject);
begin
  DisplayMessage (
  #13#10+#13#10
  +'#######################'+#13#10
  +'DataSave Program'+#13#10
  +'for AVAT ECS'+#13#10
  +'2010.4.30'+#13#10
  +'#######################'+#13#10, dtSendMemo);
end;

//Active ��ư Ŭ��
procedure TDataSaveMain.CB_ActiveClick(Sender: TObject);
begin
  //Data save�� �������� ���
  if CB_Active.Checked then
  begin
    FMonitorStart := True;
    DisplayMessage (#13#10+ '#####################' +#13#10+ TimeToStr(Time)+' Start Data Receiving', dtSendMemo);
    FLogStart := True;

    //CSV ���Ͽ� Data Save�� ���
    if CB_CSVlogging.Checked then
    begin
      FSaveDataBuf :=#13#10+TimeToStr(Time) + FCSVHeader + ',' + FDynamoHeader;
      FSaveFileName := ED_csv.Text;
      SaveData2File;
    end;

    //�����޸� ����;����� ���� ����
    FIPCMonitor_ECS_kumo.Resume;

    //Data save ���߿� ���ú��� �Ұ�
    CB_DBlogging.Enabled := False;
    CB_CSVlogging.Enabled := False;
    RB_bydate.Enabled := False;
    RB_byfilename.Enabled := False;
    ED_csv.Enabled := False;
    RB_byevent.Enabled := False;
    RB_byinterval.Enabled := False;
    ED_interval.Enabled := False;
  end

  //Data save�� ������ ���
  else
  begin
    FMonitorStart := False;
    DisplayMessage (TimeToStr(Time)+#13#10+' Processing terminated', dtSendMemo);
    FlogStart := False;
    FIPCMonitor_ECS_kumo.Suspend;    //�����޸� ����;����� ���� ����

    //Data save������ ���ÿ� �� ��ư ���ú���Ұ� ����
    CB_DBlogging.Enabled := True;
    CB_CSVlogging.Enabled := True;
    RB_bydate.Enabled := True;
    RB_byfilename.Enabled := True;

    if RB_byfilename.Checked then
    begin
      ED_csv.Enabled := True;
    end;
    RB_byevent.Enabled := True;
    RB_byinterval.Enabled := True;
    if RB_byinterval.Checked then
    begin
      ED_interval.Enabled := True;
    end;
  end;
end;

procedure TDataSaveMain.CB_DBloggingClick(Sender: TObject);
begin

end;

////////////////////////////////////////////////////////////////////////////////
//Save by date ���� ��ư
procedure TDataSaveMain.RB_bydateClick(Sender: TObject);
begin
  FFileName_Convention := FC_YMD;
  ED_CSV.Text := FormatDatetime('yyyymmdd',date)+'.'+'CSV';
  ED_csv.enabled := False;
end;

//Save by filename ���� ��ư
procedure TDataSaveMain.RB_byfilenameClick(Sender: TObject);
begin
  FFileName_Convention := FC_FIXED;
  ED_csv.enabled := True;
end;

//Save by interval ���� ��ư//////////////////////////////////////////////////
procedure TDataSaveMain.RB_byintervalClick(Sender: TObject);
begin
  ED_interval.Enabled := True;
  ED_interval.Text := '1000';
end;

//Save by event ���� ��ư/////////////////////////////////////////////////////
procedure TDataSaveMain.RB_byeventClick(Sender: TObject);
begin
  ED_interval.Enabled := False;
  ED_interval.Text := '';
end;

////////////////////////////////////////////////////////////////////////////////
//DB ���� ������ ���� �Լ�
procedure TDataSaveMain.CreateSave2DBThread;
begin
  if not Assigned(FDataSave2DBThread) then
  begin
    FDataSave2DBThread := TDataSave2DBThread.Create(Self);
    with FDataSave2DBThread do
    begin
      //FHostName := Self.FHostName;
      //FDBName := Self.FDBName;
      //FLoginID := Self.FLoginID;
      //FPasswd := Self.FPasswd;
      if FDataSave2DBThread.OraSession1.Connected then
      begin
        DisplayMessage ('Server Connected', dtSendMemo);
        Resume;
      end
    end;//with
  end//if
  else if not FDataSave2DBThread.OraSession1.Connected then
  begin
    FDataSave2DBThread.ConnectDB;
    if FDataSave2DBThread.OraSession1.Connected then
      DisplayMessage ('Server Re-Connected', dtSendMemo);
  end;
end;

//DB ���� ������ ��� �Լ�
procedure TDataSaveMain.SaveData2DB;
begin
  //if FCurrentBlockNo < 5 then
  //  exit;

  with FDataSave2DBThread do
  begin
    FStrData := FSaveDBDataBuf; //������ ������(FSaveDataBuf)�� ����(FStrData)�� �Է�
    FSaveDBDataBuf := '';

    if not FSaving then
      FDataSaveEvent.Signal;
  end;//with
end;

//DB ���� ������ ���� �Լ�
procedure TDataSaveMain.DestroySave2DBThread;
begin
  if Assigned(FDataSave2DBThread) then
  begin
    FDataSave2DBThread.Terminate;
    FDataSave2DBThread.FDataSaveEvent.Signal;
    FDataSave2DBThread.Free;
    FDataSave2DBThread := nil;
  end;//if

end;

////////////////////////////////////////////////////////////////////////////////
//CSV ���� ���� ������  ���� �Լ�
procedure TDataSaveMain.CreateSave2FileThread;
begin
  if not Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread := TDataSave2FileThread.Create(Self);
    FDataSave2FileThread.Resume;
  end;
end;
//CSV ���� ���� ��� �Լ�
procedure TDataSaveMain.SaveData2File;
begin
  with FDataSave2FileThread do
  begin
    FStrData := FSaveDataBuf; //������ ������(FSaveDataBuf)�� ����(FStrData)�� �Է�
    FTagData := FTagNameBuf;  //���ʿ� �������� ���� �� ���(�Ӹ���) �Է�
    FName_Convention := FFileName_Convention; //���ϸ��� �������ִ� �������
    FFileName := FSaveFileName; //���ϸ� ���� (FName_Convention�� FC_Fixed������ ���)
    if not FSaving then
      DisplayMessage(TimeToStr(Time)+' Processing DataSave to CSV file', dtSendMemo);
    FDataSaveEvent.Signal;
  end;//with

  FSaveDataBuf := formatDateTime('yyyy-mm-dd hh:nn:ss:zzz',now);
end;

//CSV ���� ���� ������ ���� �Լ�
procedure TDataSaveMain.DestroySave2FileThread;
begin
  if Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread.Terminate;
    FDataSave2FileThread.FDataSaveEvent.Signal;
    FDataSave2FileThread.Free;
    FDataSave2FileThread := nil;
  end;//if
end;

////////////////////////////////////////////////////////////////////////////////
//�޽����� ȭ�鿡 ǥ���ϴ� �Լ� ////////////////////////////////////////////////
procedure TDataSaveMain.DisplayMessage(msg: string; ADspNo: TDisplayTarget);
begin
  case ADspNo of
    dtSendMemo : begin
      if msg = ' ' then
      begin
        exit;
      end
      else
        ;

      with Protocol do
      begin
        if Lines.Count > 100 then
          Clear;

        Lines.Add(msg);
      end;//with
    end;//dtSendMemo

    dtStatusBar: begin
       StatusBar1.SimplePanel := True;
       StatusBar1.SimpleText := msg;
    end;//dtStatusBar
  end;//case
end;

procedure TDataSaveMain.DisplayMessage2SB(Msg: string);
begin
  StatusBar1.SimplePanel := True;
  StatusBar1.SimpleText := Msg;
end;

procedure TDataSaveMain.Dynamo_OnSignal(Sender: TIPCThread_Dynamo;
  Data: TEventData_Dynamo);
begin
  FDynamoData.FPower := Data.FPower;
  FDynamoData.FPowerUnit := Data.FPowerUnit;
  FDynamoData.FTorque := Data.FTorque;
  FDynamoData.FTorqueUnit := Data.FTorqueUnit;
  FDynamoData.FRevolution := Data.FRevolution;
  FDynamoData.FBrgTBTemp := Data.FBrgTBTemp;
  FDynamoData.FBrgMTRTemp := Data.FBrgMTRTemp;
  FDynamoData.FWaterInletTemp := Data.FWaterInletTemp;
  FDynamoData.FWaterOutletTemp := Data.FWaterOutletTemp;
  FDynamoData.FBody1Press := Data.FBody1Press;
  FDynamoData.FBody2Press := Data.FBody2Press;
  FDynamoData.FInletOpen1 := Data.FInletOpen1;
  FDynamoData.FInletOpen2 := Data.FInletOpen2;
  FDynamoData.FOutletOpen1 := Data.FOutletOpen1;
  FDynamoData.FOutletOpen2 := Data.FOutletOpen2;

  SendMessage(Handle, WM_EVENT_DYNAMO, 0,0);
end;

//ini ���Ͽ� �ִ� Host IP, Port�� Form�� ǥ���ϴ� �Լ� /////////////////////////
procedure TDataSaveMain.LoadConfigDataini2Form(FSaveConfigF: TSaveConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile, FSaveConfigF do
    begin
      Ed_sharedmemory.Text := ReadString(DATASAVE_SECTION, 'IPCCLIENTNAME1', '');
      Ed_DynamoMM.Text := ReadString(DATASAVE_SECTION, 'IPCCLIENTNAME_DYNAMO', '');
      BlockNoEdit.Text := ReadString(DATASAVE_SECTION, 'Block No', '1');
      MapFilenameEdit.FileName := ReadString(DATASAVE_SECTION, 'Modbus Map File Name1', '');
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//ini���Ϸ� Host�� Port, IP �ּҸ� �����ϴ� �Լ� ///////////////////////////////
procedure TDataSaveMain.SaveConfigDataForm2ini(FSaveConfigF: TSaveConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  DisplayMessage(#13#10+'System configuration changed'+#13#10+'Please restart program...' , dtSendMemo);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile, FSaveConfigF do
    begin
      WriteString(DATASAVE_SECTION, 'IPCCLIENTNAME1', Ed_sharedmemory.Text);
      WriteString(DATASAVE_SECTION, 'IPCCLIENTNAME_DYNAMO', Ed_DynamoMM.Text);
      WriteString(DATASAVE_SECTION, 'Modbus Map File Name1', MapFilenameEdit.FileName);
      WriteString(DATASAVE_SECTION, 'Block No', BlockNoEdit.Text);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//ini ���Ͽ��� �ʱ�ȭ������ �о� ���α׷����� ����ϴ� ������ �����ϴ� �Լ�/////
procedure TDataSaveMain.LoadConfigDataini2Var;
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME+DeviceName+'.ini');
  try
    with iniFile do
    begin
      //DB �������� �ʱ�ȭ ����
      FSharedMMName := ReadString(DATASAVE_SECTION, 'IPCCLIENTNAME1', '');
      FDynamoSharedMMName := ReadString(DATASAVE_SECTION, 'IPCCLIENTNAME_DYNAMO', '');
      FHostName := ReadString(DATASAVE_SECTION, 'SAVEDATA_HOSTNAME', '');
      FMapFileName := ReadString(DATASAVE_SECTION, 'Modbus Map File Name1', '');
      FLastBlockNo := ReadInteger(DATASAVE_SECTION, 'Block No', 1);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

end.
