unit Translate;
// copy of TranslateData.pas
// but without DB support
// uses "C:\XCT550\Calc\TransTxt.txt" for translation
// Modifications:
// 04.02.09 P.W: Avoid load and store of AddTrans when not used

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  A_XctDir,   // 04.02.09 P.W
  GlbPath,
  StrUtils,
  Grids, SysUtils, Windows, Classes, Graphics, ComCtrls, StdCtrls, Controls,
  Forms, Dialogs;//, DB, DBTables;

type
  TTransLang =
    // never change the order!
    (TL_Org, TL_Ger, TL_Eng, TL_Fre, TL_Ita, TL_Spa);

const
  TransLangMsgArr :
    Array [Low(TTransLang).. High(TTransLang)] of String =
    ('Org', 'Ger', 'Eng', 'Fre', 'Ita', 'Spa');

const
  UseDb = False;
//  UseDb = True;

  TextSeparator = #9; // Tab

type
  TTranslateDataModule = class//(TDataModule)
//    TblTranslateORG: TStringField;
//    TblTranslateGER: TStringField;
//    TblTranslateENG: TStringField;
//    TblTranslateFRE: TStringField;
//    TblTranslateITA: TStringField;
//    TblTranslateSPA: TStringField;
//    dtsrcTranslate: TDataSource;
//    TblTranslate: TTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure dtsrcTranslateUpdateData(Sender: TObject);
//    procedure TblTranslateAfterEdit(DataSet: TDataSet);
//    procedure TblTranslateAfterPost(DataSet: TDataSet);
//    procedure TblTranslateBeforeEdit(DataSet: TDataSet);
  private
    { private declarations }
    StrListOrg : TStringList;
    StrListTra : TStringList;
    FTransLang: TTransLang;
    RequestPrepTransLang : Boolean;
    procedure SetTransLang(const Value: TTransLang);
    procedure FillStrList(var StrList: TStringList; aTransLang: TTransLang);
//    procedure AFieldChanged(Field: TField);
    procedure PrepTransLang;
//    procedure CreateExportFile(ExpName: String);

  public
    { public declarations }
    NumTexts : Integer;
    function TranslateOrg(Org: String): String;
    property TransLang : TTransLang read FTransLang write SetTransLang default TL_Eng;
    function TransLangMsg: String;
    procedure ChkPrepTransLang_;
  end;

var
  TranslateDataModule: TTranslateDataModule;

type
  TAddTrans = class
  private
    Data : TStringList;
    aSG : TStringGrid;
    constructor Create;
    function OrgIndex(Org: AnsiString): Integer;
    function EmptyLine: String;
    function DataLineInsLang(const DataLine: AnsiString; S: String; Lang: TTransLang): AnsiString;

    procedure InsertTrans(Org, Tra: String; Lang: TTransLang);
    procedure LoadClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    function DataLineToSL(const DataLine: AnsiString): TStringList;
    function SLToDataLine(const SL: TStringList): AnsiString;
  public
    destructor  Destroy; override;
    procedure EditContent;
  end;

function AddTrans: TAddTrans;  // replaces var AddTrans since: 04.02.09 P.W


//function  OemToString(const aStr: AnsiString): AnsiString; -> WinTools.pas
//function  StringToOem(const aStr: AnsiString): AnsiString;

Implementation
  const Unit_Name = 'Translate'; // 03.05.24 P.W

//{$R *.DFM}

// v--- replacement for var AddTrans  04.02.09 P.W
var
  fAddTrans : TAddTrans = nil;
function AddTrans: TAddTrans;
begin
  if not assigned(fAddTrans) then
  begin
    fAddTrans := TAddTrans.create;
  end;
  Result := fAddTrans;
end;
// ^--- replacement for var AddTrans  04.02.09 P.W

function UseTxtName :String;
//  UseTxtName = 'C:\XCT550\Calc\TransTxt.txt';
begin
  Result := GlbResDir + 'TransTxt.txt';
end;

