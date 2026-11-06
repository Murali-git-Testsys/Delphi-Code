unit PrinterGlb;

// Modifications:
// 01.09.08 P.W: move TCanvas_Plus to new unit GraphicsExt.pas

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  DialogsSecure,     // 12.11.09 P.W
  Dialogs,           // 12.11.09 P.W
  Menus,             // 12.11.09 P.W
  GraphicsExt,       // 01.09.08 P.W
  WinTools,          // 17.07.08 P.W
  Translate,         // 17.07.08 P.W
  XctVersion,        // 13.12.07 P.W
  Forms,
  Controls,
  StdCtrls,
  MsgBox,            // 17.06.05 P.W
  TransX,
  GlbType, // 01.04.05 P.W for AsciiExpSep and FixSem
  RectGlb,
  PrintersFpu,
  Windows, Messages,
  Classes, Types, Graphics, SysUtils, Math;

type
  TOEMmode = (OEM_none, OEM_437, OEM_ANSI); // 17.07.08 P.W

function  PrinterName: AnsiString;
function  PrinterInstalled: Boolean;
procedure ShowPrnRasterCaps;
function  GetTotalPrintRect: TRect;
function  GetFramedPrintRect(LeftFrameMm:Double=25;TopFrameMm:Double=10;
             RightFrameMm:Double=10;BottomFrameMm:Double=10): TRect;
function  GetFramedPrintWidth: Integer;
function  GetFramedPrintHeight: Integer;
function  PropRect(RectSrc, RectDest: TRect): TRect;
function  PropPrintRect(SrcRect: TRect; ScaleFact:Double=1.0): TRect; overload;
function  PropPrintRect(Bmp: TBitmap; ScaleFact:Double=1.0): TRect; overload;

function PrintMultiDoc_Begin: Integer; // 06.10.08 P.W
function PrintMultiDoc_End: Integer;   // 06.10.08 P.W
function  PrintStringList(SL: TStringList; fName, HeadMsg: AnsiString): Integer;
procedure File_ToUnicode(fNameInp, fNameOut: AnsiString; OEMmode: TOEMmode); // 17.07.08 P.W
procedure File_FromUnicode(fNameInp, fNameOut: AnsiString; OEMmode: TOEMmode);
function  PrintTextFile(fName, HeadMsg: AnsiString; SLAdd:TStringList=nil;
            OEMmode:TOEMmode=OEM_none; MessageWindow:Boolean=False): Integer;
function  ViewTextFile(fName, HeadMsg: AnsiString; SLAdd:TStringList=nil; ViewTitle:AnsiString=''): Integer;

Implementation
  const Unit_Name = 'PrinterGlb'; // 03.05.24 P.W

var
  GetPrinterCapabilitiesPerformed : Boolean = False;

procedure GetPrinterCapapilities;
// procedure GetPrinter(ADevice, ADriver, APort: PChar; var ADeviceMode: THandle);
var
  ADevice, ADriver, APort: AnsiString;
var
  ADeviceMode: THandle;
  DevMode : PDeviceMode;
begin
  if GetPrinterCapabilitiesPerformed then EXIT;
  SetLength(ADevice, 1024);
  SetLength(ADriver, 1024);
  SetLength(APort,   1024);

  PrinterFpu.GetPrinter(
     PChar(ADevice),
     PChar(ADriver),
     PChar(APort),
     ADeviceMode);
  DevMode := GlobalLock  (ADeviceMode);
//  ShowMessageFmt('PaperLength: %d',[DevMode.dmPaperLength]);
  MessageBox1(0,
    PChar(AnsiString(
    Format(
      'PaperLength: %d',
      [DevMode.dmPaperLength]))),
    PChar(AnsiString('GetPrinterCapapilities')),
    MB_OK+MB_TASKMODAL);

  GlobalUnlock(ADeviceMode);
  GetPrinterCapabilitiesPerformed := True;


{  GetGetDeviceCaps()
HORZSIZE	Width, in millimeters, of the physical screen.
VERTSIZE	Height, in millimeters, of the physical screen.
HORZRES	Width, in pixels, of the screen.
VERTRES	Height, in raster lines, of the screen.
LOGPIXELSX	Number of pixels per logical inch along the screen width.
LOGPIXELSY	Number of pixels per logical inch along the screen height.
BITSPIXEL	Number of adjacent color bits for each pixel.
PHYSICALWIDTH	For printing devices: the width of the physical page, in device units. For example, a printer set to print at 600 dpi on 8.5"x11" paper has a physical width value of 5100 device units. Note that the physical page is almost always greater than the printable area of the page, and never smaller.
PHYSICALHEIGHT	For printing devices: the height of the physical page, in device units. For example, a printer set to print at 600 dpi on 8.5"x11" paper has a physical height value of 6600 device units. Note that the physical page is almost always greater than the printable area of the page, and never smaller.
PHYSICALOFFSETX	For printing devices: the distance  from the left edge of the physical page to the left edge of the printable area, in device units. For example, a printer set to print at 600 dpi on 8.5"x11" paper, that cannot print on the leftmost 0.25" of paper, has a horizontal physical offset of 150 device units.
PHYSICALOFFSETY	For printing devices: the distance  from the top edge of the physical page to the top edge of the printable area, in device units. For example, a printer set to print at 600 dpi on 8.5"x11" paper, that cannot print on the topmost 0.5" of paper, has a vertical physical offset of 300 device units.
}
//  ShowMessageFmt(
//  'HorzSize %d'+FixSem+' HorzRes %d'+FixSem+' LogPixelsSX %d'+FixSem+' PHYSICALWIDTH %d'+FixSem+' PHYSICALOFFSETX%d ',
//  [
//    PrinterFpu.GetDeviceCaps(HorzSize),      // [mm]
//    PrinterFpu.GetDeviceCaps(HorzRes),       // [pixels]
//    PrinterFpu.GetDeviceCaps(LOGPIXELSX),    // [pixels/inch]
//    PrinterFpu.GetDeviceCaps(PHYSICALWIDTH), // [pixels]
//    PrinterFpu.GetDeviceCaps(PHYSICALOFFSETX)// [pixels]
//  ]);
  MessageBox1(0,
    PChar(AnsiString(
    Format(
      'HorzSize %d'+FixSem+' HorzRes %d'+FixSem+' LogPixelsSX %d'+FixSem+' PHYSICALWIDTH %d'+FixSem+' PHYSICALOFFSETX%d ',
      [
        PrinterFpu.GetDeviceCaps(HorzSize),      // [mm]
        PrinterFpu.GetDeviceCaps(HorzRes),       // [pixels]
        PrinterFpu.GetDeviceCaps(LOGPIXELSX),    // [pixels/inch]
        PrinterFpu.GetDeviceCaps(PHYSICALWIDTH), // [pixels]
        PrinterFpu.GetDeviceCaps(PHYSICALOFFSETX)// [pixels]
      ]))),
    PChar(AnsiString('GetPrinterCapapilities')),
    MB_OK+MB_TASKMODAL);
