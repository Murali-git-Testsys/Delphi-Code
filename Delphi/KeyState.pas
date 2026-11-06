// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Vers.: @(#)KeyState V.:1.00                             ) +*)
(*+ Author           : P.Wueseke                                          +*)
(*+ Date             : 25.09.95                                           +*)
(*+ Description      :                                                    +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*
// Modifications:
// 19.07.04 P.W adapt to Windows:
// Function TKeyState.ReadKeySt:Byte;
//   instead of using Intr($16, Regs) whrere Regs.AH = 2
//   use GetAsyncKeyState
25.04.05 P.W: While Serive Tool Threshold is running in a background window
  pressing of Shift keys inside an other program (Editor...) did lead to movements
  Reason: Measurement module FemurPcDelphi.exe uses KeyState.pas
  Function TKeyState.ReadKeySt:Byte;
  Modification: ReadKeySt returns 0 (no key pressed) when the Application is not active
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)
Unit KeyState;

INTERFACE

Uses
 //Dialogs,
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  Forms,
  Windows; // Dos;

Type
  TKeyState = Object

    KeyStOld         : Byte;
    KeySt            : Byte;

    Constructor Init;
    Destructor  Done;
    Function  ReadKeySt:Byte;
    Procedure SetKeySt;

    Function RSftPr : Boolean;
    Function RSftJPr: Boolean;
    Function RSftJUp: Boolean;

    Function LSftPr : Boolean;
    Function LSftJPr: Boolean;
    Function LSftJUp: Boolean;

    Function CtrlPr : Boolean;
    Function CtrlJPr: Boolean;
    Function CtrlJUp: Boolean;

    Function AltPr  : Boolean;
    Function AltJPr : Boolean;
    Function AltJUp : Boolean;
  end;

Var
  GlbKeyState      : TKeyState;
var
  GlbLeftShiftPressed  : Boolean = False;  // used for Win98 by KeyState and FemurPcForm1
  GlbRightShiftPressed : Boolean = False;  // used for Win98 by KeyState and FemurPcForm1


function Win98ShiftKeys: Byte;

Implementation

uses SysUtils;
  const Unit_Name = 'KeyState'; // 03.05.24 P.W

Const
  KS_RSft          = 1 shl 0;
  KS_LSft          = 1 shl 1;
  KS_Ctrl          = 1 shl 2;
  KS_Alt           = 1 shl 3;
  KS_ScrL          = 1 shl 4;
  KS_NumL          = 1 shl 5;
  KS_CapL          = 1 shl 6;
  KS_Ins           = 1 shl 7;

const
  TstPress  = $8000;  // for ShortInt
  TstToggle = $0001;  // for ShortInt

function Win98ShiftKeys: Byte;
begin
  Result := 0;
  if (TstPress and GetAsyncKeyState(VK_Shift ))<>0 then
  begin
    if GlbLeftShiftPressed then
      Result := Result or KS_LSft;
    if GlbRightShiftPressed then
      Result := Result or KS_RSft;
  end else
  begin // for security if message Key up is not detected by FemurPcForm1 AppMessage
    GlbLeftShiftPressed := False;
    GlbRightShiftPressed := False;
  end;
end;

