unit MEXA7000_Watch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, iComponent, iVCLComponent, iCustomComponent,
  iPlotComponent, iPlot, StdCtrls, ExtCtrls,SyncObjs, iniFiles,
  DeCAL_pjh, IPCThrd2, IPCThrdMonitor2,janSQL,
  Menus, iProgressComponent, iLedBar,
  iPositionComponent, iScaleComponent, iGaugeComponent, iAngularGauge,
  ConfigConst, Options, Watchonfig;

type
  TWatchF = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
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
    Label10: TLabel;
    AvgEdit: TEdit;
    UpDown1: TUpDown;
    Button2: TButton;
    Label2: TLabel;
    AvgLabel: TLabel;
    PopupMenu2: TPopupMenu;
    Add1: TMenuItem;
    CurrentValue1: TMenuItem;
    Average1: TMenuItem;
    MinValue1: TMenuItem;
    MaxValue1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Config1: TMenuItem;
    N1: TMenuItem;
    Displayalldatainthischart1: TMenuItem;
    StatusBar1: TStatusBar;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Config1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CurrentValue1Click(Sender: TObject);
    procedure Average1Click(Sender: TObject);
    procedure MinValue1Click(Sender: TObject);
    procedure MaxValue1Click(Sender: TObject);
    procedure Displayalldatainthischart1Click(Sender: TObject);
  private
    FFilePath: string;      //������ ������ ���
    //FMEXA7000Data: TEventData2;
    FCriticalSection: TCriticalSection;
    FMonitorStart: Boolean; //Ÿ�̸� ���� �Ϸ��ϸ� True
    FFirst: Boolean; //Ÿ�̸� ���� �Ϸ��ϸ� True
    FMsgList: TStringList;  //Message�� �����ϴ� ����Ʈ

    procedure OnSignal(Sender: TIPCThread2; Data: TEventData2);
    procedure UpdateTraceData(var Msg: TEventData2); message WM_EVENT_DATA;
  public
    FOwnerHandle: THandle;//Owner form handle
    FOwnerListIndex: integer;//TList�� ����Ǵ� Index(�����ÿ� �ʿ���)
    FIPCMonitor: TIPCMonitor2;//���� �޸� �� �̺�Ʈ ��ü
    FSharedName: string;//���� �޸� �̸�
    FLabelName: string; //����͸��ϰ��� �ϴ� ����Ÿ�� �̸��� ������.
    FWatchName: string; //component �̸��� ������.(FunctionCode+Address)
    FWatchValue: string; //����͸� ����Ÿ
    FWatchTag: integer; //����Ÿ�� ������ ������.
    FDivisor: integer; //����

    FWatchValueRecord: TEventData2; //���¿� ��û����, ��� ����Ÿ�� �Ѱ��� ��Ʈ�� ǥ���ϱ� ����.
    FDisplayAllData: Boolean; //�Ѱ��� ��Ʈ�� ��� ǥ���ҷ��� True

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
    FCurrentValueX: double;

    FIsAverageValueGraph: boolean;//��հ��� �׷����� ǥ���ϸ� True
    FAverageValueChannel: integer;// FIsCurrentValueGraph=true �� ��� ä�� ��ȣ
    FAverageValueX: double;

    FIsMinValueGraph: boolean;//�ּҰ��� �׷����� ǥ���ϸ� True
    FMinValueChannel: integer;// FIsCurrentValueGraph=true �� ��� ä�� ��ȣ
    FMinValueX: double;

    FIsMaxValueGraph: boolean;//�ִ밪�� �׷����� ǥ���ϸ� True
    FMaxValueChannel: integer;// FIsCurrentValueGraph=true �� ��� ä�� ��ȣ
    FMaxValueX: double;

    procedure InitVar;
    procedure DisplayMessage(Msg: string);
    procedure WatchValue2Screen_Analog(Name: string; AValue: string);

    procedure ApplyAvgSize;

    procedure LoadConfigDataini2Form(ConfigForm:TWatchConfigF);
    procedure LoadConfigDataini2Var;
    procedure SaveConfigDataForm2ini(ConfigForm:TWatchConfigF);
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

  FMsgList := TStringList.Create;
  FMonitorStart := False;
  FFirst := True;
  LoadConfigDataini2Var;
  LoadConfigDataini2Form(nil);
  SetLength(FWatchValueAry, FAvgSize);
  //FillChar(FWatchValueAry,Sizeof(FWatchValueAry) * FAvgSize,0);
  FCurrentAryIndex := 0;
  FFirstCalcAry := True;

end;

