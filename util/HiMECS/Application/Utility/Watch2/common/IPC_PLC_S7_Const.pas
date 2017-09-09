unit IPC_PLC_S7_Const;

interface

type
  TEventData_PLC_S7 = packed record
    DataByte: array[0..255] of byte;
    DataWord: array[0..255] of word;
    DataInt: array[0..255] of smallint;
    DataDWord: array[0..255] of cardinal;
    DataDInt: array[0..255] of integer;
    DataFloat: array[0..255] of extended;
    DataType: integer; //S7 Data Type
    NumOfData: integer;//����Ÿ ���� �ݳ�
    NumOfBit: integer;//Bit ���� �ݳ�(01 function �� ��� Bit ������ ���޵Ǳ� ������)
    BlockNo: integer;
    ModBusMapFileName: string[255];
    PowerOn: Boolean;
  end;

const
  PLC_S7_EVENT_NAME = 'MONITOR_EVENT_PLC_S7';

implementation

end.
