unit getUserInfo_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NxColumnClasses, NxColumns,
  NxScrollControl, NxCustomGridControl, NxCustomGrid, NxGrid, Vcl.StdCtrls,
  Vcl.Mask, JvExMask, JvToolEdit, AeroButtons, JvExControls, JvLabel,
  Vcl.ImgList, Vcl.Imaging.jpeg, Vcl.ExtCtrls, Ora, JvExStdCtrls, JvCombobox,
  pjhComboBox, Vcl.Menus, IdGlobal, IdHash, IdHashMessageDigest;

type
  TgetUserInfo_Frm = class(TForm)
    Panel8: TPanel;
    Image1: TImage;
    ImageList32x32: TImageList;
    ImageList1: TImageList;
    JvLabel20: TJvLabel;
    JvLabel22: TJvLabel;
    AeroButton3: TAeroButton;
    AeroButton4: TAeroButton;
    JvFilenameEdit1: TJvFilenameEdit;
    grid_User: TNextGrid;
    NxIncrementColumn2: TNxIncrementColumn;
    NxTextColumn25: TNxTextColumn;
    NameEng: TNxTextColumn;
    EMPNO: TNxTextColumn;
    GRDNM: TNxTextColumn;
    HpNo: TNxTextColumn;
    OfficeNo: TNxTextColumn;
    NxTextColumn31: TNxTextColumn;
    NxTextColumn1: TNxTextColumn;
    NxTextColumn2: TNxTextColumn;
    JvLabel11: TJvLabel;
    JvLabel1: TJvLabel;
    cb_dept: TComboBoxInc;
    cb_deptcode: TComboBoxInc;
    JvLabel2: TJvLabel;
    cb_teamname: TComboBoxInc;
    PopupMenu1: TPopupMenu;
    GUNMUO1: TMenuItem;
    AeroButton1: TAeroButton;
    N1: TMenuItem;
    HiTEMSUSER1: TMenuItem;
    Email: TNxTextColumn;
    DPMSUSERSpell1: TMenuItem;
    N2: TMenuItem;
    CreateDPMSDEPTALIAS1: TMenuItem;
    AddAdminUserToDPMSUSER1: TMenuItem;
    N3: TMenuItem;
    Deleteselected1: TMenuItem;
    Label1: TLabel;
    procedure JvFilenameEdit1Change(Sender: TObject);
    procedure AeroButton4Click(Sender: TObject);
    procedure AeroButton3Click(Sender: TObject);
    procedure cb_deptDropDown(Sender: TObject);
    procedure cb_deptcodeDropDown(Sender: TObject);
    procedure cb_deptSelect(Sender: TObject);

    procedure FillInDeptCombo;
    procedure cb_deptcodeSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GUNMUO1Click(Sender: TObject);
    procedure AeroButton1Click(Sender: TObject);
    procedure HiTEMSUSER1Click(Sender: TObject);
    procedure DPMSUSERSpell1Click(Sender: TObject);
    procedure CreateDPMSDEPTALIAS1Click(Sender: TObject);
    procedure AddAdminUserToDPMSUSER1Click(Sender: TObject);
    procedure Deleteselected1Click(Sender: TObject);
//    procedure cb_deptChange(Sender: TObject);
//    procedure cb_deptKeyPress(Sender: TObject; var Key: Char);
  private
    FPartList,
    FPartCodeList: TStringList;
  public
    { Public declarations }
    function Get_UserItems(const aVal, aItem :String):String;
    function Get_GradeCode(aDescr:String):String;
    function Get_DeptCode(aDeptName:String):String;
    function Get_DeptCode2(aDeptName, aPosition, aCode:String):String;
    function Get_DeptCode3(aDeptName, aPartName, aCode, aPosition:String):String;
    function Get_DeptName(ADeptName:string): string;
    function Get_Gunmucode(AGunmu: string): string;
    function Get_MD5(aPasswd:String): string;

    procedure Get_UserDataFromInsaDB;
    procedure Set_ColumnName2Grid;
    procedure Set_UserData2Grid(AQry: TOraQuery);
    procedure Get_PartList;

    procedure Process_DPMS_User;
    procedure Process_DPMS_Dept;
    procedure InsertOrUpdate2DPMS_User(Ai: integer; ACode: string; var AUpdateCnt, AInsertCnt: integer);
    procedure Update_DPMS_User_From_SpellFile;
    procedure Create_DPMS_DEPT_ALIAS;
    procedure AddAdmin2DPMS_User;
  end;

