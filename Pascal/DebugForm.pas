unit DebugForm;

interface

uses
  DebugUnit,        // 03.05.24 P.W
  InitFinal_List,   // 03.05.24 P.W
  MsgBox, Math, StrUtils, WinTmr,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ExtCtrls;

type
  TMemo2 = class(TMemo)
  end;

  TfrmDebug = class(TForm)
    memDebug: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Clear1: TMenuItem;
    KeepWindow1: TMenuItem;
    Options1: TMenuItem;
    StayAtTop1: TMenuItem;
    OnLine1: TMenuItem;
    tmrApd: TTimer;
    ResetFLevel1: TMenuItem;
    tmrCheckEnable: TTimer;
    Larger1: TMenuItem;
    Smaller1: TMenuItem;
    FontDialog1: TFontDialog;
    Font1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure KeepWindow1Click(Sender: TObject);
    procedure memDebugClick(Sender: TObject);
    procedure StayAtTop1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnLine1Click(Sender: TObject);
    procedure tmrApdTimer(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure ResetFLevel1Click(Sender: TObject);
    procedure tmrCheckEnableTimer(Sender: TObject);
    procedure Larger1Click(Sender: TObject);
    procedure Smaller1Click(Sender: TObject);
    procedure Font1Click(Sender: TObject);
  private
    FLineCtr,
    FLineCtrClose : Integer;
    FKeepOpen : Boolean;
    FLevel: Integer;
    FLines : TStrings;
    FApdTmr : TPerfTmr;
    FOnLine: Boolean;
    procedure MyMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure PreFormDestroy;
    procedure SetOnLine(const Value: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CheckEnable;
  public
    procedure Clear;
    procedure Append   (const S      : AnsiString; DeltaLevel:Integer=0);
    procedure IncLevel;
    procedure DecLevel;
    property  OnLine: Boolean read FOnLine write SetOnLine;
  end;

function frmDebug: TfrmDebug;

procedure DebCheckInit(X0, Y0, dX, dY: Integer);
procedure DebClear;
procedure DebDebugOff(Title: AnsiString);
procedure DebMsgLine(const S: AnsiString; LineIdx: Integer); overload;
procedure DebMsgLine(const aFormat: AnsiString; const Args: array of const; LineIdx: Integer); overload;
procedure DebApp(const S: AnsiString; DeltaLevel:Integer=0); overload;
procedure DebApp(const aFormat: AnsiString; const Args: array of const; DeltaLevel:Integer=0); overload;
procedure DebDecLevel;
procedure DebIncLevel;
procedure DebOnline(Value: Boolean);

procedure AppendToFile(aName, aText: AnsiString);

Implementation
  const Unit_Name = 'DebugForm'; // 03.05.24 P.W

{$R *.dfm}

var
  ffrmDebug: TfrmDebug;

function frmDebug: TfrmDebug;
var
  ActiveCustFrm : TCustomForm;
begin
  if not assigned(ffrmDebug) then
  begin
    ffrmDebug := TfrmDebug.Create(nil);
  end;
  Result := ffrmDebug;
//exit;
  if (not Result.Visible) and (not (fsShowing in Result.FFormState)) then
  try
    ActiveCustFrm := Screen.ActiveCustomForm;
    try
      Result.Show;  // throws an exception during onShow onHide
    finally
      if Assigned(ActiveCustFrm) and ActiveCustFrm.Enabled then
        ActiveCustFrm.SetFocus;
    end;
  except
  end;

end;

procedure DebCheckInit(X0, Y0, dX, dY: Integer);
begin
  if not Assigned(ffrmDebug) then
  begin
    frmDebug.BoundsRect := Rect(X0, Y0, X0+dX, Y0+dY);
  end;
end;

procedure DebClear;
begin
  frmDebug.Clear;
end;

procedure DebDebugOff(Title: AnsiString);
// Off allows DebApp DeltaLevel 1 ... 2 used as lineNumbers (1=first line)
begin
  frmDebug.Caption  := Title;
  frmDebug.KeepWindow1.Visible := False;
  frmDebug.OnLine1.Visible := False;
end;

procedure DebMsgLine(const S: AnsiString; LineIdx: Integer);
begin
  While frmDebug.memDebug.Lines.Count < LineIdx +1 do
    frmDebug.memDebug.Lines.Append('');
  frmDebug.memDebug.Lines[LineIdx] := S;
end;

procedure DebMsgLine(const aFormat: AnsiString; const Args: array of const; LineIdx: Integer); overload;
begin
  DebMsgLine(Format(aFormat, Args), LineIdx);
end;

procedure DebApp(const S: AnsiString; DeltaLevel:Integer=0);
begin
  try
    frmDebug.Append(S, DeltaLevel);
  except
  end;
end;

procedure DebApp(const aFormat: AnsiString; const Args: array of const; DeltaLevel:Integer=0);
begin
  try
    DebApp(Format(aFormat, Args), DeltaLevel);
  except
  end;
end;

procedure DebDecLevel;
begin
  frmDebug.DecLevel;
end;

procedure DebIncLevel;
begin
  frmDebug.IncLevel;
end;

procedure DebOnline(Value: Boolean);
begin
  frmDebug.OnLine := Value;
end;

procedure AppendToFile(aName, aText: AnsiString);
var
  fs : TFileStream;
begin
  if FileExists(aName) then
    fs := TFileStream.Create(aName, fmOpenWrite, fmShareDenyWrite)
  else
  begin
    ForceDirectories(ExtractFileDir(aName));
    fs := TFileStream.Create(aName, fmCreate,    fmShareDenyWrite);
  end;
  fs.Seek(0, soFromEnd);
  fs.Write(aText[1], Length(aText));
  fs.Write(sLineBreak, Length(sLineBreak));
  fs.Free;
end;

{ TfrmDebug }

procedure TfrmDebug.CheckEnable;
begin
  if not IsWindowEnabled(Handle) then
  begin
    EnableWindow(Handle, True);
  end;
end;


procedure TfrmDebug.CreateParams(var Params: TCreateParams);
// use override!
begin
  inherited CreateParams(Params);

  with Params do
  begin
    ExStyle := ExStyle and WS_EX_APPWINDOW;  // for own taskbar button
//    ExStyle := ExStyle or WS_EX_TRANSPARENT;
//    ExStyle := ExStyle or WS_EX_TOPMOST;
 //   Style     := Style AND NOT WS_CAPTION;  // no caption ; needs BorderStyle property the value bsNone
    WndParent := GetDesktopwindow;     // for systemwide topmost and independend taskbar button
//    Style     := Style or WS_HSCROLL or WS_VSCROLL;// AND NOT WS_OVERLAPPED;
  end;
//  BorderStyle := bsNone;  // in properties or in FormCreate!
end;

procedure FileAppendLine(const fName, Msg: AnsiString; AppendFlg : Boolean);
var
  f : Text;
begin
  try
    try
      Assign(f, fName);
      if FileExists(fName) and AppendFlg
        then Append(f)
        else Rewrite(f);
      Writeln(f, Msg);
    finally
      Close(f);
    end;
  except
  end;
end;

procedure TfrmDebug.Append(const S: AnsiString; DeltaLevel:Integer=0);
  function FLevelStr: AnsiString;
  begin
    if FLevel = 0
      then Result := '  :'
      else Result := Format('%2d:%s', [FLevel, DupeString(' |', FLevel)])
  end;
var
  DeltaSec : Double;
  DeltaChr : Char;
  Msg      : AnsiString;
begin
  Inc(FLineCtr);
  if OnLine then
  begin
    try
      if DeltaLevel < 0 then DebDecLevel;
      try
        DeltaSec := ReadPerfTmrSec(FApdTmr);
        if DeltaSec > 0.099
          then DeltaChr := '>'
          else DeltaChr := ' ';
        Msg := Format('%4d%s%6.3f %s %s', [FLineCtr, DeltaChr, DeltaSec, FLevelStr, S]);
//        FileAppendLine('C:\TEMP\DebugForm.txt', Msg, FLineCtr<>1);
        StartPerfTmr(FApdTmr);
        FLines.Append(Msg);
      finally
        if DeltaLevel > 0 then DebIncLevel;
      end;
      tmrApd.Enabled := True;
      Application.ProcessMessages;
    except
    end;  
  end;
end;

procedure TfrmDebug.Clear;
begin
//  FLineCtr := 0;
  FLines.Clear;
  memDebug.Clear;
end;

procedure TfrmDebug.MyMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  NumDelta : Integer;
begin
  NumDelta := WheelDelta div WHEEL_DELTA;
  if (ssCtrl in Shift) then
  begin
    Handled := True;
    if NumDelta > 0 then
    begin
      memDebug.Perform(WM_VSCROLL, SB_PAGEUP, 0);
    end else
    if NumDelta < 0 then
    begin
      memDebug.Perform(WM_VSCROLL, SB_PAGEDOWN, 0);
    end;
  end;
end;

procedure TfrmDebug.FormCreate(Sender: TObject);
var
  mf : TForm;
begin
  Width   := Round(0.40 * Screen.WorkAreaWidth);  // div 5;
  Height  := Screen.WorkAreaHeight;// div 2;
  FLines  := TStringList.Create;
  FOnLine := True;

  Left := Screen.WorkAreaLeft + (Screen.WorkAreaWidth - Width);
  FormStyle := fsStayOnTop;
  mf := Application.MainForm;
  if Assigned(mf) then
  begin
//    KeyPreview := mf.KeyPreview;
//    OnKeyDown  := mf.OnKeyDown;
//    OnKeyPress := mf.OnKeyPress;
//    OnKeyUp    := mf.OnKeyUp;
    Left := Min(Left, mf.Left + mf.Width);
    Top  := mf.Top;
  end;
  TMemo2(memDebug).OnMouseWheel := MyMouseWheel;
  StartPerfTmr(FApdTmr);
end;

procedure TfrmDebug.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmDebug.Clear1Click(Sender: TObject);
begin
  Clear;
end;

procedure TfrmDebug.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  OnLine1.Enabled := False;
  FLineCtrClose := FLineCtr;
end;

procedure TfrmDebug.KeepWindow1Click(Sender: TObject);
begin
  if FKeepOpen then EXIT;

  FKeepOpen := True;
  if not Application.Terminated then
    KeepWindow1.Caption := 'Autoclose disabled!'
  else
    MemDebug.Lines.Append('Autoclose disabled!');
  KeepWindow1.Enabled := False;
end;

procedure TfrmDebug.memDebugClick(Sender: TObject);
begin
  if Application.Terminated then
    KeepWindow1Click(Sender);
end;

procedure TfrmDebug.StayAtTop1Click(Sender: TObject);
begin
  if StayAtTop1.Checked then
  begin
    SetWindowPos(Handle, HWND_TOPMOST,     0, 0, 0, 0, SWP_NOSIZE or SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOREPOSITION);
  end else
  begin
    SetWindowPos(Handle, HWND_NOTOPMOST,   0, 0, 0, 0, SWP_NOSIZE or SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOREPOSITION);
  end;
end;

procedure TfrmDebug.DecLevel;
begin
  Dec(FLevel);
end;

procedure TfrmDebug.IncLevel;
begin
  Inc(FLevel);
end;

procedure TfrmDebug.OnLine1Click(Sender: TObject);
begin
  OnLine:= not Online;
end;

procedure TfrmDebug.tmrApdTimer(Sender: TObject);
begin
  tmrApd.Enabled := False;
  memDebug.Text := FLines.Text;
  memDebug.Perform(WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TfrmDebug.PreFormDestroy;
// 23.11.07 P.W: ensure debug output stays visible at program termination
var
  DelayCloseCtr: Integer;
begin
  DelayCloseCtr := 20;
  if (not FKeepOpen)
     and
     (
       ((FLines.Text = '') and (memDebug.Text = ''))
       or
       (FLineCtrClose = FLineCtr)
       or
       (ReadPerfTmrSec(FApdTmr) > 2.5)
     )
   then exit;   // -> destroy immediate
  Visible := True;
  WindowState := wsNormal;
  repeat
    Application.ProcessMessages;
    Sleep(100);
    dec(DelayCloseCtr);
    if (not FKeepOpen) then
    begin  // delayed destroy ...
      //KeepWindow1.Caption := Format('Keep Window (%.1f)', [0.1*DelayCloseCtr]);
      MemDebug.Text := FLines.Text;
      MemDebug.Lines.Append(Format('Closing ... (%.1f); Click to stop', [0.1*DelayCloseCtr]));
      if (DelayCloseCtr < 0) then
        Visible := False;
    end;
  until not self.Visible;
end;

procedure CheckClose_ffrmDebug;
begin
  if Assigned(ffrmDebug) then
  begin
    ffrmDebug.OnLine1.Enabled := False;
    ffrmDebug.PreFormDestroy;
    FreeAndNil(ffrmDebug);
  end;
end;

procedure TfrmDebug.Options1Click(Sender: TObject);
begin
  ResetFLevel1.Enabled := (FLevel <> 0);
end;

procedure TfrmDebug.ResetFLevel1Click(Sender: TObject);
begin
  FLevel := 0;
end;

procedure TfrmDebug.tmrCheckEnableTimer(Sender: TObject);
begin
  CheckEnable;
end;

procedure TfrmDebug.SetOnLine(const Value: Boolean);
begin
  FOnLine := Value;
  if FOnLine then
  begin
    OnLine1.Caption := 'OnLine';
//    if Sender = OnLine1 then
      memDebug.Lines.Append('Online');
  end else
  begin
    OnLine1.Caption := 'Off Line!';
    memDebug.Lines.Append('OFF LINE!');
  end;
  OnLine1.Checked := FOnLine;
end;

procedure TfrmDebug.Larger1Click(Sender: TObject);
var
  FS : Integer;
begin
  FS := memDebug.Font.Size;
  if FS < 8
    then Inc(FS, 1)
    else Inc(FS, Round(0.3 * FS));

  if FS > 14 then
    memDebug.Font.Style := [fsBold]
  else
    memDebug.Font.Style := [];
    
  memDebug.Font.Size := FS;
end;

procedure TfrmDebug.Smaller1Click(Sender: TObject);
var
  FS : Integer;
begin
  FS := memDebug.Font.Size;
  if FS < 5 then Exit;
  if FS < 8
    then Dec(FS, 1)
    else Dec(FS, Round(0.3 * FS));

  if FS > 14 then
    memDebug.Font.Style := [fsBold]
  else
    memDebug.Font.Style := [];


  memDebug.Font.Size := FS;
end;

procedure TfrmDebug.Font1Click(Sender: TObject);
begin
  FontDialog1.Font := memDebug.Font;
  if FontDialog1.Execute then
  begin
    memDebug.Font := FontDialog1.Font;
  end;
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  ffrmDebug := nil;

//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Initialization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
end;
function Unit_Final(aMode: Integer=0): Integer;
// Finalization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  CheckClose_ffrmDebug;
end;
initialization
  InitFinal_Add(Unit_Name, Unit_Init, Unit_Final);

finalization
(* -v--- moved to function Unit_Final // 03.05.24 P.W
  CheckClose_ffrmDebug;
   -^--- moved to function Unit_Final // 03.05.24 P.W *)
end.
