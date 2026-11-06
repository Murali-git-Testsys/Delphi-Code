// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; changes: 3; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Name of module: GlbDecs
global type and variable declarations
Version    : @(#).PAS V.: 1.00
Author     : Michael Welsch
Date       : 03.06.93
USAGE      :
PARAMETERS :
INPUT      :
OUTPUT     :
GENERAL HINTS and MODIFICATION LOG:
graphic independent, project independent
{08.02.96 Michael Welsch}
{24.05.96 Michael Welsch}
ARCHIVBLOCKSIZE     = 40; implemented, used in GlbTools
{06.05.96 Michael Welsch moved from boiler }
{12.07.96 P.W}      : ErrorLevelEsc introduced; Objects no longer used
{27.11.96 Michael Welsch} pointer type for Tprocedure and tfunction
{01.10.00 P.W} : Added: ProgramNameMsg, ReadlnWait, ReadlnHalt;
{05.10.01 P.W} GlbUserId added
{08.10.01 P.W} DosErrorPathNotFound, DosErrorNoMoreFiles added
{23.10.01 P.W}
  New Definition: (from KN_Glb.Pas)
  tFilterInfo   = String[60]; {do not change! (used in DBI files) 23.10.01 P.W}
  tRoiName      = String[15];
23.04.04 P.W: MaxCTImageSize of Boiler.pas now here defined
25.08.09 P.W: Handling of TestPathFlg and ServiceFlg from FemGlb to GlbDecs and GlbPath
  Aim avoid ReadlnHalt does not support ParameterRepairMode because
  InitServiceFlg has not been called early enough; no longer use ServiceFlgCopy
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)

Unit GlbDecs;      {03.06.93 Michael Welsch}

Interface

Uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  HaltUnit,
  Param_StrUnit,
  MsgBox,            // 17.06.05 P.W
  Windows, SysUtils, // 23.02.05 P.W
//  Crt,     {01.10.00 P.W}
  Dos,
  GlbType; {11.01.02 P.W}

Const
  MaxAvail : LongInt = 8000000; // replaces Turbo.System.MaxAvail 22.10.03 P.W
  MemAvail : LongInt = 8000000; // replaces Turbo.System.MemAvail 22.10.03 P.W

(* vvv--- from Boiler *)
var
  MaxCTImageSize : LongInt = 0;    // 23.04.04 P.W
(* ^^^--- from Boiler *)

const
    { global errorcodes }
    FileNotFound = 2;
    MaxGetMemBlock = 65528;
    MaxOptionFlgs  = 4;
    ErrorLevelEsc  = 252;              {12.07.96 P.W}
    DosErrorPathNotFound =  3;         {08.10.01 P.W}
    DosErrorNoMoreFiles  = 18;         {08.10.01 P.W}

Type
    tFilterInfo   = String[60]; {do not change! (used in DBI files) 23.10.01 P.W}
    tRoiName      = String[15];
    TDataType = (T_DATE,T_REAL,T_LINT,T_WORD);

    String02  = String[02];
    String03  = String[03];
    String04  = String[04];
    String05  = String[05];
    String06  = String[06];
    String08  = String[08];
    String10  = String[10];
    String12  = String[12];
    String15  = String[15];
    String16  = String[16];
    String19  = String[19];
    String20  = String[20];
    String40  = String[40];
    String60  = String[60];
    String80  = String[80];

    TDevice = (_None,_Screen1,_VRI);

    PProcedure  = ^TProcedure;
    TProcedure  = Procedure;

    PFunction   = ^TFunction;
    TFunction   = Function: Smallint;  {23.10.01 P.W}

    TFuncStr    = Function: String;

    TBoolProc   = Procedure(Var Flg:Boolean);
    TBoolProcPtr = ^TBoolProc; {29.03.95 Michael Welsch}
    TSOC        = Set Of Char;

    TPrnTyp             = (NN,LJ,PJ,PXL,DJ,CN);


    TBasicListPointer  = ^TBasicStrList;

    TBasicStrList = Packed Record // "Record" to "Packed Record" Chg#52 (02.03.04 P.W)
     NextPtr    :  TBasicListPointer;
     Element    :  String;
    end;

    PDisplColors        =       ^TDisplColors;
    TDisplColors     =       Packed Record // "Record" to "Packed Record" Chg#53 (02.03.04 P.W)
     P                    :    Pointer;  {04.10.95 Michael Welsch, um einem bestimmten
                                          Eintrag zuzuordnen}
     Back,Vor,Frame       :    Byte;
     HBack,HVor           :    Byte;
     TBack,TVor           :    Byte;
    end;

    TSetOfChar  =       Set Of Char;

    PGlbOptionFlgs =   ^TGlbOptionFlgs;
    TGlbOptionFlgs =   Packed Record // "Record" to "Packed Record" Chg#54 (02.03.04 P.W)
      GlbOptions   : Array[1..MaxOptionFlgs] Of Boolean;
    end;

