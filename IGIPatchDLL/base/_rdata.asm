num_version_ids         dd 2

build_id0_addr          dd 0x00541ECC
build_id0_pstr          dd build_id0_cstr
build_id1_addr          dd 0x00542624
build_id1_pstr          dd build_id1_cstr

build_id0_cstr          db 'IGIMUTEX',0
build_id1_cstr          db 'IGIMUTEX',0

;--------------------------------------------------

sec_main                du 'Main',0
key_enable              du 'EnablePatch',0
def_enable              dd 1

sec_options             du 'Options',0
key_nocdcheck           du 'RemoveCDCheck',0
def_nocdcheck           dd 1
key_timerspatch         du 'ImprovedTimerResolution',0
def_timerspatch         dd 1
key_windowedfix         du 'FixWindowedCursor',0
def_windowedfix         dd 1
key_cursorfix           du 'FixCursorPrecision',0
def_cursorfix           dd 1

;--------------------------------------------------
; Improved timer resolution
;--------------------------------------------------

TimerAPIError_QPC       db 'QueryPerformanceCounter returned an error.',0
TimerAPIError_tGT       db 'timeGetTime returned an error.',0
