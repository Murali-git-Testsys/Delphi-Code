// send Form info to screen that does normaly not wait to be closed
// (closes itself using tmrClose)
// ! But when the Application closes the form closes immediately
//   Form.close is not fired each time!
//   Form.destroy also not!
// free is not fired when Close is called except OnClose is doing so!
// but free and nil in onClose crashes in many cases

// To achive Form is freed: OnClose: FormClose calls btnOkclick
// btnOkClick uses timer to free the form

// Modifications:
// 22.12.06 P.W:
//  a) Instead of FreeAndNil by Timer use FormOnClose Action = caFree (better programming style)
//  b) Position and size when closed are used as default for next opening window
// 15.12.08 P.W: MessageDlgExt from UfrmBack.pas to here

// ########################################################################################
// ###################### compare Units: UMsgDelay, MsgBox, DialogSecure
// ########################################################################################

unit UMsgDelay;

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  HaltUnit,
  Param_StrUnit,
  TransX,
  DialogsSecure, // 26.08.09 P.W
  MsgBox,        // 26.08.09 P.W
  ActnList,      // 15.12.08 P.W
  ClipBrdUse,    // 15.12.08 P.W
  Math,          // 15.12.08 P.W
  GlbType,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus;

const
  // return values of MessageDlgExt when a button has been pressed:
  MR_MsgDlgExtBase   = 100;
  MR_MsgDlgExt_1st   = MR_MsgDlgExtBase + 0; // first button
  MR_MsgDlgExt_2nd   = MR_MsgDlgExtBase + 1; // second button
  MR_MsgDlgExt_3rd   = MR_MsgDlgExtBase + 2; // third button
  MR_MsgDlgExt_4th   = MR_MsgDlgExtBase + 3; // fourth button
  MR_MsgDlgExt_5th   = MR_MsgDlgExtBase + 4; // fifth button

type
  TfrmMsgDelay = class(TForm)
    Panel2: TPanel;
    btnOk: TButton;
    tmrClose: TTimer;
    memMsg: TMemo;
    btnHoldMsg: TButton;
    btnCancel: TButton;
    procedure btnOkClick(Sender: TObject);
    procedure tmrCloseTimer(Sender: TObject);
    procedure btnHoldMsgClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
  private
    ActiveFormWhenCreated : TForm;
    procedure frmMsgStop;
  public
    constructor Create(Msg:AnsiString; DelayMs: Integer= 3000; Title:String=''); reintroduce;
  end;

var
  MsgCtr : Integer = 0;         // Unique for each Message
  MsgDelayWindow : THandle = 0; // for ForceToFront
  MsgDelayEsc : Boolean = false;

type
  TMsgMode = (MSG_None, MSG_Delay, MSG_Wait, MSG_WaitEver);        // 28.07.06 P.W

function MessageDlgExt1(Title, Msg: AnsiString; ButtonsCapt : Array of AnsiString;
  Enabled: Array of Boolean; DefaultBtnIdx: Integer; uType: UINT; Alignment: TAlignment;
  ButtonsHoriz: Boolean; EscapeIdx: Integer) : Integer;
function MessageDlgExt(Title, Msg: AnsiString; ButtonsCapt : Array of AnsiString;
  DefaultBtnIdx:Integer=0; uType:UINT=MB_ICONEXCLAMATION; Alignment:TAlignment=taLeftJustify;
  ButtonsHoriz:Boolean=True; EscapeIdx:Integer=-1) : Integer;
procedure ShowMessageExt(const Msg: AnsiString; uType:UINT=MB_OK; Alignment:TAlignment=taLeftJustify); overload;
procedure ShowMessageExt(const aFmt: AnsiString; const Args: Array of const; uType:UINT=MB_OK; Alignment:TAlignment=taLeftJustify); overload;

function ShowMessageMs(Msg:AnsiString;
            DelayMs: Integer= 3000; Title:String=''; TestPathFlg:Boolean=False;
            Options:Integer=0): TfrmMsgDelay;
function ShowMessageFmtMs(const Msg: AnsiString; Params: array of const;
            DelayMs: Integer= 3000; Title:String= ''): TfrmMsgDelay;
