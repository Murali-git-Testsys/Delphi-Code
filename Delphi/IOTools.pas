// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; changes: 2; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; changes: 1; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Vers.: @(#)IoTools; V.:1.00                             ) +*)
(*+ Author           : M.Welsch                                           +*)
(*+ Date             : ??.??.95                                           +*)
(*+ Description      :                                                    +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*+ Date/Modification: 07.07.99 P.W / FileExist complete new to handle    +*)
(*+ Date/Modification: 07.07.99 P.W + and find also readonly files        +*)
(*+ Date/Modification: 10.05.01 P.W / DoCopy: copy also the timestamp     +*)
(*+
{22.06.01 P.W}:
  DoCopy use "FileMode:=FileMode_ReadOnly" to allow copy of ReadOnlyFiles
  FileLength also
  Use Unit GlbType
{18.07.03 P.W}
  Function DoCopy renamed to DoCopyN
    Parameter KeepDate added; for compatibility use "True"
  For for compatibility:
    Function DoCopy calls DoCopyN with KeepDate : True
{17.09.03 P.W}
  Function MakePathExist fails if one of the folders has any
  other attribute set than directory:
  Reason found in SingleCheckMake testing the attribute with directory
  CHANGED: Function SingleCheckMake test of attributes corrected
{22.10.03 P.W}
  unused routines into comment
(*+ Date/Modification  (end of list)                                      +*)
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)
Unit IOTools;
{$F+}

INTERFACE

Uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  SysUtils,
  Dos,
  GlbType;         {22.06.01 P.W}

Type
   DISKVOLUME          = STRING[12] ;
   TTxtFileMode        = (_Reset,_Rewrite,_Append,_Close);

   TFSStats            = Packed Record // "Record" to "Packed Record" Chg#189 (02.03.04 P.W)
    NumFound           : LongInt;
    SpaceNeeded        : Real;
   end;

{Function DosDir(Dir:DirStr):DirStr;}
 Function MakePath(PathName:String):Smallint;
Function DeletePath(PathName:String):Smallint;
FUNCTION FILEEXIST(NAME : STRING) : BOOLEAN ;
{FUNCTION FILELENGTH(NAME : STRING) : LONGINT ;}
FUNCTION PATHEXIST(NAME : STRING) : BOOLEAN ;
{FUNCTION GETVOLUME(DRIVE : CHAR) : DISKVOLUME ;}
FUNCTION DOCOPYN(FPATH,NPATH : PATHSTR;
                KeepDate: Boolean               {18.07.03 P.W}
                ) : Smallint ;
FUNCTION DOCOPY(FPATH,NPATH : PATHSTR
                ) : Smallint ;
Function Eraser(FileName:String):Boolean ;
{Function TXTFileHandler(Mode:TTxtFileMode;Var FileName:String;Var txt:Text):Smallint;}
Function GetDiskFree(name:String):LongInt;
{Function GetDiskSize(name:String):LongInt;}
{Procedure ResetIOResult;}
{Procedure GetFileSearchStatistics(Mask:String;Attr:Word;Var FSStats:TFSStats);}
{Function  MakeFlagFile(FName:String;DiskNum:Smallint):Smallint;}
Function CheckMake(DStr: DirStr): Boolean;      {??.??.90 P.W}
Function CheckMakeA(const DStr: DirStrA): Boolean;      
Function  MakePathExist(P:PathStr):Smallint;
function  MakePathExistA(const P:PathStrA):Smallint;
Procedure GetFileSize(Mask:String;Attr:Word;Var FSStats:TFSStats);
VAR
  IOFEHLER            : WORD ;

