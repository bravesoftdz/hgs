unit UnitAlarmConfigInterface;

interface

uses SynCommons, UnitAlarmConfigClass;

type
  IAlarmConfig = interface(IInvokable)
    ['{B53A6DD3-C007-4DDF-8DD9-8D1D597E21D5}']
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
    procedure NotifyAlarmConfigChanged(const UniqueEngine: TRawUTF8DynArray; const ACount: integer; const ASenderUrl: string);
  end;

implementation

end.