procedure ShowMessageMode(const Msg: AnsiString; MsgMode: TMsgMode;
            DelayMs: Integer= 3000; Title:String='');

Implementation

uses Types;
  const Unit_Name = 'UMsgDelay'; // 03.05.24 P.W

{$R *.dfm}

type
  TCtrlCNotifyEvent= class (TObject)
    fForm : TForm;
    procedure CtrlCNotifyEvent(Sender: TObject);
    procedure ShortCutEvent(Sender: TObject);
    constructor Create(aForm: TForm);
  end;

procedure TCtrlCNotifyEvent.CtrlCNotifyEvent(Sender: TObject);
var
  RequestClear : Boolean;

  procedure AppNE(S: AnsiString);
  begin
    if (S <> '') then
    begin
      if RequestClear then
      begin
        RequestClear := False;
        ToClipboard(S);
      end else
        AppendToClipboard(S);
    end;
  end;
  procedure AppCB(c: TControl);
  var
    I : Integer;
  begin
    if C is TForm   then AppNE(TForm  (C).Caption) else
    if C is TMemo   then AppNE(TMemo  (C).Text   ) else
    if C is TLabel  then AppNE(TLabel (C).Caption) else
    if C is TPanel  then AppNE(TPanel (C).Caption) else
    if C is TButton then AppNE(TButton(C).Caption) else
      ; // ";": end of else!

    if C is TWinControl then
      for I := 0 to TWinControl(c).ControlCount -1 do
        AppCB(TWinControl(c).Controls[I]);
  end;
begin
  RequestClear := True;
  if Assigned(fForm) and
    IsWindow(fForm.Handle) then
      AppCB(fForm);
end;

procedure TCtrlCNotifyEvent.ShortCutEvent(Sender: TObject);
begin
  if Assigned(fForm) and
    IsWindow(fForm.Handle) and
      (Sender is TAction) then
        fForm.ModalResult := TAction(Sender).Tag;
end;

constructor TCtrlCNotifyEvent.Create(aForm: TForm);
begin
  fForm := aForm;
end;

function MessageDlgExt1(Title, Msg: AnsiString; ButtonsCapt : Array of AnsiString;
  Enabled: Array of Boolean; DefaultBtnIdx:Integer; uType:UINT; Alignment:TAlignment;
  ButtonsHoriz:Boolean; EscapeIdx:Integer) : Integer;           overload;
// first button returns MR_MsgDlgExtBase+0 next MR_MsgDlgExtBase+1 and so on
// Modifications:
// 15.12.08 P.W: support Ctrl-C to copy content to clipboard
//   autosize of buttons and form; support hotkeys for buttons
// 24.07.09 P.W: ButtonsHoriz=False to support vertical order of buttons (for use by SvMen SvAbortDlg)
const
  MinPicWidth = 20;
  MaxPicWidth = 50;
var
  frm : TForm;

  procedure AdaptButtonCaptions;
  var
    aPop     : TPopupMenu;
    b, Index : Integer;
    NewItem  : TMenuItem;
  begin
    aPop := TPopupMenu.Create(nil);
    for b := low (ButtonsCapt) to high(ButtonsCapt) do
    begin
      NewItem := TMenuItem.Create(aPop); // create the new item
      aPop.Items.Add(NewItem);           // add it to the Popupmenu
      NewItem.Caption := ButtonsCapt[b];
    end;

    if aPop.Items.RethinkHotkeys then
    for b := low (ButtonsCapt) to high(ButtonsCapt) do
    begin
      Index := b - low (ButtonsCapt);
      ButtonsCapt[b] := aPop.Items[Index].Caption;
    end;
    aPop.Free;
  end;

  function CheckButtonsCaptUseFirst: Boolean;
  // returns true when all ButtonsCapt differ in their uppercase first character;
  // returns false else with ButtonsCapt adapted ("&") inserted to mark shortcut keys
  var
    b : Integer;
    C1 : Char;
    FirstChars: set of char;
  begin
    Result := True;
    FirstChars := [];
    for b := low (ButtonsCapt) to high(ButtonsCapt) do
    begin
      if (ButtonsCapt[b] <> '') then
      begin
        C1 := UpCase(ButtonsCapt[b][1]);
        if C1 in FirstChars then
        begin
          Result := False;
          Break;
        end else
          Include(FirstChars, C1);
      end;
    end;
    if not Result then
      AdaptButtonCaptions;
  end;

  function TextW(const S: AnsiString): Integer;
  // ! needs ParentFont = true !
  begin
    Result := frm.Canvas.TextWidth(S);
  end;

  function TextH(const S: AnsiString): Integer;
  // ! needs ParentFont = true !
  begin
    Result := frm.Canvas.TextHeight(S);
  end;
