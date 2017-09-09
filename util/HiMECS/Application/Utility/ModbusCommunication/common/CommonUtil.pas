unit CommonUtil;

interface

uses Windows, sysutils, classes, Forms, shellapi, Graphics, math, MMSystem,
    JclStringConversions;

type
  TRGB = record
      R: Integer;
      G: Integer;
      B: Integer;
  end;

  THLS = record
      H: Integer;
      L: Integer;
      S: Integer;
  end;

  PProcWndInfo = ^TProcWndInfo;
  TProcWndInfo = record
    TargetProcessID: DWORD;
    FoundWindow    : HWND;
  end; { TProcWndInfo }

  TBit          = 0..31;

  TSoundType = (stFileName, stResource, stSysSound);

CONST B36 : PChar = ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ');

function IsbitSet(const Value: Integer; const TheBit: TBit): Boolean;
function HexToInt(HexStr : string) : Int64;
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
Function SaveData2DateFile(dirname,extname,data: string; APosition: integer;
                            AHeader: string=''): Boolean;
Function SaveData2FixedFile(dirname,filename,data: string; APosition: integer;
                            AHeader: string=''): Boolean;
function File_Open_Append(FileName:string;var Data:String;
                    AppendPosition:integer; AHeader: string=''): Boolean;
function GetBitVal(const i, Nth: integer): integer;
function IntToBase(iValue: integer; Base: byte; Digits: byte): string;

function ExecNewProcess(ProgramName : String; Wait: Boolean): string;
function ExecNewProcess2(ProgramName: string; ParamString : String = ''): THandle;
function FileExecute(const FileName, Params, StartDir: string): Cardinal;
function ExecAndWait(const ExecuteFile, ParamString: string) : THandle;
function GetHandleByPID(Pid: longword): THandle;
function DSiGetProcessWindow(targetProcessID: cardinal): HWND;

function ColorToRGB(PColor: TColor): TRGB;
function RGBToColor(PR,PG,PB: Integer): TColor;
function RGBToCol(PRGB: TRGB): TColor;
function RGBToHLS(PRGB: TRGB): THLS;
function HLSToRGB(PHLS: THLS): TRGB;
function CalcComplementalColor(AColor: TColor): TColor;

procedure HSVtoRGB (const H,S,V: double; var R,G,B: double);
procedure RGBToHSV (const R,G,B: Double; var H,S,V: Double);
function HSVtoColor(Const Hue, Saturation, Value: Integer): TColor;
procedure ColortoHSV(Const Color: TColor; Var Hue, Saturation, Value: Integer);

function ExecuteSound(const Sound: string; IsStop: Boolean = False;
  SoundType: TSoundType = stFileName;
  Synchronous: Boolean = False; Module: HMODULE = 0;
  AddFlags: LongWord = 0): Boolean;

function IsFloat(AValue: double): Boolean;
function GetFileListFromDir(const Path, Mask: string; IncludeSubDir: boolean): TStringList;
Function FORMAT_TIME (V : Integer) : string; { format time as hh:mm:ss }
function GetVariableName(var ANames: string): string;
function IntToBool(AValue: Integer): Boolean;
function BoolToInt(AValue: Boolean): Integer;
function PosRev(SubStr,s : string; IgnoreCase : boolean = false) : integer;
procedure GetFiles(var AFileList: TStringList; AFileName: string);
function ExtractRelativePathBaseApplication(AApplicationPath, AFileNameWithPath: string): string;

implementation

function max(P1,P2,P3: double): Double;
begin
    Result := -1;
    if (P1 > P2) then begin
        if (P1 > P3) then begin
            Result := P1;
        end else begin
            Result := P3;
        end;
    end else if P2 > P3 then begin
        result := P2;
    end else result := P3;
end;

function min(P1,P2,P3: double): Double;
begin
    Result := -1;
    if (P1 < P2) then begin
        if (P1 < P3) then begin
            Result := P1;
        end else begin
            Result := P3;
        end;
    end else if P2 < P3 then begin
        result := P2;
    end else result := P3;
end;

