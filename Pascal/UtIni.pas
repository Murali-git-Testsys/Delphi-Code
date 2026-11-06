// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; changes: 3; (02.03.04 P.W)
(*.++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Module Name/Vers.: UTINI  1.0
Date/Author      : {10.10.95 Michael Welsch}
Description      : Interface to windows *.ini style like parameter files
Date/Modification:
{05.03.96 Michael Welsch GetNextLine modified
{20.05.96 Michael Welsch file creation removed because of possible
conflict in network!! Files are opened for read only !! except append is called !!

{20.05.96 Michael Welsch
!!!!Use TSetUpIni instead of TGenIni!!!
Advantages:
1 ) the file is only read once, all operations are done in a String collection
2 ) the function Append was a little bit overloaded!
    It has been split into the functions:
    Delete,Insert and Modify.
3 ) If changes are made in the content, use write to save them in the file!
{21.05.96 Michael Welsch} TDoSetUpIni implemented:
Used as Setup and update utility
{23.05.96 Michael Welsch}
TNoSecSetUpIni implemented
{28.05.96 Michael Welsch}
ChangeSectionName(OldSec,NewSec:String) implemented
{29.05.96 Michael Welsch} implemented
Function    ModifyR(Section,ID,NewValStr:String):SmallInt;
converts the values to real variables and modifies only if the real
values are different. Prevents changes caused by same values written in
different ways like: 1.2000 -> 1.2 or .998 -> 0.998.
{06.05.96 Michael Welsch}
implemented for normal text search in TSetUpIni:
    Function    SearchFirstText(Search:String):SmallInt;
    Function    SearchNextText(Search:String):SmallInt;
{13.06.96 Michael Welsch}
Implemented:
TSetUpIni.SectionOn
TNoSecSetUpIni.Constructor Init(_Name:PathStr);
{13.11.96 Michael Welsch} comments added
{16.06.97 MW} changes in Function    TSetUpIni.SearchIDValStr(...)
{17.06.97 P.W} change to comment: tGenIni (please use tSetUpIni)
{17.06.97 P.W} changes in tSetUpIni:
  Introduce GetD, GetL, GetBoo, GetMqThr from unit MyUtIni from P.W
  several times: My_Section:=Section;
  several times: ErrChk();
  several times: SetErrFlg();
{27.06.97 MW} new methods:
    Function    PutHoldStrNo(No: SmallInt;Var ResStr:String): SmallInt;
    Function    GetHoldStrNo(No: SmallInt;Var ResStr:String): SmallInt;
Used to change the content of the HOLD buffer.
Example: delete multiple spaces between words etc.
    Procedure   DoubleChar2Single(C:Char)
{18.07.97 MW} new proc.
Procedure  EnableUtiniDebugFile; {18.07.97 MW}
const
  INIDEBUGFLG      : BOOLEAN = FALSE;  { if DisplayOn, a debug file is written }
  INIDEBUGFILE     : String  = 'INIDEB.TXT';
  UTINI_DISPLAYON  : BOOLEAN = FALSE;
purpose : switch debug file and display on.
new method:
    Procedure   SwitchDisplayOn;
purpose : write a header line withe the filename in the debugfile
{16.10.97 MW}
Procedure   MDisplay(M:String);
purpose: unique interface to debug/log file for all methods,
may also be used from "outside" the object.
{17.10.97 MW}
GlbInstID and field TSetUpIni.InstID implemented.
purpose: It is useful to identify the different instances of TSetUpIni
in a installation LOG file. The GlbInstID is always increased, the
destructor does NOT decrease the number! If it exceeds MAXINSTID, it is
reset to 1, assuming that any installation procedure does NOT use more
than MAXINSTID (255) files (instances of TSetUpIni). In all other
purposes which use this object recursive, it is unlikely that the ID number
is of any interest!
The InstID is diaplayed together with the SwitchDisplayOn message and
with all other messages, created by DetDisplay.
{21.10.97 MW:
Procedure  tSetUpIni.Merge(Source:PSetUpIni);
{21.10.97 MW purpose:
 Merge two ini files. Source gets included in SELF!
 Depending on the content, the two instances must be setup
 whether the camparison (MODIFY) should be made case sensitive or not.
}
Procedure   GoTop; set pointer to first item, trivial but may be
  a point of further improvements, so this is the interface!
Function    GetFirstLine(Var Str:String):SmallInt;
  The brother of GetNextLine similar to the pair FindFirst/FindNext
{22.10.97 MW}
.DetDisplay:
{22.10.97 MW, set Val=NF if Res<0 to avoid displaying the previous value ! }
.Delete
{22.10.97 MW, the section line itseld is deleted too, if ID='' !!
{09.12.97 P.W}
  Everywhere post Val(.., Err), Err is >0 if an error occurs, but
             ErrChk does only recognize an error if Err is < 0 so
             change in GetD and GetMqThr
             ErrChk(Err, ..)  to  ErrChk(-Abs(Err), ..)
  new virtual Function: SplitValStr
    as hook to allow reading values from MeasMask Input/Output fields
{10.12.97 P.W}
  Introduce GetBooStrict
  Introduce GetS
{01.10.00 P.W}
  Halt -> ReadlnHalt
{18.11.02 P.W}
  TSetUpIni.SearchNext adapt to special formatings to use Labview Tools:
  remove "" arround ValStr
23.02.05 P.W: Writeln modified: IniWritelnHook
13.05.05 P.W: support DefVal
01.04.08 P.W: Procedure TSetUpIni.ErrHalt single messagebox instead of messagebox for each error message line
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)
Unit UtIni;
INTERFACE
Uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  Param_StrUnit,
  GlbType,  // 01.04.05 P.W for AsciiExpSep and FixSem
  Graphics, Dialogs,    // 23.02.05 P.W
  DOS,
  Crt,
  UTGenOb,
  GlbDecs,     {01.10.00 P.W}
  ComNames,
  GlbPath,
  GlbFT,
  GlbTools,
  Objects;


Type
  {------------------------------------------------------------------}
  {17.06.97 P.W}
  tMQ              = (MQ_Warn, MQ_Invalid, MQ_Abort);
                     {typeMeasQuality}
  tMqThr           = Array[MQ_Warn .. MQ_Abort] of SmallInt;
                     {Array of limits for MeasQuality}
  {------------------------------------------------------------------}

  { interface to a windows *.ini like parameter file
    with sections  : [section]
    and parameters : ID=Value
    ID names can exist more than one time!
    1: in different sections
    2: in the same section like
       OPTIONS=RESEARCH
       OPTIONS=AUTOROI
       etc.
       i.e. to add values to a bit coded parameter!
    All sections,IDs and values are upcased!
    Init normally opens the file for reading and writing, if it doesn't
    exist, it is created with the default section [STRATEC]
  }

  {20.05.96 Michael Welsch
  OBSOLETE use TSetUpIni }
(* * * {17.06.97 P.W} *
  PGenIni       =       ^TGenIni;
  TGenIni       =       Object(TObject_TP7) // "TObject" to "TObject_TP7" Chg#1556 (02.03.04 P.W)
    Buf         :       POwnBufStream;
    Name        :       PathStr;
    DoValUpCase :       Boolean;
    Constructor Init(_Name:PathStr);
    Destructor  Done;virtual;
    Function    SearchSection(Section:String):SmallInt;
    Function    Search(Section,ID:String;Var ValStr:String):SmallInt;
    Function    SearchNext(ID:String;Var ValStr:String):SmallInt;
    Function    GetNextLine(Var Str:String):SmallInt;
    Function    Append(Section,ID,OldValStr,NewValStr:String):SmallInt;virtual;
    Function    Check:SmallInt;
  end;
* * * {17.06.97 P.W} *)

  { interface to a windows *.ini like parameter file
    with sections  : [section]
    and parameters : ID=Value
    ID names can exist more than one time!
    1: in different sections
    2: in the same section like
       OPTIONS=RESEARCH
       OPTIONS=AUTOROI
       etc.
       i.e. to add values to a bit coded parameter!
    All sections,IDs and values are upcased! Upcase of values can be switched off
    with the filed DoValUpcase (default=TRUE)!
    Init normally opens the file only for reading.
    Save changes with the function write!
    The object may display all actions if DisplayOn=TRUE.
  }
  PSetUpIni     =       ^TSetUpIni;
  TSetUpIni     =       Object(TObject_TP7) // "TObject" to "TObject_TP7" Chg#1557 (02.03.04 P.W)
    Buf         :       POwnBufStream;
    ActPos      :       SmallInt;
    Name        :       PathStr;
    DoValUpCase :       Boolean;
    Hold        :       POwnStringCollection;
    DisplayOn   :       Boolean;
    Changed     :       Boolean;
    SectionOn   :       Boolean;
    {----------------------------------------------------------------}
    {17.06.97 P.W}
    ErrorHaltFlg:       Boolean;
    My_Section  :       String;
    My_CallPos  :       String;
    {----------------------------------------------------------------}
    SplitValStrMode       : Word;       {09.12.97 P.W}
    (* used by GetD and GetMqThr to Handle Lines like:
    (* CtSpeed =30.0 /3.0, 60.0/REA/8/2/"Ct speed[mm per sec]:" /40/20/1/202
    (* -> ValStr: 30.0 /3.0, 60.0/REA/8/2/"Ct speed[mm per sec]:" /40/20/1/202
    (* SplitValStrMode modifies the return value of SplitValStr
    (* SplitValStrMode=0: do not take care of "/" in ValStr
    (* SplitValStrMode=1: Use 1th   part -> Returns 30.0
    (* SplitValStrMode=2: Use 2nd   part -> Returns 3.0
    (* SplitValStrMode=3: Use 3rd   part -> Returns 60.0
    *)
    {----------------------------------------------------------------}
    InstID      :       Byte;   { Instance ID, used to identify the instances
                                  of this object in a LOG-file written with
                                  DetDisplay }

    Constructor Init(_Name:PathStr);
    Destructor  Done;virtual;
    {----------------------------------------------------------------}
    {17.06.97 P.W}
    Procedure   SetErrFlg   (Var EfLoc: Boolean; Const Aim: Boolean);
    Procedure   CallPos(Const CPos: String); virtual;
    Procedure   ErrHalt(Const IdStr: String); virtual;
    Procedure   ErrChk(Res: SmallInt; Const IdStr: String); virtual;
    {----------------------------------------------------------------}
    Function    SearchSection(Section:String):SmallInt;virtual;
    Function    Search(Section,ID:String;Var ValStr:String):SmallInt;virtual;
    Function    SearchNext(ID:String;Var ValStr:String):SmallInt; {use for multiple assigned vars!, e.g. OPTIONS }
    Function    SearchIDValStr(Section,ID,OldValStr:String):SmallInt;
    Function    GetNextLine(Var Str:String):SmallInt;
    Function    Insert(Section,ID,NewValStr:String):SmallInt;
    Function    Modify(Section,ID,NewValStr:String):SmallInt;
    Function    ModifyR(Section,ID,NewValStr:String):SmallInt;
    Function    Delete(Section,ID,OldValStr:String):SmallInt;
    Function    Write:SmallInt;
    Procedure   Display;
    Procedure   DetDisplay(OPCode:Byte;Var Sec,ID,Val:String;Res:SmallInt);
    Function    ChangeSectionName(OldSec,NewSec:String):SmallInt;
    Function    SearchFirstText(SearchStr:String):SmallInt;
    Function    SearchNextText(SearchStr:String):SmallInt;
    Procedure   ParseLine(Line:SmallInt;Var ID,ValStr:String);
    {----------------------------------------------------------------}
    {09.12.97 P.W}
    Function    SplitValStr(ValStr: String; Mode: Word): String;
      Virtual;
    {----------------------------------------------------------------}
    {17.06.97 P.W}
    Function    GetD(IdStr: String;DefVal:Double=0.0): Double;
    Function    GetL(IdStr: String;DefVal:LongInt=0): LongInt;
    Function    GetBoo (IdStr: String; Default:Boolean=False): Boolean;
    Function    GetBooStrict (IdStr: String): Boolean;   {10.12.97 P.W}
    Function    GetS(IdStr: String): String;             {10.12.97 P.W}
    Function    GetMqThr(Var MqThr: tMqThr; Const IdStr: String): SmallInt;
    {----------------------------------------------------------------}
    {27.06.97 MW}
    Function    PutHoldStrNo(No: SmallInt;Var ResStr:String): SmallInt;
    Function    GetHoldStrNo(No: SmallInt;Var ResStr:String): SmallInt;
    Procedure   DoubleChar2Single(C:Char);
    Procedure   SwitchDisplayOn;
    {16.10.97 MW}
    Procedure   MDisplay(M:String);
    {21.10.97 MW}
    Procedure   Merge(Source:PSetUpIni;MoccurIDS:PStringCollection);
    Procedure   GoTop;
    Function    GetFirstLine(Var Str:String):SmallInt;
  end;

  { used to read old style parameter files like newbone.v1.
    Searchsection always returns 0, so every Search begins at
    item number 0 in the collection.
    23.05.96 Michael Welsch
  }
  PNoSecSetUpIni     =       ^TNoSecSetUpIni;
  TNoSecSetUpIni     =       Object(TSetUpIni)
    Constructor Init(_Name:PathStr);
    Function    SearchSection(Section:String):SmallInt;virtual;
    Function    Search(Section,ID:String;Var ValStr:String):SmallInt;virtual;
  end;


  { used in installation and update procedure
    Usage:
    TDoSetUpIni.Init(_Job);
    (* check if TDoSetUpIni.error=0*)
    TDoSetUpIni.Run;
    TDoSetUpIni.Done;

    -> _Job is the filename of the job file.
       It contains as a header:
       - filename of the *.ini file,( may contain %XCTDIR%)
       several blocks of:
       - mode specifier: *DELETE,*INSERT or *MODIFY
       - section specifier: [section]
       - variables
       Comment lines are marked with '//' or FixSem

       Example:
       // First line must contain the name of the ini file.
       // It is accepted if the name contains %XCTDIR%
       // If the file doesn't exist, it will be created!
       %XCTDIR%INIT\LOCAL.INIT
       *DELETE
       // this will delete all items TEXT in the section USERDATA
       [USERDATA]
       TEXT=
       // this will delete paticular items in the section:
       [TEST1]
       ITEM1=V1
       ITEM2=V2
       // this will modify the value for the standard phantom
       *MODIFY
       [STANDARD PHANTOM]
       01_03=0.505;0.005
       // this will insert a new section with new variables
       *INSERT
       [NEWSEC]
       VAR1=NEW
  }
  PDoSetUpIni     =       ^TDoSetUpIni;
  TDoSetUpIni     =       Object(TSetUpIni)
    Job           :       PSetUpIni;
    Error         :       SmallInt;
    Constructor Init(_Job:PathStr);
    Destructor  Done;virtual;
    Procedure   Run;
    Procedure   DisplayHelp;
  end;


function BoolFromString(const ValStr: String): Boolean;
Procedure  EnableUtiniDebugFile(FName:String);
Procedure  DisableUtiniDebugFile; // 17.03.05 P.W
var
  INIDEBUGFILE     : PathStr  = 'INIDEB.TXT'; {String -> PathStr 10.01.02 P.W}
  IniWritelnHook   : procedure(const Msg:AnsiString; aColor:TColor=clNone) = nil;
                                        // ^--- must be AnsiString!

Implementation
  const Unit_Name = 'UtIni'; // 03.05.24 P.W

function BoolFromString(const ValStr: String): Boolean;
// 30.10.08 P.W
// Code from UReadSet.pas as function
// Modifications:
// 30.10.08 P.W: Accept also "1" as True  // for compatibility with Delphi TFileIni and TMemIni
begin
                  {T: True else False}
  Result := (Pos('T', UpcaseString(ValStr)) > 0)
         or (Pos('1',              ValStr ) > 0);  // or: 30.10.08 P.W
end;



procedure Writeln(const S0: String; const S1:String='';  const S2:String='');
// 23.02.05 P.W avoid Runtime Error 105 inside Windows GUI Apps
begin
  if Assigned(IniWritelnHook) then IniWritelnHook(S0+S1+S2) else
  if IsConsole                then System.Writeln(S0+S1+S2) else
  begin
    ShowMessage('UtIni.pas: "'+S0+S1+S2+'"');
  end;
end;

(* {$I TGenIni.INC} obsolete, use TSetUpIni*)
var // const
  INIDEBUGFLG      : BOOLEAN = FALSE;  { if DisplayOn, a debug file is written }
  UTINI_DISPLAYON  : BOOLEAN = FALSE;
  GlbInstID        : Byte    = 0;
const
  MAXINSTID        = 255;

Procedure  EnableUtiniDebugFile(FName:String);
{18.07.97 MW}
begin
  UTINI_DISPLAYON  := TRUE;
  INIDEBUGFLG      := TRUE;
  If Fname='' Then          { defualt name }
    INIDEBUGFILE     :=LocInterDir+INIDEBUGFILE
  else
    INIDEBUGFILE     :=FName;
end;

Procedure  DisableUtiniDebugFile;
// 17.03.05 P.W used by Install.pas post call of Do540Up.pas DoTheUpdate
begin
  UTINI_DISPLAYON  := False;
  INIDEBUGFLG      := False;
end;


{----------------------------------------------------------------------------}
{  TSetUpIni     =       Object(TObject_TP7) // "TObject" to "TObject_TP7" Chg#1558 (02.03.04 P.W)
{----------------------------------------------------------------------------}
Constructor TSetUpIni.Init(_Name:PathStr);
Var
  Help  :       String;
begin
  Name:=_Name;
  DoValUpCase:=TRUE;
  DisplayOn:=UTINI_DISPLAYON;
  Changed:=False;
  ErrorHaltFlg:=False;          {17.06.97 P.W}
  My_Section:='[?]';            {17.06.97 P.W}
  My_CallPos:='';               {17.06.97 P.W}
  SplitValStrMode:=0;           {09.12.97 P.W}

  Buf:=New(POwnBufStream,Init(_Name,StOpenRead,1024));
  Hold:=New(POwnStringCollection,Init(10,10,FALSE));
  Hold^.Duplicates:=TRUE;
  While Buf^.Status=0 Do
  begin
    Buf^.SReadln(Help);
    If (Length(Help)=0) Then
       Help:=' ';
    If (Buf^.Status=0) Then
    begin
      Hold^.Insert(NewStr(Help));
    end;
  end;
  Dispose(Buf,Done);
  ActPos:=0;
  Buf:=NIL;
  SectionOn:=TRUE;
  {17.10.97 MW}
  If GlbInstID<MAXINSTID Then
     Inc(GlbInstID)
  else
     GlbInstID:=1;               { reset to 1 }
  InstID:=GlbInstID;
end;
{----------------------------------------------------------------------------}
Destructor  TSetUpIni.Done;
begin
  If Buf<>NIL Then
     Dispose(Buf,Done);
  If Hold<>NIL Then
     Dispose(Hold,Done);
end;
{----------------------------------------------------------------------------}
Procedure TSetUpIni.SetErrFlg(Var EfLoc: Boolean; Const Aim: Boolean);
begin
  EfLoc        := ErrorHaltFlg;
  ErrorHaltFlg := Aim;
end;
{----------------------------------------------------------------------------}
Procedure TSetUpIni.CallPos(Const CPos: String);
Var
  P                : Byte;
begin
//!!! Exit
  If ErrorHaltFlg then
  begin
    If (CPos <> '') then
    begin
      If (My_CallPos <> '') then My_CallPos := My_CallPos + '|';
      My_CallPos := My_CallPos + CPos;
    end else
    begin
      P:=Length(My_CallPos);
      While (P > 0) and (My_CallPos[P] <> '|') do Dec(P);
      If P>0 then dec(P);
      SetLength(My_CallPos, P); // My_CallPos[0] := Char(P);
    end;
  end;
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
(** Procedure Name   : ErrHalt                                            **)
(** Author           : P.Wueseke                                          **)
(** Date             : 27.11.96                                           **)
(** Description      : Stop with error message                            **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Search, Val, ReadlnHalt                            **)
(** Input            : IdStr, S                                           **)
(** Output           : -                                                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : My_Section                                         **)
(***************************************************************************)
(** Last modified/By : 01.10.00 P.W                                       **)
(** Date/Modification: 01.10.00 P.W/Use ReadlnHalt instead of Halt        **)
(**************************************************************************.*)
Procedure TSetUpIni.ErrHalt(Const IdStr: String);
// 01.04.08 P.W (old code see below)
// Multiple Messages to a single one (old writeln shows messagebox for each line)
var
  Msg : AnsiString;
  procedure Writeln(S: AnsiString); begin Msg := Msg + S + sLineBreak; end;
begin
  Msg := '';
  If (IdStr =  '') then
  begin
    Writeln('Error, section '+My_Section+' not found!');
  end else
  begin
    Writeln('Error, variable "'+IdStr+'" is invalid or not found!');
    Writeln('Section '+ My_Section);
  end;
  Writeln('File "'+ FExpand(Name)+ '"');
  If (My_CallPos <> '') then Writeln('Function: '+ My_CallPos);
  // if Assigned(IniWritelnHook) then IniWritelnHook('',1); //  u.   01.04.08 P.W
  ReadlnHalt(1, Msg);  {Halt -> ReadlnHalt: 01.10.00 P.W}   // Msg : 01.04.08 P.W
end;
{  // until 01.04.08 P.W
Procedure TSetUpIni.ErrHalt(Const IdStr: String);
begin
  If (IdStr =  '') then Writeln('Error, section not found:')
                   else Writeln('Error, variable is invalid or not found:');
  Writeln('File    : "', FExpand(Name), '"');
  Writeln('Section : ', My_Section);

  If (IdStr      <> '') then Writeln('Variable: ', IdStr);
  If (My_CallPos <> '') then Writeln('Function: ', My_CallPos);

  if Assigned(IniWritelnHook) then IniWritelnHook('',1);
  ReadlnHalt(1);  //Halt -> ReadlnHalt: 01.10.00 P.W
end;
}
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Procedure TSetUpIni.ErrChk(Res: SmallInt; Const IdStr: String);
(***************************************************************************
Date/Author      :{17.06.97 P.W}
Description      : if (Res < 0) and (ErrorHaltFlg) then call
                   ErrorHalt(IdStr: String)
***************************************************************************
heap             :
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   :
***************************************************************************
Date/Modification:

**************************************************************************.*)
begin
  If (Res<0) and ErrorHaltFlg then ErrHalt(IdStr);
end;

{----------------------------------------------------------------------------}
(*.**************************************************************************)
Function    TSetUpIni.SearchSection
(
    Section:String { I  section name: '[section]' (with brackets!!) }
):SmallInt;
(***************************************************************************
Date/Author      :{20.05.96 Michael Welsch}
Description      : search the section in the parameter file
***************************************************************************
return           : =>0: position where the section including [SECTION] begins
                    <0: not found
heap             :
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   : x ,moves the pointer in the stream  < that's wrong !!!!
***************************************************************************
Date/Modification:
{24.01.97 MW} it DOES NOT move the pointer in the stream!!!!!
**************************************************************************.*)

Var
  Help  :       String;
  Found :       SmallInt;
  I     :       SmallInt;
begin
  CallPos('SearchSection');
  Section:=UpCaseString(Section);
  My_Section:=Section;                     {17.06.97 P.W}
  If (Hold=NIL) Or (Hold^.Count=0) Then
  begin
    SearchSection:=-1;
    ErrChk(-1, '');   {17.06.97 P.W}
    CallPos('');
    Exit;
  end;
  Found:=-1;
  I:=0;
  While (I<Hold^.Count) And (Found<0) Do
  begin
    Help:=PString(Hold^.At(I))^;
    If (UpCaseString(Help)=Section) Then
       Found:=I;
    Inc(I);
  end;
  ErrChk(Found, ''); {17.06.97 P.W}
  SearchSection:=Found;
  CallPos('');
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Function    TSetUpIni.Search
(
     Section,             { I   section to search in }
     ID         :String;  { I   ID of the wanted variable }
 Var ValStr     :String   { O   result }
):SmallInt;
(***************************************************************************
Date/Author      : {20.05.96 Michael Welsch}
Description      : searches the first existing variable "ID" in "section"
***************************************************************************
return           : >=0 :found, position of the variable
                   <0  : not found, evtually section not found!
heap             :
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   : x , moves pointer in stream
***************************************************************************
Date/Modification:
**************************************************************************.*)

Var
  Res   :       SmallInt;
begin
  CallPos('Search');
  Res:=SearchSection(Section);
  If Res<0 Then
  begin
    Search:=Res;
    CallPos('');
    Exit;
  end;
  ID:=UPCaseString(ID);
  ActPos:=Res;
  Res:=SearchNext(ID,ValStr);
  Search:=Res;
  ErrChk(Res, ID);               {17.06.97 P.W}
  DetDisplay(1,Section,ID,ValStr,Res);
  CallPos('');
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Function    TSetUpIni.SearchNext
  (   ID     :       String;  { I  -ID of the wanted variable }
  Var ValStr :       String   { O   result }
  ):SmallInt;
(***************************************************************************
Date/Author      : 20.05.96 Michael Welsch
Description      : Used to read multiple assigned variables inside one section.
!!!Usage of SEARCH before Searchnext is required!!!
Usage example:
   Res:=Search('[GENERAL]','OPTIONS',Val)
   While Res>=0 Do
   begin
     NumVal:=ffffff(Val);
     OPTIONS:=OPTIONS and NumVal;
     Res:=SearchNext('OPTIONS',Val)
     ....
   end;
***************************************************************************
return           : >=0 :found, position of the variable
                   <0  : not found, evtually section not found!
heap             :
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   : x , moves pointer in stream
***************************************************************************
Date/Modification:
{18.11.02 P.W}
  adapt to special formatings to use Labview Tools:
  remove "" arround ValStr
**************************************************************************.*)


Var
  Res   :       SmallInt;
  Stop  :       Boolean; {22.05.96 Michael Welsch}
  Str   :       String;
  SETUPIND : STRING;

begin
  CallPos('SearchNext');
  Res:=0;
  ID:=UPCaseString(ID);
  Stop:=False;
  While Not(Stop) Do
  begin
    Inc(ActPos);
    If ActPos<Hold^.Count Then
      Res:=0
    else
    begin
      Stop:=True;
      Res:=-1;
    end;
    If Res=0 Then
    begin
      Str:=PString(Hold^.At(ActPos))^;
      If (Str[1]='[') And SectionOn Then
      begin
        Stop:=True;
        Res:=-1;  { next section is reached !! }
      end else
      begin
        GETSETUP(Str,SETUPIND,ValStr) ;
        SetUpInd:=DelSpcLR(UpCaseString(SetUpInd));
        If  DoValUpCase Then
           ValStr:=DelSpcLR(UpCaseString(ValStr))
        else
           ValStr:=DelSpcLR(ValStr);

        {v--- adapt to special formatings to use Labview Tools -----}
        {18.11.02 P.W}
        {remove "" arround ValStr}
        If (Length(ValStr)              >= 2  ) and
           (ValStr[1]                   =  '"') and
           (ValStr[Length(ValStr)]      =  '"')
        then
        begin
          ValStr := Copy(ValStr,2,Length(ValStr)-2);
        end;
        {^--- adapt to special formatings to use Labview Tools -----}

        If SETUPIND=ID Then
        begin
          Stop:=True;
          Res:=ActPos;
        end;
      end;
    end;
  end;
  ErrChk(Res, ID);           {17.06.97 P.W}
  SearchNext:=Res;
  CallPos('');
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Function    TSetUpIni.SearchIDValStr(
   Section,               { I - section to search }
   ID,                    { I - ID to serach }
   OldValStr:String       { I - prev. value  }
   ):SmallInt;             { pos. of item, or -1 }
(***************************************************************************
Date/Author      : {96 MW}
Description      : Used by Modify and Insert to check if the id is already
existing and assigned to the value OldvalStr.
***************************************************************************
return           : pos. of item or -1 for failed
heap             :
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   : x
***************************************************************************
Date/Modification:
{11.06.97 MW}
  While (Found<0) And (Res>0) Do {11.06.97 MW, 0 is allowed !!}
  changed to
  While (Found<0) And (Res>=0) Do
**************************************************************************.*)

Var
  Res              : SmallInt;
  Found            : SmallInt;
  ValStr           : String;
begin
  CallPos('SearchIDValStr');
  Res:=SearchSection(Section);
  If Res<0 Then
  begin
    SearchIDValStr:=Res;
    CallPos('');
    Exit;
  end;
  ID:=UPCaseString(ID);
  ActPos:=Res;
  Found:=-1;
  If  DoValUpCase Then
     OldValStr:=UpCaseString(OldValStr);
{  While (Found<0) And (Res>0) Do {11.06.97 MW, 0 is allowed !!}
  While (Found<0) And (Res>=0) Do
  begin
    Res:=SearchNext(ID,ValStr);
    If Res>0 Then
    begin
      If ValStr=OldValStr Then
        Found:=Res;
    end;
  end;
  SearchIDValStr:=Found;
  CallPos('');
end;
{----------------------------------------------------------------------------}
Function    TSetUpIni.GetNextLine(Var Str:String):SmallInt;
{21.10.97 MW,
  Error: The first line (Actpos=0) was never a result!
  This was removed by seperating the break condition from the value
  of Actpos.
}
Var
   Res  :       SmallInt;
begin
  Res:=0;
  While Res=0 Do
  begin
    Inc(ActPos);
    If ActPos<Hold^.Count Then
      Res:=0
    else
      Res:=-1;
    If Res=0 Then
    begin
      Str:=PString(Hold^.At(ActPos))^;
      Str:=DelSpcLR(Str);{05.03.96 Michael Welsch}
      If Not(   (Pos('//',Str)=1)          { comment maybe "// ... " or ";..." }
             Or (Str[1]=FixSem)
             Or (Length(Str)=0)) Then       { skip empty lines ! }
      begin
{        Res:=ActPos; {21.10.97 MW}
         Res:=1;
      end;
    end;
  end;
{21.10.97 MW
  GetNextLine:=Res;
}
  If Res>0 Then
     GetNextLine:=ActPos
  else
     GetNextLine:=Res;
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Function    TSetUpIni.Delete
(           Section,
            ID,
            OldValStr   :       String
            ):SmallInt;
(***************************************************************************
Date/Author      : {20.05.96 Michael Welsch}
Description      : deletes items in ini files.
If ID and Oldvalstr defined (<>'') the function deletes only the item
ID=OldValstr
If Oldvalstr='' it deletes all items named ID=...,
If the ID='' it deletes the whole section.
***************************************************************************
return           : number of items deleted
heap             : x
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   :
***************************************************************************
Date/Modification:
{22.10.97 MW, the section line itseld is deleted too, if ID='' !!
**************************************************************************.*)
Var
  Res    :       SmallInt;
  Ctr    :       SmallInt;
  ValStr :       String;
begin
  CallPos('Delete');
  Ctr:=0;
  If ID='' Then      { delete the whole section }
  begin
    Res:=SearchSection(Section);
    {22.10.97 MW
    Inc(Res);
    }
    If (Res>=0) And SectionOn Then
    begin
      Inc(Ctr);
      Hold^.AtFree(Res);   { shift all lines -1 in position !! }
      Changed:=True;
    end;

    While Res>=0 Do
    begin
      If Res<Hold^.Count Then
      begin
        Valstr:=PString(Hold^.At(Res))^;
        If (ValStr[1]='[') And SectionOn  Then
          Res:=-1  { next section is reached !! }
      end else
        Res:=-1;
      If Res>=0 Then
      begin
        Inc(Ctr);
        Hold^.AtFree(Res);   { shift all lines -1 in position !! }
        Changed:=True;
      end;
    end;
  end else           { delete certain variable(s) in the section }
  begin
    If  DoValUpCase Then
        OldValStr:=UpCaseString(OldValStr);
    Res:=Search(Section,ID,ValStr);
    While Res>0 Do
    begin
      If ((OldValStr='') Or (OldValStr=ValStr)) Then
      begin
        Inc(Ctr);
        Hold^.AtFree(Res);
        Changed:=True;
        Res:=Search(Section,ID,ValStr); { set new ActPos }
      end else
        Res:=SearchNext(ID,ValStr);
    end;
  end;
  DetDisplay(2,Section,ID,OldValStr,Ctr);
  Delete:=Ctr;
  CallPos('');
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Function    TSetUpIni.Modify
(
        Section,
        ID,
        NewValStr       :       String
        ):SmallInt;
(***************************************************************************
Date/Author      : {20.05.96 Michael Welsch}
Description      : modifys the item ID in section.
***************************************************************************
return           : position of item in collection or -1 for fail
heap             : x
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   :
***************************************************************************
Date/Modification:
**************************************************************************.*)

Var
  Res    :       SmallInt;
  ValStr :       String;
  P      :       PString;
  EFLoc  :       Boolean;
begin
  CallPos('Modify');
  { search for existing item with same value }
  SetErrFlg   (EfLoc, False);  {Off   }
  Res:=SearchIDValStr(Section,ID,NewValStr);
  SetErrFlg   (EfLoc, EfLoc);  {Resume}
  If Res>0 Then
  begin            {we have nothing to do}
    Modify:=Res;
    CallPos('');
    Exit;
  end;

  { search for first existing item with other value }
  SetErrFlg   (EfLoc, False);  {Off   }
  Res:=Search(Section,ID,ValStr);
  SetErrFlg   (EfLoc, EfLoc);  {Resume}
  If Res>0 Then
  begin
    Changed:=True;
    ValStr:=ID+'='+NewValStr;
    P:=PString(Hold^.At(Res));
    Hold^.AtPut(Res,NewStr(ValStr));
    If P<>NIL Then
      DisposeStr(P);
    DetDisplay(4,Section,ID,NewValStr,Res);
  end else
  begin
    Res:=Insert(Section,ID,NewValStr);
  end;

  Modify:=Res;
  CallPos('');
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Function    TSetUpIni.ModifyR
(
        Section,
        ID,
        NewValStr       :       String
        ):SmallInt;
(***************************************************************************
Date/Author      : {29.05.96 Michael Welsch}
Description      : modifys the item ID in section, only if the values
converted to reals are different!
***************************************************************************
return           : position of item in collection or -1 for fail
heap             : x
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   :
***************************************************************************
Date/Modification:
**************************************************************************.*)

Var
  Res    :       SmallInt;
  ValStr :       String;
  P      :       PString;
  EFLoc  :       Boolean;
begin
  CallPos('ModifyR');
  { search for existing item with same value }
  SetErrFlg   (EfLoc, False);  {Off   }
  Res:=SearchIDValStr(Section,ID,NewValStr);
  SetErrFlg   (EfLoc, EfLoc);  {Resume}
  If Res>0 Then
  begin
    ModifyR:=Res;
    CallPos('');
    Exit;
  end;

  { search for first existing item with other value }
  SetErrFlg   (EfLoc, False);  {Off   }
  Res:=Search(Section,ID,ValStr);
  SetErrFlg   (EfLoc, EfLoc);  {Resume}
  If Res>0 Then
  begin
    If GetReal(ValStr)<>GetReal(NewValStr) Then
    begin
      Changed:=True;
      ValStr:=ID+'='+NewValStr;
      P:=PString(Hold^.At(Res));
      Hold^.AtPut(Res,NewStr(ValStr));
      If P<>NIL Then
        DisposeStr(P);
      DetDisplay(4,Section,ID,NewValStr,Res);
    end;
  end else
  begin
    Res:=Insert(Section,ID,NewValStr);
  end;

  ModifyR:=Res;
  CallPos('');
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Function    TSetUpIni.Insert
(
        Section,
        ID,
        NewValStr       :       String
        ):SmallInt;
(***************************************************************************
Date/Author      : {20.05.96 Michael Welsch}
Description      : Inserts item ID in section.
If the item exists with another value the item is inserted too!!
If the section doesn't exist at all, it is inserted .
***************************************************************************
return           : position of the item in the collection.
heap             : x
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   :
***************************************************************************
Date/Modification:
**************************************************************************.*)
Var
  Res    :       SmallInt;
  ValStr :       String;
  EFLoc  :       Boolean;
begin
  { search for existing item with same value }
  CallPos('Insert');

  SetErrFlg   (EfLoc, False);  {Off   }
  Res:=SearchIDValStr(Section,ID,NewValStr);
  SetErrFlg   (EfLoc, EfLoc);  {Resume}
  If (Res>0) Then
  begin
    Insert:=Res;
    CallPos('');
    Exit;
  end;

  SetErrFlg   (EfLoc, False);  {Off   }
  Res:=SearchSection(Section);
  SetErrFlg   (EfLoc, EfLoc);  {Resume}
  If Res>=0 Then
  begin
    Inc(Res);
    If Res>Hold^.Count Then
       Res:=Hold^.Count;
    ValStr:=ID+'='+NewValStr;
    Hold^.AtInsert(Res,NewStr(ValStr));
    ActPos:=Res;
    Changed:=True;
  end else
  begin
    Res:=Hold^.Count;
    Hold^.AtInsert(Res,NewStr(' '));
    Inc(Res);
    Hold^.AtInsert(Res,NewStr(Section));
    If ID<>'' Then
    begin
      Inc(Res);
      ValStr:=ID+'='+NewValStr;
      Hold^.AtInsert(Res,NewStr(ValStr));
    end;
    ActPos:=Res;
    Changed:=True;
  end;
  DetDisplay(3,Section,ID,NewValStr,Res);
  Insert:=Res;
  CallPos('');
end;
{----------------------------------------------------------------------------}
Function    TSetUpIni.Write:SmallInt;
{ rewrite the ini file !! }
Var
  Res,I   :       SmallInt;
begin
  CallPos('Write');
  Buf:=New(POwnBufStream,Init(Name,StCreate,1024));
  For I:=0 To Hold^.Count-1 Do
    Buf^.SWriteln(PString(Hold^.At(I))^);
  Res:=Buf^.Status;
  Dispose(Buf,Done);
  Buf:=NIL;
  Write:=Res;
  ErrChk(Res, '');        {17.06.97 P.W}
  CallPos('');
end;
{----------------------------------------------------------------------------}
Procedure    TSetUpIni.Display;
{ this is only for debug ! }
Var
  I     :       SmallInt;
begin
  ClrScr;
  For I:=0 To Hold^.Count-1 Do
    Writeln(PString(Hold^.At(I))^);
end;
{----------------------------------------------------------------------------}
Procedure   TSetUpIni.DetDisplay(OPCode:Byte;Var Sec,ID,Val:String;Res:SmallInt);
{16.10.97 MW, using MDisplay}
{22.10.97 MW, set Val=NF if Res<0 to avoid displaying the previous value ! }
Var
  OpStr :       String;
(*  DB    :       TOwnBufStream;*)
begin
  If Not DisplayOn Then Exit;
  Case OPCode Of
    1 : begin
          OpStr:=' SEARCH sec:';
          If Res<0 Then Val:='NF'; {22.10.97 MW}
        end;
    2 : OpStr:=' DELETE sec:';
    3 : OpStr:=' INSERT sec:';
    4 : OpStr:=' MODIFY sec:';
    else
        OpStr:=' --';
  end;
  Writeln(GetIntStr(InstID,3)+' File: "'+Name+'"');
  MDisplay(GetIntStr(InstID,3)+OpStr
          +FT_(FT_(Sec,FL,15),FM,15)
          +' id:' +FT_(FT_(ID,FL,15),FM,15)
          +' val:'+FT_(FT_(Val,FL,15),FM,15)
          +' res:'+GetIntStr(Res,3));
(*
  Writeln(OpStr
          +FT_(FT_(Sec,FL,15),FM,15)
          +' id:' +FT_(FT_(ID,FL,15),FM,15)
          +' val:'+FT_(FT_(Val,FL,15),FM,15)
          +' res:'+GetIntStr(Res,3));
  If INIDEBUGFLG Then
  begin
    DB.Init(INIDEBUGFILE,stOpen,1024);
    If DB.Status<>0 Then
    begin
      DB.Done;
      DB.Init(INIDEBUGFILE,stcreate,1024);
    end;
    DB.Seek(DB.GetSize);
    DB.SWriteln(OpStr
          +FT_(FT_(Sec,FL,15),FM,15)
          +' id:' +FT_(FT_(ID,FL,15),FM,15)
          +' val:'+FT_(FT_(Val,FL,15),FM,15)
          +' res:'+GetIntStr(Res,3));
    DB.Done;
  end;
*)
end;
{----------------------------------------------------------------------------}
Function   TSetUpIni.ChangeSectionName(OldSec,NewSec:String):SmallInt;
Var
  Res   :       SmallInt;
  P     :       PString;
begin
  CallPos('ChangeSectionName');
  Res:=SearchSection(OldSec);
  If Res>=0 Then
  begin
    P:=PString(Hold^.At(Res));
    Hold^.AtPut(Res,NewStr(NewSec));
    If P<>NIL Then
      DisposeStr(P);
    ChangeSectionName:=0;
  end else
    ChangeSectionName:=-1;
  CallPos('');
end;
{----------------------------------------------------------------------------}
Function   TSetUpIni.SearchFirstText(SearchStr:String):SmallInt;
begin
  ActPos:=-1;
  SearchFirstText:=SearchNextText(SearchStr);
end;
{----------------------------------------------------------------------------}
Function   TSetUpIni.SearchNextText(SearchStr:String):SmallInt;
Var
  Res   :       SmallInt;
  I,P   :       SmallInt;
  Str   :       String;
begin
  I:=ActPos+1;
  Res:=-1;
  If  DoValUpCase Then
    SearchStr:=UpCaseString(SearchStr);
  While (Res=-1) And (I<Hold^.Count) Do
  begin
    Str:=PString(Hold^.At(I))^;
    If  DoValUpCase Then
      Str:=UpCaseString(Str);
    P:=Pos(SearchStr,Str);
    If P<>0 Then
    begin
      ActPos:=I;
      Res:=I;
    end;
    Inc(I);
  end;
  DetDisplay(1,SearchStr,SearchStr,SearchStr,Res);
  SearchNextText:=Res;
end;
{----------------------------------------------------------------------------}
Procedure   TSetUpIni.ParseLine(Line:SmallInt;Var ID,ValStr:String);
Var
  Str   :       String;
begin
  ID:='';
  ValStr:='';
  If (Line>=Hold^.Count) Or (Line<0) Then
    Exit;
  Str:=PString(Hold^.At(Line))^;
  GETSETUP(Str,ID,ValStr) ;
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
(** Function Name    : SplitValStr                                        **)
(** Author           : P.Wueseke                                          **)
(** Date             : 09.12.97                                           **)
(** Description      : Allow special treatment of ValStr for use in GetD  **)
(** used to Handle Lines like:                                            **)
(** CtSpeed =30.0 /3.0, 60.0/REA/8/2/"Ct speed[mm per sec]:" /40/20/1/202 **)
(** ->ValStr: 30.0 /3.0, 60.0/REA/8/2/"Ct speed[mm per sec]:" /40/20/1/202**)
(** Mode modifies the return value of SplitValStr                         **)
(** Mode=0: return ValStr unchanged                                       **)
(** Mode=1: Use 1th   part -> Returns in example 30.0                     **)
(** Mode=2: Use 2nd   part -> Returns in example 3.0                      **)
(** Mode=3: Use 3rd   part -> Returns in example 60.0                     **)
(** ...                                                                   **)
(***************************************************************************)
(** Called By        : any, GetD, GetBoo                                  **)
(** Calls            : ?                                                  **)
(** Input            : ValStr, Mode                                       **)
(** Output           : RETURN (String): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function   TSetUpIni.SplitValStr (ValStr: String; Mode: Word): String;
  Function SepFromMode(Mode: Word): Char;
  begin
    If Mode = 2 then SepFromMode:=','
                else SepFromMode:='/';
  end;
  Function PosCut(Const SubStr: String; Var S: String): String;
  Var
    P              : Byte;
  begin
    P:=Pos(SubStr, S);
    If (P=0) and (SubStr= ',') then P:=Pos('/', S);
    If (P=0) then
    begin
      PosCut:=S;
      S:='';
    end else
    begin
      PosCut:=Copy(S, 1, P-1);
      System.Delete(S, 1, P);
    end;
  end;
Var
  SRet             : String;
  M                : Word;
begin  {Func. SplitValStr}
  SRet:=ValStr;
  For M:=1 to Mode do
    SRet := PosCut(SepFromMode(M), ValStr);
  SRet:=DelSpcLR(SRet);
  SplitValStr:=SRet;
end;   {Func. SplitValStr}

(*.**************************************************************************)
(** Function Name    : GetD                                               **)
(** Author           : P.Wueseke                                          **)
(** Date             : 27.11.96                                           **)
(** Description      : Get Double (ignore error)                          **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Search                                             **)
(** Input            : IdStr                                              **)
(** Output           : RETURN (Double): DRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : My_Section                                         **)
(***************************************************************************)
(** Last modified/By : 09.12.97 / P.Wueseke                               **)
(** Date/Modification: 09.12.97 P.W / enable correct error check          **)
(** Date/Modification: 09.12.97 P.W / Sup. SplitValStr                    **)
// 13.05.05 support DefVal
(**************************************************************************.*)
Function  tSetUpIni.GetD (IdStr: String; DefVal:Double=0.0): Double;
Var
  Res              : SmallInt;
  DRet             : Double;
  ValStr           : String;
  Err              : Integer;
begin  {Func. GetD}
  CallPos('GetD');
  DRet:=DefVal;
  Res:=Search(My_Section, IdStr, ValStr);
  If (Res>=0) then
  begin
    ValStr:=SplitValStr(ValStr, SplitValStrMode);       {09.12.97 P.W}
    Val(ValStr, DRet, Err);
    If (Err <> 0) then DRet:=0;
    ErrChk(-Abs(Err), IdStr);                    {-Abs : 09.12.97 P.W}
  end;
  GetD:=DRet;
  CallPos('');
end;   {Func. GetD}

(*.**************************************************************************)
(** Function Name    : GetL                                               **)
(** Author           : P.Wueseke                                          **)
(** Date             : 12.12.96                                           **)
(** Description      : Error Halt Get LongInt                             **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : EhGetD                                             **)
(** Input            : IdStr                                              **)
(** Output           : RETURN (LongInt)                                   **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : My_Section                                         **)
(***************************************************************************)
(** Date/Modification: -                                                  **)
// 13.05.05 P.W: support DefVal
// 14.11.07 P.W: support Hexstrings (no longer use Round(GetD(...))
// 29.11.07 P.W: support also Round(GetD(...)) for compatibility
(**************************************************************************.*)
Function  tSetUpIni.GetL (IdStr: String; DefVal:LongInt=0): LongInt;
Var
  Res              : SmallInt;
  ValStr           : String;
  Err              : Integer;
begin  {Func. GetD}
  CallPos('GetL');
  Result := DefVal;
  Res:=Search(My_Section, IdStr, ValStr);
  If (Res>=0) then
  begin
    ValStr:=SplitValStr(ValStr, SplitValStrMode);       {09.12.97 P.W}
    Val(ValStr, Result, Err);                          // supports also $ (hex) because Result is Longint!   // 14.11.07 P.W
    If (Err <> 0) then
    begin  // accept also float Values for compatibility
      Err := 0;
      GetL:=Round(GetD(IdStr, DefVal));
    end;
    ErrChk(-Abs(Err), IdStr);                    {-Abs : 09.12.97 P.W}
  end;
  CallPos('');
end;   {Func. GetD}

(*  // until 14.11.07 P.W
Function  tSetUpIni.GetL (IdStr: String;DefVal:LongInt=0): LongInt;
begin  {Func. GetL}
  CallPos('GetL');
  GetL:=Round(GetD(IdStr, DefVal));
  CallPos('');
end;   {Func. GetL}
*)

(*.**************************************************************************)
(** Function Name    : GetBoo                                             **)
(** Author           : P.Wueseke                                          **)
(** Date             : 27.11.96                                           **)
(** Description      : Get Boolean (ignore error)                         **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Search                                             **)
(** Input            : IdStr                                              **)
(** Output           : RETURN (Boolean): Boo                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : My_Section                                         **)
(***************************************************************************)
(** Last modified/By : 09.12.97 / P.Wueseke                               **)
(** Date/Modification: 09.12.97 P.W / Sup. SplitValStr                    **)
// 15.10.08 P.W: Accept also "1" as true
// 30.10.08 P.W: use BoolFromString so true is assumed when T, t or 1 is found in ValStr
// 02.10.09 P.W: Additional Parameter "Default"
(**************************************************************************.*)
Function  tSetUpIni.GetBoo (IdStr: String; Default:Boolean=False): Boolean;
Var
  Res              : SmallInt;
  Boo              : Boolean;
  ValStr           : String;
begin  {Func. GetBoo}
  CallPos('GetBoo');
  Boo:=Default;  // False -> Default:  02.10.09 P.W
  Res:=Search(My_Section, IdStr, ValStr);
  ValStr:=SplitValStr(ValStr, SplitValStrMode);       {09.12.97 P.W}
   // If Res>=0 then Boo:= (Pos('T', ValStr) > 0) or (Pos('t', ValStr) > 0) or (ValStr = '1'); // u. 30.10.08 P.W
   If (Res >= 0) then Boo := BoolFromString(ValStr);     // s. 30.10.08 P.W
  GetBoo:=Boo;
  CallPos('');
end;   {Func. GetBoo}

Function  tSetUpIni.GetBooStrict (IdStr: String): Boolean;
{10.12.97 P.W from GetBoo, but ValStr must be FALSE or TRUE and
              not only contain a "T" or not}
Var
  Res              : SmallInt;
  Boo              : Boolean;
  ValStr           : String;
begin  {Func. GetBooStrict}
  CallPos('GetBooStrict');
  Boo:=False;
  Res:=Search(My_Section, IdStr, ValStr);
  ValStr:=SplitValStr(ValStr, SplitValStrMode);
  ValStr:=UpCaseString(ValStr);
  ValStr:=DelSpcLR(ValStr);
  If Res>=0 then
  begin
    IF ValStr='TRUE' then Boo:=True
    else
    IF ValStr='FALSE' then Boo:=False
    else Res:=-1;
  end;
  ErrChk(Res, IdStr);
  GetBooStrict:=Boo;
  CallPos('');
end;   {Func. GetBooStrict}

(*.**************************************************************************)
(** Function Name    : GetS                                               **)
(** Author           : P.Wueseke                                          **)
(** Date             : 10.12.97                                           **)
(** Description      : Get String                                         **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Search                                             **)
(** Input            : IdStr                                              **)
(** Output           : RETURN (String): ValStr                            **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : My_Section                                         **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function  tSetUpIni.GetS (IdStr: String): String;
Var
  Res              : SmallInt;
  ValStr           : String;
begin  {Func. GetS}
  CallPos('GetS');
  ValStr:='';
  Res:=Search(My_Section, IdStr, ValStr);
  If (Res>=0) then
  begin
    ValStr:=SplitValStr(ValStr, SplitValStrMode);
    If ValStr='' then ErrChk(-1, IdStr);
  end;
  GetS:=ValStr;
  CallPos('');
end;   {Func. GetS}

(*.**************************************************************************)
(** Function Name    : GetMqThr                                           **)
(** Author           : P.Wueseke                                          **)
(** Date             : 17.06.97                                           **)
(** Description      : Get MqThr   (don't ignore error)                   **)
(** Description      : ! Result is errorcode                              **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Search                                             **)
(** Input            : IdStr                                              **)
(** Output           : MqThr                                              **)
(** Output           : RETURN (SmallInt): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : My_Section                                         **)
(***************************************************************************)
(** Last modified/By : 09.12.97 / P.Wueseke                               **)
(** Date/Modification: 09.12.97 P.W / enable correct error check          **)
(**************************************************************************.*)
Function  tSetUpIni.GetMqThr(
            Var MqThr: tMqThr; Const IdStr: String): SmallInt;
Const
  Delimiter        = ',';
Var
  Res              : SmallInt;
  IRet             : SmallInt;
  ValStr           : String;
  Err              : Integer;
  Num              : Byte;
  MQ               : tMQ;
  HStr             : String;
begin  {Func. GetMqThr}
  CallPos('GetMqThr');
  Res:=Search(My_Section, IdStr, ValStr);
    If Res>=0 then
    begin
      For MQ:=MQ_Warn to MQ_Abort do
      begin
        Num  := Ord(MQ)+1;
        HStr := StringParser(ValStr, Delimiter, Num);
        DelSpcLR(HStr);
        Val(HStr, IRet, Err);
        If (Err <> 0) then IRet:=0;
        ErrChk(-Abs(Err), IdStr);      {-Abs : 09.12.97 P.W}
        MqThr[MQ]:=IRet;
      end;
    end;
  GetMqThr:=Res;
  CallPos('');
end;   {Func. GetMqThr}

{----------------------------------------------------------------------------}
Function  tSetUpIni.GetHoldStrNo(No: SmallInt;Var ResStr:String): SmallInt;
{27.06.97 MW - get the line number No from the collection}
Var
  Res        :       SmallInt;
begin
  Res:=-1;
  ResStr:='';
  If (No>0) And (No<Hold^.Count) Then
  begin
    ResStr:=PString(Hold^.At(No))^;
    Res:=0;
  end;
  GetHoldStrNo:=Res;
end;
{----------------------------------------------------------------------------}
Function  tSetUpIni.PutHoldStrNo(No: SmallInt;Var ResStr:String): SmallInt;
{27.06.97 MW - put the line number No in the collection}
Var
  Res        :       SmallInt;
  PP         :       PString;
begin
  Res:=-1;
  If (No>0) And (No<Hold^.Count) and (ResStr<>'') Then
  begin
    PP:=Hold^.At(No);
    DisposeStr(PP);
    Hold^.AtPut(No,NewStr(ResStr));
    Res:=0;
  end;
  PutHoldStrNo:=Res;
end;
{----------------------------------------------------------------------------}
Procedure  tSetUpIni.DoubleChar2Single(C:Char);
{27.06.97 MW}
Var
  I,Res :       SmallInt;
  Str   :       String;
begin
  For I:=0 To Hold^.Count-1 Do
  begin
    Res:=GetHoldStrNo(I,Str);
    If Res=0 Then
    begin
      Str:=MakeDoubleCharSingle(Str,C);
      PutHoldStrNo(I,Str);
    end;
  end;
end;
{----------------------------------------------------------------------------}
Procedure  tSetUpIni.SwitchDisplayOn;
begin
  DisplayOn:=TRUE;
  MDisplay(GetIntStr(InstID,3)+' File: "'+Name+'"');
end;

(*
Var
  DB    :       TOwnBufStream;
begin
  DisplayOn:=TRUE;
  Writeln('File: "'+Name+'"');
  If INIDEBUGFLG Then
  begin
    DB.Init(INIDEBUGFILE,stOpen,1024);
    If DB.Status<>0 Then
    begin
      DB.Done;
      DB.Init(INIDEBUGFILE,stcreate,1024);
    end;
    DB.Seek(DB.GetSize);
    DB.SWriteln('File: "'+Name+'"');
    DB.Done;
  end;
end;
*)
{----------------------------------------------------------------------------}
Procedure  tSetUpIni.MDisplay(M:String);
Var
  DB    :       TOwnBufStream;
begin
  Writeln(M);
  If INIDEBUGFLG Then
  begin
    DB.Init(INIDEBUGFILE,stOpen,1024);
    If DB.Status<>0 Then
    begin
      DB.Done;
      DB.Init(INIDEBUGFILE,stcreate,1024);
    end;
    DB.Seek(DB.GetSize);
    DB.SWriteln(M);
    DB.Done;
  end;
end;
{----------------------------------------------------------------------------}
Function    TSetUpIni.GetFirstLine(Var Str:String):SmallInt;
{21.10.97 MW purpose: Get the first valid line in the file}
begin
  GoTop;
  Dec(ActPos);
  GetFirstLine:=GetNextLine(Str);
end;
{----------------------------------------------------------------------------}
Procedure  tSetUpIni.GoTop;
{21.10.97 MW}
begin
  ActPos:=0;
end;
{----------------------------------------------------------------------------}
Procedure  tSetUpIni.Merge(Source:PSetUpIni;MoccurIDS:PStringCollection);
{21.10.97 MW purpose:
 Merge two ini files. Source gets included in SELF!
 Depending on the content, the two instances must be setup
 whether the camparison (MODIFY) should be made case sensitive or not.
 MoccurIDS contains a list of all variables that may occure multiple times
 (Example OPTIONS in OPTIONS.INI ). If a variable is contained in this list
 it s INSERTed instead of MODIFYed.
 MoccurIDs may be NIL to ignore multiple IDs. (all items then are modified !)
}
Var
  SaveSSection  :       String;
  Str,ID,ValStr :       String;
  Index,Res     :       SmallInt;
  Mode          :       Byte;
  PS            :       PString;
begin
  SaveSSection:=Source^.My_Section;
  Res:=Source^.GetFirstLine(Str);
  Source^.My_Section:='';    { use this field to store the current section }
  While Res>=0 Do
  begin
    If Str[1]='[' Then    { the line is a section  or... }
        Source^.My_Section:=Str
    else If Source^.My_Section<>'' Then  { ...the line is a parameter line }
    begin
      Source^.ParseLine(Res,ID,ValStr);
      Mode:=0; { modify }
      If (MoccurIDs<>NIL) And (ID<>'') Then
      begin
        PS:=NewStr(ID);
        If MoccurIDs^.Search(PS,Index) Then
           Mode:=1;
        DisposeStr(PS);
      end;
      Case Mode Of
        0 : Modify(Source^.My_Section,ID,ValStr); { inserts if it is new, or different}
        1 : Insert(Source^.My_Section,ID,ValStr); { inserts in any case}
      end;
    end;
    Res:=Source^.GetNextLine(Str);  { get next line }
  end;
  Source^.My_Section:=SaveSSection;
end;
{----------------------------------------------------------------------------}
{  TNoSecSetUpIni     =       Object(TSetUpIni)
{----------------------------------------------------------------------------}
Constructor TNoSecSetUpIni.Init(_Name:PathStr);
begin
  inherited Init(_Name);
  SectionOn:=FALSE;
end;
{----------------------------------------------------------------------------}
Function    TNoSecSetUpIni.SearchSection(Section:String):SmallInt;
begin
  My_Section:=Section;                  {17.06.97 P.W}
  SearchSection:=0;
end;
{----------------------------------------------------------------------------}
Function    TNoSecSetUpIni.Search(Section,ID:String;Var ValStr:String):SmallInt;
Var
  Res   :       SmallInt;
begin
  CallPos('TNoSec..Search');
  My_Section:=Section;                  {17.06.97 P.W}
  ID:=UPCaseString(ID);
  ActPos:=-1;  { to start at the first line !! }
  Res:=SearchNext(ID,ValStr);
  DetDisplay(1,Section,ID,ValStr,Res);
  Search:=Res;
  CallPos('');
end;
{----------------------------------------------------------------------------}
{  TDoSetUpIni     =       Object(TSetUpIni)
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Constructor TDoSetUpIni.Init(
     _Job   :   PathStr  { I - job file name }
     );
(***************************************************************************
Date/Author      : {21.05.96 Michael Welsch}
Description      :  initialize the object, read the output filename from the
job file. Check error for status.
***************************************************************************
return           :
heap             : x
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   : x
***************************************************************************
Date/Modification:
**************************************************************************.*)

Var
  Help  :       String;
begin
  Error:=0;
  Job:=New(PSetUpIni,Init(_Job));
  If Job^.Hold^.Count=0 Then
  begin
    Error:=stReadError;
    Exit;
  end;
  Help:=PString(Job^.Hold^.At(0))^;
  Help:=DelSpcLR(Help);
  If (Pos('//',Help)=1) Or (Help[1]=FixSem) Then
     Job^.GetNextLine(Help);
  If Pos(XctDirBat,Help)<>0 Then
     Help:=ExchangeString(Help,XctDirBat,XctDir);
  inherited Init(Help);
end;
{----------------------------------------------------------------------------}
Destructor  TDoSetUpIni.Done;
begin
  Dispose(Job,Done);
  inherited Done;
end;
{----------------------------------------------------------------------------}
Procedure   TDoSetUpIni.DisplayHelp;
begin
  Writeln('Program :',Param_Str(0));
  Writeln('Parameter: <job filename>');
  Writeln('For syntax of the <job filename> see file SETINI.TXT');
end;
{----------------------------------------------------------------------------}
(*.**************************************************************************)
Procedure   TDoSetUpIni.Run;
(***************************************************************************
Date/Author      : {21.05.96 Michael Welsch}
Description      :  starts the updating process
***************************************************************************
return           :
heap             : x
Global Variables
 - affected      :
 - predefined    :
---------------------------------------------------------------------------
virtual          :
change  status   :
***************************************************************************
Date/Modification:
**************************************************************************.*)

Type
  TIniJobMode   = (__NOTHING,__DELETE,__INSERT,__MODIFY);
Var
  Help                  :       String;
  Section,ID,ValStr     :       String;
  Mode                  :       TIniJobMode;
  Res                   :       SmallInt;
  X,Y                   :       Byte;
begin
  ClrScr;
  Res:=Job^.GetNextLine(Help);
  Help:=DelSpcLR(Help);
  Mode:=__NOTHING;
  Window(1,1,80,7);
  Writeln('Program    : ',Param_Str(0));
  Writeln('Job file   : ',Job^.Name);
  Writeln('Output file: ',Name);
  GotoXY(1,6);
  Writeln(FT_( '-',MU,79));
  Window(1,8,80,25);
  X:=1;
  Y:=1;
  While (Res>0)  Do
  begin
    GotoXY(X,Y);
    Writeln(Help);
    X:=WhereX;
    Y:=WhereY;
    Case Help[1] Of
      '*' : begin
              Window(1,1,80,7);
              GotoXY(1,4);
              If Help='*INSERT' Then
              begin
                Mode:=__INSERT;
                Writeln('Mode       : INSERT');
              end else
              If Help='*DELETE' Then
              begin
                Mode:=__DELETE;
                Writeln('Mode       : DELETE');
              end else
              If Help='*MODIFY' Then
              begin
                Mode:=__MODIFY;
                Writeln('Mode       : MODIFY');
              end;
              Window(1,8,80,25);
            end;
      '[' : begin
              Window(1,1,80,7);
              GotoXY(1,5);
              Section:=Help;
              Writeln('Section    : ',FT_(Section,FL,20));
              Window(1,8,80,25);
            end;
      FixSem:
            begin end;
      else
      begin
        If Pos('//',Help)<>1 Then
        begin
          GETSETUP(Help,ID,ValStr) ;
          Case Mode Of
            __INSERT,__MODIFY :
                      begin
                        If ValStr<>'' Then
                        begin
                          Case Mode Of
                            __INSERT :Res:=Insert(Section,ID,ValStr);
                            __MODIFY :Res:=Modify(Section,ID,ValStr);
                          end;
                        end else
                          Res:=-1;
                      end;
            __DELETE : Res:=Delete(Section,ID,ValStr);
            else
            begin
              GotoXY(X,Y);
              Writeln('Error in job file! Mode undefined !');
              X:=WhereX;
              Y:=WhereY;
              ReadlnHalt(1);   {Halt -> ReadlnHalt: 01.10.00 P.W}
            end;
          end;
          If Res<=0 Then
          begin
            GotoXY(X,Y);
            Writeln('Name NOT found / Value undefined!');
            Writeln('#### Name="'+ID+'", Value="'+ValStr+'"####');
            X:=WhereX;
            Y:=WhereY;
            Delay(500);
          end;
        end;
      end;

    end;
    Res:=Job^.GetNextLine(Help);
    Help:=DelSpcLR(Help);
  end;
  Res:=Write;
  If Res<>0 Then
  begin
    Writeln('Error writing file: ',Name);
    ReadlnHalt(1);   {Halt -> ReadlnHalt: 01.10.00 P.W}
  end;
end;
{----------------------------------------------------------------------------}

{----------------------------------------------------------------------------}

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  GlbInstID        := 0;
  INIDEBUGFILE     := 'INIDEB.TXT'; {String -> PathStr 10.01.02 P.W}
  INIDEBUGFLG      := FALSE;  { if DisplayOn, a debug file is written }
  IniWritelnHook   := nil;
  UTINI_DISPLAYON  := FALSE;

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
end.
