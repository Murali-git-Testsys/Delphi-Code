unit UBnlockWin;
// Modifications:
// 17.12.08 P.W: Support EventsLog by function  AskPassWord

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  Param_StrUnit,
  MsgBox,           // 07.01.09 P.W
  EventLogs,        // 17.12.08 P.W
  ComNames,
//  Dialogs,        // u: 07.01.09 P.W
  forms,
  frmBnLockPassWd,
  Controls,
  StdCtrls,
  Windows,
  Classes,
  StrUtils,
  SysUtils,
  UFileCrc32;

type
  TAutoMode = (T_Manu, T_Auto, T_Serv, T_Test);  // T_Test 15.01.08 P.W

function ChkFolderList(StartPath, CrcList: AnsiString; AM: TAutoMode; WarnFlg:Boolean=True): Boolean;
function ChkExeList   (StartPath, CrcList: AnsiString; AM: TAutoMode; WarnFlg:Boolean=True): Boolean;
function ChkBnLockList(AM: TAutoMode; WarnFlg:Boolean=True): Boolean;
function StringInList(const S: AnsiString; const Masks:Array of AnsiString): Boolean;

Implementation
  const Unit_Name = 'UBnlockWin'; // 03.05.24 P.W

const
  PwdParams      = 'PARAMSOK';
  PwdExeDir      = 'CRCOK';
  TestPath       = 'TEST';

  MaskAllFiles   = '*.*';
  ParentFolder   = '..';
  SelfFolder     = '.';
  Exe_Exts            : Array [0..1] of AnsiString = ('.EXE', '.COM');
  SelfAndParentFolder : Array [0..1] of AnsiString = (SelfFolder, ParentFolder);

type
  TKeyStringList = Class(TStringList)
  // uses Objects[] property to store checksum
    Constructor Create;
    function LoadKeyList(aName: AnsiString): Boolean;
    procedure SaveKeyList(aName: AnsiString);
  end;

function CreateBnLockFileList(LNew: TKeyStringList; aName: AnsiString): Boolean;
begin
  try
    LNew.Clear;
    LNew.Append('SelSet.Bat');
    LNew.Append('Init\Options.ini');
    LNew.Append('Init\Typ\*.typ');
    LNew.Append('Init\Typ\*.MCH');
    LNew.Append('DEV\%XCTDEV%DEVICE.SNR');
    LNew.Append('DEV\%XCTDEV%DETSV.REC');
    LNew.Append('DEV\%XCTDEV%FWDT.CMD');
    LNew.Append('DEV\%XCTDEV%PHANTOMS.INI');
    LNew.Append('MASKS\ENG\*.*');
    LNew.Append('MASKS\GER\*.*');
    LNew.Append('MASKS\FRE\*.*');
    LNew.Append('MASKS\ITA\*.*');
    LNew.Append('MASKS\SPA\*.*');
    LNew.Append('UTIL\SERVICE\*.LST');
    LNew.Append('UTIL\MANAGER\*.LST');
    LNew.Append('UTIL\USER\*.LST');
    LNew.SaveToFile(aName);
    Result := False;
  except
    on E : Exception do
      begin
        Result := False;
        ShowMessageFmt_(E.Message+sLineBreak + Param_Str(0));
      end;
  end;
end;

Constructor TKeyStringList.Create;
begin
  Inherited Create;
  // Note: Duplicates does nothing if the list is not sorted!
  Duplicates    := dupIgnore;
  Sorted        := True;
  CaseSensitive := False;
end;

function ListGetChkSum(L : TStringList): DWord;
var
  S : AnsiString;
begin
  S:= L.Text;
  Result := BufCalcCRC32(Pointer(S), Length(S));
end;

function TKeyStringList.LoadKeyList(aName: AnsiString): Boolean;
  function StrToChkSum(S: AnsiString): DWord; overload;
  begin
    Result := StrToIntDef(S, 0);
  end;
var
  L : TStringList;
  I0, I : Integer;
  ChkSum : DWord;
begin
  Result := False;
  Clear;
  if FileExists(aName) then
  begin
    L := TStringList.Create;
    L.LoadFromFile(aName);
    if (L.Count >= 2) then
    begin
      ChkSum := StrToChkSum(L[L.Count-1]);
      L.Delete(L.Count-1);
      Result := ChkSum = ListGetChkSum(L);
      L.Delete(L.Count-1);
    end;
    for I0 := 0 to (L.Count div 2) -1 do
    begin
      I := I0 * 2;
      AddObject(L[I], Pointer(StrToChkSum(L[I+1])));
    end;
    FreeAndNil(L);
  end;
end;

