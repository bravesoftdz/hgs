unit HiTEMS_TMS_CONST;

interface

const
  fStatusCdGrp : Double = (63490488633265);//�����׷�

  //JOBCODE ����
  fsiteRstCode : Double = (63496011770313);//������� JOBCODE


  //�ٹ�����
  ftimeType : array[0..5] of string = ('�⺻�ٹ�','����ٹ�','�ָ��ٹ�','�߰��ٹ�','ö�߱ٹ�','�߰�����');
  //���±���
  fgeuntae : array[0..8] of string = ('����','����','�İ�','�Ʒ�(����)',
                                      '��/����','��/����(����)',
                                      '��/����(����)','�ް�','��Ÿ');

  fDayofWeek : array[1..7] of string = ('��','��','ȭ','��','��','��','��');


  fK2bSite : String = ('K2B3');

implementation

uses
  CommonUtil_Unit,
  DataModule_Unit;

end.

