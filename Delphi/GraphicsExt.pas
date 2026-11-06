unit GraphicsExt;
// created: 01.09.08 P.W
// purpose: support TCanvas_Plus for further units (Draw.pas, UseDelphi.pas)
// TCanvas_Plus moved from PrinterGlb.pas to here: 01.09.08 P.W

interface

uses
  Windows, Graphics;

  function TextWfromText(const Text: AnsiString): WideString;
  
type
  TCanvas_Plus = class(TCanvas)  // 09.07.08 P.W
    // no new variables!
    procedure TextRect_W(Rect: TRect; X, Y: Integer; const Text: AnsiString);  // only simple non virtual procedure
      // because typecast used which uses parent as child!
    procedure TextOut_W(X, Y: Integer; const Text: String);

  end;

Implementation
  const Unit_Name = 'GraphicsExt'; // 03.05.24 P.W

function TextWfromText(const Text: AnsiString): WideString;
// 09.07.08 P.W
// simple insert zeros (keeps the english ansicodepage in japan environment)
var
  Len, I : Integer;
begin
  Len := Length(Text);
  SetLength(Result, Len);
  for I := 1 to Len do
    Result [I] := WideChar(Ord(Text[I]));
end;

procedure TCanvas_Plus.TextRect_W(Rect: TRect; X, Y: Integer; const Text: AnsiString);
// 09.07.08 P.W
{
// Original in Graphics.pas:
procedure TCanvas.TextRect(Rect: TRect; X, Y: Integer; const Text: string);
var
  Options: Longint;
begin
  Changing;
  RequiredState([csHandleValid, csFontValid, csBrushValid]);
  Options := ETO_CLIPPED or FTextFlags;
  if Brush.Style <> bsClear then
    Options := Options or ETO_OPAQUE;
  if ((FTextFlags and ETO_RTLREADING) <> 0) and
     (CanvasOrientation = coRightToLeft) then Inc(X, TextWidth(Text) + 1);
  Windows.ExtTextOut(FHandle, X, Y, Options, @Rect, PChar(Text),
    Length(Text), nil);
  Changed;
end;
}
var
  Options: Longint;
  TextW : WideString;
begin

//TextW := Text;    // uses  MultiByteToWideChar(DefaultUserCodePage, 0, CharSource, SrcBytes, WCharDest, DestChars);
                    // DefaultUserCodePage = 3 (CP_THREAD_ACP) under win2k xp
                    //   -> Windows 2000/XP: The current thread's ANSI code page
                    // by this we get under vista (Japan) not the wanted english AnsiCode page

  TextW := TextWfromText(Text);   // this achieves what I want the coded characters appear under Japan as expected:
                                  // Alt 0xxx codes (leading zero is neccessary!):
                                  // µ 0181; º0186; ß 0223; Ä 196; ä 0228; Ö 0214; ö 0246; Ü 0220; ü 0252;

  Changing;
  RequiredState([csHandleValid, csFontValid, csBrushValid]);
  Options := ETO_CLIPPED or TextFlags;
  if Brush.Style <> bsClear then
    Options := Options or ETO_OPAQUE;
  if ((TextFlags and ETO_RTLREADING) <> 0) and
     (CanvasOrientation = coRightToLeft) then Inc(X, TextWidth(Text) + 1);
  Windows.ExtTextOutW(Handle, X, Y, Options, @Rect, PWideChar(TextW),
    Length(Text), nil);
  Changed;
end;

procedure TCanvas_Plus.TextOut_W(X, Y: Integer; const Text: String);
// 09.07.08 P.W
{
// Original in Graphics.pas:
procedure TCanvas.TextOut(X, Y: Integer; const Text: String);
begin
  Changing;
  RequiredState([csHandleValid, csFontValid, csBrushValid]);
  if CanvasOrientation = coRightToLeft then Inc(X, TextWidth(Text) + 1);
  Windows.ExtTextOut(FHandle, X, Y, FTextFlags, nil, PChar(Text),
   Length(Text), nil);
  MoveTo(X + TextWidth(Text), Y);
  Changed;
end;
}
var
  TextW : WideString;
begin
  TextW := TextWfromText(Text);
  Changing;
  RequiredState([csHandleValid, csFontValid, csBrushValid]);
  if CanvasOrientation = coRightToLeft then Inc(X, TextWidth(Text) + 1);
  Windows.ExtTextOutW(Handle, X, Y, TextFlags, nil, PWideChar(TextW),
   Length(Text), nil);
  MoveTo(X + TextWidth(Text), Y);
  Changed;
end;

end.
