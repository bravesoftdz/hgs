unit IPC_FlowMeter_Const;

interface

type
  TEventData_FlowMeter = packed record
    InpDataBuf: array[0..255] of integer;
    InpDataBuf2: array[0..255] of Byte;
    NumOfData: integer;//����Ÿ ���� �ݳ�
    NumOfBit: integer;//Bit ���� �ݳ�(01 function �� ��� Bit ������ ���޵Ǳ� ������)
    //Block Mode �ϰ�� Modbus Block Start Address,
    //Individual Mode�ϰ�� Modbus Address
    ModBusFunctionCode: integer;
    ModBusAddress: array[0..19] of char;//String ������ �����޸𸮿� ��� �Ұ���
    //ASCII Mode = 0, RTU Mode = 1;
    ModBusMode: integer;
    PowerOn: Boolean;
  end;

const
  FLOWMETER_EVENT_NAME = 'MONITOR_EVENT_FlowMeter';

implementation

end.
