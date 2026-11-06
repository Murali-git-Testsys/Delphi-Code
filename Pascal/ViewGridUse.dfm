object frmViewGridUse: TfrmViewGridUse
  Left = 5
  Top = 108
  Width = 469
  Height = 733
  Caption = 'frmViewGridUse'
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
  object PageControl1: TPageControl
    Left = 0
    Top = 65
    Width = 461
    Height = 634
    ActivePage = tbshParameters
    Align = alClient
    TabOrder = 0
    object tbshParameters: TTabSheet
      Caption = 'Parameters'
      object sgrdPar: TStringGrid
        Left = 0
        Top = 0
        Width = 453
        Height = 606
        Align = alClient
        DefaultColWidth = 48
        FixedCols = 0
        RowCount = 3
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing, goThumbTracking]
        TabOrder = 0
      end
    end
    object tbshPreview: TTabSheet
      Caption = 'Preview'
      ImageIndex = 1
      OnShow = tbshPreviewShow
      object memPreview: TMemo
        Left = 0
        Top = 0
        Width = 453
        Height = 606
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 461
    Height = 65
    Align = alTop
    TabOrder = 1
    object btnBrowse: TButton
      Left = 6
      Top = 32
      Width = 75
      Height = 25
      Caption = 'Browse ...'
      TabOrder = 0
      OnClick = btnBrowseClick
    end
    object BtnViewData: TButton
      Left = 88
      Top = 32
      Width = 75
      Height = 25
      Caption = 'View Data'
      TabOrder = 1
      OnClick = BtnViewDataClick
    end
    object edtDataList: TEdit
      Left = 8
      Top = 8
      Width = 441
      Height = 21
      TabOrder = 2
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Image File List|*.txt'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 360
    Top = 48
  end
end
