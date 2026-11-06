// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; changes: 1; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.*************************************************************************
Unit MenuIDs:  IDs for the project: knochen.exe
Version : @(#)  V:2.0
Author  : M.Welsch
Date    : 11.03.93
Modified:
Modification log:
{26.05.93 Michael Welsch}
Type declarations seperated from menu valid and set functions.
{28.10.94 Michael Welsch}                           M_HISTO,
{24.04.97 MW}     M_KSTEST,
{07.07.99 P.W}    support Menu Point for "Table" : M_TableSpec
{27.06.03 P.W} TMenufield.Name type from String15 to String20
               (Reason: Message >START "MacroName"<  was incomplete)
16.04.08 P.W: Record TMenufield Field Name from String20 to String40 for longer LoopProject Names
****************************************************************************)
Unit MenuIds;
{$O+}
{$F+}

INTERFACE

Uses
  GlbDecs;

const
  MaxMenuFields    = 15;
Type
{!!!! Attention: !!!!
 new menu option constants should always be appended NOT inserted!!!
 Otherwise files like reference data is no longer compatible !! }

   TMenuID             = (
                 { help context = Ord(Main)*1000+Ord(Sub)}
                 {  0}         M_First,
                 {  1}         M_MMAIN,  { Multislice main menu   }
                 {  2}         M_SELECTSLICE,
                 {  3}         M_SUMMARY,
                 {  4}         M_SMAIN,  { single Slice main menu }
                 {  5}         M_MMACRO, {07.08.95 Michael Welsch}
                 {  6}         M_AUTO,   {12.10.95 Michael Welsch}
                 {  7}         M_MSTARTREAD,
                 {  8}         M_MSTARTWRITE,
                 {  9}         M_MSELECT,
                 { 10}         M_MPAUSE,
                 { 11}         M_SETUP,
                 { 12}         M_OK,
                 { 13}         M_END,
                 { 14}         M_IMAGE,
                 { 15}         M_COLOR,
                 { 16}         M_SHOWSV,
                 { 17}         M_SCDMP,
                 { 18}         M_SAVEPX,
                 { 19}         M_EXTRA,
                 { 20}         M_DISTANCE,
                 { 21}         M_PROFIL,
                 { 22}         M_ANALYSE,
                 { 23}         M_ROI,
                          { analysis types.. }
                 { 24}         M_CALCBD,  {M_CALCB2 see 47}
                 { 25}         M_CORTBD,
                 { 26}         M_DENSIT,
                 { 27}         M_LOOP,
                 { 28}         M_HISTO,
                 { 29}         M_STAB,
                 { 30}         M_CONCPEEL,
                          { may be used in many analysis types}
                 { 31}         M_PARAMETER,
                 { 32}         M_NORMAL,
                 { 33}         M_TREND,
                 { 34}         M_PRINT,
                          { special for histo }
                 { 35}         M_HSTSELECT,
                 { 36}         M_HSTCHANGE,
                          { special for Loop }
                 { 37}         M_LOOPSTART,
                 { 38}         M_LOOPSELECT,
                 { 39}         M_LOOPEDIT,
                 { 40}         M_LOOPBROWSE,
                          { special for M_SUMMARY, }
                 { 41}         M_SUMSELECT,
                 { 42}         M_SUMTREND,
                 { 43}         M_QA,
                 { 44}         M_STUDY,
                 { 45}         M_STATUS,
                 { 46}         M_PALETTE,
                 { 47}         M_CALCB2,    {04.01.96 Michael Welsch}
                 { 48}         M_SUMSLICE,
                 { 49}         M_INFO,
                 { 50}         M_HELP,
                 { 51}         M_LOCSVSHOW,
                 { 52}         M_DEFSET,
                 { 53}         M_KSTEST,       {22.04.97 MW}
                 { 54}         M_TableSpec,    {07.07.99 P.W (1/5)}
                                 {^-- Used for Muscle and Tibia Results}
                 { 55}         M_PlaySlices,   {07.07.99 P.W (1/5)}
                 { 56}         M_LAST);

    TAnaTypeSet      =       Set Of TMenuID; {24.04.96 Michael Welsch}

    TMenufield = Packed Record // "Record" to "Packed Record" Chg#1555 (02.03.04 P.W)
     Name      : String40;  { this is translated ! } {15-> 20: 27.06.03 P.W}  // 20->40: 16.04.08 P.W
     IDName    : String15;  { this NOT! it is the ID used in XBana.txt for autom. calc. }
     LotusHelp : String80;
     ID        : TMenuID;
     Context   : Word; {30.04.96 Michael Welsch}
    end;

    TMenu      = Array[0..MaxMenuFields] Of TMenufield;

    SetOfTMenuID  =   Set Of TMenuID;
const
    ALLANALYSIS    :   SetOfTMenuID
                   =   [M_CALCBD,M_CORTBD,M_DENSIT,
                       M_LOOP,M_HISTO,M_STAB,M_CONCPEEL];

Implementation
  const Unit_Name = 'MenuIds'; // 03.05.24 P.W

end.
