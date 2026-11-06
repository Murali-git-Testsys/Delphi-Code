// Created 19.10.05 P.W
// Purpose collect functions from GraphGlb.pas and PrintersFpu.pas that are used to
// enshure secure call of dialogs to avoid FpuControl word is changed or Directory is changed
// Modifications:
// 18.04.08 P.W: Use FileUtils, New Functions:
//  DlgGetFileNameWithValidExt; DlgGetFilterIndexFromExt;
// 05.12.08 P.W: MonitorFpuCw: detected changes are not shown by Message in each case
//   detected FpuCw-Changes are restored
// 17.12.08 P.W: no longer a Message to user; MonitorFpuCW_Changed_2 uses EventLog


unit DialogsSecure;

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  EventLogs,  // 17.12.08 P.W
  Math,       // 05.12.08 P.W
  MsgBox,     // 05.12.08 P.W
  Messages,   // 04.11.08 P.W
  Printers,   // 04.11.08 P.W
  Forms,      // 13.10.08 P.W
  FileUtils,  // 18.04.08 P.W
  Controls,   // 18.04.08 P.W
  SysUtils, Dialogs, Classes, Windows, CommDlg;

function  MyGet8087CW: Word;
procedure MySet8087CW(FPUControlWord: Word);
procedure MonitorFpuCw;
procedure MonitorFpuCw_Debug;
function  CommonDialog_Execute(Dlg: TCommonDialog): BOOL;
function DlgGetFileNameWithValidExt(Dlg: TOpenDialog; out OldExt, NewExt: String): String;
function DlgGetFilterIndexFromExt(Dlg: TOpenDialog; const Ext: String): Integer;

function DlgOpen  (Dlg: TOpenDialog; const DefFileName, DefInitialDir: String): Boolean;
function DlgSaveAs(Dlg: TSaveDialog; const DefFileName, DefInitialDir: String): Boolean;

procedure ShowMessageS(Msg: AnsiString);
procedure ShowMessageFmtS(const Msg: string; Params: array of const);

Implementation
  const Unit_Name = 'DialogsSecure'; // 03.05.24 P.W

var
  MonitorFpuCwBlinded : Boolean = False;   // allow blind changes while Dialogs run


(*
MonitorFpuCw:
Results:
-------------------------------------------------------------------------
Default8087CW: Word = $1332
(bit no:           2 1098 7654 3210)
Def  4914 = $1332  1 0011 0011 0010
Def setting means
  a) Exceptions
  Denormalized Operation(bit 1 set) leads not to an exception
  also underflow(4) and precision(5) do not generate an exception
  b) Precision(8,9) is set to 11B -> Extended Precision
  c) Rounding Control(10,11) is set to  00B -> Round to nearest

// SetDefault $1332 may result in Get8087CW returns $1372
//   it looks like that on Pentium 4 the reserved bit 6 is hardcoded to be set


bits  0 ..5: Exception masks, bit set blocks corresponding exception from beein generated
----------------------------------
bit   0: Invalid Operation
bit   1: Denormalized Operand
bit   2: Zero Divide
bit   3: Overflow
----------------------------------
bit   4: Underflow
bit   5: Precision
bits  6,  7: Reserved
----------------------------------
bits  8,  9: Precision Control
                00B -> Single Precision   (24-Bits)
                01B -> Reserved
                10B -> Double Precision   (53-Bits)
                11B -> Extended Precision (64-Bits)
bits 10, 11: Rounding Control
                00B -> Round to nearest (even)
                01B -> Round down (toward -invinity)
                10B -> Round up   (toward -invinity)
                11B -> Round toward zero (Truncate)
----------------------------------
bit  12    : Infinity Control (for comaptibility with "287" purposes only, no meaning for Pentium)
bits 13..15: Reserved
-------------------------------------------------------------------------
13.09.04 P.W:
During create preview in knmulti Analyse Print Display occures:
"FpuCw changed from 4978 to 4722"
(here WinXP Service Pack 1, printer hp 5952)

  This message comes from FemurPcForm1.pas procedure MonitorFpuCw;
  (called by TfrmMain.Timer1Timer, interval is 20 ms)

Def  4914 = $1332  1 0011 0011 0010
From 4978 = $1372  1 0011 0111 0010
To   4722 = $1272  1 0010 0111 0010
  changed: bit 8 cleared so bits 9,8 from  bin"11" to "10"
    --> Extended Precision to Double Precision
-------------------------------------------------------------------------
*)

