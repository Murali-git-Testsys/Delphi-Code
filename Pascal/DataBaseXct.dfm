object DataModuleXCT: TDataModuleXCT
  OldCreateOrder = False
  Top = 110
  Height = 289
  Width = 257
  object DataSource1: TDataSource
    DataSet = Table1
    Left = 88
    Top = 16
  end
  object Table1: TTable
    DatabaseName = 'D:\XCT\Database'
    TableName = 'XPATDAT.DB'
    Left = 24
    Top = 16
  end
  object Table2: TTable
    Active = True
    DatabaseName = 'D:\XCT\Database'
    TableName = 'XMEAS.DB'
    Left = 32
    Top = 136
  end
  object Table3: TTable
    Active = True
    DatabaseName = 'D:\XCT\Database'
    TableName = 'XRESULTS.DB'
    Left = 32
    Top = 200
  end
  object DataSource2: TDataSource
    DataSet = Table2
    Left = 112
    Top = 136
  end
  object DataSource3: TDataSource
    DataSet = Table3
    Left = 112
    Top = 200
  end
end