var
  getUserInfo_Frm: TgetUserInfo_Frm;

implementation
uses
  DataModule_Unit;

{$R *.dfm}

procedure TgetUserInfo_Frm.Update_DPMS_User_From_SpellFile;
var
  Ai,AUpdateCnt: integer;
begin
  with grid_User do
  begin
    for Ai := 0 to RowCount - 1 do
    begin
      Self.Caption := 'ó�� ( '+IntToStr(RowCount)+'/'+IntToStr(Ai+1)+' )';

      with DM1.OraQuery1 do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT USERID FROM DPMS_USER ' +
                'WHERE USERID = :param1 ');
        ParamByName('param1').AsString := CellByName['EMPNO',Ai].AsString;
        Open;

        if RecordCount > 0 then
        begin
          Close;
          SQL.Clear;
          SQL.Add('UPDATE DPMS_USER SET ' +
                  'NAME_ENG = :NAME_ENG, TELNO = :TELNO, HPNO = :HPNO, ' +
                  'EMAIL = :EMAIL ' +
                  'WHERE USERID = :param1 ');
          ParamByName('param1').AsString  := CellByName['EMPNO',Ai].AsString;

          ParamByName('NAME_ENG').AsString := CellByName['NameEng',Ai].AsString;
          ParamByName('TELNO').AsString   := CellByName['OfficeNo',Ai].AsString;
          ParamByName('HPNO').AsString:= CellByName['HpNo',Ai].AsString;
          ParamByName('EMAIL').AsString:= CellByName['Email',Ai].AsString;

          ExecSQL;
          Inc(AUpdateCnt);
        end;
      end;
    end;
  end;
end;

procedure TgetUserInfo_Frm.AddAdmin2DPMS_User;
begin
  with DM1.OraQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT USERID FROM DPMS_USER ' +
            'WHERE USERID = ''ADMIN'' ');
    Open;

    if RecordCount = 0 then
    begin
      Close;
      SQL.Clear;
      SQL.Add('INSERT INTO DPMS_USER ( USERID, PASSWD ) ' +
              'VALUES(:USERID, :PASSWD) ');
      ParamByName('USERID').AsString  := 'ADMIN';
      ParamByName('PASSWD').AsString  := Get_MD5('ROOT');

      ExecSQL;
    end
    else
      ShowMessage('ADMIN User is already exist.');
  end;
end;

procedure TgetUserInfo_Frm.AddAdminUserToDPMSUSER1Click(Sender: TObject);
begin
  AddAdmin2DPMS_User;
end;

procedure TgetUserInfo_Frm.AeroButton1Click(Sender: TObject);
begin
  Get_UserDataFromInsaDB;
end;

procedure TgetUserInfo_Frm.AeroButton3Click(Sender: TObject);
begin
  Close;
end;

procedure TgetUserInfo_Frm.AeroButton4Click(Sender: TObject);
begin
  if grid_User.RowCount = 0 then
  begin
    ShowMessage('�μ� ���� �� ��ȸ ��ư�� ���� �����ÿ�!');
    exit;
  end;

  Process_DPMS_User;
  Process_DPMS_Dept;
end;

//procedure TgetUserInfo_Frm.cb_deptChange(Sender: TObject);
//var
//  TmpText : string;
//  i : integer;
//begin
//  with TComboBox(Sender) do
//  begin
//    TmpText := Text; // save the text that was typed by the user
//
//    for i := 0 to Items.Count - 1 do
//    begin
//      if Pos(Text, Items[i]) = 1 then
//      begin
//        ItemIndex := i;
//        SelStart := Length(TmpText);
//        SelLength := Length(Items[i]) - Length(TmpText);
//        Break;
//      end;
//    end;
//  end;
//end;

procedure TgetUserInfo_Frm.cb_deptcodeDropDown(Sender: TObject);
begin
  FillInDeptCombo;
end;

procedure TgetUserInfo_Frm.cb_deptcodeSelect(Sender: TObject);
begin
  if cb_deptcode.Text <> '' then
  begin
    cb_dept.ItemIndex := cb_deptcode.ItemIndex;
    Get_PartList;
    cb_teamname.Items.Assign(FPartList);
  end;
end;

procedure TgetUserInfo_Frm.cb_deptDropDown(Sender: TObject);
begin
  FillInDeptCombo;
end;