const
  ImgFile_Stop         = 'Res\IconStop.bmp';
  ImgFile_Exclamation  = 'Res\IconExclamation.bmp';
  ImgFile_Question     = 'Res\IconQuestion.bmp';
  ImgFile_Information  = 'Res\IconInformation.bmp';

var
  ImgFile : AnsiString;
  pic : TImage;              // panel for icon
  mem : TMemo;               // Message area
  pnl : TPanel;              // Buttons area
  b0, b1, b, btnCount, btnIdx : Integer;
  btn : TButton;
  btnArr : Array of TButton;      // 24.07.09 P.W
  UseFirstChars : Boolean;

  ALst : TActionList;
  AC   : TAction;
  CCNE : TCtrlCNotifyEvent;
  I, MsgW, MsgH, LCount,
  MaxBtnCols,
  MaxBtnRows,                     // 24.07.09 P.W
  btnCols, btnRows, bCol, bRow,
  df, BtnWidth, BtnHeight, memWidth, memHeight,
  frmClW, frmClH, dMaxW, dMaxH, MaxW, MaxH : Integer;
  uTypeIcon : UINT;
begin
  Result := 0;

  b0 := low (ButtonsCapt);
  b1 := high(ButtonsCapt);
  btnCount := (b1 - b0) + 1;

  if btnCount = 0 then EXIT;

  SetLength(btnArr, btnCount);  // 24.07.09 P.W

  frm             := TForm.Create(nil);
  frm.Parent      := nil;
  frm.Font.Size   := Round(1.5 * frm.Font.Size);
  frm.Font.Style  := [fsBold];
  frm.AutoScroll  := True;
  frm.BorderStyle := bsDialog;
  frm.Position    := poDesigned; //poScreenCenter; // changed to poScreenWorkAreaCenter
  if Title = '' then
    frm.Caption     := ExtractFileName(Param_Str(0))
  else
    frm.Caption     := Title;

  pic              := TImage.Create(frm);
  pic.Parent       := frm;
  pic.Width        := 0;
  pic.Proportional := True;
  pic.Center       := True;
  pic.Align        := alLeft;
  uTypeIcon := (uType and MB_ICONMASK);
  case uTypeIcon of
    MB_ICONHAND:        ImgFile := ImgFile_Stop;
    MB_ICONQUESTION:    ImgFile := ImgFile_Question;
    MB_ICONEXCLAMATION: ImgFile := ImgFile_Exclamation;
    MB_ICONASTERISK:    ImgFile := ImgFile_Information;
