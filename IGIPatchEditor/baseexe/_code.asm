proc start

        locals
                si STARTUPINFO
        endl

        invoke  GetModuleHandle,NULL
        mov     ebx,eax
        invoke  GetCommandLine
        mov     esi,eax
        lea     edi,[si]
        and     dword[edi+STARTUPINFO.dwFlags],0
        invoke  GetStartupInfo,edi
        movzx   eax,word[edi+STARTUPINFO.wShowWindow]
        mov     ecx,SW_SHOWDEFAULT
        bt      dword[edi+STARTUPINFO.dwFlags],1 shr STARTF_USESHOWWINDOW
        sbb     edx,edx
        and     eax,edx
        not     edx
        and     ecx,edx
        or      eax,ecx
        stdcall WinMain,ebx,NULL,esi,eax
        invoke  ExitProcess,eax
endp

proc WinMain hInstance,hPrevInstance,lpCmdLine,nCmdShow ; TODO: multi-monitor, dpi scaling

        locals
                hWindow dd ?
                hMenu dd ?
                hAccel dd ?
                nExitCode dd 0
        endl

        push    ebx
        mov     ebx,dword[hInstance]

        .init:
        stdcall App_Init,ebx
        test    eax,eax
        jz      .deinit

        .ui_init:
        lea     eax,[hWindow]
        lea     ecx,[hMenu]
        lea     edx,[hAccel]
        stdcall App_UIInit,ebx,dword[nCmdShow],eax,ecx,edx
        test    eax,eax
        jz      .deinit

        .run_once:
        stdcall App_RunOnce,ebx,dword[hWindow]
        test    eax,eax
        jz      .deinit

        .msg_loop:
        stdcall App_MsgLoop,dword[hWindow],dword[hAccel]
        mov     dword[nExitCode],eax

        .deinit:
        stdcall App_DeInit

        .end:
        mov     eax,dword[nExitCode]
        pop     ebx
        ret
endp

proc App_Init hInstance

        ; dynamic linking initialization
        stdcall App_InitRunTimeDynamicLinking

        ; get current dir
        stdcall App_GetCurrentDir,dword[hInstance],App_szCurrentDir
        test    eax,eax
        jz      .err_init

        ; get ini filename
        stdcall App_GetCombinedFilename,App_szIniFilename,App_szCurrentDir,App_szIniBasename
        test    eax,eax
        jz      .err_init

        ; init memory
        stdcall MemInit,FALSE

        ; init file patcher
        stdcall Patcher_Init,FilePatcher
        test    eax,eax
        jz      .err_init

        .ok:
        mov     eax,TRUE

        .end:
        ret

        .err_init:
        invoke  MessageBox,NULL,App_szErrInitApp,App_szErrorCap,MB_ICONERROR+MB_OK
        xor     eax,eax
        jmp     .end
endp

proc App_InitRunTimeDynamicLinking

        push    ebx

        .user32_dll: ; User32.dll
        mov     eax,DLL_User32
        ;stdcall GetOrLoadLibrary,eax,User32DLL
        invoke  GetModuleHandleW,eax
        mov     dword[User32DLL],eax
        test    eax,eax
        jz      .uxtheme_dll
        mov     ebx,eax
        mov     eax,PROC_ChangeWindowMessageFilter
        stdcall GetFuncAddress,ebx,eax
        mov     dword[ChangeWindowMessageFilter],eax
        mov     eax,PROC_ChangeWindowMessageFilterEx
        stdcall GetFuncAddress,ebx,eax
        mov     dword[ChangeWindowMessageFilterEx],eax

        .uxtheme_dll: ; Uxtheme.dll
        mov     eax,DLL_UxTheme
        ;stdcall GetOrLoadLibrary,eax,UxThemeDLL
        invoke  LoadLibraryW,eax
        mov     dword[UxThemeDLL],eax
        test    eax,eax
        jz      .shell32_dll
        mov     ebx,eax
        mov     eax,PROC_SetWindowTheme
        stdcall GetFuncAddress,ebx,eax
        mov     dword[SetWindowTheme],eax

        .shell32_dll: ; Shell32.dll
        mov     eax,DLL_Shell32
        ;stdcall GetOrLoadLibrary,eax,Shell32DLL
        invoke  GetModuleHandleW,eax
        mov     dword[Shell32DLL],eax
        test    eax,eax
        jz      .end
        mov     ebx,eax
        mov     eax,PROC_ShellExecuteW
        stdcall GetFuncAddress,ebx,eax
        mov     dword[_ShellExecuteW],eax

        .end:
        pop     ebx
        ret
endp

proc App_GetCurrentDir hInstance,pszDirectory

        push    ebx
        mov     ebx,[pszDirectory]
        and     word[ebx],0
        stdcall GetModuleFileNameSafe,dword[hInstance],ebx,MAX_PATH
        test    eax,eax
        jz      .end
        invoke  PathRemoveFileSpec,ebx
        .end:
        pop     ebx
        ret
endp

proc App_GetCombinedFilename pszFilenameOut,pszDirectoryIn,pszBaseNameIn

        invoke  PathCombine,dword[pszFilenameOut],dword[pszDirectoryIn],dword[pszBaseNameIn]
        ret
endp

proc App_UIInit hInstance,nCmdShow,pWindow,pMenu,pAccel

        push    ebx esi edi

        ; enable win xp visual styles and extended controls
        stdcall App_InitCommonControlsEx

        ; create window class
        stdcall App_CreateWndClass,dword[hInstance]
        test    eax,eax
        jz      .error_regclass

        ; create menu bar
        stdcall App_CreateMenuBar,dword[hInstance]
        test    eax,eax
        jz      .error_createmenu
        mov     ebx,eax

        ; create main window
        stdcall App_CreateMainWnd,dword[hInstance],eax,dword[nCmdShow]
        test    eax,eax
        jz      .error_createmainwnd
        mov     esi,eax

        ; create keyboard accelerators
        stdcall App_CreateAccelerators
        mov     edi,eax

        ; init OPENFILENAME
        stdcall App_InitOFN,dword[hInstance],esi

        ; init Drag&Drop
        stdcall App_InitDnD,esi

        .ok:
        mov     eax,dword[pWindow]
        mov     ecx,dword[pMenu]
        mov     edx,dword[pAccel]
        mov     dword[eax],esi
        mov     dword[ecx],ebx
        mov     dword[edx],edi
        mov     eax,TRUE

        .end:
        pop     edi esi ebx
        ret

        .error_regclass:
        invoke  MessageBox,NULL,App_szErrRegClass,App_szErrorCap,MB_ICONERROR+MB_OK
        xor     eax,eax
        jmp     .end

        .error_createmenu:
        invoke  MessageBox,NULL,App_szErrCreateMenu,App_szErrorCap,MB_ICONERROR+MB_OK
        xor     eax,eax
        jmp     .end

        .error_createmainwnd:
        invoke  MessageBox,NULL,App_szErrCreateMainWnd,App_szErrorCap,MB_ICONERROR+MB_OK
        xor     eax,eax
        jmp     .end
