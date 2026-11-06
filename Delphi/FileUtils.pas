unit FileUtils;
// created by: 18.04.08 P.W                                    
// purpose collect all filename and foldername tools
interface

uses
  TypesUse,
  Classes, Math, SysUtils, StrUtils;

type
  TExtCompareResult = (ECR_Equal,
                       ECR_CaseDiffers,
                       ECR_FirstEmpty,
                       ECR_SecondEmpty,
                       ECR_NotEqual);

function Reset_fmRead(var T: Text                  ): Integer;     overload;
function Reset_fmRead(var F: File                  ): Integer;     overload;
function Reset_fmRead(var F: File; RecSize: Integer): Integer;     overload;
function IsFileWriteProtected(const FileName: String): Boolean;

function ExtCompare(const ExtA, ExtB: String): TExtCompareResult;
function IsExtValid(const Ext, Filter: String): Boolean;
function IsFileExtValid(const FileName, Filter: String): Boolean;

function GetFilterByIndex(const Filter: String; FilterIndex: Integer): String;
function GetFilterIndexFromExt(const Filter, Ext: String): Integer;
function GetSelFiltExt(const SelFilter, FileExt, DefaultExt: String): String;
function GetFileNameWithValidExt(const FileName, DefaultExt, Filter: String; const FilterIndex: Integer; out OldExt, NewExt: String): String;

Implementation
  const Unit_Name = 'FileUtils'; // 03.05.24 P.W

function Reset_fmRead(var T: Text                  ): Integer;
// 18.04.08 P.W as copy from DOS.pas ResetReadOnly
// Result is Errorcode (0=OK)
var
  FileModeSav         : Word;
begin
  {$I-}
    FileModeSav := FileMode;
    FileMode    := fmOpenRead;
      Reset(T);
    FileMode    := FileModeSav;
    Result := IoResult;
  {$I+}
end;

function Reset_fmRead(var F: File                  ): Integer;
// 18.04.08 P.W
// Result is Errorcode (0=OK)
var
  FileModeSav         : Word;
begin
  {$I-}
    FileModeSav := FileMode;
    FileMode    := fmOpenRead;
      Reset(F);
    FileMode    := FileModeSav;
    Result := IoResult;
  {$I+}
end;

function Reset_fmRead(var F: File; RecSize: Integer): Integer;
// 18.04.08 P.W
// Result is Errorcode (0=OK)
var
  FileModeSav         : Word;
begin
  {$I-}
    FileModeSav := FileMode;
    FileMode    := fmOpenRead;
      Reset(f, RecSize);
    FileMode    := FileModeSav;
    Result := IoResult;
  {$I+}
end;

function IsFileWriteProtected(const FileName: String): Boolean;
begin
  Result := FileExists(FileName)
            and
            ((FileGetAttr(FileName) and faReadOnly) <> 0);
end;

function ExtCompare(const ExtA, ExtB: String): TExtCompareResult;
// 18.04.08 P.W
begin
  If (          ExtA  = ExtB           ) then Result := ECR_Equal
  else
  if (UpperCase(ExtA) = UpperCase(ExtB)) then Result := ECR_CaseDiffers
  else
  if (          ExtA  = ''             ) then Result := ECR_FirstEmpty
  else
  if (          ''    = ExtB           ) then Result := ECR_SecondEmpty
  else                                        Result := ECR_NotEqual;
end;

function IsExtValid(const Ext, Filter: String): Boolean;
// 18.04.08 P.W
begin
  Result := (
              (Filter = '')
              or
              (Pos('.*',                         Filter)      > 0)
              or
              (Pos(UpperCase(Ext)+'|', UpperCase(Filter)+'|') > 0)
              or
              (Pos(UpperCase(Ext)+';', UpperCase(Filter)+';') > 0)
            )
            and
            (Pos  ('?', Ext   ) = 0)
            and
            (Pos  ('*', Ext   ) = 0)
            and
            (Pos  ('.', Ext   ) = 1)
            and
            (PosEx('.', Ext, 2) = 0)
            ;
end;

function IsFileExtValid(const FileName, Filter: String): Boolean;
// 18.04.08 P.W
begin
  Result := IsExtValid(ExtractFileExt(FileName), Filter);
end;


function GetFilterByIndex(const Filter: String; FilterIndex: Integer): String;
// 18.04.08 P.W
// Index is based 1!
// Examples for filter:
// 'Text files (*.txt)|*.TXT';
// 'Text files (*.txt)|*.TXT|Pascal files (*.pas)|*.PAS';
// 'Pascal files|*.PAS;*.DPK;*.DPR';
// '' (empty is for All Files *.*)
// may be combined to:
// 'Text files (*.txt)|*.TXT|Pascal files|*.PAS;*.DPK;*.DPR|All files|*.*'
//  ------ Index = 1 -------|-------- Index = 2 -----------|- Index = 3 -
//  -----Part 0-------|-Pt1-|-- Part 2 --|---- Part 3 -----|-Part 4 -|Pt5
// (?) rule:     FilterName|Filter ; even number of parts
// "|" separates descriptor and extentsion list
// if Index is out of Range the first filter is returned

var
  SL : TStringList;
  Wanted : Integer;
begin
  SL := StringToStringList(Filter, '|');   // Parts: even : FilterName, Odd: Filter!
  Wanted :=  (2 * FilterIndex) -1;
  if (Wanted < 1) or (Wanted >= SL.Count) then
    Wanted := 1;  // out of range: use first filter
  if (Wanted >= SL.Count) then
    Result := '*.*'        // no Filter defined
  else
    Result := SL[Wanted];
  SL.Free;
end;

function GetFilterIndexFromExt(const Filter, Ext: String): Integer;
// 18.04.08 P.W
// Index is based 1!
// Examples for filter:
// see function GetFilterByIndex
var
  SL : TStringList;
  I  : Integer;
begin
  SL := StringToStringList(Filter, '|');   // Parts: even : FilterName, Odd: Filter!
  I := 1;
  Result := 1;
  While I < SL.Count do
  begin
    If IsExtValid(Ext, SL[I]) then
    begin
      Result := (I+1) div 2;
      Break;
    end;
    Inc(I, 2);  // 2: skip FilterNames!
  end;
  SL.Free;
end;

function GetSelFiltExt(const SelFilter, FileExt, DefaultExt: String): String;
// 18.04.08 P.W
begin
  if IsExtValid(FileExt, SelFilter) then
  begin
    Result := FileExt;
  end else
  begin
    if Pos(';', SelFilter) > 0 then
      Result := Copy(SelFilter, 1, Pos(';', SelFilter) -1)
    else
      Result := SelFilter;
    Result := ExtractFileExt(Result);
  end;
  if (Result = '') then
    Result := DefaultExt;
  if (Result = '') then
    Result := FileExt;
end;

function GetFileNameWithValidExt(const FileName, DefaultExt, Filter: String; const FilterIndex: Integer; out OldExt, NewExt: String): String;
// 18.04.08 P.W
var
  SelFilter : String;
begin
  SelFilter  := GetFilterByIndex(Filter,    FilterIndex);
  OldExt     := ExtractFileExt  (FileName);
  NewExt     := GetSelFiltExt   (SelFilter, OldExt, DefaultExt);
  Result     := ChangeFileExt   (FileName,  NewExt);
end;

end.
