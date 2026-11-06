object frmDebug: TfrmDebug
  Left = 41
  Top = 125
  Width = 204
  Height = 197
  Caption = 'frmDebug'
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
  object memDebug: TMemo
    Left = 0
    Top = 0
    Width = 188
    Height = 119
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    OnClick = memDebugClick
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
      OnClick = Options1Click
      object StayAtTop1: TMenuItem
        AutoCheck = True
        Caption = 'Stay At Top'
        Checked = True
        OnClick = StayAtTop1Click
      end
      object ResetFLevel1: TMenuItem
        Caption = 'Reset FLevel'
        OnClick = ResetFLevel1Click
      end
      object Larger1: TMenuItem
        Caption = 'Larger'
        OnClick = Larger1Click
      end
      object Smaller1: TMenuItem
        Caption = 'Smaller'
        OnClick = Smaller1Click
      end
      object Font1: TMenuItem
        Caption = 'Font'
        OnClick = Font1Click
      end
    end
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
    object KeepWindow1: TMenuItem
      Caption = 'Keep Window'
      OnClick = KeepWindow1Click
    end
    object OnLine1: TMenuItem
      Caption = 'OnLine'
      Checked = True
      OnClick = OnLine1Click
    end
  end
  object tmrApd: TTimer
    Interval = 200
    OnTimer = tmrApdTimer
    Left = 64
    Top = 16
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
