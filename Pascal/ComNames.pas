unit ComNames;
// created 02.09.05 P.W to support names for use in all projects
//  without the overhead of GlbPath
// Modifications:
// 20.12.06 P.W:
//  new function SliceNrToNamePart(SliceNr: Integer): String;
//  new function SliceNameToSliceNr(SliceName: String) : Integer;
//  new function SliceNameToCtNr(SliceName: String) : Integer;
//  new const SliceNrNamePartMask = '.???' use to replace '.M*' and '.M??' to support more than 255 slices
//  new const StartSliceNrNamePart = '.' use to replace '.M' when used in Pos().
// 21.02.24 P.W  DevelopeXctDir = 'D:\XCT\' -> 'C:\XCT\'
// 25.04.24 P.W  function  IsDevelopePath no longer tests for 'C:\XCTCMP\' but for 'C:\XCTANADLL\'

interface

uses
  HaltUnit,
  Param_StrUnit,
  SysUtils;   // 20.12.06 P.W

const
// Inst_MinDiskFree from Install.pas to ComNames: // 23.01.09 P.W
//Inst_MinDiskFree      = Int64 (40000000);       // 20 MB ->   40 MB: 08.05.01 P.W
//Inst_MinDiskFree      = Int64 (60000000);       // 40 MB ->   60 MB: 08.10.07 P.W
  Inst_MinDiskFree      = Int64 (1000*1000*1000); // 60 MB -> 1000 MB: 23.01.09 P.W
  Inst_MinDiskFreeMsg   = ' 1000 MB';             // 23.01.09 P.W
// See also: General.pas MinimuSpaceFreeWorkDrive and XMenu.pas CheckDriveSpace

const
//  BnLockNameBatch  = 'SERV\BNLOCK.EXE';
//  BnLockNameDelphi = 'SERV\BNLOCKDELPHI.EXE';
  BnLockName                     = 'SERV\BNLOCK.EXE';
// from GlbPath.pas
  XCTDIRVAR           = 'XCTDIR';
  LocInterDir                    = 'INTER\';
  LocUtilDir                     = 'UTIL\';
  LVJobName                      = LocInterDir + 'LVJOB.TXT'; // from LV_Tools
  LVJobResName                   = LocInterDir + 'LvJobRes.txt'; // 20.11.08 P.W
  LVJobProgressName              = LocInterDir + 'LvJobPrg.txt'; // 20.11.08 P.W
  XbAnaName                      = LocInterDir + 'XBANA.TXT';    // 24.08.09 P.W
  TempXmenuJobName               = LocInterDir + 'XMENUJOB.TX1'; // 09.12.09 P.W
  StopXmenuJobName               = LocInterDir + 'XMENUJOB.END'; // 09.12.09 P.W

// from UBnLockWin.pas
  BnLockFileList = 'INIT\BNLOCKLST.TXT';
  BnLockCrcList  = 'INIT\BNLOCKCRC.TXT';
  CrcExeListName = 'CRCEXE.TXT';
  CrcDirListName = 'CRCDIR.TXT';

// from WinTools:
//XctConLaunchTitle   = 'Stratec XCT Console';  // moved to GetXCTLaunchTitle: 08.10.07 P.W
  LaunchXctConBatName = 'START01.BAT';

// from UfrmShowRef.pas
  ReferencesFolder = 'References';
  CtNrLogName = 'LOG\CTNRLOG.TXT';   // 11.10.05 P.W
  FirstSliceExt = '.M01';            // 11.10.05 P.W
  StartSliceNrNamePart = '.';                     // 20.12.06 P.W
  SliceNrNamePartMask = '.???';                   // 20.12.06 P.W     // as replacement for '.M*', '.M??'
  ImageNameMask = 'I???????'+SliceNrNamePartMask; // 20.12.06 P.W

  ReferencesIni_Default  = ReferencesFolder + '\Ref_Default.ini';      // 21.10.05 P.W
  FirstSliceNrGlb = 1;                                                 // 20.12.06 P.W
  DevelopeXctDir  = 'C:\XCT\';     // 21.02.24 P.W  DevelopeXctDir 'D:\XCT\' -> 'C:\XCT\'
  DevelopeXctDev  = 'XCT2003.A\';

  TempLogName      = 'LOG\TempLog.TXT';     // 09.07.08 P.W
  TempLogNameOld   = 'LOG\TempLog_Old.TXT'; // 09.07.08 P.W
  TempLogLimitSize = 1000000;               // 09.07.08 P.W

  C_LastCtBat      = LocInterDir + 'LASTCT.BAT';  // from XbJob1.pas  06.11.08 P.W
  LocMasksIniName  = 'INIT\Masks.ini';      // 26.01.09 P.W


function  IsDevelopePath: Boolean;  // 02.07.08 P.W

function  SliceNrToNamePart(SliceNr: Integer): String;                 // 20.12.06 P.W
function  SliceNameToSliceNr(SliceName: String) : Integer;             // 20.12.06 P.W
function  SliceNameToCtNr(SliceName: String) : Integer;                // 20.12.06 P.W
function  SliceNrToName(const aName: String; SliceNr: Integer): String;// 20.12.06 P.W

