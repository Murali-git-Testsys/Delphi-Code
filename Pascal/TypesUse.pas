unit TypesUse;

interface

uses
  HaltUnit,
  Classes, Types,
  ColorModels,
  Math,
  SysUtils;

const
  Tab = #9;

type
  TColumns = Set of Byte;

  TRectS = packed record
    case Integer of
    -11: (L, T, R, B: Longint);
    - 9: (N: TRect);
    - 7: (L1, T1, W, H: Longint);
    - 5: (LT, RB: TPoint);
      0: (Left, Top, Right, Bottom: Longint);
      1: (TopLeft, BottomRight: TPoint);
  end;

  TRectD  = record
    Left, Top, Right, Bottom : Double;
  end;

  T_RectMovePnt = (
    RM_LeftTop,       // 0
    RM_MidTop,        // 1
    RM_RightTop,      // 2
    RM_LeftMid,       // 3
    RM_Center,        // 4
    RM_RightMid,      // 5
    RM_LeftBottom,    // 6
    RM_MidBottom,     // 7
    RM_RightBottom);  // 8

type
  TDoub2Arr = Array[0..1] of Double;
  PPointD = ^TPointD;
  TPointD = packed record
    X: Double;
    Y: Double;
  end;

  TCol32Hist = packed record
    Col : TCol32;
    Num : Integer;
  end;

  TColArr       = Array of TCol32;
  TColHistArr   = Array of TCol32Hist;
  TPntArr       = Array of TPoint;
  TPntDArr      = Array of TPointD;
  TSingArr      = Array of Single;
  TSingArrArr   = Array of TSingArr;
  TDoubArr      = Array of Double;
  TDoubArrArr   = Array of TDoubArr;
  TByteArr      = Array of Byte;
  TByteArrArr   = Array of TByteArr;
  TBoolArr      = Array of Boolean;
  TIntArr       = Array of Integer;
  TIntArrArr    = Array of TIntArr;
  TStringArr    = Array of AnsiString;
  TBooleanArr   = Array of Boolean;     // 24.07.09 P.W
  TMinMax       = Record
    MinVal, MaxVal : Double;
    MinIdx, MaxIdx : Integer;
    MinIdy, MaxIdy : Integer; // only used for ArrArr!
  end;


  TRectArr     = Array of TRect;

function RectD(Left, Top, Right, Bottom : Double): TRectD;
function RectD2I(RD: TRectD; df:Double=0.0): TRect;
procedure IncD(var D: Double; const delta:Double=1.0);

//#################################################################
function RectS(ALeft, ATop, ARight, ABottom: Integer): TRectS;
function ExpandRectS(R: TRectS; d: Integer): TRectS;
Function CommonRect(const R1, R2: TRect): TRect;

function Rect1Only(R1, R2: TRect):  TRectArr;
function SplitTwoRects(const RA, RB: TRect; var RA_s, RABs, R_Bs: TRectArr): Boolean;

function PositionRect(const R: TRect; nP: TPoint): TRect; overload;
function PositionRect(const R: TRect; nx, ny: Integer): TRect; overload;

function GetOffsetRect(const Rect: TRect; dx, dy: Integer): TRect; overload;
function GetOffsetRect(const Rect: TRect; dP: TPoint): TRect; overload;

procedure RectResize(var R: TRect; dx0, dy0, dx1, dy1: Integer);
function RectW(const Rect: TRect): Integer;
function RectH(const Rect: TRect): Integer;
function RectAspect(const R: TRect): Double;
function SetRectAspect(const R: TRect; Aspect: Double): TRect;
function OrderedRect(const Rect: TRect): TRect;
function PntRect(P, dp: TPoint): TRect;
function PntRel2FromRect(const R: TRect; XRel2, YRel2: Integer): TPoint;

function PointsAdd(A, B: TPoint): TPoint;   overload;
function PointsAdd(A: TPoint; B: TPointD): TPointD;   overload;
function PointsAdd(A: TPointD; B: TPoint): TPointD;   overload;
function PointsAdd(A, B: TPointD): TPointD; overload;

function PointsSub(A, B: TPoint): TPoint;   overload;
function PointsSub(A: TPoint; B: TPointD): TPointD;   overload;
function PointsSub(A: TPointD; B: TPoint): TPointD;   overload;
function PointsSub(A, B: TPointD): TPointD; overload;

function PntNrFromRect(const R: TRect; Nr: Integer): TPoint;
//  0     1      2
//  3     4      5
//  6     7      8
function  RectExpand(const R: TRect; dX, dY: Integer): TRect;  overload;
function  RectExpand(const R: TRect; dXY: Integer): TRect;  overload;
function  RectExpand(const R: TRect; dP: TPoint): TRect;  overload;
function RectMinWidthHeight(R: TRect): Integer;
function RectMaxWidthHeight(R: TRect): Integer;
function PntDistSqr(A, B: TPoint): Integer;
function  RectPntNrFromXY(const R: TRect; pXY: TPoint): Integer;
//#################################################################


function PntMult(const A: TPoint; fact: Double): TPoint;   overload;
function PntMult(const A: TPointD; fact: Double): TPointD; overload;
function PntMult(const A, B: TPointD): TPointD; overload;
function PntMult(const A: TPntDArr; fact: Double): TPntDArr; overload;

procedure PntInc(var A: TPoint; B: TPoint); overload;
procedure PntDec(var A: TPoint; B: TPoint); overload;

function PntAdd (const A, B: TPoint): TPoint; overload;
function PntAdd (const A, B: TPointD): TPointD; overload;
function PntAdd (const A, B: TPntDArr): TPntDArr; overload;

function PntDiff(const A, B: TPoint): TPoint; overload;
function PntDiff(const A, B: TPointD): TPointD; overload;
function PntDiff(const A, B: TPntDArr): TPntDArr; overload;

function PntDist(A, B: TPoint):  Double; overload;
function PntDist(A: TPoint; B: TPointD): Double; overload;
function PntDist(A: TPointD; B: TPoint): Double; overload;
function PntDist(A, B: TPointD): Double; overload;

function PointsDEqual(const A, B: TPointD; Tolerance: Double): Boolean;

//#################################################################
procedure ArrWH(const A: TIntArrArr; var W, H: Integer); overload;
procedure ArrWH(const A: TDoubArrArr; var W, H: Integer); overload;



function StrArrToString(const StrArr: TStringArr): AnsiString;

function IntArrToDoubArr(const IArr: TIntArr): TDoubArr;
function StringToIntArr(const S: AnsiString; Delimiter: Char): TIntArr;
function StringToDoubArr(const S: AnsiString; Delimiter: Char=Tab): TDoubArr;
function  TStringList_Create(const SArr: Array of AnsiString): TStringList;
procedure StringAppendToStringList(SL: TStringList; const S: AnsiString; Delimiter: Char=Tab);
function StringToStringList(const S: AnsiString; Delimiter: Char=Tab): TStringList;

function IntArrToRect(const IArr: TIntArr): TRect;
function IntArrToString(const IArr: TIntArr;              Msg: String= ''; Fmt: String=''): AnsiString;
function IntArrToStringList(const IArr: TIntArr;              Msg: String= ''; Fmt: String=''): TStringList;
function IntArrArrToStringList(const IArrArr: TIntArrArr; Msg: String= ''; Fmt: String=''): TStringList;
function IntArrArrToStringArr (const IArrArr: TIntArrArr; Msg: String= ''; Fmt: String=''): TStringArr;

function DoubArrToString(const DArr: TDoubArr;              Msg: String= ''; Fmt: String=''): AnsiString;
function DoubArrToStringArr(const DArr: TDoubArr; Msg: String= ''; Fmt: String=''): TStringArr;
function DoubArrToStringList(const DArr: TDoubArr; Fmt:AnsiString='%1.6f'): TStringList;
function DoubArrArrToStringList(const DArrArr: TDoubArrArr; Msg: String= ''; Fmt: String=''): TStringList;
procedure DoubArrArrAppendToStringList(Res: TStringList; const DArrArr: TDoubArrArr; Msg: String; Fmt: String; IdxOffset: Integer);
function DoubArrArrToStringArr (const DArrArr: TDoubArrArr; Msg: String= ''; Fmt: String=''; HeaderFlg:Boolean=True): TStringArr;