function UseTxtNameAdd :String;
//  UseTxtName = 'C:\XCT550\Calc\TransTxt.txt';
begin
  Result := GlbResDir + 'TransTxtAdd.txt';
end;

const
  UseSepChar = #9; // TabStop

{ TAddTrans }

constructor TAddTrans.Create;
begin
  inherited Create;
  Data := TStringList.Create;
  If FileExists(UseTxtNameAdd) then
    Data.LoadFromFile(UseTxtNameAdd);
  InsertTrans('ORG', 'GER', TL_GER);  // Org is used to find entry
  InsertTrans('ORG', 'ENG', TL_Eng);
  InsertTrans('ORG', 'FRE', TL_Fre);
  InsertTrans('ORG', 'ITA', TL_Ita);
  InsertTrans('ORG', 'SPA', TL_Spa);
end;

destructor TAddTrans.Destroy;
begin
  If DirectoryExists(ExtractFileDir(UseTxtName)) then  // if: 11.04.05 P.W
    Data.SaveToFile(UseTxtNameAdd);
  FreeAndNil(Data);
  // ---
  inherited Destroy;
end;

function TAddTrans.OrgIndex(Org: AnsiString): Integer;
// search for Org in Data
var
  I : Integer;
begin
  Result := -1; // not found;
  For I := 0 to Data.Count -1 do
  begin
    if (Pos(Org+UseSepChar, Data[I]) = 1) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TAddTrans.EmptyLine: String;
begin
  Result := StringOfChar(UseSepChar, Ord(High(TTransLang)));
end;

function TAddTrans.DataLineToSL(const DataLine: AnsiString): TStringList;
var
  P0, P1 : Integer;
  Ready : Boolean;
begin
  Result := TStringList.Create;
  P0 := 1;
  Repeat
    P1 := PosEx(UseSepChar, DataLine, P0);
    Ready := (P1 = 0);
    If Ready then
      P1 := Length(DataLine)+1;  // simulate terminating SepChar

    Result.Append(Copy(DataLine, P0, P1-P0));
    P0 := P1+1;
  Until Ready;

  While Result.Count < Ord(High(TTransLang))+1 do
    Result.Append('');
end;

function TAddTrans.SLToDataLine(const SL: TStringList): AnsiString;
var
  I : Integer;
begin
  Result := SL[0];
  For I := 1 to SL.Count -1 do
    Result := Result + UseSepChar + SL [I];
end;

function TAddTrans.DataLineInsLang(const DataLine: AnsiString; S: String;
  Lang: TTransLang): AnsiString;
var
  SL : TStringList;
begin
  SL := DataLineToSL(DataLine);
  SL[Ord(Lang)] := S;
  Result := SLToDataLine(SL);
  SL.Free;
end;

procedure TAddTrans.InsertTrans(Org, Tra: String; Lang: TTransLang);
// Org is used to find entry
// tra is inserted under field of Lang if not TL_ORG
var
  Indx : Integer;
  DataLine : AnsiString;
begin
  Indx := OrgIndex(Org);
  If Indx < 0 then
  begin
    DataLine := EmptyLine;
    DataLine := DataLineInsLang(DataLine, Org, TL_Org);
  end else
  begin
    if Lang = TL_ORG then EXIT; // nothing news

    DataLine := Data[Indx];
  end;

  if (Lang <> TL_Org) and (Tra <> '') then
    DataLine := DataLineInsLang(DataLine, Tra, Lang);

  If Indx < 0 then
  begin
    Data.Append(DataLine);
  end else
  begin
    Data[Indx] := DataLine;
  end;
end;

procedure TAddTrans.LoadClick(Sender: TObject);
var
  SL : TStringList;
  R, C : Integer;
begin
  If FileExists(UseTxtNameAdd) then
    Data.LoadFromFile(UseTxtNameAdd);

  // Data To StringGrid aSG:
  aSG.RowCount := Data.Count;
  aSG.ColCount := Ord(High(TTransLang))+1;
  For R := 0 to Data.Count -1 do
  begin
    SL := DataLineToSL(Data[R]);

    for C := 0 to SL.Count -1 do
      aSG.Cells[C, R] := SL[C];
    SL.Free;
  end;