function GetXCTLaunchTitle(LaunchDir: AnsiString): AnsiString; // 08.10.07 P.W

Implementation
  const Unit_Name = 'ComNames'; // 03.05.24 P.W

function  IsDevelopePath: Boolean;  // 02.07.08 P.W
begin
//Result := (Pos('C:\XCTCMP\', UpperCase(Param_Str(0))) = 1);
  Result := (Pos('C:\XCTANADLL\', UpperCase(Param_Str(0))) = 1)   // 25.04.24 P.W
     or     (Pos('C:\XCT\', UpperCase(Param_Str(0))) = 1) 
end;


function  SliceNrToNamePart(SliceNr: Integer): String;                 // 20.12.06 P.W
// returns extension : ".M01" .. ".MFF", ".N00", ...

// Window Explorer hides some extensions ever. Among these are ".LNK", ".MAD", ".MAF", ".SCF"
//	(.MAD = Slice 173; .MAF = Slice 175; .SCF = Slice 1743 (Slice > 1000 and so not used at time))
//	But this makes no problems to XCT software the used functions FindFirst FindNext support the complete names.

  Function InvValHex           (L:LongInt; Len:Byte): String;
  // as copy from Tools.pas to avoid conflicts when Using Tools.pas uses CRT.Pas ...
  const
    HexArr           : Array [0..$F] of Char
                     = ('0','1','2','3','4','5','6','7','8','9',
                        'A','B','C','D','E','F');
  Var
    Txt              : String;
  begin
    SetLength(Txt, Len); // Txt[0]:=Char(Len);
    While (Len>0) do
    begin
      Txt[Len]:=HexArr[L and $F];
      L:=L Shr 4;
      dec(Len);
    end;
    InvValHex:=Txt;
  end; { Function InvValHex }

begin
  Result := '.' + Char(Ord('M') + SliceNr div 256) + InvValHex(SliceNr mod 256, 2);
end;

function  SliceNrToName(const aName: String; SliceNr: Integer): String;   // 20.12.06 P.W
begin
  Result := ChangeFileExt(aName, '') + SliceNrToNamePart(SliceNr);
end;

function  SliceNameToSliceNr(SliceName: String) : Integer;             // 20.12.06 P.W
const
  HexChars = ['0' .. '9', 'A' .. 'F'];
var
  Ext : String;
begin
  Ext := UpperCase(ExtractFileExt(SliceName));
  if (Length(Ext) = 4)      and
     (Ext[1] = '.')         and
     (Ext[2] in ['M'..'Z']) and
     (Ext[3] in HexChars)   and
     (Ext[4] in HexChars)   then
  begin
    Result := 256 * (Ord(Ext[2]) - Ord('M')) + StrToIntDef('$'+Ext[3]+Ext[4], 0);
  end else
  begin
    Result := -1;
  end;
end;

function  SliceNameToCtNr(SliceName: String) : Integer;                // 20.12.06 P.W
var
  P : Integer;
begin
  P := LastDelimiter('.' ,SliceName);
  if P >= 9 then
  begin
    Result := StrToIntDef(Copy(SliceName, P - 7, 7), -1);
  end else
  begin
    Result := -1;
  end;
end;

function GetXCTLaunchTitle(LaunchDir: AnsiString): AnsiString; // 08.10.07 P.W
const  // moved to here, force use of GetXctLaunchTitle  // 08.10.07 P.W
  XctConLaunchTitle   = 'Stratec XCT Console';
begin
  if LaunchDir = '' then
    Result := XctConLaunchTitle
  else
    Result := XctConLaunchTitle+' ('+LaunchDir+')';
  Result := StringReplace(Result, '\', '_', [rfReplaceAll, rfIgnoreCase] );
  Result := StringReplace(Result, ':', '_', [rfReplaceAll, rfIgnoreCase] );
  Result := StringReplace(Result, '__', '_', [rfReplaceAll, rfIgnoreCase] );
end;

procedure Test;
var
  I : Integer;
begin
  I := SliceNameToCtNr('D:\XCT\AV123\A1234560\C1234567.M01');
  if I = 0 then;
  I := SliceNameToSliceNr('D:\XCT\AV123\A1234560\C1234567.PE8');
  if I = 0 then;
  I := SliceNameToSliceNr('D:\XCT\AV123\A1234560\C1234567.M01');
  if I = 0 then;
  I := SliceNameToSliceNr('D:\XCT\AV123\A1234560\C1234567.MFF');
  if I = 0 then;
  I := SliceNameToSliceNr('D:\XCT\AV123\A1234560\C1234567.N00');
  if I = 0 then;
  H_alt(1);
end;

{
procedure TestFileExtensionCreation;
const
  TstPath = 'C:\Temp\TstSlcExt';
var
  I : Integer;
  SL : TStringList;
begin
  SL := TStringList.Create;
  ForceDirectories(TstPath);
  for I := 0 to 2000 do
  begin
    SL.SaveToFile(TstPath+Format('\CI0%.5d', [I])+SliceNrToNamePart(I));
  end;
  SL.Free;
end;
}


//initialization
//  Test;

end.
