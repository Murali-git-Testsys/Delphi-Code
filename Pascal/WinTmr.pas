unit WinTmr;
// 08.07.08 P.W
//! use Install.pas procedure BootIni_QueryPerformanceCtr; to ensure correct readings on AMD multiprocessor systems!
interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  Windows,
  SysUtils;

type
  TPerfTmr    = Int64;
// Time until overrun is > 80000 years! (with PerfTmrFreq = 3579545 at hp compaq 2.4 GHz)
//   when clock is not devided by nearly 670 and computers speed up by 1000
//  then overrun occurs each 43 days (this might be to short for a server but not for XCT applications
//  running maximal 7 days for a single multislice measurement ...
  
function UsePerfTmr: Boolean;
function GetPerfTmrFreq : TPerfTmr;
procedure StartPerfTmr(var PerfTmr: TPerfTmr);
function ReadPerfTmrSec(const PerfTmr: TPerfTmr): Double;

procedure ResTstTmr;
procedure ChkTstTmr(SecLimit: Double; const Msg: String);


Implementation
  const Unit_Name = 'WinTmr'; // 03.05.24 P.W

var
  PerfTmrFreq : TPerfTmr = 0;     // counts per second

function UsePerfTmr: Boolean;
// 08.07.08 P.W
begin
  if PerfTmrFreq > 0 then
  begin
    Result := True;
  end else
  if PerfTmrFreq < 0 then
  begin
    Result := False;
  end else
  begin
    if not QueryPerformanceFrequency(PerfTmrFreq)
      then PerfTmrFreq := -1;
    Result := PerfTmrFreq > 0;
  end;
end;

function GetPerfTmrFreq : TPerfTmr;
// 08.07.08 P.W
begin
  UsePerfTmr;
  Result := PerfTmrFreq;
end;

procedure StartPerfTmr(var PerfTmr: TPerfTmr);
// 08.07.08 P.W
var
  PerfTimeC_Help : Int64;
begin
  if UsePerfTmr then
  begin
    //  a:= QueryPerformanceCounter(LE.PerfTimeC);  // this needs "var LE"
    // returns false!
    //  RaiseLastOSError;
    // ->
    // Project XctSerialTest.exe raised exception class EOSError with message 'System Error.  Code: 998.
    // Unzulässiger Zugriff auf einen Speicherbereich'. Process stopped. Use Step or Run to continue.

    // work around:
    QueryPerformanceCounter(PerfTimeC_Help);
    PerfTmr := PerfTimeC_Help;   // no direct access!
  end
  else PerfTmr := -1;
end;

function ReadPerfTmrSec(const PerfTmr: TPerfTmr): Double;
// 08.07.08 P.W
var
  PerfCtr : TPerfTmr;
begin
  if UsePerfTmr then
  begin
    QueryPerformanceCounter(PerfCtr);
    Result := (PerfCtr - PerfTmr) / PerfTmrFreq;
  end else
  begin
    Result := -1;
  end;
end;

var
  TstTmr: TPerfTmr;

procedure ResTstTmr;
begin
  StartPerfTmr(TstTmr);
end;
procedure ChkTstTmr(SecLimit: Double; const Msg: String);
var
  RT : Double;
begin
  RT := ReadPerfTmrSec(TstTmr);
  if RT > SecLimit then
  begin
    MessageBox(0, PChar(Format('Test Time : %5.3f sec; %s', [RT, Msg])), 'Debug Timing', MB_OK);
  end;
  ResTstTmr;
end;


procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  PerfTmrFreq := 0;
  TstTmr      := 0;

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
