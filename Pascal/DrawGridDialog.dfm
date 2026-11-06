object frmDrawGridDialog: TfrmDrawGridDialog
  Left = 16
  Top = 411
  Width = 481
  Height = 290
  Caption = 'frmDrawGridDialog'
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
  object Panel3: TPanel
    Left = 0
    Top = 174
    Width = 473
    Height = 82
    Align = alBottom
    TabOrder = 0
    object cbxLongestContOn: TCheckBox
      Left = 224
      Top = 24
      Width = 120
      Height = 17
      Caption = 'Longest Cont On'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = cbxLongestContOnClick
    end
    object btnOk: TButton
      Left = 8
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
    object btnEscape: TButton
      Left = 120
      Top = 48
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Escape'
      ModalResult = 2
      TabOrder = 2
    end
    object cbxC31: TCheckBox
      Left = 8
      Top = 24
      Width = 50
      Height = 17
      Caption = 'C31'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = cbxC31Click
    end
    object cbxC3: TCheckBox
      Left = 8
      Top = 8
      Width = 50
      Height = 17
      Caption = 'C3'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = cbxC3Click
    end
    object cbxLongestContOff: TCheckBox
      Left = 224
      Top = 8
      Width = 120
      Height = 17
      Caption = 'Longest Cont Off'
      Checked = True
      State = cbChecked
      TabOrder = 5
      OnClick = cbxLongestContOffClick
    end
    object cbxContourCheckOff: TCheckBox
      Left = 80
      Top = 8
      Width = 120
      Height = 17
      Caption = 'Contour Check Off'
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = cbxContourCheckOffClick
    end
    object cbxContourCheckOn: TCheckBox
      Left = 80
      Top = 24
      Width = 120
      Height = 17
      Caption = 'Contour Check On'
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = cbxContourCheckOnClick
    end
    object cbxF03F05: TCheckBox
      Left = 360
      Top = 8
      Width = 97
      Height = 17
      Caption = 'Filter F03F05'
      Checked = True
      State = cbChecked
      TabOrder = 8
      OnClick = cbxF03F05Click
    end
    object cbxF06F06: TCheckBox
      Left = 360
      Top = 24
      Width = 97
      Height = 17
      Caption = 'Filter F06F06'
      Checked = True
      State = cbChecked
      TabOrder = 9
      OnClick = cbxF06F06Click
    end
    object cbxF06F06F06: TCheckBox
      Left = 360
      Top = 40
      Width = 97
      Height = 17
      Caption = 'Filter F06F06F06'
      Checked = True
      State = cbChecked
      TabOrder = 10
      OnClick = cbxF06F06F06Click
    end
    object cbxF08: TCheckBox
      Left = 360
      Top = 56
      Width = 97
      Height = 17
      Caption = 'Filter F08'
      Checked = True
      State = cbChecked
      TabOrder = 11
      OnClick = cbxF08Click
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 473
    Height = 57
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 40
      Height = 13
      Caption = 'Columns'
    end
    object LblCheckedColumns: TLabel
      Left = 8
      Top = 37
      Width = 86
      Height = 13
      Caption = 'Checked Columns'
    end
    object sedtNumColumns: TSpinEdit
      Left = 72
      Top = 8
      Width = 97
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 33
      OnChange = sedtNumColumnsChange
    end
  end
  object chkLbCheckedColumns: TCheckListBox
    Left = 0
    Top = 57
    Width = 473
    Height = 117
    Align = alClient
    Columns = 5
    ItemHeight = 13
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12'
      '13'
      '14'
      '15'
      '16'
      '17'
      '18'
      '19'
      '20'
      '21'
      '22'
      '23'
      '24'
      '25'
      '26'
      '27'
      '28'
      '29'
      '30'
      '31'
      '32'
      '33')
    PopupMenu = PopSelColumns
    TabOrder = 2
    OnClick = chkLbCheckedColumnsClick
  end
  object PopSelColumns: TPopupMenu
    Left = 352
    Top = 8
    object Check1: TMenuItem
      Caption = 'Check'
      OnClick = Check1Click
    end
    object InvertCheck1: TMenuItem
      Caption = 'Invert Check'
      OnClick = InvertCheck1Click
    end
    object ClearCheck1: TMenuItem
      Caption = 'Clear Check'
      OnClick = ClearCheck1Click
    end
  end
end
