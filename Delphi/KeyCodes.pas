// Turbo To Delphi; Replace "Ofs(TypeOf" to "TypeOf"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; "Convert OemToAnsi"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Record to Packed Record; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PStream" to "PStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TStream" to "TStream_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "PObject" to "PObject_TP7"; nothing changed; (02.03.04 P.W)
// Turbo To Delphi; Rename "TObject" to "TObject_TP7"; nothing changed; (02.03.04 P.W)
(*.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
(*+ ~ ~                                                    ) %15nV0.%22v) +*)
(*+ Module Name/Vers.: @(#)KeyCodes; V.:1.00                            ) +*)
(*+ Author           : P.Wueseke                                          +*)
(*+ Date             : 03.07.95                                           +*)
//  Duplicate Code   : compare TKeyApp.pas ExtCodeAry
(*+ Description      : KeyCodes for Turbo-Pascal under Dos                +*)
(*+ ~ ~                                                       : %15d%30w: +*)
(*+ Last modified/By : 19.06.02 / P.Wueseke                               +*)
(*+ Date/Modification: -                                                  +*)
(*+ Date/Modification: 21.09.95 P.W / TKeyCP                              +*)
(*
{19.06.02 P.W}
  added codes for number keys:
    KCP_0 .. KCP_9 and KCP_NumLeft ...
*)
(*+ Date/Modification  (end of list)                                      +*)
(*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.*)
Unit KeyCodes;

INTERFACE

Type
  TKeyCP      = Word;    {Kombination of KC1_* and KC2_*}

Const
  KC1_BS      = #$08 ;                       {BackSpace    }
  KC1_TAB     = #$09 ;                       {TAB          }
  KC1_CR      = #$0D ;                       {Carriage Ret.}
  KC1_ESC     = #$1B ;                       {ESCAPE       }
  {=== Function Keys: (former: MOVIT) ===}
 {KC2_        = #$03 ; ??                    {NUL-Zeichen  }
  KC2_STAB    = #$0F ;                       {SHIFT TAB    }
 {KC2_        = #$10 ; ??                    {Alt - Q      }
 {KC2_        = #$11 ; ??                    {Alt - W      }
 {KC2_        = #$12 ; ??                    {Alt - E      }
 {KC2_        = #$13 ; ??                    {Alt - R      }
 {KC2_        = #$14 ; ??                    {Alt - T      }
 {KC2_        = #$15 ; ??                    {Alt - Z Y?   }
 {KC2_        = #$16 ; ??                    {Alt - U      }
 {KC2_        = #$17 ; ??                    {Alt - I      }
 {KC2_        = #$18 ; ??                    {Alt - O      }
 {KC2_        = #$19 ; ??                    {Alt - P      }
 {KC2_        = #$1E ; ??                    {Alt - A      }
 {KC2_        = #$1F ; ??                    {Alt - S      }
 {KC2_        = #$20 ; ??                    {Alt - D      }
 {KC2_        = #$21 ; ??                    {Alt - F      }
 {KC2_        = #$22 ; ??                    {Alt - G      }
 {KC2_        = #$23 ; ??                    {Alt - H      }
 {KC2_        = #$24 ; ??                    {Alt - J      }
 {KC2_        = #$25 ; ??                    {Alt - K      }
 {KC2_        = #$26 ; ??                    {Alt - L      }
 {KC2_        = #$2C ; ??                    {Alt - Y Z?   }
 {KC2_        = #$2D ; ??                    {Alt - X      }
 {KC2_        = #$2E ; ??                    {Alt - C      }
 {KC2_        = #$2F ; ??                    {Alt - V      }
 {KC2_        = #$30 ; ??                    {Alt - B      }
 {KC2_        = #$31 ; ??                    {Alt - N      }
 {KC2_        = #$32 ; ??                    {Alt - M      }
 {KC2_        = #$3A ; ??                    {             }
  KC2_F1      = #$3B ;
  KC2_F2      = #$3C ;
  KC2_F3      = #$3D ;
  KC2_F4      = #$3E ;
  KC2_F5      = #$3F ;
  KC2_F6      = #$40 ;
  KC2_F7      = #$41 ;
  KC2_F8      = #$42 ;
  KC2_F9      = #$43 ;
  KC2_F10     = #$44 ;
 {KC2_F11     = #$45 ; {??}
 {KC2_F12     = #$46 ; {??}
  KC2_Pos1    = #$47 ;                       {      POS1   }
  KC2_Up      = #$48 ;                       {      UP     }
  KC2_PgUp    = #$49 ;                       {      PGUP   }
 {KC2_        = #$4A ; ??                    {             }
  KC2_Left    = #$4B ;                       {      LEFT   }
 {KC2_        = #$4C ; ??                    {             }
  KC2_Right   = #$4D ;                       {      RIGHT  }
 {KC2_        = #$4E ; ??                    {             }
  KC2_End     = #$4F ;                       {      ENDE   }
  KC2_Dwn     = #$50 ;                       {      DWN    }
  KC2_PgDwn   = #$51 ;                       {      PGDWN  }
  KC2_Ins     = #$52 ;                       {      INS    }
  KC2_Del     = #$53 ;                       {      DEL    }
  KC2_SF1     = #$54 ;
  KC2_SF2     = #$55 ;
  KC2_SF3     = #$56 ;
  KC2_SF4     = #$57 ;
  KC2_SF5     = #$58 ;
  KC2_SF6     = #$59 ;
  KC2_SF7     = #$5A ;
  KC2_SF8     = #$5B ;
  KC2_SF9     = #$5C ;
  KC2_SF10    = #$5D ;
  KC2_CF1     = #$5E ;
  KC2_CF2     = #$5F ;
  KC2_CF3     = #$60 ;
  KC2_CF4     = #$61 ;
  KC2_CF5     = #$62 ;
  KC2_CF6     = #$63 ;
  KC2_CF7     = #$64 ;
  KC2_CF8     = #$65 ;
  KC2_CF9     = #$66 ;
  KC2_CF10    = #$67 ;
  KC2_AF1     = #$68 ;
  KC2_AF2     = #$69 ;
  KC2_AF3     = #$6A ;
  KC2_AF4     = #$6B ;
  KC2_AF5     = #$6C ;
  KC2_AF6     = #$6D ;
  KC2_AF7     = #$6E ;
  KC2_AF8     = #$6F ;
  KC2_AF9     = #$70 ;
  KC2_AF10    = #$71 ;
 {KC2_        = #$72 ; ??                    {Ctrl PrtScr  }
  KC2_CLeft   = #$73 ;                       {CRTL  LEFT   }
  KC2_CRight  = #$74 ;                       {CRTL  RIGHT  }
  KC2_CEnd    = #$75 ;                       {CRTL  ENDE   }
  KC2_CPgDwn  = #$76 ;                       {CRTL  PGDWN  }
  KC2_CPos1   = #$77 ;                       {CRTL  POS1   }
  KC2_CPgUp   = #$84 ;                       {CRTL  PGUP   }
  KC2_F11     = #$85 ;  // 03.02.09 P.W
 {KC2_F11     = #$85 ; ??                    {F11          }
 {KC2_F12     = #$86 ; ??                    {F12          }
 {KC2_SF11    = #$87 ; ??                    {Shift F11    }
 {KC2_SF12    = #$88 ; ??                    {Shift F12    }
 {KC2_CF11    = #$89 ; ??                    {Ctrl  F11    }
 {KC2_CF12    = #$8A ; ??                    {Ctrl  F12    }
 {KC2_AF11    = #$8B ; ??                    {Alt   F11    }
 {KC2_AF12    = #$8C ; ??                    {Alt   F12    }
 {KC2_        = #$8D ; ??                    {             }
 {KC2_        = #$8E ; ??                    {             }
 {KC2_        = #$8F ; ??                    {             }

 {-------------------------------------------------------------------}

  KCP_Space   = $2000 ;                       {"Space"      } // 20.06.05 P.W
  {v--- since 19.06.02 P.W ---}
  KCP_0       = $3000 ;                       {"0"          }
  KCP_1       = $3100 ;                       {"1"          }
  KCP_2       = $3200 ;                       {"2"          }
  KCP_3       = $3300 ;                       {"3"          }
  KCP_4       = $3400 ;                       {"4"          }
  KCP_5       = $3500 ;                       {"5"          }
  KCP_6       = $3600 ;                       {"6"          }
  KCP_7       = $3700 ;                       {"7"          }
  KCP_8       = $3800 ;                       {"8"          }
  KCP_9       = $3900 ;                       {"9"          }
  KCP_NumIns  = KCP_0 ;                       {"0"->"Ins"   }
  KCP_NumEnd  = KCP_1 ;                       {"1"->"End"   }
  KCP_NumDwn  = KCP_2 ;                       {"2"->"Dwn"   }
  KCP_NumPgDwn= KCP_3 ;                       {"3"->"PgDwn" }
  KCP_NumLeft = KCP_4 ;                       {"4"->"Left"  }
  KCP_Num5    = KCP_5 ;                       {"5"->"---"   }
  KCP_NumRight= KCP_6 ;                       {"6"->"Right" }
  KCP_NumPos1 = KCP_7 ;                       {"7"->"Pos1"  }
  KCP_NumUp   = KCP_8 ;                       {"8"->"Up"    }
  KCP_NumPgUp = KCP_9 ;                       {"9"->"PgUp"  }
  {^--- since 19.06.02 P.W ---}
  KCP_BS      = $0800 ;                       {BackSpace    }
  KCP_TAB     = $0900 ;                       {TAB          }
  KCP_CR      = $0D00 ;                       {Carriage Ret.}
  KCP_ESC     = $1B00 ;                       {ESCAPE       }
  KCP_CtrlP   = $1000 ;                       {Control P    }
  {=== Function Keys: (former: MOVIT) ===}
 {KCP_        = $0003 ; ??                    {NUL-Zeichen  }
  KCP_STAB    = $000F ;                       {SHIFT TAB    }
 {KCP_        = $0010 ; ??                    {Alt - Q      }
 {KCP_        = $0011 ; ??                    {Alt - W      }
 {KCP_        = $0012 ; ??                    {Alt - E      }
 {KCP_        = $0013 ; ??                    {Alt - R      }
 {KCP_        = $0014 ; ??                    {Alt - T      }
 {KCP_        = $0015 ; ??                    {Alt - Z Y?   }
 {KCP_        = $0016 ; ??                    {Alt - U      }
 {KCP_        = $0017 ; ??                    {Alt - I      }
 {KCP_        = $0018 ; ??                    {Alt - O      }
 {KCP_        = $0019 ; ??                    {Alt - P      }
 {KCP_        = $001E ; ??                    {Alt - A      }
 {KCP_        = $001F ; ??                    {Alt - S      }
 {KCP_        = $0020 ; ??                    {Alt - D      }
 {KCP_        = $0021 ; ??                    {Alt - F      }
 {KCP_        = $0022 ; ??                    {Alt - G      }
 {KCP_        = $0023 ; ??                    {Alt - H      }
 {KCP_        = $0024 ; ??                    {Alt - J      }
 {KCP_        = $0025 ; ??                    {Alt - K      }
 {KCP_        = $0026 ; ??                    {Alt - L      }
 {KCP_        = $002C ; ??                    {Alt - Y Z?   }
 {KCP_        = $002D ; ??                    {Alt - X      }
 {KCP_        = $002E ; ??                    {Alt - C      }
 {KCP_        = $002F ; ??                    {Alt - V      }
 {KCP_        = $0030 ; ??                    {Alt - B      }
 {KCP_        = $0031 ; ??                    {Alt - N      }
 {KCP_        = $0032 ; ??                    {Alt - M      }
 {KCP_        = $003A ; ??                    {             }
  KCP_F1      = $003B ;
  KCP_F2      = $003C ;
  KCP_F3      = $003D ;
  KCP_F4      = $003E ;
  KCP_F5      = $003F ;
  KCP_F6      = $0040 ;
  KCP_F7      = $0041 ;
  KCP_F8      = $0042 ;
  KCP_F9      = $0043 ;
  KCP_F10     = $0044 ;
 {KCP_F11     = $0045 ; {??}
 {KCP_F12     = $0046 ; {??}
  KCP_Pos1    = $0047 ;                       {      POS1   }
  KCP_Up      = $0048 ;                       {      UP     }
  KCP_PgUp    = $0049 ;                       {      PGUP   }
 {KCP_        = $004A ; ??                    {             }
  KCP_Left    = $004B ;                       {      LEFT   }
 {KCP_        = $004C ; ??                    {             }
  KCP_Right   = $004D ;                       {      RIGHT  }
 {KCP_        = $004E ; ??                    {             }
  KCP_End     = $004F ;                       {      ENDE   }
  KCP_Dwn     = $0050 ;                       {      DWN    }
  KCP_PgDwn   = $0051 ;                       {      PGDWN  }
  KCP_Ins     = $0052 ;                       {      INS    }
  KCP_Del     = $0053 ;                       {      DEL    }
  KCP_SF1     = $0054 ;
  KCP_SF2     = $0055 ;
  KCP_SF3     = $0056 ;
  KCP_SF4     = $0057 ;
  KCP_SF5     = $0058 ;
  KCP_SF6     = $0059 ;
  KCP_SF7     = $005A ;
  KCP_SF8     = $005B ;
  KCP_SF9     = $005C ;
  KCP_SF10    = $005D ;
  KCP_CF1     = $005E ;
  KCP_CF2     = $005F ;
  KCP_CF3     = $0060 ;
  KCP_CF4     = $0061 ;
  KCP_CF5     = $0062 ;
  KCP_CF6     = $0063 ;
  KCP_CF7     = $0064 ;
  KCP_CF8     = $0065 ;
  KCP_CF9     = $0066 ;
  KCP_CF10    = $0067 ;
  KCP_AF1     = $0068 ;
  KCP_AF2     = $0069 ;
  KCP_AF3     = $006A ;
  KCP_AF4     = $006B ;
  KCP_AF5     = $006C ;
  KCP_AF6     = $006D ;
  KCP_AF7     = $006E ;
  KCP_AF8     = $006F ;
  KCP_AF9     = $0070 ;
  KCP_AF10    = $0071 ;
 {KCP_        = $0072 ; ??                    {Ctrl PrtScr  }
  KCP_CLeft   = $0073 ;                       {CRTL  LEFT   }
  KCP_CRight  = $0074 ;                       {CRTL  RIGHT  }
  KCP_CEnd    = $0075 ;                       {CRTL  ENDE   }
  KCP_CPgDwn  = $0076 ;                       {CRTL  PGDWN  }
  KCP_CPos1   = $0077 ;                       {CRTL  POS1   }
  KCP_CPgUp   = $0084 ;                       {CRTL  PGUP   }
 {KCP_F11     = $0085 ; ??                    {F11          }
 {KCP_F12     = $0086 ; ??                    {F12          }
 {KCP_SF11    = $0087 ; ??                    {Shift F11    }
 {KCP_SF12    = $0088 ; ??                    {Shift F12    }
 {KCP_CF11    = $0089 ; ??                    {Ctrl  F11    }
 {KCP_CF12    = $008A ; ??                    {Ctrl  F12    }
 {KCP_AF11    = $008B ; ??                    {Alt   F11    }
 {KCP_AF12    = $008C ; ??                    {Alt   F12    }
 {KCP_        = $008D ; ??                    {             }
 {KCP_        = $008E ; ??                    {             }
 {KCP_        = $008F ; ??                    {             }

Implementation
  const Unit_Name = 'KeyCodes'; // 03.05.24 P.W

end.
