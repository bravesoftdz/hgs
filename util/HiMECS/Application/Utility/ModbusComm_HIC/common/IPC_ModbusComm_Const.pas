unit IPC_ModbusComm_Const;

interface

type
  //IPCClient�� Config Data ������ ���
  //3���� �迭�� ũ�� ������(0..50) stack over flow ���� �߻���)
  TConfigData_ModbusComm = packed record
    XAxisData: array[0..99] of integer;
    YAxisData: array[0..99] of integer;
    ZAxisData: array[0..99] of integer;
    XAxisData_f: array[0..99] of single;
    YAxisData_f: array[0..99] of single;
    ZAxisData_f: array[0..99] of single;
    DataBuf: array[0..255] of integer;
    DataBuf_f: array[0..255] of single;
    //����Ÿ ���� �ݳ�(Function 16�� ��� Quantity of Registers)
    //Byte Count = NumOfData x 2
    NumOfData_X: integer;  //XAxis data count
    NumOfData_Y: integer;  //YAxis data count
    NumOfData_Z: integer;  //ZAxis data count
    NumOfData: integer;    //Matrix data count

    SlaveNo: integer;
    ModBusFunctionCode: integer;
    ModBusAddress: string[5];
    //2: ptAnalog, 4: ptMatrix1, 5: ptMatrix2, 6: ptMatrix3, 7: ptMatrix1f...
    ParameterType: integer;
    //ASCII Mode = 0, RTU Mode = 1, RTU mode simulation = 3;
    ModbusMode: integer;
    //0: Repeat Read, 1: Only One read(config data), 2: Only One Write, 3: Only One Write for Confirm
    CommMode: integer;
    BlockNo: integer;
    ModBusMapFileName: string[255];
    //IPCClient�� Free�ɶ� pulse event�� �ѹ� �ϹǷ� Termination=true�� �ϸ� no action�ϱ� ����
    //Read�ÿ��� ���� �� �������� Write�ÿ� ���� ���ܼ� �ذ���(2013.2.20)
    //IPCClient.free ������ True�� �� ��
    Termination: boolean;
  end;

const
  MODBUSCOMM_EVENT_NAME = 'MONITOR_EVENT_MODBUSCOMM';

implementation

end.