end;

function  PrinterName: AnsiString;
// modifications:
// 12.04.05 P.W: handle case that PrinterIndex is negative
var
  PrnIdx : Integer;
begin
  PrnIdx := PrinterFpu.PrinterIndex;
  If PrnIdx < 0
  then Result := TraS('Error: no printer found!')
  else Result := PrinterFpu.Printers[PrnIdx];
end;

function  PrinterInstalled: Boolean;
// Created: 12.04.05 P.W
begin
  Result := (PrinterFpu.PrinterIndex >= 0);
end;

function PrnRasterCapsMsg(PrnRasterCaps: Integer): AnsiString;
  procedure ChkAdd(RC_Msk: Integer; Rc_Msg: AnsiString);
  Const
    FalseTrueMsg : Array[False .. True] of AnsiString = (' - ', ' X ');
  begin
    Result := Result + #13#10 + FalseTrueMsg[(RC_MSK and PrnRasterCaps)<>0] + Rc_Msg;
  end;
begin
  Result := Format('Printer Raster Capabilities = $%x', [PrnRasterCaps]);

  ChkAdd(RC_BITBLT       , 'RC_BITBLT       : Can do standard BLT.');
  ChkAdd(RC_BANDING      , 'RC_BANDING      : Device requires banding support');
  ChkAdd(RC_SCALING      , 'RC_SCALING      : Device requires scaling support');
  ChkAdd(RC_BITMAP64     , 'RC_BITMAP64     : Device can support >64K bitmap');
  ChkAdd(RC_GDI20_OUTPUT , 'RC_GDI20_OUTPUT : has 2.0 output calls');
  ChkAdd(RC_GDI20_STATE  , 'RC_GDI20_STATE  : =?');
  ChkAdd(RC_SAVEBITMAP   , 'RC_SAVEBITMAP   : =?');
  ChkAdd(RC_DI_BITMAP    , 'RC_DI_BITMAP    : supports DIB to memory');
  ChkAdd(RC_PALETTE      , 'RC_PALETTE      : supports a palette');
  ChkAdd(RC_DIBTODEV     , 'RC_DIBTODEV     : supports DIBitsToDevice');
  ChkAdd(RC_BIGFONT      , 'RC_BIGFONT      : supports >64K fonts');
  ChkAdd(RC_STRETCHBLT   , 'RC_STRETCHBLT   : supports StretchBlt');
  ChkAdd(RC_FLOODFILL    , 'RC_FLOODFILL    : supports FloodFill');
  ChkAdd(RC_STRETCHDIB   , 'RC_STRETCHDIB   : supports StretchDIBits');
  ChkAdd(RC_OP_DX_OUTPUT , 'RC_OP_DX_OUTPUT : =?');
  ChkAdd(RC_DEVBITS      , 'RC_DEVBITS      : =?');
end;

procedure ShowPrnRasterCaps;
var
  PrnRasterCaps    : Integer;
begin
  PrnRasterCaps := PrinterFpu.GetDeviceCaps(RASTERCAPS);
//  ShowMessage('GetFramedPrintRect ' + PrnRasterCapsMsg(PrnRasterCaps));
  MessageBox1(0,
    PChar(AnsiString(
      'GetFramedPrintRect ' + PrnRasterCapsMsg(PrnRasterCaps))),
    PChar(AnsiString('GetPrinterCapapilities')),
    MB_OK+MB_TASKMODAL);
end;

function  GetTotalPrintRect: TRect;
begin
  Result.Top    := 0;
  Result.Left   := 0;
  Result.Right  := Max(100, PrinterFpu.GetDeviceCaps(HorzRes));        // [pixels]
  Result.Bottom := Max(100, PrinterFpu.GetDeviceCaps(VertRes));        // [pixels]
end;

function  GetFramedPrintRect(LeftFrameMm:Double=25;TopFrameMm:Double=10;
             RightFrameMm:Double=10;BottomFrameMm:Double=10): TRect;
