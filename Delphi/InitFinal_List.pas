unit InitFinal_List;

interface
uses
  DebugUnit,
  Classes,
  Dialogs,
  SysUtils;

type
  tInitFinalFunc =  function(aMode:Integer=0): Integer;

function InitFinal_Add(aName: String; aInit: tInitFinalFunc; aFinal: tInitFinalFunc=nil): Integer;

function Init_CallAll(aMode: Integer): Integer;
function Final_CallAll(aMode: Integer): Integer;


Implementation
  const Unit_Name = 'InitFinal_List'; // 03.05.24 P.W

Function CheckInit(var aList: TStringList): Boolean;
// create aList when nil
// returns True when just created
begin
  if not Assigned(aList) then
  begin
    aList := TStringList.Create;
    //aList.Duplicates := dupError; // at insert only checked when sorted!
    Result := True;
  end else
  begin
    Result := False;
  end;
end;

var
  InitList : TStringList = nil;
  FinalList : TStringList = nil;

type
  tInitFinalObj = class(TObject)
    Status : Integer;
    InitFinalFunc : TInitFinalFunc;
  end;

function Any_Add(var aList: TStringList;  aName: String; aFunc: tInitFinalFunc; aMode: Integer = 0): Integer;
var
  InitFinalObj : tInitFinalObj;
begin
  if Assigned(aFunc) then
  begin
    CheckInit(aList);
    InitFinalObj := tInitFinalObj.Create;
    InitFinalObj.InitFinalFunc := aFunc;
    if aList.IndexOf(aName) >= 0 then
      ShowMessageFmt('Object already inserted: %s', [aName]);
if aName = '??' then
begin
if aName = '??' then;
end;
    aList.AddObject(aName, InitFinalObj);
  end;
  Result  := 0;
end;

function InitFinal_Add(aName: String; aInit: tInitFinalFunc; aFinal: tInitFinalFunc=nil): Integer;
begin
  Any_Add(InitList,  aName, aInit );
  Any_Add(FinalList, aName, aFinal);
  Result  := 0;
end;

function Any_CallAll(aList: TStringList; aMode: Integer; Msg: String): Integer;
var
  I : Integer;
begin
  Result := 0;
  Deb0('---v--- Any_CallAll %d %s ---v---', [aMode, Msg]);
  try
    if Assigned(aList) then
    begin
      for I:= 0 to aList.Count -1 do
      begin
  Deb0('<%s (%d) %s',   [Msg, I, aList.Strings[I]]);
        tInitFinalObj(aList.Objects[I]).InitFinalFunc(aMode);
  Deb0(' %s (%d) %s >', [Msg, I, aList.Strings[I]]);
      end;
    end;
  except
    On E: Exception do
    begin
      Deb0('### Any_CallAll Exception 0');
      ShowMessage('InitFinal_List.pas Any_CallAll'+sLineBreak+E.Message);
      Deb0('### Any_CallAll Exception 0');
    end;
  end;
  Deb0('---^--- Any_CallAll %d %s ---^---', [aMode, Msg]);
end;

function Init_CallAll(aMode: Integer): Integer;
begin
  Result := Any_CallAll(InitList, aMode, 'Init');
end;

function Final_CallAll(aMode: Integer): Integer;
begin
  Result := Any_CallAll(FinalList, aMode, 'Final');
end;

end.
