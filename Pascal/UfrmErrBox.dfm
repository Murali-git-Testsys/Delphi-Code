object frmErrBox: TfrmErrBox
  Left = 316
  Top = 207
  Width = 870
  Height = 542
  Caption = 'frmErrBox'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 862
    Height = 475
    Align = alClient
    TabOrder = 0
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 860
      Height = 473
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
      OnClick = Memo1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 475
    Width = 862
    Height = 33
    Align = alBottom
    TabOrder = 1
    object btnOk: TButton
      Left = 8
      Top = 8
      Width = 85
      Height = 20
      Cancel = True
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnPrintText: TButton
      Left = 192
      Top = 8
      Width = 85
      Height = 20
      Caption = 'Print Text'
      TabOrder = 1
      OnClick = btnPrintTextClick
    end
    object btnMailToService: TButton
      Left = 384
      Top = 8
      Width = 85
      Height = 20
      Caption = 'Mail to Service'
      TabOrder = 2
      OnClick = btnMailToServiceClick
    end
    object btnPrintScreen: TButton
      Left = 288
      Top = 8
      Width = 85
      Height = 20
      Caption = 'Print Screen'
      TabOrder = 3
      OnClick = btnPrintScreenClick
    end
    object btnHints: TButton
      Left = 480
      Top = 8
      Width = 85
      Height = 20
      Caption = 'Hints'
      TabOrder = 4
      Visible = False
      OnClick = btnHintsClick
    end
    object btnTextClipboard: TButton
      Left = 576
      Top = 8
      Width = 85
      Height = 20
      Caption = 'Text to Clipboard'
      TabOrder = 5
      OnClick = btnTextClipboardClick
    end
    object btnDetails: TButton
      Left = 104
      Top = 8
      Width = 75
      Height = 20
      Caption = 'Details >>>'
      TabOrder = 6
      OnClick = btnDetailsClick
    end
  end
  object tmrIdle: TTimer
    Enabled = False
    OnTimer = tmrIdleTimer
    Left = 728
    Top = 40
  end
end