//procedure TgetUserInfo_Frm.cb_deptKeyPress(Sender: TObject; var Key: Char);
//begin
//  if Key = #8 then
//  begin
//    with TComboBox(Sender) do
//    begin
//      Text := Copy(Text, 1, Length(Text) - SelLength - 1);
//    end;
//
//    cb_deptChange(Sender);
//    Key := #0;
//  end;
//end;

procedure TgetUserInfo_Frm.cb_deptSelect(Sender: TObject);
begin
  if cb_dept.Text <> '' then
  begin
    cb_deptcode.ItemIndex := cb_dept.ItemIndex;

    if cb_deptcode.Text <> '' then
    begin
      Get_PartList;
      cb_teamname.Items.Assign(FPartList);
    end;
  end;
end;

procedure TgetUserInfo_Frm.CreateDPMSDEPTALIAS1Click(Sender: TObject);
begin
  Create_DPMS_DEPT_ALIAS;
end;

procedure TgetUserInfo_Frm.Create_DPMS_DEPT_ALIAS;
var
  i: integer;
begin
  with DM1.OraQuery3 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT count(*) reccnt FROM DPMS_DEPT_ALIAS');

    Open;

    if FieldByName('reccnt').AsInteger > 0 then
    begin
      ShowMessage('DPMS_DEPT_ALIAS Table�� �����Ͱ� �����մϴ�.');
      exit;
    end;

    Close;
    SQL.Clear;
    SQL.Add('SELECT * FROM DPMS_DEPT ORDER BY DEPT_CD');

    Open;

    if RecordCount = 0 then
    begin
      ShowMessage('DPMS_DEPT Table�� �����Ͱ� �����ϴ�.');
      exit;
    end;
  end;

  with DM1.OraQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('INSERT INTO DPMS_DEPT_ALIAS ' +
            'VALUES( ' +
            '   :DEPT_CODE, :ALIAS_CODE, :PRE_DEPT_CODE, :MODID, :MODDATE ) ');

    for i := 0 to DM1.OraQuery3.RecordCount - 1 do
    begin
      ParamByName('DEPT_CODE').AsString     := DM1.OraQuery3.FieldByName('DEPT_CD').AsString;
      ParamByName('ALIAS_CODE').AsInteger   := i + 1;
      ParamByName('PRE_DEPT_CODE').AsString := '';
      ParamByName('MODID').AsString   := '';
      ParamByName('MODDATE').AsDateTime := Now;

      ExecSQL;
      DM1.OraQuery3.Next;
    end;
  end;
end;

procedure TgetUserInfo_Frm.Deleteselected1Click(Sender: TObject);
begin
  grid_User.DeleteRow(grid_User.SelectedRow);
end;

procedure TgetUserInfo_Frm.DPMSUSERSpell1Click(Sender: TObject);
begin
  Update_DPMS_User_From_SpellFile;
end;

procedure TgetUserInfo_Frm.FillInDeptCombo;
begin
  with DM1.OraQuery2 do
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
      cb_dept.Items.BeginUpdate;
      cb_deptcode.Items.BeginUpdate;
      try
        cb_dept.Items.Clear;
        cb_deptcode.Items.Clear;

        cb_dept.Items.Add('');
        cb_deptcode.Items.Add('');
        cb_dept.Items.Add('�ӿ�');
        cb_deptcode.Items.Add('A');

        while not eof do
        begin
          cb_dept.Items.Add(FieldByName('DEPTNM').AsString);
          cb_deptcode.Items.Add(FieldByName('DEPT').AsString);
          Next;
        end;
      finally
        cb_dept.Items.EndUpdate;
        cb_deptcode.Items.EndUpdate;
      end;
    end;
  end;

end;

procedure TgetUserInfo_Frm.FormCreate(Sender: TObject);
begin
  FPartList := TStringList.Create;
  FPartCodeList := TStringList.Create;
end;

procedure TgetUserInfo_Frm.FormDestroy(Sender: TObject);
begin
  FPartList.Free;
  FPartCodeList.Free;
end;

function TgetUserInfo_Frm.Get_DeptCode(aDeptName: String): String;
var
  OraQuery : TOraQuery;
begin
  OraQuery := TOraQuery.Create(nil);
  try
    with OraQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT DEPT_CD FROM DPMS_DEPT ' +
              'WHERE DEPT_NAME LIKE :param1 ');
      ParamByName('param1').AsString := aDeptName;
      Open;

      Result := FieldByName('DEPT_CD').AsString;

    end;
  finally
    FreeAndNil(OraQuery);
  end;
