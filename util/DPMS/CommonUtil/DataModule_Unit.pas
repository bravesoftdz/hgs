unit DataModule_Unit;

interface

uses
  System.SysUtils, System.Classes, Data.DB, MemDS, DBAccess, Ora, OraTransaction,
  OraCall, IdGlobal, IdHash, IdHashMessageDigest, Vcl.StdCtrls;

type
  TDM1 = class(TDataModule)
    OraTransaction1: TOraTransaction;
    OraSession1: TOraSession;
    OraQuery1: TOraQuery;
  private
    { Private declarations }
  public
    function CheckPassWord(APasswd, AHashedPasswd: string): Boolean;
    procedure FillInDeptCombo(AComboBox: TComboBox);
  end;

var
  DM1: TDM1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TDM1 }

//APassed: ����ڷ� ���� �Է� ���� Password��(Hash ó�� �ȵ�)
//AHashedPasswd: DB�� ����� Password��(Hash ó�� ��)
function TDM1.CheckPassWord(APasswd, AHashedPasswd: string): Boolean;
var
  LStr: string;
begin
  LStr := '';

  with TIdHashMessageDigest5.Create do
  try
    LStr := HashStringAsHex(APasswd);
  finally
    Free;
  end;

  Result := SameText(LStr, AHashedPasswd);
end;

procedure TDM1.FillInDeptCombo(AComboBox: TComboBox);
var
  i: integer;
begin
  with OraQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select DEPT, DEPTNM from kx01.gtaa004 ' +
            'where DEPTNM IS NOT NULL AND DIVISION = ''K'' AND GUBUN = ''Z01'' ' +
//            'where DEPTNM IS NOT NULL AND DEPT like ''K%'' ' +
            'GROUP BY DEPT, DEPTNM ');
    Open;

    if RecordCount > 0 then
    begin
      AComboBox.Items.BeginUpdate;
      try
        AComboBox.Items.Clear;

        AComboBox.Items.Add('');
        AComboBox.Items.Add('�ӿ�');

        while not eof do
        begin
          AComboBox.Items.Add(FieldByName('DEPTNM').AsString);
          Next;
        end;
      finally
        AComboBox.Items.EndUpdate;
      end;
    end;
  end;
end;

end.
