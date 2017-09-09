unit ConfigUtil;

interface

uses sysutils;

  function GetToken( var str1: string; SepChar: string ): String;
  function LTrimZero(const str1: string): String;
  procedure RTrimComma(var sDir : String);

implementation

//�и� ���ڸ� �������� ��ū�� ��ȯ�Ѵ�. ���� �ҽ��� ������
//�¿� ������ �����ش�.
function GetToken( var str1: string; SepChar: string ): String;
var i: integer;
  function LRTrim_bnk( const s: string ): String;
  var i: word;
      str1: string;
  begin
    i := 1;

    if s <> '' then
    begin
      while (i < 1000) and (s[i] in [' ',#9]) do
        inc(i);

      str1 := copy(s, i, length(s));
      i := Length(str1);

      while (i >0) and (str1[i] in [' ',#9]) do
        Dec(i);
      LRTrim_bnk := copy(str1, 1, i);
    end;
  end;
begin
  if str1 = '' then
  begin
    Result := '';
    exit;
  end;

  str1 := LRTrim_bnk(Str1);
  i := Pos(SepChar,Str1);
  if i > 0 then
  begin
    Result := Copy(Str1, 1, i-1);
    Delete(Str1,1,i);
  end
  else
  begin
    Result := LRTrim_bnk(Str1);
    str1 := '';
  end;
end;

//���� 012�� 12�� ��ȯ�Ѵ�.
//������ 0�� �����Ѵ�.
function LTrimZero(const str1: string): String;
begin
  Result := str1;

  if StrToIntDef(str1, -1) <> -1 then  // �������� üũ....
      Result := FormatFloat('####0', StrToInt(str1));
end;

//��Ʈ���� ���� Comma�� �����Ѵ�.
procedure RTrimComma(var sDir : String);
begin
  if (Length(sDir)>0) and (sDir[Length(sDir)]=',') then
     sDir := Copy(sDir,1,Length(sDir)-1);
end;

end.
