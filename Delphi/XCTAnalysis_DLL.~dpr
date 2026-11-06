library XCTAnalysis_DLL;     // 19.04.24 P.W
// ===================================================================
// URGENT:
// use "Run in UI thread" for "Call Library Function"-Thread (LabVIEW)
// drawing is not thread safe
// ===================================================================

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

(*
// 19.04.24 P.W
	Startpoint: copied
	"C:\Program Files (x86)\National Instruments\LabVIEW 2015\user.lib\NovotecAddOns\_LvUc\Delphi"
	to "C:\XctCmp\Delphi"
	LV_Unicode_DLL.dpr saved as XCTAnalysis_DLL.dpr


// 07.11.2019 P.W: v8.2.00
support "WM_QUERYENDSESSION" $0011
    procedure Set_WM_QUERYENDSESSION_Result allows to define the result returned
    default is one to allow terminate the session
// 07.10.2020 P.W: v8.2.03
support "WM_SETTINGCHANGE"   $001A
support "WM_TIMECHANGE"      $001E
// 12.10.2020 P.W include resource FileVers.RES
*)

uses
//  InitFinal_List,
//  HaltUnit,
  DebugUnit,
  Param_StrUnit,
  SetDecimalPoint,
  LabViewAna,
  UTGENROI,
//  SelectForm,
//  ViewXctImages,
//  DelphiCrt,
//  PrintForm,
//  Forms,
//  FemurPcForm1,
//  RoiDialog,
//  KnMulti,
//  TurboToDelphi,
//  Draw,
//  FrmXCTAbout,
//  UseDelphi,
//  ViewScreens,
//  GraphGlb,
//  Translate,
//  FramePaint,
//  PrintersFpu,
//  UfrmShowRef,
//  UfrmRefReport,
//  Kn_Debug,
//  BufferNumbers,
//  ThreadView,
//  FormatedList,
//  GraphicsExt,
  WinTypes,
  SysUtils,
  Dialogs,
//  Math,
  LV_Delphi_Types; // in '..\Common\Pas\LV_Delphi_Types.pas';

{$R *.res}
{$R FileVers.RES}    // 12.10.2020 P.W

// PChar[]  is 0-based !
// AnsiString[] is 1-baseded !


Function Min (A,B:t_I32): t_I32; {17.06.03 P.W}
begin
  If A<B then Min :=A else Min :=B;
end;
Function Max (A,B:t_I32): t_I32; {17.06.03 P.W}
begin
  If A>B then Max :=A else Max :=B;
end;
var
  ClipCtr : t_I32 = 0;
Function Clip(V, Mini, Maxi: t_I32):t_I32;
begin
  Result := Min(Max(V,Mini),Maxi);
  if Result <> V then Inc(ClipCtr);
end;

Function Mat_Ok(B_Len, dx, dy: t_I32): Boolean;
var
  tst: t_I32;
begin
  tst := dx * dy * sizeof(t_I16);
  if tst <> B_Len then
  begin
    ShowMessage(Format('Invalid parameters for Mat_I16_Rotate!'+slinebreak+'SizeOf(t_I16)= %d,  B_Len= %d, dx= %d, dy= %d, tst= %d ',
      [SizeOf(t_I16),B_Len, dx, dy, tst]));
    Result := False;
  end else
  begin
    Result := true;
  end;
end;

Function Mat_I16_Rotate(M_In, M_Out :pMat_I16; B_Len, dx, dy: t_I32):t_I32; stdcall;
  function Idx(x,y:t_I32): t_I32;
  var
    I : t_I32;
  begin
    I := x + (y-1)*dy;
    Result := Clip(I ,1 ,dx*dy);
  end;
var
  x, y, d: t_I32;
begin
  Result := -1;
  if not Mat_Ok(B_Len, dx, dy) then EXIT;

  d := Min(dx, dy);
  For x := 1 to d do
  begin
    For y := 1 to d do
    begin
//    M_Out[Idx(x,y)] := M_In[Idx(y,x)];          // Transpose
//    M_Out[Idx(x,y)] := M_In[Idx(d-x+1,y)];     // TopDown
      M_Out[Idx(x,y)] := M_In[Idx(y,d-x+1)];     // Rotate clockwise
    end;
  end;
  Result := B_Len;
