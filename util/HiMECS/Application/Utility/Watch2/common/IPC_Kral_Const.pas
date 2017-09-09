unit IPC_Kral_Const;

interface

type
  TEventData_Kral = packed record
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
    BlockNo: integer;
  end;

const
  KRAK_EVENT_NAME = 'MONITOR_EVENT_Kral';

implementation

end.
