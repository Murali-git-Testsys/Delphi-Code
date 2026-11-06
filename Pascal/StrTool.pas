// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Vers.: @(#)StrTool; V.:1.00                             ) +*)
(*+ Author           : P.Wueseke                                          +*)
(*+ Date             : 17.10.94                                           +*)
(*+ Description      : Tools used to work with strings                    +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*+ Last modified/By : 01.09.97 / P.Wueseke                               +*)
(*+ Date/Modification: 19.10.94 P.W / Added: InvVal, InvValD              +*)
(*+ Date/Modification: 07.11.94 P.W / Added: LeadZeros                    +*)
(*+ Date/Modification: 14.11.94 P.W / Added: DelSpcLeft, DelSpcRight      +*)
(*+ Date/Modification: 27.03.96 P.W / Added: ExpandEnvVar                 +*)
(*+ Date/Modification: 23.06.97 P.W / Added: NameExtPart ExtPart          +*)
(*+ Date/Modification: 01.09.97 P.W / no longer define String01 ... to    +*)
(*+ Date/Modification: 01.09.97 P.W + avoid type mismatch with GlbType    +*)
(*+ Date/Modification  (end of list)                                      +*)
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)
Unit StrTool;

INTERFACE

Uses
  SysUtils,
  Dos;

Const
  MinLongInt       = -2147483647-1; {-2147483648 not accepted!}
  MaxLongInt       =  2147483647;
  MaxWord          = 65535;
  LineEnd          = #13;
  Space            = ' ';
  TabChar          =  #9;

(*  {until 01.09.97 P.W}
Type
  String01         = String[01];
  StrPtr01         = ^String01;
  String02         = String[02];
  StrPtr02         = ^String02;
  String03         = String[03];
  StrPtr03         = ^String03;
  String04         = String[04];
  StrPtr04         = ^String04;
  String05         = String[05];
  StrPtr05         = ^String05;
  String06         = String[06];
  StrPtr06         = ^String06;
  String07         = String[07];
  StrPtr07         = ^String07;
  String08         = String[08];
  StrPtr08         = ^String08;
  String09         = String[09];
  StrPtr09         = ^String09;
  String10         = String[10];
  StrPtr10         = ^String10;
  String11         = String[11];
  StrPtr11         = ^String11;
  String12         = String[12];
  StrPtr12         = ^String12;
  String15         = String[15];
  StrPtr15         = ^String15;
  String20         = String[20];
  StrPtr20         = ^String20;
  String25         = String[25];
  StrPtr25         = ^String25;
  String30         = String[30];
  StrPtr30         = ^String30;
  String40         = String[40];
  StrPtr40         = ^String40;
  String50         = String[50];
  StrPtr50         = ^String50;
  String60         = String[60];
  StrPtr60         = ^String60;
  String70         = String[70];
  StrPtr70         = ^String70;
  String80         = String[80];
  StrPtr80         = ^String80;
  String90         = String[90];
  StrPtr90         = ^String90;
*)
Function UpStr (Txt: String): String;
Procedure CleanStr (Var HStr: String);
Procedure DelSpcLeft (Var Txt: String);
Procedure DelSpcRight (Var Txt: String);
Function ValStrToDouble (ValStr: String; Var DRet: Double): Smallint;
Function ValStrToLong (ValStr: String; Var LRet: LongInt): Smallint;
Function ValStrToWord (ValStr: String; Var WRet: Word): Smallint;
Function InvValD(Value: Double; Width, Decimals: Byte): String;
Function InvVal (Value: LongInt; Width: Byte): String;
Function LeadZeros (L : LongInt; MinLen: Byte): String;
Function ExpandEnvVar (Txt: String): String;
Function NameExtPart(Const Name: PathStr): String;
Function ExtPart(Const Name: PathStr): ExtStr;

Implementation
  const Unit_Name = 'StrTool'; // 03.05.24 P.W
{
#CF
}

