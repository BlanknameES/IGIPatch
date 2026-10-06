;------------------------------------------------------------
; APIs
;------------------------------------------------------------

DLL_Kernel32                        du 'Kernel32.dll',0
PROC_AddVectoredExceptionHandler    db 'AddVectoredExceptionHandler',0

DLL_User32                          du 'User32.dll',0
PROC_SetProcessDPIAware             db 'SetProcessDPIAware',0

;------------------------------------------------------------
; fpu constants
;------------------------------------------------------------

FPU_CONSTS:
; general purpose
.flt__1_0               dd -1.0
.flt__0_5               dd -0.5
.flt_0_0                dd 0.0
.flt_0_5                dd 0.5
.flt_1_0                dd 1.0
