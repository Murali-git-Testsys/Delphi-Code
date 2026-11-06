unit PrintersFpu;
// Created: 06.10.04 P.W
// Purpose: Use Unit Printers but avoid change of FPU Code Word
// which occurs using some printer drivers like HP 5600 series ...
// So replcace all use Printers by PrintersFpu
//   and use instead of TPrinterOrientation TPrinterFpuOrientation
// But also use Graph0.Pas CommonDialog_Execute(DialogXY) instead of
//    DialogXY.Execute
// modifications:
// 12.04.05 P.W: The attempt of printing without a printer
//   did lead to unhandled exceptions
// Solution:
// Define Return values in case of exceptions
// Problem was to detect handled exceptions
// procedures PrnFpuLocFill and PrnFpuLoc_Ok defined to support
// MyGet8087CW together with new PrnExceptionCtr
// the PrnExceptionCtr is necessary to detect handled exceptions
// in nested calls PrnFpuLoc_Ok returns false in such cases to
// allow return meaningful results
// Modifications:
// 04.11.08 P.W: Ensure CurrentDirectory is restored (PrnFpuLoc...)

interface

uses

  DebugUnit,        // 03.05.24 P.W
  InitFinal_List,   // 03.05.24 P.W
  MsgBox,           // 17.06.05 P.W
  DialogsSecure,    // 19.10.05 P.W
  Forms,
  TransX,
  Classes,
  Graphics,
  Printers,
  SysUtils,
  Windows;

const
  Printer = 'Use PrinterFpu!';  // Disable use of Printers.Printer directly

type
  // copy of TPrinterOrientation to avoid use of Printers together with PrintersFpu:
  TPrinterFpuOrientation = (poPortrait, poLandscape, poAutomatic);
    // poAutomatic added: 13.10.08 P.W


  TPrinterFpu = class(TObject)
    // look out: no local properties! (see Title: FTitle in Printer!)
    // we have to use all the variables of Printers.FPrinter
    // because Dialogs.pas .. use Printers.FPrinter and not FPrinterFpu!
  private
    FMultiDocNr: Integer;                        // 06.10.08 P.W
    FMultiDocMode: Boolean;
    FPageNrStartDoc: Integer;                      // 06.10.08 P.W

    function GetNumCopies: Integer;
    procedure SetNumCopies(const Value: Integer);
    function GetOrientation: TPrinterFpuOrientation;
    procedure SetOrientation(const Value: TPrinterFpuOrientation);
    function GetCanvas: TCanvas;
    function GetPageHeight: Integer;
    function GetPageWidth: Integer;
    function GetPageNumber: Integer;
    function GetPrinters: TStrings;
    function GetPrinterIndex: Integer;
    procedure SetPrinterIndex(const Value: Integer);
    function GetHandle: HDC;
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    procedure SetMultiDocMode(const Value: Boolean);
    function GetPageNumberMultiDoc: Integer;
    function GetPrinting: Boolean;  // 06.10.08 P.W
  public
    procedure BeginDoc(const DocTitle: string = '');
    procedure Abort;
    procedure EndDoc;
    procedure NewPage;
    procedure GetPrinter(ADevice, ADriver, APort: PChar; var ADeviceMode: THandle);
    procedure SetPrinter(ADevice, ADriver, APort: PChar; var ADeviceMode: THandle);
    property Canvas: TCanvas read GetCanvas;
    property Copies: Integer read GetNumCopies write SetNumCopies;
    property Handle: HDC read GetHandle;
    property Orientation: TPrinterFpuOrientation read GetOrientation write SetOrientation;
    property PageHeight: Integer read GetPageHeight;
    property PageWidth: Integer read GetPageWidth;
    property PageNumber: Integer read GetPageNumber;
    property PageNumberMultiDoc: Integer read GetPageNumberMultiDoc;  // 06.10.08 P.W
    property PrinterIndex: Integer read GetPrinterIndex write SetPrinterIndex;
    property Printers: TStrings read GetPrinters;
    property Printing: Boolean read GetPrinting;

    property Title: string read GetTitle write SetTitle;//GetSetTitle and not FTitle as in TPrinter!
    property MultiDocNr: Integer read FMultiDocNr;                            // 06.10.08 P.W
    property MultiDocMode: Boolean read FMultiDocMode write SetMultiDocMode;  // 06.10.08 P.W
    property PageNrStartDoc: Integer read FPageNrStartDoc;                    // 06.10.08 P.W

    function  GetDeviceCaps(Index: Integer): Integer;  // additional
  end;

