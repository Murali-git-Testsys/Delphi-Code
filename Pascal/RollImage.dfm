object frmRollImage: TfrmRollImage
  Left = 33
  Top = 119
  Width = 800
  Height = 564
  VertScrollBar.Smooth = True
  VertScrollBar.Tracking = True
  Caption = 'frmRollImage'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 50
    Top = 50
    Width = 100
    Height = 60
    AutoSize = True
    Visible = False
  end
  object pnlTools: TPanel
    Left = 0
    Top = 482
    Width = 792
    Height = 28
    Align = alBottom
    Constraints.MinHeight = 26
    TabOrder = 0
    object lblInfo: TLabel
      Left = 696
      Top = 3
      Width = 28
      Height = 13
      Caption = 'lblInfo'
    end
    object cbxImages: TComboBox
      Left = 8
      Top = 4
      Width = 265
      Height = 21
      Hint = 'Selects an image (List content from file "LoadImageList.Txt")'
      DropDownCount = 14
      ItemHeight = 13
      TabOrder = 0
      Text = 'Select an Image'
      OnClick = cbxImagesClick
      Items.Strings = (
        'Image01.jpg'
        'Image02.jpg'
        'Image03.jpg'
        'Image04.jpg'
        'Image05.jpg'
        'Image06.jpg'
        'Image07.jpg'
        'Image08.jpg'
        'Image09.jpg'
        'Image10.jpg'
        'Image11.jpg'
        'Image12.jpg'
        'Image13.jpg'
        'Image14.jpg'
        'Image15.jpg'
        'Image16.jpg'
        'C:\TEMP\RollImages\Image01.jpg'
        'C:\TEMP\RollImages\Image02.jpg'
        'C:\TEMP\RollImages\Image03.jpg'
        'C:\TEMP\RollImages\Image04.jpg'
        'C:\TEMP\RollImages\Image05.jpg'
        'C:\TEMP\RollImages\Image06.jpg'
        'C:\TEMP\RollImages\Image07.jpg'
        'C:\TEMP\RollImages\Image08.jpg'
        'C:\TEMP\RollImages\Image09.jpg'
        'C:\TEMP\RollImages\Image10.jpg'
        'C:\TEMP\RollImages\Image11.jpg'
        'C:\TEMP\RollImages\Image12.jpg'
        'C:\TEMP\RollImages\Image13.jpg'
        'C:\TEMP\RollImages\Image14.jpg'
        'C:\TEMP\RollImages\Image15.jpg'
        'C:\TEMP\RollImages\Image16.jpg')
    end
    object sedtStep: TSpinEdit
      Left = 280
      Top = 3
      Width = 57
      Height = 22
      Hint = 'Step Width (-1: Positions; 0: until end)'
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = -1
      OnChange = sedtStepChange
    end
    object sedtStepRes: TSpinEdit
      Left = 344
      Top = 3
      Width = 49
      Height = 22
      Hint = 'Step Resolution'
      MaxValue = 1000
      MinValue = 1
      TabOrder = 2
      Value = 1
      OnChange = sedtStepResChange
    end
    object sedtDelay: TSpinEdit
      Left = 400
      Top = 3
      Width = 49
      Height = 22
      Hint = 'Step Delay (mSec)'
      MaxValue = 100
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = sedtDelayChange
    end
    object sedtVPosNr: TSpinEdit
      Left = 536
      Top = 3
      Width = 57
      Height = 22
      Hint = 'Vertical Position Number'
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
      OnChange = sedtVPosNrChange
    end
    object sedtVPosition: TSpinEdit
      Left = 600
      Top = 3
      Width = 89
      Height = 22
      Hint = 'Vertical Position'
      MaxValue = 0
      MinValue = 0
      TabOrder = 5
      Value = 88888
      OnChange = sedtVPositionChange
      OnKeyDown = sedtVPositionKeyDown
    end
    object sedtDeltaVPosition: TSpinEdit
      Left = 472
      Top = 3
      Width = 57
      Height = 22
      Hint = 'Delta Position for Vertical Position Enter'
      MaxValue = 0
      MinValue = 0
      TabOrder = 6
      Value = 10
    end
  end
  object ScrollBar1: TScrollBar
    Left = 775
    Top = 0
    Width = 17
    Height = 482
    Align = alRight
    Kind = sbVertical
    PageSize = 0
    TabOrder = 1
    OnChange = ScrollBar1Change
  end
  object pnlShow: TPanel
    Left = 0
    Top = 0
    Width = 775
    Height = 482
    Align = alClient
    Color = clGray
    TabOrder = 2
    object spltBlack: TSplitter
      Left = 1
      Top = 478
      Width = 773
      Height = 2
      Cursor = crVSplit
      Align = alBottom
      Color = clBlack
      MinSize = 5
      ParentColor = False
      OnMoved = spltBlackMoved
    end
    object shpBlack: TShape
      Left = 1
      Top = 480
      Width = 773
      Height = 1
      Cursor = crUpArrow
      Align = alBottom
      Brush.Color = clBlack
      OnMouseDown = imgMergeMouseDown
    end
    object pnlDraw: TPanel
      Left = 1
      Top = 1
      Width = 773
      Height = 453
      Align = alClient
      Constraints.MinHeight = 50
      TabOrder = 0
      OnResize = pnlDrawResize
      object imgMerge: TImage
        Left = 1
        Top = 1
        Width = 777
        Height = 408
        Cursor = crUpArrow
        AutoSize = True
        OnMouseDown = imgMergeMouseDown
      end
    end
    object pnlLoadMsg: TPanel
      Left = 1
      Top = 454
      Width = 773
      Height = 24
      Align = alBottom
      Alignment = taLeftJustify
      Caption = '      No image loaded'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
    end
  end
  object MainMenu1: TMainMenu
    Left = 72
    Top = 328
    object File1: TMenuItem
      Caption = 'File'
      object LoadImageList1: TMenuItem
        Caption = 'Load Image List'
        ShortCut = 16460
        OnClick = LoadImageList1Click
      end
      object EditImageList1: TMenuItem
        Caption = 'Edit Image List'
        ShortCut = 16453
        OnClick = EditImageList1Click
      end
      object FullScreen1: TMenuItem
        AutoCheck = True
        Caption = 'Full Screen'
        ShortCut = 16454
        OnClick = FullScreen1Click
      end
      object ViewLoadList1: TMenuItem
        AutoCheck = True
        Caption = 'View Load List'
        ShortCut = 16470
        OnClick = ViewLoadList1Click
      end
      object NormalScreen1: TMenuItem
        Caption = 'Normal Screen'
        ShortCut = 27
        OnClick = NormalScreen1Click
      end
      object PreviousImage1: TMenuItem
        Caption = 'Previous Image'
        ShortCut = 16464
        OnClick = PreviousImage1Click
      end
      object NextImage1: TMenuItem
        Caption = 'Next Image'
        ShortCut = 16462
        OnClick = NextImage1Click
      end
      object ReloadImage1: TMenuItem
        Caption = 'Reload Image'
        ShortCut = 16466
        OnClick = ReloadImage1Click
      end
      object Roll1: TMenuItem
        Caption = 'Roll'
        ShortCut = 32
        OnClick = Roll1Click
      end
      object Up1: TMenuItem
        Caption = 'Up'
        ShortCut = 85
        OnClick = Up1Click
      end
      object Down1: TMenuItem
        Caption = 'Down'
        ShortCut = 68
        OnClick = Down1Click
      end
      object Bottom1: TMenuItem
        Caption = 'Bottom'
        ShortCut = 66
        OnClick = Bottom1Click
      end
      object op1: TMenuItem
        Caption = 'Top'
        ShortCut = 84
        OnClick = op1Click
      end
      object Wait1: TMenuItem
        Caption = 'Wait'
        ShortCut = 87
        OnClick = Wait1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        ShortCut = 32856
        OnClick = Exit1Click
      end
    end
    object ools1: TMenuItem
      Caption = 'Tools'
      object InvertColors1: TMenuItem
        Caption = 'Invert Colors'
        OnClick = InvertColors1Click
      end
      object RedPart1: TMenuItem
        Caption = 'Red Part'
        OnClick = RedPart1Click
      end
      object GreenPart1: TMenuItem
        Caption = 'Green Part'
        OnClick = GreenPart1Click
      end
      object BluePart1: TMenuItem
        Caption = 'Blue Part'
        OnClick = BluePart1Click
      end
      object Saveas1: TMenuItem
        Caption = 'Save as ...'
        OnClick = Saveas1Click
      end
      object LoadImage1: TMenuItem
        Caption = 'Load Image ...'
        OnClick = LoadImage1Click
      end
      object Background1: TMenuItem
        AutoCheck = True
        Caption = 'Background'
        Checked = True
        ShortCut = 16450
        OnClick = Background1Click
      end
      object LoadBackground1: TMenuItem
        Caption = 'Load Background ...'
        OnClick = LoadBackground1Click
      end
      object ClearBackground1: TMenuItem
        Caption = 'Clear Background'
        OnClick = ClearBackground1Click
      end
      object XCuttoHalf1: TMenuItem
        Caption = 'X Cut to Half'
        OnClick = XCuttoHalf1Click
      end
      object YCuttoHalf1: TMenuItem
        Caption = 'Y Cut to Half'
        OnClick = YCuttoHalf1Click
      end
      object Show800x6001: TMenuItem
        Caption = 'Show 800 x 600'
        OnClick = Show800x6001Click
      end
      object Filter1: TMenuItem
        Caption = 'Filter'
        OnClick = Filter1Click
      end
      object ClipAbove1: TMenuItem
        Caption = 'Clip Above'
        OnClick = ClipAbove1Click
      end
      object Clip1: TMenuItem
        Caption = 'Clip'
        OnClick = Clip1Click
      end
      object ClipBelow1: TMenuItem
        Caption = 'Clip Below'
        OnClick = ClipBelow1Click
      end
      object CleanSmallParticles1: TMenuItem
        Caption = 'Clean Small Particles'
        OnClick = CleanSmallParticles1Click
      end
      object Resize1: TMenuItem
        Caption = 'Resize'
        OnClick = Resize1Click
      end
      object Options1: TMenuItem
        Caption = 'Options ...'
        ShortCut = 16463
        OnClick = Options1Click
      end
      object SaveOptions1: TMenuItem
        Caption = 'Save Options'
        OnClick = SaveOptions1Click
      end
      object LoadOptions1: TMenuItem
        Caption = 'Load Options'
        OnClick = LoadOptions1Click
      end
      object Job1: TMenuItem
        Caption = 'Job'
        OnClick = Job1Click
      end
      object JobList1: TMenuItem
        Caption = 'Job List'
        OnClick = JobList1Click
      end
      object MountImage1: TMenuItem
        Caption = 'Mount Image ...'
        OnClick = MountImage1Click
      end
    end
    object Positions1: TMenuItem
      Caption = 'Positions'
      object AddPosition1: TMenuItem
        Caption = 'Add Position'
        ShortCut = 116
        OnClick = AddPosition1Click
      end
      object InsertPosition1: TMenuItem
        Caption = 'Insert Position'
        OnClick = InsertPosition1Click
      end
      object SetPosition1: TMenuItem
        Caption = 'Set Position'
        ShortCut = 8308
        OnClick = SetPosition1Click
      end
      object DeletePosition1: TMenuItem
        Caption = 'Delete Position'
        OnClick = DeletePosition1Click
      end
      object EmptyPositions1: TMenuItem
        Caption = 'Empty Positions'
        OnClick = EmptyPositions1Click
      end
      object DeleteRemainingPositions1: TMenuItem
        Caption = 'Delete Remaining Positions'
        OnClick = DeleteRemainingPositions1Click
      end
      object NextPosition1: TMenuItem
        Caption = 'Next Position'
        ShortCut = 78
        OnClick = NextPosition1Click
      end
      object PreviousPosition1: TMenuItem
        Caption = 'Previous Position'
        ShortCut = 80
        OnClick = PreviousPosition1Click
      end
      object SavePosition1: TMenuItem
        Caption = 'Save Position ...'
        OnClick = SavePosition1Click
      end
      object LoadPosition1: TMenuItem
        Caption = 'Load Position ...'
        OnClick = LoadPosition1Click
      end
    end
    object LoadNumber1: TMenuItem
      Caption = 'Load Number'
      object Load11: TMenuItem
        Caption = 'Load #1'
        ShortCut = 24625
        OnClick = Load11Click
      end
      object Load21: TMenuItem
        Caption = 'Load #2'
        ShortCut = 24626
        OnClick = Load21Click
      end
      object Load31: TMenuItem
        Caption = 'Load #3'
        ShortCut = 24627
        OnClick = Load31Click
      end
      object Load41: TMenuItem
        Caption = 'Load #4'
        ShortCut = 24628
        OnClick = Load41Click
      end
      object Load51: TMenuItem
        Caption = 'Load #5'
        ShortCut = 24629
        OnClick = Load51Click
      end
      object Load61: TMenuItem
        Caption = 'Load #6'
        ShortCut = 24630
        OnClick = Load61Click
      end
      object Load71: TMenuItem
        Caption = 'Load #7'
        ShortCut = 24631
        OnClick = Load71Click
      end
      object Load81: TMenuItem
        Caption = 'Load #8'
        ShortCut = 24632
        OnClick = Load81Click
      end
      object Load91: TMenuItem
        Caption = 'Load #9'
        ShortCut = 24633
        OnClick = Load91Click
      end
      object Load101: TMenuItem
        Caption = 'Load #10'
        ShortCut = 24641
        OnClick = Load101Click
      end
      object Load111: TMenuItem
        Caption = 'Load #11'
        ShortCut = 24642
        OnClick = Load111Click
      end
      object Load121: TMenuItem
        Caption = 'Load #12'
        ShortCut = 24643
        OnClick = Load121Click
      end
      object Load131: TMenuItem
        Caption = 'Load #13'
        ShortCut = 24644
        OnClick = Load131Click
      end
      object Load141: TMenuItem
        Caption = 'Load #14'
        ShortCut = 24645
        OnClick = Load141Click
      end
      object Load151: TMenuItem
        Caption = 'Load #15'
        ShortCut = 24646
        OnClick = Load151Click
      end
    end
  end
  object SavePictureDialog1: TSavePictureDialog
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 72
    Top = 368
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 112
    Top = 376
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 224
    Top = 264
  end
  object SaveDialog1: TSaveDialog
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 288
    Top = 264
  end
  object XPManifest1: TXPManifest
    Left = 241
    Top = 153
  end
end
