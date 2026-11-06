unit EventLogs;
// 17.12.08 P.W
// Purpose: support additional event-logs wiht limited size as in FemErr2.pas for LocErrName
// Aim: get a more general object
// Use FileNameMasks like "Res\EventsLog%.2d.txt"
// --> current file is "Res\EventsLog00.txt" (Nr = 0)
// --> previous file is "Res\EventsLog01.txt" (Nr = 1)
// --> preprevious file is "Res\EventsLog02.txt" (Nr = 2)
//    ...
// file sizes are limited to nearly EventsLogMaxSize
//   at open and during (Append) the filesize is tested during append 20% more are allowed to
// reduce swaping during run of an application.
// Access to Eventslog via function EventsLog ensures EventsLog is created
// Open and close is supported automatically: Append openes (and checks for swap)
// units finalization closes opened EventsLog
//

interface

uses
  DebugUnit,        // 03.05.24 P.W
  InitFinal_List,   // 03.05.24 P.W
  HaltUnit,         // 03.05.24 P.W
  Param_StrUnit,    // 03.05.24 P.W
  DosTimer,
  SysUtils, WindowsEx, DateUtils, Classes, StrUtils,
  GlbPath;

type
  TEventsLogKey =
    ( ELK_None,            // no key used
      ELK_Debug,           // Debug Messages
      ELK_FpuCwChange,     // unexpected change of Floating Point Unit Codeword detected
      ELK_RestoreDatabase, // Database Restored
      ELK_ParameterChange, // Change of parameters detected by bnlock ...
      ELK_ExeCrcChange,    // Change of Executables Crc detected
      ELK_TempMaxReached   // Pause Temperature reaches limit      // 24.07.09 P.W
    );

const
  EventsLogKeyMsgArr : Array [TEventsLogKey] of AnsiString =
    ('',                    // no key used
     'ELK_Debug',           // Debug Messages
     'ELK_FpuCwChange',     // unexpected change of Floating Point Unit Codeword detected
     'ELK_RestoreDatabase', // Database Restored
     'ELK_ParameterChange', // Change of parameters detected by bnlock ...
     'ELK_ExeCrcChange',    // Change of Executables Crc detected
     'ELK_TempMaxReached'   // Pause Temperature reaches limit     // 24.07.09 P.W
    );
type
  TEventsLog = class(TObject)
  private
    fText : Text;
    fFileNameMask : AnsiString;
    fOpen : Boolean;
    fTimeOpen  : TDateTime;
    fTimerOpen : TDosTimer;
    fCheckSizeSwapRuns : Boolean;
    function CheckOpen(SwapFlg: Boolean): Boolean;
    function GetTimeStamp: AnsiString;
    function CheckSizeSwap: Boolean;
    function GetFileName: AnsiString;
    function GetFileNameNr(Idx: Integer): AnsiString;
    function OpenSwapMessage(SwapFlg: Boolean): AnsiString;
    property  FileNameNr[Idx:Integer]: AnsiString read GetFileNameNr;
    function GetExistingFiles: TStringList;
    function GetFilesCount: Integer;
  public
    constructor Create(aFileNameMask: AnsiString);
    destructor  Destroy;  override;
    procedure CheckClose(SwapFlg:Boolean=False);

    function EventsLogKeyMsg(ELK: TEventsLogKey): AnsiString;

    procedure Append(const Msg: AnsiString; ELK:TEventsLogKey=ELK_None; SingleLine:Boolean=False); overload;
    procedure Append(const aFmt: AnsiString;
      const Args: Array of const; ELK:TEventsLogKey=ELK_None; SingleLine:Boolean=False); overload;
    property FileName: AnsiString read GetFileName;
    property FilesCount: Integer read GetFilesCount;
    property ExistingFiles: TStringList read GetExistingFiles;

  end;

function EventsLog: TEventsLog;

Implementation
  const Unit_Name = 'EventLogs'; // 03.05.24 P.W

const
  EventsLogMaxSize    = LimitErrorLogSize; // nearly 1.2 MB at 17.12.08 P.W
  EventsLogMaxNumPrev = 3; // allows current=00 and previous 01 02 03 files

