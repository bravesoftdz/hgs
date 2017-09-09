unit MT210_TCPUtil;

interface

uses Winsock, SysUtils;

const DeviceName = 'MT210';

type
  TCommBlock = record   // the Communication Block used in both parts (Server+Client)
                 Command,
                 MyUserName,                 // the sender of the message
                 Msg,                        // the message itself
                 ReceiverName: string[100];  // name of receiver
               end;

function GetLocalIP : string;

implementation

function GetLocalIP : string;
type
    TaPInAddr = array [0..10] of PInAddr;
    PaPInAddr = ^TaPInAddr;
var
    phe  : PHostEnt;
    pptr : PaPInAddr;
    Buffer : array [0..63] of char;
    I    : Integer;
    GInitData      : TWSADATA;

begin
  // WSAStartup�� ���� ���α׷��� �������� �Ұ��� �̿��� �� ���ʷ� ȣ���Ͽ�
  // �ٸ� ���� �Լ��� ����� �� �ֵ��� �ʱ�ȭ �Ѵ�.(�������� WSACleanup���)
  // �� �Լ��� ���� ���α׷��� �ʿ��� �������� ���� API�� ������ �˷��ְ�,
  // ���� ������ ���� ������ �����Ѵ�.
    WSAStartup($101, GInitData);
    Result := '';
    GetHostName(Buffer, SizeOf(Buffer));
    phe :=GetHostByName(buffer);
    if phe = nil then Exit;
    pptr := PaPInAddr(Phe^.h_addr_list);
    I := 0;
    while pptr^[I] <> nil do begin
      result:=StrPas(inet_ntoa(pptr^[I]^));
      Inc(I);
    end;
    WSACleanup;
end;

end.
 