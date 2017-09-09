unit DataSave;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, IPCThrdMonitor2, ModbusComConst, ModbusComStruct, DB,
  ExtCtrls, IPCThrd2, DeCAL_pjh, DataSaveConfig, janSQL,
  janSQLStrings, DataSaveConst, StdCtrls, SCLED, ComCtrls, Menus, SyncObjs,
  DataSave2FileThread,DataSave2DBThread, TimerPool, ALed;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    MsgLed: TSCLED;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    Panel29: TPanel;
    Panel30: TPanel;
    Panel31: TPanel;
    Panel32: TPanel;
    Panel33: TPanel;
    Panel28: TPanel;
    CONSUMPTIONQ: TPanel;
    TOTALT1: TPanel;
    TOTALT2: TPanel;
    VOL_A_QA: TPanel;
    VOL_A_T: TPanel;
    Panel83: TPanel;
    Panel36: TPanel;
    Panel23: TPanel;
    VOL_B_QB: TPanel;
    VOL_B_T: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel14: TPanel;
    Panel18: TPanel;
    Panel8: TPanel;
    Panel19: TPanel;
    Panel3: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    VOL_A_TOT_TA1: TPanel;
    VOL_A_TOT_TA2: TPanel;
    VOL_B_TOT_TB1: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    Panel34: TPanel;
    VOL_B_TOT_TB2: TPanel;
    Panel7: TPanel;
    GroupBox2: TGroupBox;
    Button4: TButton;
    Button1: TButton;
    Timer2: TTimer;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    ed_Load: TEdit;
    Label2: TLabel;
    ed_LogSec: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    ed_LogMin: TEdit;
    Label6: TLabel;
    ed_LogHour: TEdit;
    Label7: TLabel;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    ed_LogEndTime: TEdit;
    Label8: TLabel;
    lb_status: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnSignal(Sender: TIPCThread2; Data: TEventData2);
    procedure UpdateTraceData(var Msg: TWMModbusData); message WM_MODBUSDATA;
//    procedure WMSaveData(var Msg: TWMModbusData); message WM_SAVEDATA;
    procedure WMSaveData(BlockNo: integer);

    procedure Timer1Timer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    FHiMap: THiMap;         //Modbus Address ����ü -> �������� ������
    FAddressMap: DMap;      //Modbus Map ����Ÿ ���� ����ü
    FModBusData: TWMModbusData;//���ŵ� ����Ÿ ���� ����ü
    FFilePath: string;      //������ ������ ���
    FIPCMonitor: TIPCMonitor2;//���� �޸� �� �̺�Ʈ ��ü
    FDataSave2FileThread: TDataSave2FileThread;//���Ͽ� ����Ÿ �����ϴ� ��ü
    FDataSave2DBThread: TDataSave2DBThread; //DB�� ����Ÿ �����ϴ� ��ü
    FTimerPool: TPJHTimerPool;
    FFirstStart: Boolean;//ó�� �ѹ��� True
    FFirstStart_Excel_Save: Boolean;//Starter for Excel Title Setup
    FLogStart: Boolean;  //Log save Start sig.
    FLogStartTime: TDateTime; //Log Start time.

    FModBusMode: integer; //ModBusMode = 0: ASCII Mode, 1: RTU Mode
    FSaveDataBuf: string; //���Ͽ� ������ ����Ÿ�� �����ϴ� ����
    FTagNameBuf: string;  //���Ͽ� ������ �����ϱ� ���� ����
    FDataSaveStart: Boolean; //������ �ð��� ��� �Ǿ����� True(Save������)
    FjanDB : TjanSQL; //text ��� SQL DB
    FMsgList: TStringList;  //Message�� �����ϴ� ����Ʈ
    FCriticalSection: TCriticalSection;
    FRecordCount: integer; //��ü ����Ÿ �Ǽ�

    //Config Data
    FSaveMedia: TSaveMedia;//����Ÿ�� ������ �̵� ������
    FSaveFileName: string; //����Ÿ�� ������ File �̸�(������ ���� �����)
    FSaveInterval: integer;//����Ÿ ���� �ֱ�(�ʴ���)
    FSaveTime: TTime; //����Ÿ ���� �Ͻ�(�ش� �Ͻð� �Ǹ� �ڵ� �����)
    FUseDate: Bool;   //��¥�� �����ϱ�
    FSaveDate: TDate; //��, ��
    FRepeat_Date: Bool;//������ ���ڿ� �ݺ��ؼ� �����ϱ�
    FRepeat_Time: Bool;//������ Interval�� �ݺ��ؼ� �����ϱ�
    FFileName_Convention: TFileName_Convetion;//���Ͽ� ����ÿ� �����̸��ο� ���
    FLastBlockNo: integer;//Modbus Block�߿� ���� ���߿� ȣ��� Block number
    FSeperator: string;//file�� �����Ҷ� ����Ÿ ���й���

    FHostName: string;//DB Host Name(IP address)
    FDBName: string;  //DB Name(Mysql�� DB Name)
    FLoginID: string;   //Login Name
    FPasswd: string;  //Password

    procedure OnAllTriggers(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);
  public
    procedure InitVar;
    procedure ReadMapAddress;
    procedure ReadMapAddress2;
    procedure SaveData(BlockNo: integer);
    procedure Value2file_Analog(pMap: THiMap);
    procedure Value2file_Digital(pMap: THiMap);
    function  ModBusValveResolve(value:integer; max: real): string;
    procedure SaveData2File;
    procedure SaveData2DB;

    procedure CreateSave2FileThread;
    procedure DestroySave2FileThread;
    procedure CreateSave2DBThread;
    procedure DestroySave2DBThread;

    procedure LoadConfigDataini2Form(ConfigForm:TSaveConfigF);
    procedure LoadConfigDataini2Var;
    procedure SaveConfigDataForm2ini(ConfigForm:TSaveConfigF);
    procedure SetConfigData;
    procedure AddMessage2List(Msg: string);
    procedure DisplayMessage(msg: string);

  published
    property FilePath: string read FFilePath;
  end;

