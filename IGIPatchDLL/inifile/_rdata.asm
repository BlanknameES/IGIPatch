;------------------------------------------------------------
; fpu constants
;------------------------------------------------------------

FPU_CONSTS.inifile:
; VerifyIniSettings
.flt_100_0              dd 100.0

;------------------------------------------------------------
; IniFile strings
;------------------------------------------------------------

; patch
ini_sec_patch           du 'Patch',0
ini_key_enabled         du 'Enabled',0
ini_key_debug           du 'Debug',0

; modules
ini_sec_modules         du 'Modules',0
ini_key_cdcheck         du 'CDCheckPatch',0
ini_key_timertask       du 'TimerTaskPatch',0
ini_key_mousecursor     du 'MouseCursorPatch',0
ini_key_borderless      du 'BorderlessPatch',0
ini_key_displaymodes    du 'DisplayModesFix',0
ini_key_widescreen      du 'WidescreenPatch',0
ini_key_debugfeatures   du 'DebugFeaturesPatch',0
ini_key_mainmenu        du 'MainMenuPatch',0
ini_key_dpiawareness    du 'DPIAwarenessPatch',0
ini_key_newfpslimiter   du 'NewFPSLimiterPatch',0

; settings (ini_key_borderless)
ini_key_blp_scalingmode du 'WindowScalingMode',0

; settings (ini_key_widescreen)
ini_key_wsp_vp_scaling  du 'ViewportScalingMode',0
ini_key_wsp_vp_fov_per  du 'ViewportFOVPercent',0

; settings (ini_key_debugfeatures)
ini_key_dfp_multiinst   du 'AllowMultiInstance',0

; settings (ini_key_mainmenu)
ini_key_mmp_width       du 'MainMenuScreenWidth',0
ini_key_mmp_height      du 'MainMenuScreenHeight',0
ini_key_mmp_bpp         du 'MainMenuScreenBPP',0
ini_key_mmp_bg_color_r  du 'MMBackgroundColorCodeRed',0
ini_key_mmp_bg_color_g  du 'MMBackgroundColorCodeGreen',0
ini_key_mmp_bg_color_b  du 'MMBackgroundColorCodeBlue',0
ini_key_mmp_bg_scaling  du 'MMBackgroundScalingMode',0
ini_key_mmp_bg_fx_on    du 'MMBackgroundFXEnabled',0

; settings (ini_key_newfpslimiter)
ini_key_nfl_timingapi   du 'TimingAPIID',0
ini_key_nfl_inputrate   du 'InputUpdateRate',0
ini_key_nfl_renderfps   du 'MaxRenderFPS',0
ini_key_nfl_en_interp   du 'EnableInterpolation',0
ini_key_nfl_fpscounter  du 'ShowFPSCounter',0
ini_key_nfl_mousesensx  du 'MouseSensitivityMultX',0
ini_key_nfl_mousesensy  du 'MouseSensitivityMultY',0
ini_key_nfl_maxmousesen du 'SliderMaxMouseSensMult',0