// --- duplicates:
//  MB_ICONWARNING:     ImgFile := ImgFile_Exclamation;
//  MB_ICONERROR:       ImgFile := ImgFile_Stop;
//  MB_ICONINFORMATION: ImgFile := ImgFile_Information;
//  MB_ICONSTOP         ImgFile := ImgFile_Stop;
    else                ImgFile := '';
  end;

  if FileExists(ImgFile) then
  begin
    try
      pic.Picture.LoadFromFile(ImgFile);
      //raise exception.Create('test load img');
      pic.Transparent := True;

    except  // ignore exceptions
    end;
    pic.Width  := Min(pic.Picture.Width+MinPicWidth, MaxPicWidth);
  end else
  begin       // avoid message starts at left side
    pic.Width := MinPicWidth;
  end;

  mem := TMemo.Create(frm);
  mem.Parent := frm;
  mem.BorderStyle := bsNone;

  mem.TabStop := False;
  mem.ReadOnly := True;
  //mem.Font.Color := clGreen;
  mem.Align := alClient;
  mem.Color :=  clBtnFace;
  mem.Text    := sLineBreak + sLineBreak + Msg + sLineBreak + sLineBreak;
  mem.ParentFont := True;
  MsgW := 0;
  MsgH := 0;
  mem.Alignment := taLeftJustify;  // not TaCenter (to count lines)
  mem.WordWrap  := False;          // together with Alignment LeftJustify
  LCount := mem.Lines.Count;       // counts non wrapped lines
  for I := 0 to LCount  -1 do
  begin
    MsgW := Max(MsgW, TextW(mem.Lines[I]));
    MsgH := Max(MsgH, TextH(mem.Lines[I]));
  end;
  mem.Alignment := Alignment;  // now taCenter may be set (changes number of mem.Lines.Count)

  memWidth  := Round(1.2 * MsgW);
  memHeight := Round(1.2 * MsgH * LCount);

  BtnWidth  := 20;
  BtnHeight := 15;
  // find BntWidth and BtnHeight
  for b := b0 to b1 do
  begin
    BtnWidth  := Max(BtnWidth,  TextW(ButtonsCapt[b]+'___'));
    BtnHeight := Max(BtnHeight, TextH(ButtonsCapt[b]      ));
  end;
  BtnHeight :=     Round(1.5 * BtnHeight)           ;
  BtnWidth  := Max(Round(3.5 * BtnHeight), BtnWidth);

  df := round(0.3 * BtnHeight);

  // check shortcuts by caption UseFirstChars is false when ampersands have been inserted:
  UseFirstChars := CheckButtonsCaptUseFirst;

  pnl := TPanel.Create(frm);
  pnl.Parent := frm;
  pnl.Caption := '';
  pnl.BevelOuter  := bvNone;
  pnl.Align := alBottom;
  pnl.ParentFont := True;

  CCNE := TCtrlCNotifyEvent.Create(frm);
  ALst := TActionList.Create(frm);
  AC   := TAction.Create(ALst);
  AC.ActionList := ALst;
  AC.ShortCut   := ShortCut(Ord('C'), [ssCtrl]);
  AC.OnExecute  := CCNE.CtrlCNotifyEvent;

  dMaxW :=  frm.Width  - frm.ClientWidth;
  dMaxH :=  frm.Height - frm.ClientHeight;
  MaxW := Screen.WorkAreaWidth -80 -dMaxW;
  MaxH := Screen.WorkAreaHeight-20 -dMaxH;

  MaxBtnCols := (MaxW - df) div (btnWidth  + df);
  MaxBtnRows := (MaxH - df) div (BtnHeight + df);   // 24.07.09 P.W
  if ButtonsHoriz then // if: 24.07.09 P.W
  begin
    btnCols := Min(btnCount, MaxBtnCols);
    btnRows := btnCount div btnCols;
    if (btnRows * btnCols) < btnCount then
      inc(btnRows);
    While (btnCols -1) * btnRows >= btnCount do
      dec(btnCols);
  end else
  begin    // 24.07.09 P.W
    btnRows := Min(btnCount, MaxBtnRows);
    btnCols := btnCount div btnRows;
    if (btnRows * btnCols) < btnCount then
      inc(btnCols);
    While (btnRows -1) * btnCols >= btnCount do
      dec(btnRows);
  end;

  btn := nil;   // to convince the compiler that btn has been initialized
  // Create Buttons and shortcuts
  DefaultBtnIdx := Min(DefaultBtnIdx, b1-b0);
  for b := b0 to b1 do
  begin
    btnIdx := b - b0;

    if ButtonsHoriz then // if: 24.07.09 P.W
    begin
      bCol   := btnIdx mod btnCols;
      bRow   := btnIdx div btnCols;
    end else
    begin    // 24.07.09 P.W
      bRow   := btnIdx mod btnRows;
      bCol   := btnIdx div btnRows;
    end;

    btn             := TButton.Create(pnl);
    btn.Parent      := pnl;
    btn.ParentFont  := True;
    btn.Caption     := ButtonsCapt[b];

    if (btnIdx = EscapeIdx) then        // 24.07.09 P.W
    begin
      btn.cancel := True;
    end;

    btn.ModalResult := MR_MsgDlgExtBase + btnIdx;

    if btnIdx <= High(Enabled) then     // 24.07.09 P.W
      btn.Enabled := Enabled[btnIdx];
    btnArr[btnIdx]  := btn;             // 24.07.09 P.W


    if UseFirstChars and    // otherwise ButtonsCapt contain "&"  which support shortcut automatically
      (btn.Caption <> '') then
    begin
      AC            := TAction.Create(ALst);
      AC.ActionList := ALst;
      AC.Tag        := btn.ModalResult;
      AC.ShortCut   := ShortCut(Ord(btn.Caption[1]), []);
      AC.OnExecute  := CCNE.ShortCutEvent;
    end;

    btn.Width       := BtnWidth;
    btn.Height      := BtnHeight;

    btn.Left := df + (BtnWidth  + df) * bCol;
    btn.Top  := df + (BtnHeight + df) * bRow;

    if (btnIdx = DefaultBtnIdx) and btn.Enabled then  // enabled: 24.07.09 P.W
    begin
      btn.Default := True;
      frm.ActiveControl := btn;
    end;

  end;

  pnl.ClientHeight := btnRows * (BtnHeight+ df) + df;
  frmClW := Max(btnCols * (BtnWidth + df) + df, Max(pic.Width + memWidth, Round(0.2 * Screen.Width)));
  frmClH := memHeight + pnl.Height;

  if (frmClW > MaxW) or
     (frmClH > MaxH) then
  begin
    if mem.Alignment = taCenter then
      mem.ScrollBars:= ssVertical  // horiz would disappear automatically (with undefined background)
    else
      mem.ScrollBars:= ssBoth;
  end;

  frm.ClientWidth  := Min(frmClW, MaxW);
  frm.ClientHeight := Min(frmClH, MaxH);