function MyGet8087CW: Word;
// use MyGet8087CW paired with MySet8087CW
begin
  Result := Get8087CW;
  MonitorFpuCwBlinded := True; // avoid messages about FpuChanges already handled here
end;

procedure MySet8087CW(FPUControlWord: Word);
// use MyGet8087CW paired with MySet8087CW
begin
  asm
    FNCLEX  // don't raise pending exceptions enabled by the new flags
    FLDCW FPUControlWord
  end;

  MonitorFpuCwBlinded := False;
end;

function MonitorFpuCw_Changed(var Last_FPUControlWord: Word; Var Msg: AnsiString): Boolean;
// compare also System.pas : Default8087CW , Set8087CW
var
  FPUControlWord: Word;
begin
  Result := False;
  asm
    //from Dialogs.pas: Avoid FPU control word change in NETRAP.dll, NETAPI32.dll, etc
    FNSTCW  FPUControlWord;
  end;

  if (FPUControlWord <> Last_FPUControlWord) then
  begin
    if (Last_FPUControlWord <> 0) then
    begin
      Msg := Format('FpuCw changed from $%x to $%x!', [Last_FPUControlWord, FPUControlWord]);
      Last_FPUControlWord := FPUControlWord;
      Result := True;
//      ShowMessage(Msg);
    end else
    begin
      Last_FPUControlWord := FPUControlWord;
    end;
  end;
end;

function MonitorFpuCw_Changed_2(var Last_FPUControlWord: Word; Var Msg: AnsiString): Boolean;
// 05.12.08 P.W created as copy of MonitorFpuCw_Changed
// compare also System.pas : Default8087CW , Set8087CW
// Modifications
// 05.12.08 P.W:
//  a) new: When a change of FPUControlWord has been detected then the previous state is restored
//  b) Sends less messages than MonitorFpuCw_Changed:
//       Only change of bits 8, 9 (Precision) and 10, 11 (Rounding) return True: Critical change
//       other changes return False
// running code is not interrupted by Timer excepted the running code calls Application.processMessages
// so there is no risk to reset FPUCW during a Trunc operation of our Application.
//  possible is that a dialog is not called with MonitorFpuBlinded then the FPUCw is resetted while the dialog is running!
// 17.12.08 P.W: use EventLog, Message changed to sinle line;

  function GetRoundMode_CW(FpuCW: Word): TFPURoundingMode;
  // 05.12.08 P.W from Math.pas
  begin
    Result := TFPURoundingMode((FpuCW shr 10) and 3);
  end;

  function GetPrecisionMode_CW(FpuCW: Word): TFPUPrecisionMode;
  // 05.12.08 P.W from Math.pas
  begin
    Result := TFPUPrecisionMode((FpuCW shr 8) and 3);
  end;


const
  MskExceptions  = $003F; // =(1 shl  0) + (1 shl  1) + (1 shl 2) + (1 shl 3) + (1 shl 4) + (1 shl 5),h;
  MskReserved    = $E0C0; // =(1 shl  6) + (1 shl  7) + (1 shl 13) + (1 shl 14) + (1 shl 15),h;
  MskPrecision   = $0300; // =(1 shl  8) + (1 shl  9),h;
  MskRound       = $0C00; // =(1 shl 10) + (1 shl 11),h;
  MskComp287     = $1000; // =(1 shl 12),h;
  MskIgnore      = MskReserved or MskComp287; // = $F0C0
var
  FPUControlWord, FpuDiff: Word;
  DifExceptions, DifPrecision, DifPrecCrit, DifRound: Boolean;
  PrecLast, PrecCur : TFPUPrecisionMode;
