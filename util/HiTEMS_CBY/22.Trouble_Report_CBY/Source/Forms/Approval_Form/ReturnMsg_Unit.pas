unit ReturnMsg_Unit;

interface

uses
  Trouble_Unit, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, NxCollection;

type
  TReturnMsg_Frm = class(TForm)
    NxHeaderPanel1: TNxHeaderPanel;
    Panel1: TPanel;
    Button2: TButton;
    Panel3: TPanel;
    Panel2: TPanel;
    RichEdit1: TRichEdit;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FFirst : Boolean;
  public
    { Public declarations }
    FOwner : TTrouble_Frm;
    FMode : integer;
  end;

var
  ReturnMsg_Frm: TReturnMsg_Frm;

implementation

{$R *.dfm}

procedure TReturnMsg_Frm.Button2Click(Sender: TObject);
begin
  try
    if FMode = 0 then //�ݷ� ó���� �ݷ� ���� �Է�
    begin
      if RichEdit1.Lines.Count > 0 then
      begin
        If MessageDlg('�ۼ��� �ݷ������� �ֽ��ϴ�.'+#13+'�ݷ�ó�� �Ͻðڽ��ϱ�?.', mtConfirmation, [mbYes, mbNo], 0) = mrYes Then
          FOwner.FReturnContent := RichEdit1.Text
        else
          Exit;

      end;
    end;
  finally
    Close;
  end;
end;

procedure TReturnMsg_Frm.FormActivate(Sender: TObject);
begin
  if FFirst = True then
  begin
    FFirst := False;

    if FMODE = 0 then
      ShowMessage('�ݷ� ������ ������ �ݷ� ������ ��� �˴ϴ�.');

    case FMode of
      0 : RichEdit1.ReadOnly := False;
      1 : RichEdit1.ReadOnly := True;
    end;
  end;
end;

procedure TReturnMsg_Frm.FormCreate(Sender: TObject);
begin
  FFirst := True;

end;

end.