function  PrinterFpu: TPrinterFpu;  // use instead of Printers.Printer 06.10.04 P.W

function SetPrinterFpu(NewPrinterFpu: TPrinterFpu): TPrinterFpu;
function SetPrinterOrg(NewPrinterOrg: TPrinter): TPrinter;
procedure FreePrinterOrgFpu;  // use to avoid win98 next doc comes with black

Implementation
  const Unit_Name = 'PrintersFpu'; // 03.05.24 P.W

var
  FPrinterFpu : TPrinterFpu = nil;
  FPrnDocCtr  : Integer     = 0;

function  PrinterOrg: TPrinter;
// cannot access Printers.Printer inside TPrinterFpu because Printers is a property
begin
  Result := Printers.Printer;
end;

var
  LastExceptionMsg : String = '';
  LastExceptionTim : TDateTime = 0;
  PrnExceptionCtr  : Word      = 0; // detect exceptions in nested calls 12.04.05 P.W

procedure PrnFpuHandleException(E: Exception; P: Integer);
// modifications:
// 12.04.05 P.W support PrnExceptionCtr
begin
  // --- inable detection of exceptions in nested calls:
  Inc(PrnExceptionCtr);  // 12.04.05 P.W

  // --- Message only if different or no message since 5 seconds:
  If (E.Message <> LastExceptionMsg) or
     (3600.0 * 24.0 *(Now - LastExceptionTim) > 5) then
  begin
//    ShowMessageFmt('Printer Error: "%s" (%d)', [E.Message, P]);
//  Use MessageBox1 to avoid use of Dialogs
    MessageBox1(0,
      PChar(AnsiString(Format('Printer Error: "%s" (%d)'+sLineBreak+'%s',
        [TraS(E.Message),
         P,
         TraS('Please install a default printer!')]))),
      nil, MB_OK or MB_ICONERROR+MB_TASKMODAL);
    LastExceptionMsg := E.Message;
    LastExceptionTim := Now;
  end;
end;

function  PrinterFpu: TPrinterFpu;  // overwrite Printers.Printer 06.10.04 P.W
var
  ResultPrinter : TPrinter;
begin
  Result := nil;
  try
    if FPrinterFpu = nil then FPrinterFpu := TPrinterFpu.Create;
    Result := FPrinterFpu;
    ResultPrinter := Printers.Printer;
    if ResultPrinter = nil then;  // nothing only avoid Hint
  except
    on E: Exception do PrnFpuHandleException(E, 1);
  end;
end;

type
  TPrnFpuLoc = record       // 12.04.05 P.W
    FPUControlWord : Word;
    ExceptionCtr   : Word;
    CurrentDir     : AnsiString;  // 04.11.08 P.W
  end;

procedure PrnFpuLocFill(var PFL: TPrnFpuLoc);
// created: 12.04.05 P.W
// purpose support MyGet8087CW together with new PrnExceptionCtr
// to keep code readable
// Modifications:
// 04.11.08 P.W: Store CurrentDirectory! This will be changed when printing to
//   "Microsoft Office Document Image Writer"
begin
  PFL.FPUControlWord := MyGet8087CW;
  PFL.ExceptionCtr   := PrnExceptionCtr;
  PFL.CurrentDir     := GetCurrentDir;
end;

function PrnFpuLoc_Ok(var PFL: TPrnFpuLoc): Boolean;
// created: 12.04.05 P.W
// purpose support MySet8087CW together with new PrnExceptionCtr
// to keep code readable
// Retruns True if now new exception occured
// Modifications:
// 04.11.08 P.W: Ensure CurrentDirectory is PFL.CurrentDir
begin
  MySet8087CW(PFL.FPUControlWord);
  Result := (PFL.ExceptionCtr = PrnExceptionCtr); // Ok if no new exception
  If PFL.CurrentDir <> GetCurrentDir then    // 04.11.08 P.W
    SetCurrentDir(PFL.CurrentDir);
