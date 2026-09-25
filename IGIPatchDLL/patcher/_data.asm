hThisExe   dd INVALID_HANDLE_VALUE

;------------------------------------------------------------
; version detection variables
;------------------------------------------------------------

Patcher_uiCurVersionID      dd -1
Patcher_pCurPMIHandle       dd NULL

PMI_IGI_Exe                 PATCHER_MODULE_INFO 0x00400000,NULL,0

;------------------------------------------------------------
; trap handling variables
;------------------------------------------------------------

Patcher_bAddrTrapInstalled  dd FALSE
