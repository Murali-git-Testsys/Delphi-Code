object frmServerViewXctImages: TfrmServerViewXctImages
  Left = 440
  Top = 292
  Width = 440
  Height = 268
  Caption = 'frmServerViewXctImages'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 432
    Height = 234
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object Button1: TButton
    Left = 48
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object DdeServerConv_ViewXctImages: TDdeServerConv
    OnExecuteMacro = DdeServerConv_ViewXctImagesExecuteMacro
    Left = 200
    Top = 24
  end
  object DdeServerItem_ViewXctImages: TDdeServerItem
    ServerConv = DdeServerConv_ViewXctImages
    Left = 248
    Top = 24
  end
  object TmrCheck: TTimer
    Interval = 5000
    OnTimer = TmrCheckTimer
    Left = 304
    Top = 24
  end
end