end;

procedure TPrinterFpu.Abort;
var
  PFL: TPrnFpuLoc;
begin
  PrnFpuLocFill(PFL);
  try
    PrinterOrg.Abort;
  except
    on E: Exception do PrnFpuHandleException(E, 3);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

procedure TPrinterFpu.BeginDoc(const DocTitle: string = '');
// may change Printer Fpu Control Word!
// may change CurrentDirectory (Print to "Microsoft Office Document Image Writer")
var
  PFL: TPrnFpuLoc;
begin
  Inc(FMultiDocNr);                           // 06.10.08 P.W
  if  MultiDocMode and (MultiDocNr > 1) then  // 06.10.08 P.W
  begin
    FPageNrStartDoc := PageNumberMultiDoc;
    NewPage;
    Exit;
  end else
  begin
    FPageNrStartDoc := 0;
  end;

  PrnFpuLocFill(PFL);
  try
    Inc(FPrnDocCtr);
    if DocTitle <> '' then
    begin
      PrinterOrg.Title := DocTitle;
    end else
    begin
      if PrinterOrg.Title = '' then
        PrinterOrg.Title := 'Stratec XCT '+Application.MainForm.Caption +' ';
    end;
    PrinterOrg.Title := PrinterOrg.Title + ' ' + DateTimeToStr(Now) + Format(' #%d', [FPrnDocCtr]);
    PrinterOrg.BeginDoc;
  except
    on E: Exception do PrnFpuHandleException(E, 2);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

procedure TPrinterFpu.EndDoc;
var
  PFL: TPrnFpuLoc;
begin
  if MultiDocMode then  // 06.10.08 P.W
  begin
    {  // when you want to limit the document size:
    if PageNumberMultiDoc >= 100 then
    begin
      MultiDocMode := False;   // Calls EndDoc!
      MultiDocMode := True;
    end;
    }
    EXIT; 
  end;
  FMultiDocNr := 0;          // 06.10.08 P.W
  PrnFpuLocFill(PFL);
  try
    PrinterOrg.EndDoc;
    PrinterOrg.Title := '';
  except
    on E: Exception do PrnFpuHandleException(E, 3);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

procedure TPrinterFpu.NewPage;
var
  PFL: TPrnFpuLoc;
begin
  PrnFpuLocFill(PFL);
  try
    PrinterOrg.NewPage;
  except
    on E: Exception do PrnFpuHandleException(E, 3);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

function TPrinterFpu.GetCanvas: TCanvas;
var
  PFL: TPrnFpuLoc;
begin
  Result := nil;
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.Canvas; // PrinterOrg and Canvas are ever defined!
  except
    on E: Exception do PrnFpuHandleException(E, 4);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

function TPrinterFpu.GetDeviceCaps(Index: Integer): Integer;
// modifications:
// 12.04.05 P.W: Return -1 in case of exception
var
  PFL: TPrnFpuLoc;
begin
  Result := -1;
  PrnFpuLocFill(PFL);
  try
    Result := Windows.GetDeviceCaps(PrinterFpu.Handle, Index);
  except
    on E: Exception do PrnFpuHandleException(E, 5);
  end;
  If not PrnFpuLoc_Ok(PFL) then Result := -1;
end;

function TPrinterFpu.GetHandle: HDC;
var
  PFL: TPrnFpuLoc;
begin
  Result := 0;
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.Handle;
  except
    on E: Exception do PrnFpuHandleException(E, 6);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

function TPrinterFpu.GetNumCopies: Integer;
// modifications:
// 12.04.05 P.W: Return 1 in case of exception
var
  PFL: TPrnFpuLoc;
begin
  Result := 0;
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.Copies;
  except
    on E: Exception do PrnFpuHandleException(E, 7);
  end;
  If not PrnFpuLoc_Ok(PFL) then Result := 1;
end;

function TPrinterFpu.GetOrientation: TPrinterFpuOrientation;
// modifications:
// 12.04.05 P.W: define return value in case of exception
var
  PFL: TPrnFpuLoc;
