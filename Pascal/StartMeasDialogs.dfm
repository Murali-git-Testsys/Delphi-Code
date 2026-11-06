object formStartMeas: TformStartMeas
  Left = 0
  Top = 0
  Width = 842
  Height = 536
  Caption = 'formStartMeas'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 450
    Width = 834
    Height = 52
    Align = alBottom
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object btnOk: TButton
      Left = 0
      Top = 0
      Width = 235
      Height = 26
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnAbort: TButton
      Left = 241
      Top = 0
      Width = 247
      Height = 26
      Cancel = True
      Caption = 'Abort'
      ModalResult = 3
      TabOrder = 1
      OnClick = btnAbortClick
    end
    object btnSound: TButton
      Left = 494
      Top = 0
      Width = 235
      Height = 26
      Caption = 'Sound is on'
      TabOrder = 2
      OnClick = btnSoundClick
    end
    object btnChangeHolder: TButton
      Left = 0
      Top = 26
      Width = 729
      Height = 26
      Caption = 'Change Holder'
      TabOrder = 3
      OnClick = btnChangeHolderClick
    end
  end
  object pnlMsgArea: TPanel
    Left = 0
    Top = 0
    Width = 834
    Height = 450
    Align = alClient
    TabOrder = 1
    object Label1: TLabel
      Left = 676
      Top = 39
      Width = 32
      Height = 13
      Caption = 'Label1'
    end
    object memoMsg: TMemo
      Left = 1
      Top = 1
      Width = 832
      Height = 301
      TabStop = False
      Align = alClient
      Alignment = taCenter
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -19
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      Lines.Strings = (
        'memoMsg'
        '')
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      OnClick = memoMsgClick
    end
    object updwnDebug: TUpDown
      Left = 7
      Top = 7
      Width = 16
      Height = 24
      TabOrder = 1
      OnClick = updwnDebugClick
    end
    object memoPositions: TMemo
      Left = 1
      Top = 334
      Width = 832
      Height = 72
      TabStop = False
      Align = alBottom
      Alignment = taCenter
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      Lines.Strings = (
        'memoPositions')
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
    end
    object memoXRay: TMemo
      Left = 1
      Top = 406
      Width = 832
      Height = 43
      TabStop = False
      Align = alBottom
      Alignment = taCenter
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      Lines.Strings = (
        'memoXRay')
      ParentFont = False
      ReadOnly = True
      TabOrder = 3
    end
    object pnlAutoStart: TPanel
      Left = 1
      Top = 302
      Width = 832
      Height = 32
      Align = alBottom
      Caption = 'pnlAutoStart'
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -19
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = pnlAutoStartClick
    end
  end
  object tmr100ms: TTimer
    Interval = 100
    OnTimer = tmr100msTimer
    Left = 160
    Top = 32
  end
  object ColorDialog1: TColorDialog
    Left = 40
    Top = 16
  end
end