procedure TWatchF.LoadConfigDataini2Form(ConfigForm: TWatchConfigF);
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
          FilenameEdit.Text := ReadString(MEXA7000_SECTION, 'XML File Name1', 'Mexa7000p.xml');
        end;//with
      end
      else
      begin
        AvgEdit.Text := ReadString(MEXA7000_SECTION, 'Aveage Size', '1');
      end;
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
      FAvgSize := ReadInteger(MEXA7000_SECTION, 'Aveage Size', 1);
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TWatchF.SaveConfigDataForm2ini(ConfigForm: TWatchConfigF);
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
          WriteString(MEXA7000_SECTION, 'XML File Name1', FilenameEdit.Text);
        end;
      end
      else
      begin
        WriteString(MEXA7000_SECTION, 'Aveage Size', AvgEdit.Text);
      end;
    end;//with
  finally
    iniFile.Free;
    iniFile := nil;
  end;//try
end;

procedure TWatchF.SetConfigData;
var WT1600WatchConfigF: TWatchConfigF;
begin
  WT1600WatchConfigF := TWatchConfigF.Create(Application);
  with WT1600WatchConfigF do
  begin
    try
      LoadConfigDataini2Form(WT1600WatchConfigF);
      if ShowModal = mrOK then
      begin
        SaveConfigDataForm2ini(WT1600WatchConfigF);
        LoadConfigDataini2Var;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TWatchF.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  try
    if FMonitorStart then
    begin
      DisplayMessage('');
    end;

    if FFirst then
    begin
      FFirst := False;
      FSharedName := FWatchName;
      FIPCMonitor := TIPCMonitor2.Create(0, FSharedName, True);
      FIPCMonitor.OnSignal := OnSignal;
      FIPCMonitor.Resume;
    end;
  finally
    FMonitorStart := True;
    Timer1.Enabled := True;
  end;//try

end;

procedure TWatchF.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FMonitorStart := False;
  Action := caFree;
  SendMessage(FOwnerHandle, WM_WATCHFORM_CLOSE, FOwnerListIndex, 0);
end;

procedure TWatchF.OnSignal(Sender: TIPCThread2; Data: TEventData2);
var
  i,dcount: integer;
begin
  if not FMonitorStart then
    exit;

  FDivisor := 1;
  
  case FWatchTag of
    1: begin
      FWatchValue := Data.CO2;
    end;
    2: begin
      FWatchValue := Data.CO_L;
    end;
    3: begin
      FWatchValue := Data.O2;
    end;
    4: FWatchValue := Data.NOx;
    5: FWatchValue := Data.THC;
    6: FWatchValue := Data.CH4;
    7: FWatchValue := Data.non_CH4;
    8: FWatchValue := format('%f',[Data.CollectedValue]);
  end;

  if FDisplayAllData then
  begin
    FWatchValueRecord.CO2 := Data.CO2;
    FWatchValueRecord.CO_L := Data.CO_L;
    FWatchValueRecord.O2 := Data.O2;
    FWatchValueRecord.NOx := Data.NOx;
    FWatchValueRecord.THC := Data.THC;
    FWatchValueRecord.CH4 := Data.CH4;
    FWatchValueRecord.non_CH4 := Data.non_CH4;
    FWatchValueRecord.CollectedValue := Data.CollectedValue;
  end;

  //StatusBar1.SimplePanel := True;
  //StatusBar1.SimpleText := Data.IPAddress + ' ����Ÿ ����';

  SendMessage(Handle, WM_EVENT_DATA, 0,0);
end;

procedure TWatchF.UpdateTraceData(var Msg: TEventData2);
var
  i, j: integer;
  tmpStr: string;
  tmpByte, ProcessBitCnt: Byte;
  IsFirst, IsSecond: Boolean;
begin

  //StatusBar1.SimpleText := FWT1600Data.IPAddress + ' ó����...';

  //���ŵ� ����Ÿ�� ȭ�鿡 �ѷ���
  if FWatchValue = '' then
    FWatchValue := '0.0';

  WatchValue2Screen_Analog(FWatchName, FWatchValue);
end;

procedure TWatchF.Displayalldatainthischart1Click(Sender: TObject);
var
  Li : integer;
begin
  Displayalldatainthischart1.Checked := not Displayalldatainthischart1.Checked;
  FDisplayAllData := Displayalldatainthischart1.Checked;

  if FDisplayAllData then
  begin
    for Li := iPlot1.ChannelCount - 1 downto 0 do
    begin
      iPlot1.DeleteChannel(Li);
      //iPlot1.DeleteYAxis(Li);
    end;

    for Li := 0 to MAXCHANNELCOUNT - 1 do
    begin
      FCurrentValueChannel := iPlot1.AddChannel;
      iPlot1.Channel[FCurrentValueChannel].VisibleInLegend := True;
      //iPlot1.AddYAxis;
    end;                                      
    
    FCurrentValueX := 0;
  end;//if
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

procedure TWatchF.WatchValue2Screen_Analog(Name: string; AValue: string);
var
  tmpdouble: double;
  tmpValue: string;
