unit w_ShapeFileWriter;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls;

type
  Tf_ShapeFileWriter = class(TForm)
    b_Execute: TButton;
    procedure b_ExecuteClick(Sender: TObject);
  private
  public
  end;

var
  f_ShapeFileWriter: Tf_ShapeFileWriter;

implementation

uses
  u_dzVclUtils,
  u_dzShapeFileWriter;

{$R *.dfm}

type
  TCoords = array[0..59] of Double;

const
  X: TCoords = (
    9.18704312,
    9.18722584,
    9.19658236,
    9.199911,
    9.19995467,
    9.19999408,
    9.200030,
    9.20006635,
    9.20011982,
    9.20014668,
    9.21669486,
    9.21662512,
    9.21669244,
    9.21649149,
    9.21556153,
    9.21550553,
    9.21540981,
    9.21531947,
    9.215207,
    9.215021,
    9.21493338,
    9.214858,
    9.21479264,
    9.21400348,
    9.21375146,
    9.21348055,
    9.21327186,
    9.21304448,
    9.21329477,
    9.21349281,
    9.21369588,
    9.21388078,
    9.214097,
    9.21433434,
    9.21447638,
    9.21463693,
    9.21489803,
    9.21506215,
    9.21551932,
    9.21557202,
    9.21563639,
    9.21571711,
    9.2158,
    9.21586628,
    9.21603639,
    9.21619585,
    9.21629668,
    9.21641413,
    9.21654844,
    9.21662308,
    9.21677247,
    9.21695188,
    9.21768111,
    9.21774784,
    9.220385,
    9.220067,
    9.217760,
    9.21736817,
    9.21693282,
    9.22067852);

  Y: TCoords = (
    48.69794929,
    48.69799673,
    48.69581559,
    48.69355544,
    48.69367699,
    48.69380327,
    48.69392498,
    48.69403163,
    48.69418944,
    48.69427278,
    48.696565,
    48.69672162,
    48.69656621,
    48.69703194,
    48.69923275,
    48.69954806,
    48.69984335,
    48.70007645,
    48.70036992,
    48.70057748,
    48.70068229,
    48.70088376,
    48.70105726,
    48.70132524,
    48.70125756,
    48.70116832,
    48.70107434,
    48.70083144,
    48.70082329,
    48.70080717,
    48.7007958,
    48.70075489,
    48.70073998,
    48.70071538,
    48.70072424,
    48.70069392,
    48.7005454,
    48.70042346,
    48.69889426,
    48.69865547,
    48.69839119,
    48.6981792,
    48.69795681,
    48.69796309,
    48.69770701,
    48.69743701,
    48.6972555,
    48.69701814,
    48.69670974,
    48.69653572,
    48.69620039,
    48.69582783,
    48.69448001,
    48.69428184,
    48.69731939,
    48.69722614,
    48.69700474,
    48.6969,
    48.69687474,
    48.69733279);

procedure Tf_ShapeFileWriter.b_ExecuteClick(Sender: TObject);
var
  Writer: TShapeFileWriterPoint;
  i: Integer;
begin
  Assert(Length(X) = Length(Y));

  Writer := TShapeFileWriterPoint.Create;
  try
    for i := Low(X) to High(X) do
      Writer.AddPoint(X[i], Y[i], i + 1);
    Writer.WriteShpAndShx(TApplication_GetExePathBS + 'shapefileexample');
  finally
    FreeAndNil(Writer);
  end;
end;

end.