procedure TKeyStringList.SaveKeyList(aName: AnsiString);
// odd line: Filename; even line: CheckSum
// last two lines: aName and Checksum of List
//   (CheckSum of list without the last two lines)
  function FmtChkSum(ChkSum: DWord): AnsiString;   overload;
  begin
    Result := '$'+IntToHex(ChkSum,8);
  end;
  function FmtChkSum(ChkSum: TObject): AnsiString; overload;
  begin
    Result := FmtChkSum(DWord(ChkSum));
  end;
var
  L : TStringList;
  I : Integer;
  ChkSum : DWord;
begin
  L := TStringList.Create;
  for I := 0 to Count -1 do
  begin
    L.Append(Self[I]);
    L.Append(FmtChkSum(Objects[I]));
  end;
  L.Append(aName);
  ChkSum := ListGetChkSum(L);
  L.Append(FmtChkSum(ChkSum));
  L.SaveToFile(aName);
  FreeAndNil(L);
end;

function  ChkExpandEnv(const S0: AnsiString): AnsiString;
// Check for placeholders of environment variables like %XctDev%
// replaces iterative
const
  Delim = '%';
var
  P0, P1: Integer;
  Ready : Boolean;
  EVN, EVC : AnsiString;
begin
  Result := S0;
  Repeat
    Ready := True;
    P0 := Pos(Delim, Result);
    if (P0 > 0) then
    begin
      P1 := PosEx(Delim, Result, P0+1);
      if (P1 > P0) then
      begin
        EVN := Copy(Result, P0+Length(Delim), P1-P0-Length(Delim));
        EVC := GetEnvironmentVariable(EVN);
        Result := AnsiReplaceStr(Result, Delim+EVN+Delim, EVC);
        Ready := Pos(Delim, EVC)>0; // avoid DeadLock if EVC contains Delim
      end;
    end;
  Until Ready;
end;

procedure KeyListAddFiles(L: TKeyStringList; S: AnsiString);
var
  SR : TSearchRec;
  SP, SM : AnsiString;
begin
  SP := ExtractFilePath(S);
  if (SP <> '') then
    SP := IncludeTrailingPathDelimiter(SP);
  SM := ExtractFileName(S);
  if (FindFirst(S,faAnyFile and (not faDirectory), SR) = 0) then
  begin
    repeat
      L.Add(UpperCase(SP+SR.Name));
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

function ExpandVariables(const L: TKeyStringList): TKeyStringList;
// Check for placeholders of environment variables like %XctDev%
var
  I: Integer;
begin
  Result := TKeyStringList.Create;
  Result.Sorted := True;
  for I := 0 to L.Count -1 do
    KeyListAddFiles(Result, ChkExpandEnv(L[I]));
end;

var
  ProgressForm : TForm = nil;
  ProgressFormTmr : TDateTime;
procedure ProgressFormCreate;
begin
  if not Assigned(ProgressForm) then
  begin
    ProgressForm := TForm.Create(Nil);
    ProgressForm.Parent := nil;
    ProgressForm.Width := Screen.WorkAreaWidth;
    ProgressForm.ClientHeight := 0;
//    ProgressForm.Position := poScreenCenter;
    ProgressForm.Left:= Screen.WorkAreaLeft;
    ProgressForm.Top := Screen.WorkAreaTop+Screen.WorkAreaHeight-ProgressForm.Height;
    ProgressFormTmr := Now;
    ProgressForm.WindowState := wsNormal;
  end;
//  ProgressForm.Show;
end;

procedure ProgressFormUpdate(S: AnsiString);
begin
  if Assigned(ProgressForm) then
  begin
    ProgressForm.Caption := ExtractFileName(Param_Str(0))+' Progress: '+ S + ' ...';
    Application.ProcessMessages;
    if Abs(ProgressFormTmr-Now) > 1.0 /(24*3600) then
    begin
      ProgressForm.Show;
      if not ProgressForm.Visible then
      begin // close of progressbar used to abort
//        ShowMessage(Param_Str(0) + ' Aborted!');
        raise Exception.Create('Aborted');
      end;
      Sleep(10);
      ProgressFormTmr := Now;
    end;
  end;
end;

procedure ProgressFormDestroy;
begin
  FreeAndNil(ProgressForm);
end;

function ExpandStartPath(const S: AnsiString): AnsiString;
begin
  Result := S;
  if Result = '' then Result := SelfFolder;
  Result := IncludeTrailingPathDelimiter(UpperCase(ExpandFileName(Result)));
end;

procedure KeyListAddChkSums(StartPath: AnsiString; L: TKeyStringList);
var
  I: Integer;
  S : AnsiString;
