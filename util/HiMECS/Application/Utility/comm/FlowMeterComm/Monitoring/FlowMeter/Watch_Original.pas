unit Watch_Original;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, iComponent, iVCLComponent, iCustomComponent,
  iPlotComponent, iPlot, StdCtrls, ExtCtrls,SyncObjs, iniFiles,
  DeCAL_pjh, IPCThrd2, IPCThrdMonitor2, Menus, iProgressComponent, iLedBar,
  iPositionComponent, iScaleComponent, iGaugeComponent, iAngularGauge,,
  Menus, iProgressComponent, iLedBar,
  iPositionComponent, iScaleComponent, iGaugeComponent, iAngularGauge;
  
type
  TWatchF = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    Panel2: TPanel;
    Label1: TLabel;
    Panel1: TPanel;
    Label3: TLabel;
    CurLabel: TLabel;
    Button1: TButton;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    MinLabel: TLabel;
    MaxLabel: TLabel;
    iPlot1: TiPlot;
    WatchLabel: TLabel;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    Config1: TMenuItem;
    Label10: TLabel;
    AvgEdit: TEdit;
    UpDown1: TUpDown;
    Button2: TButton;
    Label2: TLabel;
    AvgLabel: TLabel;
    iAngularGauge1: TiAngularGauge;
    iLedBar1: TiLedBar;
    PopupMenu2: TPopupMenu;
    Add1: TMenuItem;
    CurrentValue1: TMenuItem;
    Average1: TMenuItem;
    MinValue1: TMenuItem;
    MaxValue1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Config1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CurrentValue1Click(Sender: TObject);
  private
    FFilePath: string;      //������ ������ ���
    FIPCMonitor: TIPCMonitor2;//���� �޸� �� �̺�Ʈ ��ü
    FCriticalSection: TCriticalSection;
    FMonitorStart: Boolean; //Ÿ�̸� ���� �Ϸ��ϸ� True
    FMsgList: TStringList;  //Message�� �����ϴ� ����Ʈ

    procedure OnSignal(Sender: TIPCThread2; Data: TEventData2);
  public
    FLabelName: string; //����͸��ϰ��� �ϴ� ����Ÿ�� �̸��� ������.
    FWatchName: string; //component �̸��� ������.(FunctionCode+Address)
    FWatchValue: string; //����͸� ����Ÿ

    FWatchValueMin: double; //Min data
    FWatchValueMax: double; //Max data
    FWatchValueSum: double; //Sum data
    FWatchValueAvg: double; //Average data
    FWatchValueAry: array of double;
    FCurrentAryIndex: integer; //ó���� �迭�� ����ÿ� ��հ� ���ϱ� ����
    FAvgSize: integer; //����� ���� �迭 size
    FFirstCalcAry: boolean; //ó�� �迭�� ä�������� True, �ѹ� �� ä��� False

    FIsCurrentValueGraph: boolean;//���簪�� �׷����� ǥ���ϸ� True
    FCurrentValueChannel: integer;// FIsCurrentValueGraph=true �� ��� ä�� ��ȣ

    FIsAverageValueGraph: boolean;//��հ��� �׷����� ǥ���ϸ� True
    FAverageValueChannel: integer;// FIsCurrentValueGraph=true �� ��� ä�� ��ȣ

    FIsMinValueGraph: boolean;//�ּҰ��� �׷����� ǥ���ϸ� True
    FMinValueChannel: integer;// FIsCurrentValueGraph=true �� ��� ä�� ��ȣ

    FIsMaxValueGraph: boolean;//�ִ밪�� �׷����� ǥ���ϸ� True
    FMaxValueChannel: integer;// FIsCurrentValueGraph=true �� ��� ä�� ��ȣ

    procedure InitVar;
    procedure DisplayMessage(Msg: string);
    procedure Value2WatchScreen(BlockNo: integer);

    procedure ApplyAvgSize;
    
    procedure ReadMapAddress(AddressMap: DMap; MapFileName: string);
    procedure LoadConfigDataini2Form(ConfigForm:TEngMonitorConfigF);
    procedure LoadConfigDataini2Var;
    procedure SaveConfigDataForm2ini(ConfigForm:TEngMonitorConfigF);
    procedure SetConfigData;
  end;

var
  WatchF: TWatchF;

implementation

uses CommonUtil;

{$R *.dfm}

