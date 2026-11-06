// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; changes: 1; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Version: @(#)ScanIo0 V.:1.00                            ) +*)
(*+ Author             : P.Wueseke                                        +*)
(*+ Date               : 14.06.94                                         +*)
(*+ Description        : Simple ScanData IO     Project Femur             +*)
(*+ Description        : Only measurement part                            +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*+ Last modified/By   : 22.06.99 / P.Wueseke                           : +*)
(*+ Date/Modification  : 22.06.99 P.W / New: FileOpenReadOnly             +*)
(*
{25.09.02 P.W}
  Type HeadPart1RecType now in XGLB
27.06.05 P.W:  moved from folder Meas\Pas to Common\Pas
*)
(*+ Date/Modification    (end of list)                                    +*)
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)

(*
{ -------------------------------------------------------------------------
{ A) Structure of Scan-Data-File:
{    -----------------------------
{    Area                          Byte in file
{    --- Header Area -------------
{    - Part 1 -
{    HeadVers           : LongInt;          0  ..   3
{    HeadLen            : LongInt;          4  ..   7
{    MaxNumScans        : LongInt;          8  ..  11
{    NumScans           : LongInt;         12  ..  15
{    - Part 2 -
{    HeaderData                            16  ..  HeadLen -1
{    --- Start of Scans Area -----
{    Start_Scan1        : LongInt; HeadLen +0  ..  HeadLen +3
{    Start_Scan2        : LongInt; HeadLen +4  ..  HeadLen +7
{    ...
{    Start_Scan_NumScans: LongInt; HeadLen + 4*(NumScans-1)
{                                              ..  HeadLen + 4*(NumScans-1) +3
{    Start_Scan_NumScansNext
{                       : LongInt; HeadLen + 4*NumScans
{                                              ..  HeadLen + 4*NumScans     +3
{    Not in use         :          HeadLen + 4*(NumScans+1)
{                                              ..  HeadLen + 4*MaxNumScans  +3
{    --- Data Area ---------------
{    Data of Scan1                 Start_Scan1 ..  Start_Scan2 -1
{    ---
{    Data of Scan2                 Start_Scan2 ..  Start_Scan3 -1
{    ---
{    ...
{    ---
{    Data of Scan_NumScans         Start_Scan_NumScans
{                                              ..  Start_Scan_NumScansNext -1
{    -----------------------------
{
{    Start_Scan1 := HeadLen+4*(MaxNumScans+1)
{ -------------------------------------------------------------------------
{ B) Actions of measurement program with data file:
{    1) File with Header-Area, Start-of-Scans-Area and Data of NumScans scans
{       must exist!
{    2) Open Data-File
{    3) Read Header Area Part 1
{    4) Check if ScanNo is valid (range [1 .. NumScans+1])
{       if not valid: close Data-File and stop with error message
{    5) Read ScanStart_ScanNo in Start-of-Scans-Area
{    6) Write Scan-Data to file
{    7) Set ScanStart_ScanNoNext to ScanStart_ScanNo + Length of Scan-Data
{    8) Close Data-File
{ -------------------------------------------------------------------------
{ C) This Unit contains only the tools necessary for B)
{ -------------------------------------------------------------------------
{ D) Tools to initalise Data-File and to interpret Data see in Unit ScanIo1
{ -------------------------------------------------------------------------
*)

Unit ScanIo0;

Interface

Uses
  GlbType,           {22.06.99 P.W}
  XGlb,
  Dos;

Type
  ScanIoRecType    = Packed Record // "Record" to "Packed Record" Chg#1573 (02.03.04 P.W)
    HP1            : HeadPart1RecType;
    ScanNo         : LongInt;
    Start_Scan_ScanNo        : LongInt;
    Start_Scan_ScanNoNext    : LongInt;
  end;

(* === GENARAL IO =========================================================*)
Function FileRewrite(Var Io: File; Name: PathStr): Smallint;
Function FileOpen(Var Io: File; Name: PathStr): Smallint;
Function FileOpenReadOnly(Var Io: File; Name: PathStr): Smallint; {22.06.99 P.W}
Function FileClose(Var Io: File): Smallint;
Function FilePosRead(Var Io: File; Pos:LongInt; Var Buf; Count: Word): Smallint;
Function FilePosWrite(Var Io: File; Pos:LongInt; Var Buf; Count: Word): Smallint;

(* === MEASUREMENT IO =====================================================*)
Function Pos_Start_ScanNo(HP1: HeadPart1RecType; ScanNo: LongInt): LongInt;
Function Calc_Start_Scan1(HP1: HeadPart1RecType): LongInt;

Function ScanFilePrepForIo(
         Var Io    : File;
         ScanNo_   : LongInt;
         Var SIR   : ScanIoRecType): Smallint;

Function ScanFileUpDate(
         Var Io    : File;
         Var SIR   : ScanIoRecType): Smallint;

Implementation
  const Unit_Name = 'ScanIo0'; // 03.05.24 P.W

(* === GENARAL IO =========================================================*)

(*.**************************************************************************)
(** Function Name    : FileRewrite                                        **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.06.94                                           **)
(** Description      : Data File must exist!                              **)
(** Description      : Opens file with a size of 1 byte per element       **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : IO, Name of file                                   **)
(** Output           : Ok:Ret=0; not Ok:Ret=ErrCode                       **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.06.94 / P.Wueseke                               **)
(** Date/Modification: --.06.94 P.W /                                     **)
(**************************************************************************.*)
Function FileRewrite(Var Io: File; Name: PathStr): Smallint;
Var
  Res, ResH        : Smallint;
begin
  Res:=0;
  {$I-}
    Assign(Io, FExpand(Name));// FExpand added (04.03.04 P.W)
    Rewrite (Io, 1);
    ResH:=IoResult; if (Res=0) then Res:=ResH;
  {$I+}
  FileRewrite:=Res;
end;

(*.**************************************************************************)
(** Function Name    : FileOpen                                           **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.06.94                                           **)
(** Description      : Data File must exist!                              **)
(** Description      : Opens file with a size of 1 byte per element       **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : IO, Name of file                                   **)
(** Output           : Ok:Ret=0; not Ok:Ret=ErrCode                       **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.06.94 / P.Wueseke                               **)
(** Date/Modification: --.06.94 P.W /                                     **)
(**************************************************************************.*)
Function FileOpen(Var Io: File; Name: PathStr): Smallint;
Var
  Res, ResH        : Smallint;
begin
  Res:=0;
  {$I-}
    Assign(Io, FExpand(Name)); // FExpand added (04.03.04 P.W)
    Reset (Io, 1);
    ResH:=IoResult; if (Res=0) then Res:=ResH;
  {$I+}
  FileOpen:=Res;
end;

Function FileOpenReadOnly(Var Io: File; Name: PathStr): Smallint;
{22.06.99 P.W} {Like FileOpen, but only for reading!}
               {helps to read files with attribute "ReadOnly"}
Var
  Res, ResH        : Smallint;
  FileModeSav      : Word;
begin
  Res:=0;
  {$I-}
    Assign(Io, FExpand(Name)); // FExpand added (04.03.04 P.W)
    FileModeSav:=FileMode;
    FileMode:=FileMode_ReadOnly;
    Reset (Io, 1);
    ResH:=IoResult; if (Res=0) then Res:=ResH;
    FileMode:=FileModeSav;
  {$I+}
  FileOpenReadOnly:=Res;
end;

(*.**************************************************************************)
(** Function Name    : FileClose                                          **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.06.94                                           **)
(** Description      : File must be open!                                 **)
(** Description      : Closes the file                                    **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : IO                                                 **)
(** Output           : Ok:Ret=0; not Ok:Ret=ErrCode                       **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.06.94 / P.Wueseke                               **)
(** Date/Modification: --.06.94 P.W /                                     **)
(**************************************************************************.*)
Function FileClose(Var Io: File): Smallint;
Var
  Res, ResH        : Smallint;
begin
  Res:=0;
  {$I-}
    if (Res=0) then Close (Io);
    ResH:=IoResult; if (Res=0) then Res:=ResH;
  {$I+}
  FileClose:=Res;
end;

(*.**************************************************************************)
(** Function Name    : FilePosRead                                        **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.06.94                                           **)
(** Description      : File must be open!                                 **)
(** Description      : Read Count bytes from file (position pos) to Buf   **)
(** Description      : If Pos is negative then Seek is skipped            **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : Io, Pos, Count                                     **)
(** Output           : Buf, Ok:Ret=0; not Ok:Ret=ErrCode                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.06.94 / P.Wueseke                               **)
(** Date/Modification: --.06.94 P.W /                                     **)
(**************************************************************************.*)
Function FilePosRead(Var Io: File; Pos:LongInt; Var Buf; Count: Word): Smallint;
Var
  Res, ResH        : Smallint;
  Result_          : LongInt; //Word;
begin
  Res:=0;
  {$I-}
    if (Pos>=0) then
    begin
      Seek(Io, Pos);
      ResH:=IoResult; if (Res=0) then Res:=ResH;
    end;
    if (Count<>0) then
    begin
      if (Res=0) then BlockRead(Io, Buf, Count, Result_);
      ResH:=IoResult; if (Res=0) then Res:=ResH;
      if (Result_<>Count) and (Res=0) then Res:=100;
    end;
  {$I+}
  FilePosRead:=Res;
end;

(*.**************************************************************************)
(** Function Name    : FilePosWrite                                       **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.06.94                                           **)
(** Description      : File must be open!                                 **)
(** Description      : Write Count bytes from Buf to file at position pos **)
(** Description      : If Pos is negative then Seek is skipped            **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : Io, Pos, Count                                     **)
(** Output           : Buf, Ok:Ret=0; not Ok:Ret=ErrCode                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.06.94 / P.Wueseke                               **)
(** Date/Modification: --.06.94 P.W /                                     **)
(**************************************************************************.*)
Function FilePosWrite(Var Io: File; Pos:LongInt; Var Buf; Count: Word): Smallint;
Var
  Res, ResH        : Smallint;
  Result_          : LongInt; //Word;
begin
  Res:=0;
  {$I-}
    if (Pos>=0) then
    begin
      Seek(Io, Pos);
      ResH:=IoResult; if (Res=0) then Res:=ResH;
    end;
    if (Count<>0) then
    begin
      if (Res=0) then BlockWrite(Io, Buf, Count, Result_);
      ResH:=IoResult; if (Res=0) then Res:=ResH;
      if (Result_<>Count) and (Res=0) then Res:=101;
    end;
  {$I+}
  FilePosWrite:=Res;
end;

(* === MEASUREMENT IO =====================================================*)

(*.**************************************************************************)
(** Function Name    : Pos_Start_ScanNo                                   **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.06.94                                           **)
(** Description      : Calculates Position of Start_ScanNo Var. in file   **)
(** Description      : ScanNo must be 1 or greater!                       **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : HP1, ScanNo                                        **)
(** Output           : Returns the Position                               **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.06.94 / P.Wueseke                               **)
(** Date/Modification: --.06.94 P.W /                                     **)
(**************************************************************************.*)
Function Pos_Start_ScanNo(HP1: HeadPart1RecType; ScanNo: LongInt): LongInt;
begin
  With HP1 do
    Pos_Start_ScanNo:=HeadLen + 4*(ScanNo-1);
end;

(*.**************************************************************************)
(** Function Name    : Calc_Start_Scan1                                   **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.06.94                                           **)
(** Description      : Calculates Start of Data of Scan1 in file          **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : HP1                                                **)
(** Output           : Returns the Position                               **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.06.94 / P.Wueseke                               **)
(** Date/Modification: --.06.94 P.W /                                     **)
(**************************************************************************.*)
Function Calc_Start_Scan1(HP1: HeadPart1RecType): LongInt;
begin
  With HP1 do
    Calc_Start_Scan1:=HeadLen + 4*(MaxNumScans+1);
end;

(*.**************************************************************************)
(** Function Name    : ScanFilePrepForIo                                  **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.06.94                                           **)
(** Description      : File must be open!                                 **)
(** Description      : Prepares ScanFile to write or read the ScanData    **)
(** Description      : (Open file and seek startpos of ScanData)          **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : FilePosRead                                        **)
(** Input            : ScanNo_                                            **)
(** Output           : Io, SIR                                            **)
(** Output           : Ok:Ret=0; not Ok:Ret=ErrCode                       **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.06.94 / P.Wueseke                               **)
(** Date/Modification: --.06.94 P.W /                                     **)
(**************************************************************************.*)
Function ScanFilePrepForIo(
         Var Io    : File;
         ScanNo_   : LongInt;
         Var SIR   : ScanIoRecType): Smallint;
Var
  Res, ResH        : Smallint;
begin
  Res:=0;
  FillChar(SIR, SizeOf(SIR), #0);
  With SIR do
  begin
    ScanNo:=ScanNo_;
    if (Res=0) then
    begin
      Res:=FilePosRead(Io, 0, HP1, SizeOf(HP1));
    end;
    if (Res=0) then
    begin
      if (ScanNo < 1              ) or
         (ScanNo > HP1.NumScans+1 ) or
         (ScanNo > HP1.MaxNumScans)    then Res:=-123;            // -1 -> -123 : 23.11.07 P.W
    end;
    if (Res=0) then
    begin
      Res:= FilePosRead(Io, Pos_Start_ScanNo(HP1, ScanNo),
              Start_Scan_ScanNo, SizeOf(Start_Scan_ScanNo));
    end;
    if (Res=0) then
    begin
      Res:= FilePosRead(Io, Pos_Start_ScanNo(HP1, ScanNo+1),
              Start_Scan_ScanNoNext, SizeOf(Start_Scan_ScanNoNext));
    end;
    if (Res=0) then
    begin
      Res:= FilePosRead(Io, Start_Scan_ScanNo, ResH, 0);{0: seek mit ioresult}
    end;
  end;
  ScanFilePrepForIo:=Res;
end;

(*.**************************************************************************)
(** Function Name    : ScanFileUpDate                                     **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.06.94                                           **)
(** Description      : Updates Fields: NumScans, Start_Scan_ScanNoNext    **)
(** Description      : FilePos must be at the end of Scan-Data(ScanNo)!   **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : FilePosWrite                                       **)
(** Input            : Io, SIR                                            **)
(** Output           : Ok:Ret=0; not Ok:Ret=ErrCode                       **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.06.94 / P.Wueseke                               **)
(** Date/Modification: --.06.94 P.W /                                     **)
(**************************************************************************.*)
Function ScanFileUpDate(
         Var Io    : File;
         Var SIR   : ScanIoRecType): Smallint;
Var
  Res, ResH        : Smallint;
begin
  Res:=0;
  With SIR do
  begin
    {$I-}
      Start_Scan_ScanNoNext:=FilePos(Io);
      ResH:=IoResult; if (Res=0) then Res:=ResH;
    {$I+}
    if HP1.NumScans<ScanNo then
    begin
      HP1.NumScans:=ScanNo;
      if (Res=0) then Res:=FilePosWrite(Io, 0, HP1, SizeOf(HP1));
    end;
    if (Res=0) then Res:=
      FilePosWrite(Io, Pos_Start_ScanNo(HP1, ScanNo+1),
                  Start_Scan_ScanNoNext, SizeOf(Start_Scan_ScanNoNext));
  end;
  ScanFileUpDate:=Res;
end;

end.
