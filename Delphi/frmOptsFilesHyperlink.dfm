object frmOptions: TfrmOptions
  Left = 65
  Top = 134
  Width = 332
  Height = 353
  Caption = 'Options'
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 324
    Height = 233
    Align = alTop
    TabOrder = 0
    object lblRelativeRoot: TLabel
      Left = 8
      Top = 189
      Width = 47
      Height = 13
      Caption = 'Link Base'
    end
    object lblImgWidth: TLabel
      Left = 64
      Top = 181
      Width = 51
      Height = 13
      Caption = 'Img. Width'
    end
    object lblImgHeight: TLabel
      Left = 248
      Top = 181
      Width = 54
      Height = 13
      Caption = 'Img. Height'
    end
    object grpbxWantedColumns: TGroupBox
      Left = 176
      Top = 8
      Width = 137
      Height = 169
      Caption = 'Wanted Columns'
      TabOrder = 0
      object Label1: TLabel
        Left = 112
        Top = 128
        Width = 32
        Height = 13
        Caption = 'Label1'
      end
      object cbxW_Link: TCheckBox
        Left = 8
        Top = 16
        Width = 121
        Height = 17
        Caption = 'Link'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbxAnyClick
      end
      object cbxW_Path: TCheckBox
        Left = 8
        Top = 32
        Width = 113
        Height = 17
        Caption = 'Path'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cbxAnyClick
      end
      object cbxW_Size: TCheckBox
        Left = 8
        Top = 48
        Width = 113
        Height = 17
        Caption = 'Size'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = cbxAnyClick
      end
      object cbxW_Created: TCheckBox
        Left = 8
        Top = 64
        Width = 113
        Height = 17
        Caption = 'Date Created'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = cbxAnyClick
      end
      object cbxW_Changed: TCheckBox
        Left = 8
        Top = 80
        Width = 113
        Height = 17
        Caption = 'Date Changed'
        Checked = True
        State = cbChecked
        TabOrder = 4
        OnClick = cbxAnyClick
      end
      object cbxW_Accessed: TCheckBox
        Left = 8
        Top = 96
        Width = 121
        Height = 17
        Caption = 'Date Last Accessed'
        Checked = True
        State = cbChecked
        TabOrder = 5
        OnClick = cbxAnyClick
      end
      object cbxW_ShortName: TCheckBox
        Left = 8
        Top = 112
        Width = 113
        Height = 17
        Caption = 'Short Name'
        Checked = True
        State = cbChecked
        TabOrder = 6
        OnClick = cbxAnyClick
      end
      object cbxW_Ext: TCheckBox
        Left = 8
        Top = 128
        Width = 113
        Height = 17
        Caption = 'Extension'
        Checked = True
        State = cbChecked
        TabOrder = 7
        OnClick = cbxAnyClick
      end
      object cbxW_Existing: TCheckBox
        Left = 8
        Top = 144
        Width = 121
        Height = 17
        Caption = 'Name && Existing'
        Checked = True
        State = cbChecked
        TabOrder = 8
        OnClick = cbxAnyClick
      end
    end
    object grpbxFormat: TGroupBox
      Left = 8
      Top = 8
      Width = 161
      Height = 169
      Caption = 'Format'
      TabOrder = 1
      object cbxClearAtDrag: TCheckBox
        Left = 16
        Top = 16
        Width = 110
        Height = 17
        Caption = 'Clear at Drag'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbxAnyClick
      end
      object cbxExtendedFormat: TCheckBox
        Left = 16
        Top = 32
        Width = 110
        Height = 17
        Caption = 'Extended Format'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cbxAnyClick
      end
      object cbxHeader: TCheckBox
        Left = 16
        Top = 48
        Width = 110
        Height = 17
        Caption = 'Header'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = cbxAnyClick
      end
      object cbxDatesAsText: TCheckBox
        Left = 16
        Top = 64
        Width = 110
        Height = 17
        Caption = 'Dates as Text'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = cbxAnyClick
      end
      object cbxStayOnTop: TCheckBox
        Left = 16
        Top = 80
        Width = 97
        Height = 17
        Caption = 'Stay on Top'
        Checked = True
        State = cbChecked
        TabOrder = 4
        OnClick = cbxAnyClick
      end
      object cbxRelativeLink: TCheckBox
        Left = 16
        Top = 144
        Width = 97
        Height = 17
        Caption = 'Relative Link'
        TabOrder = 5
        OnClick = cbxAnyClick
      end
      object cbxBold: TCheckBox
        Left = 16
        Top = 96
        Width = 97
        Height = 17
        Caption = 'Bold'
        TabOrder = 6
        OnClick = cbxAnyClick
      end
      object cbxJpgBmpAsImage: TCheckBox
        Left = 16
        Top = 128
        Width = 113
        Height = 17
        Caption = 'Jpg Bmp as Image'
        TabOrder = 7
        OnClick = cbxAnyClick
      end
    end
    object edtRelativeRoot_prototype: TEdit
      Left = 8
      Top = 204
      Width = 305
      Height = 21
      TabOrder = 2
      OnChange = edtRelativeRoot_prototypeChange
    end
    object sedtWidth: TSpinEdit
      Left = 120
      Top = 180
      Width = 57
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 128
      OnChange = cbxAnyClick
    end
    object sedtHeight: TSpinEdit
      Left = 184
      Top = 180
      Width = 57
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 128
      OnChange = cbxAnyClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 233
    Width = 324
    Height = 86
    Align = alClient
    TabOrder = 1
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 322
      Height = 24
      Align = alTop
      TabOrder = 0
      object btnListClipboardFormats: TButton
        Left = 8
        Top = 3
        Width = 305
        Height = 18
        Caption = 'List Clipboard Formats'
        TabOrder = 0
        OnClick = btnListClipboardFormatsClick
      end
    end
    object Memo1: TMemo
      Left = 1
      Top = 25
      Width = 322
      Height = 60
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 1
      WantReturns = False
    end
  end
end