procedure TWatchF.InitVar;
begin
  FFilePath := ExtractFilePath(Application.ExeName); //�ǳ��� '\' ���Ե�
  FCriticalSection := TCriticalSection.Create;

  FAddressMap := DMap.Create;
  FIPCMonitor := TIPCMonitor2.Create(0, MONITORNAME, True);
  FIPCMonitor.OnSignal := OnSignal;
  FIPCMonitor.Resume;

  FMsgList := TStringList.Create;
  FMonitorStart := False;

  LoadConfigDataini2Var;
  LoadConfigDataini2Form(nil);
  SetLength(FWatchValueAry, FAvgSize);
  //FillChar(FWatchValueAry,Sizeof(FWatchValueAry) * FAvgSize,0);
  FCurrentAryIndex := 0;
  FFirstCalcAry := True;

end;

procedure TWatchF.LoadConfigDataini2Form(ConfigForm: TEngMonitorConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME);
  try
    with iniFile do
    begin
      if Assigned(ConfigForm) then
      begin
        with ConfigForm do
        begin
          FilenameEdit.Text := ReadString(ENGMONITOR_SECTION, 'Modbus Map File Name1', '.\ss197_Modbus_Map.txt');
        end;//with
      end
      else
      begin
        AvgEdit.Text := ReadString(ENGMONITOR_SECTION, 'Aveage Size', '1');
      end;
      //FilenameEdit2.Filename := ReadString(ENGMONITOR_SECTION, 'Modbus Map File Name2', '.\ss197_Modbus_Map.txt');
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TWatchF.LoadConfigDataini2Var;
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME);
  try
    with iniFile do
    begin
      FMapFileName := ReadString(ENGMONITOR_SECTION, 'Modbus Map File Name1', '');
      FAvgSize := ReadInteger(ENGMONITOR_SECTION, 'Aveage Size', 1);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TWatchF.SaveConfigDataForm2ini(ConfigForm: TEngMonitorConfigF);
var
  iniFile: TIniFile;
begin
  SetCurrentDir(FFilePath);
  iniFile := nil;
  iniFile := TInifile.create(INIFILENAME);
  try
    with iniFile do
    begin
      if Assigned(ConfigForm) then
      begin
        with ConfigForm do
        begin
          WriteString(ENGMONITOR_SECTION, 'Modbus Map File Name1', FilenameEdit.Text);
        end;
      end
      else
      begin
        WriteString(ENGMONITOR_SECTION, 'Aveage Size', AvgEdit.Text);
      end;
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TWatchF.SetConfigData;
var EngMonitorConfigF: TEngMonitorConfigF;
begin
  EngMonitorConfigF := TEngMonitorConfigF.Create(Application);
  with EngMonitorConfigF do
  begin
    try
      LoadConfigDataini2Form(EngMonitorConfigF);
      if ShowModal = mrOK then
      begin
        SaveConfigDataForm2ini(EngMonitorConfigF);
        LoadConfigDataini2Var;
        FAddressMap.clear;
        ReadMapAddress(FAddressMap,FMapFileName);
      end;
    finally
      Free;
    end;
  end;
end;

