// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; changes: 1; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; changes: 1; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
{$R-}
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Vers.: @(#)Tools.Pas V.:1.00                          )   +*)
(*+ Author           : P.Wueseke                                          +*)
(*+ Date             : 04.08.93                                           +*)
(*+ Description      : Glb Tools Project Femur...                         +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*+ Last modified/By : 26.04.99 / P.Wueseke                           :   +*)
(*+ Date/Modification: 27.07.94 P.W / IsHexTxt                            +*)
(*+ Date/Modification: 03.07.95 P.W / InvValD new                         +*)
(*+ Date/Modification: 07.04.97 P.W / Transfer Unit to PPool              +*)
(*+ Date/Modification: 03.06.97 P.W / New: InvValHexNLZ                   +*)
(*+ Date/Modification: 15.08.97 P.W / New: InvValDOpt                     +*)
(*+ Date/Modification: 13.10.97 P.W / New: InvValNice                     +*)
(*+ Date/Modification: 26.04.99 P.W / New: WhereXyRec, GotoXyRec          +*)
(*+ Date/Modification  (end of list)                                      +*)
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)

Unit Tools;

Interface

Uses
  Crt;           {26.04.99 P.W}

Type                           {26.04.99 P.W}
  TScrXY           = Packed Record // "Record" to "Packed Record" Chg#50 (02.03.04 P.W)
    X, Y           : Smallint;
  end;


Function SumSetBits(L:LongInt):Byte;
Function InvValD             (D:Double; MinLen, Decimals: Byte): String;
Function InvVal              (L:LongInt; Len:Byte): String;
Function InvValHex           (L:LongInt; Len:Byte): String;
Function InvValHexNLZ        (L:LongInt; Len:Byte): String;
Function HexToLong(Var Buf; Len: Byte): LongInt;
Function InvValDir           (L:LongInt): Char;
Function IsHex               (Ch:Char): Boolean;
Function IsHexTxt            (Txt:String): Boolean;
Function TxtMasked(Txt:String; Mode:Byte):String;
Function InvValDOpt(ValD: Double; MinLen, NumDec, MaxNumDigits: Smallint): String;
Function InvValNice (L: LongInt; MinLen: Byte): String;
Procedure WhereXYRec(Var ScrXY: tScrXY);    {26.04.99 P.W}
Procedure GotoXYRec(Const ScrXY: tScrXY);   {26.04.99 P.W}

Implementation
  const Unit_Name = 'Tools'; // 03.05.24 P.W

Const
  HexArr           : Array [0..$F] of Char
                   = ('0','1','2','3','4','5','6','7','8','9',
                      'A','B','C','D','E','F');

(*.**************************************************************************)
(** Function Name    : SumSetBits                                         **)
(** Author           : P.Wueseke                                          **)
(** Date             : 04.08.93                                           **)
(** Description      : Sum of all set Bits in a Longint Value             **)
(***************************************************************************)
(** Called By        : ANY                                                **)
(** Calls            : -                                                  **)
(** Input            : L : LongInt;                                       **)
(** Output           : Byte;                                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By :                                                    **)
(** Date/Modification:                                                    **)
(**************************************************************************.*)
Function SumSetBits(L:LongInt):Byte;
Var
  Res              : Byte;
begin
  Res:=0;
  While (L<>0) do
  begin
    if ((L and 1) <>0) then Inc(Res);
    L:=L shr 1;
  end;
  SumSetBits:=Res;
end;

