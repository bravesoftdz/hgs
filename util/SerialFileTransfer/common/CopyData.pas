unit CopyData;

interface

uses Windows, Messages, SysUtils;

type
  PCopyDataStruct = ^TCopyDataStruct;
  TCopyDataStruct = record
    dwData: LongInt;
    cbData: LongInt;
    lpData: Pointer;
  end;

type
  PRecToPass = ^TRecToPass;
  TRecToPass = record
    StrMsg : array[0..255] of char;
    StrSrcFormName : array[0..255] of char;
    iHandle : integer;
  end;

  procedure SendCopyData(FromFormName, ToFormName, Msg: string; MsgType: integer);
  procedure SendCopyData2(ToHandle: integer; Msg: string; MsgType: integer);

var
  FormName: string;   //�޼����� ������ �� �̸�
  msgHandle: THandle; //�޼����� ���� �� �ڵ�

implementation

//�޼��� ���÷��̿� �ʿ��� �� �̸��� �ڵ��� �Ҵ��Ѵ�.
//�� Unit�� ����ϴ� Unit�ּ� �ѹ��� �� �����ؾ� ��
//FormName: �޼����� ���� Form Name
//msgHandle: �޼����� ������ ���� Form Handle(��� 0�� ��)
procedure UnitInit(_FormName: string; _msgHandle: THandle);
begin
  FormName := _FormName;
  msgHandle := _msgHandle;
end;

//FromFormName: �޼����� ������ ���� �̸�, �ΰ� ����
//ToFormName: �޼����� �޴� ���� �̸�, �ΰ� �Ұ�
//Msg: �������� �ϴ� �޼���
//SrcHandle:�޼����� ������ ���� �ڵ�,Form1.Handle
procedure SendCopyData(FromFormName, ToFormName, Msg: string; MsgType: integer);
var
  h : THandle;
  fname:array[0..255] of char;
  pfName: PChar;
  cd : TCopyDataStruct;
  rec : TRecToPass;
begin
  if ToFormName = '' then
    exit;
  pfName := @fname[0];
  StrPCopy(pfName,ToFormName);
  h := FindWindow(nil, pfName);
  if h <> 0 then
  begin
    with rec, cd do
    begin
      if Msg <> '' then
        StrPCopy(StrMsg,Msg);

      if FromFormName <> '' then
        StrPCopy(StrSrcFormName,FromFormName);

      iHandle := MsgType;
      dwData := 3232;
      cbData := sizeof(rec);
      lpData := @rec;
    end;//with

    SendMessage(h, WM_COPYDATA, 0, LongInt(@cd));
  end;//if
end;

//ToHandle: �޼����� ������ ���� �ڵ�
//Msg: ������ ���ڿ�
//iMag: ������ ����
procedure SendCopyData2(ToHandle: integer; Msg: string; MsgType: integer);
var
  cd : TCopyDataStruct;
  rec : TRecToPass;
begin
    with rec, cd do
    begin
      if Msg <> '' then
        StrPCopy(StrMsg,Msg);

      iHandle := MsgType;

      dwData := 3232;
      cbData := sizeof(rec);
      lpData := @rec;
    end;//with

    SendMessage(ToHandle, WM_COPYDATA, 0, LongInt(@cd));
end;

end.