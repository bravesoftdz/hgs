unit UnitDateUtil;

interface

uses SysUtils, System.DateUtils;

//��¥�� �Է� �޾Ƽ� �б⸦ ��ȯ��
function QuarterOf(ADate: TDateTime): word;
//�⵵�� �б⸦ �Է� �޾Ƽ� �б��� ù��° ��¥�� ��ȯ��
function GetDateFromQuarter(AYear, AQuarter: word): TDateTime;
function DateTimeMinusInteger(d1:TDateTime;i:integer;mType:integer;Sign:Char):TDateTime;

implementation

function QuarterOf(ADate: TDateTime): word;
begin
  Result := MonthOf(ADate);

  if Result <= 3 then
    Result := 1
  else if (Result > 3) and (Result <= 6)  then
    Result := 2
  else if (Result > 6) and (Result <= 9)  then
    Result := 3
  else if (Result > 9) and (Result <= 12)  then
    Result := 4;
end;

function GetDateFromQuarter(AYear, AQuarter: word): TDateTime;
var
  Lm: word;
begin
  case AQuarter of
    1: Lm := 1;
    2: Lm := 4;
    3: Lm := 7;
    4: Lm := 10;
  end;

  Result := EncodeDate(AYear, Lm, 1);
end;

//��¥���� ������ ���ų� ���ؼ� ��ȯ��
//mType = 1 : '�ð�'���� ������ ���ų� ����
//        2 : '��'���� ������ ���ų� ����
//        3 : '�ʿ��� ������ ���ų� ����
//        4 : '��'���� ������ ���ų� ����
//        5 : '��' ���� ������ ���ų� ����
// '��'�ڴ� �ٷ� ������ ���ų� ���Ե� ������
function DateTimeMinusInteger(d1:TDateTime;i:integer;mType:integer;Sign:Char)
                                                                    :TDateTime;
var hour,min,sec,msec:word;
    year,mon,dat: word;
    tmp: integer;
begin
  Decodetime(d1,hour,min,sec,msec);
  Decodedate(d1,year,mon,dat);

  case mType of
    1:begin//�ð�
        tmp := 24;
      end;
    2:begin//��
        tmp := 24*60;
      end;
    3:begin//��
        tmp := 24*60*60;
      end;
    4:begin//��
      end;
    5:begin//��
      end;
  end;

  if Sign = '+' then
    Result := d1 + (i/tmp)
  else
    Result := d1 - (i/tmp);
end;

end.
