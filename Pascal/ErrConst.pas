// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*
Modifications:
{24.10.02 P.W}
  add Error_SliceHasNoRoi and Error_RoiNotFound
*)
Unit ErrConst;
INTERFACE
Const
    Error_FileNotFound        =       2;
    Error_NoMemory            =       -1000;
    Error_MemBlockTooLarge    =       -1001;
    Error_NoEMSMemory         =       -1002;
    Error_MacroAlreadyActiv   =       -1003;
    Error_MacroNotFound       =       -1004;
    Error_ExtMacroInvalid     =       -1005;
    Error_WrongMacroVersion   =       -1006;
    Error_CorrDataStructure   =       -1007;
    Error_TempPathNotFound    =       -1008;
    Error_MacroROIinval       =       -1009;  {08.04.97 MW}
    Error_IndexOutOfRange     =       -1200;

    Error_SetDev              =       -3000;
    Error_InitGraphics        =       -3001;

    Error_NoIntegrationArea   =       -4000;
    Error_UnKnownParameter    =       -4001;
    Error_InvalidPeelArea     =       -4002;
    Error_Peel20THNotFound    =       -4003;
    Error_ContNotFound        =       -4105;
    Error_AutoTHNotFound      =       -4106;
    Error_THAutoChanged       =       -4107;
    Error_MenuNotAvail        =       -4108;
    Error_MenuValNotExist     =       -4109;
    Error_InvLoopPrj          =       -4110;
    Error_Peel20UserAbort     =       -4111; {25.11.96 Michael Welsch}
    Error_SliceNotFound       =       -4112; {25.11.96 Michael Welsch}
    Error_SliceHasNoRoi       =       -4113; {24.10.02 P.W}
    Error_RoiNotFound         =       -4114; {24.10.02 P.W}

    Error_DataBlinded         =       -4500;

    Error_NoCallibration      =       -5000;
    Error_SectionGENNotFound  =       -5001;
    Error_TypInfoNotFound     =       -5002;
    Error_InvalidHeadVers     =       -5003;
    Error_ReadPersSliceCol    =       -5004;
    Error_WritePersSliceCol   =       -5005;
    Error_ReadBufferFile      =       -5006;
    Error_InvIMGDATA          =       -5007;
    Error_CTIMGNotSquare      =       -5008;
    Error_CTASCIIinvnum       =       -5010;

    Error_DialogCanceled      =       -6000;
Implementation
  const Unit_Name = 'ErrConst'; // 03.05.24 P.W
{begin}
end.
