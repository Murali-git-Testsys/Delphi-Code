// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; changes: 11; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Vers.: @(#)GlbFT V.:1.00                                ) +*)
(*+ Author           : P.Wueseke                                          +*)
(*+ Date             : 22.06.96                                           +*)
(*+ Description      : Global  Formatted Text                             +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*+ Last modified/By : 01.10.00 / P.Wueseke                               +*)
(*+ Date/Modification: 22.02.96 P.W / Use Include GlbFtLoc                +*)
(*+ Date/Modification: 23.02.96 M.W. filename RES_... -> RSC_...          +*)
(*+ Date/Modification: 23.02.96 P.W / GlbFtLoc,FT: FtClipFlg  introduced  +*)
(*+ Date/Modification: 23.02.96 P.W / GlbFtLoc: FtResStreamBufSize intr.  +*)
(*+ Date/Modification: 03.02.97 P.W / GlbLangTxtDef '.TXT' -> '.ENG'      +*)
(*+ Date/Modification: {29.04.97 MW} Function GetLanguageExt:             +*)
(*+                                     New const GlbMaskDir              +*)
(*+ Date/Modification: 07.06.99 P.W / Sup ExitTool.AddExitProc            +*)
(*+ Date/Modification: 07.07.99 P.W / Conditional defines: NOTRANS        +*)
(*+ Date/Modification: 01.10.00 P.W / Halt -> ReadlnHalt                  +*)
// 08.02.08 P.W no longer include unused units SysUtils, Crt, GlbDecs, GlbPath, Dos
//   avoid overhead
(*+ Date/Modification  (end of list)                                      +*)
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)
Unit GlbFT;

INTERFACE

Uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
//  SysUtils,                // u. 08.02.08 P.W
//  Crt,                     // u. 08.02.08 P.W
  TransX;//  TranslateData,     // 24.06.04 P.W
//  GlbDecs,  {01.10.00 P.W} // u. 08.02.08 P.W
//  GlbPath,                 // u. 08.02.08 P.W
//  Dos;                     // u. 08.02.08 P.W

{--------------------------------------------------------------------}
{$I TransCon}             
(* Example for TransCon:
const
  sc00001                = 100;
  sc00002                = 101;
*)
{--------------------------------------------------------------------}

{--------------------------------------------------------------------}
{$I GlbFtLoc}
(* Example for GlbFtLoc: a) in ANA\PAS:
  Const
    TransInitAutoFlg = FALSE;
    LocProjNamePart  = 'KNMU';
    FtClipFlg             = False;   {23.02.96 P.W}
    FtResStreamBufSize    = 4096;    {23.02.96 P.W}
*)
(* Example for GlbFtLoc: b) in MEAS\PAS:
Const
  TransInitAutoFlg      = False;
  LocProjNamePart       = 'XBON';
  FtClipFlg             = True;
  FtResStreamBufSize    = 4096;
*)
{--------------------------------------------------------------------}


  {------------------------------------------------------------------}

