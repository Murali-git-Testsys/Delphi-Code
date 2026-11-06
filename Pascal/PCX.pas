unit PCX;
(*
Created: 15.01.04 P.W
Aim    : Support loading of *.PCX Files by units UniDIB and DIBTools
         but added: create as persistant BitMap in LoadFromStream
modifications:
26.04.05 P.W
  a) LoadPCXfromStream Added
  b) LoadFromStream supported
  c) use corrected version of DibTools
*)

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  Graphics, Classes, UniDIB, DIBTools;

Function FindList(
           Const Path: String;
           Const ExtArr: Array of String;
           var List: TStringList): Integer;
Function LoadPCXasBMP(const FileName: String): TBitMap;
Procedure SaveAsJPEG(const Graphic: TGraphic; const FileName: String);
Procedure SaveAsExt(const Graphic: TGraphic; const FileName: String);
Procedure PCXtoJPEG(const FileNamePCX: String; FileNameJPEG: String = '');

type
  TPCX = class(TBitMap)
//    procedure LoadFromFile(const Filename: string); override; // not "virtual"!
    procedure LoadFromFile(const Filename: string); reintroduce;//virtual; 
    procedure LoadFromStream(Stream: TStream); override; //abstract;
  end;

Implementation

uses Consts, Dialogs, jpeg, SysUtils;
  const Unit_Name = 'PCX'; // 03.05.24 P.W

Function InArray(
           Const StrItem :String;
           Const StrArr : Array of String): Integer;
var
  I : Integer;           
begin
  Result := -1;
  if StrArr[0] = '.*' then  // All
  begin
    Result := 0;
  end else
  begin
    For I := Low(StrArr) to High(StrArr) do
    begin
      if StrItem = StrArr[I] then
      begin
        Result := I;
        Break;
      end;
    end;
  end;
end;


Function FindList(
           Const Path:String;
           Const ExtArr: Array of String;
           var List: TStringList): Integer;
var
  SearchRec : TSearchRec;
  FindRes : Integer;
  Ext : String;
begin
  If not assigned(List)
    then List := TStringList.Create;
