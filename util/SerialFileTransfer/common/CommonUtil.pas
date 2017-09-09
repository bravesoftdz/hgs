unit CommonUtil;

interface

uses Windows, sysutils, classes, Forms;

function HexToInt(HexStr : string) : Integer;
function Real2Str(Number:real;Decimals:byte):string;
Function ReadLine(File_Handle: Integer;var ReadData: String): Boolean;
function GetTokenWithComma( var str1: string ): String;
function Str2Hex_Byte(szStr: string): Byte;
function Str2Hex_Int(szStr: string): integer;
function String2HexByteAry(str1: string; var  Buf: array of byte): integer;
function UpdateCRC16(InitCRC: Word; var Buffer; Length: LongInt): Word;
function CalcCRC16_2(const data: string): word;
function Update_LRC(Data: string; size: integer): Byte;
function Check_LRC(Data: array of char; size: integer; lrc: Byte): Boolean;
function strToken(var S: String; Seperator: Char): String;
function strTokenCount(S: String; Seperator: Char): Integer;
function NextPos2(SearchStr, Str : String; Position : integer) : integer;
Function SaveData2DateFile(dirname,extname,data: string; APosition: integer): Boolean;
Function SaveData2FixedFile(dirname,filename,data: string; APosition: integer): Boolean;
function File_Open_Append(FileName:string;var Data:String;
                                              AppendPosition:integer): Boolean;
function GetBitVal(const i, Nth: integer): integer;
function IsBitSet(const i, Nth: integer): boolean;
function GetSizeOfFile(const FileName : String) : Integer;
function TrunFileSize(const FileName: string): LongInt;

implementation

function HexToInt(HexStr : string) : Integer;
var RetVar : Integer;
    i : byte;
begin
  HexStr := UpperCase(HexStr);
  if HexStr[length(HexStr)] = 'H' then
    Delete(HexStr,length(HexStr),1);
  RetVar := 0;

  for i := 1 to length(HexStr) do
  begin
    RetVar := RetVar shl 4;
    if HexStr[i] in ['0'..'9'] then
      RetVar := RetVar + (byte(HexStr[i]) - 48)
    else
      if HexStr[i] in ['A'..'F'] then
        RetVar := RetVar + (byte(HexStr[i]) - 55)
      else begin
        Retvar := 0;
        break;
      end;
  end;

  Result := RetVar;
end;

function Real2Str(Number:real;Decimals:byte):string;
var Temp : string;
begin
    Str(Number:20:Decimals,Temp);
    repeat
       If copy(Temp,1,1)=' ' then delete(Temp,1,1);
    until copy(temp,1,1)<>' ';
    If Decimals=255 {Floating} then begin
       While Temp[1]='0' do Delete(Temp,1,1);
       If Temp[Length(temp)]='.' then Delete(temp,Length(temp),1);
    end;
    Result:= Temp;
end;

//���Ϸκ��� �� ���� ������ �д´�
//Eof�� False�� ��ȯ�Ѵ�.
Function ReadLine(File_Handle: Integer;var ReadData: String): Boolean;
var BRead,BlockSize: word;
    Buffer: PAnsiChar;
    tmpary: array[1..1000] of char;
    n: integer;