var
  Form1: TForm1;

implementation

uses CommonUtil;

{$R *.dfm}

{ TForm1 }

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FCriticalSection.Enter;

  FTimerPool.Free;
  FTimerPool := nil;

  try
    ObjFree(FAddressMap);
    FAddressMap.free;
    FIPCMonitor.Free;
    FMsgList.Free;

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
  finally
    FCriticalSection.Leave;
  end;//try

  FCriticalSection.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitVar;
  LoadConfigDataini2Var;
end;

procedure TForm1.InitVar;
begin
  FCriticalSection := TCriticalSection.Create;
  FFilePath := ExtractFilePath(Application.ExeName); //�ǳ��� '\' ���Ե�
  //Manual-Reset���� �����ϴ� �������� wait �Լ��� ���ÿ� return��
  FIPCMonitor := TIPCMonitor2.Create(1, 'ModBusCom', True);//GetCurrentProcessID
  FIPCMonitor.OnSignal := OnSignal;
  FIPCMonitor.Resume;

  FAddressMap := DMap.Create;
  FMsgList := TStringList.Create;

  FDataSave2FileThread := nil;
  FDataSave2DBThread := nil;

  FTimerPool := TPJHTimerPool.Create(Self);
  FTimerPool.OnAllTriggers := OnAllTriggers;
  FDataSaveStart := False;
  FFirstStart := True;
  FFirstStart_Excel_Save := True;
  FLogStart := False;
end;

procedure TForm1.LoadConfigDataini2Var;
var
  iniFile: TIniFile;
  bSaveFile, bSaveDB: Bool;
  Hour, Min, Sec, H, M: integer;
  Mon, ddd: integer;
  ampm: string;
  sep: PChar;
  tmp: array [1..2] of char;
