unit TCPServer_Util;

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


function Ping(InetAddress : string) : boolean;
function Ping2(AIPAddr : IPAddr) : boolean;

procedure TranslateStringToTInAddr(AIP: string; var AInAddr);
function TInAddrToString(var AInAddr): string;
function GetToken( var str1: string; SepChar: string ): String;
function LRTrim_bnk( const s: string ): String;
function replaceString(str,s1,s2:string;casesensitive:boolean):string;
function StrToFloatDef(const s:string;def:Extended):Extended;
function DoIExist(lpszName,lpszClassName,lpszTitle: LPSTR):Bool;

implementation

uses WinSock;

procedure TranslateStringToTInAddr(AIP: string; var AInAddr);
var
  phe: PHostEnt;
  pac: PChar;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  try
    phe := GetHostByName(PChar(AIP));
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

function Ping(InetAddress : string) : boolean;
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

function Ping2(AIPAddr : IPAddr) : boolean;
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
  DW := IcmpSendEcho(Handle, AIPAddr, nil, 0, nil, @rep, 128, 0);
  Result := (DW <> 0);
  IcmpCloseHandle(Handle);
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

// �������� �̸� = lpszName, ������ �̸� =  TApplication,������ �μ�=lpszTitle
//�̹� ���� ���̸� True�� ��ȯ�Ѵ�.
//ex) DoIExist('hhwang_semaphore','TApplication',PChar(Application.Title))
function DoIExist(lpszName,lpszClassName,lpszTitle: LPSTR):Bool;
var
    hSem: THANDLE;
    hWndMy: HWND;
begin

    hSem := CreateSemaphore(nil, 0, 1, lpszName);
    // ��ȣ�Ӽ� = NULL, �ʱ� ī��Ʈ = 0, �ִ� ī��Ʈ = 1,
    // �������� �̸� = lpszName

    if (hSem <> 0) and (GetLastError() = ERROR_ALREADY_EXISTS) then
    begin
        // �̹� �������  ������� �ִ� ��쿡 �����츦 ã�Ƽ�
        // ���α׷��� ��ȯ�Ѵ�.

        CloseHandle(hSem);

        if lpszClassName = '' then
          lpszClassName := 'TApplication';

        hWndMy := FindWindow(lpszClassName, lpszTitle);
        if hWndMy <> 0 then
        begin
          BringWindowToTop(hWndMy);
          ShowWindow(hWndMy,SW_SHOWNORMAL);
        end;
            //SetForegroundWindow(hWndMy);
        DoIExist := TRUE;
        exit;
    end;
    // ù��°�� ������� ���� ����.
    DoIExist :=  FALSE;
end;

end.