end;

function TgetUserInfo_Frm.Get_DeptCode2(aDeptName, aPosition, aCode: String): String;
var
  i: integer;
begin
  Result := '';

  if (aDeptName = '') and (aPosition = '�μ���') then
  begin
    Result := aCode + '0';
    exit;
  end;

  i := FPartList.IndexOf(aDeptName);

  if i > 0 then
  begin
    if FPartCodeList.Strings[i] <> '-1' then
      Result := aCode + FPartCodeList.Strings[i];
  end;
end;

function TgetUserInfo_Frm.Get_DeptCode3(aDeptName, aPartName, aCode,
  aPosition:String): String;
var
  i: integer;
begin
  Result := '';

  if (aPartName = '') and (aPosition = '�μ���') then
  begin
    Result := aCode + '0';
    exit;
  end
  else
  if (aPartName = '') and ((aPosition = '����ӿ�') or (aPosition = '�ι���') or
    (aPosition = '�κ�����') or (aPosition = '�����ǥ')) then
  begin
    Result := aCode + 'K00';
    exit;
  end;

  i := FPartList.IndexOf(aPartName);

  if i > 0 then
  begin
    if FPartCodeList.Strings[i] <> '-1' then
      Result := aCode + FPartCodeList.Strings[i];
  end;
end;

function TgetUserInfo_Frm.Get_DeptName(ADeptName: string): string;
var
  LStr: string;
begin
  LStr := ADeptName;

  if Copy(LStr, Length(LStr), 1) = '��' then
    Result := LStr + '����'
  else
    Result := LStr + '��';
end;

function TgetUserInfo_Frm.Get_GradeCode(aDescr: String): String;
var
  OraQuery : TOraQuery;
begin
  if aDescr = '������' then
    aDescr := '�δ�'
  else
  if aDescr = '4�ޱ��' then
    aDescr := '4��'
  else
  if aDescr = '5�ޱ��' then
    aDescr := '5��'
  else
  if aDescr = '6�ޱ��' then
    aDescr := '6��'
  else
  if aDescr = '7�ޱ��' then
    aDescr := '7��';


  OraQuery := TOraQuery.Create(nil);
  try
    with OraQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT GRADE FROM DPMS_USER_GRADE ' +
              'WHERE DESCR LIKE :param1 ');
      ParamByName('param1').AsString := aDescr;
      Open;

      Result := FieldByName('GRADE').AsString;

    end;
  finally
    FreeAndNil(OraQuery);
  end;
end;

function TgetUserInfo_Frm.Get_Gunmucode(AGunmu: string): string;
begin
  if (AGunmu = '����') or (AGunmu = '����') then
    Result := 'I'
  else
  if AGunmu = '����' then
    Result := 'O';
end;

function TgetUserInfo_Frm.Get_MD5(aPasswd: String): string;
begin
  Result := '';

  with TIdHashMessageDigest5.Create do
  try
    Result := HashStringAsHex(APasswd);
  finally
    Free;
  end;
end;

procedure TgetUserInfo_Frm.Get_PartList;
var
  i,j: integer;
begin
  with DM1.OraQuery2 do
  begin
    Close;
    SQL.Clear;
    if cb_deptcode.Text = 'A' then
      SQL.Add('select RESNM from kx01.gtaa004 ' +
              'where DEPT like :param1 ' +
              'GROUP BY RESNM ')
    else
      SQL.Add('select PARTNM from kx01.gtaa004 ' +
              'where DEPTNM IS NOT NULL AND DEPT = :param1 ' +
              'GROUP BY PARTNM ');

    if cb_deptcode.Text <> '' then
    begin
      ParamByName('param1').AsString := cb_deptcode.Text;

      if cb_deptcode.Text = 'A' then
        ParamByName('param1').AsString := cb_deptcode.Text + 'K%';
    end
    else
      SQL.Text := StringReplace(SQL.Text,'AND DEPT = :param1','',[rfReplaceAll]);

    Open;

    if RecordCount > 0 then
    begin
      FPartList.Clear;
      FPartCodeList.Clear;

      while not eof do
      begin
        if cb_deptcode.Text = 'A' then
        begin
          if FieldByName('RESNM').AsString <> '' then
            FPartList.Add(FieldByName('RESNM').AsString)
        end
        else
        if FieldByName('PARTNM').AsString <> cb_dept.Text then
          FPartList.Add(FieldByName('PARTNM').AsString);
        Next;
      end;

      FPartList.Sort;

      j := 1;
      for i := 0 to FPartList.Count - 1 do
      begin
        if FPartList.Strings[i] <> '' then
        begin
          FPartCodeList.Add(IntToStr(j));
          Inc(j);
        end
        else
          FPartCodeList.Add(IntToStr(-1));

      end;
    end;
  end;
