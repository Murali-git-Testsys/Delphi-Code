object ViewErrScr: TViewErrScr
  Left = 91
  Top = 172
  Width = 870
  Height = 640
  Caption = 'View Errorr Screens'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 53
    Width = 862
    Height = 533
    Align = alClient
    Proportional = True
    Stretch = True
    OnClick = Image1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 862
    Height = 53
    Align = alTop
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    Lines.Strings = (
      '')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    OnChange = Memo1Change
  end
  object MainMenu1: TMainMenu
    Left = 120
    Top = 32
    object File1: TMenuItem
      Caption = 'File'
      object Print1: TMenuItem
        Caption = 'Print'
        OnClick = Print1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        ShortCut = 27
        OnClick = Exit1Click
      end
    end
    object FirstImg: TMenuItem
      Caption = '<<'
      ShortCut = 16417
      OnClick = FirstImgClick
    end
    object PrevImg: TMenuItem
      Caption = '<'
      ShortCut = 33
      OnClick = PrevImgClick
    end
    object NextImg: TMenuItem
      Caption = '>'
      ShortCut = 34
      OnClick = NextImgClick
    end
    object LastImg: TMenuItem
      Caption = '>>'
      ShortCut = 16418
      OnClick = LastImgClick
    end
  end
  object tmrTimeOut: TTimer
    Enabled = False
    OnTimer = tmrTimeOutTimer
    Left = 216
    Top = 32
  end
end