begin
  Result := poPortrait;
  PrnFpuLocFill(PFL);
  try
    Result := TPrinterFpuOrientation(PrinterOrg.Orientation);
  except
    on E: Exception do PrnFpuHandleException(E, 8);
  end;
  If not PrnFpuLoc_Ok(PFL) then Result := poPortrait;
end;

function TPrinterFpu.GetPageHeight: Integer;
// modifications:
// 12.04.05 P.W: define return value in case of exception
var
  PFL: TPrnFpuLoc;
begin
  Result := 0;
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.PageHeight;
  except
    on E: Exception do PrnFpuHandleException(E, 9);
  end;
  If not PrnFpuLoc_Ok(PFL) then Result := 1200;
end;

function TPrinterFpu.GetPageWidth: Integer;
// modifications:
// 12.04.05 P.W: define return value in case of exception
var
  PFL: TPrnFpuLoc;
begin
  Result := 0;
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.PageWidth;
  except
    on E: Exception do PrnFpuHandleException(E, 10);
  end;
  If not PrnFpuLoc_Ok(PFL) then Result := 800;
end;

function TPrinterFpu.GetPageNumberMultiDoc: Integer;
// modifications:
// 12.04.05 P.W: define return value in case of exception
// 06.10.08 P.W renamed from former GetPageNnumber
var
  PFL: TPrnFpuLoc;
begin
  Result := 0;
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.PageNumber;
  except
    on E: Exception do PrnFpuHandleException(E, 101);
  end;
  If not PrnFpuLoc_Ok(PFL) then Result := 1;
end;

function TPrinterFpu.GetPrinting: Boolean;
var
  PFL: TPrnFpuLoc;
begin
  Result := False;
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.Printing;
  except
    on E: Exception do PrnFpuHandleException(E, 102);
  end;
  If not PrnFpuLoc_Ok(PFL) then Result := False;
end;

function TPrinterFpu.GetPageNumber: Integer;
// modifications:
// 12.04.05 P.W: define return value in case of exception
// 06.10.08 P.W: support PageNrStartDoc for comaptibility in MultiDocMode
//   returns the PageNr of the current document
begin
  Result := PageNumberMultiDoc - PageNrStartDoc;
end;

procedure TPrinterFpu.GetPrinter(ADevice, ADriver, APort: PChar;
  var ADeviceMode: THandle);
// modifications:
// 12.04.05 P.W: define return values in case of exception
var
  PFL: TPrnFpuLoc;
begin
  PrnFpuLocFill(PFL);
  try
    PrinterOrg.GetPrinter(ADevice, ADriver, APort, ADeviceMode);
  except
    on E: Exception do PrnFpuHandleException(E, 11);
  end;
  If not PrnFpuLoc_Ok(PFL) then
  begin               // 12.04.05 P.W
    ADevice := '';
    ADriver := '';
    APort   := '';    
    ADeviceMode := 0;
  end;
end;

procedure TPrinterFpu.SetPrinter(ADevice, ADriver, APort: PChar;
  var ADeviceMode: THandle);
// modifications:
// 12.04.05 P.W: define return values in case of exception
var
  PFL: TPrnFpuLoc;
begin
  PrnFpuLocFill(PFL);
  try
    PrinterOrg.SetPrinter(ADevice, ADriver, APort, ADeviceMode);
  except
    on E: Exception do PrnFpuHandleException(E, 11);
  end;
  If not PrnFpuLoc_Ok(PFL) then
  begin               // 12.04.05 P.W
    ADevice := '';
    ADriver := '';
    APort   := '';
    ADeviceMode := 0;
  end;
end;

function TPrinterFpu.GetPrinterIndex: Integer;
// modifications
// 12.04.05 P.W: in case of no default printer found return a negative result
var
  PFL: TPrnFpuLoc;
begin
  Result := -1;
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.PrinterIndex;
  except
    on E: Exception do PrnFpuHandleException(E, 12);
  end;
  If not PrnFpuLoc_Ok(PFL) then Result := -1;
end;

function TPrinterFpu.GetPrinters: TStrings;
var
  PFL: TPrnFpuLoc;