(*.**************************************************************************)
(** Function Name    : InvValD                                            **)
(** Author           : P.Wueseke                                          **)
(** Date             : 03.07.95                                           **)
(** Description      :                                                    **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            : D, MinLen, Decimals                                **)
(** Output           : RETURN (String): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : ?                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function InvValD (D: Double; MinLen, Decimals: Byte): String;
Var
  SRet             : String;
begin  {Func. InvValD}
  Str(D: MinLen: Decimals, SRet);
  InvValD:=SRet;
end;   {Func. InvValD}


(*.**************************************************************************)
(** Function Name    : InvVal                                             **)
(** Author           : P.Wueseke                                          **)
(** Date             : 04.08.93                                           **)
(** Description      : Convert LongInt --> String, Len = minimale Länge   **) //OemToAnsi Chg#51 (02.03.04 P.W)
(***************************************************************************)
(** Called By        : ANY                                                **)
(** Calls            : -                                                  **)
(** Input            : L, Len                                             **)
(** Output           : L converted to String                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By :                                                    **)
(** Date/Modification:                                                    **)
(**************************************************************************.*)
Function InvVal              (L:LongInt; Len:Byte): String;
Var
  Txt              : String;
begin
  Str(L:Len, Txt);
  InvVal:=Txt;
end; { Function InvVal }

(*.**************************************************************************)
(** Function Name    : InvValHex                                          **)
(** Author           : P.Wueseke                                          **)
(** Date             : 04.08.93                                           **)
(** Description      : Convert LongInt --> HexString, Len = Length        **)
(***************************************************************************)
(** Called By        : ANY                                                **)
(** Calls            : -                                                  **)
(** Input            : L, Len                                             **)
(** Output           : L converted to Hexadecimal String                  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By :                                                    **)
(** Date/Modification:                                                    **)
(**************************************************************************.*)
Function InvValHex           (L:LongInt; Len:Byte): String;
Var
  Txt              : String;
begin
  SetLength(Txt, Len); // Txt[0]:=Char(Len);
  While (Len>0) do
  begin
    Txt[Len]:=HexArr[L and $F];
    L:=L Shr 4;
    dec(Len);
  end;
  InvValHex:=Txt;
end; { Function InvValHex }

(*.**************************************************************************)
(** Function Name    : InvValHexNLZ                                       **)
(** Author           : P.Wueseke                                          **)
(** Date             : 04.08.93                                           **)
(** Description      : Convert LongInt --> HexString, Len = Length        **)
(** Description      : But delete all leading zeros                       **)
(***************************************************************************)
(** Called By        : ANY                                                **)
(** Calls            : InvValHex                                          **)
(** Input            : L, Len                                             **)
(** Output           : L converted to Hexadecimal String  (No Lead. Zeros)**)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By :                                                    **)
(** Date/Modification:                                                    **)
(**************************************************************************.*)
Function InvValHexNLZ        (L:LongInt; Len:Byte): String;
Var
  Txt              : String;
begin {Func. InvValHexNLZ}
  Txt:=InvValHex(L, Len);
  While (Length(Txt) > 1) and (Txt[1] = '0') do delete(Txt, 1, 1);
  InvValHexNLZ:=Txt;
end;  {Func. InvValHexNLZ}

(*.**************************************************************************)
(** Function Name    : HexToLong                                          **)
(** Author           : P.Wueseke                                          **)
(** Date             : 27.07.94                                           **)
(** Description      : Convert Hexadecimal Code to LongInt                **)
(** Tested           : Full Range of Longint; even and odd len;           **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : Buf, Len (Len: 1..8)                               **)
(** Output           : Converted value                                    **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : --.07.94 / P.Wueseke                               **)
(** Date/Modification: --.07.94 P.W /                                     **)
(**************************************************************************.*)
Function HexToLong(Var Buf; Len: Byte): LongInt;
Type
  LByteArr = Array [0..3] of Byte;
  ByteArr  = Array [0..7] of Byte;
Var
  L                : LongInt;
  B                : Byte;
  Ind              : Byte;
begin
  L:=0;
  Ind:=0;
  if Len>8 then Len:=8;
  While (Len>0) do
  begin
    Dec(Len);
    B:=ByteArr(Buf)[Len];
    if (Ord('0')<=B) and (B<=Ord('9')) then Dec(B,Ord('0'))
    else
    if (Ord('A')<=B) and (B<=Ord('F')) then Dec(B,Ord('A')-10)
    else
    if (Ord('a')<=B) and (B<=Ord('f')) then Dec(B,Ord('a')-10)
    else B:=0;
    if odd(Ind) then B:=B shl 4;
    Inc(LByteArr(L)[Ind shr 1], B);
    Inc(Ind);
  end;
  HexToLong:=L;
end;

(*.**************************************************************************)
(** Function Name    : InvValDir                                          **)
(** Author           : P.Wueseke                                          **)
(** Date             : 11.02.94                                           **)
(** Description      : Convert LongInt --> + -                            **)
(***************************************************************************)
(** Called By        : ANY                                                **)
(** Calls            : -                                                  **)
(** Input            : L                                                  **)
(** Output           : L converted to DirChar (L<0: '-', L>=0: '+')       **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By :                                                    **)
(** Date/Modification:                                                    **)
(**************************************************************************.*)
Function InvValDir           (L:LongInt): Char;
begin
  if (L>=0) then InvValDir:='+'
            else InvValDir:='-';
