object frmBmpMove: TfrmBmpMove
  Left = 3
  Top = 108
  HorzScrollBar.Tracking = True
  VertScrollBar.Tracking = True
  AutoScroll = False
  Caption = 'frmBmpMove'
  ClientHeight = 415
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 455
    Height = 415
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 0
    object PntBx: TPaintBox
      Left = 0
      Top = 0
      Width = 337
      Height = 297
      OnPaint = PntBxPaint
    end
  end
  object tmrMove: TTimer
    Interval = 5
    OnTimer = tmrMoveTimer
    Left = 40
    Top = 56
  end
  object ApplicationEvents1: TApplicationEvents
    OnIdle = ApplicationEvents1Idle
    Left = 176
    Top = 56
  end
end
