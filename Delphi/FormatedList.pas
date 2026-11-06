unit FormatedList;
// created: 25.03.08 P.W
// purpose: support improved formating of TrendParameter
// used by UtAna.pas

interface

uses
  ClipBrdUse,
  Classes, SysUtils, Math,
  GlbType, TypesUse;

function FormatedTrendParamList(const TPL : TStringList; var ParNames, ParUnits: String): TStringList;

Implementation
  const Unit_Name = 'FormatedList'; // 03.05.24 P.W

function FormatedTrendParamList(const TPL : TStringList; var ParNames, ParUnits: String): TStringList;
{ format lines like these:
Names
Units
CalcBd:
Threshold:280[mg/ccm];Trab.area:45.0%;Contourmode:1;Peelmode:1;Filters2:-;Voxelsize:0.4995[mm];
Threshold:280[mg/ccm];Trab.area:40.8%;Contourmode:1;Peelmode:1;Filters2:F05F08;Voxelsize:0.4995[mm];
Threshold:280[mg/ccm];conc.peel:5.0%;Contourmode:1;Peelmode:4;Innerthreshold:399[mg/ccm];Usefilter:TRUE;Filters2:-;Voxelsize:0.4995[mm];
CortBd:
Threshold:780[mg/ccm];Separationmode:1;Filters2:-;Voxelsize:0.4995[mm];
Threshold:780[mg/ccm];Separationmode:4;Innerthreshold:540[mg/ccm];Filters2:-;Voxelsize:0.4995[mm];
SSI:
Threshold:480[mg/ccm];Separationmode:1;Filters2:-;Voxelsize:0.4995[mm];
Threshold:480[mg/ccm];Separationmode:4;Innerthreshold:540[mg/ccm];Filters2:-;Voxelsize:0.4995[mm];
Histo:
C1/P1;Threshold:399[mg/ccm];Trab.area:45.0%;Filters2:-;Voxelsize:0.4995[mm];
C1/P4;I.threshold:399[mg/ccm];Threshold:399[mg/ccm];Peelby:5.0%;Filters2:-;Voxelsize:0.4995[mm];
ConcPeel:
C1;Threshold:280[mg/ccm];Interpolate:ON;Filters2:-;Voxelsize:0.4995[mm];
--------
FieldSeparator := ';';
ValueStart     := ':';
UnitStart      := '[';
for all Lines do:
  Splitt into Fields
    Fields splitt into Name, Value, Unit

for all names have a list of values

}

  procedure DebugData(TPL: TStringList);
  begin
    TPL.Clear;
  //CalcBd:
    TPL.Append('Threshold:280[mg/ccm];Trab.area:45.0%;Contourmode:1;Peelmode:1;Filters2:-;Voxelsize:0.4995[mm];');
    TPL.Append('Threshold:280[mg/ccm];Trab.area:40.8%;Contourmode:1;Peelmode:1;Filters2:F05F08;Voxelsize:0.4995[mm];');
    TPL.Append('Threshold:280[mg/ccm];conc.peel:5.0%;Contourmode:1;Peelmode:4;Innerthreshold:399[mg/ccm];Usefilter:TRUE;Filters2:-;Voxelsize:0.4995[mm];');
  //CortBd, SSI:
    TPL.Append('Threshold:780[mg/ccm];Separationmode:1;Filters2:-;Voxelsize:0.4995[mm];');
    TPL.Append('Threshold:780[mg/ccm];Separationmode:4;Innerthreshold:540[mg/ccm];Filters2:-;Voxelsize:0.4995[mm];');
  //Histo:
    TPL.Append('C1/P1;Threshold:399[mg/ccm];Trab.area:45.0%;Filters2:-;Voxelsize:0.4995[mm];');
    TPL.Append('C1/P4;I.threshold:399[mg/ccm];Threshold:399[mg/ccm];Peelby:5.0%;Filters2:-;Voxelsize:0.4995[mm];');
  //ConcPeel:
    TPL.Append('C1;Threshold:280[mg/ccm];Interpolate:ON;Filters2:-;Voxelsize:0.4995[mm];');
  end;

  function LineToFields(S: String; var Names, Values, Units : TStringList): Integer;

  type
    TInMode = (IM_Start, IM_Value, IM_Unit);
  var
    InMode : TInMode;
    Len, I : Integer;
    Name, Value, aUnit: String;
    AnyStartPos: Integer;

    procedure SetInMode(aPos: Integer; InModeTo: TInMode);
    begin
      case InMode of // mode "from"
        IM_Start:
          begin
            case InModeTo of
              IM_Start:   // Start to Start  : Value ready
                begin
                  Value  := Value + Copy(S, AnyStartPos, aPos-AnyStartPos);
                end;
              IM_Value:   // Start to Value  : Name  ready
                begin
                  Name   := Name  + Copy(S, AnyStartPos, aPos-AnyStartPos);
                end;
              IM_Unit:    // Start to Unit (not expected!)
                begin
                  aUnit  := aUnit + Copy(S, AnyStartPos, aPos-AnyStartPos);
                end;
            end;
          end;
        IM_Value:         // Value to Any    : Value ready
          begin
                  Value := Value + Copy(S, AnyStartPos, aPos-AnyStartPos);
          end;
        IM_Unit:          // Unit  to Any    : Unit ready
          begin
                  aUnit := aUnit + Copy(S, AnyStartPos, aPos-AnyStartPos);
          end;
      end;
      InMode := InModeTo;
      case InModeTo of
        IM_Unit:  AnyStartPos := aPos
        else      AnyStartPos := aPos + 1;
      end;  
    end;

    procedure StartValue(aPos: Integer);
    begin
      SetInMode(aPos, IM_Value);
    end;
    procedure StartUnit(aPos: Integer);
    begin
      SetInMode(aPos, IM_Unit);
    end;
    procedure StartField;
    begin
      Name  := '';
      Value := '';
      aUnit := '';
    end;
    procedure FieldReady(aPos: Integer);
    begin
      Inc(Result);
      SetInMode(aPos, IM_Start);
      if Name = '' then Name := 'Mode';
      Names .Append(''+Name);
      Values.Append(''+Value);
      Units .Append(''+aUnit);

      StartField;
    end;
    procedure InitVars;
    begin
      StartField;
      InMode := IM_Start;
      AnyStartPos := 1;
    end;
  begin
    Result := 0;
    S := Trim(S);
    Len := Length(S);
    if Len > 0 then
    begin
      if (S[Len] <> FixSem) then
      begin
        S := S + FixSem;
        Inc(Len);
      end;

      InitVars;
      for I := 1 to Len do
      begin
        case S[I] of
          '['    : StartUnit(I);
          '%'    : StartUnit(I);
          ':'    : StartValue(I);
          FixSem : FieldReady(I);
        end;
      end;
    end;
  end;