end;

procedure TgetUserInfo_Frm.Get_UserDataFromInsaDB;
begin
  try
    with DM1.OraQuery2 do
    begin
      Close;
      SQL.Clear;
      if cb_deptcode.Text = 'A' then
        SQL.Add('SELECT * FROM kx01.gtaa004 ' +
              'WHERE DEPT LIKE :param1 AND STATNM = ''����''' //''K%''  AND EMPNO = ''A379042''
        )
      else
        SQL.Add('select * from kx01.gtaa004 ' +
              'where DEPTNM IS NOT NULL AND DEPT = :param1 AND STATNM = ''����''' //''K%''  AND EMPNO = ''A379042''
        );

      if cb_deptcode.Text <> '' then
      begin
        ParamByName('param1').AsString := cb_deptcode.Text;

        if cb_deptcode.Text = 'A' then
          ParamByName('param1').AsString := cb_deptcode.Text + 'K%';
      end
      else
        SQL.Text := StringReplace(SQL.Text,'AND DEPT = :param1','',[rfReplaceAll]);

      Open;

      if RecordCount > 0 then
      begin
        Set_ColumnName2Grid;
        Set_UserData2Grid(DM1.OraQuery2);
      end;//if

    end;
  finally

  end;
end;

function TgetUserInfo_Frm.Get_UserItems(const aVal, aItem: String): String;
var
  c, d : Integer;
  LStr1 : String;
begin
  c := POS('<'+aItem+'>',aVal)+(Length(aItem)+2);
  d := POS('</'+aItem+'>',aVal);
  d := d - c;

  LStr1 := Copy(aVal,c,d);

  c := POS('<![CDATA[',LStr1)+9;
  d := POS(']]>',LStr1);
  d := d - c;

  Result := Copy(LStr1,c,d);

end;

//�μ��� DPMS_USER ���̺� ������ ��  �ش� �μ������� ���� GUNMU�� 'O'�� ���� �ؾ� ��.
procedure TgetUserInfo_Frm.GUNMUO1Click(Sender: TObject);
begin
  if cb_deptcode.Text <> '' then
  begin
    with DM1.OraQuery1 do
    begin
      Close;
      SQL.Clear;
      SQL.Add('UPDATE DPMS_USER SET ' +
              'GUNMU = ''O'' ' +
              'WHERE DEPT_CD = :param1 ');
      ParamByName('param1').AsString := cb_deptcode.Text;

      ExecSQL;
    end;
  end;
end;

procedure TgetUserInfo_Frm.HiTEMSUSER1Click(Sender: TObject);
var
  LCode: string;
  LUpdate, LInsert: integer;
begin
  LCode := Copy(cb_deptcode.Text, 1, 3);
  InsertOrUpdate2DPMS_User(grid_user.SelectedRow, LCode, LUpdate, LInsert);
end;

procedure TgetUserInfo_Frm.InsertOrUpdate2DPMS_User(Ai: integer; ACode: string; var AUpdateCnt, AInsertCnt: integer);
begin
  with grid_User do
  begin
    Self.Caption := 'ó�� ( '+IntToStr(RowCount)+'/'+IntToStr(Ai+1)+' )';

    with DM1.OraQuery1 do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT USERID FROM DPMS_USER ' +
              'WHERE USERID = :param1 ');
      ParamByName('param1').AsString := CellByName['EMPNO',Ai].AsString;
      Open;

      if RecordCount > 0 then
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE DPMS_USER SET ' +
                'DEPT_CD = :DEPT_CD, GRADE = :GRADE, POSITION = :POSITION, ' +
                'GUNMU = :GUNMU ' +
                'WHERE USERID = :param1 ');
        ParamByName('param1').AsString  := CellByName['EMPNO',Ai].AsString;

