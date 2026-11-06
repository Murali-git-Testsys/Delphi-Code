// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
Unit ChkSum;
{$R-}
(*
  ChkSum calculation

  a) for Raw Data (SV or CT):
     1) ChkSum := 0 (Each time when BlockWriteSDR with ScanNo=1)
     2) for all blocks: AddChkSum
     3) AddChkSumDR (DetRec)
     4) AddChkSum (PatInfoRec)

  b) for Images (by CtFemNnD SaveImage)
     1) ChkSum := 0;
     2) AddChkSum(HeadPrefix)
     3) AddChkSumDR (DetRec);
     4) AddChkSum(PatInfoRec)
     5) AddChkSum(PicInfoRec)
     6) for all Lines AddChkSum(Line)

used:
FemCmd3.Pas  CheckProfile:
  support StoreDataChkSum(OutNameGlb, GlbChkSumRawData);
*)

Interface

Uses
  GlbType;

Const
  ChkSum_None      = 'NO CHECKSUM'; // 22.07.05 P.W // SVPLUS
  ChkSum_Beg       = 'C01(';
  ChkSum_End       = ')';
  ChkSum_Invalid   = '- invalid -';
  ChkSum_NotSupp   = '- not sup.-';

Type
  tChkSum          = LongInt;
  tLongArr         = Array[1..MaxWord div SizeOf(tChkSum)] of tChkSum;
  tByteArr         = Array[1..MaxWord                    ] of Byte   ;
  tTstChkSum       = (C_ChkSum_notsup, C_ChkSum_invalid,  C_ChkSum_Ok);

Procedure AddChkSum (Var ChkSum: tChkSum; Const Buf; Const NumBytes: Word);
Function  ChkSumEntry(Const aChkSum: tChkSum): String;
Function  ChkSumInvalidEntry: String;
Function  ChkSumNotSupportedEntry: String;
Function  TstChkSum(Const ChkSum: tChkSum; Const ChkEntry: String): tTstChkSum;
Function  GetTstChkSumMsg(Const TstChkSum: tTstChkSum): String;     {19.02.02 P.W}

Implementation
  const Unit_Name = 'ChkSum'; // 03.05.24 P.W

Procedure AddChkSum (Var ChkSum: tChkSum; Const Buf; Const NumBytes: Word);
Var
  W              : Word;
  LongLimit      : Word;
  BytesRemain    : Word;
  LocChkSum         : tChkSum;
begin
  LocChkSum := ChkSum;  {it is quicker to use a copy}
  {Steps of "SizeOf(tChkSum)" bytes:}
  LongLimit := NumBytes div SizeOf(tChkSum);
  For W:= 1 to LongLimit do
  begin
    LocChkSum:=LocChkSum XOR tLongArr(Buf)[W];
    if (LocChkSum > 0)
      then LocChkSum:= LocChkSum shl 1
      else LocChkSum:=(LocChkSum shl 1)+1;
  end;
  {Remaining Bytes:}
  BytesRemain := SizeOf(tChkSum) * LongLimit + 1;
  For W:= BytesRemain to NumBytes do
  begin
    LocChkSum:=LocChkSum XOR tByteArr(Buf)[W];

    if (LocChkSum > 0)
      then LocChkSum:= LocChkSum shl 1
      else LocChkSum:=(LocChkSum shl 1)+1;
  end;
  ChkSum := LocChkSum;
end;

Function  ChkSumEntry(Const aChkSum: tChkSum): String;
(*
{25.09.02 P.W}
Purpose:  Format the CheckSum to a "Message"
      {DataChkSum post DRChkSum (=Header ChkSum)}
*)
  Procedure Rotate(Var ChkSum: tChkSum);
  begin
    if (ChkSum > 0)
      then ChkSum:= ChkSum shl 1
      else ChkSum:=(ChkSum shl 1)+1;
  end;
Var
  ChkSum           : tChkSum;
  ChkSumB          : tChkSum;
  ChkTxt           : String;
  ChkTxtB          : String;
  A                : tChkSum;
  Procedure MixChkSum;
  begin
    ChkSum := ChkSum xor A;
    Rotate(ChkSum);
    ChkSumB := ChkSumB xor ChkSum;
    Rotate(ChkSumB);
    Rotate(ChkSumB);
    Rotate(A);
  end;
begin
  ChkSum := aChkSum;
  A:= 489;
  MixChkSum;
  ChkSumB := ChkSum;
  A:= A * 12345;           {! $R- !}
  MixChkSum;
  A:= A + 103705875;       {! $R- !}
  MixChkSum;

  Str(ChkSum : 11, ChkTxt);
  Str(ChkSumB: 11, ChkTxtB);

  ChkSumEntry:= ChkSum_Beg + ChkTxt + ChkTxtB  + ChkSum_End;
end;

Function  ChkSumInvalidEntry: String;
(*
  Mark the Chksum as invalid
*)
begin
  ChkSumInvalidEntry := ChkSum_Beg + ChkSum_Invalid + ChkSum_End;
end;

Function  ChkSumNotSupportedEntry: String;
(*
  Mark the Chksum as not supported
*)
begin
  ChkSumNotSupportedEntry := ChkSum_NotSupp;
end;

Function  TstChkSum(Const ChkSum: tChkSum; Const ChkEntry: String): tTstChkSum;
(*
{25.09.02 P.W}
*)
Var
  TstRes : tTstChkSum; {C_ChkSum_notsup, C_ChkSum_invalid,  C_ChkSum_Ok}
begin
  If (Pos(ChkSum_Beg, ChkEntry) = 1) then
  begin
    If (ChkSumEntry(ChkSum) = ChkEntry)
      then TstRes  := C_ChkSum_Ok
      else TstRes  := C_ChkSum_Invalid;
  end else
  begin
    TstRes := C_ChkSum_notsup;
  end;
  TstChkSum := TstRes;
end;

Function  GetTstChkSumMsg(Const TstChkSum: tTstChkSum): String;     {19.02.02 P.W}
begin
  Case TstChkSum of
    C_ChkSum_invalid: GetTstChkSumMsg := 'invalid'      ;
    C_ChkSum_Ok     : GetTstChkSumMsg := 'valid'        ;
    ELSE              GetTstChkSumMsg := 'not supported';
  end;
end;

end.
