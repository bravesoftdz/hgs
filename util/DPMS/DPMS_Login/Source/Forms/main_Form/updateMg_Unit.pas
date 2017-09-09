unit updateMg_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvComponentBase, JvThread,
  JvThreadDialog, JvExControls, JvAnimatedImage, JvGIFCtrl, Vcl.StdCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdFTP, AdvProgressBar, Data.DB, MemDS,
  DBAccess, Ora, Vcl.ExtCtrls;

type
  TupdateThread = class(TThread)
    procedure Execute; Override;

  end;
  TupdateMg_Frm = class(TForm)
    JvGIFAnimator1: TJvGIFAnimator;
    Panel1: TPanel;
    Check: TLabel;
    AdvProgressBar1: TAdvProgressBar;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FFirst : Boolean;
  public
    { Public declarations }
  end;

var
  updateMg_Frm: TupdateMg_Frm;
  updateThread : TupdateThread;
  FsysCode : String;
  FStart : Boolean;

  procedure updateProc;


implementation
uses
  HiTEMS_CONST,
  CommonUtil_Unit,
  DataModule_Unit;
procedure updateProc;
begin
  updateMg_Frm := TupdateMg_Frm.Create(nil);
  updateMg_Frm.Show;

  updateThread := TupdateThread.Create(True);
  updateThread.Priority := tpLower;
  updateThread.Resume;
  updateThread.WaitFor;
  updateMg_Frm.Timer1.Enabled := True;
end;

procedure TupdateThread.Execute;
var
  lPath : String;
  li: Integer;
  lupdateMg_Frm : TupdateMg_Frm;

  DBVer,
  LCVer : TDateTime;

  lms : TMemoryStream;
  lFileName : String;

begin
  lPath := 'C:\Temp\'+FsysCode+'.exe';
  lFileName := FsysCode+'.exe';

  if Assigned(updateMg_Frm) then
  begin
    with updateMg_Frm do
    begin
      check.Caption := '�ý��� ����...';
      check.Refresh;
      AdvProgressbar1.Position := 0;
      sleep(200);

      check.Caption := '���μ��� Ȯ��...';
      check.Refresh;
      AdvProgressbar1.Position := 15;
      sleep(100);

      if isOpen(lFileName) > 0 then
        KillTask(lFileName);

      check.Caption := '�ý��� ���� �˻�...';
      check.Refresh;
      AdvProgressbar1.Position := 25;
      with DM1.OraQuery1 do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select SYSCODE, SYSNO, LASTWRITETIME from HITEMS_SYS_VERSION ' +
                'where SYSCODE = '+FSysCode+
                ' order by SYSNO Desc');
        Open;
        if not(RecordCount = 0) then
        begin
          DBVer := FieldByName('LASTWRITETIME').AsDateTime;
        end
        else
        begin
          JvGIFAnimator1.Animate := False;
          raise Exception.Create('��ϵ� �ý����� �����ϴ�!');
          Timer1.Enabled := True;
        end;

        check.Caption := '�ý��� ���� �˻� �Ϸ�...';
        check.Refresh;
        AdvProgressbar1.Position := 35;


        if FileExists(lPath) then
        begin
          LCVer := GetFileLastWriteTime(lPath);
          if DBVer > LCVer then
          begin
            check.Caption := '�� �����߰�...';
            check.Refresh;
            AdvProgressbar1.Position := 40;
            sleep(100);

            with DM1.OraQuery1 do
            begin
              Close;
              SQL.Clear;
              SQL.Add('select Files from HITEMS_SYS_VERSION ' +
                      'where SYSCODE = '+FSysCode+
                      ' order by SYSNO Desc');
              Open;

              if not(RecordCount = 0) then
              begin
                if FieldByName('FILES').IsBlob then
                begin
                  lms := TMemoryStream.Create;
                  try
                    check.Caption := '�� ���� �ٿ�ε�...';
                    check.Refresh;
                    AdvProgressbar1.Position := 50;
                    sleep(100);

                    (FieldByName('FILES') as TBlobField).SaveToStream(LMS);
                    lms.SaveToFile(lPath);

                    check.Caption := '�ٿ�ε� �Ϸ�...';
                    check.Refresh;
                    AdvProgressbar1.Position := 60;
                    sleep(300);
                  finally
                    FreeAndNil(lms);
                  end;
                end;
              end;
            end;
          end;
        end
        else
        begin
          //������ ������� �ڵ�����
          check.Caption := '�� �ý������ϻ���...';
          check.Refresh;
          AdvProgressbar1.Position := 40;
          sleep(100);


          with DM1.OraQuery1 do
          begin
            Close;
            SQL.Clear;
            SQL.Add('select Files from HITEMS_SYS_VERSION ' +
                    'where SYSCODE = '+FSysCode+
                    ' order by SYSNO Desc');
            Open;

            if not(RecordCount = 0) then
            begin
              if FieldByName('FILES').IsBlob then
              begin
                lms := TMemoryStream.Create;
                try
                  (FieldByName('FILES') as TBlobField).SaveToStream(LMS);
                  lms.SaveToFile(lPath);

                  check.Caption := '�ý��� ���� ���� �Ϸ�...';
                  check.Refresh;
                  AdvProgressbar1.Position := 50;
                  sleep(300);
                finally
                  FreeAndNil(lms);
                end;
              end;
            end;
          end;
        end;
        //���Ͻ���

        check.Caption := '���μ��� �ʱ�ȭ...';
        check.Refresh;
        AdvProgressbar1.Position := 60;
        sleep(200);
        AdvProgressbar1.Position := 65;
        sleep(250);
        AdvProgressbar1.Position := 75;
        sleep(200);
        AdvProgressbar1.Position := 80;
        sleep(400);
        AdvProgressbar1.Position := 90;
        sleep(300);
        AdvProgressbar1.Position := 95;

        check.Caption := '�ý��۽���...';
        check.Refresh;
        AdvProgressbar1.Position := 100;
        sleep(300);
        JvGIFAnimator1.Animate := False;
        ExecNewProcess2(LPath+ ' ' + CurrentUserId);
      end;
    end;
  end;
end;
{$R *.dfm}

{ TForm1 }


procedure TupdateMg_Frm.Timer1Timer(Sender: TObject);
const
  FADE_IN_SPEED = 3;
  FADE_OUT_SPEED = 5;
var
  newBlendValue : integer;
begin
  if AlphaBlendValue > 0 then
  begin
    newBlendValue := -1 * FADE_OUT_SPEED + AlphaBlendValue;
    if newBlendValue >  0 then
      AlphaBlendValue := newBlendValue
    else
      AlphaBlendValue := 0;
  end
  else
  begin
    Timer1.Enabled := false;

    if Assigned(updateMg_Frm) then
      FreeAndNil(updateMg_Frm);

    Close;
  end;
end;

end.
