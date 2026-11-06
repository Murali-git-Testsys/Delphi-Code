unit DebugUnit;     // 19.04.24 P.W

interface

uses
 // InitFinal_List,
  Forms,
  Dialogs,
  Classes,
//  Strings,
  SysUtils;

type
  tDebugLevel = (Off, Level1, Level2, Level3);
const
  DebugLevelStr : Array[tDebugLevel] of String =
                ('Off', 'Level 1', 'Level 2', 'Level 3');
var
  DebugLevel : tDebugLevel;

procedure SetDebugLevel(DebStr: String); stdcall;


Procedure Deb0(Msg: String = 'DebMsg'); overload;
procedure Deb0(const Msg: string; Params: array of const); overload;
Procedure Deb1(Msg: String);
Function  GetWorkingDir: String;
Procedure Deb0M(Msg: String = 'DebMsg'); overload;
procedure Deb0M(const Msg: string; Params: array of const); overload;

procedure SMsg(const Msg:String); overload;
procedure SMsg(const Msg: string; Params: array of const); overload;
procedure Handle_DLL_Exception(const Msg:String); overload;
procedure Handle_DLL_Exception(const Msg: string; Params: array of const); overload;

function Get_DLL_Exception_Ctr: LongInt; stdcall;
function Get_DLL_Exception(Ctr: LongInt; Res: PChar; Size: Integer): Integer; stdcall;
function Clear_DLL_ExceptionList: Integer; stdcall;


var
  Glb_DebPos : String = '---';

  Deb0_Disabled : Boolean = True;

  ToScreen : Boolean = False; //!!!  // 24.06.24 P.W   False for DLL

Implementation
  const Unit_Name = 'DebugUnit'; // 03.05.24 P.W

procedure SetDebugLevel(DebStr: String); stdcall;
  function GetDebugLevel(DebStr: String): tDebugLevel;
  Var
    A: tDebugLevel;
  begin
    Result := Off;
    for A := Low(A) to High(A) do
      if DebStr = DebugLevelStr[A] then
        Result := A;
  end;
begin
//  SMsg('SetDebugLevel to "%s"', [DebStr]);
  DebugLevel := GetDebugLevel(DebStr);
end;

procedure SMsg(const Msg:String); overload;
begin
  ShowMessagePos(Msg, 5, 5);
end;

procedure SMsg(const Msg: string; Params: array of const); overload;
begin
  SMsg(Format(Msg, Params));
end;

var
  DLL_Exception_List : TStringList;


function Get_DLL_Exception_Ctr: LongInt; stdcall;
begin
  Result := DLL_Exception_List.Count;
end;

function Get_DLL_Exception(Ctr: LongInt; Res: PChar; Size: Integer): Integer; stdcall;
var
  count: LongInt;
  I, Len : Integer;
  A : AnsiString;
begin
  Result := 0;
  try
    count := Get_DLL_Exception_Ctr;
    if count <= 0 then EXIT;
    if Ctr <= 0 then Ctr := count;
    if Ctr > count then Ctr := count;
    A := DLL_Exception_List.Strings[Ctr-1];

    for I := 0 to Size-1  do Res[I] := #0;      // otherwise we get parts from previous longer strings

    Len := Length(A);
    if Len > Size then Len := Size;
    Result := Len;
    if Len > 0  then
      for I := 0 to Len-1  do Res[I] := PChar(A)[I];
  except
  end;
end;

function Clear_DLL_ExceptionList: Integer; stdcall;
begin
  Result := Get_DLL_Exception_Ctr;
  DLL_Exception_List.Clear;
end;

procedure Handle_DLL_Exception(const Msg:String); overload;
begin
  if DebugLevel <> Off then
    SMsg('DLL_Exception_Info (%d)' + sLineBreak + '%s'+sLineBreak+Glb_DebPos, [Get_DLL_Exception_Ctr+1, Msg]);

  DLL_Exception_List.Add(Msg+sLineBreak+Glb_DebPos);
