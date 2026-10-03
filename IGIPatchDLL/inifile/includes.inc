;------------------------------------------------------------
; Unicode
;------------------------------------------------------------

IniFile_GetSettingsFileName equ IniFile_GetSettingsFileNameW

;------------------------------------------------------------
; IniFile struct
;------------------------------------------------------------

struct INIFILE_SEC_PATCH

        Enabled                         dd ?
        Debug                           dd ?
ends

struct INIFILE_SEC_MODULES

        CDCheckPatch                    dd ?
        TimerTaskPatch                  dd ?
        MouseCursorPatch                dd ?
        BorderlessPatch                 dd ?
        DisplayModesFix                 dd ?
        WidescreenPatch                 dd ?
        DebugFeaturesPatch              dd ?
        MainMenuPatch                   dd ?
        DPIAwarenessPatch               dd ?
        NewFPSLimiterPatch              dd ?
ends

struct INIFILE_SEC_BLP

        WindowScalingMode               dd ?
ends

struct INIFILE_SEC_WSP

        ViewportScalingMode             dd ?
        ViewportFOVPercent              dd ?
ends

struct INIFILE_SEC_MMP

        MainMenuScreenWidth             dd ?
        MainMenuScreenHeight            dd ?
        MainMenuScreenBPP               dd ?
        MMBackgroundColorR              dd ?
        MMBackgroundColorG              dd ?
        MMBackgroundColorB              dd ?
        MMBackgroundScalingMode         dd ?
        MMBackgroundFXEnabled           dd ?
ends

struct INIFILE_SEC_NFL

        TimingAPIID                     dd ?
        InputUpdateRate                 dd ?
        MaxRenderFPS                    dd ?
        EnableInterpolation             dd ?
        ShowFPSCounter                  dd ?
        MouseSensMultX                  dd ?
        MouseSensMultY                  dd ?
        MaxMouseSensMult                dd ?
ends

struct INIFILE

        Filename                        rw MAX_PATH
        Patch                           INIFILE_SEC_PATCH
        Modules                         INIFILE_SEC_MODULES
        BLP                             INIFILE_SEC_BLP
        WSP                             INIFILE_SEC_WSP
        MMP                             INIFILE_SEC_MMP
        NFL                             INIFILE_SEC_NFL
ends
