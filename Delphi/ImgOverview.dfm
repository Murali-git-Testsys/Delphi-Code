object frmImgOverview: TfrmImgOverview
  Left = 36
  Top = 248
  Width = 537
  Height = 296
  Caption = 'frmImgOverview'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object DrawGrid1: TDrawGrid
    Left = 0
    Top = 37
    Width = 529
    Height = 167
    Align = alClient
    ColCount = 10
    DefaultRowHeight = 64
    DefaultDrawing = False
    FixedCols = 0
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goThumbTracking]
    TabOrder = 0
    OnDrawCell = DrawGrid1DrawCell
    OnKeyDown = DrawGrid1KeyDown
    OnKeyPress = DrawGrid1KeyPress
    OnMouseDown = DrawGrid1MouseDown
    OnSelectCell = DrawGrid1SelectCell
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 0
    Width = 529
    Height = 37
    Align = alTop
    Max = 1000
    TabOrder = 1
    Visible = False
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 204
    Width = 529
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object MainMenu1: TMainMenu
    Left = 112
    object Refresh1: TMenuItem
      Caption = 'Refresh'
      OnClick = Refresh1Click
    end
    object Markduplicates1: TMenuItem
      Caption = 'Mark duplicates'
      OnClick = Markduplicates1Click
    end
    object InvertSelection1: TMenuItem
      Caption = 'Invert Selection'
      OnClick = InvertSelection1Click
    end
    object ClearSelction1: TMenuItem
      Caption = 'Clear Selction'
      OnClick = ClearSelction1Click
    end
    object UseSelection1: TMenuItem
      Caption = 'Use Selection'
      object NewOverviewofSelection1: TMenuItem
        Caption = 'New Overview of Selection'
        OnClick = NewOverviewofSelection1Click
      end
      object NewOverviewofrowswithselection1: TMenuItem
        Caption = 'New Overview of rows with selection'
        OnClick = NewOverviewofrowswithselection1Click
      end
      object ListSelectedFiles1: TMenuItem
        Caption = 'List Selected Files to Clipboard'
        OnClick = ListSelectedFiles1Click
      end
      object ClearSelectionYellow1: TMenuItem
        Caption = 'Clear Selection Yellow'
        OnClick = ClearSelectionYellow1Click
      end
      object RanktoSelection1: TMenuItem
        Caption = 'Rank to Selection ...'
        OnClick = RanktoSelection1Click
      end
      object SaveSelectionList1: TMenuItem
        Caption = 'Save Selection List ...'
        OnClick = SaveSelectionList1Click
      end
      object SelectionfromList1: TMenuItem
        Caption = 'Selection from List ...'
        OnClick = SelectionfromList1Click
      end
      object SaveRankArr1: TMenuItem
        Caption = 'Save Rank Arr ...'
        OnClick = SaveRankArr1Click
      end
      object RankArrfromList1: TMenuItem
        Caption = 'Rank Arr from List ...'
        OnClick = RankArrfromList1Click
      end
      object ClearRankArr1: TMenuItem
        Caption = 'Clear Rank Arr'
        OnClick = ClearRankArr1Click
      end
      object CopySelectedfilestoNextFreeNames1: TMenuItem
        Caption = 'Copy Selected files to NextFreeNames'
        Enabled = False
        OnClick = CopySelectedfilestoNextFreeNames1Click
      end
      object DeleteSelectedFiles1: TMenuItem
        Caption = 'Hide not Selected Files'
        OnClick = DeleteSelectedFiles1Click
      end
      object DeleteSelectedFiles2: TMenuItem
        Caption = 'Delete Selected Files'
        OnClick = DeleteSelectedFiles2Click
      end
    end
    object Larger1: TMenuItem
      Caption = 'Larger'
      OnClick = Larger1Click
    end
    object Smaller1: TMenuItem
      Caption = 'Smaller'
      OnClick = Smaller1Click
    end
    object Columns1: TMenuItem
      Caption = 'Columns ...'
      OnClick = Columns1Click
    end
    object ShowColumnsDialog1: TMenuItem
      Caption = 'Show Columns Dialog'
      OnClick = ShowColumnsDialog1Click
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 192
    Top = 8
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 272
    Top = 8
  end
end
