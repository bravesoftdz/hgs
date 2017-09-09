unit DataSave2FileThread;

interface

uses
  Windows, Classes, Forms, MyKernelObject, CommonUtil, DataSaveConst, SysUtils;

type
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
    FTagData: string; //Tag�̸��� ������
    FSaving: Boolean; //����Ÿ �������̸� True

    //������ ó�� ������ �� ����Ÿ�� ó�� ����� ��� True
    FIsFileFirst: Boolean;    //���� �Ӹ��� ������ ����ϱ� ����
    constructor Create(AOwner: TForm);
    destructor Destroy; override;
    function MakeCSVData: Boolean;
  end;

implementation

uses EngineTotal_DataSave_Main;

{ TDataSaveThread }

constructor TDataSave2FileThread.Create(AOwner: TForm);
begin
  inherited Create(True);
  FOwner := AOwner;
  FDataSaveEvent := TEvent.Create('EngineTotalDataSaveEvent'+IntToStr(GetCurrentThreadID),False);
end;

destructor TDataSave2FileThread.Destroy;
begin
  FDataSaveEvent.Free;
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
            //������ ó�� ������ ��� ���� �Ӹ��� ����� ������
            if SaveData2DateFile('Eng_Total_CSVFile','csv', FStrData, soFromEnd) then
              SaveData2DateFile('Eng_Total_CSVFile','csv', FTagData, soFromBeginning);
          end;
          FC_FIXED:
          begin
            if SaveData2FixedFile('Eng_Total_CSVFile',FFileName, FStrData, soFromEnd)then
              SaveData2FixedFile('Eng_Total_CSVFile',FFileName, FTagData, soFromBeginning)
          end;
        end;//case

        //���͹��� �����͸� ������ ��� �ش� �ð����� �����带 sleep ��Ŵ
        if DataSaveMain.RB_byinterval.Checked then
        begin
          sleep(StrToInt(DataSaveMain.Ed_interval.Text));
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
