unit DataSaveConst;

interface

uses messages;

const
  SAVEINIFILENAME = '.\DataSave_ECS.ini';
  SAVEDATA_FIX_SECTION = 'Fix Condition';
  SAVEDATA_PERIOD_SECTION = 'Period Condition';
  SAVEDATA_MEDIA_SECTION = 'Save Media';
  SAVEDATA_DB_SECTION = 'Database';
  SAVEDATA_ETC_SECTION = 'ETC';

  SAVEDATA_DATABASE_NAME = 'ModBusCom_kumo';
  SAVEDATA_LOGIN_ID = 'KUMO_ECS_SAVE';
  SAVEDATA_PASSWD = 'KUMO_ECS_SAVE';

  INIFILENAME = '.\kumo_ECS_DatasaveConfig_';
  DeviceName = 'KUMO-ECS';
  DATASAVE_SECTION = 'Datasave';
  ENGMONITOR_SECTION = 'Engine Monitor';
  WM_EVENT_ECS = WM_USER + 102;
  WM_EVENT_DYNAMO = WM_USER + 103;

type

  THiMap = class(TObject)
    FSid: integer;//ID = 200�� ���� Block Scanning��
    FName: string;//�̸�
    FAddress: string;//Modbus �ּ�
    FDescription: string;//����
    FBlockNo: integer;//ModBus Block Scanning ��ȣ(DB�� cnt �ʵ� ��)
    FMaxval: real;//�ִ밪
    FUnit: string;//����
    FAlarm: Boolean;//Alarm�̸� True
    FValue: Integer;//������- MpdBus ������κ��� ������
    FContact: Integer;//1: A����(1�϶� On), 2: B����(1�϶� Off), 3: C����
  end;

  TModbusBlock = class(TObject)
    FStartAddr: string;//Block Scanning ���� �ּ�
    FCount: integer;   //Block Scanning Count
  end;

implementation

end.
 