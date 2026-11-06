unit FileMapping;

interface
uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
   Dialogs,
   SysUtils,
   Windows;

procedure StringToMem(Text:AnsiString);
function StringFromMem:AnsiString;


Implementation
  const Unit_Name = 'FileMapping'; // 03.05.24 P.W

Function Min (A,B:LongInt): LongInt; {17.06.03 P.W}
begin
  If A<B then Min :=A else Min :=B;
end;

const
  FirstProcess : Boolean = True;
  AnToLv_MappingName : AnsiString = 'AnToLv-Share';
  LvToAn_MappingName : AnsiString = 'LvToAn-Share';

const
  BufferSize = 1024;

type
  pMappingBuffer = ^tMappingBuffer;
  tMappingBuffer = Array [0..BufferSize-1] of Byte;

var
  AnToLv_MappingHandle : THandle;
  AnToLv_pMapBuf       : pMappingBuffer;
  LvToAn_MappingHandle : THandle;
  LvToAn_pMapBuf       : pMappingBuffer;

procedure StringToBuffer(const A: AnsiString; var pB: pMappingBuffer; const BufSize: LongInt);
type
  i32Bytes = packed record
    case integer of
      0: (i32: Longint);
      1: (bArr: array [0..3] of byte);
  end;
var
  Len, I: Integer;
begin
  Len := length(A);
  for I := 0 to 3 do
    pB[I] := i32Bytes(Len).bArr[I];

  Len := Min(BufSize-4, Len);
  for I := 1 to Len do
    pB[3+I] := Ord(A[I]);
end;

procedure StringFromBuffer(var A: AnsiString; const pB: pMappingBuffer; const BufSize: LongInt);
type
  i32Bytes = packed record
    case integer of
      0: (i32: Longint);
      1: (bArr: array [0..3] of byte);
  end;
var
  Len, I: Integer;
begin
//  Len := length(A);
  for I := 0 to 3 do
    i32Bytes(Len).bArr[I] := pB[I];

  Len := Min(BufSize-4, Len);
  SetLength(A, Len);
  for I := 1 to Len do
    A[I] := Char(pB[3+I]);
end;

procedure StringToMem(Text:AnsiString);
begin
  StringToBuffer  (Text,  AnToLv_pMapBuf, BufferSize);
end;

function StringFromMem:AnsiString;
begin
  StringFromBuffer(Result, LvToAn_pMapBuf, BufferSize);
end;

procedure Prep_FileMapping(MappingName: AnsiString; var MappingHandle: THandle; var pMapBuf : pMappingBuffer);
var
  LastErr : Integer;
  l : LongInt;
  s : AnsiString;
begin

  if FirstProcess then
  begin
    MappingHandle := CreateFileMapping($FFFFFFFF,
                                       nil,
                                       PAGE_READWRITE,
                                       0,
                                       SizeOf(tMappingBuffer),
                                       PChar(MappingName));
    if (MappingHandle = 0) then
    begin
      LastErr := GetLastError;
      ShowMessage(Format('Could not create file mapping object "%s"'+sLineBreak+'Error: %d',[MappingName, LastErr]));
      EXIT;
    end;
  end else
  begin
    MappingHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS,
                                     False,
                                     PChar(MappingName));
    if (MappingHandle = 0) then
    begin
      LastErr := GetLastError;
      ShowMessage(Format('Could not open file mapping object "%s"'+sLineBreak+'Error: %d',[MappingName, LastErr]));
      EXIT;
    end;
  end;

  LastErr := GetLastError;
  Case LastErr of
    0, ERROR_ALREADY_EXISTS:
      begin
        pMapBuf := MapViewOfFile(MappingHandle,
                                      FILE_MAP_ALL_ACCESS,
                                      0,
                                      0,
                                      BufferSize);
//        s := 'Hello!'+sLineBreak+'Let''s start now...';
//        StringToBuffer(s, pMapBuf);
      end;
    else
      begin
        ShowMessage(Format('Could not create file mapping object (%d).\n',[LastErr]));
      end;
  end;

end;

procedure Init_FileMapping;
begin
//  ShowMessage('FileMapping.Pas Init_FileMapping');
  Prep_FileMapping(AnToLv_MappingName, AnToLv_MappingHandle, AnToLv_pMapBuf);
  Prep_FileMapping(LvToAn_MappingName, LvToAn_MappingHandle, LvToAn_pMapBuf);
end;

procedure Done_FileMapping;
begin
//  ShowMessage('FileMapping.Pas Done_FileMapping');
  if Assigned(AnToLv_pMapBuf) then
     UnmapViewOfFile(AnToLv_pMapBuf);
  if (AnToLv_MappingHandle <> 0) then
     CloseHandle(AnToLv_MappingHandle);

  if Assigned(LvToAn_pMapBuf) then
     UnmapViewOfFile(LvToAn_pMapBuf);
  if (LvToAn_MappingHandle <> 0) then
     CloseHandle(LvToAn_MappingHandle);

end;
(****
Initialization
  Init_FileMapping;

Finalization
  Done_FileMapping;
******)

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  AnToLv_MappingHandle := 0;
  AnToLv_MappingName   := 'AnToLv-Share';
  AnToLv_pMapBuf       := nil;
  FirstProcess         := True;
  LvToAn_MappingHandle := 0;
  LvToAn_MappingName   := 'LvToAn-Share';
  LvToAn_pMapBuf       := nil;

//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Initialization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
  Init_FileMapping;
end;
function Unit_Final(aMode: Integer=0): Integer;
// Finalization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  Done_FileMapping;
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init, Unit_Final); // 03.05.24 P.W
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  Init_FileMapping;
   -^--- moved to function Unit_Init // 03.05.24 P.W *)
Finalization
(* -v--- moved to function Unit_Final // 03.05.24 P.W
  Done_FileMapping;
   -^--- moved to function Unit_Final // 03.05.24 P.W *)
end.

