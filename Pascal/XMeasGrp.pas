// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; changes: 14; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; changes: 1; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Vers.: @(#)XMeasGrp V.:1.00                             ) +*)
(*+ Author           : P.Wueseke                                          +*)
(*+ Date             : 11.03.97 & 20.03.97                                +*)
(*+ Description      : Support several measgroups (FEMUR)                 +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*+ Last modified/By : 20.03.01 / P.Wueseke                               +*)
(*+ Date/Modification: 21.03.97 P.W / Continue work                       +*)
(*+ Date/Modification: 01.04.97 P.W / Continue work (supp. RefFlg)        +*)
(*+ Date/Modification: 07.04.97 P.W / Correction in MeasGrpsToSvHead      +*)
(*+ Date/Modification: 07.04.97 P.W / Use IoTools instead of DirTool      +*)
(*+ Date/Modification: 10.04.97 MW  new function:                         +*)
(*+ Function Fem_GrpNo          (Const DR: DetRecType_Fem): Smallint;      +*)
(*+ Date/Modification: 16.04.97 P.W / Improved Support of DoAddGrp        +*)
(*+ Date/Modification: 16.04.97 P.W / Change all Byte to Smallint          +*)
(*+ Date/Modification: 17.04.97 P.W / New: tMeasGrpObj.StoreDRF           +*)
(*+ Date/Modification: 17.04.97 P.W / tMeasGrpList RefMode del empty ct   +*)
(*+ Date/Modification: 22.06.99 P.W / Sup. ObjectLen <-> PatObjLen        +*)
(*+ Date/Modification: 22.06.99 P.W + in MeasGrpsToSvHead and             +*)
(*+ Date/Modification: 22.06.99 P.W + in SvHeadToMeasGrps                 +*)
(*+ Date/Modification: 22.06.99 P.W / Support FileMode_ReadOnly           +*)
(*+ Date/Modification: 22.06.99 P.W / LoadDRF returns errorcode           +*)
(*+ Date/Modification: 09.03.01 P.W / Some Comment added                  +*)
(*+ Date/Modification: 20.03.01 P.W / Sup. NumSlicesDone                  +*)
(*+ Date/Modification: 20.03.01 P.W +  Will be 0 if not RefFlg            +*)
(*+ Date/Modification: 20.03.01 P.W +  Will be checked & summed if RefFlg +*)
// Modifications:
// 20.12.06 P.W:
//    Function Fem_SlicePos     use GetSliceNoGrp
//    function CtMaskFromSvName use SliceNrNamePartMask
//    function NameOfSlice      use SliceNrToNamePart
// 13.01.09 P.W: new function GetSlicePositions
(*+ Date/Modification  (end of list)                                      +*)
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)
Unit XMeasGrp;

INTERFACE

Uses
  Param_StrUnit,
  TypesUse,  // 13.01.09 P.W
  BnHead0,
  ComNames,  // 20.12.06 P.W
  Dos,
  GlbType,
  IoTools,    {07.04.97 P.W}
  Objects,
  Tools,
  XGlb;

function Fem_SlicePos_SliceNoGrp(const DR: DetRecType_Fem;
                                 const SliceNoGrp: SmallInt): Single;
Function Fem_SlicePos       (Const DR: DetRecType_Fem;
                             Const HelpSliceNo: Smallint): Single;
Function Fem_GrpNo          (Const DR: DetRecType_Fem): Smallint; {10.04.97 MW}
Function Fem_DistMeasRef    (Const DR: DetRecType_Fem): Single;
Function Fem_RefPos         (Const DR: DetRecType_Fem): Single;
Function Fem_MeasPos        (Const DR: DetRecType_Fem): Single;
Function Fem_CalcSliceStart (Const DR: DetRecType_Fem;
                             Const RefPos: Single    ): Single;

