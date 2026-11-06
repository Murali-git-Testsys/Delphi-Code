object frmImgMeasTools: TfrmImgMeasTools
  Left = 11
  Top = 9
  Width = 307
  Height = 253
  Caption = 'frmImgMeasTools'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object memInfo: TMemo
    Left = 0
    Top = 0
    Width = 299
    Height = 119
    Align = alClient
    Constraints.MinHeight = 100
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 119
    Width = 299
    Height = 80
    Align = alBottom
    TabOrder = 1
    object lbl_dx: TLabel
      Left = 125
      Top = 4
      Width = 55
      Height = 16
      Caption = 'dx [mm]'
    end
    object lbl_dy: TLabel
      Left = 125
      Top = 28
      Width = 56
      Height = 16
      Caption = 'dy [mm]'
    end
    object lbl_dPhi: TLabel
      Left = 125
      Top = 52
      Width = 73
      Height = 16
      Caption = 'dPhi [deg]'
    end
    object sedt2_dx: TSpinEdit2
      Left = 0
      Top = 0
      Width = 121
      Height = 26
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      Increment = 1.000000000000000000
      ParentFont = False
      ReadOnly = False
      TabOrder = 0
      Visible = True
      DecHexMode = dh_Dec
      Decimals = 1
      MinLen = 0
      MaxLen = 0
      ValueI = 0
      ValueFactor = 1.000000000000000000
      InactiveColor = clWindow
    end
    object sedt2_dy: TSpinEdit2
      Left = 0
      Top = 24
      Width = 121
      Height = 26
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      Increment = 1.000000000000000000
      ParentFont = False
      ReadOnly = False
      TabOrder = 1
      Visible = True
      DecHexMode = dh_Dec
      Decimals = 1
      MinLen = 0
      MaxLen = 0
      ValueI = 0
      ValueFactor = 1.000000000000000000
      InactiveColor = clWindow
    end
    object sedt2_dPhi: TSpinEdit2
      Left = 0
      Top = 48
      Width = 121
      Height = 26
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      Increment = 1.000000000000000000
      ParentFont = False
      ReadOnly = False
      TabOrder = 2
      Visible = True
      DecHexMode = dh_Dec
      Decimals = 1
      MinLen = 0
      MaxLen = 0
      ValueI = 0
      ValueFactor = 1.000000000000000000
      InactiveColor = clWindow
    end
    object btnSetDelta: TButton
      Left = 200
      Top = 8
      Width = 90
      Height = 25
      Caption = 'Set Delta'
      TabOrder = 3
      OnClick = btnSetDeltaClick
    end
    object btnClearDelta: TButton
      Left = 200
      Top = 48
      Width = 90
      Height = 25
      Caption = 'Clear Delta'
      Enabled = False
      TabOrder = 4
      OnClick = btnClearDeltaClick
    end
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 8
    object File1: TMenuItem
      Caption = 'File'
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Options1: TMenuItem
      Caption = 'Options'
      object StayAtTop1: TMenuItem
        AutoCheck = True
        Caption = 'Stay At Top'
        Checked = True
        OnClick = StayAtTop1Click
      end
      object Font1: TMenuItem
        Caption = 'Font'
        OnClick = Font1Click
      end
      object Larger1: TMenuItem
        Caption = 'Larger'
        OnClick = Larger1Click
      end
      object Smaller1: TMenuItem
        Caption = 'Smaller'
        OnClick = Smaller1Click
      end
    end
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
  end
  object tmrCheckEnable: TTimer
    Interval = 3000
    OnTimer = tmrCheckEnableTimer
    Left = 64
    Top = 72
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 128
    Top = 16
  end
end
