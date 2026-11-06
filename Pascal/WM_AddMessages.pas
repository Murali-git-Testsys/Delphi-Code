unit WM_AddMessages;
// Modifications:
// 22.01.07 P.W: define and initialize UM_BackProjectionFileReady
// 29.08.07 P.W: define and initialize UM_CheckPreviousParamsFile
interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  Messages, Windows;

const
  WM_ForceToFront = WM_APP + 1;

  // for  WM_POWERBROADCAST  26.01.05 P.W
//     PBT_APMQUERYSUSPEND = 536; equal to WM_POWERBROADCAST!

var
  UM_BackProjectionFileReady : Cardinal = 0;  // 22.01.07 P.W
  UM_CheckPreviousParamsFile : Cardinal = 0;  // 29.08.07 P.W
//  UM_StratecXctConsoleMsg    : Cardinal = 0;  // 08.07.09 P.W

const
  // for use with UM_StratecXctConsoleMsg:
  WParam_RequestConWnd      = 0;               // 08.07.09 P.W
  WParam_SendConWnd         = 1;               // 08.07.09 P.W

//var
//  GlbConWnd  : HWND  = 0;                      // 08.07.09 P.W
//  GlbHlpWnd  : HWND  = 0;                      // 08.07.09 P.W

//function CreateHlpWnd: HWND;                   // 08.07.09 P.W for tests

Implementation
  const Unit_Name = 'WM_AddMessages'; // 03.05.24 P.W

const
{ strings used to obtain unique window message for communication
  between backprojection module and ViewXctImages }

  BackProjectionFileReadyString = 'BackProjectionFileReady';   // 22.01.07 P.W
  CheckPreviousParamsFileString = 'CheckPreviousParamsFile';   // 29.08.07 P.W
//  StratecXctConsoleMsgString    = 'StratecXctConsoleMsg';      // 08.07.09 P.W

(***
const
  HlpWndClassName          = 'HelpXctWnd';  // 08.07.09 P.W

function HlpWndProc(Wnd : HWND; message : UINT; wParam : Integer; lParam: Integer) : Integer; stdcall;
// 08.07.09 P.W
begin
  if message = UM_StratecXctConsoleMsg then  // here because UM_... is not a constant
  begin // 08.07.09 P.W
    case wParam of
      WParam_SendConWnd:
        begin // receive ConWnd:
          GlbConWnd := lParam;
        end;
    end;
    Result := 1;
  end else
  begin
    Result := DefWindowProc(Wnd, message, wParam, lParam);
  end;
end;

function CallCreateHlpWindow(x0, y0, dx, dy: Integer; WndName: AnsiString): HWND;
// 08.07.09 P.W
var
  Wnd : THandle;
begin
   Wnd := CreateWindow(
      HlpWndClassName,     // window class name
      pChar(WndName),      // window caption
      WS_POPUP or          // no title no frame ... all gray
      WS_CLIPCHILDREN or   // avoids paint over ConWnd when UseParent
      WS_CLIPSIBLINGS or
      0 ,                  // window style
      x0, //    Integer(CW_USEDEFAULT), // initial x position
      y0, //    Integer(CW_USEDEFAULT), // initial y position
      dx, //    Integer(CW_USEDEFAULT), // initial x size       // Default does not work with PopUp and ShowNormal!
      dy, //    Integer(CW_USEDEFAULT), // initial y size
      0,                   // parent window handle
      0,                   // window menu handle
      hInstance,           // program instance handle
      nil);                // creation parameters

   Result := Wnd;
end;

function HelpWndClass: TWndClass;
// 08.07.09 P.W
begin
  Result.style          := CS_HREDRAW or CS_VREDRAW;
  Result.lpfnWndProc    := @HlpWndProc;
  Result.cbClsExtra     := 0;
  Result.cbWndExtra     := 0;
  Result.hInstance      := hInstance;
  Result.hIcon          := LoadIcon(0, IDI_APPLICATION);
  Result.hCursor        := LoadCursor(0, IDC_ARROW);
  Result.hbrBackground  := HBRUSH(GetStockObject(HOLLOW_BRUSH));  // GRAY_BRUSH HOLLOW_BRUSH
  Result.lpszMenuName   := nil;
  Result.lpszClassName  := HlpWndClassName;
end;

function CreateHlpWnd: HWND;
// 08.07.09 P.W
// purpose: handle UM_StratecXctConsoleMsg
//--- example for use:
//  if GlbHlpWnd = 0 then
//    CreateHlpWnd;    // wnd to receive answer of StartXct0/Con to UM_StratecXctConsoleMsg
//  SendMessage(HWND_BROADCAST, UM_StratecXctConsoleMsg, WParam_RequestConWnd,
//    aForm.Handle);  // wisth HWND_BROADCAST : Result is ever 1!
//---
begin
  RegisterClass(HelpWndClass);
  Result := CallCreateHlpWindow( 0, 0, 0, 0, 'HelpWindow');
//  ShowWindow(Result, SW_SHOW);  // needs Widht and Height > 0
  GlbHlpWnd := Result;
end;
***)

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  UM_BackProjectionFileReady := 0;
  UM_CheckPreviousParamsFile := 0;

//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
  UM_BackProjectionFileReady := RegisterWindowMessage(BackProjectionFileReadyString); // 22.01.07 P.W
  UM_CheckPreviousParamsFile := RegisterWindowMessage(CheckPreviousParamsFileString); // 29.08.07 P.W
//  UM_StratecXctConsoleMsg    := RegisterWindowMessage(CheckPreviousParamsFileString); // 08.07.09 P.W
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  UM_BackProjectionFileReady := RegisterWindowMessage(BackProjectionFileReadyString); // 22.01.07 P.W
  UM_CheckPreviousParamsFile := RegisterWindowMessage(CheckPreviousParamsFileString); // 29.08.07 P.W
//  UM_StratecXctConsoleMsg    := RegisterWindowMessage(CheckPreviousParamsFileString); // 08.07.09 P.W
   -^--- moved to function Unit_Init // 03.05.24 P.W *)
end.