procedure PointToXY(const Pnt: TPointD; var x, y: Double);
function PointD(x, y: Double): TPointD;
function ConvertToPntDArr(DArr: Array of TPointD): TPntDArr;
function ConvertToDoubArr(DArr: Array of Double): TDoubArr;
function ConvertToIntArr (IArr: Array of Integer): TIntArr;
function ConvertToStringArr (SArr: Array of AnsiString): TStringArr;
function ConvertToBooleanArr (BArr: Array of Boolean): TBooleanArr;

function IntArrEqual(const IArrA, IArrB: TIntArr): Boolean;

function DoubArrEqual(const DArrA, DArrB: TDoubArr; Tolerance: Double = 0.0): Boolean;
function DoubArrArrEqual(const DArrArrA, DArrArrB: TDoubArrArr): Boolean;

function IntArrsConcat(const IArrA, IArrB: TIntArr): TIntArr;

function DoubArrsConcat(const DArrA, DArrB: TDoubArr): TDoubArr;
function DoubArrArrsConcat2ndIdx(const DArrArrA, DArrArrB: TDoubArrArr; SinglePart:Boolean=True): TDoubArrArr;

function DoubArrSubSet(const DArr: TDoubArr; Index, Count: Integer): TDoubArr;
function DoubArrMean(const DArr: TDoubArr): Double;
function DoubArrSubMean(const DArr: TDoubArr; Index, Count: Integer): Double;

function DoubArrRevert(a: TDoubArr): TDoubArr;
function DoubArrSelectColumns(const DArr: TDoubArr; Columns: TColumns): TDoubArr;

function DoubArrFiner(const a: TDoubArr; Factor: Integer): TDoubArr;
function DoubArrsAdd(a, b: TDoubArr): TDoubArr;
function DoubArrsSub(a, b: TDoubArr): TDoubArr;
function DoubArrsRadius(Re, Im: TDoubArr): TDoubArr;
function DoubArrsLog2(a: TDoubArr): TDoubArr;
function DoubArrsLog10(a: TDoubArr): TDoubArr;
function DoubArrsLogN(a: TDoubArr; Base : Double): TDoubArr;

function DoubArrScale(a: TDoubArr; Factor: Double): TDoubArr;
function IntArrScale(a: TIntArr; Factor: Double): TIntArr;
function DoubArrMinMax(const a: TDoubArr): TMinMax; overload;
function DoubArrMinMax(const a: Array of Double): TMinMax; overload;
function DoubArrArrMinMax(a: TDoubArrArr): TMinMax;
function DoubArrMin(a: TDoubArr): Double;
function DoubArrMax(a: TDoubArr): Double;
function DoubArrArrMin(a: TDoubArrArr): Double;
function DoubArrArrMax(a: TDoubArrArr): Double;
function DoubArrArrScale(a: TDoubArrArr; Factor: Double): TDoubArrArr;
function DoubArrArrCopy(a: TDoubArrArr): TDoubArrArr;
function DoubArrFromDoubArrArr(a: TDoubArrArr): TDoubArr;

function StrCompareStr(StrA, StrB: AnsiString; ChEqu:Char='='; ChDif:Char='!'): AnsiString;

function DoubArrAllZero(Len: Integer): TDoubArr;
function IntArrAllZero(Len: Integer): TIntArr;
function IntArrAllSame(Len: Integer; Value: Integer=0): TIntArr;
function DoubArrAllSame(Len: Integer; Value: Double=0): TDoubArr;
function DoubArrAllEquIdx(Len: Integer; Offset: Double = 0.0): TDoubArr;
function IntArrAllEquIdx(Len: Integer; Offset: Integer =0): TIntArr;
function BoolArrAll(Len: Integer; Value: Boolean = False): TBoolArr;
function DoubArrAllOne(Len: Integer): TDoubArr;
function DoubArrFirstOne(Len: Integer): TDoubArr;
function DoubArrCenterOne(Len: Integer): TDoubArr;
function DoubArrFirstHalfOne(Len: Integer): TDoubArr;

procedure GetLength(const DArrArr: TDoubArrArr; var LenX, LenY : Integer); overload;
procedure GetLength(const IArrArr: TIntArrArr; var LenX, LenY : Integer); overload;
procedure GetLength(const BArrArr: TByteArrArr; var LenX, LenY : Integer); overload;
//procedure DoubArrsExchange(var a, b: TDoubArr);
function  DoubArrArrTranspose(const DArrArr: TDoubArrArr): TDoubArrArr;

function  DoubArrCenterSetZeros(const DArr: TDoubArr; NumZeros: Integer): TDoubArr;
//function  DoubArrCenterInsZeros(const DArr: TDoubArr; NumZeros: Integer): TDoubArr;
procedure DoubArrCenterInsZeros(var DArr: TDoubArr; NumZeros: Integer);
procedure DoubArrArrCenterInsZeroArr(var D2: TDoubArrArr; NumZeroLines: Integer);

function DoubArrNumberedFilled(Len: Integer; Start, Delta: Double): TDoubArr;
function DoubArrArrNumberedFilled(LenX, LenY, Start, DeltaX, DeltaY: Integer): TDoubArrArr; overload;
function DoubArrArrNumberedFilled(LenX, LenY: Integer; Start: Integer= 0; Delta: Integer =1): TDoubArrArr; overload;
function DoubArrArrZoom(const D2: TDoubArrArr; ZoomX, ZoomY : Integer): TDoubArrArr;

procedure DoubArrAppend(var DArr: TDoubArr; Val: Double);
procedure DoubArrDelItem(var DArr: TDoubArr; Idx: Integer);

procedure IntArrAppend(var IArr: TIntArr; Val: Integer);
procedure IntArrDelItem(var IArr: TIntArr; Idx: Integer);

procedure IntArrArrAppend(var IArrArr: TIntArrArr; IArr: TIntArr);

function  IntArrSortFunc(const IArr: TIntArr; Ascending:Boolean=True): TIntArr;
procedure IntArrSortProc(var IArr: TIntArr; Ascending:Boolean=True);
function  IntArrSortFuncIdx(const IArr: TIntArr; Ascending:Boolean=True): TIntArr;
procedure IntArrArrSortKeyProc(var IArrArr: TIntArrArr; const KeyArr: TIntArr; Ascending:Boolean=True);

function  IntArrFind(const IArr: TIntArr; Value: Integer; Offset: Integer=0): Integer;
function  IntArrMinMax(const a: TIntArr): TMinMax;
function  IntArrAppendCheck(var IArr: TIntArr; Value: Integer): Boolean;

Implementation

uses StrUtils;
  const Unit_Name = 'TypesUse'; // 03.05.24 P.W

function RectD(Left, Top, Right, Bottom : Double): TRectD;
begin
  Result.Left   := Left;
  Result.Top    := Top;
  Result.Right  := Right;
  Result.Bottom := Bottom;
end;

function RectD2I(RD: TRectD; df:Double=0.0): TRect;
begin
  Result := Rect(
    Round(RD.Left  +df),
    Round(RD.Top   +df),
    Round(RD.Right -df),
    Round(RD.Bottom-df));
end;

procedure IncD(var D: Double; const delta:Double=1.0);
begin
  D := D + delta;
end;

//#################################################################
function RectS(ALeft, ATop, ARight, ABottom: Integer): TRectS;
begin
  Result := TRectS(Types.Rect(ALeft, ATop, ARight, ABottom));
end;

function ExpandRectS(R: TRectS; d: Integer): TRectS;
begin
  Result := RectS(R.L-d, R.T-d, R.R+d, R.B+d);
end;

