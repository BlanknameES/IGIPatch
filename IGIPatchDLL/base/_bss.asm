;--------------------------------------------------
; version detection stuff

PMI_IGIExe              PATCHMODULEINFO

GameVersionID           rd 1

;--------------------------------------------------
; ini file stuff

ini_filename            rw MAX_PATH

ini_main_enable         rd 1

ini_opts_nocdcheck      rd 1
ini_opts_timerspatch    rd 1
ini_opts_windowedfix    rd 1
ini_opts_cursorfix      rd 1
ini_opts_borderless     rd 1
ini_opts_resolutions    rd 1
ini_opts_widescreen     rd 1
ini_opts_debugpatch     rd 1
ini_opts_mainmenures    rd 1
ini_opts_dpiawareness   rd 1

ini_sett_resolutionsbpp rd 1

ini_sett_mainmenuresx   rd 1
ini_sett_mainmenuresy   rd 1
ini_sett_mainmenuresbpp rd 1

;--------------------------------------------------
; Improved timer resolution
;--------------------------------------------------

Timer_lpCount           rq 1 ;LARGE_INTEGER
uiMaxSysTimerRes        rd 1
Timer_nStartTime        rd 1
