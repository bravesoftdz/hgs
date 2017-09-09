unit IPC_MT210_Const;

interface

type
  TEventData_MT210 = packed record
    FUnit: string[10]; //���� ����
    FState: string[2];//���� ����
    FData: double;//���� ����Ÿ ����
    PowerOn: Boolean;
 end;

const
  MT210_EVENT_NAME = 'MONITOR_EVENT_MT210';

implementation

end.
