unit frmBnLockPassWd;

interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  WinTools,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmPassWord = class(TForm)
    edtPassword: TEdit;
    Memo1: TMemo;
    btnOk: TButton;
    btnCancel: TButton;
    lblPassword: TLabel;
    Panel1: TPanel;
    lblChanges: TLabel;
    Timer1: TTimer;
    btnWait: TButton;
    Timer2: TTimer;
    procedure edtPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure Panel1Resize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnWaitClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPassWord: TfrmPassWord;

Implementation
  const Unit_Name = 'frmBnLockPassWd'; // 03.05.24 P.W

{$R *.dfm}

procedure TfrmPassWord.edtPasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then ModalResult := mrOk;
end;

procedure TfrmPassWord.Panel1Resize(Sender: TObject);
begin
  edtPassword.Width := Panel1.ClientWidth - 2*(edtPassword.Left);
end;

procedure TfrmPassWord.Timer1Timer(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmPassWord.btnWaitClick(Sender: TObject);
begin
  Timer1.Enabled  := False;
  btnWait.Enabled := False;
  btnCancel.Enabled := True;
end;

procedure TfrmPassWord.Timer2Timer(Sender: TObject);
// 05.09.05 P.W
begin
  ForceForegroundWindow(Self.Handle);
  Sleep(1);
  ForceBringToFront;
  Sleep(1);
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
  frmPassWord := nil;

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
   -^--- moved to function Unit_Init // 03.05.24 P.W *)
end.
