object FrameScrollImageTool: TFrameScrollImageTool
  Left = 0
  Top = 0
  Width = 443
  Height = 270
  Align = alClient
  TabOrder = 0
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 443
    Height = 251
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 0
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 649
      Height = 560
      AutoSize = True
    end
    inline Frame_ToolRect0: TFrame_ToolRect
      Left = 0
      Top = 0
      Width = 209
      Height = 105
      AutoScroll = False
      AutoSize = True
      TabOrder = 0
      Visible = False
    end
    inline Frame_ToolRect1: TFrame_ToolRect
      Left = 296
      Top = 0
      Width = 209
      Height = 105
      AutoScroll = False
      AutoSize = True
      TabOrder = 1
      Visible = False
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 251
    Width = 443
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
