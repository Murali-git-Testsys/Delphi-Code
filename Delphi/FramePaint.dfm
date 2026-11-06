object frmPaint: TfrmPaint
  Left = 0
  Top = 0
  Width = 380
  Height = 286
  Constraints.MinHeight = 40
  Constraints.MinWidth = 40
  TabOrder = 0
  OnResize = FrameResize
  object sbHori: TScrollBar
    Left = 0
    Top = 266
    Width = 360
    Height = 20
    Align = alCustom
    LargeChange = 10
    PageSize = 0
    TabOrder = 0
    TabStop = False
    OnChange = sbHoriChange
  end
  object sbVert: TScrollBar
    Left = 360
    Top = 0
    Width = 20
    Height = 266
    Align = alCustom
    Kind = sbVertical
    LargeChange = 10
    PageSize = 0
    TabOrder = 1
    TabStop = False
    OnChange = sbVertChange
  end
  object updZoom: TUpDown
    Left = 360
    Top = 266
    Width = 20
    Height = 20
    Hint = 'Zoom'
    Min = -32768
    Max = 32767
    TabOrder = 2
    Wrap = True
  end
  object pnlImgPaint: TPanel
    Left = 32
    Top = 32
    Width = 329
    Height = 233
    Align = alCustom
    TabOrder = 3
    object imgPaint: TImage
      Left = 1
      Top = 1
      Width = 327
      Height = 231
      Align = alCustom
    end
  end
end
