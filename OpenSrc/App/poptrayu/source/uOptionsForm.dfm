object OptionsForm: TOptionsForm
  Left = 0
  Top = 0
  Caption = 'OptionsForm'
  ClientHeight = 341
  ClientWidth = 481
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object panOptionButtons: TPanel
    Left = 0
    Top = 309
    Width = 481
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 2
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      481
      32)
    object btnHintHelp: TSpeedButton
      Left = 76
      Top = 3
      Width = 25
      Height = 25
      Hint = 'Quick Help'
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        04000000000080000000130B0000130B00001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7777777777007777777777777700777777777777700777700777707770077770
        0777700700777777777770000077777007777000000007700777700000007777
        0077700000077777700770000077700777007000077700777700700077770077
        7700700777777007770070777777770000077777777777777777}
      ParentShowHint = False
      ShowHint = True
      OnClick = btnHintHelpClick
    end
    object lblTest: TLabel
      Left = 133
      Top = 6
      Width = 3
      Height = 13
      Visible = False
    end
    object btnHelpOptions: TPngBitBtn
      Left = 8
      Top = 3
      Width = 65
      Height = 25
      Caption = '&Help'
      TabOrder = 0
      OnClick = btnHelpOptionsClick
      PngImage.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        61000003144944415478DA75936B4853611CC61FCFB6E3DCA62E333DEA36D734
        6F119AB72ED20D89CA2F9A61D185886E041554D205024BFA2041F4A108822823
        63A5945241885DA8344D0BD73D2F35B5B636E7DCF46C67DBD9D9D93AECC3A0B4
        FFC7F77D9EDFFBF0BECF1B8559A6FEED14F5C2C86667259347E44420AFFB177F
        EFCD76EAF46CDAA87F1756349997ADCD53EC1BB27359063B5766FBE5428C5444
        FF3C92113F2B604DD3982A554696C5C8445B292559C9723CAEBDA7A11373480A
        71F8E4F0C33C19844A33E783E998AE6006A0A167CAA99B1FAFECB5B2308CBAF1
        D9C2A2AE44864345C22E3309CE3A81C287243E9B44C8502B5A7E1CCDDCF217A0
        E681855F9593487CF585306CF64047F2B85A9E80964F0E989C348EE9A6B1B72B
        88EBEF0810D210326265FB874F655F8B00322E0D799312E4D2936B5371CFC8C2
        4B33A0C4415CE967B14507DC5DEDC286561EED4689209F868C10819290CB8D67
        17F5840109C7FBEA1DA4A2EE4CA5062929723C31329870B0F832CEE261B918C5
        4A37B4B7395868411DE401BF1B724282C4809F1A3BBF643CFC0AE2C3BD3F25DA
        79EA1B9BD4F8C8843062F7A177CC07FD4A124B950C74B7588CD03C44A11078CE
        07F02CE202223ACEE59E1B06A80EBE2A3091324369A90AF5E5C96816CCF6092F
        2C0C8F1DE93C7E5818DC1C0202011E3E2E28A4F00869428863B8B6480FE47B9F
        3532C9D4AE13151A14EA14D00FBA20F2F1685D27164EB4A3B03188012701AF5F
        B0385C82C305852F30100124ED6C276DD1D1D34496467AB35A83118EC0EB5106
        0732019B9B436D9F183EEB6FA404ACD8964D604F71122A2E5973FE6A626C75EB
        669746DD9C5FA4C2C50A0A6D36E0D9B0176EB319254E03AA72E3B1B1200D0AED
        C2B03EEF60877E4695C99A072FFCB999ABB6AE48472E46E13574A12C8D4469F1
        62CCD352822011BDDF27F1A8CB8286FB83C33300F2F5FAB94C6AAA5D9DAFC6ED
        B46E642F48036294608262DC31B078DC3981EE0FE34F31C93660E0C0F31980F0
        9435D51654E55CE8D82C46E7208BE6BE29B474D18370326DC2ED9FC3DBDD9EFF
        FEC648924AFD4B4D7AE2CA6FFDA6CBF0E02EFA7777CFA6FB03CB4E49A33B4AE8
        A90000000049454E44AE426082}
    end
    object btnCancel: TBitBtn
      Left = 402
      Top = 3
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      Glyph.Data = {
        36060000424D3606000000000000360000002800000020000000100000000100
        18000000000000060000230B0000230B00000000000000000000008284008284
        6E6E6E6E6E6E0082840082840082840082840082840082840082840082840082
        84008284008284008284008284008284008284FFFFFF00828400828400828400
        82840082840082840082840082840082840082840082840082840082843159FF
        0029DA0019B06E6E6E0082840082840082840082840082843159FF6E6E6E0082
        84008284008284008284008284008284848284848284FFFFFF00828400828400
        8284008284008284008284FFFFFF0082840082840082840082840082843159FF
        0030EF0029DA0019B06E6E6E0082840082840082843159FF0020CE0019B06E6E
        6E008284008284008284008284848284FFFFFF008284848284FFFFFF00828400
        8284008284FFFFFF848284848284FFFFFF0082840082840082840082846382FF
        0030EF0030EF0029DA0019B06E6E6E0082843159FF0020CE0020CE0020CE0019
        B06E6E6E008284008284008284848284FFFFFF008284008284848284FFFFFF00
        8284FFFFFF848284008284008284848284FFFFFF008284008284008284008284
        6382FF0030EF0030EF0029DA0019B06E6E6E0029DA0020CE0020CE0020CE0019
        B06E6E6E008284008284008284848284FFFFFF008284008284008284848284FF
        FFFF848284008284008284008284008284848284FFFFFF008284008284008284
        0082846382FF0030EF0030EF0029DA0029DA0029DA0029DA0020CE0020CE6E6E
        6E008284008284008284008284008284848284FFFFFF00828400828400828484
        8284008284008284008284008284FFFFFF848284008284008284008284008284
        0082840082846382FF0030EF0029DA0029DA0029DA0029DA0029DA6E6E6E0082
        84008284008284008284008284008284008284848284FFFFFF00828400828400
        8284008284008284008284FFFFFF848284008284008284008284008284008284
        0082840082840082840030EF0030EF0029DA0029DA0019B06E6E6E0082840082
        84008284008284008284008284008284008284008284848284FFFFFF00828400
        8284008284008284008284848284008284008284008284008284008284008284
        0082840082840082843159FF0030EF0030EF0029DA0019B06E6E6E0082840082
        84008284008284008284008284008284008284008284008284848284FFFFFF00
        8284008284008284848284008284008284008284008284008284008284008284
        0082840082843159FF0030EF0030EF0030EF0030EF0019B06E6E6E0082840082
        8400828400828400828400828400828400828400828400828484828400828400
        8284008284008284848284FFFFFF008284008284008284008284008284008284
        0082843159FF0030EF0030EF0030EF6E6E6E0030EF0029DA0019B06E6E6E0082
        8400828400828400828400828400828400828400828484828400828400828400
        8284008284008284848284FFFFFF008284008284008284008284008284008284
        6382FF0030EF0030EF0030EF6E6E6E0082843159FF0030EF0029DA0019B06E6E
        6E00828400828400828400828400828400828484828400828400828400828484
        8284FFFFFF008284008284848284FFFFFF008284008284008284008284008284
        6382FF0030EF0020CE6E6E6E0082840082840082846382FF0030EF0029DA0019
        B06E6E6E008284008284008284008284848284FFFFFF00828400828484828400
        8284848284FFFFFF008284008284848284FFFFFF008284008284008284008284
        0082846382FF0030EF0082840082840082840082840082846382FF0030EF0030
        EF0029DA008284008284008284008284848284FFFFFFFFFFFF84828400828400
        8284008284848284FFFFFF008284008284848284FFFFFF008284008284008284
        0082840082840082840082840082840082840082840082840082846382FF0030
        EF0029DA00828400828400828400828400828484828484828400828400828400
        8284008284008284848284FFFFFFFFFFFFFFFFFF848284008284008284008284
        0082840082840082840082840082840082840082840082840082840082840082
        8400828400828400828400828400828400828400828400828400828400828400
        8284008284008284008284848284848284848284008284008284}
      NumGlyphs = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
    object btnSaveOptions: TBitBtn
      Left = 280
      Top = 3
      Width = 113
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Save Options'
      Default = True
      Glyph.Data = {
        36060000424D3606000000000000360000002800000020000000100000000100
        18000000000000060000230B0000230B0000000000000000000000FF0000FF00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF
        0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
        8080806363636363635050505050504040404040404040404040404040404040
        4040404050505063636300FF0000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
        AA5000D36605C85E00B5B2B5B5B2B5B5B2B5B5B2B5B5B2B5B5B2B59B49009B49
        00D36605D3660550505000FF0000FF006F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F
        6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F55555500FF0000FF0000FF00FF973B
        ED801FED801FD36605AD9E9CFC8F2EDEB6B5FFFBFFF7F3F7E7E7E79B49009B49
        00ED801FD3660540404000FF0087878700FF0000FF006F6F6F9F9F9F00FF0000
        FF0000FF0000FF00E7E7E76F6F6F00FF006F6F6F00FF0000FF0000FF00FF973B
        ED801FED801FD36605CEB6B5DB6E0DFFA24FDEDBDEFFFBFFF7F3F79B49009B49
        00ED801FD3660540404000FF0087878700FF0000FF006F6F6FB8B8B800FF0000
        FF0000FF0000FF00E7E7E76F6F6F00FF006F6F6F00FF0000FF0000FF00FF973B
        ED801FED801FD36605E7C7C6C85E00F98C2BB5B2B5DEDBDEFFFBFF9B49009B49
        00ED801FD3660540404000FF0087878700FF0000FF006F6F6FCACACA00FF0000
        FF0000FF0000FF00E7E7E76F6F6F00FF006F6F6F00FF0000FF0000FF00FF973B
        ED801FED801FD36605DECBCECE9694CEB2B5ADAAADB5B2B5D6CFCE9B4900A14C
        00ED801FD3660540404000FF0087878700FF0000FF006F6F6FCECECE9C9C9CB6
        B6B6ABABABB3B3B3CFCFCF6F6F6F00FF006F6F6F00FF0000FF0000FF00FF973B
        ED801FED801FED801FED801FED801FED801FED801FED801FED801FED801FED80
        1FED801FD3660540404000FF0087878700FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF0000FF006F6F6F00FF0000FF0000FF00FF973B
        ED801FED801FFFA24FFFA24FFFA24FFFA24FFFA24FFFA24FFFA24FFFA24FED80
        1FED801FD3660540404000FF0087878700FF0000FF0093939393939393939393
        939393939393939393939393939300FF006F6F6F00FF0000FF0000FF00FF973B
        ED801FFFA24FFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFA2
        4FED801FD3660550505000FF0087878700FF0093939300FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF009393936F6F6F00FF0000FF0000FF00FF973B
        ED801FFFA24FFFFBFFC6C3C6C6C3C6C6C3C6C6C7C6C6C7C6C6C7C6FFFBFFFFA2
        4FED801FD3660550505000FF0087878700FF0093939300FF00C4C4C4C4C4C4C4
        C4C4C7C7C7C7C7C7C7C7C700FF009393936F6F6F00FF0000FF0000FF00FF973B
        ED801FFFA24FFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFA2
        4FED801FD3660563636300FF0087878700FF0093939300FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF009393936F6F6F00FF0000FF0000FF00FF973B
        ED801FFFA24FFFFBFFBDBEBDC6C3C6C6C3C6C6C3C6C6C7C6C6C7C6FFFBFFFFA2
        4FED801FD3660563636300FF0087878700FF0093939300FF00BDBEBDC6C3C6C6
        C3C6C6C3C6C6C7C6C6C7C600FF009393936F6F6F00FF0000FF0000FF00FF973B
        ED801FFFA24FFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFFBFFFFA2
        4FED801FD3660580808000FF0087878700FF0093939300FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF009393936F6F6F00FF0000FF0000FF00FF973B
        D36605FFA24F0000C00000C00000C00000C00000C00000C00000C00000C0FFA2
        4FD3660500FF0000FF0000FF008787876F6F6F9393936F6F6F6F6F6F6F6F6F6F
        6F6F6F6F6F6F6F6F6F6F6F6F6F6F93939355555500FF0000FF0000FF0000FF00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF
        0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00}
      NumGlyphs = 2
      TabOrder = 2
      OnClick = btnSaveOptionsClick
    end
  end
  object panOptionPage: TPanel
    Left = 0
    Top = 0
    Width = 481
    Height = 309
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    ParentBackground = False
    TabOrder = 1
    object spltOptions: TSplitter
      Left = 149
      Top = 4
      Width = 6
      Height = 301
      ResizeStyle = rsUpdate
      ExplicitHeight = 331
    end
    object tvOptions: TTreeView
      Left = 4
      Top = 4
      Width = 145
      Height = 301
      Hint = 'Select the option screen to show.'
      Align = alLeft
      HideSelection = False
      Images = dm.imlOptions
      Indent = 27
      ReadOnly = True
      ShowRoot = False
      TabOrder = 0
      OnChange = tvOptionsChange
      OnMouseDown = tvOptionsMouseDown
      Items.NodeData = {
        030B0000002E0000000100000001000000FFFFFFFFFFFFFFFF00000000000000
        00000000000108440065006600610075006C00740073002E0000000000000000
        000000FFFFFFFFFFFFFFFF000000000000000000000000010849006E00740065
        007200760061006C003C0000000200000002000000FFFFFFFFFFFFFFFF000000
        000000000000000000010F470065006E006500720061006C0020004F00700074
        0069006F006E007300340000000400000004000000FFFFFFFFFFFFFFFF000000
        000000000000000000010B4D00610069006E002000570069006E0064006F0077
        003A0000000400000004000000FFFFFFFFFFFFFFFF0000000000000000000000
        00010E50007200650076006900650077002000570069006E0064006F00770028
        0000000600000006000000FFFFFFFFFFFFFFFF00000000000000000000000001
        05520075006C0065007300420000000900000009000000FFFFFFFFFFFFFFFF00
        000000000000000000000001125700680069007400650020002F00200042006C
        00610063006B0020004C00690073007400400000000B0000000B000000FFFFFF
        FFFFFFFFFF0000000000000000000000000111560069007300750061006C0020
        0041007000700065006100720061006E00630065003800000007000000070000
        00FFFFFFFFFFFFFFFF000000000000000000000000010D4D006F007500730065
        00200042007500740074006F006E0073002E0000000800000008000000FFFFFF
        FFFFFFFFFF000000000000000000000000010848006F0074002D004B00650079
        0073003E0000000300000003000000FFFFFFFFFFFFFFFF000000000000000000
        000000011041006400760061006E0063006500640020004F007000740069006F
        006E007300}
    end
    object panOptions: TPanel
      Left = 155
      Top = 4
      Width = 322
      Height = 301
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object panOptSpacer: TPanel
        Left = 0
        Top = 30
        Width = 322
        Height = 4
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
      end
      object panOptionsTitle: TPanel
        Left = 0
        Top = 0
        Width = 322
        Height = 30
        Align = alTop
        BevelInner = bvRaised
        BevelOuter = bvLowered
        Color = clWindow
        ParentBackground = False
        TabOrder = 1
        DesignSize = (
          322
          30)
        object imgOptionTitle: TImage
          Left = 2
          Top = 2
          Width = 26
          Height = 26
          Align = alLeft
          Center = True
        end
        object lblOptionTitle: TLabel
          Left = 28
          Top = 0
          Width = 276
          Height = 29
          Alignment = taCenter
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Options'
          Transparent = True
          Layout = tlCenter
          ExplicitWidth = 318
        end
      end
      object scrollBox1: TScrollBox
        Left = 0
        Top = 34
        Width = 322
        Height = 267
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        TabOrder = 2
      end
    end
  end
end