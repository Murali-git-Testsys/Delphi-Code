// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; changes: 1; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
Unit Objects0;
(*
Created {22.10.03 P.W}
Aim     replace Unit Objects and ObjectsP
*)

Interface

Type
  PString = ^String; {from objects}

Const  
  { TStream_TP7 error codes (from objects.pas) } // "TStream" to "TStream_TP7" Chg#1668 (02.03.04 P.W)

  stOk         =  0;              { No error }
  stError      = -1;              { Access error }
  stInitError  = -2;              { Cannot initialize stream }
  stReadError  = -3;              { Read beyond end of stream }
  stWriteError = -4;              { Cannot expand stream }
  stGetError   = -5;              { Get of unregistered object type }
  stPutError   = -6;              { Put of unregistered object type }

function NewStr(const S: String): PString;
procedure DisposeStr(P: PString);
Function  NewStrS(const S: String): PString;

Implementation
  const Unit_Name = 'Objects0'; // 03.05.24 P.W

{ Dynamic string handling routines }

function NewStr(const S: String): PString;
var
  P: PString;
begin
  if S = '' then P := nil else
  begin
    GetMem(P, Length(S) + 1);
    P^ := S;
  end;
  NewStr := P;
end;

procedure DisposeStr(P: PString);
begin
  if P <> nil then FreeMem(P, Length(P^) + 1);
end;

Function NewStrS(const S: String): PString;
{GetMem also for S = '';  19.12.95 P.W}
var
  P: PString;
begin
  GetMem(P, Length(S) + 1);
  P^ := S;
  NewStrS := P;
end;

end.