Function TKeyState.ReadKeySt:Byte;
{0:RightShift; 1:LeftShift; 2:Ctrl; 3:Alt; 4:Scrol; 5:Num; 6:Caps; 7:Ins;}
// Modifications:
// 19.07.04 P.W DOS to Windows use GetAsyncKeyState
//---------------------------
//Var Regs         : Registers;  // until 19.07.04 P.W
// 25.04.05 Return Zero if Application is not active
begin
  (* for DOS until 19.07.04 P.W:
  FillChar(Regs, SizeOf(Regs), #0);
  Regs.AH:=2;
  Intr($16, Regs);
  ReadKeySt:=Regs.AL;
  *)
  Result := 0;
  if  not Application.Active then EXIT; // 25.04.05 P.W Avoid Shift detected if not active


  // Right Shift and Left Shift are used by FemurPC for
  // positioning the gantry Scans.pas Func. TScans.TestStand
  if (Win32Platform >= VER_PLATFORM_WIN32_NT) then
  begin
    if (TstPress and GetAsyncKeyState(VK_RShift ))<>0 then
      Result := Result or KS_RSft;
    if (TstPress and GetAsyncKeyState(VK_LShift ))<>0 then
      Result := Result or KS_LSft;
  end else
  begin  // Win95 and Win98 do not distinguish Left Right in GetAsyncKeyState!
         // so we use GetKeyState     // no! does not help!
    Result := Result or Win98ShiftKeys;

  end;
  if (TstPress and GetAsyncKeyState(VK_CONTROL))<>0 then
    Result := Result or KS_Ctrl;
  if (TstPress and GetAsyncKeyState(VK_MENU   ))<>0 then
    Result := Result or KS_Alt;

  // for these keys we return the state pressed or not
  // but not the toggled state, this may differ from
  // the DOS version, but they are not used
  if (TstPress and GetAsyncKeyState(VK_SCROLL ))<>0 then
    Result := Result or KS_ScrL;
  if (TstPress and GetAsyncKeyState(VK_NUMLOCK))<>0 then
    Result := Result or KS_NumL;
  if (TstPress and GetAsyncKeyState(VK_CAPITAL))<>0 then
    Result := Result or KS_CapL;
  if (TstPress and GetAsyncKeyState(VK_INSERT ))<>0 then
    Result := Result or KS_Ins;
end;

Procedure TKeyState.SetKeySt;
begin
  KeyStOld:=KeySt;  KeySt:=ReadKeySt;
end;

Function TKeyState.RSftPr : Boolean;
begin
  RSftPr :=((KeySt and KS_RSft)>0);
end;

Function TKeyState.RSftJPr: Boolean;
begin
  RSftJPr:=((KeySt and KS_RSft)>0) and ((KeyStOld and KS_RSft)=0);
end;

Function TKeyState.RSftJUp: Boolean;
begin
  RSftJUp:=((KeySt and KS_RSft)=0) and ((KeyStOld and KS_RSft)>0);
end;

Function TKeyState.LSftPr : Boolean;
begin
  LSftPr :=((KeySt and KS_LSft)>0);
end;

Function TKeyState.LSftJPr: Boolean;
begin
  LSftJPr:=((KeySt and KS_LSft)>0) and ((KeyStOld and KS_LSft)=0);
end;

Function TKeyState.LSftJUp: Boolean;
begin
  LSftJUp:=((KeySt and KS_LSft)=0) and ((KeyStOld and KS_LSft)>0);
end;

Function TKeyState.CtrlPr : Boolean;
begin
  CtrlPr :=((KeySt and KS_Ctrl)>0)
end;

Function TKeyState.CtrlJPr: Boolean;
begin
  CtrlJPr:=((KeySt and KS_Ctrl)>0) and ((KeyStOld and KS_Ctrl)=0);
end;

Function TKeyState.CtrlJUp: Boolean;
begin
  CtrlJUp:=((KeySt and KS_Ctrl)=0) and ((KeyStOld and KS_Ctrl)>0);
end;

Function TKeyState.AltPr  : Boolean;
begin
  ALtPr  :=((KeySt and KS_Alt )>0)
end;

Function TKeyState.AltJPr : Boolean;
begin
  ALtJPr :=((KeySt and KS_Alt )>0) and ((KeyStOld and KS_Alt )=0);
end;

Function TKeyState.AltJUp : Boolean;
begin
  ALtJUp :=((KeySt and KS_Alt )=0) and ((KeyStOld and KS_Alt )>0);
end;

Constructor TKeyState.Init;
begin
  SetKeySt;
  SetKeySt;
end;

Destructor TKeyState.Done;
begin

end;

{
function Test: Byte;
begin
  repeat
    Result := GlbKeyState.ReadKeySt;
    If (Result <> 0) then
      if (Result) <> 0 then
        ShowMessageFmt('%x',[Result]);
  until false;
end;
}
procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
//      : TKeyState;
  FillChar(GlbKeyState, SizeOf(GlbKeyState), #0);  //??
  GlbLeftShiftPressed  := False;
  GlbRightShiftPressed := False;

//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
  GlbKeyState.Init;
//  Test;
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  GlbKeyState.Init;
//  Test;
   -^--- moved to function Unit_Init // 03.05.24 P.W *)
end.
