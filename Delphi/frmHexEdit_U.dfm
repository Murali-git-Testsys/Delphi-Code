object frmHexEdit: TfrmHexEdit
  Left = 46
  Top = 112
  Width = 869
  Height = 529
  Caption = 'frmHexEdit'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 25
    Width = 777
    Height = 431
    Align = alLeft
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 861
    Height = 25
    Align = alTop
    TabOrder = 1
    object edtWorkFile: TEdit
      Left = 2
      Top = 2
      Width = 753
      Height = 21
      TabOrder = 0
      Text = 'Double click to select a file'
      OnDblClick = edtWorkFileDblClick
    end
    object btnBrowse: TButton
      Left = 760
      Top = 0
      Width = 89
      Height = 25
      Caption = 'Browse ...'
      TabOrder = 1
      OnClick = btnBrowseClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 456
    Width = 861
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ScrollBox1: TScrollBox
    Left = 777
    Top = 25
    Width = 84
    Height = 431
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 3
    object PaintBox1: TPaintBox
      Left = 0
      Top = 0
      Width = 440
      Height = 538
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      OnPaint = PaintBox1Paint
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 272
    Top = 112
  end
  object MainMenu1: TMainMenu
    Left = 232
    Top = 112
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open ...'
        OnClick = Open1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Search1: TMenuItem
      Caption = 'Search'
      object Find1: TMenuItem
        Caption = 'Find ...'
        OnClick = Find1Click
      end
    end
    object estKeys1: TMenuItem
      Caption = 'Test Keys'
      object AltP1: TMenuItem
        Caption = 'Alt-P'
        ShortCut = 32848
      end
    end
  end
  object FindDialog1: TFindDialog
    OnShow = FindDialog1Show
    OnFind = FindDialog1Find
    Left = 312
    Top = 112
  end
end
