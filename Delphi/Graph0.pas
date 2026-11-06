// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; changes: 13; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; changes: 9; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
// Code reduced to what is used by SvComp or FemurPc 28.04.04 P.W
// Modifications:
// 29.03.05 P.W
// GetImage check values to avoid ScanLine Index out of Range
// 10.06.05 P.W: ClearPage supporta color of parent ScrollBox1 of frmMain
// 30.09.05 P.W PutPixel supports XORMode
// 24.07.06 P.W: OutTextXY_mixed handle "-" as number to support rastered output also for negative numbers
// 22.08.06 P.W: PutPixel: correction: use GetCoordLeft/Top
// 29.06.07 P.W: C_BlackEver added
// 15.04.08 P.W: Limit ErrorScreens in function ErrSaveGraph0_DrawBmp
// 13.06.08 P.W: new Graph0_DrawBmp_Copy and Graph0_DrawBmp_Restore;
//                   Correction in SaveGraph0_DrawBmp_BW and SaveGraph0_DrawBmp
// 26.01.09 P.W: support DrawArrow
Unit Graph0;
(*
Created: {09.10.03 P.W}
Aim    : Capsulate the use of Graph, GrapAdd, Boiler, Spooler
Use is only temporary for testing: wrrite Graph Commands into file
      which are read by a Delphi-Windows application:
          "GraphScreenR.Exe" interface file is "C:\Temp\GrCmd_0.Rec"

  Tests: SvComp1 uses VidMem disabled!
*)

Interface

Uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  PntMath,    // 26.01.09 P.W
  UMsgDelay,  // 25.11.05 P.W
  TransX,
  Classes,
  Windows,
  PrintForm,
  Dialogs,
  Controls,
  ExtCtrls,
  Graphics,
  Dos,
  TurboToDelphi,
  Forms,
  Crt,
  Draw,
  DosTimer,
  GlbDecs,
  GlbPath,
  GlbTools,
  GlbType,
  Objects,
  RectGlb,
  PrinterGlb,
  GraphGlb;

var
  CrtCurWanted      : Boolean = False; // for use by ClearPage
//TestDebug_Enabled : Boolean = False; // 15.10.08 P.W

//function TestDebug(Msg:String=''; DebMode:Integer=0): Boolean; overload; // 15.10.08 P.W
//function TestDebug(OkIfTrue:Boolean; Msg:String=''; DebMode:Integer=0): Boolean; overload; // 15.10.08 P.W

function ColWarnForeground(Bkg: Word): Word;
function  SetMaxViewPort(Clip:Boolean=True): ViewPortType;
procedure ClearPage(Color: SmallInt = C_Black);
(* vvv--- from Boiler *)              // 23.04.04 P.W
Procedure MybeginPage;
Function  MyEndPage : Boolean;
Function  MyEnterGraphics(SelectDev: TGraphDev): Integer;
Procedure MyExitGraphics;
(* ^^^--- from Boiler *)              // 23.04.04 P.W
{--------------------------------------------------------------------}

procedure Bar(x1, y1, x2, y2: Smallint; Col:TColor=NoColor);
procedure BarBG(x1, y1, x2, y2: Smallint);
procedure BarInv(x1, y1, x2, y2: Smallint);
procedure DrawArrow(x0, y0, x1, y1, dA : Integer);      // 26.01.09 P.W
procedure SetFillStyle(Pattern: Word; Color: Word);
function  GraphResult: Smallint;
function  GetGraphMode: Smallint;
function  GetMaxX: Smallint;
function  GetMaxY: Smallint;
function  GetMaxColor: Word;
function  GetX: Smallint;
function  GetY: Smallint;
function  GetColor: Word;
procedure GetTextSettings(var TextInfo: TextSettingsType);
procedure GetViewSettings(var ViewPort: ViewPortType);
procedure SetTextMode(TextMode: TTextMode);
procedure SetTextStyle(Font, Direction: Word; CharSize: Word);
procedure SetViewPort(x1, y1, x2, y2: Smallint; Clip: Boolean); overload;
procedure SetViewPort(ViewPort: ViewPortType); overload;
procedure SetColor(Color: Word);
procedure SetTextJustify(Horiz, Vert: Word);
function AsciiPrintFileName: String;
Procedure SaveClearAsciiPage;
procedure OutTextXY(X,Y: Smallint; const TextString: string;
            TM: TTextMode=TM_UseSet; RasterMode:TRaster=TR_Default);
procedure OutText(const TextString: string;
            TM: TTextMode=TM_UseSet; RasterMode:TRaster=TR_Default);
procedure MoveTo(X, Y: Smallint);
function  ImageSize(x1, y1, x2, y2: Integer): Integer;
procedure GetImage(x1, y1, x2, y2: Integer; var BitMap);
procedure PutImage(x0, y0: Integer; var BitMap; BitBlt: Word);
function  TextWidth(TextString: string): Word;
function  TextHeight(TextString: string='gX'): Word;
procedure GetAspectRatio(var Xasp, Yasp: Word);
procedure Rectangle(x1, y1, x2, y2: Smallint);
procedure RectangleAbs(x1, y1, x2, y2: Smallint);
procedure SetUserCharSize(MultX, DivX, MultY, DivY: Word);
procedure PutPixel(X, Y: Smallint; Color: Word);
function  GetPixel(X, Y: Smallint): TColor;
procedure SetWriteMode(WriteMode: Smallint);
procedure GetFillSettings(var FillInfo: FillSettingsType);
procedure GetLineSettings(var LineInfo: LineSettingsType);
procedure SetLineStyle(LineStyle: Word; Pattern: Word; Thickness: Word);
procedure FloodFill(X, Y: Smallint; BorderColor: Word);
procedure Activate8bitRgbPalette;
procedure SetRGBPalette(ColorNum, RedValue, GreenValue, BlueValue: Integer;
            ActivatePal: Boolean = False); overload;
procedure SetRGBPalette(ColorNum: Integer; Col: TColor;
            ActivatePal: Boolean = False); overload;
function  ColorDistNorm(ColIdx0, ColIdx1: Word): Double;
function  GetBkColor: Word;
procedure Circle(X,Y: Smallint; Radius: Word);
procedure PieSlice(X, Y: Smallint; StAngle, EndAngle, Radius: Word);
procedure Bar3D(x1, y1, x2, y2: Smallint; Depth: Word=0; Top: Boolean=False);
procedure SetBkColor(ColorNum: Word);
function  ChkSetThickPenWidth: Integer;
procedure SetPenWidth(PenWidth: Integer);
procedure Line(x1, y1, x2, y2: Smallint);
procedure LineTo(X, Y: Smallint);
procedure Graph0_Init(aImage: TImage;
            ClearFlg: Boolean = True;
            ImgWidth: Integer = 0;
            ImgHeight: Integer = 0);
procedure SetSysColors;  // in Interface s. 13.11.07 P.W
{--------------------------------------------------------------------}
{Procedure CmdWrite(Cmd: String);}
{--------------------------------------------------------------------}

function  CmdOut(DrawCmd: TDrawCmd;
                P1: Smallint = 0; P2: Smallint = 0;
                P3: Smallint = 0; P4: Smallint = 0;
                P5: Smallint = 0): Pointer;                overload;
function  CmdOut(DrawCmd: TDrawCmd; R: TRect) : Pointer;   overload;

function DefaultTextHeight: Integer;
function DefaultTextWidth: Integer;

function Graph0_DrawBmp_Copy: TBitMap;
procedure Graph0_DrawBmp_Restore(const Bmp: TBitMap);
procedure SaveGraph0_DrawBmp(aName: String);
procedure LoadGraph0_DrawBmp(aName: String);
function ErrSaveGraph0_DrawBmp(ErrInfo:TStringList=nil): String; overload;
function ErrSaveGraph0_DrawBmp(
  const aFormat: AnsiString;
  const Args: array of const): String; overload;
function ErrSaveGraph0_DrawBmp(const aInfo: AnsiString): String; overload;
function TempSaveGraph0_DrawBmp: String;
procedure TempLoadGraph0_DrawBmp(aTempName: String; DeleteFlg:Boolean=True);
procedure DrawPrinterColorCheckBox(R: TRect); // 15.10.08 P.W

Implementation

uses
  SysUtils, StrUtils, Types;
  const Unit_Name = 'Graph0'; // 03.05.24 P.W

const
  TextWidthBasisChar  = 'X';
  MinPrintHeightWidth = 1200;
