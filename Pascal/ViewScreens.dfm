object frmViewScreens: TfrmViewScreens
  Left = 40
  Top = 27
  Width = 1060
  Height = 812
  HorzScrollBar.Tracking = True
  VertScrollBar.Tracking = True
  Caption = 'frmViewScreens'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  ShowHint = True
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object sbHorz: TScrollBar
    Left = 0
    Top = 737
    Width = 1044
    Height = 16
    Align = alBottom
    Max = 300
    PageSize = 0
    TabOrder = 0
    TabStop = False
    OnChange = sbHorzChange
  end
  object sbVert: TScrollBar
    Left = 1028
    Top = 0
    Width = 16
    Height = 737
    Align = alRight
    Kind = sbVertical
    Max = 300
    PageSize = 0
    TabOrder = 1
    TabStop = False
    OnChange = sbVertChange
  end
  object pnlImages: TPanel
    Left = 0
    Top = 0
    Width = 1028
    Height = 737
    Align = alClient
    TabOrder = 2
    OnResize = pnlImagesResize
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 
      'All (*.jpg;*.bmp)|*.jpg;*.bmp|JPEG Image File (*.jpg)|*.jpg|Bitm' +
      'aps (*.bmp)|*.bmp'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofAllowMultiSelect, ofFileMustExist, ofEnableSizing]
    Left = 177
    Top = 17
  end
  object MainMenu1: TMainMenu
    Left = 64
    Top = 16
    object File1: TMenuItem
      Caption = '&File'
      object New1: TMenuItem
        Caption = '&New'
        OnClick = New1Click
      end
      object Open1: TMenuItem
        Caption = '&Open...'
        OnClick = Open1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Screentofile1: TMenuItem
        Caption = 'Screen to file ...'
        OnClick = Screentofile1Click
      end
      object SaveScreen1: TMenuItem
        Caption = 'Save Screen      Ctrl+F8'
        OnClick = SaveScreen1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        ShortCut = 115
        OnClick = Exit1Click
      end
    end
    object Zoom1: TMenuItem
      Caption = 'Zoom'
      object ZoomMinus1: TMenuItem
        Caption = 'Zoom Minus'
        ShortCut = 16496
        OnClick = ZoomMinus1Click
      end
      object ZoomPlus1: TMenuItem
        Caption = 'Zoom Plus'
        ShortCut = 16497
        OnClick = ZoomPlus1Click
      end
    end
    object ViewOptions1: TMenuItem
      Caption = 'View Options'
      object Scrollbarsvisible1: TMenuItem
        Caption = 'Scrollbars Common / Separate'
        OnClick = Scrollbarsvisible1Click
      end
      object TileHorizVert1: TMenuItem
        Caption = 'Tile Horiz / Vert'
        OnClick = TileHorizVert1Click
      end
      object SingleImage1: TMenuItem
        Caption = 'Single Image'
        OnClick = SingleImage1Click
      end
      object PreviousImage1: TMenuItem
        Caption = 'Previous Image'
        ShortCut = 33
        OnClick = PreviousImage1Click
      end
      object NextImage1: TMenuItem
        Caption = 'Next Image'
        ShortCut = 34
        OnClick = NextImage1Click
      end
    end
  end
  object SavePictureDialog1: TSavePictureDialog
    DefaultExt = 'jpg'
    Filter = 
      'All (*.jpg;*.bmp)|*.jpg;*.bmp|JPEG Image File (*.jpg)|*.jpg|Bitm' +
      'aps (*.bmp)|*.bmp'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 265
    Top = 17
  end
  object ActionList1: TActionList
    Left = 120
    Top = 16
    object ScreenToFile: TAction
      Category = 'Screen'
      Caption = 'Screen to file ...'
      ShortCut = 16503
      OnExecute = SaveScreen1Click
    end
    object ScrollbarsVisible: TAction
      Category = 'Screen'
      Caption = 'Scrollbars visible'
      OnExecute = ScrollbarsVisibleExecute
    end
  end
  object XPManifest1: TXPManifest
    Left = 360
    Top = 16
  end
end