begin
  StartPath := ExpandStartPath(StartPath);
  for I := 0 to L.Count -1 do
  begin
    S := StartPath + L[I];
    ProgressFormUpdate('CheckSum of '+S);
    if FileExists(S) then
      L.Objects[I] := Pointer(GetFileChkSum(S));
  end;
end;

function  AskPassWord(L: TKeyStringList; aTitle, aPassWrd, StartPath: AnsiString; AM: TAutoMode): Boolean;
// Modifications:
// 17.12.08 P.W: Support EventsLog
const
  CtrMax = 3;
var
  aForm : TfrmPassWord;
  Ready, PwdOk : Boolean;
  Ctr : Integer;
  ELK : TEventsLogKey;  // 17.12.08 P.W
begin
  if (Pos('CRC', UpperCase(aTitle)) > 0) then                    // 17.12.08 P.W
    ELK := ELK_ExeCrcChange
  else
    ELK := ELK_ParameterChange;
  EventsLog.Append('Mode:%d; Title:%s; Msg:%s', [Ord(AM), aTitle, L.Text], ELK, True);  // 17.12.08 P.W

  if (AM = T_Auto) then
  begin
    Result := True;
    Exit;
  end;

  aPassWrd := UpperCase(aPassWrd);
  aForm := TfrmPassWord.Create(nil);
  aForm.Parent := nil;
  aForm.Memo1.Lines := L;
  aForm.lblChanges.Caption := 'Changes in "'+StartPath+'":';
  if (aTitle <> '') then aForm.Caption := aTitle;
  if (AM = T_Manu) then
  begin // automatic if in test path
    if (Pos(PathDelim+TestPath+PathDelim,
            IncludeTrailingPathDelimiter(
              UpperCase(
                ExpandFileName(
                  GetCurrentDir)))) > 0) then
      AM := T_Serv;
  end;

  if (AM = T_Serv) then
  begin  // automatic password
    aForm.edtPassword.Text := aPassWrd;
    aForm.edtPassword.ReadOnly := True;
    aForm.btnWait.Visible := True;
    aForm.btnWait.Enabled := True;
    aForm.lblPassword.Caption := 'Press Ok to accept changes';
    aForm.btnCancel.Enabled := False;
    aForm.Timer1.Enabled := True;
  end;

  Ctr := 0;
  repeat
    if (AM = T_Test) then
    begin             // 15.01.08 P.W
      aForm.lblPassword.Visible := False;
      aForm.edtPassword.Visible := False;
      aForm.btnOk.Visible := False;
    end else
    begin
      aForm.Timer2.Enabled := True;
      Inc(Ctr);
      aForm.Show;
      if aForm.edtPassword.Enabled then
        aForm.edtPassword.SetFocus;
      aForm.Hide;
    end;

    //------------------------
    aForm.ShowModal;
    //------------------------

    if (AM = T_Test) then
    begin             // 15.01.08 P.W
      Ready := True;
      PwdOk := False;
    end else
    begin
      PwdOk := (aForm.ModalResult = mrOk) and (Uppercase(aForm.edtPassword.Text) = aPassWrd);
      Ready := (aForm.ModalResult = mrCancel) or PwdOk or (Ctr >= CtrMax);
      aForm.Timer2.Enabled := False;  // otherwise next message might be forced into background by Timer2!
      if (not PwdOk) and (aForm.ModalResult <> mrCancel) then
      begin
        ShowMessageFmt_('Password is invalid! (%d/%d)', [Ctr,CtrMax]);
        aForm.edtPassword.Text := '';   // 17.12.08 P.W
      end;
    end;
  until Ready;

  Result := PwdOk;

  if Result then
  begin
//      ShowMessage('Ok!');
  end else
  begin
//    ShowMessage('Not Ok!');
  end;

  FreeAndNil(aForm);
end;

function StringInList(const S: AnsiString; const Masks:Array of AnsiString): Boolean;
var
  I : Integer;
begin
  Result := True;
  for I:= Low(Masks) to High(Masks) do
    if (S=Masks[I]) then exit;
  Result := False;
end;

function KeyListsAreEqual(LNew, LOld, LDiff: TKeyStringList; var Ok2: Boolean; WarnFlg: Boolean): Boolean;
// Modifications:
// 07.01.09 P.W new parameter Warnflg (use True for compatibility)
var
  Ok : Boolean;
  INew, IOld  : Integer;
  S, Msg, MsgWarn : AnsiString;
