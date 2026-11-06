unit FrmXCTAbout;
// modifications
// 11.01.08 P.W display Version Information

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  Param_StrUnit,   // 03.05.24 P.W
  TransX,
  XctVersion,
  GlbPath,
  Graphics,
  Forms, Windows, SysUtils,
  StdCtrls, Classes, Controls, ExtCtrls;

type
  TFrmAbout = class(TForm)
    Memo1: TMemo;
    btnOk: TButton;
    btnDetails: TButton;
    pnlButtons: TPanel;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnDetailsClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FHelpDebug: Boolean;
    procedure SetHelpDebug(const Value: Boolean);
  private
    fKeysPressed: AnsiString;
    property HelpDebug: Boolean read FHelpDebug write SetHelpDebug;
  public
    { Public declarations }
  end;

var
  FrmAbout: TFrmAbout;
  GlbHelpDebug : Boolean = False;

procedure ShowAppAbout;

Implementation
  const Unit_Name = 'FrmXCTAbout'; // 03.05.24 P.W

{$R *.dfm}

procedure TFrmAbout.btnDetailsClick(Sender: TObject);
// 11.01.08 P.W from Delphi Example: "Reading Version Information"
//   modifications:
//   order of fields as under properties Version
const
  InfoNum = 10;
  InfoStr: array[1..InfoNum] of AnsiString =
    (
     'FileVersion',
     'FileDescription',
     'LegalCopyright',
     'CompanyName',
     'InternalName',
     'Comments',
     'LegalTradeMarks',
     'OriginalFileName',
     'ProductName',
     'ProductVersion'
     );
var
  S: AnsiString;
  n, Len, i: DWORD;
  Buf: PChar;
  Value: PChar;
begin
  S := Application.ExeName;
  n := GetFileVersionInfoSize(PChar(S), n);
  if n > 0 then
  begin
    Left   := Left - Round(0.25 * Width);
    Width  :=        Round(1.50 * Width);

    Top    := Top  - Round(0.25 * Height);
    Height :=        Round(1.50 * Height);

    Buf := AllocMem(n);
//    Memo1.Lines.Add('VersionInfoSize = ' + IntToStr(n));
    Memo1.Lines.Add('');
    GetFileVersionInfo(PChar(S), 0, n, Buf);
    for i := 1 to InfoNum do
      if VerQueryValue(Buf, PChar('StringFileInfo\040904E4\' + InfoStr[i]), Pointer(Value), Len) then
        Memo1.Lines.Add(InfoStr[i] + '  :  ' + Value);
    FreeMem(Buf, n);
  end
  else
    Memo1.Lines.Add('No version information found');
  btnDetails.Enabled := False;
  ActiveControl:= btnOk;
end;

procedure TFrmAbout.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TFrmAbout.FormCreate(Sender: TObject);
begin
  TraXC(Self);  // 01.08.06 P.W
  HelpDebug := GlbHelpDebug;
  // further modifications of Memo1 content in ShowAppAbout;
end;

procedure ShowAppAbout;
var
  AppName, AgeMsg : String;
begin
  If not assigned(FrmAbout) then
  begin
    FrmAbout := TFrmAbout.Create(nil);
    FrmAbout.Parent := nil;
  end;
  If assigned(FrmAbout) then
  begin
    if (FrmAbout.Memo1.Lines.Count >= 2) then
    begin
      FrmAbout.Memo1.Lines[1] := XctCompanyNameMsg;
    end;
    if (FrmAbout.Memo1.Lines.Count >= 4) then
    begin
      if FrmAbout.Memo1.Lines[3] = 'XCTVERSION' then
        FrmAbout.Memo1.Lines[3] := XctVersionLongMsg;
    end;
    if (FrmAbout.Memo1.Lines.Count >= 6) then
    begin
      if (Pos('Copyright', FrmAbout.Memo1.Lines[5]) > 0)  then
        FrmAbout.Memo1.Lines[5] := XctCopyRightShortMsg;
    end;
    AppName := ExpandFileName(Param_Str(0));
    AgeMsg  := DateToStr(FileDateToDateTime(FileAge(AppName)));

    FrmAbout.Memo1.Lines.Append(
      Format('%s %s [%s]',
             [ExtractFileName(AppName),
             AgeMsg,
             ShortDateFormat]));

    FrmAbout.Memo1.Lines.Append(XctDir);
    FrmAbout.Memo1.Lines.Append(XctDev);

    FrmAbout.ShowModal;
    FreeAndNil(FrmAbout);
  end;
end;


procedure TFrmAbout.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
// needs KeyPreview = True
begin
  case Key of
    VK_Space: fKeysPressed := '';
    Ord(' ')+1 .. 255:
    begin
      fKeysPressed := fKeysPressed + Char(Ord(Key));
    end;
  end;
  HelpDebug := (fKeysPressed = '12344321');
end;


procedure TFrmAbout.SetHelpDebug(const Value: Boolean);
begin
  FHelpDebug := Value;
  GlbHelpDebug := Value;
  if FHelpDebug then
  begin
    Memo1.Font.Color := clGreen;
  end else
  begin
    Memo1.Font.Color := clPurple;
  end;
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  FrmAbout     := nil;
  GlbHelpDebug := False;
//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Initialization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);
end.

