unit RunOne;
(* ���ǻ���
 .dpr ������ uses���� RunOne�� ���� ����(�̰� �߿���) ������ ��
 �Ʒ� ������ ������ ���� �־�� ��.
  Author = 'Silhwan Hyun';  // ���ڸ� : ���࿩�θ� �˻��ϱ� ���� �˻�� ������.
  RunProgram = 'TClock';    // ���α׷��� :             "

*)
interface

uses WinTypes, SysUtils, Forms;

function DoIExist2: Bool;

var
  Author: string = 'HiTEMS_Start';      // ���ڸ� : ���࿩�θ� �˻��ϱ� ���� �˻�� ������.
  RunProgram: string = 'HiTEMS_Start'; // ���α׷��� :             "

implementation

var
  AtomText: array[0..63] of Char;
  AtomSaved : boolean = false;

  MyClassName    : array[0..255] of Char;
  FoundPrevInst  : boolean = false;
  PrevInstHandle : HWnd = 0;
  FoundAtom      : TAtom;

  NewAtom : TAtom;
  MyPopup : HWnd;

function LookAtAllWindows(Handle: HWnd; Temp: Longint): BOOL; stdcall;
var
  ClassName : array[0..255] of Char;
begin
  LookAtAllWindows := true;

  if GetClassName(Handle, ClassName, SizeOf(ClassName)) > 0 then
  begin
    if StrComp(ClassName, MyClassName) = 0 then // ���� window class ?
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

function DoIExist2: Bool;
begin
 // ���α׷��� Ŭ�������� �˾Ƴ���.
  GetClassName(Application.Handle, MyClassName, SizeOf(MyClassName));
 // �����츦 �˻��Ͽ� �ߺ������� �ƴ��� Ȯ���Ѵ�
  EnumWindows(@LookAtAllWindows, 0);
  if FoundPrevInst then   // �̹� ���� ���̸�
  begin
    Result := True;
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
    Result := False;
   // �������� �ƴϸ� �˻�� Global Atom Table�� ����Ѵ�
     StrPCopy(AtomText, Author + RunProgram + IntToStr(Application.Handle));
     NewAtom := GlobalAddAtom(AtomText);
     if NewAtom <> 0 then   // Global Atom Table�� ��ϼ����̸�
        AtomSaved := true;
  end;
end;

initialization
  DoIExist2;
  
finalization
  // ���α׷� ����ô� Global Atom Table�� ����� �� �˻�� �����Ѵ�.
  if AtomSaved then
  begin
     FoundAtom := GlobalFindAtom(AtomText);
     if FoundAtom <> 0 then
        GlobalDeleteAtom(FoundAtom);
  end;

end.
 