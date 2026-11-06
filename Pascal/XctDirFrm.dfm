object frmDirectorMain: TfrmDirectorMain
  Left = 201
  Top = 248
  Width = 536
  Height = 402
  Caption = 'XCT Director'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 24
  object pnlMainBtns: TPanel
    Left = 0
    Top = 0
    Width = 528
    Height = 329
    Align = alClient
    TabOrder = 0
    object btnServiceTools: TButton
      Left = 265
      Top = 13
      Width = 250
      Height = 71
      Caption = 'Service Tools'
      TabOrder = 1
      OnClick = btnServiceToolsClick
    end
    object btnMeas: TButton
      Left = 7
      Top = 93
      Width = 250
      Height = 70
      Caption = 'Measurement'
      Enabled = False
      TabOrder = 2
      OnClick = btnMeasClick
    end
    object btnService: TButton
      Left = 265
      Top = 93
      Width = 250
      Height = 69
      Caption = 'Service'
      Enabled = False
      TabOrder = 3
      OnClick = btnServiceClick
    end
    object btnExit: TButton
      Left = 7
      Top = 245
      Width = 250
      Height = 70
      Cancel = True
      Caption = 'Exit'
      TabOrder = 4
      OnClick = btnExitClick
    end
    object btnUserTools: TButton
      Left = 7
      Top = 13
      Width = 250
      Height = 71
      Caption = 'User Tools'
      Default = True
      TabOrder = 0
      OnClick = btnUserToolsClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 329
    Width = 528
    Height = 19
    Panels = <
      item
        Width = 300
      end
      item
        Width = 200
      end>
  end
  object MainMenu1: TMainMenu
    Left = 360
    Top = 8
    object File1: TMenuItem
      Caption = 'File'
      object ViewScreens1: TMenuItem
        Caption = 'View Screens ...'
        OnClick = ViewScreens1Click
      end
      object SaveScreen1: TMenuItem
        Caption = 'Save Screen'
        ShortCut = 16503
        OnClick = SaveScreen1Click
      end
      object PrintSetup1: TMenuItem
        Caption = 'Print Setup ...'
        OnClick = PrintSetup1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        ShortCut = 115
        OnClick = Exit1Click
      end
    end
  end
  object XPManifest1: TXPManifest
    Left = 408
    Top = 8
  end
  object PrinterSetupDialog1: TPrinterSetupDialog
    Left = 449
    Top = 9
  end
end
