object frmPlot: TfrmPlot
  Left = 12
  Top = 113
  Width = 643
  Height = 594
  Caption = 'frmPlot'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 183
    Top = 32
    Height = 508
    OnMoved = Splitter1Moved
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 29
    Width = 635
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 635
    Height = 29
    ButtonHeight = 23
    Caption = 'ToolBar1'
    Constraints.MinHeight = 5
    Constraints.MinWidth = 5
    TabOrder = 0
    object cbx3D: TCheckBox
      Left = 0
      Top = 2
      Width = 49
      Height = 23
      Caption = '3D'
      TabOrder = 0
      OnClick = cbx3DClick
    end
    object cbxLogX: TCheckBox
      Left = 49
      Top = 2
      Width = 56
      Height = 23
      Caption = 'Log X'
      TabOrder = 1
      OnClick = cbxLogXClick
    end
    object cbxLogY: TCheckBox
      Left = 105
      Top = 2
      Width = 56
      Height = 23
      Caption = 'Log Y'
      TabOrder = 2
      OnClick = cbxLogYClick
    end
    object cbxPoints: TCheckBox
      Left = 161
      Top = 2
      Width = 56
      Height = 23
      Caption = 'Points'
      TabOrder = 3
      OnClick = cbxPointsClick
    end
    object cbxStayAtTop: TCheckBox
      Left = 217
      Top = 2
      Width = 80
      Height = 23
      Caption = 'Stay at top'
      TabOrder = 4
      OnClick = cbxStayAtTopClick
    end
  end
  object grpbxSelect: TGroupBox
    Left = 0
    Top = 32
    Width = 183
    Height = 508
    Align = alLeft
    Caption = 'Select'
    TabOrder = 1
    object lblProfilesTitle: TLabel
      Left = 2
      Top = 169
      Width = 179
      Height = 13
      Align = alTop
    end
    object chklbxSelect: TCheckListBox
      Left = 2
      Top = 182
      Width = 179
      Height = 324
      OnClickCheck = chklbxSelectClickCheck
      Align = alClient
      ItemHeight = 16
      Style = lbOwnerDrawFixed
      TabOrder = 0
      OnContextPopup = chklbxSelectContextPopup
      OnDblClick = chklbxSelectDblClick
      OnDrawItem = chklbxSelectDrawItem
    end
    object pnlSelBtns: TPanel
      Left = 2
      Top = 15
      Width = 179
      Height = 154
      Align = alTop
      BevelOuter = bvNone
      Constraints.MinHeight = 1
      Constraints.MinWidth = 1
      TabOrder = 1
      object btnSelClear: TButton
        Left = 8
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Sel. Clear'
        TabOrder = 0
        OnClick = btnSelClearClick
      end
      object btnSelAll: TButton
        Left = 88
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Sel. All'
        TabOrder = 1
        OnClick = btnSelAllClick
      end
      object btnSelInv: TButton
        Left = 6
        Top = 72
        Width = 75
        Height = 25
        Caption = 'Sel. Inv'
        TabOrder = 2
        OnClick = btnSelInvClick
      end
      object btnSelNext: TButton
        Left = 86
        Top = 40
        Width = 75
        Height = 25
        Caption = 'Sel. Next'
        TabOrder = 3
        OnClick = btnSelNextClick
      end
      object btnSelBefore: TButton
        Left = 8
        Top = 40
        Width = 75
        Height = 25
        Caption = 'Sel. Before'
        TabOrder = 4
        OnClick = btnSelBeforeClick
      end
      object sedSelStep: TSpinEdit
        Left = 88
        Top = 75
        Width = 73
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 5
        Value = 0
        OnDblClick = sedSelStepDblClick
      end
      object lbxRegisterSel: TListBox
        Left = 8
        Top = 104
        Width = 89
        Height = 49
        ItemHeight = 13
        TabOrder = 6
        OnClick = lbxRegisterSelClick
      end
      object btnRegisterSel: TButton
        Left = 104
        Top = 128
        Width = 65
        Height = 17
        Caption = 'Register Sel.'
        TabOrder = 7
        OnClick = btnRegisterSelClick
      end
      object btnDeleteRegister: TButton
        Left = 104
        Top = 112
        Width = 65
        Height = 17
        Caption = 'Register Del.'
        TabOrder = 8
        OnClick = btnDeleteRegisterClick
      end
    end
  end
  object pnlChart: TPanel
    Left = 186
    Top = 32
    Width = 449
    Height = 508
    Align = alClient
    TabOrder = 2
    object Chart1: TChart
      Left = 1
      Top = 89
      Width = 447
      Height = 418
      BackWall.Brush.Color = clWhite
      BackWall.Brush.Style = bsClear
      Title.Text.Strings = (
        'TChart')
      DepthAxis.Visible = True
      Legend.Visible = False
      View3D = False
      Align = alClient
      Color = clWhite
      TabOrder = 0
      TabStop = True
      OnMouseDown = Chart1MouseDown
      OnMouseWheel = Chart1MouseWheel
      object Series1: TFastLineSeries
        Marks.ArrowLength = 8
        Marks.Visible = False
        PercentFormat = '##0.##,%'
        SeriesColor = clRed
        Title = 'Series0'
        LinePen.Color = clGreen
        XValues.DateTime = False
        XValues.Name = 'X'
        XValues.Multiplier = 1.000000000000000000
        XValues.Order = loAscending
        YValues.DateTime = False
        YValues.Name = 'Y'
        YValues.Multiplier = 1.000000000000000000
        YValues.Order = loNone
      end
    end
    object pnl3D: TPanel
      Left = 1
      Top = 1
      Width = 447
      Height = 88
      Align = alTop
      Color = clWhite
      TabOrder = 1
      object lblZoom: TLabel
        Left = 418
        Top = 11
        Width = 27
        Height = 13
        Caption = 'Zoom'
      end
      object lblRotation: TLabel
        Left = 144
        Top = 10
        Width = 40
        Height = 13
        Caption = 'Rotation'
      end
      object lblElevation: TLabel
        Left = 144
        Top = 34
        Width = 44
        Height = 13
        Caption = 'Elevation'
      end
      object lblHorizOffset: TLabel
        Left = 416
        Top = 34
        Width = 52
        Height = 13
        Caption = 'HorizOffset'
      end
      object lblVertOffset: TLabel
        Left = 416
        Top = 58
        Width = 47
        Height = 13
        Caption = 'VertOffset'
      end
      object lblPerspective: TLabel
        Left = 144
        Top = 58
        Width = 56
        Height = 13
        Caption = 'Perspective'
      end
      object lblZoomVal: TLabel
        Left = 632
        Top = 13
        Width = 12
        Height = 13
        Caption = '<>'
      end
      object lblRotationVal: TLabel
        Left = 360
        Top = 13
        Width = 12
        Height = 13
        Caption = '<>'
      end
      object lblElevationVal: TLabel
        Left = 360
        Top = 37
        Width = 12
        Height = 13
        Caption = '<>'
      end
      object lblHorizOffsetVal: TLabel
        Left = 632
        Top = 37
        Width = 12
        Height = 13
        Caption = '<>'
      end
      object lblVertOffsetVal: TLabel
        Left = 632
        Top = 61
        Width = 12
        Height = 13
        Caption = '<>'
      end
      object lblPerspectiveVal: TLabel
        Left = 360
        Top = 61
        Width = 12
        Height = 13
        Caption = '<>'
      end
      object Label1: TLabel
        Left = 16
        Top = 13
        Width = 25
        Height = 13
        Caption = '3D %'
      end
      object cbxOrthogonal: TCheckBox
        Left = 16
        Top = 31
        Width = 97
        Height = 17
        Caption = 'cbxOrthogonal'
        TabOrder = 0
        OnClick = cbxOrthogonalClick
      end
      object cbxZoomText: TCheckBox
        Left = 16
        Top = 48
        Width = 97
        Height = 17
        Caption = 'Zoom Text'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cbxZoomTextClick
      end
      object trbarZoOm: TTrackBar
        Left = 480
        Top = 8
        Width = 150
        Height = 25
        Max = 200
        Min = 1
        Position = 100
        TabOrder = 2
        TickStyle = tsNone
        OnChange = trbarZoOmChange
      end
      object trbarRotation: TTrackBar
        Left = 208
        Top = 8
        Width = 150
        Height = 25
        Max = 360
        Min = 270
        Position = 345
        TabOrder = 3
        TickStyle = tsNone
        OnChange = trbarRotationChange
      end
      object trbarElevation: TTrackBar
        Left = 208
        Top = 32
        Width = 150
        Height = 25
        Max = 360
        Min = 270
        Position = 345
        TabOrder = 4
        TickStyle = tsNone
        OnChange = trbarElevationChange
      end
      object trbarHorizOffset: TTrackBar
        Left = 480
        Top = 32
        Width = 150
        Height = 25
        Max = 1500
        Min = -1500
        TabOrder = 5
        TickStyle = tsNone
        OnChange = trbarHorizOffsetChange
      end
      object trbarVertOffset: TTrackBar
        Left = 480
        Top = 56
        Width = 150
        Height = 25
        Max = 1500
        Min = -1500
        TabOrder = 6
        TickStyle = tsNone
        OnChange = trbarVertOffsetChange
      end
      object trbarPerspective: TTrackBar
        Left = 208
        Top = 56
        Width = 150
        Height = 25
        Max = 50
        Position = 15
        TabOrder = 7
        TickStyle = tsNone
        OnChange = trbarPerspectiveChange
      end
      object spinEdt3DPercent: TSpinEdit
        Left = 50
        Top = 9
        Width = 71
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 8
        Value = 1
        OnChange = spinEdt3DPercentChange
      end
    end
  end
  object ColorDialog1: TColorDialog
    Options = [cdFullOpen, cdAnyColor]
    Left = 144
    Top = 301
  end
  object MainMenu1: TMainMenu
    Left = 144
    Top = 253
    object File1: TMenuItem
      Caption = 'File'
      object Print1: TMenuItem
        Caption = 'Print ...'
        OnClick = Print1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Profile1: TMenuItem
      Caption = 'Profile'
      object DeleteSelected1: TMenuItem
        Caption = 'Delete Selected'
        OnClick = DeleteSelected1Click
      end
      object DeleteAll1: TMenuItem
        Caption = 'Delete All'
        OnClick = DeleteAll1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object CopySelectedtoClipboard1: TMenuItem
        Caption = 'Copy Selected to Clipboard'
        OnClick = CopySelectedtoClipboard1Click
      end
      object CopyVisibleParttoClipboard1: TMenuItem
        Caption = 'Copy Visible Part to Clipboard'
        OnClick = CopyVisibleParttoClipboard1Click
      end
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 56
    Top = 288
  end
  object PrintDialog1: TPrintDialog
    Left = 64
    Top = 256
  end
end