Function CommonRect(const R1, R2: TRect): TRect;
// compare with InterSectRect
// supports rects where Left > Right...
begin
  Result.Left   := Min(Min(R1.Left, R1.Right),  Min(R2.Left, R2.Right));
  Result.Right  := Max(Max(R1.Left, R1.Right),  Max(R2.Left, R2.Right));
  Result.Top    := Min(Min(R1.Top,  R1.Bottom), Min(R2.Top,  R2.Bottom));
  Result.Bottom := Max(Max(R1.Top,  R1.Bottom), Max(R2.Top,  R2.Bottom));
end;

function Rect1Only(R1, R2: TRect):  TRectArr;
// returns all parts of R1 that are not covered by R2
// assumes Left <= Right, Top <= Bottom
// may return 0 up to 4 rectangles!
  procedure AddRect(R: TRect); overload;
  begin
    SetLength(Result, Length(Result)+1);
    Result[Length(Result)-1] := R;
  end;
  procedure AddRect(Left, Top, Right, Bottom: Integer); overload;
  begin
    AddRect(Rect(Left, Top, Right, Bottom));
  end;
var
  IR : TRect;
begin
  SetLength(Result, 0);
  If InterSectRect(IR, R1, R2) then
  begin
    if IR.Left > R1.Left then
    begin  // Left side band
      AddRect(R1.Left,  R1.Top, IR.Left, R1.Bottom);
      R1.Left := IR.Left;
    end;
    if IR.Right < R1.Right then
    begin // Right side band
      AddRect(IR.Right,  R1.Top, R1.Right, R1.Bottom);
      R1.Right := IR.Right;
    end;
    if IR.Top > R1.Top then
    begin  // Top band
      AddRect(R1.Left,  R1.Top, R1.Right, IR.Top);
      R1.Top := IR.Top;
    end;
    if IR.Bottom < R1.Bottom then
    begin  // Bottom band
      AddRect(R1.Left,  IR.Bottom, R1.Right, R1.Bottom);
      R1.Top := IR.Top;
    end;
  end else
  begin  // R1 complete outside R2
    AddRect(R1);
  end;
end;

function SplitTwoRects(const RA, RB: TRect; var RA_s, RABs, R_Bs: TRectArr): Boolean;
// returns false if no InterSectRect exists
// compare function Rect1Only
// RA_s : all parts of RA that are not covered by RB   (0 up to 4 rectangles)
// RABs : all parts of RA that are     covered by RB   (0 up to 1 rectangle )
// R_Bs : all parts of RB that are not covered by RA   (0 up to 4 rectangles)
// assumes Left <= Right, Top <= Bottom
var
  IR : TRect;
begin
  Result := InterSectRect(IR, RA, RB);
  If Result then
  begin
    RA_s    := Rect1Only(RA, RB);

    SetLength(RABs, 1);
    RABs[0] := IR;

    R_Bs    := Rect1Only(RB, RA);
  end else
  begin
    SetLength(RA_s, 1);
    RA_s[0] := RA;

    SetLength(RABs, 0);

    SetLength(R_Bs, 1);
    R_Bs[0] := RB;
  end;

end;

function PositionRect(const R: TRect; nx, ny: Integer): TRect; overload;
var
  W, H : Integer;
begin
  W := R.Right  - R.Left;
  H := R.Bottom - R.Top;
  Result := Rect(nx, ny, nx + W, ny + H);
end;

function PositionRect(const R: TRect; nP: TPoint): TRect; overload;
begin
  Result := PositionRect(R, nP.X, nP.Y);
end;

function GetOffsetRect(const Rect: TRect; dx, dy: Integer): TRect; overload;
begin
  Result := Rect;
  Types.OffsetRect(Result, dx, dy);
end;

function GetOffsetRect(const Rect: TRect; dP: TPoint): TRect; overload;
begin
  Result := GetOffsetRect(Rect, dP.X, dP.Y);
end;

procedure RectResize(var R: TRect; dx0, dy0, dx1, dy1: Integer);
begin
  Inc(R.Left,   dx0);
  Inc(R.Top,    dy0);
  Inc(R.Right,  dx1);
  Inc(R.Bottom, dy1);
end;

function RectW(const Rect: TRect): Integer;
begin
  Result := Abs(Rect.Right - Rect.Left);
end;

function RectH(const Rect: TRect): Integer;
begin
  Result := Abs(Rect.Bottom - Rect.Top);
end;

function RectAspect(const R: TRect): Double;
begin
  Result := Max(1, RectH(R)) / Max(1, RectW(R));
end;

function SetRectAspect(const R: TRect; Aspect: Double): TRect;
// Ascect: Height / Width
var
  ChangeW : Boolean;
  RW, RH : Integer;
begin
  Result := R;
  RW := RectW(R);
  RH := RectH(R);
  ChangeW := (RW < RH);
//  if (Aspect < 1) then ChangeW := not ChangeW;
  if ChangeW
    then Result.Right  := R.Left + Round(RH / Aspect)
    else Result.Bottom := R.Top  + Round(RW * Aspect);
end;

function OrderedRect(const Rect: TRect): TRect;
begin
  Result.Left   := Min(Rect.Left, Rect.Right);
  Result.Right  := Max(Rect.Left, Rect.Right);
  Result.Top    := Min(Rect.Top , Rect.Bottom);
  Result.Bottom := Max(Rect.Top , Rect.Bottom);
end;

function PntRect(P, dp: TPoint): TRect;
begin
  Result := Rect(P.X-dp.X, P.Y-dp.Y, P.X+dp.X, P.Y+dP.Y);
end;

function PntRel2FromRect(const R: TRect; XRel2, YRel2: Integer): TPoint;
begin
  Result.X :=  (XRel2 * (R.Right  - R.Left)) div 2 + R.Left;
  Result.Y :=  (YRel2 * (R.Bottom - R.Top )) div 2 + R.Top;
end;

function PointsAdd(A, B: TPoint): TPoint;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
end;

function PointsAdd(A: TPoint; B: TPointD): TPointD;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
end;

function PointsAdd(A: TPointD; B: TPoint): TPointD;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
end;

function PointsAdd(A, B: TPointD): TPointD;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
end;

function PointsSub(A, B: TPoint): TPoint;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
end;

function PointsSub(A: TPoint; B: TPointD): TPointD;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
end;

function PointsSub(A: TPointD; B: TPoint): TPointD;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
end;

function PointsSub(A, B: TPointD): TPointD;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
end;

function PntNrFromRect(const R: TRect; Nr: Integer): TPoint;
//  0     1      2
//  3     4      5
//  6     7      8
begin
  Case Nr of
    0: Result := R.TopLeft;
    1: Result := PntRel2FromRect(R, 1, 0);
    2: Result := PntRel2FromRect(R, 2, 0);
    3: Result := PntRel2FromRect(R, 0, 1);
    4: Result := PntRel2FromRect(R, 1, 1);
    5: Result := PntRel2FromRect(R, 2, 1);
    6: Result := PntRel2FromRect(R, 0, 2);
    7: Result := PntRel2FromRect(R, 1, 2);
    8: Result := R.BottomRight;
  end;
end;

function  RectExpand(const R: TRect; dX, dY: Integer): TRect;  overload;
begin
  Result.Left   := R.Left   - dX;
  Result.Top    := R.Top    - dY;
  Result.Right  := R.Right  + dX;
  Result.Bottom := R.Bottom + dY;
end;

function  RectExpand(const R: TRect; dXY: Integer): TRect;  overload;
begin
  Result := RectExpand(R, dXY, dXY);
end;

function  RectExpand(const R: TRect; dP: TPoint): TRect;  overload;
begin
  Result := RectExpand(R, dP.X, dP.Y);
end;


function RectMinWidthHeight(R: TRect): Integer;
begin
  Result := Min(RectW(R), RectH(R));
end;

function RectMaxWidthHeight(R: TRect): Integer;
begin
  Result := Max(RectW(R), RectH(R));
end;

function PntDistSqr(A, B: TPoint): Integer;
begin
  A := PointsSub(A,B);
  Result := A.X * A.X + A.Y * A.Y;
end;

function  RectPntNrFromXY(const R: TRect; pXY: TPoint): Integer;
const
  dp = 8;
