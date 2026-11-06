object frmComparePathes: TfrmComparePathes
  Left = 0
  Top = 237
  Width = 838
  Height = 779
  Caption = 'Compare Pathes'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter2: TSplitter
    Left = 0
    Top = 499
    Width = 830
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 830
    Height = 73
    Align = alTop
    TabOrder = 0
    object Edit1: TEdit
      Left = 8
      Top = 8
      Width = 489
      Height = 21
      TabOrder = 0
      OnDblClick = Edit2DblClick
    end
    object Edit2: TEdit
      Left = 8
      Top = 40
      Width = 489
      Height = 21
      TabOrder = 1
      OnDblClick = Edit2DblClick
    end
    object Button1: TButton
      Left = 720
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 2
      OnClick = Button1Click
    end
    object btnCompare: TButton
      Left = 576
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Compare'
      TabOrder = 3
      OnClick = btnCompareClick
    end
    object btnRefresh1: TButton
      Left = 504
      Top = 8
      Width = 55
      Height = 25
      Caption = 'Refresh 1'
      TabOrder = 4
      OnClick = btnRefresh1Click
    end
    object btnRefresh2: TButton
      Left = 504
      Top = 40
      Width = 55
      Height = 25
      Caption = 'Refresh 2'
      TabOrder = 5
      OnClick = btnRefresh2Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 73
    Width = 830
    Height = 426
    Align = alTop
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 401
      Top = 1
      Height = 424
    end
    object TreeView1: TTreeView
      Left = 1
      Top = 1
      Width = 400
      Height = 424
      Align = alLeft
      Indent = 19
      TabOrder = 0
    end
    object TreeView2: TTreeView
      Left = 404
      Top = 1
      Width = 425
      Height = 424
      Align = alClient
      Indent = 19
      TabOrder = 1
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 502
    Width = 830
    Height = 243
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 2
    WordWrap = False
  end
  object OpenDialog1: TOpenDialog
    Left = 408
    Top = 16
  end
end
