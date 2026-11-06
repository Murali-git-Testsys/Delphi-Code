object frmSelectList: TfrmSelectList
  Left = 105
  Top = 205
  Width = 280
  Height = 402
  Caption = 'frmSelectList'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object chklbx: TCheckListBox
    Left = 0
    Top = 0
    Width = 264
    Height = 295
    OnClickCheck = chklbxClickCheck
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ItemHeight = 18
    ParentFont = False
    PopupMenu = popChkLbx
    Style = lbOwnerDrawFixed
    TabOrder = 0
    OnClick = chklbxClick
    OnDrawItem = chklbxDrawItem
    OnMeasureItem = chklbxMeasureItem
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 344
    Width = 264
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
    SimplePanel = True
    OnClick = StatusBar1Click
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 312
    Width = 264
    Height = 32
    Align = alBottom
    Constraints.MinWidth = 195
    TabOrder = 2
    object lblDisclaimer: TLabel
      Left = 172
      Top = 9
      Width = 58
      Height = 13
      Caption = 'lblDisclaimer'
      Visible = False
    end
    object btnOK: TButton
      Left = 6
      Top = 4
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOKClick
    end
    object BtnCancel: TButton
      Left = 88
      Top = 4
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnlDisclaimer: TPanel
    Left = 0
    Top = 295
    Width = 264
    Height = 17
    Align = alBottom
    Caption = 'pnlDisclaimer'
    TabOrder = 3
    Visible = False
  end
  object popChkLbx: TPopupMenu
    Left = 88
    Top = 72
    object CheckSelecteduncheckothers1: TMenuItem
      Caption = 'Check Marked, uncheck others'
      OnClick = CheckSelecteduncheckothers1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object CheckSelected1: TMenuItem
      Caption = 'Check Marked'
      OnClick = CheckSelected1Click
    end
    object UncheckSelected1: TMenuItem
      Caption = 'Uncheck Marked'
      OnClick = UncheckSelected1Click
    end
    object InvertSelected1: TMenuItem
      Caption = 'Invert Marked'
      OnClick = InvertSelected1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object MarkCheckNext1: TMenuItem
      Caption = 'Mark Check Next'
      OnClick = MarkCheckNext1Click
    end
    object RepeatSelection1: TMenuItem
      Caption = 'Repeat Mark'
      OnClick = RepeatSelection1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object MarkAll1: TMenuItem
      Caption = 'Mark All'
      OnClick = MarkAll1Click
    end
    object MarkChecked1: TMenuItem
      Caption = 'Mark Checked'
      OnClick = MarkChecked1Click
    end
    object MarkNone1: TMenuItem
      Caption = 'Mark None'
      OnClick = MarkNone1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object CheckAll1: TMenuItem
      Caption = 'Check All'
      OnClick = CheckAll1Click
    end
    object UnchceckAll1: TMenuItem
      Caption = 'Check None'
      OnClick = UnchceckAll1Click
    end
    object InvertAll1: TMenuItem
      Caption = 'Checks Invert'
      OnClick = InvertAll1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object ShowImages1: TMenuItem
      AutoCheck = True
      Caption = 'Show Images'
      OnClick = ShowImages1Click
    end
  end
end