//return framed rect in printer coordinates.
// a) printable area size is given by:
// PgWidth=HorzRes and PgHeight=VertRes  [pixels].
// b) physical papersize is given by:
// PgPhysW=PHYSICALWIDTH and
// PgPhysH=PHYSICALHEIGHT                [pixels].
// c) the offset between them by
// PhOfsXL=PHYSICALOFFSETX and
// PhOfsYT=PHYSICALOFFSETY               [pixels].
// d) the offsets are not symmetric for top and bottom,
// so we have to calculate also
// PhOfsXR, PhOfsYB
// e) independend of printing orientation:
// frame not rotated!
{
const
  // Frames (including the offset)
  LeftFrameMm   = 25;         // [mm]
  TopFrameMm    = 10;         // [mm]
  RightFrameMm  = 10;         // [mm]
  BottomFrameMm = 10;         // [mm]
}
var
  PgWidth, PgHeight: Integer; // [pixels]
  LogPixX, LogPixY : Integer; // [pixels/inch]
  // Offset values Left and Top:
  PhOfsXL, PhOfsYT : Integer; // [pixels]
  // Offset values Right and Bottom:
  PhOfsXR, PhOfsYB : Integer; // [pixels]

  // Physical Page Width (is larger than PageWidth)
  PgPhysW, PgPhysH : Integer; // [pixels]

const
  InchPerMm  = 1 / 25.4;      // [inch/mm]

  function MmToPixX(XMm: Double): Integer;  // [pixels]
  begin
    Result := Round(XMm * LogPixX * InchPerMm);
  end;

  function MmToPixY(YMm: Double): Integer;  // [pixels]
  begin
    Result := Round(YMm * LogPixY * InchPerMm);
  end;

  function RemainFramePixX(FrameMmX: Double; PhOffsX: Integer): Integer; // [pixels]
  begin
    Result := Max(0, MmToPixX(FrameMmX)-PhOffsX);
  end;

  function RemainFramePixY(FrameMmY: Double; PhOffsY: Integer): Integer; // [pixels]
  begin
    Result := Max(0, MmToPixY(FrameMmY)-PhOffsY);
  end;

var
  LeftFramePix     : Integer; // [pixels]
  TopFramePix      : Integer; // [pixels]
  RightFramePix    : Integer; // [pixels]
  BottomFramePix   : Integer; // [pixels]
begin
//  ShowPrnRasterCaps;

  // printable area:
  PgWidth  := PrinterFpu.GetDeviceCaps(HorzRes);        // [pixels]
  if PgWidth < 0 then  // case no printer found
  begin
    PgWidth  :=  800;
    PgHeight := 1200;

    LogPixX  :=  100;
    LogPixY  :=  100;

    PhOfsXL  :=   50;
    PhOfsYT  :=   50;

    PgPhysW  :=  900;
    PgPhysH  := 1300;
  end else
  begin
    PgHeight := PrinterFpu.GetDeviceCaps(VertRes);        // [pixels]

    // printer resolution:
    LogPixX  := PrinterFpu.GetDeviceCaps(LOGPIXELSX);     // [pixels/inch]
    LogPixY  := PrinterFpu.GetDeviceCaps(LOGPIXELSY);     // [pixels/inch]

    // Offset of printable area in physical paper:
    PhOfsXL  := PrinterFpu.GetDeviceCaps(PHYSICALOFFSETX);// [pixels]
    PhOfsYT  := PrinterFpu.GetDeviceCaps(PHYSICALOFFSETY);// [pixels]

    // Physical paper size:
    PgPhysW  := PrinterFpu.GetDeviceCaps(PHYSICALWIDTH);  // [pixels]
    PgPhysH  := PrinterFpu.GetDeviceCaps(PHYSICALHEIGHT); // [pixels]
  end;

  // offset at Right and Bottom side [pixels]:
  PhOfsXR  := PgPhysW - PgWidth  - PhOfsXL;  // "Offset" at Right Side
  PhOfsYB  := PgPhysH - PgHeight - PhOfsYT;  // "Offset" at Bottom

  // calculate the frames in the printable area
  // regarding the offsets:
  case PrinterFpu.Orientation of
    poPortrait:
      begin
        LeftFramePix   := RemainFramePixX(LeftFrameMm,  PhOfsXL); // [pixels]
        TopFramePix    := RemainFramePixY(TopFrameMm ,  PhOfsYT); // [pixels]
        RightFramePix  := RemainFramePixX(RightFrameMm, PhOfsXR); // [pixels]
        BottomFramePix := RemainFramePixY(BottomFrameMm,PhOfsYB); // [pixels]
      end;
    else    // poLandscape
      begin // rotate FrameMm: L.T.R.B to B.L.T.R:
        LeftFramePix   := RemainFramePixX(BottomFrameMm,PhOfsXL); // [pixels]
        TopFramePix    := RemainFramePixY(LeftFrameMm , PhOfsYT); // [pixels]
        RightFramePix  := RemainFramePixX(TopFrameMm,   PhOfsXR); // [pixels]
        BottomFramePix := RemainFramePixY(RightFrameMm, PhOfsYB); // [pixels]
      end;
  end;
  //return used rect in printer coordinates:
  Result := Rect(
    LeftFramePix,                 // Left    [pixels]
    TopFramePix,                  // Top     [pixels]
    PgWidth  -  RightFramePix,    // Right   [pixels]
    PgHeight -  BottomFramePix);  // Bottom  [pixels]
end;

function  GetFramedPrintWidth: Integer;
var
  R: TRect;
begin
  R := GetFramedPrintRect;
  Result := R.Right - R.Left;
end;

function  GetFramedPrintHeight: Integer;
var
  R: TRect;
begin
  R := GetFramedPrintRect;
  Result := R.Bottom - R.Top;
end;

