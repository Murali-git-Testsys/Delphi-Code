object frmClipBoardTools: TfrmClipBoardTools
  Left = 0
  Top = 156
  Width = 576
  Height = 422
  Caption = 'frmClipBoardTools'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 568
    Height = 368
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 0
    WantReturns = False
  end
  object MainMenu1: TMainMenu
    Left = 128
    Top = 24
    object ListClipboardContent1: TMenuItem
      Caption = 'List Clipboard Content'
      ShortCut = 16460
      OnClick = ListClipboardContent1Click
      object Exit1: TMenuItem
        Caption = 'Exit'
        ShortCut = 27
        OnClick = Exit1Click
      end
    end
  end
end
