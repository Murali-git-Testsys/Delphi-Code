unit ViewXctImages;
// Modifications:
// 21.11.07 P.W: function BmpFromXctImage, orientation of images adapted to analysis orientation
// 26.06.08 P.W: color of current empty image changed from maroon to moneygreen

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  HaltUnit,
  ComNames, WM_AddMessages,
  BmpUse,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, AppEvnts, DdeMan;

function GrayFrom(By: Byte): TColor;
function BmpFromXctImage(aName: String; BmpW, BmpH: Integer): TBitmap;

const
  MaxBmpArrCount = 40;

type
  TfrmViewXctImages = class(TForm)
    DrawGrid1: TDrawGrid;
    MemoDeb: TMemo;
    tmrMonitorNewImages: TTimer;
    ApplicationEvents1: TApplicationEvents;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      aRect: TRect; State: TGridDrawState);
    procedure tmrMonitorNewImagesTimer(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
  private
    FileList : TStringList;  // contains all files that may be viewed (unlimited)
    BmpArr   : TStringList;
    MonitorNewImagesMask : String;
    MonitorNewImagesSliceNr : Integer;
    function GetCount: Integer;
  public
    procedure CheckMonitorNewImages;
    procedure AppendFile(aFileName: String);
    procedure AppendFileCheckPrevious(aFileName: String);
    procedure AppendFileSlices(aFileName: String);  // contains bitmaps of last shown files  (limited by MaxBmpArrCount)
    function  ImageReadyToView(aFileName: String; SliceNr: Integer): Boolean;
    procedure StartMonitorNewImages(aFileName: String);
    property Count: Integer read GetCount;
  end;

var
  frmViewXctImages: TfrmViewXctImages;

Implementation

uses Math;
  const Unit_Name = 'ViewXctImages'; // 03.05.24 P.W

{$R *.dfm}

procedure BmpSetPixelFormat(Bmp: TBitmap; pixfmt: TPixelFormat);
begin
  Bmp.PixelFormat := pixfmt;
  Case pixfmt of
    pf4bit: Bmp.Palette := CreateGrayPal_16;  // is not protected by Graphics.pas InternalDeletePalette!
    pf8bit: Bmp.Palette := CreateGrayPal256;
  end;
end;

const
  pfFormat = pf4bit;

type
  PSL = ^TSL;
  TSL = Array[0..MaxWord] of Byte; // 2 points per byte
  TXctDataLine = Array [0..2000] of SmallInt;

function GrayFrom(By: Byte): TColor;
begin
  Result := By + By shl 8 + By shl 16;
end;

function ReadDataLine(DataLine: TXctDataLine; Pos: Integer): TColor;
var
  CA : SmallInt;
  GrayVal : Byte;
begin
  {
  CA := DataLine[Pos];
  if (CA >= 2*256) then Result := clWhite            else
  if (CA >  0    ) then Result := GrayFrom(CA div 2) else
                        Result := clBlack;
  }
  CA := DataLine[Pos];
  if (CA >= 4379 ) then GrayVal := 255   else
  if (CA >= 2919 ) then GrayVal := 15*16 else
  if (CA >= 1964 ) then GrayVal := 14*16 else
  if (CA >= 1297 ) then GrayVal := 13*16 else
  if (CA >=  864 ) then GrayVal := 12*16 else
  if (CA >=  577 ) then GrayVal := 11*16 else
  if (CA >=  384 ) then GrayVal := 10*16 else
  if (CA >=  256 ) then GrayVal :=  9*16 else
  if (CA >=  171 ) then GrayVal :=  8*16 else
  if (CA >=  114 ) then GrayVal :=  7*16 else
  if (CA >=   76 ) then GrayVal :=  6*16 else
  if (CA >=   51 ) then GrayVal :=  5*16 else
  if (CA >=   34 ) then GrayVal :=  4*16 else
  if (CA >=   23 ) then GrayVal :=  3*16 else
  if (CA >=   15 ) then GrayVal :=  2*16 else
  if (CA >=   10 ) then GrayVal :=  1*16 else
                        GrayVal :=  0*16;

  Result := GrayFrom(GrayVal);
end;


function BmpFromXctImage(aName: String; BmpW, BmpH: Integer): TBitmap;
// Modifications:
// 21.11.07 P.W: Orientation of images adapted to analysis orientation
var
  DataLine : TXctDataLine;
  FS : TMemoryStream;
  dx, dy : Double;
  HdVers, HdSize, S, W, H, Wb, Hb, xb, yb : Integer;
  x0, x1, y: Integer;
  SL : PSL;
//    SLArr : Array[0..2*BmpWH
begin
  Result := Nil;
  FS := TMemoryStream.Create;//(aName, fmOpenRead);
  try

    Result := TBitmap.Create;              // not only when FileExists 10.11.08 P.W
    BmpSetPixelFormat(Result, pfFormat);   //                "

    if FileExists(aName) then
    begin

      FS.LoadFromFile(aName);
      FS.Read(HdVers, SizeOf(HdVers));
      FS.Read(HdSize, SizeOf(HdSize));
      FS.Position := HdSize;

      S := FS.Size;
      W := Round(Sqrt((S - HdSize) div 2));
      H := W;

      if BmpW = 0
        then Wb := W
        else Wb := BmpW;
      if BmpH = 0
        then Hb := H
        else Hb := BmpH;

      dx := W / Wb;
      dy := H / Hb;

      Result.Width  := Wb;
      Result.Height := Hb;
      for yb := 0 to Hb -1 do
      begin
        y := Round(yb * dy);
        SL := Result.ScanLine[yb];
        FS.Position := HdSize + 2 * y * W;

        FS.Read(DataLine, 2*W);
        //for I := 0 to W-1 do DataLine[I] := round(I * 2500 / W);
        
        if Result.PixelFormat = pf4bit then
        begin
          for xb := 0 to (Wb div 2) -1 do
          begin  // 2 points in one byte!
            x0 := Round(((2 * xb)+0)  * dx);
            x1 := Round(((2 * xb)+1)  * dx);
            SL[xb] :=  (ReadDataLine(DataLine, x0) and $F0) +
                      ((ReadDataLine(DataLine, x1) and $F0) shr 4);
          end;
        end else
        begin
          for xb := 0 to Wb -1 do
          begin
            x0 := Round(xb * dx);
            SL[xb] := ReadDataLine(DataLine, x0);
          end;
        end;
      end;

    end else
    begin
      Result.Width  := Max(10, BmpW);     // "Max(10,"  10.11.08 P.W
      Result.Height := Max(10, BmpH);     //   "
    end;

  finally
    FreeAndNil(FS);
  end;
  BmpReplace(Result, BmpMirrorVerticalLR(Result));  // 21.11.07 P.W
  BmpReplace(Result, BmpRotate270(Result));         // 21.11.07 P.W
end;

procedure Test;
begin
  With TfrmViewXctImages.Create(nil) do
  begin
    Parent := nil;
    ShowModal;
    Free;
  end;
  H_alt(1);
end;

procedure TfrmViewXctImages.FormResize(Sender: TObject);
begin
  DrawGrid1.DefaultRowHeight := DrawGrid1.ClientHeight;
  DrawGrid1.DefaultColWidth  := DrawGrid1.ClientHeight;
end;

procedure TfrmViewXctImages.FormCreate(Sender: TObject);
begin
  DrawGrid1.RowCount := 1;
  DrawGrid1.ColCount := 1;
  DrawGrid1.Brush.Style := bsClear;
  DrawGrid1.DefaultDrawing := False;

  FileList := TStringList.Create;
  FileList.Sorted := True;
  FileList.Duplicates := dupIgnore;

  BmpArr   := TStringList.Create;
end;

procedure TfrmViewXctImages.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  aRect: TRect; State: TGridDrawState);
  function CurImgIdx  : Integer;
  begin
    Result := ACol + (ARow * DrawGrid1.ColCount);
  end;
  function CurImgName : String;
  var
    Idx : Integer;
  begin
    Idx := CurImgIdx;
    if (Idx >= 0) and (Idx < FileList.Count) then
    begin
      Result := FileList[Idx];
    end else
    begin
      Idx := -1;
      Result := '';
    end;
  end;

  function GetBmp(aName: String): TBitmap;
  var
    Idx : Integer;
  begin
    Result := nil;
    if aName = '' then EXIT;

    Idx := BmpArr.IndexOf(aName);
    if Idx < 0 then
    begin
      if BmpArr.Count >= MaxBmpArrCount then
      begin