var
  fEventsLog : TEventsLog = nil;

function EventsLogDateStamp(Time: TDateTime): AnsiString;
begin
  Result :=
    Format('%.4d/%.2d/%.2d',
           [YearOf(Time), MonthOf(Time), DayOf(Time)]);
end;

function EventsLogTimeStamp(Time: TDateTime; WantMillSeconds:Boolean=True): AnsiString;
begin
  Result :=
    Format('%.2d:%.2d:%.2d',
           [HourOf(Time), MinuteOf(Time), SecondOf(Time)]);
  if WantMillSeconds then
    Result := Format('%s.%.3d', [Result, MilliSecondOf(Time)]);
end;

function EventsLogDateTimeStamp(Time: TDateTime; WantMillSeconds:Boolean=True): AnsiString;
begin
  Result := EventsLogDateStamp(Time) + ' ' + EventsLogTimeStamp(Time);
end;

function EventsLogNameFromNr(const aNameMask: AnsiString; Nr: Integer): AnsiString;
// 0: current file; 1: previous; 2: prePrevious ...
begin
  Result := Format(aNameMask, [Nr]);
end;

function MakeSingleLine(S: AnsiString): AnsiString;
const
  LB1 = sLineBreak;
  LB2 = LB1+LB1;
var
  LenD  : Integer;
begin
  // remove duplicate LineBreaks:
  While Pos(LB2, S) > 0 do
    S := StringReplace(S, LB2, LB1, [rfReplaceAll]);

  // Delete Leading LineBreak:
  if Pos(LB1, S) = 1 then
    Delete(S, 1, Length(LB1));

  // remove trailing LineBreak:
  LenD := Length(S) - Length(LB1);
  if PosEx(LB1, S, LenD)=LenD+1 then
      S := Copy(S, 1, LenD);

   // replace LineBreaks by '; '
   S := StringReplace(S, LB1, '; ', [rfReplaceAll]);

  Result := S;
end;


function EventsLog: TEventsLog;
begin
  if not Assigned(fEventsLog) then
  begin
    try
      fEventsLog := TEventsLog.Create(LocEventsLogNameMask);
    except
      fEventsLog := nil;
    end;
  end;
  Result := fEventsLog;
end;

procedure CheckCloseEventsLogs;
begin
  FreeAndNil(fEventsLog);
end;

{ TEventsLog }

function TEventsLog.GetTimeStamp: AnsiString;
var
  Time : TDateTime;
begin
  Result := '';
  Time := Now;
  Result := Format('%7.3f', [ReadDosTimer(fTimerOpen)]);
end;

function TEventsLog.OpenSwapMessage(SwapFlg: Boolean): AnsiString;
var
  MsgOpenSwapPart,
  CmdLineCensored : AnsiString;
begin
  if SwapFlg then
    MsgOpenSwapPart := 'swaped'
  else
    MsgOpenSwapPart := 'opened';

  CmdLineCensored := CmdLine;
  if Pos('BNLOCK', UpperCase(CmdLineCensored)) > 0 then
    CmdLineCensored := Param_Str(0);
  Result := Format('--- %s %s by ''%s''---', [EventsLogDateTimeStamp(fTimeOpen), MsgOpenSwapPart, CmdLineCensored]);
end;

function TEventsLog.CheckOpen(SwapFlg: Boolean): Boolean;
var
  fs : Int64;
  I  : Integer;
begin
  if not fOpen then
  try
    fs := FileSizeInt64(FileName);
    if fs > EventsLogMaxSize then
    begin
      for I := EventsLogMaxNumPrev downto 1 do
      begin
        DeleteFile(                 FileNameNr[I]);
        RenameFile(FileNameNr[I-1], FileNameNr[I]);
      end
    end;
    Assign(fText, FileName);
    if FileExists(FileName) then
      System.Append(fText)
    else
      Rewrite(fText);
    fOpen := True;
    if not SwapFlg then
    begin
      fTimeOpen := Now;
      StartDosTimer(fTimerOpen);
    end;
    Append(OpenSwapMessage(SwapFlg));
  except
    fOpen := False;
    try
      Close(fText);
    except
    end;
  end;
  Result := fOpen;