function  PropRect(RectSrc, RectDest: TRect): TRect;
// return a rectangle that fits proportional and centered into RectDest
var
  DestRatio, SrcRatio, Ratio: Double;
  ReduceHalf : Integer;
begin
  Result := RectDest;
  // DestRatio := PrinterFpu.usedWidth / PrinterFpu.usedHeight:
  DestRatio := (Result.Right  - Result.Left) /
              (Result.Bottom - Result.Top );

  SrcRatio := RectWidth(RectSrc) / RectHeight(RectSrc);

  Ratio    := DestRatio  / SrcRatio;
  If (Ratio > 1) then
  begin  // reduce used PageWidth
    ReduceHalf := Round(0.5 * (Result.Right - Result.Left) * (1 - 1/Ratio));
    Inc(Result.Left,  ReduceHalf);
    Dec(Result.Right, ReduceHalf);
  end else
  begin  // reduce used PageHeight
    ReduceHalf := Round(0.5 * (Result.Bottom - Result.Top) * (1 - Ratio));
    Inc(Result.Top,    ReduceHalf);
    Dec(Result.Bottom, ReduceHalf);
  end;
end;

function  PropPrintRect(SrcRect: TRect; ScaleFact:Double=1.0): TRect; overload;
// returns a rectangle for stretchdraw where
// Rect fits proportional to printpage
  function MakeDouble(D: Double): Double;
  begin
    Result := D;
  end;
begin
  Result   := GetFramedPrintRect;
  if ScaleFact <> MakeDouble(1.0) then
  begin
    Result.Right  := Result.Left + Round(RectWidth (Result) * ScaleFact);
    Result.Bottom := Result.Top  + Round(RectHeight(Result) * ScaleFact);
  end;
  Result := PropRect(SrcRect, Result);
end;

function  PropPrintRect(Bmp: TBitmap; ScaleFact:Double=1.0): TRect; overload;
// returns a rectangle for stretchdraw where
// Bmp fits proportional to printpage
begin
  Result := PropPrintRect(RectFromGraphic(Bmp), ScaleFact);
end;

function PrintMultiDoc_Begin: Integer;
// 06.10.08 P.W
begin
  if PrinterInstalled then
  begin
    PrinterFpu.MultiDocMode := True;
    Result := 0;
  end else
  begin
    Result := -1;
  end;
end;

function PrintMultiDoc_End: Integer;
// 06.10.08 P.W
begin
  if PrinterInstalled then
  begin
    PrinterFpu.MultiDocMode := False;
    Result := 0;
  end else
  begin
    Result := -1;
  end;
end;

//var
//  PgNum : Integer = 0;
//  var DebSl : TStringList = nil;
function  PrintStringList(SL: TStringList; fName, HeadMsg: AnsiString): Integer;
// Created 21.03.05 P.W
// Purpose replacement of LV_Tools
// 13.12.07 P.W: in footline "     Version XCT ..." added (post pagenr)
// 06.10.08 P.W: Footline splitted in two lines
const
  Tab = #09;    // Tabulator
  Spc = #32;    // Space
  FF  = #12;    // FormFeed
  TabWidth = 8;

  function  DivMax(Val, DivVal: Integer): Integer;
  begin
    if  DivVal < 1 then DivVal := 1;

    Result := (Val div DivVal);
    if (Result * DivVal) < Val then Inc(Result);
  end;

  function ExpandTabs(const S: AnsiString): AnsiString;
    function AddSpc(TabPos:Integer):Integer;
    begin
      Result := (TabWidth - (TabPos mod TabWidth)) mod TabWidth;
    end;
  var
    PS, PR, DTab : Integer;
  begin
    PR := 0;
    Result := S;
    For PS := 1 to Length(S) do
    begin
      Inc(PR);
      Case S[PS] of
        Tab :
          begin
            Result[PR] := SPC;
            DTab := AddSpc(PR);
            Insert(StringOfChar(Spc, DTab), Result, PR);
            Inc(PR, DTab);
          end;
      end;
    end;
  end;

  function CleanStr(const S_: AnsiString): AnsiString;
  var
    P : Integer;
  begin
    Result := S_;
    // replace each FormFeed by a Space:
    While Pos(FF, Result) > 0 do
      Result[Pos(FF, Result)] := Spc;

    // remove Trailing Spaces and Tabs:  
    P := Length(Result);
    While (P > 0) and (Result[P] in [Tab, Spc]) do Dec(P);
    SetLength(Result, P);
  end;

  function CountLines(var SL: TStringList; MaxCharsPerLine: Integer): Integer;
  var
    I, DL : Integer;
  begin
    Result := 0;
    for I := 0 to SL.Count -1 do
    begin
      SL[I] := ExpandTabs(CleanStr(SL[I]));
      DL := Max(1, DivMax(Length(SL[I]), MaxCharsPerLine)); //Count empty Lines!
      if DL <> 1 then
      begin
        Result := Result-0;
      end;

      Inc(Result, DL);
    end;
  end;

  function CalcPages(Lines, LinesPerPage: Integer): Integer;
  begin
    Result := DivMax(Lines, LinesPerPage);
  end;

  function CalcLinesOnLastPage(Lines, LinesPerPage: Integer): Integer;
  begin
    Result := Lines - ((CalcPages(Lines, LinesPerPage) - 1) * LinesPerPage);
  end;


const
  LinesPerPage     =  60;     //  50        55
  ScaleFont        =   0.84;  //   0.70      0.77
  MinLinesLastPage =   5;
  HeadLines        =   2;
  FootLines        =   3;     // 2 -> 3: 06.10.08 P.W

