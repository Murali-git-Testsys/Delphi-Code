//
// CIN source file
//

//#include "extcode.h"

// typedefs
Unit EE_Param;

Interface

uses
  DebugUnit,       // 03.05.24 P.W
  InitFinal_List,  // 03.05.24 P.W
  GlbType;   // 12.03.09 P.W: EE_Param basic types moved to GlbType

const
  AreaUnknownValue = 4294967296.0;

Type
  // Structure of parameters in Device XCT2010 Firmware stored in EE_Prom
  // structure is from CIN source file created by LV from EE_ALL.CTL structure
  // and adapted to Delphi
  // The structure is defined in three places:
  //  a) for Labview  in EE_ALL.CTL
  //  b) for Firmware in INIT_03.h
  //  c) for Delphi   in EE_Param.pas
  // BUT look out: the definition in INIT_03.H differs in this point:
  //   Collimations (struct ee_collims_type) the position of ee_collim_type
  //     as Collim_array has to be behind change_pos_z
  //     so long no problem as the firmware make no use of the content of ee_collims_type

  TEE_Special               = Packed Record
    crc_checksum            : uInt16;
    ee_mem_size             : uInt16;
    operationTimeDev1S      : uInt32;
    operationTimeDev2S      : uInt32;
    operationTimeXray1S     : uInt32;
    operationTimeXray2S     : uInt32;
    reserved1               : uInt32;
    reserved2               : uInt32;
    reserved3               : uInt32;
  end; // TEE_Special (TD2)

  TEE_Info                  = Packed Record
    ParamVersionMajor       : uInt8;
    ParamVersionMinor       : uInt8;
    BytesUsed               : uInt16;
    DeviceClass2Bytes       : char2;
    SerialNumber            : uInt32;
    ParameterDate           : uInt32;
    ManufacturingDate       : uInt32;
    XCTDEV12Bytes           : char12;
    DeviceName16Bytes       : char16;
    DeviceType12Bytes       : char12;
    DeviceInfo192Bytes      : char192;
  end; // TEE_Info (TD3)

  TEE_Flash                 = Packed Record
    target_type             : uInt16;
    flash_crc               : uInt32;
    flash_sectors_used      : uInt16;
  end; // TEE_Flash (TD4)

  TEE_MotorAxis             = Packed Record
    Contr_KP                : uInt16;
    Contr_KI                : uInt16;
    Contr_IL                : uInt16;
    Contr_KD                : uInt16;
    Steps1Mm                : float32;
    PosToluM                : uInt16;
    PosErrChkuM             : uInt16;
    PosErrStopuM            : uInt16;
    PosMinMm                : int16;
    PosMaxMm                : int16;
    InitOffsMm              : int16;
    InitDir                 : int8;
    VSearchMmS              : uInt8;
    VMoveMmS                : uInt8;
    VMaxMmS                 : uInt8;
    AccMmS2                 : uInt16;
  end; // TEE_MotorAxis (TD6)   // XMotorParameter

  TEE_MotorsCommon          = Packed Record
    MotorSampleTimeuS       : uInt16;
    motor_timeoutS          : uInt16;
    manual_key_select       : uInt16;
    LiDiffVal_X             : int16;
  end; // TEE_MotorsCommon (TD7)

  TEE_SoftRefDeg10          = Packed Record
    HardStop1               : int16;
    HardStop2               : int16;
    SoftRefStart1           : int16;
    SoftRefEnd1             : int16;
    SoftRefStart2           : int16;
    SoftRefEnd2             : int16;
    SoftRefStart3           : int16;
    SoftRefEnd3             : int16;
  end; // TEE_SoftRefDeg10 (TD8)

  TEE_Mot_Params            = Packed Record
    X                       : TEE_MotorAxis;
    Y                       : TEE_MotorAxis;
    Z                       : TEE_MotorAxis;
    MotorsCommon            : TEE_MotorsCommon;
    SoftRefDeg10            : TEE_SoftRefDeg10;
  end; // TEE_Mot_Params (TD5)

  TEE_DeviceOptions         = Packed Record
    BaudrateEnum            : uInt16;
    Options                 : uInt16;
  end; // TEE_DeviceOptions (TD9)

  TEE_DetThresholds         = Packed Record
    det_1                   : uInt8;
    det_2                   : uInt8;
    det_3                   : uInt8;
    det_4                   : uInt8;
    det_5                   : uInt8;
    det_6                   : uInt8;
    det_7                   : uInt8;
    det_8                   : uInt8;
    det_9                   : uInt8;
    det_10                  : uInt8;
    det_11                  : uInt8;
    det_12                  : uInt8;
  end; // TEE_DetThresholds (TD11)

  TEE_Detectors             = Packed Record
    det_thresholds          : TEE_DetThresholds;
    num_det                 : uInt16;
    det_select              : uInt16;
    opt_scan_data           : uInt8;
    scan_data_format        : uInt8;
    det_on_intervalS        : uInt16;
    det_off_intervalS       : uInt16;
    SlicePauseDetOnS        : uInt16;
  end; // TEE_Detector (TD10)

  TEE_XRay                  = Packed Record
    TubePotentialKV         : float32;
    MaxCurrentuA            : uInt16;
    MaxPotentialKV          : uInt16;
    MaxPowerW               : uInt8;
    WaitStableS             : uInt8;
    XRayTimeoutS            : uInt8;
    cmd_idle_timeoutS       : uInt8;
    SlicePauseMinimumS      : uInt16;
  end; // TEE_XRay (TD12)

  TEE_CollimCommon          = Packed Record
    NumOfCollimatons        : uInt8;
    SelectedCollimaton      : uInt8;
    ChangePosXMm10          : int16;
    ChangePosYDeg10         : int16;
    ChangePosZMm10          : int16;
  end; // TEE_CollimCommon (TD14)

  TEE_Collimation           = Packed Record
    Extension3Bytes         : char3;
    Color                   : uInt8;
    dxuM                    : uInt16;
    dzuM                    : uInt16;
    TubeCurrentuA           : uInt16;
    CpsAlarm1S              : uInt32;
    CpsAir1S                : uInt32;
    CpsMinimum1S            : uInt32;
    SlicePauseLimitS        : uInt16;
    SlicePausePerc          : uInt16;
    OffsetCenterMm          : float32;
  end; // TEE_Collimation (TD15)
  PEE_Collimation = ^TEE_Collimation;

  TEE_Collimations          = Packed Record
    CollimCommon            : TEE_CollimCommon;
    A                       : TEE_Collimation;
    B                       : TEE_Collimation;
    C                       : TEE_Collimation;
    D                       : TEE_Collimation;
  end; // TEE_Collimations (TD13)

  TEE_XRayCheck             = Packed Record
    HvOffChkSec_A01S        : uInt8;
    HvOffMaxPot_AKV         : uInt8;
    HvOffMaxCurr_AuA        : uInt8;
    HvOffChkSec_B01S        : uInt8;
    HvOffMaxPot_BKV         : uInt8;
    HvOffMaxCurr_BuA        : uInt8;
    HvOnChkSec_A01S         : int8;
    HvOnMaxDeltaPot_AKV     : uInt8;
    HvOnMaxDeltaCurr_AuA    : uInt8;
    HvOnChkSec_B01S         : uInt8;
    HvOnMaxDeltaPot_BKV     : uInt8;
    HvOnMaxDeltaCurr_BuA    : uInt8;
  end; // TEE_XRayCheck (TD17)

  TEE_DataCheck             = Packed Record
    LnChkMinAtt             : uInt8;
    LnDeltaPercDet          : uInt8;
    LnDeltaPercScan         : uInt8;
    DeltaOffsetLimitQa01Mm  : uInt8;
    DeltaOffsetLimit01Mm    : uInt8;
    DeltaLimitAirLeftRight  : uInt8;
    DeltaPercTime           : uInt8;
    MQLnChk1                : int8;
    MQLnChk2                : int8;
    MQLnChk3                : int8;
    MQOffset1               : int8;
    MQOffset2               : int8;
    MQOffset3               : int8;
    MQRangeChk1             : int8;
    MQRangeChk2             : int8;
    MQRangeChk3             : int8;
  end; // TEE_DataCheck (TD18)

  TEE_Check                 = Packed Record
    XRayCheck               : TEE_XRayCheck;
    DataCheck               : TEE_DataCheck;
  end; // TEE_Check (TD16)

  TEE_Geometry              = Packed Record
    DistSourceCenterMm      : float32;
    Theta_Det1Deg           : float32;
    DeltaThetaSignedDeg     : float32;
    SystemDir               : int8;
    MirrorDir               : int8;
    CtMirrorHoriz           : LVBoolean;
    CtMirrorVert            : LVBoolean;
    SvMirrorHoriz           : LVBoolean;
    SvMirrorVert            : LVBoolean;
  end; // TEE_Geometry (TD19)

  TEE_Measurement           = Packed Record
    MeasOptions             : uInt8;
    SpeedLow                : uInt8;
    MinCounts_V1            : uInt32;
    DiameterMaxMm           : uInt16;
    AddValueMm              : uInt8;
    V0MmS                   : uInt8;
    V1MmS                   : uInt8;
    V2MmS                   : uInt8;
  end; // TEE_Measurement (TD20)

  TEE_Calibration           = Packed Record
    TimeRef1S               : uInt32;
    DeadTimeuS              : float32;
    SlFactorNorm            : float32;
    BeamHard_SF1            : float32;
    BeamHard_SF2            : float32;
    BeamHard_SF3            : float32;
    BeamHard_SF4            : float32;
    XSlope                  : float32;
    XInter                  : float32;
  end; // TEE_Calibration (TD21)

  TEE_Phantoms              = Packed Record
    AR_TypSoftAtt           : uInt16;
    AR_TypBoneAtt           : uInt16;
    StdPh_1_3               : uInt16;
    StdPh_1_3_Tol           : uInt16;
    ConePh_1_2Area          : float32;   // value of 4294967296.0 means unknown
    ConePh_1_2Area_Tol      : float32;
    ConePh_1_3              : uInt16;
    ConePh_1_3_Tol          : uInt16;
    ConePh_2_3              : uInt16;
    ConePh_2_3_Tol          : uInt16;
    ConePh_3_3              : uInt16;
    ConePh_3_3_Tol          : uInt16;
    ConePh_4_3              : uInt16;
    ConePh_4_3_Tol          : uInt16;
    StdPh_QaDays            : uInt8;
    ConePh_QaDays           : uInt8;
    StdPh_QaDate            : uInt32;
    ConePh_QaDate           : uInt32;
  end; // TEE_Phantoms (TD22)

  TEE_Parameter             = Packed Record    // size : 710
    Special                 : TEE_Special;
    Info                    : TEE_Info;
    Flash                   : TEE_Flash;
    Mot_Params              : TEE_Mot_Params;
    DeviceOptions           : TEE_DeviceOptions;
    Detectors               : TEE_Detectors;
    XRay                    : TEE_XRay;
    Collimations            : TEE_Collimations;
    Check                   : TEE_Check;
    Geometry                : TEE_Geometry;
    Measurement             : TEE_Measurement;
    Calibration             : TEE_Calibration;
    Phantoms                : TEE_Phantoms;
	end; // TEE_Parameter  (TD1)