//        MemoDeb.Lines.Append(Format('%s <- %s',[BmpArr[0], aName]));
    //    MemoDeb.Lines.Append(Format('%d <- %d',[FileList.IndexOf(BmpArr[0]), FileList.IndexOf(aName)]));

        if Assigned(BmpArr.Objects[0]) then
        begin
          BmpArr.Objects[0].Free;
          BmpArr.Objects[0] := nil;
        end;
        BmpArr.Delete(0);
      end;
      Idx := BmpArr.AddObject(aName, BmpFromXctImage(CurImgName,200, 200));
    end;
    Result := TBitmap(BmpArr.Objects[Idx]);
  end;
var
  Bmp : TBitmap;
begin
//  showmessage('on paint');
//  MemoDeb.Lines.Append(Format('On Paint (%d, %d)', [ACol, ARow]));
  {
  inherited;
  if not Assigned(Bmp) then
  begin
    Bmp := BmpFromXctImage(CurImgName,400, 400);
    // BmpSetPixelFormat(Bmp, pf4bit);
  end;
  }
  Bmp := GetBmp(CurImgName);
  if Assigned(Bmp) then
  begin
    DrawGrid1.Canvas.StretchDraw(aRect, Bmp);
    //gdSelected, gdFocused, gdFixed
    if (gdSelected in State) then
    begin
      DrawGrid1.Canvas.Brush.Color := clAqua;
    end else
    if (gdFocused  in State) then
    begin
      DrawGrid1.Canvas.Brush.Color := clYellow;
    end else
    if (gdFixed    in State) then
    begin
      DrawGrid1.Canvas.Brush.Color := clLime;
    end else
    begin
      DrawGrid1.Canvas.Brush.Color := clWhite;
    end;


