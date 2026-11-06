// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; changes: 2; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; changes: 1; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Vers.: @(#)Accel V.:1.00                                ) +*)
(*+ Author           : P.Wueseke                                          +*)
(*+ Date             : 02.02.96                                           +*)
(*+ Description      : Accelerator;                                       +*)
(*+ Description      : You will find an example at the end of this file.  +*)
(*+ Description      :                                                    +*)
(*+ Description      : Use                                                +*)
(*+ Description      :   Init([Byte(Up), Byte(Down)]);  (as example)      +*)
(*+ Description      :   PreWaitKey                                       +*)
(*+ Description      :   PostWaitKey(RetCodeA, RetCodeB)                  +*)
(*+ Description      :   IncAcc(...)                                      +*)
(*+ Description      :   Done                                             +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*+ Last modified/By : 22.06.99 / P.Wueseke                               +*)
(*+ 22.03.96 Michael Welsch                                               +*)
(*+ Date/Modification: 22.03.96 P.W / CircleRoundFlg added                +*)
(*+ Date/Modification: 28.03.96 P.W / IncAcc: Speed limit 10% of range    +*)
(*+ Date/Modification: 22.06.99 P.W / IncAccProc: Return Delta of S       +*)
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)
Unit Accel;

INTERFACE

Uses
  DosTimer,
//  Objects,
  Objects0;

Type
  TRetCode         = Word;
  TRetCodeB        = Byte;
  TPairSet         = Set of TRetCodeB;
{--------------------------------------------------------------------}

  PAccel           = ^TAccel;
  TAccel           = Object//(TObject_TP7) // "TObject" to "TObject_TP7" Chg#1665 (02.03.04 P.W)
    AccMsg         : PString;
    Acc10Max       : Word; {2000}
    AccInfoFlg     : Boolean;
    LastRetCodeA   : TRetCode;
    LastRetCodeB   : TRetCode;
    PairSet        : TPairSet;
    Tmr            : TDosTimer;
    StartTmrReqFlg : Boolean;
    Acc10          : LongInt;
    NoRefFlg       : Boolean;    {Disable refresh of MenuBar}
    CircleRoundFlg : Boolean;    {Inable to rotate around} {22.03.96 P.W}
    {----------------------------------------------------------------}

    Constructor Init(Const APairSet : TPairSet);
    Destructor  Done;                                                Virtual;

    Procedure   AccInfo(S: Single);                                  Virtual;
    Procedure   ClrAccInfo;                                          Virtual;
    Function    IncAcc (S: Single; dS, SMin, SMax: Single): Single;  Virtual;
    Function    IncAccProc(Var S: Single; DirFlg:Boolean;
                  dS, SMin, SMax: Single): Single;                   Virtual;
    Procedure   IncAccProcW(Var W: Word; DirFlg:Boolean;
                  dS, SMin, SMax: Single);                           Virtual;
    Procedure   IncAccProcL(Var L: LongInt; DirFlg:Boolean;
                      dS, SMin, SMax: Single);                       Virtual;
    Procedure   IncAccProcI(Var I: Smallint; DirFlg:Boolean;
                      dS, SMin, SMax: Single);                       Virtual;
    Procedure   IncAccProcR(Var R: Real; DirFlg:Boolean;
                      dS, SMin, SMax: Single);                       Virtual;

    {----------------------------------------------------------------}
    Procedure   PreWaitKey;                                          Virtual;
    Procedure   PostWaitKey(RetCodeA: TRetCode; RetCodeB: TRetCodeB);Virtual;
    {----------------------------------------------------------------}
  end;

{--------------------------------------------------------------------}

Implementation
  const Unit_Name = 'Accel'; // 03.05.24 P.W
{
#CF
}