var
    { CountryCodeGlb      :Word       = 49; --> GlbFt.Pas 21.02.96 P.W}
     Century             :Boolean    = FALSE;
     SoundOnOff          :Boolean    = TRUE;
const
     PossMaxColor        = 256;
     {06.05.96 Michael Welsch moved from boiler }
     ARCHIVBLOCKSIZE     = 40; {24.05.96 Michael Welsch}
var
     AUTOMACRONAME       : String12 = 'AUTOANA.BIN';
     AutoStartFlg        : Boolean  = FALSE; { indicates,if autom. startsequence is running }
     PALEXT              : String04 = '.PAL';
     { these flags etc. can be used with different meanings !! }
     GlbOptionFlgs       : TGlbOptionFlgs = (GlbOptions: (TRUE,TRUE,TRUE,FALSE)); // never changed!
        // usage see UTKNApp0.pas Procedure empty dialog TKNApp.F10_Pressed;
        // fixed values:
        // SMOOTHMASKS=True; UseFilters=True; UseNewFilters=True; Refresh calc always=False;
        // GlbOptionFlgs.GlbOptions[1]  used in UTKNPane.pas Function  TCTGenPane.ShowSmoothZoom
        //                                      
        // GlbOptionFlgs.GlbOptions[4]  used in UTParam.pas  Function  TGenParams.Dialog
        //                                      forces Changed to true if true

     GlbUserId           : String04 = '';    {05.10.01 P.W}

     CheckDoubleKrnUse  :       byte;   {22.08.95 Michael Welsch}

     {GlbStrings           : PStringList; --> GlbFt.Pas 21.02.96 P.W}
     GlbErrorCode          : Smallint; {09.04.96 Michael Welsch}
     MaxAtt        :       Smallint     =       5000;    { maximum attenuation }
const
     PossMaxAtt    =       10000;
var
     ErrorLogFile  :       PathStr     =    'APPERROR.TXT';
const
     ScrYResThres  =       768-1;  {12.11.97 AG}
var
     DTFontHeight  :       Smallint  =       2;
Type
     T_GlbDebugMsgFunc =
       Function (Const Msg: String): Smallint;
     T_GlbDebugMsg0Func =
       Function (Const Msg, Button1, Button2, Button3: String): Smallint;

var
     GlbDebugMsgFunc    : T_GlbDebugMsgFunc   = NIL;
     GlbDebugMsg0Func   : T_GlbDebugMsg0Func  = NIL;
     GlbDebugMsgNetFunc : T_GlbDebugMsgFunc   = NIL;
//   ServiceFlgCopy     : Boolean = False;           // 09.07.08 P.W until 25.08.09 P.W
     ParameterRepairMode: Boolean = False;           // 09.07.08 P.W
     ReadlnHaltMessages : Array of AnsiString = NIL; // 09.07.08 P.W

  DisableRequestSound   : Boolean = False;  // 27.06.08 P.W  // set to true when femGlb.pas testPathflg is true
            // DisableRequestSound from TurboToDelphi to GlbDecs 25.08.09 P.W

 
  FTestPathFlg : Boolean = False;  // 27.06.08 P.W from FemGlb.pas at 25.08.09 P.W
  FServiceFlg  : Boolean = False;  // 25.08.09 P.W