endp

proc App_InitCommonControlsEx

        locals
                pICCE INITCOMMONCONTROLSEX
        endl

        lea     eax,[pICCE]
        mov     dword[eax+INITCOMMONCONTROLSEX.dwSize],sizeof.INITCOMMONCONTROLSEX
        mov     dword[eax+INITCOMMONCONTROLSEX.dwICC],ICC_ALL_CLASSES
        invoke  InitCommonControlsEx,eax
        ret
endp

proc App_CreateWndClass hInstance

        locals
                pWCE WNDCLASSEX
        endl

        push    ebx esi edi
        lea     ebx,[pWCE]

        .load_icon:
        invoke  LoadIcon,NULL,IDI_APPLICATION ;dword[hInstance],IDI_MAIN
        mov     esi,eax

        .load_cursor:
        invoke  LoadCursor,NULL,IDC_ARROW ;dword[hInstance],IDC_MAIN
        mov     edi,eax

        .register_class:
        ;stdcall ZeroMemory,ebx,sizeof.WNDCLASSEX
        mov     eax,dword[hInstance]
        mov     dword[ebx+WNDCLASSEX.cbSize],sizeof.WNDCLASSEX
        mov     dword[ebx+WNDCLASSEX.style],CS_HREDRAW+CS_VREDRAW
        mov     dword[ebx+WNDCLASSEX.lpfnWndProc],App_WindowProc
        mov     dword[ebx+WNDCLASSEX.cbClsExtra],0
        mov     dword[ebx+WNDCLASSEX.cbWndExtra],0
        mov     dword[ebx+WNDCLASSEX.hInstance],eax
        mov     dword[ebx+WNDCLASSEX.hIcon],esi
        mov     dword[ebx+WNDCLASSEX.hCursor],edi
        mov     dword[ebx+WNDCLASSEX.hbrBackground],COLOR_WINDOW+1 ;COLOR_BTNFACE+1
        mov     dword[ebx+WNDCLASSEX.lpszMenuName],NULL
        mov     dword[ebx+WNDCLASSEX.lpszClassName],App_szClassName
        mov     dword[ebx+WNDCLASSEX.hIconSm],NULL
        invoke  RegisterClassEx,ebx
        movzx   eax,ax

        .end:
        pop     edi esi ebx
        ret
endp

proc App_CreateMenuBar hInstance

        locals
                pMI MENUINFO
        endl

        push    ebx

        .create_menu:
        invoke  CreateMenu
        test    eax,eax
        jz      .end
        mov     ebx,eax

        .get_menu_info:
        lea     eax,[pMI]
        mov     dword[eax+MENUINFO.cbSize],sizeof.MENUINFO
        mov     dword[eax+MENUINFO.fMask],MIM_STYLE
        invoke  GetMenuInfo,ebx,eax
        test    eax,eax
        jz      .end

        .set_notify_mode:
        lea     eax,[pMI]
        ;or      dword[eax+MENUINFO.dwStyle],MNS_NOTIFYBYPOS
        and     dword[eax+MENUINFO.dwStyle],not MNS_NOTIFYBYPOS
        invoke  SetMenuInfo,ebx,eax
        test    eax,eax
        jz      .end

        .ok:
        mov     eax,ebx

        .end:
        pop     ebx
        ret
endp

proc App_CreateMainWnd hInstance,hMenu,nCmdShow

        locals
                WndRect RECT
                WndSize POINT
        endl

        push    ebx esi edi

        ; calculate window size
        xor     eax,eax
        lea     ebx,[WndRect]
        mov     dword[ebx+RECT.left],eax
        mov     dword[ebx+RECT.top],eax
        mov     dword[ebx+RECT.right],APP_WINCLIENTWIDTH
        mov     dword[ebx+RECT.bottom],APP_WINCLIENTHEIGHT
        cmp     dword[hMenu],0
        setne   al
        invoke  AdjustWindowRectEx,ebx,APP_WINSTYLES,eax,APP_WINEXSTYLES
        test    eax,eax
        jz      .end
        mov     esi,dword[ebx+RECT.right]
        sub     esi,dword[ebx+RECT.left]
        mov     edi,dword[ebx+RECT.bottom]
        sub     edi,dword[ebx+RECT.top]

        ; get screen size
        lea     ebx,[WndSize]
        stdcall GetPrimaryScreenSize,0,ebx
        test    eax,eax
        jz      .end

        ; calculate window position
        mov     ecx,dword[ebx+POINT.x]
        sub     ecx,esi
        cmp     ecx,0x80000000
        sbb     eax,eax
        and     ecx,eax
        shr     ecx,1
        mov     edx,dword[ebx+POINT.y]
        sub     edx,edi
        cmp     edx,0x80000000
        sbb     eax,eax
        and     edx,eax
        shr     edx,1

        ; create window
        invoke  CreateWindowEx,APP_WINEXSTYLES,App_szClassName,App_szWindowName,APP_WINSTYLES,ecx,edx,esi,edi,NULL,dword[hMenu],dword[hInstance],NULL
        test    eax,eax
        jz      .end
        mov     ebx,eax

        ; update window
        invoke  ShowWindow,ebx,dword[nCmdShow]
        invoke  UpdateWindow,ebx
        mov     eax,ebx

        .end:
        pop     edi esi ebx
        ret
endp

proc App_CreateAccelerators

        invoke  CreateAcceleratorTable,accel_entries,num_accel_entries
        ret
endp

proc App_InitOFN hInstance,hWnd

        push    ebx
        lea     ebx,[OFN]
        stdcall ZeroMemory,ebx,sizeof._OPENFILENAME
        mov     eax,dword[hWnd]
        mov     ecx,dword[hInstance]
        mov     dword[ebx+_OPENFILENAME.lStructSize],sizeof._OPENFILENAME
        mov     dword[ebx+_OPENFILENAME.hwndOwner],eax
        mov     dword[ebx+_OPENFILENAME.hInstance],ecx
        mov     dword[ebx+_OPENFILENAME.lpstrFilter],OFN_szFileFilter
        mov     dword[ebx+_OPENFILENAME.nFilterIndex],2
        mov     dword[ebx+_OPENFILENAME.lpstrFile],OFN_szFileName
        mov     dword[ebx+_OPENFILENAME.nMaxFile],MAX_PATH
        mov     dword[ebx+_OPENFILENAME.lpstrInitialDir],App_szCurrentDir
        mov     dword[ebx+_OPENFILENAME.lpstrTitle],OFN_szTitle
        mov     dword[ebx+_OPENFILENAME.Flags],OFN_FILEMUSTEXIST+OFN_PATHMUSTEXIST+OFN_HIDEREADONLY
        mov     dword[ebx+_OPENFILENAME.lpstrDefExt],OFN_szDefExt
        mov     word[OFN_szFileName],0
        pop     ebx
        ret