function IsbitSet(const Value: Integer; const TheBit: TBit): Boolean;
begin
  Result:= (Value and (1 shl TheBit)) <> 0;
end;

function HexToInt(HexStr : string) : Int64;
var RetVar : Int64;
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
    Buffer: PChar;
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
    Result := System.Copy(Str1, 1, i-1);
    System.Delete(Str1,1,i);
  end
  else
  begin
    Result := Str1;
    Str1 := '';
  end;
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

//���ڸ��� �Ѱ��� ���簪�� ����.
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
function FileAppend2(hFile, AppendPosition: Integer; Data: String): Boolean;
var
  BWrite: word;
  Buffer: RawByteString;
begin
  if hFile > 0 then
  begin
    if FileSeek(hFile,0,AppendPosition) <> HFILE_ERROR then
    begin
      try
        Buffer := PChar(Data+#13+#10);
        BWrite:=FileWrite(hFile,Buffer[1],Length(Buffer));
        if BWrite = Sizeof(Data) then
          Result := True
        else
          Result := False;
      finally
      end;
    end;
  end;
end;

//������ AppendPosition�� �� ���� ������ �� �ִ´�.
//AppendPosition = soFromBeginning, soFromCurrent, soFromEnd
function FileAppend(hFile, AppendPosition: Integer; var Data: String): Boolean;
var
  Buffer: PChar;
  BWrite: word;
  UTF8S: AnsiString;
  SL: TStringList;
  I: Integer;
begin
  if hFile > 0 then
  begin
    if FileSeek(hFile,0,AppendPosition) <> HFILE_ERROR then
    begin
      SL := TStringList.Create;
      try
        SL.Text := Data;
        for I := 0 to SL.Count - 1 do
        begin
          UTF8S := StringToUTF8(SL[i]+#13#10);
          BWrite:=FileWrite(hFile, UTF8S[1], Length(UTF8S));
          if BWrite = Length(Data) then
            Result := True
          else
            Result := False;
        end;
      finally
        SL.Free;
      end;
    end;
  end;
end;

//ȭ���� ����(IsUpdate�� False�̰� ȭ���� �������� �������)�ϰų�
//���� ȭ�Ͽ� Data�� �߰���
//IsUpdate : True = ���� ȭ���� �����ϰ� �� ����
//ȭ���� ó�� ������ ��� True�� ��ȯ��
function File_Open_Append(FileName:string;var Data:String;
                          AppendPosition:integer; AHeader: string=''): Boolean;
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

      if AHeader <> '' then
        FileAppend2(hFile,AppendPosition,AHeader);

      Result := True;
    end;

    FileAppend2(hFile,AppendPosition,data);
  finally
    if hFile > 0 then
      FileClose(hFile);
  end;

end;

//Directory Name, Extention Name, Data�� ȭ���̸��� ���糯¥�� ȭ�Ͽ� ���
//ȭ���� ó�� ������ ��� True�� ��ȯ��
Function SaveData2DateFile(dirname,extname,data: string; APosition: integer;
                          AHeader: string=''): Boolean;
var filename:string;
begin
  Result := False;
  setcurrentdir(ExtractFilePath(Application.Exename));
  if not setcurrentdir(dirname) then
    createdir(dirname);
  setcurrentdir(ExtractFilePath(Application.Exename));
  dirname := IncludeTrailingPathDelimiter(dirname);
  filename := dirname + FormatDatetime('yyyymmdd',date) + '.' + extname;
  if File_Open_Append(filename,data,APosition,AHeader) then
    Result := True;
end;

//ȭ���� ó�� ������ ��� True�� ��ȯ��
Function SaveData2FixedFile(dirname,filename,data: string; APosition: integer;
                            AHeader: string=''): Boolean;
begin
  Result := False;
  setcurrentdir(ExtractFilePath(Application.Exename));
  if not setcurrentdir(dirname) then
    createdir(dirname);
  setcurrentdir(ExtractFilePath(Application.Exename));
  dirname := IncludeTrailingPathDelimiter(dirname);
  filename := dirname + filename;
  if File_Open_Append(filename,data,APosition,AHeader) then
    Result := True;
end;

//Nth = 0 �̸� ���� ������(LSB)���� ��ȯ��
//���� 0�� �ƴ� ���� 2���� ����, �� Nth = 3 �� 1�̸� 4�� ��ȯ��
function GetBitVal(const i, Nth: integer): integer;
begin
  Result := (i and (1 shl Nth));
end;

function IntToBase(iValue: integer; Base: byte; Digits: byte): string;
begin
  result := '';
  repeat
    result := B36[iValue MOD BASE]+result;
    iValue := iValue DIV Base;
  until (iValue DIV Base = 0);

  result := B36[iValue MOD BASE]+result;

  while length(Result) < Digits do
    Result := '0' + Result;
end;

function ExecNewProcess(ProgramName : String; Wait: Boolean): string;
var
  StartInfo : TStartupInfo;
  ProcInfo : TProcessInformation;
  CreateOK : Boolean;
begin
  Result := '';
  { fill with known state }
  FillChar(StartInfo,SizeOf(TStartupInfo),#0);
  FillChar(ProcInfo,SizeOf(TProcessInformation),#0);
  StartInfo.cb := SizeOf(TStartupInfo);
  CreateOK :=   CreateProcessW(nil,
      PWideChar(UTF8Decode(ProgramName)),       // command line
      nil,          // process security attributes
      nil,          // primary thread security attributes
      TRUE,         // handles are inherited
      0,            // creation flags
      nil,          // use parent's environment
      nil,          // use parent's current directory
      StartInfo,  // STARTUPINFO pointer
      ProcInfo);  // receives PROCESS_INFORMATION
  WaitForInputIdle(ProcInfo.hProcess, INFINITE);
    { check to see if successful }
  if CreateOK then
    begin
        //may or may not be needed. Usually wait for child processes
      if Wait then
        WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    end
  else
    Result := 'Unable to run '+ProgramName;

  CloseHandle(ProcInfo.hProcess);
  CloseHandle(ProcInfo.hThread);
end;

function ExecNewProcess2(ProgramName: string; ParamString : String = ''): THandle;
var
  StartInfo : TStartupInfo;
  ProcInfo : TProcessInformation;
  CreateOK : Boolean;
  Res: Boolean;
  Msg: TagMsg;
begin
  Result := 0;
  { fill with known state }
  FillChar(StartInfo,SizeOf(TStartupInfo),#0);
  FillChar(ProcInfo,SizeOf(TProcessInformation),#0);
  StartInfo.cb := SizeOf(TStartupInfo);

  if ParamString <> '' then
    ProgramName := ProgramName + ' ' + ParamString;

  CreateOK :=   CreateProcessW(nil,
      PChar(ProgramName),       // command line
      nil,          // process security attributes
      nil,          // primary thread security attributes
      TRUE,         // handles are inherited
      0,            // creation flags
      nil,          // use parent's environment
      nil,          // use parent's current directory
      StartInfo,  // STARTUPINFO pointer
      ProcInfo);  // receives PROCESS_INFORMATION
    { check to see if successful }
  if CreateOK then
  begin
    WaitForInputIdle(ProcInfo.hProcess, INFINITE);

    {while WaitForSingleObject(ProcInfo.hProcess,1) = WAIT_TIMEOUT do
    begin
      repeat
        Res := PeekMessage(Msg, ProcInfo.hProcess, 0,0,PM_REMOVE);
        if Res then
        begin
          TranslateMessage(Msg);
          DispatchMessage(Msg);
        end;
      until not Res;
    end;
     }
    //Result := GetHandleByPID(ProcInfo.dwProcessId);
    Result := ProcInfo.dwProcessId;
  end;
  CloseHandle(ProcInfo.hProcess);
  CloseHandle(ProcInfo.hThread);
end;

function FileExecute(const FileName, Params, StartDir: string): Cardinal;
begin
  Result := ShellExecute(Application.Handle, 'open', PChar(FileName),
                    PChar(Params), PChar(StartDir), SW_SHOWNORMAL);
end;

function ExecAndWait(const ExecuteFile, ParamString: string) : THandle;
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
begin
  Result := 0;

  try
    FillChar(SEInfo, Sizeof(SEInfo), 0);
    SEInfo.cbSize := SizeOf(TShellExecuteInfo);
    with SEInfo do
    begin
      fMask := SEE_MASK_NOCLOSEPROCESS;
      Wnd := Application.Handle;
      lpFile := PChar(ExecuteFile);
      lpParameters := PChar(ParamString);
      nShow := SW_SHOW;
    end;

    if ShellExecuteEx(@SEInfo) then
    begin
      Result := SEInfo.hProcess;
    end;

  Except

  end;
end;

function GetHandleByPID(Pid: longword): THandle; // ������ '���� �Ѷ���' ���� �ڵ带 ��½...
var
  test_hwnd  : longword;
  test_pid : longword;
  test_thread_id : longword;
begin
  Result := 0;
  test_hwnd := FindWindow(nil, nil);
  while test_hwnd <> 0 do
  begin
    If GetParent(test_hwnd) = 0 Then
    begin
      test_thread_id := GetWindowThreadProcessId(test_hwnd, test_pid);
      if test_pid = Pid then
      begin
        Result :=  test_hwnd;
        exit;
      end;
    end;
    test_hwnd := GetWindow(test_hwnd, GW_HWNDNEXT);
  end;
end;

function RGBToColor(PR,PG,PB: Integer): TColor;
begin
  Result := TColor((PB * 65536) + (PG * 256) + PR);
end;

function ColorToRGB(PColor: TColor): TRGB;
var
  i: Integer;
begin
  i := PColor;
  Result.R := 0;
  Result.G := 0;
  Result.B := 0;

  while i - 65536 >= 0 do
  begin
    i := i - 65536;
    Result.B := Result.B + 1;
  end;

  while i - 256 >= 0 do
  begin
    i := i - 256;
    Result.G := Result.G + 1;
  end;

  Result.R := i;
end;

function RGBToCol(PRGB: TRGB): TColor;
begin
  Result := RGBToColor(PRGB.R,PRGB.G,PRGB.B);
end;

function RGBToHLS(PRGB: TRGB): THLS;
var
  LR,LG,LB,LH,LL,LS,LMin,LMax: double;
  LHLS: THLS;
  i: Integer;
begin
  LR := PRGB.R / 256;
  LG := PRGB.G / 256;
  LB := PRGB.B / 256;
  LMin := min(LR,LG,LB);
  LMax := max(LR,LG,LB);
  LL := (LMax + LMin)/2;

  if LMin = LMax then
  begin
    LH := 0;
    LS := 0;
    Result.H := round(LH * 256);
    Result.L := round(LL * 256);
    Result.S := round(LS * 256);
    exit;
  end;

  If LL < 0.5 then LS := (LMax - LMin) / (LMax + LMin);
  If LL >= 0.5 then LS := (LMax-LMin) / (2.0 - LMax - LMin);
  If LR = LMax then LH := (LG - LB)/(LMax - LMin);
  If LG = LMax then LH := 2.0 + (LB - LR) / (LMax - LMin);
  If LB = LMax then LH := 4.0 + (LR - LG) / (LMax - LMin);
  Result.H := round(LH * 42.6);
  Result.L := round(LL * 256);
  Result.S := round(LS * 256);
end;

function HLSToRGB(PHLS: THLS): TRGB;
var
  LR,LG,LB,LH,LL,LS: double;
  LHLS: THLS;
  L1,L2: Double;
begin
  LH := PHLS.H / 255;
  LL := PHLS.L / 255;
  LS := PHLS.S / 255;

  if LS = 0 then
  begin
      Result.R := PHLS.L;
      Result.G := PHLS.L;
      Result.B := PHLS.L;
      Exit;
  end;

  If LL < 0.5 then L2 := LL * (1.0 + LS);
  If LL >= 0.5 then L2 := LL + LS - LL * LS;
  L1 := 2.0 * LL - L2;
  LR := LH + 1.0/3.0;
  if LR < 0 then LR := LR + 1.0;
  if LR > 1 then LR := LR - 1.0;
  If 6.0 * LR < 1 then LR := L1+(L2 - L1) * 6.0 * LR
  Else if 2.0 * LR < 1 then LR := L2
  Else if 3.0*LR < 2 then LR := L1 + (L2 - L1) *
                                     ((2.0 / 3.0) - LR) * 6.0
  Else LR := L1;
  LG := LH;
  if LG < 0 then LG := LG + 1.0;
  if LG > 1 then LG := LG - 1.0;
  If 6.0 * LG < 1 then LG := L1+(L2 - L1) * 6.0 * LG
  Else if 2.0*LG < 1 then LG := L2
  Else if 3.0*LG < 2 then LG := L1 + (L2 - L1) *
                                     ((2.0 / 3.0) - LG) * 6.0
  Else LG := L1;
  LB := LH - 1.0/3.0;
  if LB < 0 then LB := LB + 1.0;
  if LB > 1 then LB := LB - 1.0;
  If 6.0 * LB < 1 then LB := L1+(L2 - L1) * 6.0 * LB
  Else if 2.0*LB < 1 then LB := L2
  Else if 3.0*LB < 2 then LB := L1 + (L2 - L1) *
                                     ((2.0 / 3.0) - LB) * 6.0
  Else LB := L1;
  Result.R := round(LR * 255);
  Result.G := round(LG * 255);
  Result.B := round(LB * 255);
end;

function CalcComplementalColor(AColor: TColor): TColor;
var
  LRGB: TRGB;
  LHLS: THLS;
begin
  LRGB := ColorToRGB(AColor);
{  LHLS := RGBToHLS(LRGB);

  LHLS.H := LHLS.H + $200;  //Hue, Add 180 deg (0x200 = 0x400 / 2)
  LHLS.H := LHLS.H and $7ff;//Hue, Mod 360 deg to Hue
  LRGB := HLSToRGB(LHLS);
  Result := RGBTOCol(LRGB);
}
  if AColor >= 0 then
    Result := RGB((255-LRGB.R),(255-LRGB.G),(255-LRGB.B))
  else
    Result := $00ffffff;
end;

procedure RGBToHSV (const R,G,B: Double; var H,S,V: Double);
var
  Delta: double;
  Min : double;
begin
  Min := MinValue( [R, G, B] );
  V := MaxValue( [R, G, B] );

  Delta := V - Min;

  // Calculate saturation: saturation is 0 if r, g and b are all 0
  if V = 0.0 then
    S := 0
  else
    S := Delta / V;

  if (S = 0.0) then
    H := NaN    // Achromatic: When s = 0, h is undefined
  else
  begin       // Chromatic
    if (R = V) then
    // between yellow and magenta [degrees]
      H := 60.0 * (G - B) / Delta
    else
      if (G = V) then
       // between cyan and yellow
        H := 120.0 + 60.0 * (B - R) / Delta
      else
        if (B = V) then
        // between magenta and cyan
          H := 240.0 + 60.0 * (R - G) / Delta;

    if (H < 0.0) then
      H := H + 360.0
  end;
end; {RGBtoHSV}

procedure HSVtoRGB (const H,S,V: double; var R,G,B: double);
var
  f : double;
  i : INTEGER;
  hTemp: double; // since H is CONST parameter
  p,q,t: double;
begin
  if (S = 0.0) then    // color is on black-and-white center line
  begin
    if IsNaN(H) then
    begin
      R := V;           // achromatic: shades of gray
      G := V;
      B := V
    end;
    //else
    //  raise;// EColorError.Create('HSVtoRGB: S = 0 and H has a value');
  end
  else
  begin // chromatic color
    if (H = 360.0) then         // 360 degrees same as 0 degrees
      hTemp := 0.0
    else
      hTemp := H;

    hTemp := hTemp / 60;     // h is now IN [0,6)
    i := TRUNC(hTemp);        // largest integer <= h
    f := hTemp - i;                  // fractional part of h

    p := V * (1.0 - S);
    q := V * (1.0 - (S * f));
    t := V * (1.0 - (S * (1.0 - f)));

    case i of
      0: begin R := V; G := t;  B := p  end;
      1: begin R := q; G := V; B := p  end;
      2: begin R := p; G := V; B := t   end;
      3: begin R := p; G := q; B := V  end;
      4: begin R := t;  G := p; B := V  end;
      5: begin R := V; G := p; B := q  end;
    end;
  end;
end; {HSVtoRGB}

function HSVtoColor(Const Hue, Saturation, Value: Integer): TColor;
Var
  Red, Green, Blue: double;
begin
  //HSVtoRGB(Hue, Saturation, Value, Red, Green, Blue);
  //Result := RGB(Red, Green, Blue);
end;

procedure ColortoHSV(Const Color: TColor; Var Hue, Saturation, Value: Integer);
Var
  RGB: LongWord;
begin
  //RGB := ColorToRGB(Color);
  //RGBtoHSV(GetRValue(RGB), GetGValue(RGB), GetBValue(RGB), Hue, Saturation, Value);
end;

function EnumGetProcessWindow(wnd: HWND; userParam: LPARAM): BOOL; stdcall;
var
  wndProcessID: DWORD;
begin
  GetWindowThreadProcessId(wnd, @wndProcessID);
  if (wndProcessID = PProcWndInfo(userParam)^.TargetProcessID) and
     (GetWindowLong(wnd, GWL_HWNDPARENT) = 0) then
  begin
    PProcWndInfo(userParam)^.FoundWindow := Wnd;
    Result := false;
  end
  else
    Result := true;
end; { EnumGetProcessWindow }

{ln}
function DSiGetProcessWindow(targetProcessID: cardinal): HWND;
var
  procWndInfo: TProcWndInfo;
begin
  procWndInfo.TargetProcessID := targetProcessID;
  procWndInfo.FoundWindow := 0;
  EnumWindows(@EnumGetProcessWindow, LPARAM(@procWndInfo));
  Result := procWndInfo.FoundWindow;
end; { DSiGetProcessWindow }

function ExecuteSound(const Sound: string; IsStop: Boolean = False;
  SoundType: TSoundType = stFileName;
  Synchronous: Boolean = False; Module: HMODULE = 0;
  AddFlags: LongWord = 0): Boolean;
var
  Flags: LongWord;
begin
  if IsStop then
  begin
    Result := sndPlaySound(nil, 0);
    exit;
  end;

  Flags := AddFlags;
  case SoundType of
    stFileName: Flags := Flags or SND_FILENAME;
    stResource: Flags := Flags or SND_RESOURCE;
    stSysSound: Flags := Flags or SND_ALIAS;
  end;
  if not Synchronous then
    Flags := Flags or SND_ASYNC;
  if SoundType <> stResource then
    Module := 0;

  //Result := PlaySound(PChar(Sound), Module, Flags);
  Result := sndPlaySound(PChar(Sound), SND_ASYNC or SND_LOOP);
end;

function IsFloat(AValue: double): Boolean;
begin
  Result := Frac(AValue) <> 0;
end;

{ Search for files with a maks;
 e.g. GetFileListFromDir('c:\data\', '*.mp3', true);
      GetFileListFromDir('d:\MyDocuments\', '*.doc', false);
}
function GetFileListFromDir(const Path, Mask: string; IncludeSubDir: boolean): TStringList;
var
 FindResult: integer;
 SearchRec : TSearchRec;
begin
  result := TStringList.Create;

  FindResult := FindFirst(Path + Mask, faAnyFile - faDirectory, SearchRec);
  while FindResult = 0 do
  begin
    { do whatever you'd like to do with the files found }
    result.Add(Path + SearchRec.Name);
    FindResult := FindNext(SearchRec);
  end;
  { free memory }
  FindClose(SearchRec);

  if not IncludeSubDir then
    Exit;

  FindResult := FindFirst(Path + '*.*', faDirectory, SearchRec);
  while FindResult = 0 do
  begin
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      GetFileListFromDir (Path + SearchRec.Name + '\', Mask, TRUE);

    FindResult := FindNext(SearchRec);
  end;
  { free memory }
  FindClose(SearchRec);
end;

//V: Second
//24�ð��� �ʰ��� ��쿡�� hhh:mm:ss�� ǥ�� ����
Function FORMAT_TIME (V : Integer) : string; { format time as hh:mm:ss }
Var
  Hour,Min,Sec : Integer;
  str1: string;
begin
  FORMAT_TIME := '';

  if V < 0 then
    exit;

  Hour := V div 3600;
  V := V mod 3600;               { process hours }

  Min := V div 60;
  Sec := V mod 60;                 { process minutes }

  FORMAT_TIME := Format('%d:%.2d:%.2d',[Hour,Min,Sec]);
end;

//ANames�߿��� ���ĺ�,����,_ �� �̷���� ���� ��ȯ�ϰ� ��ȯ�� ���ڸ� ANames���� ������
function GetVariableName(var ANames: string): string;
var
  pos: integer;
begin
  Result := '';
  pos := 0;
  while (pos <= length(ANames)) and (ANames[pos] = ' ') do inc(pos);
  if pos > length(ANames) then
    exit;

  while (pos <= length(ANames)) and
    (ANames[pos] in ['a'..'z', 'A'..'Z', '_', '1'..'9', '0']) do
  begin
    Result := Result + ANames[pos];
    inc(pos);
  end;

  dec(pos);

  System.Delete(ANames,1,pos);

end;

function IntToBool(AValue: Integer): Boolean;
begin
  Result := AValue <> 0;
end;

function BoolToInt(AValue: Boolean): Integer;
begin
  Result := Ord(AValue);
end;

{-------------------------------------------------------------------------------
*PosRev - Same as standard Pos string function except that it scans backwards.
 Example: PosRev('O','HELLO WORLD') > 8 (last O)
-------------------------------------------------------------------------------}
function PosRev(SubStr,s : string; IgnoreCase : boolean = false) : integer;
var i : integer;

   function IsMatch : boolean;
   var j : integer;
   begin
     Result := false;
     for j := 2 to Length(SubStr) do if SubStr[j]<>s[i+(j-1)] then exit;
     Result := true;
   end;

var l : integer;
begin
  Result := 0;
  if IgnoreCase then
  begin
    s := UpperCase(s);
    SubStr := UpperCase(SubStr);
  end;
  l := Length(SubStr);
  if l=0 then exit;
  for i := Length(s) downto 1 do
  begin
    if s[i]=SubStr[1] then
    begin
      if l=1 then
      begin
        Result := i;
        exit;
      end else
      begin
        if IsMatch then
        begin
          Result := i;exit;
        end;
      end;
    end;
  end;
end;

procedure GetFiles(var AFileList: TStringList; AFileName: string);
Var
  SearchRec: TSearchRec;
  sgPath   : String;
  inRetval : Integer;
begin
  sgPath := ExpandFileName(AFileName);
  sgPath := ExtractFilePath(sgPath);
  AFileName := ExtractFileName(AFileName);
  Try
    inRetval := FindFirst(sgPath + '*'+AFileName+ '*', faAnyFile, SearchRec);
    If inRetval = 0 Then
    begin
      repeat
        AFileList.Add(sgPath+SearchRec.Name);
        inRetval := FindNext(SearchRec);
      until (inRetval <> 0);
    end;
  Finally
    SysUtils.FindClose(SearchRec);
  End;
end;

//Application.exename�� �������� AFilePath�� ��� ��θ� ��ȯ��
//'.\'�� ������
function ExtractRelativePathBaseApplication(AApplicationPath, AFileNameWithPath: string): string;
begin
  Result := IncludeTrailingBackslash(ExtractRelativePath(
                      ExtractFilePath(AApplicationPath),
                      ExtractFilePath(AFileNameWithPath))) +
                      ExtractFileName(AFileNameWithPath);

  if Pos('.\', Result) = 0 then
    Result := '.\' + Result;
end;

end.