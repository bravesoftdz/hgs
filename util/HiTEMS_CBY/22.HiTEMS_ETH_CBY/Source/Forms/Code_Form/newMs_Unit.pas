unit newMs_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TnewMs_Frm = class(TForm)
    Panel7: TPanel;
    Button1: TButton;
    Button2: TButton;
    Panel8: TPanel;
    Panel9: TPanel;
    prtMsName: TEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    newMs: TEdit;
    Panel3: TPanel;
    Panel4: TPanel;
    newMsName: TEdit;
    Panel5: TPanel;
    Panel6: TPanel;
    newMsDesc: TEdit;
    prtMs: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure prtMsChange(Sender: TObject);
    procedure newMsChange(Sender: TObject);
  private
    { Private declarations }
    FupdateMs : String;
    FnewLv : Integer;
  public
    { Public declarations }
    function Check_Code_Group(aGrpName : String;var aMsg:String) : Boolean;
    procedure Add_New_Code_Group;
    procedure Update_Ms_Info;
  end;

var
  newMs_Frm: TnewMs_Frm;
  function Create_new_Ms(aPrtMs:String;aNewLv:Integer) : Boolean;
  function Create_update_Ms(aMsNo:String) : Boolean;

implementation
uses
  HiTEMS_ETH_COMMON,
  HiTEMS_ETH_CONST,
  DataModule_Unit;

{$R *.dfm}

{ TaddGrp_Frm }

function Create_new_Ms(aPrtMs:String;aNewLv:Integer) : Boolean;
begin
  newMs_Frm := TnewMS_Frm.Create(Application);
  try
    with newMs_Frm do
    begin
      Caption := '�� MS �߰�';
      Button2.Caption := '�߰�';

      prtMs.Text     := aPrtMs;
      FnewLv         := aNewLv;
      ShowModal;

      if modalResult = mrOk then
      begin
        Result := True;

      end;
    end;
  finally
    FreeAndNil(newMs_Frm);
  end;
end;

function Create_update_Ms(aMsNo:String) : Boolean;
begin
  newMs_Frm := TnewMS_Frm.Create(Application);
  try
    with newMs_Frm do
    begin
      Caption := 'MS ����';
      Button2.Caption := '����';

      FUpdateMs       := aMsNo;
      newMs.Text      := FupdateMs;

      ShowModal;

      if modalResult = mrOk then
      begin
        Result := True;

      end;
    end;
  finally
    FreeAndNil(newMs_Frm);
  end;
end;

procedure TnewMs_Frm.Add_New_Code_Group;
begin
  try
    with DM1.OraQuery1 do
    begin
      Close;
      SQL.Clear;
      SQL.Add('insert into HiMSEN_MS_NUMBER ');
      SQL.Add('values(:MSNO, :PRTMSNO, :MSNAME, :DESCRIPTION, ' +
              ':LV, :REGID, :REGDATE, :MODID, :MODDATE)');

      parambyname('MSNO').AsString          := newMs.Text;
      parambyname('PRTMSNO').AsString       := prtMs.Text;
      parambyname('MSNAME').AsString        := newMsName.Text;
      parambyname('DESCRIPTION').AsString   := newMsDesc.Text;
      parambyname('LV').AsInteger           := FnewLv;
      parambyname('REGID').AsString         := CurrentUsers;
      parambyname('REGDATE').AsDateTime     := Now;
      ExecSQL;
      ShowMessage('�׷��߰� ����!!');
      ModalResult := mrOk;
    end;
  except
    ShowMessage('DB ���� ����!! �ٽ� �õ��Ͽ� �ֽʽÿ�,'+#10#13+
                '������ ���ӵǸ� �����ڿ��� �����Ͻʽÿ�.');

  end;
end;

procedure TnewMs_Frm.Button1Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TnewMs_Frm.Button2Click(Sender: TObject);
var
  lMsg : String;
begin
  if newMs.Text = '' then
  begin
    newMs.SetFocus;
    raise Exception.Create('MS Number(��)�� �ʼ� �Է� �Դϴ�.');
  end;

  if newMsName.Text = '' then
  begin
    newMsName.SetFocus;
    raise Exception.Create('MS Name(��)�� �ʼ� �Է� �Դϴ�.');
  end;

  if Button2.Caption = '�߰�' then
    Add_New_Code_Group
  else
    Update_Ms_Info;

end;


function TnewMs_Frm.Check_Code_Group(aGrpName: String;
  var aMsg: String): Boolean;
begin
  with DM1.OraQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select cdGrpName from HITEMS_CODE_ROOT');
    SQL.Add('where cdGrpName = :param1');
    parambyname('param1').AsString := aGrpName;
    Open;

    if RecordCount > 0 then
    begin
      Result := False;
      aMsg := '���� �׷���� ���� �մϴ�.'+#13#10+'�׷���� ���� �Ͻʽÿ�.';
    end
    else
      Result := True;
  end;
end;

procedure TnewMs_Frm.newMsChange(Sender: TObject);
var
  lprt : String;
begin
  with DM1.OraQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select * from HIMSEN_MS_NUMBER ' +
            'where MSNO = '''+newMs.Text+''' ');
    Open;

    if not(RecordCount = 0) then
    begin
      newMsName.Text := FieldByName('MSNAME').AsString;
      newMsDesc.Text := FieldByName('Description').AsString;
      FnewLv         := FieldByName('LV').AsInteger;
      prtMs.Text     := FieldByName('PRTMSNO').AsString;
    end;
  end;
end;

procedure TnewMs_Frm.prtMsChange(Sender: TObject);
begin
  with DM1.OraQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select MSNAME from HIMSEN_MS_NUMBER ' +
            'where MSNO = '''+PRTMS.Text+''' ');
    Open;

    if not(RecordCount = 0) then
    begin
      prtMsName.Text := FieldByName('MSNAME').AsString;
    end;
  end;
end;

procedure TnewMs_Frm.Update_Ms_Info;
begin
  try
    with DM1.OraQuery1 do
    begin
      Close;
      SQL.Clear;
      SQL.Add('update HiMSEN_MS_NUMBER set ');
      SQL.Add('MSNO = :MSNO, PRTMSNO = :PRTMSNO, MSNAME = :MSNAME, ' +
              'DESCRIPTION = :DESCRIPTION, LV = :LV, MODID = :MODID, ' +
              'MODDATE = :MODDATE where MSNO = :param1');

      ParamByName('param1').AsString        := FupdateMs;

      parambyname('MSNO').AsString          := newMs.Text;
      parambyname('PRTMSNO').AsString       := prtMs.Text;
      parambyname('MSNAME').AsString        := newMsName.Text;
      parambyname('DESCRIPTION').AsString   := newMsDesc.Text;
      parambyname('LV').AsInteger           := FnewLv;
      parambyname('MODID').AsString         := CurrentUsers;
      parambyname('MODDATE').AsDateTime     := Now;
      ExecSQL;
      ShowMessage('�׷��߰� ����!!');
      ModalResult := mrOk;
    end;
  except
    ShowMessage('DB ���� ����!! �ٽ� �õ��Ͽ� �ֽʽÿ�,'+#10#13+
                '������ ���ӵǸ� �����ڿ��� �����Ͻʽÿ�.');

  end;
end;
end.