end;

procedure TAddTrans.SaveClick(Sender: TObject);
var
  SL : TStringList;
  R, C : Integer;
begin
  For R := 0 to Data.Count -1 do
  begin
    SL := DataLineToSL(EmptyLine);

    for C := 0 to SL.Count -1 do
      SL[C] := aSG.Cells[C, R];

    Data[R] := SLToDataLine(SL);
    SL.Free;
  end;


  Data.SaveToFile(UseTxtNameAdd);
end;

procedure TAddTrans.EditContent;
Const
  BtnW = 200;
var
  aForm : TForm;
  aTB : TToolbar;
  aBtnL, ABtnS : TButton;
begin
  aForm := TForm.Create(nil);
  aForm.Parent := nil;
  aForm.WindowState := wsMaximized;

    aTB := TToolBar.Create(aForm);
    aTB.Parent := aForm;
//    aTB.Align := alTop;
    aTB.ButtonWidth := BtnW;


    aBtnS := TButton.Create(aTB);
    aBtnS.Parent := aTB;
    aBtnS.Width  := BtnW;
    aBtnS.Caption := 'Save TransTxtAdd.txt';
    aBtnS.OnClick := SaveClick;

    aBtnL := TButton.Create(aTB);
    aBtnL.Parent := aTB;
    aBtnL.Width  := BtnW;
    aBtnL.Caption := 'Load TransTxtAdd.txt';
    aBtnL.OnClick := LoadClick;

    aSG := TStringGrid.Create(aForm);
    aSG.Parent := aForm;
    aSG.Align := alClient;
    aSG.DefaultColWidth := 500;
    asG.Options := asG.Options + [goEditing,goColSizing,goThumbTracking];
    aSG.EditorMode := True;

  aForm.ShowModal;
  FreeAndNil(aForm);
end;


(*
procedure TTranslateDataModule.AFieldChanged(Field: TField);
begin
  // fired as soon as the changed field looses focus
  // but closing the form using the "x" - button
  // does not fire!
  // so we use additionally TblTranslate.BeforeEdit
  // ShowMessage('AFieldChanged');
  RequestPrepTransLang := True;
end;
*)
procedure TTranslateDataModule.DataModuleCreate(Sender: TObject);
begin
  if GlbLangExt = '.ENG' then TransLang := TL_Eng else
  if GlbLangExt = '.GER' then TransLang := TL_Ger else
  if GlbLangExt = '.FRE' then TransLang := TL_Fre else
  if GlbLangExt = '.ITA' then TransLang := TL_Ita else
  if GlbLangExt = '.SPA' then TransLang := TL_Spa else
     TransLang := TL_Eng;

  NumTexts := 0;
  if UseDb then
  begin
//    TblTranslate.Open;
//     TblTranslateORG.ReadOnly := True;
//     TblTranslateORG.OnChange := AFieldChanged;
//     TblTranslateGER.OnChange := AFieldChanged;
//     TblTranslateENG.OnChange := AFieldChanged;
//     TblTranslateFRE.OnChange := AFieldChanged;
//     TblTranslateITA.OnChange := AFieldChanged;
//     TblTranslateSPA.OnChange := AFieldChanged;
  //   TblTranslateFRE.ReadOnly := True;
  end;
  RequestPrepTransLang := True;
  ChkPrepTransLang_;