Procedure GlbDebugMsg (Const Msg: String);  {23.10.01 P.W}
Function  GlbDebugMsg0(Const Msg, Button1, Button2, Button3: String): Smallint;  {23.10.01 P.W}
            {Result of GlbDebugMsg0: 0: Escape; 1: Button1 ...}
Procedure GlbDebugMsgN(Const Msg: String);  {23.10.01 P.W}

Procedure DoNothingProc;
Procedure DoubleKrnError;


Function  ProgramNameMsg: String;                        {01.10.00 P.W}
Procedure ReadlnWait(Msg:AnsiString='');                 {01.10.00 P.W}
Procedure ReadlnHalt(ExitCode: Word; const Msg:AnsiString=''); {01.10.00 P.W}

function TestPathFlg : Boolean; // ! Duplicate code in FemGlb.pas and GlbDecs.pas !
procedure SetServiceFlg(Value: Boolean); // 25.08.09 P.W;
function ServiceFlg  : Boolean;  // 27.06.08 P.W ! Duplicate code in FemGlb.pas and GlbDecs.pas !


Implementation
  const Unit_Name = 'GlbDecs'; // 03.05.24 P.W

Procedure DoubleKrnError;
begin
//  Writeln('Programm benutzt beide Graphiksysteme !!');
//  Writeln('Programm mit option BUILD compilieren !!');

  ReadlnHalt(1,
    'Programm benutzt beide Graphiksysteme !!' +sLineBreak+
    'Programm mit option BUILD compilieren !!'
  );   {Halt -> ReadlnHalt: 01.10.00 P.W}
end;

Procedure GlbDebugMsg(Const Msg: String);  {23.10.01 P.W}
begin
  If Assigned(GlbDebugMsgFunc)
    then GlbDebugMsgFunc(Msg);
  If Assigned(GlbDebugMsgNetFunc)
    then GlbDebugMsgNetFunc(Msg);
end;

Function  GlbDebugMsg0(Const Msg, Button1, Button2, Button3: String): Smallint;  {23.10.01 P.W}
begin
  If Assigned(GlbDebugMsg0Func)
    then GlbDebugMsg0 := GlbDebugMsg0Func(Msg, Button1, Button2, Button3)
    else GlbDebugMsg0 := -1;
end;

Procedure GlbDebugMsgN(Const Msg: String);  {23.10.01 P.W}
begin
  If Assigned(GlbDebugMsgNetFunc)
    then GlbDebugMsgNetFunc(Msg);
end;


Procedure DoNothingProc;
begin
end;

Function  ProgramNameMsg: String; {01.10.00 P.W}
begin
  ProgramNameMsg := 'Program "' + ExpandFileName(Param_Str(0)) + '"';
end;

Procedure ReadlnWait(Msg:AnsiString='');                {01.10.00 P.W}
// Msg since 23.02.05 P.W
begin
//  --- until 23.02.05 P.W: ---
//  Writeln('  Please press ENTER to continue...');
//  Sound(1000); Delay(500); NoSound;
//  While KeyPressed do Readkey;
//  Readln;

//  --- since 23.02.05 P.W: ---
  Beep;
  if Msg <> '' then Msg := Msg + sLineBreak;
//  ShowMessage(Msg+'  Please press ENTER to continue...');
  MessageBox1(0,
//  PChar(AnsiString(Msg+'  Please press ENTER to continue...')),   // u. 01.04.08 P.W
    PChar(Msg),                                                     // s. 01.04.08 P.W
    nil, MB_OK+MB_TASKMODAL);
end;

function ParameterRepairModePossible: Boolean;
// 09.07.08 P.W
begin
  Result := (AppStratec = AS_XctDirector) and ServiceFlg;   // ServiceFlgCopy -> ServiceFlg 25.08.09 P.W
end;

