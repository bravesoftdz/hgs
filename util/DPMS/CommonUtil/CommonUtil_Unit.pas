﻿unit CommonUtil_Unit;

interface

uses Windows, sysutils, classes, Forms, shellapi, Graphics, math, MMSystem,
    JclStringConversions, WinSock, Winapi.Messages, TLHelp32, GraphUtil,
    Vcl.Imaging.PngImage, Vcl.Imaging.GIFImg, Vcl.Imaging.Jpeg, Vcl.ExtCtrls, DB, Vcl.Consts, Winapi.SHFolder,
    ShlObj, JvWinDialogs, WinApi.IMM;

type
  TByteArr = array of byte;

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

CONST
  B36 : PChar = ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  MinGraphicSize = 44; //we may test up to & including the 11th longword

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

function GetIpFromHost(var HostName, IPaddr, WSAErr : String) : Boolean;
function IsHanGeul(S: String): Boolean;
function LRTrim_bnk( const s: string ): String;
function GetToken( var str1: string; SepChar: string ): String;
Function DateTimeToMilliseconds(DateTime: TDateTime): Int64;
function GetFileVersion(szFullPath: pChar): String; //파일정보 읽어오기
function GetFileLastWriteTime(sFileName:string) : TDateTime;

procedure GetFileInfo(FileName: String; var iFileSizeByte, sFileSizeKB : longint;
                    var sCreateDate, sUpdateDate, sAcessDate, sFileType : String);

procedure LockMDIChild(Lock: Boolean);

function KillTask(ExeFileName: string): Integer;//파일명으로 실행중인 프로세스 죽이기
function isOpen(ExeFileName: string): integer; //파일명으로 실행여부 확인하고 프로세 아이디 얻기
function NumberFormat(S:String):String;
function GetFileIcon(aFileName:String):HICON;
function SecondIdle : DWord;
function ThumbnailFromImage(aImgPath:String; aImgStream:TMemoryStream; aThumbnailSize:Integer) : TMemoryStream;
function DataSavedTimeToDateFormat(aDataSavedTime:String):String;
function StrToByte(const Value: String): TByteArr;
function Get_ImageFromStream(const aStream:TMemoryStream;aImage:TImage):Boolean;

function FindGraphicClass(const Buffer; const BufferSize: Int64;
  out GraphicClass: TGraphicClass): Boolean; overload;
function FindGraphicClass(Stream: TStream;
  out GraphicClass: TGraphicClass): Boolean; overload;
procedure LoadPictureFromBlobField(Field: TBlobField; Dest: TPicture);
function GetMyDocumentsDir: String;
Function ColNumToName(ColNum : Integer) : String;
Function ColNameToNum(In_StrColName : String) : Integer;
function FileSize(const aFilename: String): Int64;

Function Week2FirstDate(n: integer; d: TDateTime):TDatetime;
Function Week2LastDate(n: integer; d: TDateTime):TDatetime;

procedure SetHangeulMode(AHandle: THandle; ASetHangeul: Boolean);
procedure SetHangeulMode2(AHandle: THandle);
function GetImeHanMode(AHandle: THandle): boolean;
procedure ToggleHanMode;
function  dateDiff2min(D1,D2: TDateTime): Integer;
function DateTimeMinusInteger(d1:TDateTime;i:integer;mType:integer;Sign:Char):TDateTime;
procedure CreateDirIfNotExist(ADir: string);
function IsRunningProcess( const ProcName: String ) : Boolean;
function KillProcess(const ProcName: String): Boolean;
function KillProcessId(const AProcId: THandle): Boolean;

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

