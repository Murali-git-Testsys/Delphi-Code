object frmClientViewXctImages: TfrmClientViewXctImages
  Left = 0
  Top = 393
  Width = 423
  Height = 283
  Caption = 'frmClientViewXctImages'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnConnect: TButton
    Left = 8
    Top = 8
    Width = 97
    Height = 33
    Caption = 'Connect'
    TabOrder = 0
    OnClick = btnConnectClick
  end
  object btnDisconnect: TButton
    Left = 120
    Top = 8
    Width = 97
    Height = 33
    Caption = 'Disconnect'
    TabOrder = 1
    OnClick = btnDisconnectClick
  end
  object btnTerminateServer: TButton
    Left = 8
    Top = 64
    Width = 97
    Height = 33
    Caption = 'Terminate Server'
    TabOrder = 2
    OnClick = btnTerminateServerClick
  end
  object btnLaunchServer: TButton
    Left = 176
    Top = 80
    Width = 145
    Height = 49
    Caption = 'Launch Server'
    TabOrder = 3
    OnClick = btnLaunchServerClick
  end
  object DdeClientConv_ViewXctImages: TDdeClientConv
    DdeService = 'ServerViewXctImages'
    DdeTopic = 'DdeServerConv_ViewXctImages'
    ConnectMode = ddeManual
    Left = 184
    Top = 32
    LinkInfo = (
      'Service ServerViewXctImages'
      'Topic DdeServerConv_ViewXctImages')
  end
  object DdeClientItem_ViewXctImages: TDdeClientItem
    DdeConv = DdeClientConv_ViewXctImages
    Left = 232
    Top = 32
  end
end
