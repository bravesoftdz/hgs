unit getIp;

interface

uses Classes, SysUtils, WinSock;

function GetLocalIP(AIndex: integer; AStrings: TStrings=nil) : string;
function GetLocalIPList : TStrings;

implementation

function RemoveNonIp(AString: string): string;
var
 I: Integer;
begin
 Result := '';
 for I := 1 to Length(AString) do
   if (AString[I] in ['0'..'9','.']) then
     Result := Result + AString[I];
end;

// returns ISP assigned IP
//AIndex = -1 �̸� ��� ����� IP�� AStrings�� ��ȯ��
//AIndex = 0 �̸� ù��° ����� IP�� ��ȯ��
function GetLocalIP(AIndex: integer; AStrings: TStrings=nil) : string;
type
    TaPInAddr = array [0..10] of PInAddr;
    PaPInAddr = ^TaPInAddr;
var
    phe  : PHostEnt;
    pptr : PaPInAddr;
    Buffer : array [0..63] of PAnsichar;
    I    : Integer;
    GInitData      : TWSADATA;
begin
  // WSAStartup�� ���� ���α׷��� �������� �Ұ��� �̿��� �� ���ʷ� ȣ���Ͽ�
  // �ٸ� ���� �Լ��� ����� �� �ֵ��� �ʱ�ȭ �Ѵ�.(�������� WSACleanup���)
  // �� �Լ��� ���� ���α׷��� �ʿ��� �������� ���� API�� ������ �˷��ְ�,
  // ���� ������ ���� ������ �����Ѵ�.
    WSAStartup($101, GInitData);
    Result := '';
    GetHostName(@Buffer, SizeOf(Buffer));
    phe :=GetHostByName(@buffer);
    if phe = nil then Exit;
    pptr := PaPInAddr(Phe^.h_addr_list);
    I := 0;

    while pptr^[I] <> nil do
    begin
      result:=StrPas(inet_ntoa(pptr^[I]^));

      if AIndex = -1 then
      begin
        AStrings.Add(Result);
      end;

      if (AIndex = I) then
        exit;

      Inc(I);
    end;
    WSACleanup;
end;

//IP List�� ��ȯ��
//
function GetLocalIPList : TStrings;
begin
  Result := TStringList.Create;
  GetLocalIP(-1, Result);
end;

end.


