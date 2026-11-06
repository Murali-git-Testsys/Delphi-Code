object frmMountImage: TfrmMountImage
  Left = 64
  Top = 127
  Width = 870
  Height = 640
  Caption = 'frmMountImage'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 862
    Height = 586
    ActivePage = tbshMountImage
    Align = alClient
    TabOrder = 0
    object tbshSource: TTabSheet
      Caption = 'Source'
      inline FImgSrc: TFrameScrollImageTool
        Left = 0
        Top = 0
        Width = 854
        Height = 558
        Align = alClient
        TabOrder = 0
        inherited ScrollBox1: TScrollBox
          Width = 854
          Height = 539
        end
        inherited StatusBar1: TStatusBar
          Top = 539
          Width = 854
        end
      end
    end
    object tbshMountImage: TTabSheet
      Caption = 'Mount'
      ImageIndex = 1
      inline FImgMnt: TFrameScrollImageTool
        Left = 0
        Top = 0
        Width = 854
        Height = 558
        Align = alClient
        TabOrder = 0
        inherited ScrollBox1: TScrollBox
          Width = 854
          Height = 539
        end
        inherited StatusBar1: TStatusBar
          Top = 539
          Width = 854
        end
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 44
    Top = 152
    object File1: TMenuItem
      Caption = 'File'
      object LoadSource1: TMenuItem
        Caption = 'Load Source'
        OnClick = LoadSource1Click
      end
      object NewMountImage1: TMenuItem
        Caption = 'New Mount Image'
        OnClick = NewMountImage1Click
      end
      object LoadMountImage1: TMenuItem
        Caption = 'Load Mount Image ...'
        OnClick = LoadMountImage1Click
      end
      object SaveMountImage1: TMenuItem
        Caption = 'Save Mount Image ...'
        OnClick = SaveMountImage1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object MountImage1: TMenuItem
      Caption = 'Mount Image'
      object AppendAll1: TMenuItem
        Caption = 'Append All'
        OnClick = AppendAll1Click
      end
      object AppendSelectionFullWidth1: TMenuItem
        Caption = 'Append Selection Full Width'
        ShortCut = 16471
        OnClick = AppendSelectionFullWidth1Click
      end
      object AppendSelection1: TMenuItem
        Caption = 'Append Selection'
        ShortCut = 16467
        OnClick = AppendSelection1Click
      end
      object InsertSourceSelectionAtMountSelectionFullWidth1: TMenuItem
        Caption = 'Insert Source Selection At Mount Selection Full Width'
        ShortCut = 16457
        OnClick = InsertAtMountSelection1Click
      end
      object EmptyMount1: TMenuItem
        Caption = 'Empty Mount'
        OnClick = NewMountImage1Click
      end
      object Rectanglesupward1: TMenuItem
        Caption = 'Rectangles upward'
        ShortCut = 113
        OnClick = Rectanglesupward1Click
      end
      object Rectanglesdownward1: TMenuItem
        Caption = 'Rectangles downward'
        ShortCut = 114
        OnClick = Rectanglesdownward1Click
      end
      object RectanglesAdaptDelta1: TMenuItem
        Caption = 'Rectangles Adapt Delta'
        ShortCut = 115
        OnClick = RectanglesAdaptDelta1Click
      end
      object SelectionHeightRedRemoveGreenInsert1: TMenuItem
        Caption = 'Selection Height: Red Remove; Green: Insert'
        ShortCut = 116
        OnClick = SelectionHeightRedRemoveGreenInsert1Click
      end
      object CombineF4F5F31: TMenuItem
        Caption = 'Combine (F4 F5 F3)'
        ShortCut = 117
        OnClick = CombineF4F5F31Click
      end
      object CombineF5F31: TMenuItem
        Caption = 'Combine (F5 F3)'
        ShortCut = 118
        OnClick = CombineF5F31Click
      end
      object CombineF5F21: TMenuItem
        Caption = 'Combine (F5 F2)'
        ShortCut = 119
        OnClick = CombineF5F21Click
      end
      object FrameColorRed1: TMenuItem
        Caption = 'Frame Color Red'
        OnClick = FrameColorRed1Click
      end
      object FrameColorGreen1: TMenuItem
        Caption = 'Frame Color Green'
        OnClick = FrameColorGreen1Click
      end
      object FrameColorBlue1: TMenuItem
        Caption = 'Frame Color Blue'
        OnClick = FrameColorBlue1Click
      end
    end
    object Exchange1: TMenuItem
      Caption = 'Exchange'
      object MounttoSource1: TMenuItem
        Caption = 'Mount to Source'
        OnClick = MounttoSource1Click
      end
      object SourcetoMount1: TMenuItem
        Caption = 'Source to Mount'
        OnClick = SourcetoMount1Click
      end
      object ExchangeSourceandMount1: TMenuItem
        Caption = 'Exchange Source and Mount'
        OnClick = ExchangeSourceandMount1Click
      end
    end
    object Export1: TMenuItem
      Caption = 'Export'
      object SelectedPartofMount1: TMenuItem
        Caption = 'Selected Part of Mount ...'
        OnClick = SelectedPartofMount1Click
      end
    end
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 84
    Top = 152
  end
  object SavePictureDialog1: TSavePictureDialog
    Left = 124
    Top = 152
  end
  object popImgSrc: TPopupMenu
    Left = 44
    Top = 192
    object AppendtoMountFullWidth1: TMenuItem
      Caption = 'Append to Mount Full Width'
      OnClick = AppendSelectionFullWidth1Click
    end
    object AppendtoMountSelectedWidth1: TMenuItem
      Caption = 'Append to Mount Selected Width'
      OnClick = AppendSelection1Click
    end
    object InsertAtMountSelection1: TMenuItem
      Caption = 'Insert at Mount Selection'
      OnClick = InsertAtMountSelection1Click
    end
  end
  object popImgMnt: TPopupMenu
    Left = 84
    Top = 192
    object SelectionWhite1: TMenuItem
      Caption = 'Selection White'
      OnClick = SelectionWhite1Click
    end
    object RemoveSelectionHeight1: TMenuItem
      Caption = 'Remove Selection Height'
      OnClick = RemoveSelectionHeight1Click
    end
    object InsertSelctionHeight1: TMenuItem
      Caption = 'Insert Selction Height'
      OnClick = InsertSelctionHeight1Click
    end
    object InsertFromSourceSelection1: TMenuItem
      Caption = 'Insert From Source Selection'
      OnClick = InsertAtMountSelection1Click
    end
    object SelectRect01: TMenuItem
      Caption = 'Select Rect0'
      OnClick = SelectRect01Click
    end
    object SelectRect11: TMenuItem
      Caption = 'Select Rect1'
      OnClick = SelectRect11Click
    end
    object HideRect01: TMenuItem
      Caption = 'Hide Rect0'
      OnClick = HideRect01Click
    end
    object HideRect11: TMenuItem
      Caption = 'Hide Rect 1'
      OnClick = HideRect11Click
    end
  end
end