(*.**************************************************************************)
(** Function Name    : UpStr                                              **)
(** Author           : P.Wueseke                                          **)
(** Date             : 17.10.94                                           **)
(** Description      : Returns Upper Case of Txt                          **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : UpCase                                             **)
(** Input            : Txt                                                **)
(** Output           : RETURN (String): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function UpStr (Txt: String): String;
Var
  p                : Byte;
begin  {Func. UpStr}
  For p:=1 to Length(Txt) do Txt[p]:=UpCase(Txt[p]);
  UpStr:=Txt;
end;   {Func. UpStr}

(*.**************************************************************************)
(** Procedure Name   : CleanStr                                           **)
(** Author           : P.Wueseke                                          **)
(** Date             : 13.10.94                                           **)
(** Description      : 1) Changes TabChar and LineEnd-->Space             **)
(** Description      : 2) Deletes all Left and Right Space                **)
(** Description      : 3) Changes all Double SpaceChars into Single Space **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : Hstr                                               **)
(** Output           : Hstr                                               **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Procedure CleanStr (Var HStr: String);
Var
  p, p2            : Byte;
  SpaceFlg         : Boolean;
begin  {Proc. CleanStr}
  p2:=0;
  SpaceFlg:= True; {Start of ReturnStr or LastChar to ReturnStr was a Space}
  For p:=1 to Length(HStr) do
  begin
    Case HStr[p] of
      Space, TabChar, LineEnd:
        if not SpaceFlg then
        begin
          inc(p2);
          HStr[p2]:=Space;
          SpaceFlg:=True;
        end;
      else
        begin
          inc(p2);
          HStr[p2]:=HStr[p];
          SpaceFlg:=False;
        end;
    end;
  end;
  if (p2>0) and SpaceFlg then dec(p2);
  //HStr[0]:=Char(p2);
  SetLength(HStr, p2);
end;   {Proc. CleanStr}

(*.**************************************************************************)
(** Procedure Name   : DelSpcLeft                                         **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.11.94                                           **)
(** Description      :                                                    **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Delete                                             **)
(** Input            : Txt                                                **)
(** Output           : Txt                                                **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Procedure DelSpcLeft (Var Txt: String);
begin  {Func. DelSpcLeft}
  While (Txt<>'')
        and
        ((Txt[1]=Space) or (Txt[1]=TabChar))
  do Delete(Txt, 1, 1);
end;   {Func. DelSpcLeft}


(*.**************************************************************************)
(** Procedure Name   : DelSpcRight                                        **)
(** Author           : P.Wueseke                                          **)
(** Date             : 14.11.94                                           **)
(** Description      :                                                    **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : -                                                  **)
(** Input            : Txt                                                **)
(** Output           : Txt                                                **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
// 22.03.05 P.W adapt to Delphi: SetLength instead of Text[0]
(**************************************************************************.*)
procedure DelSpcRight (Var Txt: String);
var
  P : Integer;
begin  {Func. DelSpcRight}
  P := Length(Txt);
  While (P>0) and (Txt[P] in [Space, TabChar]) do Dec(P);
  SetLength(Txt, P);
//  While (Txt[Length(Txt)]=Space) or (Txt[Length(Txt)]=TabChar)
//  do Dec(Txt[0]);
end;   {Func. DelSpcRight}

(** Function Name    : ValStrToDouble                                     **)
(** Author           : P.Wueseke                                          **)
(** Date             : 17.10.94                                           **)
(** Description      : ValStr to Double                                   **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Val                                                **)
(** Input            : ValStr                                             **)
(** Output           : DRet                                               **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function ValStrToDouble (ValStr: String; Var DRet: Double): Smallint;
Var
  Res              : LongInt;
begin
  Res:=0;
  Val(ValStr, DRet, Res);
  If (Res<>0) then DRet:=0;
  ValStrToDouble:=Res;
end;

(*.**************************************************************************)
(** Function Name    : ValStrToLong                                       **)
(** Author           : P.Wueseke                                          **)
(** Date             : 17.10.94                                           **)
(** Description      : ValStr to LongInt                                  **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Val                                                **)
(** Input            : ValStr                                             **)
(** Output           : LRet                                               **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function ValStrToLong (ValStr: String; Var LRet: LongInt): Smallint;
Var
  Res              : LongInt;
begin
  Val(ValStr, LRet, Res);
  if (Res<>0) then LRet:=0;
  ValStrToLong:=Res;
end;

(*.**************************************************************************)
(** Function Name    : ValStrToWord                                       **)
(** Author           : P.Wueseke                                          **)
(** Date             : 17.10.94                                           **)
(** Description      : ValStr to LongInt                                  **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Val                                                **)
(** Input            : ValStr                                             **)
(** Output           : WRet                                               **)
(** Output           : RETURN (Smallint): Ok: Ret=0; not Ok: Ret=ErrCode;  **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function ValStrToWord (ValStr: String; Var WRet: Word): Smallint;
Var
  Res              : Smallint;
  L                : LongInt;
begin
  Res:=ValStrToLong(ValStr, L);
  If (Res<>0) or (L<0) or (L>MaxWord) then
  begin
    WRet:=0;
    if (Res=0) then Res:=-1;   { out of Range }
  end else
  begin
    WRet:=L;
  end;

  ValStrToWord:=Res;
end;

(*.**************************************************************************)
(** Function Name    : InvValD                                            **)
(** Author           : P.Wueseke                                          **)
(** Date             : 19.10.94                                           **)
(** Description      : Convert Double into String                         **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Str                                                **)
(** Input            : Value, Width, Decimals                             **)
(** Output           : RETURN (String): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function InvValD (Value: Double; Width, Decimals: Byte): String;
Var
  SRet             : String;
begin  {Func. InvValD}
  Str(Value: Width: Decimals, SRet);
  InvValD:=SRet;
end;   {Func. InvValD}

(*.**************************************************************************)
(** Function Name    : InvVal                                             **)
(** Author           : P.Wueseke                                          **)
(** Date             : 19.10.94                                           **)
(** Description      : Convert LongInt into String                        **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Str                                                **)
(** Input            : Value, Width                                       **)
(** Output           : RETURN (String): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function InvVal (Value: LongInt; Width: Byte): String;
Var
  SRet             : String;
begin  {Func. InvVal}
  Str(Value: Width, SRet);
  InvVal:=SRet;
end;   {Func. InvVal}

(*.**************************************************************************)
(** Function Name    : LeadZeros                                          **)
(** Author           : P.Wueseke                                          **)
(** Date             : 07.11.94                                           **)
(** Description      : LongInt to String with leading zeros               **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : Str                                                **)
(** Input            : L, MinLen                                          **)
(** Output           : RETURN (String): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function LeadZeros (L : LongInt; MinLen: Byte): String;
Var
  SRet             : String;
begin  {Func. LeadZeros}
  Str(L, SRet);
  While (Length(SRet)<MinLen) do SRet:='0'+SRet;
  LeadZeros:=SRet;
end;   {Func. LeadZeros}

(*.**************************************************************************)
(** Function Name    : ExpandEnvVar                                       **)
(** Author           : P.Wueseke                                          **)
(** Date             : 27.03.96                                           **)
(** Description      : Expand %xyz% in string with environmentvar xyz     **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : ?                                                  **)
(** Input            : Txt                                                **)
(** Output           : RETURN (String): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : ?                                                  **)
(**  - predefined    : ?                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function ExpandEnvVar (Txt: String): String;

  Function PercDeleted(Var PrePerc: String):Boolean;
  Var
    P : Smallint;
  begin
    P:=Pos('%', Txt);
    PercDeleted:=(P>0);

    If (P>0) then
    begin
      Delete(Txt, P, 1);
      Dec(P);
    end else
    begin
      P:=Length(Txt);
    end;
    PrePerc:=Copy(Txt,1,P);
    Delete       (Txt,1,P);
  end;

Var
  SRet             : String;
  HStr             : String;
begin  {Func. ExpandEnvVar}
  SRet:='';
  While PercDeleted(HStr) do
  begin
    SRet:=SRet+HStr;

    PercDeleted(HStr);
    If (HStr='') then HStr:='%'
                 else HStr:=GetEnvironmentVariable(HStr);
    SRet:=SRet+HStr;
    Hstr:='';
  end;
  SRet:=SRet+HStr;
  ExpandEnvVar:=SRet;
end;   {Func. ExpandEnvVar}

(*.**************************************************************************)
(** Function Name    : NameExtPart                                        **)
(** Author           : P.Wueseke                                          **)
(** Date             : 23.06.97                                           **)
(** Description      : Returns NameStr+ExtStr of Name                     **)
(***************************************************************************)
(** Called By        : any                                                **)
(** Calls            : FExpand, FSplit                                    **)
(** Input            : Name                                               **)
(** Output           : RETURN (String): SRet                              **)
(** Global Variables                                                      **)
(**  - affected      : -                                                  **)
(**  - predefined    : -                                                  **)
(***************************************************************************)
(** Last modified/By : -                                                  **)
(** Date/Modification: -                                                  **)
(**************************************************************************.*)
Function NameExtPart(Const Name: PathStr): String;
Var
  DStr             : DirStr;
  NStr             : NameStr;
  EStr             : ExtStr;
begin  {Func. NameExtPart}
  FSplit(Fexpand(Name), DStr, NStr, EStr);
  NameExtPart:=NStr+EStr;
end;   {Func. NameExtPart}

Function ExtPart(Const Name: PathStr): ExtStr;    {23.06.97 P.W}
Var
  DStr             : DirStr;
  NStr             : NameStr;
  EStr             : ExtStr;
begin  {Func. ExtPart}
  FSplit(Fexpand(Name), DStr, NStr, EStr);
  ExtPart:=EStr;
end;   {Func. ExtPart}

end.