//  until: 24.07.09 P.W
//  if (btnCount = 1) and Assigned(btn) then   // single button show centered:
//    btn.Left := (pnl.ClientWidth - btn.Width) div 2;
//  since: 24.07.09 P.W // single colom of button show centered:
  if (btnCols = 1) then
    for b := 0 to btnCount -1 do
      btnArr[b].Left := (pnl.ClientWidth - btnArr[b].Width) div 2;

  if (btnCount -1 = EscapeIdx) and (btnCols = 1) then    // 24.07.09 P.W
  begin
    btnArr[EscapeIdx].Align := alBottom;
  end;


  // center to screen workarea:  
  frm.Left := Screen.WorkAreaLeft + (Screen.WorkAreaWidth  - frm.Width ) div 2;
  frm.Top  := Screen.WorkAreaTop  + (Screen.WorkAreaHeight - frm.Height) div 2;

  MessageBeep(uTypeIcon);
  MessageBox1Flg := True; // 26.08.09 P.W
  try
    Result := frm.ShowModal;
  finally
    MessageBox1Flg := False; // 26.08.09 P.W
  end;
  //ShowMessageFmt('Modal Result = %d', [Result]);

  frm.Free;
  CCNE.Free;
end;

function MessageDlgExt(Title, Msg: AnsiString; ButtonsCapt : Array of AnsiString;
  DefaultBtnIdx:Integer=0; uType:UINT=MB_ICONEXCLAMATION; Alignment:TAlignment=taLeftJustify;
  ButtonsHoriz:Boolean=True; EscapeIdx:Integer=-1) : Integer;
begin
  Result := MessageDlgExt1(Title, Msg, ButtonsCapt, [], DefaultBtnIdx, uType, Alignment, ButtonsHoriz, EscapeIdx);
end;


procedure ShowMessageExt(const Msg: AnsiString; uType:UINT=MB_OK; Alignment:TAlignment=taLeftJustify);
// 15.12.08 P.W
begin
  MessageDlgExt(ExtractFileName(Application.ExeName), Msg, ['Ok'], 0, uType, Alignment);
end;

procedure ShowMessageExt(const aFmt: AnsiString; const Args: Array of const; uType:UINT=MB_OK; Alignment:TAlignment=taLeftJustify);
// 15.12.08 P.W
begin
  ShowMessageExt(Format(aFmt, Args), uType, AlignMent);
end;