end;

function TEventsLog.CheckSizeSwap: Boolean;
begin
  Result := False;
  if fCheckSizeSwapRuns then Exit;
  if fOpen then
  try
    fCheckSizeSwapRuns := True;
    if (GetFileSizeInt64(TTextRec(fText).Handle) >= 1.2 * EventsLogMaxSize) then
    begin
      Result := True;
      CheckClose(True);
      CheckOpen(True);
    end;
    fCheckSizeSwapRuns := False;
  except
    fCheckSizeSwapRuns := False;
  end;
end;

function TEventsLog.EventsLogKeyMsg(ELK: TEventsLogKey): AnsiString;
begin
  Result := EventsLogKeyMsgArr[ELK];
  if (Result <> '') then Result := Result + ' ';
end;

procedure TEventsLog.Append(const Msg: AnsiString; ELK:TEventsLogKey=ELK_None; SingleLine:Boolean=False);
  function CheckSingleLine(const Msg: AnsiString): AnsiString;
  begin
    if SingleLine then
      Result := MakeSingleLine(Msg)
    else
      Result := Msg;
  end;
begin
  if CheckOpen(False) then
  begin
    CheckSizeSwap;
    try
      Writeln(fText, GetTimeStamp + ': ' + EventsLogKeyMsg(ELK) + CheckSingleLine(Msg));
      Flush  (fText);
    except
      try
        Close(fText);
      except
      end;
      fOpen := False;
    end;
  end;
end;

procedure TEventsLog.Append(const aFmt: AnsiString;
  const Args: array of const; ELK:TEventsLogKey=ELK_None; SingleLine:Boolean=False);
begin
  Append(Format(aFmt, Args), ELK, SingleLine);
end;

constructor TEventsLog.Create(aFileNameMask: AnsiString);
begin
  fFileNameMask := aFileNameMask;
end;

procedure TEventsLog.CheckClose(SwapFlg:Boolean=False);
begin
  if fOpen then
  try
    if SwapFlg then
      Append(OpenSwapMessage(SwapFlg))
    else
      Append('--- closed ---');
    Close(fText);
  except
  end;
  fOpen := False;
end;

destructor TEventsLog.Destroy;
begin
  CheckClose(False);
  inherited;
end;

procedure TestEventsLog;
var
  I : Integer;
begin
  for I := 0 to 149999 do
  begin
    //if I > 0 then Sleep(Random(1000));
    EventsLog.Append('Cycle %.2d: %.6d', [I, Random(999999)]);
  end;
  H_alt(1);
end;

function TEventsLog.GetFileNameNr(Idx: Integer): AnsiString;
begin
  Result := EventsLogNameFromNr(fFileNameMask, Idx);
end;

function TEventsLog.GetFileName: AnsiString;
begin
  Result := GetFileNameNr(0);
end;

function TEventsLog.GetFilesCount: Integer;
var
  I : Integer;
begin
  Result := 0;
  for I := 0 to EventsLogMaxNumPrev do
    if FileExists(FileNameNr[I]) then
      Inc(Result);
end;

function TEventsLog.GetExistingFiles: TStringList;
var
  I : Integer;
begin
  Result := TStringList.Create;
  for I := 0 to EventsLogMaxNumPrev do
    if FileExists(FileNameNr[I]) then
      Result.Append(FileNameNr[I]);
end;

function Unit_Final(aMode: Integer=0): Integer;
// Finalization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  CheckCloseEventsLogs;
end;


procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  fEventsLog := nil;

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
//  TestEventsLog;  // for debugging
  InitFinal_Add(Unit_Name, Unit_Init, Unit_Final);

finalization
(* -v--- moved to function Unit_Final // 03.05.24 P.W
  CheckCloseEventsLogs;
   -^--- moved to function Unit_Final // 03.05.24 P.W *)
end.
