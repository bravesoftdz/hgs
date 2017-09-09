unit RpInfo_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NxEdit, StdCtrls, ImgList, ExtCtrls, UnitTestReport, Buttons;

type
  TRpInfo_Frm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    TestNm: TNxComboBox;
    Testm: TNxComboBox;
    Label3: TLabel;
    testcnt: TNxNumberEdit;
    Label4: TLabel;
    startnum: TNxNumberEdit;
    Panel1: TPanel;
    Label5: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FOwner : TFormTestReport;
    FRpCnt : integer;
    procedure Set_Report_Info_to_main;
  end;

var
  RpInfo_Frm: TRpInfo_Frm;

implementation

{$R *.dfm}

{ TRpInfo_Frm }

procedure TRpInfo_Frm.Button1Click(Sender: TObject);
begin
  Set_Report_Info_to_main;
end;

procedure TRpInfo_Frm.Set_Report_Info_to_main;
begin
  if TestNm.Text = '' then
  begin
    ShowMessage('���� ������ �����ϴ�.');
    Exit;
  end;

  if Testm.Text = '' then
  begin
    ShowMessage('����ڸ� �����Ͽ� �ֽʽÿ�.');
    Exit;
  end;

  if startnum.Value = 0 then
  begin
    ShowMessage('���� ���� ��ȣ�� "0"�̻� �Ǿ�� �մϴ�.');
    Exit;
  end;

  with FOwner do
  begin
    FReportTitle    := TestNm.Text;
    FPersonInCharge := Testm.Text;
    FTestStartNum   := StrToInt(StartNum.Text);
  end;
  Close;
end;

end.