end;

Function Mat_I16_FindRoi(XS,YS: Double):t_I32; stdcall;
var
  R : PGenRoi;
begin
  Result := -1;
  R := FindRoi_XY(XS, YS); //250, 160);
  If Assigned(R) then
    Result := 1;
end;

Function Mat_I16_SetSlice(M_In :pMat_I16; B_Len, dx, dy: t_I32; VoxelSize:t_Dbl; Side: Char; CtNr: Integer):t_I32; stdcall;
begin
  Result := SetSlice (M_In, B_Len, dx, dy, VoxelSize, Side, CtNr);
end;

Function ReverseStringA(S_Inp, S_Out :PChar; S_Len: t_I32):t_I32; stdcall;
var
  I: t_I32;
begin
  for I := 0 to S_Len-1 do S_Out[I] := S_Inp[S_Len-1-I];
  Result := S_Len;
end;

Function ReverseStringW(S_Inp, S_Out :PWideChar; S_Len: t_I32):t_I32; stdcall;
var
  I: Integer;
begin
  for I := 0 to S_Len-1 do S_Out[I] := S_Inp[S_Len-1-I];
  Result := S_Len;
end;


exports
  Set_Global_WorkingDir,
  SetDebugLevel,
  Get_DLL_Exception_Ctr,
  Get_DLL_Exception,
  Clear_DLL_ExceptionList,

  Mat_I16_Rotate,
  DLL_SliceColl_Clear,
  DLL_SliceColl_ClearRois,
  DLL_SliceColl_ClearResults,

  DLL_CalcJob,
  DLL_SetGlobals,
  DLL_GetRoi,

  Mat_I16_FindRoi,
  Mat_I16_SetSlice,
  JobFromString,
  SetFileMode,
  JobFromFile,
  JobCalcAnyDebug,
  GetSlice,
  GetSlice_Range,
  GetMarkerArray,
  FilterSlice,
  SelectSlice,
  RoiJob,

  ReverseStringA;

var
  SaveDllProc: TDLLProc;

Function ReasonStr(Reason: t_I32): String;
begin
  Case Reason  of
    DLL_PROCESS_ATTACH : Result:='1 DLL_PROCESS_ATTACH';
    DLL_THREAD_ATTACH  : Result:='2 DLL_THREAD_ATTACH';
    DLL_THREAD_DETACH  : Result:='3 DLL_THREAD_DETACH';
    DLL_PROCESS_DETACH : Result:='0 DLL_PROCESS_DETACH';
    else                 Result:='-?-';
  end;
end;

procedure LibExit(Reason: t_I32);
begin
  Deb0('XCTAnalysis_DLL.dpr LibExit 0 Reason: %d "%s"', [Reason, ReasonStr(Reason)]);
  try
//      SMsg('xxx Finalize XCTAnalysis_DLL: %d', [Reason]);  // v8.2.00 for debugging  // 0: once; 2 3: several detected
    case Reason of
      DLL_PROCESS_DETACH:
      begin
        // library exit code
//        SMsg('Finalize XCTAnalysis_DLL');  // v8.1.08 for debugging  //!!!
  //      Writeln(LogFile, 'LibExit'); Flush(LogFile);
  //      Close(LogFile);
      end;
      DLL_PROCESS_ATTACH:
      begin
        //DisableThreadLibraryCalls (HInstance);        // may be no DLL_THREAD_... Messages
      end;
    end;
    if Assigned(SaveDllProc) then           // was missing in example!
    begin         // mostly nil
      Deb0('LibExit SaveDllProc 0');
      SaveDllProc(Reason);  // call saved entry point procedure
      Deb0('LibExit SaveDllProc 1');
    end;
  except
    on E: Exception do SMsg('Exception from LibExit!' + sLineBreak + E.Message);
  end;
  Deb0('XCTAnalysis_DLL.dpr LibExit 1-');
end;

begin // use  "begin"; "initialization" is not allowed for library!
// library initialization code
//  SMsg('XCTAnalysis_DLL.dpr Initialization');   //!!!
  SaveDllProc := DllProc;  // save exit procedure chain
  DllProc := @LibExit;  // install LibExit exit procedure
end.

