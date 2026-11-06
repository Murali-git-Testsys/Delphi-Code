object FrmAbout: TFrmAbout
  Left = 288
  Top = 159
  Width = 702
  Height = 425
  Caption = 'FrmAbout'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 355
    Width = 686
    Height = 31
    Align = alBottom
    TabOrder = 0
    object btnDetails: TButton
      Left = 144
      Top = 5
      Width = 117
      Height = 20
      Caption = 'Details'
      TabOrder = 0
      OnClick = btnDetailsClick
    end
    object btnOk: TButton
      Left = 12
      Top = 5
      Width = 117
      Height = 20
      Cancel = True
      Caption = 'Ok'
      TabOrder = 1
      OnClick = btnOkClick
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 686
    Height = 355
    Align = alClient
    Alignment = taCenter
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clPurple
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Lines.Strings = (
      ''
      'Stratec Medizintechnik GmbH'
      ''
      'XCTVERSION'
      ''
      'Copyright 1990 ... 2008'
      '')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
