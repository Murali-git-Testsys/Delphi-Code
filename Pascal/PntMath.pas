// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; changes: 6; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; changes: 1; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
Unit PntMath; {15.07.03 P.W}
(*
Created: {15.07.03 P.W} (from code of KN_SLC0)
Purpose: make t_point and mathematics of KN_SLC0.pas available for
         other units.
         Mainly: a) defines p_point and t_point
                 b) angular calculations rotate ...
*)

Interface
Uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List;  // 03.05.24 P.W

Const
  Disable_PntRound : Boolean = False;
  NbMax          = 8;
  NbMinEqual     = 2;
  dNeighbours    : Array [0..NbMax, 1..2] of Smallint
                   {delta coordinates of neighbours}
                   {(dX,dY)       #}
                 = (( 0, 0),     {0}
                    ( 1, 0),     {1}        {+-+-+-+}  { ^ Y     }
                    ( 1, 1),     {2}        {|4|3|2|}  { |       }
                    ( 0, 1),     {3}        {+-+-+-+}  { |       }
                    (-1, 1),     {4}        {|5|0|1|}  { +---> X }
                    (-1, 0),     {5}        {+-+-+-+}
                    (-1,-1),     {6}        {|6|7|8|}
                    ( 0,-1),     {7}        {+-+-+-+}
                    ( 1,-1));    {8}



Type
  p_point  = ^t_point;
  t_point  = Packed Record                      {! don't mix with Objects tPoint} // "Record" to "Packed Record" Chg#2936 (02.03.04 P.W)
    X, Y : Double;
  end;

Procedure IncD(Var R: Double; Delta: Double);

Procedure XY2Pnt(X, Y: Double; Var P: t_point);
function  XY2PntFunc(X, Y: Double): t_point;

Function  PntsIntDiffer(P1, P2: t_point): Boolean;
{ do points differ if rounded to Smallint? }

Procedure PntRound(Var P: t_point);

Procedure Pnt2DXDY(P: t_point; Var X, Y: Double);

Procedure Pnt2IxIy(P: t_point; Var IX, IY: Smallint);

Procedure Pnt2RxRy(P: t_point; Var RX, RY: Real);

Procedure RoundPnt2RxRy(P: t_point; Var RX, RY: Real);

Procedure DecPnt(Var P: t_point; PDelta: t_point);
{ P := P - PDelta }

Procedure IncPnt(Var P: t_point; PDelta: t_point);
{ P := P+PDelta }

Procedure AddPoints(out P: t_point; P1, P2: t_point);
{ P := P1 +P2 }

Procedure AddPointAngleFact(out P: t_point; P1: t_point; AngRad, Fact:Double);
{ P := P1 + Cos|Sin(AngRad) * Fact }

Procedure AddPointsFact(out P: t_point; P1, P2: t_point; Fact:Double);
{ P := P1 + P2 * Fact }

Procedure SubPoints(out P: t_point; P1, P2: t_point);
{ P := P1 - P2 }

Procedure PointFact(Var P: t_point; Fact: Double);
{ P := P * Fact }

Procedure PointBetweenRel(Var P: t_point; P1, P2: t_point; Fact: Double);
{ P:= P1 + Fact * (P2-P1) }

Function  CalcDist(P1, P2: t_point): Double;

Procedure PerpPoint(Var P: t_point; P1: t_point);
{Perpendicular Point
  Assuming: P and P1 from origin O (0,0);
    O-P perpendicular to O-P1
}

{Function sign(I: Smallint): Smallint;                           } {only local}
{Procedure NbLeft (dIX, dIY: Smallint; Var dIXL, dIYL: Smallint);} {only local}
{left Neighbour}
{Procedure NbRight(dIX, dIY: Smallint; Var dIXL, dIYL: Smallint);} {only local}
{right Neighbour}

Procedure PointsNbLR(P, dP: t_Point; Var NbL, NbR: t_Point);

Function  GetNeighbourNr(dP: t_Point): Smallint;

Procedure GetNormDp(Var   dP: t_point;
                    Const P1, P2: t_point; SideNorm: Double);
{dP points from P1 towards P2}

Procedure GetNormPerpDp(Var   dP: t_point;
                        Const P1, P2: t_point; SideNorm: Double);

Function  Deg2Rad(AngDeg: Double): Double;

Function  Rad2Deg(AngRad: Double): Double;

Function  NormAngRad(AngRad: Double): Double;
{Result: -pi < NormAngRad <= pi}

Function  GetAngleRad(P1, P2: t_point): Double;
{
Purpose: get an direction angle for a vector

  Quadrants:     ^Y        Angle:      _^
               2 | 1                _-A |
              ---|---> X          -+----+- 0° //OemToAnsi Chg#2942 (02.03.04 P.W)
               3 | 4
}

Function  DeltaAngleRad(P0, P1, P2: t_point): Double;

{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}

Implementation
  const Unit_Name = 'PntMath'; // 03.05.24 P.W

Procedure IncD(Var R: Double; Delta: Double);
begin
  R := R + Delta;
end;

Procedure XY2Pnt(X, Y: Double; Var P: t_point);
begin
  P.X:=X;
  P.Y:=Y;
end;

function  XY2PntFunc(X, Y: Double): t_point;
// with DELPHI may replace XY2Pnt
begin
  Result.X:=X;
  Result.Y:=Y;
end;

Function PntsIntDiffer(P1, P2: t_point): Boolean;
{ do points differ if rounded to Smallint? }
begin
  PntsIntDiffer := (Round(P1.X) <> Round(P2.X))
                   or
                   (Round(P1.Y) <> Round(P2.Y));
end;

Procedure PntRound(Var P: t_point);
begin
  If Disable_PntRound then Exit;

  P.X := Round(P.X);
  P.Y := Round(P.Y);
end;

Procedure Pnt2DXDY(P: t_point; Var X, Y: Double);
begin
  X := P.X;
  Y := P.Y;
end;

Procedure Pnt2IxIy(P: t_point; Var IX, IY: Smallint);
begin
  IX := Round(P.X);
  IY := Round(P.Y);
end;

Procedure Pnt2RxRy(P: t_point; Var RX, RY: Real);
begin
  RX := P.X;
  RY := P.Y;
end;

Procedure RoundPnt2RxRy(P: t_point; Var RX, RY: Real);
begin
  RX := Round(P.X);
  RY := Round(P.Y);
end;

Procedure DecPnt(Var P: t_point; PDelta: t_point);
{ P := P - PDelta }
begin
  IncD(P.X, -PDelta.X);
  IncD(P.Y, -PDelta.Y);
end;

Procedure IncPnt(Var P: t_point; PDelta: t_point);
{ P := P+PDelta }
begin
  IncD(P.X, PDelta.X);
  IncD(P.Y, PDelta.Y);
end;

Procedure AddPoints(out P: t_point; P1, P2: t_point);
{ P := P1 +P2 }
begin
  P.X := P1.X + P2.X;
  P.Y := P1.Y + P2.Y;
end;

Procedure AddPointAngleFact(out P: t_point; P1: t_point; AngRad, Fact:Double);
{ P := P1 + Cos|Sin(AngRad) * Fact }
begin
  P.X := P1.X + Cos(AngRad) * Fact;
  P.Y := P1.Y + Sin(AngRad) * Fact;
end;

Procedure AddPointsFact(out P: t_point; P1, P2: t_point; Fact:Double);
{ P := P1 + P2 * Fact }
begin
  P.X := P1.X + P2.X * Fact;
  P.Y := P1.Y + P2.Y * Fact;
end;

Procedure SubPoints(out P: t_point; P1, P2: t_point);
{ P := P1 - P2 }
begin
  P.X := P1.X - P2.X;
  P.Y := P1.Y - P2.Y;
end;

Procedure PointFact(Var P: t_point; Fact: Double);
{ P := P * Fact }
begin
  P.X := P.X * Fact;
  P.Y := P.Y * Fact;
end;

Procedure PointBetweenRel(Var P: t_point; P1, P2: t_point; Fact: Double);
{ P:= P1 + Fact * (P2-P1) }
begin
  P.X := P1.X + Fact * (P2.X - P1.X);
  P.Y := P1.Y + Fact * (P2.Y - P1.Y);
end;

Function CalcDist(P1, P2: t_point): Double;
begin
  CalcDist:=Sqrt(sqr(P1.X-P2.X) + sqr(P1.Y-P2.Y));
end;

Procedure PerpPoint(Var P: t_point; P1: t_point);
{Perpendicular Point
  Assuming: P and P1 from origin O (0,0);
    O-P perpendicular to O-P1
  }
Var
  H                : Double;
begin
  H   := + P1.X;
  P.X := - P1.Y;
  P.Y :=      H;
end;

Function sign(I: Smallint): Smallint;
begin
  If I < 0 then I := -1
  else
  If I > 0 then I := +1;
  sign := I;
end;

Procedure NbLeft (dIX, dIY: Smallint; Var dIXL, dIYL: Smallint);
{left Neighbour}
begin
  dIXL := sign(+ dIX - dIY);
  dIYL := sign(+ dIX + dIY);
end;

Procedure NbRight(dIX, dIY: Smallint; Var dIXL, dIYL: Smallint);
{right Neighbour}
begin
  dIXL := sign(+ dIX + dIY);
  dIYL := sign(- dIX + dIY);
end;

Procedure PointsNbLR(P, dP: t_Point; Var NbL, NbR: t_Point);
Var
  dIX, dIY : Smallint;
  dNX, dNY : Smallint;
begin
  Pnt2IXIY (dP, dIX,   dIY);

  NbLeft   (dIX, dIY, dNX, dNY);
  NbL.X    := P.X + dNX;
  NbL.Y    := P.Y + dNY;

  NbRight  (dIX, dIY, dNX, dNY);
  NbR.X    := P.X + dNX;
  NbR.Y    := P.Y + dNY;
end;

Function  GetNeighbourNr(dP: t_Point): Smallint;
Var
  dIX, dIY         : Smallint;
  Nb               : Smallint;
  Found            : Boolean;
begin
  Pnt2IXIY(dP, dIX, dIY);
  Found := False;
  Nb := 0;
  While (Nb < NbMax) and (not Found) do
  begin
    Inc(Nb);
    Found := (dIX = dNeighbours[Nb,1]) and
             (dIY = dNeighbours[Nb,2])
  end;
  If (not Found) then Nb := 0;
  GetNeighbourNr := Nb;
end;

Procedure GetNormDp(Var   dP: t_point;
                    Const P1, P2: t_point; SideNorm: Double);
{dP points from P1 towards P2}
Var
  dist             : Double;
begin
  SubPoints(dP, P2, P1);     {dP := P2-P1}
  dist  := CalcDist(P2, P1);
  If (dist = 0)
    then dist := 1;
  PointFact(dP, SideNorm / dist);   {dP := dp * 1.0 / dist}
end;

Procedure GetNormPerpDp(Var   dP: t_point;
                        Const P1, P2: t_point; SideNorm: Double);
begin
  GetNormDp(dP, P1, P2, SideNorm);
  {--- perpendicular: ---}
  PerpPoint(dP, dP);
end;

Function Deg2Rad(AngDeg: Double): Double;
begin
  Deg2Rad:=AngDeg*pi/180.0;
end;

Function Rad2Deg(AngRad: Double): Double;
begin
  Rad2Deg:=AngRad*180.0/pi;
end;

Function NormAngRad(AngRad: Double): Double;
{Result: -pi < NormAngRad <= pi}
begin
  While (AngRad > pi)
    do AngRad:= AngRad - 2.0 * pi;
  While (AngRad <= -pi)
    do AngRad:= AngRad + 2.0 * pi;
  NormAngRad := AngRad;
end;

Function GetAngleRad(P1, P2: t_point): Double;
(*  {23.10.01 P.W}
Purpose: get an direction angle for a vector
Tested see : T_GetAng.Pas
{
  Quadrants:     ^Y        Angle:      _^
               2 | 1                _-A |
              ---|---> X          -+----+- 0° //OemToAnsi Chg#2941 (02.03.04 P.W)
               3 | 4
}
*)
  Function AngleRad(SinRad, CosRad: Double): Double;
  begin
    If (CosRad <> 0.0)
      then AngleRad := ArcTan(SinRad / CosRad)
      else
        if (SinRad > 0)
          then AngleRad :=  0.5*pi
          else AngleRad := -0.5*pi;
  end;
Var
  dx, dy ,
  dxn, dyn ,
  dist       : Double;
  A          : Double;
begin {Function GetAngleRad}
  If (P1.X=P2.X) and (P1.Y=P2.Y) then
  begin
    A:=0;
  end else
  begin
    dx   := P2.X-P1.X;
    dy   := P2.Y-P1.Y;
    dist := CalcDist(P1,P2);
    dxn  := dx / dist;
    dyn  := dy / dist;
    if (dxn >= 0) then
    begin
      if (dyn >= 0) then
      begin    {Q.: 1;   0°..  90°; dx >= 0; dy >= 0} //OemToAnsi Chg#2940 (02.03.04 P.W)
        A:=  AngleRad(dyn, dxn);
      end else
      begin    {Q.: 4; 270°.. 360°; dx >= 0; dy <  0} //OemToAnsi Chg#2939 (02.03.04 P.W)
        A:=  AngleRad(dyn, dxn) + 2.0 * pi;
      end;
    end else
    begin
      if (dyn >= 0) then
      begin    {Q.: 2;  90°.. 180°; dx <  0; dy >= 0} //OemToAnsi Chg#2938 (02.03.04 P.W)
        A:=  AngleRad(dyn, dxn) + 1.0 * pi;
      end else
      begin    {Q.: 3; 180°.. 270°; dx <  0; dy <  0} //OemToAnsi Chg#2937 (02.03.04 P.W)
        A:=  AngleRad(dyn, dxn) + 1.0 * pi;
      end;
    end;
  end;
  GetAngleRad := A;
end;  {Function GetAngleRad}

Function DeltaAngleRad(P0, P1, P2: t_point): Double;
begin
  DeltaAngleRad := NormAngRad(GetAngleRad(P1,P2) - GetAngleRad(P0,P1));
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  Disable_PntRound := False;

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