type
  TDeviceKbdType = (DKBD_None,       // 3 bits (2 .. 4)  of Options
                    DKBD_79003_x,
                    DKBD_802_902_x,  // see also Scans0.pas
                    DKBD_Unknown0,
                    DKBD_Unknown1,
                    DKBD_Unknown2,
                    DKBD_Unknown3,
                    DKBD_Unknown4);  // 27.04.09 P.W

  TEE_Param_DeviceOptions = record   // 27.04.09 P.W for use by ReadPar GlbEE_Param_DeviceOptions
    //-------------------------------------------------------------
    Valid           : Boolean;       // True when read from EE_Prom
    //-------------------------------------------------------------
    Ventilator      : Boolean;
    XRayThermometer : Boolean;
    DeviceKbdType   : TDeviceKbdType;
    ManualMoveKey   : Boolean;
    XRayVentilator  : Boolean;
  end;


function  DeviceOptions_Expand(Options: uInt16): TEE_Param_DeviceOptions;  // 27.04.09 P.W

Implementation
  const Unit_Name = 'EE_Param'; // 03.05.24 P.W

function  DeviceOptions_Expand(Options: uInt16): TEE_Param_DeviceOptions;  // 27.04.09 P.W
var
  DKBDPart : Byte;
begin
  FillChar(Result, SizeOf(Result), #0);
  //-------------------------------------------------------------
  Result.Valid := True;
  //-------------------------------------------------------------
  Result.Ventilator      := (Options and (1 shl 0)) <> 0;
  Result.XRayThermometer := (Options and (1 shl 1)) <> 0;
  DKBDPart               := (Options and ($0007 shl 2)) shr 2;
  Result.DeviceKbdType   := TDeviceKbdType(DKBDPart);
  Result.ManualMoveKey   := (Options and (1 shl 5)) <> 0;
  Result.XRayVentilator  := (Options and (1 shl 6)) <> 0;
end;

procedure TestSize;
var
  E : Integer;
  D1 : TEE_Parameter;
begin
  E := Sizeof(TEE_Parameter);
  If (E <> 710) or
     (LongInt(@D1.DeviceOptions.Options) - LongInt(@D1) <> $196) then    // $196 = 406 dec.
  begin
    Writeln('Error in EE_Param.pas definition of TEE_Parameter (enter...)');
    Readln; 
  end;
end;

procedure InitVars_Dll; // 03.05.24 P.W
begin
  Deb1(Unit_Name + '0');
   // none
//  FillChar(, SizeOf(), #0);
  Deb1(Unit_Name + '1');
end;

function Unit_Init(Mode : Integer = 0) : Integer;
// Init  part  into  function // 03.05.24 P.W
begin
  Result := 0;
  InitVars_Dll; // 03.05.24 P.W
  TestSize;
end;
Initialization
  InitFinal_Add(Unit_Name, Unit_Init);
(* -v--- moved to function Unit_Init // 03.05.24 P.W
  TestSize;
   -^--- moved to function Unit_Init // 03.05.24 P.W *)
end.

