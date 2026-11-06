// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; changes: 3; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; changes: 8; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; changes: 10; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; changes: 64; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; changes: 13; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; changes: 17; (02.03.04 P.W)

{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Standard Objects Unit                           }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{       22.10.03 P.W  vmtLink := Ofs(... disabled for delphi }
{                     a lot of asm lines disabled
{           Code must be replaced by delphi code!
{ in asm self --> <TObject_TP7>.Self helps compiling // "tObject" to "TObject_TP7" Chg#62 (02.03.04 P.W)
{  unused Objects removed
{*******************************************************}
//TODO 1 -oPW: Implement stubbed out methods
(*
Changes:  Objects.txt
         see in folder Changes the files with same name
         but extension ".pas" replaced by ".txt"
Modifications:
// 28.06.04 procedure TStream_TP7.Put Missing write of ObjType added
// 21.06.05 procedure RegisterObjects protected against duplicate call 
*)

unit Objects;
//interface implementation end.

{$O+,F+,X+,I-,S-}

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  SysUtils, MsgBox, Windows;

const
{ TStream_TP7 access modes } // "TStream" to "TStream_TP7" Chg#92 (02.03.04 P.W)

  stCreate    = $3C00;           { Create new file }
  stOpenRead  = $3D00;           { Read access only }
  stOpenWrite = $3D01;           { Write access only }
  stOpen      = $3D02;           { Read and write access }

{ TStream_TP7 error codes } // "TStream" to "TStream_TP7" Chg#93 (02.03.04 P.W)

  stOk         =  0;              { No error }
  stError      = -1;              { Access error }
  stInitError  = -2;              { Cannot initialize stream }
  stReadError  = -3;              { Read beyond end of stream }
  stWriteError = -4;              { Cannot expand stream }
  stGetError   = -5;              { Get of unregistered object type }
  stPutError   = -6;              { Put of unregistered object type }

{ Maximum TCollection size }

  MaxCollectionSize = 65520 div SizeOf(Pointer);

{ TCollection error codes }

  coIndexError = -1;              { Index out of range }
  coOverflow   = -2;              { Overflow }

{ VMT header size }

  vmtHeaderSize = 8;

type

{ Type conversion records }

  WordRec = Packed Record // "record" to "Packed Record" Chg#166 (02.03.04 P.W)
    Lo, Hi: Byte;
  end;

{ String pointers }

  PString = ^String;


{ General arrays }

  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of Byte;

{ TStreamRec }

//type
  PStreamRec = ^TStreamRec;
  TStreamRec = Record
    ObjType : Word;     // unchanged because written to stream!
    VmtLink : Pointer;  // Word under Turbo
    Load    : Pointer;
    Store   : Pointer;
    Next    : Pointer;  // Word under Turbo
  end;

{ TObject_TP7 base object } // "TObject" to "TObject_TP7" Chg#63 (02.03.04 P.W)

  // 23.04.04 P.W TObject_TP7 renamed to TObject_TP7_0
  // and enhanced object TObject_TP7 introduced:
  // Proecdure Store implemented to avoid TStream_TP7.Put as assembler
  // TObject_TP7_0 only used to create TStream_TP7
  PObject_TP7 = ^TObject_TP7; // "TObject" to "TObject_TP7" Chg#64 (02.03.04 P.W) // "PObject" to "PObject_TP7" Chg#79 (02.03.04 P.W)

  TObject_TP7_0 = object // "TObject" to "TObject_TP7" Chg#65 (02.03.04 P.W)
    constructor Init;
    procedure Free;
    destructor Done; virtual;
  end;

{ TStream_TP7 } // "TStream" to "TStream_TP7" Chg#94 (02.03.04 P.W)

  PStream_TP7 = ^TStream_TP7; // "TStream" to "TStream_TP7" Chg#95 (02.03.04 P.W) // "PStream" to "PStream_TP7" Chg#156 (02.03.04 P.W)
  TStream_TP7 = object(TObject_TP7_0) // "TObject" to "TObject_TP7" Chg#66 (02.03.04 P.W) // "TStream" to "TStream_TP7" Chg#96 (02.03.04 P.W)
    Status: Smallint;
    ErrorInfo: Smallint;
    constructor Init;
    procedure CopyFrom(var S: TStream_TP7; Count: Longint); // "TStream" to "TStream_TP7" Chg#97 (02.03.04 P.W)
    procedure Error(Code, Info: Smallint); virtual;
    procedure Flush; virtual;
    function Get: PObject_TP7; // "PObject" to "PObject_TP7" Chg#80 (02.03.04 P.W)
    function GetPos: Longint; virtual;
    function GetSize: Longint; virtual;
    procedure Put(P: PObject_TP7); // "PObject" to "PObject_TP7" Chg#81 (02.03.04 P.W)
    procedure Read(var Buf; Count: Word); virtual;
    function ReadStr: PString;
    procedure Reset;
    procedure Seek(Pos: Longint); virtual;
    function StrRead: PChar;
    procedure StrWrite(P: PChar);
    procedure Truncate; virtual;
    procedure Write(const Buf; Count: Word); virtual;
    procedure WriteStr(P: PString);
    function GetFileName: string; virtual; // added 20.02.04 P.W
  end;

  // 23.04.04 P.W TObject_TP7 renamed to TObject_TP7_0
  // and enhanced object TObject_TP7 introduced:
  // Proecdure Store implemented to avoid TStream_TP7.Put as assembler
  // TObject_TP7_0 only used to create TStream_TP7
  // PObject_TP7 = ^TObject_TP7; defined above before TObject_TP7_0
  TObject_TP7 = object(TObject_TP7_0)
    Procedure  Store(var S:TStream_TP7); virtual;//used for persistance 23.04.04 P.W
  end;

{ DOS file name string }

  FNameStr = string[79];

{ TDosStream }

  PDosStream = ^TDosStream;
  TDosStream = object(TStream_TP7) // "TStream" to "TStream_TP7" Chg#98 (02.03.04 P.W)
    Handle : LongInt; //Handle: Word;
    File_Name : string;  // added 20.02.04 P.W
    Init_Mode : Word;    // added 20.02.04 P.W
    constructor Init(FileName: FNameStr; Mode: Word);
    destructor Done; virtual;
    function GetFileName: string; virtual;// added 20.02.04 P.W
    function GetPos: Longint; virtual;
    function GetSize: Longint; virtual;
    procedure Read(var Buf; Count: Word); virtual;
    procedure Seek(Pos: Longint); virtual;
//    procedure Truncate; virtual;
    procedure Write(const Buf; Count: Word); virtual;
  end;

{ TBufStream }
  // BufStream does not use the buffer! so it is slow (BnLockDelphi)
  PBufStream = ^TBufStream;
  TBufStream = object(TDosStream)
    Buffer: Pointer;
    BufSize: Word;
    BufPtr: Word;
    BufEnd: Word;
    constructor Init(FileName: FNameStr; Mode, Size: Word);
    destructor Done; virtual;
    procedure Flush; virtual;
    function GetPos: Longint; virtual;
    function GetSize: Longint; virtual;
    procedure Read(var Buf; Count: Word); virtual;
    procedure Seek(Pos: Longint); virtual;
    procedure Truncate; virtual;
    procedure Write(const Buf; Count: Word); virtual;
  end;

{ TEmsStream }  // Removed (unused in UtBuffer

{ TMemoryStream } // removed

{ TCollection types }

  PItemList = ^TItemList;
  TItemList = array[0..MaxCollectionSize - 1] of Pointer;

{ TCollection object }

  PCollection = ^TCollection;
  TCollection = object(TObject_TP7) // "TObject" to "TObject_TP7" Chg#67 (02.03.04 P.W)
    Items: PItemList;
    Count: Smallint;
    Limit: Smallint;
    Delta: Smallint;
    constructor Init(ALimit, ADelta: Smallint);
    constructor Load(var S: TStream_TP7); // "TStream" to "TStream_TP7" Chg#99 (02.03.04 P.W)
    destructor Done; virtual;
    function At(Index: Smallint): Pointer;
    procedure AtDelete(Index: Smallint);
    procedure AtFree(Index: Smallint);
    procedure AtInsert(Index: Smallint; Item: Pointer);
    procedure AtPut(Index: Smallint; Item: Pointer);
    procedure Delete(Item: Pointer);
    procedure DeleteAll;
    procedure Error(Code, Info: Smallint); virtual;
    procedure ForEach(Action: Pointer);
    procedure Free(Item: Pointer);
    procedure FreeAll;
    procedure FreeItem(Item: Pointer); virtual;
    function GetItem(var S: TStream_TP7): Pointer; virtual; // "TStream" to "TStream_TP7" Chg#100 (02.03.04 P.W)
    function IndexOf(Item: Pointer): Smallint; virtual;
    procedure Insert(Item: Pointer); virtual;
    procedure PutItem(var S: TStream_TP7; Item: Pointer); virtual; // "TStream" to "TStream_TP7" Chg#101 (02.03.04 P.W)
    procedure SetLimit(ALimit: Smallint); virtual;
    procedure Store(var S: TStream_TP7); // "TStream" to "TStream_TP7" Chg#102 (02.03.04 P.W)
      virtual; // virtual added 23.04.04 P.W
  end;

{ TSortedCollection object }

  TSortedCollection = object(TCollection)
    Duplicates: Boolean;
    constructor Init(ALimit, ADelta: Smallint);
    constructor Load(var S: TStream_TP7); // "TStream" to "TStream_TP7" Chg#103 (02.03.04 P.W)
    function Compare(Key1, Key2: Pointer): Smallint; virtual;
    function IndexOf(Item: Pointer): Smallint; virtual;
    procedure Insert(Item: Pointer); virtual;
    function KeyOf(Item: Pointer): Pointer; virtual;
    function Search(Key: Pointer; var Index: Smallint): Boolean; virtual;
    procedure Store(var S: TStream_TP7); // "TStream" to "TStream_TP7" Chg#104 (02.03.04 P.W)
      virtual; // virtual added 23.04.04 P.W
  end;

{ TStringCollection object }

  PStringCollection = ^TStringCollection;
  TStringCollection = object(TSortedCollection)
    function Compare(Key1, Key2: Pointer): Smallint; virtual;
    procedure FreeItem(Item: Pointer); virtual;
    function GetItem(var S: TStream_TP7): Pointer; virtual; // "TStream" to "TStream_TP7" Chg#105 (02.03.04 P.W)
    procedure PutItem(var S: TStream_TP7; Item: Pointer); virtual; // "TStream" to "TStream_TP7" Chg#106 (02.03.04 P.W)
  end;

{ TStrCollection object } // Removed


{ TResourceCollection object }  // Removed

{ TStringList object }  // Removed

{ TStrListMaker object }  // Removed

{ TPoint object }  // Removed

{ TRect Rectangle object }  // Removed

{ Dynamic string handling routines }

function NewStr(const S: String): PString;
procedure DisposeStr(P: PString);

{ Stream routines }

procedure RegisterType(var S: TStreamRec);

{ Abstract notification procedure }

procedure Abstract;

{ Objects registration procedure }

procedure RegisterObjects;

var

{ Stream error procedure }

  StreamError: Pointer = nil;


{ Stream registration records }

var
  RCollection: TStreamRec = (
    ObjType: 50;
    VmtLink: TypeOf(TCollection); // "Ofs(TypeOf" to "TypeOf" Chg#3688 (02.03.04 P.W)
    Load: @TCollection.Load;
    Store: @TCollection.Store);

var
  RStringCollection: TStreamRec = (
    ObjType: 51;
    VmtLink: TypeOf(TStringCollection); // "Ofs(TypeOf" to "TypeOf" Chg#3689 (02.03.04 P.W)
    Load: @TStringCollection.Load;
    Store: @TStringCollection.Store);

Implementation
  const Unit_Name = 'Objects'; // 03.05.24 P.W


procedure ErrMessageBox(const Msg: AnsiString);
// 23.03.05 P.W
// Duplicates: TurboToDelphi.pas and Objects.pas
begin
  MessageBox1(0, PChar(Msg), nil, MB_OK or MB_ICONWARNING+MB_TASKMODAL);
end;

procedure Abstract;
begin
  RunError(211);
end;

{ TObject_TP7 } // "TObject" to "TObject_TP7" Chg#70 (02.03.04 P.W)

constructor TObject_TP7_0.Init; // "TObject" to "TObject_TP7" Chg#71 (02.03.04 P.W)
type
  Image = Packed Record // "record" to "Packed Record" Chg#169 (02.03.04 P.W)
    Link: LongInt; //{22.10.03 P.W}  Word;
    Data: Packed Record end; // "record" to "Packed Record" Chg#170 (02.03.04 P.W)
  end;
begin
//  Deb0('D TObject_TP7_0.Init 0');
  FillChar(Image(Self).Data, SizeOf(Self) - SizeOf(TObject_TP7), 0); // "TObject" to "TObject_TP7" Chg#72 (02.03.04 P.W)
//  Deb0('D TObject_TP7_0.Init 1');
end;

{ Shorthand procedure for a done/dispose }

procedure TObject_TP7_0.Free; // "TObject" to "TObject_TP7" Chg#74 (02.03.04 P.W)
begin
  Dispose(PObject_TP7(@Self), Done); // "PObject" to "PObject_TP7" Chg#84 (02.03.04 P.W)
end;

destructor TObject_TP7_0.Done; // "TObject" to "TObject_TP7" Chg#75 (02.03.04 P.W)
begin
end;

procedure TObject_TP7.Store(var S: TStream_TP7);
begin
   Abstract;
end;

{ TStream_TP7 type registration routines } // "TStream" to "TStream_TP7" Chg#110 (02.03.04 P.W)


var
  StreamTypes : Pointer = nil;  // TP7: "const StreamTypes: Word = 0;"

procedure RegisterError;
begin
  RunError(212);  // Terminates!
end;

procedure RegisterType(var S: TStreamRec);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
// TurboToDelphi, code replaced
// 1. check that ObjType is not zero
// 2. check that ObjType is not duplicate
// 3. if ok then insert S into the chain of StreamTypes:
//     a) S.Next := StreamTypes
//     b) StreamTypes := address(S)
// removed is the check that S is member of Datasegment
// under Delphi we need Next as LongWord so the restriction
// to datasegment makes no sense
// 03.05.24 P.W
// no error message when already registered
var
  hPtr : PStreamRec;
begin
  // 1. check that ObjType is not zero
  if (S.ObjType = 0) then
  begin
    ErrMessageBox('Register Error (ObjType is zero)');
    EXIT;
  end;

  hPtr := StreamTypes;
  // 3. a)
  S.Next := hPtr;

  // 2. check that ObjType is not duplicate
  While assigned(hPtr) do
  begin
    if (hPtr^.ObjType = S.ObjType) then
    begin
      // ErrMessageBox('Register Error (ObjType in use)');   // 03.05.24 P.W disable Error Message
      EXIT;
    end;
    hPtr := hPtr^.Next;
  end;
  // --- all ok ---
  // 3. b)     now S becomes a member of the chain
  StreamTypes := Addr(S);
end;
(*
procedure RegisterType(var S: TStreamRec); assembler;
  { TODO -oPW -cCheck Changes : Register Objects }
asm
        MOV     AX,DS          // AX := DatenSegment
        CMP     AX,S.Word[2]   // compares DS and seg(S)// S only on DS!
        JNE     @@1            // not equal: jump to RegisterError
        MOV     SI,S.Word[0]   // SI := ofs(S))
        MOV     AX,[SI].TStreamRec.ObjType // AX := S.ObjType
        OR      AX,AX          // sets Z Flag
        JE      @@1            // jump if AX equals zero (ZF=1)
        MOV     DI,StreamTypes // DI := StreamTypes
        MOV     [SI].TStreamRec.Next,DI //S.Next := StreamTypes
        JMP     @@3
@@1:    JMP     RegisterError  // Terminates!
@@2:    CMP     AX,[DI].TStreamRec.ObjType
        JE      @@1            // Duplicate ObjType!
        MOV     DI,[DI].TStreamRec.Next
@@3:    OR      DI,DI
        JNE     @@2            // Jump if DI is not zero
        MOV     StreamTypes,SI // StreamTypes := ofs(S)
end;
*)

function FindStreamRec(aVmtLink: Pointer):PStreamRec;
// added 23.04.04 P.W
// searches in StreamTypes list for aObjType
// returns pointer to the StreamRec if found
//   else returns nil
begin
  Result := StreamTypes;
  While assigned(Result) do
  begin
    if (Result^.VmtLink = aVmtLink) then BREAK;
    Result := Result^.Next;
  end;
end;

function GetObjType(var S: TStream_TP7; aObjType: Word): PObject_TP7;
// added (03.03.04 P.W)
// Gets Object from Stream
var
  hPtr : PStreamRec;
  hCall: Pointer;
begin
  Result := nil;
  hPtr := StreamTypes;

  While assigned(hPtr) and (not Assigned(Result)) do
  begin
    if (hPtr^.ObjType = aObjType) then
    begin // create an instance
      // like Result := New(PObj1, Load(S));
      // BUT the type PObj1 is flexible! (VmtLink as parameter)
      asm  // eax, edx, ecx are free for use
        mov  ecx, hPtr
        mov  edx, [ecx].TStreamRec.VmtLink  // prepare EDX

        mov  ecx, [ecx].TStreamRec.Load     // prepare hCall
        mov hCall, ecx

        mov  ecx, S                         // prepare ECX

        xor  eax,  eax                      // prepare EAX zero
        call hCall    // needs parameters: eax=0, edx=VMT, ecx=S
        mov  Result, eax
      end;
    end;
    if (hPtr = hPtr^.Next) then   // 21.06.05 P.W
    begin
      S.Status := stGetError;
      BREAK;
    end;
    hPtr := hPtr^.Next;
  end;
end;


{ TStream_TP7 support routines } // "TStream" to "TStream_TP7" Chg#111 (02.03.04 P.W)

const
  TStream_Error = vmtHeaderSize + $04;
  TStream_Flush = vmtHeaderSize + $08;
  TStream_Read  = vmtHeaderSize + $14;
  TStream_Write = vmtHeaderSize + $20;

procedure DoStreamError(S: PStream_TP7; Code : SmallInt); // "PStream" to "PStream_TP7" Chg#162 (02.03.04 P.W)
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// 23.03.05 P.W:
// no longer call ErrLogMsg for stError and stInitError
begin
 { TODO -oPW -cAdapt Objects : Fill in code for removed asm }
  If (Code <> stReadError ) and   // stReadError occurs at end of read ini files
     (Code <> stError) and (Code <> stInitError) then // 23.03.05 P.W
    ErrMessageBox(
      Format('Stream Error %d occured in "%s"',
             [Code, S.GetFileName]));
  S.Status := Code;
end;
(*
procedure DoStreamError; near; assembler;
{ Stream error handler                                  }
{ In    AX    = Error info                              }
{       DX    = Error code                              }
{       ES:DI = Stream object pointer                   }
{ Uses  AX,BX,CX,DX,SI                                  }
asm
        PUSH    ES
        PUSH    DI
        PUSH    DX
        PUSH    AX
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    DWORD PTR [DI].TStream_Error
        POP     DI
        POP     ES
end;
*)

{ TStream_TP7 } // "TStream" to "TStream_TP7" Chg#113 (02.03.04 P.W)

constructor TStream_TP7.Init; // "TStream" to "TStream_TP7" Chg#114 (02.03.04 P.W)
begin
  TObject_TP7_0.Init; // "TObject" to "TObject_TP7" Chg#76 (02.03.04 P.W)
  Status := stOk;
  ErrorInfo := 0;
end;

function TStream_TP7.GetFileName: string; // added 20.02.04 P.W // "TStream" to "TStream_TP7" Chg#115 (02.03.04 P.W)
begin
  Result := '-';
end;

procedure TStream_TP7.CopyFrom(var S: TStream_TP7; Count: Longint); // "TStream" to "TStream_TP7" Chg#116 (02.03.04 P.W) // "TStream" to "TStream_TP7" Chg#117 (02.03.04 P.W)
var
  N: Word;
  Buffer: array[0..1023] of Byte;
begin
  while Count > 0 do
  begin
    if Count > SizeOf(Buffer) then N := SizeOf(Buffer) else N := Count;
    S.Read(Buffer, N);
    Write(Buffer, N);
    Dec(Count, N);
  end;
end;

procedure TStream_TP7.Error(Code, Info: Smallint); // "TStream" to "TStream_TP7" Chg#118 (02.03.04 P.W)
type
  TErrorProc = procedure(var S: TStream_TP7); // "TStream" to "TStream_TP7" Chg#119 (02.03.04 P.W)
begin
  Status := Code;
  ErrorInfo := Info;
  if StreamError <> nil then TErrorProc(StreamError)(Self);
end;

procedure TStream_TP7.Flush; // "TStream" to "TStream_TP7" Chg#120 (02.03.04 P.W)
begin
end;

function TStream_TP7.Get: PObject_TP7; // "PObject" to "PObject_TP7" Chg#85 (02.03.04 P.W) // "TStream" to "TStream_TP7" Chg#121 (02.03.04 P.W)
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
var
  Buf : Word;
begin
  Result := nil;
  If (Status = stOk) then
    Read(Buf, 2);
  If (Status = stOk) then
  Result := GetObjType(Self, Buf);
end;
(*
function TStream_TP7.Get: PObject_TP7; assembler; // "PObject" to "PObject_TP7" Chg#86 (02.03.04 P.W) // "TStream" to "TStream_TP7" Chg#122 (02.03.04 P.W)
asm
        PUSH    AX
        MOV     AX,SP
        PUSH    SS
        PUSH    AX
        MOV     AX,2
        PUSH    AX
        LES     DI,TStream_TP7.Self // "TStream" to "TStream_TP7" Chg#123 (02.03.04 P.W)
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    DWORD PTR [DI].TStream_Read
        POP     AX
        OR      AX,AX
        JE      @@3
        MOV     BX,StreamTypes
        JMP     @@2
@@1:    CMP     AX,[BX].TStreamRec.ObjType
        JE      @@4
        MOV     BX,[BX].TStreamRec.Next
@@2:    OR      BX,BX
        JNE     @@1
        LES     DI,TStream_TP7.Self // "TStream" to "TStream_TP7" Chg#124 (02.03.04 P.W)
        MOV     DX,stGetError
        CALL    DoStreamError
@@3:    XOR     AX,AX
        MOV     DX,AX
        JMP     @@5
@@4:    LES     DI,TStream_TP7.Self // "TStream" to "TStream_TP7" Chg#125 (02.03.04 P.W)
        PUSH    ES
        PUSH    DI
        PUSH    [BX].TStreamRec.VmtLink
        XOR     AX,AX
        PUSH    AX
        PUSH    AX
        CALL    [BX].TStreamRec.Load
@@5:
end;
*)

function TStream_TP7.GetPos: Longint; // "TStream" to "TStream_TP7" Chg#126 (02.03.04 P.W)
begin
  Abstract;
  Result := 0;
end;

function TStream_TP7.GetSize: Longint; // "TStream" to "TStream_TP7" Chg#127 (02.03.04 P.W)
begin
  Abstract;
  Result := 0;
end;

procedure TStream_TP7.Put(P: PObject_TP7); // "PObject" to "PObject_TP7" Chg#87 (02.03.04 P.W) // "TStream" to "TStream_TP7" Chg#128 (02.03.04 P.W)
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// DESCRIPTION:
// Supports storing of objects into a stream for read using "Get"
//   If P is not nil then
//   a) Search VmtOffset in list of registrated objects (compares whith
//      field VmtLink)
//   b) write ObjectTypeId into stream
//   c) call Store of the Object
//   If P is not registered then calls "Error" and writes nothing into stream
//   If P is nil then writes only a word of value zero into stream
// 28.06.04 Missing write of ObjType added
var
  VmtLink   : Pointer;
  StreamRec : PStreamRec;
  WordZero  : Word;
begin
  WordZero := 0;
  if Assigned(P) then
  begin  // search the registerd VmtLink
    VmtLink   := TypeOf(TObject_TP7(P^));
    StreamRec := FindStreamRec(VmtLink);
    if Assigned(StreamRec) then
    begin
      // v------------- missing write ObjType added 28.07.04 P.W
       If (Status = stOk) then
       begin
         Write(StreamRec.ObjType, 2);
       end else
       begin
         DoStreamError(@Self, stPutError);
       end;
      // ^------------- missing write ObjType added 28.07.04 P.W
      P^.Store(self);
    end else
    begin // Error
      DoStreamError(@Self, stPutError);
    end;
  end else
  begin  // P is nil; write word zero into stream
    Write(WordZero, SizeOf(WordZero));
  end;
end;
(*
procedure TStream_TP7.Put(P: PObject_TP7); assembler; // "PObject" to "PObject_TP7" Chg#88 (02.03.04 P.W) // "TStream" to "TStream_TP7" Chg#129 (02.03.04 P.W)
asm
        LES     DI,Pointer(P) //{22.10.03 P.W}  LES     DI,P
        MOV     CX,ES
        OR      CX,DI
        JE      @@4
        MOV     AX,ES:[DI]
        MOV     BX,StreamTypes
        JMP     @@2
@@1:    CMP     AX,[BX].TStreamRec.VmtLink
        JE      @@3
        MOV     BX,[BX].TStreamRec.Next
@@2:    OR      BX,BX
        JNE     @@1
        LES     DI,TStream_TP7.Self // "TStream" to "TStream_TP7" Chg#130 (02.03.04 P.W)
        MOV     DX,stPutError
        CALL    DoStreamError
        JMP     @@5
@@3:    MOV     CX,[BX].TStreamRec.ObjType
@@4:    PUSH    BX
        PUSH    CX
        MOV     AX,SP
        PUSH    SS
        PUSH    AX
        MOV     AX,2
        PUSH    AX
        LES     DI,TStream_TP7.Self // "TStream" to "TStream_TP7" Chg#131 (02.03.04 P.W)
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    DWORD PTR [DI].TStream_Write
        POP     CX
        POP     BX
        JCXZ    @@5
        LES     DI,TStream_TP7.Self // "TStream" to "TStream_TP7" Chg#132 (02.03.04 P.W)
        PUSH    ES
        PUSH    DI
        PUSH    P.Word[2]
        PUSH    P.Word[0]
        CALL    [BX].TStreamRec.Store
@@5:
end;
*)

procedure TStream_TP7.Read(var Buf; Count: Word); // "TStream" to "TStream_TP7" Chg#133 (02.03.04 P.W)
begin
  Abstract;
end;

function TStream_TP7.ReadStr: PString; // "TStream" to "TStream_TP7" Chg#134 (02.03.04 P.W)
var
  L: Byte;
  P: PString;
begin
  Read(L, 1);
  if L > 0 then
  begin
    GetMem(P, L + 1);
    //P^[0] := Char(L);
    SetLength(P^, L);
    Read(P^[1], L);
    ReadStr := P;
  end else ReadStr := nil;
end;

procedure TStream_TP7.Reset; // "TStream" to "TStream_TP7" Chg#135 (02.03.04 P.W)
begin
  Status := stOk;
  ErrorInfo := 0;
end;

procedure TStream_TP7.Seek(Pos: Longint); // "TStream" to "TStream_TP7" Chg#136 (02.03.04 P.W)
begin
  Abstract;
end;

function TStream_TP7.StrRead: PChar; // "TStream" to "TStream_TP7" Chg#137 (02.03.04 P.W)
var
  L: Word;
  P: PChar;
begin
  Read(L, SizeOf(Word));
  if L = 0 then StrRead := nil else
  begin
    GetMem(P, L + 1);
    Read(P[0], L);
    P[L] := #0;
    StrRead := P;
  end;
end;

procedure TStream_TP7.StrWrite(P: PChar); // "TStream" to "TStream_TP7" Chg#138 (02.03.04 P.W)
var
  L: Word;
begin
  if P = nil then L := 0 else L := StrLen(P);
  Write(L, SizeOf(Word));
  if P <> nil then Write(P[0], L);
end;

procedure TStream_TP7.Truncate; // "TStream" to "TStream_TP7" Chg#139 (02.03.04 P.W)
begin
  Abstract;
end;

procedure TStream_TP7.Write(const Buf; Count: Word); // "TStream" to "TStream_TP7" Chg#140 (02.03.04 P.W)
begin
  Abstract;
end;

procedure TStream_TP7.WriteStr(P: PString); // "TStream" to "TStream_TP7" Chg#141 (02.03.04 P.W)
const
//  Empty: String[1] = '';
  Empty : Char = #0;  // 22.03.05 P.W
begin
  if P <> nil then Write(P^, Length(P^) + 1) else Write(Empty, 1);
end;

{ TDosStream }

constructor TDosStream.Init(FileName: FNameStr; Mode: Word);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// uses now delphi SysUtils:
// function FileOpen(const FileName: string; Mode: LongWord): Integer;
// FileCreate
// 23.04.04 P.W
// inherited init added;
var
  OpenMode : LongWord;
begin
// === Turbo:  ==================================================
//  stCreate    = $3C00;           { Create new file }
//  stOpenRead  = $3D00;           { Read access only }
//  stOpenWrite = $3D01;           { Write access only }
//  stOpen      = $3D02;           { Read and write access }
// === Delphi: ==================================================
//  fmCreate         = $FFFF;           (?) (only in help not sysUtils)
//  fmOpenRead       = $0000;
//  fmOpenWrite      = $0001;
//  fmOpenReadWrite  = $0002;
//
//  fmShareCompat    = $0000 platform;
//  fmShareExclusive = $0010;
//  fmShareDenyWrite = $0020;
//  fmShareDenyRead  = $0030 platform;
//  fmShareDenyNone  = $0040;
//
// function FileOpen(const FileName: string; Mode: LongWord): Integer;
// function FileCreate(const FileName: string): Integer; overload;
// FileCreate creates a new file with the specified name.
// Return values for FileOpen and FileCreate are equal:
// If the return value is positive, the function was successful and
// the value is the file handle of the new file.
// A return value of -1 indicates that an error occurred.
   inherited init; // 23.04.04 P.W

   FileName  := ExpandFileName(FileName);
   File_Name := FileName;
   Init_Mode := Mode;
   Case Mode of
     stCreate    : OpenMode := $FFFF;//fmCreate; (not defined)
     stOpenRead  : OpenMode := fmOpenRead;
     stOpenWrite : OpenMode := fmOpenWrite;
     stOpen      : OpenMode := fmOpenReadWrite;
     else          OpenMode := fmOpenRead;
   end;
   If (Mode = stCreate)
     then Handle := FileCreate(FileName)
     else Handle := FileOpen(FileName, OpenMode or fmShareDenyNone);
   If (Handle <= 0) then
     DoStreamError(@Self, stInitError);
end;
(*
constructor TDosStream.Init(FileName: FNameStr; Mode: Word); assembler;
var
  NameBuf: array[0..79] of Char;
asm
        XOR     AX,AX
        PUSH    AX
        LES     DI,TDosStream.Self
        PUSH    ES
        PUSH    DI
        CALL    TStream_TP7.Init // "TStream" to "TStream_TP7" Chg#142 (02.03.04 P.W)
{$I F D E F Windows}
	LEA	DI,NameBuf
	PUSH	SS
	PUSH	DI
	LES	DI,FileName
	PUSH	ES
	PUSH	DI
	MOV	AX,79
	PUSH	AX
	CALL	StrLCopy
	PUSH	DX
	PUSH	AX
	PUSH	DX
	PUSH	AX
	CALL	AnsiToOem
	PUSH	DS
	LEA	DX,NameBuf
{$ELSE}
        PUSH    DS
        LDS     SI,Pointer(FileName)//{22.10.03 P.W}   LDS     SI,FileName
        LEA     DI,NameBuf
        MOV     DX,DI
        PUSH    SS
        POP     ES
        CLD
        LODSB
        CMP     AL,79
        JB      @@1
        MOV     AL,79
@@1:    CBW
        XCHG    AX,CX
        REP     MOVSB
        XCHG    AX,CX
        STOSB
{$ENDIF}
        PUSH    SS
        POP     DS
        XOR     CX,CX
        MOV     AX,Mode
        INT     21H
        POP     DS
        JNC     @@2
        LES     DI,TDosStream.Self
        MOV     DX,stInitError
        CALL    DoStreamError
        MOV     AX,-1
@@2:    LES     DI,TDosStream.Self
        MOV     ES:[DI].TDosStream.Handle,AX
end;
*)

destructor TDosStream.Done;
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// now uses SysUtils FileClose
begin

// procedure FileClose(Handle: Integer);
// FileClose closes a file given its handle. The handle is
// obtained when the file is opened using FileOpen or FileCreate.
  FileClose(Handle);
end;
(*
destructor TDosStream.Done; assembler;
asm
        LES     DI,TDosStream.Self
        MOV     BX,ES:[DI].TDosStream.Handle
        CMP     BX,-1
        JE      @@1
        MOV     AH,3EH
        INT     21H
@@1:    XOR     AX,AX
        PUSH    AX
        PUSH    ES
        PUSH    DI
        CALL    TStream_TP7.Done // "TStream" to "TStream_TP7" Chg#143 (02.03.04 P.W)
end;
*)

function TDosStream.GetFileName: string; // added 20.02.04 P.W
begin
  Result := File_Name;
end;

function TDosStream.GetPos: Longint;
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// uses now SysUtils FileSeek
Const
  OriginCurPos = 1;
begin

// delphi FileSeek
// function FileSeek(Handle, Offset, Origin: Integer): Integer; overload;
// The file pointer is positioned Offset bytes from ...
//   Origin = 0:	... the beginning of the file.
//   Origin = 1:	... its current position.
//   Origin = 2:	... the end of the file.
// If FileSeek is successful, it returns the new position of the file pointer;
//   otherwise, it returns -1.

  Result := FileSeek(Handle, 0, OriginCurPos); // move relative zero bytes
  if (Result = -1) then
    DoStreamError(@self, stError);
end;
(*
function TDosStream.GetPos: Longint; assembler;
asm
        LES     DI,TDosStream.Self
        XOR     DX,DX
        CMP     DX,ES:[DI].TDosStream.Status
        JNE     @@1
        MOV     CX,DX
        MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AX,4201H
        INT     21H
        JNC     @@2
        MOV     DX,stError
        CALL    DoStreamError
@@1:    MOV     AX,-1
        CWD
@@2:
end;
*)

function TDosStream.GetSize: Longint;
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
Const
  OriginEnd = 2;
var
 OrgPos : LongInt;
begin

// delphi FileSeek
// function FileSeek(Handle, Offset, Origin: Integer): Integer; overload;
// The file pointer is positioned Offset bytes from ...
//   Origin = 0:	... the beginning of the file.
//   Origin = 1:	... its current position.
//   Origin = 2:	... the end of the file.
// If FileSeek is successful, it returns the new position of the file pointer;
//   otherwise, it returns -1.

  OrgPos := GetPos;
  Result := FileSeek(Handle, 0, OriginEnd); // move zero bytes to end;
  if (Result = -1) then
    DoStreamError(@self, stError);
  Seek(OrgPos);
end;
(*
function TDosStream.GetSize: Longint; assembler;
asm
        LES     DI,TDosStream.Self
        XOR     DX,DX
        CMP     DX,ES:[DI].TDosStream.Status
        JNE     @@1
        MOV     CX,DX
        MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AX,4201H
        INT     21H
        PUSH    DX
        PUSH    AX
        XOR     DX,DX
        MOV     CX,DX
        MOV     AX,4202H
        INT     21H
        POP     SI
        POP     CX
        PUSH    DX
        PUSH    AX
        MOV     DX,SI
        MOV     AX,4200H
        INT     21H
        POP     AX
        POP     DX
        JNC     @@2
        MOV     DX,stError
        CALL    DoStreamError
@@1:    MOV     AX,-1
        CWD
@@2:
end;
*)

procedure TDosStream.Read(var Buf; Count: Word);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// now uses SysUtils FileRead
begin

// function FileRead(Handle: Integer; var Buffer; Count: Integer): Integer;
// FileRead reads Count bytes from the file specified by Handle
// into the buffer. The Count parameter indicates the size,
// in bytes, of the buffer. The function result is the actual
// number of bytes read, which may be less than Count.
// The Handle that is passed to FileRead must be opened with
// FileOpen or FileCreate.
  if (FileRead(Handle, Buf, Count) <> Count) then
    DoStreamError(@self, stReadError);
end;
(*
procedure TDosStream.Read(var Buf; Count: Word); assembler;
asm
        LES     DI,TDosStream.Self
        CMP     ES:[DI].TDosStream.Status,0
        JNE     @@2
        PUSH    DS
        LDS     DX,Pointer(Buf)//{22.10.03 P.W}LDS     DX,Buf
        MOV     CX,Count
        MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AH,3FH
        INT     21H
        POP     DS
        MOV     DX,stError
        JC      @@1
        CMP     AX,CX
        JE      @@3
        XOR     AX,AX
        MOV     DX,stReadError
@@1:    CALL    DoStreamError
@@2:    LES     DI,Pointer(Buf) //{22.10.03 P.W}LES     DI,Buf
        MOV     CX,Count
        XOR     AL,AL
        CLD
        REP     STOSB
@@3:
end;
*)

procedure TDosStream.Seek(Pos: Longint);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// now use FileSeek
Const
  OriginBegin = 0;
begin
// delphi FileSeek
// function FileSeek(Handle, Offset, Origin: Integer): Integer; overload;
// The file pointer is positioned Offset bytes from ...
//   Origin = 0:	... the beginning of the file.
//   Origin = 1:	... its current position.
//   Origin = 2:	... the end of the file.
// If FileSeek is successful, it returns the new position of the file pointer;
//   otherwise, it returns -1.

  if (FileSeek(Handle, Pos, OriginBegin) = -1) then
    DoStreamError(@self, stError);
end;
(*
procedure TDosStream.Seek(Pos: Longint); assembler;
asm
        LES     DI,TDosStream.Self
        CMP     ES:[DI].TDosStream.Status,0
        JNE     @@2
        MOV     DX,Pos.Word[0]
        MOV     CX,Pos.Word[2]
        OR      CX,CX
        JNS     @@1
        XOR     DX,DX
        XOR     CX,CX
@@1:    MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AX,4200H
        INT     21H
        JNC     @@2
        MOV     DX,stError
        CALL    DoStreamError
@@2:
end;
*)

procedure TDosStream.Write(const Buf; Count: Word);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// now use FileWrite
begin
// Delphi SysUtils FileWrite
// function FileWrite(Handle: Integer; const Buffer; Count: Integer): Integer;
// FileWrite writes Count bytes to the file given by Handle from the buffer
//   specified by Buffer. Handle is a file handle returned by the FileOpen
//   or FileCreate method.
// The return value is the number of bytes actually written,
//   or -1 if an error occurred.
  if (FileWrite(Handle, Buf, Count) = -1) then
    DoStreamError(@self, stWriteError);
end;
{
procedure TDosStream.Write(var Buf; Count: Word); assembler;
asm
        LES DI,TDosStream.Self
        CMP     ES:[DI].TDosStream.Status,0
        JNE     @@2
        PUSH    DS
        LDS     DX,Pointer(Buf) // 22.10.03 P.W LDS     DX,Buf
        MOV     CX,Count
        MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AH,40H
        INT     21H
        POP     DS
        MOV     DX,stError
        JC      @@1
        CMP     AX,CX
        JE      @@2
        XOR     AX,AX
        MOV     DX,stWriteError
@@1:    CALL    DoStreamError
@@2:
end;
}

{ TBufStream }

{ Flush TBufStream buffer                               }
{ In    AL    = Flush mode (0=Read, 1=Write, 2=Both)    }
{       ES:DI = TBufStream pointer                      }
{ Out   ZF    = Status test                             }
procedure FlushBuffer(BS: TBufStream);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
begin
  If (BS.BufPtr <> BS.BufEnd) then
  begin
   Case BS.Init_Mode of
     stCreate,
     stOpenWrite,
     stOpen:
       begin
//         ErrorNotSupported('(ok?) procedure FlushBuffer;');
         BS.Write(BS.Buffer, BS.BufEnd - BS.BufPtr);
       end;
   end;
  end;
  BS.BufPtr := 0;
  BS.BufEnd := 0;
end;
{
procedure FlushBuffer; near; assembler;
asm
        MOV     CX,ES:[DI].TBufStream.BufPtr
        SUB     CX,ES:[DI].TBufStream.BufEnd
        JE      @@3
        MOV     BX,ES:[DI].TDosStream.Handle
        JA      @@1
        CMP     AL,1
        JE      @@4
        MOV     DX,CX
        MOV     CX,-1
        MOV     AX,4201H
        INT     21H
        JMP     @@3
@@1:    CMP     AL,0
        JE      @@4
        PUSH    DS
        LDS     DX,ES:[DI].TBufStream.Buffer
        MOV     AH,40H
        INT     21H
        POP     DS
        MOV     DX,stError
        JC      @@2
        CMP     AX,CX
        JE      @@3
        XOR     AX,AX
        MOV     DX,stWriteError
@@2:    CALL    DoStreamError
@@3:    XOR     AX,AX
        MOV     ES:[DI].TBufStream.BufPtr,AX
        MOV     ES:[DI].TBufStream.BufEnd,AX
        CMP     AX,ES:[DI].TStream_TP7.Status // "TStream" to "TStream_TP7" Chg#144 (02.03.04 P.W)
@@4:
end;
}

constructor TBufStream.Init(FileName: FNameStr; Mode, Size: Word);
begin
  TDosStream.Init(FileName, Mode);
  BufSize := Size;
  if Size = 0 then Error(stInitError, 0)
  else GetMem(Buffer, Size);
  BufPtr := 0;
  BufEnd := 0;
end;

destructor TBufStream.Done;
begin
  TBufStream.Flush;
  TDosStream.Done;
  FreeMem(Buffer, BufSize);
end;

procedure TBufStream.Flush;
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
begin
  If (Status = stOk) then
  begin
    FlushBuffer(Self);
  end;
end;
{
procedure TBufStream.Flush; assembler;
asm
        LES     DI,TBufStream.Self
        CMP     ES:[DI].TBufStream.Status,0
        JNE     @@1
        MOV     AL,2
        CALL    FlushBuffer
@@1:
end;
}

function TBufStream.GetPos: Longint;
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// uses now inhrited GetPos;
begin
  Result := inherited GetPos;
end;
{
function TBufStream.GetPos: Longint; assembler;
asm
        LES     DI,TBufStream.Self
        PUSH    ES
        PUSH    DI
        CALL    TDosStream.GetPos
        OR      DX,DX
        JS      @@1
        LES     DI,TBufStream.Self
        SUB     AX,ES:[DI].TBufStream.BufEnd
        SBB     DX,0
        ADD     AX,ES:[DI].TBufStream.BufPtr
        ADC     DX,0
@@1:
end;
}
function TBufStream.GetSize: Longint;
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
begin
  Result := inherited GetSize;
end;
{
function TBufStream.GetSize: Longint; assembler;
asm
        LES     DI,TBufStream.Self
        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        CALL    TBufStream.Flush
        CALL    TDosStream.GetSize
end;
}

procedure TBufStream.Read(var Buf; Count: Word);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// uses now inherited read;
begin
  inherited Read(Buf, Count);
end;
{
procedure TBufStream.Read(var Buf; Count: Word); assembler;
asm
        LES     DI,TBufStream.Self
        CMP     ES:[DI].TBufStream.Status,0
        JNE     @@6
        MOV     AL,1
        CALL    FlushBuffer
        JNE     @@6
        XOR     BX,BX
@@1:    MOV     CX,Count
        SUB     CX,BX
        JE      @@7
        LES     DI,TBufStream.Self
        MOV     AX,ES:[DI].TBufStream.BufEnd
        SUB     AX,ES:[DI].TBufStream.BufPtr
        JA      @@2
        PUSH    DS
        PUSH    CX
        PUSH    BX
        LDS     DX,ES:[DI].TBufStream.Buffer
        MOV     CX,ES:[DI].TBufStream.BufSize
        MOV     BX,ES:[DI].TBufStream.Handle
        MOV     AH,3FH
        INT     21H
        POP     BX
        POP     CX
        POP     DS
        MOV     DX,stError
        JC      @@5
        MOV     ES:[DI].TBufStream.BufPtr,0
        MOV     ES:[DI].TBufStream.BufEnd,AX
        OR      AX,AX
        JE      @@4
@@2:    CMP     CX,AX
        JB      @@3
        MOV     CX,AX
@@3:    PUSH    DS
        LDS     SI,ES:[DI].TBufStream.Buffer
        ADD     SI,ES:[DI].TBufStream.BufPtr
        ADD     ES:[DI].TBufStream.BufPtr,CX
        LES     DI,Pointer(Buf) //22.10.03 P.WLES     DI,Buf
        ADD     DI,BX
        ADD     BX,CX
        CLD
        REP     MOVSB
        POP     DS
        JMP     @@1
@@4:    MOV     DX,stReadError
@@5:    CALL    DoStreamError
@@6:    LES     DI,Pointer(Buf) //22.10.03 P.WLES     DI,Buf
        MOV     CX,Count
        XOR     AL,AL
        CLD
        REP     STOSB
@@7:
end;
}

procedure TBufStream.Seek(Pos: Longint);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
begin
  inherited Seek(Pos);
end;
{
procedure TBufStream.Seek(Pos: Longint); assembler;
asm
        LES     DI,TBufStream.Self
        PUSH    ES
        PUSH    DI
        CALL    TDosStream.GetPos
        OR      DX,DX
        JS      @@2
        LES     DI,TBufStream.Self
        SUB     AX,Pos.Word[0]
        SBB     DX,Pos.Word[2]
        JNE     @@1
        OR      AX,AX
        JE      @@1
        MOV     DX,ES:[DI].TBufStream.BufEnd
        SUB     DX,AX
        JB      @@1
        MOV     ES:[DI].TBufStream.BufPtr,DX
        JMP     @@2
@@1:    PUSH    Pos.Word[2]
        PUSH    Pos.Word[0]
        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        CALL    TBufStream.Flush
        CALL    TDosStream.Seek
@@2:
end;
}

procedure TBufStream.Truncate;
begin
  TBufStream.Flush;
  TDosStream.Truncate;
end;

procedure TBufStream.Write(const Buf; Count: Word);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// uses now inherited Write
begin
  inherited Write(Buf, Count);
end;
{
procedure TBufStream.Write(var Buf; Count: Word); assembler;
asm
        LES     DI,TBufStream.Self
        CMP     ES:[DI].TBufStream.Status,0
        JNE     @@4
        MOV     AL,0
        CALL    FlushBuffer
        JNE     @@4
        XOR     DX,DX
@@1:    MOV     CX,Count
        SUB     CX,DX
        JE      @@4
        LES     DI,TBufStream.Self
        MOV     AX,ES:[DI].TBufStream.BufSize
        SUB     AX,ES:[DI].TBufStream.BufPtr
        JA      @@2
        PUSH    CX
        PUSH    DX
        MOV     AL,1
        CALL    FlushBuffer
        POP     DX
        POP     CX
        JNE     @@4
        MOV     AX,ES:[DI].TBufStream.BufSize
@@2:    CMP     CX,AX
        JB      @@3
        MOV     CX,AX
@@3:    PUSH    DS
        MOV     AX,ES:[DI].TBufStream.BufPtr
        ADD     ES:[DI].TBufStream.BufPtr,CX
        LES     DI,ES:[DI].TBufStream.Buffer
        ADD     DI,AX
        LDS     SI,TBufStream.Buf
        ADD     SI,DX
        ADD     DX,CX
        CLD
        REP     MOVSB
        POP     DS
        JMP     @@1
@@4:
end;
}

{ TEmsStream }  // Removed

{ TMemoryStream } // Removed

{ TCollection }

const
  TCollection_Error    = vmtHeaderSize + $04;
  TCollection_SetLimit = vmtHeaderSize + $1C;

procedure CollectionError(Code: SmallInt);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
begin
 { TODO -oPW -cAdapt Objects : Fill in code for removed asm }
  ErrMessageBox(
    Format('Collection Error %d occured',
           [Code]));
end;
{
procedure CollectionError; near; assembler;
asm
        PUSH    AX
        PUSH    BX
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    DWORD PTR [DI].TCollection_Error
end;
}

constructor TCollection.Init(ALimit, ADelta: Smallint);
begin
  TObject_TP7.Init; // "TObject" to "TObject_TP7" Chg#77 (02.03.04 P.W)
  Items := nil;
  Count := 0;
  Limit := 0;
  Delta := ADelta;
  SetLimit(ALimit);
end;

constructor TCollection.Load(var S: TStream_TP7); // "TStream" to "TStream_TP7" Chg#145 (02.03.04 P.W)
var
  C, I: Smallint;
begin
  S.Read(Count, SizeOf(Smallint) * 3);
  Items := nil;
  C := Count;
  I := Limit;
  Count := 0;
  Limit := 0;
  SetLimit(I);
  Count := C;
  for I := 0 to C - 1 do AtPut(I, GetItem(S));
end;

destructor TCollection.Done;
begin
  FreeAll;
  SetLimit(0);
end;

function TCollection.At(Index: Smallint): Pointer;
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
begin
  if (Index >= 0) and (Index < Count) then
  begin
    Result := Items[Index];
  end else
  begin
    Result := nil;
    CollectionError(coIndexError);
  end;
end;
{
function TCollection.At(Index: Smallint): Pointer; assembler;
asm
        LES     DI,Pointer(Self) // 22.10.03 P.W LES     DI,Self
        MOV     BX,Index
        OR      BX,BX
        JL      @@1
        CMP     BX,ES:[DI].TCollection.Count
        JGE     @@1
        LES     DI,ES:[DI].TCollection.Items
        SHL     BX,1
        SHL     BX,1
	MOV	AX,ES:[DI+BX]
	MOV	DX,ES:[DI+BX+2]
        JMP     @@2
@@1:    MOV     AX,coIndexError
        CALL    CollectionError
        XOR     AX,AX
        MOV     DX,AX
@@2:
end;
}

procedure TCollection.AtDelete(Index: Smallint);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
begin
  if (Index >= 0) and (Index < Count) then
  begin // delete the item:
    Dec(Count);    // reduce list length by one
    If (Index < Count) then
    begin  // not the last element
           // so we have to move the above elements 1 step down
      // Input List example:
      // 0, 1, 2, 3, 4, 5, 6, 7,  (Count    = 8) Index = 2
      // Dec Count:
      // 0, 1, 2, 3, 4, 5, 6, 7,  (CountRed = 7) Index = 2
      // Move the elements
      //          3, 4, 5, 6, 7,
      //   Move from [Index+1](=3) to [Index](=2)  CountRed(7-2)(=5) Elements
      // List post move:
      // 0, 1, 3, 4, 5, 6, 7,(7,) (Count = 7)

      Move(Items^[Index+1], Items^[Index], (Count-Index) * SizeOf(Pointer));
      // Move (From, To, NumBytes)
    end;
  end else
  begin
    CollectionError(coIndexError);
  end;
end;
{
procedure TCollection.AtDelete(Index: Smallint); assembler;
asm
        LES     DI,Pointer(Self) // 22.10.03 P.W LES     DI,Self
        MOV     BX,Index
        OR      BX,BX
        JL      @@1
        CMP     BX,ES:[DI].TCollection.Count
        JGE     @@1
        DEC     ES:[DI].TCollection.Count
        MOV     CX,ES:[DI].TCollection.Count
        SUB     CX,BX
        JE      @@2
        CLD
        LES     DI,ES:[DI].TCollection.Items
        SHL     BX,1
        SHL     BX,1
        ADD     DI,BX
        LEA     SI,[DI+4]
        SHL     CX,1
        PUSH    DS
        PUSH    ES
        POP     DS
        REP     MOVSW
        POP     DS
        JMP     @@2
@@1:    MOV     AX,coIndexError
        CALL    CollectionError
@@2:
end;
}

procedure TCollection.AtFree(Index: Smallint);
var
  Item: Pointer;
begin
  Item := At(Index);
  AtDelete(Index);
  FreeItem(Item);
end;

procedure TCollection.AtInsert(Index: Smallint; Item: Pointer);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
begin
  if (Index >= 0) and (Index <= Count) then
  begin  // invalid index
    If (Count >= MaxCollectionSize) then
    begin  // too many items
      CollectionError(coOverflow);
    end else
    begin // Insert Item
      if (Count >= Limit) then
      begin // make list longer
        SetLimit(Limit + Delta);
      end;
      // now insert the item:
      If (Index < Count) then
      begin // move the list of pointers to get space
        // example: Index = 2, Count = 5, Limit = 8; u:used, e:empty
        // [0u], [1u], [2u], [3u], [4u], [5e], [6e], [7e],
        //              ^-Index     ^-OCount-1        ^-Limit-1
        // move elements [2u], [3u], [4u] one position higher
        // [0u], [1u], [2n], [32], [43], [54], [6e], [7e],
        //              ^-Index           ^-NCount-1  ^-Limit-1
        Move(Items^[Index], Items^[Index+1], (Count-Index) * SizeOf(Pointer));
      end;
      Items[Index] := Item;
      Inc(Count);
    end;
  end else
  begin
    CollectionError(coIndexError);
  end;
end;
{
procedure TCollection.AtInsert(Index: Smallint; Item: Pointer); assembler;
asm
        LES     DI,Pointer(Self) // 22.10.03 P.W LES     DI,Self
        MOV     BX,Index
        OR      BX,BX
        JL      @@3
        MOV     CX,ES:[DI].TCollection.Count
        CMP     BX,CX
        JG      @@3
        CMP     CX,ES:[DI].TCollection.Limit
        JNE     @@1
        PUSH    CX
        PUSH    BX
        ADD     CX,ES:[DI].TCollection.Delta
        PUSH    CX
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    DWORD PTR [DI].TCollection_SetLimit
        POP     BX
        POP     CX
        LES     DI,Pointer(Self) // 22.10.03 P.W LES     DI,Self
        CMP     CX,ES:[DI].TCollection.Limit
        JE      @@4
@@1:    INC     ES:[DI].TCollection.Count
        STD
        LES     DI,ES:[DI].TCollection.Items
        SHL     CX,1
        ADD     DI,CX
        ADD     DI,CX
        INC     DI
        INC     DI
        SHL     BX,1
        SUB     CX,BX
        JE      @@2
        LEA     SI,[DI-4]
        PUSH    DS
        PUSH    ES
        POP     DS
        REP     MOVSW
        POP     DS
@@2:    MOV     AX,WORD PTR [Item+2]
        STOSW
        MOV     AX,WORD PTR [Item]
        STOSW
        CLD
        JMP     @@6
@@3:    MOV     AX,coIndexError
        JMP     @@5
@@4:    MOV     AX,coOverflow
        MOV     BX,CX
@@5:    CALL    CollectionError
@@6:
end;
}

procedure TCollection.AtPut(Index: Smallint; Item: Pointer);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
begin
  If (Index >= 0) and (Index < Count) then
  begin
    Items[Index] := Item;
  end else
  begin
    CollectionError(coIndexError);
  end;
end;
{
procedure TCollection.AtPut(Index: Smallint; Item: Pointer); assembler;
asm
	MOV	AX,Item.Word[0]
        MOV	DX,Item.Word[2]
        LES     DI,Pointer(Self) // 22.10.03 P.W LES	DI,Self
        MOV     BX,Index
        OR      BX,BX
        JL      @@1
        CMP     BX,ES:[DI].TCollection.Count
        JGE     @@1
        LES     DI,ES:[DI].TCollection.Items
        SHL     BX,1
        SHL     BX,1
        MOV     ES:[DI+BX],AX
        MOV     ES:[DI+BX+2],DX
        JMP     @@2
@@1:    MOV     AX,coIndexError
        CALL    CollectionError
@@2:
end;
}

procedure TCollection.Delete(Item: Pointer);
begin
  AtDelete(IndexOf(Item));
end;

procedure TCollection.DeleteAll;
begin
  Count := 0;
end;

procedure TCollection.Error(Code, Info: Smallint);
begin
  RunError(212 - Code);
end;

procedure TCollection.ForEach(Action: Pointer);
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
type
  TAction = Procedure(Item: Pointer);
var
  indx : Integer;
begin
  for indx := 0 to Count -1 do
    TAction(Action)(At(indx));
end;
{
procedure TCollection.ForEach(Action: Pointer); assembler;
asm
        LES     DI,Pointer(Self) // 22.10.03 P.W LES     DI,Self
        MOV     CX,ES:[DI].TCollection.Count
        JCXZ    @@2
        LES     DI,ES:[DI].TCollection.Items
@@1:    PUSH    ES
        PUSH    DI
        PUSH    CX
        PUSH    WORD PTR ES:[DI+2]
        PUSH    WORD PTR ES:[DI]
//$I F D E F Windows
	MOV	AX,[BP]
	AND	AL,0FEH
	PUSH	AX
//$ELSE
        PUSH    WORD PTR [BP]
//$ENDIF
        CALL    Action
        POP     CX
        POP     DI
        POP     ES
        ADD     DI,4
        LOOP    @@1
@@2:
end;
}

procedure TCollection.Free(Item: Pointer);
begin
  Delete(Item);
  FreeItem(Item);
end;

procedure TCollection.FreeAll;
var
  I: Smallint;
begin
  for I := 0 to Count - 1 do FreeItem(At(I));
  Count := 0;
end;

procedure TCollection.FreeItem(Item: Pointer);
begin
  if Item <> nil then Dispose(PObject_TP7(Item), Done); // "PObject" to "PObject_TP7" Chg#89 (02.03.04 P.W)
end;

function TCollection.GetItem(var S: TStream_TP7): Pointer; // "TStream" to "TStream_TP7" Chg#146 (02.03.04 P.W)
begin
  GetItem := S.Get;
end;

function TCollection.IndexOf(Item: Pointer): Smallint;
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
//
var
  I : Smallint;
begin
  Result := -1;
  For I:= 0 to Count -1 do
  begin
    If (Item = Items[I]) then
    begin
      Result := I;
      Break;
    end;
  end;
end;
{
function TCollection.IndexOf(Item: Pointer): Smallint; assembler;
asm
	MOV	AX,Item.Word[0]
	MOV	DX,Item.Word[2]
        LES     DI,Pointer(Self) // 22.10.03 P.W LES     DI,Self
        MOV     CX,ES:[DI].TCollection.Count
        JCXZ    @@3
        LES     DI,ES:[DI].TCollection.Items
        MOV     BX,DI
        SHL     CX,1
        CLD
@@1:    REPNE   SCASW
        JCXZ    @@3
        TEST    CX,1
        JE      @@1
        XCHG    AX,DX
        SCASW
        XCHG    AX,DX
        LOOPNE  @@1
        JNE     @@3
        MOV     AX,DI
        SUB     AX,BX
        SHR     AX,1
        SHR     AX,1
        DEC     AX
        JMP     @@2
@@3:    MOV     AX,-1
@@2:
end;
}

procedure TCollection.Insert(Item: Pointer);
begin
  AtInsert(Count, Item);
end;

procedure TCollection.PutItem(var S: TStream_TP7; Item: Pointer); // "TStream" to "TStream_TP7" Chg#147 (02.03.04 P.W)
begin
  S.Put(Item);
end;

procedure TCollection.SetLimit(ALimit: Smallint);
var
  AItems: PItemList;
begin
  if ALimit < Count then ALimit := Count;
  if ALimit > MaxCollectionSize then ALimit := MaxCollectionSize;
  if ALimit <> Limit then
  begin
    if ALimit = 0 then AItems := nil else
    begin
      GetMem(AItems, ALimit * SizeOf(Pointer));
      if (Count <> 0) and (Items <> nil) then
        Move(Items^, AItems^, Count * SizeOf(Pointer));
    end;
    if Limit <> 0 then FreeMem(Items, Limit * SizeOf(Pointer));
    Items := AItems;
    Limit := ALimit;
  end;
end;

procedure TCollection.Store(var S: TStream_TP7); // "TStream" to "TStream_TP7" Chg#148 (02.03.04 P.W)

  procedure DoPutItem(P: Pointer); far;
  begin
    PutItem(S, P);
  end;

begin
  S.Write(Count, SizeOf(Smallint) * 3);
  ForEach(@DoPutItem);
end;

{ TSortedCollection }

constructor TSortedCollection.Init(ALimit, ADelta: Smallint);
begin
  TCollection.Init(ALimit, ADelta);
  Duplicates := False;
end;

constructor TSortedCollection.Load(var S: TStream_TP7); // "TStream" to "TStream_TP7" Chg#149 (02.03.04 P.W)
begin
  TCollection.Load(S);
  S.Read(Duplicates, SizeOf(Boolean));
end;

function TSortedCollection.Compare(Key1, Key2: Pointer): Smallint;
begin
  Abstract;
  Result := 0;
end;

function TSortedCollection.IndexOf(Item: Pointer): Smallint;
var
  I: Smallint;
begin
  IndexOf := -1;
  if Search(KeyOf(Item), I) then
  begin
    if Duplicates then
      while (I < Count) and (Item <> Items^[I]) do Inc(I);
    if I < Count then IndexOf := I;
  end;
end;

procedure TSortedCollection.Insert(Item: Pointer);
var
  I: Smallint;
begin
  if not Search(KeyOf(Item), I) or Duplicates then AtInsert(I, Item);
end;

function TSortedCollection.KeyOf(Item: Pointer): Pointer;
begin
  KeyOf := Item;
end;

function TSortedCollection.Search(Key: Pointer; var Index: Smallint): Boolean;
var
  L, H, I, C: Smallint;
begin
  Search := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := Compare(KeyOf(Items^[I]), Key);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Search := True;
        if not Duplicates then L := I;
      end;
    end;
  end;
  Index := L;
end;

procedure TSortedCollection.Store(var S: TStream_TP7); // "TStream" to "TStream_TP7" Chg#150 (02.03.04 P.W)
begin
  TCollection.Store(S);
  S.Write(Duplicates, SizeOf(Boolean));
end;

{ TStringCollection }

function TStringCollection.Compare(Key1, Key2: Pointer): Smallint;
// Convert Turbo to Delphi
// Modifications:
// 20.02.04 P.W
// replaced code see below
// TP7 Help: Returns : -1 if Key1 < Key2; 0 if Key1 = Key2; 1 if Key1 > Key2;
// 23.04.04 P.W
begin
  If Assigned(Key1) and Assigned(Key2) then
  begin
    Result := AnsiCompareText(String(Key1^), String(Key2^));
  end else
    Result := 0;
end;
{
function TStringCollection.Compare(Key1, Key2: Pointer): Smallint; assembler;
asm
        PUSH    DS
        CLD
        LDS     SI,Pointer(Key1)// 22.10.03 P.W LDS     SI,Key1
        LES     DI,Pointer(Key2)// 22.10.03 P.W LES     DI,Key2
        LODSB
        MOV     AH,ES:[DI]
        INC     DI
        MOV     CL,AL
        CMP     CL,AH
        JBE     @@1
        MOV     CL,AH
@@1:    XOR     CH,CH
        REP     CMPSB
        JE      @@2
        MOV     AL,DS:[SI-1]
        MOV     AH,ES:[DI-1]
@@2:    SUB     AL,AH
        SBB     AH,AH
        POP     DS
end;
}

procedure TStringCollection.FreeItem(Item: Pointer);
begin
  DisposeStr(Item);
end;

function TStringCollection.GetItem(var S: TStream_TP7): Pointer; // "TStream" to "TStream_TP7" Chg#151 (02.03.04 P.W)
begin
  GetItem := S.ReadStr;
end;

procedure TStringCollection.PutItem(var S: TStream_TP7; Item: Pointer); // "TStream" to "TStream_TP7" Chg#152 (02.03.04 P.W)
begin
  S.WriteStr(Item);
end;

{ TStrCollection } // Removed

{ TStrListMaker } // Removed

{ TRect Rectangle object }  // Removed

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

{ Objects registration procedure }

var
  RegisterObjectsFlg : Boolean = False;  // 21.06.05 P.W
procedure RegisterObjects;
// modifications:
// 21.06.05 P.W avoid duplicate registration
// (which occured during repeated call of UBnLock.pas procedure BNLOCKMain)
begin
  if RegisterObjectsFlg then EXIT;  // 21.06.05 P.W
  RegisterObjectsFlg := True;
  RegisterType(RCollection);
  RegisterType(RStringCollection);
end;

{ TObject_TP7_1 }

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  RegisterObjectsFlg := False;
  StreamError        := nil;
  StreamTypes        := nil;
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
  InitFinal_Add(Unit_Name, Unit_Init);

end.