var
  SkipCtr : Integer;
  PagesOut : Integer;
  StopPrinting, SkipPage : Boolean;
  UseMaxCharsPerLine,
  UseLinesPerPage, LineDist, PgLineCtr, NumPages : Integer;
  PrintRect : TRect;

  function HeadLineYPos(HeadLineNr: Integer): Integer;
  begin
    Result := LineDist * (HeadLineNr-1) +
              PrintRect.Top;
  end;

  function TextLineYPos(TextLine: Integer): Integer;
  begin
    Result := LineDist * (TextLine-1 + HeadLines) +
              PrintRect.Top;
  end;

  function FootLineYPos(FootLine: Integer): Integer;
  begin
    Result := LineDist * (FootLine-1 + HeadLines + UseLinesPerPage) +
              PrintRect.Top;
  end;

  function LineXPos: Integer;
  begin
    Result := PrintRect.Left;
  end;

  function LineXMid: Integer;
  // 06.10.08 P.W
  begin
    Result := (PrintRect.Left + PrintRect.Right) div 2;
  end;

  function PageNumber: Integer;
  begin
    Result := PrinterFpu.PageNumber + SkipCtr;
  end;

  function PageNumberMultiDoc: Integer;
  begin
    Result := PrinterFpu.PageNumberMultiDoc;
  end;

  function PageNumberAsk: Integer;
  begin
    Result := PagesOut+1+SkipCtr;
  end;

  procedure PrnNewPage;
  begin
    PrinterFpu.NewPage;
//    DebSl.Append(
//      Format('=== PrnNewPage === (%d/%d) --------------------------',
//       [PageNumber, NumPages]));
  end;

  procedure TxtOutXY(X, Y: Integer; Txt: AnsiString);
  // modifications:
  // 17.07.08 P.W: use TextOut_W to avoid surprisings when codepage for non unicode programs is japan codepage
  begin
//    if PgNum <> PageNumber then
//    begin
//      DebSl.Append('=== NEW PAGE === -------------------------------------');
//      PgNum := PageNumber;
//    end;
//    DebSl.Append(Txt);
    // PrinterFpu.Canvas.TextOut(X, Y, Txt);                 // u.: 17.07.08 P.W
    TCanvas_Plus(PrinterFpu.Canvas).TextOut_W(X, Y, Txt);    // s.: 17.07.08 P.W
  end;

  function FmtDateTime(DT: TDateTime): AnsiString;
  begin
    Result :=
      FormatDateTime('dd.mm.yyyy hh:nn', DT);
  end;

  procedure AskPageOut;
  begin
exit;
    case MessageBox1(0, PChar(AnsiString(
           Format('Print Page %d of %d? '+
                  '                                               ',
                  [PageNumberAsk, NumPages]))),
                  PChar(AnsiString(fName)),
                  MB_YESNOCANCEL+MB_ICONQUESTION+MB_TASKMODAL) of
      IDYES:
        begin
        end;
      IDABORT, IDCANCEL:
        begin
          StopPrinting := True;
        end;
      IDNO:
        begin
          SkipPage := True;
          Inc(SkipCtr);
        end;

    end;
  end;

  procedure PageHeadOut;
  begin
//PrinterFpu.Canvas.Ellipse(PrintRect); // Ellipse behind the lines; Spaces clear Ellipse
    PgLineCtr := 0;
    AskPageOut;     // first time PageNumber is 1 next time also!
    if SkipPage then exit;
    if StopPrinting then exit;
    Inc(PagesOut);

    if (PagesOut > 1) then
      PrnNewPage;

    TxtOutXY(LineXPos, HeadLineYPos(1),
      'Stratec Medizintechnik GmbH' + '   ' +
//      FmtDateTime(Now)              + '   ' +
      DateTimeToStr(Now)              + '   ' +  // s. 13.06.05 P.W
      HeadMsg);

  end;

  procedure PageFootOut;
  begin
    if SkipPage then
    begin
      SkipPage := False;
      exit;
    end;
    if StopPrinting then exit;
    If (PgLineCtr = 0) then exit;
    // --- 2 footlines to 3 footlines: 06.10.08 P.W
    // firstline empty
    // secondline splitted since 06.10.08 P.W
    { --- u. 06.10.08 P.W
    TxtOutXY(LineXPos, FootLineYPos(FootLines),
      Format('"%s"     Page %d/%d     Version %s',
      [fName, PageNumber, NumPages,
       XctVersionLongMsg]));  // XctVers.: 13.12.07 P.W
    }
    // --- s. 06.10.08 P.W
    TxtOutXY(LineXPos, FootLineYPos(FootLines-1),
      Format('Version %s', [XctVersionLongMsg]));    // XctVers.: 13.12.07 P.W
    if (PrinterFpu.MultiDocMode) then
      TxtOutXY(LineXMid, FootLineYPos(FootLines-1),
        Format('Page %d/%d (%d)  #%d', [PageNumber, NumPages, PageNumberMultiDoc, PrinterFpu.MultiDocNr]))
//      Format('Page %d/%d (%d) %d %d', [PageNumberDoc, NumPages, PageNumber, UseLinesPerPage, UseMaxCharsPerLine]))  // debug
    else
      TxtOutXY(LineXMid, FootLineYPos(FootLines-1),  // "-1": 02.11.09 P.W
        Format('Page %d/%d', [PageNumber, NumPages]));
    TxtOutXY(LineXPos, FootLineYPos(FootLines),
      Format('"%s"',       [fName]));
//PrinterFpu.Canvas.Ellipse(PrintRect); // some lines are incomplete inside the ellipse!
  end;

  procedure NextPageOut;
  begin
    PageFootOut;
