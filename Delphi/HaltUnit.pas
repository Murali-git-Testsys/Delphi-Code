unit HaltUnit;    // 19.04.24 P.W

interface
uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  Dialogs;

var FormGlb:Pointer=nil;

Procedure H_alt(aExitCode: Integer; Msg:String='');


Implementation
  const Unit_Name = 'HaltUnit'; // 03.05.24 P.W
(*
// found in FemurPcForm1.pas:            // not used
Procedure Halt_Save(Code: Integer);
// 15.10.04 P.W. avoid access violation of simple Halt
// (Violation occured in SvComp.pas where file not found did lead to use of Halt(1))
begin
  frmMain.Free;     // does not crash when nil!
  frmMain := nil;   // otherwise DelphiCrt ModOut may crash
  Halt(Code);
end;
*)
Procedure H_alt(aExitCode: Integer; Msg:String='');
// here we come in case of error but not when normal end
begin
  Deb0          ('Halt -> H_alt (%d) ExitCode: %d%s%s', [aExitCode, ExitCode, sLineBreak, Msg]);
  ShowMessageFmt('Halt -> H_alt (%d) ExitCode: %d%s%s', [aExitCode, ExitCode, sLineBreak, Msg]);
  Halt(aExitCode);
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  FormGlb := nil;

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