end; { Function InvValDir }

(*.**************************************************************************)
(** Function Name    : IsHex                                              **)
(** Author           : P.Wueseke                                          **)
(** Date             : 06.08.93                                           **)
(** Description      : Checks if Upcase (Ch) is '0'..'9' or 'A'..'F'      **)
(***************************************************************************)
(** Called By        : ANY                                                **)
(** Calls            : -                                                  **)
(** Input            : Ch : Char                                          **)
(** Output           : Return: Boolean                                    **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By :                                                    **)
(** Date/Modification:                                                    **)
(**************************************************************************.*)
Function IsHex               (Ch:Char): Boolean;
begin
  IsHex:= ((Ch>='0') and (Ch<='9'))
          or
          ((Ch>='A') and (Ch<='F'))
          or
          ((Ch>='a') and (Ch<='f'));
end;

(*.**************************************************************************)
(** Function Name    : IsHexTxt                                           **)
(** Author           : P.Wueseke                                          **)
(** Date             : 27.07.94                                           **)
(** Description      : Checks if all characters in Txt are "IsHex"        **)
(***************************************************************************)
(** Called By        : ANY                                                **)
(** Calls            : -                                                  **)
(** Input            : Txt  String;                                       **)
(** Output           : Return: Boolean                                    **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By :                                                    **)
(** Date/Modification:                                                    **)
(**************************************************************************.*)
Function IsHexTxt            (Txt:String): Boolean;
Var
  P, L             : Byte;
begin
  L:=Length(Txt);
  P:=1;
  While (P<=L) and IsHex(Txt[P]) do inc(P);
  IsHexTxt:=(L>0) and (P-1=L);
end;