end;

procedure Handle_DLL_Exception(const Msg: string; Params: array of const); overload;
begin
  Handle_DLL_Exception(Format(Msg, Params));
end;


const
  Deb0_File = 'C:\Temp\Deb0.txt';
var
  Deb0_Txt :       Text;

  LastWrkDir : String = '';

Procedure Deb0_Clear;
begin
  If Deb0_Disabled then EXIT;
  {$I-}
  Assign(Deb0_Txt,Deb0_File);
  Rewrite(Deb0_Txt);
  Close(Deb0_Txt);
  {$I+}
  While IoResult <> 0 do;
end;

Procedure Deb0_WriteMsg(Msg: String; NewLine: Boolean = True);
begin
  If Deb0_Disabled then EXIT;
  {$I-}
  Assign(Deb0_Txt,Deb0_File);
  Append(Deb0_Txt);
  if NewLine
    then Writeln(Deb0_Txt, Msg)
    else Write  (Deb0_Txt, Msg);
  Close(Deb0_Txt);
  {$I+}
  While IoResult <> 0 do;
end;

Function ReadList(fName: String): TStringList;
begin
  Result := TStringList.Create;
  try
  Result.LoadFromFile(fName);
  except
  end;
end;

var
  InitSkipList : TStringList = nil;
  FinalSkipList : TStringList = nil;

Function CheckInList_InitSkip(aStr: String): Boolean;
begin
  if not Assigned(InitSkipList) then
    InitSkipList := ReadList('C:\Temp\InitSkipList.txt');
  Result := InitSkipList.IndexOf(aStr) >= 0;
  If Result then;
end;

Function CheckInList_FinalSkip(aStr: String): Boolean;
begin
  if not Assigned(FinalSkipList) then
    FinalSkipList := ReadList('C:\Temp\FinalSkipList.txt');
  Result := FinalSkipList.IndexOf(aStr) >= 0;
  If Result then;
end;

Function DebInit(Msg: String): Boolean;
begin
  Deb0('<Initialization of "%s"', [Msg]);
  Result := False; // CheckInList_InitSkip(Msg);
end;

Function DebFinal(Msg: String): Boolean;
begin
  Deb0('<Finalization of "%s"', [Msg]);
  Result := False; // CheckInList_FinalSkip(Msg);
end;

Function GetWorkingDir: String;
begin
  Result := ExpandFileName('.');
end;

Procedure TstWorkingDir;
var
  CurWrkDir : String;
begin
  CurWrkDir := GetWorkingDir;
  If CurWrkDir <> LastWrkDir then
  begin
    Deb0_WriteMsg(Format('###! WorkingDir changed from "%s" to "%s"', [LastWrkDir, CurWrkDir]));
    LastWrkDir := CurWrkDir;
  end;
end;


Procedure Deb0(Msg: String = 'DebMsg'); overload;
begin
  //TurboToDelpbi.ApplicationProcessMessages; // circular or mismatched initialization order!
//      Forms.Application.ProcessMessages;     // Forms.

  TstWorkingDir;
  Deb0_WriteMsg(Msg);
end;

procedure Deb0(const Msg: string; Params: array of const); overload;
begin
  Deb0(Format(Msg, Params));
end;

Procedure Deb1(Msg: String);
begin
  //Deb0(Msg);
end;

Procedure Deb0M(Msg: String = 'DebMsg'); overload;
begin
  Deb0_WriteMsg(Msg);
  SMsg(Msg);
end;

procedure Deb0M(const Msg: string; Params: array of const); overload;
begin
  Deb0M(Format(Msg, Params));
end;

Procedure InitDeb0;
begin
  Deb0_Clear;
  Deb0_WriteMsg('Start Deb0');
  LastWrkDir := GetWorkingDir;
  Deb0_WriteMsg(Format('Initial WorkingDir: "%s"', [LastWrkDir]));
  DLL_Exception_List := TStringList.Create;
