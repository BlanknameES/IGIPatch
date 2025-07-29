;--------------------------------------------------
; improved timer resolution
;--------------------------------------------------

bIsAPIAvailable_QPC     dd 0
bIsAPIAvailable_tGT     dd 0

;--------------------------------------------------
; borderless window + debug patches
;--------------------------------------------------

AppContext_tAppContext2 AppContext2_s 0,0

;--------------------------------------------------
; borderless window patch
;--------------------------------------------------

Cursor_XSensMult        dd 1.0
Cursor_YSensMult        dd 1.0

;--------------------------------------------------
; display modes patch
;--------------------------------------------------

Config_nScreenBPP       dd 32

;--------------------------------------------------
; widescreen patch
;--------------------------------------------------

Display_vAspectRatio    dd 1.3333334 ; 4:3
Display_vRelAspectRatio dd 1.0 ; 4:3 * Display_vAspectRatio34
Display_vInvAspectRatio dd 1.0 ; 1 / (4:3 * Display_vAspectRatio34)

;--------------------------------------------------
; custom main menu resolution
;--------------------------------------------------

Display_MMResWidth      dd 640
Display_MMResHeight     dd 480
Display_MMResBPP        dd 16