begin
  Result := True;
  Ok2 := True; // stays true when files are added but all listed files are ok
  if not LNew.Sorted then LNew.Sort;
  if not LOld.Sorted then LOld.Sort;

  MsgWarn := '';

  // Test that all elements of LNew are in LOld and that Checksums are equal:
  For INew := 0 to LNew.Count -1 do
  begin
    Msg := '';
    S := LNew[INew];
    // file is missing in LNew if Ok1 is false:
    Ok := LOld.Find(S, IOld); // Note: use find only with sorted lists!
    if not Ok then Msg := ' <added>';
    // if Objects differ then the checksum differs:

    if Ok then
    begin
      Ok := (LNew.Objects[INew] = LOld.Objects[IOld]);
      if not Ok then
      begin
        Ok2 := False;
        Msg := ' <changed>';
        if StringInList(ExtractFileExt(S), Exe_Exts) then
        begin
          if MsgWarn = '' then
            MsgWarn := 'Warning: CheckSum of program file(s) changed!';
          MsgWarn := MsgWarn + sLineBreak + S;
        end;
      end;
    end;

    // add to LDiff if not Ok1:
    if not Ok then
    LDiff.Add(S+Msg);

    // Ok if true only when all elements are same:
    Result := Result and Ok;
  end;

  // Test that all elements of LOld are in LNew:
  For IOld := 0 to LOld.Count -1 do
  begin
    S := LOld[IOld];
    // file is missing in LNew if Ok is false:
    Ok := LNew.Find(S, INew); // Note: use find only with sorted lists!

    // add to LDiff if not found:
    if not Ok then
    begin
      LDiff.Add(LOld[IOld]+ ' <removed>');
      Ok2 := False;
    end;

    // Result if true only when all elements are found:
    Result := Result and Ok;
  end;

  if (MsgWarn <> '') then
    if WarnFlg then
      ShowMessageFmt_(MsgWarn)
    else
      ShowMessageFmt_(MsgWarn, 5000);   // 07.01.09 P.W
end;

procedure FillFolderList(const L: TKeyStringList; const StartPath, SubPath, Excluded: AnsiString; ExeFlg:Boolean);
// modifications:
// 29.11.05 P.W: do not check AV??? and QA??? for exe files
var
  SR : TSearchRec;
  aName : String;
  Ext : AnsiString;
begin
  If FindFirst(StartPath+SubPath+MaskAllFiles, faAnyFile, SR) = 0 then
  begin
    ProgressFormUpdate(StartPath+SubPath);
    repeat
      If ((SR.Attr and faDirectory) <> 0) then
      begin
        aName := UpperCase(SR.Name);
        If
          //do not iterate to self or parent folder:
          (not StringInList(SR.Name, SelfAndParentFolder))
          and
          //do not check EXE of TestPath from customer:
          (not
            ( ExeFlg and
              (
                (aName = TestPath)
                or
                ((Length(aName)=5) and (Pos('AV', aName)=1))   // 29.11.05 P.W
                or
                ((Length(aName)=5) and (Pos('QA', aName)=1))   // 29.11.05 P.W
              )
            )
          )
        then
          FillFolderList(L, StartPath, SubPath+UpperCase(SR.Name)+PathDelim, ExCluded, ExeFlg);
      end else
      begin
        if (StartPath+SubPath+SR.Name <> Excluded) then
        begin
          if ExeFlg then
          begin
            Ext := UpperCase(ExtractFileExt(SR.Name));
            if StringInList(Ext, Exe_Exts) then
            begin
              L.Add(UpperCase({StartPath+}SubPath+SR.Name));
            end;
          end else
          begin
              L.Add(UpperCase({StartPath+}SubPath+SR.Name));
          end;
        end;
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

function ChkFolderOrExeList(StartPath, CrcList: AnsiString; ExeFlg: Boolean; AM: TAutoMode; WarnFlg:Boolean): Boolean;
label
  L_Cont;
var
  Ok, Ok2           : Boolean;
  Exclude           : AnsiString;
  LNew, LOld, LDiff : TKeyStringList;