Const
  {NameExtLen       = 12;  { ########.### (8 + 1 + 3) } {u.: 02.09.97 P.W}
  MaskDetCtRec     = 'INTER\DETCT??.REC';
  // SliceNoMax       = 255; { decimal 1..255; as hex extenison: ".Mxx" }  // not used; as comment: 12.01.09 P.W

Type
  tDistRefSliceInfo = record    // 29.06.09 P.W
    DistRefFirstSlice,
    DistSlices          : Double;
    NumSlices           : Integer;
    AsymFlg             : Boolean;
    RefPos              : Double;
    RefNr               : Integer;
  end;
  tDistRefSliceInfoArr = Array of tDistRefSliceInfo; // 29.06.09 P.W

  pMeasGrpObj      = ^tMeasGrpObj;
  tMeasGrpObj      = Object(TObject_TP7) // "TObject" to "TObject_TP7" Chg#1773 (02.03.04 P.W)
    Name           : PathStr;
    SliceOffset    : Smallint;
    Group          : Smallint;
    DRF            : DetRecType_Fem;
    FirstMeasSlice : Smallint;         {16.04.97 P.W}
    Status         : Smallint;         {22.06.99 P.W}

    Constructor Init(Const I_Name: PathStr);
    Constructor CopyInit(
                  Const I_Name: PathStr;
                  Const I_Orig: pMeasGrpObj);
    Destructor  Done;                                                virtual;

    Function    LoadDRF:  Smallint;                                   virtual;
    Function    StoreDRF: Smallint;                                   virtual;
  end;

  pMeasGrpList     = ^tMeasGrpList;
  tMeasGrpList     = Object(TSortedCollection)
    PathMask       : PathStr;
    Path           : PathStr;
    Mask           : String12;
    MaskLeft       : String12;
    MaskRight      : String12;
    MaskGrpLen     : Smallint;
    NumSlicesAll   : Smallint;
    NumSlicesDone  : Smallint; {Already done slices}  {20.03.01 P.W}
    NumGroups      : Smallint;
    NumRefLines    : Smallint;
    MyRefArr       : tRefLineArr;                     {14.04.97 P.W}
    MyGrpRefNo     : Array[1..MaxMeasGrp] of Smallint; {14.04.97 P.W}
    RefFlg         : Boolean;                         {01.04.97 P.W}
    Status         : Smallint;         {22.06.99 P.W}
    Function    CheckIntegrity: Smallint;                             virtual;
    Constructor Init(I_PathMask: PathStr; I_RefFlg: Boolean);
    Destructor  Done;                                                virtual;
    Function    Compare(Key1, Key2: Pointer): Smallint;               virtual;
    Function    NameOfGrp(Grp: Smallint): PathStr;                    virtual;
    Function    NameOfSlice (SliceNo: Smallint): PathStr;             virtual;
    Function    MeasGrpsToSvHead
                  (Var SvHead: THeadRec;
                   LockedMeasGrps: Smallint): Smallint;                virtual;
    Function    SvHeadToMeasGrps(Const SvHead: THeadRec): Smallint;   virtual;
    function    GetSlicePositions: TDoubArrArr;
    function    GetVoxelSizes: TDoubArr;
    function    GetDistRefSliceInfoArr: tDistRefSliceInfoArr; // 29.06.09 P.W
    function    GetQaFlg: Boolean;                            // 24.08.09 P.W
  end;

Implementation

uses SysUtils;
  const Unit_Name = 'XMeasGrp'; // 03.05.24 P.W

(*.**************************************************************************)
(** Function Name    : SplitMask                                          **)
(** Author           : P.Wueseke                                          **)
(** Date             : 21.03.97                                           **)
(** Description      : DETCT??.REC -> DETCT .REC 2                        **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            : Mask, MaskLeft, MaskRight, MaskGrpLen              **)
(** Output           : Mask, MaskLeft, MaskRight                          **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : ?                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function SplitMask (Var Mask, MaskLeft, MaskRight : String12;
                    Var MaskGrpLen: Smallint): Smallint;
Const
  NameLen = 8;
  ExtLen  = 3;
Var
  Res              : Smallint;
  P                : Smallint;
  Mode             : Smallint;
  MaskPart         : String12;
  Ch               : Char;
begin  {Func. SplitMask}
  Res:=0;

  MaskLeft   := '';
  MaskPart   := '';
  MaskRight  := '';
  Mode       := -1;

  For P:=1 to Length(Mask) do
  begin
    Ch:=Mask[P];
    If (Ch = '?')
      then Mode:=0
      else if Mode=0 then Mode:=1;

    Case Mode of
      -1: MaskLeft  := MaskLeft  + Ch;
       0: MaskPart  := MaskPart  + Ch;
       1: MaskRight := MaskRight + Ch;
    end;
  end;
  MaskGrpLen:=Length(MaskPart);
  SplitMask:=Res;
end;   {Func. SplitMask}

Type
  tLoad_Save = (Load, SaveExist, SaveRewrite);
(*.**************************************************************************)
(** Function Name    : BlockLoad_Save                                     **)
(** Author           : P.Wueseke                                          **)
(** Date             : 20.03.97                                           **)
(** Description      : Reads or writes data                               **)
(** Description      : Mode Load & SaveExist: file must exist!            **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            : Name, Mode, Buf, Pos1, NumBytes, ErrMode           **)
(** Output           : Buf, Pos1                                          **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : 22.06.99 / P.Wueseke                               **)
(** Date/Modification: 17.04.97 P.W / Sup. Load, SaveRewrite, SaveExist   **)
(** Date/Modification: 22.06.99 P.W / Support FileMode_ReadOnly           **)
(**************************************************************************.*)
Function BlockLoad_Save
  (Name: PathStr;
   Mode: tLoad_Save;
   Var Buf;
   Pos1: LongInt;
   NumBytes: Word;
   ErrMode: Smallint): Smallint;
Var
  Res, ResH        : Smallint;
  InpOut           : File;
  ReadedWritten    : LongInt; //Word;
  FileModeSav      : Word; {22.06.99 P.W}
begin  {Func. BlockLoad_Save}
  Res:=0;
  {$I-}
    If (Mode=Load) then Fillchar(Buf, NumBytes, #0);

    assign(InpOut, FExpand(Name)); // FExpand added (04.03.04 P.W)
    Case Mode of
      Load,
      SaveExist:
        begin
          FileModeSav:=FileMode;                            {22.06.99 P.W}
          If (Mode=Load) then FileMode:=FileMode_ReadOnly;  {22.06.99 P.W}
                              {otherwise READONLY files may not be read}
          reset  (InpOut, 1);
          FileMode:=FileModeSav;                            {22.06.99 P.W}
            ResH:=IoResult; if (Res=0) then Res:=ResH;
          If (Res=0) then Seek(InpOut, Pos1);
            ResH:=IoResult; if (Res=0) then Res:=ResH;
        end;
      SaveRewrite:
        begin
          rewrite(InpOut, 1);
            ResH:=IoResult; if (Res=0) then Res:=ResH;
        end;
    end;

    Case Mode of
      Load:
        begin
          if (Res=0) then BlockRead (InpOut, Buf, NumBytes, ReadedWritten);
            ResH:=IoResult; if (Res=0) then Res:=ResH;
            If (Res=0) and (NumBytes<>ReadedWritten) then Res:=Err_DiskRead;
        end;
      SaveExist,
      SaveRewrite:
        begin
          if (Res=0) then BlockWrite(InpOut, Buf, NumBytes, ReadedWritten);
            ResH:=IoResult; if (Res=0) then Res:=ResH;
            If (Res=0) and (NumBytes<>ReadedWritten) then Res:=Err_DiskWrite;
        end;
    end;

    close(InpOut);
      ResH:=IoResult; if (Res=0) then Res:=ResH;
  {$I+}
  If (ErrMode=0) and (Res<>0) then
  begin
    Writeln('Program: ', Param_Str(0));
    Writeln('XMeasGrp BlockLoad_Save Error: ', Res:3);
    Writeln('File: ', Name);
    Writeln('Please press ENTER to abort ...');
    Readln;
  end;
  BlockLoad_Save:=Res;
end;   {Func. BlockLoad_Save}

{--------------------------------------------------------------------}
{--------------------------------------------------------------------}


(* "FEMUR" {11.03.97 P.W}
  Header of DetRecType_Fem contains:
    SliceStart    [mm]
    SliceDist     [mm]
    NumSlices     [1]
    SliceNoGrp    [1]
    Percent       [% of ObjLen] or [mm] {depends on DistFlg}
    DistFlg       {true: Percent [mm]; false: Percent [% of ObjLen]}
    AsymFlg       {true:  MeasLine id. to SliceStart;
                  {false: MeasLine id. to center of slices}

    1) AsymFlg = true
    ^
    ¦                - - - - - - - - - - - - - - - RefPos //OemToAnsi Chg#1787 (02.03.04 P.W)
    ¦ //OemToAnsi Chg#1786 (02.03.04 P.W)
    ¦ //OemToAnsi Chg#1785 (02.03.04 P.W)
    ¦ (SliceStart)   -------------- SliceNoGrp 1 - - - MeasPos //OemToAnsi Chg#1784 (02.03.04 P.W)
    ¦                                                       Slices not sym. //OemToAnsi Chg#1783 (02.03.04 P.W)
    ¦                -------------- SliceNoGrp 2 //OemToAnsi Chg#1782 (02.03.04 P.W)
    + //OemToAnsi Chg#1781 (02.03.04 P.W)

    2) AsymFlg = false
    ^
    ¦                - - - - - - - - - - - - - - - RefPos //OemToAnsi Chg#1780 (02.03.04 P.W)
    ¦ //OemToAnsi Chg#1779 (02.03.04 P.W)
    ¦ //OemToAnsi Chg#1778 (02.03.04 P.W)
    ¦ (SliceStart)   -------------- SliceNoGrp 1 //OemToAnsi Chg#1777 (02.03.04 P.W)
    ¦                - - - - - - - - - - - - - - - MeasPos  Slices symmetric //OemToAnsi Chg#1776 (02.03.04 P.W)
    ¦                -------------- SliceNoGrp 2 //OemToAnsi Chg#1775 (02.03.04 P.W)
    + //OemToAnsi Chg#1774 (02.03.04 P.W)




  The following set of functions shall support the use of the header:
    Fem_SlicePos
    Fem_DistMeasRef
    Fem_RefPos
    Fem_MeasPos
  Special use:
    Fem_CalcSliceStart  {to find out the value to enter into header}
*)

(*.**************************************************************************)
(** Function Name    : Fem_SlicePos                                       **)
(** Author           : P.Wueseke                                          **)
(** Date             : 11.03.97                                           **)
(** Description      : Calculate the  SlicePos                  [mm]      **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : DR, HelpSliceNo                                    **)
(** Output           : RETURN (Single): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : 20.03.97 / P.Wueseke                               **)
(** Date/Modification: 20.03.97 P.W / HelpSliceNo: if SliceNoGrp is zero  **)
(** Date/Modification: 20.03.97 P.W + then use HelpSliceNo                **)
// Modifications:
// 20.12.06 P.W: use GetSliceNoGrp
(**************************************************************************.*)
function Fem_SlicePos_SliceNoGrp(const DR: DetRecType_Fem; const SliceNoGrp: SmallInt): Single;
// 13.01.09 P.W: part of Fem_Slice_Pos as code: use SliceNo in each case
begin
  Result := DR.SliceStart + DR.SliceDist * (SliceNoGrp - 1);
end;
Function Fem_SlicePos (Const DR: DetRecType_Fem;
                       Const HelpSliceNo: Smallint): Single;
Var
  Loc_SliceNoGrp   : Smallint;
begin  {Func. Fem_SlicePos}
  With DR do
  begin
    {v--- until 20.12.06 P.W ---
      If SliceNoGrp=0 then Loc_SliceNoGrp:=HelpSliceNo
                      else Loc_SliceNoGrp:=SliceNoGrp;
    {^--- until 20.12.06 P.W ---}
    {v--- since 20.12.06 P.W ---}
      Loc_SliceNoGrp := GetSliceNoGrp(DR);
      If Loc_SliceNoGrp=0 then
        Loc_SliceNoGrp:=HelpSliceNo;
    {^--- since 20.12.06 P.W ---}
    //Fem_SlicePos:=SliceStart + SliceDist * (Loc_SliceNoGrp - 1);
    Fem_SlicePos := Fem_SlicePos_SliceNoGrp(DR, Loc_SliceNoGrp); // use code as function: 13.01.09 P.W
  end;  {With DR}
end;   {Func. Fem_SlicePos}

(*.**************************************************************************)
Function Fem_GrpNo
  (
  Const DR: DetRecType_Fem  { I - slice header record }
  ): Smallint; {10.04.97 MW}
(***************************************************************************
Date/Author      : {10.04.97 MW}
Description      : Returns the number of the group
***************************************************************************
return           : number of group
heap             :
Global Variables
 - affected      :
 - predefined    :
***************************************************************************
Date/Modification:
**************************************************************************.*)
begin
  If DR.GroupNo=0 Then
     Fem_GrpNo:=1
  else
     Fem_GrpNo:=DR.GroupNo;
end;
(*.**************************************************************************)
(** Function Name    : Fem_DistMeasRef                                    **)
(** Author           : P.Wueseke                                          **)
(** Date             : 11.03.97                                           **)
(** Description      : Calculate the Distance Meas to Reference line [mm] **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : DR                                                 **)
(** Output           : RETURN (Single): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function Fem_DistMeasRef (Const DR: DetRecType_Fem): Single;
begin  {Func. Fem_DistMeasRef}
  With DR do
    If DistFlg then Fem_DistMeasRef:= Percent
               else Fem_DistMeasRef:= 0.01 * Percent * ObjLen;
end;   {Func. Fem_DistMeasRef}

(*.**************************************************************************)
(** Function Name    : Fem_RefPos                                         **)
(** Author           : P.Wueseke                                          **)
(** Date             : 11.03.97                                           **)
(** Description      : Calculate the Position of Reference line [mm]      **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Fem_DistMeasRef                                    **)
(** Input            : DR                                                 **)
(** Output           : RETURN (Single): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
function DistSliceStartMeasPos(Const DR: DetRecType_Fem): Double;
// 29.06.09 P.W
// codepart used in Fem_RefPos and Fem_CalcSliceStart as function
begin
  if DR.AsymFlg
    then Result := 0.0
    else Result := 0.5 * (DR.NumSlices-1) * DR.SliceDist;
end;
Function Fem_RefPos (Const DR: DetRecType_Fem): Single;
// Modifications:
// 29.06.09 P.W use DistSliceStartMeasPos
begin  {Func. Fem_RefPos}
//  With DR do
//    If AsymFlg then Fem_RefPos:= SliceStart - Fem_DistMeasRef(DR)
//               else Fem_RefPos:= SliceStart - Fem_DistMeasRef(DR)
//                                            + 0.5 * (NumSlices-1) * SliceDist;
  Result := DR.SliceStart - Fem_DistMeasRef(DR) + DistSliceStartMeasPos(DR); // 29.06.09 P.W
end;   {Func. Fem_RefPos}

(*.**************************************************************************)
(** Function Name    : Fem_MeasPos                                        **)
(** Author           : P.Wueseke                                          **)
(** Date             : 11.03.97                                           **)
(** Description      : Calculate the measurement line position [mm]       **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Fem_RefPos, Fem_DistMeasRef                        **)
(** Input            : DR                                                 **)
(** Output           : RETURN (Single): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function Fem_MeasPos (Const DR: DetRecType_Fem): Single;
begin  {Func. Fem_MeasPos}
  Fem_MeasPos := Fem_RefPos(DR) + Fem_DistMeasRef(DR);
end;   {Func. Fem_MeasPos}

(*.**************************************************************************)
(** Function Name    : Fem_CalcSliceStart                                 **)
(** Author           : P.Wueseke                                          **)
(** Date             : 11.03.97                                           **)
(** Description      : Calculate the start of the slice [mm]              **)
(** Description      : only for use by XbJob.exe SvComp.exe !             **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : DR, RefPos                                         **)
(** Output           : RETURN (Single): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function Fem_CalcSliceStart (
           Const DR: DetRecType_Fem; Const RefPos: Single): Single;
// Modifications:
// 29.06.09 P.W use DistSliceStartMeasPos
begin  {Func. Fem_CalcSliceStart}
//  With DR do
//    If AsymFlg then Fem_CalcSliceStart := RefPos + Fem_DistMeasRef(DR)
//               else Fem_CalcSliceStart := RefPos + Fem_DistMeasRef(DR)
//                                          - 0.5 * (NumSlices-1) * SliceDist;
  Result := RefPos + Fem_DistMeasRef(DR) - DistSliceStartMeasPos(DR); // 29.06.09 P.W
end;   {Func. Fem_SliceStart}

{--------------------------------------------------------------------}
{-- Object tMeasGrpObj ----------------------------------------------}
{--------------------------------------------------------------------}
Constructor tMeasGrpObj.Init(Const I_Name: PathStr);
Var
  Res              : Smallint;
begin {Const. Init}
  Inherited Init;
  {------------------------------------------------------------------}
  Res:=0;
  Name:=I_Name;
  Status:=0;                       {22.06.99 P.W}
  SliceOffset:=0;
  FirstMeasSlice:=1;               {16.04.97 P.W}
  Group:=0;
  If (Res=0) then Res:=LoadDRF;
  If (Status=0) then Status:=Res;  {22.06.99 P.W}
end;  {Const. Init}

Constructor tMeasGrpObj.CopyInit(
              Const I_Name: PathStr;
              Const I_Orig: pMeasGrpObj);
begin {Const. CopyInit}
  Inherited Init;
  {------------------------------------------------------------------}
  Name:=I_Name;
  Status:=0;                       {22.06.99 P.W}
  SliceOffset:=0;
  FirstMeasSlice:=1;               {16.04.97 P.W}
  Group:=0;
  DRF:=I_Orig^.DRF;
  If (Status=0) then Status:=I_Orig^.Status;          {22.06.99 P.W}
end;  {Const. CopyInit}

Destructor  tMeasGrpObj.Done;
begin {Dest. Done}

  {------------------------------------------------------------------}
  Inherited Done;
end;  {Dest. Done}

(*.**************************************************************************)
(** Function Name    : LoadDRF                                            **)
(** Author           : P.Wueseke                                          **)
(** Date             : 17.04.97                                           **)
(** Description      :  Load DRF                                          **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : BlockLoad_Save                                     **)
(** Input            : -                                                  **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : 22.06.99 / P.Wueseke                               **)
(** Date/Modification: 22.06.99 P.W / Return result of BlockLoad_Save     **)
(**************************************************************************.*)
Function    tMeasGrpObj.LoadDRF: Smallint;
Var
  Res              : Smallint;
begin  {Func. LoadDRF}
  If (Pos('DETCT', Name) > 0)
    then Res:=BlockLoad_Save(Name, Load, DRF,            0, SizeOf(DRF), 0)
    else Res:=BlockLoad_Save(Name, Load, DRF, SizHeadPart1, SizeOf(DRF), 0);
         {^-- 2x "Res:=": 22.06.99 P.W}

  LoadDRF:=Res;
end;   {Func. LoadDRF}

(*.**************************************************************************)
(** Function Name    : StoreDRF                                           **)
(** Author           : P.Wueseke                                          **)
(** Date             : 17.04.97                                           **)
(** Description      :   Store DRF                                        **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : BlockLoad_Save                                     **)
(** Input            : -                                                  **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function    tMeasGrpObj.StoreDRF: Smallint;
Var
  Res              : Smallint;
begin  {Func. StoreDRF}
  Res:=0;
  If (Pos('DETCT', Name) > 0)
    then BlockLoad_Save(Name, SaveRewrite, DRF,            0, SizeOf(DRF), 0)
    else BlockLoad_Save(Name, SaveExist,   DRF, SizHeadPart1, SizeOf(DRF), 0);

  StoreDRF:=Res;
end;   {Func. StoreDRF}

{--------------------------------------------------------------------}
{-- Object tMeasGrpList ---------------------------------------------}
{--------------------------------------------------------------------}
(*.**************************************************************************)
(** Function Name    : CheckIntegrity                                     **)
(** Author           : P.Wueseke                                          **)
(** Date             : 21.03.97                                           **)
(** Description      : Check that variables fit to content of list        **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            : -                                                  **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : ?                                                  **)
(***************************************************************************)
(** Last modified/By : 17.04.97 / P.Wueseke                               **)
(** Date/Modification: 14.04.97 P.W /Sup. NumRefLines,MyRefArr,MyGrpRefNo **)
(** Date/Modification: 17.04.97 P.W /RefMode: del empty ct files          **)
(**************************************************************************.*)
Function    tMeasGrpList.CheckIntegrity: Smallint;
  Function RefPosToMyRefArr(RefPos: Single): Smallint;      {14.04.97 P.W}
  Var
    Found          : Boolean;
    Ref            : Smallint;
  begin
    Found:=False;
    Ref:=1;
    While (not Found) and (Ref<=NumRefLines) do
      If Abs(RefPos - MyRefArr[Ref]) <= 0.001
        then Found:=True
        else Inc(Ref);

    If (not found) then
    begin
      Inc(NumRefLines);
      MyRefArr[NumRefLines]:=RefPos;
    end;
    RefPosToMyRefArr:=Ref;
  end;

Var
  Res              : Smallint;
  Ctr              : Smallint;
  SR               : SearchRec;   {16.04.97 P.W}
  SliceNoLoc       : Smallint;     {16.04.97 P.W}
  HName            : PathStr;     {17.04.97 P.W}
begin  {Func. CheckIntegrity}
  Res:=0;
  NumSlicesAll   := 0;
  NumSlicesDone  := 0;            {20.03.01 P.W}
  NumGroups      := 0;
  NumRefLines    := 0;
  FillChar(MyRefArr, SizeOf(MyRefArr), #0);

  For Ctr:=0 to Count-1 do       {Ctr = Counter of Groups}
  begin
    Inc(NumGroups);
    pMeasGrpObj(At(Ctr))^.SliceOffset:=NumSlicesAll;
       {NumSlices: is here the Sum of all Slices of previous groups}

    With pMeasGrpObj(At(Ctr))^ do                       {16.04.97 P.W}
    begin
      If RefFlg then
      begin
        { find missing slices: }
        { search from top and reject all files which are missing or too small}
        { erases files that are too small}
        { search stops if a file is ok, the below are not checked!}
        SliceNoLoc := DRF.NumSlices; {Number of slices wanted by cur. group}
        DosError   := 2;
        While (DosError  <> 0) and
              (SliceNoLoc > 1) do    {don't check first slice again}
        begin
          HName := NameOfSlice(SliceNoLoc+SliceOffset);
          FindFirstDE(HName, AnyFile, SR);
          ChkFindClose(SR); // ChkFindClose (05.03.04 P.W)
          If (DosError=0) and (SR.Size<CT_FS_LimitDelete) then {17.04.97 P.W}
          begin {Del empty Ct files:}
            Eraser(HName);
            DosError:=2;
          end;
          If (DosError <> 0) then Dec(SliceNoLoc);  {Slice not found}
        end;
        FirstMeasSlice := SliceNoLoc + 1;
        Inc(NumSlicesDone, SliceNoLoc);             {20.03.01 P.W}
      end else
      begin
        FirstMeasSlice:=1;  {if not RefFlg: all slices ought to be measured}
      end;
    end;

    pMeasGrpObj(At(Ctr))^.Group:=NumGroups;
    Inc(NumSlicesAll, pMeasGrpObj(At(Ctr))^.DRF.NumSlices);

    MyGrpRefNo[NumGroups]:=
    RefPosToMyRefArr(Fem_RefPos(pMeasGrpObj(At(Ctr))^.DRF));   {14.04.97 P.W}
  end;

  CheckIntegrity:=Res;
end;   {Func. CheckIntegrity}

(*.**************************************************************************)
(** Constructor Name : tMeasGrpList.Init                                  **)
(** Author           : P.Wueseke                                          **)
(** Date             : 01.04.97                                           **)
(** Description      : Init the object, Supposes Sv and Ct in same        **)
(** Description      : directory if I_RefFlg is true and than name of     **)
(** Description      : Sv and Ct files may differ only by "S" and "C"     **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Called By        : Scans.ShowStatusMG        (RefFlg=False)           **)
(** Called By        : FemSvIo.UpDate__          (RefFlg=False)           **)
(** Called By        : FemSvIo.TFemSvToBnSv.Init (RefFlg=False/TRUE)      **)
(** Called By        : FemPrep                   (RefFlg=False/TRUE)      **)
(** Calls            : FSplit, FindFirst, Eraser, SplitMask,              **)
(** Calls            : CheckIntegrity                                     **)
(** Input            : I_PathMask, I_RefFlg                               **)
(** Output           : Initialised object                                 **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : 22.06.99 / P.Wueseke                               **)
(** Date/Modification: 01.04.97 P.W / Supp. RefFlg                        **)
(** Date/Modification: 17.04.97 P.W / RefFlg: only Ct>CT_FS_LimitDelete   **)
(** Date/Modification: 02.09.97 P.W / Correction: sup. also SR0.M01 names **)
(** Date/Modification: 22.06.99 P.W / Sup. Status                         **)
(**************************************************************************.*)
Constructor tMeasGrpList.Init(I_PathMask: PathStr; I_RefFlg: Boolean);
  (*.**************************************************************************)
  (** Function Name    : CtMaskFromSvName                                   **)
  (** Author           : P.Wueseke                                          **)
  (** Date             : 02.09.97                                           **)
  (** Description      : Make C:\INTER\SR0.M01 to C:\INTER\CR0.M??          **)
  (** Description      : or   C:\...\S#######.M01 to C:\...\C#######.M??    **)
  (***************************************************************************)
  (** Called By        : any                                                **)
  (** Calls            : FExppand, FSplit                                   **)
  (** Input            : SvName                                             **)
  (** Output           : RETURN (PathStr): Ret                              **)
  (** Global Variables                                                      **)
  (**  - affected      : -                                                  **)
  (**  - predefined    : -                                                  **)
  (***************************************************************************)
  (** Last modified/By : -                                                  **)
  (** Date/Modification: -                                                  **)
  // Modifications
  // 20.12.06 P.W use SliceNrNamePartMask
  (**************************************************************************.*)
  Function CtMaskFromSvName (SvName: PathStr): PathStr;
  Var
    DStr           : DirStr;
    NStr           : NameStr;
    EStr           : ExtStr;
  begin  {Func. CtMaskFromSvName}
    FSplit(FExpand(SvName), DStr, NStr, EStr);
    NStr[1]:='C';
    EStr := SliceNrNamePartMask; // replaces EStr[3]:='?'; EStr[4]:='?'; 20.12.06 P.W
    CtMaskFromSvName:=DStr+NStr+Estr;
  end;   {Func. CtMaskFromSvName}

Var
  DStr             : DirStr;
  NStr             : NameStr;
  EStr             : ExtStr;
  SR               : SearchRec;
//  Len              : Smallint;
  SliceNoLoc       : Smallint;
{ h:String;}
begin {Const. Init}
  Inherited Init(5, 2);
  RefFlg         := I_RefFlg;       {01.04.97 P.W}
  Status         := 0;              {22.06.99 P.W}
  {------------------------------------------------------------------}
  //Len:=Length(I_PathMask);
  If RefFlg {and ( Len >= NameExtLen ) }{u. 02.09.97 P.W} then
  begin
    (* {u. 02.09.97 P.W}
    {expected:  I_PathMask  is like 'C:\XCT540\AV002\A0020000\S0020001.M01'}

    {but also   'C:\XCT540\INTER\SR0.M01' occur! (if exported measurement)}
    {^-- 02.09.97 P.W}

    PathMask := I_PathMask;
    PathMask [Len -              0] := '?';    {-> S#######.M0?}
    PathMask [Len -              1] := '?';    {-> S#######.M??}
    PathMask [Len - Name ! ExtLen + 1] := 'C';    {-> C#######.M??}
    *)
    PathMask:=CtMaskFromSvName(I_PathMask);
  end else
  begin
    PathMask := MaskDetCtRec;
  end;
  FSplit(PathMask, DStr, NStr, EStr);
  Path            := DStr;
  Mask            := NStr+EStr;
  SplitMask(Mask, MaskLeft, MaskRight, MaskGrpLen);
  {------------------------------------------------------------------}
  If RefFlg then    {also used for find what has already been measured}
  begin  {Sequence of slices may not be interrupted!}
    SliceNoLoc:=1;
    FindFirstDE(NameOfSlice(SliceNoLoc), AnyFile, SR);
    ChkFindClose(SR); // ChkFindClose (05.03.04 P.W)
{ h:=NameOfSlice(SliceNoLoc);}
    While (DosError = 0) and (Status = 0) do {Size: 17.04.97 P.W}
                             {^-- Status: 22.06.99 P.W}
    begin
      If (SR.Size < CT_FS_LimitDelete) then {if: 17.04.97 P.W}
      begin {Del empty Ct files:}               {17.04.97 P.W}
        Eraser(NameOfSlice(SliceNoLoc));
        DosError:=2;
      end else
      begin
        Insert(New(pMeasGrpObj, Init(Path+SR.Name)));
        if (Status=0) then Status:=pMeasGrpObj(At(Count-1))^.Status;{22.06.99 P.W}
        Inc(SliceNoLoc, pMeasGrpObj(At(Count-1))^.DRF.NumSlices);
        FindFirstDE(NameOfSlice(SliceNoLoc), AnyFile, SR);
        ChkFindClose(SR); // ChkFindClose (05.03.04 P.W)
      end;
    end;
  end else
  begin
    FindFirstDE(PathMask, AnyFile, SR);
    While (DosError = 0) do
    begin
      if (SR.Name<>'DETCT.REC') then
      begin
        Insert(New(pMeasGrpObj, Init(Path+SR.Name)));
        if (Status=0) then Status:=pMeasGrpObj(At(Count-1))^.Status;{22.06.99 P.W}
      end;
      FindNextDE(SR);
    end;
    ChkFindClose(SR); // ChkFindClose (05.03.04 P.W)
  end;
  {------------------------------------------------------------------}
  CheckIntegrity;
  {------------------------------------------------------------------}
end;  {Const. Init}

Destructor  tMeasGrpList.Done;
begin {Dest. Done}

  {------------------------------------------------------------------}
  Inherited Done;
end;  {Dest. Done}

Function    tMeasGrpList.Compare(Key1, Key2: Pointer): Smallint;
begin {Func. Compare}
  If pMeasGrpObj(Key1)^.Name
     <
     pMeasGrpObj(Key2)^.Name then Compare:=-1
  else
  If pMeasGrpObj(Key1)^.Name
     =
     pMeasGrpObj(Key2)^.Name then Compare:= 0
  else                            Compare:= 1;
end;  {Func. Compare}

(*.**************************************************************************)
(** Function Name    : NameOfGrp                                          **)
(** Author           : P.Wueseke                                          **)
(** Date             : 21.03.97                                           **)
(** Description      : Returns the name of a group file                   **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            : Grp                                                **)
(** Output           : RETURN (PathStr): NameOfGrp                        **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : ?                                                  **)
(***************************************************************************)
// modifications:
(**************************************************************************.*)
Function    tMeasGrpList.NameOfGrp (Grp: Smallint): PathStr;
begin  {Func. NameOfGrp}
  NameOfGrp := Path + MaskLeft + InvValHex(Grp, MaskGrpLen) + MaskRight;
end;   {Func. NameOfGrp}

(*.**************************************************************************)
(** Function Name    : NameOfSlice                                        **)
(** Author           : P.Wueseke                                          **)
(** Date             : 01.04.97                                           **)
(** Description      : Returns the name of a slice file                   **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : SliceNrToNamePart                                  **)
(** Input            : SliceNo                                            **)
(** Output           : RETURN (PathStr): NameOfSlice                      **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : ?                                                  **)
(***************************************************************************)
// modifications:
// 20.12.06 P.W use SliceNrToNamePart and no longer NameOfGrp
(**************************************************************************.*)
Function    tMeasGrpList.NameOfSlice (SliceNo: Smallint): PathStr;
begin  {Func. NameOfSlice}
//NameOfSlice := NameOfGrp(SliceNo);   // until 20.12.06 P.W
  Result := Path + ChangeFileExt(MaskLeft, '')+ SliceNrToNamePart(SliceNo); // since 20.12.06 P.W
end;   {Func. NameOfSlice}

(*.**************************************************************************)
(** Function Name    : MeasGrpsToSvHead                                   **)
(** Author           : P.Wueseke                                          **)
(** Date             : 21.03.97                                           **)
(** Description      : Transfer all meas groups to sv header              **)
(** Description      : If LockedMeasGrps > 0: Locked Grps are unchanged   **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            : SvHead                                             **)
(** Output           : SvHead                                             **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : ?                                                  **)
(***************************************************************************)
(** Last modified/By : 22.06.99 / P.Wueseke                               **)
(** Date/Modification: 07.04.97 P.W / Correct AT(1) -> AT(0)              **)
(** Date/Modification: 14.04.97 P.W / Use MyRefArr, MyGrpRefNo            **)
(** Date/Modification: 16.04.97 P.W / Improved Support of DoAddGrp        **)
(** Date/Modification: 16.04.97 P.W + new parameter : LockedMeasGrps      **)
(** Date/Modification: 22.06.99 P.W / Sup. ObjectLen <-> PatObjLen        **)
(**************************************************************************.*)
Function    tMeasGrpList.MeasGrpsToSvHead
              (Var SvHead: THeadRec;
              LockedMeasGrps: Smallint): Smallint;  {L.: 16.04.97 P.W}
Var
  Res              : Smallint;
  Ctr              : Smallint;
  Grp              : Smallint;
begin  {Func. MeasGrpsToSvHead}
  Res:=0;

  If (LockedMeasGrps=0) then                 {If: 16.04.97 P.W}
  begin
    SvHead.RefArr      := MyRefArr;          {14.04.97 P.W}
  end else
  begin                                      {16.04.97 P.W}
    If (SvHead.NumRefLines < 1) then SvHead.NumRefLines:=1;
    For Ctr:=SvHead.NumRefLines+1 to MaxRefLine do
      SvHead.RefArr[Ctr] := MyRefArr[Ctr];
  end;

  SvHead.NumRefLines   := NumRefLines;       {14.04.97 P.W}

  SvHead.NumMeasGroups := NumGroups;

  If Count>0 then
  begin
    {07.04.97 P.W: At(1) -> At(0) (2*):}
    SvHead.SlicesSymFlg  := not pMeasGrpObj(At(0))^.DRF.AsymFlg;
    SvHead.PercentFlg    := not pMeasGrpObj(At(0))^.DRF.DistFlg;
    SvHead.PatObjLen     :=     pMeasGrpObj(At(0))^.DRF.ObjLen; {22.06.99 P.W}
  end else
  begin
    SvHead.NumRefLines               := 1;
    SvHead.NumMeasGroups             := 1;
    SvHead.SlicesSymFlg              := False;
    SvHead.PercentFlg                := False;
    SvHead.RefArr    [1]             := 0;
    SvHead.MeasGrpArr[1].RefLineNo   := 1;
    SvHead.MeasGrpArr[1].PercDist    := 0;
    SvHead.MeasGrpArr[1].NumSlicesGrp:= 1;
    SvHead.MeasGrpArr[1].SliceDistGrp:= 1;
  end;

  For Ctr:=LockedMeasGrps to Count-1 do {0->LockedMeasGrps: 16.04.97 P.W}
  begin
    Grp:=Ctr+1;
    SvHead.MeasGrpArr[Grp].RefLineNo:=MyGrpRefNo[Grp];   {My.: 14.04.97 P.W}
    SvHead.MeasGrpArr[Grp].PercDist:=
      pMeasGrpObj(At(Ctr))^.DRF.Percent;
    SvHead.MeasGrpArr[Grp].NumSlicesGrp:=
      pMeasGrpObj(At(Ctr))^.DRF.NumSlices;
    SvHead.MeasGrpArr[Grp].SliceDistGrp:=
      pMeasGrpObj(At(Ctr))^.DRF.SliceDist;
(*v* )
GrpRef:=SvHead.MeasGrpArr[Grp].RefLineNo;
writeln('Program: "', Fexpand(Param_Str(0)) ,'"');
write  ('   --- XMEASGRP MeasGrpsToSvHead: ---');
writeln('PathMask              :"', PathMask, '"');
writeln('Grp                   :', Grp:5, '   ');
writeln('GrpRef                :', GrpRef:5);
writeln('SvHead.RefArr[GrpRef] :', SvHead.RefArr[GrpRef]:8:2);
writeln('Calc RefPos           :', Fem_RefPos(pMeasGrpObj(At(Ctr))^.DRF):8:2);
Readln;
(*^*)
  end;
  MeasGrpsToSvHead:=Res;
end;   {Func. MeasGrpsToSvHead}

(*.**************************************************************************)
(** Function Name    : SvHeadToMeasGrps                                   **)
(** Author           : P.Wueseke                                          **)
(** Date             : 21.03.97                                           **)
(** Description      : transfer all measgroups from sv header             **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            : SvHead                                             **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : ?                                                  **)
(***************************************************************************)
(** Last modified/By : 17.04.97 / P.Wueseke                               **)
(** Date/Modification: 07.04.97 P.W / Use IoTools.Eraser instead of       **)
(** Date/Modification: 07.04.97 P.W / DirTools.TryErase                   **)
(** Date/Modification: 17.04.97 P.W / Use StoreDRF                        **)
(** Date/Modification: 22.06.99 P.W / Sup. ObjectLen <-> PatObjLen        **)
(**************************************************************************.*)
Function    tMeasGrpList.SvHeadToMeasGrps (Const SvHead: THeadRec): Smallint;
Var
  Res              : Smallint;
  Ctr              : Smallint;
  Grp              : Smallint;
  pMGO             : pMeasGrpObj;  // 25.10.04 P.W.
  pDRF             : ^DetRecType_Fem;
begin  {Func. SvHeadToMeasGrps}
  Res:=0;
  For Grp:=1 to SvHead.NumMeasGroups do
  begin
    Ctr:=Grp-1;
    {----------------------------------------------------------------}
    {--- in case of some additional measgroups: ---}
    If (Ctr=Count) and (Ctr>0) then
      Insert(New(pMeasGrpObj, CopyInit(NameOfGrp(Grp),
                                       pMeasGrpObj(At(Ctr-1)))));
    {----------------------------------------------------------------}
    {--- now transfer the measgroup to pMeasGrpObj(At(Ctr-1))^: ---}
    // pDRF := Addr(pMeasGrpObj(At(Ctr))^.DRF);   // u.: 25.10.04 P.W.
    pMGO := At(Ctr);          // s.: 25.10.04 P.W. (may be nil in case of missing files)
    if Assigned(pMGO) then    // if: 25.10.04 P.W.
    begin
      pDRF := Addr(pMGO^.DRF);

      pDRF^.AsymFlg    := not SvHead.SlicesSymFlg;
      pDRF^.DistFlg    := not SvHead.PercentFlg;
      pDRF^.ObjLen     :=     SvHead.PatObjLen;   {22.06.99 P.W}
      pDRF^.Percent    :=     SvHead.MeasGrpArr[Grp].PercDist;
      pDRF^.NumSlices  :=     SvHead.MeasGrpArr[Grp].NumSlicesGrp;
      pDRF^.SliceDist  :=     SvHead.MeasGrpArr[Grp].SliceDistGrp;
      pDRF^.SliceStart := Fem_CalcSliceStart(pDRF^,
                              SvHead.RefArr[
                              SvHead.MeasGrpArr[Grp].RefLineNo
                                           ]);
    end;
    {----------------------------------------------------------------}
  end;
  {------------------------------------------------------------------}
  {--- in case of some deleted measgroups: ---}
  While (Count > Integer(SvHead.NumMeasGroups)) do
  begin
    Eraser( pMeasGrpObj(At(Count-1))^.Name );
      {^- TryErase -> Eraser: 07.04.97 P.W}
    AtFree(Count-1);
  end;
  {------------------------------------------------------------------}
  CheckIntegrity;

  {------------------------------------------------------------------}
  For Ctr:=0 to (Count-1) do
    If (Res=0) then Res:=pMeasGrpObj(At(Ctr))^.StoreDRF;
  {------------------------------------------------------------------}

  SvHeadToMeasGrps:=Res;
end;   {Func. SvHeadToMeasGrps}

function    tMeasGrpList.GetSlicePositions: TDoubArrArr;
// 13.01.09 P.W
var
  G, NumSl, S : Integer;
  pDR: pDetRec;
begin
  SetLength(Result, Count);
  for G := 0 to Count -1 do
  begin
    pDR := @pMeasGrpObj(At(G))^.DRF;
    NumSl := pDR.NumSlices;
    SetLength(Result[G], NumSl);
    for S := 0 to NumSl -1 do
      Result[G][S] := Fem_SlicePos_SliceNoGrp(pDR^, S+1);
  end;
end;

function    tMeasGrpList.GetVoxelSizes: TDoubArr;
// 13.01.09 P.W
var
  G  : Integer;
  pDR: pDetRec;
begin
  SetLength(Result, Count);
  for G := 0 to Count -1 do
  begin
    pDR := @pMeasGrpObj(At(G))^.DRF;
    Result[G] := pDR.VoxelSize;
  end;
end;

function    tMeasGrpList.GetDistRefSliceInfoArr: tDistRefSliceInfoArr;
// 29.06.09 P.W
var
  G  : Integer;
  pDR: pDetRec;
begin
  SetLength(Result, Count);
  for G := 0 to Count -1 do
  begin
    pDR := @pMeasGrpObj(At(G))^.DRF;
    Result[G].DistRefFirstSlice := Fem_CalcSliceStart(pDR^, 0);
    Result[G].DistSlices        := pDR^.SliceDist;
    Result[G].NumSlices         := pDR^.NumSlices;
    Result[G].AsymFlg           := pDR^.AsymFlg;
    Result[G].RefPos            := Fem_RefPos(pDR^);
    Result[G].RefNr             := MyGrpRefNo[G+1];
  end;
end;

function    tMeasGrpList.GetQaFlg: Boolean;
// 24.08.09 P.W
var
  G  : Integer;
  pDR: pDetRec;
begin
  Result := False;
  for G := 0 to Count -1 do
  begin
    pDR := @pMeasGrpObj(At(G))^.DRF;
    Result := Result or pDR^.QaFlg;
  end;
end;




{--------------------------------------------------------------------}
{--------------------------------------------------------------------}
{--------------------------------------------------------------------}
{--------------------------------------------------------------------}
end.