//파일로부터 한 개의 라인을 읽는다
//Eof면 False를 반환한다.
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

  n := Pos(#13,ReadData); //Readln(#10도 있음)
  if n > 0 then
  begin
    //Delete(ReadData, n,BlockSize-n+5 );
    Delete(ReadData, n,Length(ReadData)-n+1 );
    FileSeek(File_Handle, n-Bread+1, 1);
  end;
  Result := True;
end;

//콤마로 분리된 문자를 하나씩 반환한다.
//원본에서는 추출된 문자를 지운다.
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
    Result := Str1;
end;

// Char를 Byte값으로 변환한다..
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
// String을 Hex값으로 바꾼다.(Byte 단위 계산임)
function Str2Hex_Byte(szStr: string): Byte;
begin
  szStr := UpperCase(szStr);
  Result := ((AtoX(szStr[1]) shl 4)  or (AtoX(szStr[2])));
end;

// Char를 Integer값으로 변환한다..
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

// String을 Hex값으로 바꾼다.(Integer 단위 계산임)
function Str2Hex_Int(szStr: string): integer;
begin
  szStr := UpperCase(szStr);
  Result := ((AtoX_Int(szStr[1]) shl 12) or (AtoX_Int(szStr[2]) shl 8) or
              (AtoX_Int(szStr[3]) shl 4)  or (AtoX_Int(szStr[4])));
end;

//두자리가 한개의 헥사값을 가짐.
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


//LRC를 Check하여 정상이면 True를 반환함
//Data는 Lrc를 제거한 상태여야 함
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

//Position: 이 위치 이후부터 맨 처음에 나오는 SearchStr의 위치를 반환함
//없으면 0을 반환함
function NextPos2(SearchStr, Str : String; Position : integer) : integer;
begin
  delete(Str, 1, Position-1);
  Result := pos(SearchStr, upperCase(Str));
  If Result = 0 then exit;
  If (Length(Str) > 0) and (Length(SearchStr) > 0) then
    Result := Result + Position - 1;
end;

//파일의 AppendPosition에 한 개의 라인을 써 넣는다.
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

//파일의 AppendPosition에 한 개의 라인을 써 넣는다.
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

//화일을 생성(IsUpdate가 False이고 화일이 존재하지 않을경우)하거나
//기존 화일에 Data를 추가함
//IsUpdate : True = 기존 화일을 삭제하고 재 생성
//화일이 처음 생성된 경우 True를 반환함
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

//Directory Name, Extention Name, Data를 화일이름이 현재날짜인 화일에 기록
//화일이 처음 생성된 경우 True를 반환함
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

//화일이 처음 생성된 경우 True를 반환함
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

//Nth = 0 이면 가장 오른쪽(LSB)값을 반환함
//값이 0이 아닌 경우는 2진수 값임, 즉 Nth = 3 이 1이면 4가 반환됨
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
      PChar(WideString(ProgramName)),       // command line
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

function GetHandleByPID(Pid: longword): THandle; // 델마당 '나도 한때는' 님의 코드를 슬쩍...
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

function GetIPFromHost
(var HostName, IPaddr, WSAErr: string): Boolean;
type
  Name = array[0..100] of AnsiChar;
  PName = ^Name;
var
  HEnt: pHostEnt;
  HName: PName;
  WSAData: TWSAData;
  i: Integer;
begin
  Result := False;
  if WSAStartup($0101, WSAData) <> 0 then begin
    WSAErr := 'Winsock is not responding."';
    Exit;
  end;
  IPaddr := '';
  New(HName);
  if GetHostName(HName^, SizeOf(Name)) = 0 then
  begin
    HostName := StrPas(HName^);
    HEnt := GetHostByName(HName^);
    for i := 0 to HEnt^.h_length - 1 do
     IPaddr :=
      Concat(IPaddr,
      IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.');
    SetLength(IPaddr, Length(IPaddr) - 1);
    Result := True;
  end
  else begin
   case WSAGetLastError of
    WSANOTINITIALISED:WSAErr:='WSANotInitialised';
    WSAENETDOWN      :WSAErr:='WSAENetDown';
    WSAEINPROGRESS   :WSAErr:='WSAEInProgress';
   end;
  end;
  Dispose(HName);
  WSACleanup;
end;

function IsHanGeul(S: String): Boolean;
const
  UniCodeHangeulBase1 = $1100;
  UniCodeHangeulLast1 = $11F9;
  UniCodeHangeulBase2 = $3130;
  UniCodeHangeulLast2 = $318E;
  UniCodeHangeulBase3 = $AC00;
  UniCodeHangeulLast3 = $D7A3;
begin
  if ((ord(S[1]) >= UniCodeHangeulBase1) and
    (ord(S[1]) <= UniCodeHangeulLast1)) or
    ((ord(S[1]) >= UniCodeHangeulBase2) and
    (ord(S[1]) <= UniCodeHangeulLast2)) or
    ((ord(S[1]) >= UniCodeHangeulBase3) and
    (ord(S[1]) <= UniCodeHangeulLast3)) then
    Result := True
  else
    Result := False;
end;

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

function DateTimeToMilliseconds(DateTime: TDateTime): Int64;
{ Converts a TDateTime variable to Int64 milliseconds from 0001-01-01.}
var ts: SysUtils.TTimeStamp;
begin
{ Call DateTimeToTimeStamp to convert DateTime to TimeStamp: }
  ts  := SysUtils.DateTimeToTimeStamp(DateTime);
{ Multiply and add to complete the conversion: }
  Result  := Int64(ts.Date)*MSecsPerDay + ts.Time;
end;

function GetFileVersion(szFullPath: pChar): String;
var
  Size, Size2: DWord;
  Pt, Pt2: Pointer;
begin
  Result := '';
  Size := GetFileVersionInfoSize(szFullPath, Size2);
  if Size > 0 then begin
    GetMem(Pt, Size);
    try
      GetFileVersionInfo(szFullPath, 0, Size, Pt);
      VerQueryValue (Pt, '\', Pt2, Size2);
      with TVSFixedFileInfo(Pt2^) do begin
        Result := Format('%d.%d.%d.%d', [HiWord(dwFileVersionMS),
                                         LoWord(dwFileVersionMS),
                                         HiWord(dwFileVersionLS),
                                         LoWord(dwFileVersionLS)]);
      end;
    finally
      FreeMem(Pt);
    end;
  end;
end;

function GetFileLastWriteTime(sFileName:string) : TDateTime;
var
  ffd: TWin32FindData;
  dft: DWord;
  lft: TFileTime;
  h: THandle;
begin
  h := Windows.FindFirstFile(PChar(sFileName), ffd);
  if (INVALID_HANDLE_VALUE <> h) then
  begin
    Windows.FindClose(h);
    FileTimeToLocalFileTime(ffd.ftLastWriteTime, lft);
    FileTimeToDosDateTime(lft, LongRec(dft).Hi, LongRec(dft).Lo);
    Result := FileDateToDateTime(dft);
  end;
end;

procedure GetFileInfo(FileName: String; var iFileSizeByte, sFileSizeKB : longint;
                    var sCreateDate, sUpdateDate, sAcessDate, sFileType : String);
  function FileSize(hi,lo: integer) :longint;
  begin
    Result := (hi * MAXDWORD) + lo;
  end;

  // This function retrieves the last time, the given file was written to disk
  function GetLocalTime(a:tfiletime):string;
  var
    mtm:   TSystemTime;
    at:    TFileTime;
    ds,ts: ShortString;
  begin
    filetimetolocalfiletime(a,at);
    filetimetosystemtime(at,mtm);
    SetLength(ds, GetDateFormat(LOCALE_USER_DEFAULT, 0, @mtm, PChar('yyyy/MM/dd'), @ds[1], 255) - 1);
    //SetLength(ts, GetTimeFormat(LOCALE_USER_DEFAULT, time_noseconds, @mtm, NIL, @ts[1], 255)  - 1);TIME_NOMINUTESORSECONDS
    SetLength(ts, GetTimeFormat(LOCALE_USER_DEFAULT, 0, @mtm, PChar('hh:mm:ss'), @ts[1], 255)  - 1);
    Result:=ds+'  '+ts;
  end;

var
  SHFinfo: TSHFileInfo;
  FindData: TWin32FindData;
  FindHandle :THandle;
begin

    iFileSizeByte := 0;
    sFileSizeKB   := 0;
    sCreateDate   := '';
    sUpdateDate := '';
    sAcessDate := '';
    sFileType := '';

    ShGetFileInfo(PChar(FileName), 0, SHFinfo, SizeOf(SHFinfo), // 파일종류만 알아낸다
                    SHGFI_TYPENAME);
    sFileType := SHFinfo.szTypeName; // 파일종류(Type)

    FindHandle := Windows.FindFirstFile(PChar(FileName), FindData);
    try
        iFileSizeByte := FileSize(FindData.nFileSizeHigh, FindData.nFileSizeLow);
        sFileSizeKB := Trunc(FileSize(FindData.nFileSizeHigh, FindData.nFileSizeLow) / 1024);

        sCreateDate    := GetLocalTime(FindData.ftCreationTime);   // 파일생성일(Created)
        sUpdateDate   := GetLocalTime(FindData.ftLastWriteTime);  // 파일변경일(Modified)
        sAcessDate := GetLocalTime(FindData.ftLastAccessTime); // 파일접근일(LastAccess)
    finally
        Windows.FindClose(FindHandle);
    end;
end;

procedure LockMDIChild(Lock: Boolean);
begin
  if Lock then
  begin
    SendMessage(Application.MainForm.ClientHandle, WM_SETREDRAW, 0, 0);
  end
  else
  begin
    SendMessage(Application.MainForm.ClientHandle, WM_SETREDRAW, 1, 0);
    RedrawWindow(Application.MainForm.ClientHandle, nil, 0,
      RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
  end;
end;

//출처 http://www.delphi3000.com/articles/article_4324.asp?SK=
//실행파일명으로 프로세스 종료
function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
        OpenProcess(PROCESS_TERMINATE,
        BOOL(0),
        FProcessEntry32.th32ProcessID),
        0));

    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

 //출처 http://www.delphi3000.com/articles/article_4324.asp?SK=
 //
function isOpen(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;

begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
    begin
      result := FProcessEntry32.th32ProcessID;
      break;
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function NumberFormat(S:String):String;
begin
  if s = '' then
    s := '0'
  else begin
    s := formatfloat('###,###,###,###,##0',StrToFloat(StringReplace(s,',','',[rfReplaceAll])));
//    s := formatfloat('###,###,###,###,##0',StrToInt64(StringReplace(s,',','',[rfReplaceAll])));
  result :=s;
end;

end;

function GetFileIcon(aFileName:String):HICON;
var
  SHFileInfo : TSHFileInfo;
  TypeName : Cardinal;

begin
  TypeName := SHGFI_USEFILEATTRIBUTES or SHGFI_ICON or SHGFI_EXETYPE or SHGFI_SMALLICON;

  SHGetFileInfo(PChar(aFileName), 0, SHFileInfo, SizeOf(TSHFileInfo), TypeName);
  Result := SHFileInfo.hIcon;
end;

function SecondIdle: DWord;
var
  linfo : TLastInputInfo;
begin
  linfo.cbSize := SizeOf(TLastInputInfo);
  GetLastInputInfo(linfo);
  Result := (GetTickCount - linfo.dwTime) DIV 1000;

end;

function ThumbnailFromImage(aImgPath:String; aImgStream:TMemoryStream;
  aThumbnailSize:Integer) : TMemoryStream;
var
  ImageExt: string;
  graphicSource: TGraphic;
  bmpSource: TBitmap;
  jpgThumbnail: TJPEGImage;
  bmpThumbnail: TBitmap;
  fScale: double;
begin
  ImageExt := LowerCase(ExtractFileExt(aImgPath));
  if ImageExt='.jpg' then
    graphicSource := TJPEGImage.Create
  else if ImageExt='.png' then
    graphicSource := TPngImage.Create
  else if ImageExt='.gif' then
    graphicSource := TGIFImage.Create
  else if ImageExt='.bmp' then
    graphicSource := TBitmap.Create
  else
    exit;

  try
    graphicSource.LoadFromStream(aImgStream);
    if ImageExt='.bmp' then
      bmpSource := TBitmap(graphicSource)
    else
    begin
      bmpSource := TBitmap.Create;
      bmpSource.Assign(graphicSource);
    end;

    bmpThumbnail := TBitmap.Create;
    try
      if bmpSource.Width >= bmpSource.Height then
        fScale := aThumbnailSize / bmpSource.Width
      else
        fScale := aThumbnailSize / bmpSource.Height;

      ScaleImage(bmpSource, bmpThumbnail, fScale);

      jpgThumbnail := TJPEGImage.Create;
      try
        jpgThumbnail.Assign(bmpThumbnail);
        jpgThumbnail.CompressionQuality := 90;
        jpgThumbnail.Compress;

        result := TMemoryStream.Create;
        try
          jpgThumbnail.SaveToStream(Result);
          result.Position := 0;

        except
          result := nil;
        end;
      finally
        jpgThumbnail.Free;
      end;
    finally
      bmpThumbnail.Free;
      if graphicSource <> bmpSource then
        bmpSource.Free;
    end;
  finally
    graphicSource.Free;
  end;
end;

function DataSavedTimeToDateFormat(aDataSavedTime:String):String;
var
  year,
  Month,
  Day,
  Hour,
  Minute,
  Second,
  milsec : String;
begin
  Result := '';
  if aDataSavedTime <> '' then
  begin
    year   := Copy(aDataSavedTime,1,4);
    Month  := Copy(aDataSavedTime,5,2);
    Day    := Copy(aDataSavedTime,7,2);

    Hour   := Copy(aDataSavedTime,9,2);
    Minute := Copy(aDataSavedTime,11,2);
    Second := Copy(aDataSavedTime,13,2);
    milsec := Copy(aDataSavedTime,15,3);

    Result := year+'-'+Month+'-'+Day+' '+Hour+':'+Minute+':'+Second+'.'+milsec;
  end;
end;

function StrToByte(const Value: String): TByteArr;
var
    I: integer;
begin
    SetLength(Result, Length(Value));
    for I := 0 to Length(Value) - 1 do
      Result[I] := ord(Value[I + 1]) - 48;
end;

function Get_ImageFromStream(const aStream:TMemoryStream;aImage:TImage):Boolean;
const
  US_BITMAP_TYPE = $4D42;
  US_JPEG_TYPE = $FFFFD8FF;
  US_GIF_TYPE = $4947;
  US_WMF_TYPE = $FFFFCDD7;
  US_TIF_TYPE = $4949;
  US_PCX_TYPE = $50A;
  US_PSD_TYPE = $4238;
  US_PNG_TYPE = $5089;
var
  var1, var2 : Word;
  Jpg : TJPEGImage;
  bmp : TBitmap;
  gif : TGIFImage;
  png : TPngImage;
  tif : TWICImage;

begin
  Result := False;
  aStream.Seek(0, soFromBeginning);
  aStream.Read(var1,2);

  aStream.Position := 2;
  aStream.Read(var2,2);

  aStream.Position := 0;
  try
    if (var1 = $D8FF) and (var2 = $E0FF) then //JPEG
    begin
      Jpg := TJPEGImage.Create;
      try
        Jpg.LoadFromStream(aStream);
        aImage.Picture.Graphic := Jpg;
        Result := True;
      finally
        FreeAndNil(Jpg);
      end;
    end else if (var1 = $4D42) then //Bitmap
    begin
      bmp := TBitmap.Create;
      try
        bmp.LoadFromStream(aStream);
        aImage.Picture.Graphic := bmp;
        Result := True;
      finally
        FreeAndNil(bmp);
      end;
    end else if (var1 = $4947) then //Gif Image
    begin
      Gif := TGIFImage.Create;
      try
        Gif.LoadFromStream(aStream);
        aImage.Picture.Graphic := Gif;
        Result := True;
      finally
        FreeAndNil(Gif);
      end;
    end else if (var1 = $4949) then //TIF Image
    begin
      tif := TWICImage.Create;
      try
        tif.LoadFromStream(aStream);
        aImage.Picture.Graphic := tif;
        Result := True;
      finally
        FreeAndNil(tif);
      end;
    end else if (var1 = $5089) then //PNG Image
    begin
      png := TPngImage.Create;
      try
        png.LoadFromStream(aStream);
        aImage.Picture.Graphic := png;
        Result := True;
      finally
        FreeAndNil(png);
      end;
    end;
  finally
    aImage.Invalidate;
    aImage.Hint := '';
  end;
end;

function FindGraphicClass(const Buffer; const BufferSize: Int64;
  out GraphicClass: TGraphicClass): Boolean; overload;
var
  LongWords: array[Byte] of LongWord absolute Buffer;
  Words: array[Byte] of Word absolute Buffer;
begin
  GraphicClass := nil;
  Result := False;
  if BufferSize < MinGraphicSize then Exit;
  case Words[0] of
    $4D42: GraphicClass := TBitmap;
    $D8FF: GraphicClass := TJPEGImage;
    $4949: if Words[1] = $002A then GraphicClass := TWicImage; //i.e., TIFF
    $4D4D: if Words[1] = $2A00 then GraphicClass := TWicImage; //i.e., TIFF
  else
    if Int64(Buffer) = $A1A0A0D474E5089 then
      GraphicClass := TPNGImage
    else if LongWords[0] = $9AC6CDD7 then
      GraphicClass := TMetafile
    else if (LongWords[0] = 1) and (LongWords[10] = $464D4520) then
      GraphicClass := TMetafile
    else if StrLComp(PAnsiChar(@Buffer), 'GIF', 3) = 0 then
      GraphicClass := TGIFImage
    else if Words[1] = 1 then
      GraphicClass := TIcon;
  end;
  Result := (GraphicClass <> nil);
end;

function FindGraphicClass(Stream: TStream;
  out GraphicClass: TGraphicClass): Boolean; overload;
var
  Buffer: PByte;
  CurPos: Int64;
  BytesRead: Integer;
begin
  if Stream is TCustomMemoryStream then
  begin
    Buffer := TCustomMemoryStream(Stream).Memory;
    CurPos := Stream.Position;
    Inc(Buffer, CurPos);
    Result := FindGraphicClass(Buffer^, Stream.Size - CurPos, GraphicClass);
    Exit;
  end;
  GetMem(Buffer, MinGraphicSize);
  try
    BytesRead := Stream.Read(Buffer^, MinGraphicSize);
    Stream.Seek(-BytesRead, soCurrent);
    Result := FindGraphicClass(Buffer^, BytesRead, GraphicClass);
  finally
    FreeMem(Buffer);
  end;
end;

//사용예:
//LoadPictureFromBlobField(cdsPicture, Image1.Picture);
procedure LoadPictureFromBlobField(Field: TBlobField; Dest: TPicture);
var
  Graphic: TGraphic;
  GraphicClass: TGraphicClass;
  Stream: TMemoryStream;
begin
  Graphic := nil;
  Stream := TMemoryStream.Create;
  try
    Field.SaveToStream(Stream);
    if Stream.Size = 0 then
    begin
      Dest.Assign(nil);
      Exit;
    end;
    if not FindGraphicClass(Stream.Memory^, Stream.Size, GraphicClass) then
      raise EInvalidGraphic.Create(SInvalidImage);
    Graphic := GraphicClass.Create;
    Stream.Position := 0;
    Graphic.LoadFromStream(Stream);
    Dest.Assign(Graphic);
  finally
    Stream.Free;
    Graphic.Free;
  end;
end;

function GetMyDocumentsDir: String;
const
  CSIDL_PROGRAM_FILES = $0026;
  CSIDL_MYDOCUMENTS   = CSIDL_PERSONAL;

var
  pidl: PItemIDList;
  Path: array [0..MAX_PATH-1] of char;
begin
  if Succeeded(SHGetSpecialFolderLocation(Application.Handle, CSIDL_MYDOCUMENTS, pidl)) then
  begin
    if SHGetPathFromIDList(pidl, Path) then
      Result := StrPas(path);
    FreePidl(pidl);
  end;
end;

// Index값을 영문 컬럼네임명으로 변환하여 반환
Function ColNumToName(ColNum : Integer) : String;
Var
  iCycleNum  : Integer;
  iWithinNum : Integer;
Begin
  Result := '';
  iCycleNum  := ColNum Div 26;
  iWithinNum := ColNum - (iCycleNum * 26);
  If (iCycleNum > 0) Then
    Result := Result + Char((iCycleNum - 1) + Ord('A'));
  Result := Result + Char(iWithinNum + Ord('A'));
End;
// 영문 컬럼명을 숫자 Index값으로 변환하여 반환
Function ColNameToNum(In_StrColName : String) : Integer;
Var
  I : Integer;
Begin
  Result := 0;
  In_StrColName := UpperCase(In_StrColName);
  For I := 1 To Length(In_StrColName) Do Begin
    Result := (Result * 26) + (Ord(In_StrColName[I]) - Ord('A') + 1);
  End;
  Dec(Result);
End;

function FileSize(const aFilename: String): Int64;
var
  info: TWin32FileAttributeData;
begin
  result := -1;

  if NOT GetFileAttributesEx(PWideChar(aFileName), GetFileExInfoStandard, @info) then
    EXIT;

  result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
end;

//1년중 몇주차를 인수로 받아서 해당 주의 시작일(월요일)을 날짜형으로 반환함
//인자: n = 주
//     d = 년도를 지정하기 위함
Function Week2FirstDate(n: integer; d: TDateTime):TDatetime;
var Year, Month, Day: Word;
    tmpDate: TDateTime;
begin
  DecodeDate(d, Year, Month, Day);
  Month := 1;
  Day := 1;
  tmpDate := EncodeDate(Year, Month, Day);

  Result := tmpDate + ((n - 1) * 7);

  while DayOfWeek(Result)<>2 do //1 = sunday
    Result := Result - 1;
end;

//1년중 몇주차를 인수로 받아서 해당 주의 말일(토요일)을 날짜형으로 반환함
//인자: n = 주
//     d = 년도를 지정하기 위함
Function Week2LastDate(n: integer; d: TDateTime):TDatetime;
var Year, Month, Day: Word;
    tmpDate: TDateTime;
begin
  DecodeDate(d, Year, Month, Day);
  Month := 1;
  Day := 1;
  tmpDate := EncodeDate(Year, Month, Day);

  Result := tmpDate + ((n - 1) * 7);

  while DayOfWeek(Result)<>7 do //7 = saturday
    Result := Result + 1;
end;

//AHandle: 한글모드로 바꾸고자 하는 컴포넌트 핸들
procedure SetHangeulMode(AHandle: THandle; ASetHangeul: Boolean);
var
  LImmHandle:HIMC;
  LIsHangeul: Boolean;
begin
  //Imm 핸들 가져옴
  LImmHandle := ImmGetContext(AHandle);
  //현재 모드를 가져옴
//  LIsHangeul := ImmGetOpenStatus(LImmHandle);

  if LIsHangeul then //한글모드이면
    exit;

  if ASetHangeul then
    ImmSetConversionStatus(LImmHandle, IME_CMODE_HANGEUL, IME_SMODE_NONE)
  else
    ImmSetConversionStatus(LImmHandle, IME_CMODE_ALPHANUMERIC, IME_SMODE_NONE);

  ImmReleaseContext(AHandle, LImmHandle);//핸들 해제
end;

procedure SetHangeulMode2(AHandle: THandle);
var
  Mode: HIMC;
  Conversion, Sentence: dword;
begin
  Mode := ImmGetContext(AHandle);
  ImmGetConversionStatus(Mode, Conversion, Sentence);

  if Conversion = IME_CMODE_ALPHANUMERIC then
    ImmSetConversionStatus(Mode, IME_CMODE_NATIVE, Sentence);
end;

function GetImeHanMode(AHandle: THandle): boolean;
var
  Mode: HIMC;
  Conversion, Sentence: dword;
begin
  Mode := ImmGetContext(Application.Handle);
  ImmGetConversionStatus(Mode, Conversion, Sentence);
  result := Conversion = IME_CMODE_HANGEUL;
end;

procedure ToggleHanMode;
var
  Mode: HIMC;
  Conversion, Sentence: dword;
begin
  Mode := ImmGetContext(Application.Handle);
  ImmGetConversionStatus(Mode, Conversion, Sentence);
  if Conversion = IME_CMODE_ALPHANUMERIC then
    ImmSetConversionStatus(Mode, IME_CMODE_NATIVE, Sentence)
  else
    ImmSetConversionStatus(Mode, IME_CMODE_ALPHANUMERIC, Sentence);
end;

//두 날짜의 차이를 분으로 반환
function  dateDiff2min(D1,D2: TDateTime): Integer;
var hour,min,sec,msec:word;
    hour2,min2,sec2,msec2:word;
    tmpd1:TDatetime;
    tmpdate,tmpmin:integer;
begin
  tmpdate := Trunc(d2)-Trunc(d1);
  tmpdate := tmpdate*24*60;

  Decodetime(d1,hour,min,sec,msec);
  Decodetime(d2,hour2,min2,sec2,msec2);

  if min > min2 then
  begin
    if hour < hour2 then
    begin
      dec(hour2);
      min2 := min2 + 60;
    end;
  end;

  tmpmin := (hour2-hour)*60 + min2-min;

  Result := Round(tmpdate+tmpmin);
end;

//날짜에서 정수를 빼거나 더해서 반환함
//mType = 1 : '시간'에서 정수를 빼거나 더함
//        2 : '분'에서 정수를 빼거나 더함
//        3 : '초에서 정수를 빼거나 더함
//        4 : '년'에서 정수를 빼거나 더함
//        5 : '월' 에서 정수를 빼거나 더함
// '일'자는 바로 정수를 빼거나 더함도 가능함
function DateTimeMinusInteger(d1:TDateTime;i:integer;mType:integer;Sign:Char)
                                                                    :TDateTime;
var hour,min,sec,msec:word;
    year,mon,dat: word;
    tmp: integer;
begin
  Decodetime(d1,hour,min,sec,msec);
  Decodedate(d1,year,mon,dat);

  case mType of
    1:begin//시간
        tmp := 24;
      end;
    2:begin//분
        tmp := 24*60;
      end;
    3:begin//초
        tmp := 24*60*60;
      end;
    4:begin//년
      end;
    5:begin//월
      end;
  end;

  if Sign = '+' then
    Result := d1 + (i/tmp)
  else
    Result := d1 - (i/tmp);
end;

procedure CreateDirIfNotExist(ADir: string);
begin
  ADir := IncludeTrailingPathDelimiter(ExpandFileName(ADir));
  if not DirectoryExists(ADir) then
    ForceDirectories(ADir);
end;

//Check whether the process is alive
// uses 에 TlHelp32 추가
function IsRunningProcess( const ProcName: String ) : Boolean;
var
  Process32: TProcessEntry32;
  SHandle: THandle;
  Next: Boolean;
begin
  Result:=False;
  Process32.dwSize:=SizeOf(TProcessEntry32);
  SHandle :=CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0 );

  // 프로세스 리스트를 돌면서 매개변수로 받은 이름과 같은 프로세스가 있을 경우 True를 반환하고 루프종료
  if Process32First(SHandle, Process32) then
  begin
    repeat
      Next := Process32Next (SHandle, Process32);

      if AnsiCompareText (Process32.szExeFile, Trim (ProcName)) = 0 then
      begin
        Result:= True;
        break;
      end;
    until not Next;
  end;

  CloseHandle (SHandle);
end;

//프로세스 죽이기 (강제종료) Kill the process (kill)
function KillProcess(const ProcName: String): Boolean;
var
  Process32: TProcessEntry32;
  SHandle: THandle;
  Next: Boolean;
  i: Integer;
begin
  Result:=True;
  Process32.dwSize := SizeOf(TProcessEntry32);
  Process32.th32ProcessID:= 0;
  SHandle :=CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0 );

  // 종료하고자 하는 프로세스가 실행중인지 확인하는 의미와 함께...
  if Process32First(SHandle, Process32) then
  begin
    repeat
      Next:=Process32Next(SHandle, Process32);

      if AnsiCompareText(Process32.szExeFile, Trim(ProcName))= 0 then
        break;
    until not Next;
  end;

  CloseHandle(SHandle);

  // 프로세스가 실행중이라면 Open & Terminate
  if Process32.th32ProcessID<> 0 then
    Result := KillProcessId(Process32.th32ProcessID)
  else
    Result:=False;
end;

function KillProcessId(const AProcId: THandle): Boolean;
var
  hProcess: THandle;
begin
  Result := True;
  hProcess:=OpenProcess(PROCESS_TERMINATE, True, AProcId);

  if hProcess<> 0 then
  begin
    Result := TerminateProcess(hProcess, 0 );
    CloseHandle(hProcess);
  end // if Process32.th32ProcessID<>0 end / / if Process32.th32ProcessID <> 0
  else Result:=False;// 프로세스 열기 실패 / / Process failed to open

end;

end.