begin
//beep(100, 1);
  Result := False;
  asm
    //from Dialogs.pas: Avoid FPU control word change in NETRAP.dll, NETAPI32.dll, etc
    FNSTCW  FPUControlWord;
  end;

  if (FPUControlWord <> Last_FPUControlWord) then
  begin
    if (Last_FPUControlWord = 0) then  // first check ($0000 is not a possible FpuCW)
    begin
      Last_FPUControlWord := FPUControlWord;
    end else
    begin
      Set8087CW(Last_FPUControlWord);  // restore to expected value soon (to avoid further calls by timer);

      Msg := Format('from $%.4x to $%.4x! previous restored',
                    [Last_FPUControlWord, FPUControlWord]);

      FpuDiff := Last_FPUControlWord xor FPUControlWord;  // FpuDiff: only differences are set
      FpuDiff := FpuDiff and (not MskIgnore);             // FpuDiff: ignored differences are cleared
      if (FpuDiff <> 0) then                              // Remaining differences
      begin  // more or less critical changes detected

        DifExceptions := (FpuDiff and MskExceptions) <> 0;
        DifPrecision  := (FpuDiff and MskPrecision ) <> 0;
        DifRound      := (FpuDiff and MskRound     ) <> 0;
        if DifRound then
          Msg := Msg + ' (Rounding)';
        if DifPrecision  then
          Msg := Msg + ' (Precision)';
        if DifExceptions then
          Msg := Msg + ' (Exceptions)';

        if DifPrecision then
        begin
          PrecLast    := GetPrecisionMode_CW(Last_FPUControlWord);
          PrecCur     := GetPrecisionMode_CW(     FPUControlWord);
          // regard change of Precision as critical excepted change from pmDouble to pmExtended and vice versa:
          DifPrecCrit := not
            (
              (PrecLast in [pmDouble, pmExtended])
                and
              (PrecCur  in [pmDouble, pmExtended])
            );

        end else
        begin
          DifPrecCrit := False;
        end;
        Result := DifPrecCrit or DifRound;      // True: critical changes detected

        EventsLog.Append(Msg, ELK_FpuCwChange, True);  // 17.12.08 P.W
      end;
    end;
  end;
end;

var
  Last_FPUControlWord_A: Word = 0;
  Last_FPUControlWord_B: Word = 0;
procedure MonitorFpuCw;
// compare also System.pas : Default8087CW , Set8087CW
// Modifications
// 05.12.08 P.W: MonitorFpuCw_Changed_2 instead of MonitorFpuCw_Changed
//   Message maximal for 8 seconds on screen
// 17.12.08 P.W: no longer a Message to user; MonitorFpuCW_Changed_2 uses EventLog
var
  Msg : AnsiString;
begin
  if MonitorFpuCwBlinded then EXIT;

  MonitorFpuCw_Changed_2(Last_FPUControlWord_A, Msg)  // "_2" : 05.12.08 P.W
    //ShowMessage(Msg);                                   // u.: 05.12.08 P.W
  //  ShowMessageFmt_(Msg, 8000, True, MB_ICONWARNING);    // s.: 05.12.08 P.W // u. 17.12.08 P.W
end;

procedure MonitorFpuCw_Debug;
// compare also System.pas : Default8087CW , Set8087CW
// 05.12.08 P.W: for debugging purposes (debugging of MonitorFpuCw when called from timer is tricky)
var
  Msg : AnsiString;
begin
  if MonitorFpuCw_Changed_2(Last_FPUControlWord_A, Msg) then
    ShowMessageFmt_(Msg, 8000, True, MB_ICONWARNING);
end;

var
  MonitorFpuCwList_B : TStringList = nil;
procedure MonitorFpuCw_B(const CallMsg:String='');
// compare also System.pas : Default8087CW , Set8087CW
var
  Msg : AnsiString;
