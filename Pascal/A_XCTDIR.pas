// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*
  created: {14.09.00 P.W}
  purpose: allow programs like Setup.exe to run with an undefined
           value of XCTDIR if they use "NoXctDir" as first unit
*)

Unit A_XCTDIR;

Interface

var
  AcceptInvalidXctDir : Boolean = False;

Implementation
uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List;  // 03.05.24 P.W

  const Unit_Name = 'A_XCTDIR'; // 03.05.24 P.W

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  AcceptInvalidXctDir := False;

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

