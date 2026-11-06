// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; changes: 1; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; changes: 1; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; changes: 8; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Module Name/Vers.:UTGenOb;
Date/Author      :{96 Michael Welsch}
Description      : general objects
Date/Modification:
{06.05.96 Michael Welsch}
implemented:
constructor TOwnStringCollection.CopyInit(Source:POwnStringCollection);
{08.04.97 MW}
Function     TIntRect.IsInsideDelta(NRect:PIntRect;Delta:SmallInt):Boolean;
{11.04.97 MW}
Procedure    TRealRect.IncludeThisVal(_X1,_Y1,_X2,_Y2:Real);
Function     TRealRect.IsTheSame(const NRect:PRealRect):Boolean;
{05.11.97 MW}
Function     GetASCII:String;virtual;
{05.02.01 P.W}
  a) Code of IsInside corrected for TIntRect and TRealRect
  b) TIntRect.ForceInsideDelta added
{18.07.03 P.W}
  Function  NewIntRectFromObjEdges &
  Procedure PIntRectToObjEdges
  Moved From FindEdge.pas to UtGenObj.pas
01.04.08 P.W Procedure TOwnBufStream.SReadln more save when EndOfFile reached
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)

Unit UTGenOb;
INTERFACE
uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  MsgBox,  // 01.04.08 P.W
  Math,    //  GlbTools,  {27.06.03 P.W} // Math since 28.07.05 P.W
  Objects;
Type
  PRealRect     =       ^TRealRect;

  TRealRect     =       Object
   X1,Y1,X2,Y2  :       Real;
   Constructor  Init(NX1,NY1,NX2,NY2:Real);
   Destructor   Done;
   Procedure    Copy(NRect:PRealRect);
   Procedure    YUpIncreasing;
   Procedure    YUpDecreasing;
   Function     Width:Real;
   Function     Height:Real;
   Function     IsInside(NRect:PRealRect):Boolean;
   Procedure    IncludeThis(NRect:PRealRect);
   Procedure    IncludeThisVal(_X1,_Y1,_X2,_Y2:Real);
   Function     IsTheSame(const NRect:PRealRect):Boolean;
   Function     GetASCII:String;virtual;
  end;


  PIntRect      =       ^TIntRect;

  TIntRect      =       Object
   X1,Y1,X2,Y2  :       SmallInt;
   Constructor  Init(NX1,NY1,NX2,NY2:SmallInt);
   Destructor   Done;
   Procedure    Copy(NRect:PIntRect);
   Procedure    YUpIncreasing;
   Procedure    YUpDecreasing;
   Function     Width:LongInt;
   Function     Height:LongInt;
   Function     IsEqual(TR:PIntRect):Boolean;
   Function     IsPointInside(X,Y:SmallInt):Boolean;
   Procedure    ExtendRect(DX,DY:SmallInt;Range:PIntRect);
   Procedure    IncludeThis(NRect:PIntRect);
   Function     IsInside(NRect:PIntRect):Boolean;
   Procedure    ForceInsideDelta(NRect:PIntRect;Delta:SmallInt);{05.02.01 P.W}
   Function     IsInsideDelta(NRect:PIntRect;Delta:SmallInt):Boolean;

  end;

   tObjEdges     = Packed Record             {27.06.03 P.W} // "Record" to "Packed Record" Chg#1513 (02.03.04 P.W)
     X1,Y1,X2,Y2 : SmallInt;           {for use by TNewStatus, no objects!}
   end;

  Function  NewIntRectFromObjEdges(ObjEdges: tObjEdges): PIntRect; {27.06.03 P.W}
  Procedure PIntRectToObjEdges(IntRect: PIntRect; Var ObjEdges: tObjEdges); {27.06.03 P.W}