//        ParamByName('PASSWD').AsString := Get_MD5(CellByName['EMPNO',Ai].AsString);
        ParamByName('DEPT_CD').AsString := Get_DeptCode2(CellByName['PARTNM',Ai].AsString,CellByName['RESNM',Ai].AsString, ACode);
        ParamByName('GRADE').AsString   := Get_GradeCode(CellByName['GRDNM',Ai].AsString);
        ParamByName('POSITION').AsString:= CellByName['RESNM',Ai].AsString;
        ParamByName('GUNMU').AsString:= Get_Gunmucode(CellByName['STATNM',Ai].AsString);

        ExecSQL;
        Inc(AUpdateCnt);
      end else
      begin
        Close;
        SQL.Clear;
        SQL.Add('INSERT INTO DPMS_USER ' +
                '( ' +
                '   USERID, PASSWD, DEPT_CD, NAME_KOR, GUNMU, GRADE, POSITION, EMAIL ' +
                ') VALUES ' +
                '( ' +
                '   :USERID, :PASSWD, :DEPT_CD, :NAME_KOR, :GUNMU, :GRADE, :POSITION, :EMAIL '+
                ') ');

        ParamByName('USERID').AsString     := CellByName['EMPNO',Ai].AsString;
        ParamByName('PASSWD').AsString     := Get_MD5(CellByName['EMPNO',Ai].AsString);
        ParamByName('DEPT_CD').AsString    := Get_DeptCode3(CellByName['DEPTNM',Ai].AsString,CellByName['PARTNM',Ai].AsString, ACode, CellByName['RESNM',Ai].AsString);
        ParamByName('NAME_KOR').AsString   := CellByName['EMPNM',Ai].AsString;
        ParamByName('GUNMU').AsString      := Get_Gunmucode(CellByName['STATNM',Ai].AsString);
        ParamByName('GRADE').AsString      := Get_GradeCode(CellByName['GRDNM',Ai].AsString);
        ParamByName('POSITION').AsString   := CellByName['RESNM',Ai].AsString;
//        ParamByName('EMAIL').AsString   := CellByName['RESNM',Ai].AsString;

        ExecSQL;
        Inc(AInsertCnt);
      end;
    end;
  end;
end;

procedure TgetUserInfo_Frm.JvFilenameEdit1Change(Sender: TObject);
var
  LValueList,
  LStrList: TStringList;
  lnameK, lnameE, ldept,lDepartment,
  LStr, LStr1,Lstr2: string;
  idx, li,
  i,j,v,c,d,lrow,lcol : integer;

begin
  LStrList := TStringList.Create;
  try
    if JvFilenameEdit1.FileName <> '' then
    begin
      with grid_User do
      begin
        BeginUpdate;
        try
          ClearRows;
          with LStrList do
          begin
            LStrList.LoadFromFile(JvFilenameEdit1.FileName);

            LValueList := TStringList.Create;
            try
              i := 0;

              while i < LStrList.Count do
              begin
                LStr := LStrList.Strings[i];

                LValueList.Clear;

                v := POS('id=chkText',LStr);
                if v > 0 then
                begin
                  lrow := AddRow;

                  //Name

                  LStr1 := Get_UserItems(LStr, 'DisplayName');
                  ExtractStrings(['/'],[],PChar(LStr1),LValueList);

                  lnameK := LValueList.Strings[0];//name
                  idx := Pos('(',lnameK);
                  lnameK := Copy(lnameK,1,idx-1);

                  lnameE := LValueList.Strings[0];
                  lnameE := Copy(lnameE,idx+1,length(lnameE)-(idx+1));

                  lDepartment := LValueList.Strings[2];



                  Cells[1,lrow] := Get_UserItems(LStr, 'EmpID');
                  Cells[2,lrow] := lnameK;
                  Cells[3,lrow] := lnameE;
                  Cells[4,lrow] := Get_UserItems(LStr, 'RankName');
                  Cells[5,lrow] := Get_UserItems(LStr, 'CellPhone');
                  Cells[6,lrow] := Get_UserItems(LStr, 'OFFICETEL');
                  Cells[7,lrow] := lDepartment;
                  Cells[8,lrow] := Get_GradeCode(Cells[4,lrow]);//����
                  Cells[9,lrow] := Get_DeptCode(Cells[7,lrow]);//�μ��ڵ�
                  Cells[10,lrow] := Get_UserItems(LStr, 'addr');
                end;
                Inc(i);
              end;
            finally
              FreeAndNil(LValueList);
            end;
          end;
        finally
          EndUpdate;
        end;
      end;
    end
    else
    begin
      ShowMessage('Choose File Name first!');
      exit;
    end;
  finally
    FreeAndNil(LStrList);

  end;
