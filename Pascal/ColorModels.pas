unit ColorModels;

interface

uses
  Graphics, Math;
// further:      "RGB" is not a color space!
// CIE Lab
// sRGB, adobe RGB ...

type
  // RG of TColor is invers to TIntRGB according R and B:
  TColRGB = packed Record   // is for TColor
    case Integer of
      0: (C: Integer);
      1: (R, G, B, S: Byte);
  end;

  TCol32  = packed Record
    case Integer of
      0: (B, G, R, S: Byte);  // B is lowest and S highest Byte of C
      1: (C: Integer);
  end;

  TIntRgb = TCol32;

  TColHsv = packed Record
    // "HSV (Hue Saturation Value)" or "HSB (Hue Saturation Brightness)"
    // H:  ColorAngle  0 .. 360 deg mapped to 0 .. 255
    // S:  Saturation  0 ..   1     mapped to 0 .. 255
    // V:  GrayVALUE   0 ..   1     mapped to 0 .. 255
    // N:  not used (0)
    case Integer of
      0: (H, S, V, N: Byte);
      1: (C: Integer);
  end;


  TCol24 = packed Record
    B, G, R: Byte
  end;

const
  C32White : TCol32 = (B:255;G:255;R:255;S:0);
  C32LtGray: TCol32 = (B:191;G:191;R:191;S:0);
  C32Gray  : TCol32 = (B:127;G:127;R:127;S:0);
  C32dkGray: TCol32 = (B: 63;G: 63;R: 63;S:0);
  C32Blue  : TCol32 = (B:255;G:  0;R:  0;S:0);
  C32Yellow: TCol32 = (B:  0;G:255;R:255;S:0);
  C32Green : TCol32 = (B:  0;G:255;R:  0;S:0);
  C32ltRed : TCol32 = (B:127;G:127;R:255;S:0);
  C32Red   : TCol32 = (B:  0;G:  0;R:255;S:0);
  C32dkRed : TCol32 = (B:  0;G:  0;R:127;S:0);
  C32Purple: TCol32 = (B:255;G:  0;R:128;S:0);
  C32Black : TCol32 = (B:  0;G:  0;R:  0;S:0);

  C24White : TCol24 = (B:255;G:255;R:255);
  C24Blue  : TCol24 = (B:255;G:  0;R:  0);
  C24Black : TCol24 = (B:  0;G:  0;R:  0);

//###########################################################
function ColorEqu32(CA, CB: TCol32): Boolean;
function Color_HalfRange(C: TCol32):TCol32;
function GrayValToCol32(GrayVal: Byte): TCol32;
function RedCol32(C: TCol32): TCol32;
function GreenCol32(C: TCol32): TCol32;
function BlueCol32(C: TCol32): TCol32;
function RedVal(C: TCol32): Byte;
function GreenVal(C: TCol32): Byte;
function BlueVal(C: TCol32): Byte;
function RedToGrayCol32(C: TCol32): TCol32;
function GreenToGrayCol32(C: TCol32): TCol32;
function BlueToGrayCol32(C: TCol32): TCol32;
function SToGrayCol32(C: TCol32): TCol32;
function GrayCol24(C: TCol24): TCol24;
function GraySimple32(C: TCol32): Byte;
function GrayVal32(C: TCol32): Byte;
function GrayCol32(C: TCol32): TCol32;
function ColorSoft32(C: TCol32): TCol32;
function ColorSoft2_32(C: TCol32): TCol32;
function ColInterpol24(CA, CB: TCol24; d: Double): TCol24;
function ColInterpol32(CA, CB: TCol32; d: Double): TCol32;
function ColorToTCol24(C: TColor): TCol24;
function ColorToTCol32(C: TColor): TCol32;

function ColorMerged32(CA, CB: TCol32; Ratio: Double): TCol32; overload;
function ColorMerged32(CA, CB: TCol32; Ratio: Integer): TCol32; overload;

procedure ColorMerged32Proc(var CA: TCol32; const CB: TCol32; const Ratio: Integer);

//procedure ColorMerged32Proc_8_0(var CA: TCol32; const CB: TCol32);
procedure ColorMerged32Proc_128(var CA: TCol32; const CB: TCol32);

function ContrastLow(C: TCol32):TCol32;
function ContrastHigh(C: TCol32):TCol32;
function ColorBrighter(C: TCol32; factor:Double=1.25):TCol32;
function ColorAdd(C: TCol32; Add: Integer):TCol32;
function ColorDarker(C: TCol32; factor:Double=0.8):TCol32;
function ColorDown(C: TCol32; factor:Double=0.5):TCol32;

