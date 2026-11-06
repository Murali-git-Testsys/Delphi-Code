object frmViewGrid: TfrmViewGrid
  Left = 6
  Top = 84
  Width = 465
  Height = 321
  Caption = 'frmViewGrid'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 129
    Width = 457
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object pnlOptions: TPanel
    Left = 0
    Top = 0
    Width = 457
    Height = 129
    Align = alTop
    TabOrder = 0
    object Memo1: TMemo
      Left = 113
      Top = 1
      Width = 343
      Height = 127
      Align = alClient
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
    object pnlButtons: TPanel
      Left = 1
      Top = 1
      Width = 112
      Height = 127
      Align = alLeft
      TabOrder = 1
      object Label1: TLabel
        Left = 72
        Top = 72
        Width = 28
        Height = 13
        Caption = 'Width'
      end
      object Label2: TLabel
        Left = 72
        Top = 96
        Width = 31
        Height = 13
        Caption = 'Height'
      end
      object btnResetMove: TButton
        Left = 8
        Top = 8
        Width = 83
        Height = 25
        Caption = 'Reset Move'
        TabOrder = 0
        OnClick = btnResetMoveClick
      end
      object btnColumnsDialog: TButton
        Left = 8
        Top = 40
        Width = 81
        Height = 25
        Caption = 'Columns Dialog'
        TabOrder = 1
        OnClick = btnColumnsDialogClick
      end
      object sedtWidth: TSpinEdit
        Left = 8
        Top = 72
        Width = 57
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 2
        Value = 128
        OnChange = sedtWidthChange
      end
      object sedtHeight: TSpinEdit
        Left = 8
        Top = 96
        Width = 57
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 3
        Value = 128
        OnChange = sedtHeightChange
      end
    end
  end
  object pnlGrid: TPanel
    Left = 0
    Top = 132
    Width = 457
    Height = 155
    Align = alClient
    TabOrder = 1
    object DrawGrid1: TDrawGrid
      Left = 1
      Top = 1
      Width = 455
      Height = 153
      Align = alClient
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goThumbTracking]
      TabOrder = 0
      OnColumnMoved = DrawGrid1ColumnMoved
      OnDblClick = DrawGrid1DblClick
      OnDrawCell = DrawGrid1DrawCell
      OnMouseMove = DrawGrid1MouseMove
      OnMouseUp = DrawGrid1MouseUp
      OnRowMoved = DrawGrid1RowMoved
      OnSelectCell = DrawGrid1SelectCell
      ColWidths = (
        64
        64
        64
        64
        64)
    end
  end
end