var
  N, Nmin : Integer;
  D, DistSqrMin : Integer;
begin
  if PtInRect(RectExpand(R, dp, dp), pXY) then
  begin
    DistSqrMin := MaxInt;
    NMin := 0;            // 08.01.09 P.W
    for N := 0 to 8 do
    begin
      D := PntDistSqr(PntNrFromRect(R, N), pXY);
      if (D < DistSqrMin) then
      begin
        DistSqrMin := D;
        Nmin := N;
      end;
    end;
    Result := NMin;
  end else
  begin
    Result := -1;
  end;
end;

//#################################################################

function PntMult(const A: TPoint; fact: Double): TPoint;
begin
  Result.X := Round(A.X * fact);
  Result.Y := Round(A.Y * fact);
end;

function PntMult(const A: TPointD; fact: Double): TPointD;
begin
  Result.X := A.X * fact;
  Result.Y := A.Y * fact;
end;

function PntMult(const A, B: TPointD): TPointD;
begin
  Result.X := A.X * B.X;
  Result.Y := A.Y * B.Y;
end;

function PntMult(const A: TPntDArr; fact: Double): TPntDArr;
var
  Len, I : Integer;
begin
  Len := Length(A);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := PntMult(Result[I], fact);
end;

procedure PntInc(var A: TPoint; B: TPoint);
begin
  A := PntAdd(A, B);
end;

procedure PntDec(var A: TPoint; B: TPoint);
begin
  A := PntDiff(A, B);
end;


function PntAdd (const A, B: TPoint): TPoint;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
end;

function PntAdd (const A, B: TPointD): TPointD;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
end;

function PntAdd (const A, B: TPntDArr): TPntDArr;
var
  Len, I : Integer;
begin
  Len := Min(Length(A), Length(B));
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := PntAdd (A[I], B[I]);
end;

function PntDiff(const A, B: TPoint): TPoint;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
end;

function PntDiff(const A, B: TPointD): TPointD;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
end;

function PntDiff(const A, B: TPntDArr): TPntDArr;
var
  Len, I : Integer;
begin
  Len := Min(Length(A), Length(B));
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := PntDiff(A[I], B[I]);
end;

function PntDist(A, B: TPoint): Double;
begin
  A := PointsSub(A,B);
  Result := Sqrt(A.X * A.X + A.Y * A.Y);
end;

function PntDist(A: TPoint; B: TPointD): Double;
begin
  B := PointsSub(A,B);
  Result := Sqrt(A.X * A.X + A.Y * A.Y);
end;

function PntDist(A: TPointD; B: TPoint): Double;
begin
  A := PointsSub(A,B);
  Result := Sqrt(A.X * A.X + A.Y * A.Y);
end;

function PntDist(A, B: TPointD): Double;
begin
  A := PointsSub(A,B);
  Result := Sqrt(A.X * A.X + A.Y * A.Y);
end;

function PointsDEqual(const A, B: TPointD; Tolerance: Double): Boolean;
begin
  Result := (Abs(A.X - B.X) <= Tolerance) and (Abs(A.Y - B.Y) <= Tolerance);
end;

//#################################################################

procedure ArrWH(const A: TIntArrArr; var W, H: Integer); overload;
begin
  H  := Length(A);
  if H > 0
    then W := Length(A[0])
    else W := 0;
end;

procedure ArrWH(const A: TDoubArrArr; var W, H: Integer); overload;
begin
  H  := Length(A);
  if H > 0
    then W := Length(A[0])
    else W := 0;
end;


function StrArrToString(const StrArr: TStringArr): AnsiString;
var
  Len, I : Integer;
begin
  Len := Length(StrArr);
  Result := '';
  for I := 0 to Len -1 do
    Result := Result + StrArr[I] + sLineBreak;
end;

function IntArrToDoubArr(const IArr: TIntArr): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Length(IArr);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := IArr[I];
end;

function IntArrToRect(const IArr: TIntArr): TRect;
begin
  if Length(IArr) >= 4 then
  begin
    Result := Rect(IArr[0],IArr[1],IArr[2],IArr[3]);
  end else
  begin
    Result := Rect(0,0,0,0);
  end;
end;

function IntArrToString(const IArr: TIntArr;              Msg: String= ''; Fmt: String=''): AnsiString;
var
  I : Integer;
begin
  if Fmt = '' then Fmt := '%10d';
//  if Msg = '' then Result := ''
//              else Result := Msg+#9;
  Result := Msg;
  for I := 0 to Length(IArr) -1 do
    Result := Result + #9 + Format(fmt, [IArr[I]]);
end;

function IntArrToStringList(const IArr: TIntArr;              Msg: String= ''; Fmt: String=''): TStringList;
var
  I : Integer;
begin
  if Fmt = '' then Fmt := '%10d';
  Result := TStringList.Create;
  if Msg <> '' then
    Result.Append(Msg);
  for I := 0 to Length(IArr) -1 do
    Result.Append(Format(fmt, [IArr[I]]));
end;

function StringToIntArr(const S: AnsiString; Delimiter: Char): TIntArr;
var
  LenR, LenS, P: Integer;
  H : String;
  procedure Append;
  begin
    if H = '' then exit;
    Inc(LenR);
    SetLength(Result, LenR);
    Result[LenR -1] := StrToIntDef(H, 0);
    H := '';
  end;
begin
  LenR := 0;
  SetLength(Result, LenR);
  LenS := Length(S);
  P := 1;
  H := '';
  While P <= LenS do
  begin
    Case S[P] of
      '0'..'9','a'..'f', 'A'..'F','+','-','$':
        H := H + S[P];
      else
        begin
          if S[P] = Delimiter then
          begin
            Append;
          end;
        end;
    end;
    Inc(P);
  end;
  Append;
end;

function StringToDoubArr(const S: AnsiString; Delimiter: Char=Tab): TDoubArr;
// Modifications
// 27.11.09 P.W
//  do not ignore "," use it as "." (example: 58,0 not to 580 but to 58.0)
var
  LenR, LenS, P: Integer;
  H : String;
  procedure Append;
  begin
    if H = '' then exit;
    Inc(LenR);
    SetLength(Result, LenR);
    Result[LenR -1] := StrToFloatDef(H, 0);
    H := '';
  end;
begin
  LenR := 0;
  SetLength(Result, LenR);
  LenS := Length(S);
  P := 1;
  H := '';
  While P <= LenS do
  begin
    Case S[P] of
      ',':    // 27.11.09 P.W
        H := H + '.';
      '.',
      '0'..'9','a'..'f', 'A'..'F','+','-','$':
        H := H + S[P];
      else
        begin
          if S[P] = Delimiter then
          begin
            Append;
          end;
        end;
    end;
    Inc(P);
  end;
  Append;
end;

function  TStringList_Create(const SArr: Array of AnsiString): TStringList;
var
  Lo, Hi, I : Integer;
begin
  Lo := Low (SArr);
  Hi := High(SArr);

  Result := TStringList.Create;
  for I := Lo to Hi do
    Result.Append(SArr[I]);
end;



procedure StringAppendToStringList(SL: TStringList; const S: AnsiString; Delimiter: Char=Tab);
var
  Len, P0, P : Integer;
begin
  Len := Length(S);
  P0 := 0;
  Repeat
    P := PosEx(Delimiter, S, P0+1);
    if P = 0 then P:=Len+1;
    SL.Append(Copy(S, P0+1, P-P0-1));
    P0 := P;
  until P > Len;
end;

function StringToStringList(const S: AnsiString; Delimiter: Char=Tab): TStringList;
begin
  Result := TStringList.Create;
  StringAppendToStringList(Result, S, Delimiter);
end;

