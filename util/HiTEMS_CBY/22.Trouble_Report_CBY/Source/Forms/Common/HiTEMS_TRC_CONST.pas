unit HiTEMS_TRC_CONST;

interface

const
  fRpType : array[0..1] of String = ('QR','ER');

  //��������ڵ�
  freportStatusNm : array[0..1] of String = ('�ۼ���','�����Ϸ�');
  freportStatus : array[0..1] of Integer = (0,1);

type
  TUserInfo = Record
    UserID,
    UserName,
    TeamNo,
    DeptNo,
    Position,
    Manager : String;
  End;

implementation


end.