Implementation
  const Unit_Name = 'IOTools'; // 03.05.24 P.W
{-----------------------------------------------------------------------}
(*
Function DosDir(Dir:DirStr):DirStr;
{ sorgt für gültige Verzeichnisnamen //OemToAnsi Chg#191 (02.03.04 P.W)
{ C:\DICHTE\ --> C:\DICHTE
{ C:\        --> C:\
{ .\         --> .
}
Var
   Len  :       Smallint;
begin
  Len:=Length(Dir);
  if (Len>1) Then
     if (Dir[Len]='\') And (Dir[Len-1]<>':') Then
        Delete(Dir,Len,1);
  DosDir:=Dir;
end;
*)
{-----------------------------------------------------------------------}
{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}

Function MakePath(PathName:String):Smallint;
begin
    Repeat
    Until IOResult=0;
    MKDir(ExpandFileName(PathName)); // FExpand added (04.03.04 P.W)
    MakePath:=IOResult
end;
{$IFDEF IOCHECK} {$I+ } {$ENDIF }

{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}

Function DeletePath(PathName:String):Smallint;
begin
    Repeat
    Until IOResult=0;
    RmDir(ExpandFileName(PathName)); // FExpand added (04.03.04 P.W)
    DeletePath:=IOResult
end;
{$IFDEF IOCHECK} {$I+ } {$ENDIF }

{-----------------------------------------------------------------------}
{new code since 07.07.99 P.W}
FUNCTION FILEEXIST(NAME : STRING) : BOOLEAN ;
{ finds also files that have attribut "READ ONLY" }
{ similar code in DirTool NewExist }
{ finds files and sub-directories (without ending backslash)}
Var
  SR : SearchRec;
BEGIN { FUNCTION FILEEXIST }
  REPEAT
  UNTIL IORESULT = 0 ;
  FindFirstDE(Name, AnyFile, SR);
  FindClose(SR); // ChkFindClose (05.03.04 P.W)
  FileExist := (DosError=0);
END ; { FUNCTION FILEEXIST }


(***  {old code, does not find files with attribute "ReadOnly"
       used until 07.07.99 P.W}
{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}

FUNCTION FILEEXIST(NAME : STRING) : BOOLEAN ;

VAR
  FIL                 : FILE ;
  H                   : BOOLEAN ;


BEGIN
  { FUNCTION FILEEXIST }
  REPEAT
  UNTIL IORESULT = 0 ;
  ASSIGN(FIL,NAME) ;
  RESET (FIL) ;
  IOFEHLER := IORESULT ;
  H := IOFEHLER = 0 ;
  FILEEXIST := H ;
  CLOSE (FIL) ;
  REPEAT
  UNTIL IORESULT = 0 ;
END ; { FUNCTION FILEEXIST }
{$IFDEF IOCHECK} {$I+ } {$ENDIF }
***)
{-----------------------------------------------------------------------}
{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}

{FUNCTION FILELENGTH(NAME : STRING) : LONGINT ;}
(*
Modifications:
{22.06.01 P.W}:
  use "FileMode:=FileMode_ReadOnly" to allow copy of ReadOnlyFiles
*)
(*
VAR
  FIL                 : FILE ;
  H                   : BOOLEAN ;
  FileModeSav         : Word;     {22.06.01 P.W}

BEGIN
  FILELENGTH := 0 ;
  REPEAT
  UNTIL IORESULT = 0 ;
  ASSIGN(FIL,NAME) ;

  FileModeSav:=FileMode;        {22.06.01 P.W}
  FileMode:=FileMode_ReadOnly;  {22.06.01 P.W}
  RESET (FIL,1) ;
  FileMode:=FileModeSav;        {22.06.01 P.W}

  IOFEHLER := IORESULT ;
  IF IOFEHLER = 0 THEN
  FILELENGTH := FILESIZE(FIL) ;
  CLOSE(FIL) ;
  REPEAT
  UNTIL IORESULT = 0 ;
END ; { FUNCTION FILEEXIST }
*)
{$IFDEF IOCHECK} {$I+ } {$ENDIF }

{-----------------------------------------------------------------------}
{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}

FUNCTION PATHEXIST(NAME : STRING) : BOOLEAN ;

VAR
  ADIR                : STRING ;
  H                   : BOOLEAN ;

BEGIN
  REPEAT
  UNTIL IORESULT = 0 ;
  NAME := ExpandFileName(NAME); // FExpand added (04.03.04 P.W)
  If (Length(Name)>3) Then
     If (Name[Length(Name)]='\') Then
        Name:=copy(Name,1,Length(Name)-1);
  GETDIR(0,ADIR) ;
  CHDIR(NAME) ;
  H := IORESULT = 0 ;
  CHDIR(ADIR) ;
  PATHEXIST := H ;
  REPEAT
  UNTIL IORESULT = 0 ;
END ; { FUNCTION PATHEXIST }
{$IFDEF IOCHECK} {$I+ } {$ENDIF }

{-----------------------------------------------------------------------}
(*
{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}
FUNCTION GETVOLUME(DRIVE : CHAR) : DISKVOLUME ;

VAR
  DIRINFO             : SEARCHREC ; { DOS RECORDS }
  PATH                : STRING[6] ;

BEGIN
  REPEAT
  UNTIL IORESULT = 0 ;
  WITH DIRINFO DO
  BEGIN
    NAME := '*.*' ;
    ATTR := VOLUMEID ;
    PATH := DRIVE +':\*.*' ;
    FINDFIRST(PATH,VOLUMEID,DIRINFO) ;
    IF (FILL[1] = (ORD(DRIVE)-$40))  AND (DOSERROR = 0) THEN
    GETVOLUME := NAME
    ELSE
    GETVOLUME := '' ;
  END ;
  REPEAT
  UNTIL IORESULT = 0 ;
END ;
{$IFDEF IOCHECK} {$I+ } {$ENDIF }
*)

{-----------------------------------------------------------------------}
{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}

FUNCTION DOCOPYN(FPATH,NPATH : PATHSTR;
                KeepDate: Boolean               {18.07.03 P.W}
                ) : Smallint ;
{Duplicates! DoCopy in IoTools & Vertrag}
{Partial duplicate also in ANA\PAS\INSTALL.PAS}
(*
Modifications:
{10.05.01 P.W}
  Copy also the timestamp setftime
{22.06.01 P.W}:
  DoCopy use "FileMode:=FileMode_ReadOnly" to allow copy of ReadOnlyFiles
{18.07.03 P.W}
  Parameter KeepDate added; for compatibility use "True"
*)

VAR
  NFILE               : FILE ;
//  NFILE_T             : Text ;    {10.05.01 P.W}
  FFILE               : FILE ;
  IOTEST              : WORD ;
  FileModeSav         : Word;     {22.06.01 P.W}
  FTEXT               : ARRAY[1..4096] OF BYTE ;
  FCNT                : LongInt; // {22.10.03 P.W} WORD ;
  RCNT                : LongInt; // {22.10.03 P.W} word ;
  ftime               : Longint; { For Get/SetFTime}  {10.05.01 P.W}

BEGIN
  IoTest := 0;
  REPEAT
  UNTIL IORESULT = 0 ;
  RCNT := 0 ;
  FPath := ExpandFileName(FPath); // FExpand added (04.03.04 P.W)
  NPath := ExpandFileName(NPath); // FExpand added (04.03.04 P.W)
  IF FPATH <> NPATH THEN
  REPEAT
    IF FILEEXIST(FPATH) THEN
    BEGIN
      ASSIGN(NFILE,NPATH) ;
      REWRITE(NFILE,1) ;
      IOTEST := IORESULT ;
      IF IOTEST = 0 THEN
      BEGIN
        ASSIGN(FFILE,FPATH) ;

        FileModeSav:=FileMode;        {22.06.01 P.W}
        FileMode:=FileMode_ReadOnly;  {22.06.01 P.W}
        RESET(FFILE,1) ;
        FileMode:=FileModeSav;        {22.06.01 P.W}

        //GetFTime(FFILE,ftime); { Get last change time } {10.05.01 P.W}
        fTime := FileAge(FPATH);          // 15.10.04 P.W.

        IOTEST := IORESULT ;
        WHILE (NOT EOF(FFILE)) AND (IOTEST = 0)  DO
        BEGIN
          BLOCKREAD(FFILE,FTEXT,SIZEOF(FTEXT),FCNT) ;
          IOTEST := IORESULT ;
          IF IOTEST = 0 THEN
          BEGIN
            BLOCKWRITE(NFILE,FTEXT,FCNT) ;
            IOTEST := IORESULT ;
          END ;
        END ;
        CLOSE(NFILE) ;
        {v--- Set the timestamp ---} {10.05.01 P.W}
        If KeepDate then  {if: 18.07.03 P.W}
        begin
          { u. 15.10.04 P.W.
          // Use NFILE_T : Text; Reset only for read
          Assign  (NFILE_T,NPATH);
          Reset   (NFILE_T); // Reopen file for reading
                             // (Otherwise, close will update time)
          SetFTime(NFILE_T,ftime);
          Close   (NFILE_T);
          }
          FileSetAge(NPath, fTime); // s. 15.10.04 P.W.
        end;
        {^--- Set the timestamp ---}
        REPEAT
        UNTIL IORESULT = 0 ;
      END ;
      CLOSE(FFILE) ;
      REPEAT
      UNTIL IORESULT = 0 ;
    END
    ELSE IOTEST := 2 ;
    INC(RCNT) ;
  UNTIL (IOTEST = 0) OR (RCNT > 2) ;
  DOCOPYN := IOTEST ;
END ;

FUNCTION DOCOPY(FPATH,NPATH : PATHSTR
                ) : Smallint ;
{Duplicates! DoCopy in IoTools & Vertrag}
{Partial duplicate also in ANA\PAS\INSTALL.PAS}
begin
  DOCOPY:=DOCOPYN(FPATH, NPATH, True); {True: 18.07.03 P.W}
end;

{$IFDEF IOCHECK} {$I+ } {$ENDIF }

{-----------------------------------------------------------------------}
{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}

Function Eraser(FileName:String):Boolean;
Var
  OK    :       Boolean;
  Tmp   :       File;
begin
  Repeat Until IORESULT=0;
  FileName := ExpandFileName(FileName); // FExpand added (04.03.04 P.W)
  OK:=FileExist(FileName);
  If OK Then
  begin
    Assign(Tmp,FileName);
    Erase(Tmp);
  end;
  If IOResult<>0 Then OK:=False;  {16.02.94 Michael Welsch}
  Eraser:=OK;
  Repeat Until IORESULT=0;
end;
{$IFDEF IOCHECK} {$I+ } {$ENDIF }
{-----------------------------------------------------------------------}
(*.*************************************************************************
TXTFileHandler: handling of textfiles
ErrorCode:
  =0 : OK
  >0 : =DOS IoResult
  -1 : Reset a file that doesn't exist
  -2 : Rewrite a file that already exists
Variables:
Input   :Mode:TTxtFileMode;FileName:String;
OutPut  :Var txt:Text; returns errorcode:Smallint;

global Variables:
  affected: --
predefined: --

Version : @(#) KN_Tools.Pas V:1.0
Author  : M.Welsch
Date    : 29.01.93
Modified:
Modification log:
{03.06.93 Michael Welsch}
****************************************************************************)
{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}

(*
Function TXTFileHandler(Mode:TTxtFileMode;Var FileName:String;Var txt:Text):Smallint;
Var
  Index :       Smallint;
  Flg   :       Boolean;
  IOFlg :       Boolean;
begin
  Index:=0;
  IOFlg:=False;
  Flg:=FileExist(FileName);
  Case Mode Of
   _Reset:
    begin
       If Flg Then
       begin
         Assign(txt,FileName);
         Reset(txt);
         IOFlg:=True;
       end else Index:=-1;
    end;
   _ReWrite:
    begin
       If Flg Then Index:=-2;
       Assign(txt,FileName);
       Rewrite(txt);
       IOFlg:=True;
    end;
   _Append:
    begin
       Assign(txt,FileName);
       If Flg Then Append(txt)
       else Rewrite(txt);
       IOFlg:=True;
    end;
   _Close:
    begin
       Close(txt);
       IOFlg:=True;
    end;
  end;
  If IOFlg Then Index:=IOResult;
  TXTFileHandler:=Index;
end;
*)
{$IFDEF IOCHECK} {$I+ } {$ENDIF }

{-----------------------------------------------------------------------}

Function GetDiskFree(name:String):LongInt;
Var
  Disk  :     Char;
  ID    :     Byte;
  Temp  :     PathStr;
begin
  Temp:=name;
  Temp:=ExpandFileName(Temp);
  Disk:=Temp[1];
  ID:=Ord(Disk)-Ord('A')+1;
  GetDiskFree:=DiskFree(ID);
end;

{-----------------------------------------------------------------------}
(*
Function GetDiskSize(name:String):LongInt;
Var
  Disk  :     Char;
  ID    :     Byte;
  Temp  :     PathStr;
begin
  Temp:=name;
  Temp:=FExpand(Temp);
  Disk:=Temp[1];
  ID:=Ord(Disk)-Ord('A')+1;
  GetDiskSize:=DiskSize(ID);
end;
*)
{-----------------------------------------------------------------------}
(*
Procedure ResetIOResult;
begin
    Repeat
    Until IOResult=0;
end;
*)
{-----------------------------------------------------------------------}
(*
Procedure GetFileSearchStatistics(Mask:String;Attr:Word;Var FSStats:TFSStats);
Var
   F       :       SearchRec;
begin
  FillChar(FSStats, SizeOf(FSStats), #0);
  FindFirst(Mask,Attr,F);
  while DosError = 0 do
  begin
    With FSStats Do
    begin
      Inc(NumFound);
      SpaceNeeded:=SpaceNeeded+F.Size;
    end;
    FindNext(F);
  end;
end;
*)
{-----------------------------------------------------------------------}
{$IFOPT I+ } {$DEFINE IOCHECK } {$ENDIF }
{$I-}
(*
Function  MakeFlagFile(FName:String;DiskNum:Smallint):Smallint;
Var
   txt  :       Text;
   Res  :       Smallint;
begin
  Res:=IOResult;
  Assign(txt,FName);
  Rewrite(txt);
  Res:=IOResult;
  If Res=0 Then
  begin
    Writeln(txt,DiskNum:5);
    Close(txt);
    Res:=IOResult;
  end;
  MakeFlagFile:=Res;
end;
*)
{$IFDEF IOCHECK} {$I+ } {$ENDIF }

{-----------------------------------------------------------------------}
Function  SingleCheckMake(DStr: DirStr): Boolean;  {??.??.90 P.W}
(*
Info:
  Duplicate Code in
    a) IoTools.pas SingleCheckMake
    b) DirTool.pas oldCheckMake
Modifications:
{17.09.03 P.W}
  testing of attr directory corrected
*)
Var
  Ok               : Boolean;
  SR               : SearchRec;
begin
  Deb0('SingleCheckMake 0 "'+DStr+'"');
  if DStr[Length(DStr)]='\' then Dec(DStr[0]);
  Ok:=False;
  FindFirstDE(DStr, Directory, SR);
  FindClose(SR); // ChkFindClose (05.03.04 P.W)
  if DosError<>0
  then
    begin     {Versuch Directory anzulegen}
      {$I-}
  Deb0('SingleCheckMake 1 Pre MkDir "'+ExpandFileName(DStr)+'"');
        MkDir(ExpandFileName(DStr)); // FExpand added (04.03.04 P.W)
      {$I+}
      if IoResult=0 then
      begin
  Deb0('SingleCheckMake 2');
        Ok:=True;   {Versuch geglückt} //OemToAnsi Chg#190 (02.03.04 P.W)
      end;
    end
  else
    begin                       { Fehlerhaft: DosError=0 auch bei Dateien!!!}
      { Fehler auffangen !!!! }
      {if SR.Attr=Directory    }         {u.: 17.09.03 P.W}
      if ((SR.Attr and Directory) <> 0)  {s.: 17.09.03 P.W}
        then begin
  Deb0('SingleCheckMake 3');
          Ok:=True;  {Directory existiert bereits}
        end;
    end;
  if (Length(DStr)=2) and (pos(':',DStr)=2) then
  begin
  Deb0('SingleCheckMake 4');
     Ok:=True;
  end;
  SingleCheckMake:=Ok;
  if OK then
    Deb0('SingleCheckMake 5- OK')
  else
    Deb0('SingleCheckMake 5- NOT ok');
end;

Procedure FSplitSubdir(Var a, b: DirStr);          {??.??.90 P.W}
{ Aufruf mit '','A:\Sub1\Sub2\...'  liefert: 'A:\','Sub1\Sub2\...' }
{ Aufruf mit 'A:\','Sub1\Sub2\...'  liefert: 'A:\Sub1\','Sub2\...' }
Var
  c                : DirStr;
  p                : word;
begin
  Deb0('FSplitSubdir 0');
  p:=Pos('\',b);
  if (P=0) and (Length(b)>0) then
  begin
    b:=b+'\';
    p:=Length(b);
  end;
  c:=Copy(b,1,p);
  a:=a+c;
  delete(b,1,p);
  Deb0('FSplitSubdir 1-');
end;

Function  CheckStepMake(DStr: DirStr): Boolean;    {??.??.90 P.W}
Var
  Ok               : Boolean;
  a, b             : DirStr;
begin
  Deb0('CheckStepMake 0');
  a:='';
  b:=ExpandFileName(DStr);
  Ok:=True;
  Deb0('CheckStepMake 1 "'+B+'"');
  while Ok and (Length(B)>0) do
  begin
    FSplitSubDir(A,B);
    Ok:=SingleCheckMake(A);
  end;
  CheckStepMake:=Ok;
  Deb0('CheckStepMake 2-');
end;

Function  CheckMake(DStr: DirStr): Boolean;      {??.??.90 P.W}
Var
  Ok               : Boolean;
begin
  Deb0('CheckMake 0 "'+DStr+'"');

  Ok:=SingleCheckMake(DStr);
  Deb0('CheckMake 1');
  if not Ok then Ok:=CheckStepMake(DStr);
  CheckMake:=Ok;
  Deb0('CheckMake 2-');
end;
Function  CheckMakeA(const DStr: DirStrA): Boolean;
// Created: 07.04.05 P.W
// Purpose: Replace CheckMake support Long FileNames
begin
  Result := ForceDirectories(DStr);
end;


{-----------------------------------------------------------------------}
Function  MakePathExist(P:PathStr):Smallint;
Var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FSplit(P, D, N, E);
  If CheckMake(D) Then
     MakePathExist:=0
  else
     MakePathExist:=-1
end;
function  MakePathExistA(const P:PathStrA):Smallint;
// Created: 07.04.05 P.W
// Purpose: Replace MakePathExist support Long FileNames
Var
  D: DirStrA;
  N: NameStrA;
  E: ExtStrA;
begin
  FSplitA(P, D, N, E);
  If CheckMakeA(D)
  then Result :=  0
  else Result := -1;
end;
{-----------------------------------------------------------------------}
Procedure GetFileSize(Mask:String;Attr:Word;Var FSStats:TFSStats);
Var
   F       :       SearchRec;
begin
  FillChar(FSStats, SizeOf(FSStats), #0);
  FindFirstDE(Mask,Attr,F);
  while DosError = 0 do
  begin
    With FSStats Do
    begin
      Inc(NumFound);
      SpaceNeeded:=SpaceNeeded+F.Size;
    end;
    FindNextDE(F);
  end;
  FindClose(F); // ChkFindClose (05.03.04 P.W)
end;


procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  IOFEHLER            := 0;

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
