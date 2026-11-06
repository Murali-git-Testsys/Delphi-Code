unit GraphGlb;
  // used together with: Graph0, BgiKrn, UtColor

// === LOOK OUT! ===
// 07.10.04 P.W:
// Dont change the size of the Drawing bitmap of GraphGlb.pas Graph0_DrawBmp
//   this might easyly happen using in frmPrint LoadImage  ...!
// =================

// Modifications:
// 08.03.05 P.W:
// print use device independend bitmap by PrintBending: now printing under
// Win 98 is working (not too large Bmp)
// 15.03.06 P.W: PrintBending renamed to PrintBending_EndDoc
//    call of PrinterFpu.EndDoc before FreeMem: no longer black printings do occure.
// 14.12.06 P.W: BmpFindUsedRect no longer crashes when Bmp is complete White!
// 29.06.07 P.W: C_BlackEver added
// 18.11.09 P.W: XorDrawColorDef from C_White to C_LGray (increased contrast for gray palettes)
interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  DialogsSecure,   // 19.10.05 P.W
  PCX,             // 14.01.05 P.W
  forms, controls,
  ExtCtrls,
  SysUtils,
  Math,
  RectGlb,
  PrintersFPU,
  PrinterGlb,
  Windows,
  Classes,
  Dialogs,
  Graphics;

type
  TBmpLongColor = LongInt; // covers TBmpCol = word and LongInt
  TPrintRes     = (PR_PrnOpt, PR_Prn1_1, PR_Low, PR_Mid, PR_High);
var
  ClearPageCtr : Integer = 0; // for objects like VidePlus ShowViewBox to detect
                              // request for refresh
  PaintDebug : Boolean = False;
//PaintDebug : Boolean = True;
  PrintDiv   : Integer = 1;  // used to reduce size of printpage bitmap
  FixedPrintRes     : TPrintRes = PR_PrnOpt;
  ExpImgInvBW       : Boolean = True;  // set in FemurPcForm1 Options1Click
  ExpTableScreen    : Boolean = False; // set in FemurPcForm1 Options1Click // 25.11.05 P.W
  PrintInvBW        : Boolean = True;  // set in FemurPcForm1 Options1Click
  PrintForcePreView : Boolean = False; // set in FemurPcForm1 Options1Click
  XFact640480       : Double  = 1; {21.01.02 P.W} // here from Video1.pas 19.10.04 P.W.
  YFact640480       : Double  = 1; {21.01.02 P.W} // here from Video1.pas 19.10.04 P.W.

  // 05.09.05 P.W
  ScreenPosFixed    : Boolean = False;
  ScreenPosLeft     : Integer = 0;
  ScreenPosTop      : Integer = 0;
  ScreenPosWidth    : Integer = 0;
  ScreenPosHeight   : Integer = 0;

  GlbAllowSvDistAngle : Boolean = False; // 29.06.09 P.W

{--------------------------------------------------------------------}
(* vvv--- from UTColor: *)
  // Rgb Values are set in Graph0.pas procedure SetSysColors (uses SetRGBPalette)
  //  Colors for bone images see UtColor.pas Function   TColor.DoFillLookUpArray
  //  Used Colors will be found in array Graph0Palette
  //  procedure InvertBlackWhite see details for printing
const
  G0_GetMaxColor =  255;     // limited to byte by GlbDecs.pas TDisplColors ...

  //--- color index as const since 22.07.04 P.W ---  (as defined in UtColor)
  C_White     = G0_GetMaxColor -  0;  // [255]


const
  C_Black     = G0_GetMaxColor -  1;  // [254]    // Black on screen White when printed
  C_Yellow    = G0_GetMaxColor -  2;  // [253]
  C_Orange    = G0_GetMaxColor -  3;  // [252]
  C_LRed      = G0_GetMaxColor -  4;  // [251]
  C_Red       = G0_GetMaxColor -  5;  // [250]
  C_Blue      = G0_GetMaxColor -  6;  // [249]
  C_LBlue     = G0_GetMaxColor -  7;  // [248]
  C_LGreen    = G0_GetMaxColor -  8;  // [247]
  C_AddBlack  = G0_GetMaxColor -  9;  // [246]  // used marking different Roi areas during printing
                                           // see units UTAna.pas UTAna1.pas UTA_CBD.pas
                                           // will be Black on screen and white hatched when printed
  C_BackGrnd  = G0_GetMaxColor -  1;  // [254]

const
  {v--- added constants 21.01.02 P.W}
  C_AddWhite  = G0_GetMaxColor - 10;  // [245]   {not exchanged with black}
  C_LCyan     = G0_GetMaxColor - 11;  // [244]
  C_LMagenta  = G0_GetMaxColor - 12;  // [243]
  C_LGray     = G0_GetMaxColor - 13;  // [242]
  C_DGray     = G0_GetMaxColor - 14;  // [241]
  C_Green     = G0_GetMaxColor - 15;  // [240]
  C_Cyan      = G0_GetMaxColor - 16;  // [239]
  C_Magenta   = G0_GetMaxColor - 17;  // [238]
  {^--- added constants 21.01.02 P.W}
  C_BlackEver = G0_GetMaxColor - 18;  // [237]  // 29.06.07 P.W Black on Screen and Printings (CalcBD)

  // v--- 13.11.07 P.W mark header of special calibration :
  C_BackGrnd_Head = G0_GetMaxColor - 19;  // [238] rgb values defined by device.typ file:
     // for screen:
     // Rgb values defined by device.typ file BackGroundHeadScreen = $000000
     // for printing:
     // Rgb values defined by device.typ file BackGroundHeadPrint = $000000
     // SetRgbPalette see Graph0.pas procedure SetSysColors;
  // ^--- 13.11.07 P.W mark header of special calibration


//  XorDrawColorDef = C_White;  // 27.06.05 P.W instead of 1 which is used in
                                // unit UTColor.pas
                                // but no improvement of contrast achived
  XorDrawColorDef = C_LGray;    // 18.11.09 P.W improves contrast in case of gray palette
                                //  contrast is now good for all palettes!
Var
  XORDRAWCOLOR    : SmallInt = XorDrawColorDef;  {definition: 11.12.95 Michael Welsch}
                            // ^-- Default value: 27.06.05 P.W

const
// NumSysCols      = 19;  //10->18: 21.01.02 P.W; 18->19: 12.07.07 P.W
   NumSysCols      = 20;  //19->20: 13.11.07 P.W

  // v--- 13.11.07 P.W mark header of special calibration :
const
  BackGrnd_Head_Print_Def  = clWhite; // $bbggrr
  BackGrnd_Head_Screen_Def = clBlack; // $bbggrr
  NoColor                  =    TColor($FFFFFFFF);  // 10.12.08 P.W
  clMidGreen               =    TColor($0055CC55);  // 10.12.08 P.W
var
  BackGrnd_Head_Print   : TColor = BackGrnd_Head_Print_Def;
  BackGrnd_Head_Screen  : TColor = BackGrnd_Head_Screen_Def;
  WarnMode              : Boolean = False;
  // ^--- 13.11.07 P.W mark header of special calibration