//if (NumPages >= 1) then StopPrinting:=True;

    if StopPrinting then exit;
    PageHeadOut;  // askPageOut
  end;

  procedure LineOut(LineStr: AnsiString);
  begin
    if StopPrinting then exit;

    If (PgLineCtr >= UseLinesPerPage) then
      NextPageOut;
    if StopPrinting then exit;

    Inc(PgLineCtr);
    if not SkipPage then
      TxtOutXY(LineXPos, TextLineYPos(PgLineCtr), LineStr);
  end;

  procedure LongLineOut(LongLineStr: AnsiString);
  var
    NumCharsOut : Integer;
  begin
    LongLineStr := CleanStr(LongLineStr);
    repeat
      NumCharsOut := Min(UseMaxCharsPerLine, Length(LongLineStr));
      LineOut(Copy(LongLineStr, 1, NumCharsOut));
      Delete(LongLineStr, 1, NumCharsOut);
    until (LongLineStr = '');
  end;

  function CalcLineDist(UsedLinesPerPage: Integer): Integer;
  // 06.10.08 P.W (code as function)
  begin
    Result  := (RectHeight(PrintRect) div
               (UsedLinesPerPage + HeadLines + FootLines));
  end;

var
  NumLines        : Integer;
  LinesOnLastPage : Integer;

var
  I : Integer;
begin
  if not PrinterInstalled then  // 12.04.05 P.W
  begin
    Result := -1;
    EXIT;
  end;

  Result := 0;
//  FreeAndNil(DebSl);
//  DebSl := TStringList.Create;

  StopPrinting := False;
  SkipPage     := False;
  SkipCtr      := 0;
  PagesOut     := 0;
//  PrinterFpu.Orientation := poLandscape;
  PrintRect := GetFramedPrintRect;

  LineDist  := CalcLineDist(LinesPerPage); // Code as function 06.10.08 P.W

  PrinterFpu.BeginDoc;             // before set font; otherwise Canvas.TextWidth is not correct!

  PrinterFpu.Canvas.Font.Name := 'Courier New';
  PrinterFpu.Canvas.Font.Style := [fsBold];
  PrinterFpu.Canvas.Font.Height :=
    Sign(PrinterFpu.Canvas.Font.Height) *
    Round( ScaleFont * LineDist);

  UseMaxCharsPerLine := (RectWidth(PrintRect) div PrinterFpu.Canvas.TextWidth('M')) ;

  NumLines := CountLines(SL, UseMaxCharsPerLine);
  UseLinesPerPage := LinesPerPage;
  NumPages := CalcPages(NumLines,  UseLinesPerPage);
  LinesOnLastPage := CalcLinesOnLastPage(NumLines,  UseLinesPerPage);
  if (NumPages > 1) and (LinesOnLastPage < MinLinesLastPage) then
  begin
    UseLinesPerPage :=
      LinesPerPage +
      DivMax(LinesOnLastPage, (NumPages-1));
    NumPages := CalcPages(NumLines,  UseLinesPerPage);
//    LinesOnLastPage := CalcLinesOnLastPage(NumLines,  UseLinesPerPage);

    LineDist  := CalcLineDist(UseLinesPerPage); // 06.10.08 P.W
  end;

//  ShowMessageFmt('Print "%s"'+FixSem+' Lines=%d'+FixSem+' Pages=%d'+FixSem+' UseLinesPerPage=%d'+FixSem+' LinesOnLastPage=%d',
//    [fName,
//     NumLines,
//     NumPages,
//     UseLinesPerPage,
//     LinesOnLastPage]);

//  PrinterFpu.BeginDoc;
  PageHeadOut;
    For I := 0 to SL.Count - 1 do
      LongLineOut(SL[I]);
  PageFootOut;

  PrinterFpu.EndDoc;

//DebSl.SaveToFile('C:\TEMP\DEBUG.TXT');
//  FreeAndNil(DebSl);
end;


procedure SL_OemToString_AnsiCurCP(SL : TStringList);
// 17.07.08 P.W
// result depends on active codepage for non unicode programs!
var
  I : Integer;
begin
  for I := 0 to SL.Count -1 do
    SL[I] := OemToString(SL[I]);   // <<< When   "[Error] PrinterGlb.pas(785): Undeclared identifier: 'OemToString'"
                                   // then use BUILD not COMPILE
end;

procedure SL_OemToString_Ansi437(SL : TStringList);
// 17.07.08 P.W
begin
  SL.Text := TextOemToAnsi437(SL.Text);
end;

function TextAnsi437ToUnicodeText(const S: AnsiString): AnsiString;
// 17.07.08 P.W
//  #$FF #$FE then S[1] #$00, S[2], #$00 ... S[Length(S)], #$00
{
ANSI:
0000:0000  41 42 43 44 45 0D 0A 46  47 48 49 4A              ABCDE..FGHIJ

UNICODE:
0000:0000  FF FE 41 00 42 00 43 00  44 00 45 00 0D 00 0A 00  ..A.B.C.D.E.....
0000:0010  46 00 47 00 48 00 49 00  4A 00                    F.G.H.I.J.
}
var
  Len, I : Integer;
begin
  Len := Length(S);
  SetLength(Result, 2*(Len+1));
  Result[1] := #$FF;
  Result[2] := #$FE;
  for I := 1 to Len do
  begin   // I = 1 -> 3 .. 4; 2 -> 5 .. 6
    Result[(2*I)+1] := S[I];
    Result[(2*I)+2] := #$00;
  end;
end;

