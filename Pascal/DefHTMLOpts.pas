unit DefHTMLOpts;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  IniFiles;

type
  PHTMLOpts = ^THTMLOpts;
  THTMLOpts = record
    StayOnTop,
    ExtendedFormat,
    HeaderWanted,
    Bold,
    ClearAtDrag,
    DatesAsText,
    RelativeLink,
    JpgBmpAsImage       : Boolean;
    ImgWidth, ImgHeight : Integer;
    RelativeRoot        : AnsiString;
    W_Link,
    W_Path,
    W_Size,
    W_Created,
    W_Changed,
    W_Accessed,
    W_ShortName,
    W_Ext,
    W_Existing           : Boolean;

    LineStart,
    LineEnd : Integer;
  end;
{
.StayOnTop;
.ExtendedFormat;
.HeaderWanted;
.Bold;
.ClearAtDrag;
.DatesAsText;
.JpgBmpAsImage;
.ImgWidth;
.ImgHeight;
.RelativeLink;
.RelativeRoot;
.W_Link;
.W_Path;
.W_Size;
.W_Created;
.W_Changed;
.W_Accessed;
.W_ShortName;
.W_Ext;
.W_Existing;
.LineStart;
.LineEnd;
}


function AreHTMLOptsEqual(A, B: THTMLOpts): Boolean;
function LoadHtmlOpts(const FileName: AnsiString; var HTMLOpts: THTMLOpts): Boolean;
function SaveHtmlOpts(const FileName: AnsiString; var HTMLOpts: THTMLOpts): Boolean;

Implementation
  const Unit_Name = 'DefHTMLOpts'; // 03.05.24 P.W

function AreHTMLOptsEqual(A, B: THTMLOpts): Boolean;
begin
  // Result := CompareMem(@A, @B, SizeOf(THTMLOpts)); fails because of AnsiString is pointer to mem!
  Result :=
	(A.StayOnTop    	=	B.StayOnTop)      and
	(A.ExtendedFormat	=	B.ExtendedFormat) and
	(A.HeaderWanted	  =	B.HeaderWanted)   and
	(A.Bold        	  =	B.Bold)           and
	(A.ClearAtDrag  	=	B.ClearAtDrag)    and
	(A.DatesAsText	  =	B.DatesAsText)    and
	(A.JpgBmpAsImage  =	B.JpgBmpAsImage)  and
	(A.ImgWidth       =	B.ImgWidth)       and
	(A.ImgHeight      =	B.ImgHeight)      and
	(A.RelativeLink	  =	B.RelativeLink)   and
	(A.RelativeRoot	  =	B.RelativeRoot)   and
	(A.W_Link	        =	B.W_Link)         and
	(A.W_Path	        =	B.W_Path)         and
	(A.W_Size	        =	B.W_Size)         and
	(A.W_Created	    =	B.W_Created)      and
	(A.W_Changed	    =	B.W_Changed)      and
	(A.W_Accessed	    =	B.W_Accessed)     and
	(A.W_ShortName	  =	B.W_ShortName)    and
	(A.W_Ext	        =	B.W_Ext)          and
	(A.W_Existing     =	B.W_Existing)     and
	(A.LineStart	    =	B.LineStart)      and
	(A.LineEnd	      =	B.LineEnd);

end;

function LoadHtmlOpts(const FileName: AnsiString; var HTMLOpts: THTMLOpts): Boolean;
var
  Ini : TIniFile;