procedure TWatchF.ReadMapAddress(AddressMap: DMap; MapFileName: string);
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
    FjanDB := TjanSQL.create;
    sqltext := 'connect to ''' + FFilePath + '''';

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

              AddressMap.PutPair([fcode + FHiMap.FAddress,FHiMap]);
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
    sqltext := FileName + '������ ���� �Ŀ� �ٽ� �Ͻÿ�';
    Application.MessageBox('Data file does not exist!', PChar(sqltext) ,MB_ICONSTOP+MB_OK);
  end;
end;

procedure TWatchF.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  try
    if FMonitorStart then
    begin
      DisplayMessage('');
    end
    else
    begin
      ReadMapAddress(FAddressMap,FMapFileName);
    end;
  finally
    FMonitorStart := True;
    Timer1.Enabled := True;
  end;//try

end;

procedure TWatchF.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TWatchF.DisplayMessage(Msg: string);
var
  i: integer;
begin
  if (Msg = '') and (FMsgList.Count > 0) then
    Msg := FMsgList.Strings[0];

  //MsgLed.Caption := Msg;
  i := FMsgList.IndexOf(Msg);
  //�޼��� ��� �� ����Ʈ���� ������(�Ź� Timer�Լ��� ���� �ٽ� ������ ������)
  if i > -1 then
    FMsgList.Delete(i);
end;

procedure TWatchF.WatchValue2Screen_Analog_FlowMeter(Name: string; AValue,
  AValue2: Integer);
var
  tmpint: integer;
  tmpdouble: double;
begin
  tmpint := ((AValue shl 16) or AValue2);
  tmpdouble := tmpint;
  tmpdouble := tmpdouble/10;

  if tmpdouble > FWatchValueMax then
    FWatchValueMax := tmpdouble;

  if tmpdouble < FWatchValueMin then
    FWatchValueMin := tmpdouble;


  if FCurrentAryIndex = (FAvgSize - 1) then
  begin
    FFirstCalcAry := False;
    FCurrentAryIndex := 0;
    FWatchValueSum := FWatchValueSum - FWatchValueAry[FCurrentAryIndex] + tmpdouble;
  end
  else
  begin
    Inc(FCurrentAryIndex);

    if FFirstCalcAry = true then
      FWatchValueSum := FWatchValueSum  + tmpdouble
    else
      FWatchValueSum := FWatchValueSum - FWatchValueAry[FCurrentAryIndex] + tmpdouble;
  end;

  FCriticalSection.Enter;

  try
    if FFirstCalcAry = true then
      FWatchValueAvg := FWatchValueSum / (FCurrentAryIndex + 1)
    else
      FWatchValueAvg := FWatchValueSum / FAvgSize;

    FWatchValueAry[FCurrentAryIndex] := tmpdouble;
  finally
    FCriticalSection.Leave;
  end;//try

  FWatchValue := FloatToStr(tmpdouble);
  case PageControl1.ActivePageIndex of
    0: begin //simple
      WatchLabel.Caption := FWatchValue;
      AvgLabel.Caption := format('%10.2f',[FWatchValueAvg]);//FloatToStr(FWatchValueAvg);
    end;
    1: begin //Min/Max
      MinLabel.Caption :=  format('%10.2f',[FWatchValueMin]);//FloatToStr(FWatchValueMin);
      MaxLabel.Caption :=  format('%10.2f',[FWatchValueMax]);//FloatToStr(FWatchValueMax);
      CurLabel.Caption := FWatchValue;
    end;
    2: begin //Graph
      if FIsCurrentValueGraph then
      begin
        iPlot1.Channel[FCurrentValueChannel].AddXY(time, tmpdouble);
      end;

      if FIsAverageValueGraph then
      begin
        iPlot1.Channel[FAverageValueChannel].AddXY(time, FWatchValueAvg);
      end;

      if FIsMinValueGraph then
      begin
        iPlot1.Channel[FMinValueChannel].AddXY(time, FWatchValueMin);
      end;

      if FIsMaxValueGraph then
      begin
        iPlot1.Channel[FMaxValueChannel].AddXY(time, FWatchValueMax);
      end;

    end;
    3: begin //Meter
    end;
    4: begin //Bar
    end;
  end;//case

end;

procedure TWatchF.Value2WatchScreen(BlockNo: integer);
begin
  ;
end;

procedure TWatchF.FormDestroy(Sender: TObject);
begin
  FWatchValueAry := nil;
  
  FCriticalSection.Free;

  ObjFree(FAddressMap);
  FAddressMap.free;
  FIPCMonitor.Free;
  FMsgList.Free;
end;

procedure TWatchF.FormCreate(Sender: TObject);
begin
  InitVar;
end;

procedure TWatchF.Config1Click(Sender: TObject);
begin
  SetConfigData;
end;

procedure TWatchF.Button2Click(Sender: TObject);
begin
  ApplyAvgSize;
end;

procedure TWatchF.ApplyAvgSize;
begin
  SaveConfigDataForm2ini(nil);
  LoadConfigDataini2Form(nil);
  LoadConfigDataini2Var;
  FCriticalSection.Enter;
  try
    SetLength(FWatchValueAry, FAvgSize);
    FCurrentAryIndex := 0;
    FFirstCalcAry := True;
  finally
    FCriticalSection.Leave;
  end;//try
end;

procedure TWatchF.FormShow(Sender: TObject);
begin
  Label1.Caption := FLabelName;
  Label3.Caption := FLabelName;
  Self.Caption := Self.Caption + ' :: ' + FLabelName;
end;

procedure TWatchF.Button1Click(Sender: TObject);
begin
  FWatchValueMax := 0;
  FWatchValueMin := 0;
end;

procedure TWatchF.CurrentValue1Click(Sender: TObject);
begin
  FIsCurrentValueGraph := True;
  FCurrentValueChannel := iPlot1.AddChannel;
  iPlot1.Channel[FCurrentValueChannel].VisibleInLegend := False;
end;

procedure TWatchF.OnSignal(Sender: TIPCThread2; Data: TEventData2);
begin
  if not FMonitorStart then
    exit;

  StatusBar1.SimplePanel := True;
  StatusBar1.SimpleText := ' ����Ÿ ����';

  //SendMessage(Handle, WM_WT1600DATA, 0,0);

end;

end.




