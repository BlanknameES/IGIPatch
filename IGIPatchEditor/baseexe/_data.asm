;------------------------------------------------------------
; APIs
;------------------------------------------------------------

User32DLL                       dd NULL
ChangeWindowMessageFilter       dd NULL
ChangeWindowMessageFilterEx     dd NULL

UxThemeDLL                      dd NULL
SetWindowTheme                  dd NULL

Shell32DLL                      dd NULL
_ShellExecuteW                  dd NULL

;------------------------------------------------------------
; control handles
;------------------------------------------------------------

hBrushBG        dd NULL
hBrushPanel     dd NULL
hBrushBorder    dd NULL
hBrushFocus     dd NULL
hPenBorder      dd NULL
hFontLabel      dd NULL
hFontValue      dd NULL
hFontButton     dd NULL
hFontSmall      dd NULL