endp

proc App_InitDnD hWnd

        push    ebx

        .check_cwmfe:
        mov     eax,dword[ChangeWindowMessageFilterEx]
        test    eax,eax
        jnz     .use_cwmfe

        .check_cwmf:
        mov     eax,dword[ChangeWindowMessageFilter]
        test    eax,eax
        jnz     .use_cwmf

        .end:
        pop     ebx
        ret

        .use_cwmfe:
        mov     ebx,eax
        stdcall ebx,dword[hWnd],WM_DROPFILES,MSGFLT_ADD,NULL
        stdcall ebx,dword[hWnd],WM_COPYDATA,MSGFLT_ADD,NULL
        stdcall ebx,dword[hWnd],WM_COPYGLOBALDATA,MSGFLT_ADD,NULL
        jmp     .end

        .use_cwmf:
        mov     ebx,eax
        stdcall ebx,WM_DROPFILES,MSGFLT_ALLOW
        stdcall ebx,WM_COPYDATA,MSGFLT_ALLOW
        stdcall ebx,WM_COPYGLOBALDATA,MSGFLT_ALLOW
        jmp     .end
endp

proc App_SelectDefaultTarget hWnd

        .get_def_filename:
        stdcall App_GetCombinedFilename,OFN_szFileName,App_szCurrentDir,App_szDefTargetName
        test    eax,eax
        jz      .end

        .check_exists:
        stdcall PathIsFile,eax
        test    eax,eax
        jz      .clear_filename

        .open_file:
        stdcall App_OpenFile,dword[hWnd],FilePatcher

        .end:
        ret

        .clear_filename:
        mov     word[OFN_szFileName],0
        ret
endp

proc App_RunOnce hInstance,hWnd

        .update_ctrls:
        stdcall App_UpdateAllControls,dword[hWnd]

        .select_def_target:
        stdcall App_SelectDefaultTarget,dword[hWnd]

        .end:
        mov     eax,TRUE
        ret
endp

proc App_MsgLoop hWnd,hAccel

        locals
                Msg MSG
        endl

        push    ebx esi edi
        lea     ebx,[Msg]
        mov     esi,dword[hWnd]
        mov     edi,dword[hAccel]

        .msg_loop:
        invoke  GetMessage,ebx,NULL,0,0
        test    eax,eax
        jz      .msg_loop_end
        sub     eax,-1
        jnc     .error
        test    edi,edi
        jz      .is_dialog_msg

        .translate_accel:
        invoke  TranslateAccelerator,esi,edi,ebx
        test    eax,eax
        jnz     .msg_loop

        .is_dialog_msg:
        invoke  IsDialogMessage,esi,ebx
        test    eax,eax
        jnz     .msg_loop

        .translate_msg:
        invoke  TranslateMessage,ebx
        invoke  DispatchMessage,ebx
        jmp     .msg_loop

        .msg_loop_end:
        test    edi,edi
        jz      .get_exit_code
        invoke  DestroyAcceleratorTable,edi

        .get_exit_code:
        mov     eax,dword[ebx+MSG.wParam]

        .end:
        pop     edi esi ebx
        ret

        .error:
        invoke  DestroyAcceleratorTable,edi
        xor     eax,eax
        jmp     .end
endp

proc App_WindowProc hWnd,uMsg,wParam,lParam

        ; parse message
        mov     eax,dword[uMsg]
        cmp     eax,WM_CREATE
        je      .wm_create
        cmp     eax,WM_PAINT
        je      .wm_paint
        cmp     eax,WM_ERASEBKGND
        je      .wm_erasebkgnd
        cmp     eax,WM_CTLCOLORSTATIC
        je      .wm_ctlcolorstatic
        cmp     eax,WM_DRAWITEM
        je      .wm_drawitem
        ;cmp     eax,WM_MENUCOMMAND
        ;je      .wmmenucommand
        cmp     eax,WM_COMMAND
        je      .wm_command
        cmp     eax,WM_DROPFILES
        je      .wm_dropfiles
        cmp     eax,WM_CLOSE
        je      .wm_close
        cmp     eax,WM_DESTROY
        je      .wm_destroy
        .DefWindowProc:
        invoke  DefWindowProc,dword[hWnd],dword[uMsg],dword[wParam],dword[lParam]
        ret

        ;------------------------------------------------------------
        ; messages
        ;------------------------------------------------------------

        .wm_create:
        stdcall App_InitMainWnd,dword[hWnd]
        test    eax,eax
        jz      .wm_destroy
        jmp     .end

        .wm_paint:
        stdcall App_PaintMainWnd,dword[hWnd]
        jmp     .end

        .wm_erasebkgnd:
        mov     eax,1
        jmp     .ret

        .wm_ctlcolorstatic:
        stdcall App_GetWndClassName,dword[lParam],App_szTempClassName
        add     eax,1*2
        stdcall EqualMemory,App_szTempClassName,WC_EDIT,eax
        test    eax,eax
        jnz     .DefWindowProc
        .set_staticctrl_color:
        stdcall App_GetCtrlTextColor,dword[lParam]
        invoke  SetTextColor,dword[wParam],eax
        invoke  SetBkMode,dword[wParam],TRANSPARENT
        mov     eax,dword[hBrushPanel]
        jmp     .ret

        .wm_drawitem:
        stdcall App_DrawMainWndItem,dword[lParam]
        mov     eax,TRUE
        jmp     .ret

        .wm_command:
        mov     ecx,dword[wParam]
        and     ecx,0xFFFF ; ignore high word (0 = Menu, 1 = Accelerator)
        cmp     dword[lParam],0 ; 0 = menu/accelerator message
        je      .check_menucommand
        cmp     ecx,IDC_PAT_OPENFILE
        je      .ctrl_openfile
        cmp     ecx,IDC_PAT_PATCH
        je      .ctrl_patchfile
        cmp     ecx,IDC_PAT_RESTORE
        je      .ctrl_restorefile
        jmp     .end

        ;.wm_menucommand:
        ;mov     ecx,dword[wParam]
        .check_menucommand:
        cmp     ecx,IDM_REOPEN
        je      .menu_reopen
        cmp     ecx,IDM_CLOSE
        je      .menu_close
        cmp     ecx,IDM_OPENINI
        je      .menu_ini_load
        cmp     ecx,IDM_RESETINI
        je      .menu_ini_reset
        cmp     ecx,IDM_EXIT
        je      .menu_exit
        cmp     ecx,IDM_ABOUT
        je      .menu_about
        jmp     .end

        .wm_dropfiles:
        invoke  SetForegroundWindow,dword[hWnd]
        stdcall GetChild,dword[hWnd],IDC_PAT_FILENAME
        invoke  SetFocus,eax
        stdcall App_ProcessDnD,dword[wParam],OFN_szFileName
        test    eax,eax
        jz      .end
        jmp     .cmd_openfile

        .wm_close:
        invoke  DestroyWindow,dword[hWnd]
        jmp     .end

        .wm_destroy:
        stdcall App_DestroyMainWnd,dword[hWnd]
        invoke  PostQuitMessage,0
        ;jmp     .end

        .end:
        xor     eax,eax
        .ret:
        ret

        ;------------------------------------------------------------
        ; menu commands
        ;------------------------------------------------------------

        .menu_reopen:
        jmp     .cmd_openfile

        .menu_close:
        stdcall App_CloseFile,dword[hWnd],FilePatcher
        jmp     .end

        .menu_ini_load:
        stdcall App_OpenIniFile,dword[hWnd],App_szIniFilename
        jmp     .end

        .menu_ini_reset:
        stdcall App_ResetIniFile,dword[hWnd],App_szIniFilename,App_acIniFileData,App_uiIniFileSize
        jmp     .end

        .menu_exit:
        invoke  ShowWindow,dword[hWnd],SW_HIDE
        jmp     .wm_close

        .menu_about:
        invoke  MessageBox,dword[hWnd],App_szAboutText,App_szAboutCap,MB_ICONINFORMATION+MB_OK
        jmp     .end

        ;------------------------------------------------------------
        ; control commands
        ;------------------------------------------------------------

        .ctrl_openfile: ; open as
        invoke  GetOpenFileName,OFN
        test    eax,eax
        jz      .end
        .cmd_openfile:
        stdcall App_OpenFile,dword[hWnd],FilePatcher
        jmp     .end

        .ctrl_patchfile:
        stdcall App_PatchFile,dword[hWnd],FilePatcher
        jmp     .end

        .ctrl_restorefile:
        stdcall App_RestoreFile,dword[hWnd],FilePatcher
        jmp     .end