//  Writeln('Search ', Ext, ' ', Path, ' ', List.Count);
  FindRes := FindFirst(Path + '\' + '*.*' , faAnyFile, SearchRec);
  while FindRes = 0 do
  begin
  //  ProcessSearchRec(SearchRec);
    if ((SearchRec.Attr and faDirectory) <> 0) then
    begin
      if (SearchRec.Name <> '.')  and
         (SearchRec.Name <> '..') then
      begin
        FindList(Path + '\' + SearchRec.Name, ExtArr, List);
      end;
    end else
    begin
      Ext := UpperCase(ExtractFileExt(SearchRec.Name));

      If (InArray(Ext, ExtArr) >= 0) then
      begin
//        Writeln('found ', Path + '\' + SearchRec.Name);
        List.Add(Path + '\' + SearchRec.Name);
      end;
    end;
    FindRes := FindNext(SearchRec);
  end;
  FindClose(SearchRec);

  Result := List.Count;
end;

(***
type
  TLUT = Array[0..47] of Byte; // P.W
{
Byte   Anzahl    Bezeichner                 Wert / Bedeutung

0      1         Hersteller                 10 = Zsoft
1      1         Versionsnr.                0, 2, 3, 4 oder 5
2      1         Kodierung                  1 = RLC
3      1         Bits pro Pixel             1, 2, 4 oder 8
4      8         Bildgröße                  X_Min, Y_Min, X_Max, Y_Max jeweils 2 Byte
12     2         horiz. Aufl.               in dpi
14     2         vert. Aufl.                in dpi
16     48        Header-Palette             LUT für 16 oder weniger Farben
64     1         reserviert                 0
65     1         Farbebenen                 1-4
66     2         Bytes / Zeile / Farbebene    zur Ermittlung des benötigten Speichers
68     2         Interpretation             1 = Farbe oder s/w, 2 = Grauwerte
70     2         horiz. Bildschirmgröße
72     2         vert. Bildschirmgröße
74     54        Leer                       bis Byte 128
}
  TPcxHeader = packed record // P.W
    Manufacturer : Byte; // 0      1         Hersteller                 10 = Zsoft
    VersionNr : Byte; // 1      1         Versionsnr.                0, 2, 3, 4 oder 5
    Coding : Byte; // 2      1         Kodierung                  1 = RLC
    BitsPerPix : Byte; // 3      1         Bits pro Pixel             1, 2, 4 oder 8
    X_Min, Y_Min, X_Max, Y_Max : Word; // 4      8         Bildgröße                  X_Min, Y_Min, X_Max, Y_Max jeweils 2 Byte
    X_ResDpi : Word; // 12     2         horiz. Aufl.               in dpi
    Y_ResDpi : Word; // 14     2         vert. Aufl.                in dpi
    LUT: TLUT; // 16     48        Header-Palette             LUT für 16 oder weniger Farben
    Reserved1 : Byte; // 64     1         reserviert                 0
    Planes : Byte; // 65     1         Farbebenen                 1-4
    BytesPerLinePerPlane : Word; // 66     2         Bytes / Zeile / Farbebene    zur Ermittlung des benötigten Speichers
ColMode1, ColMode2 : Byte;
//    ColorMode : Word; // 68     2         Interpretation             1 = Farbe oder s/w, 2 = Grauwerte
    X_ScreenSize: Word; // 70     2         horiz. Bildschirmgröße
    Y_ScreenSize : Word; // 72     2         vert. Bildschirmgröße
    Unused : Array[0..53] of Byte // 74     54        Leer                       bis Byte 128
  end;
***)


Function LoadPcxFromStream(Stream: TStream): TBitMap;
// as copy of LoadPCXasBMP 26.04.05
var
  DIB  : TUniDIB;
  x, y : integer;
  P    : PIntegerArray;
begin
  DIB := nil;
  UpsideDownDIB:=True;
  If (UDIBLoadPCX_Stream (Stream, DIB) <> UDIBNoError) then
  begin
    //MessageDlg ('Error when loading file !',mtError,[mbOK],0);
    Result := nil;
    Exit;
  end
  else begin
    // Create a Bitmap
    Result := TBitmap.Create;
    Result.Width := Abs(DIB.Width);
    Result.Height:= Abs(DIB.Height);

    //receive the data from DIB
    Result.PixelFormat := pf32bit;//pf16bit; //pf8bit;
    for y := 0 to Result.Height -1 do
    begin
      P := Result.ScanLine[y];
      for x := 0 to Result.Width -1 do
        P[x] := HelpPal256_B[DIB.GetPixel(X,Y)];
    end;

    //Result.PixelFormat := pf8bit;  // reduce requiered size if saved as BMP
                                   // but has no influence on save as jpg
                      // ^-- but palette support shows poor quality !
  end;
end;

Function LoadPCXasBMP(const FileName: String): TBitMap;
var
  DIB  : TUniDIB;
  x, y : integer;
  P    : PIntegerArray;
begin
  DIB := nil;
  UpsideDownDIB:=True;
  If (UDIBLoadPCX (
          ChangeFileExt(
          FileName,
          '.'+GraphicExtension(TPCX)),
     DIB) <> UDIBNoError) then
  begin
    //MessageDlg ('Error when loading file !',mtError,[mbOK],0);
    Result := nil;
    Exit;
  end
  else begin
    // Create a Bitmap
    Result := TBitmap.Create;
    Result.Width := Abs(DIB.Width);
    Result.Height:= Abs(DIB.Height);

    //receive the data from DIB
    Result.PixelFormat := pf32bit;//pf16bit; //pf8bit;
    for y := 0 to Result.Height -1 do
    begin
      P := Result.ScanLine[y];
      for x := 0 to Result.Width -1 do
        P[x] := HelpPal256_B[DIB.GetPixel(X,Y)];
    end;

    //Result.PixelFormat := pf8bit;  // reduce requiered size if saved as BMP
                                   // but has no influence on save as jpg
                      // ^-- but palette support shows poor quality !
  end;
end;

Procedure SaveAsExt(const Graphic: TGraphic; const FileName: String);
//------------------------------------------------------
// many conversions are not allowed:
// TBitmap     to TIcon, TMetafile    is invalid
// TIcon       to TMetaFile           is invalid
// TJPEGImage  to TIcon, TMetafile    is invalid
// TPCX        to TIcon, TMetafile    is invalid
//------------------------------------------------------
//Allowed:
// TPCX        to TJPEGImage          is valid
// TBitmap     to TJPEGImage          is valid
//------------------------------------------------------
var
  Ext: string;
  TempGraphic: TGraphic;
  GraphicClass: TGraphicClass;
begin

  Ext := ExtractFileExt(Filename);
  Delete(Ext, 1, 1);

  // GraphicClass := GetFileFormats.FindExt(Ext);  // is hidden!
  If Ext = GraphicExtension(TJPEGImage) then GraphicClass := TJPEGImage
  else     // TPCX as TJPEGImage:
  If Ext = GraphicExtension(TPCX)       then GraphicClass := TJPEGImage
  else
  If Ext = GraphicExtension(TBitMap)    then GraphicClass := TBitmap
  else
  If Ext = GraphicExtension(TMetafile)  then GraphicClass := TMetafile
  else
  If Ext = GraphicExtension(TIcon)      then GraphicClass := TIcon
  else
    GraphicClass := nil;

  if GraphicClass = nil then
  begin
    raise EInvalidGraphic.CreateFmt(SUnknownExtension, [Ext]);
  end else
  begin
    TempGraphic := GraphicClass.Create;
    try
      // NewGraphic.OnProgress := Progress;
      TempGraphic.Assign(Graphic);
      if (TempGraphic is TJPEGImage) then
      begin
        ShowMessageFmt('JPEG CompressionQuality: %d ',[(TempGraphic as TJPEGImage).CompressionQuality]);
        //(TempGraphic as TJPEGImage).CompressionQuality := 10;  10: poor quality!
               // ^-- 90 is default
        //(TempGraphic as TJPEGImage).PixelFormat := jf8Bit;
               // ^-- results in 0 byte image
      end;
      TempGraphic.SaveToFile(
        ChangeFileExt(Filename, '.' + GraphicExtension(GraphicClass)));
    except
      TempGraphic.Free;
      raise;
    end;
  end;

end;

Procedure SaveAsJPEG(const Graphic: TGraphic; const FileName: String);
var
  jp : TJPEGImage;
begin
  jp := TJPEGImage.Create;
  try
    with jp do
    begin
      Assign(Graphic);
      SaveToFile(
        ChangeFileExt(
          FileName,
          '.'+GraphicExtension(TJPEGImage)));
    end;
  finally
    jp.Free;
  end;
end;

Procedure PCXtoJPEG(const FileNamePCX: String; FileNameJPEG: String = '');
var
  bmp : TBitMap;
begin
  bmp := LoadPCXasBMP(FileNamePCX);
  if Assigned(bmp) then
  begin
    If FileNameJPEG = '' then
    begin
      SaveAsJPEG(bmp,
        ChangeFileExt(
          FileNamePCX,
          '.'+GraphicExtension(TJPEGImage)));
    end else
    begin
      SaveAsJPEG(bmp, FileNameJPEG);
    end;
    bmp.Destroy;
  end;
end;

procedure TPCX.LoadFromFile(const Filename: string); // override!
var
  bmp : TBitMap;
begin
  bmp := LoadPCXasBMP(FileName);
  if Assigned(bmp) then
  begin
    Assign(bmp);   // here we create the BMP which is shown during Dialog preview!
    bmp.Destroy;
  end;
end;

procedure TPCX.LoadFromStream(Stream: TStream);
var
  bmp : TBitMap;
begin
  bmp :=  LoadPcxFromStream(Stream);
  if Assigned(bmp) then
  begin
    Assign(bmp);   // here we create the BMP which is shown during Dialog preview!
    bmp.Destroy;
  end;
 // ShowMessage('TPCX.LoadFromStream may not be used! use LoadFromFile!');
end;

Procedure RegisterPCX;
var
  help : TPicture;
begin
  help := TPicture.Create;
  help.RegisterFileFormat('PCX', 'PCX Image file', TPCX);
  help.Destroy;
end;

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
  RegisterPCX;
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  RegisterPCX;
   -^--- moved to function Unit_Init // 03.05.24 P.W *)
end.

