object frmBmpStack: TfrmBmpStack
  Left = 210
  Top = 304
  Width = 268
  Height = 174
  BorderStyle = bsSizeToolWin
  Caption = 'frmBmpStack'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pntbxConnected: TPaintBox
    Left = 8
    Top = 8
    Width = 81
    Height = 81
    OnPaint = pntbxConnectedPaint
  end
  object btnSto: TButton
    Left = 96
    Top = 8
    Width = 50
    Height = 25
    Caption = '> Sto >'
    TabOrder = 0
    OnClick = btnStoClick
  end
  object btnRcl: TButton
    Left = 96
    Top = 40
    Width = 50
    Height = 25
    Caption = '< Rcl <'
    TabOrder = 1
    OnClick = btnRclClick
  end
  object btnExch: TButton
    Left = 96
    Top = 72
    Width = 50
    Height = 25
    Caption = '>  Exch <'
    TabOrder = 2
    OnClick = btnExchClick
  end
  object btnDel: TButton
    Left = 152
    Top = 104
    Width = 97
    Height = 25
    Caption = 'Del'
    TabOrder = 3
    OnClick = btnDelClick
  end
  object ComboBox1: TComboBox
    Left = 152
    Top = 8
    Width = 97
    Height = 22
    Style = csOwnerDrawVariable
    DropDownCount = 24
    ItemHeight = 16
    ItemIndex = 0
    TabOrder = 4
    Text = '0'
    OnChange = ComboBox1Change
    OnDrawItem = ComboBox1DrawItem
    OnMeasureItem = ComboBox1MeasureItem
    Items.Strings = (
      '0')
  end
  object ActionList1: TActionList
    Left = 176
    Top = 56
    object ClipboardCopy: TAction
      Caption = 'ClipboardCopy'
      ShortCut = 16451
      OnExecute = ClipboardCopyExecute
    end
    object ClipboardPaste: TAction
      Caption = 'ClipboardPaste'
      ShortCut = 16470
      OnExecute = ClipboardPasteExecute
    end
  end
end