begin
  if not Assigned(MonitorFpuCwList_B) then
    MonitorFpuCwList_B := TStringList.Create;
  MonitorFpuCwList_B.Append(CallMsg);
  if MonitorFpuCw_Changed(Last_FPUControlWord_B, Msg) then
  begin
    ShowMessage(MonitorFpuCwList_B.Text+#13#10+Msg+#13#10+'-B- '+CallMsg);

  end;
end;


// vvv ------------------------------------------------------------------------- // 04.11.08 P.W
// Copy of all parts necessary to support PrinterSetupDialog correctly under Vista
// Problem: number of copies is no longer returned in pDevMode.dmCopies but under
// TPrintDlg.nCopies!

//{$UNDEF VER150}
{$IFNDEF VER150}
   When the compiler is no longer of Version 15.0 then this codesegment must be removed
   TPrinterSetupDialog_Vista then no longer used
{$ENDIF}

type
  tSpyRec = packed record
    case Integer of
      0 : (FObjectInstance : Pointer);
      1 : (B0, B1, B2, B3: Byte);
      2 : (BA : Array [0..16] of Byte);
      3 : (P0: Byte; FObjInst1: Pointer);
      4 : (P1, P2: Byte; FObjInst2: Pointer);
      5 : (P3, P4, P5: Byte; FObjInst3: Pointer);
      6 : (P6, P7, P8, P9: Byte; FObjInst4: Pointer);
  end;


//    {$A1}
//    {$A2}
//    {$A4}
//    {$A8}

  TestAlignRec = Record
    A: Byte;
    B: Integer;
  end;

{$IF SizeOf(TestAlignRec) = 5}
  {$DEFINE Align_was_A01}        // A1
{$IFEND}
{$IF SizeOf(TestAlignRec) = 6}
  {$DEFINE Align_was_A02}        // A2
{$IFEND}
{$IF SizeOf(TestAlignRec) = 8}
  {$DEFINE Align_was_A48}        // A4 or A8
{$IFEND}


{$A4}
  TCommonDialog_Hack = class(TComponent)
  private
    FCtl3D: Boolean;
    FDefWndProc: Pointer;
    FHelpContext: THelpContext;
    FHandle: HWnd;
    FObjectInstance: Pointer;
  end;
{$IFDEF Align_was_A01}        // A1
  {$A1}
{$ENDIF}
{$IFDEF Align_was_A02}        // A2
  {$A2}
{$ENDIF}
{$IFDEF Align_was_A48}        // A4 or A8
  {$A4}
{$ENDIF}

  TPrinterSetupDialog_Vista = class(TPrinterSetupDialog)
  public
    function Execute: Boolean; reintroduce; //override;
  end;

var
  CreationControl: TCommonDialog_Hack = nil;

{ Center the given window on the screen }

procedure CenterWindow(Wnd: HWnd);
var
  Rect: TRect;
  Monitor: TMonitor;
begin
  GetWindowRect(Wnd, Rect);
  if Application.MainForm <> nil then
  begin
    if Assigned(Screen.ActiveForm) then
      Monitor := Screen.ActiveForm.Monitor
      else
        Monitor := Application.MainForm.Monitor;
  end
  else
    Monitor := Screen.Monitors[0];
  SetWindowPos(Wnd, 0,
    Monitor.Left + ((Monitor.Width - Rect.Right + Rect.Left) div 2),
    Monitor.Top + ((Monitor.Height - Rect.Bottom + Rect.Top) div 3),
    0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
end;

{ Generic dialog hook. Centers the dialog on the screen in response to
  the WM_INITDIALOG message }

function DialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
begin
  Result := 0;
  if Msg = WM_INITDIALOG then
  begin
    CenterWindow(Wnd);
    CreationControl.FHandle := Wnd;
    CreationControl.FDefWndProc := Pointer(SetWindowLong(Wnd, GWL_WNDPROC,
      Longint(CreationControl.FObjectInstance)));
    CallWindowProc(Pointer(CreationControl.FObjectInstance), Wnd, Msg, WParam, LParam);
    CreationControl := nil;
  end;
end;

{ Printer dialog routines }

procedure GetPrinter(var DeviceMode, DeviceNames: THandle);
var
  Device, Driver, Port: array[0..1023] of char;
  DevNames: PDevNames;
  Offset: PChar;
begin
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
  if DeviceMode <> 0 then
  begin
    DeviceNames := GlobalAlloc(GHND, SizeOf(TDevNames) +
     StrLen(Device) + StrLen(Driver) + StrLen(Port) + 3);
    DevNames := PDevNames(GlobalLock(DeviceNames));
    try
      Offset := PChar(DevNames) + SizeOf(TDevnames);
      with DevNames^ do
      begin
        wDriverOffset := Longint(Offset) - Longint(DevNames);
        Offset := StrECopy(Offset, Driver) + 1;
        wDeviceOffset := Longint(Offset) - Longint(DevNames);
        Offset := StrECopy(Offset, Device) + 1;
        wOutputOffset := Longint(Offset) - Longint(DevNames);;
        StrCopy(Offset, Port);
      end;
    finally
      GlobalUnlock(DeviceNames);
    end;
  end;
end;

procedure SetPrinter(DeviceMode, DeviceNames: THandle);
var
  DevNames: PDevNames;
begin
  DevNames := PDevNames(GlobalLock(DeviceNames));
  try
    with DevNames^ do
      Printer.SetPrinter(PChar(DevNames) + wDeviceOffset,
        PChar(DevNames) + wDriverOffset,
        PChar(DevNames) + wOutputOffset, DeviceMode);
  finally
    GlobalUnlock(DeviceNames);
    GlobalFree(DeviceNames);
  end;
end;

function CopyData(Handle: THandle): THandle;
var
  Src, Dest: PChar;
  Size: Integer;
begin
  if Handle <> 0 then
  begin
    Size := GlobalSize(Handle);
    Result := GlobalAlloc(GHND, Size);
    if Result <> 0 then
      try
        Src := GlobalLock(Handle);
        Dest := GlobalLock(Result);
        if (Src <> nil) and (Dest <> nil) then Move(Src^, Dest^, Size);
      finally
        GlobalUnlock(Handle);
        GlobalUnlock(Result);
      end
  end
  else Result := 0;
end;

{ TPrinterSetupDialog }

function TPrinterSetupDialog_Vista.Execute: Boolean;
var
  PrintDlgRec: TPrintDlg;
  DevHandle: THandle;
  DevMode : PDeviceMode;  // 04.11.08 P.W
begin
  FillChar(PrintDlgRec, SizeOf(PrintDlgRec), 0);
  with PrintDlgRec do
  begin
    lStructSize := SizeOf(PrintDlgRec);
    hInstance := SysInit.HInstance;
    GetPrinter(DevHandle, hDevNames);
    hDevMode := CopyData(DevHandle);
    Flags := PD_ENABLESETUPHOOK or PD_PRINTSETUP;
    lpfnSetupHook := DialogHook;
    hWndOwner := Application.Handle;
    CreationControl := @Self; // 04.11.08 P.W (because Dialogs.TaskModalDialog sets Dialogs.CreationControl which we do NOT use)
    Result := TaskModalDialog(@PrintDlg, PrintDlgRec);

    // --- for vista: 04.11.08 P.W ---
      if PrintDlgRec.nCopies > 1 then
      begin
        DevMode := GlobalLock(hDevMode);
        DevMode.dmCopies := nCopies;
        GlobalUnlock(hDevMode);
      end;
    // -------------------------------

    if Result then
      SetPrinter(hDevMode, hDevNames)
    else begin
      if hDevMode <> 0 then GlobalFree(hDevMode);
      if hDevNames <> 0 then GlobalFree(hDevNames);
    end;
  end;
end;

// ^^^ ------------------------------------------------------------------------- // 04.11.08 P.W


function  CommonDialog_Execute(Dlg: TCommonDialog): BOOL;
// call a CommoDialog and ignore changed FPUCword because this is handled in
//  Dialogs.pas TCommonDialog.TaskModalDialog
// modifications:
// 19.10.05 P.W:
// a) for OpenDialogs and SaveDialogs handle the situation that Dialogs with an invalid
//    filename will never be shown (FileName = "C:" will never be shown!)
// b) handle Exceptions during Execute
// 04.11.08 P.W: Support TPrinterSetupDialog_Vista incase of TPrinterSetupDialog
var
  FPUControlWord: Word;
  SaveDir : String;
  Retryflg : Boolean;  // 19.10.05 P.W
begin
  repeat               // 19.10.05 P.W
    SaveDir := GetCurrentDir; // 04.10.04 P.W
    FPUControlWord := MyGet8087CW;

    Result := False;   // 19.10.05 P.W
    Retryflg := False; // 19.10.05 P.W
    try  // try : 19.10.05 P.W       // despite Dlg.Execute is not expected to throw an exception ...

    if Dlg is TPrinterSetupDialog then // 04.11.08 P.W
      Result := TPrinterSetupDialog_Vista(Dlg).Execute // 04.11.08 P.W
    else
      Result := Dlg.Execute;
       // Print Setup Dialog does not keep the FpuCW when in the dialog you
       //  1st change printer selection from Hp5600 series to HpLaser 5p and then
       //  2nd Abort the dialog
       // this occurs only first time in each run of program when printer has not been used
       //  (maybe printer index -1 leads to set default printer)

    finally // finally: 19.10.05 P.W

      if not Result then // 19.10.05 P.W
      begin
        case CommDlgExtendedError of
          FNERR_INVALIDFILENAME :
            begin
              if Dlg is TOpenDialog then  // includes also SaveDialogs
              begin // dialog did not appear so retry may make sense:
                Retryflg := TOpenDialog(Dlg).FileName <> '';
                TOpenDialog(Dlg).FileName := '';
                // if Retryflg then ShowMessage('Retry dialog');
              end;
            end;
        end;
      end;

      MySet8087CW(FPUControlWord);

      SetCurrentDir(SaveDir);   // 04.10.04 P.W  as long as relative pathes expect WorkDir
    end; // end finally: 19.10.05 P.W
  until not RetryFlg;
end;

function DlgGetFileNameWithValidExt(Dlg: TOpenDialog; out OldExt, NewExt: String): String;
// 18.04.08 P.W
begin
  Result := GetFileNameWithValidExt(Dlg.FileName, Dlg.DefaultExt, Dlg.Filter, Dlg.FilterIndex, OldExt, NewExt);
end;

function DlgGetFilterIndexFromExt(Dlg: TOpenDialog; const Ext: String): Integer;
// 18.04.08 P.W
begin
  Result := GetFilterIndexFromExt(Dlg.Filter, Ext);
end;

procedure DlgPreset(Dlg: TOpenDialog; const DefFileName, DefInitialDir: String);
// 18.04.08 P.W
begin
  if (DefFileName <> '')    then
  begin
    Dlg.FileName   := DefFileName;
    Dlg.FilterIndex := DlgGetFilterIndexFromExt(Dlg, ExtractFileExt(DefFileName));
  end;
  if (Dlg.FileName = '') then Dlg.InitialDir := ExcludeTrailingPathDelimiter(DefInitialDir);
end;

function DlgIsFileExtValid(Dlg: TOpenDialog): Boolean;
// 18.04.08 P.W
begin
  Result := IsExtValid(ExtractFileExt(Dlg.FileName), Dlg.Filter);
end;

function DlgOpen(Dlg: TOpenDialog; const DefFileName, DefInitialDir: String): Boolean;
// 18.04.08 P.W
begin
  Result := False;

  // Presettings:
  DlgPreset(Dlg, DefFileName, DefInitialDir);

  if CommonDialog_Execute(Dlg) then
  begin
    Result := DlgIsFileExtValid(Dlg);
    if not Result then
      MessageDlg(
        Format('Extension of selected file is not valid!', [])
      , mtWarning, [mbOk], 0);
  end;
end;


function DlgSaveAs(Dlg: TSaveDialog; const DefFileName, DefInitialDir: String): Boolean;
// 18.04.08 P.W
//   presets Dlg.FilterIndex and InitialDir if Dlg.FileName is empty
//   ensure a valid extension has been added by DlgGetFileNameWithValidExt
var
  OldExt, NewExt: String;
  Msg : AnsiString;
  ExtChanged, Exist: Boolean;
  DlgType : TMsgDlgType;
  //Debug: Dlg.Filter := 'Text files (*.txt)|*.TXT|Pascal files|*.PAS;*.DPK;X*.DPR|All files|*.*';
begin
  Result := False;

  // Presettings:
  DlgPreset(Dlg, DefFileName, DefInitialDir);
  Dlg.Options := Dlg.Options + [ofNoReadOnlyReturn];     // Readonly file may not be selected!

  // Dialog:
  if CommonDialog_Execute(Dlg) then
  begin
    // Check Extension
    Dlg.FileName := DlgGetFileNameWithValidExt(Dlg, OldExt, NewExt);
    ExtChanged   := ExtCompare(OldExt, NewExt) in [ECR_SecondEmpty, ECR_NotEqual];
    Exist        := FileExists(Dlg.FileName);
    Result       := True;
    if ExtChanged or Exist then
    begin // Dialog Changed Extension and or Existing
      Result := False;
      Msg := '';

      if ExtChanged then
      begin
        DlgType := mtWarning;
      end else
      begin
        DlgType := mtConfirmation;
      end;

      if Exist then
        Msg := Msg + sLineBreak +
               Format('File "%s" already exists!', [Dlg.FileName]);

      if ExtChanged then
        Msg := Msg + sLineBreak +
               Format('Extension has been changed from "%s" to "%s"', [OldExt, NewExt]);

      if Exist then
        Msg := Msg + sLineBreak +
                     sLineBreak +
               'Do you want to replace the file?'
      else
        Msg := Msg + sLineBreak +
                     sLineBreak +
               'Continue saving the file?';

      Case MessageDlg(Msg, DlgType, [mbYes, mbNo], 0) of
        mrYes : Result := True;
        else    Result := False;
      end;
    end;
  end;
end;

procedure ShowMessageS(Msg: AnsiString);
// 26.08.09 P.W
begin
  MessageBox1Flg := True;
  try
    ShowMessage(Msg);
  finally
    MessageBox1Flg := False;
  end;
end;

procedure ShowMessageFmtS(const Msg: string; Params: array of const);
// 26.08.09 P.W
begin
  ShowMessageS(Format(Msg, Params));
end;


procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  CreationControl       := nil;
  Last_FPUControlWord_A := 0;
  Last_FPUControlWord_B := 0;
  MonitorFpuCwBlinded   := False;
  MonitorFpuCwList_B    := nil;

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
