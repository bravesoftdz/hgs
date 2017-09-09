unit UnitCraneIoTConfigInterface;

interface

uses SynCommons, UnitAlarmConfigClass;

type
  ICraneIoTConfig = interface(IInvokable)
    ['{F5C46078-FE54-45A8-98CA-391D50C8B913}']
    //���� ����Ʈ ��ȯ
    function GetPlantList: TRawUTF8DynArray;
    //���� ���� �ִ� ���� ����Ʈ ��ȯ
    procedure GetEngineListFromPlant(PlantName: string; out EngList: TAlarmConfigCollect);
    //������ ����(�±�)����Ʈ ��ȯ
    procedure GetTagListFromEngine(ProjNo, EngNo: string; out TagList: TAlarmConfigEPCollect);
    //������ ������ �˶� ���� ����Ʈ�� DB�� ���� ��ȸ�Ͽ� ��ȯ
    procedure GetAlarmConfigList(UserId, CatCode, ProjNo, EngNo: string;
      out TagNames: TAlarmConfigCollect);
    //�˶� �������� DB�� ������
    function SetAlarmConfigList2(const TagNames: RawJSON): Boolean;
    procedure SetAlarmConfigList(TagNames: TAlarmConfigCollect);
  end;

implementation

end.