function ColorContrast32(Col: TCol32; ContrastCenter: Integer; ContrastFact: Double): TCol32;
function MultColors32(CA, CB: TCol32): TCol32;
function MeanColor(CA, CB: TCol32): TCol32; overload;
function MeanColor(CA, CB, CC, CD: TCol32): TCol32; overload;
function MultColors32MinPartAB(CA, CB: TCol32; MinPartA, MinPartB: Integer): TCol32;
function ColorMergedGray32_0(CA, CB: TCol32; Ratio: Double): TCol32;
function ColorMergedGray32(CA, CB: TCol32; Ratio: Double): TCol32;
function ColorMergedGraySimple32(CA, CB: TCol32; Ratio: Double): TCol32;
function ColorMergedGray_Gamma32(CA, CB: TCol32; Ratio: Double): TCol32;
function ColorMergedGrayUseHsv32(CA, CB: TCol32; Ratio: Double): TCol32;
//##########################################################


function HsvToRgbCol32(Hsv: TColHsv): TCol32;
function RgbToHsvCol32(C32: TCol32 ): TColHsv;
procedure RgbToHSV(const RGB: TCol32; var H, S, V: Byte); overload;
procedure RgbToHSV(const RGB: TColor; var H, S, V: Byte); overload;

function RgbToHsvToRgbCol32(const C32: TCol32 ): TCol32;

function HSV_HVal(const C: TCol32): Byte; overload;
function HSV_HVal(const C: TColor): Byte; overload;
function HSV_SVal(const C: TCol32): Byte; overload;
function HSV_SVal(const C: TColor): Byte; overload;
function HSV_VVal(const C: TCol32): Byte; overload;
function HSV_VVal(const C: TColor): Byte; overload;

Implementation
  const Unit_Name = 'ColorModels'; // 03.05.24 P.W

function ColorEqu32(CA, CB: TCol32): Boolean;
// ignores S part
begin
  Result := (CA.R = CB.R) and (CA.G = CB.G) and (CA.B = CB.B);
end;

function Color_HalfRange(C: TCol32):TCol32;
const
  mskL1 = $00FEFEFE;  // mask lowest color bit
  mskL2 = $00FCFCFC;  // mask lowest 2 color bits
  mskL3 = $00F8F8F8;
  mskL4 = $00F0F0F0;
  mskL5 = $00E0E0E0;
  mskL6 = $00C0C0C0;
  mskL7 = $00808080;
  mskL8 = $00000000;  // mask all color bits

  mskH1 = $007F7F7F;  // mask highest color bit
  mskH2 = $003F3F3F;  // mask highest color bit
  mskH3 = $001F1F1F;  // mask highest color bit
  mskH4 = $000F0F0F;  // mask highest color bit
begin
  Result.C := (C.C shr 1) and mskH1;  // darker factor 2

//  Result.C := C.C and mskL1;        // ignore lowest bit
end;

function GrayValToCol32(GrayVal: Byte): TCol32;
begin
  Result.B := GrayVal;
  Result.G := GrayVal;
  Result.R := GrayVal;
  Result.S :=       0;
end;

function RedCol32(C: TCol32): TCol32;
begin
  Result.C := 0;
  Result.S := C.S;
  Result.R := C.R;
end;

function RedVal(C: TCol32): Byte;
begin
  Result := C.R;
end;

function GreenVal(C: TCol32): Byte;
begin
  Result := C.G;
end;

function BlueVal(C: TCol32): Byte;
begin
  Result := C.B;
end;

function GreenCol32(C: TCol32): TCol32;
begin
  Result.C := 0;
  Result.S := C.S;
  Result.G := C.G;
end;

function BlueCol32(C: TCol32): TCol32;
begin
  Result.C := 0;
  Result.S := C.S;
  Result.B := C.B;
end;

function RedToGrayCol32(C: TCol32): TCol32;
begin
  Result.S := C.S;
  Result.R := C.R;
  Result.G := C.R;
  Result.B := C.R;
end;

function GreenToGrayCol32(C: TCol32): TCol32;
begin
  Result.S := C.S;
  Result.R := C.G;
  Result.G := C.G;
  Result.B := C.G;
end;

function BlueToGrayCol32(C: TCol32): TCol32;
begin
  Result.S := C.S;
  Result.R := C.B;
  Result.G := C.B;
  Result.B := C.B;
end;

function SToGrayCol32(C: TCol32): TCol32;
begin
  Result.S := C.S;
  Result.R := C.S;
  Result.G := C.S;
  Result.B := C.S;
end;

function GrayCol24(C: TCol24): TCol24;
var
  Gr : Byte;
begin
  GR := (C.R + C.G + C.B) div 3;
  Result.R := Gr;
  Result.G := Gr;
  Result.B := Gr;