//  if UseDb then
//    CreateExportFile(UseTxtName);
end;
(*
procedure TTranslateDataModule.CreateExportFile(ExpName: String);
var
  ExpStr  : AnsiString;
  procedure Add(S: String);
  begin
    If (ExpStr <> '') then
      ExpStr:= ExpStr + TextSeparator;
    if pos(TextSeparator, S) > 0 then
    begin
      showMessage('TTranslateDataModule.CreateExportFile: Separtor in Text!');
    end;
    ExpStr:=ExpStr + OemToString(S);
  end;
var
  Ok : Boolean;
  StrList : TStringList;
begin
  // fill the list from TblTranslate:
  StrList := TStringList.Create;
  Ok := TblTranslate.FindFirst;
  While Ok do
  begin
    ExpStr := '';
    Add(TblTranslateORG.Text);
    Add(TblTranslateGER.Text);
    Add(TblTranslateENG.Text);
    Add(TblTranslateFRE.Text);
    Add(TblTranslateITA.Text);
    Add(TblTranslateSPA.Text);

    StrList.Append(ExpStr);
    Ok := TblTranslate.FindNext;
  end;
  StrList.SaveToFile(ExpName);
  StrList.Free;
end;
*)
procedure TTranslateDataModule.FillStrList(var StrList: TStringList; aTransLang: TTransLang);
var
//  Ok : Boolean;
  S  : String;

  StrListUseTxt : TStringList;
  I : Integer;
  ImpStr : AnsiString;

  Function GetLangText(aTransLang: TTransLang): String;
  // assumes ImpStr surrounded by TextSeparator
  var
    PartNr, P1, P2 : Integer;
  begin
    PartNr := 0;
    P1 := 1;
    While PartNr <= Integer(aTransLang) do
    begin
      P1 := PosEx(TextSeparator, ImpStr, P1);
      Inc(P1);
      Inc(PartNr);
    end;
    P2 := PosEx(TextSeparator, ImpStr, P1);
    Result := Copy(ImpStr, P1, P2-P1);
  end;
  
begin
  // empty the list if not empty:
  StrList.Free;

  // create the list and set necessary options
  StrList := TStringList.Create;
  StrList.CaseSensitive := False;
  StrList.Sorted        := False;
  StrList.Duplicates    := dupAccept;

  if UseDb then
  begin // UseDb
    // fill the list from TblTranslate:
(*
    Ok := TblTranslate.FindFirst;
    While Ok do
    begin
      Case aTransLang of
        TL_Org: S := TblTranslateOrg.Text;
        TL_Ger: S := TblTranslateGer.Text;
        TL_Eng: S := TblTranslateEng.Text;
        TL_Fre: S := TblTranslateFre.Text;
        TL_Ita: S := TblTranslateIta.Text;
        TL_Spa: S := TblTranslateSpa.Text;
        else    S := TblTranslateEng.Text;
      end;
      If (S = '') then
        Case TransLang of
          TL_Fre .. TL_Spa :
            S := TblTranslateEng.Text;
        end;
      If (S = '') then
        S := TblTranslateOrg.Text;
      StrList.Append(OemToString(S));
      Ok := TblTranslate.FindNext;
    end;
*)
  end else
  begin // do not use DB
    // fill the list from TblTranslate:
    StrListUseTxt := TStringList.Create;
    try
      if FileExists(UseTxtName) then
      StrListUseTxt.LoadFromFile(UseTxtName);
    except
      on E: Exception do ShowMessage(E.Message);
    end;
    NumTexts := StrListUseTxt.Count;
    for I := 0 to StrListUseTxt.Count -1 do
    begin
      ImpStr := TextSeparator+StrListUseTxt[I]+TextSeparator;
      S := GetLangText(aTransLang);
      If (S = '') then
        Case TransLang of
          TL_Fre .. TL_Spa :
            S := GetLangText(TL_Eng);
        end;
      If (S = '') then
        S := GetLangText(TL_Org);
      StrList.Append(S);
    end;
    StrListUseTxt.Free;
  end;
end;

procedure SortStrListOrg(StrList: TStringList);
var
  I : Integer;
begin
  // use the ObjectsArray to store the Index before sorting
  For I := 0 to StrList.Count -1 do
    StrList.Objects[I] := Pointer(I);
  StrList.Sorted := True;  // sorts when changes from false to true
end;

procedure TTranslateDataModule.PrepTransLang;
//var
//  RecNoSav : Integer;
begin
  RequestPrepTransLang := False;
  if UseDb then
  begin
//    RecNoSav := TblTranslate.RecNo;
  end;
  FillStrList(StrListOrg, TL_Org);
  SortStrListOrg(StrListOrg);
  FillStrList(StrListTra, TransLang);
  if UseDb then
  begin