{--------------------------------------------------------------------}
{--------------------------------------------------------------------}
(*.**************************************************************************)
(** Procedure Name   : Init                                               **)
(** Author           : P.Wueseke                                          **)
(** Date             : 02.02.96                                           **)
(** Description      : Constructor                                        **)
(** Description      : Initialise with a set of KeyCodes (Byte)           **)
(** Description      : for example "Init([Byte(Up), Byte(Dwn)])"          **)
(** Description      : that are to be recognized by Accelerator           **)
(** Description      : Otherwise Accelerator will set speed to minimum    **)
(** Description      : abruptly because, with for example up and down     **)
(** Description      : the RetCodeA will not be the same. In this         **)
(** Description      : case the RetCodeB (Byte!) helps to stay on speed/4 **)
(** Description      :                                                    **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Inherited Init, StartDosTimer,                     **)
(** Input            : APairSet                                           **)
(** Output           : -                                                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Constructor TAccel.Init(Const APairSet : TPairSet);
begin
  //Inherited Init;
  {------------------------------------------------------------------}
  AccMsg           := NewStrS('');  {Pointer to a ""-String}
  Acc10Max         := 2000;
  AccInfoFlg       := False;
  LastRetCodeA     := 0;
  LastRetCodeB     := 0;
  PairSet          := APairSet;
  StartDosTimer(Tmr);
  StartTmrReqFlg   := True;
  Acc10            := 10;
  NoRefFlg         := False;      {True: Disable refresh of MenuBar ...}
  CircleRoundFlg   := False;
end;

(*.**************************************************************************)
(** Procedure Name   : Done                                               **)
(** Author           : P.Wueseke                                          **)
(** Date             : 02.02.96                                           **)
(** Description      : Destructor                                         **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : inherited Done                                     **)
(** Input            : -                                                  **)
(** Output           : -                                                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Destructor  TAccel.Done;
begin
  DisposeStr(AccMsg);
  {------------------------------------------------------------------}
  //Inherited Done;
end;

(*.**************************************************************************)
(** Procedure Name   : AccInfo                                            **)
(** Author           : P.Wueseke                                          **)
(** Date             : 02.02.96                                           **)
(** Description      : Displays a message using IncAcc (if overwritten)   **)
(** Description      : If you overwrite please call also inherited AccInfo**)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : -                                                  **)
(** Output           : -                                                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Procedure   TAccel.AccInfo(S: Single);
begin {Proc. AcellInfo}
  (*** Example:
  GotoXy(4, 24);
  Write(AccMsg^, S:10:3);
  ***)
  AccInfoFlg:=True;
end;  {Proc. AcellInfo}

(*.**************************************************************************)
(** Procedure Name   : ClrAccInfo                                         **)
(** Author           : P.Wueseke                                          **)
(** Date             : 02.02.96                                           **)
(** Description      : Clears a message of AccInfo (if overwritten)       **)
(**                If you overwrite please call also inherited ClrAccInfo **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : -                                                  **)
(** Output           : -                                                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Procedure   TAccel.ClrAccInfo;
begin {Proc. AcellInfo}
  (*** Example:
  GotoXy(4, 24);
  Write('¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦'); //OemToAnsi Chg#1667 (02.03.04 P.W)
  ***)
  AccInfoFlg:=False;
end;  {Proc. AcellInfo}

(*.**************************************************************************)
(** Function Name    : IncAcc                                             **)
(** Author           : P.Wueseke                                          **)
(** Date             : 01.02.96                                           **)
(** Description      : Incree/Decree using accelerator, force stepwidth   **)
(** Description      : Limited Range uses Round (Abs(S/dS) < MaxLongInt!  **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Round                                              **)
(** Input            : S, dS, SMin, SMax                                  **)
(** Output           : RETURN (Single): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : 28.03.96 / P.Wueseke                               **)
(** Date/Modification: 22.03.96 P.W / CircleRoundFlg added                **)
(** Date/Modification: 28.03.96 P.W / Speed limit 10% of range            **)
(**************************************************************************.*)
Function    TAccel.IncAcc(S: Single; dS, SMin, SMax: Single): Single;
Var
  dsUse            : Single;   {28.03.96 P.W}
  dsLim            : Single;   {28.03.96 P.W}
begin
  NoRefFlg:=True;

  if S>SMax then S:=SMax    {Before Inc: to prevent Error in Round( S/ dS)}
  else
  if S<SMin then S:=SMin;

  if (dS<>0) then
  begin
    dsUse := 0.1 * dS * Acc10;
    {----------------------------------------------------------------}
    {28.03.96 P.W}
    dsLim := 0.1 * (SMax-SMin);
    if dsLim < abs(ds) then dsLim:=abs(ds);
    if (abs(dsUse)>dsLim) then
    begin
      if (ds>0) then dsUse:=  dsLim
                else dsUse:= -dsLim;
    end;
    {----------------------------------------------------------------}
    S:=S + dsUse;
    S:=dS * Round( S / dS);   {Force Steps: 0.1: 0.00, 0.10, 0.20 ..}
  end;

  If CircleRoundFlg then
  begin  {22.03.96 P.W}
    if S>SMax then S:=SMin
    else
    if S<SMin then S:=SMax;
  end else
  begin
    if S>SMax then S:=SMax
    else
    if S<SMin then S:=SMin;
  end;


  if S=-0.0 then S:=0.0;  {to avoid -0.00!}
  {------------------------------------------------------------------}
  {Info:}
  AccInfo(S);
  {------------------------------------------------------------------}
  IncAcc := S;
end;

(*.**************************************************************************)
(** Function  Name   : IncAccProc                                         **)
(** Author           : P.Wueseke                                          **)
(** Date             : 02.02.96                                           **)
(** Description      : Procedure (Input=Output: S: Single)                **)
(** Description      : Incree/Decree depends on DirFlg                    **)
(** Description      :   If DirFlg is false: Sign of ds is inverted       **)
(** Description      : Example: DirFlg:=(RetCode=RC_Incree)               **)
(** Description      :   allows correct direction in calls like           **)
(** Description      : Case RetCode of                                    **)
(** Description      :   RC_Incree,                                       **)
(** Description      :   RC_Decree:                                       **)
(** Description      :     IncAccProc(X, RetCode=RC_Incree, ds, ...);     **)
(** Description      : End;                                                   **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : IncAcc                                             **)
(** Input            : S, DirFlg, dS, SMin, SMax;                         **)
(** Output           : S                                                  **)
(** Return           : Delta (=Snew-Sold)                                 **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : 22.06.99 / P.Wueseke                               **)
(** Date/Modification: 22.06.99 P.W / Return delta of S                   **)
(**************************************************************************.*)
Function    TAccel.IncAccProc(Var S: Single; DirFlg:Boolean;
                              dS, SMin, SMax: Single): Single;
Const
  DirArr           : Array [False..True] of ShortInt
                   = (-1, +1);
Var
  delta : Single;
begin
  delta:=S;
  S:=IncAcc(S, DirArr[DirFlg] * dS, SMin, SMax);
  delta:=S-delta;
  IncAccProc:=Delta;
end;

(*.**************************************************************************)
(** Procedure Name   : IncAccProcW/L/I/R                                  **)
(** Author           : P.Wueseke                                          **)
(** Date             : 02.02.96                                           **)
(** Description      : Like IncAccProc, but for Word, LongInt, Smallint    **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : IncAccProc                                         **)
(** Input            : W/L/I, DirFlg, dS, SMin, SMax;                     **)
(** Output           : S                                                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(** 22.03.96 Michael Welsch: real procedure appended                      **)
(**************************************************************************.*)
Procedure   TAccel.IncAccProcW(Var W: Word; DirFlg:Boolean;
                  dS, SMin, SMax: Single);
Var
  S                : Single;
begin
  S:=W;
  IncAccProc(S, DirFlg, dS, SMin, SMax);
  W:=Round(S);
end;

Procedure   TAccel.IncAccProcL(Var L: LongInt; DirFlg:Boolean;
                  dS, SMin, SMax: Single);
Var
  S                : Single;
begin
  S:=L;
  IncAccProc(S, DirFlg, dS, SMin, SMax);
  L:=Round(S);
end;

Procedure   TAccel.IncAccProcI(Var I: Smallint; DirFlg:Boolean;
                  dS, SMin, SMax: Single);
Var
  S                : Single;
begin
  S:=I;
  IncAccProc(S, DirFlg, dS, SMin, SMax);
  I:=Round(S);
end;

Procedure   TAccel.IncAccProcR(Var R: Real; DirFlg:Boolean;
                  dS, SMin, SMax: Single);
Var
  S                : Single;
begin
  S:=R;
  IncAccProc(S, DirFlg, dS, SMin, SMax);
  R:=S;
end;

(*.**************************************************************************)
(** Procedure Name   : PreWaitKey                                         **)
(** Author           : P.Wueseke                                          **)
(** Date             : 02.02.96                                           **)
(** Description      : Actions to be done before you wait for a key       **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : StartDosTimer                                      **)
(** Input            : -                                                  **)
(** Output           : -                                                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Procedure   TAccel.PreWaitKey;
begin
  If StartTmrReqFlg then
  begin
    StartDosTimer(Tmr);
    StartTmrReqFlg := False;
  end;
end;

(*.**************************************************************************)
(** Procedure Name   : PostWaitKey                                        **)
(** Author           : P.Wueseke                                          **)
(** Date             : 02.02.96                                           **)
(** Description      : Actions to be done after you did wait for a key    **)
(** Description      : and after you have received the RetCodeA           **)
(** Description      : You can use Pre and PostWaitKey also in a loop     **)
(** Description      : where you don't wait but only check if you have    **)
(** Description      : a keymessage: in this case RetCodeA and RetCodeB   **)
(** Description      : must be zero, otherwise the accelertor speed will  **)
(** Description      : be at maximum                                      **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            :                                                    **)
(** Output           : -                                                  **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : ?                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Procedure   TAccel.PostWaitKey(RetCodeA: TRetCode; RetCodeB: TRetCodeB);
Var
  TmrSec           : Double;
  PairFlg          : Boolean;
begin
  If (RetCodeA<>0) or (RetCodeB<>0) then
  begin
    StartTmrReqFlg:=True;
    PairFlg:=RetCodeB in PairSet;
    If AccInfoFlg and not PairFlg then ClrAccInfo;
    If (LastRetCodeA = RetCodeA) or PairFlg then
    begin
      If (RetCodeA<>LastRetCodeA) then
      begin
        Acc10:= Acc10 div 4;
      end;

      TmrSec:=ReadDosTimer(Tmr);

      If TmrSec<0.20 then inc(Acc10, 1 + Acc10 div 20)
      else
      If TmrSec<0.40 then inc(Acc10, 0)
      else
      If TmrSec<0.50 then dec(Acc10, 1 + Acc10 div 10)
      else
        Acc10:=10;

      if Acc10<10 then Acc10:=10
      else
      if Acc10>Acc10Max then Acc10:=Acc10Max;
    end else
    begin
      Acc10:=10;
    end;
    LastRetCodeA:=RetCodeA;
    LastRetCodeB:=RetCodeB;
  end;
end;
{--------------------------------------------------------------------}
{--------------------------------------------------------------------}

end.