var
  DefaultPositonDefined : Boolean = False;    // 22.12.06 P.W
  DefaultPosition : TRect;                    // 22.12.06 P.W
  OpenMsgCtr : Integer = 0;                   // 22.12.06 P.W

constructor TfrmMsgDelay.Create(Msg:AnsiString; DelayMs: Integer= 3000; Title:String='');
// modifications:
// 13.12.07 P.W: memMsg.Text := Msg; moved behind TraXC(self) to avoid
//  translation of messages like 'Error screen saved to file "D:\XCT\ERRSCR\SC00288.jpg"'
begin
  MsgDelayEsc := False;
  ActiveFormWhenCreated := Screen.ActiveForm;
  inherited Create(nil);
//inheritedCreate(activeForm);

  Inc(MsgCtr);
  Inc(OpenMsgCtr);  // 22.12.06 P.W

  Caption := Title;
  Parent := nil;
//Parent := activeForm;

  // memMsg.Text := Msg;  // here until 13.12.07 P.W
  FormStyle := fsStayOnTop;

  TraXC(Self);

  memMsg.Text := Msg;     // here since 13.12.07 P.W


  if DelayMs < 0 then  // wanted: do not disappear
                       // but disappears as soon as application closes!
  begin
    tmrClose.Enabled  := False;
  end else
  if DelayMs = 0 then  // use default
  begin
    tmrClose.Interval := 3000;
    tmrClose.Enabled  := True;
  end else
  begin
    tmrClose.Interval := DelayMs;
    tmrClose.Enabled  := True;
  end;

//  Show;  // here until 22.12.06 P.W


  if (MsgDelayWindow = 0) then
    MsgDelayWindow := Self.Handle; // for ForceToFront
end;

function ShowMessageMs(Msg:AnsiString; DelayMs: Integer= 3000; Title:String=''; TestPathFlg:Boolean=False; Options:Integer=0): TfrmMsgDelay;
// modifications:
// 07.09.05 P.W TestPathFlg to reduce sice of message and move from screencenter
//   to top left to allow adjust of detector with zero counts during diagnose scan
// 27.08.09 P.W: Options added;
//   1: poMainFormCenter;
//   2: No Buttons
begin
//DelayMs:=-1;
  Result := TfrmMsgDelay.Create(Msg, DelayMs, Title);
  if (Options and 1) <> 0 then           // 27.08.09 P.W
  begin
    Result.Position := poMainFormCenter;
  end;
  if (Options and 2) <> 0 then           // 27.08.09 P.W
  begin
    Result.btnOk.Visible := False;
    Result.btnHoldMsg.Visible := False;
    Result.btnCancel.Visible := False;
  end;
  if TestPathFlg and (not DefaultPositonDefined) then   // "and (not Def.)" : 22.12.06 P.W
  begin  // 07.09.05 P.W
    Result.Left := 0;
    Result.Top  := 0;
    Result.Height := Result.Height div 2;
  end;

  if DefaultPositonDefined then // 22.12.06 P.W
  begin
    Result.Position   := poDesigned;
    Result.BoundsRect := DefaultPosition;
  end;

  if DelayMs < 0 then
  begin   // use showmodal to stay until btnOk has been pressed
    Result.btnHoldMsg.Enabled := False;
    // Result.Hide;       // before showmodal! // until 22.12.06 P.W
    MessageBox1Flg := True; // 26.08.09 P.W
    try
      Result.ShowModal;
    finally
      MessageBox1Flg := False; // 26.08.09 P.W
    end;

    Result.btnOkClick(nil);  // free
  end else
  begin
    Result.Show;  // here since 22.12.06 P.W
    if Assigned(Result.ActiveFormWhenCreated) then
      Result.ActiveFormWhenCreated.Show;
  end;
end;

function ShowMessageFmtMs(const Msg: AnsiString; Params: array of const; DelayMs: Integer= 3000; Title:String=''): TfrmMsgDelay;
begin
  Result := ShowMessageMs(Format(Msg, Params), DelayMs, Title);
end;

procedure ShowMessageMode(const Msg: AnsiString; MsgMode: TMsgMode; DelayMs: Integer= 3000; Title:String='');
// 28.07.06 P.W
var
  Mode: Integer;
