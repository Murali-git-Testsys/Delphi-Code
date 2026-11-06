unit MsgBox;
// 17.06.05 P.W
// Purpose support MessageBox of Windows for
// a) Console Applications: Avoid use of Dialogs, Forms to keep *.Exe small
// b) Delphi GUI Apps.: here avoid problems with Screen.ActiveForm
//    during Measmodule we check that no other app is in foreground
//    but this did lead to problems with the Messagebox:
//      If Messagebox does not use a handle (first parameter = 0) then
//      the box is brought to background and not visible
//      If also MB_TASKMODAL is used then we run into a deadlock
//      Which comes from FemurPcForm1 Timer2 calling procedure
//      CheckForegroundWindow;
// Plan:
//  use the difference between a) and b):
//  console App: Conditional defines without "DELPHI"
//  GUI Apps have "DELPHI" defined
//  in case of b) disable CheckForeGroundWindow


// ########################################################################################
// ###################### compare Units: UMsgDelay, MsgBox, DialogSecure
// ########################################################################################

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  HaltUnit,
  Param_StrUnit,
{$Ifdef DELPHI}
  Forms,
{$ENDIF}
  SysUtils,
  Windows;

var
  MessageBox1Flg : Boolean = False;

function MessageBox1(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT; TopMost:Boolean=True): Integer;
function MessageBoxT1(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT; dwMilliseconds: DWORD; TopMost:Boolean=True): Integer;

procedure ShowMessageFmt_(const aFormat: AnsiString; const Args: array of const; dwMilliseconds: DWORD=0; TopMost:Boolean=True; uType:UINT=0); overload;
procedure ShowMessageFmt_(const msg: AnsiString; dwMilliseconds: DWORD=0; TopMost:Boolean=True; uType:UINT=0); overload;

//interface declaration
const
  MB_TIMEDOUT = 32000;

function MessageBoxTimeOut(hWnd: HWND; lpText: PChar; lpCaption: PChar;
  uType: UINT; wLanguageId: WORD; dwMilliseconds: DWORD): Integer;
  stdcall; external user32 name 'MessageBoxTimeoutA';


Implementation
  const Unit_Name = 'MsgBox'; // 03.05.24 P.W

// uType may be also : MB_YESNOCANCEL ... , MB_DEFBUTTON1 .. MB_DEFBUTTON4
// return types may be : IDABORT = ID_ABORT ...
// Examples of return values of MessageBox:
           // --- MB_YESNOCANCEL ---
           // x or cancel: 2
           // yes : 6
           // no  : 7
           // --- only Ok ---
           // x or ok : 1
           // --- MB_YESNO ---
           // yes : 6
           // no  : 7
           // --- MB_OKCANCEL ---  (x disabled)
           // ok : 1
           // x or cancel: 2
           // --- MB_ABORTRETRYIGNORE ---  (x disabled)
           // Abort  : 3
           // Retry  : 4
           // Ignore : 5
           // ---  ---
           //

function MessageBox1(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT; TopMost:Boolean=True): Integer;
// TopMost: other apps message boxes may below this box!
begin
  MessageBox1Flg := True;
  try
    uType := uType or MB_TASKMODAL;
    if TopMost then
      uType := uType or MB_TOPMOST;  // MB_TOPMOST since 04.10.05 P.W
{$Ifdef DELPHI}
    if (hwnd = 0) and Assigned(Screen.ActiveForm)
      then hwnd := Screen.ActiveForm.Handle;
{$ENDIF}
    Result := MessageBox       (hWnd, lpText, lpCaption, uType);
  finally
    MessageBox1Flg := False;
  end;
end;

function MessageBoxT1(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT; dwMilliseconds: DWORD; TopMost:Boolean=True): Integer;
// TopMost: other apps message boxes may below this box!
begin
  MessageBox1Flg := True;
  try
    uType := uType or MB_TASKMODAL;
    if TopMost then
      uType := uType or MB_TOPMOST;  // MB_TOPMOST since 04.10.05 P.W
{$Ifdef DELPHI}
    if (hwnd = 0) and Assigned(Screen.ActiveForm)
      then hwnd := Screen.ActiveForm.Handle;
{$ENDIF}
    Result := MessageBoxTimeOut(hWnd, lpText, lpCaption, uType, 0, dwMilliseconds);
  finally
    MessageBox1Flg := False;
  end;
end;
{
//implementation (Button1's OnClick event handler on Form1)
procedure TForm1.Button1Click(Sender: TObject) ;
var
  iRet: Integer;
  iFlags: Integer;
begin
   iFlags := MB_OK or MB_SETFOREGROUND or MB_SYSTEMMODAL or MB_ICONINFORMATION;
   MessageBoxTimeout(Application.Handle, 'Test a timeout of 2 seconds.', 'MessageBoxTimeout Test', iFlags, 0, 2000) ;

   iFlags := MB_YESNO or MB_SETFOREGROUND or MB_SYSTEMMODAL or MB_ICONINFORMATION;
   iRet := MessageBoxTimeout(Application.Handle, 'Test a timeout of 5 seconds.', 'MessageBoxTimeout Test', iFlags, 0, 5000) ;
   case iRet of
     IDYES:
       ShowMessage('Yes') ;
     IDNO:
       ShowMessage('No') ;
     MB_TIMEDOUT:
       ShowMessage('TimedOut') ;
   end;
end;
}

procedure ShowMessageFmt_(const aFormat: AnsiString; const Args: array of const; dwMilliseconds: DWORD=0; TopMost:Boolean=True; uType:UINT=0);
// TopMost: other apps message boxes may below this box!
var
  S, N : AnsiString;
begin
  S := Format(aFormat, Args);
  N := Param_Str(0);
  if dwMilliseconds > 0 then
  begin
    if uType = 0 then uType := MB_ICONINFORMATION;
    MessageBoxT1(0, pChar(S), pChar(N), uType, dwMilliseconds, TopMost)
  end else
  begin
    if uType = 0 then uType := MB_ICONWARNING;
    MessageBox1 (0, pChar(S), pChar(N), uType,                 TopMost);
  end;
end;

procedure ShowMessageFmt_(const Msg: AnsiString; dwMilliseconds: DWORD=0; TopMost:Boolean=True; uType:UINT=0);
// TopMost: other apps message boxes may below this box!
begin
  ShowMessageFmt_('%s', [Msg], dwMilliseconds, TopMost, uType);
end;

procedure TestMsgBox;
  procedure Test(Msg: AnsiString; uType: UINT);
  begin
    MessageBox1(0, PChar(Msg), PChar(Msg), uType);
  end;
begin
  Test('MB_ICONHAND        x Stop',        MB_ICONHAND);
  Test('MB_ICONQUESTION    ? Question',    MB_ICONQUESTION);
  Test('MB_ICONEXCLAMATION ! Exclamation', MB_ICONEXCLAMATION);
  Test('MB_ICONASTERISK    I Inforamtion', MB_ICONASTERISK);
  Test('MB_ICONWARNING     ! Exclamation', MB_ICONWARNING);
  Test('MB_ICONERROR       x Stop',        MB_ICONERROR);
  Test('MB_ICONINFORMATION I Inforamtion', MB_ICONINFORMATION);
  Test('MB_ICONSTOP        x Stop',        MB_ICONSTOP);
  H_alt(1);
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  MessageBox1Flg := False;

//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Initialization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
//  TestMsgBox;
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init); // 03.05.24 P.W
(* -v--- moved to function Unit_Init // 03.05.24 P.W
   -^--- moved to function Unit_Init // 03.05.24 P.W *)
end.
