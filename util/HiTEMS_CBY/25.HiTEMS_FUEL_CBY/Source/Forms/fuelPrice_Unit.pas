unit fuelPrice_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NxEdit, AdvGlowButton, Vcl.StdCtrls,
  Vcl.Grids, AdvObj, BaseGrid, AdvGrid, Vcl.ComCtrls, AdvPanel, Vcl.ExtCtrls,
  AdvSplitter, NxCollection, AeroButtons, JvExControls, JvLabel, Vcl.ExtDlgs,
  Vcl.ImgList, Vcl.Imaging.jpeg, tmsAdvGridExcel, DateUtils;

type
  TfuelPrice_Frm = class(TForm)
    Panel8: TPanel;
    Image1: TImage;
    ImageList16x16: TImageList;
    ImageList32x32: TImageList;
    JvLabel22: TJvLabel;
    btn_Close: TAeroButton;
    btn_Reg: TAeroButton;
    btn_Refrash: TAeroButton;
    btn_Del: TAeroButton;
    Label19: TLabel;
    pfrom: TDateTimePicker;
    Label20: TLabel;
    pto: TDateTimePicker;
    JvLabel10: TJvLabel;
    fuelInNo: TNxEdit;
    fuelNo: TNxEdit;
    fuelPrice: TNxNumberEdit;
    fuelUnit: TNxEdit;
    fuelStd: TNxEdit;
    fuelName: TNxComboBox;
    fuelIndate: TDateTimePicker;
    subCode: TNxEdit;
    JvLabel1: TJvLabel;
    JvLabel2: TJvLabel;
    JvLabel3: TJvLabel;
    JvLabel4: TJvLabel;
    JvLabel5: TJvLabel;
    JvLabel6: TJvLabel;
    JvLabel7: TJvLabel;
    JvLabel8: TJvLabel;
    priceGrid: TAdvStringGrid;
    btn_report: TAeroButton;
    SaveDialog1: TSaveDialog;
    AdvGridExcelIO1: TAdvGridExcelIO;
    btn_search: TAeroButton;
    procedure btn_CloseClick(Sender: TObject);
    procedure fuelNameButtonDown(Sender: TObject);
    procedure fuelNameSelect(Sender: TObject);
    procedure fuelNameChange(Sender: TObject);
    procedure btn_RefrashClick(Sender: TObject);
    procedure priceGridDblClickCell(Sender: TObject; ARow, ACol: Integer);
    procedure priceGridGetAlignment(Sender: TObject; ARow, ACol: Integer;
      var HAlign: TAlignment; var VAlign: TVAlignment);
    procedure btn_RegClick(Sender: TObject);
    procedure btn_DelClick(Sender: TObject);
    procedure btn_reportClick(Sender: TObject);
    procedure btn_searchClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Set_priceGrid_Header;
    procedure Set_priceGrid;
    procedure Insert_Into_HiTEMS_FUEL_PRICE;
    procedure Update_HiTEMS_FUEL_PRICE;
    procedure Del_HiTEMS_FUEL_PRICE(aFuelInNo:String);
  end;

var
  fuelPrice_Frm: TfuelPrice_Frm;

implementation
uses
  CommonUtil_Unit,
  DataModule_Unit;

{$R *.dfm}

procedure TfuelPrice_Frm.btn_CloseClick(Sender: TObject);
begin
  Close;

end;

procedure TfuelPrice_Frm.btn_DelClick(Sender: TObject);
begin
  if MessageDlg('���� �Ͻðڽ��ϱ�? ������ ������ ������ �� �����ϴ�.',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if fuelInNo.Text <> '' then
    begin
      Del_HiTEMS_FUEL_PRICE(fuelInNo.Text);
      Set_priceGrid;
    end;
  end;
end;

procedure TfuelPrice_Frm.btn_RefrashClick(Sender: TObject);
begin
  fuelInNo.Clear;
  fuelNo.Clear;
  fuelName.Clear;
  fuelStd.Clear;
  fuelUnit.Clear;
  fuelPrice.Clear;
  fuelIndate.Date := now;
  subCode.Clear;
  btn_Reg.Caption := '�ܰ����';
  btn_Del.Enabled := False;
end;

procedure TfuelPrice_Frm.btn_RegClick(Sender: TObject);
begin
  if fuelName.Text = '' then
  begin
    fuelName.SetFocus;
    raise Exception.Create('ǰ���� �Է��Ͽ� �ֽʽÿ�!');
  end;

  if fuelPrice.AsInteger <= 0 then
  begin
    fuelPrice.SetFocus;
    raise Exception.Create('�ܰ��� �Է��Ͽ� �ֽʽÿ�!');
  end;

  if fuelNo.Text = '' then
  begin
    fuelNo.SetFocus;
    raise Exception.Create('�����ȣ�� �Է��Ͽ� �ֽʽÿ�!');
  end;

  if subCode.Text = '' then
  begin
    subCode.SetFocus;
    raise Exception.Create('�����ڵ带 �Է��Ͽ� �ֽʽÿ�!');
  end;

  if btn_Reg.Caption = '�ܰ����' then
    Insert_Into_HiTEMS_FUEL_PRICE
  else
    Update_HiTEMS_FUEL_PRICE;

  Set_priceGrid;
//  btn_Refrash(sender);
end;

procedure TfuelPrice_Frm.btn_reportClick(Sender: TObject);
var
  lstr : String;
begin
  lstr := FormatDateTime('YYMMDD_',Now);
  SaveDialog1.FileName := lstr+'������_�ܰ�ǥ.xls';
  if SaveDialog1.Execute then
  begin
    AdvGridExcelIO1.AdvStringGrid := priceGrid;
    AdvGridExcelIO1.XLSExport(SaveDialog1.FileName);
  end;
end;

procedure TfuelPrice_Frm.btn_searchClick(Sender: TObject);
begin
  Set_priceGrid_Header;
  Set_priceGrid;
end;

procedure TfuelPrice_Frm.Del_HiTEMS_FUEL_PRICE(aFuelInNo: String);
begin
  with DM1.OraQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Delete From FUEL_PRICE ' +
            'where FUELINNO LIKE :param1 ');

    ParamByName('param1').AsString := aFuelInNo;

    ExecSQL;
    ShowMessage(Format('%s ����!',[btn_Del.Caption]));

  end;