Type
   POwnStringCollection  =  ^TOwnStringCollection;
   TOwnStringCollection  =  Object(TStringCollection)
     _Sorted             :  Boolean;
     constructor Init(ALimit, ADelta: SmallInt;Sorted:Boolean);
     constructor CopyInit(Source:POwnStringCollection);
     function    Compare(Key1, Key2: Pointer): SmallInt; virtual;
     Constructor Load(Var S:TStream_TP7); { used for persistance } // "TStream" to "TStream_TP7" Chg#1505 (02.03.04 P.W)
     Procedure   Store(Var S:TStream_TP7);virtual;{ used for persistance } // "TStream" to "TStream_TP7" Chg#1506 (02.03.04 P.W)
   end;

   POwnBufStream        =   ^TOwnBufStream;
   TOwnBufStream        =   Object(TBufStream)
     Procedure   SReadln(Var Str:String);
     Procedure   SWriteln(Str:String);
   end;
Procedure  WriteStringInStream(Var St:String;Var S:TStream_TP7); // "TStream" to "TStream_TP7" Chg#1507 (02.03.04 P.W)
Procedure  WriteCRLFInStream(Var S:TStream_TP7); // "TStream" to "TStream_TP7" Chg#1508 (02.03.04 P.W)
var //const
  ROwnStringCollection : TStreamRec = (
    ObjType           :500;
    VmtLink           :TypeOf(TOwnStringCollection); // "Ofs(TypeOf" to "TypeOf" Chg#3695 (02.03.04 P.W)
    Load              :@TOwnStringCollection.Load;
    Store             :@TOwnStringCollection.Store );

Procedure AdaptToWantedExtend(       {from FindEdge.pas: 27.06.03 P.W}
            Var ObjRange    : PIntRect;
                VARange     : TIntRect;
                WantedExtend: SmallInt);  {Extend := Max(Heigt, Width)}
                                         {Extend := Delta + 1}

Implementation
  const Unit_Name = 'UTGenOb'; // 03.05.24 P.W
{--------------------------------------------------------------------------}
Procedure AdaptToWantedExtend(
            Var ObjRange   : PIntRect;
                VARange    : TIntRect;
                WantedExtend: SmallInt);  {Extend := Max(Heigt, Width)}
                                         {Extend := Delta + 1}
(*
  Squared ObjRange adapt to WantedExtend-1 but complete inside VARange
  If WantedExtend is below 10 than use ObjExtend
*)
Var
//  InvertX          : Boolean;
  IXA,IXB          : SmallInt;
  InvertY          : Boolean;
  IYA,IYB          : SmallInt;
  VAExtend         : SmallInt;
  ObjExtend        : SmallInt;
  WantedDelta      : SmallInt;

  ObjCenterX       : Double;
  ObjCenterY       : Double;

begin {Proc. AdaptToWantedExtend}
  With VARange do
  begin
//    InvertX := X1 > X2;
    IXA := Min(X1, X2);
    IXB := Max(X1, X2);

    InvertY := Y1 > Y2;
    IYA := Min(Y1, Y2);
    IYB := Max(Y1, Y2);

    VAExtend := Min(Width, Height);
  end;

  With ObjRange^ do ObjExtend := Max(Width, Height);


  If (WantedExtend < 10) then WantedExtend := ObjExtend;

  {--- Clip WantedDelta to VAExtend-1: ---}
  {extend not ouside Range!}
  WantedDelta  := Min(WantedExtend, VAExtend) -1;

  With ObjRange^ do
  begin {With ObjRange^}

    YUpIncreasing; {afterwards: X1 <= X2; Y1 <= Y2}

    ObjCenterX := 0.5 * (X1 + X2);
    ObjCenterY := 0.5 * (Y1 + Y2);

    {v--- adapt ObjRoi Extend ---}
      {--- Squared Roi around ObjCenter: ---}
      X1 := Round(ObjCenterX - (0.5 * WantedDelta));
      Y1 := Round(ObjCenterY - (0.5 * WantedDelta));
      X2 := X1 + WantedDelta;
      Y2 := Y1 + WantedDelta;

      {--- Now move Roi until it fits into VA Range: ---}
      If (X1 < IXA) then
      begin
        X1:= IXA;
        X2:= IXA+WantedDelta;
      end;
      If (X2 > IXB) then
      begin
        X1:= IXB-WantedDelta;
        X2:= IXB;
      end;
      If (Y1 < IYA) then
      begin
        Y1:= IYA;
        Y2:= IYA+WantedDelta;
      end;
      If (Y2 > IYB) then
      begin
        Y1:= IYB-WantedDelta;
        Y2:= IYB;
      end;
    {^--- adapt ObjRoi Extend ---}

    If InvertY then
      YUpDecreasing; {afterwards: X1 <= X2; Y2 <= Y1}

  end;  {With ObjRange}
