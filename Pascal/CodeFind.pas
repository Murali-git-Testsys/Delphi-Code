// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
Unit CodeFind;
(*
Created:
  {08.07.02 P.W}
Purpose: Help to find source code.
  Objects with descendants are purely supported by search symbol.
  Example:
    TGenAnalysis defines DoAnalysis as a virtual method
      these method is overwritten by TCalcBDAnalysi DoAnalysis
      If we search for DoAnalysis we get only the elements of the
      current focus.
      But each DoAnalysis has to use the procedure "CheckApplyFilterInfo"
      To ensure we find the DoAnalysis easier in future
      the constant FC_DoAnalysis is defined
      and in each DoAnalysis the line
        FindCode := FC_DoAnalysis;
      will help to browse the DoAnalysis by search Symbol "FC_DoAnalysis"

Hint: Use Unit MenuIds.Pas to find code belonging to the menubar

See also:
  {v--- inserted to find init parts of units: 18.07.03 P.W ---}
  If Test8086=0 then;
  {^--- inserted to find init parts of units: 18.07.03 P.W ---}

*)

Interface
Const
    FC_DoAnalysis            = 1 shl 0;

    FC_AsciiExport           = 1 shl 1;
    FC_WriteAsciiHeader      = 1 shl 2;
    FC_WriteAsciiResults     = 1 shl 3;
    FC_WriteAsciiParams      = 1 shl 4;
    FC_ReadAscii             = 1 shl 5;
Var
    FindCode       : LongInt;

Implementation
Uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List;  // 03.05.24 P.W

  const Unit_Name = 'CodeFind'; // 03.05.24 P.W

{Examples for use:
  FindCode := FC_DoAnalysis;
  FindCode := FC_WriteAsciiHeader  + FC_AsciiExport;
  FindCode := FC_WriteAsciiResults + FC_AsciiExport;
  FindCode := FC_WriteAsciiParams  + FC_AsciiExport;
}
procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
    FindCode       := 0;

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
