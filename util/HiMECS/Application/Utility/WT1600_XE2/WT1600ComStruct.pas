unit WT1600ComStruct;

interface

Type
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
  public

  end;

  TWMWT1600Data = record
    IPAddress: string;
    URMS1: string;
    URMS2: string;
    URMS3: string;
    IRMS1: string;
    IRMS2: string;
    IRMS3: string;
    PSIGMA: string;
    SSIGMA: string;
    QSIGMA: string;
    RAMDA: string;
    FREQUENCY: string;
    PowerMeterOn: boolean;
    PowerMeterNo: integer;
  end;

implementation

{ THiMap }

end.