endp

proc App_InitMainWnd hWnd

        push    ebx
        mov     ebx,dword[hWnd]

        .create_menu:
        invoke  GetMenu,ebx
        stdcall App_CreateMenuBarItems,eax
        test    eax,eax
        jz      .err_create_menuitems
        invoke  DrawMenuBar,ebx

        .create_gdiobjects:
        stdcall App_CreateGDIObjects
        test    eax,eax
        jz      .err_create_gdiobjects

        .create_controls:
        invoke  GetWindowLong,ebx,GWL_HINSTANCE
        stdcall App_CreateMainWndCtrls,ebx,eax
        test    eax,eax
        jz      .err_create_mainwndctrls

        .ok:
        mov     eax,TRUE

        .end:
        pop     ebx
        ret

        .err_create_menuitems:
        invoke  MessageBox,NULL,App_szErrCreateMenuItems,App_szErrorCap,MB_ICONERROR+MB_OK
        xor     eax,eax
        jmp     .end

        .err_create_gdiobjects:
        invoke  MessageBox,NULL,App_szErrCreateGDIObjects,App_szErrorCap,MB_ICONERROR+MB_OK
        xor     eax,eax
        jmp     .end

        .err_create_mainwndctrls:
        invoke  MessageBox,NULL,App_szErrCreateMainWndCtrls,App_szErrorCap,MB_ICONERROR+MB_OK
        xor     eax,eax
        jmp     .end
endp

proc App_CreateMenuBarItems hMenu

        locals
                hMenuFile rd 1
                hMenuEdit rd 1
                hMenuAbout rd 1
        endl

        push    ebx esi edi
        mov     esi,dword[hMenu]

        ; create File menu
        invoke  CreatePopupMenu
        test    eax,eax
        jz      .end
        mov     dword[hMenuFile],eax
        invoke  AppendMenu,esi,MF_POPUP+MF_STRING,eax,menu_file
        test    eax,eax
        jz      .end

        ; create Help menu
        invoke  CreatePopupMenu
        test    eax,eax
        jz      .end
        mov     dword[hMenuAbout],eax
        invoke  AppendMenu,esi,MF_POPUP+MF_STRING,eax,menu_help
        test    eax,eax
        jz      .end

        ; init result
        mov     ebx,TRUE

        ; create File sub-menus
        mov     edi,dword[hMenuFile]
        invoke  AppendMenu,edi,MF_STRING,IDM_REOPEN,menu_file_reopen
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  AppendMenu,edi,MF_STRING,IDM_CLOSE,menu_file_close
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  AppendMenu,edi,MF_SEPARATOR,0,0
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  AppendMenu,edi,MF_STRING,IDM_OPENINI,menu_file_openini
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  AppendMenu,edi,MF_STRING,IDM_RESETINI,menu_file_resetini
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  AppendMenu,edi,MF_SEPARATOR,0,0
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  AppendMenu,edi,MF_STRING,IDM_EXIT,menu_file_exit
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx

        ; create About sub-menus
        mov     edi,dword[hMenuAbout]
        invoke  AppendMenu,edi,MF_STRING,IDM_ABOUT,menu_help_about
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx

        ; return result
        mov     eax,ebx

        .end:
        pop     edi esi ebx
        ret
endp

proc App_CreateGDIObjects

        push    ebx
        mov     ebx,TRUE

        .create_brushes:
        invoke  CreateSolidBrush,CLR_BG
        mov     dword[hBrushBG],eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateSolidBrush,CLR_PANEL
        mov     dword[hBrushPanel],eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateSolidBrush,CLR_BORDER
        mov     dword[hBrushBorder],eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateSolidBrush,CLR_FOCUS
        mov     dword[hBrushFocus],eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreatePen,PS_SOLID,1,CLR_BORDER
        mov     dword[hPenBorder],eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx

        .create_fonts:
        invoke  CreateFont,-14,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH+FF_SWISS,App_szFontName
        mov     dword[hFontLabel],eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateFont,-14,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH+FF_SWISS,App_szFontName
        mov     dword[hFontValue],eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateFont,-16,0,0,0,FW_BOLD,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH+FF_SWISS,App_szFontName
        mov     dword[hFontButton],eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateFont,-13,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH+FF_SWISS,App_szFontName
        mov     dword[hFontSmall],eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx

        .end:
        mov     eax,ebx
        pop     ebx
        ret
endp

