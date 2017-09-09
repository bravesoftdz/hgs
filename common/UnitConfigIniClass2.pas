{����:
  1. Config Form�� Control.hint = ���� ���� �Ǵ� �ʵ��(��: Caption �Ǵ� Value �Ǵ� Text)�� ���� ��
    1) Ini ���� Config Form(AForm)�� Load�� ȣ��:
      FSettings.LoadConfig2Form(AForm, FSettings);
    2) Config Form�� ������ Ini�� Save �� ȣ��:
      FSettings.LoadConfigForm2Object(AForm, FSettings);
  2. Control.Tag�� 1���� �ߺ����� �ʰ� �Է���
}
unit UnitConfigIniClass2;

interface

uses SysUtils, Vcl.Controls, Forms, Rtti, TypInfo, IniPersist;

type
  TINIConfigBase = class (TObject)
  private
    FIniFileName: string;
  public
    constructor create(AFileName: string);

    property IniFileName : String read FIniFileName write FIniFileName;

    procedure Save(AFileName: string = '');
    procedure Load(AFileName: string = '');

    procedure LoadConfig2Form(AForm: TForm; ASettings: TObject);
    procedure LoadConfigForm2Object(AForm: TForm; ASettings: TObject);
  end;

implementation

function strToken(var S: String; Seperator: Char): String;
var
  I: Word;
begin
  I:=Pos(Seperator,S);
  if I<>0 then
  begin
    Result:=System.Copy(S,1,I-1);
    System.Delete(S,1,I);
  end else
  begin
    Result:=S;
    S:='';
  end;
end;

{ TINIConfigBase }

constructor TINIConfigBase.create(AFileName: string);
begin
  FIniFileName := AFileName;
end;

procedure TINIConfigBase.Load(AFileName: string);
begin
  if AFileName = '' then
    AFileName := FIniFileName;

  TIniPersist.Load(AFileName, Self);
end;

//Component�� Hint�� ���� ����Ǵ� �ʵ���� ����Ǿ� �־�� ��
procedure TINIConfigBase.LoadConfig2Form(AForm: TForm; ASettings: TObject);
var
  ctx, ctx2 : TRttiContext;
  objType, objType2 : TRttiType;
  Prop, Prop2  : TRttiProperty;
  Value : TValue;
  IniValue : IniValueAttribute;
//  Data : String;
  LControl: TControl;

  i, LTagNo: integer;
  LStr: string;
begin
  ctx := TRttiContext.Create;
  ctx2 := TRttiContext.Create;
  try
    objType2 := ctx2.GetType(ASettings.ClassInfo);

    for i := 0 to AForm.ComponentCount - 1 do
    begin
      LControl := TControl(AForm.Components[i]);
      LStr := LControl.Hint; //Caption �Ǵ� Text �Ǵ� Value
      LTagNo := LControl.Tag;

      if LStr = '' then
        Continue;

      objType := ctx.GetType(LControl.ClassInfo);

      Prop := nil;
      Prop := objType.GetProperty(LStr);

      if Assigned(Prop) then
      begin
        for Prop2 in objType2.GetProperties do
        begin
          IniValue := TIniPersist.GetIniAttribute(Prop2);

          if Assigned(IniValue) then
          begin
            if IniValue.TagNo = LTagNo then
            begin
              Value := Prop2.GetValue(ASettings);
//              Data := TIniPersist.GetValue(Value);
              Prop.SetValue(LControl, Value);
              break;
            end;
          end;
        end;
      end;
    end;
 finally
   ctx.Free;
   ctx2.Free;
 end;
end;

procedure TINIConfigBase.LoadConfigForm2Object(AForm: TForm; ASettings: TObject);
var
  ctx, ctx2 : TRttiContext;
  objType, objType2 : TRttiType;
  Prop, Prop2  : TRttiProperty;
  Value : TValue;
  IniValue : IniValueAttribute;
  Data : String;
  LControl: TControl;

  i, LTagNo: integer;
  LStr: string;
begin
  ctx := TRttiContext.Create;
  ctx2 := TRttiContext.Create;
  try
    objType2 := ctx2.GetType(ASettings.ClassInfo);

    for i := 0 to AForm.ComponentCount - 1 do
    begin
      LControl := TControl(AForm.Components[i]);
      LStr := LControl.Hint; //Caption �Ǵ� Text �Ǵ� Value
      LTagNo := LControl.Tag;

      if LStr = '' then
        Continue;

      objType := ctx.GetType(LControl.ClassInfo);

      Prop := nil;
      Prop := objType.GetProperty(LStr);

      if Assigned(Prop) then
      begin
        for Prop2 in objType2.GetProperties do
        begin
          IniValue := TIniPersist.GetIniAttribute(Prop2);

          if Assigned(IniValue) then
          begin
            if IniValue.TagNo = LTagNo then
            begin
              Value := Prop.GetValue(LControl);
//              Data := TIniPersist.GetValue(Value);
//              TIniPersist.SetValue(Data, Value, Prop2.PropertyType.TypeKind);
              Prop2.SetValue(ASettings, Value);
              break;
            end;
          end;
        end;
      end;
    end;
  finally
   ctx.Free;
   ctx2.Free;
  end;
end;

procedure TINIConfigBase.Save(AFileName: string);
begin
  if AFileName = '' then
    AFileName := FIniFileName;

  // This saves the properties to the INI
  TIniPersist.Save(AFileName ,Self);
end;

end.