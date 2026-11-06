object frmViewXctImages: TfrmViewXctImages
  Left = 0
  Top = 0
  Width = 558
  Height = 226
  Caption = 'View Xct Images'
  Color = clBtnFace
  Constraints.MaxHeight = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object DrawGrid1: TDrawGrid
    Left = 0
    Top = 0
    Width = 354
    Height = 187
    Align = alClient
    Constraints.MaxWidth = 2000
    Constraints.MinHeight = 80
    Constraints.MinWidth = 80
    DefaultDrawing = False
    FixedCols = 0
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goTabs]
    ScrollBars = ssHorizontal
    TabOrder = 0
    OnDrawCell = DrawGrid1DrawCell
  end
  object MemoDeb: TMemo
    Left = 354
    Top = 0
    Width = 188
    Height = 187
    Align = alRight
    ScrollBars = ssBoth
    TabOrder = 1
    Visible = False
    WordWrap = False
  end
  object tmrMonitorNewImages: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = tmrMonitorNewImagesTimer
    Left = 608
    Top = 56
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 592
    Top = 24
  end
end
