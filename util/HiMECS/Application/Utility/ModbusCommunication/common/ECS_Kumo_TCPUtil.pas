unit ECS_Kumo_TCPUtil;

interface

uses Winsock, SysUtils, Classes, IPCThrd_ECS_kumo;

const DeviceName = 'ECS_Kumo';

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
function ReadEventDataFromStream(AStream:TStream):TEventData_ECS_Kumo;
procedure WriteEventData2Stream(AEventData: TEventData_ECS_Kumo; AStream:TStream);

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
  // WSAStartup은 응용 프로그램이 원도우즈 소겟을 이용할 때 최초로 호출하여
  // 다른 소켓 함수를 사용할 수 있도록 초기화 한다.(마무리는 WSACleanup사용)
  // 이 함수는 응용 프로그램에 필요한 원도우즈 소켓 API의 버전을 알려주고,
  // 소켓 내부의 구현 사항을 리턴한다.
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

function ReadEventDataFromStream(AStream: TStream): TEventData_ECS_Kumo;
begin
  FillChar(Result, Sizeof(Result),0);
  AStream.Position := 0;
  AStream.Read(Result, Sizeof(Result));
end;

procedure WriteEventData2Stream(AEventData: TEventData_ECS_Kumo; AStream:TStream);
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
  // WSAStartup은 응용 프로그램이 원도우즈 소겟을 이용할 때 최초로 호출하여
  // 다른 소켓 함수를 사용할 수 있도록 초기화 한다.(마무리는 WSACleanup사용)
  // 이 함수는 응용 프로그램에 필요한 원도우즈 소켓 API의 버전을 알려주고,
  // 소켓 내부의 구현 사항을 리턴한다.
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
 