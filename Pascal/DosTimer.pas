// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Vers.: @(#)DosTimer V.:1.00                             ) +*)
(*+ Author           : P.Wueseke                                          +*)
(*+ Date             : 26.04.95      (derived from TimeDos and Glb)       +*)
(*+ Description      :                                                    +*)
(*+   Uses Dos-Timer-Tick Counter to support time measurements up to      +*)
(*+   a limit of 1000 days as long as you call "ReadDosTimer" for all     +*)
(*+   used Timer-Variables before next 24 hours are passed. Otherwise     +*)
(*+   the reset of the dos Timer at 0:00 could not be handeled.           +*)
(*+   Result is given in seconds. Resolution is 1/18 of a second.         +*)
(*+   Result is not reliable if Windows is running in the background.     +*)
(*+   Also if software is running that changes the Dos-Timer              +*)
(*+   or disables the interrupts.                                         +*)
(*+                                                                       +*)
(*+   Example for use:                                                    +*)
(*+                                                                       +*)
(*+     Type                                                              +*)
(*+       Timer1 : tDosTimer;                                             +*)
(*+     begin                                                             +*)
(*+       StartDosTimer(Timer1);                                          +*)
(*+       Readln;                                                         +*)
(*+       Writeln('Time since start in sec: ',ReadDosTimer(Timer1),8,2);  +*)
(*+     end.                                                              +*)
(*+                                                                       +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*+ Date/Modification: 20.11.96 P.W / Add: ClearDosTimer                  +*)
(*+ Date/Modification: 01.10.00 P.W / Mod: Real -> Double                 +*)
(*+ Date/Modification: 05.12.00 P.W / Add: Const CInitDosTimer            +*)
// 18.05.06 P.W: Added TMeasTimer
// 09.07.08 P.W: support use of WinTmr StartPerfTmr and ReadPerfTmrSec to avoid results depend on Timesettings
(*+ Date/Modification  (end of list)                                      +*)
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)
Unit DosTimer;

INTERFACE

uses
  WinTmr, // 09.07.08 P.W
  Dos;

Type
  tDosTimer        = Array[0..1] of LongInt;
                     {two longInt are used to handle reset of counter}

  TMeasTimer = Record  // 18.05.06 P.W
    Timer        : TDosTimer;
    LoopCtr      : Integer;
    MinMeasSec,
    MeasSec,
    TimePerLoop  : Double;
  end;

Function GetTimeCnt: LongInt;
Procedure StartDosTimer(Var Timer: tDosTimer);
Function  ReadDosTimer (Var Timer: tDosTimer):Double;
Procedure ClearDosTimer(Var Timer: tDosTimer);
procedure MeasTimerStart(var MeasTimer: TMeasTimer; aMinMeasSec: Double = 1.0); // 18.05.06 P.W
function  MeasTimerReady(var MeasTimer: TMeasTimer; IncLoopCtr:Boolean=True): Boolean; // 18.05.06 P.W

Implementation
  const Unit_Name = 'DosTimer'; // 03.05.24 P.W


Const
  DayCnt           = 1573040;
  TimeFact         = (3600.0*24.0)/DayCnt; {TimeFact ca.: 1/18.20654}
  CInitDosTimer    = -2*DayCnt;

Function GetTimeCnt: LongInt;
begin
  GetTimeCnt := Trunc(DelphiTime* DayCnt);
end;

Procedure StartDosTimer(Var Timer: tDosTimer);
begin
  if UsePerfTmr then
  begin            // 09.07.08 P.W
    StartPerfTmr(TPerfTmr(Timer));
  end else        // original
  begin
    Timer[0]:=GetTimeCnt;
    Timer[1]:=Timer[0];
  end;
end;

Function  ReadDosTimer (Var Timer: tDosTimer):Double;
{handles reset of counter if called in time distances shorter 24 hours}
// returns time since last StartDosTimer in Seconds
Var
  TimeCnt : LongInt;
begin
  if UsePerfTmr then
  begin               // 09.07.08 P.W
    Result := ReadPerfTmrSec(TPerfTmr(Timer));
  end else
  begin              // original
    TimeCnt:=GetTimeCnt;
    if (TimeCnt<Timer[1]) then Dec(Timer[0], DayCnt);
    Timer[1]:=TimeCnt;
    ReadDosTimer:=(Timer[1]-Timer[0]) * TimeFact;
  end;
end;

Procedure ClearDosTimer(Var Timer: tDosTimer);  {20.11.96 P.W}
// aim: ensure that readdostimer results in a large value  (above 2 hours) (returns nearly two days)
begin
  if UsePerfTmr then
  begin               // 09.07.08 P.W
    TPerfTmr(Timer) := - (2 * 24 * 3600) * GetPerfTmrFreq;
  end else
  begin              // original
    Timer[0]:=-2*DayCnt;
    Timer[1]:=-2*DayCnt;
  end;
end;


procedure MeasTimerStart(var MeasTimer: TMeasTimer; aMinMeasSec: Double = 1.0); // 18.05.06 P.W
begin
  FillChar(MeasTimer, SizeOf(MeasTimer), #0);
  MeasTimer.MinMeasSec := aMinMeasSec;
  StartDosTimer(MeasTimer.Timer);
end;

function  MeasTimerReady(var MeasTimer: TMeasTimer; IncLoopCtr:Boolean=True): Boolean; // 18.05.06 P.W
begin
  if IncLoopCtr then
    Inc(MeasTimer.LoopCtr);
  MeasTimer.MeasSec := ReadDosTimer(MeasTimer.Timer);
  if (MeasTimer.LoopCtr > 0) then
    MeasTimer.TimePerLoop := MeasTimer.MeasSec / MeasTimer.LoopCtr;
  Result := MeasTimer.MeasSec >= MeasTimer.MinMeasSec;
end;

end.