begin
  Case MsgMode of
    MSG_None  :   Mode := 0;
    MSG_Delay :   Mode := 1;
    MSG_Wait  :   If Glb_MacroFlg
                    then Mode := 1
                    else Mode := 2;
    MSG_WaitEver: Mode := 2;
    else          Mode := 2;
  end;
  Case Mode of
    0: ;                                       // nothing
    1: ShowMessageMs(Msg, DelayMs, Title);     // Message disappears when DelayMs is >= 0
    2: ShowMessageS (Msg);                     // message waiting for user input  // "S": 26.08.09 P.W
  end;
end;

procedure TfrmMsgDelay.frmMsgStop;
begin
  if (Self.Handle = MsgDelayWindow) then MsgDelayWindow := 0;
end;

procedure TfrmMsgDelay.btnOkClick(Sender: TObject);
// FormClose must use nil when calling btnOkClick(nil)!
begin
  tmrClose.Enabled := False;

  frmMsgStop;
  if (Screen.ActiveForm = Self) then
  begin
    DefaultPosition       := BoundsRect;                              // since 22.12.06 P.W
    DefaultPositonDefined := True;                                    // since 22.12.06 P.W
  end;

  if  (fsmodal in Formstate) then // called via FormClose from ShowModal
  begin
    if modalResult = mrNone then
      ModalResult := mrOk;        // terminates ShowModal
  end else
  begin
    {--- until 22.12.06 P.W:
      tmrClose.Enabled  := False;
      tmrClose.Interval := 500;
      tmrClose.Enabled  := True;   // use timer to free the form!
    {---}
      if Assigned(Sender) then Close; // nil by FormClose to avoid looping;  since 22.12.06 P.W
  end;
end;

procedure TfrmMsgDelay.tmrCloseTimer(Sender: TObject);
// remove the message screen
begin
  if  (fsmodal in Formstate) then EXIT;  // may not be used while form is modal!

  tmrClose.Enabled := False;
//Enabled          := False;                                        // until 22.12.06 P.W
  frmMsgStop;
//FreeAndNil(Self);           // delayed after form has been closed // until 22.12.06 P.W
  Close;                                                            // since 22.12.06 P.W
end;

procedure TfrmMsgDelay.btnHoldMsgClick(Sender: TObject);
begin
  if btnHoldMsg.Enabled then
  begin
    btnHoldMsg.Enabled := False;
    tmrClose.Enabled   := False;
  end;
end;

procedure TfrmMsgDelay.btnCancelClick(Sender: TObject);
begin
  MsgDelayEsc := True;
  ModalResult := mrCancel;
  btnOkClick(Sender);
end;

procedure TfrmMsgDelay.FormClose(Sender: TObject;
  var Action: TCloseAction);      // not fired when application closes!
begin
//btnOkClick(Sender); // free                              // until 22.12.06 P.W

  Dec(OpenMsgCtr);  // 22.12.06 P.W

  Action := caFree;                                        // since 22.12.06 P.W
  btnOkClick(nil);  // nil to avoid endless loop!          // since 22.12.06 P.W
end;

procedure Test;
var
  I, J : Integer;
  H : TfrmMsgDelay;
begin
  H := ShowMessageMs('Application Mainform', 3600000);
  H.FormStyle := fsNormal;
  H.WindowState := wsMaximized;
  for I := 0 to 15 do
  begin
    ShowMessageFmtMs('test(%d)', [I], 5000);
    for J := 0 to 20 do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;
  end;
  H_alt(1);
end;

procedure Test_MessageDlgExt;
var
  ShowResult : Boolean;
  function MessageDlgExt_T(Title, Msg: AnsiString; ButtonsCapt : Array of AnsiString;
    DefaultBtnIdx:Integer=0; uType:UINT=MB_ICONEXCLAMATION) : Integer;
  begin
    Msg := Format('%.4x %s', [uType, Msg]);
    Result := MessageDlgExt(Title, Msg, ButtonsCapt, DefaultBtnIdx, uType, taLeftJustify, True);
    if ShowResult then
      ShowMessageExt('Result %d', [Result]);
  end;
var
  Msg : AnsiString;
begin
  Msg :=
    'Please confirm: Ignore warning and continue?'+sLineBreak
    +'--------------------------------------------------------------------------'
    +'a'+sLineBreak
    +'---------------- Long Line ---------------------------------------------------------------- Long Line ------------------------------------------------'
    +'b'+sLineBreak
    ;

  Msg := Msg
    +'---------------- Longer Line ------------------------------------------------------------------------'
    +'--------- Long Line ----------------------------------------------------------------------------------------'
    ;
  Msg := Msg
    +'--------- Long Line ----------------------------------------------------------------------------------------'
    ;
  Msg := Msg
    +'--------- Long Line ----------------------------------------------------------------------------------------'
    ;

  Msg := Msg
    +'c'+sLineBreak
    ;
  Msg := Msg
    +'--'+sLineBreak
    +'2'+sLineBreak
    +'--'+sLineBreak
    +'3'+sLineBreak
    +'--'+sLineBreak
    +'4'+sLineBreak
    +'--'+sLineBreak
    +'5';

  ShowResult := False;

  MessageDlgExt_T('Test a', '$10 MB_ICONHAND        x Stop',        ['Yes', 'No'], 1, MB_ICONHAND);
  MessageDlgExt_T('Test b', '$20 MB_ICONQUESTION    ? Question',    ['Yes', 'No'], 1, MB_ICONQUESTION);
  MessageDlgExt_T('Test c', '$30 MB_ICONEXCLAMATION ! Exclamation', ['Yes', 'No'], 1, MB_ICONEXCLAMATION);
  MessageDlgExt_T('Test d', '$40 MB_ICONASTERISK    I Inforamtion', ['Yes', 'No'], 1, MB_ICONASTERISK);
  MessageDlgExt_T('Test e', '$30 MB_ICONWARNING     ! Exclamation', ['Yes', 'No'], 1, MB_ICONWARNING);
  MessageDlgExt_T('Test f', '$10 MB_ICONERROR       x Stop',        ['Yes', 'No'], 1, MB_ICONERROR);
  MessageDlgExt_T('Test g', '$40 MB_ICONINFORMATION I Inforamtion', ['Yes', 'No'], 1, MB_ICONINFORMATION);
  MessageDlgExt_T('Test h', '$10 MB_ICONSTOP        x Stop',        ['Yes', 'No'], 1, MB_ICONSTOP);

//  MessageDlgExt_T('Test_MessageDlgExt A', 'Hello!', ['Yes', 'No', 'No', 'No', 'No', 'No', 'No0', 'No1', 'No2', 'No3', 'No4', 'No5'],2);
  MessageDlgExt_T('Test_MessageDlgExt A', 'Hello!', ['Oo', 'OOOoooo'], 2, MB_ICONQUESTION);
  MessageDlgExt_T('Test_MessageDlgExt A', 'Hello!', ['Ok', 'Ordentlich'], 0, 0);
  MessageDlgExt_T('Test_MessageDlgExt A', 'Hello!', ['Ok', 'Ok'], 2, MB_ICONASTERISK);
  MessageDlgExt_T('Test_MessageDlgExt A', 'Hello!', ['Ok'], 2, MB_ICONEXCLAMATION);
  ShowResult := True;
  MessageDlgExt_T('Test_MessageDlgExt A', 'Hello!', ['Yes', 'No']);
  MessageDlgExt_T('Test_MessageDlgExt A', 'Hello!', ['Yes', 'No'], 1);
  MessageDlgExt_T('Test_MessageDlgExt B', Msg, ['Yes', 'No', 'Long Button Text', '1'], 2);
  H_alt(1);
end;




procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  FillChar(DefaultPosition, SizeOf(DefaultPosition), #0);
  DefaultPositonDefined := False;
  MsgCtr                := 0;
  MsgDelayEsc           := false;
  MsgDelayWindow        := 0;
  OpenMsgCtr            := 0;

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
  InitFinal_Add(Unit_Name, Unit_Init); // 03.05.24 P.W
(* -v--- moved to function Unit_Init // 03.05.24 P.W
   -^--- moved to function Unit_Init // 03.05.24 P.W *)
//  Test;
//  Test_MessageDlgExt;

end.
