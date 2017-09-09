program ModbusMapConfp;

uses
  Forms,
  ModbusMapConfUint in 'ModbusMapConfUint.pas' {Form1},
  String_Func in 'common\String_Func.pas',
  EngineParameterClass in '..\HiMECS\Application\Source\Common\EngineParameterClass.pas',
  BaseConfigCollect in '..\HiMECS\Application\Source\Common\BaseConfigCollect.pas',
  HiMECSConst in '..\HiMECS\Application\Source\Common\HiMECSConst.pas',
  SynCommons in '..\..\Common\mORMot\SynCommons.pas',
  UnitEncrypt in '..\..\Common\UnitEncrypt.pas',
  DBSelectUint in 'DBSelectUint.pas' {DBSelectForm},
  UnitSetMatrix in '..\HiMECS\Application\Source\Forms\UnitSetMatrix.pas' {SetMatrixForm},
  ModbusComConst_endurance in '..\HiMECS\Application\Utility\ModbusComm_����������\ModbusComConst_endurance.pas',
  UnitEngParamConfig in '..\HiMECS\Application\Source\Forms\UnitEngParamConfig.pas' {EngParamItemConfigForm},
  UnitSelectUser in '..\HiMECS\Application\Source\Forms\UnitSelectUser.pas' {SelectUserF};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDBSelectForm, DBSelectForm);
  Application.CreateForm(TSetMatrixForm, SetMatrixForm);
  Application.CreateForm(TEngParamItemConfigForm, EngParamItemConfigForm);
  Application.CreateForm(TSelectUserF, SelectUserF);
  Application.Run;
end.