;------------------------------------------------------------
; APIs
;------------------------------------------------------------

DLL_User32                          du 'User32.dll',0
PROC_ChangeWindowMessageFilter      db 'ChangeWindowMessageFilter',0
PROC_ChangeWindowMessageFilterEx    db 'ChangeWindowMessageFilterEx',0

DLL_UxTheme                         du 'UxTheme.dll',0
PROC_SetWindowTheme                 db 'SetWindowTheme',0

DLL_Shell32                         du 'Shell32.dll',0
PROC_ShellExecuteW                  db 'ShellExecuteW',0

;------------------------------------------------------------
; menu strings
;------------------------------------------------------------

menu_file               du '&File',0
menu_file_reopen        du 'Re-&open target',9,'Ctrl+O',0
menu_file_close         du '&Close target',9,'Ctrl+F4',0
menu_file_openini       du '&Launch settings file',9,'Ctrl+L',0
menu_file_resetini      du '&Restore settings file',9,'Ctrl+R',0
menu_file_exit          du 'E&xit',0
menu_help               du '&Help',0
menu_help_about         du '&About...',0

;------------------------------------------------------------
; keyboard accelerators
;------------------------------------------------------------

accel_entries           = $
                        ACCEL FCONTROL+FVIRTKEY,'O',IDM_REOPEN
                        ACCEL FCONTROL+FVIRTKEY,'F4',IDM_CLOSE
                        ACCEL FCONTROL+FVIRTKEY,'L',IDM_OPENINI
                        ACCEL FCONTROL+FVIRTKEY,'R',IDM_RESETINI
                        ;ACCEL FALT+FVIRTKEY,'X',IDM_EXIT
                        ;ACCEL FALT+FVIRTKEY,'A',IDM_ABOUT
num_accel_entries       = ($ - accel_entries) / sizeof.ACCEL

;------------------------------------------------------------
; controls
;------------------------------------------------------------

App_szClassName         du SubProjectName,'Class',0
App_szWindowName        du SubProjectName,' v',SubProjectVersion,0

WC_BUTTON               du 'Button',0
WC_COMBOBOX             du 'ComboBox',0
WC_EDIT                 du 'Edit',0
WC_STATIC               du 'Static',0

App_szFontName          du 'Tahoma',0

App_szDefTargetName     du 'IGI.exe',0

ctrl_pat_filename_bu    du '...',0
ctrl_pat_patch_bu       du 'Patch',0
ctrl_pat_restore_bu     du 'Restore',0
ctrl_pat_filename_st    du 'Target: ',0
ctrl_pat_filename_eb    du '',0
ctrl_pat_version_st     du 'Version: ',0
ctrl_pat_version_eb     du '',0
ctrl_pat_protected_st   du 'Protected: ',0
ctrl_pat_protected_eb   du '',0
ctrl_pat_status_st      du 'Status: ',0
ctrl_pat_status_eb      du '',0
ctrl_pat_laaflag_st     du 'LAA Flag: ',0
ctrl_pat_laaflag_eb     du '',0
ctrl_pat_laaflag_cb     du 'Enable LAA flag (4GB patch)',0

OFN_szFileFilter        du 'Windows Executable (*.exe)',0,'*.exe',0,\
                           'IGI executable (IGI.exe)',0,'IGI.exe',0,\
                           'All Files (*.*)',0,'*.*',0,\
                           0
OFN_szTitle             du 'Please select IGI.exe',0
OFN_szDefExt            du 'exe',0

;------------------------------------------------------------
; control states
;------------------------------------------------------------

align 4 ; TODO: figure out why text becomes invisible without this line
App_szCtrlNoFile        du 'Select a file to patch',0
App_szCtrlEmpty         du '',0
App_szCtrlNA            du 'N/A',0
App_szCtrlUnknown       du 'Unknown',0
App_szCtrlTrue          du 'True',0
App_szCtrlFalse         du 'False',0
App_szCtrlEnabled       du 'Enabled',0
App_szCtrlDisabled      du 'Disabled',0
App_szCtrlPatched       du 'Patched',0
App_szCtrlNotPatched    du 'Not patched',0
App_szCtrlYes           du 'Yes',0
App_szCtrlNo            du 'No',0

                        dd App_szCtrlUnknown
App_pazCtrlVersionTbl   dd App_szCtrlVersionID0
                        dd App_szCtrlVersionID1
                        dd App_szCtrlVersionID2

                        dd App_szCtrlUnknown
App_pazCtrlProtectedTbl dd App_szCtrlFalse
                        dd App_szCtrlTrue

                        dd App_szCtrlUnknown
App_pazCtrlLAAFlagTbl   dd App_szCtrlDisabled
                        dd App_szCtrlEnabled

                        dd App_szCtrlUnknown
App_pazCtrlPatchedTbl   dd App_szCtrlNotPatched
                        dd App_szCtrlPatched

                        dd CLR_STA_TEXT_RED
App_paiCtrlVersionTbl   dd CLR_STA_TEXT_GREEN
                        dd CLR_STA_TEXT_GREEN
                        dd CLR_STA_TEXT_GREEN

                        dd CLR_STA_TEXT_RED
App_paiCtrlProtectedTbl dd CLR_STA_TEXT_GREEN
                        dd CLR_STA_TEXT_RED

                        dd CLR_STA_TEXT_RED
App_paiCtrlLAAFlagTbl   dd CLR_STA_TEXT_BLUE
                        dd CLR_STA_TEXT_GREEN

                        dd CLR_STA_TEXT_RED
App_paiCtrlPatchedTbl   dd CLR_STA_TEXT_BLUE
                        dd CLR_STA_TEXT_GREEN

App_szCtrlVersionID0    du '1.0 [EU]',0
App_szCtrlVersionID1    du '1.0 [USA]',0
App_szCtrlVersionID2    du '1.0 [JAP]',0

;------------------------------------------------------------
; MessageBox strings
;------------------------------------------------------------

; error msgs
App_szErrorCap                  du 'Error',0
App_szErrInitApp                du 'Application initialization failed!',0
App_szErrRegClass               du 'Could not register window class!',0
App_szErrCreateMenu             du 'Could not create menu bar!',0
App_szErrCreateMainWnd          du 'Could not create main window!',0
App_szErrCreateMenuItems        du 'Could not create menu bar items!',0
App_szErrCreateGDIObjects       du 'Could not create GDI objects!',0
App_szErrCreateMainWndCtrls     du 'Could not create main window controls!',0

; error msgs - ini
App_szErrLaunchIni              du 'Could not launch settings file!',0
App_szErrOpenIni                du 'Could not open settings file!',0
App_szErrWriteIni               du 'Could not write settings file!',0

; error msgs - patcher
App_szErrLoadTarget             du 'Could not load target file!',0
App_szErrSaveTarget             du 'Could not save target file!',0

; warning msgs
App_szWarningCap                du 'Warning',0

; info msgs
App_szInfoCap                   du 'Information',0
App_szInfoResetIni              du 'Settings file successfully restored',0

; about msg
App_szAboutCap                  du 'About',0
App_szAboutText                 du SubProjectName,13,10,\
                                   'Copyright © 2026 BlanknameES',13,10,\
                                   'https://github.com/BlanknameES',13,10,\
                                   13,10,\
                                   'UI design by neoxaero',13,10,\
                                   0

;------------------------------------------------------------
; ini file
;------------------------------------------------------------

App_szIniBasename       du ProjectName,'.ini',0

App_acIniFileData       = $
                        file '..\IGIPatch.ini'
App_uiIniFileSize       = $ - App_acIniFileData
