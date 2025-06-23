;--------------------------------------------------
; Improved timer resolution
;--------------------------------------------------

bIsAPIAvailable_QPC     dd 0
bIsAPIAvailable_tGT     dd 0

;--------------------------------------------------
; borderless window + debug patches
;--------------------------------------------------

AppContext_tAppContext2 AppContext2_s

;--------------------------------------------------
; borderless window patch
;--------------------------------------------------

Cursor_XSensMult        dd 1.0
Cursor_YSensMult        dd 1.0

;--------------------------------------------------
; display modes patch
;--------------------------------------------------

Config_nScreenBPP       dd 0

;--------------------------------------------------
; widescreen patch
;--------------------------------------------------

Display_vAspectRatio    dd 1.33333337306976318359375 ; 4:3
Display_vRelAspectRatio dd 1.0 ; 4:3 * 0.75
