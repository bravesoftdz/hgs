unit IPC_HIC_Const;

interface

type
  //HIC Data�� Monitor��  ������ ���
  TEventData_HIC = packed record
    //Config Data�� ���(DataMode=CM_CONFIG_READ) InpDataBuf �迭��
    //Matrix1 = XAxis Data ������ Value Data ��
    //Matrix2 = XAxis Data, YAxis Data, Value Data
    //Matrix3 = XAxis Data, YAxis Data, YAxis Data, Value Data ��
    InpDataBuf: array[0..255] of integer;
    InpDataBuf_b: array[0..255] of Byte;
    InpDataBuf_f: array[0..255] of single;
    NumOfData: integer;//����Ÿ ���� �ݳ�
    NumOfBit: integer;//Bit ���� �ݳ�(01 function �� ��� Bit ������ ���޵Ǳ� ������)
    //Block Mode �ϰ�� Modbus Block Start Address,
    //Individual Mode�ϰ�� Modbus Address
    ModBusFunctionCode: integer;
    ModBusAddress: string[5];
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
    PowerOn: Boolean;
  end;

const
  HIC_EVENT_NAME = 'MONITOR_EVENT_HIC';

implementation

end.