end;

function GraySimple32(C: TCol32): Byte;
// matches human eye impression on sRGB screen
// nearly same as IrfanView  "Image Convert to Grayscale"
var
  Y: Double;
begin
  Y := 0.2989 * C.R + 0.5870 * C.G + 0.1140 * C.B;
  Result := EnsureRange(Round(Y), 0, 255);
end;

function GrayVal32(C: TCol32): Byte;
begin
  Result := (Integer(C.R) + Integer(C.G) + Integer(C.B)) div 3;
end;

function GrayCol32(C: TCol32): TCol32;
var
  Gr : Byte;
begin
  GR := (C.R + C.G + C.B) div 3;
  Result.S := 0;
  Result.R := Gr;
  Result.G := Gr;
  Result.B := Gr;
end;

function ColorSoft32(C: TCol32): TCol32;
begin
  Result.C := ((C.C div 2) and $007F7F7F) + $00808080;
end;

function ColorSoft2_32(C: TCol32): TCol32;
begin
  Result.C := ((C.C div 4) and $003F3F3F) + $00C0C0C0;
end;

function ColInterpol24(CA, CB: TCol24; d: Double): TCol24;
var
  fa, fb : Integer;
begin
//  Result := CA; EXIT;                     //   7.3 sec
  fb := Round(d * 256);
  fa := 256 - fb;
  Result.R := (CA.R * fa + fb * CB.R) div 256;    // 11.3
  Result.G := (CA.G * fa + fb * CB.G) div 256;
  Result.B := (CA.B * fa + fb * CB.B) div 256;
end;

function ColInterpol32(CA, CB: TCol32; d: Double): TCol32;
var
  fa, fb : Integer;
begin
//  Result := CA; EXIT;                     //   6.4 sec
  Result.S := 0;
  fb := Round(d * 256);
  fa := 256 - fb;
  Result.R := (CA.R * fa + fb * CB.R) div 256;    // 10.9
  Result.G := (CA.G * fa + fb * CB.G) div 256;
  Result.B := (CA.B * fa + fb * CB.B) div 256;
end;

function ColorToTCol24(C: TColor): TCol24;
begin
  Result.R := TColRgb(C).R;
  Result.G := TColRgb(C).G;
  Result.B := TColRgb(C).B;
end;

function ColorToTCol32(C: TColor): TCol32;
begin
  Result.S := TColRgb(C).S;
  Result.R := TColRgb(C).R;
  Result.G := TColRgb(C).G;
  Result.B := TColRgb(C).B;
end;

function ColorMerged32(CA, CB: TCol32; Ratio: Double): TCol32;
// ratio = 0 returns CA
var
  fa, fb : Double;
begin
  fa := 1 - Ratio;
  fb := Ratio;
  Result.S := 0;
  Result.R := Round(fa * CA.R + fb * CB.R);
  Result.G := Round(fa * CA.G + fb * CB.G);
  Result.B := Round(fa * CA.B + fb * CB.B);
end;

function ColorMerged32(CA, CB: TCol32; Ratio: Integer): TCol32;
// Ratio : 0..256
// ratio = 0 returns CA
begin
  Result.S := 0;
  Result.R := ((256 - Ratio) * CA.R + Ratio * CB.R) shr 8;
  Result.G := ((256 - Ratio) * CA.G + Ratio * CB.G) shr 8;
  Result.B := ((256 - Ratio) * CA.B + Ratio * CB.B) shr 8;
end;