begin
  SetCurrentDir(FilePath);
  iniFile := nil;
  iniFile := TInifile.create(SAVEINIFILENAME);
  try
    with iniFile do
    begin
      ampm := ReadString(SAVEDATA_FIX_SECTION, 'AM/PM', '����');
      H := ReadInteger(SAVEDATA_FIX_SECTION, '�ð�', 0);
      M := ReadInteger(SAVEDATA_FIX_SECTION, '��', 0);
      FUseDate := ReadBool(SAVEDATA_FIX_SECTION, '���ڼ���', False);
      Mon := ReadInteger(SAVEDATA_FIX_SECTION, '��', 1);
      ddd := ReadInteger(SAVEDATA_FIX_SECTION, '��', 1);
      FRepeat_Date := ReadBool(SAVEDATA_FIX_SECTION, '�ݺ����', False);

      Hour := ReadInteger(SAVEDATA_PERIOD_SECTION, '�ð�', 0);
      Min := ReadInteger(SAVEDATA_PERIOD_SECTION, '��', 0);
      Sec := ReadInteger(SAVEDATA_PERIOD_SECTION, '��', 0);
      FRepeat_Time := ReadBool(SAVEDATA_PERIOD_SECTION, '�ݺ����', False);

      bSaveDB := ReadBool(SAVEDATA_MEDIA_SECTION, 'Save to Database', False);
      bSaveFile := ReadBool(SAVEDATA_MEDIA_SECTION, 'Save to File', False);

      FFileName_Convention := TFileName_Convetion(ReadInteger(SAVEDATA_MEDIA_SECTION, 'File Name Type', 0));
      FSaveFileName := ReadString(SAVEDATA_MEDIA_SECTION, 'File Name', '');
      FLastBlockNo := ReadInteger(SAVEDATA_ETC_SECTION, 'Last Block Number', 0);
      FSeperator := ReadString(SAVEDATA_ETC_SECTION, 'Seperator', ',');

      FHostName := ReadString(SAVEDATA_DB_SECTION, 'Host Name', '127.0.0.1');
      FDBName := ReadString(SAVEDATA_DB_SECTION, 'Database Name', 'HIMSENDB');
      FLoginID := ReadString(SAVEDATA_DB_SECTION, 'Login ID', 'root');
      FPasswd := ReadString(SAVEDATA_DB_SECTION, 'Passwd', 'root');

      FSaveMedia := [];

      if bSaveDB then
      begin
        FSaveMedia := [SM_DB];
        CreateSave2DBThread;
      end
      else
        DestroySave2DBThread;

      if bSaveFile then
      begin
        FSaveMedia := FSaveMedia + [SM_FILE];
        CreateSave2FileThread;
      end
      else
        DestroySave2FileThread;

      FSaveInterval := ((Hour * 3600) + (Min * 60) + Sec) * 1000; //Milisecond

      if ampm = '����' then
        ampm := 'AM'
      else
        ampm := 'PM';

      if (H <> 0) or (M <> 0) then
        FSaveTime := StrToTime(format('%2.2d:%2.2d:00 %s',[H,M,ampm]));

      if FUseDate then
      begin
        sep := @tmp;
        GetLocaleInfo(LOCALE_USER_DEFAULT,LOCALE_SDATE, sep, 10);
        FSaveDate := StrToDate(IntToStr(Mon) + strPas(sep) + IntToStr(ddd));
      end;

      FTimerPool.RemoveAll;
      FTimerPool.Add(nil, FSaveInterval);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TForm1.OnSignal(Sender: TIPCThread2; Data: TEventData2);
var
  i,dcount: integer;