begin
  tmpdouble := StrToFloatDef(AValue, 0.0)/FDivisor;
  tmpValue := format('%.2f',[tmpdouble]);

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
      if FCurrentAryIndex = 0 then
        FWatchValueAvg := FWatchValueSum
      else
        FWatchValueAvg := FWatchValueSum / FCurrentAryIndex
    else
      FWatchValueAvg := FWatchValueSum / FAvgSize;

    FWatchValueAry[FCurrentAryIndex] := tmpdouble;
    //Label4.Caption := format('%.2f',[FWatchValueSum]);
  finally
    FCriticalSection.Leave;
  end;//try

  FWatchValue := FloatToStr(tmpdouble);
  case PageControl1.ActivePageIndex of
    0: begin //simple
      WatchLabel.Caption := tmpValue;
      AvgLabel.Caption := format('%.2f',[FWatchValueAvg]);//FloatToStr(FWatchValueAvg);
    end;
    1: begin //Min/Max
      MinLabel.Caption :=  format('%.2f',[FWatchValueMin]);//FloatToStr(FWatchValueMin);
      MaxLabel.Caption :=  format('%.2f',[FWatchValueMax]);//FloatToStr(FWatchValueMax);
      CurLabel.Caption := tmpValue;
    end;
    2: begin //Graph
      if not FDisplayAllData then
      begin
        if FIsCurrentValueGraph then
        begin
          iPlot1.Channel[FCurrentValueChannel].AddXY(FCurrentValueX, tmpdouble);
          FCurrentValueX := FCurrentValueX + 1;
        end;

        if FIsAverageValueGraph then
        begin
          iPlot1.Channel[FAverageValueChannel].AddXY(FAverageValueX, FWatchValueAvg);
          FAverageValueX := FAverageValueX + 1;
        end;

        if FIsMinValueGraph then
        begin
          iPlot1.Channel[FMinValueChannel].AddXY(FMinValueX, FWatchValueMin);
          FMinValueX := FMinValueX + 1;
        end;

        if FIsMaxValueGraph then
        begin
          iPlot1.Channel[FMaxValueChannel].AddXY(FMaxValueX, FWatchValueMax);
          FMaxValueX := FMaxValueX + 1;
        end;
      end;
    end;
    3: begin //Meter
    end;
    4: begin //Bar
    end;
  end;//case

  if FDisplayAllData then
  begin
    tmpdouble := StrToFloatDef(FWatchValueRecord.CO2, 0.0);
    iPlot1.Channel[0].AddXY(FCurrentValueX, tmpdouble);
    tmpdouble := StrToFloatDef(FWatchValueRecord.CO_L, 0.0);
    iPlot1.Channel[1].AddXY(FCurrentValueX, tmpdouble);
    tmpdouble := StrToFloatDef(FWatchValueRecord.O2, 0.0);
    iPlot1.Channel[2].AddXY(FCurrentValueX, tmpdouble);
    tmpdouble := StrToFloatDef(FWatchValueRecord.NOx, 0.0);
    iPlot1.Channel[3].AddXY(FCurrentValueX, tmpdouble);
    tmpdouble := StrToFloatDef(FWatchValueRecord.THC, 0.0);
    iPlot1.Channel[4].AddXY(FCurrentValueX, tmpdouble);
    tmpdouble := StrToFloatDef(FWatchValueRecord.CH4, 0.0);
    iPlot1.Channel[5].AddXY(FCurrentValueX, tmpdouble);
    tmpdouble := StrToFloatDef(FWatchValueRecord.non_CH4, 0.0);
    iPlot1.Channel[6].AddXY(FCurrentValueX, tmpdouble);
    tmpdouble := FWatchValueRecord.CollectedValue;
    iPlot1.Channel[7].AddXY(FCurrentValueX, tmpdouble);

    FCurrentValueX := FCurrentValueX + 1;
  end;
end;

procedure TWatchF.FormDestroy(Sender: TObject);
begin
  FWatchValueAry := nil;

  FCriticalSection.Free;

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

procedure TWatchF.CurrentValue1Click(Sender: TObject);
begin
  FIsCurrentValueGraph := True;
  FCurrentValueChannel := iPlot1.AddChannel;
  iPlot1.Channel[FCurrentValueChannel].VisibleInLegend := False;
  FCurrentValueX := 0;
  CurrentValue1.Enabled := False;
end;

procedure TWatchF.Average1Click(Sender: TObject);
begin
  FIsAverageValueGraph := True;
  FAverageValueChannel := iPlot1.AddChannel;
  iPlot1.Channel[FAverageValueChannel].VisibleInLegend := False;
  FAverageValueX := 0;
  Average1.Enabled := False;
end;

procedure TWatchF.MinValue1Click(Sender: TObject);
begin
  FIsMinValueGraph := True;
  FMinValueChannel := iPlot1.AddChannel;
  iPlot1.Channel[FMinValueChannel].VisibleInLegend := False;
  FMinValueX := 0;
  MinValue1.Enabled := False;
end;

procedure TWatchF.MaxValue1Click(Sender: TObject);
begin
  FIsMaxValueGraph := True;
  FMaxValueChannel := iPlot1.AddChannel;
  iPlot1.Channel[FMaxValueChannel].VisibleInLegend := False;
  FMaxValueX := 0;
  MaxValue1.Enabled := False;
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

end.




