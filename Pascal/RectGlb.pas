unit RectGlb;

interface

uses
  Math, Windows, Graphics, Types;

function  RectWidth(const R: TRect): Integer;
function  RectHeight(const R: TRect): Integer;
function  CalcPercRectArea(const R1, R2: TRect): Double;
function  RectsEqual(const R1, R2: TRect): Boolean;
function  RectMove(const R: TRect; dx, dy: Integer): TRect;
function  RectR(X1, Y1, X2, Y2: Double): TRect;
function  RectFromGraphic(Gr: TGraphic; dxy:Integer=0): TRect;
function  ZeroOffsetRect(const aRect: TRect): TRect;
function  RectForCopyRect(const aRect: TRect): TRect;

Implementation
  const Unit_Name = 'RectGlb'; // 03.05.24 P.W

function  RectWidth(const R: TRect): Integer;
begin
  Result := Abs(R.Right - R.Left) +1;
end;

function  RectHeight(const R: TRect): Integer;
begin
  Result := Abs(R.Bottom - R.Top) +1;
end;

function  RectArea(const R: TRect): Integer;
begin
  Result := RectWidth(R) * RectHeight(R);
end;

function  CalcPerc(D1, D2: Integer): Double;
begin
  if (D1 = 0)
  then
    if  (D2 = 0)
      then Result := 100
      else Result := 999
  else
    Result := 100.0 * D2 / D1;
end;

function  CalcPercRectArea(const R1, R2: TRect): Double;
begin
  Result := CalcPerc(RectArea(R1), RectArea(R2));
end;

function  RectsEqual(const R1, R2: TRect): Boolean;
begin
  Result :=
    (R1.Left   = R2.Left)  and
    (R1.Top    = R2.Top)   and
    (R1.Right  = R2.Right) and
    (R1.Bottom = R2.Bottom);
end;

function  RectMove(const R: TRect; dx, dy: Integer): TRect;
begin
  Result := R;
  Inc(Result.Left,   dx);
  Inc(Result.Top,    dy);
  Inc(Result.Right,  dx);
  Inc(Result.Bottom, dy);
end;

function  RectR(X1, Y1, X2, Y2: Double): TRect;
begin
  Result := Rect(Round(X1),Round(Y1),Round(X2),Round(Y2));
end;

function  RectFromGraphic(Gr: TGraphic; dxy:Integer=0): TRect;
// coordinates cover complete Bmp:
// (0,0) to (Gr.Width-1, Gr.Height-1)
// Windows FillRect needs dxy=1 to fill the complete graphic!
begin
  Result  := Rect(0,0, Gr.Width-1+dxy, Gr.Height-1+dxy);
end;

function  ZeroOffsetRect(const aRect: TRect): TRect;
begin
  Result := Rect(0,0, RectWidth(aRect)-1, RectHeight(aRect)-1);
end;

function  RectForCopyRect(const aRect: TRect): TRect;
// Delphi.CopyRect uses Right-Left and Bottom-Top as
// Width and Height, so we have to increase Right and Bottom:
begin
  Result := aRect;
  Inc(Result.Right);
  Inc(Result.Bottom);
end;



end.