function TextUnicodeToAnsi437Text(const S: AnsiString): AnsiString;
// 03.09.08 P.W
//  #$FF #$FE then S[1] #$00, S[2], #$00 ... S[Length(S)], #$00
{
ANSI:
0000:0000  41 42 43 44 45 0D 0A 46  47 48 49 4A              ABCDE..FGHIJ

UNICODE:
0000:0000  FF FE 41 00 42 00 43 00  44 00 45 00 0D 00 0A 00  ..A.B.C.D.E.....
0000:0010  46 00 47 00 48 00 49 00  4A 00                    F.G.H.I.J.
}
var
  Len, LenRes, I : Integer;

begin
  Len    := Length(S);
  LenRes := (Len-2) div 2;
  SetLength(Result, LenRes);
  for I := 1 to LenRes do
  begin   // invert of : I = 1 -> 3 .. 4; 2 -> 5 .. 6
    Result[I] := S[(2*I)+1];
  end;
end;

function TextOEM437ToUnicodeText(const S: AnsiString): AnsiString;
// 17.07.08 P.W
//  #$FF #$FE then S[1] #$00, S[2], #$00 ... S[Length(S)], #$00
{
ANSI:
0000:0000  41 42 43 44 45 0D 0A 46  47 48 49 4A              ABCDE..FGHIJ

UNICODE:
0000:0000  FF FE 41 00 42 00 43 00  44 00 45 00 0D 00 0A 00  ..A.B.C.D.E.....
0000:0010  46 00 47 00 48 00 49 00  4A 00                    F.G.H.I.J.
}
var
  Len, I : Integer;
begin
  Len := Length(S);
  SetLength(Result, 2*(Len+1));
  Result[1] := #$FF;
  Result[2] := #$FE;
  for I := 1 to Len do
  begin   // I = 1 -> 3 .. 4; 2 -> 5 .. 6
    Result[(2*I)+1] := OEM_ANSI_437[Ord(S[I])];
    Result[(2*I)+2] := #$00;
  end;
end;

procedure AnsiStringSaveToFile(const S: AnsiString; const fName: AnsiString);
// 17.07.08 P.W
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(fName, fmCreate);
  try
//  Stream.WriteBuffer(Pointer(S)^, Length(S));  // Ok??
    Stream.WriteBuffer(S[1], Length(S));
  finally
    Stream.Free;
  end;
end;

procedure AnsiStringLoadFromFile(var S: AnsiString; const fName: AnsiString);
// 17.07.08 P.W
var
  Stream: TStream;
  fs : Integer;
begin
  Stream := TFileStream.Create(fName, fmOpenRead);
  fs := Stream.Size;
  try
//  Stream.WriteBuffer(Pointer(S)^, Length(S));  // Ok??
    SetLength(S, fs);
    Stream.ReadBuffer(S[1], fs);
  finally
    Stream.Free;
  end;
end;

procedure File_ToUnicode(fNameInp, fNameOut: AnsiString; OEMmode: TOEMmode);
// 17.07.08 P.W

  procedure SL_Append_UnicodeLines(SL : TStringList);
  var
    I : Integer;
  begin
    for I := 16 to 255 do
      SL.Append(Format('// %3d: "%s"', [I, Char(I)]));
  end;
