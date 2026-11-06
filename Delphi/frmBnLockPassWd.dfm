object frmPassWord: TfrmPassWord
  Left = 405
  Top = 131
  Width = 669
  Height = 415
  Caption = 'XCT Protected files'
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  PixelsPerInch = 96
  TextHeight = 20
  object lblChanges: TLabel
    Left = 0
    Top = 0
    Width = 653
    Height = 20
    Align = alTop
    Caption = 'Changes:'
  end
  object Memo1: TMemo
    Left = 0
    Top = 20
    Width = 653
    Height = 216
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 236
    Width = 653
    Height = 140
    Align = alBottom
    TabOrder = 1
    OnResize = Panel1Resize
    object lblPassword: TLabel
      Left = 7
      Top = 7
      Width = 403
      Height = 20
      Caption = 'Please enter the password to accept the changes:'
    end
    object edtPassword: TEdit
      Left = 6
      Top = 32
      Width = 494
      Height = 45
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      PasswordChar = '*'
      TabOrder = 0
      OnKeyPress = edtPasswordKeyPress
    end
    object btnOk: TButton
      Left = 6
      Top = 83
      Width = 110
      Height = 46
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 128
      Top = 83
      Width = 110
      Height = 46
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
    object btnWait: TButton
      Left = 250
      Top = 83
      Width = 109
      Height = 46
      Caption = 'Wait'
      TabOrder = 3
      Visible = False
      OnClick = btnWaitClick
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 4000
    OnTimer = Timer1Timer
    Left = 552
    Top = 312
  end
  object Timer2: TTimer
    Enabled = False
    OnTimer = Timer2Timer
    Left = 608
    Top = 313
  end
end