begin
  try
    Ok := True;

    StartPath := ExpandStartPath(StartPath);

    if CrcList = '' then
    begin
      if ExeFlg
        then CrcList := StartPath + CrcExeListName
        else CrcList := StartPath + CrcDirListName;
    end else
    begin
      CrcList := UpperCase(ExpandFileName(CrcList));
    end;

    if (Pos(StartPath, CrcList) = 1) then
    begin
      Exclude := CrcList;
    end else
    begin
      Exclude := '';
    end;

    LNew := TKeyStringList.Create;
    LOld := TKeyStringList.Create;
    LDiff:= TKeyStringList.Create;

    ProgressFormCreate;
      FillFolderList(LNew, StartPath, '', Exclude, ExeFlg);
      KeyListAddChkSums(StartPath, LNew);
    ProgressFormDestroy;

    if not LOld.LoadKeyList(CrcList) then
    begin
      Ok := False;
      if FileExists(CrcList)
        then LDiff.Append(CrcList + ' <invalid>')
        else LDiff.Append(CrcList + ' <will be created>');
    end;

    Ok2 := False;
    if (not KeyListsAreEqual(LNew, LOld, LDiff, Ok2, WarnFlg)) or (not Ok) then
    begin
      If (Ok and Ok2) and (AM = T_Test) then
      begin  // accept added files
        Result := True;
        Goto L_Cont;
      end;
      If (Ok and Ok2) and ExeFlg and (AM = T_Manu) then
      begin  // accept added *.exe
        AM := T_AUTO
      end;
      if AskPassWord(LDiff,'XCT Checksum of files (CRC)', PwdExeDir, StartPath, AM) then
      begin
        LNew.SaveKeyList(CrcList);
        Result := True;
      end else
      begin
        Result := False;
      end;
    end else
    begin
      Result := True;
    end;

 L_Cont:

    FreeAndNil(LDiff);
    FreeAndNil(LOld);
    FreeAndNil(LNew);
  except
    on E : Exception do
      begin
        Result := False;
        ShowMessageFmt_(E.Message+sLineBreak + Param_Str(0) + sLineBreak+'UBnLockWin ChkFolderOrExeList');
      end;
  end;
end;

function ChkFolderList(StartPath, CrcList: AnsiString; AM: TAutoMode; WarnFlg:Boolean=True): Boolean;
begin
  Result := ChkFolderOrExeList(StartPath, CrcList, False, AM, WarnFlg);
end;

function ChkExeList(StartPath, CrcList: AnsiString; AM: TAutoMode; WarnFlg:Boolean=True): Boolean;
begin
  Result := ChkFolderOrExeList(StartPath, CrcList, True, AM, WarnFlg);
end;

function ChkBnLockList(AM: TAutoMode; WarnFlg:Boolean=True): Boolean;
var
  Ok, Ok2            : Boolean;
  LNew, LOld, LDiff : TKeyStringList;
begin

{
//Debug:
if GetEnvironmentVariable('XCTDEV')='' then
  SetEnvironmentVariable('XCTDEV', 'XCT2003.A\');
if GetEnvironmentVariable('XCTDIR')='' then
  SetEnvironmentVariable('XCTDIR', 'C:\XCT\');
{}
  try
    if (GetEnvironmentVariable('XCTDEV') = '') or
       (GetEnvironmentVariable('XCTDIR') = '') then
       begin
         ShowMessageFmt_('Error: Environment variables "XCTDIR" or "XCTDEV" are not defined!'+SLineBreak+Param_Str(0));
         Result := False;
         Exit;
       end;
    Ok := True;
    LNew := TKeyStringList.Create;
    LOld := TKeyStringList.Create;
    LDiff:= TKeyStringList.Create;
    if FileExists(BnLockFileList) then
    begin
      LNew.LoadFromFile(BnLockFileList);
    end else
    begin
      CreateBnLockFileList(LNew, BnLockFileList);
      Ok := False;
      LDiff.Append(BnLockFileList + ' <created>');
//      ShowMessage(BnLockFileList + ' created!');
    end;
    LNew.Append(BnLockFileList);

    LNew := ExpandVariables(LNew);
    KeyListAddChkSums('', LNew);
    if not LOld.LoadKeyList(BnLockCrcList) then
    begin
      Ok := False;
      if FileExists(BnLockCrcList)
        then LDiff.Append(BnLockCrcList+ ' <invalid>')
        else LDiff.Append(BnLockCrcList+ ' <will be created>');
    end;

    Ok2 := False;
    if (not KeyListsAreEqual(LNew, LOld, LDiff, Ok2, WarnFlg)) or (not Ok) then
    begin
      if AskPassWord(
          LDiff,
          'XCT Protected files (Params)',
          PwdParams,
          ExpandFileName(SelfFolder),
          AM) then
      begin
        LNew.SaveKeyList(BnLockCrcList);
        Result := True;
      end else
      begin
        Result := False;
      end;
    end else
    begin
      Result := True;
    end;

    FreeAndNil(LDiff);
    FreeAndNil(LOld);
    FreeAndNil(LNew);

  except
    on E : Exception do
      begin
        Result := False;
        ShowMessageFmt_(E.Message+sLineBreak + Param_Str(0));
      end;
  end;

end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  ProgressForm    := nil;
  FillChar(ProgressFormTmr, SizeOf(ProgressFormTmr), #0);

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
