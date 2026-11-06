unit DelphiCrt;
(*
Created: 17.02.04 P.W
Compiler : Delphi 7.0
Purpose: support Writeln(Output) for a Delphi Application
         like it is supported for Delphi Console Applications
         Also writes to ErrorLog
modifications:
27.04.05 P.W:
  function ModInp adapted to Delphi:
    a) Return CR LF if CR is detected
    b) Adapt BufEnd
    c) use Write(Ch) to echo input to screen
*)

interface

procedure Wait;

Implementation

uses
//  Dialogs,
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  KeyCodes,
  Crt,
  TurboToDelphi,
  Forms,
  FemurPcForm1,
  SysUtils;
  const Unit_Name = 'DelphiCrt'; // 03.05.24 P.W

procedure Wait;
var
  I: Integer;
begin
  for I := 1 to 20 do
  begin
     Sleep(500);
     ApplicationProcessMessages;
     frmMain.Show;
     frmMain.Repaint;
     Beep;
  end;
end;


function ModInp(VAR F : TTEXTREC) : Smallint ;
{ Aim: Support Writeln for Windows nonConsole Applications }
// Called by System.pas function _ReadChar(var t: TTextRec): Char;
//  Caller expects CRLF returned to terminate
//  F.BufPtr is set by Callers to the aim string ...
//  F.BufPos is set by callers to BufPtr + BufEnd - BufPos
//  expected seems that F.BufPos is set to 0
//  and F.BufEnd to Number of received Characters
//  Do not use the Buffer! (its the F.Buffer of 128 bytes)
//  Write Characters to F.BufPtr[0] ...
// DOES NOT SUPPORT BACKSPACE ...!
var
  Ch : Char;
BEGIN
  F.BufEnd := 0;
  F.BufPos := 0;
  if Assigned(frmMain) then
  begin
    if not frmMain.Enabled then
    if not frmMain.ModalFlg then  // avoid hiding Modal Box!  27.07.05 P.W
    begin
      frmMain.Enabled := True;
      frmMain.WindowState := wsMaximized;
      frmMain.Show;
      frmMain.BringToFront;
    end;
    if (F.BufEnd < F.BufSize-1) then
    begin
      Ch := ReadKey;
      Write(Ch);

      F.BufPtr[F.BufEnd] := Ch;
      Inc(F.BufEnd);
      Case Ch of
        KC1_Cr :
          begin
            F.BufPtr[F.BufEnd] := #10; //cLF;
            Inc(F.BufEnd);
            Write(#10);
          end;
      end;
    end;

    ApplicationProcessMessages;
    frmMain.Refresh;
  end;

  Result := 0;
END ;

function ModOut(VAR F : TTEXTREC) : Smallint ;
{ Aim: Support Writeln for Windows nonConsole Applications }
const
  NewLine = #13#10;
var
  Msg : string;
BEGIN
  if (F.BufPos <> F.BufEnd) then
  begin
    Msg := Copy(F.BufPtr, 1, F.BufPos);
    if Assigned(frmMain) then
    begin
      CRT_TextOut(Msg); // 19.07.04 P.W  needs NewLine
    end;

    if (Copy(Msg, Length(Msg)-Length(NewLine)+1, Length(NewLine)) = NewLine)
      then Delete(Msg, Length(Msg)-Length(NewLine)+1, Length(NewLine));

  end;

  if (F.BufPos <= F.BufSize)
    then Result := 0
    else Result := 160 ;
  F.BufPos := 0 ;   // Write does not support cyclical buffer
END ;

Var
  OrigInput  : TTextRec;
  OrigOutput : TTextRec;

Procedure Assign_Input;
begin
  OrigInput := TTEXTREC(Input);
  WITH TTEXTREC(Input) DO
  BEGIN
    Handle    := 0; // Integer;
    Mode      := fmInput; // Word;
    Flags     := 1; // Word;
    BufSize   := SizeOf(Buffer); // Cardinal;
    BufPos    := 0; // Cardinal;
    BufEnd    := 0; // Cardinal;
    BufPtr    := Addr(Buffer); // PChar;
    OpenFunc  := nil; // Pointer;
    InOutFunc := @ModInp; // Pointer;
    FlushFunc := @ModInp; // Pointer;
    CloseFunc := nil; // Pointer;
    //UserData  := ; // array[1..32] of Byte;
    //Name      := ; // array[0..259] of Char;
    //Buffer    := ; // TTextBuf;
  END;
end;

Procedure Assign_Output;
begin
  OrigOutPut := TTEXTREC(Output);
  WITH TTEXTREC(Output) DO
  BEGIN
    Handle    := 0; // Integer;
    Mode      := fmOutput; // Word;
    Flags     := 1; // Word;
    BufSize   := SizeOf(Buffer); // Cardinal;
    BufPos    := 0; // Cardinal;
    BufEnd    := 0; // Cardinal;
    BufPtr    := Addr(Buffer); // PChar;
    OpenFunc  := nil; // Pointer;
    InOutFunc := @ModOut; // Pointer;
    FlushFunc := @ModOut; // Pointer;
    CloseFunc := nil; // Pointer;
    //UserData  := ; // array[1..32] of Byte;
    //Name      := ; // array[0..259] of Char;
    //Buffer    := ; // TTextBuf;
  END;
end;

(*                    // delphi definition
type
  PTextBuf = ^TTextBuf;
  TTextBuf = array[0..127] of Char;
  TTextRec = packed record

    Handle  : Integer;
    Mode    : Word;
    Flags   : Word;
    BufSize : Cardinal;
    BufPos  : Cardinal;
    BufEnd  : Cardinal;
    BufPtr: PChar;
    OpenFunc: Pointer;
    InOutFunc: Pointer;
    FlushFunc: Pointer;
    CloseFunc: Pointer;
    UserData: array[1..32] of Byte;
    Name: array[0..259] of Char;
    Buffer: TTextBuf;

  end;
*)
procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  FillChar(OrigInput, SizeOf(OrigInput), #0);
  FillChar(OrigOutput, SizeOf(OrigOutput), #0);

//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
//   Application.CreateForm(TfrmMain, frmMain);  // 21.02.24 P.W moved from DelphiCrt to FemurPcForm1.pas

//  frmMain.Show;  // 02.09.05 P.W (handled in TfrmMain.create and timer)

  Assign_Input;
  Assign_Output;
end;

function Unit_Final(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  //Close(OutPut);
  //Close(Input);
 TTEXTREC(Output) := OrigOutput;
 TTEXTREC(Input)  := OrigInput;
end;

Initialization
  InitFinal_Add(Unit_Name, Unit_Init, Unit_Final);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
//   Application.CreateForm(TfrmMain, frmMain);  // 21.02.24 P.W moved from DelphiCrt to FemurPcForm1.pas

//  frmMain.Show;  // 02.09.05 P.W (handled in TfrmMain.create and timer)

  Assign_Input;
  Assign_Output;
   -^--- moved to function Unit_Init // 03.05.24 P.W *)

finalization
(* -v--- moved to function Unit_Final // 03.05.24 P.W
  //Close(OutPut);
  //Close(Input);
 TTEXTREC(Output) := OrigOutput;
 TTEXTREC(Input)  := OrigInput;
   -^--- moved to function Unit_Final // 03.05.24 P.W *)
end.