proc App_CreateMainWndCtrls hWnd,hInstance

        .style_statusbar = WS_VISIBLE+WS_CHILD
        .style_static = WS_VISIBLE+WS_CHILD+SS_LEFTNOWORDWRAP
        .style_staticbox = WS_VISIBLE+WS_CHILD+WS_BORDER+ES_CENTER+WS_DISABLED
        .style_editint = WS_VISIBLE+WS_CHILD+WS_BORDER+WS_TABSTOP+ES_UPPERCASE ; using ES_UPPERCASE as int flag
        .style_editflt = WS_VISIBLE+WS_CHILD+WS_BORDER+WS_TABSTOP+ES_LOWERCASE ; using ES_LOWERCASE as flt flag
        .style_editstr = WS_VISIBLE+WS_CHILD+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL
        .style_checkbox = WS_VISIBLE+WS_CHILD+WS_TABSTOP+BS_AUTOCHECKBOX
        .style_group = WS_VISIBLE+WS_CHILD+BS_GROUPBOX
        .style_button = WS_VISIBLE+WS_CHILD+BS_PUSHBUTTON+WS_TABSTOP
        .style_hseparator = WS_VISIBLE+WS_CHILD+SS_ETCHEDHORZ
        .style_vseparator = WS_VISIBLE+WS_CHILD+SS_ETCHEDVERT
        .style_dropdown = WS_VISIBLE+WS_CHILD+CBS_DROPDOWNLIST+CBS_NOINTEGRALHEIGHT+CBS_HASSTRINGS

        push    ebx esi edi
        mov     ebx,TRUE
        mov     esi,dword[hWnd]
        mov     edi,dword[hInstance]

        .create_buttons:
        invoke  CreateWindowEx,0,WC_BUTTON,ctrl_pat_patch_bu,.style_button+BS_OWNERDRAW,240,60,120,40,esi,IDC_PAT_PATCH,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_BUTTON,ctrl_pat_restore_bu,.style_button+BS_OWNERDRAW,240,104,120,40,esi,IDC_PAT_RESTORE,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_BUTTON,ctrl_pat_filename_bu,.style_button+BS_OWNERDRAW,330,20,30,20,esi,IDC_PAT_OPENFILE,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx

        .create_statics:
        invoke  CreateWindowEx,0,WC_STATIC,ctrl_pat_filename_st,.style_static,20,20,80,20,esi,IDC_PAT_FILENAMEL,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_EDIT,ctrl_pat_filename_eb,.style_editstr+ES_READONLY,110,20,210,20,esi,IDC_PAT_FILENAME,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_STATIC,ctrl_pat_version_st,.style_static,20,60,80,20,esi,IDC_PAT_VERSIONL,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_STATIC,ctrl_pat_version_eb,.style_static,110,60,120,20,esi,IDC_PAT_VERSIONV,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_STATIC,ctrl_pat_protected_st,.style_static,20,82,80,20,esi,IDC_PAT_PROTECTEDL,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_STATIC,ctrl_pat_protected_eb,.style_static,110,82,120,20,esi,IDC_PAT_PROTECTEDV,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_STATIC,ctrl_pat_laaflag_st,.style_static,20,104,80,20,esi,IDC_PAT_LAAFLAGL,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_STATIC,ctrl_pat_laaflag_eb,.style_static,110,104,120,20,esi,IDC_PAT_LAAFLAGV,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_STATIC,ctrl_pat_status_st,.style_static,20,126,80,20,esi,IDC_PAT_STATUSL,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  CreateWindowEx,0,WC_STATIC,ctrl_pat_status_eb,.style_static,110,126,120,20,esi,IDC_PAT_STATUSV,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx

        .create_checkboxes:
        invoke  CreateWindowEx,0,WC_BUTTON,ctrl_pat_laaflag_cb,.style_checkbox,20,148,210,20,esi,IDC_PAT_ENABLELAA,edi,NULL
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx

        .init_ctrls:
        stdcall App_InitMainWndCtrls,esi
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp

proc App_InitMainWndCtrls hWnd

        push    ebx esi edi
        mov     ebx,dword[hWnd]

        .set_font:
        stdcall App_SetWndCtrlRangeFont,ebx,IDC_PAT_BUTTON_START,IDC_PAT_BUTTON_END,dword[hFontButton],TRUE
        stdcall App_SetWndCtrlRangeFont,ebx,IDC_PAT_EDITBOX_START,IDC_PAT_EDITBOX_END,dword[hFontValue],TRUE
        stdcall App_SetWndCtrlRangeFont,ebx,IDC_PAT_STATICL_START,IDC_PAT_STATICL_END,dword[hFontLabel],TRUE
        stdcall App_SetWndCtrlRangeFont,ebx,IDC_PAT_STATICV_START,IDC_PAT_STATICV_END,dword[hFontValue],TRUE
        stdcall App_SetWndCtrlRangeFont,ebx,IDC_PAT_CHECKBOX_START,IDC_PAT_CHECKBOX_END,dword[hFontSmall],TRUE

        .setup_checkboxes:
        stdcall App_SetWndCtrlRangeNoTheme,ebx,IDC_PAT_CHECKBOX_START,IDC_PAT_CHECKBOX_END,FALSE

        .setup_editboxes:
        stdcall App_SetWndCtrlRangeEditMaxText,ebx,IDC_PAT_EDITBOX_START,IDC_PAT_EDITBOX_END,MAX_PATH-1

        .set_focus:
        stdcall GetChild,ebx,IDC_PAT_FILENAME
        invoke  SetFocus,eax
        test    eax,eax
        setnz   al
        movzx   eax,al

        pop     edi esi ebx
        ret
endp

proc App_SetWndCtrlRangeFont hWnd,uiStart,uiEnd,hFont,bRedraw

        push    ebx esi edi
        mov     ebx,dword[hWnd]

        .set_font:
        mov     esi,dword[uiStart]
        mov     edi,dword[uiEnd]
        .loop:
        stdcall GetChild,ebx,esi
        invoke  SendMessage,eax,WM_SETFONT,dword[hFont],dword[bRedraw]
        inc     esi
        cmp     esi,edi
        jbe     .loop

        .end:
        pop     edi esi ebx
        ret
endp

proc App_SetWndCtrlRangeNoTheme hWnd,uiStart,uiEnd,bUseDefault

        push    ebx esi edi
        mov     ebx,dword[hWnd]

        .set_font:
        mov     esi,dword[uiStart]
        mov     edi,dword[uiEnd]
        .loop:
        stdcall GetChild,ebx,esi
        stdcall DisableWindowTheme,eax,dword[bUseDefault]
        inc     esi
        cmp     esi,edi
        jbe     .loop

        .end:
        pop     edi esi ebx
        ret
endp