//  DrawGrid1.Canvas.TextOut    (aRect.Left, aRect.Top, Format('(%d, %d) "%s"', [ACol, ARow, CurImgName]));
//  DrawGrid1.Canvas.TextOut    (aRect.Left, aRect.Top, Format('"%s"', [CurImgName]));

    DrawGrid1.Canvas.TextOut    (aRect.Left, aRect.Top, Format('%d', [SliceNameToSliceNr(CurImgName)]));
//  FreeAndNil(Bmp);
  end else
  begin
    DrawGrid1.Canvas.Brush.Color := clMoneyGreen; // clMaroon;  // clMoneyGreen: since 26.06.08 P.W
    DrawGrid1.Canvas.FillRect(aRect);
  end;
  DrawGrid1.Canvas.Brush.Color := clWhite;

end;

//initialization
//  Test;



procedure TfrmViewXctImages.AppendFile(aFileName: String);
//const
//  CurImgName = 'D:\XCT\AV002\A0020000\I0020007.M01';
var
  Idx,  LeftCol: Integer;
begin
  if FileExists(aFileName) then
  begin
    Idx := FileList.Add(aFileName);
    if Abs(DrawGrid1.ColCount - (1+FileList.Count)) > 1 then
      DrawGrid1.Visible := False;

    DrawGrid1.ColCount := 1+FileList.Count;
    Caption := Format('%s; %d; Images: %d', [aFileName, SliceNameToSliceNr(aFileName), FileList.Count]);
//  MemoDeb.Lines.Append(Format('Append_File %s; %d;', [aFileName,FileList.Count]));

//  DrawGrid1.LeftCol := Max(0, Min(DrawGrid1.ColCount - DrawGrid1.VisibleColCount-1, DrawGrid1.ColCount-1));
    LeftCol := Max(0, Min(Idx + 1 - DrawGrid1.VisibleColCount, DrawGrid1.ColCount-1));
    if Abs(LeftCol - DrawGrid1.LeftCol) > 1 then
      DrawGrid1.Visible := False;
    DrawGrid1.LeftCol := LeftCol;
    DrawGrid1.Selection := TGridRect(Rect(Idx,0, Idx, 0));
      DrawGrid1.Visible := True;
  end;
