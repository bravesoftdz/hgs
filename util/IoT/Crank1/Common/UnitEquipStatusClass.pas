unit UnitEquipStatusClass;

interface

uses Classes, System.SysUtils, Generics.Legacy, BaseConfigCollect, UnitTimerPool,
  SynCommons;//OtlTaskControl

const
  EquipNameAry : array [0..29] of string = ( //ũ��ũ 1���� ������� ����Ʈ
    '394','391','392','351','393','387','358','389','396','259',
    '258','253','252','251','388','385','384','399','327','386',
    '254','257','322','324','346','325','345','344','339','294'
    );

const
  __TEquipRunStatusRecord_DynArr =
  'RunStatus_DynArr array of string LastUpdated_DynArr array of TDateTime';

type
  TEquipRunStatusRecord = packed record
    RunStatus_DynArr: array of string;
    LastUpdated_DynArr: array of TDateTime;
  end;

  //  TTimerTask = class(TOmniWorker)
//  public
//    procedure OnTimer;
//  end;

  TEquipStatusItem = class(TCollectionItem)
  private
    FEquipName,
    FEquipDesc,
    FRunStatus: string;
    FRunComponent,
    FRunTextComponent,
    FCommComponent,
    FEquipNoComponent,
    FProductComponent: TComponent;
    FLastUpdatedDate: TDateTime;
    FCommConnected: Boolean;
    FCommStatusTimerHandle: integer;
    FOnUpdateCommStatusName: string; //Timer Trigger Name
//    FOnUpdateCommStatus: TVpTimerTriggerEvent;
  public
//    property OnUpdateCommStatus: TVpTimerTriggerEvent read FOnUpdateCommStatus write FOnUpdateCommStatus;
    procedure AssignTo(Dest: TPersistent); override;
    function SetCommConnected(AExpiredSec: integer): Boolean;
  published
    property EquipName: string read FEquipName write FEquipName;
    property EquipDesc: string read FEquipDesc write FEquipDesc;
    //'0' : stop, '1': run
    property RunStatus: string read FRunStatus write FRunStatus;
    property RunComponent: TComponent read FRunComponent write FRunComponent;
    property RunTextComponent: TComponent read FRunTextComponent write FRunTextComponent;
    property CommComponent: TComponent read FCommComponent write FCommComponent;
    property EquipNoComponent: TComponent read FEquipNoComponent write FEquipNoComponent;
    property ProductComponent: TComponent read FProductComponent write FProductComponent;
    property CommConnected: Boolean read FCommConnected write FCommConnected;
    property LastUpdatedDate: TDateTime read FLastUpdatedDate write FLastUpdatedDate;
  end;

  TEquipStatusCollect<T: TEquipStatusItem> = class(Generics.Legacy.TCollection<T>)
  public
    procedure GetRunStatusEquipList(ACollect: TEquipStatusCollect<TEquipStatusItem>;
      ARunStatus: string);
    procedure GetCommStatusEquipList(ACollect: TEquipStatusCollect<TEquipStatusItem>;
      ACommConnected: Boolean);
    procedure UpdateCommConnected(AExpiredSec: integer);
    function GetRunStatusEquipCount(AStatus: string): integer;
    function GetDisconnectedEquipCount: integer;
  end;

  TEquipStatusInfo = class(TpjhBase)
  private
    FEquipStatusCollect: TEquipStatusCollect<TEquipStatusItem>;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Clear;
    procedure InitEquipStatusInfo;
  published
    function GetCollectIndex(AEquipName: string): integer;
    procedure SetRunStatus2Collect(AEquipName, AStatus: string);
    procedure SetCollectFromRecord(ARecord: TEquipRunStatusRecord);

    property EquipStatusCollect: TEquipStatusCollect<TEquipStatusItem> read FEquipStatusCollect write FEquipStatusCollect;
  end;

implementation

uses System.DateUtils, mORMot;

procedure TEquipStatusInfo.Clear;
begin

end;

constructor TEquipStatusInfo.Create(AOwner: TComponent);
begin
  FEquipStatusCollect := TEquipStatusCollect<TEquipStatusItem>.Create;
end;

destructor TEquipStatusInfo.Destroy;
begin
  FEquipStatusCollect.Free;

  inherited;
end;

function TEquipStatusInfo.GetCollectIndex(AEquipName: string): integer;
var
  i: integer;
  LESItem: TEquipStatusItem;
begin
  Result := -1;

  for i := 0 to EquipStatusCollect.Count - 1 do
  begin
    LESItem := EquipStatusCollect.Items[i];
    if LESItem.EquipName = AEquipName then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TEquipStatusInfo.InitEquipStatusInfo;
var
  LESItem: TEquipStatusItem;
  i: integer;
begin
  EquipStatusCollect.Clear;

  for i := Low(EquipNameAry) to High(EquipNameAry) do
  begin
    LESItem := EquipStatusCollect.Add;
    LESItem.EquipName := EquipNameAry[i];
//    LESItem.LastUpdatedDate := now;
  end;