proc App_SetWndCtrlRangeEditMaxText hWnd,uiStart,uiEnd,nTextLimit

        push    ebx esi edi
        mov     ebx,dword[hWnd]

        .set_font:
        mov     esi,dword[uiStart]
        mov     edi,dword[uiEnd]
        .loop:
        stdcall GetChild,ebx,esi
        invoke  SendMessage,eax,EM_SETLIMITTEXT,dword[nTextLimit],0
        inc     esi
        cmp     esi,edi
        jbe     .loop

        .end:
        pop     edi esi ebx
        ret
endp

proc App_PaintMainWnd hWnd

        locals
                ps PAINTSTRUCT
                rect RECT
        endl

        push    ebx esi edi

        .begin_paint:
        lea     eax,[ps]
        invoke  BeginPaint,dword[hWnd],eax
        mov     ebx,eax

        .fill_background:
        lea     eax,[rect]
        ;invoke  GetClientRect,dword[hWnd],eax
        mov     dword[eax+RECT.left],0
        mov     dword[eax+RECT.top],0
        mov     dword[eax+RECT.right],APP_WINCLIENTWIDTH
        mov     dword[eax+RECT.bottom],APP_WINCLIENTHEIGHT
        invoke  FillRect,ebx,eax,dword[hBrushBG]

        .fill_panel:
        invoke  SelectObject,ebx,dword[hBrushPanel]
        invoke  SelectObject,ebx,dword[hPenBorder]
        mov     ecx,10 ; width
        mov     edx,10 ; height
        invoke  RoundRect,ebx,10,10,APP_WINCLIENTWIDTH-10,APP_WINCLIENTHEIGHT-10,ecx,edx

        .fill_divider:
        invoke  SelectObject,ebx,dword[hPenBorder]
        invoke  MoveToEx,ebx,20,50,NULL
        invoke  LineTo,ebx,APP_WINCLIENTWIDTH-20,50

        .end_paint:
        lea     eax,[ps]
        invoke  EndPaint,dword[hWnd],eax

        .end:
        pop     edi esi ebx
        ret
endp

proc App_DrawMainWndItem pDIS

        locals
                dwDefColor rd 1
                ;dwHovColor rd 1
                dwSelColor rd 1
                dwBrushColor rd 1
                dwPenColor rd 1
                hBrush rd 1
                hPen rd 1
                szText rw 32
                sizeof.szText = 32 ; actually length
        endl

        push    ebx esi edi
        mov     ebx,dword[pDIS]
        mov     esi,dword[ebx+DRAWITEMSTRUCT.hDC]
        mov     edi,dword[ebx+DRAWITEMSTRUCT.CtlID]

        .check_button_open:
        cmp     edi,IDC_PAT_OPENFILE
        jne     .check_button_patch
        mov     dword[dwDefColor],CLR_BTN_OPEN
        mov     dword[dwSelColor],CLR_BTN_OPEN_SEL
        jmp     .get_item_state

        .check_button_patch:
        cmp     edi,IDC_PAT_PATCH
        jne     .check_button_restore
        mov     dword[dwDefColor],CLR_BTN_PATCH
        mov     dword[dwSelColor],CLR_BTN_PATCH_SEL
        jmp     .get_item_state

        .check_button_restore:
        cmp     edi,IDC_PAT_RESTORE
        jne     .end
        mov     dword[dwDefColor],CLR_BTN_REST
        mov     dword[dwSelColor],CLR_BTN_REST_SEL

        .get_item_state:
        mov     eax,dword[ebx+DRAWITEMSTRUCT.itemState]

        .check_item_state:
        test    eax,ODS_SELECTED
        jnz     .use_state_selected

        .use_state_default:
        mov     ecx,dword[dwDefColor]
        mov     dword[dwBrushColor],ecx
        mov     dword[dwPenColor],ecx
        jmp     .check_item_focus

        .use_state_selected:
        mov     ecx,dword[dwSelColor]
        mov     dword[dwBrushColor],ecx
        mov     dword[dwPenColor],ecx
        jmp     .check_item_focus

        .check_item_focus:
        mov     ecx,dword[hBrushPanel]
        test    eax,ODS_FOCUS
        jz      .draw_background
        mov     ecx,dword[hBrushFocus]

        .draw_background:
        lea     edx,[ebx+DRAWITEMSTRUCT.rcItem]
        invoke  FillRect,esi,edx,ecx

        .draw_control:
        invoke  CreateSolidBrush,dword[dwBrushColor]
        mov     dword[hBrush],eax
        invoke  SelectObject,esi,eax
        invoke  CreatePen,PS_SOLID,0,dword[dwPenColor]
        mov     dword[hPen],eax
        invoke  SelectObject,esi,eax
        mov     eax,dword[ebx+DRAWITEMSTRUCT.rcItem.left]
        mov     ecx,dword[ebx+DRAWITEMSTRUCT.rcItem.top]
        mov     edx,dword[ebx+DRAWITEMSTRUCT.rcItem.right]
        invoke  RoundRect,esi,eax,ecx,edx,dword[ebx+DRAWITEMSTRUCT.rcItem.bottom],8,8
        invoke  DeleteObject,dword[hBrush]
        invoke  DeleteObject,dword[hPen]

        .draw_label:
        invoke  SetBkMode,esi,TRANSPARENT
        invoke  SetTextColor,esi,CLR_BTN_TEXT
        invoke  SelectObject,esi,dword[hFontLabel]
        lea     eax,[szText]
        invoke  GetWindowText,dword[ebx+DRAWITEMSTRUCT.hwndItem],eax,sizeof.szText
        lea     eax,[szText]
        lea     ecx,[ebx+DRAWITEMSTRUCT.rcItem]
        invoke  DrawText,esi,eax,-1,ecx,DT_CENTER+DT_VCENTER+DT_SINGLELINE

        .end:
        pop     edi esi ebx
        ret
endp

proc App_DestroyMainWnd hWnd

        .delete_brushes:
        invoke  DeleteObject,dword[hBrushBG]
        invoke  DeleteObject,dword[hBrushPanel]
        invoke  DeleteObject,dword[hBrushBorder]
        invoke  DeleteObject,dword[hPenBorder]

        .delete_fonts:
        invoke  DeleteObject,dword[hFontLabel]
        invoke  DeleteObject,dword[hFontValue]
        invoke  DeleteObject,dword[hFontButton]
        invoke  DeleteObject,dword[hFontSmall]

        .end:
        ret
endp

proc App_DeInit

        ; dynamic linking termination
        stdcall App_DeInitRunTimeDynamicLinking

        .end:
        ret
endp

proc App_DeInitRunTimeDynamicLinking

        stdcall FreeLoadedLibrary,dword[User32DLL]
        stdcall FreeLoadedLibrary,dword[UxThemeDLL]
        stdcall FreeLoadedLibrary,dword[Shell32DLL]
        ret