(****
// [ebp-$30] // xa
// [ebp-$34] // xb
// esi       // x  
// ebx       // xb - xa + 1 // for loop ctr
ColorMerged32Proc(SLDestY[x], SLSrcY[XSr], MergeI);
  mov eax, [ebp-$1c]       // SLScrY
  mov edx, [ebp-$0c]       // XSr
  mov edx, [eax+edx*4]     //   SLSrcY[XSr]
  mov eax, [ebp-$18]       // SLDestY
  mov eax, [eax+esi*4]     //   SLDestY[x]
  mov ecx, [ebp-$5c]       // MergeI
  call ColorMerged32Proc   //

ColorMerged32Proc
begin                            
  push  ebx                   // 
  push  esi                   // 
  push  ecx                   // Ratio
  mov   [esp],     edx        //        ???

CA.R := ((256 - Ratio) * CA.R + Ratio * CB.R) shr 8;
  mov   edx,       $00000100  // 256
  sub   edx,       ecx        // 256 - Ratio
  mov   ebx,       edx        // 256 - Ratio
  movzx esi,       [eax+$02]  // CA.R zero expanded
  imul  ebx,       esi        // (256 - Ratio) * CA.R
  movzx esi,       [esp+$02]  // CB.R zero expanded
  imul  esi,       ecx        // Ratio * CB.R
  add   ebx,       esi        // (256 - Ratio) * CA.R + Ratio * CB.R
  shr   ebx,       $08        // 
  mov   [eax+$02], bl         // 

CA.G := ((256 - Ratio) * CA.G + Ratio * CB.G) shr 8;
  mov   ebx,       edx        // 256 - Ratio
  movzx esi,       [eax+$01]  // CA.G zero expanded
  imul  ebx,       esi        // (256 - Ratio) * CA.G
  movzx esi,       [esp+$01]  // CB.G zero expanded
  imul  esi,       ecx        // Ratio * CB.G
  add   ebx,       esi        // (256 - Ratio) * CA.G + Ratio * CB.G
  shr   ebx,       $08        //
  mov   [eax+$01], bl         //

CA.B := ((256 - Ratio) * CA.B + Ratio * CB.B) shr 8;
  xor   ebx,       ebx        // 0 // for zero expansion of ebx
  mov   bl,        [eax]      // CA.B (zero expanded) in ebx
  imul  edx,       ebx        // (256 - Ratio) * CA.B
  xor   ebx,       ebx        // 0 // for zero expansion of ebx
  mov   bl,        [esp]      // CB.B (zero expanded) in ebx
  imul  ebx,       ecx        // Ratio * CB.B
  add   edx,       ebx        // (256 - Ratio) * CA.B + Ratio * CB.B
  shr   edx,       $08        //
  mov   [eax],     dl         //

end;
  pop   edx                   //
  pop   esi                   //
  pop   ebx                   //
  ret                         //
****)
procedure ColorMerged32Proc(var CA: TCol32; const CB: TCol32; const Ratio: Integer);
// Ratio : 0..256
// ratio =   0 returns CA
// ratio = 256 returns CB
begin
  CA.R := ((256 - Ratio) * CA.R + Ratio * CB.R) shr 8;
  CA.G := ((256 - Ratio) * CA.G + Ratio * CB.G) shr 8;
  CA.B := ((256 - Ratio) * CA.B + Ratio * CB.B) shr 8;
end;

procedure ColorMerged32Proc_8_0(var CA: TCol32; const CB: TCol32);
// Ratio : 0..256
// ratio =   0 returns CA
// ratio = 256 returns CB
(***
begin
  push ecx
  mov  [esp], edx
CA.C := CA.C - ((CA.C shr 1) and $7F7F7F7F) + ((CB.C shr 1) and $7F7F7F7F); // Ratio = 128;
  mov  edx,   [eax]
  mov  ecx,   edx
  shr  edx,   1
  and  edx,   $7f7f7f7f
  sub  ecx,   edx
  mov  edx,   [esp]
  shr  edx,   1
  and  edx,   $7f7f7f7f
  add  ecx,   edx
  mov  [eax], ecx
end;
  pop  edx
  ret
***)
begin
{
  CA.R := ((256 - Ratio) * CA.R + Ratio * CB.R) shr 8;
  CA.G := ((256 - Ratio) * CA.G + Ratio * CB.G) shr 8;
  CA.B := ((256 - Ratio) * CA.B + Ratio * CB.B) shr 8;
}
  //CA.C:=CA.C - ((CA.C shr 8) and $00000000) + ((CB.C shr 8) and $00000000); // Ratio =   1;
//CA.C := CA.C;                                                               // Ratio =   1;
//CA.C := CA.C - ((CA.C shr 7) and $01010101) + ((CB.C shr 7) and $01010101); // Ratio =   2;
//CA.C := CA.C - ((CA.C shr 6) and $03030303) + ((CB.C shr 6) and $03030303); // Ratio =   4;
//CA.C := CA.C - ((CA.C shr 5) and $07070707) + ((CB.C shr 5) and $07070707); // Ratio =   8;
  CA.C := CA.C - ((CA.C shr 4) and $0F0F0F0F) + ((CB.C shr 4) and $0F0F0F0F); // Ratio =  16;
//CA.C := CA.C - ((CA.C shr 3) and $1F1F1F1F) + ((CB.C shr 3) and $1F1F1F1F); // Ratio =  32;
//CA.C := CA.C - ((CA.C shr 2) and $3F3F3F3F) + ((CB.C shr 2) and $3F3F3F3F); // Ratio =  64;
//CA.C := CA.C - ((CA.C shr 1) and $7F7F7F7F) + ((CB.C shr 1) and $7F7F7F7F); // Ratio = 128;
//CA.C := CB.C;                                                               // Ratio = 256;
  //CA.C:=CA.C - ((CA.C shr 0) and $FFFFFFFF) + ((CB.C shr 0) and $FFFFFFFF); // Ratio = 256;
