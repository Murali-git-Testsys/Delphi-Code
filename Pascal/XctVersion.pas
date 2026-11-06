// 16.06.05 P.W
// for common use by FemGlb.pas, Kn_NGlb.pas & Do540Up.pas

Unit XctVersion;

Interface

const
//BuiltMsg                   = '00.61';    // for Kn_NGlb.pas 16.06.05 P.W
//BuiltMsg                   = '00.62';    // for Kn_NGlb.pas 28.09.07 P.W
//BuiltMsg                   = '00.63';    // for Kn_NGlb.pas 09.12.08 P.W
  BuiltMsg                   = '00.64';    // for Kn_NGlb.pas 18.11.09 P.W

  // for Measurement Header via PatInfoRec_ set by (?)FemPrep.pas:
  VersionNrHead              =  6201;      // 26.01.09 P.W        // all before are zero when read from Header


  VersionNrHead_SupOrientDir =  6201;  // do never change! to detect whether or not Orientation Information has been stored in header

  XctCompanyNameMsg     = 'Stratec Medizintechnik GmbH'; // 09.12.08 P.W

//XctVersionMsg         = '6.00 B';   // 16.06.05 P.W
//XctVersionMsg         = '6.00 C';   // 02.02.06 P.W
//XctVersionMsg         = '6.00 D';   // 28.09.07 P.W
//XctVersionMsg         = '6.00 E';   // 29.11.07 P.W
//XctVersionMsg         = '6.00 F';   // 13.12.07 P.W
//XctVersionMsg         = '6.20 A';   // 09.12.08 P.W
//XctVersionMsg         = '6.20 B';   // 27.04.09 P.W
  XctVersionMsg         = '6.20 C';   // 18.11.09 P.W

  XctVersionLongMsg     = 'XCT '+XctVersionMsg;

  XctCopyRightYearMsg   = '1990 ... 2009';               // 07.01.09 P.W

  XctCopyRightShortMsg  = '© '+XctCopyRightYearMsg;      // 09.12.08 P.W
  XctCopyRightLongMsg   = '© '+XctCopyRightYearMsg+' '+XctCompanyNameMsg+'. All rights reserved.'; // 09.12.08 P.W

// further files that contain Version:
//    Install.pas allows update to Info.Eng containing version messages:
//         "5.4" "5.5" "6.0" .. "6.9"
//    frmVersionManager.pas
//    several Device.Snr files                (handled by VersionManager)
//    Masks\xxx\Info.xxx files Line 2 and 5   (handled by VersionManager)
//    TKeyAPP.pas: MACROVERSION, MinMacroVersSupported

(*   Info from Kn_NGlb:
***************************************************************************
{ BUILT         =       '00.26'; {26.11.97 MW}
{ BUILT         =       '00.55'; {19.09.00 P.W}
{ BUILT         =       '00.56'; {25.09.01 P.W}
{ BUILT         =       '00.57'; {23.10.01 P.W}
{ BUILT         =       '00.58'; {19.02.02 P.W}
{ BUILT         =       '00.59'; {08.07.02 P.W}
//BUILT         =       '00.60'; {09.10.02 P.W}
//  BUILT         =    BuiltMsg; // 16.06.05 P.W
***************************************************************************
{ Version       :       String10    =       '5.40 A'; {06.11.96 Michael Welsch}
{ Version       :       String10    =       '5.41 A'; {07.07.99 P.W}
{ Version       :       String10    =       '5.50 A'; {19.09.00 P.W}
{ Version       :       String10    =       '5.50 B'; {25.09.01 P.W}
   // --- MacroVersion 2.2 !
{ Version       :       String10    =       '5.50 C'; {23.10.01 P.W}
{ Version       :       String10    =       '5.50 D'; {08.07.02 P.W}
{ Version       :       String10    =       '5.50 E'; {09.10.02 P.W}
{ Version       :       String10    =       '5.50E0'; {21.10.02 P.W}
{ Version       :       String10    =       '5.50 E'; {21.10.02 P.W}
//Version       :       String10    =       '6.00 B'; {09.03.05 P.W}
//  Version       :       String10    = X c t VersionMsg; //16.06.05 P.W
//  ^--- duplicates: FemGlb.pas GlbVersStr, Kn_NGlb.pas Version & Do540Up.pas ParamVersion!
***************************************************************************
*)

(*   Info from TKeyAPP.pas:
***************************************************************************
    {MACROVERSION       :  tMacroVersion ='VER 2.1';}
     MACROVERSION       :  tMacroVersion ='VER 2.2'; {23.10.01 P.W}
       {^-- "VER 2.2" signals additional ParFilterInfo stored}
     MinMacroVersSupported               ='VER 2.1'; {23.10.01 P.W}
     MinMacroVersParFilterInfo           ='VER 2.2'; {23.10.01 P.W}
***************************************************************************
*)



Implementation
  const Unit_Name = 'XctVersion'; // 03.05.24 P.W

end.