(*.**************************************************************************)
(** Function Name    : TxtMasked                                          **)
(** Author           : P.Wueseke                                          **)
(** Date             : 19.07.94                                           **)
(** Description      : Masked Output of Binary data                       **)
(** Description      :   Mode=0: #0..#31--> .                             **)
(** Description      :   Mode=1: #0..#31--> <0>..<31>                     **)
(** Description      :   Mode=2: #0..#255-->00..FF                        **)
(** Description      :   Mode=3: #0..#255--> 00.. FF   (blank separated)  **)
(***************************************************************************)
(** Called By        : ANY                                                **)
(** Calls            : -                                                  **)
(** Input            : Txt, Mode                                          **)
(** Output           : Return: Masked Text                                **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By :                                                    **)
(** Date/Modification:                                                    **)
(**************************************************************************.*)
Function TxtMasked(Txt:String; Mode:Byte):String;
Var
  A, B             : Byte;
  CH               : Char;
  ResTxt           : String;
begin
  Case Mode of
    0: FillChar(ResTxt, SizeOf(ResTxt), '.');
    1: FillChar(ResTxt, SizeOf(ResTxt), '<');
    2: FillChar(ResTxt, SizeOf(ResTxt), #0 );
    3: FillChar(ResTxt, SizeOf(ResTxt), ' ');
  end;

  B:=0;
  For A:=1 to Length(Txt) do
  begin
    Ch:=Txt[A];
    Case Mode of
      0: begin
           Inc(B);
           if Ch>#31 then ResTxt[B]:=Ch;
         end;
      1: begin
           Inc(B);
           if Ch>#31 then ResTxt[B]:=Ch
                     else begin
                            inc(B);
                            ResTxt[B]:=Char( (Byte(Ch) div 10) + Byte('0'));
                            inc(B);
                            ResTxt[B]:=Char( (Byte(Ch) mod 10) + Byte('0'));
                            inc(B);
                            ResTxt[B]:='>';
                          end;
         end;
      2: begin
           Inc(B);
           ResTxt[B]:=HexArr[Byte(Ch) and $0F];
           Inc(B);
           ResTxt[B]:=HexArr[Byte(Ch) shr 4];
         end;
      3: begin
           Inc(B,2);
           ResTxt[B]:=HexArr[Byte(Ch) and $0F];
           Inc(B);
           ResTxt[B]:=HexArr[Byte(Ch) shr 4];
         end;
    end;
  end;
  SetLength(ResTxt, B); // ResTxt[0]:=Char(B);

  TxtMasked:=ResTxt;
end;

(*.**************************************************************************)
(** Function Name    : InvValDOpt                                         **)
(** Author           : P.Wueseke                                          **)
(** Date             : 15.08.97                                           **)
(** Description      : Sup. only significant num of digits                **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : InValD                                             **)
(** Input            : ValD, MinLen, NumDec, MaxNumDigits                 **)
(** Output           : RETURN (String): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
// 22.03.05 P.W: Adapt to Delphi use SetLength
(**************************************************************************.*)
Function InvValDOpt(ValD: Double; MinLen, NumDec, MaxNumDigits: Smallint): String;
Var
  HTxt             : String;
  I                : Smallint;
  NumDigits        : Smallint;
  NonZeroFound     : Boolean;
  DecrFlg          : Boolean;
  DecLen           : Smallint;
  P                : Integer;
begin
  If (NumDec > 0)
    then DecLen:=NumDec+1
    else DecLen:=NumDec;
  HTxt         := InvValD(ValD, 1, NumDec);
  NumDigits    := Length(HTxt);
  NonZeroFound := False;
  DecrFlg      := False;
  For I:=1 to Length(HTxt) do
    begin
      Case HTxt[I] of
        ' ' :     Dec(NumDigits);
        '+' :     Dec(NumDigits);
        '-' :     Dec(NumDigits);
        '.' :     Dec(NumDigits);
        '0' :     If not NonZeroFound then Dec(NumDigits);
        '1'..'9': NonZeroFound:=True;
      end;
    end;
  While (NumDigits > MaxNumDigits) and (NumDec > 0) do
  begin
    Dec(NumDigits);
    Dec(NumDec);
    DecrFlg     := True;
  end;
  If DecrFlg then
    HTxt       := InvValD(ValD, 1, NumDec);

//While (HTxt[Length(HTxt)] = ' ') do Dec(HTxt[0]);
    P:= Length(HTxt);
    While (P > 0) and (HTxt[P] = ' ') do Dec(P);
    SetLength(HTxt, P);

  For I:=1 to NumDec do
  begin
//  if (HTxt[Length(HTxt)] = '0') then Dec(HTxt[0]);
      P:= Length(HTxt);
      if (P > 0) and (HTxt[P] = '0') then Dec(P);
      SetLength(HTxt, P);
  end;

//While (HTxt[Length(HTxt)] = '.') do Dec(HTxt[0]);
    P:= Length(HTxt);
    While (P > 0) and (HTxt[P] = '.') do Dec(P);
    SetLength(HTxt, P);

  If (Pos('.', HTxt)>0) then
  begin
    While (Length(HTxt)<MinLen) and (Pos('.', HTxt)<=MinLen-DecLen) do HTxt:=' '+HTxt;
    While (Length(HTxt)<MinLen)          do HTxt:=HTxt+' ';
  end else
  begin
    While (Length(HTxt)<MinLen-DecLen) do HTxt:=' '+HTxt;
    While (Length(HTxt)<MinLen)        do HTxt:=HTxt+' ';
  end;
  InvValDOpt   := HTxt;
end;

(*.**************************************************************************)
(** Function Name    : InvValNice                                         **)
(** Author           : P.Wueseke                                          **)
(** Date             : 13.10.97                                           **)
(** Description      : Return -1234567 as -1.234.567                      **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Str, Length, Delete                                **)
(** Input            : L, MinLen                                          **)
(** Output           : RETURN (String): Ret                               **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function InvValNice (L: LongInt; MinLen: Byte): String;
Var
  Ret, H           : String;
  P, Len           : Byte;

begin  {Func. InvValNice}
  Ret:='';
  Str( L:MinLen, H);
  Len:=Length(H);
  P:=0;
  While (P < Len) do
  begin
    Inc(P);
    begin
      Ret := Ret + H[P];
      If (H[P] <> ' ')         and
         (H[P] <> '-')         and
         (((Len-P) mod 3) = 0) and (P<Len)
        then Ret := Ret + '.';
    end;
  end;
  While (Length(Ret) > MinLen) and (Ret[1] = ' ') do delete(Ret, 1, 1);
  InvValNice:=Ret;
end;   {Func. InvValNice}

Procedure WhereXYRec(Var ScrXY: tScrXY);  {26.04.99 P.W}
begin
  ScrXY.X:=WhereX;
  ScrXY.Y:=WhereY;
end;

Procedure GotoXYRec(Const ScrXY: tScrXY); {26.04.99 P.W}
begin                                     
  GotoXy(ScrXY.X, ScrXY.Y);
end;

end.
