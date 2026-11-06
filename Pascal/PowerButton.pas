unit PowerButton;

///////////////////////////////////////////////////////////////////////////////////////
//Dies ist eine Komponente um den Powerknopf anzusteuern.
//Eigenschaften:
//PowerOffEnable:boolean
//  >false lässt den Pc nicht mehr herunterfahren
//Ereignisse:
//  OnPowerbuttonpress
//  >Wird ausgeführt wenn der Powerbutton gedrückt wurde
//
//Programmed by CTV => www.ctvnet.ch
//
//Komponente darf frei für alles verwendet werden copyright darf nicht entfernt werden
///////////////////////////////////////////////////////////////////////////////////////

// from http://www.delphipraxis.net/topic17958_tpowerbutton.html at 26.01.05 P.W
// a) for the case "PPowerOffEnable = false":
// works with the correction: Result of MessageHook is TRUE
// b) used or not Delphi leads to an exception when recovering from standby:
//   invalid access by the timers!
// Changes: Code reduced to what is needed;  P.W
// Modifications:
// 02.11.09 P.W support SetThreadExecutionState (required for Vista)

interface

uses
  DebugUnit,        // 03.05.24 P.W
  InitFinal_List,   // 03.05.24 P.W
  Windows, Messages, SysUtils, Classes, Forms;

type

  TPowerButton = class(TComponent)
  private
    FHooked: Boolean;
    PPowerOffEnable:Boolean;
    DenyValue : Integer; // P.W
    function MessageHook(var Msg: TMessage): Boolean;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property PowerOffEnable : boolean read PPowerOffEnable write PPowerOffEnable;

  end;

procedure PowerOffDisable;  // 27.01.05 P.W
procedure PowerOffEnable;   // 27.01.05 P.W

Implementation
  const Unit_Name = 'PowerButton'; // 03.05.24 P.W

var
  FPowerButton : TPowerButton = nil;    // 27.01.05 P.W

const
  ES_SYSTEM_REQUIRED  =    $00000001;   // 02.11.09 P.W
  ES_DISPLAY_REQUIRED =    $00000002;   // 02.11.09 P.W
  ES_CONTINUOUS       =    $80000000;   // 02.11.09 P.W

// ! "Vista, an application must call SetThreadExecutionState"   // 02.11.09 P.W
// EXECUTION_STATE WINAPI SetThreadExecutionState(
//   __in  EXECUTION_STATE esFlags
// );

function SetThreadExecutionState(const ModeFlags: DWORD): DWORD; // 02.11.09 P.W
  stdcall  external kernel32 name 'SetThreadExecutionState';


procedure PowerOffDisable;  // 27.01.05 P.W
begin
  if not Assigned(FPowerButton) then
  begin
    FPowerButton := TPowerButton.Create(Application.MainForm);
    FPowerButton.PowerOffEnable := False;
    if Win32Platform >= VER_PLATFORM_WIN32_NT then               // 02.11.09 P.W
      SetThreadExecutionState(ES_SYSTEM_REQUIRED + ES_CONTINUOUS);
  end;
end;

procedure PowerOffEnable;   // 27.01.05 P.W
begin
  if Assigned(FPowerButton) then
  begin
    FPowerButton.PowerOffEnable := True;
    if Win32Platform >= VER_PLATFORM_WIN32_NT then               // 02.11.09 P.W
      SetThreadExecutionState(ES_CONTINUOUS);
  end;
end;

constructor TPowerButton.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  if Win32Platform >= VER_PLATFORM_WIN32_NT  // P.W
    then DenyValue := BROADCAST_QUERY_DENY   // winNT,2k,XP
    else DenyValue := PWR_FAIL;              // Win 95/98
//  Version:='1.0.0.0';
//  Hersteller:='CTVNet.ch';
  FHooked := False;
  if not (csDesigning in ComponentState) then
  begin
    Application.HookMainWindow(MessageHook);
    FHooked := True;
  end;
end;

function TPowerButton.MessageHook(var Msg: TMessage): Boolean;
begin
  Result := False; // message not processed! 26.01.05 P.W
  if (msg.msg=WM_POWERBROADCAST) and (msg.WParam=0) then
  begin
    if PPowerOffEnable = False then
    begin
      msg.Result := DenyValue; // BROADCAST_QUERY_DENY;
      Result := True; // message  processed (avoids others to allow power down)! 26.01.05 P.W
//ShowMessage('Power Off denied!')
    end;
  end;
end;

destructor TPowerButton.Destroy;
begin
  if FHooked then Application.UnhookMainWindow(MessageHook);
  inherited Destroy;
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  FPowerButton := nil;    // 27.01.05 P.W

//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Initialization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
end;
function Unit_Final(aMode: Integer=0): Integer;
// Finalization part  into  function // 03.05.24 P.W
begin
  Result := 0;
  FreeAndNil(FPowerButton);
end;
initialization
  InitFinal_Add(Unit_Name, Unit_Init, Unit_Final);

finalization
(* -v--- moved to function Unit_Final // 03.05.24 P.W
  FreeAndNil(FPowerButton);
   -^--- moved to function Unit_Final // 03.05.24 P.W *)

end. 