begin
  Result := nil;
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.Printers;
  except
    on E: Exception do PrnFpuHandleException(E, 13);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

function TPrinterFpu.GetTitle: string;
var
  PFL: TPrnFpuLoc;
begin
  PrnFpuLocFill(PFL);
  try
    Result := PrinterOrg.Title;
  except
    on E: Exception do PrnFpuHandleException(E, 14);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

procedure TPrinterFpu.SetNumCopies(const Value: Integer);
var
  PFL: TPrnFpuLoc;
begin
  PrnFpuLocFill(PFL);
  try
    PrinterOrg.Copies := Value;
  except
    on E: Exception do PrnFpuHandleException(E, 15);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

procedure TPrinterFpu.SetOrientation(const Value: TPrinterFpuOrientation);
var
  PFL: TPrnFpuLoc;
begin
  PrnFpuLocFill(PFL);
  try
    PrinterOrg.Orientation := TPrinterOrientation(Value);
  except
    on E: Exception do PrnFpuHandleException(E, 16);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

procedure TPrinterFpu.SetPrinterIndex(const Value: Integer);
var
  PFL: TPrnFpuLoc;
begin
  PrnFpuLocFill(PFL);
  try
    PrinterOrg.PrinterIndex := Value;
  except
    on E: Exception do PrnFpuHandleException(E, 17);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

procedure TPrinterFpu.SetTitle(const Value: string);
var
  PFL: TPrnFpuLoc;
begin
  PrnFpuLocFill(PFL);
  try
    PrinterOrg.Title:= Value;
  except
    on E: Exception do PrnFpuHandleException(E, 18);
  end;
  If not PrnFpuLoc_Ok(PFL) then ;
end;

function SetPrinterOrg(NewPrinterOrg: TPrinter): TPrinter;
begin
  Result := nil;
  try
    Result := Printers.SetPrinter(NewPrinterOrg);
  except
    on E: Exception do PrnFpuHandleException(E, 19);
  end;
end;

function SetPrinterFpu(NewPrinterFpu: TPrinterFpu): TPrinterFpu;
begin
  Result := nil;
  try
    Result := FPrinterFpu;
    FPrinterFpu := NewPrinterFpu;
  except
    on E: Exception do PrnFpuHandleException(E, 20);
  end;
end;

procedure FreePrinterOrgFpu;
var
  OrgPrinter : TPrinter;
begin
  try
    OrgPrinter := SetPrinterOrg(nil);  // returns Printers.FPrinter and sets it to nil
    FreeAndNil(OrgPrinter);
    FreeAndNil(FPrinterFpu);
  except
    on E: Exception do PrnFpuHandleException(E, 21);
  end;
end;

procedure TPrinterFpu.SetMultiDocMode(const Value: Boolean);
// 06.10.08 P.W
begin
  if Value = FMultiDocMode then EXIT;

  if Value then
  begin
    FMultiDocNr     := 0;
    FPageNrStartDoc := 0;
    FMultiDocMode := True;
  end else
  begin
    FMultiDocMode := False;
    if MultiDocNr > 0 then
      EndDoc;
  end;
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  FPrinterFpu := nil;
  FPrnDocCtr  := 0;
  LastExceptionMsg := '';
  LastExceptionTim := 0;
//Printer = 'Use PrinterFpu!';
  PrnExceptionCtr  := 0;
  Deb1(Unit_Name + '1');
end;

function Unit_Init(aMode: Integer=0): Integer;
// Finalization part  into  function // 03.05.24 P.W
begin
  InitVars_Dll; // 03.05.24 P.W
  Result := 0;
end;

function Unit_Final(aMode: Integer=0): Integer;
// Finalization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  try
    FreeAndNil(FPrinterFpu);
  except
    on E: Exception do PrnFpuHandleException(E, 22);
  end;
end;

initialization
  InitFinal_Add(Unit_Name, Unit_Init, Unit_Final);

finalization
(* -v--- moved to function Unit_Final // 03.05.24 P.W
  try
    FreeAndNil(FPrinterFpu);
  except
    on E: Exception do PrnFpuHandleException(E, 22);
  end;
   -^--- moved to function Unit_Final // 03.05.24 P.W *)
end.