var
  G0_GetMaxX : integer = 1024; {1024; {800;}
  G0_GetMaxY : integer =  768; { 768; {600;}

function ColWarnForeground(Bkg: Word): Word;
// 13.11.07 P.W
const
  ColWarn : Array [0..1] of Word = (C_LRed, C_Yellow);//, C_LBlue);
var
  I : Word;
  Dist, DistMax: Double;
begin
  DistMax := 0;
  Result := ColWarn[0];
  for I := Low(ColWarn) to High(ColWarn) do
  begin
    Dist := ColorDistNorm(Bkg, ColWarn[I]);
    if (Dist > DistMax) then
    begin
      Result := ColWarn[I];
      DistMax := Dist;
    end;
  end;
end;

{--------------------------------------------------------------------}


//Const
//  DefaultTextHeight =  18;  // until 22.06.04 P.W
function DefaultTextHeight: Integer;
// since 22.06.04 P.W
// this value has a significant influence on layout
// 21.07.06 P.W: Font size for printing not 0.66 but 0.85 of Font size for screen
// in the same step: TNHTool.pas no longer uses SetStandardBTextPrn
begin
  if Assigned(Graph0_DrawBmp) then
  begin
    Result :=  Round((20 / 911) * Min(Graph0_DrawBmp.Width, Graph0_DrawBmp.Height));
    if printeractiv then result := Round(0.85* Result);//Round(Result / 1.5); // 0.85* : 21.07.06 P.W
  end else
  begin
    Result :=  Round(0.02 * Screen.Height)
  end;
end;

function DefaultTextWidth: Integer;
begin
  DefaultTextWidth := (2 * DefaultTextHeight) div 3;
end;


Type
  TG0_Rec = packed Record
    CurX           : Smallint;
    CurY           : Smallint;
    VGColor        : Smallint;
    BkColor        : Smallint;
    FillSettings   : FillSettingsType;
    TextSettings   : TextSettingsType;
    ViewPort       : ViewPortType;
    LineSettings   : LineSettingsType;
    FillPattern    : FillPatternType;
    UserCharHeight : Integer;
    GraphDev       : TGraphDev;
    MyImage        : TImage;
    TextMode       : TTextMode;
  end;

Var
  G0_Rec           : TG0_Rec;

Procedure SetDefault_G0_Rec(Var G0_Rec: TG0_Rec);
// called during printing!

begin
  G0_Rec.CurX                   := 0;
  G0_Rec.CurY                   := 0;
  G0_Rec.VGColor                := G0_GetMaxColor;
  G0_Rec.BkColor                := 0;
  G0_Rec.FillSettings.Pattern   := SolidFill;
  G0_Rec.FillSettings.Color     := 0;

  G0_Rec.TextSettings.Font      := 0;
  G0_Rec.TextSettings.Direction := 0;
  G0_Rec.TextSettings.CharSize  := 0;
  G0_Rec.TextSettings.Horiz     := 0;
  G0_Rec.TextSettings.Vert      := 0;

  G0_Rec.ViewPort.x1            := 0;
  G0_Rec.ViewPort.y1            := 0;
  G0_Rec.ViewPort.x2            := G0_GetMaxX-1;
  G0_Rec.ViewPort.y2            := G0_GetMaxY-1;
  G0_Rec.ViewPort.Clip          := True;

  G0_Rec.LineSettings.LineStyle := 0;
  G0_Rec.LineSettings.Pattern   := $FFFF;
  G0_Rec.LineSettings.Thickness := 1;

  G0_Rec.FillPattern[1]         := $FF;
  G0_Rec.FillPattern[2]         := $FF;
  G0_Rec.FillPattern[3]         := $FF;
  G0_Rec.FillPattern[4]         := $FF;
  G0_Rec.FillPattern[5]         := $FF;
  G0_Rec.FillPattern[6]         := $FF;
  G0_Rec.FillPattern[7]         := $FF;
  G0_Rec.FillPattern[8]         := $FF;

  G0_Rec.UserCharHeight         := 18;
  G0_Rec.TextMode               := TM_Opaque;  // 25.10.04 P.W.
end;

{--------------------------------------------------------------------}
{
function TestDebug(Msg:String=''; DebMode:Integer=0): Boolean;
// 15.10.08 P.W
begin
  Result := False;
  if TestDebug_Enabled then
  begin
    Result := True;
    if (Msg <> '') and (DebMode <> 0) then;
    if (G0_Rec.CurX <> 0) then;
  end;
end;

function TestDebug(OkIfTrue:Boolean; Msg:String=''; DebMode:Integer=0): Boolean;
// 15.10.08 P.W
begin
  Result := False;
  if TestDebug_Enabled and (not OkIfTrue)then
  begin
    Result := TestDebug(Msg, DebMode);

  end;
end;
}
{--------------------------------------------------------------------}

function  CmdOut(DrawCmd: TDrawCmd;
                 P1: Smallint = 0; P2: Smallint = 0;
                 P3: Smallint = 0; P4: Smallint = 0;
                 P5: Smallint = 0): Pointer;
var
  DrawCmdRec : TDrawCmdRec;
begin
  DrawCmdRec.DrawCmd := DrawCmd;
  DrawCmdRec.si1     := P1;
  DrawCmdRec.si2     := P2;
  DrawCmdRec.si3     := P3;
  DrawCmdRec.si4     := P4;
  DrawCmdRec.si5     := P5;
  Result := CallDrawCmd(Graph0_DrawCanvas, DrawCmdRec);
end;

function  CmdOut(DrawCmd: TDrawCmd; R: TRect) : Pointer;
begin
  Result := CmdOut(DrawCmd, R.Left, R.Top, R.Right, R.Bottom);
end;


procedure CmdOutBrushColor(Color: Word; Col:TColor=NoColor);
// Modifications:
// 10.12.08 P.W: New Parameter Col; Aim allow direct use of TColor values instead of the limited colors of Color
begin
  if Col = NoColor then  // if: 10.12.08 P.W
    Col := Graph0Palette[Color].DelphiColor;  // Original: Use Color as Index
  Graph0_DrawCanvas.Brush.Color := Col;
end;

procedure CmdOutBrushPattern(Pattern: Word);
begin
  Case Pattern of
    CloseDotFill:
      Graph0_DrawCanvas.Brush.Style := bsDiagCross;
    else
      Graph0_DrawCanvas.Brush.Style := bsSolid;
  end;
end;

procedure CmdOutPenColor(Color: Word);
begin
  Graph0_DrawCanvas.Pen.Color := Graph0Palette[Color].DelphiColor;
end;

function  GetCoordLeft (Left: Smallint): Smallint;
begin
  Result := Left + G0_Rec.ViewPort.x1;
  G0_LastCoord.x1 := Result;
end;

function  GetCoordTop(Top: Smallint): Smallint;
begin
  Result := Top + G0_Rec.ViewPort.y1;
  G0_LastCoord.y1 := Result;
end;

function  GetCoordRight(Right: Smallint): Smallint;
begin
  Result := Right + G0_Rec.ViewPort.x1;
  G0_LastCoord.x2 := Result;
end;

function  GetCoordBottom(Bottom: Smallint): Smallint;
begin
  Result := Bottom + G0_Rec.ViewPort.y1;
  G0_LastCoord.y2 := Result;
end;

function  CmdOutCoord(Cmd: TDrawCmd; P1, P2, P3, P4: Smallint; P5:Smallint=0): Pointer;
begin
  Result :=
    CmdOut(
      Cmd,
      GetCoordLeft  (P1),
      GetCoordTop   (P2),
      GetCoordRight (P3),
      GetCoordBottom(P4),
      P5);
end;

Procedure CmdInit;
  Procedure Graph0PaletteInit;
  Var
    ColNum: Integer;
  begin
    For ColNum := 0 to Graph0PaletteMax do
    begin
      Graph0Palette [ColNum].DelphiColor :=
        ColNum + ColNum *256 + ColNum *256*256;
        //R + G *256 + B *256*256;
    end;
  end;

begin
  SetDefault_G0_Rec(G0_Rec);

  G0_Rec.GraphDev               := ScreenDev;
  G0_Rec.MyImage                := nil;

  FillChar(G0_LastCoord, SizeOf(G0_LastCoord), #0);
  Graph0PaletteInit;
end;

{--------------------------------------------------------------------}

procedure Bar(x1, y1, x2, y2: Smallint; Col:TColor=NoColor);
// if hatched: background is ever black ($00000000)!
// Modifications:
// 10.12.08 P.W: New Parameter Col; Aim allow direct use of TColor values instead of the limited colors of FillInfo.Color
Var
  FillInfo: FillSettingsType;      // only pattern and Color
  x, y : Integer;
  DitherWidth : Integer;
  DitherColor : TBmpCol;
  SL: PBmpArr;
begin
  GetFillSettings(FillInfo);
  Case FillInfo.Pattern of
    CloseDotFill:
      begin
        // simulate dithering found in UtKnPane.pas
        if PrinterActiv then
          DitherWidth := 4 else
          DitherWidth := 2;
        DitherColor := Graph0Palette[FillInfo.Color].DelphiBmpColor;
        CmdOutBrushPattern(SolidFill);
//        CmdOutBrushPattern(FillInfo.Pattern);  // sets brushstyle // only Black bachground!
//        CmdOutBrushColor(FillInfo.Color);
        // force the background:
        CmdOutBrushColor(G0_Rec.BkColor);
        CmdOutCoord(dc_Bar, x1, y1, x2, y2);
        CmdOutBrushColor(FillInfo.Color);

        // force the pattern:
        for y := y2 to y1-1 do
        begin
          SL := Graph0_DrawBmp.ScanLine[y+G0_Rec.ViewPort.Y1];
          for x := x1 to x2-1 do
            If ((x+y) Mod DitherWidth <> 0) xor PrinterActiv
//              then Graph0_DrawCanvas.Pixels[x+G0_Rec.ViewPort.x1, y+G0_Rec.ViewPort.Y1] := DitherColor;
              then SL[x+G0_Rec.ViewPort.x1] := DitherColor;
        end;
        CmdOutBrushColor(FillInfo.Color);
      end;
    else
      begin // "normal"
        CmdOutBrushColor(FillInfo.Color, Col); // Col: 10.12.08 P.W
        CmdOutBrushPattern(FillInfo.Pattern);  // sets brushstyle
        CmdOutCoord(dc_Bar, x1, y1, x2, y2);
      end;
  end;

  CmdOutBrushPattern(SolidFill);         // again SolidBrush
end;

procedure BarBG(x1, y1, x2, y2: Smallint);
Var
  FillInfo: FillSettingsType;      // only pattern and Color
begin
  GetFillSettings(FillInfo);
  CmdOutBrushPattern(SolidFill);         // use SolidBrush
  CmdOutBrushColor(G0_Rec.BkColor);
  CmdOutCoord(dc_Bar, x1, y1, x2, y2);
  CmdOutBrushColor(FillInfo.Color);
end;

procedure BarInv(x1, y1, x2, y2: Smallint);
Var
  FillInfo: FillSettingsType;      // only pattern and Color
begin
  GetFillSettings(FillInfo);
  CmdOutBrushPattern(SolidFill);         // use SolidBrush
  CmdOutBrushColor(G0_Rec.BkColor);
  CmdOutCoord(dc_BarInv, x1, y1, x2, y2);
  CmdOutBrushColor(FillInfo.Color);
end;

procedure DrawArrow(x0, y0, x1, y1, dA: Integer);
// 26.01.09 P.W

  function GetRotatedPoint(dPhiRad, dR: Double): tPoint;
  Var
    PMid, PRot     : t_point;
    PhiRad         : Double;
    IP             : Smallint;
  begin
    PMid.X := x1;
    PMid.Y := y1;

    PRot.X := x0;
    PRot.Y := y0;
    PhiRad := GetAngleRad(PMid, PRot);
    AddPointAngleFact    (PRot, PMid, PhiRad + dPhiRad, dR);

    Result.X := Round(PRot.X);
    Result.Y := Round(PRot.Y);
  end;

var
  I : Integer;
  PA0, PA1, PAm: TPoint;
begin
  Graph0.MoveTo(x0, y0);
  Graph0.LineTo(x1, y1);


  x0  := GetCoordLeft(x0);
  y0  := GetCoordTop (y0);
  x1  := GetCoordLeft(x1);
  y1  := GetCoordTop (y1);

  dA  := Abs(dA);
  PA0 := GetRotatedPoint( 45 * pi/180,       dA);
  PA1 := GetRotatedPoint(-45 * pi/180,       dA);
  PAm := GetRotatedPoint(  0 * pi/180, 0.4 * dA);
  ActivateGlbClipRegion(Graph0_DrawCanvas);
  Graph0_DrawCanvas.Polygon([PA0, Point(x1, y1), PA1, PAm]);
end;


procedure SetFillStyle(Pattern: Word; Color: Word);
begin
  G0_Rec.FillSettings.Pattern := Pattern; // 1:SolidFill; 11:CLOSEDOTFILL;
  G0_Rec.FillSettings.Color   := Color;
//  G0_Rec.BkColor := Color;
end;

function  GraphResult: Smallint;
begin
  GraphResult := GrOk;
end;

function  GetGraphMode: Smallint;
begin
  GetGraphMode := 0;  {1: Avoids BgiKrn.Pas inits graphic}
end;

function  GetMaxX: Smallint;
begin
  Result := G0_GetMaxX;
end;

function  GetMaxY: Smallint;
begin
  GetMaxY := G0_GetMaxY;
end;

function  GetMaxColor: Word;
begin
  GetMaxColor := G0_GetMaxColor;
end;

function  GetX: Smallint;
begin
  GetX := G0_Rec.CurX;
end;

function  GetY: Smallint;
begin
  GetY := G0_Rec.CurY;
end;

function  GetColor: Word;
begin
  GetColor := G0_Rec.VGColor;
end;

procedure GetTextSettings(var TextInfo: TextSettingsType);
begin
  TextInfo := G0_Rec.TextSettings;
end;

procedure GetViewSettings(var ViewPort: ViewPortType);
begin
  ViewPort := G0_Rec.ViewPort;
end;

procedure SetTextSize(CharSize: Word);
begin
  if CharSize = UserCharSize then
  begin
    CmdOut(dc_SetFontHeight, G0_Rec.UserCharHeight);
  end else
  begin  // "CharSize" is a factor!
    CmdOut(dc_SetFontHeight, CharSize*DefaultTextHeight);
  end;
end;

procedure SetTextMode(TextMode: TTextMode);
// 09.07.04 P.W
begin
  G0_Rec.TextMode := TextMode;
end;

procedure SetTextStyle(Font, Direction: Word; CharSize: Word);
// Direction: HorizDir=0 or VertDir=1
begin
  G0_Rec.TextSettings.Font      := Font;
  G0_Rec.TextSettings.Direction := Direction;
  G0_Rec.TextSettings.CharSize  := CharSize;
  CmdOut(dc_TextDir, Direction);
  SetTextSize(CharSize);
end;

procedure SetViewPort(x1, y1, x2, y2: Smallint; Clip: Boolean); overload;
begin
  G0_Rec.ViewPort.x1 := x1;
  G0_Rec.ViewPort.y1 := y1;
  G0_Rec.ViewPort.x2 := x2;
  G0_Rec.ViewPort.y2 := y2;
  G0_Rec.ViewPort.Clip := Clip;
  CmdOut(dc_SetClipRegion, x1, y1, x2, y2);
end;

procedure SetViewPort(ViewPort: ViewPortType); overload;
begin
  With ViewPort do
    SetViewPort(x1, y1, x2, y2, Clip);
end;

procedure SetColor(Color: Word);
begin
  G0_Rec.VGColor :=  Color;
  CmdOutPenColor(Color);
end;

procedure SetTextJustify(Horiz, Vert: Word);
// SetTextJustify(LeftText,BottomText)
begin
  G0_Rec.TextSettings.Horiz := Horiz;
  G0_Rec.TextSettings.Vert  := Vert;
end;

procedure  CmdOutText(Const S: AnsiString);
var
  DrawCmdRec : TDrawCmdRec;
begin
  DrawCmdRec.DrawCmd := dc_Text;
  DrawCmdRec.PAStr := @S;
  CallDrawCmd(Graph0_DrawCanvas, DrawCmdRec);
end;

Procedure CmdTextOut(X, Y: Smallint;
            Txt: String; TM: TTextMode); // 23.04.04 P.W
  function  CoordDx: Smallint;
  begin
    Result := G0_Rec.ViewPort.x1;
  end;
  function  CoordDy: Smallint;
  begin
    Result := G0_Rec.ViewPort.y1-TextHeight(Txt);
//    if  (G0_Rec.TextSettings.Vert = TopText)
//      then inc(Result, TextHeight(Txt));
//    if  (G0_Rec.TextSettings.Vert = TopText   ) then Txt[1]:='^';
//    if  (G0_Rec.TextSettings.Vert = BottomText) then Txt[1]:='v';
  // nearly all are bottom texts!
  end;
Var
  Len : Smallint;
  bStySave : TBrushStyle;
  bColSave: TColor;
begin
  Case TM of
    TM_UseSet:
      TM := G0_Rec.TextMode;
  end;
  Len := Length(Txt);
  If  (Len > 0) then
  begin
    bStySave  := Graph0_DrawCanvas.Brush.Style;
    bColSave  := Graph0_DrawCanvas.Brush.Color;

    Case TM of
      TM_Opaque:
        begin
          Graph0_DrawCanvas.Brush.Style := bsSolid;
          Graph0_DrawCanvas.Brush.Color :=
            Graph0Palette[G0_Rec.BkColor].DelphiColor;
        end;
      TM_Transparent:
        begin
          Graph0_DrawCanvas.Brush.Style := bsClear;
        end;
    end;
    CmdOut(dc_Move, X+CoordDx , Y+CoordDy, 0, 0);

    CmdOutText(Txt);

    if not assigned(Graph0_DrawCanvas.Brush.BitMap) then
    begin
      Graph0_DrawCanvas.Brush.Color := bColSave;
      Graph0_DrawCanvas.Brush.Style := bStySave;
    end;
  end;
end;

procedure GetTextDirectionSigns(var xSign, ySign: Integer);
begin
  If (G0_Rec.TextSettings.Direction = HorizDir) then
  begin
    xSign :=  1;     ySign :=  0;
  end else
  begin
    xSign :=  0;     ySign := -1;
  end;
end;

procedure OutTextXY_Mixed(X,Y: Smallint; const TextString: string; TM: TTextMode);
// s. 11.10.04 P.W.
// === "Mixture of proportional and block text": ===
// Text Words will be drawn proportional but each Text Word starts at a
// rastered position, Numbers if not in Text Word will be rastered;
// Text Words are separated by one of " ", ":", "[" if it is preceded by a Space.
// Single Spaces do not seperate text
// Rasterwidth is TextWidth of TextWidthBasisChar (this has to fit to TextWidth!)
// ===
// Example:
//-------------------------------------------------------
//  "Density :123.45    mg/cm^3"
//  "Area    : 45.45    %"
//-------------------------------------------------------
//  "Density    :  1 2 3 . 4 5           mg/cm^3"         (spaces exaguerated)
//  "Area       :    4 5 . 4 5           %"
//-------------------------------------------------------
// May be: duplicate spaces are not drawn, so partly the background may be not cleared
// modifications:
// 24.07.06 P.W: handle "-" as number to support rastered output also for negative numbers
var
  P : Integer;
  Ch : Char;
  xs, ys, dxy    : Integer;
  dStartXY, dEndXY : Integer;
  TextLen: Integer;
  PStart : Integer;
  TxWrd  : String;
  SpcCtr : Integer;
  InSpc    : Boolean;
  InTxt    : Boolean;

  Procedure SetLocVars;
  begin
    PStart   := 0;                   // [Characters]
    TextLen  := Length(TextString);  // [Characters]
    SpcCtr   := 0;                   // [Characters]
    TxWrd    := '';                  // Text Word
    InSpc    := False;
    InTxt    := False;
    dStartXY := 0;                   // Start of TextWord [Pixels] relative to XY
    dEndXy   := 0;                   // End of TextWord   [Pixels]
    dxy      := TextWidth(TextWidthBasisChar);
    GetTextDirectionSigns(xs, ys);
  end;

  Procedure SetInSpc(NewVal: Boolean);    Forward;

  Procedure SetInTxt(NewVal: Boolean);
  // True  to False: Draw TxWrd
  // False to True : Clear TxWrd and store startPos
  // When True     : append character
  var
    TxLen   : Integer;  // [Pixels]
    OverLen : Integer;  // [Pixels]
  begin
    If (NewVal <> InTxt) then
    begin
      InTxt := NewVal;
      if InTxt then
      begin   // a new Text Word starts
        TxWrd    := '';
        dStartXY := Max(dEndXy, dxy*(P-1));
        PStart   := P;
      end else
      begin
        TxLen    := Graph0_DrawCanvas.TextWidth(TxWrd);      // drawn length
        OverLen  := Max(0, TxLen - Graph0.TextWidth(TxWrd)); // if longer than estimated
        if ((PStart = 1) and (P=TextLen)) or
           ((PStart > 1) and (P<TextLen)) then
        begin
          Dec(dStartXY, OverLen div 2); // Center the Overlen
        end else
        if (P=TextLen) then
        begin
          Dec(dStartXY, OverLen);       // move to left
        end else
        begin
          ;                             // move to right
        end;
        if (TxWrd = '.') then
        begin
          Inc(dStartXY, (4*(dxy-TxLen)) div 13);  // center point in numbers
        end;
        dEndXy   := dStartXY + TxLen;
        CmdTextOut(X+xs*dStartXY, Y+ys*dStartXY, TxWrd, TM);
      end;
    end;

    If InTxt then
    begin
      SetInSpc(False);
      TxWrd := TxWrd + Ch;
    end;
  end;

  Procedure SetInSpc(NewVal: Boolean);
  // InText stays true for first space!
  begin
    If (NewVal <> InSpc) then
    begin
      InSpc := NewVal;
      SpcCtr := 0;
    end;

    if InSpc then
    begin
      Inc(SpcCtr);
      if (SpcCtr = 1) then
      begin
        If InTxt then TxWrd := TxWrd + Ch;// avoid SetInTxt(True) it would Reset SpcCtr by SetInSpc(false)!
      end else
      begin
        SetInTxt(False);
      end;
    end;
  end;

begin
//TM:=TM_Transparent; // 25.10.04 P.W. ? default assumed by SvComp ???
  SetLocVars;

  P := 0;
  While (P < TextLen) do  // avoid for loop (P used outside by SetInTxt)
  begin
    Inc(P);
    Ch := TextString[P];
    case Ch of
      '-',                      // "-" for negative numbers to be rastered: 24.07.06 P.W  
      '0'..'9','.':
           begin
             If InTxt then
             begin              // append character to TxWrd
               SetInTxt(True);  // call for InSpace!
             end else
             begin              // output character (rastered for tables with aligned numbers)
               SetInTxt(True);
               SetInTxt(False);
             end;
           end;
      ' ': SetInSpc(True);
      '|', ':', '[': if InSpc then
           begin                // output character
             SetInTxt(False);
             SetInTxt(True);
           end else
           begin                // append character to TxWrd
             SetInTxt(True);    // call for InSpace!
           end;
      else SetInTxt(True);
    end;
  end;
  SetInTxt(False);  // draw remaining
end;

procedure DrawUpDownArrow(X0, Y0, TW, TH: Integer);
var
  PutPixBmpCol : TColor;
  procedure PutPix(X, Y: Integer);
  begin
    Graph0_DrawScanLines[Y][X] := PutPixBmpCol;
  end;
var
  dxM           : Integer;
  dy, dy0, dyAr : Integer;
  ix, iy : Integer;
  XM, YT, YB : Integer;
begin
  dxM  :=  TW div  2;

  dy   :=  (4 * TH) div 5;                 // reduce height
  dy0  :=  TH - dy;

  XM   := X0 + dxM + G0_Rec.ViewPort.x1;   // XMid

  YT   := Y0 - dy  + G0_Rec.ViewPort.y1;   // YTop
  YB   := Y0 - dy0 + G0_Rec.ViewPort.y1;   // YBottom

  dyAr := (YB - YT +1) div 3;              // dyArrow

  PutPixBmpCol := Graph0Palette[G0_Rec.VGColor].DelphiBmpColor;
  for iy := 0 to dyAr do
  begin
    for ix := 0 to iy do
    begin
      PutPix(XM+ix, YT+iy);    // upper right side of arrow
      PutPix(XM-ix, YT+iy);    // upper left  side of arrow

      PutPix(XM+ix, YB-iy);    // lower right side of arrow
      PutPix(XM-ix, YB-iy);    // lower left  side of arrow
    end;
  end;

end;

procedure DrawRightArrow(X0, Y0, TW, TH: Integer);
// 07.11.07 P.W
var
  PutPixBmpCol : TColor;
  procedure PutPix(X, Y: Integer);
  begin
    Graph0_DrawScanLines[Y][X] := PutPixBmpCol;
  end;
var
  dxM           : Integer;
  dy, dy0, dyAr : Integer;
  ix, iy : Integer;
  XM, YT, YB : Integer;
begin
  dxM  :=  TW div  3;

  dy   :=  (4 * TH) div 5;                 // reduce height
  dy0  :=  TH - dy;

  XM   := X0 + dxM + G0_Rec.ViewPort.x1;   // XMid

  YT   := Y0 - dy  + G0_Rec.ViewPort.y1;   // YTop
  YB   := Y0 - dy0 + G0_Rec.ViewPort.y1;   // YBottom

  dyAr := (YB - YT +1) div 2;              // dyArrow

  PutPixBmpCol := Graph0Palette[G0_Rec.VGColor].DelphiBmpColor;
  for iy := 0 to dyAr do
  begin
    for ix := 0 to iy do
    begin
      PutPix(XM+ix, YT+iy);    // upper right side of arrow
//    PutPix(XM-ix, YT+iy);    // upper left  side of arrow

      PutPix(XM+ix, YB-iy);    // lower right side of arrow
//    PutPix(XM-ix, YB-iy);    // lower left  side of arrow
    end;
  end;

end;

procedure OutTextXY_Raster(X,Y: Smallint; const TextString: string; TM: TTextMode; dxy: Integer);
var
  P   : Integer;
  xs, ys : Integer;
  dStartXY : Integer;
  dw, ChW : Integer;
  Ch : Char;
begin
  GetTextDirectionSigns(xs, ys);
  if TM = TM_Opaque then
  begin
    BarBG(X,Y, X+TextWidth(TextString), Y-TextHeight);
    TM := TM_Transparent;
  end;

  For P:= 1 to Length(TextString) do
  begin
    Ch  := TextString[P];
    ChW := Graph0_DrawCanvas.TextWidth(Ch);
    dw  := (dxy - ChW) div 2;  // for center the characters
    dStartXY := dxy*(P-1) + dw;
    Case Ch of
      #18:   // Arrorw Up and Down
        begin
          DrawUpDownArrow(X+xs*dStartXY, Y+ys*dStartXY, ChW, TextHeight);
        end;
      #26: // "^Z" Arrow Right 07.11.07 P.W
        begin
          DrawRightArrow(X+xs*dStartXY, Y+ys*dStartXY, ChW, TextHeight);
        end
      else
        begin
          CmdTextOut(X+xs*dStartXY, Y+ys*dStartXY, Ch, TM);
        end;
    end;
    //CmdTextOut(X+xs*dStartXY, Y+ys*dStartXY, Ch, TM);
  end;
end;

type
  TStringList = Classes.TStringList;  // not Objects.TStringList !! // 11.10.04 P.W.

var
  FAsciiPage : TStringList = nil;           // 11.10.04 P.W.

function AsciiPage : TStringList;           // 11.10.04 P.W.
begin
  if not Assigned(FAsciiPage) then
    FAsciiPage := TStringList.Create;
  Result := FAsciiPage;
end;

procedure  AsciiPageAdd(XCh, YCh: Integer; TextString: AnsiString);   // 11.10.04 P.W.
// coordinates from 0, 0
var
  S                      : AnsiString;
  P, TxLen, MinLen, LenS : Integer;
begin
  // avoid negative values:
  XCh:= Max(XCh, 0);
  YCh:= Max(YCh, 0);

  // adapt number of lines
  While (YCh >= AsciiPage.Count) do
    AsciiPage.Append('');
  S := AsciiPage[YCh];
  TxLen  := Length(TextString);
  MinLen := TxLen + XCH;

  // Adapt length preseted with spaces
  LenS := Length(S);
  If (LenS < MinLen) then
  begin
    SetLength(S, MinLen);
    For P := LenS+1 to MinLen do
      S[P]:=' ';
  end;

  // insert the TextString
  For P := 1 to TxLen do
  begin
    if (S[XCh+P] = ' ') then
    begin
      S[XCh+P] := TextString[P];
    end else
    begin // Check overwritten by other
      if S[XCh+P] <> TextString[P] then
         S[XCh+P] := '@';  // "@" marks overwritten characters
    end;
  end;
  AsciiPage[YCh]:=S;
end;

Procedure OutTextAsciiPage(X,Y: Integer; TextString: AnsiString);   // 11.10.04 P.W.
begin
  X := X + G0_Rec.ViewPort.x1;
  Y := Y + G0_Rec.ViewPort.y1-TextHeight;
  AsciiPageAdd(2*X div DefaultTextHeight, 2*Y div DefaultTextHeight, TextString);
end;


function AsciiPrintFileName: String;
begin
  Result := FExpand(LocLogDir+'AsciiPrint.Txt');
end;
var
  OutTextF  : ^Text = nil;  // 11.10.04 P.W.


procedure CloseOutTextF;
begin
  if Assigned(OutTextF) then
  begin
    Close(OutTextF^);
    OutTextF := nil;
  end;
end;

procedure OutTextFile(X,Y: Smallint; TextString: AnsiString; AppendFlg:Boolean=False);   // 11.10.04 P.W.
begin
  if not Assigned(OutTextF) then
  begin
    New(OutTextF);
    Assign(OutTextF^, AsciiPrintFileName);
    if AppendFlg and FileExists(AsciiPrintFileName)
      then Append (OutTextF^)
      else Rewrite(OutTextF^);
  end;
  if (X < 0)
    then Writeln(OutTextF^, TextString)
    else Writeln(OutTextF^, Format('%4d %4d %s', [X, Y, TextString]));
end;


var
  PageCtr : Integer = 0;
Procedure SaveAsciiPage;
var
  I, P : Integer;
  S : AnsiString;
begin
  If Assigned(FAsciiPage) then
  begin
    Inc(PageCtr);
    OutTextFile(-1, 0, Format('v=== Page %2d ======================', [PageCtr]), PageCtr>1);

    // for each line
    For I:= 0 to AsciiPage.Count - 1 do
    begin
      S := AsciiPage[I];
      P := Length(S);

      // reduce trailing spaces
      While (P>0) and (S[P] = ' ') do Dec(P);
      SetLength(S, P);

      // detect nonprintable characters replace them by "@"
      for P:= 1 to Length(S) do
        if (S[P] < ' ') then S[P] := '@';

      // write only nonempty lines
      if (Length(S)>0) then
        OutTextFile(-1, I, S);
    end;
    OutTextFile(-1, 0, Format('^=== Page %2d ======================', [PageCtr]));

    CloseOutTextF;
  end;
end;

Procedure ClearAsciiPage;
begin
  If Assigned(FAsciiPage) then
  begin
    FreeAndNil(FAsciiPage);
  end;
end;

Procedure SaveClearAsciiPage;
begin
  SaveAsciiPage;
  ClearAsciiPage;
end;

procedure OutTextXY(X,Y: Smallint; const TextString: string;   // 11.10.04 P.W.
            TM: TTextMode=TM_UseSet; RasterMode:TRaster=TR_Default);
begin
  if PrinterActiv or TableActiv then
  begin
    OutTextAsciiPage(X, Y, TextString);
  end;
  Case RasterMode of
    TR_Default, TR_Mixed:
      OutTextXY_Mixed(X, Y, TextString, TM);
    TR_Prop:
      CmdTextOut(X, Y, TextString, TM);
    TR_Raster:
      OutTextXY_Raster(X, Y, TextString, TM,
        Graph0_DrawCanvas.TextWidth(TextWidthBasisChar));
  end;
end;

{                  //u. 11.10.04 P.W.
procedure OutTextXY(X,Y: Smallint; TextString: string;
            TM: TTextMode=TM_UseSet);
// formats only if a ":" found
var
  P : Integer;
begin
  P := PosEx(':',TextString,2);
  While (P > 1) do
  begin
    if (TextString[P-1] in ['0' .. '9']) then
    begin  // avoid Time "17:30" becomes  "17    : 30"
      P := PosEx(':',TextString,P+1);
    end else
    begin
      Break;
    end;
  end;
  If (P > 1) and (G0_Rec.TextSettings.Direction = HorizDir) then
  begin
    CmdTextOut(X,Y, Copy(TextString, 1, P-1), TM);
    Delete(TextString, 1, P-1);
    if (Length(TextString) >= 2) then
    begin
      if TextString[2] <> ' ' then Insert(' ', TextString, 2);
    end;
    OutTextXY(X+TextWidth(StringOfChar('X',P-1)),Y, TextString, TM);
  end else
  begin
    CmdTextOut(X, Y, TextString, TM);
  end;
end;
}

procedure OutText(const TextString: string;
            TM: TTextMode=TM_UseSet; RasterMode:TRaster=TR_Default);
begin
  OutTextXY(GetX, GetY, TextString, TM, RasterMode);
end;

procedure MoveTo(X, Y: Smallint);
begin
  G0_Rec.CurX := X;
  G0_Rec.CurY := Y;
end;

type
  TPointerRec = Record
    case integer of
      0: (Ptr1: Pointer);
      1: (s3, s4: Smallint);
  end;

//================================================
// since 08.07.04 simulate Turbo GetImage PutImage
// without use of harddisk
const
  MaxImgData = MaxLongInt - 16;
type
  tImgHead = packed record
    Size   : Integer;       // of record with data
    PixFmt : Integer;       // typecast to TPixelFormat
    Width  : Integer;
    Height : Integer;
  end;
  pImgData = ^TImgData;
  tImgData = packed record
    Head   : tImgHead;
    Data   : Array [0 .. MaxImgData-1] of byte;
  end;

function  ImageSize(x1, y1, x2, y2: Integer): Integer;
// result must be limited to range of Word (64 K)
// if size is above 64 K then return 0!
// for use by KnMulti.exe ... which checks this
// and reduces the size as in  unit TNHTool.pas
//  Procedure   TNBigBitMap.Catch;
begin
//Result := Disk_ImageSize(x1, y1, x2, y2); EXIT;

  Result := SizeOf(tImgHead) +
            SizeOF(TBmpCol)
            * (1 + abs(x2-x1))
            * (1 + abs(y2-y1));
  if Result >= MaxWord-16 then
  begin
//    ShowMessageFmt('ImageSize %d is too high for Word', [Result]);
    Result := 0; // behavior of Turbo Pascal Unit Graph
  end;
end;

procedure GetImage(x1, y1, x2, y2: Integer; var BitMap);
// assumes BitMap supports enough memory for the data!
// Modifications:
// 29.03.05 P.W avoid crash when coordinates are outside limits:
// crash occured where y2 equals GetMaxY: "ScanLine out of Range"
//  Force Values into Range 0..GetMaxXY-1
var
  y        : Integer;
  SL       : PBmpArr;
  LineSize : Integer;
  DataAim  : Integer;
begin
//Disk_GetImage(x1, y1, x2, y2, BitMap);    EXIT;
  // the New routines lead to crash in KnMulti.exe!
  SortInt(x1, x2);
  SortInt(y1, y2);

  // --- force coordinates into valid range --- s.: 29.03.05 P.W
  x1 := Max(0, Min(x1, GetMaxX-1));
  x2 := Max(0, Min(x2, GetMaxX-1));
  y1 := Max(0, Min(y1, GetMaxY-1));
  y2 := Max(0, Min(y2, GetMaxY-1));

  with TImgData(BitMap), Head do
  begin
    Size   := ImageSize(x1, y1, x2, y2);
    PixFmt := Integer(Graph0_DrawBmp.PixelFormat);
    Width  := (1 + x2 - x1);
    Height := (1 + y2 - y1);

    DataAim := 0;
    LineSize := Width * SizeOF(TBmpCol);

    for y := y1 to y2 do
    begin
      SL := Graph0_DrawBmp.ScanLine[y];
      Move(SL[x1], Data[DataAim], LineSize);
      Inc(DataAim, LineSize);
    end;
  end;
end;

procedure PutImage(x0, y0: Integer; var BitMap; BitBlt: Word);
var
  y        : Integer;
  SL       : PBmpArr;
  LineSize : Integer;
  DataAim  : Integer;
begin
//Disk_PutImage(x0, y0, BitMap, BitBlt);    EXIT;

  with TImgData(BitMap), Head do
  begin
    if (PixFmt = Integer(Graph0_DrawBmp.PixelFormat)) then
    begin
      DataAim := 0;
      LineSize := Width * SizeOF(TBmpCol);
      for y := 0 to Height -1 do
      begin
        SL := Graph0_DrawBmp.ScanLine[y0 + y];
        Move(Data[DataAim], SL[x0], LineSize);
        Inc(DataAim, LineSize);
      end;
    end;
  end;
end;
//================================================

function  TextWidth(TextString: string): Word;
// 11.10.04 P.W. : Proportional to length of Text to fit to OutTextXY
begin
  Result := Graph0_DrawCanvas.TextWidth(TextWidthBasisChar) * Length(TextString); // 11.10.04 P.W.
  //Result := Graph0_DrawCanvas.TextWidth(TextString);     // u. 11.10.04 P.W.
end;

function  TextHeight(TextString: string='gX'): Word;
begin
  Result := Graph0_DrawCanvas.TextHeight(TextString);
end;

procedure GetAspectRatio(var Xasp, Yasp: Word);
begin
  Xasp:= 8;
  Yasp:= 8;
end;

procedure Rectangle(x1, y1, x2, y2: Smallint);
begin
  G0_Rec.CurX := x2;
  G0_Rec.CurY := y2;
  CmdOutCoord(dc_Rect, x1, y1, x2, y2);
end;

procedure RectangleAbs(x1, y1, x2, y2: Smallint);
begin
  G0_Rec.CurX := x2;
  G0_Rec.CurY := y2;
  CmdOut(dc_Rect, x1, y1, x2, y2);
end;

procedure SetUserCharSize(MultX, DivX, MultY, DivY: Word);
begin
  G0_Rec.UserCharHeight := (DefaultTextHeight * MultY) div DivY;
  SetTextSize(UserCharSize);
end;

procedure PutPixel(X, Y: Smallint; Color: Word);
// Paints relative to G0_Rec.ViewPort.x1/y1
// Modifications:
// 29.03.05 P.W correction: Check for Y was missing (two times X)
// 24.06.05 P.W correction: Maximum is x2-1, y2-1
//  use of Graph0_DrawScanLines is critical: never Assign Graphic to
//  Graph0_DrawBmp!
// 30.09.05 P.W Support XORMode using slower call of CmdOutCoord
// 22.08.06 P.W correction: use GetCoordLeft/Top
begin
  G0_Rec.CurX := X;
  G0_Rec.CurY := Y;
  CmdOutPenColor(Color);

  if (Graph0_DrawCanvas.Pen.Mode <> pmCopy) then  // if: 30.09.05 P.W
  begin               // for pmXor
    CmdOutCoord(dc_Pixel, x, y, 0, 0);         // used since 30.09.05 P.W
  end else
  begin
    X := GetCoordLeft(X);   // correction for KnMulti ContPixShow 22.08.06 P.W 
    Y := GetCoordTop (Y);   // correction for KnMulti ContPixShow 22.08.06 P.W
                            // SvComp, FemurPc use Viewport.x1/y1 : 0/0
    // is quicker: (but does not take care about pmXor)
    if (X >= G0_Rec.ViewPort.x1) and (X < G0_Rec.ViewPort.x2) and
       (Y >= G0_Rec.ViewPort.y1) and (Y < G0_Rec.ViewPort.y2) then // X->Y 29.03.05 P.W
      Graph0_DrawScanLines[Y][X] := Graph0Palette[Color].DelphiBmpColor;
    Graph0_DrawBmp.Modified    := True;  // not ever neccessary because done by others
  end;
end;

function  GetPixel(X, Y: Smallint): TColor;
begin
  G0_Rec.CurX := X;
  G0_Rec.CurY := Y;
  Result := Integer(CmdOutCoord(dc_GetPixel, x, y, 0, 0));
end;

procedure SetWriteMode(WriteMode: Smallint);
begin
  Case WriteMode of
    XorPut : CmdOut(dc_PenXor ,0,0,0,0);
    else     CmdOut(dc_PenNorm,0,0,0,0);
  end;
end;

procedure GetFillSettings(var FillInfo: FillSettingsType);
begin
  FillInfo := G0_Rec.FillSettings;
end;

procedure GetLineSettings(var LineInfo: LineSettingsType);
begin
  LineInfo := G0_Rec.LineSettings;
end;

procedure SetLineStyle(LineStyle: Word; Pattern: Word; Thickness: Word);
{ Pascal.Graph:
    Linienarten
    SolidLn   0
    DottedLn  1
    CenterLn  2
    DashedLn  3
    UserBitLn 4 (selbstdefinierbare Linienart)

    Linienbreiten:
    NormWidth  1
    ThickWidth 3
  Delphi.Graph:
}
type  TDelhiPenStyle = (psSolid, psDash, psDot,
                        psDashDot, psDashDotDot, psClear, psInsideFrame);
var
  DelphiLineStyle    : TDelhiPenStyle;
  DelphiPattern,
  DelphiWidth        : SmallInt;
begin
  G0_Rec.LineSettings.LineStyle := LineStyle;
  G0_Rec.LineSettings.Pattern   := Pattern;
  G0_Rec.LineSettings.Thickness := Thickness;
  Case LineStyle of
    SolidLn    : DelphiLineStyle := psSolid;
    DottedLn   : DelphiLineStyle := psDot;
    CenterLn   : DelphiLineStyle := psDashDot;
    DashedLn   : DelphiLineStyle := psDash;
    UserBitLn  : DelphiLineStyle := psDashDotDot;
    else         DelphiLineStyle := psSolid;
  end;

  DelphiWidth := Thickness;

  // If (Graph0_DrawBmp.Height > 1500) then
  // case ThickNess of
  //  1..3: DelphiWidth := Thickness + 2;
  //   else  DelphiWidth := Thickness * 2;
  // end;

  DelphiPattern := 0 * Pattern;

  CmdOut(dc_LineStyle,
         Ord(DelphiLineStyle),
         DelphiWidth,
         DelphiPattern,
         0);
end;

procedure FloodFill(X, Y: Smallint; BorderColor: Word);
var
  SaveColor : TColor;
begin
  SaveColor := Graph0_DrawCanvas.Brush.Color;

  Graph0_DrawCanvas.Brush.Color:=Graph0Palette[G0_Rec.FillSettings.Color].Delphicolor;
  ActivateGlbClipRegion(Graph0_DrawCanvas);  // for b) after ShowMessage
  Graph0_DrawCanvas.FloodFill(
    X+G0_Rec.ViewPort.x1,
    Y+G0_Rec.ViewPort.y1,
//  Graph0_DrawCanvas.Pixels[X+G0_Rec.ViewPort.x1, Y+G0_Rec.ViewPort.y1], fsSurface); // a)
    Graph0Palette[BorderColor].DelphiColor, fsBorder);                                // b)    <--
  // a) fills all connected points of same color
  // b) fills until color is reached needs closed border and/or valid Clipregion

  Graph0_DrawCanvas.Brush.Color := SaveColor;
end;

procedure Activate8bitRgbPalette;
// adapted using graphics.CopyPalette
var
  Palette     : HPALETTE;
  PaletteSize : Integer;
  LogPal      : TMaxLogPalette;
  I           : Integer;
begin
  // only for pf8bit:
  if (Graph0_DrawBmp.PixelFormat <> pf8bit)
    then EXIT;
  // instead of parameter Palette:
  Palette := Graph0_DrawBmp.Palette;

  if Palette = 0 then Exit;
  PaletteSize := 0;
  if GetObject(Palette, SizeOf(PaletteSize), @PaletteSize) = 0 then Exit;
  if PaletteSize = 0 then Exit;
  with LogPal do
  begin
    palVersion := $0300;
    palNumEntries := PaletteSize;
    GetPaletteEntries(Palette, 0, PaletteSize, palPalEntry);

    // added:
    for I := 0 to PaletteSize -1 do
    begin
      palPalEntry[I].peRed   := Graph0Palette[I].R;
      palPalEntry[I].peGreen := Graph0Palette[I].G;
      palPalEntry[I].peBlue  := Graph0Palette[I].B;
      palPalEntry[I].peFlags := 0;
    end;
  end;

  // instead of result set directly:
  Graph0_DrawBmp.Palette :=
    CreatePalette(PLogPalette(@LogPal)^);
end;

procedure SetRGBPalette(ColorNum, RedValue, GreenValue, BlueValue: Integer;
            ActivatePal: Boolean = False);
// 29.06.04 P.W:
// Parameter ActivatePal added
begin
  If (ColorNum >= 0) and (ColorNum <= Graph0PaletteMax) then
  begin
    Graph0Palette[ColorNum].R := RedValue;
    Graph0Palette[ColorNum].G := GreenValue;
    Graph0Palette[ColorNum].B := BlueValue;
    Graph0Palette[ColorNum].DelphiColor :=
      RedValue + (GreenValue shl 8) + (BlueValue shl 16);
    if Graph0_DrawBmp.PixelFormat = pf8bit then
    begin
      Graph0Palette[ColorNum].DelphiBmpColor :=
        ColorNum;
      if ActivatePal then
        Activate8bitRgbPalette;
    end else
    begin
      Graph0Palette[ColorNum].DelphiBmpColor :=
        GetBmpColor(Graph0Palette[ColorNum].DelphiColor, Graph0_DrawBmp.PixelFormat);
    end;
  end;

end;

procedure SetRGBPalette(ColorNum: Integer; Col: TColor;
            ActivatePal: Boolean = False);
// 13.11.07 P.W
type
  TColRGB = packed Record   // is for TColor
    case Integer of
      0: (C: Integer);
      1: (R, G, B, S: Byte);
  end;
begin
  SetRGBPalette(ColorNum, TColRGB(Col).R, TColRGB(Col).G, TColRGB(Col).B, ActivatePal);
end;

function  ColorDistNorm(ColIdx0, ColIdx1: Word): Double;
// 13.11.07 P.W
// normalized to 0.0 ... 1.0 !
var
  R0, G0, B0,
  R1, G1, B1 : Double;
begin
  R0 := Graph0Palette[ColIdx0].R / 255;
  G0 := Graph0Palette[ColIdx0].G / 255;
  B0 := Graph0Palette[ColIdx0].B / 255;
  R1 := Graph0Palette[ColIdx1].R / 255;
  G1 := Graph0Palette[ColIdx1].G / 255;
  B1 := Graph0Palette[ColIdx1].B / 255;
  Result := sqrt((sqr(R0 - R1) + sqr(G0 - G1) + sqr(B0 - B1))/3);
end;

function  GetBkColor: Word;
begin
  GetBkColor := G0_Rec.BkColor;
end;

procedure Circle(X,Y: Smallint; Radius: Word);
begin
  G0_Rec.CurX := X;
  G0_Rec.CurY := Y;

  CmdOutPenColor(GetColor);

  CmdOut(dc_Circle, GetCoordLeft (X), GetCoordTop(Y), Radius, 0);
end;

procedure PieSlice(X, Y: Smallint; StAngle, EndAngle, Radius: Word);
// StAngle, EndAngle in degree
var
  FillInfo: FillSettingsType;
begin
  G0_Rec.CurX := X;
  G0_Rec.CurY := Y;

  CmdOutPenColor(GetColor);

  GetFillSettings(FillInfo);
  CmdOutBrushColor(FillInfo.Color);

  CmdOut(dc_PieSlice, GetCoordLeft (X), GetCoordTop(Y), StAngle, EndAngle, Radius);
end;

procedure Bar3D(x1, y1, x2, y2: Smallint; Depth: Word=0; Top: Boolean=False);
begin
  Bar(x1, y1, x2, y2);
  Rectangle(x1, y1, x2, y2);  
end;

procedure SetBkColor(ColorNum: Word);
begin
  G0_Rec.BkColor := ColorNum;
  G0_Rec.Fillsettings.Color := ColorNum;
  CmdOutBrushColor(ColorNum);
end;

function  ChkSetThickPenWidth: Integer;
// returns previous width
begin
  Result := Graph0_DrawCanvas.Pen.Width;
  If (Graph0_DrawBmp.Height > 2*MinPrintHeightWidth) and   // 1500 -> 2*MinPrintHeightWidth : 02.08.06 P.W
     (Graph0_DrawCanvas.Pen.Width = 1)
  then Graph0_DrawCanvas.Pen.Width := 3;
end;

procedure SetPenWidth(PenWidth: Integer);
begin
  Graph0_DrawCanvas.Pen.Width := PenWidth;
end;

procedure UserBitLineY(x1, y1, x2: Integer);
// may be slow: a) PutPixel, b) calculation
//  without bresenham
var
  Pattern : Word;
  ColBmp : TBmpCol;
  PatternBit    : Word;
  SL : PBmpArr;
begin
  // display coordinates:
  x1 := GetCoordLeft  (x1);
  y1 := GetCoordTop   (y1);
  x2 := GetCoordRight (x2);

  Pattern := G0_Rec.LineSettings.Pattern;
  ColBmp  := Graph0Palette[G0_Rec.VGColor].DelphiBmpColor;

  SortInt(x1, x2);
  SL := Graph0_DrawBmp.ScanLine[y1];
  PatternBit := 1;

  if Graph0_DrawCanvas.Pen.Mode = pmXor
  then // xor drawing
    while x1 <= x2 do  // draw including last point
    begin
      if ((PatternBit and Pattern) <> 0) then
        SL[x1] := ColBmp xor SL[x1];
      PatternBit := PatternBit Shl 1;
      if PatternBit = 0
        then PatternBit := 1;
      inc(x1);
    end
  else // normal drawing
    while x1 <= x2 do  // draw including last point
    begin
      if ((PatternBit and Pattern) <> 0) then
        SL[x1] := ColBmp;
      PatternBit := PatternBit Shl 1;
      if PatternBit = 0
        then PatternBit := 1;
      inc(x1);
    end

end;
procedure UserBitLine(x1, y1, x2, y2: Integer);
// may be slow: a) PutPixel, b) calculation
//  without bresenham
var
  Pattern : Word;
  PixCtr, PixDist  : Integer;
  dx, dy, ddx, ddy  : Double;
  x, y, dist    : Double;
  Color : Smallint;
  PatternBit    : Word;
begin
  if (y1 = y2) then
  begin
    UserBitLineY(x1, y1, x2);
    EXIT;
  end;
  // display coordinates:
  x1 := GetCoordLeft  (x1);
  y1 := GetCoordTop   (y1);
  x2 := GetCoordRight (x2);
  y2 := GetCoordBottom(y2);

  Pattern := G0_Rec.LineSettings.Pattern;
  Color   := G0_Rec.VGColor;
  dx := x2 - x1;
  dy := y2 - y1;

  x  := x1;
  y  := y1;
  dist := sqrt(sqr(dx) + sqr(dy));
  ddx := dx / dist;
  ddy := dy / dist;
  PixDist := Round(dist);
  PixCtr  := 0;
  PatternBit := 1;
  while PixCtr < PixDist do
  begin
    if (PatternBit and Pattern) <> 0 then
      PutPixel(Round(x), Round(y), Color);

    x := x + ddx;
    y := y + ddy;
    inc(PixCtr);
    PatternBit := PatternBit Shl 1;
    if PatternBit = 0 then PatternBit := 1;
  end;

end;

procedure Line(x1, y1, x2, y2: Smallint);
begin
  G0_Rec.CurX := x2;
  G0_Rec.CurY := y2;
  if (G0_Rec.LineSettings.LineStyle = UserBitLn)
  then UserBitLine(x1, y1, x2, y2)
  else CmdOutCoord(dc_Line, x1, y1, x2, y2);
end;

procedure LineTo(X, Y: Smallint);
Var
  WX, WY : Smallint;
begin
  // If (Graph0_DrawBmp.Height > 1500) and
  //    (Graph0_DrawCanvas.Pen.Width = 1)
  //   then Graph0_DrawCanvas.Pen.Width := 3;

  WX := GetX;
  WY := GetY;
  G0_Rec.CurX := X;
  G0_Rec.CurY := Y;
  CmdOutCoord(dc_Line, WX, WY, X, Y);
end;

function  SetMaxViewPort(Clip:Boolean=True): ViewPortType;
begin
  GetViewSettings(result);
  SetViewPort(0, 0, GetMaxX, GetMaxY, Clip);
end;

procedure ClearPage(Color: SmallInt = C_Black);
// makes sense post FitSysColors
// 10.06.05 P.W: support color of parent ScrollBox1 of frmMain
begin
  Inc(ClearPageCtr);  // give objects a chance to refresh themselfes
  CrtCurWanted:= False;
  CmdOutBrushColor(Color);
  CmdOutBrushPattern(SolidFill);
  SetMaxViewPort;
  With G0_Rec.ViewPort do
    CmdOutCoord(dc_Bar, x1, y1, x2+1, y2+1);
  if G0_Rec.MyImage.Parent is TScrollBox then  // 10.06.05 P.W
    TScrollBox(G0_Rec.MyImage.Parent).Color :=
      Graph0Palette[Color].DelphiColor;

end;
{--------------------------------------------------------------------}
(* vvv--- from Boiler *)            // 23.04.04 P.W

Procedure MybeginPage;
begin
  case G0_Rec.GraphDev of
    PrintDev:
      begin
        ClearPage;
        PrintForm.frmPrint.ModalResult := 0;  // 08.01.07 P.W
      end;
  end;
//  ShowMessage('MyBeginPage');
end;

Function  MyEndPage : Boolean;       // 23.04.04 P.W
// 08.01.07 P.W: returns false when printform.modalresult = mrAbort
begin
  Result := True;
  if PrintInvBW then
    InvertBlackWhite(
      PrintForm.frmPrint.ImgPrint.Picture.Bitmap);

  if PreViewFlg or PrintForcePreView then
  begin
    if PrintForm.frmPrint.Showing then
      PrintForm.frmPrint.Hide;
    PrintForm.frmPrint.ShowModal;
  end else
  begin
    if not DTPFlg then
    begin
      PrintForm.frmPrint.Show; //  08.01.07 P.W
      PrintForm.frmPrint.ImgPrint.Refresh;
      PrintForm.frmPrint.btnPrintClick(nil);
    end;
  end;
  SaveClearAsciiPage; // 11.10.04 P.W.
  ClearPage;
  Result := (PrintForm.frmPrint.ModalResult <> mrAbort); // 08.01.07 P.W
end;

function GetFontSmoothing: BOOL;
begin
  SystemParametersInfo(SPI_GETFONTSMOOTHING, 0, @Result, 0);
end;

var
  InitialFontSmoothing : (IFS_Unknown, IFS_Off, IFS_On) = IFS_Unknown;
procedure SetFontSmoothing(OnFlg: Boolean);
begin
  EXIT;   // ##DEBUG!
  if InitialFontSmoothing = IFS_Unknown then  // to give a chance to restore original mode
  begin
    if GetFontSmoothing
      then InitialFontSmoothing := IFS_On
      else InitialFontSmoothing := IFS_Off;
  end;
  SystemParametersInfo(SPI_SETFONTSMOOTHING, UINT(OnFlg), nil, 0);
end;

var
  SaveScreenImage: TImage = nil;
  SaveGraphSystem : PGraphSystem = nil;

Function  MyEnterGraphics(SelectDev: TGraphDev): Integer;
  procedure SetPrintDiv;  // 22.09.04 P.W
  //
  // a) calculate MinExtend = Minimum(Width, Height) of FramedPrintRect
  // b) Find PrintDiv so that MinExtend div PrintDiv is not above 2400; aim: avoid too large images 
  // c) set caption of frmPrint
  var
    PFW, PFH : Integer;
    PrnCaption : String;
  begin
    PFW := GetFramedPrintWidth;
    PFH := GetFramedPrintHeight;
    PrintDiv := Min(PFW, PFH) div MinPrintHeightWidth;
    if PrintDiv < 1 then PrintDiv := 1;

//    if (Win32Platform = VER_PLATFORM_WIN32_WINDOWS) then
//      printDiv := 1;  // maybe Printer.Canvas.StretchDraw is not supported

    if (FixedPrintRes <> PR_PrnOpt) then PrintDiv := 1;

    if not (FixedPrintRes in  [PR_PrnOpt, PR_Prn1_1]) then
    begin
      PrintDiv := 1;
      PrnCaption := // PrintForm.frmPrint.Caption :=
        Format('frmPrint (%d*%d) fixed!', [FixedPrintResDx, FixedPrintResDy])
    end else
    if PrintDiv = 1
    then
      PrnCaption := // PrintForm.frmPrint.Caption :=
        Format('frmPrint (%d*%d)', [PFW, PFH])
    else
      PrnCaption := // PrintForm.frmPrint.Caption :=
        Format('frmPrint (%dx%d)/(%dx%d) -> (%dx%d)',
        [PFW, PFH, PrintDiv, PrintDiv, PFW div PrintDiv, PFH div PrintDiv]);

    PrintForm.frmPrint.Caption :=
      Format(TraS('XCT Print Preview; Printer: "%s"'), [PrinterName]);
  end;

begin
  Result := 0;
  If (SelectDev <> G0_Rec.GraphDev) then
  begin
    Case SelectDev of
      ScreenDev:
        begin
 ////         Application.MainForm.WindowState:=wsMaximized; // u. 25.11.05 P.W
          //wsMaximized avoids crash in TMenuApp.pas
          //TMenPane.DeltaX when user minimized screen  // should be not a problem
                                              // since Screen is not adapted
                                              // 

          DeltaAppProcMsgSec := DeltaAppProcMsgSecDef;
          PrinterActiv := False;
          if Assigned(SaveScreenImage) then
            Graph0_Init(SaveScreenImage, False);
          if Assigned(SaveGraphSystem) then
          begin
            Proc_SetGraphSystem(SaveGraphSystem);
            Dispose(SaveGraphSystem);
            SaveGraphSystem := nil;
          end;
          ButtonsInvalid := True;  // for KnMultiDelphi TMenuApp
          PrintForm.frmPrint.Hide;
        end;
      PrintDev:
        begin
          PrintForm.frmPrint.WindowState := wsMaximized;
          PrintForm.frmPrint.ModalResult := 0;  // 08.01.07 P.W
          if not DTPFLG then
            PrintForm.frmPrint.Show;
          SaveScreenImage := G0_Rec.MyImage;
          If Assigned(Func_GetGraphSystem) then
          begin
            SaveGraphSystem := Func_GetGraphSystem(nil);
          end;
          if DTPFlg then  // if DTPFlg s.: 31.03.05 P.W
          begin // 31.03.05 P.W
            PrintDiv := 1;
            Graph0_Init(PrintForm.frmPrint.imgPrint,
              True,
              DTPWidth,
              DTPWidth);
          end else
          begin
            SetPrintDiv;  // 22.09.04 P.W
  //          ShowMessageFmt('Printer Name:%s Width:%d, Height:%d',
  //            [Printer.Printers[Printer.PrinterIndex],
  //             Printer.PageWidth, Printer.PageHeight]);
            if (FixedPrintRes in [Pr_PrnOpt]) then
            begin
              Graph0_Init(PrintForm.frmPrint.imgPrint,
                True,
                GetFramedPrintWidth div PrintDiv,
                GetFramedPrintHeight div PrintDiv);
                // ^-- if reduced by 0.5*0.8 then white is dithered
                // on Hp DeskJet 690 C  // reason pf16Bit?
            end else
            begin
              Graph0_Init(PrintForm.frmPrint.imgPrint,
                True,
                FixedPrintResDx,
                FixedPrintResDy);
            end;
          end;

          PrintForm.frmPrint.cbxStretch.Checked:=True;
          PrintForm.frmPrint.cbxStretchClick(nil);
          DeltaAppProcMsgSec := 1.0;
        end;
    end;
    G0_Rec.GraphDev := SelectDev;
  end;
end;

Procedure MyExitGraphics;
begin
  Case G0_Rec.GraphDev of
    ScreenDev:
      begin
      end;
    PrintDev:
      begin
        MyEnterGraphics(ScreenDev);
      end;
  end;
end;
(* ^^^--- from Boiler *)            // 23.04.04 P.W
{--------------------------------------------------------------------}

procedure OnChange(Sender: TObject);// of object;
begin
end;

procedure SetSysColors;
// from UtColor.pas Procedure   TColor.FitSysColors;
// Modifications:
// 26.07.04 P.W
// Invert Black and White Palette here for Printer
// otherwise Windows System smoothing of fonts is bad when
// later only the black and White are exchanged (the gray values are not inverted)
// Also changed:
//  a) BGIKrn.pas Function InitPrinter set PrinterActiv earlier
//  b) GraphGlb.pas procedure InvertBlackWhite no longer inverts
//     pure Black and White, but continues to adapt AddWhite and AddBlack
//  c) UtKnPane
// 25.10.04 P.W.: C_LGreen like C_Green for Printouts
begin
  // since 22.07.04 P.W support C_White .. as constants

  if PrinterActiv or ScreenInvBW then                        // if: 26.07.04 P.W
  begin  // invert black and white here       // 26.07.04 P.W
    SetRGBPalette(C_White   ,   0,   0,   0);
    SetRGBPalette(C_AddBlack, 255, 255, 255);
    SetRGBPalette(C_Black   , 255, 255, 255);
    SetRGBPalette(C_BackGrnd_Head, BackGrnd_Head_Print); // 13.11.07 P.W
  end else
  begin      // normal for display
    SetRGBPalette(C_White   , 255,  255, 255);
      // Results in Graph0Palette[255](16777215, 65535, 255, 255, 255)
      //                               ^         ^      R,   G,   B : Byte;
      //                               |         DelphiBmpColor : TBmpCol;
      //                               DelphiColor : TColor;
      // 16777215 = $FFFFFF;   65535 = $FFFF;  on screen: 255 255 255

    SetRGBPalette(C_Black   ,   0,   0,   0);
    SetRGBPalette(C_AddBlack,   0,   0,   0);
    SetRGBPalette(C_BackGrnd_Head, BackGrnd_Head_Screen); // 13.11.07 P.W
  end;

  SetRGBPalette(C_Yellow   , 255, 255,  85);  {LC[6]}  // compare StartMeasDialogs.pas cl_LightYellow
  SetRGBPalette(C_Orange   , 255, 170,   0);  {LC[4]}

  SetRGBPalette(C_LRed     , 255,   0,   0);  {LC[2]}  // s.: 25.10.04 P.W.

  SetRGBPalette(C_Red      , 170,   0,   0);  {LC[7]}

//SetRGBPalette(C_Blue     ,   0,   0, 255);  {LC[3]}  // u.: 25.10.04 P.W.
  SetRGBPalette(C_Blue     ,   0,   0, 190);  {LC[3]}  // s.: 25.10.04 P.W. more dark

  SetRGBPalette(C_LBlue    , 170, 255, 255);  {LC[5]}

  if PrinterActiv then      // 25.10.04 P.W. C_LGreen less bright for printing
  SetRGBPalette(C_LGreen   ,   0, 180,   0)   {LC[1]}     // 25.10.04 P.W.
    else
  SetRGBPalette(C_LGreen   , 170, 255,  85);  {LC[1]}

  {v--- added constants 21.01.02 P.W}
  SetRGBPalette(C_AddWhite , 250, 250, 250);    // pf16bit: 255, 251, 255 (on Screen!) : Reason : Draw with Delphicolor on canvas of 16 Bit Bitmap which is drawn to screen
                                                // DelphiColor = 16448250 = $FAFAFA;
                                                // DelphiBmpColor = 65503 = $FFDF = bin: 11111 111110 11111  = 31 62 31
                                                // (16448250, 65503, 250, 250, 250)
  SetRGBPalette(C_LCyan    ,   0, 252, 252);
  SetRGBPalette(C_LMagenta , 176,   0, 252);
  SetRGBPalette(C_LGray    , 160, 160, 160);
  SetRGBPalette(C_DGray    ,  52,  52,  52);
  SetRGBPalette(C_Green    ,   0, 112,   0);
  SetRGBPalette(C_Cyan     ,   0, 112, 112);
  SetRGBPalette(C_Magenta  , 112,   0, 112);
  {^--- added constants 21.01.02 P.W}

  SetRGBPalette(C_BlackEver,   8,   4,   8);  // 29.06.07 P.W
       // 4,4,4 -> 0,4,0     // values on screen for pf16bit: R div 8; G div 4; B div 8;
       // 5,5,5 -> 0,4,0
       // 8,4,8 -> 8,4,8
       // 9,9,9 -> 8,8,8

  Activate8bitRgbPalette;
end;

procedure Graph0_Init(aImage: TImage;
            ClearFlg: Boolean = True;
            ImgWidth: Integer = 0;
            ImgHeight: Integer = 0);
// Modifications:
begin
  ChkDelGlbClipRegion; // 11.10.04 P.W.
  G0_Rec.MyImage  := aImage; // used to swap back post print
  aImage.Picture.Bitmap.PixelFormat := BmpPixFmt; // read property creates bitmap!

  if not ClearFlg then
  begin              // this avoids partial resize when size of taskbar
                     // has been changed inbetween
                     // this works for calls
                     // post RoiDialog or PrintPreview with
                     // Parameter(frmMain.ImgMain, False)
    if (ImgWidth = 0) then  // keep the original size when reactivated
    begin
      ImgWidth  := aImage.Width;
      ImgHeight := aImage.Height;
    end;
  end;

  if (ImgWidth = 0) then
  begin
    // alClient: adapt to size of Form
    aImage.Align  := alClient;

    // alCustom: do no longer adapt to size of Form
    // but allow setting of Width and Height
    aImage.Align  := alCustom;

    aImage.Picture.Bitmap.Height := aImage.Height;
    aImage.Picture.Bitmap.Width  :=
      Min(aImage.Width, Round(1.35 * aImage.Height) );
    aImage.Width := aImage.Picture.Bitmap.Width;
  // Info: If BitMap is smaller than aImage the screen flickers!
  end else
  If (ImgWidth > 0) then
  begin
    // alCustom: do not adapt to size of Form
    // but allow setting of Width and Height
    aImage.Align  := alCustom;

    aImage.Width  := ImgWidth;
    aImage.Height := ImgHeight;
    aImage.Picture.Bitmap.Width  := ImgWidth;
    aImage.Picture.Bitmap.Height := ImgHeight;
  end;

  aImage.Align := alNone;  // necessary for ScrollBox1 Scrolling

//  Graph0_DrawImage  := aImage;
  Graph0_DrawCanvas := aImage.Canvas;
  Graph0_DrawBmp    := aImage.Picture.Bitmap;
  G0_GetMaxX        := aImage.Picture.Bitmap.Width;
  G0_GetMaxY        := aImage.Picture.Bitmap.Height;

  XFact640480 := (GetMaxX+1) / 640; {21.01.02 P.W} // here from Video1.pas 19.10.04 P.W.
  YFact640480 := (GetMaxY+1) / 480; {21.01.02 P.W} // here from Video1.pas 19.10.04 P.W.

  SetMaxViewPort;
  SetGraph0_DrawScanLines;

//  Graph0_DrawCanvas.Font.Name := 'Small Fonts';  // too coarse!
//  Graph0_DrawCanvas.Font.Name := 'Courier New';
//  Graph0_DrawCanvas.Font.Name := 'Fixedsys';  // hunging:
  //^--  FixedSys is hunging in UtKnPane Procedure TColorBoxPane.Draw (not small enough!);
  Graph0_DrawCanvas.Font.Name := 'Arial';  // best!  (useable from Size 6 (10 Pixels heigh))
  Graph0_DrawCanvas.Font.Height := DefaultTextHeight;
  Graph0_DrawCanvas.Font.Style  := [fsBold];
  Graph0_DrawCanvas.CopyMode := cmSrcCopy;


  SetFontSmoothing(PrinterActiv);  // for Screen Dump better support of invert Black & White
  SetSysColors;  // since 22.07.04 P.W
  SetBkColor(C_Black);
  SetColor  (C_White);


  if ClearFlg then
    ClearPage;
  (****************************************
  // *** neccessary are also ***
    // from init printer;    needed for pf8bit!
    GlbColor^.FillLookUpArray(GlbAttenuationToDensity);
    GlbColor^.FitSysColors;
  // *** done in InitPrinter, InitGraphic,
  //     RoiDialog.pas TfrmRoiDialog.FormPaint
  ****************************************)

//ShowMessage('Graph0_Init');
end;

function Graph0_DrawBmp_Copy: TBitMap;
// 13.06.08 P.W
var
  Dest, Source: TRect;
begin
  Result := TBitMap.Create;
//  Result.Assign(Graph0_DrawBmp);    // will make Graph0_DrawScanLines invalid when Result destroyed!
  Result.PixelFormat := BmpPixFmt;
  Result.Width       := Graph0_DrawBmp.Width;
  Result.Height      := Graph0_DrawBmp.Height;

  Dest   := RectFromGraphic(Result, 1);
  Source := RectFromGraphic(Graph0_DrawBmp, 1);
  Result.Canvas.CopyRect(Dest, Graph0_DrawBmp.Canvas, Source);
end;

procedure Graph0_DrawBmp_Restore(const Bmp: TBitMap);
// 13.06.08 P.W
var
  Dest, Source: TRect;
begin
  Dest   := RectFromGraphic(Graph0_DrawBmp, 1);
  Source := RectFromGraphic(Bmp, 1);
  BMP.PixelFormat := Graph0_DrawBmp.PixelFormat;
  Graph0_DrawBmp.Canvas.CopyRect(Dest, Bmp.Canvas, Source);
end;

procedure SaveGraph0_DrawBmp(aName: String);
begin
  SaveBitMapAsAny(Graph0_DrawBmp, aName);
  SetGraph0_DrawScanLines; // 13.06.08 P.W
end;

procedure SaveGraph0_DrawBmp_BW(aName: String);
// 01.12.05 P.W
// 13.06.08 P.W: use Graph0_DrawBmp_Copy to avoid problems with Graph0_DrawScanLines when Assign is used
var
  Bmp : TBitMap;
begin
  {                              // u. 13.06.08 P.W
  Bmp := TBitMap.Create;
  Bmp.Assign(Graph0_DrawBmp);    // LOOK OUT SL will be destroyed when Bmp is released!
  Bmp.PixelFormat := BmpPixFmt;
  }
  Bmp := Graph0_DrawBmp_Copy;    // s. 13.06.08 P.W
  if ExpImgInvBW then
    InvertBlackWhite(Bmp);
  SaveBitMapAsAny(Bmp, aName);
  FreeAndNil(Bmp);
end;

procedure LoadGraph0_DrawBmp(aName: String);
// modifications:
// 24.06.05 P.W
// Is critical! afterwards PutPixel fails because Scanlines are invalid
//  gets new bitmap!
// correction: Use Temp Bitmap and CopyRect to avoid
//    Graph0_DrawBmp is replaced (which occures during assign of graphic)
//    Putpixel no longer crashes because Graph0_DrawScanLines now stay valid
var
  HBmp : TBitMap;
  Dest, Source: TRect;
begin
//  LoadBitMapFromAny(Graph0_DrawBmp, aName);  // until 24.06.05 P.W

// since 24.06.05 P.W:
  HBmp := nil;
  LoadBitMapFromAny(HBmp, aName);
  Dest   := RectFromGraphic(Graph0_DrawBmp, 1);
  Source := RectFromGraphic(HBmp, 1);
  Graph0_DrawBmp.Canvas.CopyRect(Dest, HBmp.Canvas, Source);
  FreeAndNil(HBmp);
end;

function ErrSaveGraph0_DrawBmp(ErrInfo:TStringList=nil): String;
// 28.11.05 P.W: support InfoFile: Extenxion *.txt instead of *.jpg
// 01.12.05 P.W: support BlackWhite inversion by using SaveGraph0_DrawBmp_BW
// 15.04.08 P.W: Limit ErrorScreens to Range 1 .. 500, oldest will be overwritten
begin
  Result := ExpandFileName(GetFirstFreeMaskName(ErrScreenNameMask, 6, 500));    // "6, 500" : 15.04.08 P.W

  SaveGraph0_DrawBmp_BW(Result);  // _BW : 01.12.05 P.W

  if (ErrScreens = nil) then
    ErrScreens := TStringList.Create;
  ErrScreens.Append(Result);
  ShowMessageFmtMs(TraS('Error screen saved to file "%s"'), [Result]); // 25.11.05 P.W
  if Assigned(ErrInfo) and (ErrInfo.Count > 0) then
  begin
    try
      ErrInfo[0] := ErrInfo[0] + ' ' + DateTimeToStr(Now) +'['+ShortDateFormat+']';
      ErrInfo.SaveToFile(ChangeFileExt(Result, '.txt'));
    except
    end;
  end;
end;

function ErrSaveGraph0_DrawBmp(
  const aFormat: AnsiString;
  const Args: array of const): String; overload;
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  SL.Text := Format(aFormat, Args);
  ErrSaveGraph0_DrawBmp(SL);
  FreeAndNil(SL)
end;

function ErrSaveGraph0_DrawBmp(const aInfo: AnsiString): String; overload;
begin
  ErrSaveGraph0_DrawBmp('%s', [aInfo]);
end;

function TempSaveGraph0_DrawBmp: String;
begin
  Result := GetFirstFreeMaskName(TempScreenNameMask);
  SaveGraph0_DrawBmp(Result);
end;

procedure TempLoadGraph0_DrawBmp(aTempName: String; DeleteFlg:Boolean=True);
begin
  LoadGraph0_DrawBmp(aTempName);
  if DeleteFlg then
    DeleteFile(aTempName);
end;

procedure DrawPrinterColorCheckBox(R: TRect);
// 15.10.08 P.W
// Draw Color Test Image
var
  Bmp: TBitMap;
  VP : ViewPortType;
begin
  // load a bitmap and place it inside rect
  If FileExists(PrinterColorCheckBoxName) then
  begin
    Bmp := TBitMap.Create;
    VP := SetMaxViewPort;

    try
      Bmp.LoadFromFile(PrinterColorCheckBoxName);
      R := PropStretchRect(Rect(0, 0, Bmp.Width, Bmp.Height), R, AM_Max, AM_Mid);

      Graph0_DrawBmp.Canvas.StretchDraw(R, Bmp);
    except
    end;

    SetViewPort(VP);
    Bmp.Free
  end;
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  CrtCurWanted := False;
  FAsciiPage := nil;
  G0_GetMaxX := 1024;
  G0_GetMaxY :=  768;
  FillChar(G0_Rec, SizeOf(G0_Rec), 0);
  InitialFontSmoothing := IFS_Unknown;
  OutTextF        := nil;
  PageCtr         := 0;
  SaveGraphSystem := nil;
  SaveScreenImage := nil;
  Deb1(Unit_Name + '1');
end;
function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll;
  CmdInit;
end;
function Unit_Final(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  if (InitialFontSmoothing <> IFS_Unknown) then  // to give a chance to restore original mode
    SetFontSmoothing(InitialFontSmoothing = IFS_On); // this might be broken, if
      // several apps run at same time and they close in non reverse order

  SaveClearAsciiPage;  // 11.10.04 P.W.
  CloseOutTextF;       // 11.10.04 P.W.
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init, Unit_Final);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  CmdInit;
   -^--- moved to function Unit_Init // 03.05.24 P.W *)

finalization
(* -v--- moved to function Unit_Final // 03.05.24 P.W
  if (InitialFontSmoothing <> IFS_Unknown) then  // to give a chance to restore original mode
    SetFontSmoothing(InitialFontSmoothing = IFS_On); // this might be broken, if
      // several apps run at same time and they close in non reverse order

  SaveClearAsciiPage;  // 11.10.04 P.W.
  CloseOutTextF;       // 11.10.04 P.W.
   -^--- moved to function Unit_Final // 03.05.24 P.W *)
end.