endp

proc App_GetWndClassName hWnd,lpClassName

        mov     eax,dword[lpClassName]
        mov     word[eax],0
        invoke  GetClassName,dword[hWnd],eax,256
        ret
endp

proc App_GetCtrlTextColor hWnd

        push    ebx
        mov     ebx,FilePatcher

        .get_id:
        stdcall GetChildID,dword[hWnd]
        mov     edx,eax
        lea     ecx,[eax-IDC_PAT_STATICV_START]
        mov     eax,CLR_STA_TEXT
        cmp     ecx,IDC_PAT_STATICV_END-IDC_PAT_STATICV_START
        ja      .end
        cmp     word[OFN_szFileName],0
        je      .end

        .check_id:
        cmp     edx,IDC_PAT_VERSIONV
        je      .version
        cmp     edx,IDC_PAT_PROTECTEDV
        je      .protected
        cmp     edx,IDC_PAT_LAAFLAGV
        je      .laa
        cmp     edx,IDC_PAT_STATUSV
        je      .status
        jmp     .end

        .version:
        mov     eax,dword[ebx+FILEPATCHER.tT1.tExtra.eVersionID]
        mov     eax,dword[App_paiCtrlVersionTbl+eax*4]
        jmp     .end

        .protected:
        mov     eax,dword[ebx+FILEPATCHER.tT1.tExtra.eProtected]
        mov     eax,dword[App_paiCtrlProtectedTbl+eax*4]
        jmp     .end

        .laa:
        mov     eax,dword[ebx+FILEPATCHER.tT1.tExtra.eLAAFlag]
        mov     eax,dword[App_paiCtrlLAAFlagTbl+eax*4]
        jmp     .end

        .status:
        mov     eax,dword[ebx+FILEPATCHER.tT1.tExtra.ePatched]
        mov     eax,dword[App_paiCtrlPatchedTbl+eax*4]
        ;jmp     .end

        .end:
        pop     ebx
        ret
endp

proc App_ProcessDnD hDrop,pszFilename

        locals
                szFilename rw MAX_PATH
        endl

        push    ebx esi edi
        lea     esi,[szFilename]
        and     word[esi],0
        mov     edi,dword[hDrop]
        invoke  DragQueryFile,edi,0,esi,MAX_PATH
        test    eax,eax
        jz      .end
        mov     ebx,eax
        invoke  DragFinish,edi
        stdcall PathIsFile,esi
        test    eax,eax
        jz      .end
        mov     eax,dword[pszFilename]
        lea     ecx,[ebx*2+2]
        stdcall CopyMemory,eax,esi,ecx
        .end:
        pop     edi esi ebx
        ret
endp

proc App_ClearAllControls hWnd

        push    ebx esi
        mov     ebx,dword[hWnd]

        .menu:
        invoke  GetMenu,ebx
        mov     esi,eax
        invoke  EnableMenuItem,esi,IDM_REOPEN,MF_GRAYED
        invoke  EnableMenuItem,esi,IDM_CLOSE,MF_GRAYED

        .patch:
        stdcall GetChild,ebx,IDC_PAT_PATCH
        invoke  EnableWindow,eax,FALSE

        .restore:
        stdcall GetChild,ebx,IDC_PAT_RESTORE
        invoke  EnableWindow,eax,FALSE

        .filename:
        stdcall GetChild,ebx,IDC_PAT_FILENAME
        mov     esi,eax
        invoke  SendMessage,esi,WM_SETTEXT,0,App_szCtrlNoFile
        invoke  SendMessage,esi,EM_SETSEL,0,-1
        invoke  SendMessage,esi,EM_SETSEL,-1,-1

        .version:
        stdcall GetChild,ebx,IDC_PAT_VERSIONV
        invoke  SendMessage,eax,WM_SETTEXT,0,App_szCtrlNA

        .protected:
        stdcall GetChild,ebx,IDC_PAT_PROTECTEDV
        invoke  SendMessage,eax,WM_SETTEXT,0,App_szCtrlNA

        .laa:
        stdcall GetChild,ebx,IDC_PAT_LAAFLAGV
        invoke  SendMessage,eax,WM_SETTEXT,0,App_szCtrlNA

        .status:
        stdcall GetChild,ebx,IDC_PAT_STATUSV
        invoke  SendMessage,eax,WM_SETTEXT,0,App_szCtrlNA

        .laa_cb:
        stdcall GetChild,ebx,IDC_PAT_ENABLELAA
        mov     esi,eax
        invoke  SendMessage,esi,BM_SETCHECK,BST_UNCHECKED,0
        invoke  EnableWindow,esi,FALSE

        .end:
        pop     esi ebx
        ret
endp

proc App_UpdateAllControls hWnd

        push    ebx esi edi
        mov     ebx,dword[hWnd]
        mov     edi,FilePatcher

        .check_open:
        cmp     word[OFN_szFileName],0
        je      .clear

        .menu:
        invoke  GetMenu,ebx
        mov     esi,eax
        invoke  EnableMenuItem,esi,IDM_REOPEN,MF_ENABLED
        invoke  EnableMenuItem,esi,IDM_CLOSE,MF_ENABLED

        .patch:
        stdcall GetChild,ebx,IDC_PAT_PATCH
        invoke  EnableWindow,eax,TRUE

        .restore:
        stdcall GetChild,ebx,IDC_PAT_RESTORE
        invoke  EnableWindow,eax,TRUE

        .filename:
        stdcall GetChild,ebx,IDC_PAT_FILENAME
        mov     esi,eax
        invoke  SendMessage,esi,WM_SETTEXT,0,OFN_szFileName
        invoke  SendMessage,esi,EM_SETSEL,0,-1
        invoke  SendMessage,esi,EM_SETSEL,-1,-1

        .version:
        stdcall GetChild,ebx,IDC_PAT_VERSIONV
        mov     ecx,dword[edi+FILEPATCHER.tT1.tExtra.eVersionID]
        mov     ecx,dword[App_pazCtrlVersionTbl+ecx*4]
        invoke  SendMessage,eax,WM_SETTEXT,0,ecx

        .protected:
        stdcall GetChild,ebx,IDC_PAT_PROTECTEDV
        mov     ecx,dword[edi+FILEPATCHER.tT1.tExtra.eProtected]
        mov     ecx,dword[App_pazCtrlProtectedTbl+ecx*4]
        invoke  SendMessage,eax,WM_SETTEXT,0,ecx

        .laa:
        stdcall GetChild,ebx,IDC_PAT_LAAFLAGV
        mov     ecx,dword[edi+FILEPATCHER.tT1.tExtra.eLAAFlag]
        mov     ecx,dword[App_pazCtrlLAAFlagTbl+ecx*4]
        invoke  SendMessage,eax,WM_SETTEXT,0,ecx

        .status:
        stdcall GetChild,ebx,IDC_PAT_STATUSV
        mov     ecx,dword[edi+FILEPATCHER.tT1.tExtra.ePatched]
        mov     ecx,dword[App_pazCtrlPatchedTbl+ecx*4]
        invoke  SendMessage,eax,WM_SETTEXT,0,ecx

        .laa_cb:
        stdcall GetChild,ebx,IDC_PAT_ENABLELAA
        mov     esi,eax
        xor     ecx,ecx
        cmp     dword[edi+FILEPATCHER.tT1.tExtra.eLAAFlag],TRUE
        sete    cl
        invoke  SendMessage,esi,BM_SETCHECK,ecx,0
        invoke  EnableWindow,esi,TRUE

        .end:
        pop     edi esi ebx
        ret

        .clear:
        stdcall App_ClearAllControls,ebx
        pop     edi esi ebx
        ret
