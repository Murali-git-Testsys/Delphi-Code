unit FemurPcForm1;
//====================================================
// 04.10.04 P.W: around savePictureDialog keep CurrentDir
//====================================================
// 04.10.04 P.W : Program termination : CanClose Query sets CanClose to false
// and inserts "Alt-X" into programs keybuffer (FemurPcForm1.Pas)
//====================================================
// Global Rules:
//  Use
//   a) PrintersFpu instead of Printers
//   b) MessageBox1 instead of MessageBox
//   c) function CommonDialog_Execute to enshure
//      - XCTDIR is ever the current directory (relative pathes used)
//      - FpuControlWord is not changed
//   d) under Win98 from batch launch Win32 Apps (GUI) over StartWin98.exe
//       to avoid not waiting until termination
//====================================================


// Modifications:
// 28.07.06 P.W
//  SaveScreenPatFolder1 added to MainMenu1
// 02.08.06 P.W support ALT-Letter Keys by function KeyDelphiToTp7
// 20.12.06 P.W use SliceNrNamePartMask and ImageNameMask
// 02.02.07 P.W for AS_MeasMod reserve ScreenArea for ServerViewXctImages
// 17.03.08 P.W "Window1" as MenuItem for AS_Analyse to open Forms like XCT View Screens again
// 30.10.08 P.W use UtIni function BoolFromString
// 02.11.09 P.W Avoid close by "Update Windows requires restart" WMClose added
//    and FormCloseQuery adapted (Measmodule ever;
//    XctDirector only when AS_XctDirector_DisableClose is true)
//----------------------

interface

uses
  HaltUnit,
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  Param_StrUnit,
//  FemErr2,                  // 29.11.05 P.W
// DebugForm,
  UtIni,                      // 30.10.08 P.W
  ComNames,                   // 20.12.06 P.W
  ClientViewXctImagesUnit,    // 07.02.07 P.W
  DialogsSecure,              // 19.10.05 P.W
  UBnLockWin,                 // 26.08.05 P.W
  DosTimer,                   // 19.07.05 P.W
  ReadPar,                    // 27.06.05 P.W
  Accessibility,              // 22.06.05 P.W
  MsgBox, XctVersion,         // 17.06.05 P.W
  FemGlb, IniFiles, GlbPath,  // 10.06.05 P.W for save options
  UMsgDelay,
  Translate,
  TransX, //GlbFt,
  GlbType,                    // 01.04.05 P.W for AsciiExpSep and FixSem
  KeyState,                   // 14.03.05 P.W for Win 98
  PowerButton,
  WM_AddMessages,
  WinTools,
  Math,
  jpeg,
  PrintersFpu, // Printers -> PrintersFpu : 06.10.04 P.W
  GraphGlb,
  Graph0,
  UseDelphi,
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Draw,
  Crt, MPlayer, ComCtrls, ExtDlgs, Menus, ActnList, Spin, SpinEdit2;

var
  AS_XctDirector_DisableClose : Boolean = False;  // 02.11.09 P.W

