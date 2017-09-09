unit RunOne_WT1600;
(* ���ǻ���
 �Ʒ� ������ ������ ���� �־�� ��.
  Author = 'Silhwan Hyun';  // ���ڸ� : ���࿩�θ� �˻��ϱ� ���� �˻�� ������.
  RunProgram = 'TClock';    // ���α׷��� :             "

  -2011.11.21
  1) GetWindowClass �Լ��� ����� �۵����� �ʾƼ�ClassName ������ Local���� Global�� ��ȯ �� �� ���� �۵� ��.

  -2011.11.29
  1) RunProgram�� ������ ������(Projece Source���� ���������� �ϱ� ����)
*)
interface

uses WinTypes, SysUtils, Forms;

Const
  Author = 'JH Park';  // ���ڸ� : ���࿩�θ� �˻��ϱ� ���� �˻�� ������.
  ProgramCommon = 'WT1600';

var
  RunProgram : array[0..63] of Char;

  procedure DoIExist_Enter;
  procedure DoIExist_Leave;

implementation

var
  AtomText: array[0..63] of Char;
  AtomSaved : boolean = false;

  MyClassName    : array[0..255] of Char;
  ClassName : array[0..255] of Char;
  FoundPrevInst  : boolean = false;
  PrevInstHandle : HWnd = 0;
  FoundAtom      : TAtom;

  NewAtom : TAtom;
  MyPopup : HWnd;

function LookAtAllWindows(Handle: HWnd; Temp: Longint): BOOL; stdcall;
//var
//  ClassName : array[0..255] of Char;
begin
  ClassName := '';
  LookAtAllWindows := true;

  if GetClassName(Handle, ClassName, SizeOf(ClassName)) > 0 then
  begin
    if ClassName = MyClassName then // ���� window class ?
    begin
    // �ߺ����࿩�θ� �����ϱ� ���� �˻��� ����
      StrPCopy(AtomText, Author + RunProgram + IntToStr(Handle));
    // �˻�� Global Atom Table�� ��ϵǾ� �ִ��� Ȯ��
       FoundAtom := GlobalFindAtom(AtomText);
       if FoundAtom <> 0 then  // Global Atom Table�� ��ϵǾ� ������
       begin
          FoundPrevInst  := true;    // �̹� ���� ���� ������ ǥ��
          PrevInstHandle := Handle;  // ���� ���� ���ø����̼� ������ �ڵ�
          LookAtAllWindows := false; // enumeration �Լ��� �����Ų��
       end;
    end;

  end;
end;

procedure DoIExist_Enter;
begin
 // ���α׷��� Ŭ�������� �˾Ƴ���.
  GetClassName(Application.Handle, MyClassName, SizeOf(MyClassName));
 // �����츦 �˻��Ͽ� �ߺ������� �ƴ��� Ȯ���Ѵ�
  EnumWindows(@LookAtAllWindows, 0);
  if FoundPrevInst then   // �̹� ���� ���̸�
  begin
     MyPopup := GetLastActivePopup(PrevInstHandle);
     BringWindowToTop(PrevInstHandle);
     if IsIconic(MyPopup) then
     begin
        ShowWindow(MyPopup, SW_RESTORE);  // �ּ�ȭ �����̸� ���� ũ���
     end else
        BringWindowToTop(MyPopup);        // �ֻ��� �������

     SetForegroundWindow(MyPopup);

     Halt(0);  // ���� ������ ���α׷��� ������ �����Ų��
  end else
  begin
   // �������� �ƴϸ� �˻�� Global Atom Table�� ����Ѵ�
     StrPCopy(AtomText, Author + RunProgram + IntToStr(Application.Handle));
     NewAtom := GlobalAddAtom(AtomText);
     if NewAtom <> 0 then   // Global Atom Table�� ��ϼ����̸�
     begin
        AtomSaved := true;
     end;
  end;
end;

procedure DoIExist_Leave;
begin
  // ���α׷� ����ô� Global Atom Table�� ����� �� �˻�� �����Ѵ�.
  if AtomSaved then
  begin
     FoundAtom := GlobalFindAtom(AtomText);
     if FoundAtom <> 0 then
        GlobalDeleteAtom(FoundAtom);
  end;
end;

end.
