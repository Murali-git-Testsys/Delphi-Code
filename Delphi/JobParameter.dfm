object frmJobParameter: TfrmJobParameter
  Left = 9
  Top = 101
  Width = 261
  Height = 429
  Caption = 'Job Parameter'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  ShowHint = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object lblCleanParticlesAThr: TLabel
    Left = 8
    Top = 56
    Width = 99
    Height = 13
    Caption = 'Clean Particles A Thr'
  end
  object lblCleanParticlesASize: TLabel
    Left = 8
    Top = 80
    Width = 103
    Height = 13
    Caption = 'Clean Particles A Size'
  end
  object lblCleanParticlesBThr: TLabel
    Left = 8
    Top = 104
    Width = 99
    Height = 13
    Caption = 'Clean Particles B Thr'
  end
  object lblCleanParticlesBSize: TLabel
    Left = 8
    Top = 128
    Width = 103
    Height = 13
    Caption = 'Clean Particles B Size'
  end
  object lblClipAboveThreshold: TLabel
    Left = 8
    Top = 8
    Width = 101
    Height = 13
    Caption = 'Clip Above Threshold'
  end
  object lblClipBelowThreshold: TLabel
    Left = 8
    Top = 32
    Width = 99
    Height = 13
    Caption = 'Clip Below Threshold'
  end
  object Label1: TLabel
    Left = 8
    Top = 248
    Width = 108
    Height = 13
    Caption = 'Bmp Save Color Depth'
  end
  object Label2: TLabel
    Left = 8
    Top = 272
    Width = 100
    Height = 13
    Caption = 'Save Add Name Part'
  end
  object Label3: TLabel
    Left = 8
    Top = 296
    Width = 40
    Height = 13
    Caption = 'Save As'
  end
  object lblDeltaSBV: TLabel
    Left = 8
    Top = 152
    Width = 91
    Height = 13
    Caption = 'DeltaScrollbar Vert.'
  end
  object lblShowStartPerc: TLabel
    Left = 8
    Top = 176
    Width = 63
    Height = 13
    Caption = 'Show Start %'
  end
  object lblShowEndPerc: TLabel
    Left = 8
    Top = 200
    Width = 60
    Height = 13
    Caption = 'Show End %'
  end
  object lblBmpWorkColorDepth: TLabel
    Left = 8
    Top = 224
    Width = 109
    Height = 13
    Caption = 'Bmp Work Color Depth'
  end
  object shpMarkColor: TShape
    Left = 208
    Top = 8
    Width = 33
    Height = 33
    Hint = 'Mark Color'
    Brush.Color = clBlack
    OnMouseDown = shpMarkColorMouseDown
  end
  object lblAdditionalHeight: TLabel
    Left = 8
    Top = 320
    Width = 80
    Height = 13
    Caption = 'Additional Height'
  end
  object sedtCleanParticlesAThr: TSpinEdit
    Left = 120
    Top = 56
    Width = 77
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 0
    Value = 0
  end
  object sedtCleanParticlesASize: TSpinEdit
    Left = 120
    Top = 80
    Width = 77
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
  end
  object sedtCleanParticlesBThr: TSpinEdit
    Left = 120
    Top = 104
    Width = 77
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object sedtCleanParticlesBSize: TSpinEdit
    Left = 120
    Top = 128
    Width = 77
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object sedtClipAboveThreshold: TSpinEdit
    Left = 120
    Top = 8
    Width = 77
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 4
    Value = 0
  end
  object sedtClipBelowThreshold: TSpinEdit
    Left = 120
    Top = 32
    Width = 77
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 5
    Value = 0
  end
  object btnOk: TButton
    Left = 8
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 6
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 168
    Top = 360
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
    OnClick = btnCancelClick
  end
  object btnApply: TButton
    Left = 88
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Apply'
    ModalResult = 4
    TabOrder = 8
    OnClick = btnApplyClick
  end
  object cbxBmpColorDepth: TComboBox
    Left = 120
    Top = 248
    Width = 125
    Height = 21
    ItemHeight = 13
    ItemIndex = 3
    TabOrder = 9
    Text = '8'
    Items.Strings = (
      '32'
      '24'
      '16'
      '8'
      '4'
      '-1')
  end
  object cbxSaveAsExt: TComboBox
    Left = 120
    Top = 296
    Width = 125
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 10
    Text = '.jpg'
    Items.Strings = (
      '.jpg'
      '.bmp'
      '.*')
  end
  object edtAddNamePart: TEdit
    Left = 120
    Top = 272
    Width = 125
    Height = 21
    TabOrder = 11
    Text = '_mod'
  end
  object sedtDeltaSBV: TSpinEdit
    Left = 120
    Top = 152
    Width = 77
    Height = 22
    Hint = 'delta vertical scrollbar'
    MaxValue = 0
    MinValue = 0
    TabOrder = 12
    Value = 24
  end
  object sedtShowStartPerc: TSpinEdit
    Left = 120
    Top = 176
    Width = 77
    Height = 22
    MaxValue = 100
    MinValue = 0
    TabOrder = 13
    Value = 0
  end
  object sedtShowEndPerc: TSpinEdit
    Left = 120
    Top = 200
    Width = 77
    Height = 22
    MaxValue = 100
    MinValue = 0
    TabOrder = 14
    Value = 100
  end
  object cbxBmpWorkColorDepth: TComboBox
    Left = 120
    Top = 224
    Width = 125
    Height = 21
    Hint = 
      'Set to 32 to enable Filter, Invert, Clean Small particles ...; 8' +
      ' for quick scrolling'
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 15
    Text = '32'
    Items.Strings = (
      '32'
      '24'
      '16'
      '8')
  end
  object sedtAdditionalHeight: TSpinEdit
    Left = 120
    Top = 320
    Width = 77
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 16
    Value = 0
  end
  object ColorDialog1: TColorDialog
    Left = 208
    Top = 64
  end
end