begin

  FillChar(FModBusData.InpDataBuf[0], High(FModBusData.InpDataBuf) - 1, #0);
  FModBusData.ModBusMode := Data.ModBusMode;

  if Data.ModBusMode = 0 then //ASCII Mode�̸�
  begin
    dcount := Data.NumOfData;

    for i := 0 to dcount - 1 do
      FModBusData.InpDataBuf[i] := Data.InpDataBuf[i];
  end
  else
  if Data.ModBusMode = 1 then// RTU Mode �̸�
  begin
    dcount := Data.NumOfData div 2;
    FModBusData.NumOfBit := Data.NumOfBit;
    if dcount = 0 then
      Inc(dcount);
    for i := 0 to dcount - 1 do
    begin
      FModBusData.InpDataBuf[i] := Data.InpDataBuf2[i*2] ;
      FModBusData.InpDataBuf[i] := FModBusData.InpDataBuf[i] shl 8 + Data.InpDataBuf2[i*2 + 1];
    end;
    if (Data.NumOfData mod 2) > 0 then
      FModBusData.InpDataBuf[i] := Data.InpDataBuf2[i*2] ;
  end;//else
  FModBusData.ModBusAddress := String(Data.ModBusAddress);
  FModBusData.NumOfData := dcount;
  FModBusData.ModBusFunctionCode := Data.ModBusFunctionCode;

  StatusBar1.SimplePanel := True;
  StatusBar1.SimpleText := FModBusData.ModBusAddress + ' ����Ÿ ����';
  SendMessage(Handle, WM_MODBUSDATA, 0,0);
end;

//OnSignal �Լ����� PostMesage�Լ��� �����ϴ� �Լ�
procedure TForm1.UpdateTraceData(var Msg: TWMModbusData);
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
  tmpStr := IntToStr(FModBusData.ModBusFunctionCode) + FModBusData.ModBusAddress;
  it := FAddressMap.locate( [ tmpstr ] );
//    pHiMap := GetObject(it) as THiMap;
//    BlockNo := pHiMap.FBlockNo;
  SetToValue(it);

  while not atEnd(it) do
  begin
    if i > FModBusData.NumOfData - 1 then
      break;

    pHiMap := GetObject(it) as THiMap;

    //if ModBusFunction Code is 3
    if FModBusData.ModBusFunctionCode = 3 then
    begin
      pHiMap.FValue := FModBusData.InpDataBuf[i];
      Inc(i);
      BlockNo := pHiMap.FBlockNo;
      Advance(it);
    end;
  end;//while

  StatusBar1.SimpleText := FModBusData.ModBusAddress + ' ó����';

  //���ŵ� ����Ÿ�� ���Ͽ� ������
  SaveData(BlockNo);
end;

//�� �������� ���� ����Ÿ�� ������
procedure TForm1.SaveData(BlockNo: integer);
begin
  if (FLogStart = True) then
  begin
    WMSaveData(BlockNo);
    if (FLogStartTime + StrToTime(ed_LogHour.Text + ':' + ed_LogMin.Text + ':' + ed_LogSec.Text))< Time then
      Button3Click(Self);
  end;
end;

//procedure TForm1.WMSaveData(var Msg: TWMModbusData);
procedure TForm1.WMSaveData(BlockNo: integer);
var
  it: DIterator;
  pHiMap: THiMap;
  LInt: integer;
  rcnt,i: integer;
  tmpint: integer;
  tmpdouble: double;
  tmpPanel: TPanel;
begin
  FCriticalSection.Enter;
  try

////////////////////SMH Modification Start//////////////////////////////////////
  it := FAddressMap.start;
//Scan pHiMap 'Block' which is called as 'it' in this paragraph
  while not atEnd(it) do
  begin
    pHiMap := GetObject(it) as THiMap;

    //Find Ordered Block using BlockNo which taken from upper fuction
    if pHiMap.FBlockNo = BlockNo then
    begin
      if pHiMap.FAlarm then
      begin

        //if FContact is 2 then Program for FlowMeter is running
        if pHiMap.FContact = 2 then
        begin
          LInt := pHiMap.FValue;
          Advance(it);
          pHiMap := GetObject(it) as THiMap;

          if (FFirstStart_Excel_Save = True) and (pHiMap.FName = 'VOL_B_T') then
          begin
            FSaveDataBuf := 'Date/time,Log_NO,CONSUMPTION_Q,TOTAL_T1,TOTAL_T2,VOL_A_QA,VOL_A_T,VOL_A_TOT_TA1,VOL_A_TOT_TA2,VOL_B_TOT_TB1,VOL_B_TOT_TB2,VOL_B_QB,VOL_B_T';
            SaveData2File;
            FFirstStart_Excel_Save := False;
            exit;
          end
          else if (FFirstStart_Excel_Save = True) and(pHiMap.FName <> 'VOL_B_T') then
          begin
            exit;
          end;

          if (pHiMap.FName = 'SERIAL_NUM') then
          begin
              FSaveDataBuf := DateTimeToStr(now); //���� �ʱ�ȭ
          end//if
          else
          begin
            //FSaveDataBuf := FSaveDataBuf + FSeperator + pHiMap.FName;
            tmpint := (LInt shl 16) or pHiMap.FValue;
            tmpdouble := tmpint;
            tmpPanel := TPanel(FindComponent(pHiMap.FName));
            tmpPanel.Caption := FloatToStr(tmpdouble/10);
            FSaveDataBuf := FSaveDataBuf + FSeperator + FloatToStr(tmpdouble/10);
          end;
          if (pHiMap.FName = 'VOL_B_T') then
            SaveData2File;
        end;
      end;
    end;
    Advance(it);
  end;//while
////////////////////SMH Modification End////////////////////////////////////////
  finally
    FCriticalSection.Leave;
  end;//try
end;

procedure TForm1.SaveData2File;
begin
  with FDataSave2FileThread do
  begin
    FStrData := FSaveDataBuf;
    FTagData := FTagNameBuf;
    FName_Convention := FFileName_Convention;
    FFileName := FSaveFileName;
    if not FSaving then
      FDataSaveEvent.Signal;
  end;//with
end;


//�������� Ini ���Ϸ� ���� ȭ�鿡 ����
procedure TForm1.LoadConfigDataini2Form(ConfigForm: TSaveConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FilePath);
  iniFile := nil;
  iniFile := TInifile.create(SAVEINIFILENAME);
  try
    with iniFile, ConfigForm do
    begin
      //ModbusModeRG.ItemIndex := ReadInteger(SAVEDATA_SECTION, 'Modbus Mode', 0);
      ampm_combo.Text := ReadString(SAVEDATA_FIX_SECTION, 'AM/PM', '����');
      Hour_SpinEdit.Value := ReadInteger(SAVEDATA_FIX_SECTION, '�ð�', 0);
      Minute_SpinEdit.Value := ReadInteger(SAVEDATA_FIX_SECTION, '��', 0);
      UseDate_ChkBox.Checked := ReadBool(SAVEDATA_FIX_SECTION, '���ڼ���', False);
      Month_SpinEdit.Value := ReadInteger(SAVEDATA_FIX_SECTION, '��', 1);
      Date_SpinEdit.Value := ReadInteger(SAVEDATA_FIX_SECTION, '��', 1);
      Repeat_ChkBox.Checked := ReadBool(SAVEDATA_FIX_SECTION, '�ݺ����', False);

      HourCnt_SpinEdit.Value := ReadInteger(SAVEDATA_PERIOD_SECTION, '�ð�', 0);
      MinuteCnt_SpinEdit.Value := ReadInteger(SAVEDATA_PERIOD_SECTION, '��', 0);
      SecondCnt_SpinEdit.Value := ReadInteger(SAVEDATA_PERIOD_SECTION, '��', 0);
      RepeatCnt_ChkBox.Checked := ReadBool(SAVEDATA_PERIOD_SECTION, '�ݺ����', False);

      SaveDB_ChkBox.Checked := ReadBool(SAVEDATA_MEDIA_SECTION, 'Save to Database', False);
      SaveFile_ChkBox.Checked := ReadBool(SAVEDATA_MEDIA_SECTION, 'Save to File', False);
      FNameType_RG.ItemIndex := ReadInteger(SAVEDATA_MEDIA_SECTION, 'File Name Type', 0);
      FilenameEdit1.Filename := ReadString(SAVEDATA_MEDIA_SECTION, 'File Name', '');

      LastBlockNo_SpinEdit.Value := ReadInteger(SAVEDATA_ETC_SECTION, 'Last Block Number', 0);
      Sep_Edit.Text := ReadString(SAVEDATA_ETC_SECTION, 'Seperator', ',');
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//�������� Ini ���Ϸ� ���� ���� ������ ����


//ȭ�鿡 �������� ���� Ini ���Ͽ� ����
procedure TForm1.SaveConfigDataForm2ini(ConfigForm: TSaveConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FilePath);
  iniFile := nil;
  iniFile := TInifile.create(SAVEINIFILENAME);
  try
    with iniFile, ConfigForm do
    begin
      WriteString(SAVEDATA_FIX_SECTION, 'AM/PM', ampm_combo.Text);
      WriteInteger(SAVEDATA_FIX_SECTION, '�ð�', Hour_SpinEdit.Value);
      WriteInteger(SAVEDATA_FIX_SECTION, '��', Minute_SpinEdit.Value);
      WriteBool(SAVEDATA_FIX_SECTION, '���ڼ���', UseDate_ChkBox.Checked);
      WriteInteger(SAVEDATA_FIX_SECTION, '��', Month_SpinEdit.Value);
      WriteInteger(SAVEDATA_FIX_SECTION, '��', Date_SpinEdit.Value);
      WriteBool(SAVEDATA_FIX_SECTION, '�ݺ����', Repeat_ChkBox.Checked);

      WriteInteger(SAVEDATA_PERIOD_SECTION, '�ð�', HourCnt_SpinEdit.Value);
      WriteInteger(SAVEDATA_PERIOD_SECTION, '��', MinuteCnt_SpinEdit.Value);
      WriteInteger(SAVEDATA_PERIOD_SECTION, '��', SecondCnt_SpinEdit.Value);
      WriteBool(SAVEDATA_PERIOD_SECTION, '�ݺ����', RepeatCnt_ChkBox.Checked);

      WriteBool(SAVEDATA_MEDIA_SECTION, 'Save to Database', SaveDB_ChkBox.Checked);
      WriteBool(SAVEDATA_MEDIA_SECTION, 'Save to File', SaveFile_ChkBox.Checked);
      WriteInteger(SAVEDATA_MEDIA_SECTION, 'File Name Type', FNameType_RG.ItemIndex);
      WriteString(SAVEDATA_MEDIA_SECTION, 'File Name', FilenameEdit1.Filename);

      WriteInteger(SAVEDATA_ETC_SECTION, 'Last Block Number', LastBlockNo_SpinEdit.Value);
      WriteString(SAVEDATA_ETC_SECTION, 'Seperator', Sep_Edit.Text);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

//ȯ�漳�� �Լ�
procedure TForm1.SetConfigData;
var
  scf: TSaveConfigF;
begin
  try
    scf := nil;
    scf := TSaveConfigF.Create(nil);

    with scf do
    begin
      LoadConfigDataini2Form(scf);

      while ShowModal = mrOK do
      begin
        if (SaveFile_ChkBox.Checked) and (FNameType_RG.ItemIndex = 1) and
          (FilenameEdit1.Text = '') then
        begin
          ShowMessage('���� �̸��� �Է��Ͻÿ�!');
          Continue;
        end
        else
        if (LastBlockNo_SpinEdit.Value = 0) then
        begin
          ShowMessage('��Ÿ -> Last Block Number�� 0�̸� �ȵ˴ϴ�! ');
          Continue;
        end
        else
        begin
          SaveConfigDataForm2ini(scf);
          LoadConfigDataini2Var;
          break;
        end;

      end;//while
    end;//with
  finally
    scf.Free;
    scf := nil;
  end;//try
end;

procedure TForm1.ReadMapAddress;
var
  i: integer;
begin
end;

procedure TForm1.ReadMapAddress2;
var
  sqltext: string;
  sqlresult, fldcnt: integer;
  i: integer;
  filename, fcode: string;
begin
  if fileexists(MAP_FILE_NAME) then
  begin
    Filename := ExtractFileName(MAP_FILE_NAME);
    FileName := Copy(Filename,1, Pos('.',Filename) - 1);
    FjanDB :=TjanSQL.create;
    sqltext := 'connect to ''' + FFilePath + '''';

    sqlresult := FjanDB.SQLDirect(sqltext);
    //Connect ����
    if sqlresult <> 0 then
    begin
      with FjanDB do
      begin
        sqltext := 'select * from '+FileName+' group by cnt';
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

            FRecordCount := RecordSets[sqlresult].RecordCount;
            //Record Count�� 0 �̸�
            if FRecordCount = 0 then exit;

            for i := 0 to FRecordCount - 1 do
            begin
              FHiMap := THiMap.Create;
              with FHiMap, RecordSets[SqlResult].Records[i] do
              begin
                FName := Fields[0].Value;
                FDescription := Fields[1].Value;
                FSid := StrToInt(Fields[2].Value);
                FAddress := Fields[3].Value;
                FBlockNo := StrToInt(Fields[4].Value);
                if Fields[5].Value = 'FALSE' then
                begin
                  FAlarm := False;
                  fcode := '1';
                end
                else
                begin
                  FAlarm := True;
                  fcode := '3';
                end;
                FMaxval := StrToFloat(Fields[6].Value);
                FContact := StrToInt(Fields[7].Value);
                FUnit := '';
              end;//with

              FAddressMap.PutPair([fcode + FHiMap.FAddress,FHiMap]);
            end;//for
          end;

        end
        else
          DisplayMessage(FjanDB.Error);
      end;//with
    end
    else
      Application.MessageBox('Connect ����',
          PChar('���� ' + FFilePath + ' �� ���� �� �ٽ� �Ͻÿ�'),MB_ICONSTOP+MB_OK);
  end
  else
  begin
    Application.MessageBox('Data file does not exist!',
            'ss197_Modbus_Map.txt ������ ���� �Ŀ� �ٽ� �Ͻÿ�',MB_ICONSTOP+MB_OK);
    //Application.Terminate;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  try
    if FFirstStart then
    begin
      ReadMapAddress2;
      FFirstStart := not FFirstStart;
    end;
  finally
    //Timer1.Enabled := True;
  end;//try

end;

procedure TForm1.Value2file_Analog(pMap: THiMap);
begin
  FCriticalSection.Enter;
  try
  //ReplaceName �Լ� �߰��Ұ�
  with pMap do
  begin
    //RPM�� ���
    if (FName = 'oSE47') or (FName = 'oSE42') then
    begin
      if FName = 'oSE42' then
      begin
        FValue := Round(StrToFloat(ModBusValveResolve(FValue,FMaxVal))*10);
//        TCRPM_Edit.Text := IntToStr(FValue);
      end
      else
      begin
        FValue := Round(StrToFloat(ModBusValveResolve(FValue,FMaxVal)));
//        RPM_Edit.Text := IntToStr(FValue);
      end;
    end
    else if Pos('iT', FName) > 0 then
    begin
        FValue := Round(StrToFloat(ModBusValveResolve(FValue,FMaxVal)));
    end
    else
    begin
        FValue := StrToFloat(ModBusValveResolve(FValue,FMaxVal));
    end;
  end;//with

  finally
    FCriticalSection.Leave;
  end;//try
end;

//AContact: 1 = A����, 2 = B����, 3 = C����
procedure TForm1.Value2file_Digital(pMap: THiMap);
var
  rslt: string;
begin
  FCriticalSection.Enter;
  try

  with pMap do
  begin
    rslt := ModBusValveResolve(FValue,FMaxVal);

    case FContact of
      1: begin
          if rslt = 'ON' then
          begin
            FValue := True;
            AddMessage2List(FDescription);
          end
          else
            FValue := False;
        end;
      2: begin
          if rslt = 'OFF' then
          begin
            FValue := True;
            AddMessage2List(FDescription);
          end
          else
            FValue := False;
        end;
     end;//case
     
     TVarData(FValue).VType := varBoolean;
  end;//with

  finally
    FCriticalSection.Leave;
  end;//try

end;

function TForm1.ModBusValveResolve(value: integer; max: real): string;
var tmpvalue: real;
begin
  //Digital ���� ���
  if max = 0 then
  begin
    if Value > 0 then  //$FF�� ����
      Result := 'ON'
    else
      Result := 'OFF';
  end
  else//Analog ���� ���
  begin
    tmpvalue := (Value * max) / 4095;
    Result := Real2Str(tmpvalue,2);
  end;//if
end;

procedure TForm1.SaveData2DB;
begin
  with FDataSave2DBThread do
  begin
    if not FSaving then
      FDataSaveEvent.Signal;
  end;//with
end;

procedure TForm1.DisplayMessage(msg: string);
var
  i: integer;
begin
  if (Msg = '') and (FMsgList.Count > 0) then
    Msg := FMsgList.Strings[0];

  MsgLed.Caption := Msg;
  i := FMsgList.IndexOf(Msg);
  //�޼��� ��� �� ����Ʈ���� ������(�Ź� Timer�Լ��� ���� �ٽ� ���� ������)
  if i > -1 then
    FMsgList.Delete(i);
end;

procedure TForm1.AddMessage2List(Msg: string);
begin
  if FMsgList.IndexOf(Msg) = -1 then
    FMsgList.Add(Msg);
end;

procedure TForm1.N1Click(Sender: TObject);
begin
  SetConfigData;
end;

procedure TForm1.CreateSave2DBThread;
begin
  if not Assigned(FDataSave2DBThread) then
  begin
    FDataSave2DBThread := TDataSave2DBThread.Create(Self);
    with FDataSave2DBThread do
    begin
      FHostName := Self.FHostName;
      FDBName := Self.FDBName;
      FLoginID := Self.FLoginID;
      FPasswd := Self.FPasswd;
      if ConnectDB then
      begin
//        ALed1.Value := True;
        CreateDBParam(INSERT_FILE_NAME,'pps_monitor');
        Resume;
      end
      else
//        ALed1.Value := False;

    end;//with
  end;
end;

procedure TForm1.CreateSave2FileThread;
begin
  if not Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread := TDataSave2FileThread.Create(Self);
    FDataSave2FileThread.Resume;
  end;
end;

procedure TForm1.DestroySave2DBThread;
begin
  if Assigned(FDataSave2DBThread) then
  begin
    FDataSave2DBThread.Terminate;
    FDataSave2DBThread.FDataSaveEvent.Signal;
    FDataSave2DBThread.Free;
    FDataSave2DBThread := nil;
  end;//if

end;

procedure TForm1.DestroySave2FileThread;
begin
  if Assigned(FDataSave2FileThread) then
  begin
    FDataSave2FileThread.Terminate;
    FDataSave2FileThread.FDataSaveEvent.Signal;
    FDataSave2FileThread.Free;
    FDataSave2FileThread := nil;
  end;//if

end;

procedure TForm1.OnAllTriggers(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  FDataSaveStart := True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  lb_status.caption := '�����  ';
  lb_status.Font.Color := clMaroon;
  FLogStart := True;
  FSaveDataBuf := #13#10 + 'Load : ' + ed_Load.Text + ' %' + Fseperator + 'Logging Start';
  SaveData2File;
  FLogStartTime := Time;
  ed_LogEndTime.Text := '��ǥ�ð� : ' + TimeToStr((FLogStartTime)+ StrToTime(ed_LogHour.Text + ':' + ed_LogMin.Text + ':' + ed_LogSec.Text));
  Edit2.Text := '��Ͻ��� : ' + TimeToStr(FLogStartTime);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  lb_status.caption := '�����  ';
  lb_status.Font.Color := clGreen;
  FSaveDataBuf := 'Logging End' + #13#10;
  SaveData2File;
  FLogStart := False;
  FFirstStart_Excel_Save := True;
  FSaveDataBuf := '';
  CONSUMPTIONQ.caption := '';
  TOTALT1.caption := '';
  TOTALT2.caption := '';
  VOL_A_QA.caption := '';
  VOL_A_T.caption := '';
  VOL_B_QB.caption := '';
  VOL_B_T.caption := '';
  VOL_A_TOT_TA1.caption := '';
  VOL_A_TOT_TA2.caption := '';
  VOL_B_TOT_TB1.caption := '';
  VOL_B_TOT_TB2.caption := '';
  Edit2.Text := '�ֱ����� : ' + TimeToStr(Time);
  ed_LogEndTime.Text := '��ǥ�ð� : ';
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Edit1.Text := '����ð� : '+TimeToStr(Time);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  v_hnd : hwnd;
  c_hnd : hwnd;
  cc_hnd : hwnd;
begin
  WinExec(PChar('.\ModBusComP_multidrop.exe'), SW_SHOWNOACTIVATE);
  v_hnd := FindWindow(nil, 'MODBUS ��� ȭ��(Multi-Drop)');
  if v_hnd <> 0 then
//    SendMessage(v_hnd, WM_CLOSE, 0, 0);
  c_hnd := FindWindowEx(v_hnd, 0, 'TPanel', nil);
  cc_hnd := FindWindowEx(c_hnd, 0, 'TButton', nil);
  if cc_hnd <> 0 then
  begin
    sendmessage(cc_hnd, WM_LBUTTONDOWN, 0, 0);
    sendmessage(cc_hnd, WM_LBUTTONUP, 0, 0);
  end;
  SetForeGroundWindow(handle);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  v_hnd : hwnd;
  c_hnd : hwnd;
  cc_hnd : hwnd;
begin
  v_hnd := FindWindow(nil, 'MODBUS ��� ȭ��(Multi-Drop)');
  if v_hnd <> 0 then
    c_hnd := FindWindowEx(v_hnd, 0, 'TPanel', nil);
  cc_hnd := FindWindowEx(c_hnd, 0, 'TButton', nil);
  if cc_hnd <> 0 then
  begin
    sendmessage(cc_hnd, WM_LBUTTONDOWN, 0, 0);
    sendmessage(cc_hnd, WM_LBUTTONUP, 0, 0);
  end;
  if v_hnd <> 0 then
    PostMessage(v_hnd, WM_CLOSE, 0, 0);
end;



end.
