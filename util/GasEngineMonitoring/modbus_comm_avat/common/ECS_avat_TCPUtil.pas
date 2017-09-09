unit ECS_avat_TCPUtil;

interface

uses Winsock, SysUtils, Classes, IPCThrd_ECS_avat;

const DeviceName = 'ECS_avat';

type
  TCommBlock = record   // the Communication Block used in both parts (Server+Client)
                 Command,
                 MyUserName,                 // the sender of the message
                 Msg,                        // the message itself
                 ReceiverName: string[100];  // name of receiver
               end;

function GetLocalIP : string;
function GetLocalIPs : TStrings;
function ReadComBlockFromStream(AStream:TStream):TCommBlock;
procedure WriteComBlock2Stream(ACommBlock: TCommBlock; AStream:TStream);
function ReadEventDataFromStream(AStream:TStream):TEventData_ECS_avat;
procedure WriteEventData2Stream(AEventData: TEventData_ECS_avat; AStream:TStream);

implementation

function GetLocalIP : string;
type
    TaPInAddr = array [0..10] of PInAddr;
    PaPInAddr = ^TaPInAddr;
var
    phe  : PHostEnt;
    pptr : PaPInAddr;
    Buffer : array [0..63] of Ansichar;
    I    : Integer;
    GInitData      : TWSADATA;

begin
  // WSAStartup�� ���� ���α׷��� �������� �Ұ��� �̿��� �� ���ʷ� ȣ���Ͽ�
  // �ٸ� ���� �Լ��� ����� �� �ֵ��� �ʱ�ȭ �Ѵ�.(�������� WSACleanup���)
  // �� �Լ��� ���� ���α׷��� �ʿ��� �������� ���� API�� ������ �˷��ְ�,
  // ���� ������ ���� ������ �����Ѵ�.
    WSAStartup($101, GInitData);
    Result := '';
    GetHostName(@Buffer[0], SizeOf(Buffer));
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

function ReadComBlockFromStream(AStream:TStream):TCommBlock;
begin
  FillChar(Result, Sizeof(Result),0);
  AStream.Position := 0;
  AStream.Read(Result, Sizeof(Result));
end;

procedure WriteComBlock2Stream(ACommBlock: TCommBlock; AStream:TStream);
begin
  AStream.Position := 0;
  AStream.Write(ACommBlock, Sizeof(ACommBlock));
  AStream.Position := 0;
end;

function ReadEventDataFromStream(AStream: TStream): TEventData_ECS_avat;
begin
  FillChar(Result, Sizeof(Result),0);
  AStream.Position := 0;
  AStream.Read(Result, Sizeof(Result));
end;

procedure WriteEventData2Stream(AEventData: TEventData_ECS_avat; AStream:TStream);
begin
  AStream.Position := 0;
  AStream.Write(AEventData, Sizeof(AEventData));
  AStream.Position := 0;
end;

function GetLocalIPs : TStrings;
type
    TaPInAddr = array [0..10] of PInAddr;
    PaPInAddr = ^TaPInAddr;
var
    phe  : PHostEnt;
    pptr : PaPInAddr;
    Buffer : array [0..63] of Ansichar;
    I    : Integer;
    GInitData      : TWSADATA;

begin
  Result := TStringList.Create;
  // WSAStartup�� ���� ���α׷��� �������� �Ұ��� �̿��� �� ���ʷ� ȣ���Ͽ�
  // �ٸ� ���� �Լ��� ����� �� �ֵ��� �ʱ�ȭ �Ѵ�.(�������� WSACleanup���)
  // �� �Լ��� ���� ���α׷��� �ʿ��� �������� ���� API�� ������ �˷��ְ�,
  // ���� ������ ���� ������ �����Ѵ�.
    WSAStartup($101, GInitData);
    GetHostName(@Buffer[0], SizeOf(Buffer));
    phe :=GetHostByName(buffer);
    if phe = nil then Exit;
    pptr := PaPInAddr(Phe^.h_addr_list);
    I := 0;
    while pptr^[I] <> nil do begin
      result.Add( StrPas(inet_ntoa(pptr^[I]^)) );
      Inc(I);
    end;
    WSACleanup;
end;

end.
 