endp

proc App_UpdateAllOptions hWnd

        push    ebx esi edi
        mov     ebx,dword[hWnd]
        mov     edi,FilePatcher

        .laa_cb:
        stdcall GetChild,ebx,IDC_PAT_ENABLELAA
        invoke  SendMessage,eax,BM_GETCHECK,0,0
        xor     ecx,ecx
        cmp     eax,BST_CHECKED
        sete    cl
        mov     dword[edi+FILEPATCHER.tT1.tExtra.eLAAFlag],ecx

        .end:
        pop     edi esi ebx
        ret
endp

proc App_OpenIniFile hWnd,pszFilename

        locals
                szOperation du 'open',0
        endl

        .open:
        lea     eax,[szOperation]
        invoke  _ShellExecute,NULL,eax,dword[pszFilename],NULL,NULL,SW_SHOWNORMAL
        cmp     eax,32
        jbe     .err_launch

        .end:
        ret

        .err_launch:
        invoke  MessageBox,dword[hWnd],App_szErrLaunchIni,App_szErrorCap,MB_ICONERROR+MB_OK
        jmp     .end
endp

proc App_ResetIniFile hWnd,pszFilename,pacFileBuf,uiFileBufSize

        push    ebx

        .open:
        invoke  CreateFile,dword[pszFilename],GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
        mov     ebx,eax
        sub     eax,INVALID_HANDLE_VALUE
        jz      .err_open

        .write:
        lea     eax,[pszFilename] ;lpNumberOfBytesWritten
        invoke  WriteFile,ebx,dword[pacFileBuf],dword[uiFileBufSize],eax,NULL
        test    eax,eax
        jz      .err_write

        .done:
        invoke  MessageBox,dword[hWnd],App_szInfoResetIni,App_szInfoCap,MB_ICONINFORMATION+MB_OK

        .close:
        invoke  CloseHandle,ebx

        .end:
        pop     ebx
        ret

        .err_open:
        invoke  MessageBox,dword[hWnd],App_szErrOpenIni,App_szErrorCap,MB_ICONERROR+MB_OK
        jmp     .end

        .err_write:
        invoke  MessageBox,dword[hWnd],App_szErrWriteIni,App_szErrorCap,MB_ICONERROR+MB_OK
        jmp     .close
endp

proc App_MessageBeep uiBeepType

        mov     eax,dword[uiBeepType]
        test    eax,eax
        jz      .end
        cmp     eax,-1
        je      .default
        cmp     eax,-2
        je      .simple
        shl     eax,4 ; 1 = MB_ICONERROR, 2 = MB_ICONQUESTION, 3 = MB_ICONWARNING, 4 = MB_ICONINFORMATION
        invoke  MessageBeep,eax
        .end:
        ret

        .default:
        invoke  MessageBeep,MB_OK
        ret

        .simple:
        invoke  MessageBeep,0xFFFFFFFF
        ret
endp

proc App_OpenFile hWnd,ptFilePatcher

        push    ebx
        mov     ebx,dword[hWnd]

        .patcher_closesilent:
        stdcall App_CloseFileSilent,ebx,dword[ptFilePatcher]

        .patcher_load:
        stdcall Patcher_LoadFile,dword[ptFilePatcher],OFN_szFileName
        test    eax,eax
        jz      .err_load

        .update_ui:
        stdcall App_UpdateAllControls,ebx
        stdcall App_MessageBeep,4

        .end:
        pop     ebx
        ret

        .err_load:
        invoke  MessageBox,ebx,App_szErrLoadTarget,App_szErrorCap,MB_ICONERROR+MB_OK
        stdcall App_ClearAllControls,ebx
        jmp     .end
endp

proc App_CloseFile hWnd,ptFilePatcher

        .patcher_close:
        stdcall Patcher_DeInit,dword[ptFilePatcher],OFN_szFileName

        .update_ui:
        stdcall App_ClearAllControls,dword[hWnd]
        stdcall App_MessageBeep,4

        .end:
        ret
endp

proc App_PatchFile hWnd,ptFilePatcher

        push    ebx
        mov     ebx,dword[hWnd]

        .update_options:
        stdcall App_UpdateAllOptions,ebx

        .patcher_save:
        stdcall Patcher_SaveFile,dword[ptFilePatcher],OFN_szFileName,1
        test    eax,eax
        jz      .err_save

        .update_ui:
        stdcall App_UpdateAllControls,ebx
        stdcall App_MessageBeep,4

        .end:
        pop     ebx
        ret

        .err_save:
        invoke  MessageBox,ebx,App_szErrSaveTarget,App_szErrorCap,MB_ICONERROR+MB_OK
        ;stdcall App_ClearAllControls,ebx
        jmp     .end
endp

proc App_RestoreFile hWnd,ptFilePatcher

        push    ebx
        mov     ebx,dword[hWnd]

        .update_options:
        stdcall App_UpdateAllOptions,ebx

        .patcher_save:
        stdcall Patcher_SaveFile,dword[ptFilePatcher],OFN_szFileName,0
        test    eax,eax
        jz      .err_save

        .update_ui:
        stdcall App_UpdateAllControls,ebx
        stdcall App_MessageBeep,4

        .end:
        pop     ebx
        ret

        .err_save:
        invoke  MessageBox,ebx,App_szErrSaveTarget,App_szErrorCap,MB_ICONERROR+MB_OK
        ;stdcall App_ClearAllControls,ebx
        jmp     .end
endp

proc App_CloseFileSilent hWnd,ptFilePatcher

        .check_open:
        stdcall Patcher_IsFileOpen,dword[ptFilePatcher]
        test    eax,eax
        jz      .end

        .patcher_close:
        stdcall Patcher_DeInit,dword[ptFilePatcher],NULL

        .end:
        ret
endp