end;
procedure ColorMerged32Proc_128(var CA: TCol32; const CB: TCol32);
// result is ivalid in high byte of CA (CA.S)
begin
  CA.C := CA.C - (((CA.C and $FEFEFEFE) - (CB.C and $FEFEFEFE)) shr 1); // Ratio = 128;
end;

{
  procedure ContrHi(var By: Byte);
  begin
    By :=  EnsureRange((Integer(by) - 64) * 2, 0, 255);
  end;
begin
  Result := C;
  ContrHi(Result.R);
  ContrHi(Result.G);
  ContrHi(Result.B);
}

function ContrastLow(C: TCol32):TCol32;
begin
  Result.C := ((C.C div 2) and $007F7F7F) + $00404040;
end;

function ContrastHigh(C: TCol32):TCol32;
  procedure ContrHi(var By: Byte);
  begin
    By :=  EnsureRange((Integer(by) - 64) * 2, 0, 255);
  end;
begin
  Result := C;
  ContrHi(Result.R);
  ContrHi(Result.G);
  ContrHi(Result.B);
end;

function ColorBrighter(C: TCol32; factor:Double=1.25):TCol32;
  procedure ColBr(var By: Byte);
  begin
    By :=  EnsureRange(Round(factor * by), 0, 255);
  end;
begin
  Result := C;
  ColBr(Result.R);
  ColBr(Result.G);
  ColBr(Result.B);
end;

function ColorAdd(C: TCol32; Add: Integer):TCol32;
  procedure ColBr(var By: Byte);
  begin
    By :=  EnsureRange(Round(Add + by), 0, 255);
  end;
begin
  Result := C;
  ColBr(Result.R);
  ColBr(Result.G);
  ColBr(Result.B);
end;

function ColorDarker(C: TCol32; factor:Double=0.8):TCol32;
  procedure ColDark(var By: Byte);
  begin
    By :=  Round(factor * by )
  end;
begin
  Result := C;
  ColDark(Result.R);
  ColDark(Result.G);
  ColDark(Result.B);
end;

function ColorDown(C: TCol32; factor:Double=0.5):TCol32;
  procedure ColDwn(var By: Byte);
  begin
    By :=  Round(factor * by) ;
  end;
begin
  Result := C;
  ColDwn(Result.R);
  ColDwn(Result.G);
  ColDwn(Result.B);
end;

function ColorContrast32(Col: TCol32; ContrastCenter: Integer; ContrastFact: Double): TCol32;
// -1: no contrast; 0: no change 1: full contrast
var
  Mult: Double;
  procedure Contrast(var By: Byte);
  begin
    By :=  EnsureRange(ContrastCenter + Round((Integer(by) - ContrastCenter) * Mult), 0, 255);
  end;
begin
  Mult := Power(255, ContrastFact);

  Result := Col;
  Contrast(Result.R);
  Contrast(Result.G);
  Contrast(Result.B);
end;

function MultColors32(CA, CB: TCol32): TCol32;
begin
  Result.S := 0;
  Result.R := EnsureRange((CA.R * CB.R) div 255, 0, 255);
  Result.G := EnsureRange((CA.G * CB.G) div 255, 0, 255);
  Result.B := EnsureRange((CA.B * CB.B) div 255, 0, 255);
end;

function MeanColor(CA, CB: TCol32): TCol32; overload;
begin
  Result.C := ((CA.C div 2) and $007F7F7F)  + ((CB.C div 2) and $007F7F7F);
end;

function MeanColor(CA, CB, CC, CD: TCol32): TCol32; overload;
begin
  Result.C := ((CA.C div 4) and $003F3F3F)  +
              ((CB.C div 4) and $003F3F3F)  +
              ((CC.C div 4) and $003F3F3F)  +
              ((CD.C div 4) and $003F3F3F);
end;

function MultColors32MinPartAB(CA, CB: TCol32; MinPartA, MinPartB: Integer): TCol32;
  function MultMinPart(A, B: Byte): Byte;
  begin
    Result := EnsureRange((Max(A, MinPartA) * Max(B, MinPartB)) div 255, 0, 255);
  end;
begin
  Result.S := 0;
  Result.R := MultMinPart(CA.R, CB.R);
  Result.G := MultMinPart(CA.G, CB.G);
  Result.B := MultMinPart(CA.B, CB.B);
end;

function ColorMergedGray32_0(CA, CB: TCol32; Ratio: Double): TCol32;
// a) Merge B with White use Ratio
// b) Multiply A and B
// ratio = 0 returns CA
var
  MinA, MinB: Integer;