type
  TNotifyEvent_Allowed = function(Sender: TObject): Boolean of object; // 04.04.08 P.W

  TNotifyConnect = record // 04.04.08 P.W
    Event   : TNotifyEvent;
    Allowed : TNotifyEvent_Allowed;
    Msg     : String;
  end;


  TfrmMain = class(TForm)
    Panel1: TPanel;
    imgMain: TImage;
    ScrollBox1: TScrollBox;
    MainMenu1: TMainMenu;
    Analyse1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Roi1: TMenuItem;
    SelectNextRoi1: TMenuItem;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    Screentofile1: TMenuItem;
    N3: TMenuItem;
    SaveScreen1: TMenuItem;
    ViewScreens1: TMenuItem;
    NewRoi1: TMenuItem;
    ViewTranslationDatabase1: TMenuItem;
    BrowseImages1: TMenuItem;
    InvertBlackWhite1: TMenuItem;
    ReducedPrintRes1: TMenuItem;
    BrowseImagesWorkDir1: TMenuItem;
    BrowseImagesA1: TMenuItem;
    BrowseImagesB1: TMenuItem;
    BrowseImagesC1: TMenuItem;
    BrowseImagesD1: TMenuItem;
    BrowseImagesE1: TMenuItem;
    BrowseImagesF1: TMenuItem;
    BrowseImagesG1: TMenuItem;
    BrowseImagesH1: TMenuItem;
    N6: TMenuItem;
    PrintScreenCtrlPrint1: TMenuItem;
    N4: TMenuItem;
    PrintResolutionLow1: TMenuItem;
    PrintResolutionMid1: TMenuItem;
    PrintResolutionHigh1: TMenuItem;
    PrintResolutionPrn1: TMenuItem;
    PaintDebug1: TMenuItem;
    PreviousSlice1: TMenuItem;
    NextSlice1: TMenuItem;
    ScreenSaver1: TMenuItem;
    PrintResolutionPrn111: TMenuItem;
    Options1: TMenuItem;
    Timer1: TTimer;
    PrintDialog1: TPrintDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    SavePictureDialog1: TSavePictureDialog;
    mdplyMeasurement: TMediaPlayer;
    TimerMeasMode: TTimer;
    MarkCommProt1: TMenuItem;
    SaveScreenPatFolder1: TMenuItem;
    Window1: TMenuItem;
    N5: TMenuItem;
    ClearAllResults1: TMenuItem;
    AutoRoi1: TMenuItem;
    N7: TMenuItem;
    StartMacro1: TMenuItem;
    AnalysisTable1: TMenuItem;
    N8: TMenuItem;
    ClearAutoRoiMacro1: TMenuItem;
    JobMacro1: TMenuItem;
    TerminateJob1: TMenuItem;
    TimerLvAn: TTimer;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure About1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SelectNextRoi1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure PrintSetup1Click(Sender: TObject);
    procedure Screentofile1Click(Sender: TObject);
    procedure SaveScreen1Click(Sender: TObject);
    procedure NewRoi1Click(Sender: TObject);
    procedure ViewTranslationDatabase1Click(Sender: TObject);
    procedure imgMainDblClick(Sender: TObject);
    procedure imgMainClick(Sender: TObject);
    procedure imgMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgMainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgMainMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure InvertBlackWhite1Click(Sender: TObject);
    procedure BrowseImages2Click(Sender: TObject);
    procedure BrowseImagesC1Click(Sender: TObject);
    procedure BrowseImagesA1Click(Sender: TObject);
    procedure BrowseImagesB1Click(Sender: TObject);
    procedure BrowseImagesD1Click(Sender: TObject);
    procedure BrowseImagesE1Click(Sender: TObject);
    procedure BrowseImagesF1Click(Sender: TObject);
    procedure BrowseImagesG1Click(Sender: TObject);
    procedure BrowseImagesH1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PrintScreenCtrlPrint1Click(Sender: TObject);
    procedure PrintResolutionPrn1Click(Sender: TObject);
    procedure PrintResolutionLow1Click(Sender: TObject);
    procedure PrintResolutionMid1Click(Sender: TObject);
    procedure PrintResolutionHigh1Click(Sender: TObject);
    procedure ViewAsciiPrint1Click(Sender: TObject);
    procedure PaintDebug1Click(Sender: TObject);
    procedure PreviousSlice1Click(Sender: TObject);
    procedure NextSlice1Click(Sender: TObject);
    procedure ScreenSaver1Click(Sender: TObject);
    procedure PrintResolutionPrn111Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure TimerMeasModeTimer(Sender: TObject);
    procedure ViewScreens1Click(Sender: TObject);
    procedure MarkCommProt1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SaveScreenPatFolder1Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure Window1Click(Sender: TObject);
    procedure ClearAllResults1Click(Sender: TObject);
    procedure AutoRoi1Click(Sender: TObject);
    procedure StartMacro1Click(Sender: TObject);
    procedure AnalysisTable1Click(Sender: TObject);
    procedure Analyse1Click(Sender: TObject);
    procedure ClearAutoRoiMacro1Click(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure TerminateJob1Click(Sender: TObject);
    procedure TimerLvAnTimer(Sender: TObject);
  private
    MaximizeDelaySec : Double;
    ModalTmr : TDosTimer;
    LastSaveScreenFile : String;   // 25.03.08 P.W
    procedure Window1Show(Sender: TObject);
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure AppActivate(Sender: TObject);
    function ChkTerminated: Boolean;
    procedure PrintScreenDialog;
    procedure BrowseImagesLbxClick(Sender: TObject);
    procedure BrowseImagesLbxDblClick_ImgSlices(Sender: TObject);
    procedure BrowseImagesLbxDblClick_All(Sender: TObject);
    procedure BrowseImagesDrive(Drive: Char);
    procedure StartBrowse(SearchDir: String);
    procedure CheckedPrnRes;
    procedure AppModalBegin(Sender: TObject);
    procedure AppModalEnd(Sender: TObject);
    procedure UpdateWindow1Items;
    procedure WMClose(var Message: TWMClose); message WM_CLOSE;  // 02.11.09 P.W

  public
    ModalFlg            : Boolean;         // 19.07.05 P.W
    FOnClearAllResults   : TNotifyConnect;  // 04.04.08 P.W
    FOnAutoRoi           : TNotifyConnect;  // 04.04.08 P.W
    FOnStartMacro1       : TNotifyConnect;  // 04.04.08 P.W
    FOnClearAutoRoiMacro : TNotifyConnect;  // 04.04.08 P.W
    FOnAnalysisTable1    : TNotifyConnect;  // 04.04.08 P.W
    procedure ViewScreens(StartDirFile: AnsiString);
  end;

procedure CRT_KeyBuf_AddEsc;
function  MarkCommProt: String;

var
  frmMain       : TfrmMain = nil;

type
  TTp7Key = packed Record
    Case Integer of
    0: (ChNorm : Char; // = #0 if DOS function key // KC1_xx
        ChFunc : Char);                            // KC2_xx
    1: (wChar : Word);
  end;

Procedure Halt_Save(Code: Integer);
function KeyDelphiToTp7(Key: Word; Shift: TShiftState): TTp7Key;

type
  TDebAppProcMsg = class   // only use: force refresh screen during debugging
  // Debug :
  //  Add GlbDebAppProcMsg.Ctr to Watch List and have Watch List visible
  //  Stepping through the code then forces call of GetCtr which updates the screen ...
  private
    FCtr: Integer;
    procedure SetCtr(const Value: Integer);
    function GetCtr: Integer;
  public
    property Ctr : Integer read GetCtr write SetCtr;
  end;

var
  GlbDebAppProcMsg : TDebAppProcMsg = nil;  // for debugging

Implementation

uses
  TurboToDelphi,
// FormTranslate, TranslateData,
  KeyCodes, FrmXCTAbout, ViewScreens, PrintForm;
  const Unit_Name = 'FemurPcForm1'; // 03.05.24 P.W

{$R *.dfm}

{ TDebAppProcMsg }


function  MarkCommProt: String;
// 29.11.05 P.W
var
  Msg : String;
begin
  Inc(CommProtMarkCtr);
  Result := Format('Mark Comm. Prot. (%d) F11', [CommProtMarkCtr]);
  Msg := Format('@ ========== Mark Communication Protocol (%d) ========== %s',
                [CommProtMarkCtr, DateTimeToStr(Now)]);
  ShowMessageMs(Msg, 1000);              
  ProtV24Msg(Msg);
end;

function TDebAppProcMsg.GetCtr: Integer;
begin
  Application.ProcessMessages;  // refreshes screen ...
  Result := FCtr;
end;

procedure TDebAppProcMsg.SetCtr(const Value: Integer);
begin
  FCtr := Value;
end;

Procedure Halt_Save(Code: Integer);
// 15.10.04 P.W. avoid access violation of simple Halt
// (Violation occured in SvComp.pas where file not found did lead to use of Halt(1))
begin
  frmMain.Free;     // does not crash when nil!
  frmMain := nil;   // otherwise DelphiCrt ModOut may crash
  H_alt(Code, 'Halt_Save');
end;

function KeyDelphiToTp7(Key: Word; Shift: TShiftState): TTp7Key;
// compare with Menus.pas function ShortCutToText
// ShortCuts of MainMenu1 are handled before!
// Modifications:
// 02.08.06 P.W: support ALT-Letter Keys (especially ALT-P for macro pause)
type
  TShiftMode  = (sm_None, sm_Alt, sm_Ctrl, sm_Shift); // under DOS no combination used
  Tsm_CodeArr = Array[TShiftMode] of Char;
const
  KC2_A0 = #0;  // not used or defined
  KC2_C0 = #0;  // not used or defined
  KC2_S0 = #0;  // not used or defined
                            // sm_None,   sm_Alt,  sm_Ctrl,    sm_Shift
  sm_KC2_F1   : Tsm_CodeArr = (KC2_F1,    KC2_AF1, KC2_CF1,    KC2_SF1);
  sm_KC2_PgUp : Tsm_CodeArr = (KC2_PgUp,  KC2_A0,  KC2_CPgUp,  KC2_S0 );
  sm_KC2_PgDn : Tsm_CodeArr = (KC2_PgDwn, KC2_A0,  KC2_CPgDwn, KC2_S0 );
  sm_KC2_End  : Tsm_CodeArr = (KC2_End,   KC2_A0,  KC2_CEnd,   KC2_S0 );
  sm_KC2_Home : Tsm_CodeArr = (KC2_Pos1,  KC2_A0,  KC2_CPos1,  KC2_S0 );
  sm_KC2_Left : Tsm_CodeArr = (KC2_Left,  KC2_A0,  KC2_CLeft,  KC2_S0 );
  sm_KC2_Up   : Tsm_CodeArr = (KC2_Up,    KC2_A0,  KC2_C0,     KC2_S0 );
  sm_KC2_Right: Tsm_CodeArr = (KC2_Right, KC2_A0,  KC2_CRight, KC2_S0 );
  sm_KC2_Down : Tsm_CodeArr = (KC2_Dwn,   KC2_A0,  KC2_C0,     KC2_S0 );
  sm_KC2_Ins  : Tsm_CodeArr = (KC2_Ins,   KC2_A0,  KC2_C0,     KC2_S0 );
  sm_KC2_Del  : Tsm_CodeArr = (KC2_Del,   KC2_A0,  KC2_C0,     KC2_S0 );
//    $20..$28: // Space, PgUp, PgDn, End, Home, Left, Up, Right, Down
//    $2D..$2E: // Ins, Del
var
  SMode : TShiftMode;
  KeyLo : Byte;
begin
  Result.ChNorm := #0;
  Result.ChFunc := #0;

  if (ssAlt   in Shift) then
    SMode := sm_Alt     else
  if (ssCtrl  in Shift) then
    SMode := sm_Ctrl    else
  if (ssShift in Shift) then
    SMode := sm_Shift
  else
    SMode := sm_None;

  KeyLo := WordRec(Key).Lo;

  if SMode = sm_Alt then
  begin // support ALT-Letter Keys 02.08.06 P.W
    Case KeyLo of    // compare GetMovit.pas Function GetMovitFunc
      Ord('Q') : Result.ChFunc := #$10; // AQ  {Alt - Q      }
      Ord('W') : Result.ChFunc := #$11; // AW  {Alt - W      }
      Ord('E') : Result.ChFunc := #$12; // AE  {Alt - E      }
      Ord('R') : Result.ChFunc := #$13; // AR  {Alt - R      }
      Ord('T') : Result.ChFunc := #$14; // AT  {Alt - T      }
      Ord('Y') : Result.ChFunc := #$15; // AY  {Alt - Y      }
      Ord('U') : Result.ChFunc := #$16; // AU  {Alt - U      }
      Ord('I') : Result.ChFunc := #$17; // AI  {Alt - I      }
      Ord('O') : Result.ChFunc := #$18; // AO  {Alt - O      }
      Ord('P') : Result.ChFunc := #$19; // AP  {Alt - P      } // not reached handled by Short cut of MainMenu1

      Ord('A') : Result.ChFunc := #$1E; // AA  {Alt - A      }
      Ord('S') : Result.ChFunc := #$1F; // AS_ {Alt - S      }
      Ord('D') : Result.ChFunc := #$20; // AD  {Alt - D      }
      Ord('F') : Result.ChFunc := #$21; // AF  {Alt - F      }
      Ord('G') : Result.ChFunc := #$22; // AG  {Alt - G      }
      Ord('H') : Result.ChFunc := #$23; // AH  {Alt - H      }
      Ord('J') : Result.ChFunc := #$24; // AJ  {Alt - J      }
      Ord('K') : Result.ChFunc := #$25; // AK  {Alt - K      }
      Ord('L') : Result.ChFunc := #$26; // AL  {Alt - L      }

      Ord('Z') : Result.ChFunc := #$2C; // AZ  {Alt - Z      }
      Ord('X') : Result.ChFunc := #$2D; // AX  {Alt - X      } // not reached handled by Short cut of MainMenu1
      Ord('C') : Result.ChFunc := #$2F; // AC  {Alt - C      }
      Ord('V') : Result.ChFunc := #$2F; // AV  {Alt - V      }
      Ord('B') : Result.ChFunc := #$30; // AB  {Alt - B      }
      Ord('N') : Result.ChFunc := #$31; // AN  {Alt - N      }
      Ord('M') : Result.ChFunc := #$32; // AM  {Alt - M      }
    end;
  end;

  case KeyLo of
    $08: Result.ChNorm := KC1_BS;
    $09: Result.ChNorm := KC1_Tab; // not reached! handled by TfrmMain.AppMessage
    $0D: Result.ChNorm := KC1_Cr;
    $1B: Result.ChNorm := KC1_Esc;
//    $20..$28: // Space, PgUp, PgDn, End, Home, Left, Up, Right, Down
//    $20: Result.ChNorm := ' ';        // Space
    $21: Result.ChFunc := sm_KC2_PgUp [SMode];
    $22: Result.ChFunc := sm_KC2_PgDn [SMode];
    $23: Result.ChFunc := sm_KC2_End  [SMode];
    $24: Result.ChFunc := sm_KC2_Home [SMode];
    $25: Result.ChFunc := sm_KC2_Left [SMode];
    $26: Result.ChFunc := sm_KC2_Up   [SMode];
    $27: Result.ChFunc := sm_KC2_Right[SMode];
    $28: Result.ChFunc := sm_KC2_Down [SMode];
//    $2D..$2E: // Ins, Del
    $2D: Result.ChFunc := sm_KC2_Ins  [SMode];
    $2E: Result.ChFunc := sm_KC2_Del  [SMode];

//    $30..$39: Result.ChNorm := Chr(KeyLo - $30 + Ord('0')); // 0 .. 9
//    $41..$5A: Result.ChNorm := Chr(KeyLo - $41 + Ord('A')); // "A" .. "Z"
//    $60..$69: Result.ChNorm := Chr(KeyLo - $60 + Ord('0')); // 0 .. 9
    $70..$87:  // F1... F24
      Result.ChFunc := Char(KeyLo - $70 + Ord(sm_KC2_F1[SMode]));
  end;

end;

procedure CRT_KeyBuf_AddEsc;
begin
  CRT_KeyBuf_AddKey(KC1_Esc);
end;

procedure CRT_KeyBuf_AddAltX;
begin  // insert Alt-X for "DOS-Crt"
  CRT_KeyBuf_AddEsc;  // some dialogs need Escape and do not support Alt-X

  CRT_KeyBuf_AddKey(#00);
  CRT_KeyBuf_AddKey(#45);  // Alt-X = #45
end;

procedure CRT_KeyBuf_AddTab;
begin
  CRT_KeyBuf_AddKey(#9);
end;

procedure CRT_KeyBuf_AddEnter;
begin
  CRT_KeyBuf_AddKey(KC1_Cr);
end;

procedure CRT_KeyBuf_AddRight;
begin
  CRT_KeyBuf_AddKey(#0);
  CRT_KeyBuf_AddKey(KC2_Right);
end;

procedure CRT_KeyBuf_AddLeft;
begin
  CRT_KeyBuf_AddKey(#0);
  CRT_KeyBuf_AddKey(KC2_Left);
end;

procedure Tp7KeyToCrtKeyBuf(Tp7Key : TTP7Key);
begin
  If (Tp7Key.wChar <> 0) then
  begin
    CRT_KeyBuf_AddKey(Tp7Key.ChNorm);
    If (Tp7Key.ChFunc <> #0) then
    CRT_KeyBuf_AddKey(Tp7Key.ChFunc);
  end;
end;

function TfrmMain.ChkTerminated: Boolean;
begin
  Result := Application.Terminated;
  if Result then // WM_QUIT not supported as message
  CRT_KeyBuf_AddAltX;
end;

procedure TfrmMain.AppMessage(var Msg: TMsg; var Handled: Boolean);
// AppMessage, FormKeyDown and FormKeyPress work together.
// AppMessage handles TabStop 
const
  SC_LShift = $2A;  // ScanCode of Left  Shift Key
  SC_RShift = $36;  // ScanCode of Right Shift Key
  CH_ShiftLR= #16;
type
  TlParam_KeyDown = packed record
    case Integer of
    0: (A, B, C, D: Byte);
    1: (RepeatCount: Word; ScanCode : Byte; State: Byte);
  end;
var
  Ch : Char;
//  dwPowerEvent : DWORD;
begin
//  Deb0('TfrmMain.AppMessage 0');
  case Msg.message of
    WM_KeyDown:
      begin    // only Upcase of chars received
  Deb0('TfrmMain.AppMessage WM_KeyDown 1');
        Ch := char(LongRec(Msg.wParam).Bytes[0]);
        Case Ch of
          #9 :                     // not seen by FormKeyDown
            CRT_KeyBuf_AddTab;
          CH_ShiftLR:
            begin  // ShiftKeys status for Win98
              Case TLParam_KeyDown(Msg.lParam).ScanCode of
                SC_LShift: GlbLeftShiftPressed := True; // for use by KeyState for Win 98
                SC_RShift: GlbRightShiftPressed := True;
              end
            end;
        end;
        Handled := False;
      end;
    WM_KeyUp:
      begin
  Deb0('TfrmMain.AppMessage WM_KeyUp 2');
        Ch := char(LongRec(Msg.wParam).Bytes[0]);
        Case Ch of
          CH_ShiftLR:
            begin  // ShiftKeys status for Win98
              Case TLParam_KeyDown(Msg.lParam).ScanCode of
                SC_LShift: GlbLeftShiftPressed := False;
                SC_RShift: GlbRightShiftPressed := False;
              end
            end;
        end;
      end;
    WM_ForceToFront:
      begin
  Deb0('TfrmMain.AppMessage WM_ForceToFront 3');
        ForceBringToFront;     // if "Undeclared identifier.." use BUILD!
        Handled := True;
      end;
    else
      begin
      end;
  end;
//  Deb0('TfrmMain.AppMessage x-');
(* not here! handling is more complex see unit PowerButton
   else
  if Msg.message = WM_POWERBROADCAST then  // 26.01.05 P.W
  begin
//    ShowMessage('WM_PowerBroadCast received'); // not reached!
    if AppStratec = AS_MeasMod then
    begin
      dwPowerEvent := DWORD(Msg.wParam);
//      case  dwPowerEvent of
//        PBT_APMQUERYSUSPEND:
          begin
//            TMessage(Msg).        := BROADCAST_QUERY_DENY;  // deny power down
          end;
//      end;
    end;
    Handled := True;
  end;
*)

  { for all other messages, Handled remains False }
  { so that other message handlers can respond }
end;

procedure TfrmMain.AppActivate(Sender: TObject);
begin
//  ShowMessage('Application.Activate');
//  BringToFront; // hopefully activates the last active frame; (does not help)
// Tip: try Screen.ActiveForm ....
end;

procedure TfrmMain.AppModalBegin(Sender: TObject);
// 19.07.05 P.W
begin
  ModalFlg := True;
  StartDosTimer(ModalTmr);
end;

procedure TfrmMain.AppModalEnd(Sender: TObject);
// 19.07.05 P.W
begin
  ModalFlg := False;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
// AppMessage, FormKeyDown and FormKeyPress work together.
// AppMessage before FormKeyDown before FormKeyPress
// 1) AppMessage handles TabStop which is not seen by the others
// 2) FormKeyDown gets only the keycode no difference for lowercase
//    handles Left, Right, CR, Esc, BackSpace, Function Keys ...
// 3) FormKeyPress handles A, B, ... a, b, .. (receives translated Codes)
//    does not receive Function Keys and Left Right Buttons
begin
  Deb0('TfrmMain.FormKeyDown 0');
  Case Key of
    VK_F11 : MarkCommProt1Click(Sender); // 29.11.05 P.W
    else
    Tp7KeyToCrtKeyBuf(KeyDelphiToTp7(Key, Shift));
  end;
  Key := 0;   // despite of set zero FormKeyPress receives characters (A..Z, a..z)!
  Shift := [];
  Deb0('TfrmMain.FormKeyDown 1-');
end;

procedure TfrmMain.FormKeyPress(Sender: TObject; var Key: Char);
// AppMessage, FormKeyDown and FormKeyPress work together.
// FormKeyPress sees characters case sensitive but no Function keys!
//const
//  SetOfAllowedChars : Set of Char = [' ' .. #255];
//    ['-', '.', '+', '*', '_', ' ',
//     ':', '\', '!', '?', '/', '"', '|', '@',
//     '0'..'9', 'a'..'z', 'A'..'Z'
//     'ä', 'ö', 'ü', 'Ä', 'Ö', 'Ü'];

begin
  Deb0('TfrmMain.FormKeyPress 0');
  if (Key >= ' ') then
  begin
    CRT_KeyBuf_AddKey(Key);
  end;

  Key := #0;
  Deb0('TfrmMain.FormKeyPress 1-');
end;

procedure TfrmMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Deb0('TfrmMain.FormKeyUp 0');
  Key := 0;
  Shift := [];
  Deb0('TfrmMain.FormKeyUp 1-');
end;

function AllowOtherProgs: Boolean;
// 17.06.05
begin
  Result := FileExists(GlbInitDir+'MeasAllowOtherProgs.txt');
end;

procedure CheckOS;
// 30.08.05 P.W
// Disable Windows 98
begin
  if not  (Win32Platform >= VER_PLATFORM_WIN32_NT) then
  begin
    ShowMessage('Invalid Operating System! Windows XP needed!');
    H_alt(1, 'CheckOS');
  end;
end;

procedure ChkScreenPos(frm: TForm);  // 05.09.05 P.W
  procedure OptionsFromLocalIniFile;
  // 05.09.05 P.W
  // compare also UReadSet.pas function GlbReadSetUp
    function FalseTrue(B: Boolean): String;
    begin
      if B then Result := 'True'
           else Result := 'False';
    end;
    function ReadBoolFT(MIni: TMemIniFile; const Section, Ident: String; Default: Boolean): Boolean;
    begin
      // Result := Pos('T', Uppercase(Mini.ReadString(Section, Ident, FalseTrue(Default)))) > 0; // u. 30.10.08 P.W
      Result := BoolFromString(Mini.ReadString(Section, Ident, FalseTrue(Default)));             // s. 30.10.08 P.W
    end;
  var
    MIni : TMemIniFile;
  begin
    try
      MIni := TMemIniFile.Create(LocIniFile);
      MIni.CaseSensitive := False;
      ScreenPosFixed  := ReadBoolFT(Mini, 'SCREEN', 'PosFixed', False);
      ScreenPosLeft   := MIni.ReadInteger('SCREEN', 'Left',     0);
      ScreenPosTop    := MIni.ReadInteger('SCREEN', 'Top',      0);
      ScreenPosWidth  := MIni.ReadInteger('SCREEN', 'Width',    0);
      ScreenPosHeight := MIni.ReadInteger('SCREEN', 'Height',   0);
    finally
      FreeAndNil(MIni);
    end;
  end;
const
  ViewScreenHeightRatio = 1/6;   // 02.02.07 P.W
var
  ViewScreenHeight : Integer;    // 02.02.07 P.W
begin
  OptionsFromLocalIniFile;  // Local.ini is not read by all applications!
  if (ScreenPosWidth <= 0) or (ScreenPosHeight <= 0) then
  begin
    ScreenPosFixed := False;
  end;
  
  if (AppStratec = AS_MeasMod) and (1000 = 1000) and (Param_Str(3) = 'CT') then   // 02.02.07 P.W
  begin  // reserve area for ServerViewXctImages
    if not ScreenPosFixed then
    begin
      ScreenPosFixed  := True;
      ScreenPosLeft   := Screen.WorkAreaLeft;
      ScreenPosTop    := Screen.WorkAreaTop;
      ScreenPosWidth  := Screen.WorkAreaWidth;
      ScreenPosHeight := Screen.WorkAreaHeight;
    end;

    ViewScreenHeight:= round (ViewScreenHeightRatio * Screen.WorkAreaHeight);
    ScreenPosTop    := Max(ScreenPosTop,    Screen.WorkAreaTop    + ViewScreenHeight);
    ScreenPosHeight := Min(ScreenPosHeight, Screen.WorkAreaHeight - ViewScreenHeight);
Deb0('FemurPcForm1.pas pre frmClientViewXctImages.ExecuteMacro_ImageReady 0');
    frmClientViewXctImages.ExecuteMacro_ImageReady('', ViewScreenHeight);  // launch Empty Image Viewer
Deb0('FemurPcForm1.pas post frmClientViewXctImages.ExecuteMacro_ImageReady 1');

  end;

  if ScreenPosFixed then
  begin
    frm.WindowState := wsNormal;
    frm.Left   := ScreenPosLeft;
    frm.Top    := ScreenPosTop;
    frm.Width  := ScreenPosWidth;
    frm.Height := ScreenPosHeight;
  end else
  begin
    frm.WindowState := wsMaximized;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
// modifications:
// 26.08.05 P.W for AS_Analyse and AS_MeasMod call UBnLockWin.pas procedure
// ChkBnLockList
// 13.12.07 P.W: added CtNumber in titlebar (Meas, SvComp, Analysis)
// 02.11.09 P.W use PowerOffDisable also for AS_XctDirector
var
  GrMaxX, GrMaxY : Integer;
  S : String;
  Idx : Integer;
begin
  CheckOS;  // 30.08.05 P.W
  TraXM(MainMenu1);  // replaces TraX(xxx) xxx = all TMenuItems // 01.08.06 P.W
  CheckedPrnRes;
  Application.OnModalBegin  := AppModalBegin; // 19.07.05 P.W
  Application.OnModalEnd    := AppModalEnd;   // 19.07.05 P.W
  Application.OnMessage     := AppMessage;
  Application.OnActivate    := AppActivate;
  KeyPreview := True; // allows OnKeyDown even if a control has focus
                      // but shortcuts are not seen!

  // v============== CAPTION ==================
  Caption := ExtractFileName(Param_Str(0));


  // --- AppStratec from name: (moved to Initialization of GlbType via procedure InitAppStratec at 07.01.08 P.W)
  {
  if      (Pos('KNMULTI', UpperCase(Caption)) > 0)
  then AppStratec := AS_Analyse
  else if (Pos('FEMURPC', UpperCase(Caption)) > 0)
  then AppStratec := AS_MeasMod
  else if (Pos('XBJOB', UpperCase(Caption)) > 0)
  then AppStratec := AS_XbJob
  else if (Pos('SVCOMP', UpperCase(Caption)) > 0)
  then AppStratec :=   AS_SvComp
  else if (Pos('CTFEM', UpperCase(Caption)) > 0)
  then AppStratec :=   AS_BackPro
  else if (Pos('XTRACT', UpperCase(Caption)) > 0)
  then AppStratec :=   AS_Xtract
  else if (Pos('XCTDIRECTOR', UpperCase(Caption)) > 0)
  then AppStratec :=   AS_XctDirector
  else if (Pos('BNLOCK', UpperCase(Caption)) > 0)
  then AppStratec :=   AS_BnLock
  ;
  }

  Case AppStratec of
    AS_Analyse : Caption := TraS('XCT Analysis');
    AS_MeasMod :
      begin
        Caption := TraS('XCT Measurement');
        PowerOffDisable;      // 27.01.05 P.W
      end;
    AS_XbJob   : Caption := TraS('XCT XbJob');
    AS_SvComp  : Caption := TraS('XCT SV Comparison');
    AS_Xtract  : Caption := TraS('XCT Ascii Export');
    AS_XctDirector:
      begin
        Caption := TraS('XCT Diagnostic Tools') +
                        ' - '+GlbDevSnr.DbHeaderPlus;    // Glb...: 22.11.05 P.W
        PowerOffDisable;      // 02.11.09 P.W
      end;
    else Caption := TraS(Caption);
  end;

  // --- Version message and XctDir
  Caption := XctVersionMsg + ' - ' + Caption
                 + ' ('+ ETPD(XctDir) + ')';  // ETPD(XctDir) 08.10.07 P.W

  // --- mark for folder test
  if TestPathFlg then
    Caption := 'Test - ' + Caption;

  // --- append Collimation info   // 19.12.07 P.W
  if (AppStratec = AS_MeasMod) and (GlbDevSnr.DbHeaderPlus <> '') then
    Caption := Caption + ' - ' + GlbDevSnr.DbHeaderPlus;

  // --- append file name without extension to caption // 13.12.07 P.W
  S := '';
  case AppStratec of
    AS_MeasMod: if ShowSvFlgGlb
                  then S := GlbXbJobHeadRec.SvFile
                  else S := GlbXbJobHeadRec.CtFile;
    AS_SvComp:  S := GlbXbJobHeadRec.SvFile;
  end;
  if S <> '' then
    Caption := Caption + ' - ' + ChangeFileExt(ExtractFileName(S), '');

  // --- append patient name
  if (AppStratec in [AS_MeasMod, AS_SvComp{, AS_Analyse}]) then  // no longer for analysis 20.12.07 P.W
  begin  // 27.06.05 P.W
      // for AS_MeasMod add the name only in special cases:
    if (AppStratec <> AS_MeasMod) or // if : 19.10.05 P.W
       (Pos('INTER\TPATPOS.CMD' , UpperCase(Param_Str(1))) > 0) or // 22.11.05 P.W: ".CMd" to ".CMD"
       (Param_Str(3) = 'SV') or
       (Param_Str(3) = 'CT') then

    Caption := Caption + ' - ' +
      GlbXbJobHeadRec.FirstName + ', ' +
      GlbXbJobHeadRec.Name;
  end;
  // ^============== CAPTION ==================

  // --- MarkCommProt1: --- // 01.08.06 P.W only for Measmodule and XctDirector
  Case AppStratec of
    AS_MeasMod,
    AS_XctDirector:
      begin
        MarkCommProt1.Visible := True;
        // MarkCommProt1.Enabled set by TfrmMain.FormActivate
      end;
    else
      begin
        MarkCommProt1.Visible := False;
        MarkCommProt1.Enabled := False;
PaintDebug1.Visible := True;   // 15.05.24 P.W
//PaintDebug1Click(self);        // 15.05.24 P.W   // slows down drawing !!!  // ##DEBUG!
      end;
  end;

  // --- MaximizeDelaySec: ---
  Case AppStratec of
    AS_Analyse    : MaximizeDelaySec := 0.0;
    AS_MeasMod    : MaximizeDelaySec := 0.0;
    AS_SvComp     : MaximizeDelaySec := 0.0;
    AS_BnLock     : MaximizeDelaySec := 0.1;
    AS_XctDirector:
      begin
                    MaximizeDelaySec := -1;  // negativ to disable
                    Position := poScreenCenter;
      end;
    else            MaximizeDelaySec := 2.0;
  end;

  LaunchedByKnMulti := // 25.10.04 P.W.    // call of SvComp in UtKnApp.pas ShowSvStudy
    (AppStratec = AS_SvComp) and
    (Pos('SVSHOW', UpperCase(Param_Str(2)))>0);

  if not LaunchedByKnMulti then   // if: 25.10.04 P.W.
    ActivateDelphi(Self.Handle);  // 10.09.04 P.W needs StartXctCon.exe

  if (AppStratec = AS_Analyse) then
  begin
    Analyse1.Enabled := True;
    Window1.Visible := True;
    JobMacro1.Visible := FileExists(TempXmenuJobName);
  end else
  begin
    {   // u.: 09.07.08 P.W:
    Analyse1.Enabled := True;
    Analyse1.Caption := TraS('Measurement');
    Roi1.Caption := TraS('Hotkeys ...');
    SelectNextRoi1.Caption := TraS('TAB');
    }
    // s.: 09.07.08 P.W:    (allows use of F3 again for Diagnse Scan (TestStand in Scans.pas))
    Idx := MainMenu1.Items.IndexOf(Analyse1);
    if Idx >= 0 then
      MainMenu1.Items.Delete(Idx);
//    if SelectNextRoi1 = Analyse1 then;
    Idx := MainMenu1.Items.IndexOf(JobMacro1);          // 10.12.09 P.W
    if Idx >= 0 then
      MainMenu1.Items.Delete(Idx);
  end;

//  SaveScreenPatFolder1.Enabled := PatNrFolderPossible;  // 28.07.06 P.W here to early!


  if (Abs(MaximizeDelaySec) > 0.001) then
  begin
    Application.ShowMainForm := False;
    Visible := False;
  end;

  if AppStratec = AS_XctDirector then
  begin
    WindowState := wsNormal;
    ScreenPosFixed := False;  // 05.09.05 P.W
  end else
  begin
    WindowState := wsMaximized;
  end;

  imgMain.Top  := 0;
  imgMain.Left := 0;


  ChkScreenPos(Self);  // 05.09.05 P.W
  if ScreenPosFixed then
  begin                // 05.09.05 P.W
    GrMaxX := 2+ ScreenPosWidth  - (Self.Width  - Self.ClientWidth)  -8;
    GrMaxY := 2+ ScreenPosHeight - (Self.Height - Self.ClientHeight) -8 ;
  end else
  begin
    GrMaxX := 2+ Screen.WorkAreaWidth  - (Self.Width  - Self.ClientWidth);
    GrMaxY := 2+ Screen.WorkAreaHeight - (Self.Height - Self.ClientHeight);
  end;

  Graph0_Init(frmMain.imgMain, True, GrMaxX, GrMaxY);// uses size of imgMain!

  if (AppStratec = AS_MeasMod) then
  begin
    Menu := Nil;
    //TimerMeasMode.Enabled := True; // 17.06.05 P.W Keep Measurement application in foreground
    TimerMeasMode.Enabled := not AllowOtherProgs;
  end;

  if (AppStratec in [AS_MeasMod, AS_XctDirector]) then
  begin
    SetAccessKeys(False);  // avoid problems with shift keys
  end;

  if (AppStratec in [AS_MeasMod, AS_Analyse]) then
  begin  // 26.08.05 P.W
    if not ChkBnLockList(T_Manu) then
    begin
//      ShowMessage('Password is invald, program will be aborted!');
      H_alt(1, 'TfrmMain.FormCreate');
    end;
  end;

end;

procedure TfrmMain.About1Click(Sender: TObject);
begin
  ShowAppAbout;
end;

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

function  NotyfyEnabled(Sender: TObject; NFC: TNotifyConnect): Boolean;
// 04.04.08 P.W
begin
  Result := Assigned(NFC.Event) and ((not Assigned(NFC.Allowed )) or NFC.Allowed(Sender));
end;

function  NotyfyCall(Sender: TObject; NFC: TNotifyConnect): Boolean;
// 04.04.08 P.W
begin
  Result :=  NotyfyEnabled(Sender, NFC);
  if Result then
    NFC.Event(Sender);
end;

procedure TfrmMain.Analyse1Click(Sender: TObject);
// 04.04.08 P.W
var
  OldEnabled : Boolean;
begin
  // Check enable older menuitems:
  OldEnabled := NotyfyEnabled(Sender, FOnAutoRoi);
  Roi1.                  Enabled := OldEnabled;
  PreviousSlice1.        Enabled := OldEnabled;
  NextSlice1.            Enabled := OldEnabled;

  // Check enable menuitems added at 04.04.08 P.W:
  ClearAllResults1.      Enabled := NotyfyEnabled(Sender, FOnClearAllResults);
  AutoRoi1.              Enabled := NotyfyEnabled(Sender, FOnAutoRoi);
  StartMacro1.           Enabled := NotyfyEnabled(Sender, FOnStartMacro1);
  ClearAutoRoiMacro1.    Enabled := NotyfyEnabled(Sender, FOnClearAutoRoiMacro);
  AnalysisTable1.        Enabled := NotyfyEnabled(Sender, FOnAnalysisTable1);

  StartMacro1.Caption := TraS('Start Macro') + ' "'+FOnStartMacro1.Msg+ '"';
end;

procedure TfrmMain.SelectNextRoi1Click(Sender: TObject);
begin
  CRT_KeyBuf_AddTab;
end;

procedure TfrmMain.NewRoi1Click(Sender: TObject);
begin
  CRT_KeyBuf_AddKey(#0);
  CRT_KeyBuf_AddKey(KC2_F3);
  CRT_KeyBuf_AddKey(KC1_CR);
end;

procedure TfrmMain.PreviousSlice1Click(Sender: TObject);
begin
  CRT_KeyBuf_AddKey(#0);
  CRT_KeyBuf_AddKey(KC2_PgUp);
end;

procedure TfrmMain.NextSlice1Click(Sender: TObject);
begin
  CRT_KeyBuf_AddKey(#0);
  CRT_KeyBuf_AddKey(KC2_PgDwn);
end;

procedure TfrmMain.ClearAllResults1Click(Sender: TObject);
// 04.04.08 P.W
begin
//  CRT_KeyBuf_AddKey(#0);
//  CRT_KeyBuf_AddKey(KC2_CF10);
  NotyfyCall(Sender, FOnClearAllResults);
end;

procedure TfrmMain.AutoRoi1Click(Sender: TObject);
// 04.04.08 P.W
begin
//  CRT_KeyBuf_AddKey(#0);
//  CRT_KeyBuf_AddKey(KC2_CF4);
  NotyfyCall(Sender, FOnAutoRoi);
end;

procedure TfrmMain.StartMacro1Click(Sender: TObject);
// 04.04.08 P.W
begin
  NotyfyCall(Sender, FOnStartMacro1);
end;

procedure TfrmMain.ClearAutoRoiMacro1Click(Sender: TObject);
// 04.04.08 P.W
begin
  {
  ClearAllResults1Click(Sender);
  Application.ProcessMessages;
  AutomaticSearchofROI1Click(Sender);
  Application.ProcessMessages;
  StartMacro1Click(Sender);
  }
  NotyfyCall(Sender, FOnClearAutoRoiMacro);
end;

procedure TfrmMain.AnalysisTable1Click(Sender: TObject);
// 04.04.08 P.W
// used by UtKnApp0.pas TKnApp.Notyfy_Analysis_Table
begin
  NotyfyCall(Sender, FOnAnalysisTable1);
end;


procedure TfrmMain.imgMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  WantRightLeftKey : Integer {= -1};
  RightKeyFlg : Boolean {= True};
  I : Integer;
begin
  Deb0('TfrmMain.imgMainMouseDown Button: %d, Shift: ?, X: %d, Y: %d',[Ord(Button), X, Y]);
  UseDelphiMouseDown(Button, Shift, X, Y);
  SetMouseClickFlg; // 22.01.07 P.W

//  ShowMessageFmt('imgMainMouseDown(%d,%d)', [X, Y]);
  WantRightLeftKey := GetNumRightLeftKeys(X,Y, RightKeyFlg);
  
  if WantRightLeftKey >= 0 then  // since 23.09.04 here and no longer by Timer1
   // 23.09.04 P.W since in
   // TMenuApp.Pas the call of EmptyKeyBuf is disabled in Procedure TMenApp.Run
   // the Keys are directly added in TfrmMain.imgMainMouseDown and not in Timer1Timer
   // for the timing was not save on slow computers, some keys had been deleted by
   // the EmptyKeyBuf call
  begin
    for I := 1 to WantRightLeftKey do
    begin
      if RightKeyFlg
      then CRT_KeyBuf_AddRight
      else CRT_KeyBuf_AddLeft;
    end;
    CRT_KeyBuf_AddEnter;
  end;
end;

procedure TfrmMain.imgMainMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  UseDelphiMouseMove(Shift, X, Y);
  CheckPaneClickMove(X, Y);
end;

procedure TfrmMain.imgMainMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  UseDelphiMouseUp(Button, Shift, X, Y);
  CheckPaneMouseUp(X,Y);
end;

procedure TfrmMain.imgMainClick(Sender: TObject);
// 26.07.04 P.W
begin
//  ShowMessage('imgMainClick');
end;

procedure TfrmMain.imgMainDblClick(Sender: TObject);
// 26.07.04 P.W
// For UtParam.pas Procedure TGenParams.SetThreshold
begin
  SetPaneDblClick;
end;

procedure TfrmMain.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
// 19.06.09 P.W
var
  NumDelta : Integer;
  VK_Wanted : Word;
  Shift_Wanted : TShiftState;
  Procedure SelectKey(KeyNeg, KeyPos: Word; Dir: Integer; Shift_Wtd: TShiftState = []);
  begin
    if Dir * NumDelta < 0
      then VK_Wanted := KeyNeg
      else
    if NumDelta = 0
      then VK_Wanted := 0
      else VK_Wanted := KeyPos;

    Shift_Wanted := Shift_Wtd;
  end;
var
  I, Rep : Integer;
begin
  NumDelta  := WheelDelta div WHEEL_DELTA;
  Handled   := True;

  if Shift = [ssCtrl, ssAlt]                      // sv - comp
    then SelectKey(VK_LEFT,  VK_RIGHT, -1)        // left right menu bar
    else
  if Shift = [ssShift]                            // page up down
    then SelectKey(VK_PRIOR, VK_NEXT,  -1)
    else
  if Shift = [ssCtrl]                             // ctrl page up down
    then SelectKey(VK_PRIOR, VK_NEXT,  -1, [ssCtrl])            // zoom in out
    else
  if Shift = [ssAlt]                              // image left right
    then SelectKey(VK_HOME,  VK_END,   -1)
    else
  if (Shift = []) or                              // regular up down
     (Shift = [ssShift, ssAlt])
    then SelectKey(VK_DOWN,  VK_UP,    +1)
    else Handled := False;

  if Handled then
  begin
    if (Shift = [ssShift, ssAlt])
      then Rep := 2
      else Rep := 1;
    for I := 1 to Rep do
      Tp7KeyToCrtKeyBuf(KeyDelphiToTp7(VK_Wanted, Shift_Wanted));
//    Perform(WM_KEYDOWN, VK_Wanted, 1);   // different use of Shift modifiers leads to conflicts!
//    Perform(WM_KEYUP,   VK_Wanted, 1);
  end;
end;

var
  MaximizedPostStartFlg : Boolean = false;
  StartTime    : TDateTime = 0.0;
  Timer1Ctr    : Cardinal = 0;
procedure TfrmMain.Timer1Timer(Sender: TObject);
// interval is 50 msec
begin
  Inc(Timer1Ctr);
  if (Timer1Ctr = 1) then
  begin
    StartTime := Now;
  end;

  (*  never use this: call Editor does not work: the apps modal window
  // "waiting for termination" disables the editor (notepad.exe)!
  // enshure ShowMessage and DlgMessage do not stay behind other window:
  if ModalFlg and // 19.07.05 P.W
     (not MonitorFpuCwBlinded) then // do not disturbe common dialogs!
  begin  // try to avoid that sometimes a ShowMessage is hidden in background
    if (ReadDosTimer(ModalTmr) > 4.0) then
      if ModalFlg then
      if not AllowOtherProgs then
      begin
        ForceBringToFront;  // disturbes input if not
        if ModalFlg then
          StartDosTimer(ModalTmr);
      end;
  end;
  *)

  // show or maximize window a bit delayed (avoid that each short running program
  // paints its window)
  if (not MaximizedPostStartFlg) and
     (MaximizeDelaySec >= -0.001) and  // negative to disable
     (3600.0 * 24.0 * (Now - StartTime) > MaximizeDelaySec ) and
     (not ModalFlg) //
     then
  begin
    MaximizedPostStartFlg:= True;

    // WindowState := wsMaximized;
    ChkScreenPos(Self);  // 05.09.05 P.W

    Show;                     // 17.06.05 P.W
    ForceBringToFront;
  end;

  Crt.CheckCursor;
  MonitorFpuCw;

  ChkTerminated;     // in timer to give a chance to get other keys
                     // like ESC in loops where AltX is not supported
end;

var
  InTimerLvAnTimer : Boolean = False;   // 21.02.24 P.W
procedure TfrmMain.TimerLvAnTimer(Sender: TObject);  // 21.02.24 P.W
begin
  if not InTimerLvAnTimer then
  begin
    InTimerLvAnTimer := True;
    try
    except
      on E: Exception do ShowMessage(E.Message);
    end;
    InTimerLvAnTimer := False;
  end;
end;

procedure TFrmMain.PrintScreenDialog;
// 13.10.08 P.W Orientation from PrinterFpu.Orientation to poAutomatic

begin
  If CommonDialog_Execute(PrintDialog1) then
    PrintScreenPart(poAutomatic);
end;

procedure TfrmMain.Print1Click(Sender: TObject);
begin
  PrintScreenDialog;
end;

procedure TfrmMain.PrintScreenCtrlPrint1Click(Sender: TObject);
begin
  PrintScreenPart;
end;

procedure TfrmMain.PrintSetup1Click(Sender: TObject);
begin
  If CommonDialog_Execute(PrinterSetupDialog1) then
  begin
    //ShowMessage('PrintSetupDialog1.Execute Ok');
  end;
end;

procedure TfrmMain.Screentofile1Click(Sender: TObject);
var
  Bmp : TBitMap;
begin
  if CommonDialog_Execute(SavePictureDialog1) then
  begin
    Bmp := Self.GetFormImage;
    SaveBitMapAsAny(Bmp, SavePictureDialog1.FileName);
    Bmp.Free;
  end;
end;

procedure TfrmMain.SaveScreen1Click(Sender: TObject);
var
  ActFrm : TForm;
  ScrFile : String;
begin
  ScrFile := '';
  if active then
  begin
    ScrFile := ScrSave(Self);
    if (AppStratec in [AS_MeasMod, AS_XctDirector])
    then ShowMessageFmtMs(TraS('Screen saved to file "%s"'), [ScrFile])
    else ShowMessageFmt  (TraS('Screen saved to file "%s"'), [ScrFile]);
    BringToFront;
  end else
  begin
    ActFrm := Screen.ActiveForm;
    if Assigned(ActFrm) then
    begin
      ScrFile := ScrSave(ActFrm);
      ShowMessageFmt(     TraS('Screen saved to file "%s"'), [ScrFile]);
    end else
    begin
      ShowMessage(TraS('No screen saved!'))
    end;
  end;
  if (ScrFile <> '') then LastSaveScreenFile := ScrFile;
end;

procedure TfrmMain.File1Click(Sender: TObject);
// 28.07.06 P.W
// is called before each sub item is called; even in the case of
// use short cut key
// excepted are programmed direct calls
var
  NotPrinting: Boolean;    // 27.10.08 P.W
begin
  SaveScreenPatFolder1.Enabled := PatNrFolderPossible;

  // --- 27.10.08 P.W
  NotPrinting := not PrinterFpu.Printing;
  PrintScreenCtrlPrint1.Enabled  := NotPrinting;
  Print1.Enabled                 := NotPrinting;
  PrintSetup1.Enabled            := NotPrinting;
  ReducedPrintRes1.Enabled       := NotPrinting;
  // ---

end;

procedure TfrmMain.SaveScreenPatFolder1Click(Sender: TObject);
// 28.07.06 P.W
var
  MsgMode : TMsgMode;
begin
  case AppStratec of
    AS_MeasMod, AS_XctDirector:  MsgMode := MSG_Delay;
    else                         MsgMode := MSG_Wait;
  end;
  ScrSaveNameMask(nil, GetFilScrOutPath, MsgMode);
end;

procedure TfrmMain.ViewScreens(StartDirFile: AnsiString);
// Modifications:
// 25.03.08 P.W StartDirFile: support as Directory or as File
var
  NewFlg : Boolean;
begin
  NewFlg := not assigned(frmViewScreens);
  If NewFlg then
  begin
    frmViewScreens := TfrmViewScreens.Create(Self);
    frmViewScreens.Parent := nil;
  end;
  If assigned(frmViewScreens) then
  begin
    if (StartDirFile <> '') then
    begin
      if SysUtils.DirectoryExists(StartDirFile) then
      begin
        frmViewScreens.SavePictureDialog1.InitialDir := StartDirFile;
        frmViewScreens.OpenPictureDialog1.InitialDir := StartDirFile;
      end else
      if SysUtils.FileExists(StartDirFile) then  // 25.03.08 P.W
      begin
        frmViewScreens.SavePictureDialog1.FileName := StartDirFile;
        frmViewScreens.OpenPictureDialog1.FileName := StartDirFile;
      end;
      frmViewScreens.SingleMode := (Pos(ErrScrDirPart,StartDirFile) > 0);
    end;
    If NewFlg or (frmViewScreens.ImageCount = 0) then
    begin
      frmViewScreens.Open1Click(Self);
      if (frmViewScreens.ImageCount > 2) then   // only when new : 19.12.07 P.W
        frmViewScreens.SingleMode := True;
    end;

    if (frmViewScreens.ImageCount > 0) then
      frmViewScreens.Show; // Modal; // window must be hidden before call!
                           // no longer modal: 19.12.07 P.W
  end;
end;

procedure TfrmMain.ViewScreens1Click(Sender: TObject);
begin
  ViewScreens(LastSaveScreenFile); // '' -> LastSaveScreenFile  25.03.08 P.W
end;

procedure TfrmMain.ViewTranslationDatabase1Click(Sender: TObject);
begin
//  StartTranslate;
  AddTrans.EditContent;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
//ShowMessage('TfrmMain.FormDestroy'); // not seen when application closes!
//  MessageBox1(0, 'TfrmMain.FormDestroy', 'Info', MB_OK);
  RestoreAccessKeys;              // 22.06.05 P.W
end;

procedure TfrmMain.InvertBlackWhite1Click(Sender: TObject);
begin
  InvertBlackWhite(Graph0_DrawBmp);
end;

function ValidImgName(ImgName: String): Boolean;
// must match I#######.Mxx'  where # is decimal and x a hexadecimal value
var
  I : Integer;
  Ch : Char;
begin
  Result := (Length(ImgName) = 12);
  if Result then
  for I:=1 to Length(ImgName) do
  begin
    Ch := UpCase(ImgName[I]);
    Case I of
      1      : Result := Ch = 'I';
      2..8   : Result := ('0' <= Ch) and (Ch <= '9');
      9      : Result := Ch = '.';
      10     : Result := Ch = 'M';
      11..12 : Result := (('0' <= Ch) and (Ch <= '9')) or (('A' <= Ch) and (Ch <= 'F'));
    end;
    if not Result then Break;
  end;
end;

var
  LastShowActiveTime : TDateTime = 0;
  frmShowActive : TForm = nil;
  ShowActiveCtr : Integer = 0;
procedure ShowActive(Msg: String = '');
var
  Time : TDateTime;
  DeltaSec : Double;
begin
  inc(ShowActiveCtr);
  Time := GetTime;
  DeltaSec := (Time - LastShowActiveTime) * 24.0 * 3600.0;
  if DeltaSec > 0.3 then
  begin
    if frmShowActive = nil then
    begin
      frmShowActive := TForm.Create(nil);
      frmShowActive.Parent := nil;
      frmShowActive.Position := poScreenCenter;
      frmShowActive.Canvas.Font.Height := DefaultTextHeight;
    end;
    frmShowActive.Canvas.TextOut(10,10,
      Format(TraS('Please wait %s (%d)'),[Msg, ShowActiveCtr]));
    frmShowActive.Show;
    LastShowActiveTime := Time;
  end;
end;

procedure HideActive;
begin
  FreeAndNil(frmShowActive);
  ShowActiveCtr := 0;
  ApplicationProcessMessages;
end;

var
  GetFileListLevel : Integer = 0;
procedure GetFileList(var List: TStringList; const SearchDir, mskFil: String; MaxLevel:Integer=-1);
// SearchDir needs trailing pathdelimiter!
Label
  To_Exit;
var
  sr : TSearchRec;
begin
  Inc(GetFileListLevel);
  if not assigned(List) then List := TStringList.Create;

  if (MaxLevel > 0) then Dec(MaxLevel) else
  if (MaxLevel = 0) then Goto To_EXIT;

  // search files
  if (FindFirst(SearchDir + mskFil, 0, sr) = 0) then
  begin
    repeat  // for all matching files:
      if ValidImgName(Sr.Name) then
        List.Append(SearchDir+Sr.Name);
        ShowActive;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

  // search subfolders
  if (FindFirst(SearchDir + '*.*', faDirectory, sr) = 0) then
  begin
    repeat  // for all sub folders:
      if (sr.Name <> '.')   and
         (sr.Name <> '..')  and
         (UpperCase(ExtractFileExt(sr.Name)) <> '.LNK') then
      begin
        ShowActive;
        GetFileList(List, IncludeTrailingPathDelimiter(SearchDir+Sr.Name), mskFil, MaxLevel);
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

 To_Exit:
  Dec(GetFileListLevel);
  if (GetFileListLevel = 0) then HideActive;
end;

function GetImgList(const WorkDir, mskImg: String): TStringList;
// Result should be sorted
Const
  mskAv3 = 'AV???';
  mskAv7 = 'A???????';
//  mskImg = 'I???????.M??';
Label
  To_Exit;
var
  dirWrk : String;
  sr_Av3 : TSearchRec;
  dirAv3 : String;
  sr_Av7 : TSearchRec;
  dirAv7 : String;
  sr_Img : TSearchRec;
begin
  Inc(GetFileListLevel);
  if (Length(WorkDir) <= 3) then
  begin
    Result := nil;
    GetFileList(Result, IncludeTrailingPathDelimiter(WorkDir), mskImg, 4);
    Goto To_Exit;
  end;
  Result := TStringList.Create;
  Result.Sorted := True;
  dirWrk := IncludeTrailingPathDelimiter(WorkDir);
  if (FindFirst(dirWrk + mskAv3, faDirectory, sr_Av3) = 0) then
  begin
    repeat  // for all <dirWrk>AV??? folders:
      ShowActive;
      dirAv3 := IncludeTrailingPathDelimiter(dirWrk+sr_Av3.Name);
      if (FindFirst(dirAv3 + mskAv7, faDirectory, sr_Av7) = 0) then
      begin
        repeat // for all <dirWrk>AV???\A??????? folders:
          ShowActive;
          dirAv7 := IncludeTrailingPathDelimiter(dirAv3+sr_Av7.Name);
          if (FindFirst(dirAv7 + mskImg, 0, sr_Img) = 0) then
          begin
            repeat // for all <dirWrk>AV???\A???????\I???????.M?? files:
              ShowActive;
              Result.Append(dirAv7+sr_Img.Name);
            until FindNext(sr_Img) <> 0;
            FindClose(sr_Img);
          end;
        until FindNext(sr_Av7) <> 0;
        FindClose(sr_Av7);
      end;
    until FindNext(sr_Av3) <> 0;
    FindClose(sr_Av3);
  end;

 To_Exit:
  Dec(GetFileListLevel);
  if (GetFileListLevel = 0) then HideActive;
end;

procedure ChkFormShow(Form: TForm);
begin
  if Assigned(Form) then
  begin
    Form.Show;
    ShowWindowAsync(Form.Handle, SW_RESTORE);
    BringWindowToTop(Form.Handle);  // flickers
  end;
end;

procedure ChkFormShowNoFlicker(Form: TForm);
begin
  if Assigned(Form) then
  begin
    if not Form.Visible      then Form.Show;
    if IsIconic(Form.Handle) then ShowWindowAsync(Form.Handle, SW_RESTORE);
//    BringWindowToTop(Form.Handle);  // flickers
  end;
end;

procedure ChkFormFree(var Form: TForm);
begin
  if Assigned(Form) then
  begin
    FreeAndNil(Form);
  end;
end;

var
  FormBrowse  : TForm  = nil;
  FormBrowseResizeFlg : Boolean = False;
  ImageBrowse : TImage = nil;
  DirBrowse   : String = '';
  ShowXctImageActive : Boolean = False;
  lbxFilesBrowse : TListBox = nil;

type
  TOnEventObj = class
  private
  public
    procedure FormActivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    constructor Create;
    destructor Destroy; override;
  end;

constructor TOnEventObj.Create;
begin
  inherited;

end;

destructor TOnEventObj.Destroy;
begin
  inherited;
end;

procedure TOnEventObj.FormActivate(Sender: TObject);
begin
  if assigned(FormBrowse) and
     isWindow(FormBrowse.Handle) and
     (not IsWindowEnabled(FormBrowse.Handle)) then
   EnableWindow(FormBrowse.Handle, True);
end;

procedure TOnEventObj.FormResize(Sender: TObject);
begin
//EXIT;
  if not ShowXctImageActive then
  begin
    FormBrowseResizeFlg := True;
    try
      if Assigned(lbxFilesBrowse) then
        lbxFilesBrowse.OnClick(lbxFilesBrowse);
    finally
      FormBrowseResizeFlg := False;
    end;
  end;
end;

Type
  THForm = Class(TForm)
  end;

procedure TOnEventObj.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
//EXIT;
end;

var
  BrowseOnEvent : TOnEventObj = nil;
  FormBrowseH : Integer = 0;
  FormBrowseW : Integer = 0;

procedure DoShowXctImage(ImgName: String; ImgNo, ImgNums: Integer);
// duplicate code in UfrmTools.pas and FemurPcForm1
  procedure ChkSquare(Form: TForm);
  Label
    To_EXIT;
  var
    DecFlg : Boolean;
    DC, DW, DH, FL, FT, FW, FH : Integer;
  begin
    if FormBrowseResizeFlg then exit;  // avoid flickering during resizing
    // tip use UpdateBoundsRect (bypasses all resize events)
    // or use SetBounds (sets Height, width... at once):
    // SetBounds: no improvement
    // UpdateBoundsRect does not update ClientRect
    DC := Form.ClientWidth - Form.ClientHeight;
    if (DC = 0) then goto To_EXIT;

    DW := Form.Width  - FormBrowseW;
    DH := Form.Height - FormBrowseH;
    If Abs(DW) > Abs(DH)
      then DecFlg := DW < 0
      else DecFlg := DH < 0;

    FL := Form.Left;
    FT := Form.Top;
    FW := Form.Width;
    FH := Form.Height;
  //    if False then            // if both allowed the flickering is extrem!
    if DecFlg then
  //    if True then
    begin // allows decrease:
      if DC > 0
        then FW := Form.Width  - ABS(DC)
        else FH := Form.Height - ABS(DC);
    end else
    begin // allows enlarge:
      if DC < 0
        then FW := Form.Width  + ABS(DC)
        else FH := Form.Height + ABS(DC);
    end;
    Form.SetBounds(FL, FT, FW, FH);  // no improvement! flickers!
    // Form.UpdateBoundsRect // is proteced! Does not Update ClientRect!
  //    THForm(Form).UpdateBoundsRect(Rect(FL, FT, FL+FW, FT+FH));
  To_EXIT:
    FormBrowseH := Form.Height;
    FormBrowseW := Form.Width;
  end;

type
  TImgData = Array[0..1024*1024] of SmallInt;
const
  XctHeaderSize = 1609;
var
  Form  : TForm;
  Image : TImage;
  ImgFil: File;
  ImgSiz: Integer;
  ImgDim: Integer;
  ImgDimShow : Integer;
  ImgData : Pointer;
  ImgDataSize : Integer;
  ScaleFact : Double;
  ixs, iys : Integer;
  ix, iy : Integer;
  SL : PBmpArr;
  DatVal : SmallInt;
  R  : Byte;
  FileModeSav : Byte;  // 10.11.05 P.W
begin
  Form  := FormBrowse;
  Image := ImageBrowse;
//  Form.Free;

  //v --- read the data ---
  Assign(ImgFil, ImgName);

  FileModeSav := FileMode;  // 10.11.05 P.W
  FileMode := fmOpenRead;   // 10.11.05 P.W   // allow to read from CD drive!
  Reset (ImgFil, 1);
  FileMode := FileModeSav;  // 10.11.05 P.W

  Seek  (ImgFil, XctHeaderSize);
    ImgSiz := FileSize(ImgFil);
    If ImgSiz < XctHeaderSize then
    begin
      Close  (ImgFil);
      Exit;
    end;
    ImgDim := Round(sqrt(0.5 *(ImgSiz - XctHeaderSize)));
    ImgDataSize := ImgDim * ImgDim * SizeOf(SmallInt);
    If ImgSiz <> XctHeaderSize + ImgDataSize then
    begin
      Close  (ImgFil);
      Exit;
    end;
    GetMem(ImgData, ImgDataSize);
    BlockRead(ImgFil, ImgData^, ImgDataSize);
  Close (ImgFil);
  //^ --- read the data ---

  ImgDimShow := Application.MainForm.Width div 3;

  if not assigned(Form) then
  begin
    Form := TForm.Create(nil);
    Form.Parent := nil;
    Form.Left   := Application.MainForm.Width div 4;
 //   Form.Width  := Form.Left * 2;
//    Form.Height := Form.Width;
    Form.Constraints.MinWidth  := 50;  // (to avoid division by zero)
    Form.Constraints.MinHeight := 50;  //
    Form.OnResize    := BrowseOnEvent.FormResize;
    Form.OnMouseUp   := BrowseOnEvent.FormMouseUp;

    Image          := TImage.Create(Form);
    Image.Parent   := Form;

//    Image.Align    := AlClient;
    Image.Align    := alCustom;
//    Image.Constraints.MinWidth  := 50;  // (to avoid division by zero)
//    Image.Constraints.MinHeight := 50;  // but both are ignored!

//    Image.Stretch  := True;
//    Image.Center   := True;
    Image.Picture.Bitmap.PixelFormat := BmpPixFmt;
    Image.Picture.Bitmap.Width  := ImgDimShow;
    Image.Picture.Bitmap.Height := ImgDimShow;
    Image.Left   := 0;
    Image.Top    := 0;
    Image.Width  := ImgDimShow;
    Image.Height := ImgDimShow;

    Form.AutoSize := True;
    Form.Show;                  // create form with adapted size
    Form.AutoSize := False;     // allow user to resize form
    FormBrowseH := Form.Height;
    FormBrowseW := Form.Width;
  end;

  //v--- adapt to changed form size (want squared client area) ---
    ChkSquare(Form);

    // ImgDimShow not below 10 to avoid division by zero:
    ImgDimShow := Max(10, Min(Form.ClientWidth, Form.ClientHeight));
    Image.Width  := ImgDimShow;
    Image.Height := ImgDimShow;
    Image.Picture.Bitmap.Width  := ImgDimShow;
    Image.Picture.Bitmap.Height := ImgDimShow;
    ScaleFact := ImgDim / ImgDimShow;
  //^--- adapt to changed form size ---

    Form.Caption := Format('%s (%d/%d)', [ImgName, ImgNo, ImgNums]);
    For iys := 0 to ImgDimShow - 1 do
    begin
      iy := Trunc(iys * ScaleFact);
      SL := Image.Picture.Bitmap.ScanLine[iys];
      For ixs := 0 to ImgDimShow - 1 do
      begin
        ix := Trunc(ixs * ScaleFact);
//        DatVal := TImgData(ImgData^)[iy * ImgDim + ix];
        DatVal := TImgData(ImgData^)[ix * ImgDim + iy];    // same as KnMulti.exe

        DatVal := Max(0,DatVal);
        R := Min(DatVal div 5, 255);
        SL[ixs] := GetBmpColorRGB(R, R, R);
      end;
    end;

    Image.Picture.Bitmap.Modified := True;
//    Application.ProcessMessages; // may crash! (because of reuse of FormBrowse)

    FreeMem(ImgData, ImgDataSize);
    ChkFormShowNoFlicker(Form);
  FormBrowse  := Form;
  ImageBrowse := Image;
//  Form.Free;
end;

procedure ShowXctImage(ImgName: String; ImgNo, ImgNums: Integer);
begin
  ShowXctImageActive := True;
  try
    DoShowXctImage(ImgName, ImgNo, ImgNums);
  finally
    ShowXctImageActive := False;
  end;
end;

procedure BrowseImages(WorkDir, ImgMsk: String; OnClick, OnDblClick: TNotifyEvent; FormFree:Boolean=False);
var
  Form     : TForm;
  lbxFilesBrowseSav,
  lbxFiles : TListBox;
//  tmr      : TTimer;
begin
  if not Assigned(BrowseOnEvent) then
  begin
    BrowseOnEvent := TOnEventObj.Create;
  end;

  ChkFormShow(FormBrowse);
  Form := TForm.Create(nil);
  Form.Parent := nil;

//  Form.Position := poScreenCenter;
  Form.Position := poDesigned;
  Form.Left := 0;
  Form.Caption := 'List ' + WorkDir + ' ' + ImgMsk;
  Form.Top := 0;
  Form.Width  := (1 * Application.MainForm.Width ) div 4;
  Form.Height := (1 * Application.MainForm.Height) div 1;

    lbxFiles := TListBox.Create(Form);
    lbxFiles.Parent := Form;

//  lbxFiles.Align      := alLeft;
    lbxFiles.Align      := alClient;
    lbxFiles.Width      := Form.Width div 1;

    lbxFiles.OnClick    := OnClick;
    lbxFiles.OnDblClick := OnDblClick;

    lbxFiles.Sorted     := True;   // maybe ignored by Items := GetImgList!
    lbxFiles.Items      := GetImgList(WorkDir, ImgMsk);
    lbxFilesBrowseSav := lbxFilesBrowse;
    lbxFilesBrowse := lbxFiles;
    OptScrollWidthX(lbxFilesBrowse);

  if not FormFree then
  begin
    Form.OnActivate := BrowseOnEvent.FormActivate; // Enable Formbrowse inside ShowModal
    //FormBrowse.Parent := Form;   // makes FormBrowse invisible outside the parent
    // FormBrowse.Parent := nil;   //  FormBrowse visible but no moveable
  end;
    Form.ShowModal;  // disables FormBrowse
                     // but the From.OnActivate enables FormBrowse

  if not FormFree then
  begin
    if Assigned(FormBrowse) then
      FormBrowse.Parent := nil;
  end;

  lbxFilesBrowse := lbxFilesBrowseSav;
  Form.Free;


  if FormFree then
  begin
    ChkFormFree(FormBrowse);
    FreeAndNil(BrowseOnEvent);
  end else
  begin
    BrowseOnEvent.FormResize(nil);
  end;
end;

procedure TfrmMain.BrowseImagesLbxClick(Sender: TObject);
var
  lbx : TListBox;
  idx : Integer;
begin
//  ShowMessage(Sender.ClassName);
  if Sender is TListBox then
  begin
    lbx := TListBox(Sender);
    idx := lbx.ItemIndex;
    if (idx >= 0) and (idx < lbx.Items.Count) then
    begin
      ShowXctImage(lbx.Items[idx], idx+1, lbx.Items.Count);
//      if BrowsePlay1.Checked and (lbx.Items.Count >= 2) then
//      begin
//        Sleep(100);
//        if idx < Lbx.Items.Count-1
//          then Lbx.ItemIndex := idx + 1
//          else Lbx.ItemIndex := 0;
//      end;
    end;
    if lbx.Enabled then
      lbx.SetFocus;
  end;
end;

procedure TfrmMain.BrowseImagesLbxDblClick_All(Sender: TObject);
// show all slices of all images            (3)
var
  ImgName : String;
  ImgMask : String;
begin
//  ShowMessage(Sender.ClassName);
  if Sender is TListBox then
  begin
    ImgName := TListBox(Sender).Items[TListBox(Sender).ItemIndex];

    ImgMask := ChangeFileExt(ExtractFileName(ImgName),
                 SliceNrNamePartMask);     //  '.M??' -> SliceNrNamePartMask : 20.12.06 P.W
    BrowseImages(DirBrowse, ImageNameMask, //'I???????.M??' -> ImageNameMask : 20.12.06 P.W
                 BrowseImagesLbxClick,
                 nil);
  end;
end;

procedure TfrmMain.BrowseImagesLbxDblClick_ImgSlices(Sender: TObject);
// show all slices of current image         (2)
var
  ImgName : String;
  ImgMask : String;
begin
//  ShowMessage(Sender.ClassName);
  if Sender is TListBox then
  begin
    ImgName := TListBox(Sender).Items[TListBox(Sender).ItemIndex];

    ImgMask := ChangeFileExt(ExtractFileName(ImgName),
                 SliceNrNamePartMask);     //  '.M??' -> SliceNrNamePartMask : 20.12.06 P.W
    BrowseImages(DirBrowse, ImgMask,
                 BrowseImagesLbxClick,
                 BrowseImagesLbxDblClick_All);
  end;
end;

procedure TfrmMain.StartBrowse(SearchDir: String);
// show first slice of all images           (1)
begin
  DirBrowse := SearchDir;
  BrowseImages(DirBrowse, 'I???????.M01',
               BrowseImagesLbxClick,
               BrowseImagesLbxDblClick_ImgSlices, True);
end;

procedure TfrmMain.BrowseImages2Click(Sender: TObject);
begin
  StartBrowse(GetEnvironmentVariable('XCTDIR'));
end;

procedure TfrmMain.BrowseImagesDrive(Drive: Char);
begin
  StartBrowse(Drive+':\');
end;

procedure TfrmMain.BrowseImagesA1Click(Sender: TObject);
begin
  BrowseImagesDrive('A');
end;

procedure TfrmMain.BrowseImagesB1Click(Sender: TObject);
begin
  BrowseImagesDrive('B');
end;

procedure TfrmMain.BrowseImagesC1Click(Sender: TObject);
begin
  BrowseImagesDrive('C');
end;

procedure TfrmMain.BrowseImagesD1Click(Sender: TObject);
begin
  BrowseImagesDrive('D');
end;

procedure TfrmMain.BrowseImagesE1Click(Sender: TObject);
begin
  BrowseImagesDrive('E');
end;

procedure TfrmMain.BrowseImagesF1Click(Sender: TObject);
begin
  BrowseImagesDrive('F');
end;

procedure TfrmMain.BrowseImagesG1Click(Sender: TObject);
begin
  BrowseImagesDrive('G');
end;

procedure TfrmMain.BrowseImagesH1Click(Sender: TObject);
begin
  BrowseImagesDrive('H');
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// if not "X" button of the window is pressed then we do not come to here!
//
// 04.10.04 P.W avoid that terminating use Win-Close button leads to
// different behaviour compared with "Button Bar Program End":
// In case of QA, where during termination all the QA-Results are shown
// differences occur when Application.Terminated is true:
// then Show Qa Info fails.
// So we set CanClose to False but insert Alt-X into the keybuffer
// to come to program end

// Modifications
// 26.08.09 P.W: AS_XctDirector improve chance to close when AddEsc two time without success
//  but when canclose is true then the mainform is closed and the application terminates!
begin
  Deb0('TfrmMain.FormCloseQuery 0');
  CanClose    := False;    // avoids Application.Terminated to be true

///for I := 0 to ControlCount -1 do
///  if (Controls[I] is TForm) then
///    TForm(Controls[I]).CloseQuery;
  case AppStratec of
    AS_MeasMod:
      begin               // no longer allow system shuttdown; user click to close is handled by WMClose
      //  CRT_KeyBuf_AddEsc;  // moved to WMClose 02.11.09 P.W
      // avoid stop of measurement because someone tries to shut down the computer
      // AddEscape only when user clicks close button
      end;
    AS_XctDirector:
      begin
        if AS_XctDirector_DisableClose then EXIT;  // 02.11.09 P.W

        { v---  until 02.11.09 P.W:
        CanClose := (not Enabled)
                    or (CRT_KeyBuf_ContainsNumEsc >= 2);  // or: 26.08.09 P.W
        if not CanClose then
          CRT_KeyBuf_AddEsc;
        {^---  until 02.11.09 P.W}
        CanClose := True;  // since 02.11.09 P.W
        CRT_KeyBuf_AddEsc;
      end;
    else
      begin
        CRT_KeyBuf_AddAltX;  // includes escape!
      end;
  end;
  Deb0('TfrmMain.FormCloseQuery x-');
end;


procedure TfrmMain.WMClose(var Message: TWMClose);
// 02.11.09 P.W
// to here we come when the user clicks the close button
// but not when FemurPcDelphi or XctDirector shall be closed using TaskManager or Restart System
begin
  Deb0('TfrmMain.WMClose 0');

  case AppStratec of
    AS_MeasMod:
      begin
        CRT_KeyBuf_AddEsc;  // to here from FormCloseQuery
      end;
    AS_XctDirector:
      begin
        Message.Result := 1;
        CRT_KeyBuf_AddEsc;
        Exit; // skip further close to keep XctDirector alive (because TfrmMain is the app.mainwindow)
      end;
  end;

  inherited;
  Deb0('TfrmMain.WMClose x-');
end;


procedure TfrmMain.CheckedPrnRes;
var
  S : String;
begin
  ReducedPrintRes1.Checked     := True;
  PrintResolutionPrn111.Checked  := False;
  PrintResolutionPrn1.Checked  := False;
  PrintResolutionLow1.Checked  := False;
  PrintResolutionMid1.Checked  := False;
  PrintResolutionHigh1.Checked := False;
  Case FixedPrintRes of
    PR_PrnOpt :
      begin
        ReducedPrintRes1.Checked     := False;
        PrintResolutionPrn1.Checked  := True;
        S:= TraS('Prn Opt');
      end;
    PR_Prn1_1 :
      begin
        ReducedPrintRes1.Checked     := False;
        PrintResolutionPrn111.Checked  := True;
        S:= TraS('Prn 1_1');
      end;
    PR_Low :
      begin
        PrintResolutionLow1.Checked  := True;
        S:= TraS('Low');
      end;
    PR_Mid :
      begin
        PrintResolutionMid1.Checked  := True;
        S:= TraS('Mid');
      end;
    PR_High:
      begin
        PrintResolutionHigh1.Checked := True;
        S:= TraS('High');
      end;
  end;

  if (FixedPrintRes in  [PR_PrnOpt, PR_Prn1_1])
  then
    ReducedPrintRes1.Caption :=
      Format(TraS('Print Res %s'), [S])
  else
    ReducedPrintRes1.Caption :=
      Format(TraS('Print Res %s (%d*%d)'), [S, FixedPrintResDx, FixedPrintResDy]);


end;
procedure TfrmMain.PrintResolutionPrn1Click(Sender: TObject);
begin
  FixedPrintRes := PR_PrnOpt;
  CheckedPrnRes;
end;

procedure TfrmMain.PrintResolutionPrn111Click(Sender: TObject);
begin
  FixedPrintRes := PR_Prn1_1;
  CheckedPrnRes;
end;

procedure TfrmMain.PrintResolutionLow1Click(Sender: TObject);
begin
  FixedPrintRes := PR_Low;
  CheckedPrnRes;
end;

procedure TfrmMain.PrintResolutionMid1Click(Sender: TObject);
begin
  FixedPrintRes := PR_Mid;
  CheckedPrnRes;
end;

procedure TfrmMain.PrintResolutionHigh1Click(Sender: TObject);
begin
  FixedPrintRes := PR_High;
  CheckedPrnRes;
end;

procedure TfrmMain.ViewAsciiPrint1Click(Sender: TObject);
begin     // not supported by MainMenu1
  ShowFileContent(AsciiPrintFileName, TraS('Show Content of Ascii Print File:')+AsciiPrintFileName);
end;

procedure TfrmMain.PaintDebug1Click(Sender: TObject);
begin
  PaintDebug1.Checked := not PaintDebug1.Checked;
  PaintDebug := PaintDebug1.Checked;
end;

procedure TfrmMain.ScreenSaver1Click(Sender: TObject);
var
  I         : Integer;
  x, y      : Integer;
  BmpCol    : TBmpCol;
  R, G, B   : Byte;
begin
  for I := 0 to (1*256)-1  do
  begin
    if not KeyPressed then
    for y := 0 to Graph0_DrawBmp.Height -1 do
    begin
      if not KeyPressed then
      for x := 0 to (Graph0_DrawBmp.Width -1) do
      begin
        BmpCol := Graph0_DrawScanLines[Y][X];
        GetRGBBmpColor(BmpCol, R, G, B);
        case I mod 3 of
          0: if (R > 0) then Dec(R);
          1: if (G > 0) then Dec(G);
          2: if (B > 0) then Dec(B);
        end;
        Graph0_DrawScanLines[y][x] := GetBmpColorRGB(R, G, B);
      end;
      Graph0_DrawBmp.Modified := True;
    end;
    Delay(1);
  end;
end;

procedure TfrmMain.Options1Click(Sender: TObject);
  procedure OptionsToLocalIniFile;
  // 10.06.05 P.W
  // compare also UReadSet.pas function GlbReadSetUp
    function FalseTrue(B: Boolean): String;
    begin
      if B then Result := 'True'
           else Result := 'False';
    end;
  var
    MIni : TMemIniFile;
  begin
    try
      MIni := TMemIniFile.Create(LocIniFile);

      MIni.WriteString(
        'EXPORT',
        'InvertBlackWhite',
        FalseTrue(ExpImgInvBW));

      MIni.WriteString(
        'EXPORT',
        'UseTabStop',
        FalseTrue(AsciiExpSep = TabStopChar));

      MIni.WriteString(            // 25.11.05 P.W
        'EXPORT',
        'ExpTableScreen',
        FalseTrue(ExpTableScreen));

      MIni.WriteString(
        'PRINT',
        'InvertBlackWhite',
        FalseTrue(PrintInvBW));

      MIni.WriteString(
        'PRINT',
        'ForcePreView',
        FalseTrue(PrintForcePreView));

(*
      ScreenPosFixed  := ReadBoolFT(Mini, 'SCREEN', 'PosFixed', False);
      ScreenPosLeft   := MIni.ReadInteger('SCREEN', 'Left',     0);
      ScreenPosTop    := MIni.ReadInteger('SCREEN', 'Top',      0);
      ScreenPosWidth  := MIni.ReadInteger('SCREEN', 'Width',    0);
      ScreenPosHeight := MIni.ReadInteger('SCREEN', 'Height',   0);
*)
      // 05.09.05 P.W :
      Mini.WriteString('SCREEN', 'PosFixed', FalseTrue(ScreenPosFixed));
      if ScreenPosFixed then
      begin
        Mini.WriteString('SCREEN', 'Left',     IntToStr(ScreenPosLeft));
        Mini.WriteString('SCREEN', 'Top',      IntToStr(ScreenPosTop));
        Mini.WriteString('SCREEN', 'Width',    IntToStr(ScreenPosWidth));
        Mini.WriteString('SCREEN', 'Height',   IntToStr(ScreenPosHeight));
      end;

      MIni.UpdateFile;
    finally
      FreeAndNil(MIni);
    end;
  end;

// sets:
// ExpImgInvBW
// AsciiExpSep
// ExpTableScreen
// PrintInvBW
// PrintForcePreView
type
  TPage    = (Pg_ExpImg, Pg_Prn, Pg_Scr);
const
  Left1    = 10;
  Top1     = 10;
  TopDelta = 20;

  function CalcTop(Nr: Integer): Integer;
  begin
    Result := Top1 + Nr * TopDelta;
  end;

var
  aForm     : TForm;
  aPgCtrl   : TPageControl;
  Pg        : TPage;
  aTabSheet : TTabSheet;
  aChkBox   : TCheckBox;
begin
  aChkBox := nil;   // 08.01.09 P.W
  aForm := TForm.Create(nil);
    aForm.Parent   := nil;
    aForm.Caption  := TraS('Options');  // "temporary" removed 10.06.05 P.W
    aForm.Position := poMainFormCenter;
    aForm.Width    := Max(300, Application.MainForm.Width  div 3);  // Max : 20.12.07 P.W
    aForm.Height   := Max(250, Application.MainForm.Height div 3);  // Max : 20.12.07 P.W
        // Constraints are not working here?

    aPgCtrl        := TPageControl.Create(aForm);
    aPgCtrl.Parent := aForm;
    aPgCtrl.Align  := alClient;

    for Pg := Low(Pg) to High(Pg) do
    begin
      aTabSheet             := TTabSheet.Create(aPgCtrl);
      aTabSheet.Parent      := aPgCtrl;
      aTabSheet.PageControl := aPgCtrl;

      Case pg of
        Pg_ExpImg, Pg_Prn:
          begin
            aChkBox         := TCheckBox.Create(aTabSheet);
            aChkBox.Parent  := aTabSheet;
            aChkBox.Caption := TraS('Invert Black && White');
            aChkBox.Left    := Left1;
            aChkBox.Top     := CalcTop(0);
            aChkBox.Width   := 2 * aChkBox.Height + TextWidth(aChkBox.Caption);
          end;
      end;
      Case Pg of
        Pg_ExpImg:
          begin
            aTabSheet.Caption := TraS('Export Images');
            aChkBox.Checked   := ExpImgInvBW;  // is init above!

            aChkBox         := TCheckBox.Create(aTabSheet);
            aChkBox.Parent  := aTabSheet;
            aChkBox.Caption := TraS('Use Tabstop as Separator');
            aChkBox.Left    := Left1;
            aChkBox.Top     := CalcTop(1);
            aChkBox.Width   := 2 * aChkBox.Height + TextWidth(aChkBox.Caption);
            aChkBox.Enabled := not TestPathFlg;   // 10.06.05 P.W
            aChkBox.Checked   := (AsciiExpSep = TabStopChar);

            aChkBox         := TCheckBox.Create(aTabSheet);  // 25.11.05 P.W
            aChkBox.Parent  := aTabSheet;
            aChkBox.Caption := TraS('Automated Analysis - Export Screen of Table');
            aChkBox.Left    := Left1;
            aChkBox.Top     := CalcTop(2);
            aChkBox.Width   := 2 * aChkBox.Height + TextWidth(aChkBox.Caption);
            aChkBox.Checked   := ExpTableScreen;
          end;
        Pg_Prn:
          begin
            aTabSheet.Caption := TraS('Print');
            aChkBox.Checked   := PrintInvBW;  // is init above!

            aChkBox         := TCheckBox.Create(aTabSheet);
            aChkBox.Parent  := aTabSheet;
            aChkBox.Caption := TraS('Force Preview');
            aChkBox.Left    := Left1;
            aChkBox.Top     := CalcTop(1);
            aChkBox.Width   := 2 * aChkBox.Height + TextWidth(aChkBox.Caption);
            aChkBox.Checked   := PrintForcePreview;
          end;
        Pg_Scr:  // 05.09.05 P.W
          begin
            aTabSheet.Caption := TraS('Screen');

            aChkBox         := TCheckBox.Create(aTabSheet);
            aChkBox.Parent  := aTabSheet;
            aChkBox.Caption := TraS('Fixed Screen');
            aChkBox.Left    := Left1;
            aChkBox.Top     := CalcTop(1);
            aChkBox.Width   := 2 * aChkBox.Height + TextWidth(aChkBox.Caption);
            aChkBox.Checked   := ScreenPosFixed;
          end;
      end;
    end;
    aForm.ShowModal;
    ExpImgInvBW       := TCheckBox(aPgCtrl.Pages[ord(Pg_ExpImg)].Controls[0]).Checked;
    if TCheckBox(aPgCtrl.Pages[ord(Pg_ExpImg)].Controls[1]).Checked
      then AsciiExpSep := TabStopChar
      else AsciiExpSep := FixSem;
    ExpTableScreen    := TCheckBox(aPgCtrl.Pages[ord(Pg_ExpImg)].Controls[2]).Checked;

    PrintInvBW        := TCheckBox(aPgCtrl.Pages[ord(Pg_Prn   )].Controls[0]).Checked;
    PrintForcePreView := TCheckBox(aPgCtrl.Pages[ord(Pg_Prn   )].Controls[1]).Checked;

    ScreenPosFixed    := TCheckBox(aPgCtrl.Pages[ord(Pg_Scr   )].Controls[0]).Checked;
    if ScreenPosFixed then  // 05.09.05 P.W
    begin
      ScreenPosLeft   := Self.Left;
      ScreenPosTop    := Self.Top;
      ScreenPosWidth  := Self.Width;
      ScreenPosHeight := Self.Height;
    end;

  OptionsToLocalIniFile; // 10.06.05 P.W
  FreeAndNil(aForm);
end;

procedure CheckForegroundWindow;
// 17.06.05 P.W for AS_MeasMod: Keep Measurement application in foreground
// Problems occur with Messagebox(0,..  MB_TASKMODAL or not
//  Works under WinXP;
//  Win 98 ?
var
  ActFrmHdl : THandle;
begin
  if Assigned(Screen.ActiveForm)
    then ActFrmHdl := Screen.ActiveForm.Handle
    else ActFrmHdl := 0;

  if GetForegroundWindow <> ActFrmHdl then
//  if Screen.ActiveForm.Enabled then /!/ does not detect Messagebox
  if not MessageBox1Flg then // set by MsgBox MessageBox1
  begin
    SetForegroundWindow(ActFrmHdl);
    if GetForegroundWindow <> ActFrmHdl then
      ForceBringToFront;
   // Beep;   // beep disabled: 30.09.08 P.W
      // SetFore. brings
      // a)MessageBox(0, .. MB_TASKMODAL) to background
      //   and does not detect that by this all is deadlocked!
      // b)MessageBox(Screen.ActiveForm.Handle, .. MB_TASKMODAL)
      //   is better: Messagebox looses focus but remains visible
      // These problems are avoided using MessageBox1 instead of MessageBox
  end;
end;

procedure TfrmMain.TimerMeasModeTimer(Sender: TObject);
// 17.06.05 P.W for AS_MeasMod: Keep Measurement application in foreground
begin
  if not GlbHelpDebug then  // if: 24.07.09 P.W
    CheckForegroundWindow;
end;

procedure TfrmMain.MarkCommProt1Click(Sender: TObject);
// 29.11.05 P.W
begin
  if not MarkCommProt1.Enabled then Exit; // avoid execution via TfrmMain.FormKeyDown
  MarkCommProt1.Caption := MarkCommProt;
end;

procedure TfrmMain.FormActivate(Sender: TObject);
// 29.11.05 P.W
begin
  MarkCommProt1.Enabled := UseProtV24;
end;

procedure TfrmMain.Window1Show(Sender: TObject);
// 17.03.08 P.W
// eventhandler for "Window1" : Open the desired form
var
  I : integer;
  MI : TMenuItem;
begin
  if Sender is TMenuItem then
  begin
    MI := TMenuItem(Sender);
    for  I := 0 to Screen.FormCount-1 do
    begin
      if (MI.Tag = Integer(Screen.Forms[I])) then
      begin
        Screen.Forms[I].Show;
        Exit;
      end;
    end;
  end;
end;

procedure TfrmMain.UpdateWindow1Items;
// 17.03.08 P.W
// most Forms to "Window1" (excepted frmMain=self, frmPrint, frmClientViewXctImages)
var
  NewItem: TMenuItem;
  I : integer;
begin
// Window1.Clear;  // disables acces of the menu!
// so have Window1 with an separator Item Created;
  if Window1.Count = 0 then
  begin
  { first create the separator }
    NewItem := TMenuItem.Create(Self);
    NewItem.Caption := '-';
  { add the new item to the Windows menu }
    Window1.Add(NewItem);
  end;

  for I := 1 to Window1.Count -1 do
    Window1.Delete(1);
  { now create and add a menu item for each form }
  for  I := 0 to Screen.FormCount-1 do
  if ((Screen.Forms[I].Tag and FormTag_InWindowsList) <> 0) then
     // for  frmMain, frmClientViewXctImages, frmPrint, frmRoiDialog
  begin
Deb0('FemurPcForm1.pas Screen.Forms create and add menu item 0');
    NewItem := TMenuItem.Create(Self);
    NewItem.Caption := Screen.Forms[I].Caption;
    NewItem.OnClick := Window1Show;
    NewItem.Tag := Integer(Screen.Forms[I]);
    Window1.Add(NewItem);
Deb0('FemurPcForm1.pas Screen.Forms create and add menu item 1');
  end;

end;

procedure TfrmMain.Window1Click(Sender: TObject);
// 17.03.08 P.W
// open invisible forms like Xct View Screens
// only for AS_Analyse visible
begin
  UpdateWindow1Items;
end;

procedure TfrmMain.TerminateJob1Click(Sender: TObject);
// 10.12.09 P.W
var
  SL : TStringList;
begin
  if TerminateJob1.Checked then
  begin
    SL := TStringList.Create;
    SL.SaveToFile(StopXmenuJobName);
    SL.Free;
  end else
  begin
    DeleteFile(StopXmenuJobName);
  end
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  AS_XctDirector_DisableClose := False;
  BrowseOnEvent               := nil;
  DirBrowse                   := '';
  FormBrowse                  := nil;
  FormBrowseH                 := 0;
  FormBrowseResizeFlg         := False;
  FormBrowseW                 := 0;
  frmMain                     := nil;
  frmShowActive               := nil;
  GetFileListLevel            := 0;
  GlbDebAppProcMsg            := nil;
  ImageBrowse                 := nil;
  InTimerLvAnTimer            := False;
  LastShowActiveTime          := 0;
  lbxFilesBrowse              := nil;
  MaximizedPostStartFlg       := false;
  ShowActiveCtr               := 0;
  ShowXctImageActive          := False;
  StartTime                   := 0.0;
  StartTime                   := 0.0;
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
  Application.CreateForm(TfrmMain, frmMain);  // 21.02.24 P.W moved from DelphiCrt to FemurPcForm1.pas
  GlbDebAppProcMsg := TDebAppProcMsg.Create;
end;

function Unit_Final(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  FreeAndNil(FormBrowse);
  if Assigned(GlbDebAppProcMsg) and (GlbDebAppProcMsg.Ctr > 0) then;  // avoids compiler to remove GetCtr
  FreeAndNil(GlbDebAppProcMsg);
end;

Initialization
  InitFinal_Add(Unit_Name, Unit_Init, Unit_Final);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  Application.CreateForm(TfrmMain, frmMain);  // 21.02.24 P.W moved from DelphiCrt to FemurPcForm1.pas
  GlbDebAppProcMsg := TDebAppProcMsg.Create;
   -^--- moved to function Unit_Init // 03.05.24 P.W *)

Finalization
(* -v--- moved to function Unit_Final // 03.05.24 P.W
  FreeAndNil(FormBrowse);
  if Assigned(GlbDebAppProcMsg) and (GlbDebAppProcMsg.Ctr > 0) then;  // avoids compiler to remove GetCtr
  FreeAndNil(GlbDebAppProcMsg);
   -^--- moved to function Unit_Final // 03.05.24 P.W *)
end.