end;

procedure TfuelPrice_Frm.FormCreate(Sender: TObject);
begin
  pFrom.Date := StartOfTheMonth(today);
  pTo.Date   := EndOfTheMonth(today);
  fuelIndate.Date := today;

  Set_priceGrid;
end;

procedure TfuelPrice_Frm.fuelNameButtonDown(Sender: TObject);
begin
  with fuelName.Items do
  begin
    BeginUpdate;
    try
      Clear;
      Add('');
      with DM1.OraQuery1 do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select distinct(FUELNO), FUELNAME, FUELSTD, UNIT, SUBCODE from ' +
                'FUEL_PRICE ' +
                'order by FuelNo ');
        Open;

        while not eof do
        begin
          Add(FieldByName('FUELNAME').AsString);
          Next;
        end;
      end;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TfuelPrice_Frm.fuelNameChange(Sender: TObject);
begin
  fuelPrice.Text := NumberFormat(fuelPrice.Text);
end;

procedure TfuelPrice_Frm.fuelNameSelect(Sender: TObject);
begin
  if fuelName.Text <> '' then
  begin
    with DM1.OraQuery1 do
    begin
      First;
      while not eof do
      begin
        if SameText(fuelName.Text,FieldByName('FUELNAME').AsString) then
        begin
          fuelStd.Text  := FieldByName('FUELSTD').AsString;
          fuelUnit.Text := FieldByName('UNIT').AsString;
          fuelNo.Text   := FieldByName('FUELNO').AsString;
          subCode.Text  := FieldByName('SUBCODE').AsString;
          Break;
        end;
        Next;
      end;
    end;
  end
  else
  begin
    fuelStd.Clear;
    fuelUnit.Clear;
    fuelNo.Clear;
  end;
end;


procedure TfuelPrice_Frm.Insert_Into_HiTEMS_FUEL_PRICE;
var
  lno : Double;
begin
  with DM1.OraQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Insert Into FUEL_PRICE ' +
            'Values(:FUELINNO, :FUELNO, :FUELNAME, :FUELSTD, :UNIT,' +
            ':PRICE, :FUELINDATE, :SUBCODE )');

    lno := DateTimeToMilliseconds(Now);
    sleep(100);
    ParamByName('FUELINNO').AsFloat := lno;
    ParamByName('FUELNO').AsString := fuelNo.Text;
    ParamByName('FUELNAME').AsString := fuelName.Text;
    ParamByName('FUELSTD').AsString := fuelStd.Text;
    ParamByName('UNIT').AsString := fuelUnit.Text;
    ParamByName('PRICE').AsInteger := fuelPrice.AsInteger;
    ParamByName('FUELINDATE').AsDateTime := fuelIndate.Date;
    ParamByName('SUBCODE').AsString := subCode.Text;
    ExecSQL;
    ShowMessage(Format('%s ����!',[btn_reg.Caption]));
  end;
end;

procedure TfuelPrice_Frm.priceGridDblClickCell(Sender: TObject; ARow,
  ACol: Integer);