end;

procedure TfrmViewXctImages.AppendFileCheckPrevious(aFileName: String);
var
  SliceNr, I : Integer;
  FNI : String;
begin
  if FileExists(aFileName) then
  begin
    SliceNr := SliceNameToSliceNr(aFileName);

    for I := FirstSliceNrGlb to SliceNr -1 do
    begin
      FNI := SliceNrToName(aFileName, I);
      if (FileList.IndexOf(FNI) < 0) and FileExists(FNI) then
        FileList.Add(FNI);
    end;

//    DrawGrid1.Visible := False;
    AppendFile(aFileName);
//    DrawGrid1.Visible := True;
  end;
end;

procedure TfrmViewXctImages.AppendFileSlices(aFileName: String);
var
  Path : String;
  sr : TSearchRec;
begin
  Path := ExtractFilePath(aFileName);
  aFileName := ChangeFileExt(aFileName, SliceNrNamePartMask);
  if FindFirst(aFileName, faAnyFile, sr) = 0 then
  begin
    repeat
      AppendFile(Path+sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
end;

function TfrmViewXctImages.ImageReadyToView(aFileName: String; SliceNr: Integer): Boolean;
var
  I : Integer;
  sr : TSearchRec;
  SizeArr : Array[-1 .. 1] of Integer;
begin
  for I := -1 to 1 do
  begin
    if FindFirst(SliceNrToName(aFileName, SliceNr+I), faAnyFile, sr) = 0 then
    begin
      SizeArr[I] := sr.Size;
      FindClose(sr);
    end else
    begin
      SizeArr[I] := -1;
    end;
  end;

  if SliceNr = FirstSliceNrGlb then
  begin // only for images!
    Result := (SizeArr[0] > 0) and (SizeArr[1] > 0);
  end else
  begin
    Result := (SizeArr[-1] > 0) and (SizeArr[-1] = SizeArr[0]);
  end;
end;

procedure TfrmViewXctImages.StartMonitorNewImages(aFileName: String);
begin
  MonitorNewImagesMask := aFileName;
  MonitorNewImagesSliceNr := FirstSliceNrGlb;
//  tmrMonitorNewImages.Enabled := True;
//  CheckMonitorNewImages;
end;

procedure TfrmViewXctImages.CheckMonitorNewImages;
begin
//  while ImageReadyToView(MonitorNewImagesMask, MonitorNewImagesSliceNr) do
  if ImageReadyToView(MonitorNewImagesMask, MonitorNewImagesSliceNr) then
  begin
    AppendFile(SliceNrToName(MonitorNewImagesMask, MonitorNewImagesSliceNr));
    Inc(MonitorNewImagesSliceNr);
//    DrawGrid1.LeftCol := Max(0, Min(MonitorNewImagesSliceNr - DrawGrid1.VisibleColCount-1, DrawGrid1.ColCount-1));

//break;
//    Application.ProcessMessages;
//    Sleep(1000);
  end;
end;

procedure TfrmViewXctImages.tmrMonitorNewImagesTimer(Sender: TObject);
begin
//  CheckMonitorNewImages;
end;

var msgReadyCtr : Integer = 0;
var LastMsgNr : Integer = -1;
procedure TfrmViewXctImages.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if Msg.message = UM_BackProjectionFileReady then  // variable system unique Message Identifier
  begin
    ApplicationEvents1.CancelDispatch;  // despite this Broadcast message comes several times!
    Inc(msgReadyCtr);
    if (LastMsgNr <> Msg.lParam) then
    begin
      LastMsgNr := Msg.lParam;
//    MemoDeb.Lines.Append(Format('Message BackprojectionFileReady %d (%d, %d)', [Msg.wParam, Msg.lParam, msgReadyCtr]));
      Handled := True;
      CheckMonitorNewImages;
    end;
  end;
end;

function TfrmViewXctImages.GetCount: Integer;
begin
  Result := FileList.Count;
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  frmViewXctImages := nil;
  LastMsgNr        := -1;
  msgReadyCtr      := 0;

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
