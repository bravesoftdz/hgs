object Form2: TForm2
  Left = 69
  Top = 77
  Caption = #49892#49884#44036' '#44221#50689' '#51221#48372' '#54788#54889
  ClientHeight = 750
  ClientWidth = 1525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 377
    Width = 1525
    Height = 7
    Cursor = crVSplit
    Align = alTop
    ExplicitLeft = -8
    ExplicitTop = 364
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 681
    Width = 1525
    Height = 7
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 643
    ExplicitWidth = 1128
  end
  object Chart1: TChart
    Left = 0
    Top = 80
    Width = 1525
    Height = 297
    BackWall.Brush.Gradient.Direction = gdBottomTop
    BackWall.Brush.Gradient.EndColor = clBlack
    BackWall.Brush.Gradient.MidColor = clSilver
    BackWall.Brush.Gradient.StartColor = clBlack
    BackWall.Brush.Gradient.Visible = True
    BackWall.Color = clBlack
    BackWall.Transparent = False
    Foot.Font.Name = 'Verdana'
    Gradient.Direction = gdBottomTop
    Gradient.EndColor = clWhite
    Gradient.MidColor = 15395562
    Gradient.StartColor = clSilver
    Gradient.SubGradient.Transparency = 98
    Gradient.Visible = True
    LeftWall.Color = 14745599
    Legend.Alignment = laTop
    Legend.Font.Name = 'Verdana'
    Legend.ShapeStyle = fosRoundRectangle
    Legend.TopPos = 40
    MarginBottom = 1
    MarginLeft = 1
    MarginRight = 1
    MarginTop = 1
    RightWall.Color = 14745599
    SubFoot.Font.Name = 'Verdana'
    SubTitle.Font.Name = 'Verdana'
    Title.Font.Color = clBlack
    Title.Font.Height = -19
    Title.Font.Name = #47569#51008' '#44256#46357
    Title.Font.Style = [fsBold]
    Title.Text.Strings = (
      #50900#48324' '#49688#51452' '#54788#54889)
    BottomAxis.Axis.Color = 4210752
    BottomAxis.Grid.Color = 11119017
    BottomAxis.LabelsFont.Name = 'Verdana'
    BottomAxis.TicksInner.Color = 11119017
    BottomAxis.Title.Font.Name = 'Verdana'
    DepthAxis.Axis.Color = 4210752
    DepthAxis.Grid.Color = 11119017
    DepthAxis.LabelsFont.Name = 'Verdana'
    DepthAxis.TicksInner.Color = 11119017
    DepthAxis.Title.Font.Name = 'Verdana'
    DepthTopAxis.Axis.Color = 4210752
    DepthTopAxis.Grid.Color = 11119017
    DepthTopAxis.LabelsFont.Name = 'Verdana'
    DepthTopAxis.TicksInner.Color = 11119017
    DepthTopAxis.Title.Font.Name = 'Verdana'
    LeftAxis.Axis.Color = 4210752
    LeftAxis.ExactDateTime = False
    LeftAxis.Grid.Color = 11119017
    LeftAxis.Increment = 100.000000000000000000
    LeftAxis.LabelsFont.Name = 'Verdana'
    LeftAxis.TicksInner.Color = 11119017
    LeftAxis.Title.Caption = #45800#50948': '#48177#47564#50896
    LeftAxis.Title.Font.Name = 'Verdana'
    RightAxis.Axis.Color = 4210752
    RightAxis.Grid.Color = 11119017
    RightAxis.LabelsFont.Name = 'Verdana'
    RightAxis.TicksInner.Color = 11119017
    RightAxis.Title.Font.Name = 'Verdana'
    RightAxis.Visible = False
    Shadow.Visible = False
    TopAxis.Axis.Color = 4210752
    TopAxis.Grid.Color = 11119017
    TopAxis.LabelsFont.Name = 'Verdana'
    TopAxis.TicksInner.Color = 11119017
    TopAxis.Title.Font.Name = 'Verdana'
    TopAxis.Visible = False
    View3D = False
    Align = alTop
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 0
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 16
    object Series1: TBarSeries
      LegendTitle = 'fafd'
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.ShapeStyle = fosRoundRectangle
      Marks.Visible = False
      Emboss.Color = 8684676
      MultiBar = mbStacked
      Shadow.Color = 8684676
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Bar'
      YValues.Order = loNone
      Data = {
        00060000000000000000E06F400000000000D06B400000000000406A40000000
        0000F064400000000000906F400000000000B06D40}
    end
    object Series2: TBarSeries
      BarPen.Color = clWhite
      BarPen.Style = psDot
      BarPen.Width = 3
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.ShapeStyle = fosRoundRectangle
      Marks.Visible = False
      SeriesColor = clWhite
      Emboss.Color = 8882055
      MultiBar = mbStacked
      Shadow.Color = 8882055
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Bar'
      YValues.Order = loNone
      Data = {
        000600000034333333338B484068666666669647409A99999999D951409A9999
        9999A146406866666666364140CECCCCCCCC444740}
    end
    object Series3: TBezierSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.ShapeStyle = fosRoundRectangle
      Marks.Visible = False
      SeriesColor = 33023
      LinePen.Color = 33023
      LinePen.Width = 3
      Pointer.Brush.Gradient.EndColor = 33023
      Pointer.Emboss.Visible = True
      Pointer.Gradient.EndColor = 33023
      Pointer.HorizSize = 6
      Pointer.InflateMargins = True
      Pointer.Style = psCircle
      Pointer.VertSize = 6
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series4: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.ShapeStyle = fosRoundRectangle
      Marks.Visible = False
      Brush.BackColor = clDefault
      Pointer.Brush.Gradient.EndColor = 14456410
      Pointer.Gradient.EndColor = 14456410
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1525
    Height = 41
    Align = alTop
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 0
    Top = 709
    Width = 1525
    Height = 41
    Align = alBottom
    TabOrder = 2
  end
  object Chart3: TChart
    Left = 0
    Top = 688
    Width = 1525
    Height = 21
    BackWall.Brush.Gradient.Direction = gdBottomTop
    BackWall.Brush.Gradient.EndColor = 11323391
    BackWall.Brush.Gradient.StartColor = 11783167
    BackWall.Brush.Gradient.Visible = True
    BackWall.Transparent = False
    Foot.Font.Name = 'Verdana'
    Gradient.Direction = gdBottomTop
    Gradient.EndColor = clWhite
    Gradient.MidColor = 15395562
    Gradient.StartColor = 15395562
    Gradient.Visible = True
    LeftWall.Color = 14745599
    Legend.Alignment = laTop
    Legend.Font.Name = 'Verdana'
    RightWall.Color = 14745599
    SubFoot.Font.Name = 'Verdana'
    SubTitle.Font.Name = 'Verdana'
    Title.Font.Color = clRed
    Title.Font.Height = -19
    Title.Font.Name = #47569#51008' '#44256#46357
    Title.Font.Style = [fsBold]
    Title.Text.Strings = (
      #50900#48324' '#49552#51061' '#54788#54889)
    BottomAxis.Axis.Color = 4210752
    BottomAxis.Grid.Color = 11119017
    BottomAxis.LabelsFont.Name = 'Verdana'
    BottomAxis.TicksInner.Color = 11119017
    BottomAxis.Title.Font.Name = 'Verdana'
    DepthAxis.Axis.Color = 4210752
    DepthAxis.Grid.Color = 11119017
    DepthAxis.LabelsFont.Name = 'Verdana'
    DepthAxis.TicksInner.Color = 11119017
    DepthAxis.Title.Font.Name = 'Verdana'
    DepthTopAxis.Axis.Color = 4210752
    DepthTopAxis.Grid.Color = 11119017
    DepthTopAxis.LabelsFont.Name = 'Verdana'
    DepthTopAxis.TicksInner.Color = 11119017
    DepthTopAxis.Title.Font.Name = 'Verdana'
    LeftAxis.Axis.Color = 4210752
    LeftAxis.Grid.Color = 11119017
    LeftAxis.LabelsFont.Name = 'Verdana'
    LeftAxis.TicksInner.Color = 11119017
    LeftAxis.Title.Font.Name = 'Verdana'
    RightAxis.Axis.Color = 4210752
    RightAxis.Grid.Color = 11119017
    RightAxis.LabelsFont.Name = 'Verdana'
    RightAxis.TicksInner.Color = 11119017
    RightAxis.Title.Font.Name = 'Verdana'
    TopAxis.Axis.Color = 4210752
    TopAxis.Grid.Color = 11119017
    TopAxis.LabelsFont.Name = 'Verdana'
    TopAxis.TicksInner.Color = 11119017
    TopAxis.Title.Font.Name = 'Verdana'
    View3D = False
    Align = alClient
    TabOrder = 3
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
  end
  object NxExpandPanel1: TNxExpandPanel
    Left = 0
    Top = 41
    Width = 1525
    Height = 39
    Align = alTop
    Color = 15790320
    Expanded = False
    ParentColor = False
    TabOrder = 4
    FullHeight = 145
    object AdvStringGrid1: TAdvStringGrid
      Left = 0
      Top = 39
      Width = 1525
      Height = 0
      Cursor = crDefault
      Align = alClient
      DrawingStyle = gdsClassic
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      Visible = False
      ActiveCellFont.Charset = DEFAULT_CHARSET
      ActiveCellFont.Color = clWindowText
      ActiveCellFont.Height = -11
      ActiveCellFont.Name = 'Tahoma'
      ActiveCellFont.Style = [fsBold]
      ControlLook.FixedGradientHoverFrom = clGray
      ControlLook.FixedGradientHoverTo = clWhite
      ControlLook.FixedGradientDownFrom = clGray
      ControlLook.FixedGradientDownTo = clSilver
      ControlLook.DropDownHeader.Font.Charset = DEFAULT_CHARSET
      ControlLook.DropDownHeader.Font.Color = clWindowText
      ControlLook.DropDownHeader.Font.Height = -11
      ControlLook.DropDownHeader.Font.Name = 'Tahoma'
      ControlLook.DropDownHeader.Font.Style = []
      ControlLook.DropDownHeader.Visible = True
      ControlLook.DropDownHeader.Buttons = <>
      ControlLook.DropDownFooter.Font.Charset = DEFAULT_CHARSET
      ControlLook.DropDownFooter.Font.Color = clWindowText
      ControlLook.DropDownFooter.Font.Height = -11
      ControlLook.DropDownFooter.Font.Name = 'Tahoma'
      ControlLook.DropDownFooter.Font.Style = []
      ControlLook.DropDownFooter.Visible = True
      ControlLook.DropDownFooter.Buttons = <>
      Filter = <>
      FilterDropDown.Font.Charset = DEFAULT_CHARSET
      FilterDropDown.Font.Color = clWindowText
      FilterDropDown.Font.Height = -11
      FilterDropDown.Font.Name = 'Tahoma'
      FilterDropDown.Font.Style = []
      FilterDropDownClear = '(All)'
      FixedRowHeight = 22
      FixedFont.Charset = DEFAULT_CHARSET
      FixedFont.Color = clWindowText
      FixedFont.Height = -11
      FixedFont.Name = 'Tahoma'
      FixedFont.Style = [fsBold]
      FloatFormat = '%.2f'
      PrintSettings.DateFormat = 'dd/mm/yyyy'
      PrintSettings.Font.Charset = DEFAULT_CHARSET
      PrintSettings.Font.Color = clWindowText
      PrintSettings.Font.Height = -11
      PrintSettings.Font.Name = 'Tahoma'
      PrintSettings.Font.Style = []
      PrintSettings.FixedFont.Charset = DEFAULT_CHARSET
      PrintSettings.FixedFont.Color = clWindowText
      PrintSettings.FixedFont.Height = -11
      PrintSettings.FixedFont.Name = 'Tahoma'
      PrintSettings.FixedFont.Style = []
      PrintSettings.HeaderFont.Charset = DEFAULT_CHARSET
      PrintSettings.HeaderFont.Color = clWindowText
      PrintSettings.HeaderFont.Height = -11
      PrintSettings.HeaderFont.Name = 'Tahoma'
      PrintSettings.HeaderFont.Style = []
      PrintSettings.FooterFont.Charset = DEFAULT_CHARSET
      PrintSettings.FooterFont.Color = clWindowText
      PrintSettings.FooterFont.Height = -11
      PrintSettings.FooterFont.Name = 'Tahoma'
      PrintSettings.FooterFont.Style = []
      PrintSettings.PageNumSep = '/'
      SearchFooter.FindNextCaption = 'Find &next'
      SearchFooter.FindPrevCaption = 'Find &previous'
      SearchFooter.Font.Charset = DEFAULT_CHARSET
      SearchFooter.Font.Color = clWindowText
      SearchFooter.Font.Height = -11
      SearchFooter.Font.Name = 'Tahoma'
      SearchFooter.Font.Style = []
      SearchFooter.HighLightCaption = 'Highlight'
      SearchFooter.HintClose = 'Close'
      SearchFooter.HintFindNext = 'Find next occurrence'
      SearchFooter.HintFindPrev = 'Find previous occurrence'
      SearchFooter.HintHighlight = 'Highlight occurrences'
      SearchFooter.MatchCaseCaption = 'Match case'
      Version = '6.1.1.0'
      ExplicitLeft = 48
      ExplicitTop = 56
      ExplicitWidth = 400
      ExplicitHeight = 250
    end
    object Button1: TButton
      Left = 96
      Top = 8
      Width = 89
      Height = 25
      Caption = 'Load File'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 192
      Top = 8
      Width = 81
      Height = 25
      Caption = 'Apply Chart'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 280
      Top = 8
      Width = 81
      Height = 25
      Caption = 'Get Query'
      TabOrder = 3
      OnClick = Button3Click
    end
  end
  object Chart2: TChart
    Left = 0
    Top = 384
    Width = 1525
    Height = 297
    BackWall.Brush.Gradient.Direction = gdBottomTop
    BackWall.Brush.Gradient.EndColor = 8404992
    BackWall.Brush.Gradient.MidColor = clSilver
    BackWall.Brush.Gradient.StartColor = 8404992
    BackWall.Brush.Gradient.Visible = True
    BackWall.Color = clBlack
    BackWall.Transparent = False
    Foot.Font.Name = 'Verdana'
    Gradient.Direction = gdBottomTop
    Gradient.EndColor = clWhite
    Gradient.MidColor = 15395562
    Gradient.StartColor = clSilver
    Gradient.SubGradient.Transparency = 98
    Gradient.Visible = True
    LeftWall.Color = 14745599
    Legend.Alignment = laTop
    Legend.Font.Name = 'Verdana'
    Legend.ShapeStyle = fosRoundRectangle
    Legend.TopPos = 40
    MarginBottom = 1
    MarginLeft = 1
    MarginRight = 1
    MarginTop = 1
    RightWall.Color = 14745599
    SubFoot.Font.Name = 'Verdana'
    SubTitle.Font.Name = 'Verdana'
    Title.Font.Height = -19
    Title.Font.Name = #47569#51008' '#44256#46357
    Title.Font.Style = [fsBold]
    Title.Text.Strings = (
      #50900#48324' '#47588#52636' '#54788#54889)
    BottomAxis.Axis.Color = 4210752
    BottomAxis.Grid.Color = 11119017
    BottomAxis.LabelsFont.Name = 'Verdana'
    BottomAxis.TicksInner.Color = 11119017
    BottomAxis.Title.Font.Name = 'Verdana'
    DepthAxis.Axis.Color = 4210752
    DepthAxis.Grid.Color = 11119017
    DepthAxis.LabelsFont.Name = 'Verdana'
    DepthAxis.TicksInner.Color = 11119017
    DepthAxis.Title.Font.Name = 'Verdana'
    DepthTopAxis.Axis.Color = 4210752
    DepthTopAxis.Grid.Color = 11119017
    DepthTopAxis.LabelsFont.Name = 'Verdana'
    DepthTopAxis.TicksInner.Color = 11119017
    DepthTopAxis.Title.Font.Name = 'Verdana'
    LeftAxis.Axis.Color = 4210752
    LeftAxis.ExactDateTime = False
    LeftAxis.Grid.Color = 11119017
    LeftAxis.Increment = 100.000000000000000000
    LeftAxis.LabelsFont.Name = 'Verdana'
    LeftAxis.TicksInner.Color = 11119017
    LeftAxis.Title.Caption = #45800#50948': '#48177#47564#50896
    LeftAxis.Title.Font.Name = 'Verdana'
    RightAxis.Axis.Color = 4210752
    RightAxis.Grid.Color = 11119017
    RightAxis.LabelsFont.Name = 'Verdana'
    RightAxis.TicksInner.Color = 11119017
    RightAxis.Title.Font.Name = 'Verdana'
    RightAxis.Visible = False
    Shadow.Visible = False
    TopAxis.Axis.Color = 4210752
    TopAxis.Grid.Color = 11119017
    TopAxis.LabelsFont.Name = 'Verdana'
    TopAxis.TicksInner.Color = 11119017
    TopAxis.Title.Font.Name = 'Verdana'
    TopAxis.Visible = False
    View3D = False
    Align = alTop
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 5
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 14
    object BarSeries1: TBarSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.ShapeStyle = fosRoundRectangle
      Marks.Visible = False
      Emboss.Color = 8684676
      MultiBar = mbStacked
      Shadow.Color = 8684676
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Bar'
      YValues.Order = loNone
      Data = {
        00060000000000000000E06F400000000000D06B400000000000406A40000000
        0000F064400000000000906F400000000000B06D40}
    end
    object BarSeries2: TBarSeries
      BarPen.Color = clWhite
      BarPen.Style = psDot
      BarPen.Width = 3
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.ShapeStyle = fosRoundRectangle
      Marks.Visible = False
      SeriesColor = clWhite
      Emboss.Color = 8882055
      MultiBar = mbStacked
      Shadow.Color = 8882055
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Bar'
      YValues.Order = loNone
      Data = {
        000600000034333333338B484068666666669647409A99999999D951409A9999
        9999A146406866666666364140CECCCCCCCC444740}
    end
    object BezierSeries1: TBezierSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.ShapeStyle = fosRoundRectangle
      Marks.Visible = False
      SeriesColor = 33023
      LinePen.Color = 33023
      LinePen.Width = 3
      Pointer.Brush.Gradient.EndColor = 33023
      Pointer.Emboss.Visible = True
      Pointer.Gradient.EndColor = 33023
      Pointer.HorizSize = 6
      Pointer.InflateMargins = True
      Pointer.Style = psCircle
      Pointer.VertSize = 6
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 15
    Top = 4
  end
  object TeeExcelSource1: TTeeExcelSource
    Left = 104
    Top = 8
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 56
    Top = 8
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    OnRedirect = IdHTTP1Redirect
    Left = 144
    Top = 8
  end
end