begin
  with priceGrid do
  begin
    if ARow > 0 then
    begin
      with DM1.OraQuery1 do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select * from FUEL_PRICE ' +
                'where FUELINNO LIKE :param1 ');
        ParamByName('param1').AsString := priceGrid.Cells[1,ARow];
        Open;

        if RecordCount <> 0 then
        begin
          fuelInNo.Text   := FieldByName('FUELINNO').AsString;
          fuelNo.Text     := FieldByName('FUELNO').AsString;
          fuelName.Text   := FieldByName('FUELNAME').AsString;
          fuelStd.Text    := FieldByName('FUELSTD').AsString;
          fuelUnit.Text   := FieldByName('UNIT').AsString;
          fuelPrice.Text  := NumberFormat(FieldByName('PRICE').AsString);
          subCode.Text    := FieldByName('SUBCODE').AsString;
          fuelIndate.Date := FieldByName('FUELINDATE').AsDateTime;


          btn_Reg.Caption := '�ܰ�����';
          btn_Del.Enabled := True;
        end;
      end;
    end;
  end;
end;

procedure TfuelPrice_Frm.priceGridGetAlignment(Sender: TObject; ARow,
  ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  if ARow < 1 then
  begin
    HAlign := taCenter;
    VAlign := vtaCenter;
  end else
  begin
    case ACol of
      0..3 : begin
               HAlign := taCenter;
               VAlign := vtaCenter;
             end;
      4..5 : VAlign := vtaCenter;
      6..8 : begin
               HAlign := taCenter;
               VAlign := vtaCenter;
             end;

    end;
  end;
end;

procedure TfuelPrice_Frm.Set_priceGrid;
var
  lrow,
  li: Integer;
begin
  Set_priceGrid_Header;
  with priceGrid do
  begin
    BeginUpdate;
    AutoSize := False;
    try
      with DM1.OraQuery1 do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select * from FUEL_PRICE ' +
                'where FUELINDATE Between :param1 and :param2 '+
                'order by FUELINDATE DESC ');

        ParamByName('param1').AsDate := pfrom.DateTime;
        ParamByName('param2').AsDate := pto.DateTime;

        Open;

        for li := 0 to RecordCount-1 do
        begin
          if li <> 0 then
            AddRow;
          lrow := RowCount-1;

          Cells[0,lrow] := IntToStr(li+1);
          Cells[1,lrow] := FieldByName('FUELINNO').AsString;
          Cells[2,lrow] := FieldByName('FUELNO').AsString;
          Cells[3,lrow] := FieldByName('FUELNAME').AsString;
          Cells[4,lrow] := FieldByName('FUELSTD').AsString;

          Cells[5,lrow] := FieldByName('UNIT').AsString;
          Cells[6,lrow] := NumberFormat(FieldByName('PRICE').AsString);
          Cells[7,lrow] := FieldByName('SUBCODE').AsString;
          Cells[8,lrow] := FormatDateTime('YYYY-MM-DD',FieldByName('FUELINDATE').AsDateTime);
          Next;

        end;
      end;
    finally
      AutoSize := True;
      ColWidths[1] := 0;
      EndUpdate;
    end;
  end;
end;

procedure TfuelPrice_Frm.Set_priceGrid_Header;
var
  li : Integer;
begin
  with priceGrid do
  begin
    BeginUpdate;
    try
      AutoSize := False;
      ClearAll;
//      if ColCount > 5 then
//        RemoveCols(0,1);
      ColCount := 9;
      FixedCols := 0;
      FixedColWidth := 18;

      while RowCount > 2 do
        RemoveRows(2,1);

      Cells[0,0] := '��';
      Cells[1,0] := '��Ϲ�ȣ';
      Cells[2,0] := '�����ȣ';
      Cells[3,0] := '�����ڵ�';
      Cells[4,0] := '�԰�';

      Cells[5,0] := '����';
      Cells[6,0] := '�ܰ�';
      Cells[7,0] := '�����ڵ�';
      Cells[8,0] := '�����';

    finally
      AutoSize := True;
      FixedRowAlways := True;
      ColWidths[1] := 0;
      EndUpdate;
    end;
  end;
end;

procedure TfuelPrice_Frm.Update_HiTEMS_FUEL_PRICE;
begin
  with DM1.OraQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Update FUEL_PRICE Set ' +
            'FUELNO = :FUELNO, FUELNAME = :FUELNAME, FUELSTD = :FUELSTD, ' +
            'UNIT = :UNIT, PRICE = :PRICE, SUBCODE = :SUBCODE ' +
            'where FUELINNO LIKE :param1 ');

    ParamByName('param1').AsString   := fuelInNo.Text;

    ParamByName('FUELNO').AsString   := fuelNo.Text;
    ParamByName('FUELNAME').AsString := fuelName.Text;
    ParamByName('FUELSTD').AsString  := fuelStd.Text;
    ParamByName('UNIT').AsString     := fuelUnit.Text;
    ParamByName('PRICE').AsInteger   := fuelPrice.AsInteger;
    ParamByName('SUBCODE').AsString  := SUBCODE.Text;
    ExecSQL;
    ShowMessage(Format('%s ����!',[btn_reg.Caption]));
  end;
end;

end.