begin
  CB := ColorMerged32(C32White, CB, Ratio);  // Returns for Ratio [0 .. 1] : [White .. CB]
//  Result := MultColors32(CA, CB);

  // for low  Ratio prefer A (CB is white)      : MinA Low   MinB High
  // for high Ratio prefer B (CB is CB   )      : MinA High  MinB Low
  MinA   := Round( 90 * (    Ratio));
  MinB   := 90 - MinA;
  Result := MultColors32MinPartAB(CA, CB, MinA, MinB);
end;

function ColorMergedGray32(CA, CB: TCol32; Ratio: Double): TCol32;
// Return Color of CA where GrayPart is merged from CA and CB
  function GrayVal32(C: TCol32): Byte;
  begin
    Result := Round(Sqrt(C.R*C.R  + C.G*C.G + C.B*C.B) / Sqrt(3));
  end;

var
  GrayA, GrayB, GrayR : Integer;

  function ColPartAdapted(ColPart: Byte): Byte;
  begin
    Result := EnsureRange( (GrayR * ColPart) div GrayA , 0, 255);
  end;

begin
  GrayA := GrayVal32(CA);
  if GrayA = 0 then
  begin
    CA.R := 1; CA.G := 1; CA.B := 1;
    GrayA := GrayVal32(CA);
  end;
  GrayB := GrayVal32(CB);
  GrayR := Round((1.0 - Ratio) * GrayA + Ratio * GrayB);

  Result.R := ColPartAdapted(CA.R);
  Result.G := ColPartAdapted(CA.G);
  Result.B := ColPartAdapted(CA.B);
end;

function ColorMergedGraySimple32_0(CA, CB: TCol32; Ratio: Double): TCol32;
// Return Color of CA where GrayPart is merged from CA and CB

var
  GrayA, GrayB, GrayR : Integer;

  function ColPartAdapted(ColPart: Byte): Byte;
  begin
    Result := EnsureRange( (GrayR * ColPart) div GrayA , 0, 255);
  end;

begin
  GrayA := GraySimple32(CA);
  if GrayA = 0 then
  begin
    CA.R := 1; CA.G := 1; CA.B := 1;
    GrayA := GraySimple32(CA);
  end;
  GrayB := GraySimple32(CB);
  GrayR := Round((1.0 - Ratio) * GrayA + Ratio * GrayB);

  Result.R := ColPartAdapted(CA.R);
  Result.G := ColPartAdapted(CA.G);
  Result.B := ColPartAdapted(CA.B);
end;

function ColorMergedGraySimple32(CA, CB: TCol32; Ratio: Double): TCol32;
// Return Color of CA where GrayPart is merged from CA and CB

const
  yR = 0.2989;
  yG = 0.5870;
  yB = 0.1140;
  function GraySimple32_Doub(C: TCol32): Double;
  // matches human eye impression on sRGB screen
  // like Gimp
  // nearly same as IrfanView  "Image Convert to Grayscale"
  begin
    Result := yR * C.R + yG * C.G + yB * C.B;
  end;


  procedure Over255toLowers(var PMax, PMid, PMin: Integer; yMax, yMid, yMin: Double);
  var
    dMax, dMid, dMin : Integer;
  begin
    dMax := PMax - 255;
    if dMax > 0 then
    begin
      PMax := 255;

      Inc(PMid, Round( 0.5 * yMax * dMax / yMid) );
      Inc(PMin, Round( 0.5 * yMax * dMax / yMin) );

      dMid := PMid - 255;
      if dMid > 0 then
      begin
        PMid := 255;
        Inc(PMin, Round( yMid * dMid / yMin) );
      end;

      dMin := PMin - 255;
      if dMin > 0 then
      begin
        PMin := 255;
        Inc(PMid, Round( yMin * dMin / yMid) );
      end;
    end;
  end;
var
  GrayA, GrayB, GrayR, gf, GrayTst, dGray : Double;

Label
  DebugRepeat;
var
  DebugRepCtr : Integer;
  R, G, B, PMax : Integer;
begin
  DebugRepCtr := 0;
