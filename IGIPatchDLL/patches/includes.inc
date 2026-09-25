;------------------------------------------------------------
; proxy hooks
;------------------------------------------------------------

ENUM_CURRENT_SETTINGS   = -1

CCHDEVICENAME   = 32
CCHFORMNAME     = 32

struct POINTL

        x       dd ?
        y       dd ?
ends

struct DEVMODEA

        dmDeviceName            rb CCHDEVICENAME
        dmSpecVersion           dw ?
        dmDriverVersion         dw ?
        dmSize                  dw ?
        dmDriverExtra           dw ?
        dmFields                dd ?
        union
            struct
                dmOrientation   dw ?
                dmPaperSize     dw ?
                dmPaperLength   dw ?
                dmPaperWidth    dw ?
            ends
            dmPosition          POINTL
        ends
        dmScale                 dw ?
        dmCopies                dw ?
        dmDefaultSource         dw ?
        dmPrintQuality          dw ?
        dmColor                 dw ?
        dmDuplex                dw ?
        dmYResolution           dw ?
        dmTTOption              dw ?
        dmCollate               dw ?
        dmFormName              rb CCHFORMNAME
        dmLogPixels             dw ?
        dmBitsPerPel            dd ?
        dmPelsWidth             dd ?
        dmPelsHeight            dd ?
        dmDisplayFlags          dd ?
        dmDisplayFrequency      dd ?
        dmICMMethod             dd ?
        dmICMIntent             dd ?
        dmMediaType             dd ?
        dmDitherType            dd ?
        dmReserved1             dd ?
        dmReserved2             dd ?
ends

struct DEVMODEW

        dmDeviceName            rw CCHDEVICENAME
        dmSpecVersion           dw ?
        dmDriverVersion         dw ?
        dmSize                  dw ?
        dmDriverExtra           dw ?
        dmFields                dd ?
        union
            struct
                dmOrientation   dw ?
                dmPaperSize     dw ?
                dmPaperLength   dw ?
                dmPaperWidth    dw ?
            ends
            dmPosition          POINTL
        ends
        dmScale                 dw ?
        dmCopies                dw ?
        dmDefaultSource         dw ?
        dmPrintQuality          dw ?
        dmColor                 dw ?
        dmDuplex                dw ?
        dmYResolution           dw ?
        dmTTOption              dw ?
        dmCollate               dw ?
        dmFormName              rw CCHFORMNAME
        dmLogPixels             dw ?
        dmBitsPerPel            dd ?
        dmPelsWidth             dd ?
        dmPelsHeight            dd ?
        dmDisplayFlags          dd ?
        dmDisplayFrequency      dd ?
        dmICMMethod             dd ?
        dmICMIntent             dd ?
        dmMediaType             dd ?
        dmDitherType            dd ?
        dmReserved1             dd ?
        dmReserved2             dd ?
ends

;------------------------------------------------------------
; shared functions
;------------------------------------------------------------

struct real32x2_t

        vX              dd ?
        vY              dd ?
ends

struct real32x3_t

        vX              dd ?
        vY              dd ?
        vZ              dd ?
ends

struct real32x4_t

        tX              real32x2_t
        tY              real32x2_t
ends

struct real32x9_t

        tX              real32x3_t
        tY              real32x3_t
        tZ              real32x3_t
        nOps            dd ?
ends

struct real64x2_t

        vX              dq ?
        vY              dq ?
ends

struct real64x3_t

        vX              dq ?
        vY              dq ?
        vZ              dq ?
ends

;------------------------------------------------------------
; CDCheckPatch
;------------------------------------------------------------

;------------------------------------------------------------
; TimerTaskPatch
;------------------------------------------------------------

;------------------------------------------------------------
; MouseCursorPatch
;------------------------------------------------------------

;------------------------------------------------------------
; BorderlessPatch
;------------------------------------------------------------

;------------------------------------------------------------
; DisplayModesFix
;------------------------------------------------------------

define MAXDISPLAYDEVICES 5
define MAXDISPLAYMODES 64 ; ListBox_t is already limited to 64 entries

struct DisplayDevice_t ; must be multiplier of 4

        zIdentifier     db 128 dup(?)
        zDesc           db 128 dup(?)
ends

struct ConfigDisplayMode_s

        nWidth          dd ?
        nHeight         dd ?
        nDepth          dd ?
ends

struct ConfigDisplayDevice_s

        tDisplayDevice          DisplayDevice_t
        nNumDisplayModes        dd ?
        tDisplayModeList        ConfigDisplayMode_s
                                rb sizeof.ConfigDisplayMode_s * (MAXDISPLAYMODES-1)
        nDefDisplayModeID       dd ?
        tDefDisplayMode         ConfigDisplayMode_s
ends

define MINDISPLAYMODEWIDTH 640
define MINDISPLAYMODEHEIGHT 480
define MINDISPLAYMODEDEPTH 16

;------------------------------------------------------------
; WidescreenPatch
;------------------------------------------------------------

;------------------------------------------------------------
; DebugFeaturesPatch
;------------------------------------------------------------

;------------------------------------------------------------
; MainMenuPatch
;------------------------------------------------------------

;------------------------------------------------------------
; NewFPSLimiterPatch
;------------------------------------------------------------

NFL_FLOW_PHASE_NONE     = 0
NFL_FLOW_PHASE_RUN      = 1
NFL_FLOW_PHASE_INTERP   = 2
NFL_FLOW_PHASE_DRAW     = 3

NFL_FLOW_PHASE_MASK_NONE    = 0
NFL_FLOW_PHASE_MASK_RUN     = 1 shl 0
NFL_FLOW_PHASE_MASK_INTERP  = 1 shl 1
NFL_FLOW_PHASE_MASK_DRAW    = 1 shl 2

struct DynCubeObjInterpData_s

        nTicks          dd ?
                        dd ? ; padding
        tOldPos         real64x3_t
ends

struct DrawRigidMeshContext2_t

        IsDoApplyInterp dd ?
                        dd ? ; padding
        tInterpPos      real64x3_t
ends

struct DrawBoneMeshContext_t

        IsDoApplyInterp dd ?
                        dd ? ; padding
        tInterpPos      real64x3_t
ends

;struct DrawSplineMeshContext2_t
;
;        IsDoApplyInterp dd ?
;                        dd ? ; padding
;        tInterpPos      real64x3_t
;ends