end;  {Proc. AdaptToWantedExtend}
{--------------------------------------------------------------------------}
Procedure RegisterUTGenOb;
begin
  RegisterType(ROwnStringCollection);
end;
{--------------------------------------------------------------------------}
Procedure  WriteStringInStream(Var St:String;Var S:TStream_TP7); // "TStream" to "TStream_TP7" Chg#1509 (02.03.04 P.W)
Var
  I     :       SmallInt;
begin
  For I:=1 To Length(ST) Do
    S.Write(ST[I],SizeOf(Char));
end;
{--------------------------------------------------------------------------}
Procedure  WriteCRLFInStream(Var S:TStream_TP7); // "TStream" to "TStream_TP7" Chg#1510 (02.03.04 P.W)
Var
  Ch    :       Char;
begin
  Ch:=#13;
  S.Write(Ch,SizeOf(Ch));
  Ch:=#10;
  S.Write(Ch,SizeOf(Ch));
end;
{--------------------------------------------------------------------------}
{  TRealRect     =       Object
{--------------------------------------------------------------------------}
Constructor  TRealRect.Init(NX1,NY1,NX2,NY2:Real);
begin
   X1:=NX1;
   Y1:=NY1;
   X2:=NX2;
   Y2:=NY2;
end;
{--------------------------------------------------------------------------}
Destructor   TRealRect.Done;
begin
end;
{--------------------------------------------------------------------------}
Procedure    TRealRect.YUpIncreasing;
{                   (X2,Y2)
 y ^  100
   |
   |
   | 0
   ----------------->x
   0                100
(X1,Y1)
}

Var
  Hold  :       Real;
begin
  If X2<X1 Then
  begin
    Hold:=X1;
    X1:=X2;
    X2:=Hold;
  end;
  If Y2<Y1 Then
  begin
    Hold:=Y1;
    Y1:=Y2;
    Y2:=Hold;
  end;
end;
{--------------------------------------------------------------------------}
Procedure    TRealRect.YUpDecreasing;
Var
  Hold  :       Real;
{                   (X2,Y2)
 y    0
   |
   |
   v  100
   ----------------->x
   0                100
(X1,Y1)
}
begin
  If X2<X1 Then
  begin
    Hold:=X1;
    X1:=X2;
    X2:=Hold;
  end;
  If Y2>Y1 Then
  begin
    Hold:=Y1;
    Y1:=Y2;
    Y2:=Hold;
  end;
end;
{--------------------------------------------------------------------------}
Function     TRealRect.Width:Real;
begin
  Width:=Abs(X2-X1);
end;
{--------------------------------------------------------------------------}
Function     TRealRect.Height:Real;
begin
  Height:=Abs(Y2-Y1);
end;
{--------------------------------------------------------------------------}
Procedure    TRealRect.Copy(NRect:PRealRect);
begin
  X1:=NRect^.X1;
  Y1:=NRect^.Y1;
  X2:=NRect^.X2;
  Y2:=NRect^.Y2;
end;
{--------------------------------------------------------------------------}
Procedure    TRealRect.IncludeThisVal(_X1,_Y1,_X2,_Y2:Real);
{TRealRect will be increased if necessary}
{11.04.97 MW, copied from prev. IncludeThis }
// look out! YUpIncreasing is not possible for Y1=Y2! (for this YUpDecreasing is used!)
Var
  temp	:	TRealRect;
begin
  temp.Init(_X1,_Y1,_X2,_Y2);
  temp.YUpIncreasing;
  If temp.X1<X1 Then X1:=temp.X1;
  If temp.X2>X2 Then X2:=temp.X2;
  If Y2>Y1 Then
  begin                              {TRealRect is YUpIncreasing}
    If temp.Y1<Y1 Then Y1:=temp.Y1;
    If temp.Y2>Y2 Then Y2:=temp.Y2;
  end else
  begin                              {TRealRect is YUpDecreasing}
    If temp.Y1<Y2 Then Y2:=temp.Y1;
    If temp.Y2>Y1 Then Y1:=temp.Y2;
  end;
  temp.done; {11.04.97 MW, this was missing in prev. versions}
end;

{--------------------------------------------------------------------------}
Procedure    TRealRect.IncludeThis(NRect:PRealRect);
{TRealRect will be increased if necessary}
{11.04.97 MW, core moved to IncludeThisVal}
begin
  With NRect^ Do
    Self.IncludeThisVal(X1,Y1,X2,Y2);
end;
{--------------------------------------------------------------------------}
Function     TRealRect.IsTheSame(const NRect:PRealRect):Boolean;
begin
  IsTheSame:= (NRect^.X1=X1) And
              (NRect^.X2=X2) And
              (NRect^.Y1=Y1) And
              (NRect^.Y2=Y2);
end;
{--------------------------------------------------------------------------}
Function     TRealRect.IsInside(NRect:PRealRect):Boolean;
{Checks if NRect is Inside TRealRect}
{independend from YUpDecreasing or YUpIncreasing for NRect and TRealRect}
{But for "TRealRect is YUpIncreasing" the code was wrong! 05.02.01 P.W}
{Modifications:
05.02.01 P.W : Comment added
               Code for "TRealRect is YUpIncreasing" corrected
               from "(Y1<=temp.Y1) And (Y2>=temp.Y2)"
               to   "(Y2>=temp.Y1) And (Y1<=temp.Y2)"
}
Var
  temp	:	TRealRect;
begin
  With NRect^ Do
     temp.Init(X1,Y1,X2,Y2);
  temp.YUpDecreasing;
  IsInside:=(X1<=temp.X1) And (X2>=temp.X2)
            And
            ( ( (Y1>Y2)  And                     {TRealRect is YUpDecreasing}
                (Y1>=temp.Y1) And (Y2<=temp.Y2) )
              Or
	      ( (Y1<Y2)  And                           {TRealRect is YUpIncreasing}
                (Y2>=temp.Y1) And (Y1<=temp.Y2) ){modified: 05.02.01 P.W}
            );

  temp.done; {05.02.01 P.W, this was missing in prev. versions}
end;
{--------------------------------------------------------------------------}
Function     TRealRect.GetASCII:String;
{05.11.97 MW}
var
  HStr,TStr  :       String;
begin
  Str(X1:6:1,TStr);
  HStr:='('+TStr;
  Str(Y1:6:1,TStr);
  HStr:=HStr+'/'+TStr;
  Str(X2:6:1,TStr);
  HStr:=HStr+'|'+TStr;
  Str(Y2:6:1,TStr);
  HStr:=HStr+'/'+TStr+')';
  GetASCII:=HStr;
end;
{--------------------------------------------------------------------------}

{--------------------------------------------------------------------------}
{  TIntRect     =       Object
{--------------------------------------------------------------------------}
Function  NewIntRectFromObjEdges(ObjEdges: tObjEdges): PIntRect;
(*
Created: {27.06.03 P.W}
Modifications:
{18.07.03 P.W}
  Moved From FindEdge.pas to UtGenObj.pas
*)
begin
  With ObjEdges do
    NewIntRectFromObjEdges :=
      New(PIntRect, Init(X1, Y1, X2, Y2));
end;

Procedure PIntRectToObjEdges(IntRect: PIntRect; Var ObjEdges: tObjEdges);
(*
Created: {27.06.03 P.W}
Modifications:
{18.07.03 P.W}
  Moved From FindEdge.pas to UtGenObj.pas
*)
begin
  FillChar(ObjEdges, SizeOf(ObjEdges), #0);
  If Assigned(IntRect) then
  begin
    ObjEdges.X1 := IntRect^.X1;
    ObjEdges.Y1 := IntRect^.Y1;
    ObjEdges.X2 := IntRect^.X2;
    ObjEdges.Y2 := IntRect^.Y2;
  end;
end;

Constructor  TIntRect.Init(NX1,NY1,NX2,NY2:SmallInt);
begin
   X1:=NX1;
   Y1:=NY1;
   X2:=NX2;
   Y2:=NY2;
end;
{--------------------------------------------------------------------------}
Destructor   TIntRect.Done;
begin
end;
{--------------------------------------------------------------------------}

Procedure    TIntRect.YUpIncreasing;
{afterwards: X1 <= X2; Y1 <= Y2}
Var
  Hold  :       SmallInt;
begin
  If X2<X1 Then
  begin
    Hold:=X1;
    X1:=X2;
    X2:=Hold;
  end;
  If Y2<Y1 Then
  begin
    Hold:=Y1;
    Y1:=Y2;
    Y2:=Hold;
  end;
end;
{--------------------------------------------------------------------------}
Procedure    TIntRect.YUpDecreasing;
{afterwards: X1 <= X2; Y2 <= Y1}
Var
  Hold  :       SmallInt;
begin
  If X2<X1 Then
  begin
    Hold:=X1;
    X1:=X2;
    X2:=Hold;
  end;
  If Y2>Y1 Then
  begin
    Hold:=Y1;
    Y1:=Y2;
    Y2:=Hold;
  end;
end;
{--------------------------------------------------------------------------}
Function     TIntRect.Width:LongInt;
begin
(*
  If X2-X1<>0 Then
    Width:=Abs(X2-X1)+1
  else
    Width:=0;
*)
  Width:=Abs(X2-X1)+1
end;
{--------------------------------------------------------------------------}
Function     TIntRect.Height:LongInt;
begin
(*
  If Y2-Y1<>0 Then
    Height:=Abs(Y2-Y1)+1
  else
    Height:=0;
*)
  Height:=Abs(Y2-Y1)+1
end;
{--------------------------------------------------------------------------}
Procedure    TIntRect.Copy(NRect:PIntRect);
begin
  X1:=NRect^.X1;
  Y1:=NRect^.Y1;
  X2:=NRect^.X2;
  Y2:=NRect^.Y2;
end;
{--------------------------------------------------------------------------}
Function     TIntRect.IsEqual(TR:PIntRect):Boolean;
begin
  IsEqual:=(TR^.X1=X1) And (TR^.X2=X2) And (TR^.Y1=Y1) And (TR^.Y2=Y2);
end;
{--------------------------------------------------------------------------}
Function     TIntRect.IsPointInside(X,Y:SmallInt):Boolean;
begin
  { assuming YUpdecreasing !!! }
  IsPointInside:=(X1<=X) And (X2>=X) And (Y1>=Y) And (Y2<=Y);
end;
{--------------------------------------------------------------------------}
Procedure    TIntRect.ExtendRect(DX,DY:SmallInt;Range:PIntRect);
begin
  { assuming YUpdecreasing !!! }
  If X1-DX>=Range^.X1 Then
     X1:=X1-DX;
  If X2+DX<=Range^.X2 Then
     X2:=X2+DX;
  If Y1+DY<=Range^.Y1 Then
     Y1:=Y1+DY;
  If Y2-DY>=Range^.Y2 Then
     Y2:=Y2-DY;
end;
{--------------------------------------------------------------------------}
Procedure    TIntRect.IncludeThis(NRect:PIntRect);
{TIntRect will be increased if necessary}
Var
  temp	:	TIntRect;
begin
  With NRect^ Do
     temp.Init(X1,Y1,X2,Y2);
  temp.YUpIncreasing;
  If temp.X1<X1 Then X1:=temp.X1;
  If temp.X2>X2 Then X2:=temp.X2;
  If Y2>Y1 Then
  begin
    If temp.Y1<Y1 Then Y1:=temp.Y1;
    If temp.Y2>Y2 Then Y2:=temp.Y2;
  end else
  begin
    If temp.Y1<Y2 Then Y2:=temp.Y1;
    If temp.Y2>Y1 Then Y1:=temp.Y2;
  end;
  temp.done; {05.02.01 P.W, this was missing in prev. versions}
end;
{--------------------------------------------------------------------------}
Procedure    TIntRect.ForceInsideDelta(NRect:PIntRect;Delta:SmallInt);
{Created: 05.02.01 P.W}
{Checks if NRect does fit into TIntRect. If Not NRect will be modified to fit}
{Independend from YUpDecreasing or YUpIncreasing for NRect and TIntRect}
Var
  Temp	:	TIntRect;
  NRectIsYUpDecreasing : Boolean;
begin
  NRectIsYUpDecreasing := (NRect^.Y1 > NRect^.Y2);
  NRect^.YUpIncreasing;  {Insures that  X1 <= X2; Y1 <= Y2}

  If (Y1<Y2)
    then Temp.Init(X1-Delta,Y1-Delta,X2+Delta,Y2+Delta)
    else Temp.Init(X1-Delta,Y1+Delta,X2+Delta,Y2-Delta);

  If not Temp.IsInside(NRect) then    {NRect is not completely inside Temp}
  begin
    Temp.YUpIncreasing;  {Insures that  X1 <= X2; Y1 <= Y2}
    NRect^.X1 := Temp.X1;
    NRect^.Y1 := Temp.Y1;
    NRect^.X2 := Temp.X2;
    NRect^.Y2 := Temp.Y2;
  end;

  If NRectIsYUpDecreasing then NRect^.YUpDecreasing; {The original order}
  Temp.Done;
end;
{--------------------------------------------------------------------------}
Function     TIntRect.IsInsideDelta(NRect:PIntRect;Delta:SmallInt):Boolean;
{08.04.97 MW assuming YUpdecreasing (i.e.: Y2 <= Y1)!!} {05.02.01 P.W}
{Comment corrected from
             "assuming YUpIncreasing!!" to
             "assuming YUpDecreasing (i.e.: Y2 <= Y1)!!"   05.02.01 P.W}
          {  This has been verified using the debug output }
Var
  temp	:	TIntRect;
begin
  temp.Init(X1-Delta,Y1+Delta,X2+Delta,Y2-Delta);
(*
{debug output: 05.02.01 P.W}
{ Delta = -1
         X1     Y1      X2    Y2
  Frame   1    263     263     1
  Temp    2    262     262     2
  NRect  87     69     233    40
}
begin
  Writeln('Frame  X1=',        X1:4,'  Y1=',      Y1:4,
               '  X2=',        X2:4,'  Y2=',      Y2:4);
  Writeln('Temp   X1=',   Temp.X1:4,'  Y1=', Temp.Y1:4,
               '  X2=',   Temp.X2:4,'  Y2=', Temp.Y2:4);
  Writeln('NRect  X1=', NRect^.X1:4,'  Y1=', NRect^.Y1:4,
               '  X2=', NRect^.X2:4,'  Y2=', NRect^.Y2:4);
  Readln;
end;
*)
  IsInsideDelta:=Temp.IsInside(NRect);
  Temp.Done;
end;
{--------------------------------------------------------------------------}
Function     TIntRect.IsInside(NRect:PIntRect):Boolean;
{Checks if NRect is Inside TIntRect}
{independend from YUpDecreasing or YUpIncreasing for NRect and TIntRect}
{But for "TIntRect is YUpIncreasing" the code was wrong! 05.02.01 P.W}
{Modifications:
05.02.01 P.W : Comment added
               Code for "TIntRect is YUpIncreasing" corrected
               from "(Y1<=temp.Y1) And (Y2>=temp.Y2)"
               to   "(Y2>=temp.Y1) And (Y1<=temp.Y2)"
}
Var
  temp	:	TIntRect;
begin
  With NRect^ Do
     temp.Init(X1,Y1,X2,Y2);   {(X1 ... from NRect^ (because of "With"))}

  temp.YUpDecreasing;   {=> X1<=X2, Y2 <= Y1  (X1 ... of temp)}
  IsInside:=(X1<=temp.X1) And (X2>=temp.X2)  {(X1 ... of TIntRect)}
            And
            ( ( (Y1>Y2)  And                     {TIntRect is YUpDecreasing}
                (Y1>=temp.Y1) And (Y2<=temp.Y2) )
              Or
	      ( (Y1<Y2)  And                           {TIntRect is YUpIncreasing}
                (Y2>=temp.Y1) And (Y1<=temp.Y2) ){modified: 05.02.01 P.W}
            );

  temp.done; {05.02.01 P.W, this was missing in prev. versions}
end;

{--------------------------------------------------------------------------}

{--------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
{   TOwnStringCollection  =  Object(TStringCollection)
{----------------------------------------------------------------------------}
constructor TOwnStringCollection.Init(ALimit, ADelta: SmallInt;Sorted:Boolean);
begin
  inherited Init(ALimit,ADelta);
  _Sorted:=Sorted;
end;
{----------------------------------------------------------------------------}
constructor TOwnStringCollection.CopyInit(Source:POwnStringCollection);
Var
  I     :       SmallInt;
begin
  inherited Init(Source^.Limit,Source^.Delta);
  _Sorted:=Source^._Sorted;
  For I:=0 To Source^.Count-1 Do
    Insert(NewStr(PString(Source^.At(I))^));
end;
{----------------------------------------------------------------------------}
function TOwnStringCollection.Compare(Key1, Key2: Pointer): SmallInt;
Var
  Res      :  SmallInt;
  A,B      :  SmallInt;

  Function _GetIndexOf(P:Pointer):SmallInt;far;
  Var
    I    :       SmallInt;
    LRes :       SmallInt;
  begin
    I:=0;
    LRes:=-1;
    While (I<=Count-1) And (LRes<0) Do
    begin
      If KeyOf(Items^[I])=P Then
         LRes:=I;
      Inc(I);
    end;
    _GetIndexOf:=LRes;
  end;

begin
(*
  Res:=inherited Compare(Key1,Key2);
  If (Res<>0) And Not(_Sorted) Then
    Res:=-1;
  Compare:=Res;
*)
  Res := 0; // force def. 29.06.04 P.W
  If Not(_Sorted) Then
  begin
    A:=_GetIndexOf(Key1);
    B:=_GetIndexOf(Key2);
    If A=B Then
       Res:=0
    else If (A=-1) Or (A>B) Then
       Res:=-1
    else If (B=-1) Or (A<B)Then
       Res:=1;
  end else
    Res:=inherited Compare(Key1,Key2);
  Compare:=Res;
end;
{----------------------------------------------------------------------------}
Constructor TOwnStringCollection.Load(Var S:TStream_TP7); { used for persistance } // "TStream" to "TStream_TP7" Chg#1511 (02.03.04 P.W)
begin
  inherited Load(S);
  S.Read(_Sorted,SizeOf(_Sorted));
end;
{----------------------------------------------------------------------------}
Procedure   TOwnStringCollection.Store(Var S:TStream_TP7);{ used for persistance } // "TStream" to "TStream_TP7" Chg#1512 (02.03.04 P.W)
begin
  inherited Store(S);
  S.Write(_Sorted,SizeOf(_Sorted));
end;
{----------------------------------------------------------------------------}
{   TOwnBufStream        =   Object(TBufStream)
{----------------------------------------------------------------------------}
Procedure   TOwnBufStream.SReadln(Var Str:String);
// Modifications:
// 01.04.08 P.W: (old code see below)
//  a) define length of returned Str when Status<>0;
//  b) accept that last line is not terminated by CR-LF:
//     - handle Ctrl-Z (#$1A) like CR-LF
//     - Ignore stReadError when Str is not empty
//     - Support files where only CR is linebreak instead of CR-LF
//  c) - Warning in case of invalid content (#00 when unicode file read)
Var
  Ch    :       Char;
  Ctr   :       SmallInt;
begin
  Str:='';     // before Exit: 01.04.08 P.W
  If Status<>0 Then Exit;
  SetLength(Str, 255); // Str[0]:=Char(255);
  Ctr:=1;
  While (Ctr<=255) And (Status=0) Do
  begin
    Read(Ch,SizeOf(Ch));
    if (Status=stReadError) then  // if:        01.04.08 P.W
    begin // probably Ch = eof (eof = #$1A = #26 = Ctrl-Z)
      SetLength(Str, Ctr-1);
      if (Ctr > 1) then //
        Status := 0;
      Ctr:=255;                       // terminates reading
    end else
    if (Ch=#$00) then  // 01.04.08 P.W
    begin
      ShowMessageFmt_(
        'Conntent of file "%s" is invalid!' +sLineBreak+
        ''                                  +sLineBreak+
        'Unicode format is not supported;'  +sLineBreak+
        'the file must be stored in "ANSI" format!',
        [File_Name]);
      Status := stReadError;
    end else
    if (Ch=#$1A) then  // 01.04.08 P.W
    begin
      SetLength(Str, Ctr-1); // Str[0]:=Char(Ctr-1);
      Ctr:=255;                       // terminates reading
    end else
    If (Ch=#13) Then
    begin
      Read(Ch,SizeOf(Ch));          // reads the LF = #10
      if (Status=stReadError) then  // accept missing LF 01.04.08 P.W
      begin                         // assume end of file
        Status := 0;
      end else
      begin                         // Back 1 Char
        if (Ch <> #10) then Seek(GetPos-1);
      end;

      SetLength(Str, Ctr-1); // Str[0]:=Char(Ctr-1);
      Ctr:=255;                       // terminates reading
    end else
      Str[Ctr]:=Ch;
    Inc(Ctr);
  end;
end;
{  // until 01.04.08 P.W:
Procedure   TOwnBufStream.SReadln(Var Str:String);
Var
  Ch    :       Char;
  Ctr   :       SmallInt;
begin
  If Status<>0 Then Exit;
  Str:='';
  SetLength(Str, 255); // Str[0]:=Char(255);
  Ctr:=1;
  While (Ctr<=255) And (Status=0) Do
  begin
    Read(Ch,SizeOf(Ch));
    If Ch=#13 Then
    begin

      Read(Ch,SizeOf(Ch));
      SetLength(Str, Ctr-1); // Str[0]:=Char(Ctr-1);
      Ctr:=255
    end else
      Str[Ctr]:=Ch;
    Inc(Ctr);
  end;
end;
}
{----------------------------------------------------------------------------}
Procedure   TOwnBufStream.SWriteln(Str:String);
Var
  Ch    :       Char;
begin
  If Status<>0 Then Exit;
  If Length(Str)>0 Then
     Write(Str[1],Length(Str));
  Ch:=#13;
  Write(Ch,SizeOf(Ch));
  Ch:=#10;
  Write(Ch,SizeOf(Ch));
(*Writeln(Str);*)
end;
{----------------------------------------------------------------------------}

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
   // none
//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
  RegisterUTGenOb;
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  RegisterUTGenOb;
   -^--- moved to function Unit_Init // 03.05.24 P.W *)

end.