(*
    TblTranslate.RecNo := RecNoSav;  // is not working with DB!
    If (TblTranslate.RecNo <> RecNoSav) and
       (TblTranslate.RecordCount > RecNoSav) then
    begin  // so move to RecNo step by step:
      TblTranslate.First;
      While TblTranslate.RecNo < RecNoSav do
        TblTranslate.FindNext;
    end;
*)
  end;
end;

procedure TTranslateDataModule.ChkPrepTransLang_;
begin
  if RequestPrepTransLang then
    PrepTransLang;
end;

procedure TTranslateDataModule.SetTransLang(const Value: TTransLang);
begin
  If (Value <> FTransLang) then
  begin
    FTransLang := Value;
    PrepTransLang;
  end;
end;

function TTranslateDataModule.TransLangMsg: String;
begin
  Result := TransLangMsgArr[TransLang];
end;

function  TTranslateDataModule.TranslateOrg(Org: String): String;
var
  Index : Integer;
begin
  If (Length(Org) <= 1) or (TransLang = TL_Org) then
  begin // nothing to translate
    Result := Org;
    EXIT;
  end;

  // --- start translate ---
  Result := '';

  // --- use the sorted StrListOrg: ---
  If StrListOrg.Find(Org, Index) then
  Result := StrListTra[Integer(StrListOrg.Objects[Index])];
  // --- use the unsorted StrListOrg: ---
  //Index := StrListOrg.IndexOf(Org);
  //If (Index >= 0) then
  //  Result := StrListTra[Index];

  // --- try to adapt the translation file
  If (Result = '') and
     (not AcceptInvalidXctDir) then  // not A.: 04.02.09 P.W
  begin
//    ShowMessageFmt('Please translate "%s" to "%s"',[Org, TransLangMsg]);
    AddTrans.InsertTrans(Org, '', TL_ORG);
  end;
  // ---

  // --- if nothing found then return Org: ---
  If (Result = '') then
    Result := Org
//+'_o'
//else Result := Result + '_t';
    ;
end;

procedure TTranslateDataModule.dtsrcTranslateUpdateData(Sender: TObject);
begin
  // fired when a) "edit record" and "select other one"
  // not on close edit formular!
  // not on change to other field!
//  ShowMessage('dtsrcTranslateUpdateData');
end;

//procedure TTranslateDataModule.TblTranslateAfterEdit(DataSet: TDataSet);
//begin
  // fired when first change switches into Edit mode
//  ShowMessage('TblTranslateAfterEdit');
//end;

//procedure TTranslateDataModule.TblTranslateAfterPost(DataSet: TDataSet);
//begin
//  ShowMessage('TblTranslateAfterPost');
//end;

//procedure TTranslateDataModule.TblTranslateBeforeEdit(DataSet: TDataSet);
//begin
//  AFieldChanged(nil);
//end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  fAddTrans := nil;
  TranslateDataModule:= nil;
//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
  TranslateDataModule := TTranslateDataModule.Create;//(nil);
  TranslateDataModule.DataModuleCreate(nil);
//  AddTrans := TAddTrans.Create;  until 04.02.09 P.W
end;
function Unit_Final(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  TranslateDataModule.Free;
  fAddTrans.Free;  // AddTrans -> fAddTrans 04.02.09 P.W
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init, Unit_Final);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  TranslateDataModule := TTranslateDataModule.Create;//(nil);
  TranslateDataModule.DataModuleCreate(nil);
//  AddTrans := TAddTrans.Create;  until 04.02.09 P.W
   -^--- moved to function Unit_Init // 03.05.24 P.W *)

Finalization
(* -v--- moved to function Unit_Final // 03.05.24 P.W
  If DebFinal('Translate') then EXIT;
  TranslateDataModule.Free;
  fAddTrans.Free;  // AddTrans -> fAddTrans 04.02.09 P.W
   -^--- moved to function Unit_Final // 03.05.24 P.W *)
end.
