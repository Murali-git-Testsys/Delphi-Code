object frmMountImage: TfrmMountImage
  Left = 167
  Top = 242
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
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 862
    Height = 606
    ActivePage = tbshSource
    TabOrder = 0
    object tbshSource: TTabSheet
      Caption = 'tbshSource'
      object ScrollBox1: TScrollBox
        Left = 0
        Top = 0
        Width = 854
        Height = 578
        Align = alClient
        TabOrder = 0
        object Image1: TImage
          Left = 0
          Top = 0
          Width = 850
          Height = 574
          AutoSize = True
        end
      end
    end
    object tbshMountImage: TTabSheet
      Caption = 'tbshMountImage'
      ImageIndex = 1
      object ScrollBox2: TScrollBox
        Left = 0
        Top = 0
        Width = 854
        Height = 578
        Align = alClient
        TabOrder = 0
        object Image2: TImage
          Left = 0
          Top = 0
          Width = 850
          Height = 574
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
      object Append1: TMenuItem
        Caption = 'Append'
      end
      object Insert1: TMenuItem
        Caption = 'Insert'
      end
      object Delete1: TMenuItem
        Caption = 'Delete'
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
end