begin
  BlockSize := 1000;

  Buffer := @tmpary;

  //getmem(Buffer,BlockSize);

  try
    BRead:=FileRead(File_Handle ,Buffer^,BlockSize);
    ReadData := Copy(StrPas(Buffer),1,BRead);
  finally
    //freemem(Buffer,BlockSize);
  end;

  if Bread <= 0 then
  begin
    Result := False;
    exit;
  end;

  n := Pos(#13,ReadData); //Readln(#10�� ����)
  if n > 0 then
  begin
    //Delete(ReadData, n,BlockSize-n+5 );
    Delete(ReadData, n,Length(ReadData)-n+1 );
    FileSeek(File_Handle, n-Bread+1, 1);
  end;
  Result := True;
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

// Char�� Byte������ ��ȯ�Ѵ�..
function AtoX(Ch : Char): Byte;
var
  Check: Byte;
begin
  Check := Byte(Ch);

  if(Check >= Byte('0')) and (Check <= Byte('9')) then
  begin
    Result := Check-Byte('0');
    Exit;
  end
  else
  begin
    Result := Check-Byte('A')+Byte(10);
    Exit;
  end;
end;

//----------------------------------------------------------------------------------
// String�� Hex������ �ٲ۴�.(Byte ���� �����)
function Str2Hex_Byte(szStr: string): Byte;
begin
  szStr := UpperCase(szStr);
  Result := ((AtoX(szStr[1]) shl 4)  or (AtoX(szStr[2])));
end;

// Char�� Integer������ ��ȯ�Ѵ�..
function AtoX_Int(Ch : Char): Integer;
var
  Check: Integer;
begin
  Check := Integer(Ch);

  if(Check >= Integer('0')) and (Check <= Integer('9')) then
  begin
    Result := Check-Integer('0');
    Exit;
  end
  else
  begin
    Result := Check-Integer('A')+Integer(10);
    Exit;
  end;
end;

// String�� Hex������ �ٲ۴�.(Integer ���� �����)
function Str2Hex_Int(szStr: string): integer;
begin
  szStr := UpperCase(szStr);
  Result := ((AtoX_Int(szStr[1]) shl 12) or (AtoX_Int(szStr[2]) shl 8) or
              (AtoX_Int(szStr[3]) shl 4)  or (AtoX_Int(szStr[4])));
end;

//���ڸ��� �Ѱ��� ��簪�� ����.
function String2HexByteAry(str1: string; var Buf: array of byte): integer;
var
  i: integer;
begin
  Result := Length(str1) div 2;
  for i := 0 to Result - 1 do
    Buf[i] := Str2Hex_Byte(str1[i*2+1] + str1[i*2+2]);
end;

const
 Crc16Tab: Array[0..$FF] of Word =
    ($00000, $01021, $02042, $03063, $04084, $050a5, $060c6, $070e7,
     $08108, $09129, $0a14a, $0b16b, $0c18c, $0d1ad, $0e1ce, $0f1ef,
     $01231, $00210, $03273, $02252, $052b5, $04294, $072f7, $062d6,
     $09339, $08318, $0b37b, $0a35a, $0d3bd, $0c39c, $0f3ff, $0e3de,
     $02462, $03443, $00420, $01401, $064e6, $074c7, $044a4, $05485,
     $0a56a, $0b54b, $08528, $09509, $0e5ee, $0f5cf, $0c5ac, $0d58d,
     $03653, $02672, $01611, $00630, $076d7, $066f6, $05695, $046b4,
     $0b75b, $0a77a, $09719, $08738, $0f7df, $0e7fe, $0d79d, $0c7bc,
     $048c4, $058e5, $06886, $078a7, $00840, $01861, $02802, $03823,
     $0c9cc, $0d9ed, $0e98e, $0f9af, $08948, $09969, $0a90a, $0b92b,
     $05af5, $04ad4, $07ab7, $06a96, $01a71, $00a50, $03a33, $02a12,
     $0dbfd, $0cbdc, $0fbbf, $0eb9e, $09b79, $08b58, $0bb3b, $0ab1a,
     $06ca6, $07c87, $04ce4, $05cc5, $02c22, $03c03, $00c60, $01c41,
     $0edae, $0fd8f, $0cdec, $0ddcd, $0ad2a, $0bd0b, $08d68, $09d49,
     $07e97, $06eb6, $05ed5, $04ef4, $03e13, $02e32, $01e51, $00e70,
     $0ff9f, $0efbe, $0dfdd, $0cffc, $0bf1b, $0af3a, $09f59, $08f78,
     $09188, $081a9, $0b1ca, $0a1eb, $0d10c, $0c12d, $0f14e, $0e16f,
     $01080, $000a1, $030c2, $020e3, $05004, $04025, $07046, $06067,
     $083b9, $09398, $0a3fb, $0b3da, $0c33d, $0d31c, $0e37f, $0f35e,
     $002b1, $01290, $022f3, $032d2, $04235, $05214, $06277, $07256,
     $0b5ea, $0a5cb, $095a8, $08589, $0f56e, $0e54f, $0d52c, $0c50d,
     $034e2, $024c3, $014a0, $00481, $07466, $06447, $05424, $04405,
     $0a7db, $0b7fa, $08799, $097b8, $0e75f, $0f77e, $0c71d, $0d73c,
     $026d3, $036f2, $00691, $016b0, $06657, $07676, $04615, $05634,
     $0d94c, $0c96d, $0f90e, $0e92f, $099c8, $089e9, $0b98a, $0a9ab,
     $05844, $04865, $07806, $06827, $018c0, $008e1, $03882, $028a3,
     $0cb7d, $0db5c, $0eb3f, $0fb1e, $08bf9, $09bd8, $0abbb, $0bb9a,
     $04a75, $05a54, $06a37, $07a16, $00af1, $01ad0, $02ab3, $03a92,
     $0fd2e, $0ed0f, $0dd6c, $0cd4d, $0bdaa, $0ad8b, $09de8, $08dc9,
     $07c26, $06c07, $05c64, $04c45, $03ca2, $02c83, $01ce0, $00cc1,
     $0ef1f, $0ff3e, $0cf5d, $0df7c, $0af9b, $0bfba, $08fd9, $09ff8,
     $06e17, $07e36, $04e55, $05e74, $02e93, $03eb2, $00ed1, $01ef0);

function UpdateCRC16(InitCRC: Word; var Buffer; Length: LongInt): Word;
begin
  asm
    push   esi
    push   edi
    push   eax
    push   ebx
    push   ecx
    push   edx
    lea    edi, Crc16Tab
    mov    esi, Buffer
    mov    ax, InitCrc
    mov    ecx, Length
    or     ecx, ecx
    jz     @@done
@@loop:
    xor    ebx, ebx
    mov    bl, ah
    mov    ah, al
    lodsb
    shl    bx, 1
    add    ebx, edi
    xor    ax, [ebx]
    loop   @@loop
@@done:
    mov    Result, ax
    pop    edx
    pop    ecx
    pop    ebx
    pop    eax
    pop    edi
    pop    esi
  end;
end;

function CalcCRC16_2(const data: string): word;
var I,j: Integer;
  f: byte;
  temp,temp2,flag: word;
begin
  temp := $FFFF;

  For I := 0 to (Length (Data) div 2) - 1 do
  begin
    f := Str2Hex_Byte(Copy(Data,i*2+1,2));
    temp := temp xor f;
    for j := 1 to 8 do
    begin
      flag := temp and 1;
      temp := temp shr 1;
      if flag <> 0 then
        temp := temp xor $a001;
    end;//for
  end;

  temp2 := temp shr 8;
  temp := (temp shl 8) or temp2;
  result := temp;
end;

//LRC(Longitudinal Redundancy Check) Calculate
function Update_LRC(Data: string; size: integer): Byte;
var
  i: integer;
  TempResult: Byte;
  tmpStr: string;
begin
  TempResult := 0;

  for i := 1 to (size div 2) do
  begin
    tmpstr := '';
    tmpstr := Data[i * 2 - 1] + Data[i * 2];
    tmpStr := UpperCase(tmpStr);
    TempResult := TempResult + Str2Hex_Byte(tmpStr);
  end;//for

  Result :=  (not TempResult) + 1; //2's Complement
end;


//LRC�� Check�Ͽ� �����̸� True�� ��ȯ��
//Data�� Lrc�� ������ ���¿��� ��
function Check_LRC(Data: array of char; size: integer; lrc: Byte): Boolean;
var tmplrc: Byte;
begin
  tmplrc := Update_LRC(Data, size);
  if tmplrc = lrc then
    Result := True
  else
    Result := False;
end;

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

//Position: �� ��ġ ���ĺ��� �� ó���� ������ SearchStr�� ��ġ�� ��ȯ��
//������ 0�� ��ȯ��
function NextPos2(SearchStr, Str : String; Position : integer) : integer;
begin
  delete(Str, 1, Position-1);
  Result := pos(SearchStr, upperCase(Str));
  If Result = 0 then exit;
  If (Length(Str) > 0) and (Length(SearchStr) > 0) then
    Result := Result + Position - 1;
end;

//������ AppendPosition�� �� ���� ������ �� �ִ´�.
//AppendPosition = soFromBeginning, soFromCurrent, soFromEnd
function FileAppend(hFile, AppendPosition: Integer; var Data: String): Boolean;
var Buffer: PAnsiChar;
    BWrite: word;
begin
  if hFile > 0 then
  begin
    if FileSeek(hFile,0,AppendPosition) <> HFILE_ERROR then
    begin
      try
        getmem(Buffer,Length(Data)+3);
        Buffer := StrPCopy(Buffer,Data+#13+#10);
        BWrite:=FileWrite(hFile,Buffer^,Strlen(Buffer));
        if BWrite = Strlen(Buffer) then
          Result := True
        else
          Result := False;
      finally
        freemem(Buffer,Length(Data)+3);
      end;
    end;
  end;
end;

//ȭ���� ����(IsUpdate�� False�̰� ȭ���� �������� �������)�ϰų�
//���� ȭ�Ͽ� Data�� �߰���
//IsUpdate : True = ���� ȭ���� �����ϰ� �� ����
//ȭ���� ó�� ������ ��� True�� ��ȯ��
function File_Open_Append(FileName:string;var Data:String;
                                              AppendPosition:integer): Boolean;
var hFile: integer;
begin
  Result := False;
  SetCurrentDir(ExtractFilePath(Application.exename));
  try
    if FileExists(FileName) then
    begin
        hFile := FileOpen(FileName,fmOpenWrite+fmShareDenyNone);  { Open Source }
    end
    else
    begin
      hFile := FileCreate(FileName);
      Result := True;
    end;

    FileAppend(hFile,AppendPosition,data);
  finally
    if hFile > 0 then
      FileClose(hFile);
  end;

end;

//Directory Name, Extention Name, Data�� ȭ���̸��� ���糯¥�� ȭ�Ͽ� ���
//ȭ���� ó�� ������ ��� True�� ��ȯ��
Function SaveData2DateFile(dirname,extname,data: string; APosition: integer): Boolean;
var filename:string;
begin
  Result := False;
  setcurrentdir(ExtractFilePath(Application.Exename));
  if not setcurrentdir(dirname) then
    createdir(dirname);
  setcurrentdir(ExtractFilePath(Application.Exename));
  filename := dirname + '\' + FormatDatetime('yyyymmdd',date) + '.' + extname;
  if File_Open_Append(filename,data,APosition) then
    Result := True;
end;

//ȭ���� ó�� ������ ��� True�� ��ȯ��
Function SaveData2FixedFile(dirname,filename,data: string; APosition: integer): Boolean;
begin
  Result := False;
  setcurrentdir(ExtractFilePath(Application.Exename));
  if not setcurrentdir(dirname) then
    createdir(dirname);
  setcurrentdir(ExtractFilePath(Application.Exename));
  filename := dirname + '\' + filename;
  if File_Open_Append(filename,data,APosition) then
    Result := True;
end;

//Nth = 0 �̸� ���� ������(LSB)���� ��ȯ��
//���� 0�� �ƴ� ���� 2���� ����, �� Nth = 3 �� 1�̸� 4�� ��ȯ��
function GetBitVal(const i, Nth: integer): integer;
begin
  Result := (i and (1 shl Nth));
end;

{------------------------------IsBitSet------------------------------------------
  returns True if a bit is ON (1)
  Nth can have any bit order value in [0..31]
----------------------------------------------------------------------------------}
function IsBitSet(const i, Nth: integer): boolean;
begin
  Result:= (i and (1 shl Nth)) <> 0;
end; { IsBitSet }

function GetSizeOfFile(const FileName : String) : Integer;
var
  hFile : LongWord;
begin
  hFile := FileOpen(FileName, fmOpenRead);
  Result := GetFileSize(hFile, nil);
  FileClose(hFile);
end;

function TrunFileSize(const FileName: string): LongInt;
Var
  SearchRec: TSearchRec;
  sgPath   : String;
  inRetval : Integer;
begin
  sgPath   := ExpandFileName(FileName);
  Try
    inRetval := FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec);
    If inRetval = 0 Then
      Result := SearchRec.Size
    Else Result := -1;
  Finally
    SysUtils.FindClose(SearchRec);
  End;
end;

end.
