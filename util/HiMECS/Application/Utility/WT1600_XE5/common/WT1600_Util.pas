unit WT1600_Util;

interface
uses
  Windows, SysUtils, Classes;

type
  TSunB = packed record
    s_b1, s_b2, s_b3, s_b4: byte;
  end;

  TSunW = packed record
    s_w1, s_w2: word;
  end;

  PIPAddr = ^TIPAddr;
  TIPAddr = record
    case integer of
      0: (S_un_b: TSunB);
      1: (S_un_w: TSunW);
      2: (S_addr: longword);
  end;

 IPAddr = TIPAddr;

function IcmpCreateFile : THandle; stdcall; external 'icmp.dll';
function IcmpCloseHandle (icmpHandle : THandle) : boolean; stdcall; external 'icmp.dll';
function IcmpSendEcho (IcmpHandle : THandle; DestinationAddress : IPAddr;
    RequestData : Pointer; RequestSize : Smallint;
    RequestOptions : pointer;
    ReplyBuffer : Pointer;
    ReplySize : DWORD;
    Timeout : DWORD) : DWORD; stdcall; external 'icmp.dll';


function Ping(InetAddress : Ansistring) : boolean;

procedure TranslateStringToTInAddr(AIP: Ansistring; var AInAddr);
function TInAddrToString(var AInAddr): string;
function GetToken( var str1: Ansistring; SepChar: Ansistring ): AnsiString;
function LRTrim_bnk( const s: Ansistring ): AnsiString;
function replaceString(str,s1,s2:string;casesensitive:boolean):string;
function StrToFloatDef(const s:string;def:Extended):Extended;

implementation

uses
  WinSock;

function Fetch(var AInput: string; const ADelim: string = ' '; const ADelete: Boolean = true)
 : string;
var
  iPos: Integer;
begin
  if ADelim = #0 then begin
    // AnsiPos does not work with #0
    iPos := Pos(ADelim, AInput);
  end else begin
    iPos := Pos(ADelim, AInput);
  end;
  if iPos = 0 then begin
    Result := AInput;
    if ADelete then begin
      AInput := '';
    end;
  end else begin
    result := Copy(AInput, 1, iPos - 1);
    if ADelete then begin
      Delete(AInput, 1, iPos + Length(ADelim) - 1);
    end;
  end;
end;

procedure TranslateStringToTInAddr(AIP: Ansistring; var AInAddr);
var
  phe: PHostEnt;
  pac: PAnsiChar;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  try
    phe := GetHostByName(PAnsiChar(AIP));
    if Assigned(phe) then
    begin
      pac := phe^.h_addr_list^;
      if Assigned(pac) then
      begin
        with TIPAddr(AInAddr).S_un_b do begin
          s_b1 := Byte(pac[0]);
          s_b2 := Byte(pac[1]);
          s_b3 := Byte(pac[2]);
          s_b4 := Byte(pac[3]);
        end;
      end
      else
      begin
        raise Exception.Create('Error getting IP from HostName');
      end;
    end
    else
    begin
      raise Exception.Create('Error getting HostName');
    end;
  except
    FillChar(AInAddr, SizeOf(AInAddr), #0);
  end;
  WSACleanup;
end;

function TInAddrToString(var AInAddr): string;
begin
  with TIPAddr(AInAddr).S_un_b do begin
    result := IntToStr(s_b1) + '.' + IntToStr(s_b2) + '.' + IntToStr(s_b3) + '.'    {Do not Localize}
     + IntToStr(s_b4);
  end;
end;

function Ping(InetAddress : Ansistring) : boolean;
var
 Handle : THandle;
 InAddr : IPAddr;
 DW : DWORD;
 rep : array[1..128] of byte;
begin
  result := false;
  Handle := IcmpCreateFile;
  if Handle = INVALID_HANDLE_VALUE then
   Exit;
  TranslateStringToTInAddr(InetAddress, InAddr);
  DW := IcmpSendEcho(Handle, InAddr, nil, 0, nil, @rep, 128, 0);
  Result := (DW <> 0);
  IcmpCloseHandle(Handle);
end;

//�и� ���ڸ� �������� ��ū�� ��ȯ�Ѵ�. ���� �ҽ��� ������
//�¿� ������ �����ش�.
function GetToken( var str1: Ansistring; SepChar: Ansistring ): AnsiString;
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

//String�� �����ʰ� ���ʿ� �پ��ִ� ������ ������ �ִ� �Լ��̴�
function LRTrim_bnk( const s: Ansistring ): AnsiString;
var i: word;
    str1: Ansistring;
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

{converts S into a number. If S is invalid, returns the number passed in Def.}
{example: strtofloatdef('$10.25',0) = 0}
function StrToFloatDef(const s:string;def:Extended):Extended;
begin
  try
    result:=strtofloat(s);
  except
    result:=def;
  end;
end;

end.