DebugRepeat:
  if (CA.R <= 30) and (CA.G <= 0) and (CA.B <= 0) then
  begin
    if (CA.R <= 30) and (CA.G <= 0) and (CA.B <= 0) then;

  end;
  GrayA := GraySimple32_Doub(CA);
  if GrayA = 0 then
  begin
    CA.R := 1; CA.G := 1; CA.B := 1;
    GrayA := GraySimple32_Doub(CA);
  end;
  GrayB := GraySimple32_Doub(CB);
  GrayR := (1.0 - Ratio) * GrayA + Ratio * GrayB;
  gf    := GrayR / GrayA;

  R := Round(CA.R * gf);
  G := Round(CA.G * gf);
  B := Round(CA.B * gf);

  Pmax := Max(Max(R, G), B);
  if Pmax > 255 then
  begin
    if (R = PMax) then
    begin
      if (G >= B) then Over255toLowers(R, G, B, yR, yG, yB)
                  else Over255toLowers(R, B, G, yR, yB, yG);
    end else
    if (G = PMax) then
    begin
      if (R >= B) then Over255toLowers(G, R, B, yG, yR, yB)
                  else Over255toLowers(G, B, R, yG, yB, yR);
    end else
    if (B = PMax) then
    begin
      if (R >= G) then Over255toLowers(B, R, G, yB, yR, yG)
                  else Over255toLowers(B, G, R, yB, yG, yR);
    end;
  end;

  Result.R := EnsureRange(R, 0, 255);
  Result.G := EnsureRange(G, 0, 255);
  Result.B := EnsureRange(B, 0, 255);
  Result.S := 0;

  GrayTst := GraySimple32_Doub(Result);
  dGray := GrayTst - GrayR;
  if abs(dGray) > 20 then
  begin
Result.R := EnsureRange(R, 0, 255);
   Inc(DebugRepCtr);
   if DebugRepCtr <= 2 then Goto DebugRepeat;
  end;
end;

function ColorMergedGray_Gamma32(CA, CB: TCol32; Ratio: Double): TCol32;
// Return Color of CA where GrayPart is merged from CA and CB
  function Gamma(V : Double): Double;
  begin
    Result := V;
    //Result := sqrt(V);
  end;

  function GrayVal32(C: TCol32): Byte;
  var
    R, G, B: Double;
  begin
    R := C.R;
    G := C.B;
    B := C.B;

    R := Gamma(R);
    G := Gamma(G);
    B := Gamma(B);

    Result := Round(Sqrt(R*R  + G*G + B*B) / Sqrt(3));
    //Result := C.G;
  end;

var
  GrayA, GrayB, GrayR : Integer;

  function ColPartAdapted(ColPart: Byte): Byte;
  begin
    Result := EnsureRange( (GrayR * ColPart) div GrayA , 0, 255);
  end;

begin
  GrayA := GrayVal32(CA);
  if GrayA = 0 then
  begin
    CA.R := 1; CA.G := 1; CA.B := 1;
    GrayA := GrayVal32(CA);
  end;
  GrayB := GrayVal32(CB);
  GrayR := Round((1.0 - Ratio) * GrayA + Ratio * GrayB);

  Result.R := ColPartAdapted(CA.R);
  Result.G := ColPartAdapted(CA.G);
  Result.B := ColPartAdapted(CA.B);
end;

function ColorMergedGrayUseHsv32(CA, CB: TCol32; Ratio: Double): TCol32;
// Return Color of CA where GrayPart is merged using HSV from CA and CB
var
  HsvA, HsvB: TColHsv;
begin
  HsvA := RgbToHsvCol32(CA);
  HsvB := RgbToHsvCol32(CB);
  HsvA.V := Round((1.0 - Ratio) * HsvA.V + Ratio * HsvB.V);
  Result := HsvToRgbCol32(HsvA);
end;

function HsvToRgbCol32(Hsv: TColHsv): TCol32;
var
  // H: "Hue" = color type ;
  // S: Saturation;
  // V: Grayvalue     // brightness
  // here the values are normalized 0..255 to fit into byte representation;
  // in "original" coordinates H runs from 0.0 to 360.0 degree where each 60 degree the color changes
  // S and V run from 0.0 to 1.0
  //       red         green       blue       red
  //            yellow       cyan       magenta
  //        ^
  //        |
  //    V   |......++++++++++++------------......       "." = red
  //        |     +.          /+          .\            "+" = green
  //        |    +  .        /  +        .  \           "/" = blue
  //        |   +    .      /    +      .    \
  //        |  +      .    /      +    .      \
  //        | +        .  /        +  .        \
  // V*(1-S)|+----------./..........+.++++++++++\
  //        |
  //        +-----+-----+-----+-----+-----+-----+--> Hue
  //        0     60   120   180   240   300   360
  //
  H, S, V, R, G, B : Double; // H: 0 .. 360 deg; S, V: 0.0 .. 1.0; R,G,B: 0.0 .. 1.0
  Hi : Integer;
  f, p, q, t : Double;