var
  SL : TStringList;
  UnicodeRes : AnsiString;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(fNameInp);
 // SL_Append_UnicodeLines(SL);  // for debugging only! 
    SL.Text := StringReplace(SL.Text, #12, ' ', [rfReplaceAll]);
    Case OEMmode of
      OEM_437:  UnicodeRes := TextOEM437ToUnicodeText (SL.Text);
      OEM_ANSI: UnicodeRes := TextAnsi437ToUnicodeText(SL.Text);
    end;
    FreeAndNil(SL);
    AnsiStringSaveToFile(UnicodeRes, fNameOut);
  except
  end;
  FreeAndNil(SL);
end;

procedure File_FromUnicode(fNameInp, fNameOut: AnsiString; OEMmode: TOEMmode);
// 03.09.08 P.W
var
  SL : TStringList;
  UnicodeRes : AnsiString;
begin
  SL := TStringList.Create;
  try
    //SL.LoadFromFile(fNameInp);
    AnsiStringLoadFromFile(UnicodeRes, fNameInp); 
    Case OEMmode of
//    OEM_437:  SL.Text := TextUnicodeToOEM437Text (UnicodeRes);
      OEM_ANSI: SL.Text := TextUnicodeToAnsi437Text(UnicodeRes);
    end;
    SL.SaveToFile(fNameOut);
    FreeAndNil(SL);
  except
  end;
  FreeAndNil(SL);
end;

procedure TestUnicode;
// 17.07.08 P.W
begin
  File_ToUnicode('D:\XCT\INTER\REPORTS.TXT', 'C:\TEMP\REPORTS_UNICODE.TXT', OEM_437);
end;

function  PrintTextFile(fName, HeadMsg: AnsiString; SLAdd:TStringList=nil;
            OEMmode:TOEMmode=OEM_none; MessageWindow:Boolean=False): Integer;
// Modifications:
// 17.07.08 P.W support new parameter OEMANSIflg
var
  SL : TStringList;
  I : Integer;
  aform: TForm;
  aMemo: TMemo;
begin
  fName := ExpandFileName(fName);
  aForm := nil;
  try
    if MessageWindow then
    begin
      aForm := TForm.Create(nil);
      aForm.Parent := nil;
      aForm.Position := poScreenCenter;

      aMemo := TMemo.Create(aForm);
      aMemo.Parent := aForm;
      aMemo.Align := alClient;
      aMemo.Alignment := taCenter;
      aMemo.Text := Format('Print "%s"', [ExpandFileName(fName)]);

      aForm.Show;
    end;
    Result := -1;
    SL := TStringList.Create;

    try
      SL.LoadFromFile(fName);
      case OEMmode of                  // 17.07.08
        OEM_none: ; // nothing
        OEM_437:  SL_OemToString_Ansi437(SL);
        OEM_Ansi: SL_OemToString_AnsiCurCP(SL);
      end;
    except
    end;
    if Assigned(SLAdd) then
    for I := 0 to SLAdd.Count -1 do
      SL.Append(SLAdd[I]);
    try
      Result := PrintStringList(SL, fName, HeadMsg);
    except
    end;
  finally
    FreeAndNil(SL);
    FreeAndNil(aForm);
  end;
end;

type
  TPrintExitObj = class  // 12.11.09 P.W
    aform    : TForm;
    aSL      : TStringList;
    aFName   : AnsiString;
    aHeadMsg : AnsiString;
    fPrinterSetupDialog : TPrinterSetupDialog;
    function  PrinterSetupDialog: TPrinterSetupDialog;
    procedure CallPrint(Sender: TObject);
    procedure CallPrintSetup(Sender: TObject);
    procedure CallBreak(Sender: TObject);
    procedure CallExit(Sender: TObject);

  end;

function  TPrintExitObj.PrinterSetupDialog: TPrinterSetupDialog;
// 12.11.09 P.W
begin
  if not Assigned(fPrinterSetupDialog) then
  begin
    fPrinterSetupDialog := TPrinterSetupDialog.Create(nil);
  end;
  Result := fPrinterSetupDialog;
end;

procedure TPrintExitObj.CallPrint(Sender: TObject);
// 12.11.09 P.W
begin
  if Assigned(aSL) then
    PrintStringList(aSL, aFName, aHeadMsg);
end;

procedure TPrintExitObj.CallPrintSetup(Sender: TObject);
// 12.11.09 P.W
begin
  If CommonDialog_Execute(PrinterSetupDialog) then
  begin
    //ShowMessage('PrintSetupDialog.Execute Ok');
  end;
end;

procedure TPrintExitObj.CallBreak(Sender: TObject);
// 12.11.09 P.W
begin
  if Assigned(aform) then
    aForm.ModalResult := mrNoToAll;
end;

procedure TPrintExitObj.CallExit(Sender: TObject);
// 12.11.09 P.W
begin
  if Assigned(aForm) then
    aForm.Close;
end;

function ViewStringList(SL: TStringList; fName, HeadMsg, ViewTitle: AnsiString): Integer;
// Modifications
// 26.11.09 P.W: new parameter ViewTitle ('' for default)
var
  aForm : TForm;
  aMemo : TMemo;
  PrnObj : TPrintExitObj; // 12.11.09 P.W
begin
  Result := 0;
  aForm := TForm.Create(nil);
  aForm.Parent := nil;
  aForm.WindowState := wsMaximized;
  if ViewTitle = '' then
    aForm.Caption := 'View "'+fName+'" '+HeadMsg+' '
  else
    aForm.Caption := ViewTitle;

    aMemo := TMemo.Create(aForm);
    aMemo.Parent := aForm;
    aMemo.Align := alClient;
    aMemo.ScrollBars := ssBoth;
    aMemo.ReadOnly := True;
    aMemo.Font.Name := 'Courier New';
    aMemo.Font.Size := 12;
    aMemo.Font.Style := [fsBold];
    aMemo.Text := SL.Text;


    PrnObj := TPrintExitObj.Create;   // 12.11.09 P.W
    PrnObj.aform    := aForm;
    PrnObj.aSL      := SL;
    PrnObj.afName   := fName;
    PrnObj.aHeadMsg := HeadMsg;
    aForm.Menu := NewMenu(aForm, 'FileMenu',  // 12.11.09 P.W
            [NewSubMenu('File', 0, 'File1', [
              NewItem('Print', TextToShortCut('Ctrl+P'), False, True,
                      PrnObj.CallPrint, 0, 'Print1'),
              NewItem('Print Setup ...', 0, False, True,
                      PrnObj.CallPrintSetup, 0, 'PrintSetup1'),
              NewItem('Break', 0, False, True,
                      PrnObj.CallBreak, 0, 'Break1'),
              NewItem('Exit',  TextToShortCut('Ctrl+Q'), False, True,
                      PrnObj.CallExit, 0, 'Exit1')
              ])
            ]);


  aForm.ShowModal;
  FreeAndNil(PrnObj);                 // 12.11.09 P.W
  result := aForm.ModalResult;        // 01.12.09 P.W
  aForm.Free;
end;

function  ViewTextFile(fName, HeadMsg: AnsiString; SLAdd:TStringList=nil; ViewTitle:AnsiString=''): Integer;
// Modifications
// 26.11.09 P.W: new parameter ViewTitle ('' for default)
var
  SL : TStringList;
  I : Integer;
begin
  fName := ExpandFileName(fName);  // 12.11.09 P.W
  Result := -1;
  SL := TStringList.Create;
  try
    SL.LoadFromFile(fName);
  except
  end;
  if Assigned(SLAdd) then
  for I := 0 to SLAdd.Count -1 do
    SL.Append(SLAdd[I]);
  try
    Result := ViewStringList(SL, fName, HeadMsg, ViewTitle);
  except
  end;
  FreeAndNil(SL);
end;


procedure TestPrint;
begin
  PrintTextFile('D:\XCT\INTER\REPORTS.TXT', '', nil, OEM_437);
end;

//initialization
//TestPrint;
//TestUnicode;


procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  GetPrinterCapabilitiesPerformed := False;

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
