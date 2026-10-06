;------------------------------------------------------------
; VERSIONINFO
;------------------------------------------------------------

VER_FILEVERSION equ SubProjectLongVer
VER_PRODUCTVERSION equ ProjectLongVer
VER_FILEFLAGSMASK equ VS_FFI_FILEFLAGSMASK
VER_FILEFLAGS equ VS_FF_RELEASE
VER_FILEOS equ VOS_NT_WINDOWS32
VER_FILETYPE equ VFT_APP
VER_FILESUBTYPE equ VFT2_UNKNOWN
VER_LANGID equ LANG_ENGLISH+SUBLANG_DEFAULT
VER_CHARSETID equ 1200

FileDescription equ SubProjectName
FileVersion equ SubProjectVersion
;ProductName equ ProjectName,' by Blankname'
ProductName equ ProjectName
ProductVersion equ ProjectVersion
;LegalCopyright equ 'No rights reserved.'
LegalCopyright equ '© 2026 BlanknameES. All rights reserved.'
OriginalFileName equ FileBaseName

;------------------------------------------------------------
; win32 constants
;------------------------------------------------------------

APP_WINSTYLES = WS_VISIBLE+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_OVERLAPPED
APP_WINEXSTYLES = WS_EX_ACCEPTFILES ;+WS_EX_APPWINDOW
APP_WINCLIENTWIDTH = 380
APP_WINCLIENTHEIGHT = 190

CLR_BG                  = 0x001F1F1F ; audi brillant black
CLR_PANEL               = 0x002B2B2B ; slate black
CLR_BORDER              = 0x003A3A3A ; onyx black
CLR_FOCUS               = 0x00FFFFFF ; white
CLR_STA_TEXT            = 0x00E0E0E0 ; light grey
CLR_STA_TEXT_RED        = 0x004040A0
CLR_STA_TEXT_GREEN      = 0x00208020
CLR_STA_TEXT_BLUE       = 0x00C06040
CLR_BTN_TEXT            = 0x00FFFFFF ; white
CLR_BTN_PATCH           = 0x00527A4C ; custom green
;CLR_BTN_PATCH_FOC       = 0x00293D26 ; custom green (-50%)
CLR_BTN_PATCH_SEL       = 0x0042623D ; custom green (-20%)
CLR_BTN_REST            = 0x007A574D ; custom blue
;CLR_BTN_REST_FOC        = 0x0062463E ; custom blue (-20%)
CLR_BTN_REST_SEL        = 0x0062463E ; custom blue (-20%)
CLR_BTN_OPEN            = 0x008C8C8C ; dark gainsboro
;CLR_BTN_OPEN_FOC        = 0x00707070 ; dark gainsboro (-20%)
CLR_BTN_OPEN_SEL        = 0x00707070 ; dark gainsboro (-20%)

;------------------------------------------------------------
; win32 control IDs
;------------------------------------------------------------

IDV_MAIN = 1

;IDM_FILE = 100
IDM_REOPEN = 101
IDM_CLOSE = 102
IDM_OPENINI = 103
IDM_RESETINI = 104
IDM_EXIT = 105
;IDM_HELP = 200
IDM_ABOUT = 201

IDC_PAT_BUTTON_START = 1000
IDC_PAT_OPENFILE = 1000
IDC_PAT_PATCH = 1001
IDC_PAT_RESTORE = 1002
IDC_PAT_BUTTON_END = 1002

IDC_PAT_EDITBOX_START = 1100
IDC_PAT_FILENAME = 1100
IDC_PAT_EDITBOX_END = 1100

IDC_PAT_STATICL_START = 1200
IDC_PAT_FILENAMEL = 1200
IDC_PAT_VERSIONL = 1201
IDC_PAT_PROTECTEDL = 1202
IDC_PAT_LAAFLAGL = 1203
IDC_PAT_STATUSL = 1204
IDC_PAT_STATICL_END = 1204

IDC_PAT_STATICV_START = 1300
;IDC_PAT_FILENAMEV = 1300
IDC_PAT_VERSIONV = 1301
IDC_PAT_PROTECTEDV = 1302
IDC_PAT_LAAFLAGV = 1303
IDC_PAT_STATUSV = 1304
IDC_PAT_STATICV_END = 1304

IDC_PAT_CHECKBOX_START = 1400
IDC_PAT_ENABLELAA = 1400
IDC_PAT_CHECKBOX_END = 1400