Type

  FTModeType  = (FL,FLP,FR,FRP,FC,FM,MU); { PxEngine.Tpu definiert FL neu! }
  { Textausgaben formatiert:
  { FL:  Text linksbündig //OemToAnsi Chg#48 (02.03.04 P.W)
  { FLP:  Text linksbündig falls notwendig auch länger //OemToAnsi Chg#47 (02.03.04 P.W)
  { FR:  Text rechtsbündig //OemToAnsi Chg#46 (02.03.04 P.W)
  { FRP:  Text rechtsbündig falls notwendig auch länger //OemToAnsi Chg#45 (02.03.04 P.W)
  { FC:  Text zentriert
  { FM:  Text wird gegebenenfalls auf angegebene Länge gekürzt //OemToAnsi Chg#44 (02.03.04 P.W)
  { MU:  "multiply Txt FieldLen times"
  }

Const
  CountryCodeGer      = 049;
var
  CountryCodeGlb      : Word = CountryCodeGer; {Deutschland}

// FT_ format Text without translation      (Previous FT( 'Field1', or FT(Name,
Function FT_(      Txt:String; FTMode:FTModeType; FieldLen:Byte):String;
// FT  format Text with    translation      (Unchanged  "FT('Please translate',")
Function FT (const Txt:String; FTMode:FTModeType; FieldLen:Byte):String;
//Function GetLanguageExt: ExtStr; // moved to GlbPath 08.04.05 P.W

Implementation
  const Unit_Name = 'GlbFT'; // 03.05.24 P.W

Const
  OldExitProcFlg   : Boolean = False; {make sure OldExitProc only once used}
  OldExitProc      : Pointer = Nil;

(*.**************************************************************************)
(** Function Name    : FT                                                 **)
(** Author           : P.Wueseke                                          **)
(** Date             : 23.02.96                                           **)
(** Description      : -------------------------------------------------- **)
(** Description      : Textausgaben formatiert:                           **)
(** Description      : -------------------------------------------------- **)
(** Description      : FL:  Text linksbündig                              **) //OemToAnsi Chg#43 (02.03.04 P.W)
(** Description      : FLP:  Text linksbündig falls notwendig auch länger **) //OemToAnsi Chg#42 (02.03.04 P.W)
(** Description      : FR:  Text rechtsbündig                             **) //OemToAnsi Chg#41 (02.03.04 P.W)
(** Description      : FRP:  Text rechtsbündig falls notwendig auch länger**) //OemToAnsi Chg#40 (02.03.04 P.W)
(** Description      : FC:  Text zentriert                                **)
(** Description      : FM:  Text wird auf angegebene Länge gekürzt        **) //OemToAnsi Chg#39 (02.03.04 P.W)
(** Description      : MU:  "multiply Txt FieldLen times"                 **)
(** Description      : -------------------------------------------------- **)
(** Description      : Clipping auf Länge bei FL, FR, FC, MU nur falls    **) //OemToAnsi Chg#38 (02.03.04 P.W)
(** Description      :   FtClipFlg True                                   **)
(** Description      : -------------------------------------------------- **)
(** Description      : Special tools use FT ( 'bsp...', for translation:   **)
(** Description      :   NTrans.Exe reads source and converts             **)
(** Description      :     FT ( 'Original',... -->                         **)
(** Description      :     FT (GlbStrings^.Get(Sc#####)                    **)
(** Description      : Look out: in above example should be (' & not ( '  **)
(** Description      : -------------------------------------------------- **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            : Txt, FTMode, FieldLen                              **)
(** Output           : RETURN (String): Txt                               **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : FtClipFlg                                          **)
(***************************************************************************)
// Modifications:
// 06.07.04 P.W: speed improved replacing "While Length.."
// 04.04.05 P.W: FT_ as copy of FT Created without translation,
//    FT Calls FT_
(**************************************************************************.*)
Function FT_(Txt: String; FTMode: FTModeType; FieldLen: Byte): String;
// FT_: no translation wanted!
  procedure FormatTxt(AddPre, Len, AddPost: Integer);
  // added 06.07.04 for speed up
  // (use of "StringOfChar" is slower!)
  var
    I : Integer;
  begin
    SetLength(Txt, FieldLen);
    if (AddPre > 0) then
    begin
      For I:=Len downto 1 do
        Txt[AddPre +I] := Txt[I];
      For I:=1 to AddPre do
        Txt[I] := ' ';
    end;
    For I:=0 to AddPost-1 do
      Txt[FieldLen-I] := ' ';
  end;
Var
  Stxt             : String;
  Len, I, AddPre, AddPost   : Integer;

begin
  Case FTMode of
    FLP,
    FL: //While Length(Txt) < FieldLen do Txt := Txt+' ' ;
       begin
         Len := Length(Txt);
         If (Len < FieldLen) then
           FormatTxt(0, Len, FieldLen-Len);
       end;
    FRP,
    FR: //While Length(Txt) < FieldLen do Txt := ' '+Txt ;
       begin
         Len := Length(Txt);
         If (Len < FieldLen) then
           FormatTxt(FieldLen-Len, Len, 0);
       end;
    FC: //While Length(Txt) < FieldLen do
        //begin
        //  Txt := ' '+Txt ;
        //  IF Length(Txt) < FieldLen then Txt := Txt+' ' ;
        //end;
       begin
         Len := Length(Txt);
         If (Len < FieldLen) then
         begin
           // prefer spaces before (AddPost <= AddPre):
           AddPost := (FieldLen - Len) div 2;
           AddPre  := (FieldLen - Len - AddPost);
           FormatTxt(AddPre, Len, AddPost);
         end;
       end;
    FM: begin
          If Length(Txt) > FieldLen then
            Setlength(Txt, FieldLen);
        end;
    MU: begin
          //If Txt='' then STxt:=' '
          //          else STxt:=Txt;
          //Txt:='';
          //While Length(Txt) < FieldLen do Txt := Txt+Stxt;
          if Txt = '' then Txt := ' ';
          if (Length(Txt) = 1) then
          begin
//slow!:    Txt := StringOfChar(Txt[1], FieldLen);
            SetLength(Txt, FieldLen);
            for I:= 2 to FieldLen do
              Txt[I] := Txt[1];
          end else
          begin
            STxt := Txt;
            While Length(Txt) < FieldLen do Txt := Txt+Stxt;
          end;
        end;
  end;

  If FtClipFlg                    {23.02.96 P.W}
    and (Length(Txt)>FieldLen)
    and not (FTmode in [FLP,FRP])
    then Setlength(Txt, FieldLen);

  Result := Txt;
end;

Function FT (const Txt: String; FTMode: FTModeType; FieldLen: Byte): String;
begin
  // 06.07.04 P.W:
  // Translate using Database (without index) a bit slow!
  // Quicker: translate using Translate.pas: + 60 %
  //  compared "Ft('Hello?',FL, 20);" with and without
  //  but the parameter FieldLen slows down if changed to 200
  //  (measured using the slow While Length version)
  // ---- but now since speed up using FormatTxt the
  // translation is the significant part!

  Result := FT_(
     TraS(Txt), // TransLate.: 24.06.04 P.W
     FtMode,
     FieldLen);
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  CountryCodeGlb   := CountryCodeGer;
  OldExitProc      := Nil;
  OldExitProcFlg   := False; 

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