end;

procedure TgetUserInfo_Frm.Process_DPMS_Dept;
var
  LCode: string;
  i,j: integer;
begin
  LCode := Copy(cb_deptcode.Text,1,3);

  DM1.OraTransaction1.StartTransaction;
  try
    with DM1.OraQuery1 do
    begin
      Close;
      SQL.Clear;
      SQL.Add('DELETE FROM DPMS_DEPT ' +
              'WHERE DEPT_CD like :param1 ');
      ParamByName('param1').AsString := LCode+'%';

      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('INSERT INTO DPMS_DEPT ' +
              '(DEPT_CD, DEPT_NAME, DEPT_LV) ' +
              'VALUES(:DEPT_CD, :DEPT_NAME, : DEPT_LV) ');
      ParamByName('DEPT_CD').AsString  := LCode;
      ParamByName('DEPT_NAME').AsString  := cb_dept.Text;
      ParamByName('DEPT_LV').AsInteger  := 1;

      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('INSERT INTO DPMS_DEPT ' +
              '(PARENT_CD, DEPT_CD, DEPT_NAME, DEPT_LV) ' +
              'VALUES(:PARENT_CD, :DEPT_CD, :DEPT_NAME, : DEPT_LV) ');
      ParamByName('PARENT_CD').AsString  := LCode;
      ParamByName('DEPT_CD').AsString  := LCode + '0';
      ParamByName('DEPT_NAME').AsString  := Get_DeptName(cb_dept.Text);
      ParamByName('DEPT_LV').AsInteger  := 2;

      ExecSQL;

      j := 1;
      for i := 0 to FPartList.Count - 1 do
      begin
        if FPartList.Strings[i] <> '' then
        begin
          Close;
          SQL.Clear;
          SQL.Add('INSERT INTO DPMS_DEPT ' +
                  '(PARENT_CD, DEPT_CD, DEPT_NAME, DEPT_LV) ' +
                  'VALUES(:PARENT_CD, :DEPT_CD, :DEPT_NAME, : DEPT_LV) ');
          ParamByName('PARENT_CD').AsString  := LCode;
          ParamByName('DEPT_CD').AsString  := LCode + IntToStr(j);
          ParamByName('DEPT_NAME').AsString  := FpartList.Strings[i];
          ParamByName('DEPT_LV').AsInteger  := 2;

          ExecSQL;

          inc(j);
        end;
      end;
    end;

    DM1.OraTransaction1.Commit;
  except
    DM1.OraTransaction1.Rollback;
  end;
end;

procedure TgetUserInfo_Frm.Process_DPMS_User;
var
  i, LUpdateCnt, LInsertCnt : Integer;
  LCode: string;
begin
  LCode := Copy(cb_deptcode.Text, 1, 3);
//    BeginUpdate;
    try
      LUpdateCnt := 0;
      LInsertCnt := 0;
      DM1.OraTransaction1.StartTransaction;
      try
        for i := 0 to grid_User.RowCount-1 do
        begin
          InsertOrUpdate2DPMS_User(i, LCode, LUpdateCnt, LInsertCnt);
        end;

        DM1.OraTransaction1.Commit;
      except
        DM1.OraTransaction1.Rollback;
      end;
    finally
      Self.Caption := 'DPMS_USER: Update = ' + IntToStr(LUpdateCnt) + ' , Insert = ' + IntToStr(LInsertCnt);
//      EndUpdate;
    end;
end;

procedure TgetUserInfo_Frm.Set_ColumnName2Grid;
var
  OraQuery : TOraQuery;
  LnxTextColumn: TnxTextColumn;