begin
  Result := False;
  Ini := nil; // 08.01.09 P.W
  try
    Ini := TIniFile.Create(FileName);
    HTMLOpts.StayOnTop      := Ini.ReadBool   ('Options', 'StayOnTop',      True);
    HTMLOpts.ExtendedFormat := Ini.ReadBool   ('Options', 'ExtendedFormat', True);
    HTMLOpts.JpgBmpAsImage  := Ini.ReadBool   ('Options', 'JpgBmpAsImage',  False);
    HTMLOpts.ImgWidth       := Ini.ReadInteger('Options', 'ImgWidth',       128);
    HTMLOpts.ImgHeight      := Ini.ReadInteger('Options', 'ImgHeight',      128);
    HTMLOpts.RelativeLink   := Ini.ReadBool   ('Options', 'RelativeLink',   False);
    HTMLOpts.RelativeRoot   := Ini.ReadString ('Options', 'RelativeRoot',   ''  );
    HTMLOpts.HeaderWanted   := Ini.ReadBool   ('Options', 'HeaderWanted',   True);
    HTMLOpts.Bold           := Ini.ReadBool   ('Options', 'Bold',           True);
    HTMLOpts.ClearAtDrag    := Ini.ReadBool   ('Options', 'ClearAtDrag',    True);

    HTMLOpts.DatesAsText    := Ini.ReadBool   ('Options', 'DatesAsText',    True);
    HTMLOpts.W_Link         := Ini.ReadBool   ('Options', 'W_Link',         True);
    HTMLOpts.W_Path         := Ini.ReadBool   ('Options', 'W_Path',         True);
    HTMLOpts.W_Size         := Ini.ReadBool   ('Options', 'W_Size',         True);
    HTMLOpts.W_Created      := Ini.ReadBool   ('Options', 'W_Created',      True);
    HTMLOpts.W_Changed      := Ini.ReadBool   ('Options', 'W_Changed',      True);
    HTMLOpts.W_Accessed     := Ini.ReadBool   ('Options', 'W_Accessed',     True);
    HTMLOpts.W_ShortName    := Ini.ReadBool   ('Options', 'W_ShortName',    True);
    HTMLOpts.W_Ext          := Ini.ReadBool   ('Options', 'W_Ext',          True);
    HTMLOpts.W_Existing     := Ini.ReadBool   ('Options', 'W_Existing',     True);
    Result := True;
  finally
    Ini.Free;
  end;
end;

function SaveHtmlOpts(const FileName: AnsiString; var HTMLOpts: THTMLOpts): Boolean;
var
  Ini : TIniFile;
begin
  Result := False;
  Ini := nil; // 08.01.09 P.W
  try
    Ini := TIniFile.Create(FileName);
    Ini.WriteBool   ('Options', 'StayOnTop',      HTMLOpts.StayOnTop);
    Ini.WriteBool   ('Options', 'ExtendedFormat', HTMLOpts.ExtendedFormat);
    Ini.WriteBool   ('Options', 'JpgBmpAsImage',  HTMLOpts.JpgBmpAsImage);
    Ini.WriteInteger('Options', 'ImgWidth',       HTMLOpts.ImgWidth);
    Ini.WriteInteger('Options', 'ImgHeight',      HTMLOpts.ImgHeight);
    Ini.WriteBool   ('Options', 'RelativeLink',   HTMLOpts.RelativeLink);
    Ini.WriteString ('Options', 'RelativeRoot',   HTMLOpts.RelativeRoot);
    Ini.WriteBool   ('Options', 'HeaderWanted',   HTMLOpts.HeaderWanted);
    Ini.WriteBool   ('Options', 'Bold',           HTMLOpts.Bold);
    Ini.WriteBool   ('Options', 'ClearAtDrag',    HTMLOpts.ClearAtDrag);

    Ini.WriteBool   ('Options', 'DatesAsText',    HTMLOpts.DatesAsText);
    Ini.WriteBool   ('Options', 'W_Link',         HTMLOpts.W_Link);
    Ini.WriteBool   ('Options', 'W_Path',         HTMLOpts.W_Path);
    Ini.WriteBool   ('Options', 'W_Size',         HTMLOpts.W_Size);
    Ini.WriteBool   ('Options', 'W_Created',      HTMLOpts.W_Created);
    Ini.WriteBool   ('Options', 'W_Changed',      HTMLOpts.W_Changed);
    Ini.WriteBool   ('Options', 'W_Accessed',     HTMLOpts.W_Accessed);
    Ini.WriteBool   ('Options', 'W_ShortName',    HTMLOpts.W_ShortName);
    Ini.WriteBool   ('Options', 'W_Ext',          HTMLOpts.W_Ext);
    Ini.WriteBool   ('Options', 'W_Existing',     HTMLOpts.W_Existing);
    Result := True;
  finally
    Ini.Free;
  end;
end;

end.
