unit ViewXctServerClientGlb;

interface

uses
  SysUtils;

type
  TMacroEnum = (
    ME_Invalid,
    ME_ClientHWND,
    ME_ClientProcId,
    ME_ForegroundHWND,
    ME_Message,
    ME_Position,
    ME_TerminateServer,
    ME_ViewXctImage);

const
   MacroStrgs : Array [TMacroEnum] of String =
     ('', 'ClientHwnd', 'ClientProcId', 'ForeGroundHwnd', 'Message',
      'Position', 'TerminateServer', 'ViewXctImage');


function MacroStrToMacroEnum(const MS: String): TMacroEnum;
function GetMacroEnum(const CmdAndPar: AnsiString; var ParStr: String; var ParVal: Int64): TMacroEnum;

Implementation
  const Unit_Name = 'ViewXctServerClientGlb'; // 03.05.24 P.W

function MacroStrToMacroEnum(const MS: String): TMacroEnum;
var
  ME : TMacroEnum;
begin
  Result := ME_Invalid;
  for ME := Low(ME) to High(ME) do
    if MS = MacroStrgs[ME] then
    begin
      Result := ME;
      Exit;
    end;
end;

function GetMacroEnum(const CmdAndPar: AnsiString; var ParStr: String; var ParVal: Int64): TMacroEnum;
var
  P : Integer;
  Cmd: String;
begin
  P := Pos(';', CmdAndPar);
  if (P = 0) then
  begin
    Result := ME_Invalid;
    ParStr := '';
    ParVal := 0;
  end else
  begin
    Cmd := Copy(CmdAndPar, 1, P-1);
    ParStr := Copy(CmdAndPar, P+1, 255);
    ParVal := StrToInt64Def(ParStr, 0);
    Result := MacroStrToMacroEnum(Cmd);
  end;
end;

end.
