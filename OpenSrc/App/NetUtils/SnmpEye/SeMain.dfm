object MainForm: TMainForm
  Left = 259
  Top = 120
  Width = 706
  Height = 480
  ActiveControl = cboAgent
  Caption = 'SnmpEye'
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 421
    Width = 690
    Height = 21
    AutoHint = True
    Panels = <
      item
        Bevel = pbNone
        Width = 50
      end>
    ParentFont = True
    SimplePanel = True
    UseSystemFont = False
    OnHint = StatusBarHint
  end
  object ListView: TListView
    Left = 0
    Top = 24
    Width = 690
    Height = 397
    Align = alClient
    Columns = <
      item
        Caption = 'Object Identifier'
        Width = 130
      end
      item
        Caption = 'Name'
        Width = 130
      end
      item
        Caption = 'Type'
        Width = 130
      end
      item
        Caption = 'Value'
        Width = 279
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    SmallImages = ImageList
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = ListViewDblClick
    OnKeyDown = ListViewKeyDown
  end
  object CoolBar: TCoolBarEx
    Left = 0
    Top = 0
    Width = 690
    Height = 24
    AutoSize = True
    BandMaximize = bmDblClick
    Bands = <
      item
        Control = MenuBar
        ImageIndex = -1
        MinHeight = 21
        Width = 141
      end
      item
        Break = False
        Control = ToolBar
        ImageIndex = -1
        MinHeight = 22
        Width = 543
      end>
    EdgeBorders = [ebLeft, ebTop, ebRight]
    object MenuBar: TToolBar
      Left = 9
      Top = 0
      Width = 128
      Height = 21
      AutoSize = True
      ButtonHeight = 21
      ButtonWidth = 43
      Caption = 'ToolBar'
      EdgeBorders = []
      Flat = True
      Menu = MainMenu
      ShowCaptions = True
      TabOrder = 0
      Wrapable = False
    end
    object ToolBar: TPanel
      Left = 152
      Top = 0
      Width = 530
      Height = 22
      BevelOuter = bvNone
      TabOrder = 1
      OnResize = ToolBarResize
      object lblAgent: TLabel
        Left = 0
        Top = 0
        Width = 37
        Height = 23
        AutoSize = False
        Caption = 'Ag&ent:'
        Layout = tlCenter
      end
      object lblCommunity: TLabel
        Left = 141
        Top = 0
        Width = 69
        Height = 23
        AutoSize = False
        Caption = 'C&ommunity:'
        Layout = tlCenter
      end
      object lblOids: TLabel
        Left = 314
        Top = 0
        Width = 28
        Height = 23
        AutoSize = False
        Caption = 'O&ids:'
        Layout = tlCenter
      end
      object cboAgent: TComboBox
        Left = 38
        Top = 0
        Width = 100
        Height = 21
        Hint = 'IP Address or IP Hostname.'
        ItemHeight = 13
        ItemIndex = 0
        ParentShowHint = False
        ShowHint = False
        TabOrder = 0
        Text = '127.0.0.1'
        Items.Strings = (
          '127.0.0.1')
      end
      object cboCommunity: TComboBox
        Left = 211
        Top = 0
        Width = 100
        Height = 21
        Hint = 
          'A community name identifies a collection of SNMP managers and ag' +
          'ents.'
        ItemHeight = 13
        ItemIndex = 0
        ParentShowHint = False
        ShowHint = False
        TabOrder = 1
        Text = 'public'
        Items.Strings = (
          'public')
      end
      object cboOids: TComboBox
        Left = 344
        Top = 0
        Width = 100
        Height = 21
        Hint = 
          'String format of an oid.You can specify multiple oids, separated' +
          ' by semicolons. Oid '#39'all'#39' is applicable only for '#39'walk'#39' action.'
        ItemHeight = 13
        ItemIndex = 0
        ParentShowHint = False
        ShowHint = False
        TabOrder = 2
        Text = '.1.3.6.1.2.1.1.1.0'
        Items.Strings = (
          '.1.3.6.1.2.1.1.1.0'
          '.1.3.6.1.2.1.1.1.0;.1.3.6.1.2.1.1.2.0;.1.3.6.1.2.1.1.3.0'
          'all')
      end
      object ActionBar: TToolBar
        Left = 446
        Top = 0
        Width = 84
        Height = 22
        Align = alRight
        AutoSize = True
        Caption = 'ActionBar'
        EdgeBorders = []
        Flat = True
        Images = ImageList
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Wrapable = False
        object btnRun: TToolButton
          Left = 0
          Top = 0
          Action = actRun
          DropdownMenu = PopupMenu
          Style = tbsDropDown
        end
        object btnStop: TToolButton
          Left = 38
          Top = 0
          Action = actStop
        end
        object btnClear: TToolButton
          Left = 61
          Top = 0
          Action = actClear
        end
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 64
    Top = 373
    object miFile: TMenuItem
      Caption = '&File'
      Hint = 'File related commands.'
      object miSave: TMenuItem
        Action = actSave
      end
      object miSaveAs: TMenuItem
        Action = actSaveAs
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miExit: TMenuItem
        Action = actExit
      end
    end
    object miView: TMenuItem
      Caption = '&View'
      Hint = 'Contains commands for manipulating the view.'
      object miToolbar: TMenuItem
        Action = actToolBar
      end
      object miStatusBar: TMenuItem
        Action = actStatusBar
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object miDetails: TMenuItem
        Action = actDetails
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object miOptions: TMenuItem
        Action = actOptions
      end
    end
    object miAction: TMenuItem
      Caption = '&Action'
      Hint = 'Contains action commands.'
      object miRun: TMenuItem
        Action = actRun
      end
      object miStop: TMenuItem
        Action = actStop
      end
      object miClear: TMenuItem
        Action = actClear
      end
      object N4: TMenuItem
        Caption = '-'
      end
    end
    object miHelp: TMenuItem
      Caption = '&?'
      Hint = 'Help topics.'
      object miAbout: TMenuItem
        Action = actAbout
      end
    end
  end
  object ActionList: TActionList
    Images = ImageList
    OnUpdate = ActionListUpdate
    Left = 14
    Top = 373
    object actSave: TAction
      Category = 'File'
      Caption = '&Save'
      Hint = 'Save current file.'
      ShortCut = 16467
      OnExecute = actSaveExecute
    end
    object actSaveAs: TAction
      Category = 'File'
      Caption = 'Save &As...'
      Hint = 'Save current file with different name.'
      OnExecute = actSaveAsExecute
    end
    object actExit: TAction
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit application.'
      OnExecute = actExitExecute
    end
    object actToolBar: TAction
      Category = 'View'
      Caption = '&Toolbar'
      Checked = True
      Hint = 'Shows or hides toolbar.'
      OnExecute = actToolBarExecute
    end
    object actStatusBar: TAction
      Category = 'View'
      Caption = 'Status &Bar'
      Checked = True
      Hint = 'Shows or hides the status bar.'
      OnExecute = actStatusBarExecute
    end
    object actDetails: TAction
      Category = 'View'
      Caption = '&Details...'
      Hint = 'MIB Object Details.'
      ShortCut = 13
      OnExecute = actDetailsExecute
    end
    object actOptions: TAction
      Category = 'View'
      Caption = '&Options...'
      Hint = 'SnmpMgrOpen settings.'
      OnExecute = actOptionsExecute
    end
    object actRun: TAction
      Category = 'Action'
      Caption = '&Run'
      Hint = 'Run|Run.'
      ImageIndex = 1
      ShortCut = 120
      OnExecute = actRunExecute
    end
    object actStop: TAction
      Category = 'Action'
      Caption = 'Sto&p'
      Hint = 'Stop|Stop.'
      ImageIndex = 2
      ShortCut = 27
      OnExecute = actStopExecute
    end
    object actClear: TAction
      Category = 'Action'
      Caption = '&Clear'
      Hint = 'Clear|Clear previous results.'
      ImageIndex = 3
      ShortCut = 16466
      OnExecute = actClearExecute
    end
    object actGet: TAction
      Category = 'Run'
      Caption = '&Get'
      Checked = True
      GroupIndex = 1
      Hint = 'Retrieve the value of the specified variable.'
      ShortCut = 16455
      OnExecute = ActionExecute
    end
    object actGetNext: TAction
      Tag = 1
      Category = 'Run'
      Caption = 'Get&Next'
      GroupIndex = 1
      Hint = 
        'Retrieve the value of the lexicographic successor the specified ' +
        'variable.'
      ShortCut = 16468
      OnExecute = ActionExecute
    end
    object actWalk: TAction
      Tag = 2
      Category = 'Run'
      Caption = '&Walk'
      GroupIndex = 1
      Hint = 'Retrieve the all values of the specified subtree.'
      ShortCut = 16471
      OnExecute = ActionExecute
    end
    object actAbout: TAction
      Category = 'Help'
      Caption = '&About SnmpEye...'
      Hint = 
        'About|Displays program information, version number, and copyrigh' +
        't.'
      OnExecute = actAboutExecute
    end
  end
  object PopupMenu: TPopupMenu
    Left = 120
    Top = 373
    object piGet: TMenuItem
      Action = actGet
      GroupIndex = 1
      RadioItem = True
    end
    object piGetNext: TMenuItem
      Action = actGetNext
      GroupIndex = 1
      RadioItem = True
    end
    object piWalk: TMenuItem
      Action = actWalk
      GroupIndex = 1
      RadioItem = True
    end
  end
  object ImageList: TImageList
    Left = 174
    Top = 373
    Bitmap = {
      494C010104000900040010001000FFFFFFFFFF00FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000135D1300135D1300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000A9804500A9804500A98045000000000000000000000000000000
      00000000000000000000000000000000000000000000000000009B9B9B009B9B
      9B009B9B9B009B9B9B009B9B9B009B9B9B009B9B9B009B9B9B009B9B9B009B9B
      9B009B9B9B009D9D9D0000000000000000000000000000000000000000000000
      0000000000001376130013761300135D13000000000000000000000000000000
      00000000000000000000000000000000000000000000000000005A6BEF001029
      A50000109C0000109C0000109C0000109C0000109C0000109C0000109C000010
      9C0008219C005A6BEF0000000000000000000000000000000000000000000000
      0000AE864E00AE864E00AE864E00AE864E00AE864E0000000000000000000000
      0000000000000000000000000000000000000000000000000000A0A0A000DDDD
      DD00D0D0D000D0D0D000D0D0D000D0D0D000D0D0D000D0D0D000D0D0D000D3D3
      D300DDDDDD00A0A0A00000000000000000000000000000000000000000000000
      000000000000137613001BAF340013761300135D130000000000000000000000
      00000000000000000000000000000000000000000000000000001029C6000018
      C6000821C6001029C6001029C6000829CE001029CE001029CE000021CE000018
      CE000010AD0010219C000000000000000000000000000000000000000000B48F
      5800B48F5800B48F5800B48F5800B48F5800B48F5800B48F5800000000000000
      0000000000000000000000000000000000000000000000000000A0A0A000D3D3
      D300C1C1C100C1C1C100C1C1C100BEBEBE00C1C1C100C1C1C100C1C1C100C3C3
      C300D0D0D000A0A0A00000000000000000000000000000000000000000000000
      0000000000001376130023AF34001BAF340013761300135D1300000000000000
      00000000000000000000000000000000000000000000000000000018CE001031
      D6001831D6002139E7002942E7002142E7001842E7001039E7000831E7000029
      E7000018CE0000109C0000000000000000000000000000000000BA956100BA95
      6100BA956100BA956100BA956100BA956100BA956100BA956100BA9561000000
      0000000000000000000000000000000000000000000000000000A5A5A500D8D8
      D800CBCBCB00C8C8C800C6C6C600C3C3C300C3C3C300C3C3C300C3C3C300C3C3
      C300D3D3D300A2A2A20000000000000000000000000000000000000000000000
      0000000000001376130023B83C0023B83C001BAF340013761300135D13000000
      00000000000000000000000000000000000000000000000000000021D6001831
      D6002942E700314AE700294AE700294AE7001842E7001042E7001039E7000831
      E7000021CE0000109C00000000000000000000000000CAAD8400BD996600BD99
      6600BD996600BD996600BD996600BD996600BD996600BD996600BD9966000E36
      E000000000000000000000000000000000000000000000000000ACACAC00E5E5
      E500D8D8D800D0D0D000D0D0D000CECECE00CECECE00CBCBCB00CBCBCB00CBCB
      CB00D8D8D800A5A5A50000000000000000000000000000000000000000000000
      0000000000001376130023C84C0023B83C001BAF34001BAF340013761300135D
      13000000000000000000000000000000000000000000000000001031D6002142
      E7003952E7003152E700314AE700294AE7001842E7001839E7001039E7000831
      E7001031CE0000109C00000000000000000000000000CCB08800C09D6B00C09D
      6B00C09D6B00C09D6B00C09D6B00C09D6B00C09D6B00C09D6B000F38E1000F38
      E1000F38E1000000000000000000000000000000000000000000ACACAC00EAEA
      EA00E5E5E500E5E5E500DFDFDF00D8D8D800D8D8D800D5D5D500D5D5D500D3D3
      D300DDDDDD00A7A7A70000000000000000000000000000000000000000000000
      000000000000137613002BC85D0023C04C0023C04C0023C04C0023B83C001376
      13001365130000000000000000000000000000000000000000002139E700314A
      E7003952E7003152E700314AE700294AE7001842E7001039E7001031E7000831
      E7001031CE0000109C0000000000000000000000000000000000C2A06F00C2A0
      6F00C2A06F00C2A06F00C2A06F00C2A06F00C2A06F00103BE300103BE300103B
      E300103BE300103BE30000000000000000000000000000000000B1B1B100F1F1
      F100EAEAEA00EAEAEA00EAEAEA00EAEAEA00EAEAEA00EAEAEA00E7E7E700E7E7
      E700EAEAEA00B0B0B00000000000000000000000000000000000000000000000
      0000000000001376130065D065006DD065005DD065005DD065005DD065001376
      1300136513000000000000000000000000000000000000000000314AE700425A
      E7004252E7003152E700314AE7002942E7001839DE001031DE001031DE001031
      DE001031CE0000109C000000000000000000000000000000000000000000C5A4
      7400C5A47400C5A47400C5A47400C5A47400123FE500123FE500123FE500123F
      E500123FE500123FE500123FE500000000000000000000000000B4B4B400F1F1
      F100EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00ECEC
      EC00ECECEC00B5B5B50000000000000000000000000000000000000000000000
      000000000000137613006DD96D007ED97E007ED976005DD0650013761300135D
      13000000000000000000000000000000000000000000000000003952E7004A63
      E700425AE7003952E7003142E7002942DE001839DE001031D6001031DE001031
      DE001031CE0000109C0000000000000000000000000000000000000000000000
      0000C7A77800C7A77800C7A778001444E8001444E8001444E8001444E8001444
      E8001444E8001444E8001444E8004369EC000000000000000000B4B4B400E5E5
      E500E5E5E500E5E5E500E5E5E500E5E5E500E2E2E200E2E2E200E2E2E200E2E2
      E200E5E5E500B5B5B50000000000000000000000000000000000000000000000
      000000000000137613007ED97E008EE98E008EE98E0013761300135D13000000
      00000000000000000000000000000000000000000000000000004252E700526B
      EF004A63E7004252DE00314AE7002942DE002139DE001839D6001831DE001031
      DE001031CE0000109C0000000000000000000000000000000000000000000000
      000000000000C9A97B001749EB001749EB001749EB001749EB001749EB001749
      EB001749EB001749EB001749EB00456DEF000000000000000000A5A5A5009898
      9800989898009898980098989800989898009898980098989800989898009898
      980098989800A3A3A30000000000000000000000000000000000000000000000
      0000000000001376130076D976009FE99F0013761300135D1300000000000000
      00000000000000000000000000000000000000000000000000004A63E7006B84
      EF005A73EF004A63E7004252E7003152E700314ADE002942DE002142DE002139
      D6001031CE0008189C0000000000000000000000000000000000000000000000
      00000000000000000000194EEE00194EEE00194EEE00194EEE00194EEE00194E
      EE00194EEE00194EEE00194EEE00000000000000000000000000D0D0D000B4B4
      B400CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
      CE00B4B4B400D0D0D00000000000000000000000000000000000000000000000
      0000000000001376130076D9760013761300135D130000000000000000000000
      00000000000000000000000000000000000000000000000000005A73EF008C94
      EF006B7BEF005273EF005263E7004A63E7004A5AE700425AE7003952E700294A
      E7001031CE001831A50000000000000000000000000000000000000000000000
      00000000000000000000000000001D57F2001D57F2001D57F2001D57F2001D57
      F2001D57F2001D57F20000000000000000000000000000000000EAEAEA00A2A2
      A200A2A2A200A2A2A200A2A2A200A2A2A200A2A2A200A2A2A200A2A2A200A2A2
      A200A2A2A200EDEDED0000000000000000000000000000000000000000000000
      0000000000001376130013761300135D13000000000000000000000000000000
      00000000000000000000000000000000000000000000000000005A73EF005A73
      EF004A5AE7003952E700314AE700314AE7002942E7002939E7002139D6001839
      D6001831C6005A6BEF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000002262F8002262F8002262F8002262
      F8002262F8000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000135D1300135D1300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000266BFD00266BFD00266B
      FD00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFF9FFFFFFF8FF
      C003F8FFC003F07FC003F87FC003E03FC003F83FC003C01FC003F81FC003800F
      C003F80FC0038007C003F807C003C003C003F807C003E001C003F80FC003F000
      C003F81FC003F800C003F83FC003FC01C003F87FC003FE03C003F8FFC003FF07
      FFFFF9FFFFFFFF8FFFFFFFFFFFFFFFFF}
  end
end