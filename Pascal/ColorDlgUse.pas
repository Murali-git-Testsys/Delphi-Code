unit ColorDlgUse;

interface

uses
  forms, SysUtils,
  ColorModels,
  Controls, ExtCtrls, Classes, Dialogs, Windows, Graphics;

function ColorFromPoint(PT: TPoint): TColor;
function ColorDlgGetColor(ColDlg: TColorDialog; DisableHSV: Boolean = False): TColor;

type
  TColorDlgUse = class
  private
    Shape : TShape;
    ShapeOrigOnMouseDown: TMouseEvent;
    ColDlg : TColorDialog;
    TmrColor : TTimer;
    FOnColorChange: TNotifyEvent;
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnTimer(Sender: TObject);
    procedure SetOnColorChange(const Value: TNotifyEvent);
    procedure SetColor(const Value: TColor);
    function GetColor: TColor;
  public
    fDisableHSV: Boolean;
    constructor Create(aShape: TShape; aDisableHsv:Boolean=False; AOnColChange:TNotifyEvent=nil);
    property Color: TColor read GetColor write SetColor;
    property OnColorChange: TNotifyEvent read FOnColorChange write SetOnColorChange;
  end;


Implementation
  const Unit_Name = 'ColorDlgUse'; // 03.05.24 P.W

function ColorFromPoint(PT: TPoint): TColor;
var
  DC : HDC;
begin
  DC  := GetDC(0);             // Wnd =0: -> Desktop
  Result := GetPixel(DC, PT.X, PT.Y);
  ReleaseDC(0, DC);
end;

procedure WindowDrawText(Wnd: HWND; Msg: AnsiString; x, y: Integer);
var
  DC : HDC;
begin
  DC  := GetDC(WND);             // Wnd =0: -> Desktop
    TextOut(DC, x,y, pChar(Msg), Length(Msg));

  ReleaseDC(0, DC);
end;

function ColorDlgGetColor(ColDlg: TColorDialog; DisableHSV: Boolean = False): TColor;
const
  ColDlgDx = 256;        // position inside the colorcontrol of the ColorDialog
  ColDlgDy = 256;
var
  H, S, V, GV : Byte;
var
  Wnd : HWND;
  CB : TRect;
begin
  Wnd := ColDlg.Handle;
  GetWindowRect(Wnd, CB);
  Result := ColorFromPoint(Point(CB.Left+ColDlgDx, CB.Top+ColDlgDy));

  if not DisableHSV then
  begin
    RgbToHSV(Result, H, S, V);
    GV := GrayVal32(ColorToTCol32(Result,));
    WindowDrawText(Wnd, Format('HSV: %3d, %3d, %3d; GV: %3d    ', [H,S,V, GV]), 0, 0);
  end;
end;

{ TColorDlgUse }

// When created with a shape:
//  MouseDown on the shape will open a colordialog
//     during the dialog current color is reflected to the shape using TmrColor

constructor TColorDlgUse.Create(aShape: TShape; aDisableHsv:Boolean=False; AOnColChange:TNotifyEvent=nil);
begin
  ColDlg := TColorDialog.Create(Shape);
  Shape := aShape;
  ShapeOrigOnMouseDown := Shape.OnMouseDown;
  Shape.OnMouseDown := OnMouseDown;
  TmrColor := TTimer.Create(Shape);
  TmrColor.Enabled  := False;
  TmrColor.Interval := 200;
  TmrColor.OnTimer  := OnTimer;
  ColDlg := TColorDialog.Create(Shape);
  ColDlg.Options :=  [cdFullOpen,
                      //cdPreventFullOpen,
                      //cdShowHelp,
                      //cdSolidColor,
                      cdAnyColor
                      ];
  fDisableHsv := aDisableHsv;
  OnColorChange := AOnColChange;                    
end;

procedure TColorDlgUse.OnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ColSav : TColor;
begin
  ColSav       := Color;
  ColDlg.Color := ColSav;

  TmrColor.Enabled := True;
  try

    if ColDlg.Execute then
    begin
      TmrColor.Enabled := False;
      Color := ColDlg.Color
    end else
    begin
      TmrColor.Enabled := False;
      Color := ColSav;
    end;
  finally
    TmrColor.Enabled := False;
  end;
  if Assigned(ShapeOrigOnMouseDown) then
    ShapeOrigOnMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TColorDlgUse.OnTimer(Sender: TObject);
var
  Col : TColor;
begin
  if (ColDlg.Handle <> 0) then
  begin
    Col := ColorDlgGetColor(ColDlg, fDisableHSV);

    if (ColDlg.Handle <> 0) then  // when ColDlg did not close inbetween
      Color := Col;
  end;
end;

function TColorDlgUse.GetColor: TColor;
begin
  Result := Shape.Brush.Color;
end;

procedure TColorDlgUse.SetColor(const Value: TColor);
var
  Col: TColor;
begin
  if Value < 0            // when clicked on not defined color palette entry
    then Col := clBlack
    else Col := Value;

  if (Col <> Color) then
  begin
    Shape.Brush.Color := Col;
    if Assigned(FOnColorChange) then FOnColorChange(Self);
  end;
end;

procedure TColorDlgUse.SetOnColorChange(const Value: TNotifyEvent);
begin
  FOnColorChange := Value;
end;

end.
