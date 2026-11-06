object FrmImg: TFrmImg
  Left = 30
  Top = 323
  Width = 677
  Height = 693
  Caption = 'FrmImg'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 640
    Width = 669
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 669
    Height = 640
    HorzScrollBar.Increment = 1
    HorzScrollBar.Tracking = True
    VertScrollBar.Increment = 1
    VertScrollBar.Tracking = True
    Align = alClient
    Color = clBtnFace
    ParentColor = False
    TabOrder = 0
    object PaintBox1: TPaintBox
      Left = 0
      Top = 0
      Width = 665
      Height = 636
      Align = alClient
      Color = clAqua
      ParentColor = False
      PopupMenu = PopupMenu1
      OnPaint = PaintBox1Paint
    end
    object PntBx: TPaintBox
      Left = 0
      Top = 0
      Width = 449
      Height = 361
      PopupMenu = PopupMenu1
      OnMouseDown = PntBxMouseDown
      OnMouseMove = PntBxMouseMove
      OnMouseUp = PntBxMouseUp
      OnPaint = PntBxPaint
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 40
    Top = 48
  end
  object ActionList1: TActionList
    Left = 496
    Top = 72
    object Action1_interpolation: TAction
      AutoCheck = True
      Caption = 'Action1_interpolation'
      ShortCut = 16457
      OnExecute = Action1_interpolationExecute
    end
    object Action_Mark_A: TAction
      Caption = 'Action_Mark_A'
      ShortCut = 16449
      OnExecute = Action_Mark_AExecute
    end
    object Action_Mark_B: TAction
      Caption = 'Action_Mark_B'
      ShortCut = 16450
      OnExecute = Action_Mark_BExecute
    end
    object Action_Mark_C: TAction
      Caption = 'Action_Mark_C'
      ShortCut = 16451
      OnExecute = Action_Mark_CExecute
    end
    object Action_Mark_D: TAction
      Caption = 'Action_Mark_D'
      ShortCut = 16452
      OnExecute = Action_Mark_DExecute
    end
    object Action_Marker_ToLinked: TAction
      Caption = 'Action_Marker_ToLinked'
      ShortCut = 16461
      OnExecute = Action_Marker_ToLinkedExecute
    end
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 544
    Top = 72
    object SmoothMode1: TMenuItem
      Action = Action1_interpolation
      AutoCheck = True
      Caption = 'Smooth Mode'
    end
    object Smoothimediate1: TMenuItem
      AutoCheck = True
      Caption = 'Smooth imediate'
      OnClick = Smoothimediate1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ShowAnglefromS1: TMenuItem
      AutoCheck = True
      Caption = 'Show Angle from S'
      OnClick = ShowAnglefromS1Click
    end
    object AngleDelta121: TMenuItem
      Caption = 'Angle Delta: xx'
      Enabled = False
    end
    object AngleDeltaInc1: TMenuItem
      Caption = 'Inc Angle Delta'
      OnClick = AngleDeltaInc1Click
    end
    object AngleDeltaDec1: TMenuItem
      Caption = 'Dec Angle Delta'
      OnClick = AngleDeltaDec1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Connected1: TMenuItem
      AutoCheck = True
      Caption = 'Connected'
      Checked = True
      OnClick = Connected1Click
    end
    object Rollmode1: TMenuItem
      AutoCheck = True
      Caption = 'Rollmode'
    end
    object ZoomMode1: TMenuItem
      AutoCheck = True
      Caption = 'ZoomMode'
    end
    object ShowScrollbars1: TMenuItem
      AutoCheck = True
      Caption = 'Show Scrollbars'
      Checked = True
      OnClick = ShowScrollbars1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object ShowBmpStackWindow1: TMenuItem
      Caption = 'Show Bmp Stack Window'
      OnClick = ShowBmpStackWindow1Click
    end
  end
  object Timer2: TTimer
    Interval = 10
    OnTimer = Timer2Timer
    Left = 40
    Top = 144
  end
  object ApplicationEvents1: TApplicationEvents
    OnIdle = ApplicationEvents1Idle
    Left = 504
    Top = 120
  end
end
