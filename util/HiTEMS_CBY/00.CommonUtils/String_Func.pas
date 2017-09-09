unit String_Func;

interface

uses  Windows, SysUtils, Classes, Math;

type
  (* TCSVOption - Options available when pasing text
     -----------------------------------------------

     KeepQuotes - Ensures that multiple words contained within quotes (")
                  keep the quotes after parsing.
     TrimSpaces - Removes leading and trailing spaces.
     TrimQuotes - Removes leading and trailing spaces from within quoted text.
     IgnoreBlankLines - Excludes blank lines.   *)

  TCSVOption = (KeepQuotes, TrimSpaces, TrimQuotes, IgnoreBlankLines);
  TCSVOptions = set of TCSVOption;

function RTrim_bnk( const s: string ): String;
function LTrim_bnkZero( const s: string ): String;
function LRTrim_bnk( const s: string ): String;
Function Upstring(S:String):String;
function GetTokenWithComma( var str1: string ): String;
function AppendBackSlash(const sDir : String): String;
function RemoveBackSlash(const sDir : String): String;
function GetToken( var str1: string; SepChar: string ): String;
function GetToken2(aString, SepChar: String; TokenNum: Byte):String;
function replaceString(str,s1,s2:string;casesensitive:boolean):string;
function CopyFromChar(s:string;c:char;l:integer):string;
function strPos(const aSubstr,S: String): Integer;
Function InStr( Start:Integer; Const BigStr,SmallStr:String):Integer;
function strToken(var S: String; Seperator: Char): String;
function strTokenCount(S: String; Seperator: Char): Integer;
procedure ParseCSVText(const Value: string; Strings: TStrings;
  Seperator: Char = ','; Options: TCSVOptions = [TrimSpaces, TrimQuotes]);
procedure ReplaceChars(var AString : string;
                       const ATheseChars,AWithChars : string;
                       AIgnoreCase : boolean = false); overload;
function StripDupSpaces(const AString : string) : string;
function StrToSms(const AMsg : string;
                  ALength : integer = 160) : string;

implementation

//String�� �����ʿ� �پ��ִ� ������ ������ �ִ� �Լ��̴�
function RTrim_bnk( const s: string ): String;
var
     i: word;
begin
     i := Length(s);

     while (i >0) and (s[i] in [' ']) do
                 Dec(i);
     RTrim_bnk := copy(s, 1, i);
end;

//String�� ���ʿ� �ִ� ����� 0�� ����
function LTrim_bnkZero( const s: string ): String;
var
     i: word;
begin
     i := 1;

     while (i < Length(s)) and (s[i] in [' ','0']) do
                 Inc(i);
     LTrim_bnkZero := copy(s, i, Length(s)-i+1);
end;

//String�� �����ʰ� ���ʿ� �پ��ִ� ������ ������ �ִ� �Լ��̴�
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

//�ҹ��ڸ� �빮�ڷ� ��ȯ�Ѵ�.
Function Upstring(S:String):String;
var
    I:Byte;
begin
 for i := 1 to Length(s) do s[i] := UpCase(s[i]);
 Upstring:=S;
end;

//�޸��� �и��� ���ڸ� �ϳ��� ��ȯ�Ѵ�.
//���������� ����� ���ڸ� �����.
function GetTokenWithComma( var str1: string ): String;
var i: integer;
begin
  i := Pos(',',Str1);
  if i > 0 then
  begin
    Result := Copy(Str1, 1, i-1);
    Delete(Str1,1,i);
  end
  else
    Result := Str1;
end;

//��Ʈ���� ���� �������� ���δ�.
function AppendBackSlash(const sDir : String): String;
begin
  if sDir = '' then
  begin
    Result := '\';
    exit;
  end;
  
  if (sDir[length(sDir)]<>'\') then
    result:=sDir+'\'
  else
    result:=sDir;
end;

//��Ʈ���� ���� �������� �����Ѵ�.
function RemoveBackSlash(const sDir : String): String;
begin
  Result := sDir;
  if (Length(sDir)>0) and (sDir[Length(sDir)]='\') then
     Result := Copy(sDir,1,Length(sDir)-1);
end;

//�и� ���ڸ� �������� ��ū�� ��ȯ�Ѵ�. ���� �ҽ��� ������
//�¿� ������ �����ش�.
function GetToken( var str1: string; SepChar: string ): String;
var i: integer;
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

{
// GetToken���� �������� ���� ��Ʈ���� ������ �ʴ´ٴ� �Ͱ�
// �Ķ���ͷ� ���̸� �����ϴ� ���̴�.
parameters: aString : ���� ��Ʈ��
            SepChar : �и� ����
            TokenNum: ���ϴ� ������ ����
result    : the substring or an empty string if the are less then
            'TokenNum' substrings
}
function GetToken2(aString, SepChar: String; TokenNum: Byte):String;
var
   Token     : String;
   StrLen    : Byte;
   TNum      : Byte;
   TEnd      : Byte;
begin
  StrLen := Length(aString);
  TNum   := 1;
  TEnd   := StrLen;

  while ((TNum <= TokenNum) and (TEnd <> 0)) do
  begin
    TEnd := Pos(SepChar,aString);

    if TEnd <> 0 then
    begin
      Token := Copy(aString,1,TEnd-1);
      Delete(aString,1,TEnd);
      Inc(TNum);
    end
    else
    begin
      Token := aString;
    end;
  end;//while

  if TNum >= TokenNum then
  begin
    GetToken2 := Token;
  end//if TNum >= TokenNum
  else
  begin
    GetToken2 := '';
  end;
end;

//str�� �ִ� s1�� s2�� �ٲ۴�.
//casesensitive = True�̸� ��ҹ��ڸ� �����Ѵ�.
//��:replace('We know what we want','we','I',false) = 'I Know what I want'
function replaceString(str,s1,s2:string;casesensitive:boolean):string;
var i:integer;
    s,t:string;
begin
  s:='';
  t:=str;

  repeat
    if casesensitive then
      i:=pos(s1,t)
    else
      i:=pos(lowercase(s1),lowercase(t));

    if i>0 then
    begin
      s:=s+Copy(t,1,i-1)+s2;
      t:=Copy(t,i+Length(s1),MaxInt);
    end
    else s:=s+t;
  until i<=0;
  result:=s;
end;

{copy l characters from string s starting at first incidence of c}
{example: Copyfromchar('Borland Delphi','a',3) = 'and'}
function CopyFromChar(s:string;c:char;l:integer):string;
var i:integer;
begin
  i:=pos(c,s);
  result:=copy(s,i,l);
end;

//���� ��Ʈ���� ������ ���� ��ġ�� ��ȯ�Ѵ�.
function strPos(const aSubstr,S: String): Integer;
begin
  Result:=Pos(aSubStr,S)+Length(aSubStr);
end;

//�� ���ڿ� (64kb�̻�) ���� Ư�� ���� �˻��� �� Pos() ���� �� ���� �Լ�
Function InStr( Start:Integer; Const BigStr,SmallStr:String):Integer;
Var
  L9, L8, Max, P: Integer;
  BigL, SmallL: Integer;
  C : Char;
Begin
  Result := 0; // Set Default

  If Start <= 0 Then
    Start := 1;

  BigL := Length( BigStr );
  SmallL := Length( SmallStr );

  If BigL = 0 Then
    Exit;

  If SmallL = 0 Then
  Begin
    Result := Start;
    Exit;
  End;

  Max := BigL - SmallL + 1;
  If Max < Start Then
    Exit;

  C := SmallStr[1];

  For L9 := Start To Max Do
    If BigStr[L9] = C Then
    Begin
      P := L9 + SmallL - 1;

      For L8 := SmallL DownTo 2 Do
      Begin
        If BigStr[P] <> SmallStr[L8] Then
          Break;

        P := P - 1;
      End;

      If P = L9 Then
      Begin
        Result := L9;
        Break;
      End;
    End;
End;{InStr}

function strToken(var S: String; Seperator: Char): String;
var
  I               : Word;
begin
  I:=Pos(Seperator,S);
  if I<>0 then
  begin
    Result:=System.Copy(S,1,I-1);
    System.Delete(S,1,I);
  end else
  begin
    Result:=S;
    S:='';
  end;
end;

function strTokenCount(S: String; Seperator: Char): Integer;
begin
  Result:=0;
  while S<>'' do begin
    StrToken(S,Seperator);
    Inc(Result);
  end;
end;

procedure ParseCSVText(const Value: string; Strings: TStrings;
  Seperator: Char = ','; Options: TCSVOptions = [TrimSpaces, TrimQuotes]);
var
  P, P1: PChar;
  S: string;
begin
  Assert(Assigned(Strings), 'Must Initialize TStringList (Strings Parameter)!'); 
  Assert(Seperator <> '', 'No seperator character specified!'); 

  Strings.Clear; 
  P := PChar(Value); 
  while (P^ in [#1..#31]) do 
    P := CharNext(P); 

  while P^ <> #0 do 
  begin
    if P^ = #34 then 
    begin 
      S := AnsiExtractQuotedStr(P, #34); 
      if TrimQuotes in Options then 
        S := Trim(S); 
      if (KeepQuotes in Options) then 
        S:= AnsiQuotedStr(S, #34) 
    end else 
    begin 
      P1 := P;
      while (P^ > #31) and (P^ <> Seperator) do
      begin 
        if (P^ = #0) then 
          Break; 
        P := CharNext(P); 
      end; 
      SetString(S, P1, P - P1); 
      if TrimSpaces in Options then 
        S := Trim(S); 
    end; 

    if not ((IgnoreBlankLines in Options) and (S = '')) then 
      Strings.Add(S); 

    while (P^ in [#1..#31]) do 
      P := CharNext(P); 

    if P^ = Seperator then 
    begin 
      repeat 
        P := CharNext(P); 
      until not (P^ in [#1..#31]); 
    end; 
  end; 
end; 

const 
    // Character Sets Constatnts 
    // Edit SMS_CHARS to suit your needs 
    // Don't need them all, just included for completeness 
    ALL_CHARS          = [#0..#255]; 
    ANSI_CHARS         = [#0..#127]; 
    INVALIDFILE_CHARS  = [#0..#31,#34,#42,#60,#62,#63,#124]; 
    VALIDFILE_CHARS    = ALL_CHARS - INVALIDFILE_CHARS; 
    NUMERIC_CHARS      = ['0'..'9']; 
    UPPERCASE_CHARS    = ['A'..'Z']; 
    LOWERCASE_CHARS    = ['a'..'z']; 
    ALPHA_CHARS        = UPPERCASE_CHARS + LOWERCASE_CHARS; 
    ALPHANUMERIC_CHARS = ALPHA_CHARS + NUMERIC_CHARS; 
    PROPERNAME_CHARS   = ALPHANUMERIC_CHARS + [' ']; 
    HEX_CHARS          = NUMERIC_CHARS + ['A'..'F','a'..'f']; 
    BINARY_CHARS       = ['0','1']; 
    WHITESPACE_CHARS   = [#9..#13,' ']; 
    PUNCTUATION_CHARS  = ['!','"','''','(',')',',','.',';',':','?','[',']']; 
    SIGN_CHARS         = ['+','-']; 
    CONTROL_CHARS      = [#0..#31]; 
    OPERATOR_CHARS     = ['+','-','*','/','^']; 
    BRACKET_CHARS      = ['{','[','(',')',']','}']; 
    VOWEL_CHARS        = ['a','e','i','o','u','y','A','E','I','O','U','Y']; 
    SMS_CHARS          = PROPERNAME_CHARS + ['(',')','#','$','%','@',';'] + 
                         ['/','+','-','"','<','>','*','&','=','_']; 
// =======================================================
// Replace multiple characters in a string with others 
// Like Oracle Translate() 
// =======================================================

procedure ReplaceChars(var AString : string;
                       const ATheseChars,AWithChars : string;
                       AIgnoreCase : boolean = false); overload;
var i,ii,iLen : integer;
begin 
  iLen := Min(length(ATheseChars),length(AWithChars));

  for i := 1 to iLen do begin 
    for ii := 1 to length(AString) do begin 
      if AIgnoreCase then begin 
        if UpCase(AString[ii]) = UpCase(ATheseChars[i]) then 
          AString[ii] := AWithChars[i]; 
      end 
      else 
        if AString[ii] = ATheseChars[i] then 
          AString[ii] := AWithChars[i]; 
    end; 
  end; 
end; 


// ========================================== 
// Remove duplicate spaces in a string
// eg.
// 'Hello    World is   lots space'
// 'Hello World is lots space'
// ==========================================

function StripDupSpaces(const AString : string) : string;
var sString : string;
    bIsSpace : boolean;
    i,iLen : integer;
begin
  SetLength(sString,length(AString));
  bIsSpace := false;
  iLen := 0;

  for i := 1 to length(AString) do begin
    if AString[i] = ' ' then begin

      if not bIsSpace then begin
        inc(iLen);
        sString[iLen] := AString[i];
      end;

      bIsSpace := true;
    end
    else begin
      inc(iLen);
      bIsSpace := false;
      sString[iLen] := AString[i];
    end;
  end;

  SetLength(sString,iLen);
  Result := sString;
end;

// ===========================================================
// Main Function StrToSms()
// Replace or remove invalid chars and duplicate spaces for
// SMS message. Also truncate to 160 chars
// ===========================================================

function StrToSms(const AMsg : string;
                  ALength : integer = 160) : string;
var sResult : string;
    i : integer;
begin
  sResult := AMsg;
  // Modify following for any char translation you require 
  ReplaceChars(sResult,'[]{}\~|','()()/-:'); 
  // Replace Invalid chars ith spaces 
  for i := 1 to length(sResult) do 
    if not (sResult[i] in SMS_CHARS) then sResult[i] := ' '; 
  // Remove duplicate spaces 
  sResult := StripDupSpaces(sResult); 
  // Truncate message string to ALength 
  Result := copy(sResult,1,160); 
end; 

end.


