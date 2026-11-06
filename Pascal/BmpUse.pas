unit BmpUse;

// memo: function NumerateParticles(GyArr: TByteArrArr; var SizeArr: TIntArr; Threshold: Integer): TIntArrArr;
//       code is in RollImage.pas

interface
uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  HaltUnit,
  WinTools,             // 18.11.09 P.W
  ColorModels,
  Controls, ExtCtrls, Classes, jpeg, JpgUse, ColorDlgUse,
  DosTimer, TypesUse,
  Forms, Dialogs, SysUtils,
  Windows, Graphics,   // Windows befor Graphics for TBitmap.Width!
  ClipBrd,  Math, UFileCrc32;

var
  UpdMsg : AnsiString = '';
type
  TClipMode   = (CM_None,   CM_Gray,      CM_Hue,      CM_Sat,   CM_V,
                 CM_Red,    CM_Green,     CM_Blue,
                 CM_Cyan,   CM_Magenta,   CM_Yellow);
const
  GlbClipModeL2 : TClipMode = CM_V;
  GlbClipModeL1 : TClipMode = CM_Sat;
  GlbClipModeL0 : TClipMode = CM_Hue;
  GlbClipMode   : TClipMode = CM_Gray;
  ClipModeMsg : Array[TClipMode] of AnsiString =
               ('CM_None', 'CM_Gray',    'CM_Hue',    'CM_Sat', 'CM_V',
                'CM_Red',  'CM_Green',   'CM_Blue',
                'CM_Cyan', 'CM_Magenta', 'CM_Yellow');
type
  TOrigMode = (OM_Keep, OM_Set, OM_SetInv, OM_Merge, OM_MergeInv, OM_KeepBG);

  TSL   = ^TCol32Arr;
  TCol32Arr   = Array [0 .. MaxWord] of TCol32;  // assumes pf32bit;
  TSL32 = TSL;

  TSL32Arr = Array of TSL;

  TSL24  = ^TCol24Arr;
  TCol24Arr   = Array [0 .. MaxWord] of TCol24;  // assumes pf24bit;

  TSL24Arr = Array of TSL24;

  TBmp1FunctionPPar = function(Bmp: TBitmap; ParamPtr: Pointer): TBitmap;
  TBmp1Function     = function(Bmp: TBitmap): TBitmap;
  TBmp1FunctionPar  = function(Bmp: TBitmap; P0, P1: Integer): TBitmap;
  TBmp2FunctionPPar = function(BmpA, BmpB: TBitmap; ParamArrPtr: Pointer): TBitmap;
  TBmp2Function     = function(BmpA, BmpB: TBitmap): TBitmap;
  TBmp2FunctionPar  = function(BmpA, BmpB: TBitmap;  P0, P1: Integer): TBitmap;
  TBmp2FunctionParDI= function(BmpA, BmpB: TBitmap;  D0: Double; P1: Integer): TBitmap;
  TBmp3Function     = function(BmpA, BmpB, BmpC: TBitmap): TBitmap;
  TBmp3FunctionPar  = function(BmpA, BmpB, BmpC: TBitmap;  P0, P1: Integer): TBitmap;


type
  TZoomInfo = Record
    dx, dy, ZFx, ZFy : Double;
  end;
const
  ZoomInfoId    : TZoomInfo = (dx: 0.0; dy: 0; ZFx: 1.0; ZFy: 1.0);
  ZoomInfoDiv2  : TZoomInfo = (dx: 0.0; dy: 0; ZFx: 0.5; ZFy: 0.5);
  ZoomInfoMult2 : TZoomInfo = (dx: 0.0; dy: 0; ZFx: 2.0; ZFy: 2.0);

type
  TFinalCopyMarker = (FinalCopyMarker);

  TGetZoomInfo    = function: TZoomInfo of Object;
  TGetVisibleRect = function: TRect     of Object;

  PGlassesFrame = ^ TGlassesFrame;
  TGlassesFrame = record
    R : TRect;    // R: surrounding rectangle of last Move_Paint region
    Moving,
    Valid       : Boolean;
    ImgZoomInfo : TZoomInfo;

    WD, HD,
    WS, HS      : Integer;

    Width,
    RelZoom,
    RatioXY     : Double;
    Mode        : Integer;
    Selected,
    ShowEdge,
    PixInterpol : Boolean;
    ContrastCenter : Integer;
    ContrastFact,
    MergeRatio  : Double;
    dcxRatio, dcyRatio: Double;
    TimeStart : TDateTime;
    PeriodPhaseX,
    PeriodPhaseY,
    PeriodTimeX,
    PeriodTimeY  : Double; // [sec]
    LastXC,
    LastYC    : Double;
    RotateDxDy,
    SinRot, CosRot,
    ZoomRelAmplitude,
    LeftRightShakeLevel,
    TopDownShakeLevel: Double;
    DyAbs,
    UseStack,
    ScreenOnly,
    RequestUpdate : Boolean;

    FinalCopyMarker : TFinalCopyMarker;
    // --------------------------------
    BmpOrg,
    BmpSrc,
    BmpDst       : TBitmap;
    SLSrc, SLOrg,
    SLDst       : TSL32Arr;
    ParentForInvalidateRect : TWinControl;
    GetZoomInfo: TGetZoomInfo;
    GetVisibleRect : TGetVisibleRect;
    VisRect : TRect;
    // --------------------------------
  end;

  TGlassesFrames = Array of TGlassesFrame;

type
  TSaveBmpRec = record     // save in memory for reuse to avoid recalculation of smoothed... Bmp
    Bmp       : TBitmap;
    ZoomFactX : Double;
    ZoomFactY : Double;
    R         : TRect;
  end;

type
  TMap   = TIntArrArr;
  TMapTree = Array of TMap;

  TSearchMap = class(TObject)
  private
    MapTree : TMapTree;
    procedure SetMapCount(const Value: Integer);
    function GetMapCount: Integer;
  public
    constructor Create(Bmp: TBitMap); virtual;
    destructor Destroy; override;
    function   MapTreeBmp: TBitmap;
    property MapCount: Integer read GetMapCount;
  end;

type
  TBmpPlus = class(TObject)
  private
  public
    dx, dy, W, H : Integer;
  end;

  TBlueToBlackParams = record
    Size : Integer;
    GrayMin, GrayMax,         // GrayValue Min Max
    HueMin, HueMax,           // Hue : Color type
    SatMin, SatMax : Byte;    // Sat : Saturation
    Mode : Integer;           //Mode : 0: SetNewColor   1:colorDown, 2:ColorBrighter, 3: ContrastLow, 4:ContrastHigh
    RInt, GInt, BInt : Integer;
    NewColor :  TCol32;
  end;

  TBlueToBlackParamsArr = Array of TBlueToBlackParams;


procedure BmpLoadFromAny(Bmp: TBitmap; FileName: String);
procedure TextOutVert(Cv: TCanvas; R: TRect; DrawTxt: String);
procedure TextOutRect(CV: TCanvas; R: TRect; DrawTxt: String; VertFlg: Boolean);
procedure TextToCanvasRect(Cv: TCanvas; R: TRect; aTextHeight: Integer; DrawTxt: String);
procedure TextToCanvas(Cv: TCanvas; x, y, aTextHeight: Integer; DrawTxt: String);
procedure TextToBmp(Bmp: TBitmap; R: TRect; aTextHeight: Integer; DrawTxt: String);

procedure GraphicSaveAsBmp(Graphic: TGraphic; BmpName: String);
  
function ZoomInfosCombine(const ZI1, ZI2: TZoomInfo): TZoomInfo;
function ZoomInfosEqual(const ZI1, ZI2: TZoomInfo): Boolean;

function CreateGrayPal_16: HPALETTE;
function CreateGrayPal256: HPALETTE;


function GetParentWindow(Wnd: HWND; Level:Integer=-1): HWND;
function ParentWindowFromPoint(PT: TPoint): HWND;
function ParentWindowFromMouse: HWND;
function WindowFromMouse: HWND;
function ParentWindowFromMousePos(const ParWnd: HWND; const MP: TPoint): TPoint; overload;
function ParentWindowFromMousePos: TPoint; overload;
procedure WindowToBmp(Wnd: HWND; Bmp: TBitmap; UseDeskTop:Boolean=True);
procedure BmpCutImage(Bmp: TBitmap; CB: TRect);
function BmpCutImageFunc(Bmp: TBitmap; CB: TRect): TBitmap;
procedure BmpCutImageInvers(Bmp: TBitmap; CB: TRect);
procedure GetBmpCutFromWnd(Wnd: HWND; Bmp: TBitmap; CutRect: TRect);


procedure BmpFloodFillXY(Bmp: TBitmap; X, Y: Integer; C_Brush, C_Border: TColor; Border: Boolean);

function BmpCreate32(W, H: Integer; BrushColor:TColor=clBlack): TBitmap;
function BmpCreateCopy32(const Bmp: TBitmap): TBitmap;

procedure BmpReplace(BmpDest, BmpSource: TBitmap);

function BmpHisto(Bmp: TBitmap; HistoMode: TClipMode=CM_Gray): TIntArr;
function BmpCross(Bmp: TBitmap; CMa, CMb: TClipMode): TDoubArrArr;
function BmpToProfiles(Bmp: TBitmap): TIntArrArr;
function ProfilesToBmp(Profiles: TIntArrArr): TBitmap;
function DoubArrArrToBmp(const A: TDoubArrArr): TBitmap;

procedure BmpInvert(Bmp: TBitmap);
function BmpAdd(BmpA, BmpB: TBitmap): TBitmap;
function BmpSetRed(BmpA, BmpB: TBitmap): TBitmap;
function BmpSetGreen(BmpA, BmpB: TBitmap): TBitmap;
function BmpSetBlue(BmpA, BmpB: TBitmap): TBitmap;

function Rotate90Deg(BmpA: TBitmap): TBitmap;


function BmpCompareMatch(BmpA, BmpB: TBitmap; dx, dy, dFrame: Integer): Double;
function BmpCompare(BmpA, BmpB: TBitmap): TBitmap;
procedure BmpDrawDirect(Wnd: HWND; Bmp: TBitmap; ZR: TRect);
procedure BmpBlendLeftRightDirect(Wnd: HWND; Result, BmpA, BmpB: TBitmap; MergeRatio: Double; P1: Integer);
procedure BmpBlendLeftRightPerc(Result, BmpA, BmpB: TBitmap; MergeRatioPerc, P1: Integer);
procedure BmpMergeColorsToBmpA(BmpA, BmpB: TBitmap; MergeRatio: Double; P1: Integer);
procedure BmpMergeColorsProc(Result, BmpA, BmpB: TBitmap; MergeRatio: Double; P1: Integer; Limit: Byte = 255);
function BmpMergeColors(BmpA, BmpB: TBitmap; MergeRatio: Double; P1: Integer): TBitmap;
function BmpMergeHatched(BmpA, BmpB: TBitmap; MergeRatio: Double; HatchMode: Integer): TBitmap;
function BmpMergeColorsGrayPerc(BmpA, BmpB: TBitmap; MergeRatioPerc, P1: Integer): TBitmap;
function BmpMergeColorsMaskedPerc(BmpA, BmpB, BmpMsk: TBitmap; MergeRatioPerc, P1: Integer): TBitmap;
function BmpMergeColorsMaskedGrayPerc(BmpA, BmpB, BmpMsk: TBitmap; MergeRatioPerc, P1: Integer): TBitmap;
function BmpMult(BmpA, BmpB: TBitmap): TBitmap;

function BmpGetGrad3x3Col32(Bmp: TBitmap): TBitmap;
function BmpGetGrad5x5Col32(Bmp: TBitmap): TBitmap;
function BmpGetMean3x3Col32(Bmp: TBitmap): TBitmap;
function BmpGetMean5x5Col32(Bmp: TBitmap): TBitmap;

function BmpRotate90(Bmp: TBitmap): TBitmap;
function BmpRotate180(Bmp: TBitmap): TBitmap;
function BmpRotate270(Bmp: TBitmap): TBitmap;
function BmpMirrorVerticalLR(Bmp: TBitmap): TBitmap;
function BmpMirrorHorizontalTD(Bmp: TBitmap): TBitmap;

function BmpCloseHolesCol32(Bmp: TBitmap): TBitmap;
function BmpRemoveSinglePntsCol32(Bmp: TBitmap): TBitmap;
function BmpRemoveEndPntsCol32(Bmp: TBitmap): TBitmap;
function BmpMarkEdgeCol32(Bmp: TBitmap; P0, P1: Integer): TBitmap;
function BmpMarkEdgeNoOrOneObjectNeighbour(Bmp: TBitmap): TBitmap;
function BmpRemoveEdgeNonConnectorCol32(Bmp: TBitmap): TBitmap;
function BmpRemoveEdgeFinalCol32(Bmp: TBitmap): TBitmap;
function BmpMarkEndPtsTreeNodesCol32(Bmp: TBitmap): TBitmap;
function BmpMarkedEndPtsTreeNodesRemoveShortLinesCol32(Bmp: TBitmap; MinLength, P1:Integer): TBitmap;
function BmpRemoveEdgeCol32(Bmp: TBitmap): TBitmap;

function BmpGetMean3x3Masked(Bmp, BmpMsk: TBitmap): TBitmap;
function BmpGetMean5x5Masked(Bmp, BmpMsk: TBitmap): TBitmap;
function BmpGetEdgeRgb3x3Col32(Bmp: TBitmap): TBitmap;

function BmpGetEdge3x3Col32(Bmp: TBitmap): TBitmap;
procedure BmpGetEdge3x3Col32_ToS(Bmp: TBitmap);  // for use by ColInterpolSL32Arr

function BmpGetEdge5x5Col32(Bmp: TBitmap): TBitmap;
function BmpGetDxDyEdge5x5Col32(Bmp: TBitmap): TBitmap;
function BmpGetMeanUseEdge5x5Col32(Bmp: TBitmap): TBitmap;


function CalcOrigRect(RL: TRect; ZI: TZoomInfo): TRect;

procedure PictureToPicBmp(PicSrc, PicDest: TPicture);
procedure PictureToBmp(picture: TPicture);

procedure CallEmptyClipboard;
function PicFromClipboard(Pic: TPicture): Boolean;
function BmpFromClipboard(Bmp: TBitmap): Boolean;
procedure ProcPicToClipboard(Pic: TPicture);
procedure ProcBmpToClipboard(Bmp: TBitMap);

function BmpHash(Bmp: TBitmap): DWORD;

function BmpGetPattern(Bmp: TBitmap; x0, y0: Integer; pdx, pdy: Integer): TColArr;
function BmpFindPattern(Bmp: TBitmap; const Pattern: TColArr; pdx, pdy, Limit: Integer; RatioNonMatch: Double): TPntArr;
function BmpPatternMatchQuality(BmpA, BmpB: TBitmap; Limit: Integer; var Pnts: TPntArr): TIntArr; overload;
function BmpPatternMatchQuality(BmpA, BmpB: TBitmap; Limit: Integer; var Pnt: TPoint): Integer;   overload;
function BmpPatternFindDxDy(BmpA, BmpB: TBitmap): TPntArr;
procedure TestPattern(Bmp: TBitmap);

procedure BmpWH(Bmp: TBitmap; var W, H: Integer); overload;
procedure BmpWH(BmpA, BmpB: TBitmap; var W, H: Integer); overload;
procedure BmpWH(BmpA, BmpB, BmpC: TBitmap; var W, H: Integer); overload;
function BmpSL24Arr(Bmp: TBitmap): TSL24Arr;
function BmpSL32Arr(Bmp: TBitmap): TSL32Arr;
procedure BmpGradCol32(Bmp: TBitmap; GradScale: Double);
procedure TestMaskedSmooth(Bmp: TBitmap);

function BmpGetRedCol32(Bmp: TBitmap): TBitmap;
function BmpGetGreenCol32(Bmp: TBitmap): TBitmap;
function BmpGetBlueCol32(Bmp: TBitmap): TBitmap;
function BmpBlueToBlack(Bmp: TBitmap; ParamPtr: Pointer): TBitmap;
function BmpBlueToBlack2(BmpA, BmpB: TBitmap; ParamArrPtr: Pointer): TBitmap;
function BmpRedToGrayCol32(Bmp: TBitmap): TBitmap;
function BmpGreenToGrayCol32(Bmp: TBitmap): TBitmap;
function BmpBlueToGrayCol32(Bmp: TBitmap): TBitmap;
function BmpSToGrayCol32(Bmp: TBitmap): TBitmap;

function BmpRgbToHsvAndBackCol32(Bmp: TBitmap): TBitmap;
function BmpToGrayHsvH32(Bmp: TBitmap): TBitmap;
function BmpToGrayHsvS32(Bmp: TBitmap): TBitmap;
function BmpToGrayHsvV32(Bmp: TBitmap): TBitmap;

function BmpToGraySimple32(Bmp: TBitmap): TBitmap;
function BmpToGrayUseHsv32(Bmp: TBitmap): TBitmap;

function BmpAddFilterFrame(Bmp: TBitmap; FrameWidth, P1 : Integer): TBitmap;
function BmpCutFrame(Bmp: TBitmap; FrameWidth, P1 : Integer): TBitmap;

function BmpMedian3x3Col32(Bmp: TBitmap): TBitmap;
function BmpMedian5x5Col32(Bmp: TBitmap): TBitmap;

function BmpMedian3x3Col32_Thr(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;
function BmpMedian5x5Col32_Thr(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;
function BmpMedian5x5Col32_ThrHSV(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;
function BmpMedian3x3Col32_ThrRGB(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;
function BmpMedian5x5Col32_ThrRGB(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;

function BmpEqual5x5Col32(Bmp: TBitmap): TBitmap;

procedure BmpGray24(Bmp: TBitmap);
procedure BmpGray32(Bmp: TBitmap);
procedure BmpSoftGray32(Bmp: TBitmap);
procedure BmpSoft2Gray32(Bmp: TBitmap);
procedure BmpFramed32(Bmp: TBitmap; dx, dy: Integer);

function ColInterpolSL32Arr        (const SLA: TSL32Arr; WS, HS: Integer; XS, YS: Double): TCol32;
function ColInterpolSL32Arr_noCheck(const SLA: TSL32Arr;                  XS, YS: Double): TCol32;

function BmpAdaptedPntsDelta(Bmp: TBitmap; const Pnts, PntsShift: TPntDArr): TBitmap;
function BmpAdaptedPnts(Bmp: TBitmap; PntsA, PntsB: TPntDArr): TBitmap;
function BmpMoveDelta(Bmp: TBitmap; dx, dy: Double): TBitmap;

procedure BmpMoveDelta_Part_Proc(var BDst: TBitMap; const BSrc, BBack: TBitmap; dx, dy: Double; xS0, yS0, WD, HD: Integer);
function BmpMoveDelta_Part(Bmp: TBitmap; dx, dy: Double; xS0, yS0, WD, HD: Integer): TBitmap;

procedure BmpRotatedProc(const BmpS: TBitmap; var Result: TBitmap; Rot: Double);               overload;
procedure BmpRotatedProc(const BmpS: TBitmap; var Result: TBitmap; Rot: Double; CRect: TRect); overload;
function BmpRotated(Bmp: TBitmap; Rot: Double): TBitmap;
function CalcGaussFilterAsym(M, N: Integer; fm, fn, rot : Double): TIntArrArr;
function BmpGauss(fm, fn, rot: Double): TBitmap;


procedure BmpRotateDemo32(Pic: TPicture; Phi0, Phi1, dPhi: Double);

procedure BmpGlasses32_Init(BmpD, BmpS: TBitMap; aParentInvalRect: TWinControl;
  aGetZoomInfo: TGetZoomInfo; aGetVisibleRect: TGetVisibleRect; var GF: TGlassesFrame);
procedure BmpGlasses32_Done(var GF: TGlassesFrame; RestoreOrg: Boolean);
procedure BmpGlasses32_Move(var GF: TGlassesFrame; XC, YC: Double; OrigMode: TOrigMode=OM_Keep; Upd:Boolean=True); overload;
procedure BmpGlasses32_Move(var GF: TGlassesFrame);     overload;
procedure BmpGlasses32_Move(const GFs: TGlassesFrames); overload;
procedure BmpGlasses32_ToOrg(var GF: TGlassesFrame; OrigMode: TOrigMode);

procedure BmpMove(BmpSrc, BmpDst: TBitmap; const GFs: TGlassesFrames);


procedure BmpGlassesDemo32(Pic: TPicture; Rad0, Rad1, dRad: Double);
function BmpKeyStoneZoomRotated(Bmp: TBitmap; KeyStone, ZoomFact, Rot: Double): TBitmap;
function BmpSizeMultDiv(Bmp: TBitmap; fMult, fDiv: Integer): TBitmap;
function BmpZoomed(Bmp: TBitmap; ZoomFact: Double): TBitmap;
procedure BmpZoomContinue_0(Bmp, BmpZ: TBitmap; ZoomFactX, ZoomFactY:  Double);
procedure BmpMergeRect(Bmp: TBitmap; Color: TCol32; MergeRatio: Double; R: TRectS);

procedure InvalidateSaveRec(var SaveRec: TSaveBmpRec);

function BmpDrawAngle(Bmp: TBitmap; ClipLo, ClipHi: Integer; ColLo, ColHi: TColor; AngleDelta: Integer): TBitmap;
function BmpZoomRect(Bmp, BmpZ: TBitmap; ZoomFactX, ZoomFactY:  Double;
               R: TRectS;
               var SR:TSaveBmpRec;
               GradScale_255: Integer;
               ClipLo, ClipHi: Integer;
               ColLo, ColHi : TCol32;
               Interpol: Boolean): Boolean;

function BmpDistorted(Bmp: TBitmap): TBitmap;

procedure BmpDiffHalf   (Bmp0, Bmp1: TBitmap);
procedure BmpAddDiffHalf(Bmp0, Bmp1: TBitmap);

procedure ShowBmp(Bmp: TBitmap; Msg:AnsiString='');
procedure MergeImagePartsJpgc(NameInA, NameInB, NameOut: String);


var
  DebugRot : Double = 0.0;




Implementation

uses Types;
  const Unit_Name = 'BmpUse'; // 03.05.24 P.W


procedure BmpLoadFromAny(Bmp: TBitmap; FileName: String);
var
  Pic : TPicture;
begin
  Pic := TPicture.Create;
  Pic.LoadFromFile(FileName);
  PictureToBmp(Pic);

  Bmp.Assign(Pic.Graphic);
  Pic.Free;
end;

procedure TextOutVert(Cv: TCanvas; R: TRect; DrawTxt: String);
// modified copy from Draw.pas
{
for (angle = 0; angle < 3600; angle += 100) {
    plf->lfEscapement = angle;
    hfnt = CreateFontIndirect(plf);
    hfntPrev = SelectObject(hdc, hfnt);
    TextOut(hdc, rc.right / 2, rc.bottom / 2,
        lpszRotate, lstrlen(lpszRotate));
    SelectObject(hdc, hfntPrev);
    DeleteObject(hfnt);
}
var
  LogFont        : TLogFont; // =plf
  hfntprev, hfnt : THandle;  // new font handle
  RetBytes       : Integer;
begin
  RetBytes:=GetObject(Cv.Font.Handle, SizeOf(LogFont), Addr(LogFont));
  if RetBytes=SizeOf(LogFont) then
  begin
    LogFont.lfEscapement  :=900;  // [0.1 deg]
    LogFont.lfOrientation := 900;   // for Win95 set same as lfEsc.
    hfnt     := CreateFontIndirect(LogFont);
    hfntPrev := SelectObject(Cv.Handle, hfnt);

    Cv.TextRect(R, R.Left,  R.Bottom, DrawTxt);

    SelectObject(Cv.Handle, hfntPrev);
    DeleteObject(hfnt);
  end else
  begin
    Cv.TextRect(R, R.Left, R.Top, DrawTxt);
  end;
end;

procedure TextOutRect(CV: TCanvas; R: TRect; DrawTxt: String; VertFlg: Boolean);
var
  TW, TH : Integer; // Width and height of Text
  DW, DH, D0, DD0 : Integer; // Width and height of draw rectangle adapted to direction
  Ready : Boolean;
  Len, P : Integer;
  TxtPart : String;
begin
  TW := CV.TextWidth (DrawTxt);
  TH := CV.TextHeight(DrawTxt);
  if VertFlg then
  begin
    DH := R.Right  - R.Left;
    DW := R.Bottom - R.Top;
    D0 := R.Left;
  end else
  begin
    DW := R.Right  - R.Left;
    DH := R.Bottom - R.Top;
    D0 := R.Top;
  end;

  DD0 := TH;
  Ready := False;
  repeat
    Len := Length(DrawTxt);
    P := Len;
    // find Length that fits:
    While (P > 0) and (CV.TextWidth (Copy(DrawTxt, 1, P)) > DW) do Dec(P);
    Ready := (P=0);
    if not ready then
    begin
      TxtPart := Copy(DrawTxt, 1, P);
      if VertFlg then
      begin
        R.Left := D0;
        TextOutVert(Cv, R, TxtPart);
      end else
      begin
        R.Top  := D0;
        Cv.TextRect(R, R.Left, R.Top, TxtPart);
      end;
      Delete(DrawTxt, 1, P);
      Inc(D0, DD0);
      Dec(DH, DD0);
      Ready := Ready or (DH < 0);
    end;
  until Ready;

end;

procedure TextToCanvasRect(Cv: TCanvas; R: TRect; aTextHeight: Integer; DrawTxt: String);
var
  RW, RH : Integer;
  PCol_sav, BCol_sav : TColor;
  FNam_Sav : String;
  FHgh_Sav : Integer;
begin
  PCol_sav := Cv.Pen.Color;
  BCol_sav := Cv.Brush.Color;
  FNam_Sav := Cv.Font.Name;
  FHgh_Sav := Cv.Font.Height;

  Cv.Pen.Color   := clBlack;
  Cv.Brush.Color := clWhite;
  Cv.Font.Name   := 'Courier New';
  Cv.Font.Height := -aTextHeight;

  RW := R.Right  - R.Left;
  RH := R.Bottom - R.Top;
  TextOutRect(CV, R, DrawTxt, RH > RW);

  Cv.Pen.Color   := PCol_sav;
  Cv.Brush.Color := BCol_sav;
  Cv.Font.Name   := FNam_Sav;
  Cv.Font.Height := FHgh_Sav;
end;

procedure TextToCanvas(Cv: TCanvas; x, y, aTextHeight: Integer; DrawTxt: String);
var
  FHgh_Sav, TW, TH : Integer;
  R : TRect;
begin
  FHgh_Sav := Cv.Font.Height;
  Cv.Font.Height := -aTextHeight;

  TW := CV.TextWidth(DrawTxt);
  TH := CV.TextHeight(DrawTxt);
  R := Rect(x, y, x + TW, y + TH);
  TextToCanvasRect(Cv, R, aTextHeight, DrawTxt);

  Cv.Font.Height := FHgh_Sav;
end;

procedure TextToBmp(Bmp: TBitmap; R: TRect; aTextHeight: Integer; DrawTxt: String);
begin
  TextToCanvasRect(Bmp.Canvas, R, aTextHeight, DrawTxt);
end;

procedure GraphicSaveAsBmp(Graphic: TGraphic; BmpName: String);
var
  Bmp : TBitmap;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.Assign(Graphic);
    ForceDirectories(ExtractFileDir(BmpName));
    Bmp.SaveToFile(BmpName);
  except
    Bmp.Free;
    raise;
  end;
  Bmp.Free;
end;



function ZoomInfosCombine(const ZI1, ZI2: TZoomInfo): TZoomInfo;
// first ZI1 applied then ZI2: dx and dy of ZI1 are zoomed by ZI2!
begin
  Result.dx  := ZI1. dx * ZI2.ZFx + ZI2.dx;
  Result.dy  := ZI1. dy * ZI2.ZFy + ZI2.dy;
  Result.ZFx := ZI1.ZFx * ZI2.ZFx;
  Result.ZFy := ZI1.ZFy * ZI2.ZFy;
end;

function ZoomInfosEqual(const ZI1, ZI2: TZoomInfo): Boolean;
begin
  Result := (ZI1.dx  = ZI2.dx ) and (ZI1.dy  = ZI2.dy ) and
            (ZI1.ZFx = ZI2.ZFx) and (ZI1.ZFy = ZI2.ZFy);
end;

//#################################################################################
function UseCreatePalette(const Entries: array of TColor): HPALETTE;
// from Graph.pas CreateSystemPalette
var
  Pal: TMaxLogPalette;
begin
  Pal.palVersion := $300;
  Pal.palNumEntries := Min(256, High(Entries)-Low(Entries)+1);
  Move(Entries, Pal.palPalEntry, Pal.palNumEntries * SizeOf(TColor));
  Result := CreatePalette(PLogPalette(@Pal)^);
end;


function CreateGrayPal_16: HPALETTE;
const
  Pal16: array [0..15] of TColor =
//    (clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple, clTeal, clDkGray,
//     clLtGray, clRed, clLime, clYellow, clBlue, clFuchsia, clAqua, clWhite);
      ($000000, $111111, $222222, $333333, $444444, $555555, $666666, $777777,
       $888888, $999999, $AAAAAA, $BBBBBB, $CCCCCC, $DDDDDD, $EEEEEE, $FFFFFF);
begin
  Result := UseCreatePalette(Pal16);
end;

function CreateGrayPal256: HPALETTE;
var
  B : Byte;
  Pal256: array [0..255] of TColor;
begin
  for B := 0 to 255 do
    Pal256[B] := B + B shl 8 + B shl 16;
  Result := UseCreatePalette(Pal256);
end;
//#################################################################################


function GetParentWindow(Wnd: HWND; Level:Integer=-1): HWND;
// Level= -1 returns parent of parent ... as long as not nil
// Level= 0 returns Wnd
// Level= 1 returns direct parent of Wnd (if not nil)
begin
  Result := Wnd;  // for case that Wnd is Null
  
  While (Wnd <> 0) and (Level <> 0) do
  begin
    Result := Wnd;
    Wnd    := GetParent(Result);
    if (Level > 0) then
      Dec(Level)
  end;
end;

function ParentWindowFromPoint(PT: TPoint): HWND;
begin
  Result := GetParentWindow(WindowFromPoint(PT));
end;

function ParentWindowFromMouse: HWND;
begin
  Result := ParentWindowFromPoint(Mouse_CursorPos);
end;

function WindowFromMouse: HWND;
begin
  Result := WindowFromPoint(Mouse_CursorPos);
end;

function ParentWindowFromMousePos(const ParWnd: HWND; const MP: TPoint): TPoint;
var
  CB  : TRect;
begin
//  MP     := Mouse_CursorPos;
//  ParWnd := ParentWindowFromPoint(MP);
  GetWindowRect(ParWnd, CB);
  Result := PointsSub(MP, CB.TopLeft);
end;

function ParentWindowFromMousePos: TPoint;
var
  MP : TPoint;
begin
  MP     := Mouse_CursorPos;
  Result := ParentWindowFromMousePos(ParentWindowFromPoint(MP), MP);
end;

procedure WindowToBmp(Wnd: HWND; Bmp: TBitmap; UseDeskTop:Boolean=True);
var
  DC : HDC;
  CB  : TRect;
  DX, DY : Integer;
  FactOrig : Integer;
begin
  if UseDeskTop then
  begin
    DC  := GetDC(0);                // Wnd =0: -> Desktop
    FactOrig := 1;
  end else
  begin
    DC  := GetDCEx(Wnd, 0, DCX_WINDOW or DCX_PARENTCLIP);
    FactOrig := 0;
  end;

  if DC = 0 then
  begin
    ShowMessage('DC is NULL!');
    EXIT;  // Error!
  end;

  //GetClipBox(DC, CB);
  GetWindowRect(Wnd, CB);
  DX := (CB.Right  - CB.Left);
  DY := (CB.Bottom - CB.Top );

  BMP.Width  := DX;
  BMP.Height := DY;

  BitBlt(
    BMP.Canvas.Handle, 0,                  0,                 DX, DY,    // destination
    DC,                FactOrig * CB.Left, FactOrig * CB.Top, //DX, DY,    // source
    cmSrcCopy);
  Bmp.Modified := True;

  if UseDeskTop then
    ReleaseDC(0,   DC)
  else
    ReleaseDC(Wnd, DC);

//  SetForegroundWindow(Wnd);           // until 13.04.07 P.W
end;

procedure BmpCutImage(Bmp: TBitmap; CB: TRect);
// avoid enlargement
// keep part of image which is covered by CB
var
  W, H : Integer;
  X0, Y0, DX, DY: Integer;
begin
  BmpWH(Bmp, W, H);
  X0 := CB.Left;
  Y0 := CB.Top;
  DX := Min(CB.Right  - CB.Left, W - CB.Left);
  DY := Min(CB.Bottom - CB.Top , H - CB.Top );

  BitBlt(
    Bmp.Canvas.Handle,  0,  0, DX, DY,    // destination
    Bmp.Canvas.Handle, X0, Y0,            // Source
    cmSrcCopy);

  Bmp.Width  := DX;
  Bmp.Height := DY;
end;

function BmpCutImageFunc(Bmp: TBitmap; CB: TRect): TBitmap;
// avoid enlargement
// keep part of image which is covered by CB
var
  W, H : Integer;
  X0, Y0, DX, DY: Integer;
begin
  BmpWH(Bmp, W, H);
  X0 := CB.Left;
  Y0 := CB.Top;
  DX := Min(CB.Right  - CB.Left, W - CB.Left);
  DY := Min(CB.Bottom - CB.Top , H - CB.Top );

  Result := BmpCreate32(DX, DY);

  BitBlt(
    Result.Canvas.Handle,  0,  0, DX, DY,    // destination
    Bmp.Canvas.Handle, X0, Y0,            // Source
    cmSrcCopy);

end;

procedure BmpCutImageInvers(Bmp: TBitmap; CB: TRect);
// avoid enlargement
// remove part of image covered by CB : Horizontally when CB.Width > CB.Heighte else Vertically
var
  W, H, RW, RH : Integer;
  XD, YD, XS, YS, DX, DY, NW, NH: Integer;
//  X0, Y0, DX, DY: Integer;
begin
  BmpWH(Bmp, W, H);
  RW := CB.Right  - CB.Left;
  RH := CB.Bottom - CB.Top;
  if RW > RH then
  begin // Horizontally
        //        ##########################
        //        ##########################
        //        --------------------------
        //        |       CB               |
        //        --------------------------
        //        ##########################    ^
        //        ##########################    | DY
        //        ##########################    v
    XD := 0;
    YD := Min(H, CB.Top);
    DX := W;
    DY := Max(0, H - CB.Bottom);        
    XS := 0;
    YS := Min(H, CB.Bottom + 1);
    NW := W;
    NH := YD + DY;
  end else
  begin // Vertically
    XD := Min(W, CB.Left);
    YD := 0;
    DX := Max(0, W - CB.Right);
    DY := H;
    XS := Min(W, CB.Right + 1);
    YS := 0;
    NW := XD + DX;
    NH := H;
  end;

  BitBlt(
    Bmp.Canvas.Handle, XD, YD, DX, DY,    // destination
    Bmp.Canvas.Handle, XS, YS,            // Source
    cmSrcCopy);

  Bmp.Width  := NW;
  Bmp.Height := NH;
end;

procedure GetBmpCutFromWnd(Wnd: HWND; Bmp: TBitmap; CutRect: TRect);
// Wnd := ParentWindowFromMouse;
// Bmp
begin
  WindowToBmp(Wnd, Bmp);
  BmpCutImage(Bmp, CutRect);
  Bmp.PixelFormat := pf32bit;
end;

procedure BmpFloodFillXY(Bmp: TBitmap; X, Y: Integer; C_Brush, C_Border: TColor; Border: Boolean);
// from Images.pas
var
  Col_XY : TColor;
begin
  Bmp.Canvas.Brush.Color := C_Brush;
  if Border then
  begin
    Bmp.Canvas.FloodFill(X, Y, C_Border, fsBorder ); // fill with Point Color all what is not C_Border
  end else
  begin
    Col_XY := Bmp.Canvas.Pixels[X, Y];
    Bmp.Canvas.FloodFill(X, Y, Col_XY, fsSurface); // all from Point what is Col_XY with Brush.Color
  end;
end;


var
  fBmpFree: Array of TBitmap = nil;

function  BmpFreeGet(W, H: Integer; BrushColor:TColor=clBlack): TBitmap;  // method to reuse Bitmaps to avoid free and create
var
  Len : Integer;
  W1, H1: Integer;
begin
  Len := Length(fBmpFree);
  if Len = 0 then
  begin
    Result := TBitmap.Create;
  end else
  begin
    Result := fBmpFree [Len -1];
    SetLength(fBmpFree, Len -1);
    BmpWH(Result, W1, H1);
    if (W1 <> W) and (H1 <> H) then
    begin // avoid unwanted copy of parts of old image when later set to W and H 
      Result.Width  := 0;
      Result.Height := 0;
    end;
  end;
  Result.PixelFormat := pf32bit;
  Result.Canvas.Brush.Color := BrushColor;
  Result.Width  := W;
  Result.Height := H;
end;

procedure BmpFreeSet(Bmp: TBitmap);
var
  Len: Integer;
begin
  if Bmp <> nil then
  begin
    Len := Length(fBmpFree);
    if Len < 5 then
    begin
      SetLength(fBmpFree, Len +1);
      fBmpFree[Len] := Bmp;
      //Bmp := nil;
    end else
    begin
      Bmp.Free;
    end;
  end;
end;

function BmpCreate32(W, H: Integer; BrushColor:TColor=clBlack): TBitmap;
begin
  {
  Result := TBitmap.Create;
  Result.PixelFormat := pf32bit;
  Result.Canvas.Brush.Color := BrushColor;
  Result.Width  := W;
  Result.Height := H;
  }
  Result := BmpFreeGet(W, H, BrushColor);
end;

procedure BmpReplace(BmpDest, BmpSource: TBitmap);
begin
  if Assigned(BmpDest) then
    BmpDest.Assign(BmpSource);
  //BmpSource.Free;
  BmpFreeSet(BmpSource);
end;

(*****
procedure BmpReplace1(var BmpDest: TBitmap; BmpSource: TBitmap);
begin
  //BmpDest.Assign(BmpSource);
  //BmpSource.Free;
  BmpFreeSet(BmpDest);
  BmpDest := BmpSource;
end;
****)

function BmpCreateCopy32(const Bmp: TBitmap): TBitmap;
begin
  Result := TBitmap.Create;
  Result.Assign(Bmp);
  Result.PixelFormat := pf32bit;
end;

function BmpHisto(Bmp: TBitmap; HistoMode: TClipMode=CM_Gray): TIntArr;
var
  W, H, x, y : Integer;
  SlArr : TSL32Arr;
begin
  SetLength(Result, 0);    // ensure clear result!
  SetLength(Result, 256);
  BmpWH(Bmp, W, H);
  SlArr := BmpSL32Arr(Bmp);
  for y := 0 to H -1 do
    for x := 0 to W -1 do
    case HistoMode of
      CM_Gray: Inc(Result[GrayVal32(SlArr[y, x])]);
      CM_Hue : Inc(Result[HSV_HVal (SlArr[y, x])]);
      CM_Sat : Inc(Result[HSV_SVal (SlArr[y, x])]);
      CM_V   : Inc(Result[HSV_VVal (SlArr[y, x])]);
    end;
end;

function BmpCross(Bmp: TBitmap; CMa, CMb: TClipMode): TDoubArrArr;
var
  SlArr : TSL32Arr;
  function ClipVal(CM: TClipMode; x, y : Integer): Byte;
  begin
    case CM of
      CM_Gray: Result := GrayVal32(SlArr[y, x]);
      CM_Hue : Result := HSV_HVal (SlArr[y, x]);
      CM_Sat : Result := HSV_SVal (SlArr[y, x]);
      CM_V   : Result := HSV_VVal (SlArr[y, x]);
      else Result := 0;     // 08.01.09 P.W
    end;
  end;

var
  W, H, x, y : Integer;
begin
  SetLength(Result, 0);    // ensure clear result!
  SetLength(Result, 256, 256);
  BmpWH(Bmp, W, H);
  SlArr := BmpSL32Arr(Bmp);
  for y := 0 to H -1 do
    for x := 0 to W -1 do
      IncD(Result[ClipVal(CMb, x, y), ClipVal(CMa, x, y)]);
end;

function BmpToProfiles(Bmp: TBitmap): TIntArrArr;
var
  W, H, x, y : Integer;
  SlArr : TSL32Arr;
begin
  BmpWH(Bmp, W, H);
  SetLength(Result, H, W);
  SlArr := BmpSL32Arr(Bmp);
  for y := 0 to H -1 do
    for x := 0 to W -1 do
      Result[y, x]:=GrayVal32(SlArr[y, x]);
end;

function ProfilesToBmp(Profiles: TIntArrArr): TBitmap;
var
  W, H, x, y : Integer;
  SlArr : TSL32Arr;
begin
  ArrWH(Profiles, W, H);
  Result:= BmpCreate32(W, H);
  SlArr := BmpSL32Arr(Result);
  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SLArr[y, x] := GrayValToCol32(Profiles[y, x]);
end;

function DoubArrArrToBmp(const A: TDoubArrArr): TBitmap;

var
  MinMax : TMinMax;
  Factor : Double;
  function Normalized(D: Double): Byte;
  begin
    // Result := EnsureRange(Round(Factor * (D - MinMax.MinVal)), 0, 255);
    Result :=  EnsureRange(Round(Factor * Ln(1 + D - MinMax.MinVal)), 0, 255);
  end;
var
  W, H, x, y : Integer;
  SlArr : TSL32Arr;
begin
  MinMax := DoubArrArrMinMax(A);
  if (MinMax.MaxVal <> MinMax.MinVal) then
  begin
    // Factor := 255 / (MinMax.MaxVal - MinMax.MinVal);
    Factor := 255 / (Ln(1 + MinMax.MaxVal - MinMax.MinVal) - Ln(1)) ;
  end else
  begin
    Factor := 255;
  end;
  ArrWH(A, W, H);

  Result:= BmpCreate32(W, H);
  SlArr := BmpSL32Arr(Result);
  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SLArr[y, x] := GrayValToCol32(Normalized(A[y, x]));

end;


procedure PictureToPicBmp(PicSrc, PicDest: TPicture);
const
  pixFormat = pf32bit;
// includes corrections for TMetafile size
  const
    HundredthMMPerInch = 2540; // from Graphics.pas
  function ScreenLogPixels: Integer;
  // from Graphics.pas
  var
    DC: HDC;
  begin
    DC := GetDC(0);
    Result := GetDeviceCaps(DC, LOGPIXELSY);
    ReleaseDC(0,DC);
  end;

  function GetEnhMetaHeader(MF: TMetaFile): TEnhMetaHeader;
  var
    EMFHeader: TEnhMetaHeader;
    MFHandle: HENHMETAFILE;
  begin
    MFHandle := MF.Handle;
    if (MFHandle <> 0) and (0 <> GetEnhMetaFileHeader(MFHandle, Sizeof(EMFHeader), @EMFHeader)) then
    begin
      Result := EMFHeader;
    end else
    begin
      FillChar(Result, SizeOf(Result), #0);
    end;
  end;

  function MetaWidth(MF: TMetaFile): Integer;
  // LoadFromClipboardFormat should set FInch to non zero!
//  var
//    EMFHeader: TEnhMetaHeader;
  begin
//    EMFHeader := GetEnhMetaHeader(MF);
    Result := MulDiv(MF.MMWidth, ScreenLogPixels, HundredthMMPerInch);
  end;
  function MetaHeight(MF: TMetaFile): Integer;
  // LoadFromClipboardFormat should set FInch to non zero!
  begin
    Result := MulDiv(MF.MMHeight, ScreenLogPixels, HundredthMMPerInch);
  end;
var
  EquFlg : Boolean;
  MF : TMetaFile;
begin
  EquFlg := (PicSrc = PicDest);
  if EquFlg then
  begin
    if (not Assigned(PicSrc.Graphic)) or (PicSrc.Graphic is TBitmap) then
    begin  // Access to PicDest.Bitmap creates Bitmap if not existing or changes to Bitmap!
      PicDest.Bitmap.PixelFormat := pf32bit;  // forces Src and Dest to be Bitmap!
      Exit;
    end else
    begin
      // create a copy:
      PicSrc := TPicture.Create;
      PicSrc.Assign(PicDest);
    end;
  end;

  // Picture.Bitmap is a property which creates a bitmap if not already a bitmap:
  PicDest.Bitmap.Canvas.Lock;   // urgent in multithreading applications!
  // ----------------------------------------------------------------------------
  // ### LOOK OUT: Never place the cursor above PicDest.Bitmap if EquFlg is true!
  //               This changes type of Src to Bitmap and looses the data!
  PicDest.Bitmap.PixelFormat := pf32bit;  // forces Dest to be Bitmap
  // ###
  // ----------------------------------------------------------------------------


  if PicSrc.Graphic = nil then
  begin
    PicDest.Bitmap.Height := 0;
    PicDest.Bitmap.Width  := 0;
    Exit;
  end;
  MF := nil;
  if PicSrc.Graphic is TMetafile then
  begin // correct incorrect size      (works for import from MS Paint; MS Word does not match!)
    MF := TMetaFile(PicSrc.Graphic);
    MF.Width  := MetaWidth (MF);
    MF.Height := MetaHeight(MF);
  end;

  PicDest.Bitmap.Width  := PicSrc.Graphic.Width;
  PicDest.Bitmap.Height := PicSrc.Graphic.Height;
  if Assigned(MF) then
  begin
    PicSrc.Graphic.Width  := PicSrc.Graphic.Width  +1;
    PicSrc.Graphic.Height := PicSrc.Graphic.Height +1;
  end;
  PicDest.Bitmap.Canvas.Draw(0,0, PicSrc.Graphic);

  PicDest.Bitmap.Canvas.Unlock; // urgent in multithreading applications!

  If EquFlg then
    FreeAndNil(PicSrc);
end;

procedure PictureToBmp(picture: TPicture);
begin
  PictureToPicBmp(Picture, Picture);
end;

procedure CallEmptyClipboard;
begin
  OpenClipboard(0);
  EmptyClipboard;
  CloseClipboard;
end;

function PicFromClipboard(Pic: TPicture): Boolean;
var
  Pic0 : TPicture;
begin
  if Clipboard.HasFormat(CF_PICTURE) or Clipboard.HasFormat(CF_BITMAP) then
  begin
    Result := True;
    Pic0 := TPicture.Create;

    Pic0.Assign(Clipboard);
    PictureToPicBmp(Pic0, Pic);

    Pic0.Free;
  end else
  begin
    Result := False;
  end;
end;

{
function PicFromClipboard(Pic: TPicture): Boolean;
begin
  if Clipboard.HasFormat(CF_PICTURE) then
  begin
    Result := True;
    Pic.Assign(Clipboard);
    PictureToBmp(Pic);
  end else
  if Clipboard.HasFormat(CF_BITMAP) then
  begin
    Result := True;
    Pic.Bitmap.Assign(Clipboard);
  end else
  begin
    Result := False;
  end;
end;
}

function BmpFromClipboard(Bmp: TBitmap): Boolean;
var
  Pic : TPicture;
begin
  if Clipboard.HasFormat(CF_PICTURE) then
  begin
    Pic := TPicture.Create;
    Result := PicFromClipboard(Pic);
    Bmp.Assign(Pic.Bitmap);
    FreeAndNil(Pic);
  end else
  if Clipboard.HasFormat(CF_BITMAP) then
  begin
    Result := True;
    Bmp.Assign(Clipboard);
  end else
  begin
    Result := False;
  end;
end;

procedure ProcPicToClipboard(Pic: TPicture);
begin
  CallEmptyClipboard;
  Clipboard.Assign(Pic);
end;

procedure ProcBmpToClipboard(Bmp: TBitMap);
begin
  if Assigned(Bmp) then
  begin
    CallEmptyClipboard;
    Clipboard.Assign(Bmp);
  end;  
end;

function BmpHash(Bmp: TBitmap): DWORD;
type
  pByteArr = ^tByteArr;
  tByteArr = Array[0..0] of Byte;
var
  W, H, y : Integer;
  CRC : DWORD;
  SL : pByteArr;
  SLen : Integer;
begin
  BmpWH(Bmp, W, H);
  Case Bmp.PixelFormat of
    pf1bit  : SLen := W div 8;
    pf4bit  : SLen := W div 2;
    pf8bit  : SLen := W div 1;
    pf15bit : SLen := W * 2;
    pf16bit : SLen := W * 2;
    pf24bit : SLen := W * 3;
    pf32bit : SLen := W * 4;
    else // pfDevice, pfCustom :
      begin
        Bmp.PixelFormat := pf24bit;
        SLen := 3 * W;
      end;
  end;

  CRC := $FFFFFFFF;
  for y := 0 to H -1 do
  begin
    SL := Bmp.ScanLine[y];
    CalcCRC32 (Addr(SL[0]), SLen, CRC);
  end;
  CRC := NOT CRC;

  Result := CRC;
end;

type
  TIntAsXY = packed record
    case Integer of
      0: (I:Integer);
      1: (x, y: Word);
  end;

function BmpGetPattern(Bmp: TBitmap; x0, y0: Integer; pdx, pdy: Integer): TColArr;
var
  SLA : TSL32Arr;
  W, H, x, y : Integer;
begin
  BmpWH(Bmp, W, H);
  if (x0 >= 0) and (x0+pdx < W) and (y0 >= 0) and (y0+pdy < H) then
  begin
    SLA := BmpSL32Arr(Bmp);
    SetLength(Result, pdx * pdy);
    for x := x0 to x0 + pdx -1 do
      for y := y0 to y0 + pdy -1 do
        Result[(x-x0) + (y-y0)*pdx] := SLA[y, x];
  end else
  begin
    SetLength(Result, 0);
  end;
end;

function BmpFindPatternNumLimited(var x00, y00: Integer; pdx, pdy, Limit, NumLimit: Integer; Bmp: TBitmap; const Pattern: TColArr): Integer;
  function PatternMatchtes(CA, CB : TCol32): Boolean;
  begin
    Result := Abs(CA.R - CB.R) + Abs(CA.G - CB.G) + Abs(CA.B - CB.B) <= Limit;
  end;
label
  Next_y0;
const
  TimeLimitSec = 2.0;
  thr = 0.5;
var
  Time: TDateTime;
  SLA : TSL32Arr;
  W, H, x0, y0, x, y, NumPattern, EquCtr: Integer;
begin
  NumPattern := pdx * pdy;

  x00 := 0;
  y00 := 0;
  Result := 0;

  BmpWH(Bmp, W, H);
  SLA := BmpSL32Arr(Bmp);
  Time := Now;
  for x0 := 0 to W-1 -pdx do
  begin
    Application.ProcessMessages;
    if (Abs(Time-Now)*24*3600 > TimeLimitSec) or Application.Terminated then
    begin
      Result := 0;
      Exit;
    end;
    for y0 := 0 to H-1 -pdy do
    begin
      // check position (x0, y0):
      EquCtr := 0;
      for x := x0 to x0 + pdx -1 do
      begin
        for y := y0 to y0 + pdy -1 do
        begin
          if PatternMatchtes(Pattern[(x-x0) + (y-y0)*pdx], SLA[y, x]) then
          begin
            Inc(EquCtr);
          end else
          begin
            goto Next_y0;
          end;
        end;
      end;
      // ---
      if EquCtr = Length(Pattern) then
      begin
        Inc(Result);
        if (Result = 1) then
        begin
          x00 := x0;
          y00 := y0;
        end;
        if Result >= NumLimit then exit;
      end;
      Next_y0:
    end;
  end;
end;

function BmpFindPattern(Bmp: TBitmap; const Pattern: TColArr; pdx, pdy, Limit: Integer; RatioNonMatch: Double): TPntArr;
var
  NonMatchCtr, NonMatchLimit, AcceptNumNonMatch : Integer;
  function PatternMatchtes(CA, CB : TCol32): Boolean;
  var
    ds : Integer;
  begin
    // Result := (Abs(CA.R - CB.R) <= Limit) and (Abs(CA.G - CB.G) <= Limit) and (Abs(CA.B - CB.B) <= Limit)
    ds := Abs(CA.R - CB.R) + Abs(CA.G - CB.G) + Abs(CA.B - CB.B);
    Result := (ds <= Limit);
    if (not Result) and (ds <= NonMatchLimit) then
    begin
      Inc(NonMatchCtr);
      Result := NonMatchCtr <= AcceptNumNonMatch;
    end;

  end;
label
  Next_y0;
var
  SLA : TSL32Arr;
  W, H, x0, y0, x, y : Integer;
  NumPattern, LenRes, EquCtr: Integer;
begin
  NumPattern := pdx * pdy;
  NonMatchCtr := 0;
  AcceptNumNonMatch := Max(1, Round(RatioNonMatch * NumPattern));
  NonMatchLimit := Limit + 3;

  LenRes := 0;
  SetLength(Result, LenRes);
  BmpWH(Bmp, W, H);
  SLA := BmpSL32Arr(Bmp);
  for x0 := 0 to W-1 -pdx do
  begin
    for y0 := 0 to H-1 -pdy do
    begin
      // check position (x0, y0):
      EquCtr := 0;
      for x := x0 to x0 + pdx -1 do
      begin
        for y := y0 to y0 + pdy -1 do
        begin
          //if Pattern[(x-x0) + (y-y0)*pdx] = GetPattern(SLA[y, x]) then
          if PatternMatchtes(Pattern[(x-x0) + (y-y0)*pdx], SLA[y, x]) then
          begin
            Inc(EquCtr);
          end else
          begin
            goto Next_y0;
          end;
        end;
      end;
      // ---
      if EquCtr = Length(Pattern) then
      begin
        Inc(LenRes);
        SetLength(Result, LenRes);
        Result[LenRes-1].X := x0;
        Result[LenRes-1].Y := y0;
      end;
      Next_y0:
    end;
  end;
end;

function PatternSorted(const Pattern: TColArr): TColArr;
begin
  Result := TColArr(IntArrSortFunc(TIntArr(Pattern)));
end;

function PatternNumDifferentValues(const Pattern: TColArr): Integer;
var
  PatSort : TColArr;
  ColTst : TCol32;
  Len, I : Integer;
begin
  Result := 0;
  Len := Length(Pattern);
  Result := Min(1, Len);
  if Len > 0 then
  begin
    PatSort := PatternSorted(Pattern);
    ColTst := PatSort[0];
    for I := 1 to Len -1 do
    begin
      if ColTst.C <> PatSort[I].C then
      begin
        Inc(Result);
        ColTst := PatSort[I];
      end;
    end;
  end;
end;

function PatternHisto(const Pattern: TColArr): TColHistArr;   overload;
var
  PatSort : TColArr;
  ColTst : TCol32;
  LenP, LenR, I : Integer;

  procedure NewTstCol(C: TCol32);
  begin
    ColTst := C;
    Inc(LenR);
    Result[LenR-1].Col := C;
    Result[LenR-1].Num := 1;
  end;
begin
  Result := nil;               // "0" -> 'nil": 08.01.09 P.W
  LenP := Length(Pattern);
  LenR := 0;
  SetLength(Result, LenP);     // more than necessary : avoid resizing often
  if LenP > 0 then
  begin
    PatSort := PatternSorted(Pattern);

    NewTstCol(PatSort[0]);

    for I := 1 to LenP -1 do
    begin
      if ColTst.C <> PatSort[I].C then
      begin
        NewTstCol(PatSort[I]);
      end else
      begin
        Inc(Result[LenR-1].Num);
      end;
    end;
  end;
  SetLength(Result, LenR);
end;

function PatternHisto(Patterns: Array of TCol32): TColHistArr;   overload;
// call like:  PatHisto := PatternHisto([c32White, c32Blue, c32White, c32Red]);
var
  Len, I : Integer;
  Pattern : TColArr;
begin
  Len := Length(Patterns);
  SetLength(Pattern, Len);
  for I := 0 to Len -1 do
    Pattern[I] := Patterns[I];
  Result := PatternHisto(Pattern);
end;

function BmpPatternMatchQuality(BmpA, BmpB: TBitmap; Limit: Integer; var Pnts: TPntArr): TIntArr; overload;
  function GetTestPnts(W, H, df, pdx, pdy: Integer): TPntArr;
  var                      //  A   B
    A, B, C, D: TPoint;    //  C   D
  begin
    A := Point(0+df,     0+df);
    B := Point(W-df-pdx, 0+df);
    C := Point(0+df,     H-df-pdy);
    D := Point(W-df-pdx, H-df-pdy);

    SetLength(Result, 8);
    Result[0] := PntMult(PointsAdd(A, B), 0.5);
    Result[1] := PntMult(PointsAdd(A, C), 0.5);
    Result[2] := PntMult(PointsAdd(B, D), 0.5);
    Result[3] := PntMult(PointsAdd(C, D), 0.5);
    Result[4] := A;
    Result[5] := B;
    Result[6] := C;
    Result[7] := D;

  end;

const
  pdxy   =  50;
  df     =   8;
  RatioNonMatch = 0.0;

var
  W, H, Len, x0, y0, x00, y00, I : Integer;
  Pattern             : TColArr;
  TestPnts           : TPntArr;
begin
  BmpWH(BmpA, W, H);
  TestPnts := GetTestPnts(W, H, df, pdxy, pdxy);
  Len := Length(TestPnts);
  SetLength(Result, Len);
  SetLength(Pnts,   Len);
  for I := 0 to Len -1 do
  begin
    x0 := TestPnts[I].X;
    y0 := TestPnts[I].Y;
    Pattern := BmpGetPattern (BmpA, x0, y0,  pdxy, pdxy);

    Result[I] := BmpFindPatternNumLimited(x00, y00, pdxy, pdxy, Limit, 2, BmpB, Pattern);
    if Result[I] <= 0 then
    begin
      Pnts  [I] := Point(0, 0);
    end else
    begin
      Pnts  [I] := Point(x0-x00, y0-y00);
    end;
  end;
end;

function BmpPatternMatchQuality(BmpA, BmpB: TBitmap; Limit: Integer; var Pnt: TPoint): Integer; overload;
  function CheckReady(aLimit: Integer; var aResult: Integer; var MuchFlg: Boolean): Boolean;
  var
    Pnts   : TPntArr;
    MqVals : TIntArr;
     I : Integer;
  begin
    MuchFlg := False;
    MqVals := BmpPatternMatchQuality(BmpA, BmpB, Max(0, aLimit), Pnts);
    for I := 0 to Length(MqVals) -1 do
    begin
      case MqVals[I] of
        0: ;
        1: begin
            Pnt    := Pnts[I];
            Result := True;
            aResult := 1;
            exit;
          end;
        else
          MuchFlg := True;
      end;
    end;
    Result := False;
  end;
var
  MuchFlg: Boolean;
begin
  if   CheckReady(Limit, Result, MuchFlg) then Exit;
  While MuchFlg and (Limit > 0) do
  begin
    Dec(Limit, 3);
    if CheckReady(Limit, Result, MuchFlg) then Exit;
  end;
  Result := -1;
  Pnt    := Point(0,0);
end;

function BmpPatternFindDxDy(BmpA, BmpB: TBitmap): TPntArr;
  function GetTestPnts(W, H, df, pdx, pdy: Integer): TPntArr;
  begin
    SetLength(Result, 4);
    Result[0] := Point(0+df,     0+df);
    Result[1] := Point(W-df-pdx, 0+df);
    Result[2] := Point(0+df,     H-df-pdy);
    Result[3] := Point(W-df-pdx, H-df-pdy);

//SetLength(Result, 1);
//Result[0] := Point(W-df-pdx, 0+df);
  end;

const
  pdxy0  =  32;
  df0    =   8;
  MaxPts =  16;
  MaxpdxyMax = 2*32;

label
  L_Restart;
var
  df, dfMax,
  pdxy, pdxyMax, PatNumDifVals,
  W, H, Limit, LimitUse, x0, y0, I, LenT, LenR, LenP, LenPmaxi, P : Integer;
  RatioNonMatch: Double;
  FindPattern : Boolean;

//PatHisto                : TColHistArr;
  Pattern                 : TColArr;
  TestPnts, Points        : TPntArr;
begin
  LimitUse      := 0;   // 08.01.09 P.W
  RatioNonMatch := 0;   // 08.01.09 P.W
  df := df0;            // 08.01.09 P.W
  
  BmpWH(BmpA, W, H);

  pdxyMax  := Min(MaxpdxyMax, (Min(W, H) - df) div 3);
  pdxy     := Min(pdxy0, pdxyMax);
  TestPnts := GetTestPnts(W, H, df, pdxy, pdxy);

  df := df0;
  dfmax := (Min(W, H) div 4) - pdxyMax;
  Limit := 0;
  Repeat
  L_Restart:
    LenR := 0;
    SetLength(Result, LenR);
    LenT := Length(TestPnts);
    LenPmaxi := 0;
    for I := 0 to LenT -1 do
    begin
      x0 := TestPnts[I].X;
      y0 := TestPnts[I].Y;
      Pattern := BmpGetPattern (BmpA, x0, y0,  pdxy, pdxy);

      // PatHisto := PatternHisto(Pattern);
      // PatNumDifVals := Length(PatternHisto(Pattern));

      PatNumDifVals := PatternNumDifferentValues(Pattern);

      FindPattern := (PatNumDifVals > 1);
      case PatNumDifVals of
        1:
          begin  // pattern all values are equal
          end;
        2..4:
          begin
            LimitUse := 0;
            RatioNonMatch := 0.005 * Limit;
          end;
        else
          begin
            RatioNonMatch := 0.010 * Limit;
            LimitUse := (1+(Limit div 4)) * 3;
          end;
      end;

      if FindPattern then
      begin
        Points  := BmpFindPattern(BmpB, Pattern, pdxy, pdxy, LimitUse, RatioNonMatch);
        LenP    := Length(Points);
        LenPmaxi := Max(LenP, LenPMaxi);
      end else
      begin
        Points := nil;
        LenP   := 0;
        LenPMaxi := 2 * MaxPts;  // assume many points to allow enlargement of testarea
      end;

      if (LenPmaxi > MaxPts) and (pdxy < pdxyMax) and (I = LenT -1) and (LenR = 0) then
      begin
        pdxy := Min(pdxyMax, pdxy + Max(4, pdxy div 2));
        TestPnts := GetTestPnts(W, H, df, pdxy, pdxy);
        if (pdxy < pdxyMax) and (Limit > 0) then
          dec(Limit);
        goto L_Restart;
      end;


      if (LenP > 0) and(LenP <= MaxPts) then
      begin // append points to Result
        Inc(LenR, LenP);
        SetLength(Result, LenR);
        for P := 0 to LenP -1 do
          Result[LenR-LenP+P] := Point(x0 - Points[P].X, y0 - Points[P].Y);
      end;
    end;
    Inc(Limit);
  until (LenR > 0) or (Limit > 16);
  Dec(Limit);
//if LenPmaxi * LenR * Limit * pdxy * pdxymax * Length(Result) > 0 then;

//  ShowMessageFmt('BmpPatternFindDxDy #Results: %d; Limit:%d', [LenR, Limit]);
end;

procedure TestPattern(Bmp: TBitmap);
var
  Pattern: TColArr;
  Points : TPntArr;
  Len, I, x0, y0 : Integer;
begin
  Pattern := BmpGetPattern(Bmp, 20, 20, 5, 5);
  Points  := BmpFindPattern(Bmp, Pattern, 5, 5, 0, 0);
  Len     := Length(Points);
  If Len > 0 then
  begin
    for I := 0 to Len -1 do
    begin
      x0 :=  Points[I].x;
      y0 :=  Points[I].y;
      ShowMessageFmt('Pattern found %2d/%2d at: (%4d;%4d)', [I, Len, x0, y0]);
    end;
  end else
  begin
    ShowMessage('Pattern not found!');
  end;

end;

procedure BmpWH(Bmp: TBitmap; var W, H: Integer);
begin
  if Assigned(Bmp) then
  begin
    W := Bmp.Width;
    H := Bmp.Height;
  end else
  begin
    W := 0;
    H := 0;
  end;
end;

procedure BmpWH(BmpA, BmpB: TBitmap; var W, H: Integer);
begin
  BmpWH(BmpA, W, H);
  if Assigned(BmpB) then
  begin
    W := Min(W, BmpB.Width );
    H := Min(H, BmpB.Height);
  end;
end;

procedure BmpWH(BmpA, BmpB, BmpC: TBitmap; var W, H: Integer);
begin
  BmpWH(BmpA, BmpB, W, H);
  if Assigned(BmpC) then
  begin
    W := Min(W, BmpC.Width );
    H := Min(H, BmpC.Height);
  end;
end;

procedure BmpWHmax(BmpA, BmpB: TBitmap; var W, H: Integer);
begin
  W := Max(BmpA.Width,  BmpB.Width );
  H := Max(BmpA.Height, BmpB.Height);
end;

function BmpSL24Arr(Bmp: TBitmap): TSL24Arr;
// sets Bmp.PixelFormat!
var
  W, H, y : Integer;
begin
  BmpWH(Bmp,W,H);
  Bmp.PixelFormat := pf24bit;
  SetLength(Result, H);
  for y := 0 to H -1 do
    Result[y] := Bmp.ScanLine[y];
end;

procedure LargeBmpPixelFormat(Bmp0: TBitmap; pf: TPixelFormat);
// does not help: in case of large DDB the creation of the handle fails!
const
  MaxLines = 128;
var
  W, H, HRemain, HBand, yBand : Integer;
  B, BLen : Integer;
  BArr : Array of TBitmap;
  Bmp : TBitmap;
  CvB : TCanvas;
  CvH : HDC;
begin
  BmpWH(Bmp0, W,H);

  BLen := (H div MaxLines);
  if BLen * MaxLines < H then inc(BLen);
  SetLength(BArr, BLen);
  HRemain := H;
  yBand   := 0;
  for B := 0 to BLen - 1 do
  begin
    HBand := Min(HRemain, MaxLines);
    BArr[B] := TBitmap.Create;
    Bmp := BArr[B];
    CvB := Bmp.Canvas;
    Bmp.PixelFormat := pf;
    Bmp.Width  := W;
    Bmp.Height := HBand;
    CvH := Bmp0.Canvas.Handle;

    BitBlt(CvB.Handle, 0, 0    , W, HBand,              // Destination
           CvH       , 0, yBand,           cmSrcCopy);  // Source
    Dec(HRemain, HBand);
    Inc(yBand, HBand);
  end;



//  Bmp1 := TBitmap.Create;
//  Bmp1.PixelFormat := pf;
//  Bmp1.Width  := W div 1;
//  Bmp1.Height := H div 1;
//  H0 := Bmp0.Canvas.Handle;
//  H1 := Bmp1.Canvas.Handle;
//  BitBlt(H1, 0, 0, W, H,        // Destination
//         H0, 0, 0, cmSrcCopy);  // Source
//  Bmp1.Assign(Bmp0);
//  Bmp0.Assign(Bmp1);
//  FreeAndNil(Bmp1);
end;

function HDCSl32Arr(Handle: HDC): TSL32Arr;
{
procedure TBitmap.SetPixelFormat(Value: TPixelFormat);
const
  BitCounts: array [pf1Bit..pf32Bit] of Byte = (1,4,8,16,16,24,32);
var
  DIB: TDIBSection;
  Pal: HPalette;
  DC: HDC;
  KillPal: Boolean;
begin
  if Value = GetPixelFormat then Exit;
  case Value of
    pfDevice:
      begin
        HandleType := bmDDB;
        Exit;
      end;
    pfCustom: InvalidGraphic(@SInvalidPixelFormat);
  else
    FillChar(DIB, sizeof(DIB), 0);
    DIB.dsbm := FImage.FDIB.dsbm;
    KillPal := False;
    with DIB, dsbm, dsbmih do
    begin
      bmBits := nil;
      biSize := sizeof(DIB.dsbmih);
      biWidth := bmWidth;
      biHeight := bmHeight;
      biPlanes := 1;
      biBitCount := BitCounts[Value];
      Pal := FImage.FPalette;
      case Value of
        pf4Bit: Pal := SystemPalette16;
        pf8Bit:
          begin
            DC := GDICheck(GetDC(0));
            Pal := CreateHalftonePalette(DC);
            KillPal := True;
            ReleaseDC(0, DC);
          end;
        pf16Bit:
          begin
            biCompression := BI_BITFIELDS;
            dsBitFields[0] := $F800;
            dsBitFields[1] := $07E0;
            dsBitFields[2] := $001F;
          end;
      end;
      try
        CopyImage(Handle, Pal, DIB);
        PaletteModified := Pal <> 0;
      finally
        if KillPal then DeleteObject(Pal);
      end;
      Changed(Self);
    end;
  end;
end;
}
{
function TBitmap.GetScanLine(Row: Integer): Pointer;
begin
  Changing(Self);
  with FImage.FDIB, dsbm, dsbmih do
  begin
    if (Row < 0) or (Row >= bmHeight) then
      InvalidOperation(@SScanLine);
    DIBNeeded;
    GDIFlush;
    if biHeight > 0 then  // bottom-up DIB
      Row := biHeight - Row - 1;
    Integer(Result) := Integer(bmBits) +
      Row * BytesPerScanline(biWidth, biBitCount, 32);
  end;
end;
}
{
procedure TBitmap.DIBNeeded;
begin
  with FImage do
  begin
    if (FHandle = 0) or (FDIBHandle <> 0) then Exit;
    PaletteNeeded;
    if FDIB.dsbmih.biSize = 0 then
    begin
      GetObject(FHandle, sizeof(FDIB), @FDIB);
      with FDIB, dsbm, dsbmih do
      begin
        biSize := sizeof(dsbmih);
        biWidth := bmWidth;
        biHeight := bmHeight;
        biPlanes := 1;
        biBitCount := bmPlanes * bmBitsPixel;
      end;
    end;
    FDIBHandle := CopyBitmap(FHandle, FPalette, FPalette, FDIB, nil);
  end;
end;
}


begin
//  PixelFormat := pf32bit;
end;

function BmpSL32Arr(Bmp: TBitmap): TSL32Arr;
// sets Bmp.PixelFormat!
var
  W, H, y : Integer;
begin
  BmpWH(Bmp,W,H);
//  LargeBmpPixelFormat(Bmp, pf32bit);
  Bmp.PixelFormat := pf32bit;
  SetLength(Result, H);
  for y := 0 to H -1 do
    Result[y] := Bmp.ScanLine[y];
end;

procedure BmpGradCol32(Bmp: TBitmap; GradScale: Double);
// uses Col32.S to store the Gradient
const
  FiltSize = 2; // -> 5x5:  (-2 .. 2) * (-2 .. 2)
var
  SL32Arr: TSL32Arr;

  function Grad(x, y: Integer) : Byte;
  const
    FiltArr : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
      ((-1, -1, -1, -1, -1),
       (-1,  2,  2,  2, -1),
       (-1,  2,  0,  2, -1),
       (-1,  2,  2,  2, -1),
       (-1, -1, -1, -1, -1));
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    Sum : Integer;
  begin
    Sum := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
        Inc(Sum, FiltArr[dy, dx] * GrayVal32(SL32Arr[y+dy, x+dx]));
    Sum := Round(Min(255, Abs(Sum*GradScale)));
    Result := Sum;
  end;
var
  W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  SL32Arr := BmpSL32Arr(Bmp);
  // Grad into *.S part:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32Arr[y,x].S := Grad(x,y);
{
  // *.S part to color:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32Arr[y,x] := GrayValToCol32(SL32Arr[y,x].S);
{}
end;

procedure BmpSharpCol32(Bmp: TBitmap);
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
//FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
  FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32ArrA: TSL32Arr;
  SL32ArrB: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
    // laplace + mean
    FiltArr : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
//    (( 1+0, -2+1,  1+0),
//     (-2+1,  4+2, -2+1),
//     ( 1+0, -2+1,  1+0));    // FSum = 6;

//    ((-1  , -1+1, -1  ),
//     (-2+1,  8  , -1+1),
//     (-1  , -1+1, -1  ));    // FSum = 4;

//     ((-1  , -1  , -1  , -1  , -1  ),
//      (-1  ,  1  ,  2+1,  1  , -1  ),
//      (-1  ,  2+1,  4+2,  2+1, -1  ),
//      (-1  ,  1  ,  2+1,  1  , -1  ),
//      (-1  , -1  , -1  , -1  , -1  )); // FSum = 6;
{
       ((-1  , -1  , -1  , -1  , -1  , -1  , -1  ),
        (-1  ,  1  ,  1  ,  1  ,  1  ,  1  , -1  ),
        (-1  ,  1  ,  1  ,  1  ,  1  ,  1  , -1  ),
        (-1  ,  1  ,  1  ,  0  ,  1  ,  1  , -1  ),
        (-1  ,  1  ,  1  ,  1  ,  1  ,  1  , -1  ),
        (-1  ,  1  ,  1  , -1  ,  1  ,  1  , -1  ),
        (-1  , -1  , -1  , -1  , -1  , -1  , -1  ));
     FSum = 1;
{}
//{
       ((-1  , -1  , -1  , -1  , -1  , -1  , -1  , -1  , -1  ),
        (-1  , -1  , -1  , -1  , -1  , -1  , -1  , -1  , -1  ),
        (-1  , -1  ,  2  ,  2  ,  2  ,  2  ,  2  , -1  , -1  ),
        (-1  , -1  ,  2  ,  3  ,  3  ,  3  ,  2  , -1  , -1  ),
        (-1  , -1  ,  2  ,  3  ,  0  ,  3  ,  2  , -1  , -1  ),
        (-1  , -1  ,  2  ,  3  ,  3  ,  3  ,  2  , -1  , -1  ),
        (-1  , -1  ,  2  ,  2  ,  2  ,  2  ,  2  , -1  , -1  ),
        (-1  , -1  , -1  , -1  , -1  , -1  , -1  , -1  , -1  ),
        (-1  , -1  , -1  , -1  , -1  , -1  , -1  , -1  , -1  ));
    FSum = 1 ;
{}
{
       (( 1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ),
        ( 1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ),
        ( 1  ,  1  ,  2  ,  2  ,  2  ,  2  ,  2  ,  1  ,  1  ),
        ( 1  ,  1  ,  2  ,  3  ,  3  ,  3  ,  2  ,  1  ,  1  ),
        ( 1  ,  1  ,  2  ,  3  ,  4  ,  3  ,  2  ,  1  ,  1  ),
        ( 1  ,  1  ,  2  ,  3  ,  3  ,  3  ,  2  ,  1  ,  1  ),
        ( 1  ,  1  ,  2  ,  2  ,  2  ,  2  ,  2  ,  1  ,  1  ),
        ( 1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ),
        ( 1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ,  1  ));
    FSum = 116;
{}
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArr[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    SumR, SumG, SumB : Integer;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);

    SumR := 0;
    SumG := 0;
    SumB := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Inc(SumR, FiltArr[dy, dx] * SL32ArrB[y+dy, x+dx].R);
        Inc(SumG, FiltArr[dy, dx] * SL32ArrB[y+dy, x+dx].G);
        Inc(SumB, FiltArr[dy, dx] * SL32ArrB[y+dy, x+dx].B);
      end;
    Result.S :=    0;
    Result.R := EnsureRange(Abs(SumR) div FSum, 0, 255);
    Result.G := EnsureRange(Abs(SumG) div FSum, 0, 255);
    Result.B := EnsureRange(Abs(SumB) div FSum, 0, 255);
  end;

var
  W, H, x, y : Integer;
  BmpB : TBitmap;
begin
  BmpWH(Bmp,W,H);
  BmpB := TBitmap.Create;
  SL32ArrA := BmpSL32Arr(Bmp);
  BmpB.Assign(Bmp);
  SL32ArrB := BmpSL32Arr(BmpB);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrA[y,x] := Filter(x,y);

  Bmp.Modified := True;
  FreeAndNil(BmpB);
end;

function BmpGetEdge3x3Col32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
//FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const

    FiltArrX : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
//{
       ((-1  ,  0  ,  1  ),
        (-1  ,  0  ,  1  ),
        (-1  ,  0  ,  1  ));
    FSumX = 1;
{}
    FiltArrY : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
//{
       (( -1  , -1  , -1  ),
        (  0  ,  0  ,  0  ),
        (  1  ,  1  ,  1  ));
    FSumY = 1;
{}
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArrX[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    Gray,
    SumX, SumY : Integer;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);

    SumX := 0;
    SumY := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Gray := GrayVal32(SL32ArrA[y+dy, x+dx]);
        Inc(SumX, FiltArrX[dy, dx] * Gray);
        Inc(SumY, FiltArrY[dy, dx] * Gray);
      end;
    Gray :=  EnsureRange(Round(Sqrt((SumX*SumX) + (SumY*SumY))), 0, 255);
//    if Gray > 64 then Gray := 255 else Gray := 0;
    Result.S :=    0;
    Result.R := Gray;
    Result.G := Gray;
    Result.B := Gray;
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

procedure BmpGetEdge3x3Col32_ToS(Bmp: TBitmap);
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
//FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32Arr: TSL32Arr;

  function Filter(x, y: Integer) : Byte;
  const

    FiltArrX : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
//{
       ((-1  ,  0  ,  1  ),
        (-1  ,  0  ,  1  ),
        (-1  ,  0  ,  1  ));
    FSumX = 1;
{}
    FiltArrY : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
//{
       (( -1  , -1  , -1  ),
        (  0  ,  0  ,  0  ),
        (  1  ,  1  ,  1  ));
    FSumY = 1;
{}
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArrX[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    Gray,
    SumX, SumY : Integer;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);

    SumX := 0;
    SumY := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Gray := GrayVal32(SL32Arr[y+dy, x+dx]);
        Inc(SumX, FiltArrX[dy, dx] * Gray);
        Inc(SumY, FiltArrY[dy, dx] * Gray);
      end;
    Gray :=  EnsureRange(Round(Sqrt((SumX*SumX) + (SumY*SumY))), 0, 255);
    Result := 255 - Gray;
  end;

var
  W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  SL32Arr := BmpSL32Arr(Bmp);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32Arr[y,x].S := Filter(x,y);

  Bmp.Modified := True;
end;

function BmpGetEdgeRgb3x3Col32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
//FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
    // laplace + mean
    FiltArrX : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
//{
       ((-1  ,  0  ,  1  ),
        (-1  ,  0  ,  1  ),
        (-1  ,  0  ,  1  ));
    FSumX = 1;
{}
    FiltArrY : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
//{
       (( -1  , -1  , -1  ),
        (  0  ,  0  ,  0  ),
        (  1  ,  1  ,  1  ));
    FSumY = 1;
{}
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArrX[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    Col : TCol32;
    SumRX, SumGX, SumBX,
    SumRY, SumGY, SumBY : Integer;
    d2R, d2G, d2B, Gray: Integer;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);

    SumRX := 0;
    SumGX := 0;
    SumBX := 0;
    SumRY := 0;
    SumGY := 0;
    SumBY := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
      //Gray := GrayVal32(SL32ArrA[y+dy, x+dx]);
        Col := SL32ArrA[y+dy, x+dx];
        Inc(SumRX, FiltArrX[dy, dx] * Col.R);
        Inc(SumGX, FiltArrX[dy, dx] * Col.G);
        Inc(SumBX, FiltArrX[dy, dx] * Col.B);

        Inc(SumRY, FiltArrY[dy, dx] * Col.R);
        Inc(SumGY, FiltArrY[dy, dx] * Col.G);
        Inc(SumBY, FiltArrY[dy, dx] * Col.B);
      end;

    d2R := (SumRX*SumRX) + (SumRY*SumRY);
    d2G := (SumGX*SumGX) + (SumGY*SumGY);
    d2B := (SumBX*SumBX) + (SumBY*SumBY);

    Gray := EnsureRange(Round(0.6*Sqrt(d2R + d2G + d2B)), 0, 255);
//  if Gray > 64 then Gray := 255 else Gray := 0;

    Result.S :=    0;

{
    Result.R := EnsureRange(Round(Sqrt(d2R)), 0, 255);
    Result.G := EnsureRange(Round(Sqrt(d2G)), 0, 255);
    Result.B := EnsureRange(Round(Sqrt(d2B)), 0, 255);
(*}
    Result.R := Gray;
    Result.G := Gray;
    Result.B := Gray;
(**)
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpGetMean3x3Masked(Bmp, BmpMsk: TBitmap): TBitmap;
//  Bmp    : image to be smoothed returned in result
//  BmpMsk : Mask (edges are marked with 255; range 0..255; 0 for no edge
//  smoothing:  spread a pixel into its neighbourhoud by a mean filter
//  Masking :  colors influence decreases along a path pixel for pixel when
//  edge value of pixel differs from origin.
//    Attenuation Filter elements are influence values:
//      Set the elements of Attenuation Filter:
//         Get the Start points edge value: EV0
//         Start with Influence Value IV = 255
//         along the path: get EVp (edge value of path point)
//         calc absolute value difference of EV0 and EVp:   dEV := Abs(EVp - EV0);
//         diminish IV by dEV; enshure IV is not negative;
//  Multiply IV at endpoint with filter value at this point
//    set the result into Attenuation Filter
//  Use Attenuation Filter to get Points color value

const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
//FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
  FiltArr : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 1  ,  2  ,  1  ),
        ( 2  ,  4  ,  2  ),
        ( 1  ,  2  ,  1  ));
var
  SL32ArrA: TSL32Arr;
  SL32ArrM: TSL32Arr;

  // AttFiltArr must be calculated for each image point using the EdgeMask!
  AttFiltArr : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer;
  AttFiltSum: Integer;

  function CalcAttFiltSum: Integer;
  var
    dx, dy : Integer;
  begin
    Result := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
        Inc(Result, AttFiltArr[dx, dy]);
    if Result = 0 then Result := 1;
  end;

  procedure FillAttFilter(x, y: Integer);
  var
    IV, EV0, EVp, dEV : Integer;
    dx, dy, p : Integer;
  begin
    EV0 := SL32ArrM[y, x].R;
    for dy := -FiltSize to FiltSize do
    begin
      for dx := -FiltSize to FiltSize do
      begin
        IV  := 255;
        if (dx<>0) or (dy<>0) then
        for p := 0 to 0 do  // along the path (for 3x3 only one point)
        begin
          EVp := SL32ArrM[y+dy, x+dx].R;
          dEV := Abs(EVp - EV0);
          dEV := (dEV * dEV) div 255;
          Dec(IV, dEV);
        end;
        IV := Max(0, IV);
        AttFiltArr[dy, dx] := FiltArr[dy, dx] * IV;
      end;
    end;
    AttFiltSum := CalcAttFiltSum;
//  ShowMessageFmt('AttFiltSum is %d', [AttFiltSum]);
  end;

  function Filter(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    SumR, SumG, SumB : Integer;
  begin
    FillAttFilter(x, y);
    SumR := 0;
    SumG := 0;
    SumB := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Inc(SumR, AttFiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].R);
        Inc(SumG, AttFiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].G);
        Inc(SumB, AttFiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].B);
      end;

    Result.S :=    0;
    Result.R := EnsureRange(SumR div AttFiltSum, 0, 255);
    Result.G := EnsureRange(SumG div AttFiltSum, 0, 255);
    Result.B := EnsureRange(SumB div AttFiltSum, 0, 255);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);
  SL32ArrM := BmpSL32Arr(BmpMsk);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpGetMean5x5Masked(Bmp, BmpMsk: TBitmap): TBitmap;
//  Bmp    : image to be smoothed returned in result
//  BmpMsk : Mask (edges are marked with 255; range 0..255; 0 for no edge
//  smoothing:  spread a pixel into its neighbourhoud by a mean filter
//  Masking :  colors influence decreases along a path pixel for pixel when
//  edge value of pixel differs from origin.
//    Attenuation Filter elements are influence values:
//      Set the elements of Attenuation Filter:
//         Get the Start points edge value: EV0
//         Start with Influence Value IV = 255
//         along the path: get EVp (edge value of path point)
//         calc absolute value difference of EV0 and EVp:   dEV := Abs(EVp - EV0);
//         diminish IV by dEV; enshure IV is not negative;
//  Multiply IV at endpoint with filter value at this point
//    set the result into Attenuation Filter
//  Use Attenuation Filter to get Points color value

const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
  FiltArr : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 0  ,  1  ,  1  ,  1  ,  0  ),
        ( 1  ,  1  ,  2  ,  1  ,  1  ),
        ( 1  ,  2  ,  4  ,  2  ,  1  ),
        ( 1  ,  1  ,  2  ,  1  ,  1  ),
        ( 0  ,  1  ,  1  ,  1  ,  0  ));
var
  SL32ArrA: TSL32Arr;
  SL32ArrM: TSL32Arr;

  // AttFiltArr must be calculated for each image point using the EdgeMask!
  AttFiltArr : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer;
  AttFiltSum: Integer;

  function CalcAttFiltSum: Integer;
  var
    dx, dy : Integer;
  begin
    Result := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
        Inc(Result, AttFiltArr[dx, dy]);
    if Result = 0 then Result := 1;
  end;

  procedure FillAttFilter(x, y: Integer);
    function PEnd(dx, dy: Integer): Integer;
    begin
      Result := Max(Abs(dx), Abs(dy));
    end;
    procedure Getdxpdyp(const p, dx, dy: Integer; var dxp, dyp: Integer);
    begin
      dxp := dx;
      dyp := dy;
      dxp := EnsureRange(dxp, -p, +p);
      dyp := EnsureRange(dyp, -p, +p);
    end;
  var
    IV, EV0, EVp, dEV : Integer;
    dx, dy, p, dxp, dyp : Integer;
  begin
    EV0 := SL32ArrM[y, x].R;
    for dy := -FiltSize to FiltSize do
    begin
      for dx := -FiltSize to FiltSize do
      begin
        IV  := 255; // for p=0 "CenterPoint"
//        if (dx<>0) or (dy<>0) then
        for p := 1 to PEnd(dx, dy) do  // along the path (for 3x3 only one point)
        begin
          Getdxpdyp(p, dx, dy, dxp, dyp);
          EVp := SL32ArrM[y+dyp, x+dxp].R;
          dEV := 2*Abs(EVp - 0*EV0);
          dEV := (dEV * dEV) div 255;
          Dec(IV, dEV);
        end;
        IV := Max(0, IV);
        AttFiltArr[dy, dx] := FiltArr[dy, dx] * IV;
      end;
    end;
    AttFiltSum := CalcAttFiltSum;
//  ShowMessageFmt('AttFiltSum is %d', [AttFiltSum]);
  end;

  function Filter(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    SumR, SumG, SumB : Integer;
  begin
    FillAttFilter(x, y);
    SumR := 0;
    SumG := 0;
    SumB := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Inc(SumR, AttFiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].R);
        Inc(SumG, AttFiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].G);
        Inc(SumB, AttFiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].B);
      end;

    Result.S :=    0;
    Result.R := EnsureRange(SumR div AttFiltSum, 0, 255);
    Result.G := EnsureRange(SumG div AttFiltSum, 0, 255);
    Result.B := EnsureRange(SumB div AttFiltSum, 0, 255);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);
  SL32ArrM := BmpSL32Arr(BmpMsk);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function Col32Invert(Col: TCol32): TCol32;
begin
  Result.C := not Col.C;
  Result.S :=     Col.S;
end;

procedure BmpInvert(Bmp: TBitmap);
var
  W, H, x, y : Integer;
  SL32Arr : TSL32Arr;
begin
  BmpWH(Bmp, W,H);
  SL32Arr := BmpSL32Arr(Bmp);
  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32Arr[y,x] := Col32Invert(SL32Arr[y,x]);
  Bmp.Modified := True;
end;

function BmpAdd(BmpA, BmpB: TBitmap): TBitmap;
  function AddColors(CA, CB: TCol32): TCol32;
  begin
    Result.S := 0;
    Result.R := EnsureRange((CA.R + CB.R) div 2, 0, 255);
    Result.G := EnsureRange((CA.G + CB.G) div 2, 0, 255);
    Result.B := EnsureRange((CA.B + CB.B) div 2, 0, 255);
  end;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
begin
  BmpWH(BmpA, BmpB, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := AddColors(SL32ArrA[y,x], SL32ArrB[y,x]);

  Result.Modified := True;
end;

function BmpSetRed(BmpA, BmpB: TBitmap): TBitmap;
  function SetRed(CA, CB: TCol32): TCol32;
  begin
    Result.S := 0;
    Result.R := CB.R;
    Result.G := CA.G;
    Result.B := CA.B;
  end;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
begin
  BmpWH(BmpA, BmpB, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := SetRed(SL32ArrA[y,x], SL32ArrB[y,x]);

  Result.Modified := True;
end;

function BmpSetGreen(BmpA, BmpB: TBitmap): TBitmap;
  function SetGreen(CA, CB: TCol32): TCol32;
  begin
    Result.S := 0;
    Result.R := CA.R;
    Result.G := CB.G;
    Result.B := CA.B;
  end;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
begin
  BmpWH(BmpA, BmpB, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := SetGreen(SL32ArrA[y,x], SL32ArrB[y,x]);

  Result.Modified := True;
end;

function BmpSetBlue(BmpA, BmpB: TBitmap): TBitmap;
  function SetBlue(CA, CB: TCol32): TCol32;
  begin
    Result.S := 0;
    Result.R := CA.R;
    Result.G := CA.G;
    Result.B := CB.B;
  end;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
begin
  BmpWH(BmpA, BmpB, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := SetBlue(SL32ArrA[y,x], SL32ArrB[y,x]);

  Result.Modified := True;
end;

function Rotate90Deg(BmpA: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR : TSL32Arr;
begin

  BmpWH(BmpA, W, H);
  Result := BmpCreate32(H, W);  // W, H exchanged!
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[(W-1)-x, y] := SL32ArrA[y, x];  // SL32ArrR[x, y]: x, y exchanged!

  Result.Modified := True;
end;


function BmpCompareMatch(BmpA, BmpB: TBitmap; dx, dy, dFrame: Integer): Double;
// compares only each 4th point!
const
  IgnoreWhite = False;

  function DeltaColor(CA, CB: TCol32): Double;
  begin
    Result := Sqrt(Sqr(CA.R - CB.R) + Sqr(CA.G - CB.G) + Sqr(CA.B - CB.B));
  end;
  function DeltaColorI(CA, CB: TCol32): Integer;
  begin
    Result := Abs(CA.R - CB.R) + Abs(CA.G - CB.G) + Abs(CA.B - CB.B);
  end;
  function DeltaColorIM(CA, CB: TCol32): Integer;
  begin
    Result := Max(Abs(CA.R - CB.R), Max(Abs(CA.G - CB.G), Abs(CA.B - CB.B)));
  end;
var
  WA, HA, WB, HB, Wmin, Hmin : Integer;
  x0, y0, x1, y1, x, y, ResultI : Integer;
  RA, RB, RI   : TRect;
  SLA, SLB : TSL32Arr;
  AreaCtr: Integer;
  Area, AreaMin, AreaRatio : Double;
  CA, CB: TCol32;
begin
  BmpWH(BmpA, WA, HA);
  BmpWH(BmpB, WB, HB);

  RA := Rect(dFrame, dFrame, WA-1-dFrame, HA-1-dFrame);
  RB := Rect(dFrame, dFrame, WB-1-dFrame, HB-1-dFrame);
  OffsetRect(RB, -dx, -dy);
  if IntersectRect(RI, RA, RB) then
  begin
    BmpWH(BmpA, BmpB, Wmin, Hmin);
    AreaMin :=  0.25 * (WMin - 2*dFrame) * (HMin  - 2*dFrame);

    Result  := 0;
    ResultI := 0;
    SLA := BmpSL32Arr(BmpA);
    SLB := BmpSL32Arr(BmpB);

    x0 := RI.Left;
    y0 := RI.Top;
    x1 := RI.Right;
    y1 := RI.Bottom;
    Area := 0.25 * ((x1 - x0 + 1) * (y1 - y0 + 1));
    AreaCtr := 0;
    for y := y0 to y1 do
      if odd(y) then
      for x := x0 to x1 do
      if odd(x) then
      begin
        CA := SLA[y, x];
        CB := SLB[y+dy, x+dx];
        if IgnoreWhite and (ColorEqu32(CA, C32White) or ColorEqu32(CB, C32White)) then
        begin // ignore white parts

        end else
        begin
          Inc(ResultI, DeltaColorIM(CA, CB));
          Inc(AreaCtr);
        end;
      end;
//      Result := Result + DeltaColor(SLA[y, x], SLB[y+dy, x+dx]);

    if AreaCtr < 10 then
    begin
      Result := 1e10;    // better than out of range!
    end else
    begin
      Area := AreaCtr;

      Result := ResultI;
      Result := Result / Area;
      AreaRatio := Area / AreaMin;
      if AreaRatio < 0.1 then
      begin
        Result := Result * (0.1 / AreaRatio);
      end;
    end;
  end else
  begin
    Result := 1e99;
  end;
end;

function BmpCompare(BmpA, BmpB: TBitmap): TBitmap;
  function AddColors(CA, CB: TCol32): TCol32;
  var
    dR, dG, dB, dGy : Integer;
  begin
    dR  := CA.R - CB.R;
    dG  := CA.G - CB.G;
    dB  := CA.B - CB.B;
    dGy := Round(sqrt(dR * dR + dG * dG + dB * dB));
    case dGy of
       0:      Result := C32Black;
       1:      Result := C32dkGray;
       2 .. 3: Result := C32Gray;
       4 .. 6: Result := C32ltGray;
       7 ..10: Result := C32dkRed;
      11 ..15: Result := C32Red;
      else     Result := C32ltRed;
    end;
  end;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
begin
  BmpWH(BmpA, BmpB, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := AddColors(SL32ArrA[y,x], SL32ArrB[y,x]);

  Result.Modified := True;
end;


procedure BmpDrawDirect(Wnd: HWND; Bmp: TBitmap; ZR: TRect);
var
  XSrc, YSrc, SrcWidth, SrcHeight: Integer;
  W, H : Integer;
  DestDc, SrcDC : HDC;
begin
  XSrc       := ZR.Left;
  YSrc       := ZR.Top;
  SrcWidth   := ZR.Right  - ZR.Left;
  SrcHeight  := ZR.Bottom - ZR.Top;

  BmpWH(Bmp, W,H);

  SrcDc  := Bmp.Canvas.Handle;
  DestDc := GetDC(Wnd);

  SetStretchBltMode(DestDC, HALFTONE);
  StretchBlt(DestDC, 0,  0, W, H, SrcDC,  XSrc, YSrc, SrcWidth, SrcHeight, cmSrcCopy);
  
  ReleaseDC(Wnd, DestDc);
end;

procedure BmpBlendLeftRightDirect(Wnd: HWND; Result, BmpA, BmpB: TBitmap; MergeRatio: Double; P1: Integer);
type
  TTransform = (TF_Normal, TF_ReflectX, TF_ReflectY, TF_RotDeg);
  procedure SetTransform(DC: HDC; W, H: Integer; TF :TTransform; Par: Extended);
    function PntTForm(XF: TXForm; Pnt: TPoint): TPoint;
    begin
      Result.X := Round(Pnt.X * XF.eM11 + Pnt.Y * XF.eM21 + XF.eDx);
      Result.Y := Round(Pnt.X * XF.eM12 + Pnt.Y * XF.eM22 + XF.eDy);
    end;
  var
    p2: TXForm;
    CA, CT : TPoint;
    cosA, sinA : Extended;
  begin
      SetGraphicsMode(DC, GM_ADVANCED);
    // x' = x * eM11 + y * eM21 + eDx,
    // y' = x * eM12 + y * eM22 + eDy,

    case TF of
      TF_Normal:
        begin
          p2.eM11 := 1;
          p2.eM12 := 0;
          p2.eM21 := 0;
          p2.eM22 := 1;
        end;
      TF_ReflectX:
        begin
          p2.eM11 := -1.0000;
          p2.eM12 :=  0.0000;
          p2.eM21 :=  0.0000;
          p2.eM22 :=  1.0000;
        end;
      TF_ReflectY:
        begin
          p2.eM11 :=  1.0000;
          p2.eM12 :=  0.0000;
          p2.eM21 :=  0.0000;
          p2.eM22 := -1.0000;
        end;
      TF_RotDeg:
        begin
          SinCos(Par * pi / 180, sinA, cosA);
          p2.eM11 :=  cosA;
          p2.eM12 :=  sinA;
          p2.eM21 := -sinA;
          p2.eM22 :=  cosA;
        end;
      end;
      // Keep Center in Center:
      p2.eDx := 0;
      p2.eDy := 0;
      CA := Point(W div 2, H div 2);
      CT := PntTForm(p2, CA);
      p2.eDx := CA.X - CT.X;
      p2.eDy := CA.Y - CT.Y;
    SetWorldTransform(DC, p2);
  end;
  procedure EndTransform(DC: HDC);
  begin
    SetTransform(DC, 0, 0, TF_Normal, 0);
    //SetGraphicsMode(DC, GM_COMPATIBLE);
  end;
var
  ZR : TRect;
  xm,
  W, H   : Integer;
//  x, y : Integer;
//  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
  DestDc, RDC, ADC, BDC : HDC;
  BF : TBlendFunction;
  ZRflg : Boolean;
  XSrc, YSrc, SrcWidth, SrcHeight: Integer;
  RotateFlg : Boolean;
  BmpTemp : TBitmap;
begin
  BmpTemp := nil; // 08.01.09 P.W
  RotateFlg := MergeRatio > 0.0001;
  MergeRatio := Abs(MergeRatio);
  ZRflg := False;
  case P1 of
    0: ;
    1: begin
         BmpWHmax(BmpA, BmpB, W,H);
         BmpA.Width  := W;
         BmpA.Height := H;
         BmpB.Width  := W;
         BmpB.Height := H;
       end;
    else // address of TZoomRect
      begin
        ZRflg := True;
        ZR := TRect(Pointer(P1)^);
      end;
  end;

  BmpWH(BmpA, BmpB, W,H);
  Result.Width  := W;
  Result.Height := H;
//  SL32ArrA := BmpSL32Arr(BmpA);
//  SL32ArrB := BmpSL32Arr(BmpB);
//  SL32ArrR := BmpSL32Arr(Result);
  xm := Round(W * (1 - MergeRatio));

  DestDc := GetDC(Wnd);
  ADC := BmpA.Canvas.Handle;
  BDC := BmpB.Canvas.Handle;

  If RotateFlg then
  begin
    BmpTemp := BmpFreeGet(W, H);
    RDC := BmpTemp.Canvas.Handle;
  end else
  begin
    RDC := Result.Canvas.Handle;
  end;


  BF.BlendOp             := AC_SRC_OVER;     //
  BF.BlendFlags          := 0;
  BF.SourceConstantAlpha := EnsureRange(Round(255 * (MergeRatio)), 0, 255);
  BF.AlphaFormat         := 0*AC_SRC_ALPHA;     // alpha may be in Source Bitmap

{  // use Alpha Channel
  for y := 0 to H -1 do
  begin
    for x := 0 to xm-1 do
    begin
      SL32ArrB[y,x].S := 0
    end;
    for x := xm to W -1 do
    begin
      SL32ArrB[y,x].S := 255;
    end;
  end;
}

  SetStretchBltMode(RDC, COLORONCOLOR);

  BitBlt      (RDC,    0,  0, W, H, ADC,  0, 0, cmSrcCopy);
  AlphaBlend  (RDC,    0,  0, W, H, BDC,  0, 0, W, H, BF);

  If RotateFlg then
  begin
    //BmpReplace(Result,  BmpRotated(Result, MergeRatio * 2 * Pi));
    if ZRflg
    then BmpRotatedProc(BmpTemp, Result, MergeRatio * 2 * Pi, ZR)
    else BmpRotatedProc(BmpTemp, Result, MergeRatio * 2 * Pi);

    RDC := Result.Canvas.Handle;
    BmpFreeSet(BmpTemp);
  end else
  begin
    // use FrmMerge.Refresh;
    ReleaseDC(Wnd, DestDC);
    Exit;
  end;

  if ZRflg then
  begin
    XSrc       := ZR.Left;
    YSrc       := ZR.Top;
    SrcWidth   := ZR.Right  - ZR.Left;
    SrcHeight  := ZR.Bottom - ZR.Top;

//    SetTransForm     (DestDC, W, H, TF_RotDeg, MergeRatio*360);
    SetStretchBltMode(DestDC, HALFTONE);                           // ignored when Angle non zero
    StretchBlt       (DestDC, 0,  0, W, H, RDC,  XSrc, YSrc, SrcWidth, SrcHeight, cmSrcCopy);
//    EndTransForm     (DestDC);
  end else
  begin
    BitBlt    (DestDC, 0,  0, W, H, RDC,  0, 0, cmSrcCopy);
  end;
{
  // Blend Left Right:
  BitBlt    (DestDC,  0 -1680,  0,   xm,  H, ADC,  0, 0, cmSrcCopy);
  BitBlt    (DestDC, xm -1680,  0, W-xm,  H, BDC, xm, 0, cmSrcCopy);
}

  ReleaseDC(Wnd, DestDc);

end;

procedure BmpBlendLeftRightPerc(Result, BmpA, BmpB: TBitmap; MergeRatioPerc, P1: Integer);
var
  xm,
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
  MergeRatio : Double;
begin
  case P1 of
    1: begin
         BmpWHmax(BmpA, BmpB, W,H);
         BmpA.Width  := W;
         BmpA.Height := H;
         BmpB.Width  := W;
         BmpB.Height := H;
       end;
  end;

  BmpWH(BmpA, BmpB, W,H);
//  Result := BmpCreate32(W, H);
  Result.Width  := W;
  Result.Height := H;
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);
  MergeRatio := 0.01 * MergeRatioPerc;
  xm := Round(W * (1 - MergeRatio));

  for y := 0 to H -1 do
  begin
    for x := 0 to xm-1 do
    begin
      SL32ArrR[y,x] := SL32ArrA[y,x];
    end;
    for x := xm to W -1 do
    begin
      SL32ArrR[y,x] := SL32ArrB[y,x];
    end;
  end;
  Result.Modified := True;
end;

procedure BmpMergeColorsToBmpA(BmpA, BmpB: TBitmap; MergeRatio: Double; P1: Integer);
  function NewColor(ColA, ColB: TCol32): TCol32;
  const
    Lim = 230;
  begin
    if (ColA.R > Lim) and (ColA.G > Lim) and (ColA.B > Lim)
      then Result := ColB
      else Result := ColorMerged32(ColA, ColB, MergeRatio);
  end;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB : TSL32Arr;
begin
  case P1 of
    1: begin
         BmpWHmax(BmpA, BmpB, W,H);
         BmpA.Width  := W;
         BmpA.Height := H;
         BmpB.Width  := W;
         BmpB.Height := H;
       end;
  end;

  BmpWH(BmpA, BmpB, W,H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);

  for y := 0 to H -1 do
    for x := 0 to W -1 do

      SL32ArrA[y,x] := NewColor(SL32ArrA[y,x], SL32ArrB[y,x]);
       // ColorMerged32(SL32ArrA[y,x], SL32ArrB[y,x], MergeRatio);

  BmpA.Modified := True;
end;

procedure BmpMergeColorsProc(Result, BmpA, BmpB: TBitmap; MergeRatio: Double; P1: Integer; Limit: Byte = 255);
  function NewColor(ColA, ColB: TCol32): TCol32;
  begin
    if (ColA.R > Limit) and (ColA.G > Limit) and (ColA.B > Limit)
      then Result := ColB
      else Result := ColorMerged32(ColA, ColB, MergeRatio);
  end;

var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
begin
  case P1 of
    1: begin
         BmpWHmax(BmpA, BmpB, W,H);
         BmpA.Width  := W;
         BmpA.Height := H;
         BmpB.Width  := W;
         BmpB.Height := H;
       end;
  end;

  BmpWH(BmpA, BmpB, W,H);
//  Result := BmpCreate32(W, H);
  Result.Width  := W;
  Result.Height := H;
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);

  if Limit = 255 then
  begin
    for y := 0 to H -1 do
      for x := 0 to W -1 do
        SL32ArrR[y,x] := ColorMerged32(SL32ArrA[y,x], SL32ArrB[y,x], MergeRatio);
  end else
  begin
    for y := 0 to H -1 do
      for x := 0 to W -1 do
        SL32ArrR[y,x] := NewColor(SL32ArrA[y,x], SL32ArrB[y,x]);
  end;

  Result.Modified := True;
end;

procedure BmpMergeHatchedProc(Result, BmpA, BmpB: TBitmap; MergeRatio: Double; HatchMode: Integer);
// MergeRatio = 0 returns BmpA
// MergeRatio = 1 returns BmpB
var
  MergeRatioPerc : Integer;
  function UseA(x, y: Integer): Boolean;
  begin
    if (MergeRatioPerc =   0) then
      Result := True
    else
    if (MergeRatioPerc = 100) then
      Result := False
    else
      Case HatchMode of
        0:  begin    // Diagonals
              Result := ((x + y) mod (100 - MergeRatioPerc) = 0);
            end;
        1:  begin    // Lines
              Result := (     y  mod (100 - MergeRatioPerc) = 0);
            end;
        else Result := Odd(y); // Lines Horiz 0.5
      end;
  end;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
begin
  // common max size:
  begin
    BmpWHmax(BmpA, BmpB, W,H);
    BmpA.Width  := W;
    BmpA.Height := H;
    BmpB.Width  := W;
    BmpB.Height := H;
  end;

  BmpWH(BmpA, BmpB, W,H);
//  Result := BmpCreate32(W, H);
  Result.Width  := W;
  Result.Height := H;
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);

  MergeRatioPerc := EnsureRange(Round(100 * MergeRatio), 0, 100); 
  for y := 0 to H -1 do
    for x := 0 to W -1 do
      if UseA(x, y) then
        SL32ArrR[y,x] := SL32ArrA[y,x]
      else
        SL32ArrR[y,x] := SL32ArrB[y,x];

  Result.Modified := True;
end;

function BmpMergeColors(BmpA, BmpB: TBitmap; MergeRatio: Double; P1: Integer): TBitmap;
begin
  Result := BmpCreate32(0, 0);
  BmpMergeColorsProc(Result, BmpA, BmpB, MergeRatio, P1);
end;

function BmpMergeHatched(BmpA, BmpB: TBitmap; MergeRatio: Double; HatchMode: Integer): TBitmap;
begin
  Result := BmpCreate32(0, 0);
  BmpMergeHatchedProc(Result, BmpA, BmpB, MergeRatio, HatchMode);
end;

function BmpMergeColorsGrayPerc(BmpA, BmpB: TBitmap; MergeRatioPerc, P1: Integer): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
  MergeRatio : Double;
begin
  BmpWH(BmpA, BmpB, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);
  MergeRatio := 0.01 * MergeRatioPerc;

  for y := 0 to H -1 do
    for x := 0 to W -1 do
    begin
      //SL32ArrR[y,x] := ColorMergedGray32(SL32ArrA[y,x], SL32ArrB[y,x], MergeRatio);
      SL32ArrR[y,x] := ColorMergedGraySimple32(SL32ArrA[y,x], SL32ArrB[y,x], MergeRatio);
      //SL32ArrR[y,x] := ColorMergedGrayUseHsv32(SL32ArrA[y,x], SL32ArrB[y,x], MergeRatio);
    end; 
  Result.Modified := True;
end;

function BmpMergeColorsMaskedPerc(BmpA, BmpB, BmpMsk: TBitmap; MergeRatioPerc, P1: Integer): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrM, SL32ArrR : TSL32Arr;
  MergeRatio : Double;
begin
  if not Assigned(BmpMsk) then
  begin
    Result := BmpMergeColors(BmpA, BmpB, 0.01 * MergeRatioPerc, P1);
    Exit;
  end;
  BmpWH(BmpA, BmpB, BmpMsk, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrM := BmpSL32Arr(BmpMsk);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
    begin
      MergeRatio := 0.01 * MergeRatioPerc * GrayVal32(SL32ArrM[y,x]) / 255 ;
      SL32ArrR[y,x] := ColorMerged32(SL32ArrA[y,x], SL32ArrB[y,x], MergeRatio);
    end;

  Result.Modified := True;
end;

function BmpMergeColorsMaskedGrayPerc(BmpA, BmpB, BmpMsk: TBitmap; MergeRatioPerc, P1: Integer): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrM, SL32ArrR : TSL32Arr;
  MergeRatio : Double;
begin
  if not Assigned(BmpMsk) then
  begin
    Result := BmpMergeColorsGrayPerc(BmpA, BmpB, MergeRatioPerc, P1);
    Exit;
  end;
  BmpWH(BmpA, BmpB, BmpMsk, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrM := BmpSL32Arr(BmpMsk);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
    begin
      MergeRatio := 0.01 * MergeRatioPerc * GrayVal32(SL32ArrM[y,x]) / 255 ;
      //SL32ArrR[y,x] := ColorMergedGray32(SL32ArrA[y,x], SL32ArrB[y,x], MergeRatio);
      SL32ArrR[y,x] := ColorMergedGraySimple32(SL32ArrA[y,x], SL32ArrB[y,x], MergeRatio);
      //SL32ArrR[y,x] := ColorMergedGrayUseHsv32(SL32ArrA[y,x], SL32ArrB[y,x], MergeRatio);
    end;

  Result.Modified := True;
end;

function BmpMult(BmpA, BmpB: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR : TSL32Arr;
begin
  BmpWH(BmpA, BmpB, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  SL32ArrB := BmpSL32Arr(BmpB);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := MultColors32(SL32ArrA[y,x], SL32ArrB[y,x]);

  Result.Modified := True;
end;



function BmpGetGrad3x3Col32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
//FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const

    FiltArr  : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
      ((-2, -3, -2),
       (-3, 20, -3),
       (-2, -3, -2));
    FSum  = 1;
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArr[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    SumR, SumG, SumB : Integer;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);
    SumR := 0;
    SumG := 0;
    SumB := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Inc(SumR, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].R);
        Inc(SumG, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].G);
        Inc(SumB, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].B);
      end;

    Result.S :=    0;
    Result.R := EnsureRange(SumR div FSum, 0, 255);
    Result.G := EnsureRange(SumG div FSum, 0, 255);
    Result.B := EnsureRange(SumB div FSum, 0, 255);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpGetGrad5x5Col32(Bmp: TBitmap): TBitmap;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const

    FiltArr  : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
      ((-1, -1, -1, -1, -1),
       (-1,  1,  2,  1, -1),
       (-1,  2,  4,  2, -1),
       (-1,  1,  2,  1, -1),
       (-1, -1, -1, -1, -1));
    FSum  = 1;
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArr[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    SumR, SumG, SumB : Integer;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);
    SumR := 0;
    SumG := 0;
    SumB := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Inc(SumR, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].R);
        Inc(SumG, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].G);
        Inc(SumB, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].B);
      end;

    Result.S :=    0;
    Result.R := EnsureRange(SumR div FSum, 0, 255);
    Result.G := EnsureRange(SumG div FSum, 0, 255);
    Result.B := EnsureRange(SumB div FSum, 0, 255);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpGetMean3x3Col32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
//FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
    // mean - gauss
    FiltArr  : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 1  ,  2  ,  1  ),
        ( 2  ,  3  ,  2  ),
        ( 1  ,  2  ,  1  ));
    FSum  = 15;
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArr[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    SumR, SumG, SumB : Integer;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);
    SumR := 0;
    SumG := 0;
    SumB := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Inc(SumR, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].R);
        Inc(SumG, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].G);
        Inc(SumB, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].B);
      end;

    Result.S :=    0;
    Result.R := EnsureRange(SumR div FSum, 0, 255);
    Result.G := EnsureRange(SumG div FSum, 0, 255);
    Result.B := EnsureRange(SumB div FSum, 0, 255);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpGetMean5x5Col32(Bmp: TBitmap): TBitmap;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const

    // mean - gauss
    FiltArr  : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 1  ,  4  ,  7  ,  4  ,  1  ),
        ( 4  , 20  , 33  , 20  ,  4  ),
        ( 7  , 33  , 55  , 33  ,  7  ),
        ( 4  , 20  , 33  , 20  ,  4  ),
        ( 1  ,  4  ,  7  ,  4  ,  1  ));
    FSum  = 331;
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArr[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    SumR, SumG, SumB : Integer;
  begin
  // ShowMessageFmt('Filtsum is %d', [FiltSum]);
    SumR := 0;
    SumG := 0;
    SumB := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Inc(SumR, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].R);
        Inc(SumG, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].G);
        Inc(SumB, FiltArr[dy, dx] * SL32ArrA[y+dy, x+dx].B);
      end;

    Result.S :=    0;
    Result.R := EnsureRange(Round(SumR / FSum), 0, 255);
    Result.G := EnsureRange(Round(SumG / FSum), 0, 255);
    Result.B := EnsureRange(Round(SumB / FSum), 0, 255);
//  Result.R := EnsureRange(SumR div FSum, 0, 255);
//  Result.G := EnsureRange(SumG div FSum, 0, 255);
//  Result.B := EnsureRange(SumB div FSum, 0, 255);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpRotate90(Bmp: TBitmap): TBitmap;
// 90 deg clockwise
var
  W, H, x, y, xB, yB : Integer;
  SL32ArrA,
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(H, W);    // H, W exchanged!
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 to H -1 do
  begin
    xB := (H -1 - y);
    for x := 0 to W -1 do
    begin
      yB := x;
      SL32ArrB[yB,xB] := SL32ArrA[y,x];
    end;
  end;

  Result.Modified := True;
end;

function BmpRotate180(Bmp: TBitmap): TBitmap;
// 180 deg clockwise
var
  W, H, x, y, xB, yB : Integer;
  SL32ArrA,
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 to H -1 do
  begin
    yB := (H -1 - y);
    for x := 0 to W -1 do
    begin
      xB := (W -1 - x);
      SL32ArrB[yB,xB] := SL32ArrA[y,x];
    end;
  end;

  Result.Modified := True;
end;

function BmpRotate270(Bmp: TBitmap): TBitmap;
// 270 deg clockwise
var
  W, H, x, y, xB, yB : Integer;
  SL32ArrA,
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(H, W);    // H, W exchanged!
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 to H -1 do
  begin
    xB := y;
    for x := 0 to W -1 do
    begin
      yB := W -1 -x;
      SL32ArrB[yB,xB] := SL32ArrA[y,x];
    end;
  end;

  Result.Modified := True;
end;

function BmpMirrorHorizontalTD(Bmp: TBitmap): TBitmap;
// Mirror Top to Down
var
  W, H, x, y, xB, yB : Integer;
  SL32ArrA,
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 to H -1 do
  begin
    yB := (H -1 - y);
    for x := 0 to W -1 do
    begin
      xB := x;
      SL32ArrB[yB,xB] := SL32ArrA[y,x];
    end;
  end;

  Result.Modified := True;
end;

function BmpMirrorVerticalLR(Bmp: TBitmap): TBitmap;
// Mirror Left to Right
var
  W, H, x, y, xB, yB : Integer;
  SL32ArrA,
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 to H -1 do
  begin
    yB := y;
    for x := 0 to W -1 do
    begin
      xB := (W -1 - x);
      SL32ArrB[yB,xB] := SL32ArrA[y,x];
    end;
  end;

  Result.Modified := True;
end;

function BmpCloseHolesCol32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
    FiltArr  : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 0  ,  1  ,  0  ),
        ( 1  ,  0  ,  1  ),
        ( 0  ,  1  ,  0  ));
  var
    dx, dy : Integer;
    OwnGray, Gray, Sum : Integer;
  begin
    OwnGray := Grayval32(SL32ArrA[y, x]);
    if OwnGray > 128 then
    begin
      Gray := 255;
    end else
    begin
      Sum := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
        begin
          Gray := Grayval32(SL32ArrA[y+dy, x+dx]);
          if Gray > 128
            then Gray := 1
            else Gray := 0;
          Inc(Sum, FiltArr[dy, dx] * Gray);
        end;

      case Sum of
        4:   Gray := 255;  // close a hole
        else Gray :=   0;
      end;
    end;
    Result := GrayValToCol32(Gray);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  // Mark Edge
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpRemoveSinglePntsCol32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
    FiltArr  : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 1  ,  1  ,  1  ),
        ( 1  ,  0  ,  1  ),
        ( 1  ,  1  ,  1  ));
  var
    dx, dy : Integer;
    OwnGray, Gray, Sum : Integer;
  begin
    OwnGray := Grayval32(SL32ArrA[y, x]);
    if OwnGray < 128 then
    begin
      Gray := 0;
    end else
    begin
      Sum := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
        begin
          Gray := Grayval32(SL32ArrA[y+dy, x+dx]);
          if Gray > 128
            then Gray := 1
            else Gray := 0;
          Inc(Sum, FiltArr[dy, dx] * Gray);
        end;

      case Sum of
        0:   Gray :=   0;  // remove Single Point
        else Gray := 255;
      end;
    end;
    Result := GrayValToCol32(Gray);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  // Mark Edge
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpMarkEdgeCol32(Bmp: TBitmap; P0, P1: Integer): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
    FiltArr  : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 1  ,  1  ,  1  ),
        ( 1  ,  0  ,  1  ),
        ( 1  ,  1  ,  1  ));
  var
    dx, dy : Integer;
    OwnGray, Gray, Sum : Integer;
  begin
    OwnGray := Grayval32(SL32ArrA[y, x]);
    if OwnGray < 128 then
    begin
      Gray := 0;
    end else
    begin
      Sum := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
        begin
          Gray := Grayval32(SL32ArrA[y+dy, x+dx]);
          if Gray > 128
            then Gray := 1
            else Gray := 0;
          Inc(Sum, FiltArr[dy, dx] * Gray);
        end;

      if (Sum >= P0) then Gray := 255   // in object
      else
      if (Sum >   0) then Gray := 128   // in object
      else                Gray :=   0;  // ignore single points

    end;
    Result := GrayValToCol32(Gray);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  // Mark Edge
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function CountBitsSet(V: Integer): Integer;
begin
  Result := 0;
  While V <> 0 do begin Inc(Result, V and 1); V := V shr 1; end;
end;

function TstBit(V, Bit: Integer): Boolean;
begin
  Result := (V and (1 shl Bit)) <> 0;
end;

procedure SetBit(var V: Integer; Bit: Integer);
begin
  V := V or (1 shl Bit);
end;

procedure SetBits(var V: Integer; Bits: Array of Byte);
var
  I: Integer;
begin
  for I := 0 to Length(Bits) -1 do
    SetBit(V, Bits[I]);
end;

function CountBitGrps(V: Integer): Integer;
// assume circle:
// 0 1 2
// 7   3
// 6 5 4
var
  I : Integer;
  BRefSet, BTstSet : Boolean;
  // C:\Temp\T_Connector_Diff.pas
begin
  Result := 0;

  if V = 255 then
  begin
    Result := 1;
  end else
  begin // cyclic, count changes from 0 to 1 (does not work when all are 1 in case of V = 255)
    BRefSet := TstBit(V, 7);
    for I := 0 to 7 do
    begin
      BTstSet := TstBit(V, I);
      if (BRefSet <> BTstSet) then
      begin
        if BTstSet then Inc(Result);  // count switch on
        BRefSet := BTstSet;
      end;
    end;
  end;

end;

function CountBitGrpsCornersConnected(V: Integer): Integer;
// assume circle:
// 0 1 2
// 7   3
// 6 5 4
// like CountBitGrps but additionally support (1,3), (3,5) .. as connected
begin
  // force the Corner Connections to use CountBitGrps:
  if (TstBit(V, 1)) then SetBit(V, 2);
  if (TstBit(V, 3)) then SetBit(V, 4);
  if (TstBit(V, 5)) then SetBit(V, 6);
  if (TstBit(V, 7)) then SetBit(V, 0);
  Result := CountBitGrps(V);
end;

type
  TArr256Int = Array[Byte] of Integer;

function ByteNewBitOrder(Orig: Byte; From :Array of Byte): Byte;
// index of From is AimPos Value is SourcePos
// From = [3,6,2, ...] means:
//             Bit 3 of Orig is moved to Bit 0 in Result
//             Bit 6 of Orig is moved to Bit 1 in Result
//             Bit 2 of Orig is moved to Bit 2 in Result
//             ...
  function ParamsOk : Boolean;
  var
    I : Integer;
    All : Array [0..7] of Byte;
  begin
    Result := (Length(From) = 8);
    FillChar(All, SizeOf(All), #0);
    If Result then for I := 0 to 7 do Result := Result and (From[I] in [0..7]);
    If Result then for I := 0 to 7 do
    begin
      Inc(All[From[I]]);
      Result := Result and (All[From[I]] = 1);
    end;
  end;
var
  I_To : Integer;
begin
  if ParamsOk then
  begin
    Result := 0;
    for I_To := 0 to 7 do
      Result := Result or  (((Orig shr From[I_To]) and 1) shl I_To);
  end else
  begin
    Result := 0;  // 08.01.09 P.W
    ShowMessage('ByteNewBitOrder parameter error');
  end;
end;

function Mirrored(I, J: Byte): Byte;
begin
  Case J of
    0: Result := ByteNewBitOrder(I, [ 0,1,2,3,4,5,6,7 ]); // 0 1 2
                                                          // 7 + 3
                                                          // 6 5 4

    1: Result := ByteNewBitOrder(I, [ 2,1,0,7,6,5,4,3 ]); // 2 1 0
                                                          // 3 + 7
                                                          // 4 5 6

    2: Result := ByteNewBitOrder(I, [ 6,5,4,3,2,1,0,7 ]); // 6 5 4
                                                          // 7 + 3
                                                          // 0 1 2

    3: Result := ByteNewBitOrder(I, [ 4,5,6,7,0,1,2,3 ]); // 4 5 6
                                                          // 3 + 7
                                                          // 2 1 0

    4: Result := ByteNewBitOrder(I, [ 0,7,6,5,4,3,2,1 ]); // 0 7 6
                                                          // 1 + 5
                                                          // 2 3 4

    5: Result := ByteNewBitOrder(I, [ 6,7,0,1,2,3,4,5 ]); // 6 7 0
                                                          // 5 + 1
                                                          // 4 3 2

    6: Result := ByteNewBitOrder(I, [ 2,3,4,5,6,7,0,1 ]); // 2 3 4
                                                          // 1 + 5
                                                          // 0 7 6

    7: Result := ByteNewBitOrder(I, [ 4,3,2,1,0,7,6,5 ]); // 4 3 2
                                                          // 5 + 1
                                                          // 6 7 0
    else
       Result := I;
  end;
end;

{
function NBPatternConnectorConvertLineToCirc(NBPCLine: TArr256Int): TArr256Int;
var
  I, J : Integer;
begin
  for I := 0 to 255 do     // I index in NBPCLine
  begin
                           // J index in new NBPC // Line  -> Circ
    J := ByteNewBitOrder(I, [ 0,1,2,4,7,6,5,3 ]); // 0 1 2    0 1 2
                                                  // 3 + 4    7 + 3
                                                  // 5 6 7    6 5 4
    Result[J] := NBPCLine[I];
  end;
end;
{
function NBPatternConnectorIdxCircToLine(ICirc: Integer): Integer;
begin
                                                         // Circ  -> Line
  Result := ByteNewBitOrder(ICirc, [ 0,1,2,7,3,6,5,4 ]); // 0 1 2    0 1 2
                                                         // 7 + 3    3 + 4
                                                         // 6 5 4    5 6 7
end;

function NBPatternConnectorConvertCircToLine(NBPCCirc: TArr256Int): TArr256Int;
var
  ICirc, JLine : Integer;
begin
  for ICirc := 0 to 255 do     // ICirc index in NBPCCirc
  begin
    JLine := NBPatternConnectorIdxCircToLine(ICirc);
    Result[JLine] := NBPCCirc[ICirc];
  end;
end;
}

procedure WriteDiffPatterns(NBPC: TArr256Int);
  function SB(B, N: Integer): String;
  begin
    If Boolean(B and (1 shl N)) then Result := 'x' else Result := '.';
  end;
  function CommaNonZero(I: Integer): String;
  begin
    If (I = 0) then Result := '' else Result := ',';
  end;
  function CommaNonEqual(I, INon: Integer): String;
  begin
    If (I = INon) then Result := ' ' else Result := ',';
  end;
var
  SL : TStringList;
  I, IG, J, IM, V, LenGrp : Integer;
  S : String;
  Done : Array[byte] of Boolean;
  IArr, SortKeyArr : TIntArr;
  GroupArr: TIntArrArr;
  FindIgArr : Array[0..255] of Integer;
begin
  SL := TStringList.Create;
//NBPC := NBPatternConnectorConvertLineToCirc(NBPC);
  FillChar(Done, SizeOf(Done), #0);
  SetLength(GroupArr, 0);
  For I := 0 to 255  do
  begin
    If not Done[I] then
    begin
      SetLength(IArr, 0);
      Done[I] := True;

      IntArrAppend(IArr, I);
      for J := 0 to 7 do
      begin
        IM := Mirrored(I, J);
        If not Done[IM] then
        begin
          Done[IM] := True;
          IntArrAppend(IArr, IM);
        end;
      end;

      IntArrSortProc(IArr);

      IntArrArrAppend(GroupArr, IArr);
    end;
  end;

  LenGrp := Length(GroupArr);
  SetLength(SortKeyArr, LenGrp);
  for IG := 0 to LenGrp -1 do
  begin // for sort GroupArr by Number of set bits in GroupArr[I, 0]
    I := GroupArr[IG, 0];                                       // range     // sort level
    SortKeyArr[IG] := 10000 * CountBitGrpsCornersConnected(I) + // 0 ..   4  // 1st
                       1000 * CountBitGrps(I)                 + // 0 ..   4  // 2nd
                        100 * CountBitsSet(I)                 + // 0 ..   8  // 3rd
                          1 * IG;                               // 0 ..  50  // 4th
  end;
  IntArrArrSortKeyProc(GroupArr, SortKeyArr);

  for I := 0 to 255 do
    FindIgArr[I] := -1;
  for IG := 0 to LenGrp -1 do
  begin
    for J := 0 to Length(GroupArr[IG]) -1 do
    begin
      I := GroupArr[IG, J];
      if (I < 0) or (I > 255) then
      begin
        ShowMessage  ('Error in GroupArr: Content is not in Range (0..255)');
      end else
      begin
        if FindIgArr[I] <> -1 then
        begin
          ShowMessage('Error in GroupArr: Content is not in Range (0..255)');
        end else
        begin
          FindIgArr[I] := IG;
        end;
      end;
    end;
  end;


  SL.Append('  // v=== Written by procedure WriteDiffPatterns ===');
  SL.Append('');
  SL.Append('const');
  SL.Append(Format('  LenGrp = %d;', [LenGrp]) );
  SL.Append('');
  SL.Append('type');
  SL.Append('  TGrpArr = Array[0 .. LenGrp -1] of Integer;');
  SL.Append('');
  SL.Append('const');
  SL.Append('  //  0 1 2');
  SL.Append('  //  7 + 3');
  SL.Append('  //  6 5 4');
  SL.Append('  GrpArr : TGrpArr = (');
  for IG := 0 to LenGrp -1 do
  begin
    I := GroupArr[IG, 0];
    V := NBPC[I];
    SL.Append(Format('        %3d%s //    %s %s %s %s %s %s %s %',
               [V, CommaNonEqual(IG, LenGrp-1), SB(V,0), SB(V,1), SB(V,2), SB(V,3), SB(V,4), SB(V,5), SB(V,6), SB(V,7) ]));
    SL.Append(Format('  //  %s %s %s',
               [SB(I,0), SB(I,1), SB(I,2)]));
    SL.Append(Format('  //  %s + %s  (%d BitGrpsCorners) (%d BitGrps) (%d Bits)' ,
               [SB(I,7),          SB(I,3),
               CountBitGrpsCornersConnected(I)
               ,
               CountBitGrps(I)
               ,
               CountBitsSet(I)
               ]));

    S :=      Format('  //  %s %s %s    #%3d: ', [SB(I,6), SB(I,5), SB(I,4), IG]);

    for J := 0 to Length(GroupArr[IG]) -1 do
      S := S + Format(CommaNonZero(J)+' %3d', [GroupArr[IG, J]]);

    SL.Append(S);
    If (IG <> LenGrp -1) then
      SL.Append('  // -------------------------------------------------------');
  end;
  SL.Append('  ); ');
  SL.Append('');

  SL.Append('  GrpArrToConnectorArr : Array[0 .. 255] of Byte = (');
  for I := 0 to 255 do
  begin
    SL.Append(Format('  %3d%s // %3d', [FindIgArr[I], CommaNonEqual(I, 255), I]));
  end;
  SL.Append('  ); ');
  SL.Append('');
  SL.Append('  // ^=== Written by procedure WriteDiffPatterns ===');

  ForceDirectories('C:\Temp');
  SL.SaveToFile('C:\Temp\T_Connector_Diff.pas');
  SL.Free;
end;

//{$I C:\Temp\T_Connector_Diff.pas}
{$I I_Connector_Diff.pas}

function NBPCfromGrpArr(const GrpArr: TGrpArr): TArr256Int;
// "NBPCfromGrpArr" = "neighbour pattern connector from Group Array"
var
  I : Integer;
begin
  for I:= 0 to 255 do
    Result[I] := GrpArr[GrpArrToConnectorArr[I]];
end;

function SymmmetrieCheckNbPatternConnector(NBPC: TArr256Int): Integer;
// Here Result - 1 is Ok
// else Result is Index of Error + 1000 * MirrorIndex
var
  I, J, V, IM: Integer;
  IL, IML : Integer;
begin
//  NBPC := NBPatternConnectorConvertLineToCirc(NBPC);
  Result := -1;
  for I := 0 to 255 do
  begin
    V := NBPC[I];
    for J := 0 to 7 do
    begin
      IM := Mirrored(I,J);
      if V <> NBPC[IM] then
      begin
        Result := 1000*1000 * I + 1000 * IM + J;
//        IL  := NBPatternConnectorIdxCircToLine(I );
//        IML := NBPatternConnectorIdxCircToLine(IM);
        IL := I;
        IML := IM;
        ShowMessageFmt('SymmmetrieCheckNbPatternConnector failed! %d (%d %d)', [Result, IL, IML]);
        Exit;
      end;
    end;
  end;
  ShowMessageFmt('SymmmetrieCheckNbPatternConnector Ok: %d', [Result]);
end;

const
  NbCount = 8;
  // Circular:
type
  TNbDxDy    = Array[-1 .. NbCount -1] of TPoint;
const
  NbdXdY : tNbDxDy =
    ((x: 0;y: 0),                                   // -1: Center Point
     (x:-1;y:-1),(x: 0;y:-1),(x:+1;y:-1),           //   0,  1,  2,
                             (x:+1;y: 0),           //   7,      3,
                             (x:+1;y:+1),           //   6,  5,  4;
                 (x: 0;y:+1),
     (x:-1;y:+1),
     (x:-1;y: 0));

const
  // possible indices depending on NbPrevious StepDirection
  //  -1 marks invalid index
                       // [NbPreviousStep,   NbTest         ]
  NbDxDyNexIdxArr : Array [-1 .. NbCount -1, 0 .. NbCount -1] of Byte =
      //0, 1, 2, 3, 4, 5, 6, 7
      ((1, 1, 1, 1, 1, 1, 1, 1),   // NbPre = -1 (start point)  (points 0 .. 7)
       (1, 1, 1, 0, 0, 0, 1, 1),   // NbPre =  0
       (1, 1, 1, 0, 0, 0, 0, 0),   // NbPre =  1
       (1, 1, 1, 1, 1, 0, 0, 0),   // NbPre =  2
       (0, 0, 1, 1, 1, 0, 0, 0),   // NbPre =  3
       (0, 0, 1, 1, 1, 1, 1, 0),   // NbPre =  4                (points 2 .. 6)
       (0, 0, 0, 0, 1, 1, 1, 0),   // NbPre =  5
       (1, 0, 0, 0, 1, 1, 1, 1),   // NbPre =  6
       (1, 0, 0, 0, 0, 0, 1, 1));  // NbPre =  7

var
  // Bit masks for NbPatternConnector // values come from T_Connector_Dif.pas GrpArr
  //  1: center "+" connects neighbours;
  //  2: wanted to remain like 1 (but neighbours are already connected)
  //  4: center remove during final thinning
  //  8: TreeNode        mark after final Thinning
  // 16: EndPoints       mark after final Thinning

  // forbidden combinations:
  //    1 and  4          =  5
  //    1 and  8          =  9
  //    1 and 16          = 17

  // allowed  combinations:
  //    1 and  8          =  9
  //    2 and  4          =  6
  //    2 and  8          = 10
  //    2 and  4 and  8   = 14

  NbPatternConnector : TArr256Int;

function BmpMarkEdgeNoOrOneObjectNeighbour(Bmp: TBitmap): TBitmap;
// assumes : Object 255; Edge : 128; else: 0   (as output by BmpMarkEdgeCol32)

const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
    FiltArr  : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 1  ,  1  ,  1  ),
        ( 1  ,  0  ,  1  ),
        ( 1  ,  1  ,  1  ));
  var
    dx, dy : Integer;
    OwnGray, Gray, Sum : Integer;
  begin
    OwnGray := Grayval32(SL32ArrA[y, x]);
    if OwnGray < 128 then
    begin
      Gray := 0;
    end else
    if OwnGray > 128 then
    begin
      Gray := 255;
    end else
    begin
      Sum := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
        begin
          Gray := Grayval32(SL32ArrA[y+dy, x+dx]);
          if Gray > 128
            then Gray := 1
            else Gray := 0;
          Inc(Sum, FiltArr[dy, dx] * Gray);
        end;

      case Sum of
        0,1: Gray := 255;    // edge point where  no or one neighbour is Object
        else Gray := 128;    // edge point where with one or more neighbour(s) is Object
      end;
    end;
    Result := GrayValToCol32(Gray);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  // Mark Edge
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpRemoveEdgeNonConnectorCol32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  var
    OwnGray, Gray, NbPattern, Nb: Integer;
  begin
    OwnGray := Grayval32(SL32ArrA[y, x]);
    if OwnGray < 128 then
    begin
      Gray := OwnGray;
    end else
    if OwnGray > 128 then
    begin
      Gray := OwnGray;
    end else
    begin
      NbPattern := 0;
      for Nb := 0 to NbCount -1 do
      begin
        Gray := Grayval32(SL32ArrA[y+NbdXdY[Nb].Y, x+NbdXdY[Nb].X]);
          if Gray >= 128
            then Gray := 1
            else Gray := 0;
        NbPattern := NbPattern or (Gray Shl Nb);
      end;
      if  Boolean(NbPatternConnector[NbPattern] and (1 or 2))
        then Gray := 255  // needed to connect
        else Gray := 0*64;

    end;
    Result := GrayValToCol32(Gray);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
    begin
      SL32ArrB[y,x] := Filter(x,y);
      SL32ArrA[y,x] := SL32ArrB[y,x];
    end;

  Result.Modified := True;
end;

function BmpRemoveEdgeFinalCol32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  var
    OwnGray, Gray, NbPattern, Nb: Integer;
  begin
    OwnGray := Grayval32(SL32ArrA[y, x]);
    if (OwnGray < 255) and (OwnGray <> 64) then
    begin
      Gray := OwnGray;
    end else
    begin
      NbPattern := 0;
      for Nb := 0 to NbCount -1 do
      begin
        Gray := Grayval32(SL32ArrA[y+NbdXdY[Nb].Y, x+NbdXdY[Nb].X]);
          if Gray > 64
            then Gray := 1
            else Gray := 0;
        NbPattern := NbPattern or (Gray Shl Nb);
      end;

      if  Boolean(NbPatternConnector[NbPattern] and 4)  
        then Gray := 64  // removed object at edge
        else Gray := OwnGray;

    end;
    Result := GrayValToCol32(Gray);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
    begin
      SL32ArrB[y,x] := Filter(x,y);
      SL32ArrA[y,x] := SL32ArrB[y,x];
    end;

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
    begin
      if Grayval32(SL32ArrA[y, x]) = 64 then
        SL32ArrB[y,x] := GrayValToCol32(0*60);
    end;

  Result.Modified := True;
end;

function BmpMarkEndPtsTreeNodesCol32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  var
    Gray, NbPattern, Nb: Integer;
  begin
    Result := SL32ArrA[y, x];
    if (Grayval32(Result) = 255) then
    begin
      NbPattern := 0;
      for Nb := 0 to NbCount -1 do
      begin
        Gray := Grayval32(SL32ArrA[y+NbdXdY[Nb].Y, x+NbdXdY[Nb].X]);
          if Gray > 128
            then Gray := 1
            else Gray := 0;
        NbPattern := NbPattern or (Gray Shl Nb);
      end;

      if  Boolean(NbPatternConnector[NbPattern] and 8)
        then Result := C32Green
      else
      if  Boolean(NbPatternConnector[NbPattern] and 16)
        then Result := C32Red;

    end;
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;



function BmpMarkedEndPtsTreeNodesRemoveShortLinesCol32(Bmp: TBitmap; MinLength, P1:Integer): TBitmap;
// assumes colors as marked by BmpMarkEndPtsTreeNodesCol32:
//          Green : TreeNodes
//          Red   : Endpoint
//          White : Lines
//          Black : Background
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

type
  TPntType = (PntBack, PntObj, PntEnd, PntNode);
  TNodeRec  = Record
    ConLines : Array of Integer;   // index into LinesArr
    ConNodes : Array of Integer;   // index into NodesArr;
  end;

  function Col32ToPntType(Col: TCol32): TPntType;
  begin
      if (Col.C = C32Black.C) then
      begin
        Result := PntBack;
      end else
      if (Col.C = C32White.C) then
      begin
        Result := PntObj;
      end else
      if (Col.C = C32Red.C) then
      begin
        Result := PntEnd;
      end else
      if (Col.C = C32Green.C) then
      begin
        Result := PntNode;
      end else
        Result := PntBack;
  end;

  function GetNbPntType(X0, Y0, Nb: Integer): TPntType;
  begin
    Result := Col32ToPntType(SL32ArrA[Y0+NbdXdY[Nb].Y, X0+NbdXdY[Nb].X]);
  end;

  function GetNbPnt(X0, Y0, Nb: Integer): TPoint;
  begin
    Result := Point(X0+NbdXdY[Nb].X, Y0+NbdXdY[Nb].Y);
  end;

  function FindNextPnt(Pnt0: TPoint; var NbPre: Integer; var NPnt: TPoint): TPntType;
  // Travel along a line
  // Hierarchy : PntBack < PntObj < PntEnd < PntTree
  var
    Nb, NbPreOrg  : Integer;
    PntType : TPntType;
    Pnt : TPoint;
  begin
    Result   := PntBack;
    NPnt     := Pnt0;
    NbPreOrg := NbPre;    // neighbour index invert "view direction"

    for Nb := 0 to NbCount -1 do
    if NbDxDyNexIdxArr[NbPreOrg, Nb] > 0 then
    begin
      Pnt := Point(Pnt0.X+NbdXdY[Nb].X, Pnt0.Y+NbdXdY[Nb].Y);
      PntType := Col32ToPntType(SL32ArrA[Pnt.Y, Pnt.X]);
      Case PntType of
        PntNode:
          begin
            Result := PntType;
            NPnt := Pnt;
            NbPre := NB;
            Exit;   // highest in hierarchy found
          end;
        PntEnd:
          if (Result < PntEnd) then
          begin
            Result := PntType;
            NPnt := Pnt;
            NbPre := NB;
          end;
        PntObj:
          if (Result < PntObj) then
          begin
            Result := PntType;
            NPnt := Pnt;
            NbPre := NB;
          end;
      end;
    end;
  end;

  function NbInvertDir(Nb: Integer): Integer;
  begin
    if Nb < 0 then
    begin
      Result := -1;
    end else
    begin
      Result := (Nb + 4) mod 8;
    end;
  end;

  function GetLinePnts(Pnt0: TPoint; NbPre: Integer): TPntArr;
  //NbPre = -1:  we start with an EndPoint, no previous Point
    procedure AppendPnt(Pnt: TPoint);
    var
      Len : Integer;
    begin
      Len := Length(Result);
      SetLength(Result, Len +1);
      Result[Len] := Pnt;
    end;
  var
    Ready : Boolean;
    Pnt, NPnt  : TPoint;
    //NbPre  : Integer;  // 0 .. 7 neighbour point previous; -1 for none
  begin
    SetLength(Result, 0);
//    if GetNbPntType(Pnt0.X, Pnt0.Y, -1)<> PntNode then
      if NbPre>=0 then
        AppendPnt(GetNbPnt(Pnt0.X, Pnt0.Y, NbInvertDir(NbPre)));
      AppendPnt(Pnt0);
    Pnt := Pnt0;
    Ready := False;
    repeat
      Case FindNextPnt(Pnt, NbPre, NPnt) of
        PntBack:
          begin  // missing second endpoint or simply a single point
            Ready := True;
          end;
        PntObj:
          begin
            AppendPnt(NPnt);
            Ready := False;
          end;
        PntEnd:
          begin
            AppendPnt(NPnt);
            Ready := True;
          end;
        PntNode:
          begin
            AppendPnt(NPnt); // Point belongs to other Lines also!
            Ready := True;
          end;
      end;
      Pnt := NPnt;
    until Ready;

  end;

var
  LinesArr : Array of TPntArr;
  NodesArr : Array of TNodeRec;
  FoundCtr : Integer;

type
  TLinesEqual = (LinesNEq, LinesEq, LinesEqInv);
  function  LinesEqual(LA, LB: TPntArr): TLinesEqual;
  // Returns  0 if not equal
  // Returns  1 if equal
  // Returns -1 if invert order is equal;
  var
    Len, I : Integer;
  begin
    Result := LinesNEq;
    Len := Length(LA);
    if Len = Length(LB) then
    begin
      // Search same direction
      I := 0;
      While (I < Len) and PointsEqual(LA[I], LB[I]) do inc(I);
      if I = Len then
      begin
        Result := LinesEq;
      end else
      begin
        // Search inverted direction
        I := 0;
        While (I < Len) and PointsEqual(LA[I], LB[Len -1 - I]) do inc(I);
        if I = Len then
          Result := LinesEqInv;
      end;
    end

  end;

  function  LineFindIndex(Line: TPntArr): Integer;
  // Return Index of Line if found ( >= 0) else -1
  var
    LenA, I : Integer;
  begin
    Result := -1;
    LenA := Length(LinesArr);
    for I := 0 to LenA -1 do
      Case LinesEqual(Line, LinesArr[I]) of
        LinesEq, LinesEqInv:
          begin
            Result := I;
            Exit;
          end;
      end;
  end;

  procedure LinesArrAdd(Line : TPntArr);
  var
    Len : Integer;
  begin
    if LineFindIndex(Line) < 0 then
    begin
      Len := Length(LinesArr);
      SetLength(LinesArr, Len+1);
      LinesArr[Len] := Line;
    end else
    begin
      Inc(FoundCtr);
    end;
  end;

  procedure NodesArrAdd(Node : TNodeRec);
  var
    Len : Integer;
  begin
    Len := Length(NodesArr);
    SetLength(NodesArr, Len+1);
    NodesArr[Len] := Node;
  end;

var
  SL32ArrB: TSL32Arr;
  W, H, x, y, I, L, Nb : Integer;
  LineArr : TPntArr;

begin
  FoundCtr := 0;
  BmpWH(Bmp,W,H);
  //Result := BmpCreate32(W, H);
  Result := BmpCreateCopy32(Bmp);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  SetLength(LinesArr, 0);
  SetLength(NodesArr, 0);

{
if (x=152) and (y=149) then
if (x=152) and (y=149) then;
}
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
    begin
      if SL32ArrA[y,x].C = C32Red.C then  // EndPoint as start
      begin
        LinesArrAdd(GetLinePnts(Point(x, y), -1));
      end;
      if SL32ArrA[y,x].C = C32Green.C then  // NodePoint as start
      begin
        for Nb := 0 to NbCount -1 do
        begin
          if (GetNbPntType(x, y, Nb) in [PntObj, PntEnd, PntNode]) then
          begin
            LinesArrAdd(GetLinePnts(GetNbPnt(x, y, Nb), Nb));
          end;
        end;
      end;
    end;

  for L := 0 to Length(LinesArr) -1 do
  begin
    LineArr := LinesArr[L];
//  if Length(LineArr) < MinLength then     // mark short lines
    for I := 0 to Length(LineArr) -1 do
    begin    // mark the Line:
      //if (SL32ArrA[LineArr[I].Y, LineArr[I].X].C <> C32Green.C) then
      SL32ArrB[LineArr[I].Y, LineArr[I].X] := C32Yellow;
    end;
  end;

  Result.Modified := True;
  ShowMessageFmt('Duplicate Lines Found: %d; Total Lines: %d ', [FoundCtr, Length(LinesArr)]);
end;

function BmpRemoveEndPntsCol32(Bmp: TBitmap): TBitmap;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  var
    Gray, NbPattern, Nb: Integer;
  begin
    Result := SL32ArrA[y, x];
    if (Grayval32(Result) > 128) then
    begin
      NbPattern := 0;
      for Nb := 0 to NbCount -1 do
      begin
        Gray := Grayval32(SL32ArrA[y+NbdXdY[Nb].Y, x+NbdXdY[Nb].X]);
          if Gray > 128
            then Gray := 1
            else Gray := 0;
        NbPattern := NbPattern or (Gray Shl Nb);
      end;

      if  Boolean(NbPatternConnector[NbPattern] and 16)
        then Result := C32Black;   // Remove Endpoint

    end;
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpRemoveEdgeCol32(Bmp: TBitmap): TBitmap;
// assumes : Object 255; Edge : 128; else: 0   (as output by BmpMarkEdgeCol32)

const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
    FiltArr  : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 1  ,  1  ,  1  ),
        ( 1  ,  0  ,  1  ),
        ( 1  ,  1  ,  1  ));
  var
    dx, dy : Integer;
    OwnGray, Gray, Sum : Integer;
  begin
    OwnGray := Grayval32(SL32ArrA[y, x]);
    if OwnGray < 128 then
    begin
      Gray := 0;
    end else
    if OwnGray > 128 then
    begin
      Gray := 255;
    end else
    begin
      Sum := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
        begin
          Gray := Grayval32(SL32ArrA[y+dy, x+dx]);
          if Gray > 128
            then Gray := 1
            else Gray := 0;
          Inc(Sum, FiltArr[dy, dx] * Gray);
        end;

      case Sum of
        0:   Gray := 255;    // edge point where  no  neighbour is Object
        else Gray := 128;    // edge point where with one or more neighbour(s) is Object
      end;
    end;
    Result := GrayValToCol32(Gray);
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  // Mark Edge
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpGetEdge5x5Col32(Bmp: TBitmap): TBitmap;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const

    FiltArrX : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
//{
       ((-1  , -1  ,  0  ,  1  ,  1  ),
        (-1  , -1  ,  0  ,  1  ,  1  ),
        (-1  , -1  ,  0  ,  1  ,  1  ),
        (-1  , -1  ,  0  ,  1  ,  1  ),
        (-1  , -1  ,  0  ,  1  ,  1  ));
    FSumX = 1;
{}
    FiltArrY : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
//{
       ((-1  , -1  , -1  , -1  , -1  ),
        (-1  , -1  , -1  , -1  , -1  ),
        ( 0  ,  0  ,  0  ,  0  ,  0  ),
        ( 1  ,  1  ,  1  ,  1  ,  1  ),
        ( 1  ,  1  ,  1  ,  1  ,  1  ));
    FSumY = 1;
{}
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArrX[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    Gray,
    SumX, SumY : Integer;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);

    SumX := 0;
    SumY := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Gray := GrayVal32(SL32ArrA[y+dy, x+dx]);
        Inc(SumX, FiltArrX[dy, dx] * Gray);
        Inc(SumY, FiltArrY[dy, dx] * Gray);
      end;
    Gray :=  EnsureRange(Round(Sqrt((SumX*SumX) + (SumY*SumY))), 0, 255);
//    if Gray > 64 then Gray := 255 else Gray := 0;
    Result.S :=    0;
    Result.R := Gray;
    Result.G := Gray;
    Result.B := Gray;
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpGetDxDyEdge5x5Col32(Bmp: TBitmap): TBitmap;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
{$If Filtsize=1}
    FiltArrX : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       ((-1,  0,  1),
        (-2,  0,  2),
        (-1,  0,  1));
    FiltArrY : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       ((-1, -2, -1),
        ( 0,  0,  0),
        ( 1,  2,  1));
    GradScale = 1.5;
{$IfEnd}
{$If Filtsize=2}
    FiltArrX : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 0  , -1  ,  0  ,  1  ,  0  ),
        (-1  , -2  ,  0  ,  2  ,  1  ),
        (-1  , -3  ,  0  ,  3  ,  1  ),
        (-1  , -2  ,  0  ,  2  ,  1  ),
        ( 0  , -1  ,  0  ,  1  ,  0  ));
    FiltArrY : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 0  , -1  , -1  , -1  ,  0  ),
        (-1  , -2  , -3  , -2  , -1  ),
        ( 0  ,  0  ,  0  ,  0  ,  0  ),
        ( 1  ,  2  ,  3  ,  2  ,  1  ),
        ( 0  ,  1  ,  1  ,  1  ,  0  ));
    GradScale = 0.5;
{$IfEnd}
    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArrX[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    Angle, AngleDeg : Double;
    Grad,
    Gray,
    SumX, SumY : Integer;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);

    SumX := 0;
    SumY := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Gray := GrayVal32(SL32ArrA[y+dy, x+dx]);
        Inc(SumX, FiltArrX[dy, dx] * Gray);
        Inc(SumY, FiltArrY[dy, dx] * Gray);
      end;
    Grad :=  EnsureRange(Round(GradScale * Sqrt((SumX*SumX) + (SumY*SumY))), 0, 255);
    Angle := ArcTan2(SumX, SumY);
    AngleDeg := Angle * 180 / Pi;
    While AngleDeg < 0 do AngleDeg := AngleDeg + 360;
    Gray :=  Round(255 * AngleDeg/ 360);
//Gray := (x + y) mod 256;
//    if Gray > 64 then Gray := 255 else Gray := 0;
    Result.S :=    Grad;
    Result.R := EnsureRange((SumX div 4) + 128, 0, 255);
    Result.G := EnsureRange((SumY div 4) + 128, 0, 255);
    Result.B := Gray;
  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function CalcGaussFilterAsym(M, N: Integer; fm, fn, rot : Double): TIntArrArr;
// fill a mxn matrix with a special gauss distribution:
// stretch m and u using fm, fn, rotate the content use angle rot
//
//  G(u,v) :=  (1 / (2*Pi*s^2)) * exp(-(u^2 + v^2)/2*s^2);
//  Matrix: (6s +1) x (6s +1)
//
  function GaussNorm(u, v: Double): Double;
  begin
    Result := exp(-(u*u + v*v));
  end;
var
  i, j : Integer;
  CosR, SinR, s,
  x, y, XD, YD, dCX, dCY : Double;
begin
  SetLength(Result, m, n);
//  s := Min(M, N) / 6;   // 3 sigma
//  s := Min(M, N) / 3.6;   // for 5x5 gauss
  s := Min(M, N) / 6  ;
  CosR := Cos(Rot);
  SinR := Sin(Rot);
  dCX := 0.5 * (M -1);
  dCY := 0.5 * (N -1);

  for i := 0 to m -1 do
  begin
    for j := 0 to n -1 do
    begin
      x := (i - dCX);
      y := (j - dCY);
      XD := fm * (x * CosR - y * SinR) / s;
      YD := fn * (x * SinR + y * CosR) / s;
      Result[i, j] := Round(255 * GaussNorm(XD, YD));
    end;
  end;
end;

function CalcGaussFilterASymDoub(M, N: Integer; fm, fn, rot, fact : Double): TDoubArrArr;
// fill a mxn matrix with a special gauss distribution:
// stretch m and u using fm, fn, rotate the content use angle rot
//
//  G(u,v) :=  (1 / (2*Pi*s^2)) * exp(-(u^2 + v^2)/2*s^2);
//  Matrix: (6s +1) x (6s +1)
//
  function GaussNorm(u, v: Double): Double;
  begin
    Result := exp(-(u*u + v*v));
  end;
var
  i, j : Integer;
  CosR, SinR, s,
  x, y, XD, YD, dCX, dCY : Double;
begin
  SetLength(Result, m, n);
//  s := Min(M, N) / 6;   // 3 sigma
//  s := Min(M, N) / 3.6;   // for 5x5 gauss
  s := Min(M, N) / 6  ;
  CosR := Cos(Rot);
  SinR := Sin(Rot);
  dCX := 0.5 * (M -1);
  dCY := 0.5 * (N -1);

  for i := 0 to m -1 do
  begin
    for j := 0 to n -1 do
    begin
      x := (i - dCX);
      y := (j - dCY);
      XD := fm * (x * CosR - y * SinR) / s;
      YD := fn * (x * SinR + y * CosR) / s;
      Result[i, j] := fact * GaussNorm(XD, YD);
    end;
  end;
end;

function ChkPoint(x, y: Integer): Integer;
const
  X0=255.5;
  Y0=184.5;
  X1=318.5;
  Y1=192.5;
  X2=345.5;
  Y2=255.5;
  X3=307.5;
  Y3=307.5;
begin
  if (x=Trunc(X0)) and (y = Trunc(Y0)) then Result := 0 else
  if (x=Trunc(X1)) and (y = Trunc(Y1)) then Result := 1 else
  if (x=Trunc(X2)) and (y = Trunc(Y2)) then Result := 2 else
  if (x=Trunc(X3)) and (y = Trunc(Y3)) then Result := 3 else
  Result := -1;
end;

function BmpGetMeanUseEdge5x5Col32(Bmp: TBitmap): TBitmap;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
//FiltSize = 3; // 3 -> 7x7:  (-3 .. 3) * (-3 .. 3)
//FiltSize = 4; // 4 -> 9x9:  (-4 .. 4) * (-4 .. 4)
  FiltLen = (FiltSize * 2) + 1;
var
  SL32ArrA: TSL32Arr;

  function Filter(x, y: Integer) : TCol32;
  const
{  from Edge:
    FiltArrX : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       ((-1, -1,  0,  1,  1),
        (-1, -1,  0,  1,  1),
        (-1, -1,  0,  1,  1),
        (-1, -1,  0,  1,  1),
        (-1, -1,  0,  1,  1));

    FiltArrY : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       ((-1, -1, -1, -1, -1),
        (-1, -1, -1, -1, -1),
        ( 0,  0,  0,  0,  0),
        ( 1,  1,  1,  1,  1),
        ( 1,  1,  1,  1,  1));
}
    FiltArrX : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       ((-2,  1,  2,  1, -2),
        (-2,  1,  2,  1, -2),
        (-2,  1,  2,  1, -2),
        (-2,  1,  2,  1, -2),
        (-2,  1,  2,  1, -2));

    FiltArrY : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       ((-2, -2, -2, -2, -2),
        ( 1,  1,  1,  1,  1),
        ( 2,  2,  2,  2,  2),
        ( 1,  1,  1,  1,  1),
        (-2, -2, -2, -2, -2));

    FiltArrU : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 0, -2, -2,  1,  2),
        (-2, -1,  1,  2,  1),
        (-2,  1,  2,  1, -2),
        ( 1,  2,  1, -1, -2),
        ( 2,  1, -2, -2,  0));

    FiltArrV : Array [-FiltSize .. FiltSize, -FiltSize .. FiltSize] of Integer =
       (( 2,  1, -2, -2,  0),
        ( 1,  2,  1, -1, -2),
        (-2,  1,  2,  1, -2),
        (-2, -1,  1,  2,  1),
        ( 0, -2, -2,  1,  2));

    function FiltSum: Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := -FiltSize to FiltSize do
        for dx := -FiltSize to FiltSize do
          Inc(Result, FiltArrX[dx, dy]);
    end;

    function FiltSum2(const Filter: TIntArrArr): Integer;
    var
      dx, dy : Integer;
    begin
      Result := 0;
      for dy := 0 to FiltLen -1 do
        for dx := 0 to FiltLen -1 do
          Inc(Result, Filter[dx, dy]);
    end;
  // Range: 0 .. 255;
  var
    dx, dy : Integer;
    Gray,
    SumX, SumY, SumU, SumV, SumG, dXY, dUV : Integer;
    Rot : Double;
//    RotDeg : Double;
    Filter : TIntArrArr;
  begin
//  ShowMessageFmt('Filtsum is %d', [FiltSum]);
    {
    case ChkPoint(x, y) of
      0 : if SumX = 0 then;
      1 : if SumX = 1 then;
      2 : if SumX = 2 then;
      3 : if SumX = 3 then;
    end;
    }
    SumX := 0;
    SumY := 0;
    SumU := 0;
    SumV := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Gray := GrayVal32(SL32ArrA[y+dy, x+dx]);
        Inc(SumX, FiltArrX[dy, dx] * Gray);
        Inc(SumY, FiltArrY[dy, dx] * Gray);
        Inc(SumU, FiltArrU[dy, dx] * Gray);
        Inc(SumV, FiltArrV[dy, dx] * Gray);
      end;
//  Gray :=  EnsureRange(Round(Sqrt((SumX*SumX) + (SumY*SumY))), 0, 255);

    dXY := abs(SumY - SumX);
    dUV := abs(SumV - SumU);

    if (dXY > dUV) then
      Rot := ArcTan2(SumX, SumY)                 // does not differ between +45 and - 45
    else
      Rot := ArcTan2(SumU, SumV) - 45 * Pi/180;   // does not differ between   0 and   90

   Rot := DebugRot * Pi / 180;

//{
// rot := 45 * Pi / 180;
    Filter := CalcGaussFilterAsym(FiltLen, FiltLen, 0.25, 1, Rot);
    SumG := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        Gray := GrayVal32(SL32ArrA[y+dy, x+dx]);
        Inc(SumG, Filter[dx+FiltSize, dy+FiltSize] * Gray);
      end;
    Gray := SumG div FiltSum2(Filter);
    Result.S :=    0;
    Result.R := Gray;
    Result.G := Gray;
    Result.B := Gray;
{}
{ // Debugging:
    RotDeg := Rot * 180 / Pi;
    While RotDeg < 0 do RotDeg := RotDeg + 180;
    case ChkPoint(x, y) of
      0 : if SumX = 0 then;
      1 : if SumX = 1 then;
      2 : if SumX = 2 then;
      3 : if SumX = 3 then;
    end;
    Gray := Round(255 * RotDeg / 360);
    Result.S :=    0;
    Result.R := EnsureRange( (SumX div 32) + 128, 0, 255);
    Result.G := EnsureRange( (SumY div 32) + 128, 0, 255);
    Result.B := Gray;
    if (dXY > dUV) then;
    dXY := abs(SumY - SumX);
    dUV := abs(SumV - SumU);
    if (dXY > dUV) then;
{}

  end;

var
  W, H, x, y : Integer;
  SL32ArrB: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrB := BmpSL32Arr(Result);

  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrB[y,x] := Filter(x,y);

  Result.Modified := True;
end;

function BmpGauss(fm, fn, rot: Double): TBitmap;
var
  W, H: Integer;
  x, y : Integer;
  SLarrR : TSL32Arr;
  Filter : TIntArrArr;
begin
  W := 5;
  H := 5;
  Result := BmpCreate32(W, H);
  SLarrR := BmpSL32Arr(Result);

  Filter := CalcGaussFilterAsym(W, H, 0.25*fm, fn, 45 * Pi/180);
  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SLarrR[y, x] := GrayValToCol32(Filter[x, y]);  // Look out crossed x, y!

  Result.Modified := True;
end;

type
  TListGrayRec = Record
    aCol : TCol32;
    aGry : Byte;
  end;
function CompareGry(Item1, Item2: Pointer): Integer;
// must be global!
// comparison function that returns
//   a positive value if Item1 is less than Item2,          //????  // Sorts descending!
//   0                if they are equal, and
//   a negative value if Item1 is greater than Item2
begin
  if TListGrayRec(Item1^).aGry < TListGrayRec(Item2^).aGry then Result := -1
  else
  if TListGrayRec(Item1^).aGry > TListGrayRec(Item2^).aGry then Result := 1
  else
  Result := 0;
end;

function CompareRed(Item1, Item2: Pointer): Integer;
// must be global!
// comparison function that returns
//   a positive value if Item1 is less than Item2,          //????  // Sorts descending!
//   0                if they are equal, and
//   a negative value if Item1 is greater than Item2
begin
  if TListGrayRec(Item1^).aCol.R < TListGrayRec(Item2^).aCol.R then Result := -1
  else
  if TListGrayRec(Item1^).aCol.R > TListGrayRec(Item2^).aCol.R then Result := 1
  else
  Result := 0;
end;

function CompareGreen(Item1, Item2: Pointer): Integer;
// must be global!
// comparison function that returns
//   a positive value if Item1 is less than Item2,          //????  // Sorts descending!
//   0                if they are equal, and
//   a negative value if Item1 is greater than Item2
begin
  if TListGrayRec(Item1^).aCol.G < TListGrayRec(Item2^).aCol.G then Result := -1
  else
  if TListGrayRec(Item1^).aCol.G > TListGrayRec(Item2^).aCol.G then Result := 1
  else
  Result := 0;
end;

function CompareBlue(Item1, Item2: Pointer): Integer;
// must be global!
// comparison function that returns
//   a positive value if Item1 is less than Item2,          //????  // Sorts descending!
//   0                if they are equal, and
//   a negative value if Item1 is greater than Item2
begin
  if TListGrayRec(Item1^).aCol.B < TListGrayRec(Item2^).aCol.B then Result := -1
  else
  if TListGrayRec(Item1^).aCol.B > TListGrayRec(Item2^).aCol.B then Result := 1
  else
  Result := 0;
end;

procedure TestMaskedSmooth(Bmp: TBitmap);
var
  BmpMsk : TBitmap;
  I : Integer;
begin
//BmpSharpCol32(bmp);
  BmpMsk := TBitmap.Create;
  BmpMsk.Assign(Bmp);   // create a copy

//  BmpMsk :=          BmpGetMean3x3Col32   (     BmpMsk) ;   // smooth
  BmpReplace(BmpMsk, BmpGetEdgeRgb3x3Col32(     BmpMsk));   // edges
//  BmpReplace(BmpMsk, BmpGetMean3x3Col32   (     BmpMsk));   // smooth

//BmpReplace(Bmp, BmpMsk); exit;

//  BmpReplace(Bmp   , BmpGetMean3x3Col32   (Bmp,       ));   // smooth
for I := 0 to 2 do
  BmpReplace(Bmp   , BmpGetMean5x5Masked  (Bmp, BmpMsk));   // smooth use mask

end;

procedure DrawAngle(Bmp: TBitmap; xs, ys: Integer; Angle, Len, LenNorm: Double; ClipLo, ClipHi: Integer; ColLo, ColHi: TColor);
var
  dx, dy : Integer;
  Col: TColor;
begin

  if Len < ClipLo then Col := ColLo else
  if Len > ClipHi then Col := ColHi else
                       Col := clYellow;
  Bmp.Canvas.Pen.Color := Col;

  Len := LenNorm*Len/255;
  dx := Round(Len * Cos(Angle));
  dy := Round(Len * Sin(Angle));

  Bmp.Canvas.MoveTo(xs,    ys);
  Bmp.Canvas.LineTo(xs+dx, ys-dy);
end;


function BmpDrawAngle(Bmp: TBitmap; ClipLo, ClipHi: Integer; ColLo, ColHi: TColor; AngleDelta: Integer): TBitmap;
// assume Blue Part 0..255 represents angle 0..360 degree
//        S Part contains Length (0..255)
var
  W, H, xs, ys, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
  Angle : Double;
begin
  BmpWH(Bmp,W,H);

//  Result := TBitmap.Create;
//  Result.Assign(Bmp);
  Result := BmpCreate32(W, H);

  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for ys := 0 to (H div AngleDelta) -1 do
  begin
    y := ys * AngleDelta;
    for xs := 0 to (W div AngleDelta) -1 do
    begin
      x := xs * AngleDelta;
      Angle := (360 * SL32ArrA[y, x].B / 255) * Pi / 180;
      DrawAngle(Result, x, y, Angle, SL32ArrA[y, x].S, AngleDelta, ClipLo, ClipHi, ColLo, ColHi);
    end;
  end;
  Result.Modified := True;
end;


function BmpGetRedCol32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := RedCol32(SL32ArrA[y,x]);
  Result.Modified := True;
end;

function BmpGetGreenCol32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := GreenCol32(SL32ArrA[y,x]);
  Result.Modified := True;
end;

function BmpGetBlueCol32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := BlueCol32(SL32ArrA[y,x]);
  Result.Modified := True;
end;

function BmpBlueToBlack(Bmp: TBitmap; ParamPtr: Pointer): TBitmap;

  function Par: TBlueToBlackParams;
  begin
    Result := TBlueToBlackParams(ParamPtr^);
  end;
  
  function BlueToBlack(C: TCol32): TCol32;
  var
    H, S, V, GV : Byte;
  begin
    GV := GrayVal32(C);
    RgbToHSV(C, H, S, V);
    if (Gv >= Par.GrayMin) and (GV < Par.GrayMax) and
       (H >= Par.HueMin) and (H <= Par.HueMax) and
       (S >= Par.SatMin) and (S <= Par.SatMax) then
    begin
      Case Par.Mode of
        0: Result := Par.NewColor;
        1: Result := ColorDown(C);
        2: Result := ColorBrighter(C);
        3: Result := ContrastLow(C);
        4: Result := ContrastHigh(C);
      end;
    end else
    begin
      Result := C;
    end;
  end;

var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := BlueToBlack(SL32ArrA[y,x]);
  Result.Modified := True;
end;

function BmpBlueToBlack2(BmpA, BmpB: TBitmap; ParamArrPtr: Pointer): TBitmap;

  function IncreaseHue(C: TCol32; dHue: Byte): TCol32;
  var
    Hsv : TColHsv;
  begin
    Hsv := RgbToHsvCol32(C);
    Hsv.H := Hsv.H + dHue;
    Result := HsvToRgbCol32(Hsv);
  end;

  function NewHue(C: TCol32; nH, nS, dV: Integer): TCol32;
  var
    Hsv : TColHsv;
  begin
    Hsv := RgbToHsvCol32(C);
    Hsv.H := EnsureRange(nH, 0, 255);
    Hsv.S := EnsureRange(nS, 0, 255);
    Hsv.V := EnsureRange(Hsv.V + dV, 0, 255);
    Result := HsvToRgbCol32(Hsv);
  end;

  function ParArr: TBlueToBlackParamsArr;
  begin
    Result := TBlueToBlackParamsArr(ParamArrPtr^);
  end;

  function FactorMultDivi(Mult, Divi : Integer): Double;
  begin
    if Divi > 1 then
      Result := Mult / Divi
    else
      Result := Mult;
  end;

  function BlueToBlack(CA, CB: TCol32): TCol32;
  var
    H, S, V, GV : Byte;
    Len, I : Integer;
    Par: TBlueToBlackParams;
    Factor : Double;
  begin
    GV := GrayVal32(CA);
    RgbToHSV(CA, H, S, V);

    Len := Length(ParArr);
    Result := CA;
    for I := 0 to Len -1 do
    begin
      Par    := ParArr[I];
      Factor := FactorMultDivi(Par.RInt, Par.GInt);
      if (Gv >= Par.GrayMin) and (GV <= Par.GrayMax) and
         (H  >= Par.HueMin ) and (H  <= Par.HueMax ) and
         (S  >= Par.SatMin ) and (S  <= Par.SatMax ) then
      begin
        Case Par.Mode of
          00: Result := Par.NewColor;
          01: Result := ColorDown    (CA, Factor);
          02: Result := ColorBrighter(CA, Factor);
          03: Result := ContrastLow  (CA);
          04: Result := ContrastHigh (CA);
          05: Result := IncreaseHue  (CA, Par.RInt);
          06: Result := NewHue       (CA, Par.RInt, Par.GInt, Par.BInt);

          20: Result :=               CB;
          21: Result := ColorDown    (CB, Factor);
          22: Result := ColorBrighter(CB, Factor);
          23: Result := ContrastLow  (CB);
          24: Result := ContrastHigh (CB);
          25: Result := IncreaseHue  (CB, Par.RInt);
          26: Result := NewHue       (CB, Par.RInt, Par.GInt, Par.BInt);
        end;
        EXIT;  // no further tries; support only first match
      end;
    end;
  end;

var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrB, SL32ArrR: TSL32Arr;
begin
  BmpWH(BmpA, BmpB, W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(BmpA);
  if Assigned(BmpB) then
    SL32ArrB := BmpSL32Arr(BmpB)
  else
    SL32ArrB := BmpSL32Arr(BmpA);

  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := BlueToBlack(SL32ArrA[y,x], SL32ArrB[y,x]);
  Result.Modified := True;
end;

function BmpRedToGrayCol32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := RedToGrayCol32(SL32ArrA[y,x]);
  Result.Modified := True;
end;

function BmpGreenToGrayCol32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := GreenToGrayCol32(SL32ArrA[y,x]);
  Result.Modified := True;
end;

function BmpBlueToGrayCol32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := BlueToGrayCol32(SL32ArrA[y,x]);
  Result.Modified := True;
end;

function BmpSToGrayCol32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := SToGrayCol32(SL32ArrA[y,x]);
  Result.Modified := True;
end;

function BmpRgbToHsvAndBackCol32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := RgbToHsvToRgbCol32(SL32ArrA[y,x]);
  Result.Modified := True;
end;

function BmpToGrayHsvH32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := GrayValToCol32(RgbToHsvCol32(SL32ArrA[y,x]).H);
  Result.Modified := True;
end;

function BmpToGrayHsvS32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := GrayValToCol32(RgbToHsvCol32(SL32ArrA[y,x]).S);
  Result.Modified := True;
end;

function BmpToGrayHsvV32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := GrayValToCol32(RgbToHsvCol32(SL32ArrA[y,x]).V);
  Result.Modified := True;
end;

function BmpToGraySimple32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SL32ArrR[y,x] := GrayValToCol32(GraySimple32(SL32ArrA[y,x]));
  Result.Modified := True;
end;

function BmpToGrayUseHsv32(Bmp: TBitmap): TBitmap;
var
  W, H, x, y, Gray : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W, H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
    begin
      Gray := RgbToHsvCol32(SL32ArrA[y,x]).V;
      SL32ArrR[y,x] := GrayValToCol32(Gray);
    end;
  Result.Modified := True;
end;

function BmpAddFilterFrame(Bmp: TBitmap; FrameWidth, P1 : Integer): TBitmap;
  function CyclicMirrored(x, W: Integer): Integer;
  begin
    if x <  0 then Result := -x
    else
    if x >= W then Result := 2*W - x -1
    else           Result := x;
  end;
var
  W, H, Wf, Hf ,x, y, xA, yA : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  WF := W + 2 * FrameWidth;
  HF := H + 2 * FrameWidth;
  Result := BmpCreate32(WF, HF);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  for y := 0 to HF -1 do
  begin
    yA := CyclicMirrored(y -FrameWidth, H);
    for x := 0 to WF -1 do
    begin
      xA := CyclicMirrored(x -FrameWidth, W);
      SL32ArrR[y,x] := SL32ArrA[yA,xA];
    end;
  end;
  Result.Modified := True;
end;

function BmpCutFrame(Bmp: TBitmap; FrameWidth, P1 : Integer): TBitmap;
var
  W, H, cW, cH, x, y : Integer;
  SL32ArrA, SL32ArrR: TSL32Arr;
begin
  BmpWH(Bmp,W,H);
  if (Min(W, H) > 2 * FrameWidth) then
  begin
    cW := W - 2 * FrameWidth;
    cH := H - 2 * FrameWidth;

    Result := BmpCreate32(cW, cH);
    SL32ArrA := BmpSL32Arr(Bmp);
    SL32ArrR := BmpSL32Arr(Result);

    for y := 0 to cH -1 do
      for x := 0 to cW -1 do
        SL32ArrR[y,x] := SL32ArrA[y+FrameWidth,x+FrameWidth];
    Result.Modified := True;
  end else
    Result := BmpCreate32(1,1);
end;

function BmpMedian3x3Col32(Bmp: TBitmap): TBitmap;
// replace points by their median;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  NumElems = sqr((FiltSize * 2) +1);
var
  SL32ArrA: TSL32Arr;
  SL32ArrR: TSL32Arr;
  List : TList;
var
  ListRecs : Array[0..NumElems-1] of TListGrayRec;

  function Median(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    N : Integer;
  begin
    N := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        ListRecs[N].aCol := SL32ArrA[y+dy, x+dx];
        ListRecs[N].aGry := GrayVal32(ListRecs[N].aCol);
        Inc(N);
      end;
    List.Sort(CompareGry);
    Result := TListGrayRec(List[NumElems div 2]^).aCol;
  end;

var
  N, W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W,H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  List := TList.Create;
  for N := 0 to NumElems -1 do
    List.Add(@ListRecs[N]);

  // Grad into *.S part:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrR[y,x] := Median(x,y);
  Bmp.Modified := True;
  FreeAndNil(List);
end;

function BmpMedian5x5Col32(Bmp: TBitmap): TBitmap;
// replace points by their median;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
  NumElems = sqr((FiltSize * 2) +1);
var
  SL32ArrA: TSL32Arr;
  SL32ArrR: TSL32Arr;
  List : TList;
var
  ListRecs : Array[0..NumElems-1] of TListGrayRec;

  function Median(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    N : Integer;
  begin
    N := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        ListRecs[N].aCol := SL32ArrA[y+dy, x+dx];
        ListRecs[N].aGry := GrayVal32(ListRecs[N].aCol);
        Inc(N);
      end;
    List.Sort(CompareGry);
    Result := TListGrayRec(List[NumElems div 2]^).aCol;
  end;

var
  N, W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W,H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  List := TList.Create;
  for N := 0 to NumElems -1 do
    List.Add(@ListRecs[N]);

  // Grad into *.S part:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrR[y,x] := Median(x,y);
  Bmp.Modified := True;
  FreeAndNil(List);
end;

function BmpMedian3x3Col32_Thr(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;
// replace points by their median;
// Thresholded
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  NumElems = sqr((FiltSize * 2) +1);
var
  SL32ArrA: TSL32Arr;
  SL32ArrR: TSL32Arr;
  List : TList;
var
  ListRecs : Array[0..NumElems-1] of TListGrayRec;

  function Median(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    N : Integer;
  begin
    N := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        ListRecs[N].aCol := SL32ArrA[y+dy, x+dx];
        ListRecs[N].aGry := GrayVal32(ListRecs[N].aCol);
        Inc(N);
      end;
    List.Sort(CompareGry);
    if TListGrayRec(List[NumElems -1]^).aGry - TListGrayRec(List[0]^).aGry <= Thr0
      then Result := TListGrayRec(List[NumElems div 2]^).aCol
      else Result := SL32ArrA[y, x];
  end;

var
  N, W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W,H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  List := TList.Create;
  for N := 0 to NumElems -1 do
    List.Add(@ListRecs[N]);

  // Grad into *.S part:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrR[y,x] := Median(x,y);
  Bmp.Modified := True;
  FreeAndNil(List);
end;

function BmpMedian5x5Col32_Thr(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;
// replace points by their median;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
  NumElems = sqr((FiltSize * 2) +1);
var
  SL32ArrA: TSL32Arr;
  SL32ArrR: TSL32Arr;
  List : TList;
var
  ListRecs : Array[0..NumElems-1] of TListGrayRec;

  function Median(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    N : Integer;
  begin
    N := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        ListRecs[N].aCol := SL32ArrA[y+dy, x+dx];
        ListRecs[N].aGry := GrayVal32(ListRecs[N].aCol);
        Inc(N);
      end;
    List.Sort(CompareGry);
    if TListGrayRec(List[NumElems -1]^).aGry - TListGrayRec(List[0]^).aGry <= Thr0
      then Result := TListGrayRec(List[NumElems div 2]^).aCol
      else Result := SL32ArrA[y, x];
  end;

var
  N, W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W,H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  List := TList.Create;
  for N := 0 to NumElems -1 do
    List.Add(@ListRecs[N]);

  // Grad into *.S part:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrR[y,x] := Median(x,y);
  Bmp.Modified := True;
  FreeAndNil(List);
end;

function BmpMedian5x5Col32_ThrHSV(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;
// replace points by their median;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
  NumElems = sqr((FiltSize * 2) +1);
var
  SL32ArrA: TSL32Arr;
  SL32ArrR: TSL32Arr;
  List : TList;
//  OrgCol : TCol32;
//  OrgHsv : TColHsv;
//  NewCol : TCol32;
//  NewHsv : TColHsv;

  function Weight_Hsv(C: TCol32): Byte;
//  var
//    Hsv : TColHsv;
//    R : Double;
  begin
  //  Hsv := RgbToHsvCol32(C);
//    R := sqrt(0.0 * sqr(1.0*Hsv.H) + 0.1 * sqr(1.0*Hsv.S) + 0.5 * sqr(1.0*Hsv.V));
  //  Result := Round(EnsureRange(R, 0, 255));

    Result := C.G;
  end;
var
  ListRecs : Array[0..NumElems-1] of TListGrayRec;

  function Median(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    N : Integer;
  begin
    N := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        ListRecs[N].aCol := SL32ArrA[y+dy, x+dx];
        ListRecs[N].aGry := Weight_Hsv(ListRecs[N].aCol);
        Inc(N);
      end;
    List.Sort(CompareGry);
    if Abs(TListGrayRec(List[NumElems -1]^).aGry - TListGrayRec(List[0]^).aGry) <= Thr0 then
    begin
      {
      OrgCol := SL32ArrA[y, x];
      OrgHsv := RgbToHsvCol32(OrgCol);
      NewCol := TListGrayRec(List[NumElems div 2]^).aCol;
      NewHsv := RgbToHsvCol32(NewCol);
      NewHsv.H := OrgHsv.H;
//    NewHsv.S := OrgHsv.S;
//    NewHsv.V := OrgHsv.V;
      Result := HsvToRgbCol32(NewHsv);
      }
      Result := TListGrayRec(List[NumElems div 2]^).aCol;
    end else
    begin
      Result := SL32ArrA[y, x];
    end;
  end;

var
  N, W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W,H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  List := TList.Create;
  for N := 0 to NumElems -1 do
    List.Add(@ListRecs[N]);

  // Grad into *.S part:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrR[y,x] := Median(x,y);
  Bmp.Modified := True;
  FreeAndNil(List);
end;

function BmpMedian3x3Col32_ThrRGB(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;
// replace points by their median;
const
  FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
//FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
  NumElems = sqr((FiltSize * 2) +1);
var
  SL32ArrA: TSL32Arr;
  SL32ArrR: TSL32Arr;
  List : TList;

  function Weight_Hsv(C: TCol32): Byte;
  begin
    Result := C.G;
  end;
var
  ListRecs : Array[0..NumElems-1] of TListGrayRec;

  function Median(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    N : Integer;
  begin
    N := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        ListRecs[N].aCol := SL32ArrA[y+dy, x+dx];
        ListRecs[N].aGry := Weight_Hsv(ListRecs[N].aCol);
        Inc(N);
      end;
    // --- Red ---
    List.Sort(CompareRed);
    if Abs(TListGrayRec(List[NumElems -1]^).aCol.R - TListGrayRec(List[0]^).aCol.R) <= Thr0 then
    begin
      Result.R := TListGrayRec(List[NumElems div 2]^).aCol.R;
    end else
    begin
      Result.R := SL32ArrA[y, x].R;
    end;
    // --- Green ---
    List.Sort(CompareGreen);
    if Abs(TListGrayRec(List[NumElems -1]^).aCol.G - TListGrayRec(List[0]^).aCol.G) <= Thr0 then
    begin
      Result.G := TListGrayRec(List[NumElems div 2]^).aCol.G;
    end else
    begin
      Result.G := SL32ArrA[y, x].G;
    end;
    // --- Blue ---
    List.Sort(CompareBlue);
    if Abs(TListGrayRec(List[NumElems -1]^).aCol.B - TListGrayRec(List[0]^).aCol.B) <= Thr0 then
    begin
      Result.B := TListGrayRec(List[NumElems div 2]^).aCol.B;
    end else
    begin
      Result.B := SL32ArrA[y, x].B;
    end;
  end;

var
  N, W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W,H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  List := TList.Create;
  for N := 0 to NumElems -1 do
    List.Add(@ListRecs[N]);

  // Grad into *.S part:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrR[y,x] := Median(x,y);
  Bmp.Modified := True;
  FreeAndNil(List);
end;

function BmpMedian5x5Col32_ThrRGB(Bmp: TBitmap; Thr0, Thr1:Integer): TBitmap;
// replace points by their median;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
  NumElems = sqr((FiltSize * 2) +1);
var
  SL32ArrA: TSL32Arr;
  SL32ArrR: TSL32Arr;
  List : TList;

  function Weight_Hsv(C: TCol32): Byte;
  begin
    Result := C.G;
  end;
var
  ListRecs : Array[0..NumElems-1] of TListGrayRec;

  function Median(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    N : Integer;
  begin
    N := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        ListRecs[N].aCol := SL32ArrA[y+dy, x+dx];
        ListRecs[N].aGry := Weight_Hsv(ListRecs[N].aCol);
        Inc(N);
      end;
    // --- Red ---
    List.Sort(CompareRed);
    if Abs(TListGrayRec(List[NumElems -1]^).aCol.R - TListGrayRec(List[0]^).aCol.R) <= Thr0 then
    begin
      Result.R := TListGrayRec(List[NumElems div 2]^).aCol.R;
    end else
    begin
      Result.R := SL32ArrA[y, x].R;
    end;
    // --- Green ---
    List.Sort(CompareGreen);
    if Abs(TListGrayRec(List[NumElems -1]^).aCol.G - TListGrayRec(List[0]^).aCol.G) <= Thr0 then
    begin
      Result.G := TListGrayRec(List[NumElems div 2]^).aCol.G;
    end else
    begin
      Result.G := SL32ArrA[y, x].G;
    end;
    // --- Blue ---
    List.Sort(CompareBlue);
    if Abs(TListGrayRec(List[NumElems -1]^).aCol.B - TListGrayRec(List[0]^).aCol.B) <= Thr0 then
    begin
      Result.B := TListGrayRec(List[NumElems div 2]^).aCol.B;
    end else
    begin
      Result.B := SL32ArrA[y, x].B;
    end;
  end;

var
  N, W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W,H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  List := TList.Create;
  for N := 0 to NumElems -1 do
    List.Add(@ListRecs[N]);

  // Grad into *.S part:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrR[y,x] := Median(x,y);
  Bmp.Modified := True;
  FreeAndNil(List);
end;

function BmpEqual5x5Col32(Bmp: TBitmap): TBitmap;
// replace points by Mean of equal points;
const
//FiltSize = 1; // 1 -> 3x3:  (-1 .. 1) * (-1 .. 1)
  FiltSize = 2; // 2 -> 5x5:  (-2 .. 2) * (-2 .. 2)
  NumElems = sqr((FiltSize * 2) +1);
var
  SL32ArrA: TSL32Arr;
  SL32ArrR: TSL32Arr;
  List : TList;
var
  ListRecs : Array[0..NumElems-1] of TListGrayRec;

  function Median(x, y: Integer) : TCol32;
  var
    dx, dy : Integer;
    N : Integer;
    Gry : Integer;
    I, Ia, Ib, Idx : Integer;
  begin
    List.Clear;
    N := 0;
    for dy := -FiltSize to FiltSize do
      for dx := -FiltSize to FiltSize do
      begin
        ListRecs[N].aCol := SL32ArrA[y+dy, x+dx];
        ListRecs[N].aGry := GrayVal32(ListRecs[N].aCol);
        List.Add(@ListRecs[N]);
        Inc(N);
      end;
    List.Sort(CompareGry);
//  Result := TListGrayRec(List[NumElems div 2]^).aCol;  // Median

    Gry := GrayVal32(SL32ArrA[y, x]);
    For I := 0 to NumElems - 1 do
    begin
      Idx := I;
      if TListGrayRec(List[I]^).aGry > Gry then break;
    end;

    Ia := Max(Idx - NumElems div 5, 0);
    Ib := Min(Idx + NumElems div 5, NumElems -1);
    Gry := 0;
    for I := Ia to Ib do
      Inc(Gry, TListGrayRec(List[I]^).aGry);
    Gry := Gry div (Ib - Ia +1);
    Result.S := 0;
    Result.R := Gry;
    Result.G := Gry;
    Result.B := Gry;

  end;

var
  W, H, x, y : Integer;
begin
  BmpWH(Bmp,W,H);
  Result := BmpCreate32(W,H);
  SL32ArrA := BmpSL32Arr(Bmp);
  SL32ArrR := BmpSL32Arr(Result);

  List := TList.Create;

  // Grad into *.S part:
  for y := 0 +FiltSize to H -1 -FiltSize do
    for x := 0 +FiltSize to W -1 -FiltSize do
      SL32ArrR[y,x] := Median(x,y);
  Bmp.Modified := True;
  FreeAndNil(List);
end;

procedure BmpGray24(Bmp: TBitmap);
var
  SL24Arr : TSL24Arr;
  W, H, x, y : Integer;
begin
  SL24Arr := BmpSL24Arr(Bmp);
  BmpWH(Bmp,W,H);
  for x := 0 to W -1 do
    for y := 0 to H -1 do
      Sl24Arr[y,x] := GrayCol24(Sl24Arr[y,x]);
  Bmp.Modified := True;
end;

procedure BmpGray32(Bmp: TBitmap);
var
  SL32Arr : TSL32Arr;
  W, H, x, y : Integer;
begin
  SL32Arr := BmpSL32Arr(Bmp);
  BmpWH(Bmp,W,H);
  for x := 0 to W -1 do
    for y := 0 to H -1 do
      Sl32Arr[y,x] := GrayCol32(Sl32Arr[y,x]);
  Bmp.Modified := True;
end;

procedure BmpSoftGray32(Bmp: TBitmap);
var
  SL32Arr : TSL32Arr;
  W, H, x, y : Integer;
begin
  SL32Arr := BmpSL32Arr(Bmp);
  BmpWH(Bmp,W,H);
  for x := 0 to W -1 do
    for y := 0 to H -1 do
      Sl32Arr[y,x] := ColorSoft32(GrayCol32(Sl32Arr[y,x]));
  Bmp.Modified := True;
end;

procedure BmpSoft2Gray32(Bmp: TBitmap);
var
  SL32Arr : TSL32Arr;
  W, H, x, y : Integer;
begin
  SL32Arr := BmpSL32Arr(Bmp);
  BmpWH(Bmp,W,H);
  for x := 0 to W -1 do
    for y := 0 to H -1 do
      Sl32Arr[y,x] := ColorSoft2_32(GrayCol32(Sl32Arr[y,x]));
  Bmp.Modified := True;
end;

procedure BmpFramed32(Bmp: TBitmap; dx, dy: Integer);
var
  SL32Arr : TSL32Arr;
  W, H : Integer;
begin
  SL32Arr := BmpSL32Arr(Bmp);
  BmpWH(Bmp,W,H);
  Bmp.Width  := Bmp.Width  + 2 * dx;
  Bmp.Height := Bmp.Height + 2 * dy;
  BitBlt(Bmp.Canvas.Handle, dx, dy, W, H, Bmp.Canvas.Handle, 0, 0, cmSrcCopy);
  Bmp.Canvas.FillRect(Rect(  0,  0,  w, dy));
  Bmp.Canvas.FillRect(Rect(  0, dy, dx,  H));
  Bmp.Modified := True;
end;

function ColInterpolSL24Arr(const SLA: TSL24Arr; W, H: Integer; XD, YD: Double): TCol24;
// W: Width; H: Height
// for colors for interpolation:
//   A  B
//   C  D
var
  A, B, C, D: TCol24;
  X, Y, fx, fy : Integer;
begin
// Result := C24Blue; EXIT;       // 1.5 sec
  X := Round(XD-0.5);  // faster than trunc(XD)!
  Y := Round(YD-0.5);
// Result := C24Blue; EXIT;       // 2.5 sec
  if (X < 0) or (X >= W-1) or (Y < 0) or (Y >= H-1) then
  begin
    Result := C24White;
    exit;
  end;
// Result := SLA[Y  , X  ]; EXIT;       // 3.0 sec    instead of 4.6 sec

  A := SLA[Y  , X  ];     // A
  B := SLA[Y  , X+1];     // B
  C := SLA[Y+1, X  ];     // C
  D := SLA[Y+1, X+1];     // D

  fx := Round(256 * (XD - X));
  fy := Round(256 * (YD - Y));

  Result.R := (256*(fx*(B.R-A.R)+256*A.R)+fy*(fx*(A.R-B.R+D.R-C.R)+256*(C.R-A.R))) shr 16;
  Result.G := (256*(fx*(B.G-A.G)+256*A.G)+fy*(fx*(A.G-B.G+D.G-C.G)+256*(C.G-A.G))) shr 16;
  Result.B := (256*(fx*(B.B-A.B)+256*A.B)+fy*(fx*(A.B-B.B+D.B-C.B)+256*(C.B-A.B))) shr 16;
end;

function ColRangeSL32Arr(const SLA: TSL32Arr; W, H: Integer; XD, YD: Double): TCol32;
// W: Width; H: Height
var
  X, Y : Integer;
begin
// Result := C32Blue; EXIT;       // 0.9 sec
  X := Round(XD-0.5);  // faster than trunc(XD)!
  Y := Round(YD-0.5);
// Result := C32Blue; EXIT;       // 1.6 sec
  if (X < 0) or (X >= W-1) or (Y < 0) or (Y >= H-1) then
  begin
    Result := C32Blue;
    exit;
  end;
  Result := SLA[Y  , X  ];             // 2.2 sec    instead of 3.8 sec
end;

function ColInterpolSL32Arr_noAsm(const SLA: TSL32Arr; WS, HS: Integer; XS, YS: Double): TCol32;
// WS: Width; HS: Height of source SLA
// for colors for interpolation:
//   A  B
//   C  D
var
  A, B, C, D: TCol32;
  X, Y, fx, fy : Integer;
begin
  X := Round(XS-0.5);  // faster than trunc(XD)!
  Y := Round(YS-0.5);
  if (X < 0) or (X >= WS-1) or (Y < 0) or (Y >= HS-1) then
  begin
    Result := C32Blue;
    exit;
  end;
  A := SLA[Y  , X  ];
  B := SLA[Y  , X+1];
  C := SLA[Y+1, X  ];
  D := SLA[Y+1, X+1];
  fx := Round(256 * (XS - X));
  fy := Round(256 * (YS - Y));
  Result.R := (256*(fx*(B.R-A.R)+256*A.R)+fy*(fx*(A.R-B.R+D.R-C.R)+256*(C.R-A.R))) shr 16;
  Result.G := (256*(fx*(B.G-A.G)+256*A.G)+fy*(fx*(A.G-B.G+D.G-C.G)+256*(C.G-A.G))) shr 16;
  Result.B := (256*(fx*(B.B-A.B)+256*A.B)+fy*(fx*(A.B-B.B+D.B-C.B)+256*(C.B-A.B))) shr 16;
//  Result.S := (256*(fx*(B.S-A.S)+256*A.S)+fy*(fx*(A.S-B.S+D.S-C.S)+256*(C.S-A.S))) shr 16;
  Result.S := 0;
end;

function ColInterpolSL32Arr(const SLA: TSL32Arr; WS, HS: Integer; XS, YS: Double): TCol32;
// WS: Width; HS: Height of source SLA
// for colors for interpolation:
//   A  B
//   C  D
label
  To_Exit;
const
  AHalf : Double = 0.5;
  A256  : Double = 256;
var
  A, B, C, D: TCol32;
  X, Y, fx, fy, fAI, fBI, fCI, fDI : Integer;
  fA, fB, fC, fD : Word;
begin
  asm  // once for all
      push ebx
      push ecx
      push edx
  end;
  Case 0 of        // best: ?
    0:
    asm
      // X := Round(XS-0.5);  // faster than trunc(XD)!
      FLD  XS
      FSUB AHalf
      FISTP X
      // Y := Round(YS-0.5);
      FLD  YS
      FSUB AHalf
      FISTP Y
      FWAIT
    end;
  end;

  if (X < 0) or (X >= WS-1) or (Y < 0) or (Y >= HS-1) then
  begin
    Result := C32Blue;
    goto To_Exit;
  end;
// Result := SLA[Y  , X  ]; goto To_Exit;

  Case 1 of        // best: ?
    0:
    begin                     // correct
      A := SLA[Y  , X  ];     // A
      B := SLA[Y  , X+1];     // B
      C := SLA[Y+1, X  ];     // C
      D := SLA[Y+1, X+1];     // D
    end;
    1:
    begin
      asm                       // correct ??
//once for all!      push ebx

      //  A := SLA[Y  , X  ];     // A
      mov eax, SLA
      mov edx, Y
      mov eax, [eax+edx*4]
      mov ecx, x
      mov ebx, [eax+ecx*4]
      mov A,   ebx
      //  B := SLA[Y  , X+1];     // B
      mov ebx,[eax+ecx*4+4]
      mov B,   ebx

      //  C := SLA[Y+1, X  ];     // C
      mov eax, SLA
      mov eax, [eax+edx*4+4]
      mov ebx, [eax+ecx*4]
      mov C,   ebx
      //  D := SLA[Y+1, X+1];     // D
      mov ebx,[eax+ecx*4+4]
      mov D,   ebx

//once for all!      pop ebx
      end;
    end;
  end;

(*
  if A.S>200 then  // set by BmpGetEdge3x3Col32_ToS (may be in TformViewVideo.ApplyViewVideoImage)
  begin            // avoid interpolated drawing when low contrast (S= 255 - Contrast)
    Result := A;
    Goto To_Exit;
  end;


  // debug Show interpolated area green:
//  Result := C32Green;
//  Goto To_Exit;
*)

  Case 0 of        // best: ?
    0:  //
    asm
      // fx := Round(256 * (XS - X));
      FILD  X
      FSUBR XS
      FMUL  A256
      FISTP fx
      // fy := Round(256 * (YS - Y));
      FILD  Y
      FSUBR YS
      FMUL  A256
      FISTP fy
      FWAIT
    end;
  end;


  Case 0 of
    1: begin  // test data;
         //           AaRrGgBb          // This is correct !
         Integer(A):=$12345678;
         Integer(B):=$12345678;
         Integer(C):=$12345678;
         Integer(D):=$12345678;
         fx := $87;
         fy := $27;
       end;
  end;


  Case 12 of        // best: ? (12) performance is nearly equal!
//  asm (1 and 12) do not interpolate 4*255 (blue) to 255 but to 253!
    0:
    begin //   does not interpolate S part!   // but is good: keeps pure blue !

      Result.R := (256*(fx*(B.R-A.R)+256*A.R)+fy*(fx*(A.R-B.R+D.R-C.R)+256*(C.R-A.R))) shr 16;
      Result.G := (256*(fx*(B.G-A.G)+256*A.G)+fy*(fx*(A.G-B.G+D.G-C.G)+256*(C.G-A.G))) shr 16;
      Result.B := (256*(fx*(B.B-A.B)+256*A.B)+fy*(fx*(A.B-B.B+D.B-C.B)+256*(C.B-A.B))) shr 16;
//      Result.S := (256*(fx*(B.S-A.S)+256*A.S)+fy*(fx*(A.S-B.S+D.S-C.S)+256*(C.S-A.S))) shr 16;
      Result.S := 0;

    end;
    1:   // a bit quicker than 0!
    asm   // A B    //  A * fx_ * fy_ ;   B * fx  * fy_ ;
          // C D    //  C * fx_ * fy  ;   D * fx  * fy  ;
          // Order D C B A is quicker than A B C D!

//once for all!      push ecx
//once for all!      push edx

      xor ecx, ecx
      xor edx, edx

      // Integer(Result) := 0
      xor  eax, eax
      mov  Result, eax

      mov  ecx, 256
      sub  ecx, fx              // fx_ -> ecx
      mov  edx, 256
      sub  edx, fy              // fy_ -> edx

      // D * fx * fy
      // --- D.0R0B
      mov  eax, D               // D  -> eax  D=ARGB
      and  eax, $00ff00ff       // Mask         0R0B
      imul eax, fx              // 0R0B * fx
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0R0B
      imul eax, fy              // 0R0B * fx
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0R0B
      add  Result, eax             // Add D.0R0B to Result
      // --- D.A0G0
      mov  eax, D               // D  -> eax  D=ARGB
      shr  eax, $08             // eax -> 0ABG
      and  eax, $00ff00ff       // Mask         0A0G
      imul eax, fx              // 0A0G * fx
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0A0G
      imul eax, fy              // 0A0G * fy
      and  eax, $ff00ff00       // Mask         A0G0
      add  Result, eax          // Add D.A0G0 to Result

      // C * fx_ * fy
      // --- C.0R0B
      mov  eax, C               // C  -> eax  C=ARGB
      and  eax, $00ff00ff       // Mask         0R0B
      imul eax, ecx             // 0R0B * fx_
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0R0B
      imul eax, fy              // 0R0B * fy
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0R0B
      add  Result, eax             // Add C.0R0B to Result
      // --- C.A0G0
      mov  eax, C               // C  -> eax  D=ARGB
      shr  eax, $08             // eax -> 0ABG
      and  eax, $00ff00ff       // Mask         0A0G
      imul eax, ecx             // 0A0G * fx_
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0A0G
      imul eax, fy              // 0A0G * fy
      and  eax, $ff00ff00       // Mask         A0G0
      add  Result, eax          // Add C.A0G0 to Result

      // B * fx * fy_
      // --- B.0R0B
      mov  eax, B               // B  -> eax  B=ARGB
      and  eax, $00ff00ff       // Mask         0R0B
      imul eax, fx              // 0R0B * fx
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0R0B
      imul eax, edx             // 0R0B * fy_
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0R0B
      add  Result, eax          // Add A.0R0B to Result
      // --- B.A0G0
      mov  eax, B               // B  -> eax  B=ARGB
      shr  eax, $08             // eax -> 0ABG
      and  eax, $00ff00ff       // Mask         0A0G
      imul eax, fx              // 0A0G * fx
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0A0G
      imul eax, edx             // 0A0G * fy_
      and  eax, $ff00ff00       // Mask         A0G0
      add  Result, eax          // Add B.A0G0 to Result

      // A * fx_ * fy_
      // --- A.0R0B
      mov  eax, A               // A  -> eax  A=ARGB
      and  eax, $00ff00ff       // Mask         0R0B
      imul eax, ecx             // 0R0B * fx_
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0R0B
      imul eax, edx             // 0R0B * fy_
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0R0B
      add  Result, eax          // Add A.0R0B to Result
      // --- A.A0G0
      mov  eax, A               // A  -> eax  A=ARGB
      shr  eax, $08             // eax -> 0ABG
      and  eax, $00ff00ff       // Mask         0A0G
      imul eax, ecx             // 0A0G * fx_
      shr  eax, $08
      and  eax, $00ff00ff       // Mask         0A0G
      imul eax, edx             // 0A0G * fy_
      and  eax, $ff00ff00       // Mask         A0G0
      add  Result, eax          // Add A.A0G0 to Result

//once for all!      pop  edx
//once for all!      pop  ecx

    end; // asm 1
    12:  // a bit quicker than ?      combine 1 and 2 + Result (as ResultAG) and ResultRB (edx)  ; mask $00ff00ff in ecx
    asm   // A B    //  A * fx_ * fy_ ;   B * fx  * fy_ ;
          // C D    //  C * fx_ * fy  ;   D * fx  * fy  ;

      //   eax used here and for function result: no push and pop necessary    
      //   ebx not used
//once for all!      push ecx
//once for all!      push edx

      // the next line speeds up (sometimes)
      xor  eax, eax

      mov  eax, fx
      imul eax, fy
      shr  eax, $08
      mov  fDI, eax             // fDI

      mov  eax, 256
      sub  eax, fx
      mov  ecx, eax             // fx_ -> ecx
      mul  eax, fy
      shr  eax, $08
      mov  fCI, eax             // fCI

      mov  eax, 256
      sub  eax, fy
      mov  edx, eax             // fy_ -> edx
      imul eax, fx
      shr  eax, $08
      mov  fBI, eax             // fBI

      imul ecx, edx
      shr  ecx, $08
      mov  fAI, ecx             // fAI


      // Integer(Result) := 0
      xor  edx, edx          // use edx as ResultRB
      mov  Result,   edx     // first as ResultAG
      mov  ecx, $00ff00ff

      // A * fx_ * fy_
      // --- A.0R0B
      mov  eax, A               // A  -> eax  A=ARGB
      and  eax, ecx             // Mask         0R0B
      imul eax, fAI             // 0R0B * fA
      add  edx, eax             // Add A.RxBx to ResultRB
      // --- A.A0G0
      mov  eax, A               // A  -> eax  A=ARGB
      shr  eax, $08             // eax -> 0ABG
      and  eax, ecx             // Mask         0A0G
      imul eax, fAI             // 0A0G * fA
      add  Result, eax          // Add A.AxGx to Result

      // B * fx * fy_
      // --- B.0R0B
      mov  eax, B               // B  -> eax  B=ARGB
      and  eax, ecx             // Mask         0R0B
      imul eax, fBI             // 0R0B * fB
      add  edx, eax             // Add A.RxBx to ResultRB
      // --- B.A0G0
      mov  eax, B               // B  -> eax  B=ARGB
      shr  eax, $08             // eax -> 0ABG
      and  eax, ecx             // Mask         0A0G
      imul eax, fBI             // 0A0G * fB
      add  Result, eax          // Add B.AxGx to Result

      // C * fx_ * fy
      // --- C.0R0B
      mov  eax, C               // C  -> eax  C=ARGB
      and  eax, ecx             // Mask         0R0B
      imul eax, fCI             // 0R0B * fC
      add  edx, eax             // Add C.RxBx to ResultRB
      // --- C.A0G0
      mov  eax, C               // C  -> eax  D=ARGB
      shr  eax, $08             // eax -> 0ABG
      and  eax, ecx             // Mask         0A0G
      imul eax, fCI             // 0A0G * fC
      add  Result, eax          // Add C.AxGx to Result

      // D * fx * fy
      // --- D.0R0B
      mov  eax, D               // D  -> eax  D=ARGB
      and  eax, ecx             // Mask         0R0B
      imul eax, fDI             // 0R0B * fD
      add  edx, eax             // Add D.RxBx to ResultRB
      // --- D.A0G0
      mov  eax, D               // D  -> eax  D=ARGB
      shr  eax, $08             // eax -> 0ABG
      and  eax, ecx             // Mask         0A0G
      imul eax, fDI             // 0A0G * fD
      add  Result, eax          // Add D.AxGx to Result

      //ResultRB (in edx) and Result(AG) to Result

      shl  ecx,    $08          // $00ff00ff -> $ff00ff00
      and  Result, ecx          // Mask      A0G0
      and  edx,    ecx          // Mask            R0B0
      shr  edx,    $08          // eax :     0R0B
      add  Result, edx          // Result :  ARGB

//once for all!      pop  edx
//once for all!      pop  ecx

    end; // asm 12
    2:   //      very slow !!
    asm   // A B    //  A * fx_ * fy_ ;   B * fx  * fy_ ;  // colors are ARGB  (A=Alpha = S)  // A: most sig byte (high)
          // C D    //  C * fx_ * fy  ;   D * fx  * fy  ;
          // Order D C B A is quicker than A B C D!

//once for all!      push ebx
//once for all!      push ecx
//once for all!      push edx

      // Integer(Result) := 0
      xor  eax, eax
      mov  Result, eax

      mov  ecx, 256
      sub  ecx, fx               // fx_ -> ecx
      mov  edx, 256
      sub  edx, fy               // fy_ -> edx

      // fD  = fx  * fy
      mov  ebx, fx
      imul ebx, fy
      shr  ebx, $08
      mov  fD,  bx
      // fC  = fx_ * fy
      mov  ebx, ecx
      imul ebx, fy
      shr  ebx, $08
      mov  fC,  bx
      // fB  = fx  * fy_
      mov  ebx, fx
      imul ebx, edx
      shr  ebx, $08
      mov  fB,  bx
      // fA  = fx_ * fy_
      mov  ebx, ecx
      imul ebx, edx
      shr  ebx, $08
      mov  fA,  bx


      // D  *  fD
      mov  ax, fD
      mul  al,  D.S
      add  Result.S, ah
      mov  ax, fD
      mul  al,  D.R
      add  Result.R, ah
      mov  ax, fD
      mul  al,  D.G
      add  Result.G, ah
      mov  ax, fD
      mul  al,  D.B
      add  Result.B, ah

      // C  *  fC
      mov  ax, fC
      mul  al,  C.S
      add  Result.S, ah
      mov  ax, fC
      mul  al,  C.R
      add  Result.R, ah
      mov  ax, fC
      mul  al,  C.G
      add  Result.G, ah
      mov  ax, fC
      mul  al,  C.B
      add  Result.B, ah

      // B  *  fB
      mov  ax, fB
      mul  al,  B.S
      add  Result.S, ah
      mov  ax, fB
      mul  al,  B.R
      add  Result.R, ah
      mov  ax, fB
      mul  al,  B.G
      add  Result.G, ah
      mov  ax, fB
      mul  al,  B.B
      add  Result.B, ah

      // A  *  fA
      mov  ax, fA
      mul  al,  A.S
      add  Result.S, ah
      mov  ax, fA
      mul  al,  A.R
      add  Result.R, ah
      mov  ax, fA
      mul  al,  A.G
      add  Result.G, ah
      mov  ax, fA
      mul  al,  A.B
      add  Result.B, ah


//once for all!      pop  edx
//once for all!      pop  ecx
//once for all!      pop  ebx

    end; // asm 2
  end; // case
 To_Exit:
  asm  // once for all
      pop  edx
      pop  ecx
      pop  ebx
  end;
end;

function ColInterpolSL32Arr_TestAsm(const SLA: TSL32Arr; WS, HS: Integer; XS, YS: Double): TCol32;
// WS: Width; HS: Height of source SLA
// for colors for interpolation:
//   A  B
//   C  D
type
  TInt64 = Record
    Case Integer of
      0: (I64   : Int64  );
      1: (IA, IB: Integer);
      2: (CA, CB: TCol32 );
  end;
const
  AHalf : Double = 0.5;
  A256  : Double = 256;
  AI256 : Integer = 256;
var
  A, B, C, D: TCol32;
  X, Y, fx, fy : Integer;
  fA, fB, fC, fD : Integer;
  A64, B64, C64, D64, R64 : Int64;
  Acp, Bcp, Ccp, Dcp, Rcp : Comp;
  Aex, Bex, Cex, Dex, Rex : Extended;
  ResInt : Integer;
  function InterpolColor(A,B,C,D: Byte): Byte;
  begin
  //Result.R := (256*(fx*(B.R-A.R)+256*A.R)+fy*(fx*(A.R-B.R+D.R-C.R)+256*(C.R-A.R))) shr 16;
  //Result   := (256*(fx*(B-A)+256*A)+fy*(fx*(A-B+D-C)+256*(C-A))) shr 16;
  //                     |---|               |-------|     |---|
  //                 |--------------|    |----------------------|
  //            |------------------------------------------------|
  //
  //Result   := ( 256* (fx*B - fx*A + 256*A) + fy*(fx*A - fx*B + fx*D - fx*C + 256*C - 256*A) ) shr 16;
  //Result   := ( 256* (fx*B - fx*A + 256*A) + fx*fy*A - fx*fy*B + fx*fy*D - fx*fy*C + 256*fy*C - 256*fy*A ) shr 16;
  //Result   := ( 256*fx*B - 256*fx*A + 256*256*A + fx*fy*A - fx*fy*B + fx*fy*D - fx*fy*C + 256*fy*C - 256*fy*A ) shr 16;
  //Result   := ( - 256*fy*A - 256*fx*A + 256*256*A + fx*fy*A + 256*fx*B - fx*fy*B - fx*fy*C + 256*fy*C + fx*fy*D) shr 16;
  //Result   := ( (- 256*fy - 256*fx + 256*256 + fx*fy)*A + (-fx*fy + 256*fx )*B + (- fx*fy + 256*fy)*C + fx*fy*D) shr 16;

  //fD := fx*fy;
  //fA := fd - 256*fy - 256*fx + 256*256;
  //fB := 256 * fx - fD;
  //fC := 256 * fy - fD;
  Result   := (fA*A + fB*B + fC*C + fD * D) shr 16;
//    Result   := (256*(fx*(B-A)+256*A)+fy*(fx*(A-B+D-C)+256*(C-A))) shr 16;
  end;

begin
// Result := C32Blue; EXIT;       // 0.9 sec

  Case 1 of        // best: 1
    0:
    begin
      X := Round(XS-0.5);  // faster than trunc(XD)!
      Y := Round(YS-0.5);
    end;
    1:
    asm  // a bit faster
      // X := Round(XS-0.5);  // faster than trunc(XD)!
      FLD  XS
      FSUB AHalf
      FISTP X
      // Y := Round(YS-0.5);
      FLD  YS
      FSUB AHalf
      FISTP Y
      FWAIT
    end;
  end;

// Result := C32Blue; EXIT;       // 1.6 sec
  if (X < 0) or (X >= WS-1) or (Y < 0) or (Y >= HS-1) then
  begin
    Result := C32Blue;
    exit;
  end;
// Result := SLA[Y  , X  ]; EXIT;       // 2.2 sec    instead of 3.8 sec

  Case 0 of
    0 :
    begin
      A := SLA[Y  , X  ];     // A
      B := SLA[Y  , X+1];     // B
      C := SLA[Y+1, X  ];     // C
      D := SLA[Y+1, X+1];     // D
    end;
  end;

  Case 2 of        // best: 2
    0:
    begin
      fx := Round(256 * (XS - X));
      fy := Round(256 * (YS - Y));
    end;
    1:
    asm  // Slowest
      // fx := Round(256 * (XS - X));
      FILD  X
      FSUBR XS
      FIMUL  AI256
      FISTP fx
      // fy := Round(256 * (YS - Y));
      FILD  Y
      FSUBR YS
      FIMUL  AI256
      FISTP fy
      FWAIT
    end;
    2:  // fastest
    asm
      // fx := Round(256 * (XS - X));
      FILD  X
      FSUBR XS
      FMUL  A256
      FISTP fx
      // fy := Round(256 * (YS - Y));
      FILD  Y
      FSUBR YS
      FMUL  A256
      FISTP fy
      FWAIT
    end;
    3:  // fastest and factors    // is Slow!
    asm
      // fx := Round(256 * (XS - X));
      FILD  X
      FSUBR XS
      FMUL  A256
//      FISTP fx

      // fy := Round(256 * (YS - Y));
      FILD  Y
      FSUBR YS
      FMUL  A256
//      FISTP fy

                         //   ST  (0) |   ST(1)   |   ST(2)   |   ST(3)   |   ST(4)   |   ST(5)   |
                         //    fy     |    fx     |           |           |           |           |
       FLD    ST         //    fy     |    fy     |    fx     |           |           |           |
       FMUL   ST, ST(2)  //  fx * fy  |    fy     |    fx     |           |           |           |
       FIST   fD         //  fx * fy  |    fy     |    fx     |           |           |           |
       FXCH   ST(2)      //    fx     |    fy     |  fx * fy  |           |           |           |
       FMUL   A256       //  fx * 256 |    fy     |  fx * fy  |           |           |           |
       FXCH   ST(1)      //    fy     |  fx * 256 |  fx * fy  |           |           |           |
       FMUL   A256       //  fy * 256 |  fx * 256 |  fx * fy  |           |           |           |
       FLD    ST(0)      //  fy * 256 |  fy * 256 |  fx * 256 |  fx * fy  |           |           |
       FSUB   ST, ST(3)  //  fy*256-fD|  fy * 256 |  fx * 256 |  fx * fy  |           |           |
       FISTP  fC         //  fy * 256 |  fx * 256 |  fx * fy  |           |           |           |
       FLD    ST(1)      //  fx * 256 |  fy * 256 |  fx * 256 |  fx * fy  |           |           |
       FSUB   ST, ST(3)  //  fx*256-fD|  fy * 256 |  fx * 256 |  fx * fy  |           |           |
       FISTP  fB         //  fy * 256 |  fx * 256 |  fx * fy  |           |           |           |

       FXCH   ST(2)      //  fx * fy  |  fx * 256 |    fy*256 |           |           |           |
       FSUBRP ST(2), ST  //  fx * 256 | FD-fy*256 |           |           |           |           |  // 32743 // -21001
       FSUBP  ST(1), ST
       FLD    A256
       FMUL   A256

       FAddP  ST(1), ST
       FISTP  fA                      // 0 on stack remaining: Ok
      FWAIT

     // fD := fx*fy;
     // fA := fd - 256*fy - 256* fx +256*256 ;
     // fB := 256 * fx - fD;
     // fC := 256 * fy - fD;

    end;
    4:  // fastest and factors    // is Slow like 3
    asm
                         //   ST  (0) |   ST(1)   |   ST(2)   |   ST(3)   |   ST(4)   |   ST(5)   |
                         //           |           |           |           |           |           |
      FLD A256           //   256     |           |           |           |           |           |
      // fx := Round(256 * (XS - X));
      FILD  X            //    X      |   256     |           |           |           |           |
      FSUBR XS           //  XS - X   |   256     |           |           |           |           |
      FMUL  ST, ST(1)    //    fx     |   256     |           |           |           |           |

      // fy := Round(256 * (YS - Y));
      FILD  Y            //    Y      |    fx     |   256     |           |           |           |
      FSUBR YS           //  YS - Y   |    fx     |   256     |           |           |           |
      FMUL  ST, ST(2)    //    fy     |    fx     |   256     |           |           |           |
//      FISTP fy

                         //   ST  (0) |   ST(1)   |   ST(2)   |   ST(3)   |   ST(4)   |   ST(5)   |
                         //    fy     |    fx     |   256     |           |           |           |
       FLD    ST         //    fy     |    fy     |    fx     |   256     |           |           |
       FMUL   ST, ST(2)  //  fx * fy  |    fy     |    fx     |   256     |           |           |
       FIST   fD         //  fx * fy  |    fy     |    fx     |   256     |           |           |
       FXCH   ST(2)      //    fx     |    fy     |  fx * fy  |   256     |           |           |
       FMUL   ST, ST(3)  //  fx * 256 |    fy     |  fx * fy  |   256     |           |           |
       FXCH   ST(1)      //    fy     |  fx * 256 |  fx * fy  |   256     |           |           |
       FMUL   ST, ST(3)  //  fy * 256 |  fx * 256 |  fx * fy  |   256     |           |           |
       FLD    ST(0)      //  fy * 256 |  fy * 256 |  fx * 256 |  fx * fy  |   256     |           |
       FSUB   ST, ST(3)  //  fy*256-fD|  fy * 256 |  fx * 256 |  fx * fy  |   256     |           |
       FISTP  fC         //  fy * 256 |  fx * 256 |  fx * fy  |   256     |           |           |
       FLD    ST(1)      //  fx * 256 |  fy * 256 |  fx * 256 |  fx * fy  |   256     |           |
       FSUB   ST, ST(3)  //  fx*256-fD|  fy * 256 |  fx * 256 |  fx * fy  |   256     |           |
       FISTP  fB         //  fy * 256 |  fx * 256 |  fx * fy  |   256     |           |           |

       FXCH   ST(2)      //  fx * fy  |  fx * 256 |    fy*256 |   256     |           |           |
       FSUBRP ST(2), ST  //  fx * 256 | FD-fy*256 |    256    |           |           |           |  // 32743 // -21001
       FSUBP  ST(1), ST  //FD-256fx-256fy| 256    |           |           |           |           |
//     FLD    A256
       FXCH   ST(1)
       FMUL   ST,ST

       FAddP  ST(1), ST
       FISTP  fA                      // 0 on stack remaining: Ok
      FWAIT

     // fD := fx*fy;
     // fA := fd - 256*fy - 256* fx +256*256 ;
     // fB := 256 * fx - fD;
     // fC := 256 * fy - fD;

    end;
  end;

  Case 0 of        // best: 0
    0:
    begin // fastest!
      Result.R := (256*(fx*(B.R-A.R)+256*A.R)+fy*(fx*(A.R-B.R+D.R-C.R)+256*(C.R-A.R))) shr 16;
      Result.G := (256*(fx*(B.G-A.G)+256*A.G)+fy*(fx*(A.G-B.G+D.G-C.G)+256*(C.G-A.G))) shr 16;
      Result.B := (256*(fx*(B.B-A.B)+256*A.B)+fy*(fx*(A.B-B.B+D.B-C.B)+256*(C.B-A.B))) shr 16;
      Result.S := 0;
    end;
    10:
    begin // try Int64    // ignores green // resulting 32 bit code is complex // result is slow
      A64 := Integer(A) and $00FF00FF;
      B64 := Integer(B) and $00FF00FF;
      C64 := Integer(C) and $00FF00FF;
      D64 := Integer(D) and $00FF00FF;
      R64 := (256*(fx*(B64-A64)+256*A64)+fy*(fx*(A64-B64+D64-C64)+256*(C64-A64))) shr 16;
      Result := TCol32(TInt64(R64).IA and $00FF00FF);
    end;
    11:
    begin // try Comp     // ignores green // floating in fpu: image is distorted!
      Acp := Integer(A) and $00FF00FF;
      Bcp := Integer(B) and $00FF00FF;
      Ccp := Integer(C) and $00FF00FF;
      Dcp := Integer(D) and $00FF00FF;
      Rcp := (256*(fx*(Bcp-Acp)+256*Acp)+fy*(fx*(Acp-Bcp+Dcp-Ccp)+256*(Ccp-Acp))) / 16;
      Result := TCol32(TInt64(Rcp).IA and $00FF00FF);
    end;
    12:
    begin // try Extended // ignores green // Floating ... image is distorted // slow also
      Aex := Integer(A) and $00FF00FF;
      Bex := Integer(B) and $00FF00FF;
      Cex := Integer(C) and $00FF00FF;
      Dex := Integer(D) and $00FF00FF;
      Rex := (256*(fx*(Bex-Aex)+256*Aex)+fy*(fx*(Aex-Bex+Dex-Cex)+256*(Cex-Aex))) / 16;
      ResInt := Round(Rex) and $00FF00FF;
      Result := TCol32(ResInt);
    end;
    1:
    begin
      fD := fx*fy;
      fA := fd - 256*fy - 256*fx + 256*256;
      fB := 256 * fx - fD;
      fC := 256 * fy - fD;

      Result.R := InterpolColor(A.R, B.R, C.R, D.R);
      Result.G := InterpolColor(A.G, B.G, C.G, D.G);
      Result.B := InterpolColor(A.B, B.B, C.B, D.B);
      Result.S := 0;
    end;
    2:
    begin
      fD := fx*fy;
      fA := fd - 256*(fy + fx -256);
      fB := 256 * fx - fD;
      fC := 256 * fy - fD;
      Result.R := (fA*A.R + fB*B.R + fC*C.R + fD*D.R) shr 16;
      Result.G := (fA*A.G + fB*B.G + fC*C.G + fD*D.G) shr 16;
      Result.B := (fA*A.B + fB*B.B + fC*C.B + fD*D.B) shr 16;
      Result.S := 0;
    end;
    3:
    begin  // factors above   // is Slow!
      Result.R := (fA*A.R + fB*B.R + fC*C.R + fD*D.R) shr 16;
      Result.G := (fA*A.G + fB*B.G + fC*C.G + fD*D.G) shr 16;
      Result.B := (fA*A.B + fB*B.B + fC*C.B + fD*D.B) shr 16;
      Result.S := 0;
    end;
  end;
end;

type
  TGetFxy =  Array [0 .. 256] of byte;
var
  GetFxy : TGetFxy;                     // for nonlinear interpolation

procedure SetFxyArr(var Fxy: TGetFxy);
var
  I : Integer;
begin
  for I := 0 to 127 do
  begin
    Fxy[I] := Round(I * I / 128);
    Fxy[255-I] := 255 - Fxy[I];
  end;
  Fxy[256] := 255;
end;


function ColInterpolSL32Arr_noCheck(const SLA: TSL32Arr; XS, YS: Double): TCol32;
// W: Width; H: Height
// for colors for interpolation:
//   A  B
//   C  D
var
  A, B, C, D: TCol32;
  X, Y, fx, fy : Integer;
begin
  X := Round(XS-0.5);  // faster than trunc(XD)!
  Y := Round(YS-0.5);

  A := SLA[Y  , X  ];     // A
  B := SLA[Y  , X+1];     // B
  C := SLA[Y+1, X  ];     // C
  D := SLA[Y+1, X+1];     // D

  fx := Round(256 * (XS - X));
  fy := Round(256 * (YS - Y));

  Result.R := (256*(fx*(B.R-A.R)+256*A.R)+fy*(fx*(A.R-B.R+D.R-C.R)+256*(C.R-A.R))) shr 16;
  Result.G := (256*(fx*(B.G-A.G)+256*A.G)+fy*(fx*(A.G-B.G+D.G-C.G)+256*(C.G-A.G))) shr 16;
  Result.B := (256*(fx*(B.B-A.B)+256*A.B)+fy*(fx*(A.B-B.B+D.B-C.B)+256*(C.B-A.B))) shr 16;
  Result.S := 0;
end;

function ColInterpolSL32Arr_noCheck_XY(const SLA: TSL32Arr; X, fx, Y, fy: Integer): TCol32;
// W: Width; H: Height
// for colors for interpolation:
//   A  B
//   C  D
var
  A, B, C, D: TCol32;
//  X,  fx : Integer;
begin
//  X := Round(XD-0.5);  // faster than trunc(XD)!
//  Y := Round(YD-0.5);

//  fx := GetFxy[fx];
//  fy := GetFxy[fy];

  A := SLA[Y  , X  ];     // A
  B := SLA[Y  , X+1];     // B
  C := SLA[Y+1, X  ];     // C
  D := SLA[Y+1, X+1];     // D

//  fx := Round(256 * (XD - X));
//  fy := Round(256 * (YD - Y));

  Result.R := (256*(fx*(B.R-A.R)+256*A.R)+fy*(fx*(A.R-B.R+D.R-C.R)+256*(C.R-A.R))) shr 16;
  Result.G := (256*(fx*(B.G-A.G)+256*A.G)+fy*(fx*(A.G-B.G+D.G-C.G)+256*(C.G-A.G))) shr 16;
  Result.B := (256*(fx*(B.B-A.B)+256*A.B)+fy*(fx*(A.B-B.B+D.B-C.B)+256*(C.B-A.B))) shr 16;
  Result.S := A.S;
end;

function ColInterpolSL32Arr_noCheck_XY_2(const SLA: TSL32Arr; X, fx_0, Y, fy_0: Integer; ShowGrad:Boolean; GradScale_255: Integer): TCol32;
// W: Width; H: Height
// for colors for interpolation:
//
//       Ay (By)
//    Ax  A  B  (Bx)
//    Cx  C  D  (Dx)
//      (Cy)(Dy)
// needs "BmpGradCol32(Pic.Bitmap, MergeRatio_255/ 255)" called by frmImage UsePicture
// the TCol32.s part is used

  function MeanColor(y, x: Integer) : TCol32;
  const
    DD  = 1;
    numDD = sqr((DD *2) + 1);
  var
    dx, dy : Integer;
    RI, GI, BI : Integer;
  begin
    RI := 0;
    GI := 0;
    BI := 0;
    for dy := -dd to +dd do
    begin
      for dx := -dd to +dd do
      begin
        Inc(RI, SLA[y+dy, x+dx].R);
        Inc(GI, SLA[y+dy, x+dx].G);
        Inc(BI, SLA[y+dy, x+dx].B);
      end;
    end;

    Result.R := RI div numDD;
    Result.G := GI div numDD;
    Result.B := BI div numDD;
    Result.S := 0;
  end;
var
  Ax, Ay                 : TCol32;   // for gradX gradY at point A
//  By, Bx, Cx, Cy, Dx, Dy : TCol32;
  A, B, C, D: TCol32;
  MeanC : TCol32;
  fx, fy : Integer;
//  X,  fx : Integer;
  GrayAy, GrayAx, GrayA, GrayC, GrayB: Integer;
  GradAx, GradAy : Integer;
begin
//  X := Round(XD-0.5);  // faster than trunc(XD)!
//  Y := Round(YD-0.5);

  Ax := SLA[Y      , X    -1];     // Ax
  Ay := SLA[Y   -1 , X      ];     // Ay
//  Bx := SLA[Y      , X+1  +1];     // Bx
//  By := SLA[Y   -1 , X+1    ];     // By
//  Cx := SLA[Y+1    , X    -1];     // Cx
//  Cy := SLA[Y+1 +1 , X      ];     // Cy
//  Dx := SLA[Y+1    , X+1  +1];     // Dx
//  Dy := SLA[Y+1 +1 , X+1    ];     // Dy


  A := SLA[Y  , X  ];     // A
  B := SLA[Y  , X+1];     // B
  C := SLA[Y+1, X  ];     // C
  D := SLA[Y+1, X+1];     // D

  GrayA  := GrayVal32(A );
  GrayAx := GrayVal32(Ax);
  GrayAy := GrayVal32(Ay);
  GrayB  := GrayVal32(B );
  GrayC  := GrayVal32(C );

  GradAx := GrayA - GrayAx;
  if (GradAx <> 0)
    then GradAx := Min(256, Abs((GradScale_255 *(GrayB - GrayAx)) div GradAx))
    else GradAx := 0;
  GradAy := GrayA - GrayAy;
  if (GradAy <> 0)
    then GradAy := Min(256, Abs((GradScale_255 *(GrayC - GrayAy)) div GradAy))
    else GradAy := 0;

GradAx := Min((GradAx+GradAy) div 2, 255);
GradAx := Min((Integer(A.S) + B.S + C.S + D.S) div 4, 255);     // Grad from Gray Grad in *.S part of TCol32
GradAy := GradAx;

//  fx := Round(256 * (XD - X));
//  fy := Round(256 * (YD - Y));
  fx := (GetFxy[fx_0] * GradAx + (256 - GradAx) * fx_0) div 256;      // Grad low: Linear interpol
  fy := (GetFxy[fy_0] * GradAy + (256 - GradAy) * fy_0) div 256;      //      high: pixel center wider

// Lower Grad: use Mean of A,B,C,D:
   MeanC.R := (Integer(A.R) + B.R + C.R + D.R) div 4;
   MeanC.G := (Integer(A.G) + B.G + C.G + D.G) div 4;
   MeanC.B := (Integer(A.B) + B.B + C.B + D.B) div 4;
//MeanC := C32Red;
   // Low gradient returns first HighGrad returns second color;
   A := ColorMerged32(MeanColor(Y  , X  ), A, GradAx / 255);
   B := ColorMerged32(MeanColor(Y  , X+1), B, GradAx / 255);
   C := ColorMerged32(MeanColor(Y+1, X  ), C, GradAx / 255);
   D := ColorMerged32(MeanColor(Y+1, X+1), D, GradAx / 255);

//fx := fx_0;   // for linear interpol;
//fy := fy_0;

  Result.R := (256*(fx*(B.R-A.R)+256*A.R)+fy*(fx*(A.R-B.R+D.R-C.R)+256*(C.R-A.R))) shr 16;
  Result.G := (256*(fx*(B.G-A.G)+256*A.G)+fy*(fx*(A.G-B.G+D.G-C.G)+256*(C.G-A.G))) shr 16;
  Result.B := (256*(fx*(B.B-A.B)+256*A.B)+fy*(fx*(A.B-B.B+D.B-C.B)+256*(C.B-A.B))) shr 16;
if ShowGrad then
begin
Result.R := Min((GradAx+GradAy) div 2, 255);
Result.G := Result.R;
Result.B := Result.R;
end;
  Result.S := 0;
end;

function DiffHalf(A, B: TCol32): TCol32;
// DiffHalf := (A div 2) - (B div 2)
const
  mskH1 = $007F7F7F;
begin
  A.C      := ((A.C shr 1) and mskH1);
  B.C      := ((B.C shr 1) and mskH1);
  Result.B := A.B - B.B;
  Result.G := A.G - B.G;
  Result.R := A.R - B.R;
//  Dec (Result.B, B.B);
//  Dec (Result.G, B.G);
//  Dec (Result.R, B.R);
end;

function AddDiffHalf(A, DH: TCol32): TCol32;
// from A and DiffHalf come back to B (+-1)
begin
  Result.C := A.C;
  Dec (Result.B, 2*DH.B);
  Dec (Result.G, 2*DH.G);
  Dec (Result.R, 2*DH.R);
end;

procedure Test;
  function DiffHalfT(BA:Byte; BB: Byte): TCol32;
  var
    A, B: TCol32;
  begin
    A.C := 0;
    A.G := BA;
    B.C := 0;
    B.G := BB;
    Result := DiffHalf(A, B);
    Result := AddDiffHalf(A, Result);
  end;
var
  D: TCol32;
begin
  D := DiffHalfT($00, $00);
  if D.C = 0 then;
  D := DiffHalfT($00, $FF);
  if D.C = 0 then;
  D := DiffHalfT($FF, $00);
  if D.C = 0 then;
  D := DiffHalfT($FF, $FF);
  if D.C = 0 then;
end;

procedure BmpDiffHalf(Bmp0, Bmp1: TBitMap);
// input:
//   Bmp0: Previous
//   Bmp1: Current
// output:
//   Bmp0: Current
//   Bmp1: DiffHalf = (A div 2) - (B div 2)

var
  SLA, SLB : TSL32;
  CB: TCol32;
  W, H, x, y : Integer;
begin
  Bmp0.PixelFormat := pf32bit;  // otherwise pfDevice and slow and invalid!
  Bmp1.PixelFormat := pf32bit;
  BmpWH(Bmp0,W,H);
  for y := 0 to H -1 do
  begin
    SLA := Bmp0.Scanline[y];
    SLB := Bmp1.Scanline[y];
    for x := 0 to W -1 do
    begin
      CB := SLB[x];
      SLB[x] := DiffHalf(SLA[x], CB);
      SLA[x] := CB;
    end;
  end;
end;

procedure BmpAddDiffHalf(Bmp0, Bmp1: TBitmap);
// input:
//   Bmp0: Previous
//   Bmp1: DiffHalf
// output:
//   Bmp0: Current from Previous and DiffHalf;
//   Bmp1: unchanged;

var
  SLA, SLB : TSL32;
  W, H, x, y : Integer;
begin
  Bmp0.PixelFormat := pf32bit;  
  Bmp1.PixelFormat := pf32bit;
  BmpWH(Bmp0,W,H);
  for y := 0 to H -1 do
  begin
    SLA := Bmp0.Scanline[y];
    SLB := Bmp1.Scanline[y];
    for x := 0 to W -1 do
    begin
      SLA[x] := AddDiffHalf(SLA[x], SLB[x]);
    end;
  end;
end;

function PntShift(const P: TPointD; const Pnts, PntsShift: TPntDArr): TPointD;
// assume PntsA is rectangle of four points:
//  A,  B                              |       --> x
//  C,  D                              v
//                                     y
// PntsShift contains the shift for each of these points;
// calculate the shift for P:
//  interpolate between A, B (use x of P) -> AB=E: ShiftAB =E_
//  interpolate between C, D (use x of P) -> CD=F: ShiftCD =F_
//  interpolate between E, F (use y of P) ->    M: ShiftM  =M_
// Result := P+M_
var
  A , B , C , D  : TPointD;    // Points
  A_, B_, C_, D_ : TPointD;    // Shift of Points
  dAB, dCD, dAP, dCP : TPointD;
  E, F : TPointD;
  dEF, dEP      : TPointD;
  E_, F_, M_ : TPointD;
begin
  A  := Pnts[0];
  B  := Pnts[1];
  C  := Pnts[2];
  D  := Pnts[3];

  A_ := PntsShift[0];
  B_ := PntsShift[1];
  C_ := PntsShift[2];
  D_ := PntsShift[3];

  dAB := PntDiff(B , A);
  dAP := PntDiff(P , A);
  E   := PntAdd (A , PntMult(dAB,             dAP.X/dAB.X));  // AB
  E_  := PntAdd (A_, PntMult(PntDiff(B_, A_), dAP.X/dAB.X));  // ShiftAB

  dCD := PntDiff(D , C);
  dCP := PntDiff(P , C);
  F   := PntAdd (C , PntMult(dCD,             dCP.X/dCD.X));   // CD
  F_  := PntAdd (C_, PntMult(PntDiff(D_, C_), dCP.X/dCD.X));  // ShiftCD

  dEF := PntDiff(F , E);
  dEP := PntDiff(P , E);
  M_  := PntAdd (E_, PntMult(PntDiff(F_, E_), dEP.Y/dEF.Y));  // ShiftM

  Result := PntDiff(P, M_);
end;

function BmpAdaptedPntsDelta(Bmp: TBitmap; const Pnts, PntsShift: TPntDArr): TBitmap;
var
  SLA, SLB : TSL32Arr;
  W, H, x, y : Integer;
  XS, YS : Double;
begin
  BmpWH(Bmp,W,H);

  Result := BmpCreate32(W, H);

  SLA := BmpSL32Arr(Bmp);
  SLB := BmpSL32Arr(Result);

  for x := 0 to W -1 do
    for y := 0 to H -1 do
    begin
      PointToXY(PntShift(PointD(x,y), Pnts, PntsShift), XS, YS);
      SlB[y,x] := ColInterpolSL32Arr(SLA, W, H, XS, YS);
    end;
  Result.Modified := True;
end;

function BmpAdaptedPnts(Bmp: TBitmap; PntsA, PntsB: TPntDArr): TBitmap;
begin
  Result := BmpAdaptedPntsDelta(Bmp, PntsA, PntDiff(PntsA, PntsB));
end;

function BmpMoveDelta(Bmp: TBitmap; dx, dy: Double): TBitmap;
var
  SLA, SLB : TSL32Arr;
  W, H, x, y : Integer;
  XS, YS : Double;
begin
  BmpWH(Bmp,W,H);

  Result := BmpCreate32(W, H);

  SLA := BmpSL32Arr(Bmp);
  SLB := BmpSL32Arr(Result);

  for x := 0 to W -1 do
  begin
    XS := x + dx;
    for y := 0 to H -1 do
    begin
      YS := y + dy;
      SlB[y,x] := ColInterpolSL32Arr(SLA, W, H, XS, YS);
    end;
  end;
  Result.Modified := True;
end;

procedure BmpMoveDelta_PartDy_Proc(var BDst: TBitMap; const BSrc, BBack: TBitmap; dy: Double; xS0, yS0, WD, HD: Integer);
  // WS: Width; HS: Height of source SLA
  // for colors for interpolation:
  //   A
  //   C
var
  fA, fC : Byte;
  procedure InitVars;     // without fAi ... as integer: (dx;dy) = (0;0) or (1;1)    come to fA..fD are all 0!
  var
    fy : Integer;
  begin
    fy := Round(256 * dy);
    fA := EnsureRange(256 - fy, 0, MaxByte);
    fC := EnsureRange(      fy, 0, MaxByte);
  end;

  procedure ColInterpol(var Res, A, C: TCol32);
  begin
    Res.R := (fA*A.R + fC*C.R) shr 8;
    Res.G := (fA*A.G + fC*C.G) shr 8;
    Res.B := (fA*A.B + fC*C.B) shr 8;
    Res.S := 0;
  end;

  procedure ColInterpolBG(var Res, A, C, BG: TCol32);
  // interpolate between A and C (Green as Gray) if Gray is above LimInterPol then use BG
  // roll text above image (Text: A, B; Image: BG) 
  const
    LimInterpol = 220;
  var
    Gr: Byte;
  begin
    Gr := (fA*A.G + fC*C.G) shr 8;
    If Gr > LimInterpol then
    begin
      Res := BG;
    end else
    begin
      Res.R := Gr;
      Res.G := Gr;
      Res.B := Gr;
      Res.S := 0;
    end;
  end;

var
  S0, S1, SB, SBG : TSL;
  WS, HS, XS, YS,
  XSA, XSB, YSA, YSB : Integer;
begin
  BmpWH(BSrc,WS,HS);

  if not Assigned(BDst) then
    BDst := BmpCreate32(WD, HD);

  BDst.PixelFormat := pf32bit;
  BSrc.PixelFormat := pf32bit;
  if Assigned(BBack) then
  begin
    BBack.PixelFormat := pf32bit;
    if WD > BBack.Width  then
      BBack.Width  := WD;
    if HD > BBack.Height then
      BBack.Height := HD;
  end;

  BDst.Width  := WD;
  BDst.Height := HD;

  InitVars;

  XSA := Max(xS0 + 0,     0    );
  XSB := Min(xS0 + WD -1, WS -2);
  YSA := Max(yS0 + 0,     0    );
  YSB := Min(yS0 + HD -1, HS -2);

  S0  := BSrc.ScanLine[YSA   ];

  for YS := YSA to YSB do
  begin
    S1  := BSrc .ScanLine[YS+1  ];
    SB  := BDst .ScanLine[YS-yS0];
    if Assigned(BBack) then
    begin
      SBG := BBack.ScanLine[YS-YS0];
      for XS := XSA to XSB do
        ColInterpolBG (SB[XS-xS0]{Result[XD]}, S0[XS]{A}, S1[XS]{C}, SBG[XS-xS0]{BG});
    end else
    begin
      for XS := XSA to XSB do
        ColInterpol   (SB[XS-xS0]{Result[XD]}, S0[XS]{A}, S1[XS]{C});
    end;

    S0 := S1;
  end;
  BDst.Modified := True;
end;

procedure BmpMoveDelta_Part_Proc(var BDst: TBitMap; const BSrc, BBack: TBitmap; dx, dy: Double; xS0, yS0, WD, HD: Integer);
  // WS: Width; HS: Height of source SLA
  // for colors for interpolation:
  //   A  B
  //   C  D
var
  fA, fB, fC, fD : Word;

  procedure InitVars;     // without fAi ... as integer: (dx;dy) = (0;0) or (1;1)    come to fA..fD are all 0!
  var
    fx, fy, fAi, fBi, fCi, fDi : Integer;
  begin
    fx := Round(256 * dx);
    fy := Round(256 * dy);
    fDi := fx*fy;
    fAi := fdi - 256*(fy + fx -256);
    fBi := 256 * fx - fDi;
    fCi := 256 * fy - fDi;
    fA := EnsureRange(fAi, 0, MaxWord);
    fB := EnsureRange(fBi, 0, MaxWord);
    fC := EnsureRange(fCi, 0, MaxWord);
    fD := EnsureRange(fDi, 0, MaxWord);
  end;

  procedure ColInterpolSL32Arr_Proc(var Result, A, B, C, D: TCol32);
  begin
    Result.R := (fA*A.R + fB*B.R + fC*C.R + fD*D.R) shr 16;
    Result.G := (fA*A.G + fB*B.G + fC*C.G + fD*D.G) shr 16;
    Result.B := (fA*A.B + fB*B.B + fC*C.B + fD*D.B) shr 16;
    Result.S := 0;
  end;

var
  S0, S1, SB : TSL;
  WS, HS, XS, YS,
  XSA, XSB, YSA, YSB : Integer;
begin
  if (Abs(dx) < 0.001) then
  begin
    BmpMoveDelta_PartDy_Proc(BDst, BSrc, BBack, dy, xS0, yS0, WD, HD);
    Exit;
  end;
  BmpWH(BSrc,WS,HS);

  if not Assigned(BDst) then
    BDst := BmpCreate32(WD, HD);

  BDst.PixelFormat := pf32bit;
  BSrc.PixelFormat := pf32bit;

  BDst.Width  := WD;
  BDst.Height := HD;

  InitVars;

  XSA := Max(xS0 + 0,     0    );
  XSB := Min(xS0 + WD -1, WS -2);
  YSA := Max(yS0 + 0,     0    );
  YSB := Min(yS0 + HD -1, HS -2);

  S0  := BSrc.ScanLine[YSA   ];
  for YS := YSA to YSB do
  begin
    S1 := BSrc.ScanLine[YS+1  ];
    SB := BDst.ScanLine[YS-yS0];
    for XS := XSA to XSB do
      ColInterpolSL32Arr_Proc(
        SB[XS-xS0],  // Result [XD]
        S0[XS    ],  // A
        S0[XS+1  ],  // B
        S1[XS    ],  // C
        S1[XS+1  ]); // D
    S0 := S1;
  end;
  BDst.Modified := True;
end;

function BmpMoveDelta_Part(Bmp: TBitmap; dx, dy: Double; xS0, yS0, WD, HD: Integer): TBitmap;
begin
  Result := nil;
  BmpMoveDelta_Part_Proc(Result, Bmp, nil, dx, dy, xS0, yS0, WD, HD);
end;

procedure SinCosD(const Theta: Double; var Sin, Cos: Double);
asm
        FLD     Theta
        FSINCOS
        FSTP    qword ptr [edx]    // Cos
        FSTP    qword ptr [eax]    // Sin tbyte Ptr  for extended
        FWAIT
end;



procedure BmpRotatedProc(const BmpS: TBitmap; var Result: TBitmap; Rot: Double; CRect: TRect);
var
  SLA, SLR : TSL32Arr;
  WD, HD, WS, HS, dW, dH, x, y, x0, y0, x1, y1 : Integer;
  CosR, SinR,
  dCX, dCY, dX, dY : Double;
  xCosR_dX, xSinR_dY : Double;
begin
  BmpWH(BmpS,WS,HS);
  WD := 1*WS;
  HD := 1*HS;
//crect := rect(0,0,WS,HS);  

  if Result = nil then
  begin
    Result := BmpCreate32(WD, HD);
  end else
  begin
    Result.Width  := WD;
    Result.Height := HD;
  end;

  SLA := BmpSL32Arr(BmpS);
  SLR := BmpSL32Arr(Result);

  SinCosD(Rot, SinR, CosR);

  dCX := 0.5*(WS * CosR - HS * SinR - WS);
  dCY := 0.5*(WS * SinR + HS * CosR - HS);

  dw  := WD - WS;
  dH  := HD - HS;
  dX  := 0.5*(dw * CosR - dh * SinR ) + dCX;
  dY  := 0.5*(dw * SinR + dh * CosR ) + dCY;

  x0  := Max( 0, CRect.Left  );
  y0  := Max( 0, CRect.Top   );
  x1  := Min(WD, CRect.Right ) -1;
  y1  := Min(HD, CRect.Bottom) -1;

  for x := x0 to x1 do
  begin
    xCosR_dX := x * CosR - dX - y0 * SinR;
    xSinR_dY := x * SinR - dY + y0 * CosR;
    for y := y0 to y1 do
    begin
      //XS := (x * CosR - y * SinR) - dX;
      //YS := (x * SinR + y * CosR) - dY;
      //SlR[y,x] := ColInterpolSL32Arr(SLA, WS, HS, XS, YS);
      //XS := xCosR_dX - y * SinR;
      //YS := xSinR_dY + y * CosR;
      SLR[y,x] := ColInterpolSL32Arr(SLA, WS, HS, xCosR_dX, xSinR_dY);
      xCosR_dX := xCosR_dX - SinR;
      xSinR_dY := xSinR_dY + CosR;
    end;
  end;
  Result.Modified := True;
end;

procedure BmpRotatedProc(const BmpS: TBitmap; var Result: TBitmap; Rot: Double);
var
  WS, HS : Integer;
begin
  BmpWH(BmpS,WS,HS);
  BmpRotatedProc(BmpS, Result, Rot, Rect(0,0, WS, HS));
end;

function BmpRotated(Bmp: TBitmap; Rot: Double): TBitmap;
begin
  Result := nil;
  BmpRotatedProc(Bmp, Result, Rot);
end;

procedure BmpRotateDemo32(Pic: TPicture; Phi0, Phi1, dPhi: Double);
var
  Tim: TDosTimer;
  BmpOrg, BmpRot : TBitmap;
  SLA, SLB : TSL32Arr;
  W, H, x, y       : Integer;
  Rot,
  CosR, SinR,
  XCosR_dCX, XSinR_dCY,
  XS, YS, dCX, dCY : Double;
begin
  StartDosTimer(Tim);

  BmpRot := Pic.Bitmap;
  BmpWH(BmpRot,W,H);
  BmpOrg := TBitmap.Create;
  BmpOrg.Assign(BmpRot);

  SLA := BmpSL32Arr(BmpOrg);
  SLB := BmpSL32Arr(BmpRot);

  Rot := Phi0;
  While Rot <= Phi1 do
  begin
    CosR := Cos(Rot);
    SinR := Sin(Rot);

    dCX := 0.5*(W * CosR - H * SinR - W);
    dCY := 0.5*(W * SinR + H * CosR - H);

    for x := 0 to W -1 do
    begin
      XCosR_dCX := x * CosR - dCX;
      XSinR_dCY := x * SinR - dCY;
      for y := 0 to H -1 do
      begin
        XS := XCosR_dCX - y * SinR;
        YS := XSinR_dCY + y * CosR;
        SlB[y,x] := ColInterpolSL32Arr(SLA, W, H, XS, YS);
      end;
    end;
    BmpRot.Modified := True;
    BmpRot.Canvas.Refresh;
    Application.ProcessMessages;
    Rot := Rot + dPhi;
  end;
  FreeAndNil(BmpOrg);
  ShowMessageFmt('Time: %4.1f [s]', [ReadDosTimer(Tim)]);
end;


procedure BmpGlasses32_Init(BmpD, BmpS: TBitMap; aParentInvalRect: TWinControl;
  aGetZoomInfo: TGetZoomInfo; aGetVisibleRect: TGetVisibleRect; var GF: TGlassesFrame);
// D: Destination; S: Source;
begin
  GF.Valid := False;
  
  GF.R := Rect(0,0,0,0);
//  PictureToBmp(ImgD.Picture);        // enshure Picture.graphic is TBitmap

//  GF.ImgD := ImgD;

  GF.GetZoomInfo    := aGetZoomInfo;
  GF.ImgZoomInfo    := GF.GetZoomInfo;
  GF.GetVisibleRect := aGetVisibleRect;
  GF.VisRect        := GF.GetVisibleRect;

  // Destination
  GF.BmpDst := BmpD;
     BmpWH(GF.BmpDst, GF.WD, GF.HD);

  // store original:
  GF.BmpOrg := TBitmap.Create;
  GF.BmpOrg.Assign(BmpD);


  GF.ParentForInvalidateRect := aParentInvalRect;
  if Assigned(BmpS) then
  begin
//    PictureToBmp(ImgS.Picture);        // enshure Picture.graphic is TBitmap
//    GF.ImgS := ImgS;
    GF.BmpSrc := BmpS;
  end else
  begin
    GF.BmpSrc := GF.BmpOrg;
  end;

  BmpWH(GF.BmpSrc, GF.WS, GF.HS);


  GF.SLOrg := BmpSL32Arr(GF.BmpOrg);
  GF.SLSrc := BmpSL32Arr(GF.BmpSrc);
  GF.SLDst := BmpSL32Arr(GF.BmpDst);
  GF.TimeStart := Now;
  GF.RequestUpdate := True;
  GF.Valid := False;
end;

function CalcOrigRect(RL: TRect; ZI: TZoomInfo): TRect;
//  XZ := Trunc((X-ZoomInfo.dx)/ZoomInfo.ZFx);
//  YZ := Trunc((Y-ZoomInfo.dy)/ZoomInfo.ZFy);

  function XOrg(X: Integer): Integer;
  begin
    Result := Trunc( X * ZI.ZFx + ZI.dx);
  end;
  function YOrg(Y: Integer): Integer;
  begin
    Result := Trunc( Y * ZI.ZFy + ZI.dy);
  end;
begin
  Result.Left   := XOrg(RL.Left);
  Result.Top    := YOrg(RL.Top);
  Result.Right  := XOrg(RL.Right);
  Result.Bottom := YOrg(RL.Bottom);
end;


var
  UpdTime : TDateTime = 0;
  UpdCtr  : Integer   = 0;
procedure BmpGlasses32_InvalidateRect(const GF: TGlassesFrame; R: TRect; Upd: Boolean);
// needs correct ZoomInfo!
var
  ROrig: TRect;
  TimNow,
  DeltaSec : TDateTime;
  Wnd: HWND;
//  PR : ^TRect;
begin
  if Assigned(GF.ParentForInvalidateRect) then
  begin
    ROrig := RectExpand(CalcOrigRect(R, GF.ImgZoomInfo), 1);

    InvalidateRect(GF.ParentForInvalidateRect.Handle, @ROrig, False);

    if Upd then
    begin
      Wnd := GF.ParentForInvalidateRect.Handle;
//      PR := nil;
//      if GetUpdateRect(Wnd, PR^, False) then
      begin
        TimNow   := Now;
        DeltaSec := Abs(UpdTime - TimNow)*3600*24;
        if DeltaSec > 0.1 then   // if nothing to do: Update occures more often!
        begin
//        GF.BmpDst.Canvas.Rectangle(R);
//        Windows.Rectangle(GF.BmpDst.Canvas.Handle ,R.Left, R.Top, R.Right, R.Bottom);
//        Windows.Rectangle(GF.BmpDst.Canvas.Handle ,0, 0, GF.BmpDst.Width, GF.BmpDst.Height);  // without invalidate

          UpdateWindow(Wnd);  // forces immediate update!
          UpdMsg := Format('UpdCtr: %5d; UpdSec: %6.2f', [UpdCtr, DeltaSec]);
          Inc(UpdCtr);
          UpdTime := TimNow;
        end;
      end;
    end;
  end;
end;

procedure BmpGlasses32_Done(var GF: TGlassesFrame; RestoreOrg: Boolean);
var
  y : Integer;
  LOrg, LDst : TSL;
begin
  GF.Valid  := False;
  GF.Moving := False;
  if not Assigned(GF.BmpOrg) then
  begin
    SetLength(GF.SLOrg, 0);
    SetLength(GF.SLSrc, 0);
    SetLength(GF.SLDst, 0);
    Exit;
  end;

  try
  //  GF.BmpDst.Assign(GF.BmpOrg);
    // better: paint Org last Rect to Dst to avoid problems with others using Dst
    if RestoreOrg then
      for y := GF.R.Top to GF.R.Bottom -1 do         // GF.R: surrounding rectangle of last Move_Paint region
      begin  // Paint Orig to Dest:
        LOrg := GF.SLOrg[y];
        LDst := GF.SLDst[y];
        // for x := R.Left to R.Right -1 do
        //  LB[x] := LA[x];
        Move(LOrg[GF.R.Left], LDst[GF.R.Left], SizeOf(TCol32)*(GF.R.Right -  GF.R.Left));
      end;

  except
    on E: exception do
    begin
    end;
  end;


  BmpGlasses32_InvalidateRect(GF, GF.R, True);

  //=================================================================================================
     // Paint Orig to Dest instead of BmpDst.Assign... avoids problems like:
     // BmpDst becomes invalid for others because changed:
     //   a) BmpGlasses32_Init uses GF.BmpDst := BmpD; // this does not create a new Bitmap as by assign
     //   b) BmpGlasses32_Done uses GF.BmpDst.Assign(GF.BmpOrg); (when GF.BmpOrg is assigned)
     //                        by this all GFs[] get new BmpDst !!
  //=================================================================================================

  SetLength(GF.SLOrg, 0);
  SetLength(GF.SLSrc, 0);
  SetLength(GF.SLDst, 0);


  FreeAndNil(GF.BmpOrg);
end;

function BmpGlasses32_Valid(var GF: TGlassesFrame): Boolean;
// avoid exception with invalid bitmaps
begin
  Result := GF.Valid;
//            and (GF.ImgD.Picture.Graphic is  TBitmap)   // before next to avoid creation of empty Bitmap
//            and (GF.ImgD.Picture.Bitmap = GF.BmpDst);
  if (not Result) and (GF.Valid) then
  begin
    FreeAndNil(GF.BmpOrg);  // to avoid BmpRot set to BmpOrg
    BmpGlasses32_Done(GF, True);
  end;
end;

function LeveledFactor(Factor, Level: Double): Double;
// level 0: returns  1.0; Level 1 returns Factor
begin
  Result := 1.0 +  Level * ( Factor - 1.0);
end;

procedure BmpGlasses32_Move(var GF: TGlassesFrame; XC, YC: Double; OrigMode: TOrigMode=OM_Keep; Upd:Boolean=True);
label
  Next_X, Next_Y;
var // for ScreenOnly = True
  ScrX, ScrY, LastScrX, LastScrY : Integer;
  function DestXToScrX(DestX: Integer): Integer;
  begin
    Result := Trunc( DestX * GF.ImgZoomInfo.ZFx * 1.5 + GF.ImgZoomInfo.dx);
  end;
  function DestYToScrY(DestY: Integer): Integer;
  begin
    Result := Trunc( DestY * GF.ImgZoomInfo.ZFx * 1.5 + GF.ImgZoomInfo.dy);
  end;
  function PntRotated(Pnt: TPoint): TPoint;              overload;
  begin
    Result.X := Round(  Pnt.X * GF.CosRot - Pnt.Y * GF.SinRot);
    Result.Y := Round(  Pnt.X * GF.SinRot + Pnt.Y * GF.CosRot);
  end;
  function PntRotated(Pnt: TPointD): TPointD;            overload;
  begin
    Result.X :=         Pnt.X * GF.CosRot - Pnt.Y * GF.SinRot;
    Result.Y :=         Pnt.X * GF.SinRot + Pnt.Y * GF.CosRot;
  end;
  function PntRotatedNeg(Pnt: TPoint): TPoint;           overload;
  begin
    Result.X := Round(  Pnt.X * GF.CosRot + Pnt.Y * GF.SinRot);
    Result.Y := Round(- Pnt.X * GF.SinRot + Pnt.Y * GF.CosRot);
  end;
  function PntRotatedNeg(Pnt: TPointD): TPointD;         overload;
  begin
    Result.X := Round(  Pnt.X * GF.CosRot + Pnt.Y * GF.SinRot);
    Result.Y := Round(- Pnt.X * GF.SinRot + Pnt.Y * GF.CosRot);
  end;
  function PntCenter(PntA, PntB: TPoint): TPoint;        overload;
  begin
    Result := PntMult(PointsAdd(PntA, PntB), 0.5);
  end;
  function PntRotCent(Pnt, Center: TPoint): TPoint;      overload;
  begin
    Result := PointsAdd(PntRotated(PointsSub(Pnt    , Center)), Center);
  end;
  function PntRotCent(Pnt, Center: TPointD): TPointD;    overload;
  begin
    Result := PointsAdd(PntRotated(PointsSub(Pnt    , Center)), Center);
  end;
  function PntRotCentNeg(Pnt, Center: TPoint): TPoint;   overload
  begin
    Result := PointsAdd(PntRotatedNeg(PointsSub(Pnt    , Center)), Center);
  end;
  function PntRotCentNeg(Pnt, Center: TPointD): TPointD; overload
  begin
    Result := PointsAdd(PntRotatedNeg(PointsSub(Pnt    , Center)), Center);
  end;

  function RectRotCentSur(R: TRect): TRect;
  // SurroundRect of rotated Rect
  // Points:    A(=TopLeft)  B
  //            C            D(=BottomRight);
  var
    Center, A,B,C,D : TPoint;
    MinX, MinY, MaxX, MaxY : Integer;
  begin
    Center := PntCenter(R.TopLeft, R.BottomRight);
    A := R.TopLeft;
    B := Point(R.Right, R.Top);
    C := Point(R.Left,  R.Bottom);
    D := R.BottomRight;
    A := PntRotCent(A, Center);
    B := PntRotCent(B, Center);
    C := PntRotCent(C, Center);
    D := PntRotCent(D, Center);
    MinX := Min(Min(A.X,B.X),Min(C.X,D.X));
    MinY := Min(Min(A.Y,B.Y),Min(C.Y,D.Y));
    MaxX := Max(Max(A.X,B.X),Max(C.X,D.X));
    MaxY := Max(Max(A.Y,B.Y),Max(C.Y,D.Y));
    Result.TopLeft     := Point(MinX, MinY);
    Result.BottomRight := Point(MaxX, MaxY);
  end;

  procedure PntRotCentGF(var xr, yr: Double);
  var
    xrh : Double;
  begin
    // PRot := PntRotCent(PointD(x, y), PointD(XC, YC));         // slow!
    // xr   := PRot.X;
    // yr   := PRot.Y;
    xrh:= xr - XC;
    yr := yr - YC;
    xr := (  xrh* GF.CosRot - yr * GF.SinRot) + XC;
    yr := (  xrh* GF.SinRot + yr * GF.CosRot) + YC;
  end;

  procedure PntRotNegCentGF(var xr, yr: Double);
  var
    xrh : Double;
  begin
    // PRot := PntRotCentNeg(PointD(XS, YS), PointD(XC, YC));    // slow!
    // XS   := PRot.X;
    // YS   := PRot.Y;
    xrh:= xr - XC;
    yr := yr - YC;
    xr := (  xrh* GF.CosRot + yr * GF.SinRot) + XC;
    yr := (- xrh* GF.SinRot + yr * GF.CosRot) + YC;
  end;

var
  dly : Double; //= 2.5;
  ZF, sfx, sfy : Double;
  LOrg, LDst : TSL;
  R, RL : TRect;
  RLonly : TRectArr;
  IR, x, y       : Integer;
  DeltaTime,
  TimeFactorX, TimeFactorY,

  Rad2ShowEdge, Rad2ShowCenter,
  xr, yr,
  Rad, Rad2, dx, dy, Dist2, RelDist2, fx, fy, dfm, XS, YS, dcXS, dcYS: Double;
  PRot : TPointD;
  mode : Integer;
  ColInt, ColMrg : TCol32;
  VisRect : TRect;
  RotFlg : Boolean;
  Lst_y, Lst_x: Integer;
  ddx, ddy, dxy : Double;
  Lst_d, Act_d, Lst_h : TDoubArr;
begin
  if (not BmpGlasses32_Valid(GF)) or (not Assigned(GF.BmpOrg)) or GF.Moving
  then
    EXIT;

  LastScrX := 0;  // 08.01.09 P.W
  dy       := 0;  // 08.01.09 P.W
  fx       := 1;  // 08.01.09 P.W
  fy       := 1;  // 08.01.09 P.W

  GF.ImgZoomInfo := GF.GetZoomInfo;
  GF.VisRect     := GF.GetVisibleRect;

{   // Paint the visible rect for debugging:
GF.BmpDst.Canvas.Brush.Color := clGreen;
GF.BmpDst.Canvas.Pen.Color   := clYellow;
GF.BmpDst.Canvas.Rectangle(RectExpand(GF.VisRect,+5,+5));
GF.BmpDst.Canvas.Brush.Color := clAqua;
GF.BmpDst.Canvas.Pen.Color   := clRed;
GF.BmpDst.Canvas.Rectangle(RectExpand(GF.VisRect,-5,-5));
BmpGlasses32_InvalidateRect(GF, RectExpand(GF.VisRect,+5,+5));
Exit;
//}



  GF.LastXC := XC;
  GF.LastYC := YC;
  RotFlg    := Abs(GF.RotateDxDy) > 0.001;

  try
    GF.Moving := False;
    Rad  := 0.5 * GF.Width;
    Rad2 := Sqr(Rad);

    Rad2ShowEdge   := Sqr(Rad - Max(1, 2.0 / GF.ImgZoomInfo.ZFx));
    Rad2ShowCenter := Sqr(      Max(1, 2.0 / GF.ImgZoomInfo.ZFx));

    dly  := GF.RatioXY;
    ZF   := GF.RelZoom;
    mode := GF.Mode;
    RL   := GF.R;

    DeltaTime  := ((Now - GF.TimeStart) * 24 * 3600);
    if Abs(GF.PeriodTimeX) > 0.001
      then TimeFactorX := Sin((2 * Pi * DeltaTime / GF.PeriodTimeX)+GF.PeriodPhaseX)
      else TimeFactorX := 1;
    if Abs(GF.PeriodTimeY) > 0.001
      then TimeFactorY := Sin((2 * Pi * DeltaTime / GF.PeriodTimeY))
      else TimeFactorY := 1;
    if Abs(GF.ZoomRelAmplitude) > 0.001
      then ZF := ZF + GF.ZoomRelAmplitude * TimeFactorX;

    if (Mode = 6) {or (Mode =4)} then
    begin
      sfx := 0.5       / (1-ZF);
      sfy := 0.5 * dly / (1-ZF);
      GF.R.Left   := Round(EnsureRange(XC-(GF.WS*sfx), 0, GF.WD));
      GF.R.Right  := Round(EnsureRange(XC+(GF.WS*sfx), 0, GF.WD));
      GF.R.Top    := Round(EnsureRange(YC-(GF.HS*sfy), 0, GF.HD));
      GF.R.Bottom := Round(EnsureRange(YC+(GF.HS*sfy), 0, GF.HD));
    end else
    begin
      if RotFlg then
      begin
        GF.R.Left   := Round(XC-Rad    );
        GF.R.Right  := Round(XC+Rad    );
        GF.R.Top    := Round(YC-Rad*dly);
        GF.R.Bottom := Round(YC+Rad*dly);

        R:=RectRotCentSur(GF.R);
        IntersectRect(GF.R, R, Rect(0,0, GF.WD, GF.HD));
      end else
      begin
        GF.R.Left   := Round(EnsureRange(XC-Rad,     0, GF.WD));
        GF.R.Right  := Round(EnsureRange(XC+Rad,     0, GF.WD));
        GF.R.Top    := Round(EnsureRange(YC-Rad*dly, 0, GF.HD));
        GF.R.Bottom := Round(EnsureRange(YC+Rad*dly, 0, GF.HD));
      end;
    end;

    if GF.ScreenOnly and (not IntersectRect(GF.R, GF.R, GF.VisRect)) then EXIT;

    if OrigMode <> OM_KeepBG then
    begin
      // restore previous Rect Part that is not covered by new rect:
      RLonly := Rect1Only(RL, GF.R);
      for IR := 0 to Length(RLonly) -1 do
      begin
        R := RLonly[IR];
        if R.Left < R.Right then
        for y := R.Top to R.Bottom -1 do
        begin
          LOrg := GF.SLOrg[y];
          LDst := GF.SLDst[y];
          // for x := R.Left to R.Right -1 do
          //  LB[x] := LA[x];
          Move(LOrg[R.Left], LDst[R.Left], SizeOf(TCol32)*(R.Right -  R.Left));
        end;
      end;
    end;

    if (Mode = 7) then
    begin
      SetLength(Lst_d, GF.WS);
      SetLength(Act_d, GF.WS);
    end;


    LastScrY := -1;

    // modify image part:
    for y := GF.R.Top to GF.R.Bottom -1 do
    begin // for y
      if GF.ScreenOnly then
      begin
        ScrY := DestYToScrY(Y);
        if ScrY = LastScrY then
        begin
//        for x := GF.R.Left to GF.R.Right -1 do GF.SLDst[y,x] := GF.SLDst[y-1,x];
          Move(GF.SLDst[y-1,GF.R.Left], GF.SLDst[y,GF.R.Left], SizeOf(TCol32)*(GF.R.Right -  GF.R.Left));
//        for x := GF.R.Left to GF.R.Right -1 do GF.SLDst[y,x] := c32yellow;
          Goto Next_Y;
        end;
        LastScrY := ScrY;
        LastScrX := -1;
      end;

      LOrg := GF.SLOrg[y];
      LDst := GF.SLDst[y];

      if not RotFlg then
      begin
        yr   := y;
        dy   := (yr - YC)/dly;
      end;

      if (Mode = 7) then
      begin
        Lst_h := Lst_d;
        Lst_d := Act_d;
        Act_d := Lst_h;
      end;

      for x := GF.R.Left to GF.R.Right -1 do
      begin // for x
        if GF.ScreenOnly then
        begin
          ScrX := DestXToScrX(X);
          if ScrX = LastScrX then
          begin
            LDst[x] := LDst[x-1];
            if (Mode=7) then
            begin
              Act_d[x] := Act_D[x-1];
            end;
            Goto Next_X;
          end;
          LastScrX := ScrX;
        end;

        xr := x;
        if RotFlg then
        begin
          yr := y;
          PntRotCentGF(xr, yr);
          dy   := (yr - YC)/dly;
        end;

        dx :=  xr - XC;

        Dist2    := dx*dx + dy*dy;
        RelDist2 := (Rad2 - Dist2) / Rad2;

        dfm := 1.0;
        if (Dist2 <= Rad2) or (Mode = 6) then
        begin    // (Dist2 <= Rad2)
          case Mode of
            0: begin
                 dfm := sqrt(RelDist2);
                 fx := ZF * dfm;
                 fy := fx;
               end;
            1: begin
                 dfm := RelDist2;
                 fx := ZF * dfm;
                 fy := fx;
               end;
            7, // ColorSpot
            2: begin
                 dfm := sqr(RelDist2);
                 fx := ZF * dfm;
                 fy := fx;
               end;
            3,
            4: begin
                 fx := ZF;
                 fy := fx;
               end;
            5,
            6: begin
                 fx := ZF;        // fx = 0 for scale 1:1 !
                 //a) fy := dly / ( 1- fx);
                 //b) fy := 1 -  1 / fy;
                 //a and b combinded:
                 fy := 1 - (1-fx)/dly;
                 if mode = 6 then
                   dy := yr - YC;
               end;
          end;
        //  larger fxy: larger zoom!
        //  fy := 2.5 * fx;  // -> larger zoom of y!

          if mode = 4 then
          begin
            XS := xr - fx * dx;
            YS := yr - fy * (Yr - YC);
          end else
          begin
            XS := xr - fx * dx;
            YS := yr - fy * dy;
          end;

          if (Mode <> 4) then
          if (Dist2 <= Rad2) and ((GF.dcxRatio <>0) or (GF.dcyRatio <>0)) then
          begin  // moving the center
            dcXS := sqrt(sqrt(RelDist2)) *  Rad;
            dcYS := - dcXS;
            dcXS := dcXS * LeveledFactor(dy / Rad, GF.LeftRightShakeLevel);
            if Gf.DyAbs
            then dcYS := dcYS * LeveledFactor(abs(dx) / Rad, GF.TopDownShakeLevel)
            else dcYS := dcYS * LeveledFactor(    dx  / Rad, GF.TopDownShakeLevel);

            XS := XS + dcXS * RelDist2 * GF.dcxRatio*TimeFactorX;
            YS := YS + dcYS * RelDist2 * GF.dcyRatio*TimeFactorY;
          end;

          if (Mode = 4) or (Mode = 6) then
          begin
            XS := XS - XC + (GF.WS div 2) + 10 * GF.dcxRatio;
            YS := YS - YC + (GF.HS div 2) + 10 * GF.dcyRatio;
          end;

          if RotFlg and (Mode <> 4) then
            PntRotNegCentGF(XS, YS);

          if GF.PixInterpol
            then ColInt := ColInterpolSL32Arr(GF.SLSrc, GF.WS, GF.HS, XS, YS)
            else ColInt := ColRangeSL32Arr   (GF.SLSrc, GF.WS, GF.HS, XS, YS);

          if (ColInt.C >= 253) and (ColInt.C <= 255) then // nearly pure blue used to mark out of range of Source
          begin    // transparent part
            LDst[x] := LOrg[x];
          end else
          begin
            if GF.MergeRatio < 0.9999
              then ColMrg := ColorMerged32(LOrg[x], ColInt, GF.MergeRatio)
              else ColMrg := ColInt;

            if Abs(GF.ContrastFact) > 0.0001 then
            begin
              ColMrg := ColorContrast32(ColMrg, GF.ContrastCenter, GF.ContrastFact);
            end;

            if (Mode=7) then
            begin
            //  dxy := sqrt(sqr(xs-x)+sqr(ys-y))/rad;
              dxy := ((xs-x)+(ys-y))/rad;

              Act_d[x] := dxy;
              //ColMrg := ColorBrighter(ColMrg, 1.0 + (180/Pi)*GF.PeriodPhaseY*dxy);
              if (x>0) and (y>0) then
              begin
                ddx := dxy - Act_d[x-1];
                ddy := dxy - Lst_d[x];
                ColMrg := ColorBrighter(ColMrg, 1.0 + (180/Pi)*GF.PeriodPhaseY* (ddx+ddy));
              end;
            end;


            if GF.ShowEdge then
              if (Dist2 >= Rad2ShowEdge) or (Dist2 <= Rad2ShowCenter) then
              begin
                if GF.Selected
                  then ColMrg := C32Green
                  else ColMrg := C32Gray;
              end;

            LDst[x] := ColMrg;     // set new color
            
            Case OrigMode of
               OM_Keep     : ;
               OM_Set      : LOrg[x] := ColInt;
               OM_SetInv   : LOrg[x] := Col32Invert(ColInt);
               OM_Merge    : LOrg[x] := ColMrg;
               OM_MergeInv : LOrg[x] := Col32Invert(ColMrg);
            end;
          end;

        end else // (Dist2 <= Rad2)
        begin    // (Dist2 >  Rad2)
               // part in Rect that is not restored
               // this is only necessary for points in LastRect
         if OrigMode <> OM_KeepBG then
           LDst[x] := LOrg[x];     // set original color
        end;     // (Dist2 >  Rad2)
  Next_X:
      end;  // for x
 Next_Y:
    end;  // for y

    BmpGlasses32_InvalidateRect(GF, RL,   Upd);
    BmpGlasses32_InvalidateRect(GF, GF.R, Upd);

    GF.Moving := False;
  except
    on E: exception do
    begin
      BmpGlasses32_Done(GF, False);
    end;
  end;
end;

procedure BmpGlasses32_Move(var GF: TGlassesFrame);
begin
  BmpGlasses32_Move(GF, GF.LastXC, GF.LastYC);
end;

procedure BmpGlasses32_Move(const GFs: TGlassesFrames);
var
  Len, I, y : Integer;
  R : TRect;
  LSrc, LDst : TSL;
  First : Boolean;
begin
  Len := Length(GFs);
  First := True;
  try
    for I := 0 to Len -1 do
    if GFs[I].Valid then
    begin
      if First then
      begin     // Orig to Dest at start of paint cycle:
        R := Rect(0, 0, GFs[I].BmpOrg.Width, GFs[I].BmpOrg.Height);
        for y := R.Top to R.Bottom -1 do         // GF.R: surrounding rectangle of last Move_Paint region
        begin
          LSrc := GFs[I].SLOrg[y];
          LDst := GFs[I].SLDst[y];
          Move(LSrc[R.Left], LDst[R.Left], SizeOf(TCol32)*(R.Right -  R.Left));
        end;
        First := False;
      end else
      begin // connected painting: Result of previous paintings in Dst (part of current GFs[I} drawing area) to Org
        R := GFs[I].R;
        for y := R.Top to R.Bottom -1 do         // GF.R: surrounding rectangle of last Move_Paint region
        begin
          LSrc := GFs[I].SLDst[y];
          LDst := GFs[I].SLOrg[y];
          Move(LSrc[R.Left], LDst[R.Left], SizeOf(TCol32)*(R.Right -  R.Left));
        end;
      end;

      BmpGlasses32_Move(GFs[I], GFs[I].LastXC, GFs[I].LastYC, OM_KeepBG, (I=Len-1));

    end;
  except
    on E: exception do
    begin
      for I := 0 to Len -1 do
        if GFs[I].Valid then
          BmpGlasses32_Done(GFs[I], False);
    end;
  end;
end;

procedure BmpMove(BmpSrc, BmpDst: TBitmap; const GFs: TGlassesFrames);
// Test
var
  DeltaTime, TimeFactorX, TimeFactorY, Tdx, Tdy, Tfx, Tfy : Double;

  procedure InitTimes(GF: TGlassesFrame);
  begin
    DeltaTime  := ((Now - GF.TimeStart) * 24 * 3600);
    if Abs(GF.PeriodTimeX) > 0.001
      then TimeFactorX := Sin((2 * Pi * DeltaTime / GF.PeriodTimeX)+GF.PeriodPhaseX)
      else TimeFactorX := 1;
    if Abs(GF.PeriodTimeY) > 0.001
      then TimeFactorY := Sin((2 * Pi * DeltaTime / GF.PeriodTimeY))
      else TimeFactorY := 1;
    Tdx := TimeFactorX * 15;
    Tdy := TimeFactorY * 15;
    Tfx := 2 + TimeFactorX;
    Tfy := 2 + TimeFactorY;
  end;

  procedure TransForm(T: Integer; var XS, YS : Double);
  var
    R, dx, dy : Double;
  begin
    dx := XS - GFs[T].LastXC;
    dy := YS - GFs[T].LastYC;
    R := sqrt(dx * dx + dy * dy);
    if R >  0.5 * GFs[T].Width then
    begin
    end else
    begin
      XS := Tfx * XS + Tdx;
      YS := Tfy * YS + Tdy;
    end;
  end;
var
  LenT, T, WS, HS, WD, HD, x, y : Integer;
  SLSrc, SLDst : TSL32Arr;
  LDst : TSL;
  XS, YS : Double;
  ColInt : TCol32;

begin
  LenT := Length(GFs);
  if LenT = 0 then EXIT;
  
  BmpWH(BmpSrc, WS, HS);
  BmpWH(BmpDst, WD, HD);
  SLSrc := BmpSL32Arr(BmpSrc);
  SLDst := BmpSL32Arr(BmpDst);

  InitTimes(GFs[0]);

  for y := 0 to HD -1 do
  begin
    LDst := SLDst[y];
    for x := 0 to WD -1 do
    begin
      XS := x;
      YS := y;
      for T := 0 to LenT -1 do
      begin
        TransForm(T, XS, YS);
      end;
      if GFs[0].PixInterpol
        then ColInt := ColInterpolSL32Arr(SLSrc, WS, HS, XS, YS)
        else ColInt := ColRangeSL32Arr   (SLSrc, WS, HS, XS, YS);
      LDst[x] := ColInt;
    end;
  end;

end;

procedure BmpGlasses32_ToOrg(var GF: TGlassesFrame; OrigMode: TOrigMode);
var
  ScreenOnlySav : Boolean;
begin
  If GF.Valid then
  begin
    ScreenOnlySav := GF.ScreenOnly;
    GF.ScreenOnly := False;
      BmpGlasses32_Move(GF, GF.LastXC, GF.LastYC, OrigMode);
    GF.ScreenOnly := ScreenOnlySav;
  end;
end;

procedure BmpGlassesDemo32(Pic: TPicture; Rad0, Rad1, dRad: Double);
var
  Tim: TDosTimer;
  BmpOrg, BmpRot : TBitmap;
  LA, LB : TSL;
  SLA, SLB : TSL32Arr;
  W, H, x, y       : Integer;
  R, R2,
  Rad, XC, YC, dx, dy, Dist2, fx, fy,
  XS, YS : Double;
begin
  StartDosTimer(Tim);

  BmpRot := Pic.Bitmap;
  BmpWH(BmpRot,W,H);
  BmpOrg := TBitmap.Create;
  BmpOrg.Assign(BmpRot);

  SLA := BmpSL32Arr(BmpOrg);
  SLB := BmpSL32Arr(BmpRot);
  R  := Min(0.3 * W, 150);
  R2 := Sqr(R);
  Rad := Rad0;
  While Rad <= Rad1 do
  begin
    XC := Mouse_CursorPos.X;
    YC := Mouse_CursorPos.Y;
//    XC := Round(0.9*Rad) mod W;
//    YC := Round(1.3*Rad) mod H;
    for y := 0 to H -1 do
    begin
      LA := SLA[y];
      LB := SLB[y];
      for x := 0 to W -1 do
      begin
        dx := XC - X;
        dy := YC - Y;
        if (abs(dx) <= 1.2*R) and (abs(dy) <= 1.2*R) then
        begin
          Dist2 := dx*dx + dy*dy;
          if Dist2 <= R2 then
          begin
            fx := 0.5 * sqrt((R2 - Dist2) / R2);
            fy := 2.0 * fx;
            XS := X + fx * dx;
            YS := Y + fy * dy;
            SlB[y,x] := ColInterpolSL32Arr(SLA, W, H, XS, YS);
          end else
          begin
//          SlB[y,x] := SLA[y, x];
            LB[x] := LA[x];
          end;
        end else
        begin
//        SlB[y,x] := SLA[y, x];
          LB[x] := LA[x];
        end;
      end;
    end;
    BmpRot.Modified := True;
    BmpRot.Canvas.Refresh;
    Application.ProcessMessages;
    Rad := Rad + dRad;
  end;
  FreeAndNil(BmpOrg);
  ShowMessageFmt('Time: %4.1f [s]', [ReadDosTimer(Tim)]);
end;

function BmpKeyStoneZoomRotated(Bmp: TBitmap; KeyStone, ZoomFact, Rot: Double): TBitmap;
var
  SLA, SLB : TSL32Arr;
  W, H, WZ, HZ, x, y : Integer;
  CosR, SinR,
  XS, YS, dCX, dCY : Double;
  function ZXD(XD: Double; y: Integer): Double;
  var
    XF, YR : Double;
  begin
    YR := y / HZ;

    // hyperbel:
    XF := 1.0 + KeyStone * YR ;
{   // trapez:
    if KeyStone > 0 then
    begin
      XF := 1 - KeyStone * (1 - YR);
      XF := 1 / XF;
    end else
    begin
      XF := 1 + KeyStone * YR;
      XF := 1 / XF;
    end;
 }
    Result := XD * XF -  (XF -1) * 0.5 *WZ;
  end;
begin
  BmpWH(Bmp,W,H);
  WZ := Round(ZoomFact * W);
  HZ := Round(ZoomFact * H);

  Result := BmpCreate32(W, H);

  SLA := BmpSL32Arr(Bmp);
  SLB := BmpSL32Arr(Result);

  CosR := Cos(Rot);
  SinR := Sin(Rot);

  dCX := 0.5*(W * CosR - H * SinR - W);
  dCY := 0.5*(W * SinR + H * CosR - H);

  ZoomFact := 1 / ZoomFact;
  for x := 0 to WZ -1 do
    for y := 0 to HZ -1 do
    begin
      XS := ZoomFact * (x * CosR - y * SinR) - dCX;
        XS := ZXD(XS, y);
      YS := ZoomFact * (x * SinR + y * CosR) - dCY;
      SlB[y,x] := ColInterpolSL32Arr(SLA, W, H, XS, YS);
    end;
  Result.Modified := True;
end;

function BmpSizeMultDiv(Bmp: TBitmap; fMult, fDiv: Integer): TBitmap;
var
  SLA : TSL32Arr;
  SLR : TSL32Arr;
  W, H, WZ, HZ     : Integer;
  x, x0, x1, y, y0, y1 : Integer;
begin
  BmpWH(Bmp,W,H);

  WZ := ((W * fMult) div fDiv) -1;
  HZ := ((H * fMult) div fDiv) -1;

  Result := BmpCreate32(WZ, HZ);
  SLA := BmpSL32Arr(Bmp);
  SLR := BmpSL32Arr(Result);  // sets Result.pixelformat to pf32bit

  for y := 0 to HZ -1 do
  begin
    y0 := ( y    * fDiv) div fMult;
    y1 := ((y+1) * fDiv) div fMult;
    for x := 0 to WZ -1 do
    begin
      x0 := ( x    * fDiv) div fMult;
      x1 := ((x+1) * fDiv) div fMult;
      SLR[y][x] := MeanColor(SLA[y0][x0],SLA[y0][x1], SLA[y1][x0], SLA[y1][x1]);
    end;
  end;
end;

function BmpZoomed(Bmp: TBitmap; ZoomFact: Double): TBitmap;
var
  SLA : TSL32Arr;
  SLB : TSL32Arr;
  W, H, WZ, HZ, x, y, x0, x1, y0, y1: Integer;
  XS, YS  : Double;
begin
  BmpWH(Bmp,W,H);
  WZ := Round(ZoomFact * W);
  HZ := Round(ZoomFact * H);

  // prepare for use with ColInterPolSL32Arr_noCheck:
  While Trunc((WZ-1) / ZoomFact)>=W-1 do
    dec(WZ);
  While Trunc((HZ-1) / ZoomFact)>=H-1 do
    dec(HZ);
  x0 := 0;
  y0 := 0;
  x1 := WZ -1;
  y1 := HZ -1;


  Result := BmpCreate32(WZ, HZ);

  SLA := BmpSL32Arr(Bmp);
  SLB := BmpSL32Arr(Result);  // sets Result.pixelformat to pf32bit

  ZoomFact := 1 / ZoomFact;
  for y := y0 to y1 do
//if (y div 8) mod 2 = 0 then
  begin
    YS := ZoomFact * y;
    for x := x0 to x1 do
    begin
      XS := ZoomFact * x;
//    SlB[y, x] := ColInterpolSL32Arr        (SLA, W, H, XS, YS);
      SlB[y, x] := ColInterpolSL32Arr_noCheck(SLA,       XS, YS);
//    SlB[y, x] := SLA[Trunc(YS), Trunc(XS)];
    end;
  end;
  Result.Modified := True;
end;

procedure BmpMergeRect(Bmp: TBitmap; Color: TCol32; MergeRatio: Double; R: TRectS);
// input  :
//         Bmp
//         R: Rect in coordinates of Bmp
// output :
//         Bmp merged with Color
var
  SLA   : TSL32Arr;
  W, H, x, y, x0, x1, y0, y1 : Integer;
begin

  BmpWH(Bmp,W,H);

  x0 := Max(R.L,     0);
  y0 := Max(R.T,     0);
  x1 := Min(R.R -1, W -1);
  y1 := Min(R.B -1, H -1);


  SLA := BmpSL32Arr(Bmp);

  for y := y0 to y1 do
  begin
    for x := x0 to x1 do
    begin
//if ((x+y) div 64) mod 2 = 0 then     // mixed drawing in diagonal stripes to check alignment // Debug
      begin
        SLA[y, x] := ColorMerged32(SLA[y,x], Color, MergeRatio);
      end;
    end;
  end;
  Bmp.Modified := True;
end;

procedure InvalidateSaveRec(var SaveRec: TSaveBmpRec);          // ! Future: belongs to caller of BmpZoomRect
begin
  FreeAndNil(SaveRec.Bmp);
end;

function CheckUseSaveRec(ZoomFactX, ZoomFactY: Double; R: TRect; SaveRec: TSaveBmpRec): Boolean;
// R: Left, Top, Right=Width, Bottom=Height!
var
  R0, RS, CR : TRect;
begin
  Result := Assigned(SaveRec.Bmp)
            and (SaveRec.ZoomFactX = ZoomFactX)
            and (SaveRec.ZoomFactY = ZoomFactY);
  if Result then
  begin
    Result := EqualRect(SaveRec.R, R);
    if not Result then
    begin
      R0 := R;
      R0 := Rect(R0.Left, R0.Top, R0.Left+R0.Right, R0.Top+R0.Bottom);
      RS := SaveRec.R;
      RS := Rect(RS.Left, RS.Top, RS.Left+RS.Right, RS.Top+RS.Bottom);
      CR := CommonRect(R0, RS);
      Result := EqualRect(RS, CR);
    end;
  end;
end;

function BmpZoomRect(Bmp, BmpZ: TBitmap; ZoomFactX, ZoomFactY:  Double;
               R: TRectS;
               var SR:TSaveBmpRec;
               GradScale_255: Integer;
               ClipLo, ClipHi: Integer;
               ColLo, ColHi : TCol32;
               Interpol: Boolean): Boolean;
// Returns True if Smooth is ready
//
// input  :
//         Bmp
//         BmpZ
//         R: Clip in coordinates of zoomed: Left, Top, Width, Height!
// output :
//         Bmp
//         BmpZ   enlarged with zoomed content of Bmp // Offset reduced
  function XtoXS(x: Integer): Double;
  // align centers to stretchdraw for numerical ZoomFactors: 1, 2, 3 ...
  begin
    Result := ((x + 0.5) / ZoomFactX)  - 0.5;
  end;
  function YtoYS(y: Integer): Double;
  // align centers to stretchdraw for numerical ZoomFactors: 1, 2, 3 ...
  begin
    Result := ((y + 0.5) / ZoomFactY)  - 0.5;
  end;
  function ColorClipped_RGB(C: TCol32): TCol32;
    function Clip(by: Byte): Byte;
    begin
      if by < ClipLo then Result := 0
      else
      if by > ClipHi then Result := 0
      else                Result := by;
    end;
  begin
    Result.S := 0;
    Result.R := Clip(C.R);
    Result.G := Clip(C.G);
    Result.B := Clip(C.B);
  end;
  function ColorClipped(C: TCol32): TCol32;
  // Gray
    function Clip(by: Byte): TCol32;
    var
      Mid : Byte;
    begin
      if ClipLo <= ClipHi then
      begin
        if by < ClipLo then Result := ColLo
        else
        if by > ClipHi then Result := ColHi
        else                Result := C;
      end else
      begin
        Mid := (ClipLo + ClipHi) div 2;
        // ClipHi <= Mid <= ClipLo : Show below Hi and above Lo unchanged
        if (by <= ClipHi) or (by >= ClipLo) then Result := C
        else
        if (by >  ClipHi) and (by < mid) then Result := ColHi
        else
          Result := ColLo;
      end;
    end;
  var
    H, S, V, ClipBy: Byte;
  begin
    ClipBy := 127;
    Case GlbClipMode of
      CM_None:
        begin
          Result := C;
          Exit;
        end;
      CM_Gray: ClipBy := GrayVal32(C);
      CM_Hue, CM_Sat, CM_V:
        begin
          RgbToHSV(C, H, S, V);
          Case GlbClipMode of
            CM_Hue: ClipBy := H;
            CM_Sat: ClipBy := S;
            CM_V:   ClipBy := V;
          end;
        end;
      CM_Red:     ClipBy := C.R;
      CM_Green:   ClipBy := C.G;
      CM_Blue:    ClipBy := C.B;
      CM_Cyan:    ClipBy := (Integer(C.G) + Integer(C.B)) div 2;
      CM_Magenta: ClipBy := (Integer(C.R) + Integer(C.B)) div 2;
      CM_Yellow:  ClipBy := (Integer(C.G) + Integer(C.R)) div 2;
    end;
    Result := Clip(ClipBy);
  end;

var
  SLA   : TSL32Arr;
  SLB   : TSL32Arr;
  W, H, WZ, HZ, x, y, x0, x1, y0, y1 : Integer;
  XS0, dXS,
  XS, YS : Double;
  xt, fx : Integer;
  yt, fy : Integer;
  RS : TRectS;
  UseSaveRec : Boolean;
begin
  Result := False;
  BmpWH(Bmp,W,H);
  WZ := Round(ZoomFactX * W);
  HZ := Round(ZoomFactY * H);

 UseSaveRec := CheckUseSaveRec(ZoomFactX, ZoomFactY, R.N, SR);  //new

  // prepare for use with ColInterPolSL32Arr_noCheck:  // not valid for alignment!

  if (not UseSaveRec) then
  begin // additional for Rolling      //not like this: because this invalidates SaveRec
//    Dec(R.L, 50);
//    Dec(R.T, 50);
//    Inc(R.R, 50);
//    Inc(R.B, 50);
  end;

  x0 := Max(R.L,     0);
  y0 := Max(R.T,     0);
  x1 := Min(R.L+R.W -1, WZ -1);
  y1 := Min(R.T+R.H -1, HZ -1);

  if Interpol then
  begin                            //   v--- +-1 additional for ColInterpolSL32Arr_noCheck_XY_2
    While (Round(XtoXS(x0)-0.5) <  0   +1) do Inc(x0);    // round(x-0.5) and trunc(x) not same for negative x!
    While (Round(YtoYS(y0)-0.5) <  0   +1) do Inc(y0);
    While (Round(XtoXS(x1)-0.5) >= W-1 -1) do Dec(x1);
    While (Round(YtoYS(y1)-0.5) >= H-1 -1) do Dec(y1);
  end;

  // zoomed output  unclipped:
//  BmpZ.Width  := max(W, BmpZ.Width);
//  BmpZ.Height := max(H, BmpZ.Height);

  // zoomed output  clipped:
  BmpZ.Width  := max(R.W, BmpZ.Width);
  BmpZ.Height := max(R.H, BmpZ.Height);

//  if CheckUseSaveRec(ZoomFactX, ZoomFactY, R.N, SR) then    // old
  if UseSaveRec then
  begin
    Result := True;
    RS.N := SR.R;
    BitBlt(   BmpZ.Canvas.Handle, X0 - R.L, Y0 - R.T, x1-x0 +1 ,y1-y0 +1,
           SR.Bmp .Canvas.Handle, X0 - RS.L, Y0 - RS.T,
           cmSrcCopy);
  end;


  SLA := BmpSL32Arr(Bmp);
  SLB := BmpSL32Arr(BmpZ);  // sets Result.pixelformat to pf32bit
  BmpZ.PixelFormat := pf32bit;
  dXS := 1/ZoomFactX;
  XS0 := XtoXS(x0);      // use of XD0 instead of XD improves performance!

  for y := y0 to y1 do
//if (y div 32) mod 2 = 0 then
  begin
    YS := YtoYS(y);
    yt := Round(YS -0.5);          // repeated in inner loop improves performance!
    fy := Round(256 * (YS - yt));

    XS  := XS0;
    for x := x0 to x1 do
    begin
      if Interpol then
//if ((x+y) div 64) mod 2 = 0 then     // mixed drawing in diagonal stripes to check alignment // Debug
      begin
        yt := Round(YS -0.5);        // repeated in inner loop improves performance!  // 1.54 sec

        xt := Round(XS -0.5);
        fx := Round(256 * (XS - xt));


//      SlB[y, x] := ColInterpolSL32Arr           (SLA, W, H, XS,     YS);  // fits centered to Stretchdraw // 2.09 sec
//      SlB[y, x] := ColInterpolSL32Arr_noCheck   (SLA,       XS,     YS);

//      SlB[y, x] := ColInterpolSL32Arr_noCheck_XY(SLA,       Xt, fx, Yt, fy);   // 1.54 sec

//if ((x+y) mod 128) <> 0 then
//case ((x+y) div 128) mod 3 of
case 0 of   // 0 until 18.03.07 P.W test 10
10:
        SlB[y-R.T, x-R.L] :=
          ColorClipped(
            ColInterpolSL32Arr(SLA, W, H, XS, YS));
0:
        SlB[y-R.T, x-R.L] :=
          ColorClipped(
            ColInterpolSL32Arr_noCheck_XY(SLA,       Xt, fx, Yt, fy));   // 1.54 sec
1:
        SlB[y-R.T, x-R.L] := ColInterpolSL32Arr_noCheck_XY_2(SLA,       Xt, fx, Yt, fy, False, GradScale_255);
2:
        SlB[y-R.T, x-R.L] := ColInterpolSL32Arr_noCheck_XY_2(SLA,       Xt, fx, Yt, fy, True,  GradScale_255);
3:
        SlB[y-R.T, x-R.L] := SLA[Round(YS), Round(XS)];  //  fits   // 0.82 sec
//end else
//case ((x+y) div 128) mod 3 of
//0: SlB[y-R.T, x-R.L] := C32Red;
//1: SlB[y-R.T, x-R.L] := C32Green;
//2: SlB[y-R.T, x-R.L] := C32Blue;
//3: SlB[y-R.T, x-R.L] := C32Yellow;
end;

//     SlB[y, x].C := (not SLB[y, x].C) and $00FFFFFF;
  //    SlB[y, x] := SLA[Yt, Xt];
//      SlB[y-R.T, x-R.L] := SLA[Round(YS), Round(XS)];  //  fits   // 0.82 sec

        // SlB[y, x].R := SlB[y, x].R div 2;  // mark the stripes
      end else
      begin
        SlB[y-R.T, x-R.L] := ColorClipped(SLA[Round(YS), Round(XS)]);  //  fits   // 0.82 sec
      end;
      XS := XS + dXS;
    end;
  end;
  BmpZ.Modified := True;

  if Interpol then
  begin
//BmpMedianCol32(BmpZ);
    Result := True;
    if not assigned(SR.Bmp) then
      SR.Bmp := TBitmap.create;
    SR.Bmp.Assign(BmpZ);
    SR.ZoomFactX := ZoomFactX;
    SR.ZoomFactY := ZoomFactY;
    SR.R := R.N;
  end;

end;

procedure BmpZoomRect_0(Bmp, BmpZ: TBitmap; ZoomFactX, ZoomFactY:  Double; R: TRectS);
// input  :
//         Bmp
//         BmpZ
// output :
//         Bmp
//         BmpZ   enlarged with zoomed content of Bmp
  function XtoXD(x: Integer): Double;
  // align centers to stretchdraw for numerical ZoomFactors: 1, 2, 3 ...
  begin
    Result := ((x + 0.5) / ZoomFactX)  - 0.5;
  end;
  function YtoYD(y: Integer): Double;
  // align centers to stretchdraw for numerical ZoomFactors: 1, 2, 3 ...
  begin
    Result := ((y + 0.5) / ZoomFactY)  - 0.5;
  end;
var
  SLA   : TSL32Arr;
  SLB   : TSL32Arr;
  W, H, WZ, HZ, x, y, x0, x1, y0, y1 : Integer;
  XD0, dXD,
  XD, YD : Double;
  xt, fx : Integer;
  yt, fy : Integer;
begin

  BmpWH(Bmp,W,H);
  WZ := Round(ZoomFactX * W);
  HZ := Round(ZoomFactY * H);

  // prepare for use with ColInterPolSL32Arr_noCheck:  // not valid for alignment!
  x0 := Max(R.L,     0);
  y0 := Max(R.T,     0);
  x1 := Min(R.L+R.W -1, WZ -1);
  y1 := Min(R.T+R.H -1, HZ -1);
  While (Round(XtoXD(x0)-0.5) <  0  ) do Inc(x0);    // round(x-0.5) and trunc(x) not same for negative x!
  While (Round(YtoYD(y0)-0.5) <  0  ) do Inc(y0);
  While (Round(XtoXD(x1)-0.5) >= W-1) do Dec(x1);
  While (Round(YtoYD(y1)-0.5) >= H-1) do Dec(y1);

  BmpZ.Width  := max(WZ, BmpZ.Width);
  BmpZ.Height := max(HZ, BmpZ.Height);

  SLA := BmpSL32Arr(Bmp);
  SLB := BmpSL32Arr(BmpZ);  // sets Result.pixelformat to pf32bit
  BmpZ.PixelFormat := pf32bit;
  dXD := 1/ZoomFactX;
  XD0 := XtoXD(x0);      // use of XD0 instead of XD improves performance!

  for y := y0 to y1 do
//if (y div 32) mod 2 = 0 then
  begin
    YD := YtoYD(y);
    yt := Round(YD -0.5);          // repeated in inner loop improves performance!
    fy := Round(256 * (YD - yt));

    XD  := XD0;
    for x := x0 to x1 do
    begin
//if ((x+y) div 64) mod 2 = 0 then     // mixed drawing in diagonal stripes to check alignment // Debug
      begin
        yt := Round(YD -0.5);        // repeated in inner loop improves performance!  // 1.54 sec

        xt := Round(XD -0.5);
        fx := Round(256 * (XD - xt));


//      SlB[y, x] := ColInterpolSL32Arr           (SLA, W, H, XD,     YD);  // fits centered to Stretchdraw // 2.09 sec
//      SlB[y, x] := ColInterpolSL32Arr_noCheck   (SLA,       XD,     YD);
        SlB[y, x] := ColInterpolSL32Arr_noCheck_XY(SLA,       Xt, fx, Yt, fy);   // 1.54 sec
//     SlB[y, x].C := (not SLB[y, x].C) and $00FFFFFF;
  //    SlB[y, x] := SLA[Yt, Xt];
//      SlB[y, x] := SLA[Round(YD), Round(XD)];  //  fits   // 0.82 sec

        // SlB[y, x].R := SlB[y, x].R div 2;  // mark the stripes
      end;
      XD := XD + dXD;
    end;
  end;
  BmpZ.Modified := True;
end;

procedure BmpZoomContinue_0(Bmp, BmpZ: TBitmap; ZoomFactX, ZoomFactY:  Double);
  function XtoXD(x: Integer): Double;
  // align centers to stretchdraw for numerical ZoomFactors: 1, 2, 3 ...
  begin
    Result := ((x + 0.5) / ZoomFactX)  - 0.5;
  end;
  function YtoYD(y: Integer): Double;
  // align centers to stretchdraw for numerical ZoomFactors: 1, 2, 3 ...
  begin
    Result := ((y + 0.5) / ZoomFactY)  - 0.5;
  end;
var
  SLA : TSL32Arr;
  SLB : TSL32Arr;
  W, H, WZ, HZ, x, y, x0, x1, y0, y1 : Integer;
  XD0, dXD,
  XD, YD : Double;
  xt, fx : Integer;
  yt, fy : Integer;
  Tmr: TDosTimer;
begin
  StartDosTimer(Tmr);

  BmpWH(Bmp,W,H);
  WZ := Round(ZoomFactX * W);
  HZ := Round(ZoomFactY * H);

  // prepare for use with ColInterPolSL32Arr_noCheck:  // not valid for alignment!
  x0 := 0;
  While (Round(XtoXD(x0)-0.5) <  0  ) do Inc(x0);    // round(x-0.5) and trunc(x) not same for negative x!
  y0 := 0;
  While (Round(YtoYD(y0)-0.5) <  0  ) do Inc(y0);
  x1 := WZ -1;
  While (Round(XtoXD(x1)-0.5) >= W-1) do Dec(x1);
  y1 := HZ -1;
  While (Round(YtoYD(y1)-0.5) >= H-1) do Dec(y1);

  BmpZ.Width  := max(WZ, BmpZ.Width);
  BmpZ.Height := max(HZ, BmpZ.Height);

  SLA := BmpSL32Arr(Bmp);
  SLB := BmpSL32Arr(BmpZ);  // sets Result.pixelformat to pf32bit

  for y := y0 to y1 do
//if (y div 32) mod 2 = 0 then
  begin
    YD := YtoYD(y);
    yt := Round(YD -0.5);          // repeated in inner loop improves performance!
    fy := Round(256 * (YD - yt));

    XD0 := XtoXD(x0);      // use of XD0 instead of XD improves performance!
    dXD := 1/ZoomFactX;
    XD  := XD0;
    for x := x0 to x1 do
    begin
//if ((x+y) div 64) mod 2 = 0 then     // mixed drawing in diagonal stripes to check alignment // Debug
      begin
        yt := Round(YD -0.5);        // repeated in inner loop improves performance!  // 1.54 sec

        xt := Round(XD -0.5);
        fx := Round(256 * (XD - xt));


//      SlB[y, x] := ColInterpolSL32Arr           (SLA, W, H, XD,     YD);  // fits centered to Stretchdraw // 2.09 sec
//      SlB[y, x] := ColInterpolSL32Arr_noCheck   (SLA,       XD,     YD);
        SlB[y, x] := ColInterpolSL32Arr_noCheck_XY(SLA,       Xt, fx, Yt, fy);   // 1.54 sec

//      SlB[y, x] := SLA[Round(YD), Round(XD)];  //  fits   // 0.82 sec

        // SlB[y, x].R := SlB[y, x].R div 2;  // mark the stripes
      end;
      XD := XD + dXD;
    end;
  end;
  BmpZ.Modified := True;
  ShowMessageFmt('Sec.: %3.2f', [ReadDosTimer(Tmr)]);
end;

function BmpDistorted(Bmp: TBitmap): TBitmap;
var
  SLA, SLB : TSL32Arr;
  W, H, x, y : Integer;
  XD, YD : Double;
begin
  BmpWH(Bmp,W,H);

  Result := BmpCreate32(W, H);

  SLA := BmpSL32Arr(Bmp);
  SLB := BmpSL32Arr(Result);


  for x := 0 to W -1 do
  begin
    XD := x*x / W;
    XD := sqrt(x) * sqrt(W);
    for y := 0 to H -1 do
    begin
      YD := y*y / H;
      YD := Y;
      SlB[y,x] := ColInterpolSL32Arr(SLA, W, H, XD, YD);
    end;
  end;
  Result.Modified := True;
end;

var
  frm : TForm;
  pbx : TImage;
procedure ShowBmp(Bmp: TBitmap; Msg:AnsiString='');
begin
  if not assigned(frm) then
  begin
    frm := TForm.Create(nil);
    frm.Parent := nil;
    frm.Width  := 800;
    frm.Height := 600;
    pbx := TImage.Create(frm);
    pbx.Parent := frm;
    pbx.AutoSize := True;
    pbx.Align:= alNone;
    pbx.Top  := 0;
    pbx.Left := 0;
  end;
  frm.Caption := Msg;
  pbx.Picture.Assign(Bmp);
  frm.ShowModal;
  //FreeAndNil(frm);
end;

function MergeBmpParts(BmpA, BmpB: TBitmap): TBitmap;
var
  SLarrA, SLarrB, SLarrC : TSL32Arr;

  function Part_AB(x, y: Integer): TCol32;
  // ImgA
  //         dy0
  //
  //   dx0    +-------+                 +-------+      ---
  //          |dxs dys|       **        |       |
  //          +-------+  *******        +-------+          dy
  //                **********
  //            *******    +-------+                   ---
  //           ***         |       |
  //                       +-------+
  //
  //          +-------+                 +-------+
  //          |       |                 |       |
  //          +-------+                 +-------+
  //
  //          |            |
  //          |     dx     |
  //
  // ImgB as ImgA with additional Offset: dxAB (offset to image "***" not pattern "+-+"!)
  //         dy0
  //
  //   dx0    +-------+                 +-------+      ---
  //          |dxs dys|                 |   **  |
  //          +-------+                *******--+          dy
  //                              ***********
  //                       +--*******                  ---
  //                       | ****  |
  //                       +-------+
  //
  //          +-------+                 +-------+
  //          |       |                 |       |
  //          +-------+                 +-------+
  //
  //          |            |
  //          |     dx     |
  //
  //
  const
//  dx0  =   34;
//  dy0  =   39;
    dx0  =   22;
    dy0  =  223;
    dxs  =  171;
    sys  =   73;
    dx   =  224;
    dy   =  256;
    dxAB = 56*4;
  var
    UseA : Boolean;
    BandX, BandY : Integer;
  begin
    BandX := (x + dx - dx0) div dx;
    BandY := (y + dy - dy0) div dy;
    if odd(BandY)
      then UseA := not odd(BandX)
      else UseA :=     odd(BandX);
    if UseA then Result := SLarrA[y, x]
            else Result := SLarrB[y, x+dxAB];
  end;
var
  WA, HA, WB, HB, W, H, x, y : Integer;
begin
  BmpWH(BmpA, WA, HA);
  BmpWH(BmpB, WB, HB);
  W := Min(WA, WB);
  H := Min(HA, HB);

  Result := BmpCreate32(W, H);

  SLArrA := BmpSL32Arr(BmpA);
  SLArrB := BmpSL32Arr(BmpB);
  SLArrC := BmpSL32Arr(Result);

  for y := 0 to H -1 do
    for x := 0 to W -1 do
      SLArrC[y, x] := Part_AB(x,y);
  Result.Modified := True;
end;

procedure MergeImagePartsJpgc(NameInA, NameInB, NameOut: String);
  function LoadAsBmp32(aName: String): TBitmap;
  var
    Pic : TPicture;
  begin
    Pic := TPicture.Create;
    Pic.LoadFromFile(aName);
    PictureToBmp(Pic);
    Pic.Bitmap.PixelFormat := pf32bit;
    Result := TBitmap.Create;
    Result.Assign(Pic.Bitmap);
    FreeAndNil(Pic);
  end;

  procedure SaveBmpAsJpgC(Bmp: TBitmap; aName: String);
  var
    graphic : TJPEGImageC;
  begin
    graphic := TJPEGImageC.Create;
    graphic.Assign(Bmp);
    graphic.SaveToFile(aName);
    FreeAndNil(graphic);
  end;
var
  BmpA, BmpB, BmpC : TBitmap;
begin
  BmpA := LoadAsBmp32(NameInA);
  BmpB := LoadAsBmp32(NameInB);
  BmpC := MergeBmpParts(BmpA, BmpB);
  FreeAndNil(BmpA);
  FreeAndNil(BmpB);
  SaveBmpAsJpgC(BmpC, NameOut);

  FreeAndNil(BmpC);
end;



{ TSearchMap }

{ TSearchMap }

function MapTreeToBmp_Lined(const MapTree: TMapTree): TBitmap;
const
  frx = 2;
  fry = 2;
var
  W, H, MapCount, I, X, Y : Integer;
  Bmp : TBitmap;
begin
  MapCount := Length(MapTree);
  ArrWH(MapTree[0], W, H);
  Result := BmpCreate32(W*2 + frx*(MapCount+1), H+ 2* fry, clWhite);  // one line
  X := frx;
  Y := fry;
  for I := 0 to MapCount -1 do
  begin
    Bmp := ProfilesToBmp(MapTree[I]);
    Result.Canvas.Draw(X, Y, Bmp);
    Inc(X, frx + Bmp.Width);
    FreeAndNil(Bmp);
  end;
end;

function MapTreeToBmp_Packed(const MapTree: TMapTree): TBitmap;
const
  frx = 2;
  fry = 2;
var
  W, H, MapCount, I, X, Y : Integer;
  Bmp : TBitmap;
begin
  MapCount := Length(MapTree);
  ArrWH(MapTree[0], W, H);
  Result := BmpCreate32((3*W) div 2 + 3 * frx, H+ 2* fry, clWhite);    // two by two
  X := frx;
  Y := fry;
  for I := 0 to MapCount -1 do
  begin
    Bmp := ProfilesToBmp(MapTree[I]);
    Result.Canvas.Draw(X, Y, Bmp);
    if Odd(I) then
    begin  // I =   1, 3, 5, ...
      Inc(Y, fry + Bmp.Height);
    end else
    begin  // I = 0, 2, 4, ...
      Inc(X, frx + Bmp.Width);
    end;

    FreeAndNil(Bmp);
  end;
end;

function SubMap(const Map: TMap): TMap;
  function FilterMean(x, y: Integer): Integer;
  begin
    Result :=        (Map[y,x]+ Map[y,x+1]+      Map[y+1,x]+ Map[y+1,x+1]) div 4;
  end;
  function FilterMax(x, y: Integer): Integer;
  begin
    Result := Max(Max(Map[y,x], Map[y,x+1]), Max(Map[y+1,x], Map[y+1,x+1]));
  end;
  function FilterMin(x, y: Integer): Integer;
  begin
    Result := Min(Min(Map[y,x], Map[y,x+1]), Min(Map[y+1,x], Map[y+1,x+1]));
  end;
var
  W, H, WS, HS, x, y : Integer;
begin
  ArrWH(Map, W, H);
  WS := Max(1, W div 2);
  HS := Max(1, H div 2);
  SetLength(Result, HS, WS);
  for y := 0 to HS -1 do
    for x := 0 to WS -1 do
      Result[y, x] := FilterMax(2*x, 2*y);
end;

constructor TSearchMap.Create(Bmp: TBitMap);
var
  W, H, MapCount,I : Integer;
begin
  BmpWH(Bmp, W, H);
  MapCount := Trunc(ln(Min(W, H)) / ln(2));
  SetLength(MapTree, MapCount);
  MapTree[0] := BmpToProfiles(Bmp);
  for I := 1 to MapCount - 1 do
    MapTree[I] := SubMap(MapTree[I-1]);
end;

destructor TSearchMap.Destroy;
begin

  inherited;
end;

function TSearchMap.GetMapCount: Integer;
begin
  Result := Length(MapTree);
end;

function TSearchMap.MapTreeBmp: TBitmap;
begin
  Result := MapTreeToBmp_Packed(MapTree);
end;

procedure TSearchMap.SetMapCount(const Value: Integer);
begin

end;

procedure Test2;
var
  Pic : TPicture;
begin
  Pic := TPicture.Create;
  Pic.LoadFromFile('C:\Temp\Film Eagle\Pic00000.JPGC');
//  Pic.LoadFromFile('C:\Temp\Pic00000.Bmp');
  PictureToBmp(Pic);
  Pic.SaveToFile  ('C:\Temp\Pic00000.Bmp');
  H_alt(1);
end;

procedure TestCreateFilter;
const
 fName = 'C:\Temp\TestCreateFilter7x7.txt';
var
  Filter : TDoubArrArr;
  SL : TStringList;
begin
  Filter := CalcGaussFilterASymDoub(7, 7, 0.5, 0.5, 0 * Pi/180, 4.0);
  SL := DoubArrArrToStringList(Filter,'','%.3f,');
  SL.SaveToFile(fName);
  SL.Free;
  ShowMessage('Filter stored in '+ fName);
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  UpdMsg := '';
  GlbClipModeL2 := CM_V;
  GlbClipModeL1 := CM_Sat;
  GlbClipModeL0 := CM_Hue;
  GlbClipMode   := CM_Gray;
  ClipModeMsg[CM_None]   := 'CM_None';
  ClipModeMsg[CM_Gray]   := 'CM_Gray';
  ClipModeMsg[CM_Hue]    := 'CM_Hue';
  ClipModeMsg[CM_Sat]    := 'CM_Sat';
  ClipModeMsg[CM_V]      := 'CM_V';
  ClipModeMsg[CM_Red]    := 'CM_Red';
  ClipModeMsg[CM_Green]  := 'CM_Green';
  ClipModeMsg[CM_Blue]   := 'CM_Blue';
  ClipModeMsg[CM_Cyan]   := 'CM_Cyan';
  ClipModeMsg[CM_Magenta]:= 'CM_Magenta';
  ClipModeMsg[CM_Yellow] := 'CM_Yellow';
  ClipModeMsg[CM_None]   := 'CM_None';

//ZoomInfoId    : TZoomInfo = (dx: 0.0; dy: 0; ZFx: 1.0; ZFy: 1.0);
  ZoomInfoId.dx:= 0.0;
  ZoomInfoId.dy:= 0;
  ZoomInfoId.ZFx:= 1.0;
  ZoomInfoId.ZFy:= 1.0;
//ZoomInfoDiv2  : TZoomInfo = (dx: 0.0; dy: 0; ZFx: 0.5; ZFy: 0.5);
  ZoomInfoDiv2.dx:= 0.0;
  ZoomInfoDiv2.dy:= 0;
  ZoomInfoDiv2.ZFx:= 0.5;
  ZoomInfoDiv2.ZFy:= 0.5;

 //ZoomInfoMult2 : TZoomInfo = (dx: 0.0; dy: 0; ZFx: 2.0; ZFy: 2.0);
  ZoomInfoMult2.dx:= 0.0;
  ZoomInfoMult2.dy:= 0;
  ZoomInfoMult2.ZFx:= 2.0;
  ZoomInfoMult2.ZFy:= 2.0;

  DebugRot := 0.0;
  fBmpFree := nil;


// Line 4279 - 4303:
{
  NbdXdY : tNbDxDy =
    ((x: 0;y: 0),
     (x:-1;y:-1),
     (x: 0;y:-1),
     (x:+1;y:-1),
     (x:+1;y: 0),
     (x:+1;y:+1),
     (x: 0;y:+1),
     (x:-1;y:+1),
     (x:-1;y: 0));
}
{
  NbDxDyNexIdxArr : Array [-1 .. NbCount -1, 0 .. NbCount -1] of Byte =
      //0, 1, 2, 3, 4, 5, 6, 7
      ((1, 1, 1, 1, 1, 1, 1, 1),   // NbPre = -1 (start point)  (points 0 .. 7)
       (1, 1, 1, 0, 0, 0, 1, 1),   // NbPre =  0
       (1, 1, 1, 0, 0, 0, 0, 0),   // NbPre =  1
       (1, 1, 1, 1, 1, 0, 0, 0),   // NbPre =  2
       (0, 0, 1, 1, 1, 0, 0, 0),   // NbPre =  3
       (0, 0, 1, 1, 1, 1, 1, 0),   // NbPre =  4                (points 2 .. 6)
       (0, 0, 0, 0, 1, 1, 1, 0),   // NbPre =  5
       (1, 0, 0, 0, 1, 1, 1, 1),   // NbPre =  6
       (1, 0, 0, 0, 0, 0, 1, 1));  // NbPre =  7
}

  FillChar(NbPatternConnector, SizeOf(NbPatternConnector), #0);
  FillChar(GetFxy, SizeOf(GetFxy), #0);
  UpdTime := 0;
  UpdCtr  := 0;
  frm := nil;
  pbx := nil;

//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
//TestCreateFilter;

  SetFxyArr(GetFxy);
//   Test2;

//  Test;
{
CountBitGrps(  0);
CountBitGrps(  1);
CountBitGrps(  3);
CountBitGrps(  7);
CountBitGrps(170);
CountBitGrps(255);
}

  NbPatternConnector := NBPCfromGrpArr(GrpArr);
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
//TestCreateFilter;

  SetFxyArr(GetFxy);
//   Test2;

//  Test;
{
CountBitGrps(  0);
CountBitGrps(  1);
CountBitGrps(  3);
CountBitGrps(  7);
CountBitGrps(170);
CountBitGrps(255);
}

  NbPatternConnector := NBPCfromGrpArr(GrpArr);
   -^--- moved to function Unit_Init // 03.05.24 P.W *)

{
SymmmetrieCheckNbPatternConnector(NbPatternConnector);
WriteDiffPatterns(NbPatternConnector);
  Halt(1);
{}


(*************
function InitMergeRec(const fName: String): PMergeRec;
var
  DC: HDC;
  Pic : TPicture;
begin
  GetMem(Result, SizeOf(Result^));
  FillChar(Result^, SizeOf(Result^), #0);
  Result.MergeRatio := 1.0;

  Pic := TPicture.Create;
  Pic.LoadFromFile(fName);
  Result.W :=  Pic.Width;
  Result.H :=  Pic.Height;
//Result.FS := 600 / Max(W,H);
Result.FS := 2.0 * sqrt(300*400 / (Result.W*Result.H));
//Result.FS := 50 / Max(W,H);
  Result.W := Round(Result.FS * Result.W);
  Result.H := Round(Result.FS * Result.H);

  Result.BmpImg := TBitMap.Create;
  Result.BmpImg.PixelFormat := pf24bit;
  Result.BmpImg.Width  := Result.W;
  Result.BmpImg.Height := Result.H;
  Result.BmpImg.Canvas.StretchDraw(Rect(0,0,Result.W,Result.H), Pic.Graphic);
  Pic.Free;

  Result.BmpSav := TBitMap.Create;
  Result.BmpSav.PixelFormat := pf24bit;
  Result.BmpSav.Width  := Result.W;
  Result.BmpSav.Height := Result.H;

  Result.BmpMrg := TBitMap.Create;
  Result.BmpMrg.PixelFormat := pf24bit;
  Result.BmpMrg.Width  := Result.W;
  Result.BmpMrg.Height := Result.H;

  DC  := GetDC(0);
    Result.XDC := -Result.W-20;
    Result.YDC := (Screen.Height - Result.H) div 2;
//    Result.XDC := Mouse_CursorPos.X - (Result.W div 1);
//    Result.YDC := Mouse_CursorPos.Y - (Result.H div 1);
    BitBlt(Result.BmpSav.Canvas.Handle,   0,   0, Result.W, Result.H, DC                  , Result.XDC, Result.YDC, cmSrcCopy);
  ReleaseDC(0, DC);
end;

procedure TfrmBackup.BackImage(const fName: String);
var
  DC: HDC;
begin
  if not FileExists(fName) then EXIT;
  if not Assigned(GlbMrgRec) then
  begin
    GlbMrgRec := InitMergeRec(fName);
    GlbMrgRec.MergeRatio:= 0.005;
    GlbMrgRec.MrgFact := 1.02;
    GlbMrgRec.MrgRatioUpLim := 0.02;
    GlbMrgRec.MrgFactStep := 0.01;
  end;

  GlbMrgRec.MergeRatio := Min(1.0, GlbMrgRec.MrgFact * GlbMrgRec.MergeRatio);
  if GlbMrgRec.MergeRatio >= GlbMrgRec.MrgRatioUpLim then
  begin
    GlbMrgRec.MrgRatioUpLim := Min(0.999, GlbMrgRec.MrgRatioUpLim + 0.1);
    if GlbMrgRec.MrgRatioUpLim > 0.3 then
    begin
      GlbMrgRec.MrgRatioUpLim := 0.05;
      GlbMrgRec.MrgFactStep := 0.03;
    end;

    GlbMrgRec.MrgFact := 1 - 2*GlbMrgRec.MrgFactStep;
  end  else
  if GlbMrgRec.MergeRatio < 0.01 then
    GlbMrgRec.MrgFact := 1 + GlbMrgRec.MrgFactStep;
    
  UpdateStatus;  

  BmpMergeColorsProc(GlbMrgRec.BmpMrg, GlbMrgRec.BmpImg, GlbMrgRec.BmpSav, (1-GlbMrgRec.MergeRatio), 1, 230);
//  GlbMrgRec.MergeRatio := 0.9985 * GlbMrgRec.MergeRatio;
//    BmpMergeColorsToBmpA(Bmp, BmpSav, 0.99, 1);
//  GlbMrgRec.BmpMrg.Canvas.TextOut(0,GlbMrgRec.BmpMrg.Height-20, Format('MR:%5.3f', [GlbMrgRec.MergeRatio]));
  DC  := GetDC(0);
  With GlbMrgRec^ do
    BitBlt(DC                  , XDC, YDC, W, H, BmpMrg   .Canvas.Handle,   0, 0, cmSrcCopy);
//    sleep(30);
//    BitBlt(DC                  , XDC, YDC, W, H, BmpSav.Canvas.Handle,   0, 0, cmSrcCopy);
  ReleaseDC(0, DC);
//  Bmp   .Free;
//  BmpSav.Free;

end;

procedure TfrmBackup.Timer1Timer(Sender: TObject);
begin
//BackImage('C:\Temp\M\Schwalbenschwanz_Imago.jpg');
//  BackImage(Format('C:\Temp\N\H\%d.JPG',[Random(9)+1]));
//  BackImage(Format('C:\Temp\N\H\9.BMP',[Random(9)+1]));
  BackImage('C:\Temp\N\H\2.JPG');
end;
*************)

end.
