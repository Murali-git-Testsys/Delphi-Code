unit ClientViewXctImagesUnit;
// compare ServerViewXctImagesUnit (used by ServerViewXctImages.dpr)
// created: 02.02.07 P.W
// Aim: support show images during measurement:
//  Backprojection uses Unit ClientViewXctImagesUnit to inform Server that a file is ready
//   use ExecuteMacro_ImageReady

interface
// Urgent (when you want to use ConnectMode = ddeAutomatic from designer)
//  Properties of "DdeClientConv_ViewXctImages" must be restored manually when
//     ConnectMode is ddeAutomatic (lost when project changes and or Delphi restarted)
//  1) set ConnectMode to ddeManual
//  2) set DdeService  to "ServerViewXctImages"         <<- must match to ServerViewXctImagesUnit;
//  3) set DdeTopic    to "DdeServerConv_ViewXctImages" <<- must match to ServerViewXctImagesUnit;
//  4) Launch Meas/ServerViewXctImages.exe
//  5) set ConnectMode to ddeAutomatic
//
// But inbetween we use ConnectMode ddeManual in designer and ddeAutomatic programatically
//  by btnConnectClick which assures correct time to addExitProc ExitProc_TerminateServer.
// but programatically the values are used from the designer properties!!!
uses
  //MsgBox,
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  ViewXctServerClientGlb, GlbType,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  DdeMan, StdCtrls;


type
  TfrmClientViewXctImages = class(TForm)
    DdeClientConv_ViewXctImages: TDdeClientConv;
    DdeClientItem_ViewXctImages: TDdeClientItem;
    btnConnect: TButton;
    btnDisconnect: TButton;
    btnTerminateServer: TButton;
    btnLaunchServer: TButton;
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnTerminateServerClick(Sender: TObject);
    procedure btnLaunchServerClick(Sender: TObject);
  private
    ViewScreenHeight : Integer;
    function ExecuteMacro(M: AnsiString): Boolean;
  public
    function ExecuteMacro_ImageReady(fName: AnsiString; ScreenHeight:Integer=0): Boolean;
  end;

procedure ServerMsg(const aFormat: AnsiString; const Args: array of const);


var
  frmClientViewXctImages: TfrmClientViewXctImages;

Implementation
  const Unit_Name = 'ClientViewXctImagesUnit'; // 03.05.24 P.W

{$R *.dfm}

procedure ServerMsg(const aFormat: AnsiString; const Args: array of const);
// 07.02.07 P.W
var
  msg : AnsiString;
begin
  if Assigned(frmClientViewXctImages) then
  begin
    try
      msg := Format(aFormat, Args);
    except
      msg := aFormat + ' //invalid arguments';
    end;
    try
      frmClientViewXctImages.ExecuteMacro(Format(MacroStrgs[ME_Message]+';%s', [msg]));
    except
    end;  
  end;
end;

procedure ExitProc_TerminateServer;
begin
//  MessageBoxT1(0,'TerminateServer?','',0,5000);
  if Assigned(frmClientViewXctImages) and Assigned(ddeMgr) then
  begin
    if frmClientViewXctImages.DdeClientConv_ViewXctImages.Conv <> 0 then
      frmClientViewXctImages.btnTerminateServerClick(frmClientViewXctImages);
    FreeAndNil(frmClientViewXctImages);
//    MessageBoxT1(0,'TerminateServer!','',0,5000);
  end;
end;

var
  ExitProc_TerminateServer_Added : Boolean = False;

procedure CheckAdd_ExitProc_TerminateServer;
begin
  if not ExitProc_TerminateServer_Added then
  begin
    ExitProc_TerminateServer_Added := True;
    AddExitProc(ExitProc_TerminateServer);
  end;
end;

procedure TfrmClientViewXctImages.btnConnectClick(Sender: TObject);
var
  FGW : HWND;
begin
  FGW := GetForegroundWindow;

  btnLaunchServerClick(Sender);  // to avoid problems with windows buttons
  CheckAdd_ExitProc_TerminateServer;
  DdeClientConv_ViewXctImages.ConnectMode := ddeManual;
  DdeClientConv_ViewXctImages.DdeService  := 'ServerViewXctImages';           // does nothing!
  DdeClientConv_ViewXctImages.DdeTopic    := 'DdeServerConv_ViewXctImages';   // does nothing!
  DdeClientConv_ViewXctImages.ConnectMode := ddeAutomatic;                    // opens the connection


  ExecuteMacro(Format(MacroStrgs[ME_ClientProcId]+';%d', [GetCurrentProcessId]));
  if Assigned(Application) and Assigned(Application.MainForm) then
  begin
    ExecuteMacro(Format('ClientHwnd;%d', [Application.MainForm.Handle]));
  end;
  if ViewScreenHeight = 0 then
    ViewScreenHeight := round (Screen.WorkAreaHeight / 6);
  ExecuteMacro(Format(MacroStrgs[ME_Position]+';%d;%d;%d;%d;%d',
    [Screen.WorkAreaLeft, Screen.WorkAreaTop, Screen.WorkAreaWidth, ViewScreenHeight,
    0]));   // 1: StayOnTop

  ExecuteMacro(Format(MacroStrgs[ME_ForeGroundHwnd]+';%d', [FGW]));

  // for ddeManual
  // DdeClientConv_ViewXctImages.SetLink('ServerViewXctImages','DdeServerConv_ViewXctImages');
