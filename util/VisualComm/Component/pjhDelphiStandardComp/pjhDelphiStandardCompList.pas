unit pjhDelphiStandardCompList;

interface

uses Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
    pjhDelphiStandardCompConst, pjhTPanel, pjhTImage, pjhTBevel, pjhTGridPanel,
    pjhTLedPanel, pjhTShadowButton;

  function GetPaletteList: TStringList;
  function GetBplFileName: string;
  //procedure Register;

implementation

function GetPaletteList: TStringList;
var
  LStr: string;
begin
  Result := TStringList.Create;
  LStr := 'Standard =';
  LStr := LStr + 'TpjhTPanel;TpjhTImage;TpjhTBevel;TpjhTGridPanel;TpjhLedPanel;';
  LStr := LStr + 'TpjhTShadowButton;';
  Result.Add(LStr);
end;

function GetBplFileName: string;
begin
  Result := pjhDelphiStandardBplFileName;
end;

exports
  GetPaletteList,
  GetBplFileName;

initialization
//bpl�� �������� �ε��� RegisterClass�ص� GetClass�ÿ� nil�� return �Ǵ� ���� �߻�
//�ذ�: exe�� bpl project option���� vcl.dcp�� rtl.dcp�� ��������(release version)
  //RegisterClasses([TpjhIfControl,TpjhGotoControl,TpjhStartControl,TpjhStopControl,TpjhDelay,TpjhSetTimer,TpjhIFTimer]);
  RegisterClasses([TpjhTPanel,TpjhTImage,TpjhTBevel,TpjhTGridPanel,TpjhLedPanel, TpjhTShadowButton]);
//  RegisterClasses([TpjhTShadowButton]);

finalization
  //UnRegisterClasses([TpjhIfControl,TpjhGotoControl,TpjhStartControl,TpjhStopControl,TpjhDelay,TpjhSetTimer,TpjhIFTimer]);
  UnRegisterClasses([TpjhTPanel,TpjhTImage,TpjhTBevel,TpjhTGridPanel,TpjhLedPanel, TpjhTShadowButton]);
//  UnRegisterClasses([TpjhTShadowButton]);

end.