begin
  if DM1.OraSession2.Connected then
  begin
    OraQuery := TOraQuery.Create(nil);
    OraQuery.Session := DM1.OraSession2;

    try
      with OraQuery do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select column_name, Data_Type, column_id from all_tab_columns ' +
                'where owner = ''kx01'' AND table_name = ''kx01.gtaa004'' ' + //owner = ''TBACS'' AND
                'order by column_id');
        Open;

        if RecordCount > 0 then
        begin
          ShowMessage('aaa');
        end
        else
        begin
          with grid_User do
          begin
            BeginUpdate;
            try
              ClearRows;
              Columns.Clear;

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'GUBUN'));
              LnxTextColumn.Name := 'GUBUN';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint];//coCanInput,coEditing,

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'EMPNO'));
              LnxTextColumn.Name := 'EMPNO';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'EMPNM'));
              LnxTextColumn.Name := 'EMPNM';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'DEPT'));
              LnxTextColumn.Name := 'DEPT';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'DEPTNM'));
              LnxTextColumn.Name := 'DEPTNM';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'PARTCD'));
              LnxTextColumn.Name := 'PARTCD';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'PARTNM'));
              LnxTextColumn.Name := 'PARTNM';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'RESCD'));
              LnxTextColumn.Name := 'RESCD';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'RESNM'));
              LnxTextColumn.Name := 'RESNM';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'GRDCD'));
              LnxTextColumn.Name := 'GRDCD';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'GRDNM'));
              LnxTextColumn.Name := 'GRDNM';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'WRKCD'));
              LnxTextColumn.Name := 'WRKCD';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'WRKNM'));
              LnxTextColumn.Name := 'WRKNM';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'TELNO'));
              LnxTextColumn.Name := 'TELNO';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'HPNO'));
              LnxTextColumn.Name := 'HPNO';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'IPADDR'));
              LnxTextColumn.Name := 'IPADDR';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'PCMCNO'));
              LnxTextColumn.Name := 'PCMCNO';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'DIVISION'));
              LnxTextColumn.Name := 'DIVISION';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'STATCD'));
              LnxTextColumn.Name := 'STATCD';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint, coCanSort];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'STATNM'));
              LnxTextColumn.Name := 'STATNM';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'TSDATE'));
              LnxTextColumn.Name := 'TSDATE';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'RUNDAY'));
              LnxTextColumn.Name := 'RUNDAY';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'CREMPNO'));
              LnxTextColumn.Name := 'CREMPNO';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'INDATE'));
              LnxTextColumn.Name := 'INDATE';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint];

              LnxTextColumn := TnxTextColumn(Columns.Add(TnxTextColumn,'VALDATE'));
              LnxTextColumn.Name := 'VALDATE';
              LnxTextColumn.Options := [coCanClick,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint];
            finally
              EndUpdate;
            end;
          end;
        end;
      end;
    finally
      FreeAndNil(OraQuery);
    end;

  end;
end;

procedure TgetUserInfo_Frm.Set_UserData2Grid(AQry: TOraQuery);
var
  i: integer;
begin
  with AQry do
  begin
    with grid_User do
    begin
      BeginUpdate;
      try
        ClearRows;

        while not eof do
        begin
          i := AddRow;

          Cells[0,i] := FieldByName('GUBUN').AsString;
          Cells[1,i] := FieldByName('EMPNO').AsString;
          Cells[2,i] := FieldByName('EMPNM').AsString;
          Cells[3,i] := FieldByName('DEPT').AsString;
          Cells[4,i] := FieldByName('DEPTNM').AsString;
          Cells[5,i] := FieldByName('PARTCD').AsString;
          Cells[6,i] := FieldByName('PARTNM').AsString;
          Cells[7,i] := FieldByName('RESCD').AsString;
          Cells[8,i] := FieldByName('RESNM').AsString;
          Cells[9,i] := FieldByName('GRDCD').AsString;
          Cells[10,i] := FieldByName('GRDNM').AsString;
          Cells[11,i] := FieldByName('WRKCD').AsString;
          Cells[12,i] := FieldByName('WRKNM').AsString;
          Cells[13,i] := FieldByName('TELNO').AsString;
          Cells[14,i] := FieldByName('HPNO').AsString;
          Cells[15,i] := FieldByName('IPADDR').AsString;
          Cells[16,i] := FieldByName('PCMCNO').AsString;
          Cells[17,i] := FieldByName('DIVISION').AsString;
          Cells[18,i] := FieldByName('STATCD').AsString;
          Cells[19,i] := FieldByName('STATNM').AsString;
          Cells[20,i] := FieldByName('TSDATE').AsString;
          Cells[21,i] := FieldByName('RUNDAY').AsString;
          Cells[22,i] := FieldByName('CREMPNO').AsString;
          Cells[23,i] := FieldByName('INDATE').AsString;
          Cells[24,i] := FieldByName('VALDATE').AsString;
          Inc(i);
          Next;
        end;//while
      finally
         EndUpdate;
      end;
    end;
  end;//with
end;

end.
