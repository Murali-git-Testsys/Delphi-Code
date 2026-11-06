object frmDeltaTime: TfrmDeltaTime
  Left = 121
  Top = 277
  Width = 538
  Height = 202
  Caption = 'frmDeltaTime'
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
  object lblDate1: TLabel
    Left = 8
    Top = 32
    Width = 32
    Height = 13
    Caption = 'Date 1'
  end
  object lblDate2: TLabel
    Left = 8
    Top = 80
    Width = 32
    Height = 13
    Caption = 'Date 2'
  end
  object lblDateFormat: TLabel
    Left = 56
    Top = 8
    Width = 115
    Height = 20
    Caption = 'lblDateFormat'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object mskEdt1: TMaskEdit
    Left = 56
    Top = 32
    Width = 300
    Height = 28
    EditMask = 'wi\l\l be \ch\anged by progr\am \l\ater;1;_'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    MaxLength = 32
    ParentFont = False
    TabOrder = 0
    Text = 'will be changed by program later'
    OnChange = mskEdt1Change
  end
  object mskEdt2: TMaskEdit
    Left = 56
    Top = 80
    Width = 300
    Height = 28
    EditMask = 'wi\l\l be \ch\anged by progr\am \l\ater;1;_'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    MaxLength = 32
    ParentFont = False
    TabOrder = 1
    Text = 'will be changed by program later'
    OnChange = mskEdt2Change
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 149
    Width = 530
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object btnOk: TButton
    Left = 8
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 104
    Top = 120
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object btnDate1ToDate2: TButton
    Left = 384
    Top = 32
    Width = 90
    Height = 20
    Caption = 'Date1 > Date2'
    TabOrder = 5
    OnClick = btnDate1ToDate2Click
  end
  object btnExchange: TButton
    Left = 384
    Top = 56
    Width = 90
    Height = 20
    Caption = 'Exchange'
    TabOrder = 6
    OnClick = btnExchangeClick
  end
  object btnDate2ToDate1: TButton
    Left = 384
    Top = 80
    Width = 90
    Height = 20
    Caption = 'Date2 > Date1'
    TabOrder = 7
    OnClick = btnDate2ToDate1Click
  end
end