end;

procedure TEquipStatusInfo.SetCollectFromRecord(ARecord: TEquipRunStatusRecord);
var
  i: integer;
  LESItem: TEquipStatusItem;
begin
  for i := Low(ARecord.RunStatus_DynArr) to High(ARecord.RunStatus_DynArr) do
  begin
    LESItem := EquipStatusCollect.Items[i];

    if ARecord.LastUpdated_DynArr[i] > IncYear(now, -100) then
    begin
      LESItem.LastUpdatedDate := ARecord.LastUpdated_DynArr[i];
    end;

    //��� ������ �Ǿ� ���� ��쿡�� ������ ������
    //3�а�(150��) �����Ͱ� ������ ��� ������ ������
    if LESItem.SetCommConnected(150) then
    begin
      LESItem.RunStatus := ARecord.RunStatus_DynArr[i];
    end;
  end;

  //3�а�(150��) �����Ͱ� ������ ��� ������ ������
//  EquipStatusCollect.UpdateCommConnected(150);
end;

procedure TEquipStatusInfo.SetRunStatus2Collect(AEquipName, AStatus: string);
var
  i: integer;
  LESItem: TEquipStatusItem;
begin
  i := GetCollectIndex(AEquipName);

  if i <> -1 then
  begin
    LESItem := EquipStatusCollect.Items[i];
    LESItem.RunStatus := AStatus;
    LESItem.LastUpdatedDate := now;
  end;
end;

{ TTimerTask }

//procedure TTimerTask.OnTimer;
//begin
//
//end;

{ TEquipStatusCollect<T> }

procedure TEquipStatusCollect<T>.GetCommStatusEquipList(
  ACollect: TEquipStatusCollect<TEquipStatusItem>; ACommConnected: Boolean);
//ACommConnected = True �̸� ��� ����� ��� ����Ʈ �ݳ�
//ACommConnected = False �̸� ��� ���� ��� ����Ʈ �ݳ�
var
  i: integer;
  LESItem: TEquipStatusItem;
begin
  for i := 0 to Count - 1 do
  begin
    if TEquipStatusItem(Items[i]).CommConnected = ACommConnected then
    begin
      LESItem := ACollect.Add;
      TEquipStatusItem(Items[i]).AssignTo(LESItem);
    end;
  end;
end;

function TEquipStatusCollect<T>.GetDisconnectedEquipCount: integer;
var
  i: integer;
begin
  Result := 0;

  for i := 0 to Count - 1 do
    if not TEquipStatusItem(Items[i]).CommConnected then
      Inc(Result);
end;

function TEquipStatusCollect<T>.GetRunStatusEquipCount(AStatus: string): integer;
//AStatus = '1' �̸� ���� ��� ���� ��ȯ
//        = '0' �̸� ��� ��� ���� ��ȯ
var
  i: integer;
begin
  Result := 0;

  for i := 0 to Count - 1 do
    if (TEquipStatusItem(Items[i]).CommConnected) and (TEquipStatusItem(Items[i]).RunStatus = AStatus) then
      Inc(Result);
end;

procedure TEquipStatusCollect<T>.GetRunStatusEquipList(
  ACollect: TEquipStatusCollect<TEquipStatusItem>; ARunStatus: string);
//ARunStatus = '1'�̸� ���� ������ ��� ����Ʈ ��ȯ
//ARunStatus = '0'�̸� ��� ������ ��� ����Ʈ ��ȯ
var
  i: integer;
  LESItem: TEquipStatusItem;
begin
  for i := 0 to Count - 1 do
  begin
    if TEquipStatusItem(Items[i]).CommConnected then
    begin
      if TEquipStatusItem(Items[i]).RunStatus = ARunStatus then
      begin
        LESItem := ACollect.Add;
        TEquipStatusItem(Items[i]).AssignTo(LESItem);
      end;
    end;
  end;
end;

procedure TEquipStatusCollect<T>.UpdateCommConnected(AExpiredSec: integer);
//AExpiredSec(��) ������ LastUpdatedDate �Ǿ����� ��� ������ ����
var
  i: integer;
  LESItem: TEquipStatusItem;
begin
  for i := 0 to Count - 1 do
  begin
    TEquipStatusItem(Items[i]).CommConnected :=
      IncSecond(now, -AExpiredSec) < TEquipStatusItem(Items[i]).LastUpdatedDate;
  end;
end;

{ TEquipStatusItem }

procedure TEquipStatusItem.AssignTo(Dest: TPersistent);
begin
  inherited;

  CopyObject(Self, Dest);
end;

function TEquipStatusItem.SetCommConnected(AExpiredSec: integer): boolean;
begin
  FCommConnected := IncSecond(now, -AExpiredSec) < LastUpdatedDate;
  Result := FCommConnected;
end;

initialization
  TTextWriter.RegisterCustomJSONSerializerFromText(
    TypeInfo(TEquipRunStatusRecord), __TEquipRunStatusRecord_DynArr);

end.
