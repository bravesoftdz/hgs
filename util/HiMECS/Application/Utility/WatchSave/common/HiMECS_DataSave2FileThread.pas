unit HiMECS_DataSave2FileThread;

interface

uses
  Windows, Classes, Forms, MyKernelObject, CommonUtil, SysUtils;

type
  TSaveMedia = set of (SM_DB, SM_FILE);
  TFileName_Convetion = (FC_YMD, FC_FIXED);

  TDataSave2FileThread = class(TThread)
  private
    FOwner: TForm;
  protected
    procedure Execute; override;
  public
    FName_Convention: TFileName_Convetion;//���Ͽ� ����ÿ� �����̸��ο� ���
    FFileName: string; //����Ÿ�� ������ File �̸�(������ ���� �����)
    FDataSaveEvent: TEvent;//Data Save Thread�� ���� ������ �˸��� Event Handle
    FStrBuf: array[0..26] of string;
    FStrData: string;
    FDataList: TStringList;
    FTagData: string; //Tag�̸��� ������
    FSaving: Boolean; //����Ÿ �������̸� True
    FUseInterval: Boolean;
    FInterval: integer;

    //������ ó�� ������ �� ����Ÿ�� ó�� ����� ��� True
    FIsFileFirst: Boolean;    //���� �Ӹ��� ������ ����ϱ� ����

    FAppendString2FileName: string;
    constructor Create(AOwner: TForm);
    destructor Destroy; override;
    function MakeCSVData: Boolean;
  end;

implementation

{ TDataSaveThread }

constructor TDataSave2FileThread.Create(AOwner: TForm);
begin
  inherited Create(True);
  FOwner := AOwner;
  FDataSaveEvent := TEvent.Create('ECSDataSaveEvent'+IntToStr(GetCurrentThreadID),False);
end;

destructor TDataSave2FileThread.Destroy;
begin
  FDataSaveEvent.Free;

  if Assigned(FDataList) then
    FreeAndNil(FDataList);

  inherited;
end;

procedure TDataSave2FileThread.Execute;
begin
  while not terminated do
  begin
    if FDataSaveEvent.Wait(INFINITE) then
    begin
      if not terminated then
      begin
        FSaving := True;
        case FName_Convention of
          FC_YMD:
          begin
            if Assigned(FDataList) then //Bulk Data�� ��� 100�Ǵ� �ѹ��� ���Ͽ� ������
            begin
              //������ ó�� ������ ��� ���� �Ӹ��� ����� ������
              if SaveData2DateFile('CSVFile',FAppendString2FileName, FDataList, soFromEnd) then
                SaveData2DateFile('CSVFile',FAppendString2FileName, FTagData, soFromBeginning);

              FDataList.Clear;
            end
            else
            begin
              //������ ó�� ������ ��� ���� �Ӹ��� ����� ������
              if SaveData2DateFile('CSVFile',FAppendString2FileName, FStrData, soFromEnd) then
                SaveData2DateFile('CSVFile',FAppendString2FileName, FTagData, soFromBeginning);
            end;
          end;
          FC_FIXED:
          begin
            if SaveData2FixedFile('CSVFile',FFileName, FStrData, soFromEnd)then
              SaveData2FixedFile('CSVFile',FFileName, FTagData, soFromBeginning)
          end;
        end;//case

        //���͹��� �����͸� ������ ��� �ش� �ð����� �����带 sleep ��Ŵ
        //if DataSaveMain.RB_byinterval.Checked then
        if FUseInterval then
        begin
          //sleep(StrToInt(DataSaveMain.Ed_interval.Text));
          sleep(FInterval);
        end;

        FSaving := False;
      end;//if
    end;//if
 end;//while
end;

//����Ÿ�� ����µ� �����ϸ� True�� ��ȯ��
function TDataSave2FileThread.MakeCSVData: Boolean;
var
  i: integer;
begin
  Result := False;

  FStrData := '';

  FStrData := FStrBuf[0];

  for i := 1 to 26 do
    FStrData := FStrData + ',' + FStrBuf[i];

  if Pos(',,',FStrData) = 0 then
    Result := True;
end;

end.
