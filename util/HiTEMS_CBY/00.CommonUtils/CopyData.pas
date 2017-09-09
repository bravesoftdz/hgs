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

  procedure SendCopyData(FromFormName, ToFormName, Msg: string; SrcHandle: integer);

var
  FormName: string;   //�޼����� ������ �� �̸�
  msgHandle: THandle; //�޼����� ���� �� �ڵ�

implementation

//�޼��� ���÷��̿� �ʿ��� �� �̸��� �ڵ��� �Ҵ��Ѵ�.
//�� Unit�� ����ϴ� Unit�ּ� �ѹ��� �� �����ؾ� ��
//FormName: �޼����� ���� Form Name
//msgHandle: �޼����� ������ ���� Form Handle(��� 0�� ��)
procedure DAOutStruct_UnitInit(_FormName: string; _msgHandle: THandle);
begin
  FormName := _FormName;
  msgHandle := _msgHandle;
end;

//FromFormName: �޼����� ������ ���� �̸�, �ΰ� ����
//ToFormName: �޼����� �޴� ���� �̸�, �ΰ� �Ұ�
//Msg: �������� �ϴ� �޼���
//SrcHandle:�޼����� ������ ���� �ڵ�,Form1.Handle
procedure SendCopyData(FromFormName, ToFormName, Msg: string; SrcHandle: integer);
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
      StrPCopy(StrMsg,Msg);
      StrPCopy(StrSrcFormName,FromFormName);
      iHandle := SrcHandle;
      dwData := 3232;
      cbData := sizeof(rec);
      lpData := @rec;
    end;//with

    SendMessage(h, WM_COPYDATA, SrcHandle, LongInt(@cd));
  end;//if
end;

end.
