// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
Unit UtFilt0;

(*
Created:       {18.07.03 P.W}
Purpose:       Support deleting of filtered images created by unit
               UtFilter.pas
               Deleting has to be used by Database import:
                 Remove Filtered Images for imported Ct-Numbers
Modifications:
*)

Interface

Uses
  Dos,
  GlbPath,
  GlbTools,
  IoTools;

Function  GetFltCtNumberStr  (CtNumber       : LongInt): String;
Function  GetFltCtNumberDir  (CtNumber       : LongInt): String;
Function  CtNumberFromPath   (CtPath         : String ): LongInt;

Procedure EraseFltSubDir     (Path           : String );
Procedure EraseFltCtNumberDir(CtNumber       : LongInt);
Procedure EraseFltDirsExclude(CtNumberExclude: LongInt);

Const
  FltImgNam        = 'FLT.IMG';                  {18.07.03 P.W}


Implementation
  const Unit_Name = 'UtFilt0'; // 03.05.24 P.W

Procedure EraseFltSubDir(Path: String);
(*
Created:     {18.07.03 P.W}
Description: Deletes all files and Subfolders of Path including Path
  as long as no Hidden, ReadOnly flag disables this.
Purpose: Used to clean up the Flt.Img files and folders:
          a) in case of low disk space
          b) in case of out of modified User filters
          c) in case of imported images

*)
Var
  SR               : SearchRec;
begin {Procedure EraseSubDir}
  FindFirstDE(Path+'*.*', AnyFile, SR);
  While (DosError=0) do
  begin
    If     (SR.Name <> '.')
       and (SR.Name <> '..')
    then
    begin
      If ((SR.Attr and Directory) <> 0)
      then
        EraseFltSubDir(Path+SR.Name+'\')      {Delete subfolder}
      else
      If ((SR.Attr and VolumeId) = 0)
         and
         (UpcaseString(SR.Name) = FltImgNam)  {for security agains unwanted deltes}
      then
        Eraser(Path+SR.Name);
    end;
    FindNextDE(SR);
  end;
  ChkFindClose(SR);

  Dec(Path[0]);       {Removes terminating Backslash}
  DeletePath(Path);
end;  {Procedure EraseSubDir}

Function  GetFltCtNumberStr(CtNumber: LongInt): String;
(*
Created      : {18.07.03 P.W}
Aim          : Support improved storage of filtered images
Description  :
Modifications:
*)
begin {Function  GetFltCtNumberStr}
  GetFltCtNumberStr := GetIntStr(CtNumber, 1);
end;  {Function  GetFltCtNumberStr}

Function  GetFltCtNumberDir(CtNumber: LongInt): String;
(*
Created      : {18.07.03 P.W}
Aim          : Support improved storage of filtered images
Description  :
Modifications:
*)
begin {Function  GetFltCtNumberDir}
  GetFltCtNumberDir := LocTempFltImgDir +
                         GetFltCtNumberStr(CtNumber) + '\';
end;  {Function  GetFltCtNumberDir}

Function  CtNumberFromPath   (CtPath         : String ): LongInt;
Var
  S                : String;
  Err              : Integer; // Smallint to Integer 23.04.04 P.W
  L                : LongInt;
begin
  S:= Copy(CtPath, Length(CtPath)-10,7);
  Val(S, L, Err);
  CtNumberFromPath := L;
{GlbDecs.GlbDebugMsg('UtFilt0.pas CtNumberFromPath: "'+CtPath+'" = '+GetIntstr(L,1)+' ('+S+')');}
end;

Procedure EraseFltCtNumberDir(CtNumber: LongInt);
(*
Created      : {18.07.03 P.W}
Aim          : Support improved storage of filtered images
Description  :
Modifications:
*)
begin {Procedure EraseFltCtNumberDir}
  EraseFltSubDir(GetFltCtNumberDir(CtNumber));
end;  {Procedure EraseFltCtNumberDir}

Procedure EraseFltDirsExclude(CtNumberExclude: LongInt);
(*
Created      : {18.07.03 P.W}
Aim          : Support improved storage of filtered images
Description  :
Modifications:
*)
Var
  SR               : SearchRec;
begin {Procedure EraseFltDirsExclude}
  FindFirstDE(LocTempFltImgDir+'*.', AnyFile, SR);
  While (DosError=0) do
  begin
    If (SR.Name <> GetFltCtNumberStr(CtNumberExclude))
       and (SR.Name <> '.')
       and (SR.Name <> '..')
    then
    begin
      EraseFltSubDir(LocTempFltImgDir+SR.Name+'\');
    end;
    FindNextDE(SR);
  end;
  ChkFindClose(SR);
end;  {Procedure EraseFltDirsExclude}




end.