end;

function MyInit1(aMode: Integer=0): Integer;
begin
  Result := 0;
  ShowMessage('DebugUnit.MyInit1');
end;
function MyInit2(aMode: Integer=0): Integer;
begin
  Result := 0;
  if aMode <> 11 then ShowMessage('DebugUnit.MyInit2');
end;

(*
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
const Unit_Name = '??'; // 03.05.24 P.W
  Deb0(' 0');

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');

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
   -^--- moved to function Unit_Init // 03.05.24 P.W * )

function Unit_Final(aMode: Integer=0): Integer;
// Finalization part  into  function // 03.05.24 P.W
begin
  Result := 0;
end;
*)

Initialization
  InitDeb0;
//  InitFinal_Add(Unit_Name, Unit_Init); // 03.05.24 P.W
(* -v--- moved to function Unit_Init // 03.05.24 P.W
   -^--- moved to function Unit_Init // 03.05.24 P.W *)
(** )

  InitFinal_Add(Unit_Name, MyInit1, Unit_Final1);
  InitFinal_Add(Unit_Name, MyInit2);
  Init_CallAll(1);
  Final_CallAll(1);
(**)


// regular serach:
//
//   DebInit(.*);
//   If DebInit(.*) then Exit;
(*
from https://delphi.fandom.com/wiki/Regular_Expressions
Replace String Expressions
\0 .. \9 	Insert text from Group (0-9) in the Found Text
\n 	Insert a Newline
\t 	Insert a Tab

The whole point of grouping characters inside { } is to let you put them back.
For example
  Find: {Version} +{[0-9]+\.[0-9][0-9]}
  Replace: \0 Alpha \1
  will find the text Version 1.23 and
  replace it with Version Alpha 1.23 regardless of the particular digits.
  The first group finds the word Version.
  Then one or more spaces are required.
Finally the second group finds one or more digits, a period, then two digits.

Version 1.23
Version 1.23
Version Alpha 1.23
*)

(*
  {DebInits} +{[0-9]+\.[0-9][0-9]}
  DebInits 1.78

  {DebInits\(} +{[0-9]+\.[0-9][0-9]}
  DebInits( 1.78

  {DebInits\(\'} +{[0-9]+\.[0-9][0-9]}
  DebInits(' 1.78

  {DebInits\(\'}+{[a..z]*}   // til a
  DebInits('abcd

  {Deb;Inits\(\'}+{[a-z]+bcd}   // til d
  Deb;Inits('rbcd');

  {Deb;Inits\(\'}+{[a-z]}   // til r
  Deb;Inits('rbcd');

  {Deb;Inits\(\'}+{[a-z]+}   // til d
  Deb;Inits('rbcd');

  {Deb;;Inits\(\'}+{[a-z]+}   // til d
  Deb;;inits('rbCd');

  {Deb;;Inits\(\'}+{[a-z]+}+{\'\);}   // til );
  Deb;;inits('rbCd');

  {DebInits1\(\'}+{[a-z]+}+{\'\);}
  If \0\1 then EXIT;
  DebInits1('rbCd');
  DebInits1('rbCd');
  If DebInits1('rbCd then EXIT;

  {DebInits2\(\'}+{[a-z]+}+{\'\);}
  If \0\1\') then EXIT;
  DebInits2('rbCd');
  DebInits2('rbCd');
  If DebInits2('rbCd') then EXIT;

  {DebInits3\(\'}+{[a-z]+\'\)}+{;}
  If \0\1 then EXIT;
  DebInits3('rbCd');
  DebInits3('rbCd');
  If DebInits3('rbCd') then EXIT;


  DebInits('debugunit');
  DebInits('DebugUnit');
  DebInits('debugunit');
  DebInits('DebugUnit');


*)
end.