end;

function TfrmClientViewXctImages.ExecuteMacro(M: AnsiString): Boolean;
begin
  if DdeClientConv_ViewXctImages.Conv = 0 then
  begin
    btnConnectClick(Self);
  end;
  Result := DdeClientConv_ViewXctImages.ExecuteMacro(PChar(M), False);
end;

function TfrmClientViewXctImages.ExecuteMacro_ImageReady(fName: AnsiString; ScreenHeight:Integer=0): Boolean;
begin
//EXIT;
//ShowMessage('ImageReady');
  if (ScreenHeight > 0) then
    ViewScreenHeight := ScreenHeight;
  Result := ExecuteMacro(MacroStrgs[ME_ViewXctImage]+';'+FName);
end;

procedure TfrmClientViewXctImages.btnDisconnectClick(Sender: TObject);
begin
  DdeClientConv_ViewXctImages.CloseLink;
end;

procedure TfrmClientViewXctImages.btnTerminateServerClick(Sender: TObject);
begin
  ExecuteMacro(MacroStrgs[ME_TerminateServer]+';');
end;

procedure TfrmClientViewXctImages.btnLaunchServerClick(Sender: TObject);
begin
// launched by WinExec(<Name>, SW_SHOWMINNOACTIVE) makes problems: Minimize does not work before
//   Restore has been clicked manually
//  WinExec('ServerViewXctImages DdeServerConv_ViewXctImages', SW_SHOWMINNOACTIVE);

  WinExec('ServerViewXctImages DdeServerConv_ViewXctImages', SW_NORMAL); // SW_SHOWMINNOACTIVE);

end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  ExitProc_TerminateServer_Added := False;
  frmClientViewXctImages := nil;
//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
//frmClientViewXctImages := TfrmClientViewXctImages.Create(nil);  // when called from dll: crashes later! (uses DdeMan)
  {$IFDEF DLL}
  {$ELSE}
  frmClientViewXctImages := TfrmClientViewXctImages.Create(nil);  // when called from dll: crashes later!
  {$ENDIF}
//  AddExitProc(ExitProc_TerminateServer); // is here too early (must come after App.Run!)
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
//  frmClientViewXctImages := TfrmClientViewXctImages.Create(nil);  // when called from dll: crashes later!
  {$IFDEF DLL}
  {$ELSE}
  frmClientViewXctImages := TfrmClientViewXctImages.Create(nil);  // when called from dll: crashes later!
  {$ENDIF}
//  AddExitProc(ExitProc_TerminateServer); // is here too early (must come after App.Run!)
  DebInit2('ClientViewXctImagesUnit');
   -^--- moved to function Unit_Init // 03.05.24 P.W *)

finalization
(***
  // ddeMgr belongs to Application and has already been terminated (is nil)!
  // and onClose has not been fired!
  // REASON: Forms.Pas TApplication.Run with AddExitProc(DoneApplication) is called
  // after initialization of this unit and so DoneApplication comes before finalization
  // or our ExitProc_TerminateServer
  if Assigned(frmClientViewXctImages) and Assigned(ddeMgr) then
  begin
    if frmClientViewXctImages.DdeClientConv_ViewXctImages.Conv <> 0 then
      frmClientViewXctImages.btnTerminateServerClick(frmClientViewXctImages);
    FreeAndNil(frmClientViewXctImages);
  end;

  Solution:  btnConnectClick calls CheckAdd_ExitProc_TerminateServer;

Info to Reason:
  Unit DdeMan.pas contains:
initialization
  ddeMgr := TDdeMgr.Create(Application);   // <-- belongs to App and is destroyed by DoneApplication
  ...
finalization
  FreeAndNil(ddeMgr);     // when Delphi comes to here ddeMgr is already nil!


  Unit Forms.pas contains
procedure TApplication.Run;
begin
  FRunning := True;
  try
    AddExitProc(DoneApplication);      // late after ClientViewXctImagesUnit initializes!
  ...

--------------------------------
--------------------------------
***)

end.