Procedure ReadlnHalt(ExitCode: Word; const Msg:AnsiString='');{01.10.00 P.W}
// modifications:
// Msg since 23.02.05 P.W
// 09.07.08 P.W: Support ParameterRepairMode;
// 01.09.08 P.W: In ParameterRepairMode no further Messages
  function AbortMsgPart: AnsiString;
  // 09.07.08 P.W replaces " aborted"
  begin
    if ParameterRepairMode then
      Result := ' not aborted (Parameter Repair Mode)'
    else
    if ParameterRepairModePossible then
      Result := ' will be aborted'
    else
      Result := ' aborted';    // original

  end;
begin
//  Writeln('  ', ProgramNameMsg, ' aborted');
  if not ParameterRepairMode then ReadlnHaltMessages := nil;

  if not ParameterRepairMode then // if: 01.09.08 P.W
  begin
    if (Msg <> '') then
      ReadlnWait(Msg + sLineBreak + '  ' + ProgramNameMsg + AbortMsgPart)
    else
      ReadlnWait(ProgramNameMsg + AbortMsgPart);
  end;

  if ParameterRepairModePossible and (not ParameterRepairMode) then   // 09.07.08 P.W
  begin
    ParameterRepairMode :=
      (MessageBox1(0,
         'Activate Parameter Repair Mode?',
         nil, MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL)
       = idYes);

  end;

  if ParameterRepairMode then
  begin
    SetLength(ReadlnHaltMessages, Length(ReadlnHaltMessages) + 1);
    ReadlnHaltMessages[Length(ReadlnHaltMessages) -1] := Msg;
  end;

  if not ParameterRepairMode then  // 09.07.08 P.W            controls
    H_alt(ExitCode, 'ReadlnHalt "'+Msg+'"');
end;

function TestPathFlg : Boolean;
// modifications:
// 27.06.08 P.W: var changed to function to ensure setting is only performed using SetTestPathFlg
// 25.08.09 P.W also in GlbDecs.pas!
// ! Duplicate code in FemGlb.pas and GlbDecs.pas !
begin
  Result := FTestPathFlg;
end;

procedure SetServiceFlg(Value: Boolean);
// 25.08.09 P.W Replaces "ServiceFlg := Value;"
begin
  FServiceFlg := Value;
end;

function ServiceFlg  : Boolean;
// modifications:
// 27.06.08 P.W: var changed to function to ensure setting is only performed using SetTestPathFlg
// ! Duplicate code in FemGlb.pas and GlbDecs.pas !
begin
  Result := FServiceFlg;
end;



{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}


procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  AUTOMACRONAME       := 'AUTOANA.BIN';
  AutoStartFlg        := FALSE;
  Century             := FALSE;
  CheckDoubleKrnUse  := 0;
  DisableRequestSound   := False;
  DTFontHeight  :=       2;
  ErrorLogFile  :=    'APPERROR.TXT';
  FServiceFlg  := False;
  FTestPathFlg := False;
  GlbDebugMsg0Func   := NIL;
  GlbDebugMsgFunc    := NIL;
  GlbDebugMsgNetFunc := NIL;
  GlbErrorCode          := 0;
//GlbOptionFlgs       : TGlbOptionFlgs = (GlbOptions: (TRUE,TRUE,TRUE,FALSE)); // never changed!
  GlbOptionFlgs.GlbOptions[1] := True;
  GlbOptionFlgs.GlbOptions[2] := True;
  GlbOptionFlgs.GlbOptions[3] := True;
  GlbOptionFlgs.GlbOptions[4] := False;
  GlbUserId           := '';
  MaxAtt        :=       5000;
  MaxAvail := 8000000;
  MaxCTImageSize := 0;
  MemAvail := 8000000;
  PALEXT              := '.PAL';
  ParameterRepairMode:= False;
  ReadlnHaltMessages := NIL;
  SoundOnOff          := TRUE;

//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
  GlbErrorCode:=0;
  CheckDoubleKrnUse:=0;
{  GlbStrings:=NIL; --> GlbFT.pas {21.02.96 P.W}
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  GlbErrorCode:=0;
  CheckDoubleKrnUse:=0;
{  GlbStrings:=NIL; --> GlbFT.pas {21.02.96 P.W}
   -^--- moved to function Unit_Init // 03.05.24 P.W *)

end.