(* ^^^--- from UTColor: *)
{--------------------------------------------------------------------}
(* vvv--- from GraphAdd: *)
Type
  TGraphDev  = (ScreenDev, PrintDev);
    // replaces SelectScreen, SelectPrinter and
    //          ScreenDev =0; PrintDev = 1;

(* ^^^--- from GraphAdd: *)
{--------------------------------------------------------------------}
type
  TTextMode = (TM_Transparent, TM_Opaque, TM_UseSet); // 09.06.04 P.W
  TRaster =   (TR_Default, TR_Mixed, TR_Prop, TR_Raster);  // 11.10.04 P.W.
const

  GROK           = 0{Graph.GROK};

  HorizDir       =      0 ;     {  von links nach rechts            }
  VertDir        =      1 ;     {  von unten nach oben              }
  UserCharSize   =      0 ;     {  benutzerdefinierte Zeichengröße  } //OemToAnsi Chg#286 (02.03.04 P.W)
{  Horizontale Konstante  Wert}
  LeftText       =      0 ;
//  CenterText     =      1 ;
  RightText      =      2 ;

{  Vertikale Konstante    Wert}
  BottomText     =      0 ;
 {CenterText     =      1 ;}
//  TopText        =      2 ;
(*
Hier können Sie sehen, wie die Textausgaben relativ zur Position des //OemToAnsi Chg#285 (02.03.04 P.W)
Grafik-Cursors angeordnet werden:
     TopText       TopText          TopText
     LeftText      CenterText       RightText
     BottomText    BottomText       BottomText
*)

{Diese Variablen müssen Sie verwenden, um mit PutImage Dinge auf dem} //OemToAnsi Chg#284 (02.03.04 P.W)
{Bildschirm darzustellen.}

{  Konstante          Wert               Bedeutung}
  NormalPut      =      0 ;      {   MOV  }
  CopyPut        =      0 ;      {   MOV  }
  XORPut         =      1 ;      {   XOR  }
  NotPut         =      4 ;      {   NOT  }

  ClipOn         =   True ;
  ClipOff        =  False ;

{  Linienarten}
  SolidLn        =      0 ;
  DottedLn       =      1 ;
  CenterLn       =      2 ;
  DashedLn       =      3 ;
  UserBitLn      =      4 ; {selbstdefinierbare Linienart)}

{  Linienbreiten:}
  NormWidth      =      1 ;
  ThickWidth     =      3 ;

