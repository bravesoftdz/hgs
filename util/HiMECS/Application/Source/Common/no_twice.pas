unit no_twice;

interface

uses  wintypes,SysUtils, Classes;

function DoIExist(lpszName,lpszClassName,lpszTitle: LPSTR):Bool;

implementation

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