var
  AllNames, AllUnits,
  LNames, LValues, LUnits : TStringList; // Lines  Lists for Names, Values, Units
  AllValues : Array of TStringList;
  ValueLinesCount : Integer;

  procedure InitVars;
  begin
    Result   := TStringList.Create;
    ParNames := '';
    ParUnits := '';
    AllNames := TStringList.Create;
    AllUnits := TStringList.Create;
    LNames   := TStringList.Create;
    LValues  := TStringList.Create;
    LUnits   := TStringList.Create;
    SetLength(AllValues, 0);  // number of Fields = zero; (first Index)
    ValueLinesCount := TPL.Count;   //                          (secoond Index)
  end;

  procedure DoneVars;
  var
    J : Integer;
  begin
    FreeAndNil(AllNames);
    FreeAndNil(AllUnits);
    FreeAndNil(LNames);
    FreeAndNil(LValues);
    FreeAndNil(LUnits);
    for J := 0 to Length(AllValues) -1 do
      FreeAndNil(AllValues[J]);
    SetLength(AllValues, 0);  
  end;

  procedure FieldAppend(LineIdx: Integer; Name, Value, aUnit: String);
  var
    Idx, LenV, E : Integer;
  begin
    LenV := Length(AllValues);
    Idx  := AllNames.IndexOf(Name);
    if (Idx < 0) then
    begin  // new Field
      Idx := AllNames.Add(Name);
             AllUnits.Add(aUnit);
      Inc(LenV);
      SetLength(AllValues, LenV);
      AllValues[LenV -1] := TStringList.Create;

      for E := 0 to ValueLinesCount -1 do
          AllValues[LenV -1].Append('');

    end;
    AllValues[Idx][LineIdx]:=Value;
  end;

  procedure PrepareResult;
  var
    NumF, F, NumR, R: Integer;
    FLens : TIntArr;
    ResLine : String;
  begin
    Result.Clear;
    ParNames := '';
    ParUnits := '';
    NumF := AllNames.Count;
    if (NumF > 0) then
    begin

      NumR := AllValues[0].Count;

      // --- find each fields longest length
      FLens := IntArrAllZero(NumF);
      for F := 0 to NumF -1 do
      begin
        FLens[F] := Max(FLens[F], Max(Length(AllNames[F]), Length(AllUnits[F])));
        for R := 0 to NumR -1 do
          FLens[F] := Max(FLens[F], Length(AllValues[F][R]));
        Inc(FLens[F]);
      end;

      // --- fill each field with its longest length:
      // ParNames and ParUnits:
      for F := 0 to NumF -1 do
      begin
        ParNames := Format('%s%'+IntToStr(FLens[F])+'s', [ParNames, AllNames[F]]);
        ParUnits := Format('%s%'+IntToStr(FLens[F])+'s', [ParUnits, AllUnits[F]]);
      end;
      ParNames := ParNames + FixSem;
      ParUnits := ParUnits + FixSem;

      // Result Lines:
      for R := 0 to NumR -1 do
      begin
        ResLine := '';
        for F := 0 to NumF -1 do
          ResLine := Format('%s%'+IntToStr(FLens[F])+'s', [ResLine, AllValues[F][R]]);
        Result.Append(ResLine + FixSem);
      end;
    end;
  end;

  procedure DebToClipBoard(I : Integer);
  begin
    AppendToClipboard(
      Format(
        '=== %3d ==='+sLineBreak+
        '%s'+sLineBreak+
        '--- Nam ---'+sLineBreak+
        '%s'+
        '--- Val ---'+sLineBreak+
        '%s'+
        '--- Uni ---'+sLineBreak+
        '%s',
        [
        I,                  // %3d
        TPL[I],             // %s
        LNames.Text,        // %s
        LValues.Text,       // %s
        LUnits.Text         // %s
        ]));
  end;

var
  L, F, LineFieldCount : Integer;
begin
  InitVars;
//Result.Text :=  TPL.Text;
//Exit;
//DebugData(TPL);
//ClearClipboard;
  for L := 0 to ValueLinesCount -1 do
  begin
    LineFieldCount := LineToFields(TPL[L], LNames, LValues, LUnits);
//  DebToClipBoard(L);
    for F := 0 to LineFieldCount -1 do
      FieldAppend(L, LNames[F], LValues[F], LUnits[F]);
    LNames .Clear;
    LValues.Clear;
    LUnits .Clear;
  end;

  PrepareResult;
  DoneVars;
end;


end.