{  Konstante     Wert Bedeutung:}
  SolidFill      =      1 ; {   Füllen mit der Zeichenfarbe       } //OemToAnsi Chg#282 (02.03.04 P.W)
  LtSlashFill    =      3 ; {   Füllen mit ///                    } //OemToAnsi Chg#280 (02.03.04 P.W)
  LtBkSlashFill  =      6 ; {   Füllen mit \                      } //OemToAnsi Chg#277 (02.03.04 P.W)
  InterleaveFill =      9 ; {   abwechselnde Linien               }
  CloseDotFill   =      11; {   eng beieinanderliegende Punkte    }

  TopOn          =   True ;
  TopOff         =  False ;


Type
  FillSettingsType = Packed Record // "record" to "Packed Record" Chg#268 (02.03.04 P.W)
     Pattern : Word;
     Color   : Word;
  end;

  TextSettingsType = Packed Record // "record" to "Packed Record" Chg#269 (02.03.04 P.W)
     Font      : Word;
     Direction : Word;
     CharSize  : Word;
     Horiz     : Word;       // SetTextJustify(LeftText,..);
     Vert      : Word;       // SetTextJustify(..,BottomText)
  end;

  ViewPortType = Packed Record // "record" to "Packed Record" Chg#270 (02.03.04 P.W)
     x1, y1, x2, y2 : Smallint;
     Clip           : Boolean;
  end;

  LineSettingsType = Packed Record // "record" to "Packed Record" Chg#271 (02.03.04 P.W)
     LineStyle : Word;
     Pattern   : Word;
     Thickness : Word;
  end;

  FillPatternType = array [1..8] of Byte;

// type
//   TWorld, TInternalStatus, pGraphSystem, TGraphSystem
//   moved from BGIKrn to GraphGlb.pas at 07.06.04 P.W
type
    TWorld        =       Packed Record // "Record" to "Packed Record" Chg#320 (02.03.04 P.W)
      Xw1,Yw1,Xw2,Yw2 :       Real;
    end;

    TInternalStatus  =  Packed Record // "Record" to "Packed Record" Chg#321 (02.03.04 P.W)
       _WorldFlg       :       Boolean;
       _MaxXPix,_MaxYPix :      Real;
       _BGIWorld        :      TWorld;
       _BTextMode       :      TTextMode;//Byte;   { 0: transparent, 1: opaque }
       _BTextBKColor    :      Byte;
       _XORFlg          :      Boolean;
       _RX0,_RY0,_RX1,_RY1 :      Smallint;  { save last rubber line }
       _RBX0,_RBY0,_RBX1,_RBY1 :      Smallint;  { save last rubber box }
       _TCurH,_TCurW,_TCurC:     Smallint;
       _HCurH,_HCurW,_HCurC:     Smallint;
       _HCurX,_HCurY      :     Smallint;
       {ViewPortType:}
       _X1,_Y1,_X2,_Y2       :     Smallint;
       _Clip              :     Boolean;

      {TextSettingsType:}
       _Font      : Word;
       _Direction : Word;
       _CharSize  : Word;
       _Horiz     : Word;
       _Vert      : Word;

    end;

  pGraphSystem     = ^tGraphSystem;  {07.07.99 P.W}
  tGraphSystem     = Packed Record          {07.07.99 P.W} // "Record" to "Packed Record" Chg#322 (02.03.04 P.W)
    S_GraphCurX      : Smallint;
    S_GraphCurY      : Smallint;
    S_Color          : Word;
    S_FillInfo       : FillSettingsType;
    S_InternalStatus : TInternalStatus;
  end;

var
//   moved from BGIKrn to GraphGlb.pas at 07.06.04 P.W :
  PrinterActiv : Boolean = False;
  ScreenInvBW  : Boolean = False;
  DTPFlg       : Boolean = False; // moved from BgiKrn.pas to GraphGlb.pas 31.03.05 P.W
  DTPFileName  : AnsiString  = ''; // 31.03.05 P.W
  DTPWidth     : Integer =  0;    // 31.03.05 P.W
  ButtonsInvalid : Boolean = True;  // for KnMultiDelphi TMenuApp 31.03.05 P.W

  TableActiv   : Boolean = False;  // 11.10.04 P.W.

type // 07.06.04 P.W
  TFunc_GetGraphSystem = Function (GrSys: pGraphSystem): pGraphSystem;  {07.07.99 P.W}
  TProc_SetGraphSystem = Procedure(GrSys: pGraphSystem);               {07.07.99 P.W}
var  // 07.06.04 P.W for support of GetSetGraphSysem by
     // MyEnterGraphics; Set in BGIKrn.pas
  Func_GetGraphSystem : TFunc_GetGraphSystem = nil;
  Proc_SetGraphSystem : TProc_SetGraphSystem = nil;

Type
  PByteArr = ^TByteArr;
  TByteArr = Array [0 .. MaxWord] of Byte;
  PWordArr = ^TWordArr;
  TWordArr = Array [0 .. MaxWord] of Word;
  PLongArr = ^TLongArr;
  TLongArr = Array [0 .. MaxWord] of LongInt;

// ######################################################
// ## BmpPixFmt and TBmpCol must fit to each other:
// ## pf8Bit    to  Byte
// ## pf15Bit   to  Word      // NOT supported!
// ## pf16Bit   to  Word          // optimal!
// ## pf32Bit   to  LongInt
// ##
// const BmpPixFmt = pf8Bit;   type TBmpCol = Byte;
   const BmpPixFmt = pf16Bit;  type TBmpCol = Word;     // smaller and quicker (recommended)
// const BmpPixFmt = pf32Bit;  type TBmpCol = LongInt;      // smoother images
// ##
// ######################################################

type
  PBmpArr   = ^TBmpArr;
  TBmpArr   = Array [0 .. MaxWord] of TBmpCol;

  PScanLines = ^TScanLines;
  TScanLines = Array [0 .. MaxWord] of PBmpArr;

  TGraph0RGB = Packed Record // "Record" to "Packed Record" Chg#274 (02.03.04 P.W)
    DelphiColor : TColor;
    DelphiBmpColor : TBmpCol;
    R, G, B : Byte;
  end;

const
  Graph0PaletteMax  = G0_GetMaxColor;
var
  Graph0Palette  : Array [0..Graph0PaletteMax] of TGraph0RGB;

  PreViewFlg        : Boolean = False;  // 17.06.04 P.W
  G0_LastCoord      : ViewPortType; // used for RegisterOkButton

//  Graph0_DrawImage  : TImage  = nil;
  Graph0_DrawCanvas : TCanvas = nil;
  Graph0_DrawBmp    : TBitmap = nil;
  Graph0_DrawScanLines : PScanLines = nil;
  Graph0_DrawScanLinesCount : Integer = 0;

var
  ErrScreens : TStringList = nil;           // 25.11.05 P.W.
type
  TAlignMode = (AM_Min, AM_Mid, AM_Max);

function PropStretchRect(const RSrc, RDest: TRect; AlignX:TALignMode=AM_Min; AlignY:TALignMode=AM_Min): TRect; // 15.10.08 P.W
function FixedPrintResDx: Integer;
function FixedPrintResDy: Integer;
procedure BmpClear(Bmp: TBitMap; ClearColor : TColor = clWhite);
procedure SetGraph0_DrawScanLines;

function  GetBmpColorRGB(R, G, B: Byte; PixelFormat: TPixelFormat= pfCustom): TBmpLongColor;
procedure GetRGBBmpColor(BmpCol: TBmpLongColor; var R, G, B: Byte; PixelFormat: TPixelFormat=pfCustom);
function  GetBmpColor(DelphiColor: TColor; PixelFormat: TPixelFormat): TBmpLongColor;
function  ColIndxToBmpCol(ColIndx: Word; PixFmt: TPixelFormat): TBmpLongColor;

function  BmpCopyCutFrame(const Bmp: TBitmap): TBitmap;
procedure PrintScreenPart(X0, Y0, X1, Y1: Integer; Orient:TPrinterFpuOrientation=poAutomatic); overload;
procedure PrintScreenPart(Orient:TPrinterFpuOrientation=poAutomatic); overload;
procedure PrintBmpOptimized(Bmp: TBitmap);
procedure PrintForm(aForm : TForm);
function  BmpFindUsedRect(Bmp: TBitmap; ShowInfo: Boolean = False): TRect;
procedure InvertBlackWhite(Bmp: TBitmap);
procedure TestImage(Bmp: TBitmap);
function  SortInt(var a, b: Integer): Boolean;


Implementation
  const Unit_Name = 'GraphGlb'; // 03.05.24 P.W

function PropStretchRect(const RSrc, RDest: TRect; AlignX:TALignMode=AM_Min; AlignY:TALignMode=AM_Min): TRect;
// 15.10.08 P.W
var
  WSrc, HSrc, WDest, HDest, DD: Integer;
  Wf, Hf: Double;
begin
  Result := RDest;

  WSrc  := Abs(RSrc .Right  - RSrc .Left);
  HSrc  := Abs(RSrc .Bottom - RSrc .Top);

  //--------------------------------
  if (WSrc=0) or (HSrc=0) then EXIT;
  //--------------------------------

  WDest := Abs(RDest.Right  - RDest.Left);
  HDest := Abs(RDest.Bottom - RDest.Top);
  Wf := WDest / WSrc;
  Hf := HDest / HSrc;

  if (Wf <= Hf) then
  begin // adapt H
    DD := Round(Wf * HSrc);
    case AlignY of
      AM_Min : Result.Bottom := Result.Top     + DD;
      AM_Mid :
        begin
               Result.Top    := Result.Top     + ((HDest - DD) div 2);
               Result.Bottom := Result.Top     + DD;
        end;
      AM_Max : Result.Top    := Result.Bottom  - DD;
    end;
  end else
  begin
//  Result.Right  := Result.Left + Round(Hf * WSrc);
    DD := Round(Hf * WSrc);
    case AlignX of
      AM_Min : Result.Right  := Result.Left    + DD;
      AM_Mid :
        begin
               Result.Left   := Result.Left    + ((WDest - DD) div 2);
               Result.Right  := Result.Left    + DD;
        end;
      AM_Max : Result.Left   := Result.Right   - DD;
    end;
  end;
end;


function  SortInt(var a, b: Integer): Boolean;
// returns true if a > b; then a and b are exchanged
var
  c : Integer;
begin
  result := (a > B);
  if result then
  begin
    c := a;
    a := b;
    b := c;
  end;
end;

function FixedPrintResDx: Integer;
begin
  Case FixedPrintRes of
    PR_PrnOpt,
    PR_Prn1_1 : Result := GetFramedPrintWidth;
    PR_Low    : Result :=  600;
    PR_Mid    : Result :=  800;
    PR_High   : Result := 1000;
    else        Result := 1000;
  end;
end;

function FixedPrintResDy: Integer;
begin
  Case FixedPrintRes of
    PR_PrnOpt,
    PR_Prn1_1 : Result := GetFramedPrintHeight;
    else        Result := Round(1.4 * FixedPrintResDx);
  end;
end;

procedure BmpClear(Bmp: TBitMap; ClearColor : TColor = clWhite);
begin
  Bmp.Canvas.Brush.Color := ClearColor;
  Bmp.Canvas.Brush.Style := bsSolid;
  Bmp.Canvas.FillRect(RectFromGraphic(Graph0_DrawBmp,1));  // ClearBackGround
end;

procedure SetGraph0_DrawScanLines;
// !Look out! Graph0_DrawScanLines become invalid when
//   Graph0_DrawBmp changes (may be using assign) 
var
  y : Integer;
begin
  // free previous Graph0_DrawScanLines
  if Graph0_DrawScanLinesCount > 0 then
    FreeMem(Graph0_DrawScanLines, Graph0_DrawScanLinesCount*SizeOf(PBmpArr));

  Graph0_DrawScanLinesCount := Graph0_DrawBmp.Height;
  GetMem(Graph0_DrawScanLines, Graph0_DrawScanLinesCount*SizeOf(PBmpArr));
  for y := 0 to Graph0_DrawScanLinesCount -1 do
    Graph0_DrawScanLines[y]:= Graph0_DrawBmp.ScanLine[y];
end;

function Palette_GetMatch(Palette: HPALETTE; R, G, B: Integer): TBmpLongColor;
// from Graphics.pas CopyPalette
var
  PaletteSize: Integer;
  LogPal: TMaxLogPalette;
  Dist, DistMin : Integer;  // squared distance in R G B coordinates
  I, IMin : Integer;
begin
  Result := 0;
  if Palette = 0 then Exit;
  PaletteSize := 0;
  if GetObject(Palette, SizeOf(PaletteSize), @PaletteSize) = 0 then Exit;
  if PaletteSize = 0 then Exit;
  with LogPal do
  begin
    palVersion := $0300;
    palNumEntries := PaletteSize;
    GetPaletteEntries(Palette, 0, PaletteSize, palPalEntry);

    // search nearest entry
    IMin := 0;
    DistMin := 3*255*255;
    for I := 0 to PaletteSize-1 do
    begin
      Dist := sqr(R- palPalEntry[I].peRed)   +
              sqr(G- palPalEntry[I].peGreen) +
              sqr(B- palPalEntry[I].peBlue);
      If Dist < DistMin then
      begin
        DistMin := Dist;
        IMin    := I
      end;

    end;
    Result := IMin;
  end;
//  Result := CreatePalette(PLogPalette(@LogPal)^);
end;

function  GetBmpColorRGB(R, G, B: Byte; PixelFormat: TPixelFormat=pfCustom): TBmpLongColor;
begin
  if PixelFormat = pfCustom then
    PixelFormat := Graph0_DrawBmp.PixelFormat;
  Case PixelFormat of
    pf8bit  :
      begin  // here return back the index of best match
        Result :=
          Palette_GetMatch(
            Graph0_DrawBmp.Palette,
            R, G, B);

      end;
    {
    pf15bit :// not supported by Delphi 7 SetPixelFormat!
      begin
        Result :=   ((R shr 3) shl 10)
                  + ((G shr 3) shl  5)
                  + ((B shr 3) shl  0);
      end;
    }
    pf16bit :
      begin
        Result :=   ((R shr 3) shl 11)
                  + ((G shr 2) shl  5)
                  + ((B shr 3) shl  0);
      end;
    pf32bit :
      begin
        Result :=   ((R shr 0) shl 16)
                  + ((G shr 0) shl  8)
                  + ((B shr 0) shl  0);
      end;
    else
      begin
        Result := 0;
        ShowMessage('GrapGlb.pas GetBmpColorRGB supports only pf16bit and pf32bit!')
      end;
  end;
end;

procedure GetRGBBmpColor(BmpCol: TBmpLongColor; var R, G, B: Byte; PixelFormat: TPixelFormat=pfCustom);
begin
  if PixelFormat = pfCustom then
    PixelFormat := Graph0_DrawBmp.PixelFormat;
  Case PixelFormat of
    pf16bit :
      begin
        // Result := ((R shr 3) shl 11) + ((G shr 2) shl  5) + ((B shr 3) shl  0);
        R := (BmpCol shr  8) and $F8;
        G := (BmpCol shr  3) and $FC;
        B := (BmpCol shl  3) and $F8;
      end;
    pf32bit :
      begin
        // Result := ((R shr 0) shl 16) + ((G shr 0) shl  8) + ((B shr 0) shl  0);
        R := (BmpCol shr 16) and $FF;
        G := (BmpCol shr  8) and $FF;
        B := (BmpCol       ) and $FF;
      end;
    else
      begin
        R := 0;
        B := 0;
        G := 0;
        ShowMessage('GrapGlb.pas GetRGBBmpColor supports only pf16bit and pf32bit!')
      end;
  end;
end;

function  GetBmpColor(DelphiColor: TColor; PixelFormat: TPixelFormat): TBmpLongColor;
(*
Windows 95: When the biCompression member is BI_BITFIELDS,
Windows 95 supports only the following 16bpp color masks:
A 5-5-5 16-bit image,
  where the blue mask is 0x001F, //             1 1111
  the green mask      is 0x03E0, //       11 1110 0000
  and the red mask    is 0x7C00; // 111 1100 0000 0000
and
a 5-6-5 16-bit image,
  where the blue mask is 0x001F, //             1 1111
  the green mask      is 0x07E0, //      111 1110 0000
  and the red mask    is 0xF800. //1111 1000 0000 0000
*)
var
  R, G, B : Byte;
begin
  Case PixelFormat of
    pf8bit  :
      begin  // here return back the index of best match
        R := (DelphiColor and $000000FF) ;
        G := (DelphiColor and $0000FF00) shr  8;
        B := (DelphiColor and $00FF0000) shr 16;
        Result :=
          Palette_GetMatch(
            Graph0_DrawBmp.Palette,
            R, G, B);

      end;
    {
    pf15bit :// not supported by Delphi 7 SetPixelFormat!
      begin
        R := (DelphiColor and $000000FF) ;
        G := (DelphiColor and $0000FF00) shr  8;
        B := (DelphiColor and $00FF0000) shr 16;
        Result :=   ((R shr 3) shl 10)
                  + ((G shr 3) shl  5)
                  + ((B shr 3) shl  0);
      end;
    }
    pf16bit :
      begin
        R := (DelphiColor and $000000FF) ;
        G := (DelphiColor and $0000FF00) shr  8;
        B := (DelphiColor and $00FF0000) shr 16;
        Result :=   ((R shr 3) shl 11)
                  + ((G shr 2) shl  5)
                  + ((B shr 3) shl  0);
      end;
    pf32bit :
      begin
        R := (DelphiColor and $000000FF) shr  0;
        G := (DelphiColor and $0000FF00) shr  8;
        B := (DelphiColor and $00FF0000) shr 16;
        Result :=   ((R shr 0) shl 16)
                  + ((G shr 0) shl  8)
                  + ((B shr 0) shl  0);
      end;
    else
      begin
        Result := DelphiColor;
        ShowMessage('GrapGlb.pas GetBmpColor supports only pf16bit and pf32bit!')
      end;
  end;
end;

function  ColIndxToBmpCol(ColIndx: Word; PixFmt: TPixelFormat): TBmpLongColor;
begin
  Result := GetBmpColor(Graph0Palette[ColIndx].DelphiColor, PixFmt);
end;

function  BmpCopyCutFrame(const Bmp: TBitmap): TBitmap;
var
  UsedRect : TRect;
  DestRect : TRect;
begin
  UsedRect      := BmpFindUsedRect(Bmp);

  Result        := TBitmap.Create;
  Result.PixelFormat := Bmp.PixelFormat;  // for large Bmp hopefully pf16bit
  Result.Width  := RectWidth (UsedRect);
  Result.Height := RectHeight(UsedRect);

  DestRect      := ZeroOffsetRect(UsedRect);

    // Delphi.CopyRect uses Right-Left and Bottom-Top as
    // Width and Height, so we have to use RectForCopyRect:
  Result.Canvas.CopyRect(
      RectForCopyRect(DestRect),
      Bmp.Canvas,
      RectForCopyRect(UsedRect));

end;

procedure ShowBmp(Bmp: TBitmap; DelayMs:Integer=0);
  Procedure WaitMs(DelayMs: Integer);
  var
    DelMs : Integer;
  begin
    While DelayMs > 0 do
    begin
      DelMs := Min(100, DelayMs);
      Application.ProcessMessages;
      Sleep(DelMs);
      Dec(DelayMs, DelMs);
    end;
  end;
var
  Form : TForm;
  Img  : TImage;

begin
  Form := TForm.Create(nil);
  Form.Parent := nil;
  Form.AutoSize := False;
  Form.WindowState := wsMaximized;
  Form.HorzScrollBar.Tracking := True;
  Form.VertScrollBar.Tracking := True;
  //Form.AutoSize := True; (true disables scrollbars!)
     Img := TImage.Create(Form);
     Img.Align := alNone;
     Img.AutoSize := True;
     Img.Parent := (Form);
     Img.AutoSize := True;
     Img.Picture.Assign(Bmp);

  if DelayMs <= 0 then
  begin
    Form.ShowModal;
  end else
  begin
    Form.Show;
    WaitMs(DelayMs);
  end;
  FreeAndNil(Form);
end;

(***  for debugging    *  )
function StretchDIBits(DC: HDC; DestX, DestY, DestWidth, DestHeight, SrcX,
  SrcY, SrcWidth, SrcHeight: Integer; Bits: Pointer; var BitsInfo: TBitmapInfo;
  Usage: UINT; Rop: DWORD): Integer;
const
  SF = 1;
var
  MapMode : Integer;
  Msg : String;
begin
  MapMode := GetMapMode(DC);
  Case MapMode of
    MM_TEXT:        // = 1;
      Msg := 'MM_TEXT';
    MM_LOMETRIC:    // = 2;
      Msg := 'MM_LOMETRIC';
    MM_HIMETRIC:    // = 3;
      Msg := 'MM_HIMETRIC';
    MM_LOENGLISH:   // = 4;
      Msg := 'MM_LOENGLISH';
    MM_HIENGLISH:   // = 5;
      Msg := 'MM_HIENGLISH';
    MM_TWIPS:       // = 6;
      Msg := 'MM_TWIPS';
    MM_ISOTROPIC:   // = 7;
      Msg := 'MM_ISOTROPIC';
    MM_ANISOTROPIC: // = 8;
      Msg := 'MM_ANISOTROPIC';
    else
      Msg := 'MM_?';
  end;
  ShowMessageFmt('MapMode = %d "%s"', [MapMode, Msg]);

SrcWidth   :=    SrcWidth   div SF;
SrcHeight  :=    SrcHeight  div SF;
DestWidth  := SF*(DestWidth  div SF);
DestHeight := SF*(DestHeight div SF);
  Result :=  Windows.StretchDIBits(DC, DestX, DestY, DestWidth, DestHeight, SrcX,
  SrcY, SrcWidth, SrcHeight, Bits, BitsInfo, Usage, Rop);
end;
(***)

procedure PrintBending_EndDoc(const Dest: TRect; Bmp: TBitMap; const Source: TRect);
// 08.03.05 P.W
// prints for not too large bitmaps under win 98
// 2nd parameter changed: BMP instead of BMP.Canvas
// modifications:
// 12.04.05 P.W : if no printer available do nothing;

// sometimes a valid BMP is printed pure black!
// 15.03.06 P.W: pure black no longer detected since EndDoc is called before FreeMem(Image)
var
  Info      : PBitmapInfo;
  InfoSize  : DWORD;
  Image     : Pointer;
  ImageSize : DWORD;
  Bits      : HBITMAP;
  SourceBU  : TRect; // BottomUp for DIB!
begin
//  ShowBmp(Bmp);
  If not PrinterInstalled then EXIT;  // 12.04.05 P.W
// DIB are bottom-up while BMP is top-down
     SourceBU := Source;
     SourceBU.Top    := Bmp.Height - Source.Bottom;
     SourceBU.Bottom := Bmp.Height - Source.Top;

     Bits := Bmp.Handle;  // bmp is passed as a parameter
     GetDIBSizes(Bits, InfoSize, ImageSize);
// try with enlarged ImageSize:   ImageSize := 2 * ImageSize; // 15.03.06 P.W : no improvement!
// InfoSize := 8 * InfoSize; // no improvement!
     Info := AllocMem(InfoSize); // 52 bytes
     try
       Image := AllocMem(ImageSize);
       try
         GetDIB(Bits, 0, Info^, Image^); // x MBytes

         StretchDIBits(PrinterFPU.Canvas.Handle, // crashes if no PrinterFound!
             Dest.Left,      Dest.Top,
             Dest.Right    - Dest.Left,
             Dest.Bottom   - Dest.Top,

// DIB are bottom-up while BMP is top-down
             SourceBU.Left,    SourceBU.Top,
             SourceBU.Right  - SourceBU.Left,
             SourceBU.Bottom - SourceBU.Top,

             Image, Info^, DIB_RGB_COLORS, SRCCOPY);
       finally
         PrinterFpu.EndDoc;  // to here 15.03.06 P.W     Improvement: no longer black printouts!
                             // ! But EndDoc is doing nothing in case of MultiDocMode=True
         FreeMem(Image, ImageSize);
       end;
     finally
       FreeMem(Info, InfoSize);
     end;
end;

procedure PrintScreenPart(X0, Y0, X1, Y1: Integer; Orient:TPrinterFpuOrientation=poAutomatic);
// 28.09.04 P.W
// modifications:
// 18.03.05 P.W use PrintBending which is better under Win98
// 13.10.08 P.W Orient Default from poLandscape to poAutomatic
var
  Bmp : TBitMap;
  SavPrinterOrientation : TPrinterFpuOrientation;
begin
  // PrinterFpu.Copies := 1;  // until 04.11.08 P.W
  SavPrinterOrientation := PrinterFpu.Orientation;
  if (Orient = poAutomatic) then  // if: 13.10.08 P.W
  begin                           // 13.10.08 P.W
    if Abs(X1-X0) > Abs(Y1-Y0)
      then PrinterFpu.Orientation := poLandscape
      else PrinterFpu.Orientation := poPortrait;
  end else
  begin
    PrinterFpu.Orientation   := Orient;
  end;

  Bmp := TBitMap.Create;//Self.GetFormImagePixFmt(pf32Bit);
  Bmp.PixelFormat := Graph0_DrawBmp.PixelFormat;
  Bmp.Width  := X1-X0 +1;
  Bmp.Height := Y1-Y0 +1;

  Bmp.Canvas.CopyRect(
    RectForCopyRect(Rect(0,0,X1-X0,Y1-Y0)),
    Graph0_DrawCanvas,
    RectForCopyRect(Rect(X0,Y0,X1,Y1)));

  if PrintInvBW then
    InvertBlackWhite(Bmp);                // we need BMP as local copy!
  PrinterFpu.BeginDoc;  // may change Printer Fpu Control Word!

//  PrinterFpu.Canvas.StretchDraw(PropPrintRect(Bmp), Bmp);             
  PrintBending_EndDoc(PropPrintRect(Bmp), Bmp, RectFromGraphic(Bmp,1)); // 18.03.05 P.W

//  PrinterFpu.EndDoc;                                                  // u. 15.03.06 P.W

  Bmp.Free;

  PrinterFpu.Orientation := SavPrinterOrientation;
end;

procedure PrintScreenPart(Orient:TPrinterFpuOrientation=poAutomatic); overload;
// 13.10.08 P.W Orient Default from poLandscape to poAutomatic
begin
  PrintScreenPart(0, 0, Graph0_DrawBmp.Width-1, Graph0_DrawBmp.Height-1, Orient);
end;

procedure PrintBmpOptimized(Bmp: TBitmap);
// assumes Bitmap is adapted to previous printer settings!
// Changes Bmp (cuts whiteFrames)
// 17.09.04 P.W : Try to support StretchDraw to use smaller Bitmaps
//   One Page on HP printer 5952 produced a 56 MB Printjob!
//   Creation of such a job is quick, but the printer spooler slows down the system!
//   now: init printer reduces the bitmap and we use stretchdraw to fill the page
//   (or  ?use print scaled)
// 03.08.06 P.W Destination Rect Right and Bottom reduced by 1
var
  UsedRect : TRect;
  dx, dy   : Integer; // offset into PrinterPage
begin
//Bmp.Width  := Bmp.Width  div 4;
//Bmp.Height := Bmp.Height div 4;
//PrintDiv := PrintDiv * 4;

  UsedRect := BmpFindUsedRect(Bmp);
//UsedRect := RectFromGraphic(Bmp);
  dx := GetFramedPrintRect.Left + UsedRect.Left * PrintDiv;
  dy := GetFramedPrintRect.Top  + UsedRect.Top  * PrintDiv;

  PrinterFpu.BeginDoc;

  if not(FixedPrintRes in [Pr_PrnOpt, Pr_Prn1_1]) then
  begin // this may crash the printer memory!  Try to avoid this by scaleFact 0.75
    PrintBending_EndDoc(
      RectForCopyRect(PropPrintRect(UsedRect, 0.75)),
      Bmp,//      Bmp.Canvas,
      RectForCopyRect(UsedRect));
  end else
  begin
    PrintBending_EndDoc(
      RectForCopyRect(
        Rect(dx,
             dy,
             dx + PrintDiv * (RectWidth (UsedRect)-1),      // -1: 03.08.06 P.W
             dy + PrintDiv * (RectHeight(UsedRect)-1) )),   // -1: 03.08.06 P.W
             Bmp,//      Bmp.Canvas,
      RectForCopyRect(UsedRect));

  end;
//  PrinterFpu.EndDoc;  // u. 15.03.06 P.W
  // the size of the printjob is proportional to
  // the uncompressed Bitmap
  // (using TJpegImage.Compress does not reduce the size)
  // PrinterFpu.Canvas.Pixels: 20 Byte for each
end;

//var
//  BmpSaveCtr : Integer = 0;
procedure PrintForm(aForm : TForm);
var
  FPUControlWord: Word;
  SavOrient : TPrinterFpuOrientation;

  Bmp : TBitMap;
  BmpRect : TRect;
begin
  FPUControlWord := MyGet8087CW;
  SavOrient := PrinterFpu.Orientation;
  if aForm.Width > aForm.Height
    then PrinterFpu.Orientation := poLandscape
    else PrinterFpu.Orientation := poPortrait;

  aForm.PrintScale := poPrintToFit;  // usee page keep Proportional
                  //poProportional; (= same size as on screen!);
//aForm.PrintScale := poProportional;

  // --- aForm.Print; // does not work properly!
  // --- so we do ower own (not using aForm.Printscale) but
  //     support margins using PropPrintRect
  Bmp := aForm.GetFormImage;
//bmp.SaveToFile(Format('C:\Temp\PrintForm%d.Bmp',[BmpSaveCtr]));  // correct BMP stored when later black printing occurs
//inc(BmpSaveCtr);
//ShowBmp(Bmp, 500);
//{
  PrinterFpu.BeginDoc;
  try
    BmpRect := RectFromGraphic(Bmp);
    PrintBending_EndDoc(                                                 // here is later; prints sometimes
      RectForCopyRect(PropPrintRect(BmpRect, 1.0)),               // pure BLACK
      Bmp,//      Bmp.Canvas,
      RectForCopyRect(BmpRect));
  finally
//    PrinterFpu.EndDoc;  // u. 15.03.06 P.W
    Bmp.Free;
  end;
//} Bmp.Free;
  PrinterFpu.Orientation := SavOrient;
  MySet8087CW(FPUControlWord);
end;

function  BmpFindUsedRect(Bmp: TBitmap; ShowInfo: Boolean = False): TRect;
// returns the Rectangle that covers the non white area
// coordinates of Bmp: (0,0) to (Bmp.Width-1, Bmp.Height-1)
// Return.Left  is the most left  point
// Return.Right is the most right point
// example: Bmp is black then result is same as
// RectFromBmp
// 14.12.06 P.W: no longer crashes when Bmp is complete White!
var
  PixFmt       : TPixelFormat;
  TstWhite     : TBmpLongColor; // LongInt for all
  x, y         : Integer;
  SL           : Pointer;
  function PixelNotWhite: Boolean;
  begin
    result := true;
    case PixFmt of
      pf8bit : Result := PByteArr(SL)[x] <> TstWhite;
      pf16bit: Result := PWordArr(SL)[x] <> TstWhite;
      pf32bit: Result := PLongArr(SL)[x] <> TstWhite;
    end;  
  end;
var
  xSmax, ySmax : Integer; //Search limits Width and Height
  xMin,  xMax,            //xMin: most left not white Point
  yMin,  yMax  : Integer; //yMin: most top  not white Point
begin
  PixFmt    := Bmp.PixelFormat;
  if not (PixFmt in [pf8bit, pf16bit, pf32bit]) then
  begin
    Result := RectFromGraphic(Bmp);
    EXIT;
  end;
  if PrinterActiv                                     // C_Black and C_White exchanged!
    then TstWhite  := ColIndxToBmpCol(C_Black, PixFmt)
    else TstWhite  := ColIndxToBmpCol(C_White, PixFmt);
  yMin := -1;
  yMax := -1;

  { debug print a white bitmap: 
    Bmp.Canvas.Brush.Color := clWhite;
    Bmp.Canvas.Pen.Color := clWhite;
    Bmp.Canvas.FillRect(Rect(0,0,Bmp.Width,Bmp.Height));
  }
  xSmax := Bmp.Width  -1;
  ySmax := Bmp.Height -1;
  xMin  := xSmax;
  xMax  := 0;

  // search yMin  (from 0 .. ySmax)
  y := 0;
  While (y <= ySmax) do
  begin  // scan from top until first nonwhite line
    SL := Bmp.ScanLine[y];
    x := 0;
    While (x <= xSmax) do
    begin  // scan from left until first nonwhite point
      if PixelNotWhite then
      begin
        xMin := x;  // xMin: not ready
        xMax := x;  // xMax: not ready
        yMin := y;  // yMin: ready
        break;
      end;
      inc(x);
    end;
    if (yMin >= 0) then break;
    inc(y);
  end;

  // search yMax  (from ySmax .. 0)
  y := ySmax;
  While (y >= 0) do
  begin // scan from bottom until first nonwhite line
    SL := Bmp.ScanLine[y];
    x := 0;
    While (x <= xSmax) do
    begin  // scan from left until first nonwhite point
      if PixelNotWhite then
      begin
        xMin := Min(xMin, x); // xMin: not ready
        xMax := Max(xMax, x); // xMax: not ready
        yMax := y;            // yMax: ready
        break;
      end;
      inc(x);
    end;
    if (yMax >= 0) then break;
    dec(y);
  end;

  // search xMin, xMax  (from yMin .. yMax)
  y := Max(0, yMin); // until 14.12.06 P.W: y := yMin;
  While (y <= yMax) do        // -1 <= -1 when empty or complete white image
  begin  // scan all lines from yMin .. yMax
    SL := Bmp.ScanLine[y];                             // here y was -1! Report preview 14.12.06 P.W!
    // search xMin (from 0 .. xMin -1)
    x := 0;
    While (x < xMin) do
    begin
      if PixelNotWhite then
      begin
        xMin := x;
        break;
      end;
      inc(x);
    end;
    // search xMax (from xSmax .. xMax +1)
    x := xSmax;
    While (x > xMax) do
    begin
      if PixelNotWhite then
      begin
        xMax := x;
        break;
      end;
      dec(x);
    end;

    if (xMin = 0) and (xMax = xSmax) then
      break; // nothing more to do
    inc(y);
  end;

  Result := Rect(xMin, yMin, xMax, yMax);

  if ShowInfo then
    ShowMessageFmt('Area used is %3.2f %%',
      [CalcPercRectArea(RectFromGraphic(Bmp), Result)]);
end;

procedure InvertBlackWhite(Bmp: TBitmap);
// invert Black and White for printer
// support gray dithering for low density parts
// HighDensity parts are changed from AddWhite to White
// Modification:
// 26.07.04 P.W Invert Black and White makes no sense for smoothed fonts
//  so for printer the Black and White Palette entry have been changed
// (see Grahp0.pas procedure SetSysColors)
// here we no lonber invert pure Black and White,
// but we continue to adapt the AddWhite and AddBlack
// 28.09.04 P.W Invert Black and White for Screen dump needs some modifications:
//   PrinterActive is false in this case,
var
  PixFmt      : TPixelFormat;
  TstBlack,
  SetWhite,     // 26.07.04 P.W  // replaces TstWhite for set
  BmpGray,
  TstBlack2,
  TstWhite2   : TBmpLongColor; // LongInt for all
  X, Y        : Integer;
  SL08        : PByteArr;  // PByteArr for pf8bit
  SL16        : PWordArr;  // PWordArr for pf16bit
  SL32        : PLongArr;  // PLongArr for pf32bit
begin
  PixFmt    := Bmp.PixelFormat;

  if (PrinterActiv or ScreenInvBW) then
  begin
    SetWhite  := ColIndxToBmpCol(C_Black, PixFmt);  // this is White for PrinterActiv!
    TstBlack  := ColIndxToBmpCol(C_White, PixFmt);
  end else
  begin
    SetWhite  := ColIndxToBmpCol(C_White, PixFmt);
    TstBlack  := ColIndxToBmpCol(C_Black, PixFmt);
  end;
  BmpGray   := ColIndxToBmpCol(C_LGray, PixFmt);
  // $.. values must fit to UtColor TColor.DoFillLookUpArray:
  // but not detected if PixFmt = pf32Bit!
  TstBlack2 := GetBmpColor($00040404, PixFmt);  // compare UTColor.pas TColor.DoFillLookUpArray
  // ^ ignores paint from pf16bit to pf32bit so:
  if (BmpPixFmt = pf16Bit) then
  if (PixFmt    = pf32Bit) then TstBlack2 := $400;
//  if (BmpPixFmt = pf8Bit)  then TstBlack2 := $00;


  TstWhite2 := GetBmpColor($00FAFAFA, PixFmt);  // compare UTColor.pas TColor.DoFillLookUpArray
  // ^ ignores paint from pf16bit to pf32bit so:
  if (BmpPixFmt = pf16Bit) then
  if (PixFmt    = pf32Bit) then TstWhite2 := $FFFBFF;

  // invert Black and White for printer
  // support gray dithering for low density parts

  Case PixFmt of
    pf8bit:    // here TstBlack and TstBlack2 are same!
      For Y := 0 to Bmp.Height-1 do
      begin
        SL08 := Bmp.ScanLine[Y];
        For X := 0 to Bmp.Width-1 do
        begin
          if not (PrinterActiv or ScreenInvBW) then
          begin  // again since 28.09.04 P.W
            if SL08[X] = TstBlack  then SL08[X] := SetWhite
            else
            if SL08[X] = SetWhite  then SL08[X] := TstBlack;
          end;
                               // highest density
          if SL08[X] = TstWhite2 then SL08[X] := SetWhite //TstWhite->SetWhite 26.07.04 P.W
          else
          if SL08[X] = TstBlack2 then
          begin     // lowest density in images
            If (((X-Y) mod 16) = 0)
            then SL08[X] := BmpGray
            else SL08[X] := SetWhite; //TstWhite->SetWhite 26.07.04 P.W
          end;
        end;
      end;
    pf16bit:
      For Y := 0 to Bmp.Height-1 do
      begin
        SL16 := Bmp.ScanLine[Y];
        For X := 0 to Bmp.Width-1 do
        begin
          if not (PrinterActiv or ScreenInvBW) then
          begin  // again since 28.09.04 P.W
            if SL16[X] = TstBlack  then SL16[X] := SetWhite
            else
            if SL16[X] = SetWhite  then SL16[X] := TstBlack;
          end;
                               // highest density
          if SL16[X] = TstWhite2 then SL16[X] := SetWhite //TstWhite->SetWhite 26.07.04 P.W
          else
          if SL16[X] = TstBlack2 then
          begin     // lowest density in images
//            Bmp.Canvas.Brush.Style := bsSolid;
//            Bmp.Canvas.Brush.Color := clGreen;
//            Bmp.Canvas.FloodFill(X,Y, Bmp.Canvas.Pixels[X,Y], fsSurface);
            If (((X-Y) mod 16) = 0)
            then SL16[X] := BmpGray
            else SL16[X] := SetWhite; //TstWhite->SetWhite 26.07.04 P.W
          end;
        end;
      end;
    pf32bit:
      For Y := 0 to Bmp.Height-1 do
      begin
        SL32 := Bmp.ScanLine[Y];
        For X := 0 to Bmp.Width-1 do
        begin
          if not (PrinterActiv or ScreenInvBW) then
          begin  // again since 28.09.04 P.W
            if SL32[X] = TstBlack  then SL32[X] := SetWhite
            else
            if SL32[X] = SetWhite  then SL32[X] := TstBlack;
          end;
                               // highest density
          if SL32[X] = TstWhite2 then SL32[X] := SetWhite //TstWhite->SetWhite 26.07.04 P.W
          else
          if SL32[X] = TstBlack2 then
          begin     // lowest density in images
            If (((X-Y) mod 16) = 0)
            then SL32[X] := BmpGray
            else SL32[X] := SetWhite; //TstWhite->SetWhite 26.07.04 P.W
          end;
        end;
      end;
  end;
  Bmp.Modified := True;
end;

procedure TestImage(Bmp: TBitmap);
var
  WrtX : Integer;
  WrtY : Integer;
  procedure Wrt(S: String);
  begin
    Bmp.Canvas.TextOut(WrtX, WrtY, S);
    Inc(WrtY, Bmp.Canvas.TextHeight(S));
  end;
var
  PixFmt      : TPixelFormat;
  TstBlack,
  TstWhite    : TBmpLongColor; // LongInt for all
  X, Y        : Integer;
  SL08        : PByteArr;  // PWordArr for pf8bit
  SL16        : PWordArr;  // PWordArr for pf16bit
  SL32        : PLongArr;  // PLongArr for pf32bit
begin
  WrtX      := 10;
  WrtY      := 10;
  PixFmt    := Bmp.PixelFormat;
  if (PixFmt = pf8bit) then
  begin
    TstBlack  := $00;
    TstWhite  := $FF;
  end else
  begin
    TstBlack  := ColIndxToBmpCol(C_Black, PixFmt);
    TstWhite  := ColIndxToBmpCol(C_White, PixFmt);
  end;

  // --- All set to TstWhite: ---
  Case PixFmt of
    pf8bit :
      For Y := 0 to Bmp.Height-1 do
      begin
        SL08 := Bmp.ScanLine[Y];
        For X := 0 to Bmp.Width-1 do
        begin
          SL08[X] := TstWhite;
        end;
      end;
    pf16bit:
      For Y := 0 to Bmp.Height-1 do
      begin
        SL16 := Bmp.ScanLine[Y];
        For X := 0 to Bmp.Width-1 do
        begin
          SL16[X] := TstWhite;
        end;
      end;
    pf32bit:
      For Y := 0 to Bmp.Height-1 do
      begin
        SL32 := Bmp.ScanLine[Y];
        For X := 0 to Bmp.Width-1 do
        begin
          SL32[X] := TstWhite;
        end;
      end;
  end;

  // --- Mark the Edges with TstBlack: ---
  Case PixFmt of
    pf8bit:
      For Y := 0 to Bmp.Height-1 do
      begin
        SL08 := Bmp.ScanLine[Y];
        If (Y = 0) or (Y = Bmp.Height-1) then
        For X := 0 to Bmp.Width-1 do
        begin
          If (X < 10) or (X > Bmp.Width-10) then
          SL08[X] := TstBlack;
        end;
        If (Y < 10) or (Y > Bmp.Height-10) then
        begin
          SL08[0] := TstBlack;
          SL08[Bmp.Width-1] := TstBlack;
        end;
      end;
    pf16bit:
      For Y := 0 to Bmp.Height-1 do
      begin
        SL16 := Bmp.ScanLine[Y];
        If (Y = 0) or (Y = Bmp.Height-1) then
        For X := 0 to Bmp.Width-1 do
        begin
          If (X < 10) or (X > Bmp.Width-10) then
          SL16[X] := TstBlack;
        end;
        If (Y < 10) or (Y > Bmp.Height-10) then
        begin
          SL16[0] := TstBlack;
          SL16[Bmp.Width-1] := TstBlack;
        end;
      end;
    pf32bit:
      For Y := 0 to Bmp.Height-1 do
      begin
        SL32 := Bmp.ScanLine[Y];
        If (Y = 0) or (Y = Bmp.Height-1) then
        For X := 0 to Bmp.Width-1 do
        begin
          If (X < 10) or (X > Bmp.Width-10) then
          SL32[X] := TstBlack;
        end;
        If (Y < 10) or (Y > Bmp.Height-10) then
        begin
          SL32[0] := TstBlack;
          SL32[Bmp.Width-1] := TstBlack;
        end;
      end;
  end;
  Bmp.Canvas.Font.Color  := clBlack;
  Bmp.Canvas.Font.Height := 40;
  Bmp.Canvas.Brush.Color := clWhite;

  Wrt(Format('Bmp.Width          : %d', [Bmp.Width]));
  Wrt(Format('Bmp.Height         : %d', [Bmp.Height]));
  Wrt(Format('Printer.PageWidth  : %d', [PrinterFpu.PageWidth]));
  Wrt(Format('Printer.PageHeight : %d', [PrinterFpu.PageHeight]));
  Wrt(Format('Printer.Orientation: %d', [Word(PrinterFpu.Orientation)]));

  Bmp.Modified := True;
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  BackGrnd_Head_Print  := BackGrnd_Head_Print_Def;
  BackGrnd_Head_Screen := BackGrnd_Head_Screen_Def;
  ButtonsInvalid       := True;
  ClearPageCtr         := 0;
  DTPFileName          := '';
  DTPFlg               := False;
  DTPWidth             :=  0;
  ErrScreens           := nil;
  ExpImgInvBW          := True;
  ExpTableScreen       := False;
  FixedPrintRes        := PR_PrnOpt;
  Func_GetGraphSystem  := nil;
  FillChar(G0_LastCoord, SizeOf(G0_LastCoord), #0);
  GlbAllowSvDistAngle  := False;
  FillChar(Graph0Palette, SizeOf(Graph0Palette), #0);
  Graph0_DrawBmp       := nil;
  Graph0_DrawCanvas    := nil;
  Graph0_DrawScanLines := nil;
  Graph0_DrawScanLinesCount := 0;
  PaintDebug := False;
  PreViewFlg           := False;
  PrintDiv             := 1;
  PrinterActiv         := False;
  PrintForcePreView    := False;
  PrintInvBW           := True;
  Proc_SetGraphSystem  := nil;
  ScreenInvBW          := False;
  ScreenPosFixed       := False;
  ScreenPosHeight      := 0;
  ScreenPosLeft        := 0;
  ScreenPosTop         := 0;
  ScreenPosWidth       := 0;
  TableActiv           := False;
  WarnMode             := False;
  XFact640480          := 1;
  XORDRAWCOLOR         := XorDrawColorDef;
  YFact640480          := 1;
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);


end.
