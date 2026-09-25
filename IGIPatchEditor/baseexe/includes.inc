include 'win32w.inc'

;------------------------------------------------------------
; Unicode
;------------------------------------------------------------

GetOrLoadLibrary equ GetOrLoadLibraryW
GetModuleFileNameSafe equ GetModuleFileNameSafeW
PathRemoveFileSpec equ PathRemoveFileSpecW
PathCombine equ PathCombineW
PathIsFile equ PathIsFileW
_ShellExecute equ _ShellExecuteW

;------------------------------------------------------------
; Equates
;------------------------------------------------------------

;HINSTANCE equ DWORD
;HWND equ DWORD
;HBRUSH equ DWORD
;HFONT equ DWORD

;------------------------------------------------------------
; VERSIONINFO
;------------------------------------------------------------

VS_FF_RELEASE         = 0x00000000 ; non-standard
VS_FF_DEBUG           = 0x00000001
VS_FF_PRERELEASE      = 0x00000002
VS_FF_PATCHED         = 0x00000004
VS_FF_PRIVATEBUILD    = 0x00000008
VS_FF_INFOINFERRED    = 0x00000010
VS_FF_SPECIALBUILD    = 0x00000020
VS_FFI_FILEFLAGSMASK  = 0x0000003F

;------------------------------------------------------------
; INITCOMMONCONTROLSEX extra constants
;------------------------------------------------------------

ICC_PAGESCROLLER_CLASS  = 1000h
ICC_NATIVEFNTCTL_CLASS  = 2000h
ICC_STANDARD_CLASSES    = 4000h ; v6.0+
ICC_LINK_CLASS          = 8000h ; v6.0+

ICC_ALL_CLASSES         = 0xFFFF

;------------------------------------------------------------
; GetDeviceCaps
;------------------------------------------------------------

HORZRES                 = 8
VERTRES                 = 10

;------------------------------------------------------------
; OPENFILENAME (updated)
;------------------------------------------------------------

struct _OPENFILENAME

        lStructSize             dd ?
        hwndOwner               dd ?
        hInstance               dd ?
        lpstrFilter             dd ?
        lpstrCustomFilter       dd ?
        nMaxCustFilter          dd ?
        nFilterIndex            dd ?
        lpstrFile               dd ?
        nMaxFile                dd ?
        lpstrFileTitle          dd ?
        nMaxFileTitle           dd ?
        lpstrInitialDir         dd ?
        lpstrTitle              dd ?
        Flags                   dd ?
        nFileOffset             dw ?
        nFileExtension          dw ?
        lpstrDefExt             dd ?
        lCustData               dd ?
        lpfnHook                dd ?
        lpTemplateName          dd ?
        ;lpEditInfo              dd ? ; #ifdef _MAC
        ;lpstrPrompt             dd ? ; #ifdef _MAC
        pvReserved              dd ?
        dwReserved              dd ?
        FlagsEx                 dd ?
ends

;------------------------------------------------------------
; Winuser.h
;------------------------------------------------------------

WM_COPYGLOBALDATA = 0x0049

;------------------------------------------------------------
; ChangeWindowMessageFilterEx
;------------------------------------------------------------

MSGFLT_RESET = 0
MSGFLT_ALLOW = 1
MSGFLT_DISALLOW = 2

;------------------------------------------------------------
; ChangeWindowMessageFilter
;------------------------------------------------------------

MSGFLT_ADD = 1
MSGFLT_REMOVE = 2

;------------------------------------------------------------
; MENUINFO
;------------------------------------------------------------

struct MENUINFO
        cbSize          dd ?
        fMask           dd ?
        dwStyle         dd ?
        cyMax           dd ?
        hbrBack         dd ?
        dwContextHelpID dd ?
        dwMenuData      dd ?
ends

MIM_STYLE               = 0x00000010
MNS_NOTIFYBYPOS         = 0x08000000

;------------------------------------------------------------
; FontQuality Enum extra constants
;------------------------------------------------------------

CLEARTYPE_QUALITY       = 5

;------------------------------------------------------------
; GetFileAttributes
;------------------------------------------------------------

INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF

;------------------------------------------------------------
; SetFilePointerEx
;------------------------------------------------------------

INVALID_SET_FILE_POINTER        = 0xFFFFFFFF
