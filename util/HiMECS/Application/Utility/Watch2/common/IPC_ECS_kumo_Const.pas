unit IPC_ECS_kumo_Const;

interface

type
  TEventData_ECS_kumo = packed record
    InpDataBuf: array[0..255] of integer;
    InpDataBuf2: array[0..255] of Byte;
    InpDataBuf_double: array[0..255] of double;
    NumOfData: integer;//����Ÿ ���� �ݳ�
    NumOfBit: integer;//Bit ���� �ݳ�(01 function �� ��� Bit ������ ���޵Ǳ� ������)
    //Block Mode �ϰ�� Modbus Block Start Address,
    //Individual Mode�ϰ�� Modbus Address
    ModBusFunctionCode: integer;
    ModBusAddress: string[5];//String ������ �����޸𸮿� ��� �Ұ���
    //ModBusAddress: array[0..19] of char;//String ������ �����޸𸮿� ��� �Ұ���
    //ASCII Mode = 0, RTU Mode = 1, RTU mode simulation = 3;
    ModBusMode: integer;
    //ModBusComConst�� TCommMode �� integer�� �����
    //TCommMode = (CM_DATA_READ, CM_CONFIG_READ, CM_DATA_WRITE, CM_CONFIG_WRITE, CM_CONFIG_WRITE_CONFIRM)
    DataMode: integer;
    //2: ptAnalog, 4: ptMatrix1, 5: ptMatrix2, 6: ptMatrix3, 7: ptMatrix1f...
    ParameterType: integer;
    BlockNo: integer;
    //9999: ����,
    ErrorCode: integer;
    ModBusMapFileName: string[255];
    IPAddress: string[16];
    PowerOn: Boolean;
  end;

const
  ECS_KUMO_EVENT_NAME = 'MONITOR_EVENT_ECS_kumo';

implementation

end.