begin
  H := Hsv.H * (360.0 / 255);
  S := Hsv.S          / 255 ;
  V := Hsv.V          / 255 ;
  //------------------------------------------
  // from Wikipedia "HSV color space" from Gonzalez und Woods:
  // Rafael Gonzalez, Richard E. Woods (2002) Digital Image Processing, 2 ed,
  //   Prentice Hall Press. p. 295, ISBN 0-201-18075-8
  Hi := Trunc(H / 60) mod 6;
  f  := (H / 60) - Hi;
  p  := V * ( 1 -           S );
  q  := V * ( 1 -  f      * S );
  t  := V * ( 1 - (1 - f) * S );
  case Hi of
    0:   begin R := V; G := t; B := p; end;
    1:   begin R := q; G := V; B := p; end;
    2:   begin R := p; G := V; B := t; end;
    3:   begin R := p; G := q; B := V; end;
    4:   begin R := t; G := p; B := V; end;
    5:   begin R := V; G := p; B := q; end;
    else begin R := 0; G := 0; B := 0; end;     // 08.01.09 P.W
  end;
  //------------------------------------------
  Result.R := Round(R * 255);
  Result.G := Round(G * 255);
  Result.B := Round(B * 255);
  Result.S := 0;
end;

function RgbToHsvCol32(C32: TCol32 ): TColHsv;
var
  // H: "Hue" = color type ;
  // S: Saturation;
  // V: Grayvalue
  H, S, V, R, G, B : Double; // H: 0 .. 360 deg; S, V: 0.0 .. 1.0; R,G,B: 0.0 .. 1.0
  MaxRgbInt, MinRgbInt : Integer;
  MaxRgb, MinRgb: Double;
begin
  R  := C32.R / 255;
  G  := C32.G / 255;
  B  := C32.B / 255;
  //------------------------------------------
  // from Wikipedia "HSV color space" from Gonzalez und Woods:
  // Rafael Gonzalez, Richard E. Woods (2002) Digital Image Processing, 2 ed,
  //   Prentice Hall Press. p. 295, ISBN 0-201-18075-8
  MaxRgbInt := Max(Max(C32.R, C32.G), C32.B);
  MinRgbInt := Min(Min(C32.R, C32.G), C32.B);

  MaxRgb := MaxRgbInt / 255;
  MinRgb := MinRgbInt / 255;
  if (MaxRgbInt = MinRgbInt) then
  begin
    H := 0;
  end else
  begin
    if C32.R = MaxRgbInt then H := ( 0 +  ( G - B ) / (MaxRgb - MinRgb)) * 60
    else
    if C32.G = MaxRgbInt then H := ( 2 +  ( B - R ) / (MaxRgb - MinRgb)) * 60
    else
    if C32.B = MaxRgbInt then H := ( 4 +  ( R - G ) / (MaxRgb - MinRgb)) * 60
    else H := 0; // else: 08.01.09 P.W

    if H < 0 then H := H + 360;
  end;

  if (MaxRgbInt = 0)
    then S := 0
    else S := 1 - (MinRgb / MaxRgb);

  V := MaxRgb;

  //------------------------------------------
  // use trunc to avoid unwanted color changes:
  Result.H := Trunc(H * 255 / 360.0);
  Result.S := Trunc(S * 255        );
  Result.V := Trunc(V * 255        );
  Result.N := 0;
end;

procedure RgbToHSV(const RGB: TCol32; var H, S, V: Byte);
var
  HSV : TColHsv;
begin
  HSV := RgbToHsvCol32(RGB);
  H := HSV.H;
  S := HSV.S;
  V := HSV.V;
end;

procedure RgbToHSV(const RGB: TColor; var H, S, V: Byte);
begin
  RgbToHSV(ColorToTCol32(RGB), H, S, V);
end;

function RgbToHsvToRgbCol32(const C32: TCol32 ): TCol32;
begin
  Result := HsvToRgbCol32(RgbToHsvCol32(C32));
end;

function HSV_HVal(const C: TCol32): Byte;
var
  H, S, V: Byte;
begin
  RgbToHSV(C, H, S, V);
  Result := H;
end;

function HSV_HVal(const C: TColor): Byte;
var
  H, S, V: Byte;
begin
  RgbToHSV(C, H, S, V);
  Result := H;
end;

function HSV_SVal(const C: TCol32): Byte;
var
  H, S, V: Byte;
begin
  RgbToHSV(C, H, S, V);
  Result := S;
end;

function HSV_SVal(const C: TColor): Byte;
var
  H, S, V: Byte;
begin
  RgbToHSV(C, H, S, V);
  Result := S;
end;

function HSV_VVal(const C: TCol32): Byte;
var
  H, S, V: Byte;
begin
  RgbToHSV(C, H, S, V);
  Result := V;
end;

function HSV_VVal(const C: TColor): Byte;
var
  H, S, V: Byte;
begin
  RgbToHSV(C, H, S, V);
  Result := V;
end;


end.