(*
function StringToIntArr(const S: AnsiString; Delimiter: Char): TIntArr;
var
  LenR, LenS, P0, P1 : Integer;
    function DelimPos: Boolean;
    begin
      Result := P1 < LenS;
      P0 := P1 + 1;
      P1:= PosEx(Delimiter, S, P0);
      if P1 <= P0 then P1 := LenS + 1;

      While (P0 < P1) and (S[P0] in [' ', #9]) do inc(P0);
    end;
begin
  LenR := 0;
  SetLength(Result, LenR);
  LenS := Length(S);
  P1 := 0;
  While DelimPos do
  begin
    Inc(LenR);
    SetLength(Result, LenR);
    Result[LenR -1] := StrToIntDef(Copy(S, P0, P1-P0), 0);
  end;
end;
*)

function IntArrArrHeadLine(const IArrArr: TIntArrArr; Msg: String= ''; Fmt: String=''): AnsiString;
var
  Len, LenI, I : Integer;
  IntArr : TIntArr;
begin
  Len    := Length(IArrArr);
  if Len > 0
    then LenI := Length(IArrArr[0])
    else LenI := 0;
  SetLength(IntArr, LenI);
  for I := 0 to LenI -1 do
    IntArr[I]:= I;
  Result := IntArrToString(IntArr, Msg, '');
end;

function IntArrArrToStringList(const IArrArr: TIntArrArr; Msg: String= ''; Fmt: String=''): TStringList;
var
  I : Integer;
begin
  Result := TStringList.Create;
  Result.Append(IntArrArrHeadLine(IArrArr, Msg, Fmt));
  for I := 0 to Length(IArrArr) -1 do
    Result.Append(IntArrToString(IArrArr[I], Msg + Format('(%2d)', [I]), Fmt));
end;

function IntArrArrToStringArr(const IArrArr: TIntArrArr; Msg: String= ''; Fmt: String=''): TStringArr;
var
  Len, I : Integer;
begin
  Len := Length(IArrArr);
  SetLength(Result, Len+1);
  Result[0] := IntArrArrHeadLine(IArrArr, Msg, Fmt);
  for I := 0 to Len -1 do
    Result[I+1] := IntArrToString(IArrArr[I], Msg + Format('(%2d)', [I]), Fmt);
end;

function DoubToString(const Doub: Double;              Msg: String= ''; Fmt: String=''): AnsiString;
begin
  if Fmt = '' then Fmt := '%15.5f';  // alternatives: '%1.5e' -> "-1.1234E-005"
  Result := Msg + #9 + Format(fmt, [Doub]);
end;

function DoubArrToString(const DArr: TDoubArr;              Msg: String= ''; Fmt: String=''): AnsiString;
var
  I : Integer;
begin
//  if Msg = '' then Result := ''
//              else Result := Msg+#9;
  Result := Msg;
  for I := 0 to Length(DArr) -1 do
    Result := Result + DoubToString(DArr[I], '', Fmt);
end;

function DoubArrToStringArr(const DArr: TDoubArr; Msg: String= ''; Fmt: String=''): TStringArr;
var
  Len, I : Integer;
begin
  Len := Length(DArr);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := Msg + DoubToString(DArr[I], Format('(%2d)', [I]), Fmt);
end;

function DoubArrToStringList(const DArr: TDoubArr; Fmt:AnsiString='%1.6f'): TStringList;
var
  Len, I : Integer;
begin
  Result := TStringList.Create;
  Len := Length(DArr);
  for I := 0 to Len -1 do
    Result.Append(Format(Fmt, [DArr[I]]));
end;

function DoubArrArrHeadLine(const DArrArr: TDoubArrArr; Msg: String= ''; Fmt: String=''): AnsiString;
var
  Len, LenI, I : Integer;
  IntArr : TIntArr;
begin
  Len    := Length(DArrArr);
  if Len > 0
    then LenI := Length(DArrArr[0])
    else LenI := 0;
  SetLength(IntArr, LenI);
  for I := 0 to LenI -1 do
    IntArr[I]:= I;
  Result := IntArrToString(IntArr, Msg, '');
end;

function DoubArrArrToStringList(const DArrArr: TDoubArrArr; Msg: String= ''; Fmt: String=''): TStringList;
var
  I : Integer;
begin
  Result := TStringList.Create;
  Result.Append(DoubArrArrHeadLine(DArrArr, Msg, Fmt));
  for I := 0 to Length(DArrArr) -1 do
    Result.Append(DoubArrToString(DArrArr[I], Msg + Format('(%2d)', [I]), Fmt));
end;

procedure DoubArrArrAppendToStringList(Res: TStringList; const DArrArr: TDoubArrArr; Msg: String; Fmt: String; IdxOffset: Integer);
var
  I : Integer;
begin
  for I := 0 to Length(DArrArr) -1 do
    Res.Append(DoubArrToString(DArrArr[I], Msg + Format('%2d', [I + IdxOffset]), Fmt));
end;

function DoubArrArrToStringArr(const DArrArr: TDoubArrArr; Msg: String= ''; Fmt: String=''; HeaderFlg:Boolean=True): TStringArr;
var
  Len, I : Integer;
begin
  Len := Length(DArrArr);
  if HeaderFlg then
  begin
    SetLength(Result, Len+1);
    Result[0] := DoubArrArrHeadLine(DArrArr, Msg, Fmt);
    for I := 0 to Len -1 do
      Result[I+1] := DoubArrToString(DArrArr[I], Msg + Format('(%2d)', [I]), Fmt);
  end else
  begin
    SetLength(Result, Len);
    for I := 0 to Len -1 do
      Result[I] := DoubArrToString(DArrArr[I], Msg + Format('(%2d)', [I]), Fmt);
  end;
end;

procedure PointToXY(const Pnt: TPointD; var x, y: Double);
begin
  x := Pnt.X;
  y := Pnt.Y;
end;

function PointD(x, y: Double): TPointD;
begin
  Result.X := x;
  Result.Y := y;
end;

function ConvertToPntDArr(DArr: Array of TPointD): TPntDArr;
var
  Len, I : Integer;
begin
  Len := Length(DArr);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := DArr[I];
end;

function ConvertToDoubArr(DArr: Array of Double): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Length(DArr);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := DArr[I];
end;

function ConvertToIntArr (IArr: Array of Integer): TIntArr;
var
  Len, I : Integer;
begin
  Len := Length(IArr);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := IArr[I];
end;

function ConvertToStringArr (SArr: Array of AnsiString): TStringArr;
// 24.07.09 P.W
var
  Len, I : Integer;
begin
  Len := Length(SArr);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := SArr[I];
end;

function ConvertToBooleanArr (BArr: Array of Boolean): TBooleanArr;
// 24.07.09 P.W
var
  Len, I : Integer;
begin
  Len := Length(BArr);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := BArr[I];
end;


function IntArrEqual(const IArrA, IArrB: TIntArr): Boolean;
var
  Len, I : Integer;
begin
  Result := False;

  Len := Length(IArrA);
  if (Len <> Length(IArrB)) then EXIT;

  for I := 0 to Len -1 do
    if IArrA[I] <> IArrB[I] then EXIT;

  Result := True;
end;

function DoubArrEqual(const DArrA, DArrB: TDoubArr; Tolerance: Double = 0.0): Boolean;
var
  Len, I : Integer;
begin
  Result := False;

  Len := Length(DArrA);
  if (Len <> Length(DArrB)) then EXIT;

  for I := 0 to Len -1 do
    if Abs(DArrA[I] - DArrB[I]) > Tolerance then EXIT;

  Result := True;
end;

function DoubArrArrEqual(const DArrArrA, DArrArrB: TDoubArrArr): Boolean;
var
  Len, I : Integer;
begin
  Result := False;

  Len := Length(DArrArrA);
  if (Len <> Length(DArrArrB)) then EXIT;

  for I := 0 to Len -1 do
    if not DoubArrEqual(DArrArrA[I],  DArrArrB[I]) then EXIT;

  Result := True;
end;

function IntArrsConcat(const IArrA, IArrB: TIntArr): TIntArr;
var
  LenA, LenB, I: Integer;
begin
  LenA := Length(IArrA);
  LenB := Length(IArrB);
  Result := Copy(IArrA);
  // Append DArrB to Result:
  SetLength(Result, LenA+LenB);
  for I := 0 to LenB -1 do
    Result[LenA+I] := IArrB[I];
end;

function DoubArrsConcat(const DArrA, DArrB: TDoubArr): TDoubArr;
var
  LenA, LenB, I: Integer;
begin
  LenA := Length(DArrA);
  LenB := Length(DArrB);
  Result := Copy(DArrA);
  // Append DArrB to Result:
  SetLength(Result, LenA+LenB);
  for I := 0 to LenB -1 do
    Result[LenA+I] := DArrB[I];
end;

function DoubArrArrsConcat2ndIdx(const DArrArrA, DArrArrB: TDoubArrArr; SinglePart:Boolean=True): TDoubArrArr;
var
  Len1stIdxA,      // Length of 1st Index of DArrArrA
  Len1stIdxB,      // Length of 1st Index of DArrArrB
  Len1stIdxC,      // Length of 1st Index common by A and B
  Len1stIdxR,      // Length of 1st Index of Result
  Len1stIdxD,      // Delta Length Result and Common
  I: Integer;
begin
  Len1stIdxA := Length(DArrArrA);
  Len1stIdxB := Length(DArrArrB);
  Len1stIdxC := Min(Len1stIdxA, Len1stIdxB);
  if SinglePart
    then Len1stIdxR := Max(Len1stIdxA, Len1stIdxB)
    else Len1stIdxR := Len1stIdxC;
  Len1stIdxD := Len1stIdxR - Len1stIdxC;

  SetLength(Result, Len1stIdxR);

  // Common part of 1stIdx:
  for I := 0 to Len1stIdxC -1 do
    Result[I] := DoubArrsConcat(DArrArrA[I],            DArrArrB[I]);

  // Single part of 1stIdx:
  if (Len1stIdxA >= Len1stIdxB) then
  begin
    for I := 0 to Len1stIdxD -1 do
      Result[I+Len1stIdxC] :=  Copy(DArrArrA[I+Len1stIdxC]);
  end else
  begin
    for I := 0 to Len1stIdxD -1 do
      Result[I+Len1stIdxC] :=  Copy(DArrArrB[I+Len1stIdxC]);
  end;
end;

function DoubArrSubSet(const DArr: TDoubArr; Index, Count: Integer): TDoubArr;
begin
  Result := Copy(DArr, Index, Count);
end;

function DoubArrMean(const DArr: TDoubArr): Double;
var
  Len, I : Integer;
begin
  Result := 0;
  Len := Length(DArr);
  if Len > 0 then
  begin
    for I := 0 to Len -1 do
      Result := Result + DArr[I];
    Result := Result / Len;
  end;
end;

function DoubArrSubMean(const DArr: TDoubArr; Index, Count: Integer): Double;
begin
  Result := DoubArrMean(DoubArrSubSet(DArr, Index, Count));
end;

function DoubArrRevert(a: TDoubArr): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Length(a);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := a[Len-1 -I];
end;

function DoubArrSelectColumns(const DArr: TDoubArr; Columns: TColumns): TDoubArr;
var
  Len, I, IR : Integer;
begin
  Len := Length(DArr);
  IR  := 0;
  for I := 0 to Len -1 do
    if (I in Columns) then
    begin
      SetLength(Result, IR+1);
      Result[IR] := DArr[I];
      Inc(IR);
    end;
end;

function DoubArrFiner(const a: TDoubArr; Factor: Integer): TDoubArr;
var
  LenA, LenR, I, J : Integer;
  dx : Double;
begin
  LenA := Length(a);
  if LenA = 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  LenR := (LenA-1)*Factor +1;
  SetLength(Result, LenR);
  for I := 0 to LenA -2 do
  begin
    dx := (a[I+1] - a[I]) / Factor;
    for J := 0 to Factor -1 do
      Result[I*Factor +J] := a[I] + J*dx;
  end;
  Result[LenR -1] := a[LenA -1];
end;


function DoubArrsAdd(a, b: TDoubArr): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Min(Length(a), Length(b));
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := a[I] + b[I];
end;

function DoubArrsSub(a, b: TDoubArr): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Min(Length(a), Length(b));
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := a[I] - b[I];
end;

function DoubArrsRadius(Re, Im: TDoubArr): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Min(Length(Re), Length(Im));
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := Sqrt(Sqr(Re[I]) + Sqr(Im[I]));
end;

function DoubArrsLog2(a: TDoubArr): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Length(a);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    if a[I] > 0.0
      then Result[I] := Log2(a[I])
      else Result[I] := -888;
end;

function DoubArrsLog10(a: TDoubArr): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Length(a);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    if a[I] > 0.0
      then Result[I] := Log10(a[I])
      else Result[I] := -888;
end;

function DoubArrsLogN(a: TDoubArr; Base : Double): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Length(a);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    if a[I] > 0.0
      then Result[I] := LogN(Base ,a[I])
      else Result[I] := -888;
end;

function DoubArrScale(a: TDoubArr; Factor: Double): TDoubArr;
var
  Len, I : Integer;
begin
  Len := Length(a);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := Factor * a[I];
end;

function IntArrScale(a: TIntArr; Factor: Double): TIntArr;
var
  Len, I : Integer;
begin
  Len := Length(a);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := Round(Factor * a[I]);
end;

function DoubArrArrScale(a: TDoubArrArr; Factor: Double): TDoubArrArr;
var
  Len, I : Integer;
begin
  Len := Length(a);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := DoubArrScale(a[I], Factor);
end;

function DoubArrArrCopy(a: TDoubArrArr): TDoubArrArr;
var
  Len, I : Integer;
begin
  Len := Length(a);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := copy(a[I]);
end;

function DoubArrFromDoubArrArr(a: TDoubArrArr): TDoubArr;
// 13.01.09 P.W
var
  TotLen, I, J, R : Integer;
begin
  TotLen := 0;
  for I := 0 to Length(a) -1 do
    Inc(TotLen, Length(a[I]));

  SetLength(Result, TotLen);

  R := 0;
  for I := 0 to Length(a) -1 do
    for J := 0 to Length(a[I]) -1 do
    begin
      Result[R] := a[I][J];
      Inc(R);
    end;
end;

function DoubArrMinMax(const a: TDoubArr): TMinMax;
var
  Len, I : Integer;
begin
  Len := Length(a);
  if (Len > 0) then
  begin
    Result.MinVal := a[0];
    Result.MinIdx := 0;
    Result.MaxVal := a[0];
    Result.MaxIdx := 0;
    for I := 1 to Len -1 do
    begin
      if a[I] < Result.MinVal then
      begin
        Result.MinVal := a[I];
        Result.MinIdx := I;
      end else
      if a[I] > Result.MaxVal then
      begin
        Result.MaxVal := a[I];
        Result.MaxIdx := I;
      end;
    end;
  end else
  begin
    Result.MinVal := 0;
    Result.MinIdx := -1;
    Result.MaxVal := 0;
    Result.MaxIdx := -1;
  end;
end;

function DoubArrMinMax(const a: Array of Double): TMinMax;
begin
  Result := DoubArrMinMax(ConvertToDoubArr(a));
end;

function IntArrMinMax(const a: TIntArr): TMinMax;
var
  Len, I : Integer;
begin
  Len := Length(a);
  if (Len > 0) then
  begin
    Result.MinVal := a[0];
    Result.MinIdx := 0;
    Result.MaxVal := a[0];
    Result.MaxIdx := 0;
    for I := 1 to Len -1 do
    begin
      if a[I] < Result.MinVal then
      begin
        Result.MinVal := a[I];
        Result.MinIdx := I;
      end else
      if a[I] > Result.MaxVal then
      begin
        Result.MaxVal := a[I];
        Result.MaxIdx := I;
      end;
    end;
  end else
  begin
    Result.MinVal := 0;
    Result.MinIdx := -1;
    Result.MaxVal := 0;
    Result.MaxIdx := -1;
  end;
end;

function DoubArrArrMinMax(a: TDoubArrArr): TMinMax;
var
  Len, y : Integer;
  ResH : TMinMax;
begin
  Len := Length(a);
  if (Len > 0) then
  begin
    FillChar(Result, SizeOf(Result), #0);
    for y := 0 to Len -1 do
    begin
      ResH := DoubArrMinMax(a[y]);
      if y = 0 then
      begin
        Result := ResH;
        Result.MinIdy := y;
        Result.MaxIdy := y;
      end else
      begin
        if (Result.MinVal > ResH.MinVal) then
        begin
          Result.MinVal := ResH.MinVal;
          Result.MinIdx := ResH.MinIdx;
          Result.MinIdy := y;
        end;
        if (Result.MaxVal < ResH.MaxVal) then
        begin
          Result.MaxVal := ResH.MaxVal;
          Result.MaxIdx := ResH.MaxIdx;
          Result.MaxIdy := y;
        end;
      end;
    end;
  end else
  begin
    Result.MinVal := 0;
    Result.MinIdx := -1;
    Result.MinIdy := -1;
    Result.MaxVal := 0;
    Result.MaxIdx := -1;
    Result.MaxIdy := -1;
  end;
end;

function DoubArrMin(a: TDoubArr): Double;
begin
  Result := DoubArrMinMax(a).MinVal;
end;

function DoubArrMax(a: TDoubArr): Double;
begin
  Result := DoubArrMinMax(a).MaxVal;
end;

function DoubArrArrMin(a: TDoubArrArr): Double;
begin
  Result := DoubArrArrMinMax(a).MinVal;
end;

function DoubArrArrMax(a: TDoubArrArr): Double;
begin
  Result := DoubArrArrMinMax(a).MaxVal;
end;

function StrCompareStr(StrA, StrB: AnsiString; ChEqu:Char='='; ChDif:Char='!'): AnsiString;
var
  LenA, LenB, LenMin, LenMax, I : Integer;
begin
  LenA := Length(StrA);
  LenB := Length(StrB);
  LenMin := Min(LenA, LenB);
  LenMax := Max(LenA, LenB);

  SetLength(Result, LenMax);
  for I := 1 to LenMin do        // string index starts with 1
  begin
    if StrA[I] = StrB[I] then
    begin
      if StrA[I] = Tab
        then Result[I] := Tab
        else Result[I] := ChEqu
    end
    else Result[I] := ChDif;
  end;
  for I := LenMin +1 to LenMax do
    Result[I] := ChDif;
end;

function DoubArrAllZero(Len: Integer): TDoubArr;
begin
  SetLength(Result, 0);
  SetLength(Result, Len);
end;

function IntArrAllZero(Len: Integer): TIntArr;
begin
  SetLength(Result, 0);
  SetLength(Result, Len);
end;

function IntArrAllSame(Len: Integer; Value: Integer=0): TIntArr;
var
  I : Integer;
begin
  SetLength(Result, 0);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := Value;
end;

function DoubArrAllSame(Len: Integer; Value: Double=0): TDoubArr;
var
  I : Integer;
begin
  SetLength(Result, 0);
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := Value;
end;

function DoubArrAllEquIdx(Len: Integer; Offset: Double = 0.0): TDoubArr;
var
  I : Integer;
begin
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := I + Offset;
end;

function IntArrAllEquIdx(Len: Integer; Offset: Integer =0): TIntArr;
var
  I : Integer;
begin
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := I+Offset;
end;

function BoolArrAll(Len: Integer; Value: Boolean = False): TBoolArr;
var
  I : Integer;
begin
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := Value;
end;

function DoubArrAllOne(Len: Integer): TDoubArr;
var
  I : Integer;
begin
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := 1.0;
end;

function DoubArrFirstOne(Len: Integer): TDoubArr;
begin
  Result := DoubArrAllZero(Len);
  if Len > 0 then
    Result[0] := 1;
end;

function DoubArrCenterOne(Len: Integer): TDoubArr;
begin
  Result := DoubArrAllZero(Len);
  if Len > 0 then
    Result[Len div 2] := 1;
end;

function DoubArrFirstHalfOne(Len: Integer): TDoubArr;
var
  I : Integer;
begin
  Result := DoubArrAllZero(Len);
  for I := 0 to Len div 2 do
    Result[I] := 1;
end;

procedure GetLength(const DArrArr: TDoubArrArr; var LenX, LenY : Integer); overload;
begin
  LenX := Length(DArrArr);
  If LenX > 0
    then LenY := Length(DArrArr[0])
    else LenY := 0;
end;

procedure GetLength(const IArrArr: TIntArrArr; var LenX, LenY : Integer); overload;
begin
  LenX := Length(IArrArr);
  If LenX > 0
    then LenY := Length(IArrArr[0])
    else LenY := 0;
end;

procedure GetLength(const BArrArr: TByteArrArr; var LenX, LenY : Integer); overload;
begin
  LenX := Length(BArrArr);
  If LenX > 0
    then LenY := Length(BArrArr[0])
    else LenY := 0;
end;

procedure DoubArrsExchange(var a, b: TDoubArr);
var
  c : TDoubArr;
begin
  SetLength(c, 0);
  c := a;
  a := b;
  b := c;
end;

function  DoubArrArrTranspose(const DArrArr: TDoubArrArr): TDoubArrArr;
var
  LenX, LenY, x, y : Integer;
begin
  GetLength(DArrArr, LenX, LenY);
  SetLength(Result, LenY, LenX);
  for x := 0 to LenX -1 do
    for y := 0 to LenY -1 do
      Result[y, x] := DArrArr[x, y];
end;

function  DoubArrCenterSetZeros(const DArr: TDoubArr; NumZeros: Integer): TDoubArr;
var
  Len, C, A, B, I : Integer;
begin
  Len := Length(DArr);
  C := (Len div 2) -1;
  A := C - (NumZeros div 2);
  B := A + NumZeros -1;
  If A <    0 then A := 0;
  if B >= Len then B := Len -1;

  Result := Copy(DArr);
  for I := A to B do
    Result[I] := 0;
end;

(***
function  DoubArrCenterInsZeros(const DArr: TDoubArr; NumZeros: Integer): TDoubArr;  // buggy?
var
  Len, C, A, B, I : Integer;
begin
  Len := Length(DArr);
  C := (Len div 2) -1;
  SetLength(Result, Len + NumZeros);

  A := C +1;
  B := A + NumZeros -1;

  If A <    0 then A := 0;
  if B >= Len then B := Len -1;

  for I := 0 to A -1 do
    Result[I] := DArr[I];
  for I := A to B do
    Result[I] := 0;
  for I := B +1 to Len + NumZeros -1 do
    Result[I] := DArr[I - NumZeros];
end;
***)
procedure DoubArrCenterInsZeros(var DArr: TDoubArr; NumZeros: Integer);
var
  LenX, LenA, LenB, LenXn, x : Integer;
begin
  if (NumZeros <= 0) then EXIT;
  //------------------------------
  LenX := Length(DArr);
  LenXn := LenX + NumZeros;
  SetLength(DArr, LenXn);

  // Split into tow parts
  LenA  := LenX div 2;
  LenB  := LenX - LenA;

  // move Part B to Bottom (higher index)  (use Exchange)
  for x := 1 to LenB do
  begin
    DArr[LenXn - x] := DArr[LenX - x];
    DArr[LenX - x] := 0;                   // not for LenX = LenXn !
  end;
end;

procedure DoubArrArrCenterInsZeroArr(var D2: TDoubArrArr; NumZeroLines: Integer);
var
  LenX, LenY, LenA, LenB, LenXn, x : Integer;
begin
  GetLength(D2, LenX, LenY);
  LenXn := LenX + NumZeroLines;
  SetLength(D2, LenXn, LenY);

  // Split into tow parts
  LenA  := LenX div 2;
  LenB  := LenX - LenA;

  // move Part B to Bottom (higher index)  (use Exchange)
  for x := 1 to LenB do
    DoubArrsExchange(D2[LenXn - x], D2[LenX - x]);
end;

function DoubArrNumberedFilled(Len: Integer; Start, Delta: Double): TDoubArr;
var
  I : Integer;
begin
  SetLength(Result, Len);
  for I := 0 to Len -1 do
    Result[I] := Start + I * Delta;
end;

function DoubArrArrNumberedFilled(LenX, LenY, Start, DeltaX, DeltaY: Integer): TDoubArrArr; overload;
var
  x, y : Integer;
begin
  SetLength(Result, LenX, LenY);
  for x := 0 to LenX -1 do
    for y := 0 to LenY -1 do
      Result[x, y] := Start + x * DeltaX + y * DeltaY;
end;

function DoubArrArrNumberedFilled(LenX, LenY: Integer; Start: Integer= 0; Delta: Integer =1): TDoubArrArr; overload;
begin
  Result := DoubArrArrNumberedFilled(LenX, LenY, Start, LenY*Delta, Delta);
end;

procedure Test;
var
  D2 : TDoubArrArr;
  LenX, LenY : Integer;
begin
  D2 := DoubArrArrNumberedFilled(4, 8);
  D2 := DoubArrArrZoom(D2, 2, 2);
  D2 := DoubArrArrNumberedFilled(4, 9);
  D2 := DoubArrArrNumberedFilled(5, 11, 7, 2);

  D2 := DoubArrArrNumberedFilled(4, 7, 1);
  D2 := DoubArrArrTranspose(D2);

  D2 := DoubArrArrNumberedFilled(4, 5, 1, 1);
DoubArrCenterInsZeros(D2[0], 4);
//  D2[0] := DoubArrCenterInsZeros(D2[0], 4);
  DoubArrArrCenterInsZeroArr(D2, 2);
  GetLength(D2, LenX, LenY);
  H_alt(1);
end;

function DoubArrArrZoom(const D2: TDoubArrArr; ZoomX, ZoomY : Integer): TDoubArrArr;
var
  LenX, LenY : Integer;
  x, y, zx, zy : Integer;
begin
  GetLength(D2, LenX, LenY);
  SetLength(Result, ZoomX*LenX, ZoomY*LenY);
  for x := 0 to LenX -1 do
  begin
    for y := 0 to LenY -1 do
      for zy := 0 to ZoomY -1 do
        Result[x*ZoomX, y*ZoomY+zy] := D2[x,y];
    for zx := 1 to ZoomX -1 do
      Result[x*ZoomX+zx] := Result[x*ZoomX];
  end;
end;

procedure DoubArrAppend(var DArr: TDoubArr; Val: Double);
begin
  SetLength(DArr, Length(DArr) +1);
  DArr[Length(DArr) -1] := Val;
end;

procedure DoubArrDelItem(var DArr: TDoubArr; Idx: Integer);
var
  Len, I : Integer;
begin
  Len := Length(DArr);
  if InRange(Idx, 0, Len -1) then
  begin
    for I := Idx+1 to Len -1 do
      DArr[I-1] := DArr[I];
    Dec(Len);
    SetLength(DArr, Len);
  end;
end;

procedure IntArrAppend(var IArr: TIntArr; Val: Integer);
begin
  SetLength(IArr, Length(IArr) +1);
  IArr[Length(IArr) -1] := Val;
end;

procedure IntArrDelItem(var IArr: TIntArr; Idx: Integer);
var
  Len, I : Integer;
begin
  Len := Length(IArr);
  if InRange(Idx, 0, Len -1) then
  begin
    for I := Idx+1 to Len -1 do
      IArr[I-1] := IArr[I];
    Dec(Len);
    SetLength(IArr, Len);
  end;
end;

procedure IntArrArrAppend(var IArrArr: TIntArrArr; IArr: TIntArr);
begin
  SetLength(IArrArr, Length(IArrArr) +1);
  IArrArr[Length(IArrArr) -1] := Copy(IArr);
end;

function SortIntegerPtrAsc(IPtr1, IPtr2: Pointer): Integer;
// compare Result: <0: I1 < I2; =0: I1 = I2; >0 I1>I2
// for sort ascending
begin
  Result := Sign(Integer(IPtr1^)-Integer(IPtr2^));
end;

function SortIntegerPtrDes(IPtr1, IPtr2: Pointer): Integer;
// compare Result: <0: I1 < I2; =0: I1 = I2; >0 I1>I2
// for sort ascending
begin
  Result := Sign(Integer(IPtr2^)-Integer(IPtr1^));
end;

function  IntArrSortFunc(const IArr: TIntArr; Ascending:Boolean=True): TIntArr;
var
  List : TList;
  Len, I : Integer;
begin
  List := TList.Create;
  Len := Length(IArr);
  for I := 0 to Len - 1 do
    List.Add(@IArr[I]);
  if Ascending
    then List.Sort(SortIntegerPtrAsc)
    else List.Sort(SortIntegerPtrDes);

  SetLength(Result, Len);
  for I := 0 to Len - 1 do
    Result[I] := Integer(List[I]^);

  FreeAndNil(List);
end;

procedure IntArrSortProc(var IArr: TIntArr; Ascending:Boolean=True);
begin
  IArr := IntArrSortFunc(IArr, Ascending);
end;

type
  TSortIntRec = record
    Idx : Integer;
    Val : Integer;
  end;

function SortIntRecPtrAsc(IPtr1, IPtr2: Pointer): Integer;
// compare Result: <0: I1 < I2; =0: I1 = I2; >0 I1>I2
// for sort ascending
begin
  Result := Sign(TSortIntRec(IPtr1^).Val-TSortIntRec(IPtr2^).Val);
end;

function SortIntRecPtrDes(IPtr1, IPtr2: Pointer): Integer;
// compare Result: <0: I1 < I2; =0: I1 = I2; >0 I1>I2
// for sort ascending
begin
  Result := Sign(TSortIntRec(IPtr2^).Val-TSortIntRec(IPtr1^).Val);
end;

function  IntArrSortFuncIdx(const IArr: TIntArr; Ascending:Boolean=True): TIntArr;
// returns sorted index list not value list!
var
  List : TList;
  SortArr : Array of TSortIntRec;
  Len, I : Integer;
begin
  List := TList.Create;
  Len := Length(IArr);

  SetLength(SortArr, Len);
  for I := 0 to Len - 1 do
  begin
    SortArr[I].Idx := I;
    SortArr[I].Val := IArr[I];
    List.Add(@SortArr[I]);
  end;

  if Ascending
    then List.Sort(SortIntRecPtrAsc)
    else List.Sort(SortIntRecPtrDes);

  SetLength(Result, Len);
  for I := 0 to Len - 1 do
    Result[I] := TSortIntRec(List[I]^).Idx;

  FreeAndNil(List);
end;


procedure IntArrArrSortKeyProc(var IArrArr: TIntArrArr; const KeyArr: TIntArr; Ascending:Boolean=True);
var
  IdxArr : TIntArr;
  TmpArrArr : TIntArrArr;
  Len, I: Integer;
begin
  IdxArr := IntArrSortFuncIdx(KeyArr);
  Len := Min(Length(IArrArr), Length(KeyArr));

  TmpArrArr := Copy(IArrArr);   // copy only pointer array
  {
  SetLength(TmpArrArr, Len);
  for I := 0 to Len -1 do
  begin
    TmpArrArr[I] := IArrArr[I]
  end;
  }
  for I := 0 to Len -1 do
    IArrArr[I] := TmpArrArr[IdxArr[I]];  // sets Pointers
end;

function  IntArrFind(const IArr: TIntArr; Value: Integer; Offset: Integer=0): Integer;
var
  Len, I : Integer;
begin
  Len := Length(IArr);
  for I := Offset to Len -1 do
    if IArr[I] = Value then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

function IntArrAppendCheck(var IArr: TIntArr; Value: Integer): Boolean;
// append if not found
// returns True when appended
begin
  Result := (IntArrFind(IArr, Value) < 0);
  if Result then
    IntArrAppend(IArr, Value);
end;

Initialization
//  Test;

end.

