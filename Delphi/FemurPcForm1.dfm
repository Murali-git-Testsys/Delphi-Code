object frmMain: TfrmMain
  Left = 65
  Top = 156
  Width = 591
  Height = 172
  Caption = 'frmMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010002002020100000000000E80200002600000010101000000000002801
    00000E0300002800000020000000400000000100040000000000800200000000
    0000000000000000000000000000000000000000800000800000008080008000
    0000800080008080000080808000C0C0C0000000FF0000FF000000FFFF00FF00
    0000FF00FF00FFFF0000FFFFFF00000000000000008888000000000000000000
    000000888888888888000000000000000000888888CCCC888888000000000000
    000888CCCCCCCCCCCC8880000000000008888CCCCCCCCCCCCCC8888000000000
    888CCCCCCCCCCCCCCCCCC8880000000088CCCCCCCCCCCCCCCCCCCC8800000008
    8CCCCCCCCCCCCCCCCCCCCCC8800000888CCCCCCCCCCCCCCCCCCCCCC888000088
    CCCCCCCCCCCCCCCCCCCCCCCC8800088CCCCCCCCCCCCCCCCCCCCCCCCCC880088C
    88CCC88CCCBBBBBCCCCEECCCC880088C88CCC88CCBBCCCBBCCCEECCCC880888C
    C88C88CCBBCCCCCCCCCEECCCC88888CCCC888CCCBBCCCCCCCCCEECCCCC8888CC
    CC888CCCBBCCCCCCCCCEECCCCC8888CCCC888CCCBBCCCCCCCCCEECCCCC8888CC
    CC888CCCBBCCCCCCCCCEECCCCC88888CC88C88CCBBCCCCCCCCCEECCCC888088C
    88CCC88CCBBCCCBBCCCEECCCC880088C88CCC88CCCBBBBBCEEEEEEEEC880088C
    CCCCCCCCCCCCCCCCCCCCCCCCC8800088CCCCCCCCCCCCCCCCCCCCCCCC88000088
    8CCCCCCCCCCCCCCCCCCCCCC8880000088CCCCCCCCCCCCCCCCCCCCCC880000000
    88CCCCCCCCCCCCCCCCCCCC8800000000888CCCCCCCCCCCCCCCCCC88800000000
    08888CCCCCCCCCCCCCC8888000000000000888CCCCCCCCCCCC88800000000000
    0000888888CCCC88888800000000000000000088888888888800000000000000
    0000000000888800000000000000FFFC3FFFFFC003FFFF0000FFFE00007FF800
    001FF000000FF000000FE0000007C0000003C000000380000001800000018000
    0001000000000000000000000000000000000000000000000000800000018000
    000180000001C0000003C0000003E0000007F000000FF000000FF800001FFE00
    007FFF0000FFFFC003FFFFFC3FFF280000001000000020000000010004000000
    0000C00000000000000000000000000000000000000000000000000080000080
    00000080800080000000800080008080000080808000C0C0C0000000FF0000FF
    000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000000EEEEEE000000000
    ECCCCCCE000000EECCCCCCCCEE0000ECCCCCCCCCCE000ECCCCCCCCCCCCE0EBCC
    CBCCBBCCBCCEECBCBCCBCCCCBCCEECCBCCCBCCCCBCCEECCBCCCBCCCCBCCEECBC
    BCCBCCCCBCCEEBCCCBCCBBCBBBCE0ECCCCCCCCCCCCE000ECCCCCCCCCCE0000EE
    CCCCCCCCEE000000ECCCCCCE000000000EEEEEE00000F81F0000F00F0000C003
    0000C00300008001000000000000000000000000000000000000000000000000
    000080010000C0030000C0030000F00F0000F81F0000}
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 575
    Height = 113
    Align = alClient
    Color = clBlack
    Constraints.MinHeight = 10
    Constraints.MinWidth = 10
    TabOrder = 0
    object ScrollBox1: TScrollBox
      Left = 1
      Top = 1
      Width = 573
      Height = 111
      Align = alClient
      Color = clBlack
      ParentColor = False
      TabOrder = 0
      object imgMain: TImage
        Left = 0
        Top = 0
        Width = 482
        Height = 145
        Constraints.MinHeight = 10
        Constraints.MinWidth = 10
        OnClick = imgMainClick
        OnDblClick = imgMainDblClick
        OnMouseDown = imgMainMouseDown
        OnMouseMove = imgMainMouseMove
        OnMouseUp = imgMainMouseUp
      end
      object mdplyMeasurement: TMediaPlayer
        Left = 303
        Top = 52
        Width = 253
        Height = 24
        Visible = False
        TabOrder = 0
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 17
    Top = 1
    object File1: TMenuItem
      Caption = '&File'
      OnClick = File1Click
      object N2: TMenuItem
        Caption = '-'
      end
      object BrowseImages1: TMenuItem
        Caption = 'Browse Images ...'
        object BrowseImagesWorkDir1: TMenuItem
          Caption = 'Browse Images WorkDir'
          OnClick = BrowseImages2Click
        end
        object N6: TMenuItem
          Caption = '-'
        end
        object BrowseImagesA1: TMenuItem
          Caption = 'Browse Images A:\'
          OnClick = BrowseImagesA1Click
        end
        object BrowseImagesB1: TMenuItem
          Caption = 'Browse Images B:\'
          OnClick = BrowseImagesB1Click
        end
        object BrowseImagesC1: TMenuItem
          Caption = 'Browse Images C:\'
          OnClick = BrowseImagesC1Click
        end
        object BrowseImagesD1: TMenuItem
          Caption = 'Browse Images D:\'
          OnClick = BrowseImagesD1Click
        end
        object BrowseImagesE1: TMenuItem
          Caption = 'Browse Images E:\'
          OnClick = BrowseImagesE1Click
        end
        object BrowseImagesF1: TMenuItem
          Caption = 'Browse Images F:\'
          OnClick = BrowseImagesF1Click
        end
        object BrowseImagesG1: TMenuItem
          Caption = 'Browse Images G:\'
          OnClick = BrowseImagesG1Click
        end
        object BrowseImagesH1: TMenuItem
          Caption = 'Browse Images H:\'
          OnClick = BrowseImagesH1Click
        end
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object ViewScreens1: TMenuItem
        Caption = 'View Screens ...'
        OnClick = ViewScreens1Click
      end
      object Screentofile1: TMenuItem
        Caption = 'Screen to file ...'
        OnClick = Screentofile1Click
      end
      object SaveScreen1: TMenuItem
        Caption = 'Save Screen'
        ShortCut = 16503
        OnClick = SaveScreen1Click
      end
      object SaveScreenPatFolder1: TMenuItem
        Caption = 'Save Screen (Pat. Folder)'
        ShortCut = 8311
        OnClick = SaveScreenPatFolder1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object PrintScreenCtrlPrint1: TMenuItem
        Caption = 'Print Screen'
        ShortCut = 16464
        OnClick = PrintScreenCtrlPrint1Click
      end
      object Print1: TMenuItem
        Caption = '&Print...'
        OnClick = Print1Click
      end
      object PrintSetup1: TMenuItem
        Caption = 'P&rint Setup...'
        OnClick = PrintSetup1Click
      end
      object ReducedPrintRes1: TMenuItem
        Caption = 'Print Res Prn'
        object PrintResolutionPrn1: TMenuItem
          Caption = 'Print Resolution Prn Opt'
          OnClick = PrintResolutionPrn1Click
        end
        object PrintResolutionPrn111: TMenuItem
          Caption = 'Print Resolution Prn 1_1'
          OnClick = PrintResolutionPrn111Click
        end
        object PrintResolutionLow1: TMenuItem
          Caption = 'Print Resolution Low'
          OnClick = PrintResolutionLow1Click
        end
        object PrintResolutionMid1: TMenuItem
          Caption = 'Print Resolution Mid'
          OnClick = PrintResolutionMid1Click
        end
        object PrintResolutionHigh1: TMenuItem
          Caption = 'Print Resolution High'
          OnClick = PrintResolutionHigh1Click
        end
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        ShortCut = 32856
        OnClick = Exit1Click
      end
    end
    object Analyse1: TMenuItem
      Caption = 'Analyse'
      OnClick = Analyse1Click
      object Roi1: TMenuItem
        Caption = 'Roi ...'
        object SelectNextRoi1: TMenuItem
          Caption = 'Select Next Roi       Tab'
          OnClick = SelectNextRoi1Click
        end
        object NewRoi1: TMenuItem
          Caption = 'New Roi'
          ShortCut = 114
          OnClick = NewRoi1Click
        end
      end
      object PreviousSlice1: TMenuItem
        Caption = 'Previous Slice'
        OnClick = PreviousSlice1Click
      end
      object NextSlice1: TMenuItem
        Caption = 'Next Slice'
        OnClick = NextSlice1Click
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object ClearAllResults1: TMenuItem
        Caption = 'Clear All Results'
        ShortCut = 16505
        OnClick = ClearAllResults1Click
      end
      object AutoRoi1: TMenuItem
        Caption = 'Automatic Search of ROI'
        ShortCut = 16499
        OnClick = AutoRoi1Click
      end
      object StartMacro1: TMenuItem
        Caption = 'Start Macro'
        OnClick = StartMacro1Click
      end
      object ClearAutoRoiMacro1: TMenuItem
        Caption = 'Clear + AutoRoi + Macro'
        OnClick = ClearAutoRoiMacro1Click
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object AnalysisTable1: TMenuItem
        Caption = 'Analysis Table'
        OnClick = AnalysisTable1Click
      end
    end
    object Options1: TMenuItem
      Caption = 'Options'
      OnClick = Options1Click
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Caption = 'About ...'
        OnClick = About1Click
      end
      object ViewTranslationDatabase1: TMenuItem
        Caption = 'View Translation Database'
        OnClick = ViewTranslationDatabase1Click
      end
      object InvertBlackWhite1: TMenuItem
        Caption = 'Invert Black && White'
        Visible = False
        OnClick = InvertBlackWhite1Click
      end
      object PaintDebug1: TMenuItem
        Caption = 'Paint Debug'
        Visible = False
        OnClick = PaintDebug1Click
      end
      object ScreenSaver1: TMenuItem
        Caption = 'Screen Saver'
        Enabled = False
        OnClick = ScreenSaver1Click
      end
    end
    object MarkCommProt1: TMenuItem
      Caption = 'Mark Comm. Prot. (0) F11'
      ShortCut = 8314
      OnClick = MarkCommProt1Click
    end
    object Window1: TMenuItem
      Caption = 'Window'
      Visible = False
      OnClick = Window1Click
      object N5: TMenuItem
        Caption = '-'
      end
    end
    object JobMacro1: TMenuItem
      Caption = 'Job/Macro'
      object TerminateJob1: TMenuItem
        AutoCheck = True
        Caption = 'Terminate Job'
        OnClick = TerminateJob1Click
      end
    end
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 337
    Top = 1
  end
  object PrintDialog1: TPrintDialog
    Left = 89
    Top = 1
  end
  object PrinterSetupDialog1: TPrinterSetupDialog
    Left = 153
    Top = 1
  end
  object SavePictureDialog1: TSavePictureDialog
    DefaultExt = 'jpg'
    Filter = 
      'All (*.jpg;*.bmp)|*.jpg;*.bmp|JPEG Image File (*.jpg)|*.jpg|Bitm' +
      'aps (*.bmp)|*.bmp'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 257
    Top = 1
  end
  object TimerMeasMode: TTimer
    Enabled = False
    Interval = 4000
    OnTimer = TimerMeasModeTimer
    Left = 225
    Top = 41
  end
  object TimerLvAn: TTimer
    Interval = 100
    OnTimer = TimerLvAnTimer
    Left = 401
    Top = 17
  end
end
