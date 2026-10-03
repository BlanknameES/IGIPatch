;------------------------------------------------------------
; proxy hooks
;------------------------------------------------------------

loc_491C05: ; Display_SetMode

        .rect = -10h

        .update_mode_vars:
        ccall   Display_UpdateModeVars,ebp

        .back:
        mov     eax,dword[esp+1Ch+.rect+RECT.top]
        mov     ecx,dword[esp+1Ch+.rect+RECT.bottom]
        jmp     near PATCHER_JUMP_TRAP ;loc_491C0D
        .fixup1 = $-4

proc Display_UpdateModeVars c ptDisplayMode

        .store_screen_size:
        invoke  GetSystemMetrics,SM_CXSCREEN
        mov     dword[Display_nScreenWidth],eax
        invoke  GetSystemMetrics,SM_CYSCREEN
        mov     dword[Display_nScreenHeight],eax

        .get_displaymode:
        mov     eax,dword[ptDisplayMode]

        .store_width_height:
        mov     ecx,dword[eax+4] ;ptDisplayMode->nWidth
        mov     edx,dword[eax+8] ;ptDisplayMode->nHeight
        mov     dword[Display_nCurrentWidth],ecx
        mov     dword[Display_nCurrentHeight],edx

        .store_real_ratio:
        fld1
        fimul   dword[Display_nCurrentWidth]
        fidiv   dword[Display_nScreenWidth]
        fstp    dword[Display_nRealWidthRatio]
        fld1
        fimul   dword[Display_nCurrentHeight]
        fidiv   dword[Display_nScreenHeight]
        fstp    dword[Display_nRealHeightRatio]

        .store_aspect_ratio:
        fild    dword[Display_nCurrentWidth]
        fidiv   dword[Display_nCurrentHeight]
        fst     dword[Display_vAspectRatio]
        fmul    dword[Display_vAspectRatio34]
        fstp    dword[Display_vRelAspectRatio]

        .store_aspect_ratio_inverted:
        fld1
        fdiv    dword[Display_vAspectRatio]
        fstp    dword[Display_vAspectRatioInv]
        fld1
        fdiv    dword[Display_vRelAspectRatio]
        fstp    dword[Display_vRelAspRatioInv]

        .end:
        ret
endp

proc Display_GetAspectRatio c ; get aspect ratio

        fld     dword[Display_vAspectRatio]
        ret
endp

proc Display_GetAspectRatioInv c ; get inverted aspect ratio

        fld     dword[Display_vAspectRatioInv]
        ret
endp

proc Display_GetRelAspectRatio c ; get aspect ratio relative to 4:3

        fld     dword[Display_vRelAspectRatio]
        ret
endp

proc Display_GetRelAspectRatioInv c ; get inverted aspect ratio relative to 4:3

        fld     dword[Display_vRelAspectRatioInv]
        ret
endp

loc_48F674: ; WinMain

        .borderless:
        cmp     dword[IniFile.Modules.BorderlessPatch],FALSE
        je      .debugfeatures
        ccall   Main_InitBorderlessPatchCmds

        .debugfeatures:
        cmp     dword[IniFile.Modules.DebugFeaturesPatch],FALSE
        je      .newfpslimiter
        ccall   Main_InitDebugFeatPatchCmds

        .newfpslimiter:
        cmp     dword[IniFile.Modules.NewFPSLimiterPatch],FALSE
        je      .back
        ccall   Main_InitNewFPSLimPatchCmds

        .back:
        mov     ecx,48
        jmp     near PATCHER_JUMP_TRAP ;loc_48F679
        .fixup1 = $-4

loc_48F6D8: ; WinMain

        .dwDXVersion = -464h
        .dwOSVersion = -45Ch

        mov     ebx,PATCHER_CALL_TRAP ;AppMain_ParseCmdLineArgs:0x0048F360
        .fixup1 = $-4

        .borderless:
        cmp     dword[IniFile.Modules.BorderlessPatch],FALSE
        je      .debugfeatures
        ccall   Main_ParseBorderlessPatchCmds,ebx

        .debugfeatures:
        cmp     dword[IniFile.Modules.DebugFeaturesPatch],FALSE
        je      .newfpslimiter
        ccall   Main_ParseDebugFeatPatchCmds,ebx

        .newfpslimiter:
        cmp     dword[IniFile.Modules.NewFPSLimiterPatch],FALSE
        je      .back
        ccall   Main_ParseNewFPSLimPatchCmds,ebx

        .back:
        xor     ebx,ebx
        lea     edx,[esp+49Ch+.dwOSVersion]
        lea     eax,[esp+49Ch+.dwDXVersion]
        jmp     near PATCHER_JUMP_TRAP ;loc_48F6E0
        .fixup2 = $-4

proc Direct3D_GetCurRefreshRateWindowed c ptIC

        .read_refresh_rate:
        invoke  GetDeviceCaps,dword[ptIC],116 ;VREFRESH

        .handle_value:
        cmp     eax,1+1 ; 0 and 1 are invalid
        sbb     ecx,ecx
        mov     edx,60 ; default value
        sub     edx,eax
        and     edx,ecx
        add     eax,edx

        .end:
        ret
endp

proc Direct3D_GetCurRefreshRateFullscreen c ptDDObj

        locals
                tDM DEVMODEA
        endl

        push    ebx

        .read_refresh_rate:
        lea     ebx,[tDM]
        stdcall ZeroMemory,ebx,sizeof.DEVMODEA
        mov     dword[tDM.dmSize],sizeof.DEVMODEA
        invoke  EnumDisplaySettingsA,NULL,ENUM_CURRENT_SETTINGS,ebx

        .handle_result:
        neg     eax
        sbb     ecx,ecx
        mov     eax,dword[tDM.dmDisplayFrequency]
        and     eax,ecx

        .handle_value:
        cmp     eax,1+1 ; 0 and 1 are invalid
        sbb     ecx,ecx
        mov     edx,60 ; default value
        sub     edx,eax
        and     edx,ecx
        add     eax,edx

        .end:
        pop     ebx
        ret
endp

loc_4942F3: ; Direct3D_CreateDevice

        .get_refresh_rate:
        ccall   Direct3D_GetCurRefreshRateWindowed,esi
        mov     dword[Display_nCurrentRefreshRate],eax

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4942FC
        .fixup1 = $-4


loc_49432E: ; Direct3D_CreateDevice

        test    eax,eax
        jnz     near PATCHER_JUMP_TRAP ;loc_49467C
        .fixup1 = $-4

        .get_refresh_rate:
        ccall   Direct3D_GetCurRefreshRateFullscreen,esi
        mov     dword[Display_nCurrentRefreshRate],eax

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_494336
        .fixup2 = $-4

loc_4F5245: ; CutScene_RunHandler

        add     esp,1*4
        test    al,al
        jnz     near PATCHER_JUMP_TRAP ;loc_4F524C
        .fixup1 = $-4

        .save_cutscene_is_running:
        or      dword[CutScene_isRunning],TRUE

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4F5261
        .fixup2 = $-4

loc_4F525B: ; CutScene_RunHandler

        add     esp,2*4

        .set_is_run:
        mov     byte[esi+60h],cl ;ptCutScene->isRun

        .save_cutscene_is_running:
        xor     eax,eax
        test    cl,cl
        setnz   al
        or      dword[CutScene_isRunning],eax

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4F5261
        .fixup1 = $-4

;------------------------------------------------------------
; CDCheckPatch
;------------------------------------------------------------

loc_4162A9: ; Game_RunHandler

        add     esp,3*4
        mov     dword[PATCHER_ADDR_TRAP],ecx ;Game_iMissionID:0x00539560
        .fixup1 = $-4

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_416300
        .fixup2 = $-4

loc_4021E7: ; Flow_CreateHandler

        add     esp,2*4

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_402239
        .fixup1 = $-4

loc_418CF7: ; MenuManager_New

        mov     byte[ebp+26C3h],al
        mov     dword[ebp+2838h],ebx

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_418D53
        .fixup1 = $-4

;------------------------------------------------------------
; TimerTaskPatch
;------------------------------------------------------------

proc Timer_Open_NEW c

        .init_apis:
        ccall   Timer_InitAPI_GTC
        ccall   Timer_InitAPI_tGT
        ccall   Timer_InitAPI_QPC

        .check_api_qpc:
        cmp     dword[Timer_IsAPIAva_QPC],FALSE
        je      .check_api_tgt
        .check_api_qpc_10mhz:
        cmp     dword[Timer_IsFreq10MHz],FALSE
        je      .set_api_qpc_standard
        .set_api_qpc_10mhz:
        mov     dword[Timer_pfnGetCounter],Timer_Read_QPC_10MHz
        jmp     .read_counter
        .set_api_qpc_standard:
        mov     dword[Timer_pfnGetCounter],Timer_Read_QPC_Standard
        jmp     .read_counter

        .check_api_tgt:
        cmp     dword[Timer_IsAPIAva_tGT],FALSE
        je      .check_api_gtc
        .set_api_tgt:
        mov     dword[Timer_pfnGetCounter],Timer_Read_tGT
        jmp     .read_counter

        .check_api_gtc:
        cmp     dword[Timer_IsAPIAva_GTC],FALSE
        je      .error
        .set_api_gtc:
        mov     dword[Timer_pfnGetCounter],Timer_Read_GTC
        ;jmp     .read_counter

        .read_counter:
        ccall   dword[Timer_pfnGetCounter]
        mov     dword[Timer_nStartTime],eax

        .end:
        ret

        .error:
        ccall   LDebug_AbortWithError,cstrInitTimerError
        ret
endp

align 16
Timer_Read_NEW: ; skipped proc macro

        .read_counter:
        ccall   dword[Timer_pfnGetCounter]
        sub     eax,dword[Timer_nStartTime]

        .end:
        retn    0

proc Timer_Close_NEW c

        .uninit_apis:
        ccall   Timer_UnInitAPI_GTC
        ccall   Timer_UnInitAPI_tGT
        ccall   Timer_UnInitAPI_QPC

        .end:
        ret
endp

proc Timer_InitAPI_tGT c

        locals
                tTimeCaps rd 2
                sizeof.tTimeCaps = 8
        endl

        .get_caps:
        lea     eax,[tTimeCaps]
        invoke  timeGetDevCaps,eax,sizeof.tTimeCaps
        test    eax,eax
        jnz     .end ; MMSYSERR_NOERROR = 0

        .set_res:
        mov     eax,dword[tTimeCaps]
        mov     dword[Timer_nMaxSysRes],eax
        invoke  timeBeginPeriod,eax
        test    eax,eax
        jnz     .end ; MMSYSERR_NOERROR = 0

        .set_available:
        mov     dword[Timer_IsAPIAva_tGT],TRUE

        .end:
        ret
endp

proc Timer_InitAPI_QPC c

        .get_freq:
        invoke  QueryPerformanceFrequency,Timer_nFrequency
        test    eax,eax
        jz      .end

        .check_max_freq: ; 4.29 GHz
        cmp     dword[Timer_nFrequency+4],0
        jne     .end

        .is_10mhz:
        xor     ecx,ecx
        cmp     dword[Timer_nFrequency],10000000
        sete    cl
        mov     dword[Timer_IsFreq10MHz],ecx

        .set_available:
        mov     dword[Timer_IsAPIAva_QPC],TRUE

        .end:
        ret
endp

proc Timer_InitAPI_GTC c

        .set_available:
        mov     dword[Timer_IsAPIAva_GTC],TRUE

        .end:
        ret
endp

align 16
Timer_Read_QPC_10MHz: ; skipped proc macro

        .n64Counter = -8

        sub     esp,8

        .get_counter:
        ;lea     eax,[esp+8+.n64Counter]
        invoke  QueryPerformanceCounter,esp
        test    eax,eax
        jz      .error

        .fast_10mhz:
        mov     eax,dword[esp+8+.n64Counter]
        mov     edx,dword[esp+8+.n64Counter+4]
        mov     ecx,10000
        div     ecx

        .end:
        add     esp,8
        retn    0

        .error:
        ccall   LDebug_AbortWithError,cstrInitTimerError
        add     esp,8
        retn    0

align 16
Timer_Read_QPC_Standard: ; skipped proc macro

        .n64Counter = -8

        sub     esp,8

        .get_counter:
        ;lea     eax,[esp+8+.n64Counter]
        invoke  QueryPerformanceCounter,esp
        test    eax,eax
        jz      .error

        .standard:
        mov     eax,dword[esp+8+.n64Counter]
        mov     edx,dword[esp+8+.n64Counter+4]
        mov     ecx,dword[Timer_nFrequency]
        div     ecx
        imul    eax,1000
        push    eax
        mov     eax,edx
        mov     edx,1000
        mul     edx
        div     ecx
        pop     edx
        add     eax,edx

        .end:
        add     esp,8
        retn    0

        .error:
        ccall   LDebug_AbortWithError,cstrInitTimerError
        add     esp,8
        retn    0

align 16
Timer_Read_tGT: ; skipped proc macro

        .get_time:
        invoke  timeGetTime

        .end:
        retn    0

align 16
Timer_Read_GTC: ; skipped proc macro

        .get_ticks:
        invoke  GetTickCount

        .end:
        retn    0

proc Timer_UnInitAPI_QPC c

        .set_not_available:
        mov     dword[Timer_IsAPIAva_QPC],FALSE

        .end:
        ret
endp

proc Timer_UnInitAPI_tGT c

        .check_api:
        cmp     dword[Timer_IsAPIAva_tGT],FALSE
        je      .end

        .restore_res:
        invoke  timeEndPeriod,dword[Timer_nMaxSysRes]

        .set_not_available:
        mov     dword[Timer_IsAPIAva_tGT],FALSE

        .end:
        ret
endp

proc Timer_UnInitAPI_GTC c

        .set_not_available:
        mov     dword[Timer_IsAPIAva_GTC],FALSE

        .end:
        ret
endp

;------------------------------------------------------------
; MouseCursorPatch
;------------------------------------------------------------

proc Cursor_GetFullscreenCursorPos c hWnd ; TODO: use directinput

        locals
                Cursor_Pos POINT
        endl

        push    ebx
        lea     ebx,[Cursor_Pos]
        invoke  GetCursorPos,ebx
        test    eax,eax
        jz      .check_pos
        invoke  ScreenToClient,dword[hWnd],ebx
        test    eax,eax
        .check_pos:
        setnz   al
        and     eax,1
        neg     eax
        mov     ecx,dword[ebx+POINT.x]
        and     ecx,eax
        mov     edx,dword[ebx+POINT.y]
        and     edx,eax
        neg     eax
        pop     ebx
        ret
endp

proc Cursor_GetWindowedCursorPos c hWnd

        locals
                Cursor_Pos POINT
        endl

        .get_pos:
        mov     ecx,dword[PATCHER_ADDR_TRAP] ;Cursor_nMouseX:0x0057BC58
        .fixup1 = $-4
        mov     edx,dword[PATCHER_ADDR_TRAP] ;Cursor_nMouseY:0x0057BC5C
        .fixup2 = $-4

        .check_borderless:
        cmp     dword[AppContext_isBorderless],FALSE
        je      .end

        .check_scaling_mode:
        cmp     dword[IniFile.BLP.WindowScalingMode],0
        je      .end

        .save_pos:
        mov     dword[Cursor_Pos+POINT.x],ecx
        mov     dword[Cursor_Pos+POINT.y],edx

        .scale_posx:
        fild    dword[Cursor_Pos+POINT.x]
        fmul    dword[Display_nRealWidthRatio]
        fistp   dword[Cursor_Pos+POINT.x]

        .scale_posy:
        fild    dword[Cursor_Pos+POINT.y]
        fmul    dword[Display_nRealHeightRatio]
        fistp   dword[Cursor_Pos+POINT.y]

        .load_pos:
        mov     ecx,dword[Cursor_Pos+POINT.x]
        mov     edx,dword[Cursor_Pos+POINT.y]

        .end:
        mov     eax,TRUE
        ret
endp

proc Cursor_GetCursorPos c

        .get_wnd:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;AppContext_tAppContext.hWnd:0x005C8BC4
        .fixup1 = $-4

        .check_fullscreen:
        cmp     dword[PATCHER_ADDR_TRAP],FALSE ;AppContext_tAppContext.isFullscreen:0x005C8C00
        .fixup2 = $-1-4
        je      .get_pos_windowed

        .get_pos_fullscreen:
        ccall   Cursor_GetFullscreenCursorPos,eax
        ret

        .get_pos_windowed:
        ccall   Cursor_GetWindowedCursorPos,eax
        ret
endp

proc Cursor_UpdatePosition c ptCursor

        push    ebx esi edi
        mov     ebx,dword[ptCursor]

        .get_pos:
        ccall   Cursor_GetCursorPos
        test    eax,eax
        jz      .end
        mov     esi,ecx
        mov     edi,edx

        .clamp_posx:
        cmp     esi,0x80000000
        sbb     eax,eax
        and     esi,eax
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup1 = $-4
        dec     eax
        cmp     esi,eax
        sbb     ecx,ecx
        and     esi,ecx
        not     ecx
        and     eax,ecx
        or      esi,eax

        .clamp_posy:
        cmp     edi,0x80000000
        sbb     eax,eax
        and     edi,eax
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup2 = $-4
        dec     eax
        cmp     edi,eax
        sbb     ecx,ecx
        and     edi,ecx
        not     ecx
        and     eax,ecx
        or      edi,eax

        .set_pos:
        mov     dword[ebx+24h],esi ;ptCursor->nX
        mov     dword[ebx+28h],edi ;ptCursor->nY

        .end:
        pop     edi esi ebx
        ret
endp

proc Cursor_RunHandler_NEW c ptCursor

        push    ebx
        mov     ebx,dword[ptCursor]

        .check_patch:
        cmp     dword[IniFile.Modules.NewFPSLimiterPatch],FALSE
        je      .update_pos

        .check_interp: ; if interp is enabled, update pos only during interp phase
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jz      .update_buttons

        .update_pos:
        ccall   Cursor_UpdatePosition,ebx

        .update_buttons:
        mov     ecx,dword[ebx+3Ch] ;ptCursor->isButtonDown
        mov     edx,dword[PATCHER_ADDR_TRAP] ;Mouse_tMouse.bButton:0x00C28F8C
        .fixup1 = $-4
        and     edx,1
        mov     dword[ebx+38h],ecx ;ptCursor->isPrevButtonDown
        mov     dword[ebx+3Ch],edx ;ptCursor->isButtonDown

        .end:
        pop     ebx
        ret
endp

proc Debug_MsgBoxFunc c zMessage ; leftover?

        push    ebx
        ccall   Cursor_SetShowLocked,TRUE
        ccall   Cursor_ForceShow,TRUE
        ccall   AppContext_GethWnd
        mov     ebx,eax
        ccall   AppContext_GetName
        invoke  MessageBoxA,ebx,dword[zMessage],eax,MB_ICONSTOP
        ccall   Cursor_ForceShow,FALSE
        ccall   Cursor_SetShowLocked,FALSE
        pop     ebx
        ret
endp

;------------------------------------------------------------
; BorderlessPatch
;------------------------------------------------------------

proc Main_InitBorderlessPatchCmds c

        .init_cmds:
        ccall   AppContext_SetBorderless,FALSE

        .end:
        ret
endp

proc Main_ParseBorderlessPatchCmds c pfParseProc

        push    ebx
        mov     ebx,dword[pfParseProc]

        .parse_cmds:
        ccall   ebx,cstrBorderless,Main_ParseBorderlessCB

        .end:
        pop     ebx
        ret
endp

proc AppContext_SetBorderless c isBorderless

        xor     eax,eax
        cmp     dword[isBorderless],FALSE
        setne   al
        mov     dword[AppContext_isBorderless],eax
        ret
endp

proc AppContext_GetBorderless c

        mov     eax,dword[AppContext_isBorderless]
        ret
endp

proc Main_ParseBorderlessCB c

        ;ccall   AppContext_SetBorderless,TRUE
        ccall   AppContext_SetWindowMode,2 ;BorderlessMode
        ret
endp

proc AppContext_SetWindowMode c nWindowMode

        mov     eax,dword[nWindowMode]
        xor     ecx,ecx
        test    eax,eax
        setz    cl
        mov     dword[PATCHER_ADDR_TRAP],ecx ;AppContext_tAppContext.isFullscreen:0x005C8C00
        .fixup1 = $-4
        sub     eax,1
        sub     ecx,1
        and     eax,ecx
        mov     dword[AppContext_isBorderless],eax
        ret
endp

proc AppContext_GetWindowMode c

        mov     eax,dword[PATCHER_ADDR_TRAP] ;AppContext_tAppContext.isFullscreen:0x005C8C00
        .fixup1 = $-4
        cmp     eax,1
        sbb     ecx,ecx
        xor     edx,edx
        cmp     dword[AppContext_isBorderless],FALSE
        setne   dl
        lea     eax,[edx+1]
        and     eax,ecx
        ret
endp

proc AppContext_GetWindowModeStyle c nMode

        .check_mode:
        mov     eax,dword[nMode]
        cmp     eax,-1
        jne     .get_style

        .get_mode:
        ccall   AppContext_GetWindowMode

        .get_style:
        mov     eax,dword[Main_aptWindowStyleList+eax*4]
        mov     eax,dword[eax]
        ret
endp

proc Main_AdjustWindowRect c ptRect,nWindowMode,nWindowWidth,nWindowHeight

        locals
                tTempRect RECT
        endl

        push    ebx esi edi
        mov     esi,dword[nWindowWidth]
        mov     edi,dword[nWindowHeight]

        .get_windowmode:
        mov     eax,dword[nWindowMode]
        cmp     eax,-1
        jne     .save_windowmode
        ccall   AppContext_GetWindowMode

        .save_windowmode:
        mov     ebx,eax

        .get_windowstyle:
        mov     ecx,dword[Main_aptWindowStyleList+ebx*4]
        mov     ecx,dword[ecx]

        .adjust_style:
        mov     dword[tTempRect.left],0
        mov     dword[tTempRect.top],0
        mov     dword[tTempRect.right],esi
        mov     dword[tTempRect.bottom],edi
        lea     eax,[tTempRect]
        invoke  AdjustWindowRect,eax,ecx,FALSE
        ;test    eax,eax
        ;jz      .end
        mov     esi,dword[tTempRect.right]
        sub     esi,dword[tTempRect.left]
        mov     edi,dword[tTempRect.bottom]
        sub     edi,dword[tTempRect.top]
        ;mov     dword[tTempRect.left],0
        ;mov     dword[tTempRect.top],0
        ;mov     dword[tTempRect.right],esi
        ;mov     dword[tTempRect.bottom],edi

        .get_rect:
        mov     eax,ebx
        mov     ebx,dword[ptRect]

        .check_windowmode:
        cmp     eax,2
        je      .mode_borderless
        cmp     eax,1
        je      .mode_windowed
        ;test    eax,eax
        ;jz      .mode_fullscreen

        .mode_fullscreen: ; fullscreen
        xor     eax,eax
        mov     dword[ebx+RECT.left],eax
        mov     dword[ebx+RECT.top],eax
        invoke  GetSystemMetrics,SM_CXSCREEN
        mov     dword[ebx+RECT.right],eax
        invoke  GetSystemMetrics,SM_CYSCREEN
        mov     dword[ebx+RECT.bottom],eax
        jmp     .ok

        .mode_windowed: ; centered
        invoke  GetSystemMetrics,SM_CXSCREEN
        sub     eax,esi
        cmp     eax,0x80000000
        sbb     ecx,ecx
        and     eax,ecx
        shr     eax,1
        lea     edx,[eax+esi]
        mov     dword[ebx+RECT.left],eax
        mov     dword[ebx+RECT.right],edx
        invoke  GetSystemMetrics,SM_CYSCREEN
        sub     eax,edi
        cmp     eax,0x80000000
        sbb     ecx,ecx
        and     eax,ecx
        shr     eax,1
        lea     edx,[eax+edi]
        mov     dword[ebx+RECT.top],eax
        mov     dword[ebx+RECT.bottom],edx
        jmp     .ok

        .mode_borderless:
        cmp     dword[IniFile.BLP.WindowScalingMode],1
        je      .mode_fullscreen
        jmp     .mode_windowed

        .mode_borderless_mode0_alt: ; top-left
        xor     eax,eax
        mov     dword[ebx+RECT.left],eax
        mov     dword[ebx+RECT.top],eax
        mov     dword[ebx+RECT.right],esi
        mov     dword[ebx+RECT.bottom],edi
        ;jmp     .ok

        .ok:
        mov     eax,TRUE

        .end:
        pop     edi esi ebx
        ret
endp

loc_48F724: ; WinMain

        .ptWindow = -45Ch

        .get_wndrect:
        ccall   Main_AdjustWindowRect,Main_tWindowPosRect,1,640,480
        mov     ecx,dword[Main_tWindowPosRect.left]
        mov     edx,dword[Main_tWindowPosRect.top]
        mov     esi,dword[Main_tWindowPosRect.right]
        mov     edi,dword[Main_tWindowPosRect.bottom]
        sub     esi,ecx ; esi = width
        sub     edi,edx ; edi = height

        .get_classname:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;zClassName:0x00541D68
        .fixup1 = $-4

        .create_window:
        invoke  CreateWindowExA,0,eax,eax,dword[Main_dwWindowedWindowStyle],ecx,edx,esi,edi,NULL,NULL,ebp,NULL
        mov     esi,eax
        mov     dword[esp+474h+.ptWindow],esi
        test    eax,eax
        jz      .error

        .back:
        push    ebx
        jmp     near PATCHER_JUMP_TRAP ;loc_48F790
        .fixup2 = $-4

        .error:
        push    ebx
        jmp     near PATCHER_JUMP_TRAP ;loc_48F781
        .fixup3 = $-4

loc_491B7B: ; Display_SetMode

        .rect = -10h

        .get_wndrect:
        lea     esi,[esp+1Ch+.rect]

        .adjust_wndrect:
        mov     ecx,dword[ebp+4] ;ptDisplayMode->nWidth
        mov     edx,dword[ebp+8] ;ptDisplayMode->nHeight
        ccall   Main_AdjustWindowRect,esi,-1,ecx,edx

        .get_hwnd:
        call    near PATCHER_CALL_TRAP ;AppContext_GethWnd:0x0048F0A0
        .fixup1 = $-4
        mov     edi,eax

        .get_wndstyle:
        ccall   AppContext_GetWindowModeStyle,-1

        .set_wndstyle:
        invoke  SetWindowLongA,edi,GWL_STYLE,eax

        .save_wndrect:
        mov     eax,dword[esi+RECT.left]
        mov     ecx,dword[esi+RECT.top]
        mov     edx,dword[esi+RECT.right]
        mov     edi,dword[esi+RECT.bottom]
        mov     dword[Main_tWindowPosRect.left],eax
        mov     dword[Main_tWindowPosRect.top],ecx
        mov     dword[Main_tWindowPosRect.right],edx
        mov     dword[Main_tWindowPosRect.bottom],edi

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_491C05
        .fixup2 = $-4

loc_494FB1: ; Direct3D_WinProcCB

        .rect = -10h

        .get_wndstyle:
        ccall   AppContext_GetWindowModeStyle,-1

        .back:
        lea     edx,[esp+14h+.rect]
        jmp     near PATCHER_JUMP_TRAP ;loc_494FC8
        .fixup1 = $-4

loc_48A452: ; LoadingScreen_New

        .nItems = 4

        mov     eax,dword[esp+50h+.nItems]
        mov     dword[esi],eax ;ptLoadingScreen->nMaxProgress
        mov     dword[esi+4],0 ;ptLoadingScreen->nActiveProgress

        .get_rect:
        lea     ebx,[Main_tWindowPosRect]

        .set_progressbar_posx:
        mov     eax,dword[ebx+RECT.right]
        sub     eax,dword[ebx+RECT.left]
        sub     eax,640
        cdq
        sub     eax,edx
        sar     eax,1
        add     eax,40
        mov     dword[esi+8],eax ;ptLoadingScreen->nX

        .set_progressbar_posy:
        mov     eax,dword[ebx+RECT.bottom]
        sub     eax,dword[ebx+RECT.top]
        .progressbar_posy_set:
        sub     eax,480
        cdq
        sub     eax,edx
        sar     eax,1
        add     eax,440
        mov     dword[esi+0Ch],eax ;ptLoadingScreen->nY

        .back:
        lea     ecx,[esi+10h]
        push    10
        push    560
        push    ecx
        jmp     near PATCHER_JUMP_TRAP ;loc_48A499
        .fixup1 = $-4

loc_48A4AD: ; LoadingScreen_New

        .set_background_size:
        mov     eax,dword[ebx+RECT.right]
        mov     edx,dword[ebx+RECT.bottom]
        sub     eax,dword[ebx+RECT.left]
        sub     edx,dword[ebx+RECT.top]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_48A4B3
        .fixup1 = $-4

loc_48A50D: ; LoadingScreen_New

        ;.nItems = 4
        .nTempValue = 4

        .logo_posx:
        mov     eax,dword[ebx+RECT.right]
        sub     eax,dword[ebx+RECT.left]
        sub     eax,640
        cdq
        sub     eax,edx
        sar     eax,1
        mov     dword[esp+48h+.nTempValue],eax
        fild    dword[esp+48h+.nTempValue]
        fstp    dword[ebp+4]

        .logo_posy:
        mov     eax,dword[ebx+RECT.bottom]
        sub     eax,dword[ebx+RECT.top]
        sub     eax,480
        cdq
        sub     eax,edx
        sar     eax,1
        mov     dword[esp+48h+.nTempValue],eax
        fild    dword[esp+48h+.nTempValue]
        fstp    dword[ebp+8]

        .back:
        push    ebp
        jmp     near PATCHER_JUMP_TRAP ;loc_48A53E
        .fixup1 = $-4

;------------------------------------------------------------
; DisplayModesFix
;------------------------------------------------------------

proc Config_FillDisplayDevices nNumDisplayDevices,ptDisplayDeviceTable

        .set_num_devices:
        mov     eax,dword[nNumDisplayDevices]
        cmp     eax,MAXDISPLAYDEVICES+1
        sbb     ecx,ecx
        sub     eax,MAXDISPLAYDEVICES
        and     eax,ecx
        add     eax,MAXDISPLAYDEVICES
        mov     dword[Config_nNumDisplayDevices],eax ; capped to MAXDISPLAYDEVICES

        .check_no_devices:
        test    eax,eax
        jz      .error

        .loop_init:
        push    ebx esi edi
        mov     edx,Config_atDisplayDevice
        mov     ebx,dword[ptDisplayDeviceTable]

        .loop_body:
        mov     ecx,sizeof.DisplayDevice_t/4 ; assumes multiplier of 4
        mov     esi,ebx
        lea     edi,[edx+ConfigDisplayDevice_s.tDisplayDevice]
        rep     movsd
        mov     byte[edx+ConfigDisplayDevice_s.tDisplayDevice.zIdentifier+sizeof.DisplayDevice_t.zIdentifier-1],0
        mov     byte[edx+ConfigDisplayDevice_s.tDisplayDevice.zDesc+sizeof.DisplayDevice_t.zDesc-1],0
        mov     dword[edx+ConfigDisplayDevice_s.nNumDisplayModes],0
        mov     dword[edx+ConfigDisplayDevice_s.nDefDisplayModeID],-1

        .loop_inc:
        add     edx,sizeof.ConfigDisplayDevice_s
        add     ebx,sizeof.DisplayDevice_t
        dec     eax
        jnz     .loop_body

        .loop_end:
        pop     edi esi ebx

        .end:
        ret

        .error:
        mov     eax,PATCHER_ADDR_TRAP ;0x005382E8 -> 'No D3D drivers with hardware acceleration found.',0
        .fixup1 = $-4
        ccall   LDebug_AbortWithError,eax
endp

loc_4035F5: ; Config_Open

        .tDisplayDeviceTable = -500h

        .fill_devices:
        lea     ecx,[esp+508h+.tDisplayDeviceTable]
        stdcall Config_FillDisplayDevices,eax,ecx

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_40362D
        .fixup1 = $-4

proc Config_AddDisplayModeToList iDevice,nWidth,nHeight,nDepth

        push    ebx esi edi

        .get_pointers:
        mov     eax,dword[iDevice]
        imul    edi,eax,sizeof.ConfigDisplayDevice_s
        add     edi,Config_atDisplayDevice
        mov     esi,dword[edi+ConfigDisplayDevice_s.nNumDisplayModes]

        .check_limit:
        cmp     esi,MAXDISPLAYMODES
        jge     .end

        .add_to_list:
        imul    ebx,esi,sizeof.ConfigDisplayMode_s
        lea     ebx,[edi+ConfigDisplayDevice_s.tDisplayModeList+ebx]
        mov     eax,dword[nWidth]
        mov     ecx,dword[nHeight]
        mov     edx,dword[nDepth]
        mov     dword[ebx+ConfigDisplayMode_s.nWidth],eax
        mov     dword[ebx+ConfigDisplayMode_s.nHeight],ecx
        mov     dword[ebx+ConfigDisplayMode_s.nDepth],edx
        add     esi,1
        mov     dword[edi+ConfigDisplayDevice_s.nNumDisplayModes],esi

        .end:
        pop     edi esi ebx
        ret
endp

proc Config_EnumDisplayModeCB_NEW c ptDisplayMode

        push    ebx esi edi
        mov     esi,dword[ptDisplayMode]

        .check_valid_mode:
        ;cmp     byte[esi+1Ch],0 ;ptDisplayMode->zDeviceIdentifier[0]
        ;je      .end
        cmp     dword[esi+4],MINDISPLAYMODEWIDTH ;ptDisplayMode->nWidth
        jl      .end
        cmp     dword[esi+8],MINDISPLAYMODEHEIGHT ;ptDisplayMode->nHeight
        jl      .end
        cmp     dword[esi+10h],MINDISPLAYMODEDEPTH ;ptDisplayMode->nBitsPerPixel
        jl      .end

        .get_pointers:
        mov     edi,Config_atDisplayDevice
        mov     eax,dword[Config_nNumDisplayDevices]

        ;.check_no_devices:
        ;test    eax,eax
        ;jz      .end

        .loop_init:
        xor     ebx,ebx
        mov     dword[ptDisplayMode],eax ;nNumDisplayDevices

        .loop_body:
        lea     eax,[esi+1Ch] ;&ptDisplayMode->zDeviceIdentifier[0]
        lea     ecx,[edi+ConfigDisplayDevice_s.tDisplayDevice.zIdentifier]
        ccall   strncmp,eax,ecx,sizeof.DisplayDevice_t.zIdentifier-1
        test    eax,eax
        jnz     .loop_inc

        .add_entry:
        mov     eax,dword[esi+4] ;ptDisplayMode->nWidth
        mov     ecx,dword[esi+8] ;ptDisplayMode->nHeight
        mov     edx,dword[esi+10h] ;ptDisplayMode->nBitsPerPixel
        stdcall Config_AddDisplayModeToList,ebx,eax,ecx,edx

        .loop_inc:
        add     ebx,1
        add     edi,sizeof.ConfigDisplayDevice_s
        cmp     ebx,dword[ptDisplayMode] ;nNumDisplayDevices
        jl      .loop_body

        .end:
        pop     edi esi ebx
        ret
endp

proc Config_UpdateDevicesDefMode

        locals
                nNumTotalDisplayModes dd ?
                nDisplayDevicesCount dd ?
                nDisplayModesCount dd ?
                nDefModeID dd ?
                nDefModeWidth dd ?
                nDefModeHeight dd ?
                nDefModeDepth dd ?
        endl

        push    ebx esi edi

        .init_total_modes:
        mov     dword[nNumTotalDisplayModes],0

        .get_pointers:
        mov     edi,Config_atDisplayDevice
        mov     eax,dword[Config_nNumDisplayDevices]

        ;.check_no_devices:
        ;test    eax,eax
        ;jz      .end

        .device_loop_init:
        mov     dword[nDisplayDevicesCount],eax

        .device_loop_body:
        mov     eax,dword[edi+ConfigDisplayDevice_s.nNumDisplayModes]

        ;.check_no_modes:
        ;test    eax,eax
        ;jz      .device_loop_inc

        .mode_loop_init:
        lea     esi,dword[edi+ConfigDisplayDevice_s.tDisplayModeList]
        xor     ebx,ebx
        mov     dword[nDisplayModesCount],eax

        .init_def_mode:
        jmp     .save_def_mode

        .mode_loop_body: ; NOTE: ridiculously big resolutions (eg.: 50'000x50'000) will cause an integer overflow
        mov     eax,dword[esi+ConfigDisplayMode_s.nWidth]
        mov     ecx,dword[esi+ConfigDisplayMode_s.nHeight]
        mov     edx,dword[esi+ConfigDisplayMode_s.nDepth]
        cmp     edx,dword[nDefModeDepth]
        jl      .mode_loop_inc ; skip if color depth is lower
        jg      .save_def_mode_noread
        imul    eax,ecx
        mov     ecx,dword[nDefModeWidth]
        mov     edx,dword[nDefModeHeight]
        imul    ecx,edx
        cmp     eax,ecx
        jge     .mode_loop_inc ; skip if resolution is bigger or equal

        .save_def_mode:
        mov     eax,dword[esi+ConfigDisplayMode_s.nWidth]
        mov     ecx,dword[esi+ConfigDisplayMode_s.nHeight]
        mov     edx,dword[esi+ConfigDisplayMode_s.nDepth]

        .save_def_mode_noread:
        mov     dword[nDefModeID],ebx
        mov     dword[nDefModeWidth],eax
        mov     dword[nDefModeHeight],ecx
        mov     dword[nDefModeDepth],edx

        .mode_loop_inc:
        add     dword[nNumTotalDisplayModes],1
        add     ebx,1
        add     esi,sizeof.ConfigDisplayMode_s
        sub     dword[nDisplayModesCount],1
        jnz     .mode_loop_body

        .set_def_mode:
        mov     ebx,dword[nDefModeID]
        mov     eax,dword[nDefModeWidth]
        mov     ecx,dword[nDefModeHeight]
        mov     edx,dword[nDefModeDepth]
        mov     dword[edi+ConfigDisplayDevice_s.nDefDisplayModeID],ebx
        mov     dword[edi+ConfigDisplayDevice_s.tDefDisplayMode.nWidth],eax
        mov     dword[edi+ConfigDisplayDevice_s.tDefDisplayMode.nHeight],ecx
        mov     dword[edi+ConfigDisplayDevice_s.tDefDisplayMode.nDepth],edx

        .device_loop_inc:
        add     edi,sizeof.ConfigDisplayDevice_s
        sub     dword[nDisplayDevicesCount],1
        jnz     .device_loop_body

        .check_num_modes:
        cmp     dword[nNumTotalDisplayModes],0
        je      .error

        .end:
        pop     edi esi ebx
        ret

        .error:
        ccall   LDebug_AbortWithError,Config_zNoDisplayModesError
endp

loc_403642: ; Config_Open

        .remove_empty_devices:

        .update_devices_defmode:
        stdcall Config_UpdateDevicesDefMode

        .back:
        call    near PATCHER_CALL_TRAP ;RenderMode_PopRenderMode:0x004B0F90
        .fixup1 = $-4
        jmp     near PATCHER_JUMP_TRAP ;loc_403647
        .fixup2 = $-4

proc Config_FillRenderDeviceListBox_NEW c ptResult,pxUnUsed,ptArgList

        locals
                tResult rb 24 ;Result_s
                zString rb 256 ; enough for sizeof.DisplayDevice_t.zDesc (128) + formatting headroom
        endl

        push    ebx esi edi

        .get_pointers:
        mov     ebx,dword[Config_nNumDisplayDevices]

        ;.check_no_devices:
        ;test    ebx,ebx
        ;jz      .copy_result

        .loop_init:
        mov     edi,Config_atDisplayDevice.tDisplayDevice.zDesc
        xor     esi,esi

        .loop_body:
        jmp     .do_format ; sadly listboxes are limited to around 26 characters only
        cmp     byte[edi],0
        je      .do_format_ex2

        .do_format_ex1:
        lea     eax,[zString]
        mov     ecx,Config_zDisplayDeviceFormatEx1
        lea     edx,[esi+1]
        push    edi
        push    edx
        push    ecx
        push    eax
        call    near PATCHER_CALL_TRAP ;_sprintf:0x004A53B3
        .fixup1 = $-4
        add     esp,4*4
        mov     byte[zString+40-1],0 ;sizeof.ListBoxItem_t.zItem
        jmp     .add_entry

        .do_format_ex2:
        lea     eax,[zString]
        mov     ecx,Config_zDisplayDeviceFormatEx2
        lea     edx,[esi+1]
        push    edx
        push    ecx
        push    eax
        call    near PATCHER_CALL_TRAP ;_sprintf:0x004A53B3
        .fixup2 = $-4
        add     esp,3*4
        mov     byte[zString+40-1],0 ;sizeof.ListBoxItem_t.zItem
        jmp     .add_entry

        .do_format:
        lea     eax,[zString]
        mov     ecx,Config_zDisplayDeviceFormat
        push    edi
        push    ecx
        push    eax
        call    near PATCHER_CALL_TRAP ;_sprintf:0x004A53B3
        .fixup3 = $-4
        add     esp,3*4
        mov     byte[zString+40-1],0 ;sizeof.ListBoxItem_t.zItem

        .add_entry:
        lea     eax,[zString]
        push    esi
        push    eax
        call    near PATCHER_CALL_TRAP ;ListBox_AddItem:0x0041F2D0
        .fixup4 = $-4
        add     esp,2*4

        .loop_inc:
        add     esi,1
        add     edi,sizeof.ConfigDisplayDevice_s
        cmp     esi,ebx
        jl      .loop_body

        .copy_result:
        xor     eax,eax
        mov     dword[tResult],eax ;tResult.nResult
        mov     dword[tResult+8],eax ;*(int*)&tResult.vResult
        mov     dword[tResult+8+4],eax ;*(int*)&tResult.vResult+4
        mov     dword[tResult+10h],PATCHER_ADDR_TRAP ;tResult.zResult ;sdefault:0x005382E8
        .fixup5 = $-4
        mov     eax,dword[ptResult]
        lea     esi,[tResult]
        mov     edi,eax
        mov     ecx,6
        rep     movsd

        .end:
        pop     edi esi ebx
        ret
endp

proc Config_GraphicOptionsGetDevice_NEW c ptResult,pxUnUsed,ptArgList

        locals
                tResult rb 24 ;Result_s
                nNumDisplayDevices dd ?
        endl

        push    ebx esi edi

        .get_pointers:
        call    near PATCHER_CALL_TRAP ;Config_GetActiveGraphicOptions:0x00404590
        .fixup1 = $-4
        lea     esi,[eax+13h] ;Config_GetActiveGraphicOptions()->zDeviceIdentifier
        mov     edi,Config_atDisplayDevice.tDisplayDevice.zIdentifier

        .loop_init:
        mov     eax,dword[Config_nNumDisplayDevices]
        xor     ebx,ebx
        mov     dword[nNumDisplayDevices],eax

        .loop_body:
        ccall   strncmp,esi,edi,sizeof.DisplayDevice_t.zIdentifier-1
        test    eax,eax
        jz      .copy_result

        .loop_inc:
        add     ebx,1
        add     edi,sizeof.ConfigDisplayDevice_s
        cmp     ebx,dword[nNumDisplayDevices]
        jl      .loop_body

        .invalid_device:
        xor     ebx,ebx

        .copy_result:
        mov     dword[tResult],ebx ;tResult.nResult
        fild    dword[tResult]
        fstp    qword[tResult+8] ;tResult.vResult
        mov     dword[tResult+10h],PATCHER_ADDR_TRAP ;tResult.zResult ;sdefault:0x005382E8
        .fixup2 = $-4
        mov     eax,dword[ptResult]
        lea     esi,[tResult]
        mov     edi,eax
        mov     ecx,6
        rep     movsd

        .end:
        pop     edi esi ebx
        ret
endp

proc Config_GraphicOptionsSetDevice_NEW c ptResult,pxUnUsed,ptArgList

        locals
                tResult rb 24 ;Result_s
        endl

        push    esi edi

        .eval_args:
        mov     eax,dword[ptArgList]
        push    0
        push    eax
        call    near PATCHER_CALL_TRAP ;Script_EvalArgInt:0x004B8A20
        .fixup1 = $-4
        add     esp,2*4

        .get_pointers:
        imul    esi,eax,sizeof.ConfigDisplayDevice_s
        add     esi,Config_atDisplayDevice
        call    near PATCHER_CALL_TRAP ;Config_GetActiveGraphicOptions:0x00404590
        .fixup2 = $-4
        mov     edi,eax

        .set_device:
        lea     eax,[edi+13h] ;Config_GetActiveGraphicOptions()->zDeviceIdentifier
        lea     ecx,[esi+ConfigDisplayDevice_s.tDisplayDevice.zIdentifier]
        ccall   strncpy,eax,ecx,sizeof.DisplayDevice_t.zIdentifier-1
        mov     byte[eax+sizeof.DisplayDevice_t.zIdentifier-1],0
        lea     eax,[edi+113h] ;Config_GetActiveGraphicOptions()->zDevice
        lea     ecx,[esi+ConfigDisplayDevice_s.tDisplayDevice.zDesc]
        ccall   strncpy,eax,ecx,sizeof.DisplayDevice_t.zDesc-1
        mov     byte[eax+sizeof.DisplayDevice_t.zDesc-1],0

        .copy_result:
        xor     eax,eax
        mov     dword[tResult],eax ;tResult.nResult
        mov     dword[tResult+8],eax ;*(int*)&tResult.vResult
        mov     dword[tResult+8+4],eax ;*(int*)&tResult.vResult+4
        mov     dword[tResult+10h],PATCHER_ADDR_TRAP ;tResult.zResult ;sdefault:0x005382E8
        .fixup3 = $-4
        mov     eax,dword[ptResult]
        lea     esi,[tResult]
        mov     edi,eax
        mov     ecx,6
        rep     movsd

        .end:
        pop     edi esi
        ret
endp

proc Config_FillScreenResolutionListBox_NEW c ptResult,pxUnUsed,ptArgList

        locals
                tResult rb 24 ;Result_s
                iDeviceShifted dd ?
                zString rb 256 ; enough for sizeof.DisplayDevice_t.zDesc (128) + formatting headroom
        endl

        push    ebx esi edi

        .eval_args:
        mov     eax,dword[ptArgList]
        push    0
        push    eax
        call    near PATCHER_CALL_TRAP ;Script_EvalArgInt:0x004B8A20
        .fixup1 = $-4
        add     esp,2*4

        .shift_device:
        mov     ecx,eax
        shl     ecx,16
        mov     dword[iDeviceShifted],ecx

        .get_pointers:
        imul    eax,eax,sizeof.ConfigDisplayDevice_s
        add     eax,Config_atDisplayDevice
        mov     esi,dword[eax+ConfigDisplayDevice_s.nNumDisplayModes]
        lea     edi,[eax+ConfigDisplayDevice_s.tDisplayModeList]

        ;.check_no_modes:
        ;test    esi,esi
        ;jz      .copy_result

        .loop_init:
        xor     ebx,ebx

        .loop_body:
        lea     eax,[zString]
        mov     ecx,Config_zDisplayModeFormat
        push    dword[edi+ConfigDisplayMode_s.nDepth]
        push    dword[edi+ConfigDisplayMode_s.nHeight]
        push    dword[edi+ConfigDisplayMode_s.nWidth]
        push    ecx
        push    eax
        call    near PATCHER_CALL_TRAP ;_sprintf:0x004A53B3
        .fixup2 = $-4
        add     esp,5*4

        .add_entry:
        lea     eax,[zString]
        mov     ecx,ebx
        and     ecx,0xFFFF
        or      ecx,dword[iDeviceShifted]
        push    ecx
        push    eax
        call    near PATCHER_CALL_TRAP ;ListBox_AddItem:0x0041F2D0
        .fixup3 = $-4
        add     esp,2*4

        .loop_inc:
        add     ebx,1
        add     edi,sizeof.ConfigDisplayMode_s
        cmp     ebx,esi
        jl      .loop_body

        .copy_result:
        xor     eax,eax
        mov     dword[tResult],eax ;tResult.nResult
        mov     dword[tResult+8],eax ;*(int*)&tResult.vResult
        mov     dword[tResult+8+4],eax ;*(int*)&tResult.vResult+4
        mov     dword[tResult+10h],PATCHER_ADDR_TRAP ;tResult.zResult ;sdefault:0x005382E8
        .fixup4 = $-4
        mov     eax,dword[ptResult]
        lea     esi,[tResult]
        mov     edi,eax
        mov     ecx,6
        rep     movsd

        .end:
        pop     edi esi ebx
        ret
endp

proc Config_GraphicOptionsSetResolution_NEW c ptResult,pxUnUsed,ptArgList

        locals
                tResult rb 24 ;Result_s
                iModeUnshifted dd ?
        endl

        push    ebx esi edi

        .eval_args:
        mov     eax,dword[ptArgList]
        push    0
        push    eax
        call    near PATCHER_CALL_TRAP ;Script_EvalArgInt:0x004B8A20
        .fixup1 = $-4
        add     esp,2*4

        .unshift_mode:
        mov     ecx,eax
        shr     eax,16
        and     ecx,0xFFFF
        mov     dword[iModeUnshifted],ecx

        .get_pointers:
        imul    ebx,eax,sizeof.ConfigDisplayDevice_s
        add     ebx,Config_atDisplayDevice
        call    near PATCHER_CALL_TRAP ;Config_GetActiveGraphicOptions:0x00404590
        .fixup2 = $-4
        mov     edi,eax
        mov     eax,dword[iModeUnshifted]
        imul    esi,eax,sizeof.ConfigDisplayMode_s
        lea     esi,[ebx+ConfigDisplayDevice_s.tDisplayModeList+esi]
        mov     ecx,dword[ebx+ConfigDisplayDevice_s.nNumDisplayModes]

        .check_valid_mode:
        cmp     eax,ecx
        jb      .get_values

        .get_defvalues:
        mov     eax,dword[ebx+ConfigDisplayDevice_s.tDefDisplayMode.nWidth]
        mov     ecx,dword[ebx+ConfigDisplayDevice_s.tDefDisplayMode.nHeight]
        mov     edx,dword[ebx+ConfigDisplayDevice_s.tDefDisplayMode.nDepth]
        jmp     .set_mode

        .get_values:
        mov     eax,dword[esi+ConfigDisplayMode_s.nWidth]
        mov     ecx,dword[esi+ConfigDisplayMode_s.nHeight]
        mov     edx,dword[esi+ConfigDisplayMode_s.nDepth]

        .set_mode:
        mov     dword[edi],eax ;ptGraphicOptions.nDisplayWidth
        mov     dword[edi+4],ecx ;ptGraphicOptions.nDisplayHeight
        mov     dword[edi+8],edx ;ptGraphicOptions.nDisplayDepth

        .copy_result:
        xor     eax,eax
        mov     dword[tResult],eax ;tResult.nResult
        mov     dword[tResult+8],eax ;*(int*)&tResult.vResult
        mov     dword[tResult+8+4],eax ;*(int*)&tResult.vResult+4
        mov     dword[tResult+10h],PATCHER_ADDR_TRAP ;tResult.zResult ;sdefault:0x005382E8
        .fixup3 = $-4
        mov     eax,dword[ptResult]
        lea     esi,[tResult]
        mov     edi,eax
        mov     ecx,6
        rep     movsd

        .end:
        pop     edi esi ebx
        ret
endp

proc Config_GraphicOptionsGetResolution_NEW c ptResult,pxUnUsed,ptArgList

        locals
                tResult rb 24 ;Result_s
                iDeviceShifted dd ?
                nDefDisplayModeID dd ?
                nNumDisplayModes dd ?
        endl

        push    ebx esi edi

        .eval_args:
        mov     eax,dword[ptArgList]
        push    0
        push    eax
        call    near PATCHER_CALL_TRAP ;Script_EvalArgInt:0x004B8A20
        .fixup1 = $-4
        add     esp,2*4

        .shift_device:
        mov     ecx,eax
        shl     ecx,16
        mov     dword[iDeviceShifted],ecx

        .get_pointers:
        imul    esi,eax,sizeof.ConfigDisplayDevice_s
        add     esi,Config_atDisplayDevice
        call    near PATCHER_CALL_TRAP ;Config_GetActiveGraphicOptions:0x00404590
        .fixup2 = $-4
        mov     edi,eax
        mov     ecx,dword[esi+ConfigDisplayDevice_s.nNumDisplayModes]
        mov     edx,dword[esi+ConfigDisplayDevice_s.nDefDisplayModeID]
        mov     dword[nDefDisplayModeID],edx

        ;.check_no_modes:
        ;test    ecx,ecx
        ;jz      .invalid_mode

        .loop_init:
        add     esi,ConfigDisplayDevice_s.tDisplayModeList
        xor     ebx,ebx
        mov     dword[nNumDisplayModes],ecx

        .loop_body:
        mov     eax,dword[esi+ConfigDisplayMode_s.nWidth]
        mov     ecx,dword[esi+ConfigDisplayMode_s.nHeight]
        mov     edx,dword[esi+ConfigDisplayMode_s.nDepth]
        xor     eax,dword[edi] ;ptGraphicOptions.nDisplayWidth
        xor     ecx,dword[edi+4] ;ptGraphicOptions.nDisplayHeight
        xor     edx,dword[edi+8] ;ptGraphicOptions.nDisplayDepth
        or      eax,ecx
        or      eax,edx
        jz      .append_device

        .loop_inc:
        add     ebx,1
        add     esi,sizeof.ConfigDisplayMode_s
        cmp     ebx,dword[nNumDisplayModes]
        jl      .loop_body

        .invalid_mode:
        mov     ebx,dword[nDefDisplayModeID]

        .append_device:
        and     ebx,0xFFFF
        or      ebx,dword[iDeviceShifted]

        .copy_result:
        mov     dword[tResult],ebx ;tResult.nResult
        fild    dword[tResult]
        fstp    qword[tResult+8] ;tResult.vResult
        mov     dword[tResult+10h],PATCHER_ADDR_TRAP ;tResult.zResult ;sdefault:0x005382E8
        .fixup3 = $-4
        mov     eax,dword[ptResult]
        lea     esi,[tResult]
        mov     edi,eax
        mov     ecx,6
        rep     movsd

        .end:
        pop     edi esi ebx
        ret
endp

proc Config_VerifyGraphicConfig_NEW

        locals
                nPlayerProfilesCount dd ?
                ptDisplayDeviceList dd ?
                nNumDisplayDevices dd ?
                ;ptDisplayModeList dd ?
                nNumDisplayModes dd ?
        endl

        push    ebx esi edi

        .get_pointers:
        mov     edi,PATCHER_ADDR_TRAP ;Config_tConfig:0x00BC2380
        .fixup1 = $-4
        mov     eax,dword[edi] ;Config_tConfig.nPlayerProfiles

        .check_no_profiles:
        test    eax,eax
        jz      .end

        .profile_loop_init:
        add     edi,8 ;&Config_tConfig.atPlayerProfile[0]
        mov     ecx,dword[Config_nNumDisplayDevices]
        mov     dword[nPlayerProfilesCount],eax
        mov     dword[nNumDisplayDevices],ecx

        ;.check_no_devices:
        ;test    ecx,ecx
        ;jz      .end

        .profile_loop_body:
        mov     esi,Config_atDisplayDevice
        mov     dword[ptDisplayDeviceList],esi

        .device_loop_init:
        xor     ebx,ebx

        .device_loop_body:
        lea     eax,[edi+0Ch+13h] ;ptPlayerProfile->tGraphicOptions.zDeviceIdentifier
        lea     ecx,[esi+ConfigDisplayDevice_s.tDisplayDevice.zIdentifier]
        ccall   strncmp,eax,ecx,sizeof.DisplayDevice_t.zIdentifier-1
        test    eax,eax
        jz      .valid_device

        .device_loop_inc:
        add     ebx,1
        add     esi,sizeof.ConfigDisplayDevice_s
        cmp     ebx,dword[nNumDisplayDevices]
        jl      .device_loop_body

        .invalid_device:
        mov     esi,dword[ptDisplayDeviceList]
        lea     eax,[edi+0Ch+13h] ;ptPlayerProfile->tGraphicOptions.zDeviceIdentifier
        lea     ecx,[esi+ConfigDisplayDevice_s.tDisplayDevice.zIdentifier]
        ccall   strncpy,eax,ecx,sizeof.DisplayDevice_t.zIdentifier-1
        mov     byte[eax+sizeof.DisplayDevice_t.zIdentifier-1],0
        lea     eax,[edi+0Ch+113h] ;ptPlayerProfile->tGraphicOptions.zDevice
        lea     ecx,[esi+ConfigDisplayDevice_s.tDisplayDevice.zDesc]
        ccall   strncpy,eax,ecx,sizeof.DisplayDevice_t.zDesc-1
        mov     byte[eax+sizeof.DisplayDevice_t.zDesc-1],0

        .valid_device:
        mov     dword[ptDisplayDeviceList],esi
        mov     eax,dword[esi+ConfigDisplayDevice_s.nNumDisplayModes]
        mov     dword[nNumDisplayModes],eax

        ;.check_no_modes:
        ;test    eax,eax
        ;jz      .end

        .mode_loop_init:
        add     esi,ConfigDisplayDevice_s.tDisplayModeList
        ;mov     dword[ptDisplayModeList],esi
        xor     ebx,ebx

        .mode_loop_body:
        mov     eax,dword[esi+ConfigDisplayMode_s.nWidth]
        mov     ecx,dword[esi+ConfigDisplayMode_s.nHeight]
        mov     edx,dword[esi+ConfigDisplayMode_s.nDepth]
        xor     eax,dword[edi+0Ch] ;ptPlayerProfile->tGraphicOptions.nDisplayWidth
        xor     ecx,dword[edi+0Ch+4] ;ptPlayerProfile->tGraphicOptions.nDisplayHeight
        xor     edx,dword[edi+0Ch+8] ;ptPlayerProfile->tGraphicOptions.nDisplayDepth
        or      eax,ecx
        or      eax,edx
        jz      .valid_mode

        .mode_loop_inc:
        add     ebx,1
        add     esi,sizeof.ConfigDisplayMode_s
        cmp     ebx,dword[nNumDisplayModes]
        jl      .mode_loop_body

        .invalid_mode:
        mov     esi,dword[ptDisplayDeviceList]
        mov     eax,dword[esi+ConfigDisplayDevice_s.tDefDisplayMode.nWidth]
        mov     ecx,dword[esi+ConfigDisplayDevice_s.tDefDisplayMode.nHeight]
        mov     edx,dword[esi+ConfigDisplayDevice_s.tDefDisplayMode.nDepth]
        mov     dword[edi+0Ch],eax ;ptPlayerProfile->tGraphicOptions.nDisplayWidth
        mov     dword[edi+0Ch+4],ecx ;ptPlayerProfile->tGraphicOptions.nDisplayHeight
        mov     dword[edi+0Ch+8],edx ;ptPlayerProfile->tGraphicOptions.nDisplayDepth

        .valid_mode:
        ; do nothing

        .profile_loop_inc:
        add     edi,564h ;sizeof.PlayerProfile_s
        sub     dword[nPlayerProfilesCount],1
        jnz     .profile_loop_body

        .end:
        pop     edi esi ebx
        ret
endp

;------------------------------------------------------------
; WidescreenPatch
;------------------------------------------------------------

proc TransContext_UpdateFOVData c ptTransContext,vFOV ; TODO: detect computer map, force 100% fov

        mov     ecx,PATCHER_ADDR_TRAP ;RenderContext_tActiveRenderContext:0x00BCABA0
        .fixup1 = $-4
        mov     edx,dword[ptTransContext]

        .check_scaling_mode:
        cmp     dword[IniFile.WSP.ViewportScalingMode],0
        jne     .mode_1

        .mode_0: ; hor+

        .m0_set_vfovx:
        fld     dword[vFOV]
        fmul    dword[Display_vRelAspectRatio]
        fmul    dword[Viewport_vFOVMul]
        fstp    dword[edx+40h] ; ptTransContext->vFOVX = vFOV * Display_GetRelAspectRatio() * Viewport_vFOVMul;

        .m0_set_vfovy:
        fld     dword[vFOV]
        fmul    dword[Display_vAspectRatio34]
        fmul    dword[Viewport_vFOVMul]
        fstp    dword[edx+44h] ; ptTransContext->vFOVY = vFOV * Display_vAspectRatio34 * Viewport_vFOVMul;

        .m0_set_vscreenfovx:
        fld     dword[ecx+0Ch+0Ch+10h] ;ptActiveRenderContext->tClippingWindow.tClippingRect.vHalfWidth
        fdiv    dword[edx+40h]
        fstp    dword[edx+48h] ; ptTransContext->vScreenFOVX = ptActiveRenderContext->tClippingWindow.tClippingRect.vHalfWidth / ptTransContext->vFOVX;

        .m0_set_vscreenfovy:
        fld     dword[edx+48h]
        fstp    dword[edx+4Ch] ; ptTransContext->vScreenFOVY = ptTransContext->vScreenFOVX;

        .m0_end:
        ret

        .mode_1: ; vert-

        .m1_set_vfovx:
        fld     dword[vFOV]
        fmul    dword[Viewport_vFOVMul]
        fstp    dword[edx+40h] ; ptTransContext->vFOVX = vFOV * Viewport_vFOVMul;

        .m1_set_vfovy:
        fld     dword[vFOV]
        fmul    dword[Display_vAspectRatio34]
        fmul    dword[Display_vRelAspRatioInv]
        fmul    dword[Viewport_vFOVMul]
        fstp    dword[edx+44h] ; ptTransContext->vFOVY = vFOV * Display_vAspectRatio34 * Viewport_vFOVMul;

        .m1_set_vscreenfovx:
        fld     dword[ecx+0Ch+0Ch+10h] ;ptActiveRenderContext->tClippingWindow.tClippingRect.vHalfWidth
        fdiv    dword[edx+40h]
        fstp    dword[edx+48h] ; ptTransContext->vScreenFOVX = ptActiveRenderContext->tClippingWindow.tClippingRect.vHalfWidth / ptTransContext->vFOVX;

        .m1_set_vscreenfovy:
        fld     dword[edx+48h]
        fstp    dword[edx+4Ch] ; ptTransContext->vScreenFOVY = ptTransContext->vScreenFOVX;

        .m1_end:
        ret
endp

loc_497DE7: ; TransContext_Create

        .vFOVX = 10h

        .set_fov_data:
        mov     eax,dword[esp+34h+.vFOVX]
        ccall   TransContext_UpdateFOVData,ebx,eax

        .set_vscreenoriginx:
        fld     dword[PATCHER_ADDR_TRAP] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vX:0x00BCABB8
        .fixup1 = $-4
        fadd    dword[PATCHER_ADDR_TRAP] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth:0x00BCABC8
        .fixup2 = $-4
        fstp    dword[ebx+50h] ; ptTransContext->vScreenOriginX = RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vX + RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth;

        .set_vscreenoriginy:
        fld     dword[PATCHER_ADDR_TRAP] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vY:0x00BCABBC
        .fixup3 = $-4
        fadd    dword[PATCHER_ADDR_TRAP] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfHeight:0x00BCABCC
        .fixup4 = $-4
        fstp    dword[ebx+54h] ; ptTransContext->vScreenOriginY = RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vY + RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfHeight;

        .set_isdraw:
        mov     dword[ebx+58h],1 ; ptTransContext->isDraw = TRUE;

        .set_elayer:
        mov     dword[ebx+60h],1 ; ptTransContext->eLayer = TRANSCONTEXT_LAYER_MIDDLE;

        .end:
        pop     edi
        pop     esi
        pop     ebx
        add     esp,28h
        retn    0

loc_49E006: ; Direct3DRender_DrawRigidMesh

        ;.vFOVX = -224h
        .tNewTransContext = -190h
        .tNewTransContext.vFOVX = -190h+40h
        .tNewTransContext.vFOVY = -190h+44h
        .tNewTransContext.vScreenFOVX = -190h+48h
        .tNewTransContext.vScreenFOVY = -190h+4Ch
        .tNewTransContext.eLayer = -190h+60h
        .tOldTransContext = -0A8h

        .copy_context1:
        mov     ecx,42 ;sizeof(TransContext_s)/4
        mov     esi,PATCHER_ADDR_TRAP ;TransContext_tActiveTransContext:0x00BCAAE0
        .fixup1 = $-4
        lea     edi,[esp+238h+.tOldTransContext]
        rep     movsd

        .copy_context2:
        mov     ecx,42 ;sizeof(TransContext_s)/4
        lea     esi,[esp+238h+.tOldTransContext]
        lea     edi,[esp+238h+.tNewTransContext]
        rep     movsd

        .set_fov_data:
        lea     eax,[esp+238h+.tNewTransContext]
        mov     ecx,dword[ebx+0ECh]
        mov     ecx,dword[PATCHER_ADDR_TRAP+ecx*4] ;Mesh3D_avOverrideFOV:0x00B81700
        .fixup2 = $-4
        ;mov     ecx,dword[PATCHER_ADDR_TRAP] ;Mesh3D_avOverrideFOV:0x00B81700
        ;.fixup2 = $-4
        ccall   TransContext_UpdateFOVData,eax,ecx

        .set_elayer:
        mov     dword[esp+238h+.tNewTransContext.eLayer],0 ; tNewTransContext.eLayer = TRANSCONTEXT_LAYER_FRONT;

        .set_context:
        lea     ecx,[esp+238h+.tNewTransContext]
        push    ecx
        call    near PATCHER_CALL_TRAP ;TransContext_SetActiveTransContext:0x00497E70
        .fixup3 = $-4
        add     esp,4

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_49E0B1
        .fixup4 = $-4

loc_49F00D: ; Direct3DRender_DrawSortedFaceGroup_Rigid

        ;.vFOVX = -244h
        .tNewTransContext = -224h
        .tNewTransContext.vFOVX = -224h+40h
        .tNewTransContext.vFOVY = -224h+44h
        .tNewTransContext.vScreenFOVX = -224h+48h
        .tNewTransContext.vScreenFOVY = -224h+4Ch
        .tNewTransContext.eLayer = -224h+60h
        .tOldTransContext = -13Ch

        .copy_context1:
        mov     ecx,42 ;sizeof(TransContext_s)/4
        mov     esi,PATCHER_ADDR_TRAP ;TransContext_tActiveTransContext:0x00BCAAE0
        .fixup1 = $-4
        lea     edi,[esp+298h+.tOldTransContext]
        rep     movsd

        .copy_context2:
        mov     ecx,42 ;sizeof(TransContext_s)/4
        lea     esi,[esp+298h+.tOldTransContext]
        lea     edi,[esp+298h+.tNewTransContext]
        rep     movsd

        .set_fov_data:
        lea     eax,[esp+298h+.tNewTransContext]
        ;mov     ecx,dword[ebx+5Ch]
        ;mov     ecx,dword[PATCHER_ADDR_TRAP+ecx*4] ;Mesh3D_avOverrideFOV:0x00B81700
        ;.fixup2 = $-4
        mov     ecx,dword[PATCHER_ADDR_TRAP] ;Mesh3D_avOverrideFOV:0x00B81700
        .fixup2 = $-4
        ccall   TransContext_UpdateFOVData,eax,ecx

        .set_elayer:
        mov     dword[esp+298h+.tNewTransContext.eLayer],0 ; tNewTransContext.eLayer = TRANSCONTEXT_LAYER_FRONT;

        .set_context:
        lea     eax,[esp+298h+.tNewTransContext]
        push    eax
        call    near PATCHER_CALL_TRAP ;TransContext_SetActiveTransContext:0x00497E70
        .fixup3 = $-4
        add     esp,4

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_49F0A3
        .fixup4 = $-4

loc_49F5AF: ; Direct3DRender_DrawSortedFaceGroup_Lightmap

        ;.vFOVX = -1ACh
        .tNewTransContext = -190h
        .tNewTransContext.vFOVX = -190h+40h
        .tNewTransContext.vFOVY = -190h+44h
        .tNewTransContext.vScreenFOVX = -190h+48h
        .tNewTransContext.vScreenFOVY = -190h+4Ch
        .tNewTransContext.eLayer = -190h+60h
        .tOldTransContext = -0A8h

        .copy_context1:
        mov     ecx,42 ;sizeof(TransContext_s)/4
        mov     esi,PATCHER_ADDR_TRAP ;TransContext_tActiveTransContext:0x00BCAAE0
        .fixup1 = $-4
        lea     edi,[esp+200h+.tOldTransContext]
        rep     movsd

        .copy_context2:
        mov     ecx,42 ;sizeof(TransContext_s)/4
        lea     esi,[esp+200h+.tOldTransContext]
        lea     edi,[esp+200h+.tNewTransContext]
        rep     movsd

        .set_fov_data:
        lea     eax,[esp+200h+.tNewTransContext]
        ;mov     ecx,dword[ebx+5Ch]
        ;mov     ecx,dword[PATCHER_ADDR_TRAP+ecx*4] ;Mesh3D_avOverrideFOV:0x00B81700
        ;.fixup2 = $-4
        mov     ecx,dword[PATCHER_ADDR_TRAP] ;Mesh3D_avOverrideFOV:0x00B81700
        .fixup2 = $-4
        ccall   TransContext_UpdateFOVData,eax,ecx

        .set_elayer:
        mov     dword[esp+200h+.tNewTransContext.eLayer],0 ; tNewTransContext.eLayer = TRANSCONTEXT_LAYER_FRONT;

        .set_context:
        lea     eax,[esp+200h+.tNewTransContext]
        push    eax
        call    near PATCHER_CALL_TRAP ;TransContext_SetActiveTransContext:0x00497E70
        .fixup3 = $-4
        add     esp,4

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_49F645
        .fixup4 = $-4

loc_49F766: ; Direct3DRender_DrawBoneMesh

        ;.vFOVX = -1D4h
        .var_1CC = -1CCh
        .tNewTransContext = -190h
        .tNewTransContext.vFOVX = -190h+40h
        .tNewTransContext.vFOVY = -190h+44h
        .tNewTransContext.vScreenFOVX = -190h+48h
        .tNewTransContext.vScreenFOVY = -190h+4Ch
        .tNewTransContext.eLayer = -190h+60h
        .tOldTransContext = -0A8h

        .copy_context1:
        mov     ecx,42 ;sizeof(TransContext_s)/4
        mov     esi,PATCHER_ADDR_TRAP ;TransContext_tActiveTransContext:0x00BCAAE0
        .fixup1 = $-4
        lea     edi,[esp+1E4h+.tOldTransContext]
        rep     movsd

        .copy_context2:
        mov     ecx,42 ;sizeof(TransContext_s)/4
        lea     esi,[esp+1E4h+.tOldTransContext]
        lea     edi,[esp+1E4h+.tNewTransContext]
        rep     movsd

        .set_fov_data:
        lea     eax,[esp+1E4h+.tNewTransContext]
        mov     ecx,dword[ebp+0D4h]
        mov     ecx,dword[PATCHER_ADDR_TRAP+ecx*4] ;Mesh3D_avOverrideFOV:0x00B81700
        .fixup2 = $-4
        ;mov     ecx,dword[PATCHER_ADDR_TRAP] ;Mesh3D_avOverrideFOV:0x00B81700
        ;.fixup2 = $-4
        ccall   TransContext_UpdateFOVData,eax,ecx

        .set_elayer:
        mov     dword[esp+1E4h+.tNewTransContext.eLayer],0 ; tNewTransContext.eLayer = TRANSCONTEXT_LAYER_FRONT;

        .set_context:
        lea     ecx,[esp+1E4h+.tNewTransContext]
        push    ecx
        call    near PATCHER_CALL_TRAP ;TransContext_SetActiveTransContext:0x00497E70
        .fixup3 = $-4
        add     esp,4

        .back:
        mov     esi,dword[esp+1E4h+.var_1CC]
        jmp     near PATCHER_JUMP_TRAP ;loc_49F80F
        .fixup4 = $-4

proc ComputerObject_ProjectRotatedPos_NEW c ptDest,vOOZ,ptContext

        .init_regs:
        mov     eax,dword[ptContext]
        mov     ecx,dword[vOOZ]
        mov     edx,dword[ptDest]

        .check_scaling_mode:
        cmp     dword[IniFile.WSP.ViewportScalingMode],0
        jne     .mode_1

        .mode_0: ; hor+
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup1 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        fmul    dword[Display_vAspectRatio43]
        fld     dword[ecx+8] ;vOOZ->vZ
        fmul    dword[eax+8] ;ptContext->vCameraFOV
        fmul    dword[Viewport_vFOVMul]
        fdivp   st1,st0 ; vOOZa = (Display_tActiveMode.nHeight * 0.5f * Display_vAspectRatio43) / (vOOZ->vZ * ptContext->vCameraFOV * Viewport_vFOVMul);
        jmp     .project

        .mode_1: ; vert-
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup2 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        fld     dword[ecx+8] ;vOOZ->vZ
        fmul    dword[eax+8] ;ptContext->vCameraFOV
        fmul    dword[Viewport_vFOVMul]
        fdivp   st1,st0 ; vOOZa = (Display_tActiveMode.nWidth * 0.5f) / (vOOZ->vZ * ptContext->vCameraFOV * Viewport_vFOVMul);

        .project:
        fld     st0 ; st0 = vOOZa, st1 = vOOZa

        .project_x:
        fmul    dword[ecx]
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup3 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        faddp   st1,st0
        fstp    dword[edx] ; ptDest->vX = (vOOZ->vX * vOOZa) + Display_tActiveMode.nWidth * 0.5f;

        .project_y:
        fmul    dword[ecx+4]
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup4 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        faddp   st1,st0
        fstp    dword[edx+4] ; ptDest->vY = (vOOZ->vY * vOOZa) + Display_tActiveMode.nHeight * 0.5f;

        .end:
        ret
endp

proc ComputerObject_ProjectWorldPos_NEW c ptDest,pvZ,ptSource,ptContext

        locals
                tTemp_vX dd ?
                tTemp_vY dd ?
                ;tTemp_vZ dd ?
        endl

        .init_regs:
        mov     eax,dword[ptContext]
        mov     ecx,dword[ptSource]
        mov     edx,dword[eax] ;ptContext->ptCameraPos

        .calc_deltas:
        fld     qword[ecx] ;ptSource->vX
        fsub    qword[edx]
        fld     qword[ecx+8] ;ptSource->vY
        fsub    qword[edx+8]
        fld     qword[ecx+16] ;ptSource->vZ
        fsub    qword[edx+16] ; st0 = dZ, st1 = dY, st2 = dX

        .transform:
        mov     edx,dword[eax+4] ;ptContext->ptCameraOrientation

        .temp_x:
        fld     st0
        fmul    dword[edx+8]
        fld     st2
        fmul    dword[edx+4]
        faddp   st1,st0
        fld     st3
        fmul    dword[edx]
        faddp   st1,st0
        fstp    dword[tTemp_vX] ; tTemp.vX = (dX * tX.vX) + (dY * tX.vY) + (dZ * tX.vZ);

        .temp_y:
        fld     st0
        fmul    dword[edx+0Ch+8]
        fld     st2
        fmul    dword[edx+0Ch+4]
        faddp   st1,st0
        fld     st3
        fmul    dword[edx+0Ch]
        faddp   st1,st0
        fstp    dword[tTemp_vY] ; tTemp.vY = (dX * tY.vX) + (dY * tY.vY) + (dZ * tY.vZ);

        .temp_z:
        fmul    dword[edx+18h+8]
        fxch    st1
        fmul    dword[edx+18h+4]
        faddp   st1,st0
        fxch    st1
        fmul    dword[edx+18h]
        faddp   st1,st0 ; tTemp.vZ = (dX * tZ.vX) + (dY * tZ.vY) + (dZ * tZ.vZ);

        .set_pvz:
        mov     edx,dword[pvZ]
        test    edx,edx
        jz      .calc_fov
        fst     dword[edx] ; *pvZ = depth;

        .calc_fov:
        fmul    dword[eax+8]
        fmul    dword[Viewport_vFOVMul] ; depth *= ptContext->vCameraFOV * Viewport_vFOVMul;

        .check_scaling_mode:
        cmp     dword[IniFile.WSP.ViewportScalingMode],0
        jne     .mode_1

        .mode_0: ; hor+
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup1 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        fmul    dword[Display_vAspectRatio43]
        fxch    st1
        fdivp   st1,st0 ; vOOZa = (Display_tActiveMode.nHeight * 0.5f * Display_vAspectRatio43) / depth;
        jmp     .project

        .mode_1: ; vert-
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup2 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        fxch    st1
        fdivp   st1,st0 ; vOOZa = (Display_tActiveMode.nWidth * 0.5f) / depth;

        .project:
        mov     edx,dword[ptDest]
        fld     st0 ; st0 = vOOZa, st1 = vOOZa

        .project_x:
        fmul    dword[tTemp_vX]
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup3 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        faddp   st1,st0
        fstp    dword[edx] ; ptDest->vX = (tTemp_vX * vOOZa * (Display_tActiveMode.nWidth / 2.0f)) + (Display_tActiveMode.nWidth / 2.0f);

        .project_y:
        fmul    dword[tTemp_vY]
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup4 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        faddp   st1,st0
        fstp    dword[edx+4] ; ptDest->vY = (tTemp_vY * vOOZa * (Display_tActiveMode.nHeight / 2.0f)) + (Display_tActiveMode.nHeight / 2.0f);

        .end:
        ret
endp

loc_46A531: ; ComputerMap_Trace

        .vTracePosY = -114h
        .vTracePosX = -110h
        ;.nRelAspectRatio = -100h
        ;.nTempValue = -0FCh
        .var_B8 = -0B8h
        .var_B0 = -0B0h

        .check_scaling_mode:
        cmp     dword[IniFile.WSP.ViewportScalingMode],0
        jne     .mode_1

        .mode_0: ; hor+
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup1 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        fmul    dword[Display_vAspectRatio43] ; vDenominator = (Display_tActiveMode.nHeight * 0.5f) * Display_vAspectRatio43;
        jmp     .calc_inv_focal

        .mode_1: ; vert-
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup2 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5] ; vDenominator = Display_tActiveMode.nWidth * 0.5f;

        .calc_inv_focal:
        fld     dword[ebp+40h] ;ptQCamera->vFOVX
        fmul    dword[Viewport_vFOVMul]
        fdivrp  st1,st0 ; vInvFocal = (ptQCamera->vFOVX * Viewport_vFOVMul) / vDenominator;

        .calc_dx:
        fld     dword[esp+128h+.vTracePosX]
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup3 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        fsubp   st1,st0
        fmul    st0,st1
        fstp    qword[esp+128h+.var_B8] ; dX = (vTracePosX - (Display_tActiveMode.nWidth * 0.5f)) * vInvFocal;

        .calc_dy:
        fld     dword[esp+128h+.vTracePosY]
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup4 = $-4
        fmul    dword[FPU_CONSTS.wsp.flt_0_5]
        fsubp   st1,st0
        fmulp   st1,st0
        fstp    qword[esp+128h+.var_B0] ; dY = (vTracePosY - (Display_tActiveMode.nHeight * 0.5f)) * vInvFocal;

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_46A59A
        .fixup5 = $-4

loc_46BD84: ; Computer_RunHandler

        .check_scaling_mode:
        cmp     dword[IniFile.WSP.ViewportScalingMode],0
        jne     .mode_1

        .mode_0: ; hor+

        .m0_set_scalex:
        fld     dword[Display_vRelAspectRatio]
        fmul    dword[Viewport_vFOVMul]
        fstp    dword[esi+98h] ; tScale.vX = Display_vRelAspectRatio * Viewport_vFOVMul;

        .m0_set_scaley:
        fld     dword[Viewport_vFOVMul]
        fstp    dword[esi+98h+4] ; tScale.vY = 1.0 * Viewport_vFOVMul;
        jmp     .back

        .mode_1: ; vert-

        .m1_set_scalex:
        fld     dword[Viewport_vFOVMul]
        fstp    dword[esi+98h] ; tScale.vX = 1.0 * Viewport_vFOVMul;

        .m1_set_scaley:
        fld     dword[Viewport_vFOVMul]
        fdiv    dword[Display_vRelAspectRatio]
        fstp    dword[esi+98h+4] ; tScale.vY = (1.0 / Display_vRelAspectRatio) * Viewport_vFOVMul;

        .back:
        fld     dword[esi+10Ch]
        jmp     near PATCHER_JUMP_TRAP ;loc_46BD8A
        .fixup1 = $-4

loc_4CFE74: ; ModelObj_GetLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4CFE7A
        .fixup2 = $-4

loc_4CFE95: ; ModelObj_GetLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4CFE9B
        .fixup2 = $-4

loc_4CFEB2: ; ModelObj_GetLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4CFEB8
        .fixup2 = $-4

loc_4CFEF2: ; ModelObj_GetLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4CFEF8
        .fixup2 = $-4

loc_4D0097: ; Mesh3D_GetBoneMeshLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4D009D
        .fixup2 = $-4

loc_4D00B7: ; Mesh3D_GetBoneMeshLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4D00BD
        .fixup2 = $-4

loc_4D00D4: ; Mesh3D_GetBoneMeshLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4D00DA
        .fixup2 = $-4

loc_4D010A: ; Mesh3D_GetBoneMeshLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4D0110
        .fixup2 = $-4

loc_4D02DD: ; Mesh3D_GetSplineMeshLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4D02E3
        .fixup2 = $-4

loc_4D02FD: ; Mesh3D_GetSplineMeshLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4D0303
        .fixup2 = $-4

loc_4D031A: ; Mesh3D_GetSplineMeshLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4D0320
        .fixup2 = $-4

loc_4D0350: ; Mesh3D_GetSplineMeshLOD

        fld     dword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4D0356
        .fixup2 = $-4

;------------------------------------------------------------
; DebugFeaturesPatch
;------------------------------------------------------------

proc Main_InitDebugFeatPatchCmds c

        .init_cmds:
        ccall   AppContext_SetDebugKeysState,FALSE

        .end:
        ret
endp

proc Main_ParseDebugFeatPatchCmds c pfParseProc

        push    ebx
        mov     ebx,dword[pfParseProc]

        .parse_cmds:
        ccall   ebx,cstrNoLightmaps,Main_ParseNoLightmapsCB
        ccall   ebx,cstrNoTerrainLightmap,Main_ParseNoTerrainLightmapCB
        ccall   ebx,cstrDebugText,Main_ParseDebugTextCB
        ccall   ebx,cstrDebug,Main_ParseDebugCB
        ccall   ebx,cstrFixmeSmall,Main_ParseSmallCB
        ccall   ebx,cstrDebugKeys,Main_ParseDebugKeysCB

        .end:
        pop     ebx
        ret
endp

proc AppContext_SetDebugKeysState c isDebugKeys

        xor     eax,eax
        cmp     dword[isDebugKeys],FALSE
        setne   al
        mov     dword[AppContext_isDebugKeys],eax
        ccall   GameFunctions_SetEnableDebugKeys,eax
        ret
endp

proc AppContext_GetDebugKeys c

        mov     eax,dword[AppContext_isDebugKeys]
        ret
endp

proc Main_ParseNoLightmapsCB c

        push    TRUE
        call    near PATCHER_CALL_TRAP ;AppContext_SetLightmapsUsed:0x0048F240
        .fixup1 = $-4
        add     esp,4
        ret
endp

proc Main_ParseNoTerrainLightmapCB c

        push    TRUE
        call    near PATCHER_CALL_TRAP ;AppContext_SetTerrainLightmapsUsed:0x0048F260
        .fixup1 = $-4
        add     esp,4
        ret
endp

proc Main_ParseDebugTextCB c

        push    TRUE
        call    near PATCHER_CALL_TRAP ;AppContext_SetDebugtextState:0x0048F1E0
        .fixup1 = $-4
        add     esp,4
        ret
endp

proc Main_ParseDebugCB c

        push    TRUE
        call    near PATCHER_CALL_TRAP ;AppContext_SetDebugged:0x0048F1A0
        .fixup1 = $-4
        add     esp,4
        ret
endp

proc Main_ParseSmallCB c

        mov     byte[PATCHER_ADDR_TRAP],TRUE ;AppContext_isFixmeSmall:0x005C8E00
        .fixup1 = $-1-4
        ret
endp

proc Main_ParseDebugKeysCB c

        ccall   AppContext_SetDebugKeysState,TRUE
        ret
endp

proc GameFunctions_SetEnableDebugKeys c isEnableDebugKeys

        xor     eax,eax
        cmp     dword[isEnableDebugKeys],FALSE
        setne   al
        mov     dword[PATCHER_ADDR_TRAP],eax ;GameFunctions_isEnableDebugKeys:0x0057B194
        .fixup1 = $-4
        ret
endp

;------------------------------------------------------------
; MainMenuPatch
;------------------------------------------------------------

loc_418B38: ; MenuManager_New

        .tDisplayMode.nWidth = -118h
        .tDisplayMode.nHeight = -114h
        .tDisplayMode.nBitsPerPixel = -10Ch

        .get_ini_width:
        mov     eax,dword[IniFile.MMP.MainMenuScreenWidth]
        mov     ecx,dword[ebx+0Ch] ; in-game setting width
        lea     edx,[eax+1]
        add     edx,-1
        sbb     edx,edx ; eax == -1 ? edx = -1 : edx = 0
        and     eax,edx ; eax &= edx
        not     edx     ; !edx
        and     ecx,edx ; ecx &= edx
        or      eax,ecx ; eax |= ecx

        .set_game_width:
        mov     dword[esp+130h+.tDisplayMode.nWidth],eax

        .get_ini_height:
        mov     eax,dword[IniFile.MMP.MainMenuScreenHeight]
        mov     ecx,dword[ebx+10h] ; in-game setting height
        lea     edx,[eax+1]
        add     edx,-1
        sbb     edx,edx
        and     eax,edx
        not     edx
        and     ecx,edx
        or      eax,ecx

        .set_game_height:
        mov     dword[esp+130h+.tDisplayMode.nHeight],eax

        .get_ini_depth:
        mov     eax,dword[IniFile.MMP.MainMenuScreenBPP]
        mov     ecx,dword[ebx+14h] ; in-game setting bpp
        lea     edx,[eax+1]
        add     edx,-1
        sbb     edx,edx
        and     eax,edx
        not     edx
        and     ecx,edx
        or      eax,ecx

        .set_game_depth:
        mov     dword[esp+130h+.tDisplayMode.nBitsPerPixel],eax

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_418B50
        .fixup1 = $-4

loc_418BDB: ; MenuManager_New

        .tDisplayMode = -11Ch

        add     esp,2*4

        .set_mode:
        lea     edx,[esp+130h+.tDisplayMode]
        push    edx
        call    near PATCHER_CALL_TRAP ;Display_SetMode:0x00491A90
        .fixup1 = $-4
        add     esp,1*4

        .set_bg_color:
        push    dword[IniFile.MMP.MMBackgroundColorB]
        push    dword[IniFile.MMP.MMBackgroundColorG]
        push    dword[IniFile.MMP.MMBackgroundColorR]
        call    near PATCHER_CALL_TRAP ;Display_SetBackgroundColourFn:0x00491E70
        .fixup2 = $-4
        add     esp,3*4

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_418BE8
        .fixup3 = $-4

loc_418CB5: ; MenuManager_New

        .check_bg_fx:
        cmp     dword[IniFile.MMP.MMBackgroundFXEnabled],FALSE
        je      .back

        .backgroundfx_on:
        push    ebp
        call    near PATCHER_CALL_TRAP ;BackgroundFX_New:0x004199D0
        .fixup1 = $-4
        add     esp,1*4
        mov     dword[ebp+27E0h],eax ; ptMenuManager->ptBackgroundFX = BackgroundFX_New()

        .back:
        mov     ecx,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup2 = $-4
        jmp     near PATCHER_JUMP_TRAP ;loc_418CC1
        .fixup3 = $-4

loc_421AB9: ; MenuScreen_UpdateInternalDataHandler

        .set_eulogo_width_offset:
        mov     dword[PATCHER_ADDR_TRAP],18 ;dword_57BC0C:0x0057BC0C
        .fixup1 = $-4-4

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_421AE2
        .fixup2 = $-4

loc_421AEC: ; MenuScreen_UpdateInternalDataHandler

        .nTempValue1 = -8
        .nTempValue2 = 4

        .get_logo_width:
        ;mov     eax,dword[esi+98h] ;ptMenuScreen->ptLogoQPicture
        push    eax
        call    near PATCHER_CALL_TRAP ;Picture_GetWidth:0x004B6E70
        .fixup1 = $-4
        add     esp,1*4
        mov     dword[esp+10h+.nTempValue2],eax
        fild    dword[esp+10h+.nTempValue2]
        fmul    dword[PATCHER_ADDR_TRAP] ;flt_533504:0x00533504 -> 0.5f
        .fixup2 = $-4
        fistp   dword[esp+10h+.nTempValue1] ;nLogoHalfWidth

        .get_logo_posx:
        call    near PATCHER_CALL_TRAP ;Display_GetActiveMode:0x00491CF0
        .fixup3 = $-4
        mov     eax,dword[eax+4] ;Display_tActiveMode.nWidth
        sar     eax,1
        add     eax,dword[PATCHER_ADDR_TRAP] ;dword_57BC0C:0x0057BC0C
        .fixup4 = $-4
        sub     eax,dword[esp+10h+.nTempValue1] ;nLogoHalfWidth
        mov     dword[esp+10h+.nTempValue2],eax
        fild    dword[esp+10h+.nTempValue2]

        .update_logo_posx:
        mov     eax,dword[esi+98h] ;ptMenuScreen->ptLogoQPicture
        fstp    dword[eax+4] ;ptLogoQPicture->vX

        .get_logo_height:
        ;mov     eax,dword[esi+98h] ;ptMenuScreen->ptLogoQPicture
        push    eax
        call    near PATCHER_CALL_TRAP ;Picture_GetHeight:0x004B6E80
        .fixup5 = $-4
        add     esp,1*4
        mov     dword[esp+10h+.nTempValue2],eax
        fild    dword[esp+10h+.nTempValue2]
        fmul    dword[PATCHER_ADDR_TRAP] ;flt_533504:0x00533504
        .fixup6 = $-4
        fistp   dword[esp+10h+.nTempValue1] ;nLogoHalfHeight

        .get_logo_posy:
        call    near PATCHER_CALL_TRAP ;Display_GetActiveMode:0x00491CF0
        .fixup7 = $-4
        mov     eax,dword[eax+8] ;Display_tActiveMode.nHeight
        sar     eax,1
        sub     eax,(480/2)+40 ;nLogoOffsetY
        add     eax,dword[esp+10h+.nTempValue1] ;nLogoHalfHeight
        mov     dword[esp+10h+.nTempValue2],eax
        fild    dword[esp+10h+.nTempValue2]

        .update_logo_posy:
        mov     eax,dword[esi+98h] ;ptMenuScreen->ptLogoQPicture
        fstp    dword[eax+8] ;ptLogoQPicture->vY

        .set_logo_misc:
        mov     dword[eax+20h],edi ;ptLogoQPicture->nPri

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_421B53
        .fixup8 = $-4

loc_421B5D: ; MenuScreen_UpdateInternalDataHandler

        .nTempValue1 = -8

        push    ebx ebp
        mov     edi,eax ; edi = ptMenuScreen->ptQPicture

        .get_pic_size:
        push    edi
        call    near PATCHER_CALL_TRAP ;Picture_GetWidth:0x004B6E70
        .fixup1 = $-4
        add     esp,4
        mov     ebx,eax
        push    edi
        call    near PATCHER_CALL_TRAP ;Picture_GetHeight:0x004B6E80
        .fixup2 = $-4
        add     esp,4
        mov     ebp,eax

        .set_menuwindow_size:
        mov     dword[esi+28h],ebx ;ptMenuScreen->tMenuWindow.nWidth
        mov     dword[esi+2Ch],ebp ;ptMenuScreen->tMenuWindow.nHeight

        .get_scaling_mode:
        mov     eax,dword[IniFile.MMP.MMBackgroundScalingMode]
        ;cmp     eax,0
        ;je      .mode_0
        cmp     eax,1
        je      .mode_1
        cmp     eax,2
        je      .mode_2

        .mode_0:

        .mode_0_set_pic_posx:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup3 = $-4
        mov     ecx,ebx
        sar     eax,1
        sar     ecx,1
        sub     eax,ecx
        mov     dword[esp+18h+.nTempValue1],eax
        fild    dword[esp+18h+.nTempValue1]
        fstp    dword[edi+4] ; ptQPicture->vX

        .mode_0_set_pic_posy:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup4 = $-4
        mov     ecx,ebp
        sar     eax,1
        sar     ecx,1
        sub     eax,ecx
        mov     dword[esp+18h+.nTempValue1],eax
        fild    dword[esp+18h+.nTempValue1]
        fstp    dword[edi+8] ;ptQPicture->vY

        .mode_0_go_back:
        jmp     .set_pic_misc

        .mode_1:

        .mode_1_set_pic_posx:
        mov     dword[edi+4],0 ;ptQPicture->vX

        .mode_1_set_pic_posy:
        mov     dword[edi+8],0 ;ptQPicture->vY

        .mode_1_go_back:
        jmp     .set_pic_misc

        .mode_2:

        .mode_2_set_pic_posx_hor: ; hor+ scaling
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup5 = $-4
        fidiv   dword[esi+2Ch] ;ptMenuScreen->tMenuWindow.nHeight
        fimul   dword[esi+28h] ;ptMenuScreen->tMenuWindow.nWidth
        fistp   dword[esp+18h+.nTempValue1] ; nScaledWidth
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup6 = $-4
        mov     ecx,dword[esp+18h+.nTempValue1] ; nScaledWidth
        sar     eax,1
        sar     ecx,1
        sub     eax,ecx
        mov     dword[esp+18h+.nTempValue1],eax
        fild    dword[esp+18h+.nTempValue1]
        fstp    dword[edi+4] ;ptQPicture->vX

        .mode_2_set_pic_posy:
        mov     dword[edi+8],0 ;ptQPicture->vY

        .mode_2_go_back:
        ;jmp     .set_pic_misc

        .set_pic_misc:
        mov     dword[edi+20h],0 ;ptQPicture->nPri
        ;mov     dword[edi+24h],0 ;ptQPicture->bQGraphicFlags

        .back:
        pop     ebp ebx
        ;xor     edi,edi
        jmp     near PATCHER_JUMP_TRAP ;loc_421BC2
        .fixup7 = $-4

proc Q3DPicture_RegisterSize c ptStaticTilemap,vX,vY,vWidth,vHeight,nDepth ; copied from igi2, optimized by ai

        locals
            ptQSprite   rd 1
            vXStep      rd 1
            vYStep      rd 1
            vY_curr     rd 1
            vY_next     rd 1
            vX_start    rd 1
            vX_next     rd 1
            map_width   rd 1
            map_height  rd 1
            vR          rd 1
            vG          rd 1
            vB          rd 1
            vA          rd 1
            vZ          rd 1
            bFlags      rd 1
        endl

        push    ebx esi edi

        .get_static_tilemap:
        mov     esi,dword[ptStaticTilemap]
        test    esi,esi
        jz      .end

        .get_qtilemap:
        mov     ecx,dword[esi] ;ptStaticTilemap->ptQTilemap
        test    ecx,ecx
        jz      .end

        .get_size:
        movsx   eax,word[ecx+4] ; eax = map_width
        movsx   edx,word[ecx+6] ; edx = map_height
        test    eax,eax
        jle     .end
        test    edx,edx
        jle     .end
        mov     dword[map_width],eax
        mov     dword[map_height],edx

        .cache_attribs:
        mov     eax,dword[ecx+8] ;ptQTilemap->ptQSprite
        mov     dword[ptQSprite],eax
        mov     eax,dword[esi+0Ch] ;ptStaticTilemap.vA
        mov     dword[vA],eax
        mov     eax,dword[esi+10h] ;ptStaticTilemap.vZ
        mov     dword[vZ],eax
        mov     eax,dword[esi+14h] ;ptStaticTilemap.vR
        mov     dword[vR],eax
        mov     eax,dword[esi+18h] ;ptStaticTilemap.vG
        mov     dword[vG],eax
        mov     eax,dword[esi+1Ch] ;ptStaticTilemap.vB
        mov     dword[vB],eax
        mov     eax,dword[esi+24h] ;ptStaticTilemap.bQGraphicFlags
        mov     dword[bFlags],eax

        .calc_xstep:
        fld     dword[vWidth]
        fild    dword[map_width]
        fdivp   st1,st0 ; vXStep = vWidth / map_width
        fstp    dword[vXStep]

        .calc_ystep:
        fld     dword[vHeight]
        fild    dword[map_height]
        fdivp   st1,st0 ; vYStep = vHeight / map_height
        fstp    dword[vYStep]

        .row_loop_init:
        mov     eax,dword[vY]
        mov     dword[vY_curr],eax
        mov     eax,dword[vX]
        mov     dword[vX_start],eax
        lea     edi,[ecx+10h] ; start of tile array
        xor     esi,esi ; row_index = 0

        .row_loop:
        fld     dword[vY_curr]
        fadd    dword[vYStep]
        fstp    dword[vY_next]

        .col_loop_init:
        mov     eax,dword[vX_start]
        mov     dword[vX],eax ; Reset vX to start of row
        xor     ebx,ebx ; col_index = 0

        .col_loop:
        movzx   eax,byte[edi] ; Read 8-bit tile ID
        inc     edi ; Increment tile memory pointer
        test    al,al
        jz      .next_col ; Skip empty tile (0)

        .calc_edge_x:
        fld     dword[vX]
        fadd    dword[vXStep]
        fstp    dword[vX_next]

        .register_sprite:
        dec     eax ; nFrame = tile_id - 1
        mov     edx,dword[vX_next]
        push    dword[nDepth]
        push    dword[bFlags]
        push    eax
        push    dword[vZ]
        push    dword[vA]
        push    dword[vB]
        push    dword[vG]
        push    dword[vR]
        push    dword[vY_next]
        push    edx
        push    dword[vY_next]
        push    dword[vX]
        push    dword[vY_curr]
        push    edx
        push    dword[vY_curr]
        push    dword[vX]
        push    dword[ptQSprite]
        call    near PATCHER_CALL_TRAP ;QSprite_Register4AZ:0x004B53B0
        .fixup1 = $-4
        add     esp,17*4

        .set_vx: ; Advance vX only when a non-zero tile renders (matches original binary)
        mov     eax,dword[vX_next]
        mov     dword[vX],eax

        .next_col:
        inc     ebx ; col_index++
        cmp     ebx,dword[map_width]
        jl      .col_loop

        .set_vy_curr: ; Advance Y coordinate for next row
        mov     eax,dword[vY_next]
        mov     dword[vY_curr],eax

        .next_row:
        inc     esi ; row_index++
        cmp     esi,dword[map_height]
        jl      .row_loop

        .end:
        pop     edi esi ebx
        ret
endp

loc_421CB6: ; MenuScreen_DrawHandler

        .nTempValue1 = 4 ; initially ptMenuScreen

        .get_scaling_mode:
        mov     eax,dword[IniFile.MMP.MMBackgroundScalingMode]
        ;cmp     eax,0
        ;je      .mode_0
        cmp     eax,1
        je      .mode_1
        cmp     eax,2
        je      .mode_2

        .mode_0: ; no scaling
        push    esi
        call    near PATCHER_CALL_TRAP ;Picture_Register:0x004B6E60
        .fixup1 = $-4
        add     esp,1*4
        pop     esi
        retn    0

        .mode_1: ; fill whole client area
        push    ebx
        mov     eax,dword[esi+4] ; ptQPicture->vX
        mov     ebx,dword[esi+8] ; ptQPicture->vY
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup2 = $-4
        fstp    dword[esp+8+.nTempValue1] ; vWidth
        mov     ecx,dword[esp+8+.nTempValue1]
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup3 = $-4
        fstp    dword[esp+8+.nTempValue1] ; vHeight
        mov     edx,dword[esp+8+.nTempValue1]
        ccall   Q3DPicture_RegisterSize,esi,eax,ebx,ecx,edx,-1
        pop     ebx esi
        retn    0

        .mode_2: ; scale preserving aspect ratio
        push    ebx
        mov     ebx,dword[esp+8+.nTempValue1] ; ebx = ptMenuScreen
        ;.mode_2_vert:
        ;fild    dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B44
        ;.fixup4 = $-4
        ;fidiv   dword[ebx+28h] ; st0 = vScaleRatio = Display_tActiveMode.nWidth / ptMenuScreen->tMenuWindow.nWidth
        .mode_2_hor:
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup4 = $-4
        fidiv   dword[ebx+2Ch] ;st0 = Display_tActiveMode.nHeight / ptMenuScreen->tMenuWindow.nHeight
        .mode_2_do_call:
        fild    dword[ebx+28h] ;ptMenuScreen->tMenuWindow.nWidth
        fmul    st0,st1
        fstp    dword[esp+8+.nTempValue1] ; vWidth
        mov     ecx,dword[esp+8+.nTempValue1]
        fild    dword[ebx+2Ch] ;ptMenuScreen->tMenuWindow.nHeight
        fmul    st0,st1
        fstp    dword[esp+8+.nTempValue1] ; vHeight
        mov     edx,dword[esp+8+.nTempValue1]
        fstp    st0
        mov     eax,dword[esi+4] ; ptQPicture->vX
        mov     ebx,dword[esi+8] ; ptQPicture->vY
        ccall   Q3DPicture_RegisterSize,esi,eax,ebx,ecx,edx,-1
        pop     ebx esi
        retn    0

proc BackgroundFX_CreateMatrix_NEW c ptMatrix,vAngle,vScale,vPivotX,vPivotY ; changed to properly scale with resolution, does not stretch/shrink horizontally

        locals
                vFloat05 dd 0.5
                vOldWidth dd 640.0
                vOldHeight dd 480.0
                vCurWidth dd ?
                vCurHeight dd ?
                vScaleXMul dd ?
                vScaleYMul dd ?
        endl

        push    ebx
        mov     ebx,dword[ptMatrix]

        .get_cur_res:
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup1 = $-4
        fstp    dword[vCurWidth]
        fild    dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup2 = $-4
        fstp    dword[vCurHeight]

        .get_scaling_mode:
        mov     eax,dword[IniFile.MMP.MMBackgroundScalingMode]
        ;cmp     eax,0
        ;je      .mode_0
        cmp     eax,1
        je      .mode_1
        cmp     eax,2
        je      .mode_2

        .mode_0: ; no scaling

        .mode_0_apply_alignment:
        fld     dword[vCurWidth]
        fsub    dword[vOldWidth]
        fmul    dword[vFloat05]
        fadd    dword[vPivotX]
        fstp    dword[vPivotX] ; vPivotX += (nCurWidth - vOldWidth) / 2
        fld     dword[vCurHeight]
        fsub    dword[vOldHeight]
        fmul    dword[vFloat05]
        fadd    dword[vPivotY]
        fstp    dword[vPivotY] ; vPivotY += (vCurHeight - vOldHeight) / 2

        .mode_0_go_back:
        jmp     .fill_struct

        .mode_1: ; fill whole client area

        .mode_1_get_scale_mul:
        fld     dword[vCurWidth]
        fdiv    dword[vOldWidth]
        fstp    dword[vScaleXMul] ; vScaleXMul = vCurWidth / vOldWidth
        fld     dword[vCurHeight]
        fdiv    dword[vOldHeight]
        fstp    dword[vScaleYMul] ; vScaleYMul = vCurHeight / vOldHeight

        .mode_1_apply_scaling:
        fld     dword[vPivotX]
        fmul    dword[vScaleXMul]
        fstp    dword[vPivotX] ; vPivotX *= vScaleXMul
        fld     dword[vPivotY]
        fmul    dword[vScaleYMul]
        fstp    dword[vPivotY] ; vPivotY *= vScaleYMul
        fld     dword[vScale]
        ;fmul    dword[vScaleXMul] ; vScaleXMul for vert-
        ;fstp    dword[vScale] ; vScale *= vScaleYMul
        fmul    dword[vScaleYMul] ; vScaleYMul for hor+
        fstp    dword[vScale] ; vScale *= vScaleYMul

        .mode_1_go_back:
        jmp     .fill_struct

        .mode_2: ; scale preserving aspect ratio

        ;.mode_2_get_scale_mul_vert:
        ;fld     dword[vCurWidth]
        ;fdiv    dword[vOldWidth]
        ;fstp    dword[vScaleXMul] ; vScaleXMul = vCurWidth / vOldWidth

        .mode_2_get_scale_mul_hor:
        fld     dword[vCurHeight]
        fdiv    dword[vOldHeight]
        fstp    dword[vScaleYMul] ; vScaleYMul = vCurHeight / vOldHeight

        ;.mode_2_apply_scaling_vert:
        ;fld     dword[vOldHeight]
        ;fmul    dword[vScaleXMul]
        ;fsubr   dword[vCurHeight]
        ;fmul    dword[vFloat05] ; (vCurHeight - vOldHeight * vScaleXMul) / 2
        ;fld     dword[vPivotY]
        ;fmul    dword[vScaleXMul]
        ;faddp   st1,st0
        ;fstp    dword[vPivotY] ; vPivotY = (vCurHeight - vOldHeight * vScaleXMul) / 2 + vPivotY * vScaleXMul
        ;fld     dword[vPivotX]
        ;fmul    dword[vScaleXMul]
        ;fstp    dword[vPivotX] ; vPivotX *= vScaleXMul
        ;fld     dword[vScale]
        ;fmul    dword[vScaleXMul]
        ;fstp    dword[vScale] ; vScale *= vScaleXMul

        .mode_2_apply_scaling_hor: ; IGI2 is pseudo hor+
        fld     dword[vOldWidth]
        fmul    dword[vScaleYMul]
        fsubr   dword[vCurWidth]
        fmul    dword[vFloat05]
        fld     dword[vPivotX]
        fmul    dword[vScaleYMul]
        faddp   st1,st0
        fstp    dword[vPivotX] ; vPivotX = (nCurWidth - vOldWidth * vScaleYMul) / 2 + vPivotX * vScaleYMul
        fld     dword[vPivotY]
        fmul    dword[vScaleYMul]
        fstp    dword[vPivotY] ; vPivotY *= vScaleYMul
        fld     dword[vScale]
        fmul    dword[vScaleYMul] ; IGI2 is pseudo hor+
        fstp    dword[vScale] ; vScale *= vScaleYMul

        .mode_2_go_back:
        ;jmp     .fill_struct

        .fill_struct:
        fld     dword[vAngle]
        fcos
        fmul    dword[vScale]
        fstp    dword[ebx]
        fld     dword[vAngle]
        fsin
        fld     st0
        fmul    dword[vScale]
        fstp    dword[ebx+4]
        fchs
        fmul    dword[vScale]
        fstp    dword[ebx+8]
        push    dword[ebx]
        pop     dword[ebx+12]
        mov     eax,dword[vPivotX]
        mov     ecx,dword[vPivotY]
        mov     edx,dword[vScale]
        mov     dword[ebx+16],eax
        mov     dword[ebx+20],ecx
        mov     dword[ebx+24],edx

        .end:
        pop     ebx
        ret
endp

loc_41A8A4: ; TypeWriterBox_DrawHandler

        mov     dword[esi+1Ch],ecx
        fstp    dword[esi+8]

        .adjust_posx:
        fld     dword[esi+4]
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup1 = $-4
        sar     eax,1
        sub     eax,(640/2) ;nHalfWidth
        mov     dword[esi+4],eax
        fiadd   dword[esi+4]
        fstp    dword[esi+4]

        .adjust_posy:
        fld     dword[esi+8]
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup2 = $-4
        sar     eax,1
        sub     eax,(480/2) ;nHalfHeight
        mov     dword[esi+8],eax
        fiadd   dword[esi+8]
        fstp    dword[esi+8]

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_41A8AA
        .fixup3 = $-4

loc_41D7A3: ; InputBox_DrawHandler

        .var_194 = -194h
        .var_190 = -190h

        .adjust_posx:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup1 = $-4
        sar     eax,1
        sub     eax,(640/2) ;nHalfWidth
        add     eax,dword[esi+20h]
        add     eax,2
        mov     dword[esp+1A4h+.var_190],eax

        .adjust_posy:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup2 = $-4
        sar     eax,1
        sub     eax,(480/2) ;nHalfHeight
        add     eax,dword[esi+24h]
        add     eax,2
        mov     dword[esp+1A4h+.var_194],eax

        .back:
        lea     edi,dword[esi+54h]
        jmp     near PATCHER_JUMP_TRAP ;loc_41D7BA
        .fixup3 = $-4

loc_424C20: ; Cursor_CreateHandler

        .init_posx:
        mov     edx,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup1 = $-4
        sar     edx,1
        mov     dword[eax+24h],edx ;this->nX

        .init_posy:
        mov     edx,dword[PATCHER_ADDR_TRAP] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup2 = $-4
        sar     edx,1
        mov     dword[eax+28h],edx ;this->nY

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_424C2E
        .fixup3 = $-4

;------------------------------------------------------------
; DPIAwarenessPatch
;------------------------------------------------------------

proc SetDPIAwareness

        locals
                dll_wstr du 'User32.dll',0
                proc_cstr db 'SetProcessDPIAware',0
        endl

        push    ebx
        xor     ebx,ebx

        .get_module:
        lea     eax,[dll_wstr]
        invoke  GetModuleHandle,eax
        test    eax,eax
        jnz     .get_proc

        .get_lib:
        lea     eax,[dll_wstr]
        invoke  LoadLibrary,eax
        test    eax,eax
        jz      .end
        mov     ebx,eax

        .get_proc:
        lea     ecx,[proc_cstr]
        invoke  GetProcAddress,eax,ecx
        test    eax,eax
        jz      .end

        .call_proc:
        call    eax

        .free_lib:
        test    ebx,ebx
        jz      .end
        invoke  FreeLibrary,ebx  ; this line should never be reached

        .end:
        pop     ebx
        ret
endp

;------------------------------------------------------------
; NewFPSLimiterPatch
;------------------------------------------------------------

proc Main_InitNewFPSLimPatchCmds c

        .init_cmds:
        ccall   AppContext_SetFPSLock,FALSE

        .end:
        ret
endp

proc Main_ParseNewFPSLimPatchCmds c pfParseProc

        push    ebx
        mov     ebx,dword[pfParseProc]

        .parse_cmds:
        ccall   ebx,cstrFPSLock,Main_ParseFPSLockCB

        .end:
        pop     ebx
        ret
endp

proc AppContext_SetFPSLock c isFPSLock

        xor     eax,eax
        cmp     dword[isFPSLock],FALSE
        setne   al
        mov     dword[AppContext_isFPSLock],eax
        ret
endp

proc AppContext_GetFPSLock c

        mov     eax,dword[AppContext_isFPSLock]
        ret
endp

proc Main_ParseFPSLockCB c

        ccall   AppContext_SetFPSLock,TRUE
        ret
endp

proc AccTimer_Open c

        .init_apies:
        ccall   AccTimer_InitAPIs
        test    eax,eax
        jz      .error

        .get_counter:
        ccall   dword[AccTimer_pfnGetCounter]
        mov     dword[AccTimer_nStartTime],eax
        mov     dword[AccTimer_nStartTime+4],edx

        .end:
        ret

        .error:
        ccall   LDebug_AbortWithError,cstrInitAccTimerError
endp

align 16
AccTimer_Read:

        .read_counter:
        ccall   dword[AccTimer_pfnGetCounter]
        sub     eax,dword[AccTimer_nStartTime]
        sbb     edx,dword[AccTimer_nStartTime+4]

        .end:
        ret

proc AccTimer_Close c

        .check_api:
        test    dword[AccTimer_bAvailableAPI],1
        jz      .uninit_apis

        .restore_res:
        invoke  timeEndPeriod,dword[AccTimer_nSysRes_ms]

        .uninit_apis:
        ccall   AccTimer_UnInitAPI_tGT
        ccall   AccTimer_UnInitAPI_QPC

        .end:
        ret
endp

proc AccTimer_InitAPIs c

        locals
                vToMillisConvMult dd 1000.0
        endl

        .init_apis:
        ccall   AccTimer_InitAPI_tGT
        ccall   AccTimer_InitAPI_QPC

        .check_api:
        test    dword[AccTimer_bAvailableAPI],1
        jz      .select_set_api

        .set_sys_res:
        invoke  timeBeginPeriod,dword[AccTimer_nSysRes_ms]
        test    eax,eax
        jnz     .error ; 0 = MMSYSERR_NOERROR

        .select_set_api:
        ccall   AccTimer_SelectSetAPI
        test    eax,eax
        jz      .error

        .calc_params:
        ccall   dword[AccTimer_pfnCalcParams]
        test    eax,eax
        jz      .error

        .ok:
        mov     eax,TRUE
        ret

        .error:
        xor     eax,eax
        ret
endp

proc AccTimer_InitAPI_tGT c

        locals
                tTimeCaps rd 2
                sizeof.tTimeCaps = 2*4
        endl

        .check_devcaps:
        lea     eax,[tTimeCaps]
        invoke  timeGetDevCaps,eax,sizeof.tTimeCaps
        test    eax,eax
        jnz     .end ; 0 = MMSYSERR_NOERROR

        .set_wrap_vars:
        ;xor     eax,eax
        mov     dword[AccTimer_nLastCounter32],eax
        mov     dword[AccTimer_nWrapCounterHI],eax

        .set_sys_res:
        mov     ecx,dword[tTimeCaps] ;tTimeCaps.wPeriodMin
        mov     dword[AccTimer_nSysRes_ms],ecx

        .set_available:
        or     dword[AccTimer_bAvailableAPI],1

        .end:
        ret
endp

proc AccTimer_InitAPI_QPC c

        locals
                vPerfFreq dq ?
                vPerfCounter dq ?
        endl

        .check_freq:
        lea     eax,[vPerfFreq]
        invoke  QueryPerformanceFrequency,eax
        test    eax,eax
        jz      .end

        .check_counter:
        lea     eax,[vPerfCounter]
        invoke  QueryPerformanceCounter,eax
        test    eax,eax
        jz      .end

        .set_available:
        or     dword[AccTimer_bAvailableAPI],2

        .end:
        ret
endp

proc AccTimer_SelectSetAPI c

        .get_available_apis:
        mov     ecx,dword[AccTimer_bAvailableAPI]

        .get_set_api:
        mov     edx,dword[AccTimer_nTimingAPI]

        .check_set_api:
        cmp     edx,-1
        je      .auto_select
        cmp     edx,0
        je      .check_api_tgt
        cmp     edx,1
        je      .check_api_qpc

        .error:
        xor     eax,eax
        ret

        .auto_select:
        ccall   AccTimer_AutoSelectAPI
        ret

        .check_api_tgt:
        test    ecx,1
        jz      .error
        .set_api_tgt:
        mov     dword[AccTimer_pfnCalcParams],AccTimer_CalcParams_tGT
        mov     dword[AccTimer_pfnGetCounter],AccTimer_GetCounter_tGT
        mov     eax,TRUE
        ret

        .check_api_qpc:
        test    ecx,2
        jz      .error
        .set_api_qpc:
        mov     dword[AccTimer_pfnCalcParams],AccTimer_CalcParams_QPC
        mov     dword[AccTimer_pfnGetCounter],AccTimer_GetCounter_QPC
        mov     eax,TRUE
        ret
endp

proc AccTimer_AutoSelectAPI c

        .get_available_apis:
        mov     ecx,dword[AccTimer_bAvailableAPI]

        .check_api_qpc:
        test    ecx,2
        jz      .check_api_tgt
        .set_api_qpc:
        mov     dword[AccTimer_pfnCalcParams],AccTimer_CalcParams_QPC
        mov     dword[AccTimer_pfnGetCounter],AccTimer_GetCounter_QPC
        mov     eax,TRUE
        ret

        .check_api_tgt:
        test    ecx,1
        jz      .error
        .set_api_tgt:
        mov     dword[AccTimer_pfnCalcParams],AccTimer_CalcParams_tGT
        mov     dword[AccTimer_pfnGetCounter],AccTimer_GetCounter_tGT
        mov     eax,TRUE
        ret

        .error:
        xor     eax,eax
        ret
endp

proc AccTimer_CalcParams_tGT c

        locals
                v1000_0 dd 1000.0
                v1_0 dd 1.0
                v0_001 dq 0.001
        endl

        .calc_vperiod:
        fild    dword[AccTimer_nSysRes_ms]
        fdiv    dword[v1000_0]
        fstp    qword[AccTimer_vPeriod] ; AccTimer_vPeriod = AccTimer_nSysRes_ms / 1000.0

        .calc_vfreq:
        fld     qword[AccTimer_vPeriod]
        fld1
        fdivrp  st1,st0
        fstp    qword[AccTimer_vFrequency] ; AccTimer_vFrequency = 1.0 / AccTimer_vPeriod

        .calc_nfreq:
        fld     qword[AccTimer_vFrequency]
        fadd    dword[FPU_CONSTS.flt_0_5] ; guard against truncation mode
        fistp   qword[AccTimer_nFrequency]

        .calc_secs_conv_mult:
        fld     qword[v0_001]
        fstp    qword[AccTimer_vToSecsConvMult]

        .calc_millis_conv_mult:
        fld     dword[v1_0]
        fstp    qword[AccTimer_vToMillisConvMult]

        .ok:
        mov     eax,TRUE
        ret

        ;.error:
        ;xor     eax,eax
        ;ret
endp

proc AccTimer_CalcParams_QPC c

        locals
                v1000_0 dd 1000.0
        endl

        .get_nfreq:
        lea     eax,[AccTimer_nFrequency]
        invoke  QueryPerformanceFrequency,eax
        test    eax,eax
        jz      .error

        .calc_vfreq:
        fild    qword[AccTimer_nFrequency]
        fstp    qword[AccTimer_vFrequency]

        .calc_vperiod:
        fld     qword[AccTimer_vFrequency]
        fld1
        fdivrp  st1,st0
        fstp    qword[AccTimer_vPeriod] ; AccTimer_vPeriod = 1.0 / AccTimer_vFrequency

        .calc_secs_conv_mult:
        fld     qword[AccTimer_vPeriod]
        fstp    qword[AccTimer_vToSecsConvMult]

        .calc_millis_conv_mult:
        fld     qword[AccTimer_vPeriod]
        fmul    dword[v1000_0]
        fstp    qword[AccTimer_vToMillisConvMult]

        .ok:
        mov     eax,TRUE
        ret

        .error:
        ;xor     eax,eax
        ret
endp

align 16
AccTimer_GetCounter_tGT:

        .get_counter:
        invoke  timeGetTime
        mov     edx,dword[AccTimer_nWrapCounterHI]

        .check_wrap:
        cmp     eax,dword[AccTimer_nLastCounter32]
        sbb     ecx,ecx
        neg     ecx
        add     edx,ecx
        mov     dword[AccTimer_nLastCounter32],eax
        mov     dword[AccTimer_nWrapCounterHI],edx

        .end:
        ret

align 16
AccTimer_GetCounter_QPC:

        .n64Counter = -8

        sub     esp,8

        .get_counter:
        ;lea     eax,[esp+8+.n64Counter]
        invoke  QueryPerformanceCounter,esp
        mov     eax,dword[esp+8+.n64Counter]
        mov     edx,dword[esp+8+.n64Counter+4]

        .end:
        add     esp,8
        ret

proc AccTimer_UnInitAPI_tGT c

        .set_not_available:
        and     dword[AccTimer_bAvailableAPI],not 1

        .end:
        ret
endp

proc AccTimer_UnInitAPI_QPC c

        .set_not_available:
        and     dword[AccTimer_bAvailableAPI],not 2

        .end:
        ret
endp

loc_4020B0: ; Flow_CreateHandler

        .init_vars:
        mov     dword[Flow_isForbidDrawOneTick],TRUE
        mov     dword[ecx+4Ch],ebx ;ptFlow->nUnknown
        ; TODO: move here rest of .data vars

        .init_input_timestep:
        ccall   Flow_UpdateCInputTimestep,ecx

        .back:
        push    PATCHER_ADDR_TRAP ;0x005362F4 -> "LOCAL:config.qsc"
        .fixup1 = $-4
        jmp     near PATCHER_JUMP_TRAP ;loc_4020C9
        .fixup2 = $-4

proc Flow_ResetTimings c ptFlow,isFullReset,nTimeNowLO,nTimeNowHI

        push    ebx
        mov     ebx,dword[ptFlow]

        .init_time_now:
        mov     eax,dword[nTimeNowLO]
        mov     edx,dword[nTimeNowHI]

        .check_provided:
        cmp     dword[isFullReset],FALSE
        je      .reset_timings

        .read_timer:
        ccall   AccTimer_Read

        .set_start_time:
        mov     dword[Flow_nStartTime],eax
        mov     dword[Flow_nStartTime+4],edx

        .reset_timings:
        xor     ecx,ecx
        mov     dword[Flow_nSkipTime],ecx
        mov     dword[Flow_nSkipTime+4],ecx
        mov     dword[ebx+40h],ecx ;ptFlow->nTicksSinceRedraw
        ;mov     byte[ebx+44h],TRUE ;ptFlow->isDrawn
        mov     dword[ebx+44h],1 ;ptFlow->nFramesSinceLastTick

        .reset_cinput:
        ;mov     dword[Flow_nCInputUpdateTime],eax
        ;mov     dword[Flow_nCInputUpdateTime+4],edx
        mov     dword[Flow_nCInputLastTime],eax
        mov     dword[Flow_nCInputLastTime+4],edx

        .reset_glogic:
        mov     dword[Flow_nGLogicUpdateTime],eax
        mov     dword[Flow_nGLogicUpdateTime+4],edx
        mov     dword[Flow_nGLogicLastTime],eax
        mov     dword[Flow_nGLogicLastTime+4],edx

        .reset_render:
        ;mov     dword[Flow_nRenderUpdateTime],eax
        ;mov     dword[Flow_nRenderUpdateTime+4],edx
        mov     dword[Flow_nRenderLastTime],eax
        mov     dword[Flow_nRenderLastTime+4],edx

        .reset_timesteps:
        ;mov     dword[Flow_nCInputTimestepAdd],ecx
        ;mov     dword[Flow_vCInputTimestepAcc],ecx
        ;mov     dword[Flow_vCInputTimestepAcc+4],ecx
        mov     dword[Flow_nGLogicTimestepAdd],ecx
        mov     dword[Flow_vGLogicTimestepAcc],ecx
        mov     dword[Flow_vGLogicTimestepAcc+4],ecx
        mov     dword[Flow_nRenderTimestepAdd],ecx
        mov     dword[Flow_vRenderTimestepAcc],ecx
        mov     dword[Flow_vRenderTimestepAcc+4],ecx

        .end:
        pop     ebx
        ret
endp

proc Flow_SetFrequency_NEW c nFrequency

        push    ebx
        mov     ebx,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup1 = $-4

        .reset_timings:
        ccall   Flow_ResetTimings,ebx,TRUE,0,0

        .reset_fps_counter:
        ccall   Flow_ResetFPSCounter

        .reset_vars:
        mov     eax,dword[nFrequency]
        xor     ecx,ecx
        mov     dword[Flow_isForbidDrawOneTick],TRUE
        mov     dword[ebx+34h],ecx ;ptFlow->nTicks
        mov     dword[ebx+38h],ecx ;ptFlow->nFrames
        mov     dword[ebx+3Ch],eax ;ptFlow->nFrequency
        mov     dword[Flow_nRefreshRate],-1

        .set_sound_freq:
        push    eax
        call    near PATCHER_CALL_TRAP ;SoundSys_SetFrequency:0x004E6030
        .fixup2 = $-4
        add     esp,1*4

        .end:
        pop     ebx
        ret
endp

align 16
Movie_IsPlaying_NEW:

        .init_result:
        xor     eax,eax

        .check_vars:
        cmp     byte[PATCHER_ADDR_TRAP],al ;0x005C8E71
        .fixup1 = $-4
        jne     .yes
        cmp     byte[PATCHER_ADDR_TRAP],al ;0x005C8E70
        .fixup2 = $-4
        jne     .yes

        .no:
        ;xor     eax,eax
        retn    0

        .yes:
        mov     eax,TRUE
        retn    0

align 16
World_ResetTracedLines:

        .reset:
        xor     eax,eax
        mov     dword[PATCHER_ADDR_TRAP],eax ;World_nTraceLines:0x00A4438C
        .fixup1 = $-4
        mov     dword[PATCHER_ADDR_TRAP],eax ;World_nTraceLinesActual:0x00A44390
        .fixup2 = $-4
        mov     dword[PATCHER_ADDR_TRAP],eax ;World_nLineOfSights:0x00A44394
        .fixup3 = $-4

        .end:
        retn    0

align 16
DebugText_Reset:

        .reset:
        call    near PATCHER_CALL_TRAP ;DebugText_Clear:0x004E7BB0
        .fixup1 = $-4
        push    0
        push    0
        call    near PATCHER_CALL_TRAP ;DebugText_SetCursor:0x004E7B80
        .fixup2 = $-4
        add     esp,2*4

        .end:
        retn    0

align 16
Flow_IsUnlimitedFPS:

        .init_result:
        xor     eax,eax

        .check_vars:
        cmp     byte[PATCHER_ADDR_TRAP],al ;AppContext_isFixmeSmall:0x005C8E00
        .fixup1 = $-4
        jne     .yes
        cmp     byte[PATCHER_ADDR_TRAP],al ;ScreenGrab_isRecord:0x00A70C5B
        .fixup2 = $-4
        jne     .yes
        cmp     byte[PATCHER_ADDR_TRAP],al ;ScreenGrab_isGrabSingle:0x00A70C5A
        .fixup3 = $-4
        jne     .yes

        .no:
        ;xor     eax,eax
        retn    0

        .yes:
        mov     eax,TRUE
        retn    0

align 16
Flow_IsInterpEnabled:

        .get_interp_enabled:
        mov     eax,dword[IniFile.NFL.EnableInterpolation]

        .end:
        retn    0

align 16
Flow_IsFPSLocked:

        .check_fpslock:
        cmp     dword[AppContext_isFPSLock],FALSE
        jne     .yes

        .check_render_vars:
        cmp     dword[Flow_isRenderTimerUsed],FALSE
        je      .yes

        .check_fpsl_mode:
        cmp     dword[Flow_nCurFPSLimiterMode],NFL_FLOW_FPSLM_NORMAL
        jne     .yes

        .check_fpsl_rendermode:
        cmp     dword[Flow_nCurFPSLimiterRenderMode],NFL_FLOW_FPSLRM_SYNCED
        je      .yes

        .check_appactive: ; not really applicable to igi 1
        cmp     dword[PATCHER_ADDR_TRAP],FALSE ;AppContext.isActive:0x005C8BFC
        .fixup1 = $-1-4
        je      .yes

        .no:
        xor     eax,eax
        retn    0

        .yes:
        mov     eax,TRUE
        retn    0

align 16
Flow_IsInterpSuppressed:

        .check_interp_enabled:
        ;ccall   Flow_IsInterpEnabled
        ;test    eax,eax
        ;jz      .yes
        cmp     dword[IniFile.NFL.EnableInterpolation],FALSE
        je      .yes

        .check_fps_locked:
        ccall   Flow_IsFPSLocked
        test    eax,eax
        jnz     .yes

        .check_render_vars:
        cmp     dword[Flow_IsRenderFasterThanGLogic],FALSE
        je      .yes

        .check_cutscene: ; bugged for some reason
        cmp     dword[CutScene_isRunning],FALSE
        jne     .yes

        .check_stationarygun: ; bugged, temporary disabled
        cmp     dword[StationaryGun_isUsedByPlayer],FALSE
        jne     .yes

        .no:
        xor     eax,eax
        retn    0

        .yes:
        mov     eax,TRUE
        retn    0

align 16
Flow_RunChildren:

        .ptFlow = 4

        push    ebx ebp esi edi
        mov     ebp,dword[esp+10h+.ptFlow]
        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_RUN
        mov     dword[Flow_isForbidDrawOneTick],FALSE
        mov     dword[CutScene_isRunning],FALSE
        mov     dword[StationaryGun_isUsedByPlayer],FALSE ; temp workaround
        ccall   World_ResetTracedLines
        ccall   DebugText_Reset

        .init_vars:
        mov     esi,PATCHER_ADDR_TRAP ;QTask_atProtectedQTaskStack:0x00AFA6E0
        .fixup1 = $-4
        mov     edi,PATCHER_ADDR_TRAP ;&QTask_nProtectedQTaskStackOffset:0x00AFA7E0
        .fixup2 = $-4

        .get_1st_children:
        mov     ebx,dword[ebp+8] ;ptFlow->tQTask.tQTaskChildren.ptHead

        .check_children:
        cmp     dword[ebx],0 ;ptQTask->ptNext
        je      .get_1st_children_ar

        .loop1_init:
        mov     ecx,dword[edi] ;QTask_nProtectedQTaskStackOffset
        align   16

        .loop1_body:
        xor     eax,eax

        .l1_get_next_task:
        mov     edx,dword[ebx] ;ptQTask->ptNext
        test    edx,edx
        jz      .l1_set_stack

        .l1_get_next_next_task:
        mov     eax,dword[edx] ;ptNext->ptNext
        neg     eax
        sbb     eax,eax
        and     eax,edx

        .l1_set_stack:
        mov     dword[esi+ecx*4],eax ;QTask_atProtectedQTaskStack[QTask_nProtectedQTaskStackOffset]
        inc     ecx
        mov     dword[edi],ecx ;QTask_nProtectedQTaskStackOffset

        .l1_get_run_handler:
        movzx   edx,word[ebx+1Ch] ;ptTask->eQTaskType
        add     edx,384 ; index 1 = _RunHandler
        mov     eax,dword[PATCHER_ADDR_TRAP+edx*4] ;QTask_aatQTaskFinalEvent.pfHandler
        .fixup3 = $-4
        test    eax,eax
        jz      .loop1_next

        .l1_call_run_handler:
        ccall   eax,ebx

        .loop1_next:
        mov     ecx,dword[edi] ;QTask_nProtectedQTaskStackOffset
        dec     ecx
        mov     dword[edi],ecx ;QTask_nProtectedQTaskStackOffset
        mov     ebx,dword[esi+ecx*4] ;QTask_atProtectedQTaskStack[QTask_nProtectedQTaskStackOffset]
        test    ebx,ebx
        jnz     .loop1_body

        .get_1st_children_ar:
        mov     ebx,dword[ebp+48h] ;ptFlow->ptAlwaysRunQTask
        mov     ebx,dword[ebx+8] ;ptAlwaysRunQTask->tQTaskChildren.ptHead

        .check_children_ar:
        cmp     dword[ebx],0 ;ptQTask->ptNext
        je      .update_vars

        .loop2_init:
        mov     ecx,dword[edi] ;QTask_nProtectedQTaskStackOffset
        align   16

        .loop2_body:
        xor     eax,eax

        .l2_get_next_task:
        mov     edx,dword[ebx] ;ptQTask->ptNext
        test    edx,edx
        jz      .l2_set_stack

        .l2_get_next_next_task:
        mov     eax,dword[edx] ;ptQTask->ptNext
        neg     eax
        sbb     eax,eax
        and     eax,edx

        .l2_set_stack:
        mov     dword[esi+ecx*4],eax ;QTask_atProtectedQTaskStack[QTask_nProtectedQTaskStackOffset]
        inc     ecx
        mov     dword[edi],ecx ;QTask_nProtectedQTaskStackOffset

        .l2_get_run_handler:
        movzx   edx,word[ebx+1Ch] ;ptQTask->eQTaskType
        add     edx,384 ; index 1 = _RunHandler
        mov     eax,dword[PATCHER_ADDR_TRAP+edx*4] ;QTask_aatQTaskFinalEvent.pfHandler
        .fixup4 = $-4
        test    eax,eax
        jz      .loop2_next

        .l2_call_run_handler:
        ccall   eax,ebx

        .loop2_next:
        mov     ecx,dword[edi] ;QTask_nProtectedQTaskStackOffset
        dec     ecx
        mov     dword[edi],ecx ;QTask_nProtectedQTaskStackOffset
        mov     ebx,dword[esi+ecx*4] ;QTask_atProtectedQTaskStack[QTask_nProtectedQTaskStackOffset]
        test    ebx,ebx
        jnz     .loop2_body

        .update_vars:
        inc     dword[ebp+34h] ;ptFlow->nTicks
        inc     dword[ebp+40h] ;ptFlow->nTicksSinceRedraw
        ;mov     byte[ebp+44h],FALSE ;ptFlow->isDrawn
        mov     dword[ebp+44h],0 ;ptFlow->nFramesSinceLastTick

        .end:
        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_NONE
        pop     edi esi ebp ebx
        retn    0

align 16
Flow_InterpChildren:

        ;.ptFlow = 4

        push    ebx esi edi
        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP

        .get_tasklist:
        mov     ebx,dword[Flow_ptDrawInterpolateQTaskList]

        .calc_offset:
        mov     esi,dword[Flow_eDrawInterpolateQTaskEvent]
        imul    esi,384

        .get_num_tasks:
        mov     edi,dword[ebx] ;Flow_ptDrawInterpolateQTaskList->nTask
        test    edi,edi
        jle     .end

        .loop_init:
        align   16

        .loop_body:
        mov     ecx,dword[ebx+8] ;Flow_ptDrawInterpolateQTaskList[i]->ptQTask
        movzx   edx,word[ecx+1Ch] ;ptTask->eQTaskType
        add     edx,esi

        .call_draw_interp_handler:
        push    ecx
        call    dword[PATCHER_CALL_TRAP+edx*4] ;QTask_aatQTaskFinalEvent:0x08540740
        .fixup1 = $-4
        add     esp,4

        .loop_next:
        add     ebx,4
        dec     edi
        jnz     .loop_body

        .end:
        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_NONE
        pop     edi esi ebx
        retn    0

align 16
Flow_DrawChildren:

        .ptFlow = 4

        push    ebx ebp esi edi
        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_DRAW

        .check_forbid_draw:
        cmp     dword[Flow_isForbidDrawOneTick],FALSE
        jne     .update_vars

        .init_vars:
        mov     esi,PATCHER_ADDR_TRAP ;QTask_atProtectedQTaskStack:0x00AFA6E0
        .fixup1 = $-4
        mov     edi,PATCHER_ADDR_TRAP ;&QTask_nProtectedQTaskStackOffset:0x00AFA7E0
        .fixup2 = $-4
        mov     ebp,dword[PATCHER_ADDR_TRAP] ;Screen_eDrawQTaskEvent:0x005488C8
        .fixup3 = $-4
        imul    ebp,384

        .get_1st_children:
        mov     eax,dword[esp+10h+.ptFlow]

        .check_children:
        mov     ebx,dword[eax+8] ;ptFlow->tQTask.tQTaskChildren.ptHead
        cmp     dword[ebx],0 ;ptQTask->ptNext
        je      .update_vars

        .loop_init:
        mov     ecx,dword[edi] ;QTask_nProtectedQTaskStackOffset
        align   16

        .loop_body:
        xor     eax,eax

        .get_next_task:
        mov     edx,dword[ebx] ;ptQTask->ptNext
        test    edx,edx
        jz      .set_stack

        .get_next_next_task:
        mov     eax,dword[edx] ;ptNext->ptNext
        neg     eax
        sbb     eax,eax
        and     eax,edx

        .set_stack:
        mov     dword[esi+ecx*4],eax ;QTask_atProtectedQTaskStack[QTask_nProtectedQTaskStackOffset]
        inc     ecx
        mov     dword[edi],ecx ;QTask_nProtectedQTaskStackOffset

        .get_draw_handler:
        movzx   edx,word[ebx+1Ch] ;ptTask->eQTaskType
        add     edx,ebp
        mov     eax,dword[PATCHER_ADDR_TRAP+edx*4] ;QTask_aatQTaskFinalEvent.pfHandler
        .fixup4 = $-4
        test    eax,eax
        jz      .loop_next

        .call_draw_handler:
        ccall   eax,ebx

        .loop_next:
        mov     ecx,dword[edi] ;QTask_nProtectedQTaskStackOffset
        dec     ecx
        mov     dword[edi],ecx ;QTask_nProtectedQTaskStackOffset
        mov     ebx,dword[esi+ecx*4] ;QTask_atProtectedQTaskStack[QTask_nProtectedQTaskStackOffset]
        test    ebx,ebx
        jnz     .loop_body

        .update_vars:
        mov     eax,dword[esp+10h+.ptFlow]
        inc     dword[eax+38h] ;ptFlow->nFrames
        mov     dword[eax+40h],0 ;ptFlow->nTicksSinceRedraw
        ;mov     byte[eax+44h],TRUE ;ptFlow->isDrawn
        inc     dword[eax+44h] ;ptFlow->nFramesSinceLastTick

        .end:
        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_NONE
        pop     edi esi ebp ebx
        retn    0

align 16
loc_402260: ; Flow_RunHandler

        ;.Flow_nDeltaTime = -10h+-10h
        ;.Flow_nCurrentTime = -8
        .Flow_nDeltaTime = -8
        .ptFlow = 4

        ;------------------------------------------------------------
        ; prologue
        ;------------------------------------------------------------

        .prologue:
        sub     esp,8
        push    ebx ebp esi edi
        ;sub     esp,8 ; alloc 8 more bytes
        mov     ebp,dword[esp+18h+.ptFlow]

        ;------------------------------------------------------------
        ; handle frequency and refresh rate changes
        ;------------------------------------------------------------

        .check_frequency:
        mov     eax,dword[ebp+3Ch] ;ptFlow->nFrequency
        cmp     eax,dword[Flow_nCurrentFrequency]
        je      .check_refreshrate
        .update_frequency:
        mov     dword[Flow_nCurrentFrequency],eax
        ccall   Flow_UpdateGLogicTimestep,ebp
        ccall   Flow_UpdateRenderMode

        .check_refreshrate:
        mov     eax,dword[Display_nCurrentRefreshRate]
        cmp     eax,dword[Flow_nCurrentRefreshRate]
        je      .check_fpslimiter_mode
        .update_refreshrate:
        mov     dword[Flow_nCurrentRefreshRate],eax
        ccall   Flow_GetMaxRenderFPS
        mov     dword[Flow_nRefreshRate],eax
        ccall   Flow_UpdateRenderTimestep,ebp
        ccall   Flow_UpdateRenderMode
        ccall   Flow_UpdateCInputDynTimestep,ebp

        ;------------------------------------------------------------
        ; check fps limiter mode
        ;------------------------------------------------------------

        .check_fpslimiter_mode:

        .check_movie_playing:
        ccall   Movie_IsPlaying_NEW
        test    eax,eax
        jnz     .movie_playing

        .check_unlimited_fps:
        ccall   Flow_IsUnlimitedFPS
        test    eax,eax
        jnz     .unlimited_fps_on

        ;------------------------------------------------------------
        ; normal mode
        ;------------------------------------------------------------

        .normal_mode:
        mov     dword[Flow_nCurFPSLimiterMode],NFL_FLOW_FPSLM_NORMAL
        mov     dword[Flow_nCurFPSLimiterRenderMode],NFL_FLOW_FPSLRM_NOT_SET

        ;------------------------------------------------------------
        ; cinput phase
        ;------------------------------------------------------------

        .cinput_get_time:
        ccall   AccTimer_Read
        mov     esi,eax
        mov     edi,edx
        sub     eax,dword[Flow_nCInputLastTime]
        sbb     edx,dword[Flow_nCInputLastTime+4]

        .cinput_check_deltatime:
        sub     eax,dword[Flow_nCInputTimestep]
        sbb     edx,dword[Flow_nCInputTimestep+4]
        jb      .glogic_phase

        .cinput_update_vars:
        mov     dword[Flow_nCInputLastTime],esi
        mov     dword[Flow_nCInputLastTime+4],edi

        .cinput_update:
        ccall   Flow_UpdateCInput,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ;jmp     .glogic_phase

        ;------------------------------------------------------------
        ; glogic phase
        ;------------------------------------------------------------

        .glogic_phase:

        .glogic_get_time:
        ccall   AccTimer_Read
        mov     esi,eax
        mov     edi,edx

        .glogic_check_updatetime:
        cmp     dword[ebp+40h],10 ;ptFlow->nTicksSinceRedraw
        jg      .glogic_slowdown
        mov     ebx,dword[Flow_nGLogicUpdateTime]
        mov     ecx,dword[Flow_nGLogicUpdateTime+4]
        add     ebx,dword[Flow_nSkipTime]
        adc     ecx,dword[Flow_nSkipTime+4]
        sub     eax,ebx
        sbb     edx,ecx
        jb      .render_phase

        .glogic_update_vars:
        fld     qword[Flow_vGLogicTimestepAcc]
        fadd    dword[Flow_vGLogicTimestepAccAdd]
        fcom    dword[FPU_CONSTS.flt_1_0]
        fnstsw  ax
        xor     ecx,ecx
        test    ah,1
        sete    cl
        mov     edx,ecx
        neg     edx
        and     edx,1.0
        mov     dword[esp+18h+.ptFlow],edx ; temp var
        fsub    dword[esp+18h+.ptFlow]
        fstp    qword[Flow_vGLogicTimestepAcc] ; Flow_vGLogicTimestepAcc -= (Flow_vGLogicTimestepAcc + Flow_vGLogicTimestepAccAdd >= 1.0) ? 1.0 : 0.0
        mov     dword[Flow_nGLogicTimestepAdd],ecx
        mov     ebx,dword[Flow_nGLogicUpdateTime]
        mov     ecx,dword[Flow_nGLogicUpdateTime+4]
        add     ebx,dword[Flow_nGLogicTimestep]
        adc     ecx,dword[Flow_nGLogicTimestep+4]
        add     ebx,dword[Flow_nGLogicTimestepAdd]
        adc     ecx,0
        mov     eax,esi
        mov     edx,edi
        sub     eax,dword[Flow_nGLogicLastTime]
        sbb     edx,dword[Flow_nGLogicLastTime+4]
        mov     dword[Flow_nGLogicUpdateTime],ebx
        mov     dword[Flow_nGLogicUpdateTime+4],ecx
        mov     dword[Flow_nGLogicLastTime],esi
        mov     dword[Flow_nGLogicLastTime+4],edi
        mov     dword[Flow_nGLogicDeltaTime],eax
        mov     dword[Flow_nGLogicDeltaTime+4],edx
        mov     dword[Flow_nSkipTime],0
        mov     dword[Flow_nSkipTime+4],0

        .glogic_run:
        ccall   Flow_CalcGLogicFPS
        ccall   Flow_UpdateInputOnRun,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_RunChildren,ebp

        .print_fps_counter:
        ccall   Flow_PrintFPSCounter
        jmp     .back

        .glogic_slowdown:
        ccall   Flow_ResetTimings,ebp,FALSE,eax,edx
        ;jmp     .render_phase

        ;------------------------------------------------------------
        ; check render mode
        ;------------------------------------------------------------

        .render_phase:

        .check_fps_locked:
        ccall   Flow_IsFPSLocked
        test    eax,eax
        jnz     .render_synced

        ;------------------------------------------------------------
        ; render phase (asynchronous)
        ;------------------------------------------------------------

        .render_async:
        mov     dword[Flow_nCurFPSLimiterRenderMode],NFL_FLOW_FPSLRM_ASYNC

        .render_get_time:
        ccall   AccTimer_Read
        mov     esi,eax
        mov     edi,edx
        sub     eax,dword[Flow_nRenderLastTime]
        sbb     edx,dword[Flow_nRenderLastTime+4]
        mov     dword[esp+18h+.Flow_nDeltaTime],eax
        mov     dword[esp+18h+.Flow_nDeltaTime+4],edx

        .render_check_deltatime:
        mov     ebx,dword[Flow_nRenderTimestep]
        mov     ecx,dword[Flow_nRenderTimestep+4]
        add     ebx,dword[Flow_nRenderTimestepAdd]
        adc     ecx,0
        sub     eax,ebx
        sbb     edx,ecx
        jb      .back

        .render_update_vars:
        fld     qword[Flow_vRenderTimestepAcc]
        fadd    dword[Flow_vRenderTimestepAccAdd]
        fcom    dword[FPU_CONSTS.flt_1_0]
        fnstsw  ax
        xor     ecx,ecx
        test    ah,1
        sete    cl
        mov     edx,ecx
        neg     edx
        and     edx,1.0
        mov     dword[esp+18h+.ptFlow],edx ; temp var
        fsub    dword[esp+18h+.ptFlow]
        fstp    qword[Flow_vRenderTimestepAcc] ; Flow_vRenderTimestepAcc -= (Flow_vRenderTimestepAcc + Flow_vRenderTimestepAccAdd >= 1.0) ? 1.0 : 0.0
        mov     dword[Flow_nRenderTimestepAdd],ecx
        mov     eax,dword[esp+18h+.Flow_nDeltaTime]
        mov     edx,dword[esp+18h+.Flow_nDeltaTime+4]
        mov     dword[Flow_nRenderLastTime],esi
        mov     dword[Flow_nRenderLastTime+4],edi
        mov     dword[Flow_nRenderDeltaTime],eax
        mov     dword[Flow_nRenderDeltaTime+4],edx

        .render_check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .render_draw

        .render_drawinterp:
        ccall   Flow_CalcRenderFPS
        ccall   Flow_CalcDrawDeltaTime
        ;ccall   Flow_CalcAnimsInterpTime
        ccall   Flow_UpdateInputOnInterp,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_InterpChildren;,ebp
        ccall   Flow_UpdateInputOnDraw,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_DrawChildren,ebp
        ccall   Flow_UpdateFPSCounter
        jmp     .back

        .render_draw:
        ccall   Flow_CalcRenderFPS
        ccall   Flow_UpdateInputOnInterp,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_UpdateInputOnDraw,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_DrawChildren,ebp
        ccall   Flow_UpdateFPSCounter
        jmp     .back

        ;------------------------------------------------------------
        ; render phase (synchronized)
        ;------------------------------------------------------------

        .render_synced:
        mov     dword[Flow_nCurFPSLimiterRenderMode],NFL_FLOW_FPSLRM_SYNCED

        .render_synced_check_drawn:
        cmp     dword[ebp+44h],0 ;ptFlow->nFramesSinceLastTick
        jne     .back

        .render_synced_get_time:
        ccall   AccTimer_Read

        .render_synced_update_vars:
        mov     esi,eax
        mov     edi,edx
        sub     eax,dword[Flow_nRenderLastTime]
        sbb     edx,dword[Flow_nRenderLastTime+4]
        mov     dword[Flow_nRenderLastTime],esi
        mov     dword[Flow_nRenderLastTime+4],edi
        mov     dword[Flow_nRenderDeltaTime],eax
        mov     dword[Flow_nRenderDeltaTime+4],edx

        .render_synced_draw:
        ccall   Flow_CalcRenderFPS
        ccall   Flow_UpdateInputOnInterp,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_UpdateInputOnDraw,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_DrawChildren,ebp
        ccall   Flow_UpdateFPSCounter
        ;jmp     .back

        ;------------------------------------------------------------
        ; jump back to handle events
        ;------------------------------------------------------------

        .back:
        mov     eax,ebp
        xor     ebx,ebx
        cmp     dword[eax+2Ch],ebx ;ptFlow->eRequestedEvent
        je      .skip_forbid_draw
        mov     dword[Flow_isForbidDrawOneTick],TRUE
        .skip_forbid_draw:
        ;add     esp,8
        jmp     near PATCHER_JUMP_TRAP ;loc_40262E
        .fixup1 = $-4

        ;------------------------------------------------------------
        ; play movie mode
        ;------------------------------------------------------------

        .movie_playing:
        mov     dword[Flow_nCurFPSLimiterMode],NFL_FLOW_FPSLM_MOVIE
        mov     dword[Flow_nCurFPSLimiterRenderMode],NFL_FLOW_FPSLRM_SYNCED
        ccall   Flow_UpdateCInput,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_CalcGLogicFPS
        ccall   Flow_UpdateInputOnRun,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_RunChildren,ebp
        ccall   Flow_CalcRenderFPS
        ccall   Flow_UpdateInputOnInterp,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_UpdateInputOnDraw,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        inc     dword[ebp+38h] ;ptFlow->nFrames
        ccall   Flow_UpdateFPSCounter
        jmp     .back

        ;------------------------------------------------------------
        ; unlimited fps mode
        ;------------------------------------------------------------

        .unlimited_fps_on:
        mov     dword[Flow_nCurFPSLimiterMode],NFL_FLOW_FPSLM_UNLIMITED
        mov     dword[Flow_nCurFPSLimiterRenderMode],NFL_FLOW_FPSLRM_SYNCED
        ccall   Flow_UpdateCInput,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_CalcGLogicFPS
        ccall   Flow_UpdateInputOnRun,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_RunChildren,ebp
        ccall   Flow_CalcRenderFPS
        ccall   Flow_UpdateInputOnInterp,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_UpdateInputOnDraw,dword[ebp+24h] ;ptFlow->ptInputPortQTask
        ccall   Flow_DrawChildren,ebp
        ccall   Flow_UpdateFPSCounter
        jmp     .back

proc Flow_UpdateCInputTimestep c ptFlow

        locals
                wFPUControlWord rd 1 ; word aligned to dword
        endl

        .check_value:
        mov     eax,dword[IniFile.NFL.InputUpdateRate]
        add     eax,1
        cmp     eax,0+1
        jbe     .zero

        .calc:
        fld     qword[AccTimer_vFrequency]
        fidiv   dword[IniFile.NFL.InputUpdateRate]
        ;fst     qword[Flow_vCInputTimestep]
        ;fld     st0
        fnstcw  word[wFPUControlWord]
        movzx   eax,word[wFPUControlWord]
        mov     ecx,eax ; old value
        or      ah,0x0C ; new value - set to Truncate
        mov     word[wFPUControlWord],ax
        fldcw   word[wFPUControlWord]
        frndint
        mov     word[wFPUControlWord],cx
        fldcw   word[wFPUControlWord]
        ;fld     st0
        fistp   qword[Flow_nCInputTimestep]
        ;mov     dword[Flow_nCInputTimestepAdd],0
        ;fsubp
        ;fst     qword[Flow_vCInputTimestepAcc]
        ;fstp    dword[Flow_vCInputTimestepAccAdd]
        ret

        .zero:
        mov     dword[Flow_nCInputTimestep],0
        mov     dword[Flow_nCInputTimestep+4],0
        ;mov     dword[Flow_nCInputTimestepAdd],0
        ;mov     dword[Flow_vCInputTimestepAcc],0
        ;mov     dword[Flow_vCInputTimestepAcc+4],0
        ;mov     dword[Flow_vCInputTimestepAccAdd],0
        ret
endp

proc Flow_UpdateCInputDynTimestep c ptFlow

        .check_dynamic:
        cmp     dword[IniFile.NFL.InputUpdateRate],-1
        jne     .end

        .copy: ; mirror ptFlow->nRefreshRate
        mov     eax,dword[Flow_nRenderTimestep]
        mov     edx,dword[Flow_nRenderTimestep+4]
        mov     dword[Flow_nCInputTimestep],eax
        mov     dword[Flow_nCInputTimestep+4],edx

        .end:
        ret
endp

proc Flow_UpdateGLogicTimestep c ptFlow

        locals
                wFPUControlWord rd 1 ; word aligned to dword
        endl

        mov     eax,dword[ptFlow]

        .check_zero:
        cmp     dword[eax+3Ch],0 ;ptFlow->nFrequency
        je      .zero

        .calc:
        fld     qword[AccTimer_vFrequency]
        fidiv   dword[eax+3Ch] ;ptFlow->nFrequency
        ;fst     qword[Flow_vGLogicTimestep]
        fld     st0
        fnstcw  word[wFPUControlWord]
        movzx   eax,word[wFPUControlWord]
        mov     ecx,eax ; old value
        or      ah,0x0C ; new value - set to Truncate
        mov     word[wFPUControlWord],ax
        fldcw   word[wFPUControlWord]
        frndint
        mov     word[wFPUControlWord],cx
        fldcw   word[wFPUControlWord]
        fld     st0
        fistp   qword[Flow_nGLogicTimestep]
        mov     dword[Flow_nGLogicTimestepAdd],0
        fsubp
        fst     qword[Flow_vGLogicTimestepAcc]
        fstp    dword[Flow_vGLogicTimestepAccAdd]
        ret

        .zero:
        mov     dword[Flow_nGLogicTimestep],0
        mov     dword[Flow_nGLogicTimestep+4],0
        mov     dword[Flow_nGLogicTimestepAdd],0
        mov     dword[Flow_vGLogicTimestepAcc],0
        mov     dword[Flow_vGLogicTimestepAcc+4],0
        mov     dword[Flow_vGLogicTimestepAccAdd],0
        ret
endp

proc Flow_GetMaxRenderFPS c

        .get_maxfps_setting:
        mov     eax,dword[IniFile.NFL.MaxRenderFPS]
        mov     ecx,dword[Flow_nCurrentRefreshRate]
        lea     edx,[eax+1]
        add     edx,-1
        sbb     edx,edx
        and     eax,edx
        not     edx
        and     ecx,edx
        or      eax,ecx ; eax = (IniFile.NFL.MaxRenderFPS == -1) ? Flow_nCurrentRefreshRate : IniFile.NFL.MaxRenderFPS

        .get_maxfreq:
        mov     ecx,dword[AccTimer_nFrequency]
        sub     ecx,0x7FFFFFFF
        cmp     dword[AccTimer_nFrequency+4],1
        sbb     edx,edx
        and     ecx,edx
        add     ecx,0x7FFFFFFF ; ecx = AccTimer_nFrequency capped to INT_MAX

        .calc_result:
        sub     eax,1
        cmp     eax,ecx
        sbb     edx,edx
        add     eax,1
        sub     eax,ecx
        and     eax,edx
        add     eax,ecx ; eax = (eax > 0 && eax <= ecx) ? eax : ecx

        .end:
        ret
endp

proc Flow_UpdateRenderTimestep c ptFlow

        locals
                wFPUControlWord rd 1 ; word aligned to dword
        endl

        mov     eax,dword[ptFlow]

        .check_zero:
        cmp     dword[Flow_nRefreshRate],0 ;ptFlow->nRefreshRate
        je      .zero

        .calc:
        fld     qword[AccTimer_vFrequency]
        fidiv   dword[Flow_nRefreshRate] ;ptFlow->nRefreshRate
        ;fst     qword[Flow_vRenderTimestep]
        fld     st0
        fnstcw  word[wFPUControlWord]
        movzx   eax,word[wFPUControlWord]
        mov     ecx,eax ; old value
        or      ah,0x0C ; new value - set to Truncate
        mov     word[wFPUControlWord],ax
        fldcw   word[wFPUControlWord]
        frndint
        mov     word[wFPUControlWord],cx
        fldcw   word[wFPUControlWord]
        fld     st0
        fistp   qword[Flow_nRenderTimestep]
        mov     dword[Flow_nRenderTimestepAdd],0
        fsubp
        fst     qword[Flow_vRenderTimestepAcc]
        fstp    dword[Flow_vRenderTimestepAccAdd]
        ret

        .zero:
        mov     dword[Flow_nRenderTimestep],0
        mov     dword[Flow_nRenderTimestep+4],0
        mov     dword[Flow_nRenderTimestepAdd],0
        mov     dword[Flow_vRenderTimestepAcc],0
        mov     dword[Flow_vRenderTimestepAcc+4],0
        mov     dword[Flow_vRenderTimestepAccAdd],0
        ret
endp

proc Flow_UpdateRenderMode c

        ;locals
        ;        vGLogicFPSMargin dd 1.0
        ;        vRenderFPSMargin dd 1.1
        ;endl

        fild    qword[Flow_nGLogicTimestep]
        fadd    dword[Flow_vGLogicTimestepAccAdd]
        ;fmul    dword[vGLogicFPSMargin]
        fild    qword[Flow_nRenderTimestep]
        fadd    dword[Flow_vRenderTimestepAccAdd]
        ;fmul    dword[vRenderFPSMargin]
        fcompp
        fnstsw  ax
        xor     ecx,ecx
        xor     edx,edx
        test    ah,40h
        setz    cl ; true if render fps != logic fps
        test    ah,1
        setnz   dl ; true if render fps > logic fps (render timestep < logic timestep)
        mov     dword[Flow_isRenderTimerUsed],ecx
        mov     dword[Flow_IsRenderFasterThanGLogic],edx
        ret
endp

proc Flow_CalcGLogicFPS c

        fild    qword[Flow_nGLogicDeltaTime]
        fmul    qword[AccTimer_vToSecsConvMult]
        fdivr   dword[FPU_CONSTS.flt_1_0]
        fstp    qword[Flow_vCurrentGLogicFPS]
        ret
endp

proc Flow_CalcRenderFPS c

        fild    qword[Flow_nRenderDeltaTime]
        fmul    qword[AccTimer_vToSecsConvMult]
        fdivr   dword[FPU_CONSTS.flt_1_0]
        fstp    qword[Flow_vCurrentRenderFPS]
        ret
endp

proc Flow_ResetFPSCounter c

        xor     eax,eax

        .reset:
        mov     dword[Flow_nFPSCounterInterval],eax
        mov     dword[Flow_nFPSCounterInterval+4],eax
        mov     dword[Flow_vAverageGLogicFPS],eax
        mov     dword[Flow_vAverageGLogicFPS+4],eax
        mov     dword[Flow_vAverageRenderFPS],eax
        mov     dword[Flow_vAverageRenderFPS+4],eax

        .end:
        ret
endp

proc Flow_UpdateFPSCounter c

        locals
                nTicks      dd ?
                nFrames     dd ?
        endl

        push    ebx
        mov     ebx,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup1 = $-4

        .check_enabled:
        cmp     dword[IniFile.NFL.ShowFPSCounter],FALSE
        je      .end

        .check_interval_zero:
        mov     ecx,dword[Flow_nFPSCounterInterval]
        or      ecx,dword[Flow_nFPSCounterInterval+4]
        jnz     .accumulate

        .conv_interval:
        fld     qword[Flow_vFPSCounterInterval]
        fdiv    qword[AccTimer_vToSecsConvMult]
        fistp   qword[Flow_nFPSCounterInterval]

        .save_elapsed:
        mov     eax,dword[Flow_nRenderDeltaTime]
        mov     edx,dword[Flow_nRenderDeltaTime+4]
        mov     dword[Flow_nFPSCounterElapsed],eax
        mov     dword[Flow_nFPSCounterElapsed+4],edx

        .save_counters:
        mov     eax,dword[ebx+34h] ;ptFlow->nTicks
        mov     edx,dword[ebx+38h] ;ptFlow->nFrames
        mov     dword[Flow_nFPSCounterStartTicks],eax
        mov     dword[Flow_nFPSCounterStartFrames],edx

        .init_done:
        jmp     .end

        .accumulate:
        mov     eax,dword[Flow_nRenderDeltaTime]
        mov     edx,dword[Flow_nRenderDeltaTime+4]
        add     dword[Flow_nFPSCounterElapsed],eax
        adc     dword[Flow_nFPSCounterElapsed+4],edx

        .check_interval:
        mov     eax,dword[Flow_nFPSCounterElapsed]
        mov     edx,dword[Flow_nFPSCounterElapsed+4]
        sub     eax,dword[Flow_nFPSCounterInterval]
        sbb     edx,dword[Flow_nFPSCounterInterval+4]
        jc      .end

        .calc_ticks:
        mov     ecx,dword[ebx+34h] ;ptFlow->nTicks
        sub     ecx,dword[Flow_nFPSCounterStartTicks]
        mov     dword[nTicks],ecx

        .calc_frames:
        mov     ecx,dword[ebx+38h] ;ptFlow->nFrames
        sub     ecx,dword[Flow_nFPSCounterStartFrames]
        mov     dword[nFrames],ecx

        .calc_avg_glogic_fps:
        fild    dword[nTicks]
        fild    qword[Flow_nFPSCounterElapsed]
        fmul    qword[AccTimer_vToSecsConvMult]
        fdivp   st1,st0
        fstp    qword[Flow_vAverageGLogicFPS]

        .calc_avg_render_fps:
        fild    dword[nFrames]
        fild    qword[Flow_nFPSCounterElapsed]
        fmul    qword[AccTimer_vToSecsConvMult]
        fdivp   st1,st0
        fstp    qword[Flow_vAverageRenderFPS]

        .set_next_interval:
        ;mov     dword[Flow_nFPSCounterElapsed],eax
        ;mov     dword[Flow_nFPSCounterElapsed+4],edx
        mov     eax,dword[ebx+34h] ;ptFlow->nTicks
        mov     ecx,dword[ebx+38h] ;ptFlow->nFrames
        xor     edx,edx
        mov     dword[Flow_nFPSCounterStartTicks],eax
        mov     dword[Flow_nFPSCounterStartFrames],ecx
        mov     dword[Flow_nFPSCounterElapsed],edx
        mov     dword[Flow_nFPSCounterElapsed+4],edx

        .end:
        pop     ebx
        ret
endp

proc Flow_PrintFPSCounter c

        .check_enabled:
        cmp     dword[IniFile.NFL.ShowFPSCounter],FALSE
        je      .end

        .print_avg_glogic_fps:
        ccall   DebugText_printf_NEW,cstrGLogicFPSCounter,dword[Flow_vAverageGLogicFPS],dword[Flow_vAverageGLogicFPS+4]

        .print_avg_render_fps:
        ccall   DebugText_printf_NEW,cstrRenderFPSCounter,dword[Flow_vAverageRenderFPS],dword[Flow_vAverageRenderFPS+4]

        .end:
        ret
endp

proc Flow_CalcAnimsInterpTime c ; TODO: add accumulator for precise durations

        ;fld     dword[Flow_vCurrentRenderFPS]
        ;fdivr   dword[PATCH_TEMP_ADDR] ;flt_534B14 - 4800.0
        ;.fixup1 = $-4
        ;fstp    dword[AnimController_vInterpTimeStep]
        ret
endp

proc Flow_CalcDrawDeltaTime c

        locals
                nTempValue rq 1
        endl

        mov     eax,dword[Flow_nRenderLastTime]
        mov     edx,dword[Flow_nRenderLastTime+4]
        sub     eax,dword[Flow_nGLogicLastTime]
        sbb     edx,dword[Flow_nGLogicLastTime+4]
        mov     dword[nTempValue],eax
        mov     dword[nTempValue+4],edx
        fild    qword[nTempValue]
        fstp    qword[Flow_vDrawDeltaTime]
        ret
endp

proc Flow_SuspendTiming_NEW c

        cmp     dword[Flow_nSuspendRefCount],0
        jne     .end
        ccall   AccTimer_Read
        mov     dword[Flow_nSuspendTime],eax
        mov     dword[Flow_nSuspendTime+4],edx
        .end:
        inc     dword[Flow_nSuspendRefCount]
        ret
endp

proc Flow_ResumeTiming_NEW c

        dec     dword[Flow_nSuspendRefCount]
        jnz     .end
        ccall   AccTimer_Read
        sub     eax,dword[Flow_nSuspendTime]
        sbb     edx,dword[Flow_nSuspendTime+4]
        add     dword[Flow_nSkipTime],eax
        adc     dword[Flow_nSkipTime+4],edx
        mov     dword[Flow_nSuspendTime],0
        mov     dword[Flow_nSuspendTime+4],0
        .end:
        ret
endp

proc Flow_GetDrawInterpolateQTaskEvent c

        .get:
        mov     eax,dword[Flow_eDrawInterpolateQTaskEvent]

        .end:
        ret
endp

proc Flow_GetDrawInterpolateQTaskList c

        .get:
        mov     eax,dword[Flow_ptDrawInterpolateQTaskList]

        .end:
        ret
endp

loc_402065: ; Flow_Open

        .alloc_interp_event:
        movzx   eax,word[PATCHER_ADDR_TRAP] ;Flow_eQTaskType:0x00567C7C
        .fixup1 = $-4
        push    eax
        call    near PATCHER_CALL_TRAP ;QTask_NewQTaskEventNoContextFn:0x00401810
        .fixup2 = $-4
        add     esp,1*4
        mov     dword[Flow_eDrawInterpolateQTaskEvent],eax

        .alloc_interp_list:
        push    255
        call    near PATCHER_CALL_TRAP ;QTaskList_New:0x004C1800
        .fixup3 = $-4
        add     esp,1*4
        mov     dword[Flow_ptDrawInterpolateQTaskList],eax

        .end:
        retn    0

loc_4027E0: ; Flow_Close

        .delete_interp_list:
        mov     eax,dword[Flow_ptDrawInterpolateQTaskList]
        push    eax
        call    near PATCHER_CALL_TRAP ;QTaskList_Delete:0x004C1830
        .fixup1 = $-4
        add     esp,1*4

        .delete_interp_event:
        mov     eax,dword[Flow_eDrawInterpolateQTaskEvent]
        push    eax
        call    near PATCHER_CALL_TRAP ;QTask_DeleteQTaskEventNoContext:0x004018E0
        .fixup2 = $-4
        add     esp,1*4

        .delete_task:
        movzx   eax,word[PATCHER_ADDR_TRAP] ;Flow_eQTaskType:0x00567C7C
        .fixup3 = $-4
        push    eax
        call    near PATCHER_CALL_TRAP ;QTask_DeleteQTaskType:0x00401A20
        .fixup4 = $-4
        add     esp,1*4

        .end:
        retn    0

loc_424C08: ; Cursor_Open

        .link_interp_event:
        mov     eax,dword[Flow_eDrawInterpolateQTaskEvent]
        movzx   ecx,word[PATCHER_ADDR_TRAP] ;Cursor_eQTaskType:0x0057BC60
        .fixup1 = $-4
        push    Cursor_DrawInterpolateHandler
        push    eax
        push    ecx
        call    near PATCHER_CALL_TRAP ;QTask_LinkQTaskEventHandlerNoContextFn:0x00401530
        .fixup2 = $-4
        add     esp,3*4

        .end:
        retn    0

proc Cursor_DrawInterpolateHandler c ptCursor

        mov     eax,dword[ptCursor]

        .check_patch:
        cmp     dword[IniFile.Modules.MouseCursorPatch],FALSE
        je      .call_run_handler

        .update_pos:
        ccall   Cursor_UpdatePosition,eax
        ret

        .call_run_handler: ; interp check is injected inside
        push    eax
        call    near PATCHER_CALL_TRAP ;Cursor_RunHandler:0x00424CE0
        .fixup1 = $-4
        add     esp,1*4
        ret
endp

loc_424DEA: ; Cursor_RunHandler

        mov     dword[esi+28h],eax ;ptCursor->nY

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        jne     .back

        .end:
        pop     edi esi
        add     esp,8
        retn    0

        .back:
        mov     edx,dword[esi+3Ch] ;ptCursor->isButtonDown
        jmp     near PATCHER_JUMP_TRAP ;loc_424DF0
        .fixup1 = $-4

loc_424C3B: ; Cursor_CreateHandler

        mov     dword[eax+3Ch],ecx ;ptCursor->isButtonDown

        .reg_interp_list:
        push    eax ; eax = ptCursor
        push    dword[Flow_ptDrawInterpolateQTaskList]
        call    near PATCHER_CALL_TRAP ;QTaskList_Register:0x004C1790
        .fixup1 = $-4
        add     esp,2*4

        .end:
        retn    0

proc Cursor_DeleteHandler_NEW c ptCursor

        mov     eax,dword[ptCursor]

        .unreg_interp_list:
        push    eax
        push    dword[Flow_ptDrawInterpolateQTaskList]
        call    near PATCHER_CALL_TRAP ;QTaskList_Remove:0x004C17C0
        .fixup1 = $-4
        add     esp,2*4

        .end:
        ret
endp

loc_41006B: ; HumanPlayer_Open

        add     esp,2*4

        .link_interp_event:
        mov     eax,dword[Flow_eDrawInterpolateQTaskEvent]
        movzx   ecx,word[PATCHER_ADDR_TRAP] ;HumanPlayer_eQTaskType:0x005385B0
        .fixup1 = $-4
        push    HumanPlayer_DrawInterpolateHandler
        push    eax
        push    ecx
        call    near PATCHER_CALL_TRAP ;QTask_LinkQTaskEventHandlerNoContextFn:0x00401530
        .fixup2 = $-4
        add     esp,3*4

        .end:
        retn    0

proc HumanPlayer_DrawInterpolateHandler c ptHumanPlayer

        push    ebx
        mov     ebx,dword[ptHumanPlayer]

        .human_update_body:
        push    ebx
        call    near PATCHER_CALL_TRAP ;Human_UpdateBody:0x004610C0
        .fixup1 = $-4
        add     esp,1*4

        .humanview_update_view:
        mov     eax,dword[ebx+4ECh] ;ptHumanPlayer->tHuman.ptHumanViewQTask
        push    ebx
        push    eax
        call    near PATCHER_CALL_TRAP ;HumanView_UpdateView:0x00464800
        .fixup2 = $-4
        add     esp,2*4

        .humanview_update_body:
        mov     eax,dword[ebx+4ECh] ;ptHumanPlayer->tHuman.ptHumanViewQTask
        push    ebx
        push    eax
        call    near PATCHER_CALL_TRAP ;HumanView_UpdateBody:0x00464BD0
        .fixup3 = $-4
        add     esp,2*4

        .end:
        pop     ebx
        ret
endp

loc_482642: ; HumanCamera_Open

        .link_interp_event:
        mov     eax,dword[Flow_eDrawInterpolateQTaskEvent]
        movzx   ecx,word[PATCHER_ADDR_TRAP] ;HumanCamera_eQTaskType:0x00540990
        .fixup1 = $-4
        push    HumanCamera_DrawInterpolateHandler
        push    eax
        push    ecx
        call    near PATCHER_CALL_TRAP ;QTask_LinkQTaskEventHandlerNoContextFn:0x00401530
        .fixup2 = $-4
        add     esp,3*4

        .end:
        retn    0

proc HumanCamera_DrawInterpolateHandler c ptHumanCamera

        push    esi edi
        mov     esi,dword[ptHumanCamera]
        xor     edi,edi ;ptTask

        .check_paused:
        ccall   Game_IsPaused
        test    eax,eax
        jnz     .end

        .get_human_taskref:
        mov     eax,dword[esi+68h] ;ptHumanCamera->ptHumanQTaskRef
        test    eax,eax
        jz      .draw_interp_humancamera
        .get_human_task:
        ;mov     edi,dword[eax+8] ptHumanCamera->ptHumanQTaskRef->pxObject
        mov     edi,dword[eax] ; ; igi 1 seems to use this pointer instead
        .check_human_task:
        test    edi,edi
        jz      .draw_interp_humancamera
        .draw_interp_human:
        mov     ecx,dword[Flow_eDrawInterpolateQTaskEvent]
        imul    ecx,384
        movzx   eax,word[edi+1Ch] ;ptTask->eQTaskType
        add     eax,ecx
        mov     edx,dword[PATCHER_ADDR_TRAP+eax*4] ;QTask_aatQTaskFinalEvent:0x00A96AE0
        .fixup1 = $-4
        test    edx,edx
        jz      .draw_interp_humancamera
        ccall   edx,edi

        .draw_interp_humancamera:
        movzx   eax,word[esi+1Ch] ;ptHumanCamera->tQTask.eQTaskType
        add     eax,384
        mov     edx,dword[PATCHER_ADDR_TRAP+eax*4] ;QTask_aatQTaskFinalEvent:0x00A96AE0
        .fixup2 = $-4
        ;test    edx,edx
        ;jz      .end
        ccall   edx,esi

        .end:
        pop     edi esi
        ret
endp

loc_4826F5: ; HumanCamera_CreateHandler

        .reg_interp_list:
        push    eax ; eax = ptHumanCamera
        push    dword[Flow_ptDrawInterpolateQTaskList]
        call    near PATCHER_CALL_TRAP ;QTaskList_Register:0x004C1790
        .fixup1 = $-4
        add     esp,2*4

        .end:
        retn    0

loc_484CEB: ; HumanCamera_DeleteHandler

        .unreg_interp_list:
        push    eax ; eax = ptHumanCamera
        push    dword[Flow_ptDrawInterpolateQTaskList]
        call    near PATCHER_CALL_TRAP ;QTaskList_Remove:0x004C17C0
        .fixup1 = $-4
        add     esp,2*4

        .end:
        retn    0

loc_474186: ; StationaryGun_Open

        .link_interp_event:
        mov     eax,dword[Flow_eDrawInterpolateQTaskEvent]
        movzx   ecx,word[PATCHER_ADDR_TRAP] ;StationaryGun_eQTaskType:0x005BE388
        .fixup1 = $-4
        push    StationaryGun_DrawInterpolateHandler
        push    eax
        push    ecx
        call    near PATCHER_CALL_TRAP ;QTask_LinkQTaskEventHandlerNoContextFn:0x00401530
        .fixup2 = $-4
        add     esp,3*4

        .end:
        retn    0

proc StationaryGun_DrawInterpolateHandler c ptStationaryGun

        ; TODO

        .end:
        ret
endp

loc_473EB8: ; StationaryGun_CreateHandler

        mov     dword[ebp+1E8h],90.0

        .reg_interp_list:
        push    ebp ; ebp = ptStationaryGun
        push    dword[Flow_ptDrawInterpolateQTaskList]
        call    near PATCHER_CALL_TRAP ;QTaskList_Register:0x004C1790
        .fixup1 = $-4
        add     esp,2*4

        .end:
        pop     edi esi ebp ebx
        retn    0

loc_47497B: ; StationaryGun_DeleteHandler

        add     esp,10h

        .unreg_interp_list:
        push    esi ; esi = ptStationaryGun
        push    dword[Flow_ptDrawInterpolateQTaskList]
        call    near PATCHER_CALL_TRAP ;QTaskList_Remove:0x004C17C0
        .fixup1 = $-4
        add     esp,2*4

        .end:
        pop     esi
        retn    0

loc_474195: ; StationaryGun_RunHandler

        .get_human_ptr:
        mov     eax,dword[esi+208h] ;ptStationaryGun->ptHumanQTask
        test    eax,eax
        jz      .back

        .is_human_player:
        mov     cx,word[PATCHER_ADDR_TRAP] ;HumanPlayer_eQTaskType:0x005385B0
        .fixup1 = $-4
        cmp     cx,word[eax+1Ch] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tQTask.eQTaskType
        jne     .back

        .set_used:
        or      dword[StationaryGun_isUsedByPlayer],TRUE

        .back:
        call    near PATCHER_CALL_TRAP ;Flow_GetTicks:0x004028B0
        .fixup2 = $-4
        jmp     near PATCHER_JUMP_TRAP ;loc_47419A
        .fixup3 = $-4

loc_4719D3: ; VUMeter_Update

        .ptVUMeter = 4

        .check_1st_frame:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup1 = $-4
        cmp     dword[eax+44h],0 ;ptFlow->nFramesSinceLastTick
        je      .back

        .end:
        add     esp,8
        retn    0

        .back:
        push    esi
        mov     esi,dword[esp+0Ch+.ptVUMeter]
        jmp     near PATCHER_JUMP_TRAP ;loc_4719D8
        .fixup2 = $-4

HumanView_GetUBRandomState:

        .get:
        mov     eax,HumanView_anUBRandomState

        .end:
        retn    0

HumanView_SetUBRandomState:

        .ptRandomState = 4

        mov     edx,dword[esp+.ptRandomState]

        .save:
        mov     eax,dword[edx]
        mov     ecx,dword[edx+4]
        mov     edx,dword[edx+8]
        mov     dword[HumanView_anUBRandomState],eax
        mov     dword[HumanView_anUBRandomState+4],ecx
        mov     dword[HumanView_anUBRandomState+8],edx

        .end:
        retn    0

loc_464C28: ; HumanView_UpdateBody

        .get_state: ; gets seed from current tick
        call    near PATCHER_CALL_TRAP ;Game_GetRandomState:0x00416D20
        .fixup1 = $-4

        .save_state:
        ccall   HumanView_SetUBRandomState,eax

        .back:
        fld     dword[ebp+1B4h]
        jmp     near PATCHER_JUMP_TRAP ;loc_464C2E
        .fixup2 = $-4

loc_464D72: ; HumanView_UpdateBody

        .check_interp:
        call    Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .interp_off

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        jne     .back

        .calc_scaled_shake_time:
        mov     ecx,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup1 = $-4
        fild    qword[Flow_nRenderDeltaTime]
        fmul    qword[AccTimer_vToSecsConvMult]
        fimul   dword[ecx+3Ch] ;ptFlow->nFrequency
        fmul    dword[ebp+1C0h] ;ptHumanView->vShakeTime

        .check_scaled_shake_time:
        fld     dword[ebp+1B4h] ;ptHumanView->vShakeFactor
        ftst
        fnstsw  ax
        test    ah,1
        jnz     .neg_shake_decay
        test    ah,40h
        jnz     .pop_fpu

        .pos_shake_decay:
        fsub    st0,st1
        fst     dword[ebp+1B4h] ;ptHumanView->vShakeFactor
        ftst
        fnstsw  ax
        test    ah,1
        jz      .pop_fpu
        mov     dword[ebp+1B4h],0 ;ptHumanView->vShakeFactor
        jmp     .pop_fpu

        .neg_shake_decay:
        fadd    st0,st1
        fst     dword[ebp+1B4h] ;ptHumanView->vShakeFactor
        ftst
        fnstsw  ax
        test    ah,1
        jnz     .pop_fpu
        mov     dword[ebp+1B4h],0 ;ptHumanView->vShakeFactor

        .pop_fpu:
        fstp    st0
        fstp    st0

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_464DE2
        .fixup2 = $-4

        .interp_off:
        fld     dword[ebp+1B4h]
        jmp     near PATCHER_JUMP_TRAP ;loc_464D78
        .fixup3 = $-4

loc_464E1B: ; HumanView_UpdateBody

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .interp_off

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        jne     .skip

        .interp_on:

        .calc_impact:
        fild    qword[Flow_nRenderDeltaTime]
        fmul    qword[AccTimer_vToSecsConvMult]
        fmul    dword[PATCHER_ADDR_TRAP] ;flt_5334A8:0x005334A8 -> 6.2831855
        .fixup1 = $-4
        fadd    dword[ebp+1C8h] ;ptHumanView->vImpactAngle
        fst     dword[ebp+1C8h] ;ptHumanView->vImpactAngle

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_464E2D
        .fixup2 = $-4

        .skip:
        fld     dword[ebp+1C8h] ;ptHumanView->vImpactAngle
        jmp     near PATCHER_JUMP_TRAP ;loc_464E2D
        .fixup3 = $-4

        .interp_off:
        fld     dword[ebp+1C8h] ;ptHumanView->vImpactAngle
        jmp     near PATCHER_JUMP_TRAP ;loc_464E21
        .fixup4 = $-4

loc_465102: ; HumanView_UpdateBody

        .vScaledStep = -10Ch

        .check_interp:
        call    Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .interp_off

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        jne     .back

        .check_retract_ideal:
        fld     dword[ebp+320h] ;ptHumanView->vRetractIdeal
        ftst
        fnstsw  ax
        fstp    st0
        test    ah,40h
        jz      .hitting_wall

        .returning_normal:
        fld     dword[PATCHER_ADDR_TRAP] ;flt_5339D8:0x005339D8 -> 75.851852f
        .fixup1 = $-4
        jmp     .calc_scaled_step

        .hitting_wall:
        fld     dword[PATCHER_ADDR_TRAP] ;flt_5339D4:0x005339D4 -> 113.77778f
        .fixup2 = $-4

        .calc_scaled_step:
        mov     ecx,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup3 = $-4
        fild    qword[Flow_nRenderDeltaTime]
        fmul    qword[AccTimer_vToSecsConvMult]
        fimul   dword[ecx+3Ch] ;ptFlow->nFrequency
        fmulp   st1,st0
        fstp    dword[esp+140h+.vScaledStep]

        .cmp_ideal_vs_real:
        fld     dword[ebp+324h] ;ptHumanView->vRetractReal
        fld     dword[ebp+320h] ;ptHumanView->vRetractIdeal
        fcom    st1
        fnstsw  ax
        sahf
        je      .fpu_pop
        jb      .step_down

        .step_up:
        fxch    st1
        fadd    dword[esp+140h+.vScaledStep]
        fcom    st1
        fnstsw  ax
        sahf
        jbe     .fpu_pop
        fstp    st0
        fld     st0
        jmp     .fpu_pop

        .step_down:
        fxch    st1
        fsub    dword[esp+140h+.vScaledStep]
        fcom    st1
        fnstsw  ax
        sahf
        jae     .fpu_pop
        fstp    st0
        fld     st0

        .fpu_pop:
        fstp    dword[ebp+324h] ;ptHumanView->vRetractReal
        fstp    st0

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4651F8
        .fixup4 = $-4

        .interp_off:
        fld     dword[ebp+320h] ;ptHumanView->vRetractIdeal
        jmp     near PATCHER_JUMP_TRAP ;loc_465108
        .fixup5 = $-4

loc_465251: ; HumanView_UpdateBody

        .check_interp:
        call    Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .interp_off

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        jne     .back

        .interp_on:
        mov     ecx,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup1 = $-4
        fild    qword[Flow_nRenderDeltaTime]
        fmul    qword[AccTimer_vToSecsConvMult]
        fimul   dword[ecx+3Ch] ;ptFlow->nFrequency

        .check_alpha:
        fld     dword[ebp+1CCh] ;ptHumanView->vObjectAlpha
        fcomp   dword[ebp+1D0h] ;ptHumanView->vIdealObjectAlpha
        fnstsw  ax
        test    ah,1
        jz      .check_alpha_sub

        .add_scaled_alpha:
        fld     dword[ebp+1D4h] ;ptHumanView->vStepAlpha
        fmul    st0,st1
        fadd    dword[ebp+1CCh] ;ptHumanView->vObjectAlpha
        fstp    dword[ebp+1CCh] ; ptHumanView->vObjectAlpha += ptHumanView->vStepAlpha * vScale
        
        .check_scaled_alpha:
        fld     dword[ebp+1CCh] ;ptHumanView->vObjectAlpha
        fcomp   dword[ebp+1D0h] ;ptHumanView->vIdealObjectAlpha
        fnstsw  ax
        test    ah,41h
        jnz     .check_gamma
        mov     ecx,dword[ebp+1D0h] ;ptHumanView->vIdealObjectAlpha
        mov     dword[ebp+1CCh],ecx ;ptHumanView->vObjectAlpha
        jmp     .check_gamma

        .check_alpha_sub:
        test    ah,41h
        jnz     .check_gamma
        fld     dword[ebp+1D4h] ;ptHumanView->vStepAlpha
        fmul    st0,st1
        fsubr   dword[ebp+1CCh] ;ptHumanView->vObjectAlpha
        fstp    dword[ebp+1CCh] ;ptHumanView->vObjectAlpha
        
        .check_scaled_alpha_sub:
        fld     dword[ebp+1CCh] ;ptHumanView->vObjectAlpha
        fcomp   dword[ebp+1D0h] ;ptHumanView->vIdealObjectAlpha
        fnstsw  ax
        test    ah,1
        jz      .check_gamma
        mov     edx,dword[ebp+1D0h] ;ptHumanView->vIdealObjectAlpha
        mov     dword[ebp+1CCh],edx ;ptHumanView->vObjectAlpha

        .check_gamma:
        fld     dword[ebp+1D8h] ;ptHumanView->vObjectGamma
        fcomp   dword[ebp+1DCh] ;ptHumanView->vIdealObjectGamma
        fnstsw  ax
        test    ah,1
        jz      .check_gamma_sub

        .add_scaled_gamma:
        fld     dword[ebp+1E0h] ;ptHumanView->vStepGamma
        fmul    st0,st1
        fadd    dword[ebp+1D8h] ;ptHumanView->vObjectGamma
        fstp    dword[ebp+1D8h] ; ptHumanView->vObjectGamma += ptHumanView->vStepGamma * vScale

        .check_scaled_gamma:
        fld     dword[ebp+1D8h] ;ptHumanView->vObjectGamma
        fcomp   dword[ebp+1DCh] ;ptHumanView->vIdealObjectGamma
        fnstsw  ax
        test    ah,41h
        jnz     .pop_fpu
        mov     eax,dword[ebp+1DCh] ;ptHumanView->vIdealObjectGamma
        mov     dword[ebp+1D8h],eax ;ptHumanView->vObjectGamma
        jmp     .pop_fpu

        .check_gamma_sub:
        test    ah,41h
        jnz     .pop_fpu
        fld     dword[ebp+1E0h] ;ptHumanView->vStepGamma
        fmul    st0,st1
        fsubr   dword[ebp+1D8h] ;ptHumanView->vObjectGamma
        fstp    dword[ebp+1D8h] ;ptHumanView->vObjectGamma
        
        .check_scaled_gamma_sub:
        fld     dword[ebp+1D8h] ;ptHumanView->vObjectGamma
        fcomp   dword[ebp+1DCh] ;ptHumanView->vIdealObjectGamma
        fnstsw  ax
        test    ah,1
        jz      .pop_fpu
        mov     ecx,dword[ebp+1DCh] ;ptHumanView->vIdealObjectGamma
        mov     dword[ebp+1D8h],ecx ;ptHumanView->vObjectGamma

        .pop_fpu:
        fstp    st0

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_46534D
        .fixup2 = $-4

        .interp_off:
        fld     dword[ebp+1CCh] ;ptHumanView->vObjectAlpha
        jmp     near PATCHER_JUMP_TRAP ;loc_465257
        .fixup3 = $-4

loc_46553F: ; HumanView_UpdateBody

        add     esp,3*4

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        je      near PATCHER_JUMP_TRAP ;loc_46560D
        .fixup1 = $-4

        .back:
        lea     ecx,[ebp+208h]
        jmp     near PATCHER_JUMP_TRAP ;loc_465545
        .fixup2 = $-4


loc_46491B: ; HumanView_UpdateView

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        je      near PATCHER_JUMP_TRAP ;loc_464989
        .fixup1 = $-4

        .back:
        fld     dword[esi+1F0h] ;ptHuman->avChannel[16]
        jmp     near PATCHER_JUMP_TRAP ;loc_464921
        .fixup2 = $-4

loc_45FD58: ; Human_GetHumanCameraInfoHandler

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        je      near PATCHER_JUMP_TRAP ;loc_45FD85
        .fixup1 = $-4

        .back:
        fld     dword[edx+1FCh] ;ptHuman->avChannel[19]
        jmp     near PATCHER_JUMP_TRAP ;loc_45FD5E
        .fixup2 = $-4

loc_460C80: ; Human_printf

        .ptHuman = 4

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_RUN
        je      .back

        .check_1st_frame:
        mov     ecx,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup1 = $-4
        cmp     dword[ecx+44h],0 ;ptFlow->nFramesSinceLastTick
        jne     .end

        .back:
        mov     eax,dword[esp+.ptHuman]
        push    eax
        jmp     near PATCHER_JUMP_TRAP ;loc_460C85
        .fixup2 = $-4

        .end:
        retn    0

loc_482C31: ;HumanCamera_ThirdPersonControlInput

        .ptHumanCamera = 4

        mov     esi,dword[esp+4+.ptHumanCamera]

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        je      .end

        .back:
        push    0x49 ;DIK_NUMPAD9
        call    near PATCHER_CALL_TRAP ;GameFunctions_IsDebugKeyPressed:0x00414FD0
        .fixup1 = $-4
        add     esp,1*4
        jmp     near PATCHER_JUMP_TRAP ;loc_482C3F
        .fixup2 = $-4

        .end:
        pop     esi
        retn    0

loc_483415: ;HumanCamera_MovementControlInput

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        je      near PATCHER_JUMP_TRAP ;loc_483455
        .fixup1 = $-4

        .back:
        push    0x49 ;DIK_NUMPAD9
        call    near PATCHER_CALL_TRAP ;GameFunctions_IsDebugKeyPressed:0x00414FD0
        .fixup2 = $-4
        add     esp,1*4
        jmp     near PATCHER_JUMP_TRAP ;loc_48341F
        .fixup3 = $-4

loc_483E17: ;HumanCamera_MovementControlInput

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        je      near PATCHER_JUMP_TRAP ;loc_483E57
        .fixup1 = $-4

        .back:
        push    0x49 ;DIK_NUMPAD9
        call    near PATCHER_CALL_TRAP ;GameFunctions_IsDebugKeyPressed:0x00414FD0
        .fixup2 = $-4
        add     esp,1*4
        jmp     near PATCHER_JUMP_TRAP ;loc_483E21
        .fixup3 = $-4

loc_4828D0: ;HumanCamera_ControlListInput

        .check_phase:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        je      .end

        .back:
        push    0x10 ;DIK_Q
        call    near PATCHER_CALL_TRAP ;GameFunctions_IsDebugKeyPressedOnce:0x00415020
        .fixup1 = $-4
        add     esp,1*4
        jmp     near PATCHER_JUMP_TRAP ;loc_4828DA
        .fixup2 = $-4

        .end:
        retn    0

proc Flow_GetDrawDeltaTime c

        .check_stuff:
        ccall   Game_IsPaused
        test    eax,eax
        jnz     .zero

        .get:
        fld     qword[Flow_vDrawDeltaTime]
        ret

        .zero:
        fldz
        ret
endp

proc DynCubeObj_AllocInterpData c ptDynCubeObj

        push    ebx
        mov     ebx,dword[ptDynCubeObj]

        .alloc_interp_data:
        push    4
        push    sizeof.DynCubeObjInterpData_s
        call    near PATCHER_CALL_TRAP ;Mem_AllocFn:0x004B0C60
        .fixup1 = $-4
        add     esp,2*4
        mov     dword[ebx+64h],eax ;ptDynCubeObj.ptInterpData

        .init_interp_data:
        mov     dword[eax+DynCubeObjInterpData_s.nTicks],0

        .end:
        pop     ebx
        ret
endp

proc DynCubeObj_DeallocInterpData c ptDynCubeObj

        push    ebx
        mov     ebx,dword[ptDynCubeObj]

        .check_allocated:
        mov     eax,dword[ebx+64h] ;ptDynCubeObj.ptInterpData
        test    eax,eax
        jz      .end

        .dealloc_interp_data:
        push    eax
        call    near PATCHER_CALL_TRAP ;Mem_DeAllocFn:0x004B0D10
        .fixup1 = $-4
        add     esp,1*4
        mov     dword[ebx+64h],NULL ;ptDynCubeObj.ptInterpData

        .end:
        pop     ebx
        ret
endp

proc DynCubeObj_UpdateInterpData c ptDynCubeObj

        push    esi edi
        mov     esi,dword[ptDynCubeObj]
        mov     edi,dword[esi+64h] ;ptDynCubeObj.ptInterpData

        .update_interp_data:
        mov     eax,dword[esi+20h] ;ptDynCubeObj.tQObj.tPos.vX
        mov     ecx,dword[esi+20h+8] ;ptDynCubeObj.tQObj.tPos.vY
        mov     edx,dword[esi+20h+10h] ;ptDynCubeObj.tPos.vZ
        mov     dword[edi+DynCubeObjInterpData_s.tOldPos.vX],eax
        mov     dword[edi+DynCubeObjInterpData_s.tOldPos.vY],ecx
        mov     dword[edi+DynCubeObjInterpData_s.tOldPos.vZ],edx
        mov     eax,dword[esi+20h+4] ;ptDynCubeObj.tQObj.tPos.vX+4
        mov     ecx,dword[esi+20h+8+4] ;ptDynCubeObj.tQObj.tPos.vY+4
        mov     edx,dword[esi+20h+10h+4] ;ptDynCubeObj.tQObj.tPos.vZ+4
        mov     dword[edi+DynCubeObjInterpData_s.tOldPos.vX+4],eax
        mov     dword[edi+DynCubeObjInterpData_s.tOldPos.vY+4],ecx
        mov     dword[edi+DynCubeObjInterpData_s.tOldPos.vZ+4],edx
        inc     dword[edi+DynCubeObjInterpData_s.nTicks]

        .end:
        pop     edi esi
        ret
endp

loc_45ECC0: ; Human_CreateHandler

        .alloc_interp_data:
        ccall   DynCubeObj_AllocInterpData,esi

        .end:
        pop     edi esi ebx
        retn    0

loc_45EFC5: ; Human_DeleteHandler

        .dealloc_interp_data:
        ccall   DynCubeObj_DeallocInterpData,esi

        .end:
        pop     edi esi ebx
        retn    0

loc_45EEA0: ; Human_RunHandler

        .ptHuman = 4

        .update_interp_data:
        ccall   DynCubeObj_UpdateInterpData,dword[esp+.ptHuman]

        .back:
        mov     edx,dword[esp+.ptHuman]
        mov     ecx,32
        jmp     near PATCHER_JUMP_TRAP ;loc_45EEA9
        .fixup1 = $-4

loc_464466: ; HumanView_CreateHandler

        fstp    dword[esi+1E8h]

        .alloc_interp_data:
        ccall   DynCubeObj_AllocInterpData,esi

        .end:
        pop     esi ebx
        retn    0

loc_464470: ; HumanView_DeleteHandler

        .ptHumanView = 4

        push    esi
        mov     esi,dword[esp+4+.ptHumanView]

        .dealloc_interp_data:
        ccall   DynCubeObj_DeallocInterpData,esi

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_464475
        .fixup1 = $-4

HumanView_RunHandler_NEW: ; HumanView_RunHandler

        .ptHumanView = 4

        .update_interp_data:
        ccall   DynCubeObj_UpdateInterpData,dword[esp+.ptHumanView]

        .back:
        mov     eax,dword[esp+.ptHumanView]
        mov     ecx,dword[eax+8]
        jmp     near PATCHER_JUMP_TRAP ;loc_488707
        .fixup1 = $-4

loc_4785E5: ; Gun_CreateHandler

        .alloc_interp_data:
        ccall   DynCubeObj_AllocInterpData,esi

        .end:
        pop     esi ebx
        retn    0

loc_4788C6: ; Gun_DeleteHandler

        .dealloc_interp_data:
        ccall   DynCubeObj_DeallocInterpData,esi

        .end:
        pop     esi
        retn    0

loc_478649: ; Gun_RunHandler

        .update_interp_data:
        ccall   DynCubeObj_UpdateInterpData,esi

        .back:
        mov     eax,dword[esi+144h]
        jmp     near PATCHER_JUMP_TRAP ;loc_47864F
        .fixup1 = $-4

loc_446AAF: ; Door_CreateHandler

        .alloc_interp_data:
        ccall   DynCubeObj_AllocInterpData,ebp

        .end:
        pop     esi ebp ebx
        retn    0

loc_446B49: ; Door_DeleteHandler

        .dealloc_interp_data:
        ccall   DynCubeObj_DeallocInterpData,esi

        .end:
        pop     esi
        retn    0

loc_446D1F: ; Door_RunHandler

        .var_AC = -0ACh

        .update_interp_data:
        ccall   DynCubeObj_UpdateInterpData,ebp

        .back:
        mov     dword[esp+0CCh+.var_AC],0
        jmp     near PATCHER_JUMP_TRAP ;loc_446D27
        .fixup1 = $-4

loc_43D273: ; Elevator_CreateHandler

        .alloc_interp_data:
        ccall   DynCubeObj_AllocInterpData,ebx

        .end:
        pop     esi ebx
        mov     esp,ebp
        pop     ebp
        retn    0

loc_43DD90: ; Elevator_DeleteHandler

        .dealloc_interp_data:
        ccall   DynCubeObj_DeallocInterpData,esi

        .end:
        pop     edi esi ebx
        retn    0

loc_43D28A: ; Elevator_RunHandler

        .update_interp_data:
        ccall   DynCubeObj_UpdateInterpData,ebp

        .back:
        mov     eax,dword[ebp+180h]
        jmp     near PATCHER_JUMP_TRAP ;loc_43D290
        .fixup1 = $-4

loc_4450DD: ; Switch_CreateHandler

        sub     esi,1D0h

        .alloc_interp_data:
        ccall   DynCubeObj_AllocInterpData,esi

        .end:
        pop     esi ebx
        add     esp,18h
        retn    0

loc_4452D1: ; Switch_DeleteHandler

        .dealloc_interp_data:
        ccall   DynCubeObj_DeallocInterpData,esi

        .end:
        pop     esi
        retn    0

loc_4450F4: ; Switch_RunHandler

        .ptSwitch = 4

        push    edi
        mov     esi,dword[esp+10h+.ptSwitch]

        .update_interp_data:
        ccall   DynCubeObj_UpdateInterpData,esi

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4450F9
        .fixup1 = $-4

loc_4782C1: ; GunCasing_CreateHandler

        .alloc_interp_data:
        ccall   DynCubeObj_AllocInterpData,esi

        .end:
        pop     esi
        retn    0

loc_478505: ; GunCasing_DeleteHandler

        .ptGunCasing = 4

        .dealloc_interp_data:
        ccall   DynCubeObj_DeallocInterpData,dword[esp+.ptGunCasing]

        .end:
        retn    0

loc_4782D0: ; GunCasing_RunHandler

        .ptGunCasing = 4

        sub     esp,2Ch

        .update_interp_data:
        ccall   DynCubeObj_UpdateInterpData,dword[esp+2Ch+.ptGunCasing]

        .back:
        mov     eax,dword[esp+2Ch+.ptGunCasing]
        jmp     near PATCHER_JUMP_TRAP ;loc_4782D7
        .fixup1 = $-4

proc QTask_IsRDCOTaskTypeInterpolable c ptQTask ; RigidDynCubeObj

        push    esi edi
        mov     eax,dword[ptQTask]
        movzx   esi,word[eax+1Ch] ;ptQTask.eQTaskType

        .check_gun:
        mov     edi,1
        movzx   ecx,word[PATCHER_ADDR_TRAP] ;Gun_eQTaskType:0x005BE3C6
        .fixup1 = $-4
        cmp     esi,ecx
        je      .yes

        .check_physicsobj:
        mov     edi,2
        movzx   eax,word[PATCHER_ADDR_TRAP] ;PhysicsObj_eQTaskType:0x00A774B0
        .fixup2 = $-4
        push    eax
        push    esi
        call    near PATCHER_CALL_TRAP ;QTask_IsQTaskTypeDerived:0x00401CF0
        .fixup3 = $-4
        add     esp,2*4
        test    al,al
        jnz     .yes

        .check_door:
        mov     edi,3
        movzx   ecx,word[PATCHER_ADDR_TRAP] ;Door_eQTaskType:0x0057C1C0
        .fixup4 = $-4
        cmp     esi,ecx
        je      .yes

        .check_elevator:
        mov     edi,4
        movzx   edx,word[PATCHER_ADDR_TRAP] ;Elevator_eQTaskType:0x0057C108
        .fixup5 = $-4
        cmp     esi,edx
        je      .yes

        .check_switch:
        mov     edi,5
        movzx   eax,word[PATCHER_ADDR_TRAP] ;Switch_eQTaskType:0x0057C1B8
        .fixup6 = $-4
        cmp     esi,eax
        je      .yes

        .check_guncasing:
        mov     edi,6
        movzx   ecx,word[PATCHER_ADDR_TRAP] ;GunCasing_eQTaskType:0x005BE3C4
        .fixup7 = $-4
        cmp     esi,ecx
        je      .yes

        .no:
        xor     eax,eax
        pop     edi esi
        ret

        .yes:
        mov     eax,edi
        pop     edi esi
        ret
endp

proc QTask_IsBDCOTaskTypeInterpolable c ptQTask ; BoneDynCubeObj

        push    esi edi
        mov     eax,dword[ptQTask]
        movzx   esi,word[eax+1Ch] ;ptQTask.eQTaskType

        .check_human:
        mov     edi,1
        movzx   eax,word[PATCHER_ADDR_TRAP] ;Human_eQTaskType:0x005BDAF8
        .fixup1 = $-4
        push    eax
        push    esi
        call    near PATCHER_CALL_TRAP ;QTask_IsQTaskTypeDerived:0x00401CF0
        .fixup2 = $-4
        add     esp,2*4
        test    al,al
        jnz     .yes

        .check_humanview:
        mov     edi,2
        movzx   ecx,word[PATCHER_ADDR_TRAP] ;HumanView_eQTaskType:0x005BDC40
        .fixup3 = $-4
        cmp     esi,ecx
        je      .yes

        .no:
        xor     eax,eax
        pop     edi esi
        ret

        .yes:
        mov     eax,edi
        pop     edi esi
        ret
endp

proc Flow_CalcInterpolatedPosByVel c ptInterpPos,ptPos,ptSpeed

        .check_speed_ptr:
        cmp     dword[ptSpeed],NULL
        je      .no_interp

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .no_interp

        .calc_alpha:
        ccall   Flow_GetDrawDeltaTime
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x083685D8
        .fixup1 = $-4
        fmul    qword[AccTimer_vToSecsConvMult]
        fimul   dword[eax+3Ch] ;Flow_ptFlow->nFrequency
        fsub    dword[FPU_CONSTS.flt_1_0] ; becomes backward linear extrapolation
        ; vAlpha = (vDrawDeltaTimeSecs * vFrequency) - 1.0f;

        .calc_lerp:
        mov     eax,dword[ptSpeed] ; float
        mov     ecx,dword[ptPos] ; double
        mov     edx,dword[ptInterpPos] ; double

        .lerp_posx:
        fld     st0 ;vAlpha
        fmul    dword[eax]
        fadd    qword[ecx]
        fstp    qword[edx] ; ptInterpPos->vX = ptPos->vX + ptSpeed->vX * vAlpha;

        .lerp_posy:
        fld     st0 ;vAlpha
        fmul    dword[eax+4]
        fadd    qword[ecx+8]
        fstp    qword[edx+8] ; ptInterpPos->vY = ptPos->vY + ptSpeed->vY * vAlpha;

        .lerp_posz:
        ;fld     st0 ;vAlpha
        fmul    dword[eax+8]
        fadd    qword[ecx+10h]
        fstp    qword[edx+10h] ; ptInterpPos->vZ = ptPos->vZ + ptSpeed->vZ * vAlpha;

        .ok:
        mov     eax,TRUE
        ret

        .no_interp:
        mov     ecx,dword[ptPos]
        mov     edx,dword[ptInterpPos]
        cmp     ecx,edx
        je      .end

        .copy_pos:
        push    esi edi
        mov     esi,ecx
        mov     edi,edx
        mov     ecx,8*3/4
        rep     movsd
        pop     edi esi

        .end:
        xor     eax,eax
        ret
endp

proc Flow_CalcInterpolatedPosByVel32 c ptInterpPos,ptPos,ptSpeed

        .check_speed_ptr:
        cmp     dword[ptSpeed],NULL
        je      .no_interp

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .no_interp

        .calc_alpha:
        ccall   Flow_GetDrawDeltaTime
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x083685D8
        .fixup1 = $-4
        fmul    qword[AccTimer_vToSecsConvMult]
        fimul   dword[eax+3Ch] ;Flow_ptFlow->nFrequency
        fsub    dword[FPU_CONSTS.flt_1_0] ; backward linear interpolation
        ; vAlpha = (vDrawDeltaTimeSecs * vFrequency) - 1.0f;

        .calc_lerp:
        mov     eax,dword[ptSpeed] ; float
        mov     ecx,dword[ptPos] ; float
        mov     edx,dword[ptInterpPos] ; float

        .lerp_posx:
        fld     st0 ;vAlpha
        fmul    dword[eax]
        fadd    dword[ecx]
        fstp    dword[edx] ; ptInterpPos->vX = ptPos->vX + ptSpeed->vX * vAlpha;

        .lerp_posy:
        fld     st0 ;vAlpha
        fmul    dword[eax+4]
        fadd    dword[ecx+4]
        fstp    dword[edx+4] ; ptInterpPos->vY = ptPos->vY + ptSpeed->vY * vAlpha;

        .lerp_posz:
        ;fld     st0 ;vAlpha
        fmul    dword[eax+8]
        fadd    dword[ecx+8]
        fstp    dword[edx+8] ; ptInterpPos->vZ = ptPos->vZ + ptSpeed->vZ * vAlpha;

        .ok:
        mov     eax,TRUE
        ret

        .no_interp:
        mov     ecx,dword[ptPos]
        mov     edx,dword[ptInterpPos]
        cmp     ecx,edx
        je      .end

        .copy_pos:
        push    esi edi
        mov     esi,ecx
        mov     edi,edx
        mov     ecx,4*3/4
        rep     movsd
        pop     edi esi

        .end:
        xor     eax,eax
        ret
endp

proc Flow_CalcInterpolatedPos c ptInterpPos,ptCurPos,ptOldPos,IsSkipInterp

        .check_skip:
        cmp     dword[IsSkipInterp],FALSE
        jne     .no_interp

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .no_interp

        .calc_alpha:
        ccall   Flow_GetDrawDeltaTime
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow
        .fixup1 = $-4
        fmul    qword[AccTimer_vToSecsConvMult]
        fimul   dword[eax+3Ch] ;Flow_ptFlow->nFrequency
        ; vAlpha = vDrawDeltaTimeSecs * vFrequency;

        .calc_lerp:
        mov     eax,dword[ptOldPos] ; double
        mov     ecx,dword[ptCurPos] ; double
        mov     edx,dword[ptInterpPos] ; double

        .lerp_posx:
        fld     qword[ecx]
        fsub    qword[eax]
        fmul    st0,st1
        fadd    qword[eax]
        fstp    qword[edx] ; ptInterpPos->vX = ptOldPos->vX + (ptCurPos->vX - ptOldPos->vX) * vAlpha;

        .lerp_posy:
        fld     qword[ecx+8]
        fsub    qword[eax+8]
        fmul    st0,st1
        fadd    qword[eax+8]
        fstp    qword[edx+8] ; ptInterpPos->vY = ptOldPos->vY + (ptCurPos->vY - ptOldPos->vY) * vAlpha;

        .lerp_posz:
        fld     qword[ecx+10h]
        fsub    qword[eax+10h]
        fmulp   st1,st0
        fadd    qword[eax+10h]
        fstp    qword[edx+10h] ; ptInterpPos->vZ = ptOldPos->vZ + (ptCurPos->vZ - ptOldPos->vZ) * vAlpha;

        .ok:
        mov     eax,TRUE
        ret

        .no_interp:
        mov     ecx,dword[ptCurPos]
        mov     edx,dword[ptInterpPos]
        cmp     ecx,edx
        je      .end

        .copy_pos:
        push    esi edi
        mov     esi,ecx
        mov     edi,edx
        mov     ecx,8*3/4
        rep     movsd
        pop     edi esi

        .end:
        xor     eax,eax
        ret
endp

loc_4E7F50: ; ViewportQTask_DrawHandler

        .tCameraPos = -0E8h
        .tCameraOldPos = -0A8h
        .IsSkipInterp = -0A8h+8*3

        mov     esi,eax ; esi = ptQCamera

        .set_skip_interp:
        mov     dword[esp+118h+.IsSkipInterp],TRUE

        .is_task_set:
        mov     eax,dword[esi+54h] ;ptQCamera->ptSetCameraQTask
        test    eax,eax
        jz      .calc_interp_pos

        .is_human_camera:
        mov     cx,word[PATCHER_ADDR_TRAP] ;HumanCamera_eQTaskType:0x00540990
        .fixup1 = $-4
        cmp     cx,word[eax+1Ch] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tQTask.eQTaskType
        jne     .calc_interp_pos

        .get_human_taskref:
        mov     edi,dword[eax+68h] ;ptHumanCamera->ptHumanQTaskRef
        test    edi,edi
        jz      .calc_interp_pos
        .get_human_task:
        ;mov     edi,dword[edi+8] ;ptHumanCamera->ptHumanQTaskRef->pxObject
        mov     edi,dword[edi] ; igi 1 seems to use this pointer instead
        test    edi,edi
        jz      .calc_interp_pos

        .check_cam_changed:
        mov     edx,dword[ebx+50h]
        cmp     edx,dword[ViewportQTask_ptLastSetQCamera]
        jne     .calc_interp_pos

        .check_ticks:
        mov     eax,dword[edi+64h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.ptInterpData
        cmp     dword[eax+DynCubeObjInterpData_s.nTicks],1
        jb      .calc_interp_pos

        .calc_camera_oldpos:
        fld     qword[esi+28h] ;ptQCamera->tPos.vX
        fadd    qword[eax+DynCubeObjInterpData_s.tOldPos.vX]
        fsub    qword[edi+20h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vX
        fstp    qword[esp+118h+.tCameraOldPos]
        fld     qword[esi+28h+8] ;ptQCamera->tPos.vY
        fadd    qword[eax+DynCubeObjInterpData_s.tOldPos.vY]
        fsub    qword[edi+20h+8] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vY
        fstp    qword[esp+118h+.tCameraOldPos+8]
        fld     qword[esi+28h+10h] ;ptQCamera->tPos.vZ
        fadd    qword[eax+DynCubeObjInterpData_s.tOldPos.vZ]
        fsub    qword[edi+20h+10h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vZ
        fstp    qword[esp+118h+.tCameraOldPos+10h]
        mov     dword[esp+118h+.IsSkipInterp],FALSE

        .calc_interp_pos:
        lea     eax,[esp+118h+.tCameraPos]
        lea     ecx,[esi+28h] ;&ptQCamera->tPos
        lea     edx,[esp+118h+.tCameraOldPos]
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,dword[esp+118h+.IsSkipInterp]

        .set_last_cam:
        mov     ecx,dword[ebx+50h]
        mov     dword[ViewportQTask_ptLastSetQCamera],ecx

        .back:
        mov     eax,esi
        lea     edx,[esp+118h+.tCameraPos]
        jmp     near PATCHER_JUMP_TRAP ;loc_4E7F62
        .fixup2 = $-4

loc_4644EE: ; HumanView_EnterHandler

        .tOldPos = 0

        .check_ticks:
        mov     edx,dword[edi+64h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.ptInterpData
        cmp     dword[edx+DynCubeObjInterpData_s.nTicks],1
        jb      .back

        .alloc:
        sub     esp,8*3

        .calc_oldpos:
        lea     eax,[esi+20h] ;ptHumanView->tPos
        lea     ecx,[edi+20h] ;ptHuman->tPos
        lea     edx,[edx+DynCubeObjInterpData_s.tOldPos] ; ptHuman->tOldPos
        fld     qword[eax] ;ptHumanView->tPos.vX
        fadd    qword[edx] ;ptHuman->tOldPos.vX
        fsub    qword[ecx] ;ptHuman->tPos.vX
        fstp    qword[esp+.tOldPos]
        fld     qword[eax+8] ;ptHumanView->tPos.vY
        fadd    qword[edx+8] ;ptHuman->tOldPos.vY
        fsub    qword[ecx+8] ;ptHuman->tPos.vY
        fstp    qword[esp+.tOldPos+8]
        fld     qword[eax+10h] ;ptHumanView->tPos.vZ
        fadd    qword[edx+10h] ;ptHuman->tOldPos.vZ
        fsub    qword[ecx+10h] ;ptHuman->tPos.vZ
        fstp    qword[esp+.tOldPos+10h]

        .calc_interp_pos:
        mov     eax,HumanView_tInterpPos
        lea     ecx,[esi+20h] ;ptHumanView->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos
        lea     edx,[esp+.tOldPos]
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE

        .dealloc:
        add     esp,8*3

        .back:
        call    near PATCHER_CALL_TRAP ;BoneDynCubeObj_GetQTaskType:0x004D9610
        .fixup1 = $-4
        jmp     near PATCHER_JUMP_TRAP ;loc_4644F3
        .fixup2 = $-4

loc_460133: ; Human_gun_event_related_3

        .ptHuman = 4
        .tOldPos = 0

        .get_human_ptr:
        mov     esi,dword[esp+14h+.ptHuman]

        .check_ticks:
        mov     edi,dword[esi+64h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.ptInterpData
        cmp     dword[edi+DynCubeObjInterpData_s.nTicks],1
        jb      .end

        .alloc:
        sub     esp,8*3

        .get_ptrs:
        add     eax,8 ;pxContext->tPos
        mov     ecx,eax
        lea     edx,[esp+.tOldPos]

        .calc_oldpos:
        fld     qword[eax] ;pxContext->tPos.vX
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vX]
        fsub    qword[esi+20h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vX
        fstp    qword[edx]
        fld     qword[eax+8] ;pxContext->tPos.vY
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vY]
        fsub    qword[esi+20h+8] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vY
        fstp    qword[edx+8]
        fld     qword[eax+10h] ;pxContext->tPos.vZ
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vZ]
        fsub    qword[esi+20h+10h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vZ
        fstp    qword[edx+10h]

        .calc_interp_pos:
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE

        .dealloc:
        add     esp,8*3

        .end:
        pop     edi esi
        add     esp,0Ch
        retn    0

loc_460187: ; Human_gun_event_related_3

        .ptHuman = 4
        .tOldPos = 0

        mov     dword[eax],0

        .get_human_ptr:
        mov     esi,dword[esp+14h+.ptHuman]

        .check_ticks:
        mov     edi,dword[esi+64h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.ptInterpData
        cmp     dword[edi+DynCubeObjInterpData_s.nTicks],1
        jb      .end

        .alloc:
        sub     esp,8*3

        .get_ptrs:
        add     eax,8 ;pxContext->tPos
        mov     ecx,eax
        lea     edx,[esp+.tOldPos]

        .calc_oldpos:
        fld     qword[eax] ;pxContext->tPos.vX
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vX]
        fsub    qword[esi+20h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vX
        fstp    qword[edx]
        fld     qword[eax+8] ;pxContext->tPos.vY
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vY]
        fsub    qword[esi+20h+8] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vY
        fstp    qword[edx+8]
        fld     qword[eax+10h] ;pxContext->tPos.vZ
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vZ]
        fsub    qword[esi+20h+10h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vZ
        fstp    qword[edx+10h]

        .calc_interp_pos:
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE

        .dealloc:
        add     esp,8*3

        .end:
        pop     edi esi
        add     esp,0Ch
        retn    0

loc_460202: ; Human_gun_event_related_4

        .ptHuman = 4
        .pxContext = 8
        .tOldPos = 0

        add     esi,1AF4h
        rep     movsd

        .get_human_ptr:
        mov     esi,dword[esp+14h+.ptHuman]

        .check_ticks:
        mov     edi,dword[esi+64h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.ptInterpData
        cmp     dword[edi+DynCubeObjInterpData_s.nTicks],1
        jb      .end

        .alloc:
        sub     esp,8*3

        .get_ptrs:
        mov     eax,dword[esp+14h+24+.pxContext] ;pxContext->tPos
        mov     ecx,eax
        lea     edx,[esp+.tOldPos]

        .calc_oldpos:
        fld     qword[eax] ;pxContext->tPos.vX
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vX]
        fsub    qword[esi+20h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vX
        fstp    qword[edx]
        fld     qword[eax+8] ;pxContext->tPos.vY
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vY]
        fsub    qword[esi+20h+8] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vY
        fstp    qword[edx+8]
        fld     qword[eax+10h] ;pxContext->tPos.vZ
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vZ]
        fsub    qword[esi+20h+10h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vZ
        fstp    qword[edx+10h]

        .calc_interp_pos:
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE

        .dealloc:
        add     esp,8*3

        .end:
        pop     edi esi
        add     esp,0Ch
        retn    0

loc_460272: ; Human_gun_event_related_5

        .ptHuman = 4
        .pxContext = 8
        .tOldPos = 0

        add     esi,1C80h
        rep     movsd

        .get_human_ptr:
        mov     esi,dword[esp+14h+.ptHuman]

        .check_ticks:
        mov     edi,dword[esi+64h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.ptInterpData
        cmp     dword[edi+DynCubeObjInterpData_s.nTicks],1
        jb      .end

        .alloc:
        sub     esp,8*3

        .get_ptrs:
        mov     eax,dword[esp+14h+24+.pxContext] ;pxContext->tPos
        mov     ecx,eax
        lea     edx,[esp+.tOldPos]

        .calc_oldpos:
        fld     qword[eax] ;pxContext->tPos.vX
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vX]
        fsub    qword[esi+20h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vX
        fstp    qword[edx]
        fld     qword[eax+8] ;pxContext->tPos.vY
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vY]
        fsub    qword[esi+20h+8] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vY
        fstp    qword[edx+8]
        fld     qword[eax+10h] ;pxContext->tPos.vZ
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vZ]
        fsub    qword[esi+20h+10h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vZ
        fstp    qword[edx+10h]

        .calc_interp_pos:
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE

        .dealloc:
        add     esp,8*3

        .end:
        pop     edi esi
        add     esp,0Ch
        retn    0

loc_4A01DC: ; RigidDynCubeObj_EnterHandler

        .ptDrawRigidMeshContext = -54h
        .tPos = -40

        add     esp,2*4+1*4

        .set_pos_ptr:
        lea     ebp,[ebx+20h] ;ptRigidDynCubeObj->tModelObj.tDynCubeObj.tQObj.tPos

        .init_apply_interp:
        xor     edi,edi ;IsApplyInterp

        .check_interpolable:
        ccall   QTask_IsRDCOTaskTypeInterpolable,ebx
        test    eax,eax
        jz      .draw_rigidmesh

        .check_physicsobj: ; does not use interp buffer
        cmp     eax,2 ; physicsobj id
        je      .calc_interp_pos_physicsobj

        .check_elevator: ; does not use interp buffer
        cmp     eax,4 ; elevator id
        je      .calc_interp_pos_elevator

        .check_ticks:
        mov     edx,dword[ebx+64h] ;ptRigidDynCubeObj->tModelObj.tDynCubeObj.ptInterpData
        cmp     dword[edx+DynCubeObjInterpData_s.nTicks],1
        jb      .draw_rigidmesh

        .check_gun: ; already interpolated
        cmp     eax,1 ; gun id
        je      .draw_rigidmesh

        .calc_interp_pos:
        mov     eax,Direct3DRender_tDrawRigidMeshContext2.tInterpPos
        mov     ecx,ebp
        lea     edx,[edx+DynCubeObjInterpData_s.tOldPos]
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE
        jmp     .set_pos_ptr_interp

        ;.calc_interp_pos_physicsobj: ; not working very well
        ;mov     eax,Direct3DRender_tDrawRigidMeshContext2.tInterpPos
        ;mov     ecx,ebp
        ;lea     edx,[ebx+6C0h] ;&ptPhysicsObj->tLastPosition
        ;ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE
        ;jmp     .set_pos_ptr_interp

        .calc_interp_pos_physicsobj:
        mov     eax,Direct3DRender_tDrawRigidMeshContext2.tInterpPos
        mov     ecx,ebp
        lea     edx,[ebx+0F0h+18h] ;&ptPhysicsObj->tPhysics.tCMVel
        ccall   Flow_CalcInterpolatedPosByVel,eax,ecx,edx
        jmp     .set_pos_ptr_interp

        .calc_interp_pos_elevator:
        mov     eax,Direct3DRender_tDrawRigidMeshContext2.tInterpPos
        mov     ecx,ebp
        lea     edx,[ebx+108h] ;&ptElevator->tLastPosition
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE

        .set_pos_ptr_interp:
        mov     ebp,Direct3DRender_tDrawRigidMeshContext2.tInterpPos

        .set_context:
        mov     edi,TRUE
        mov     dword[Direct3DRender_tDrawRigidMeshContext2.IsDoApplyInterp],edi

        .draw_rigidmesh:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Mesh3D_eDrawRigidMeshRenderModeMethod:0x00B46D14
        .fixup1 = $-4
        lea     ecx,[esp+64h+.ptDrawRigidMeshContext]
        push    ecx
        call    dword[PATCHER_ADDR_TRAP+eax*4] ;RenderMode_tActiveRenderMode.apfRenderModeMethod:0x00A94E84
        .fixup2 = $-4
        add     esp,1*4

        .check_interp_applied:
        test    edi,edi
        jz      .back

        .reset_context:
        xor     eax,eax
        mov     dword[Direct3DRender_tDrawRigidMeshContext2.IsDoApplyInterp],eax

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_4A01F0
        .fixup3 = $-4

loc_5124EB: ; BoneDynCubeObj_EnterHandler

        .ptDrawBoneMeshContext = -54h
        .tPos = -40

        add     esp,2*4+1*4

        .set_pos_ptr:
        lea     esi,[ebx+20h] ;ptRigidDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos

        .init_apply_interp:
        xor     edi,edi ;IsApplyInterp

        .check_interpolable:
        ccall   QTask_IsBDCOTaskTypeInterpolable,ebx
        test    eax,eax
        jz      .draw_bonemesh

        .check_ticks:
        mov     edx,dword[ebx+64h] ;ptBoneDynCubeObj.tModelObj.tDynCubeObj.ptInterpData
        cmp     dword[edx+DynCubeObjInterpData_s.nTicks],1
        jb      .draw_bonemesh

        .check_humanview: ; pre-calculated already
        cmp     eax,2 ; humanview id
        je      .set_context_humanview

        .calc_interp_pos:
        mov     eax,Direct3DRender_tDrawBoneMeshContext2.tInterpPos
        mov     ecx,esi
        lea     edx,[edx+DynCubeObjInterpData_s.tOldPos]
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE

        .set_pos_ptr_interp:
        mov     esi,Direct3DRender_tDrawBoneMeshContext2.tInterpPos

        .set_context:
        mov     edi,TRUE
        mov     dword[Direct3DRender_tDrawBoneMeshContext2.IsDoApplyInterp],edi
        jmp     .draw_bonemesh

        .set_context_humanview:
        mov     edi,TRUE
        mov     dword[Direct3DRender_tDrawBoneMeshContext2.IsDoApplyInterp],edi
        mov     eax,dword[HumanView_tInterpPos.vX]
        mov     ecx,dword[HumanView_tInterpPos.vY]
        mov     edx,dword[HumanView_tInterpPos.vZ]
        mov     dword[Direct3DRender_tDrawBoneMeshContext2.tInterpPos.vX],eax
        mov     dword[Direct3DRender_tDrawBoneMeshContext2.tInterpPos.vY],ecx
        mov     dword[Direct3DRender_tDrawBoneMeshContext2.tInterpPos.vZ],edx
        mov     eax,dword[HumanView_tInterpPos.vX+4]
        mov     ecx,dword[HumanView_tInterpPos.vY+4]
        mov     edx,dword[HumanView_tInterpPos.vZ+4]
        mov     dword[Direct3DRender_tDrawBoneMeshContext2.tInterpPos.vX+4],eax
        mov     dword[Direct3DRender_tDrawBoneMeshContext2.tInterpPos.vY+4],ecx
        mov     dword[Direct3DRender_tDrawBoneMeshContext2.tInterpPos.vZ+4],edx

        .draw_bonemesh:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Mesh3D_eDrawBoneMeshRenderModeMethod:0x00B81880
        .fixup1 = $-4
        lea     ecx,[esp+60h+.ptDrawBoneMeshContext]
        push    ecx
        call    dword[PATCHER_ADDR_TRAP+eax*4] ;RenderMode_tActiveRenderMode.apfRenderModeMethod:0x00A94E84
        .fixup2 = $-4
        add     esp,1*4

        .check_interp_applied:
        test    edi,edi
        jz      .copy_pos

        .reset_context:
        xor     eax,eax
        mov     dword[Direct3DRender_tDrawBoneMeshContext2.IsDoApplyInterp],eax

        .copy_pos:
        mov     ecx,6
        ;mov     esi,esi
        lea     edi,[esp+60h+.tPos]
        rep     movsd

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_51250D
        .fixup3 = $-4

loc_49E0B1: ; Direct3DRender_DrawRigidMesh

        .set_pos_ptr:
        lea     edi,[ebx+20h] ;ptRigidDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos

        .check_context2:
        cmp     dword[Direct3DRender_tDrawRigidMeshContext2.IsDoApplyInterp],FALSE
        je      .back

        .set_pos_ptr_interp:
        mov     edi,Direct3DRender_tDrawRigidMeshContext2.tInterpPos

        .back:
        fld     qword[edi]
        fsub    qword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.tPos.vX:0x00BCAB08
        .fixup1 = $-4
        jmp     near PATCHER_JUMP_TRAP ;loc_49E0BA
        .fixup2 = $-4

loc_49E272: ; Direct3DRender_DrawRigidMesh

        .var_210 = -210h

        .set_pos_ptr:
        lea     edi,[ebx+20h] ;ptRigidDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos

        .check_context2:
        cmp     dword[Direct3DRender_tDrawRigidMeshContext2.IsDoApplyInterp],FALSE
        je      .back

        .set_pos_ptr_interp:
        mov     edi,Direct3DRender_tDrawRigidMeshContext2.tInterpPos

        .back:
        mov     eax,dword[esp+238h+.var_210]
        mov     eax,dword[eax+20h]
        test    eax,eax
        fld     qword[edi]
        fsub    qword[PATCHER_ADDR_TRAP] ;TransContext_tActiveTransContext.tPos.vX:0x00BCAB08
        .fixup1 = $-4
        jmp     near PATCHER_JUMP_TRAP ;loc_49E27B
        .fixup2 = $-4

loc_49F80F: ; Direct3DRender_DrawBoneMesh

        .tInterpPos = -190h

        .set_pos_ptr:
        lea     edi,[ebp+20h] ;ptBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos

        .check_context2:
        cmp     dword[Direct3DRender_tDrawBoneMeshContext2.IsDoApplyInterp],FALSE
        je      .back

        .set_pos_ptr_interp:
        mov     edi,Direct3DRender_tDrawBoneMeshContext2.tInterpPos

        .back:
        mov     eax,dword[esi+ebx*4]
        jmp     near PATCHER_JUMP_TRAP ;loc_49F815
        .fixup1 = $-4

loc_4E0C8A: ; Shadow_MagicObjEnterHandler

        push    ebp
        mov     ebp,ebx ;ptShadow
        mov     ebx,dword[ebx+74h] ;ptShadow->ptPolyList

        .get_human:
        mov     esi,dword[ebp+14h] ;ptShadow->tQTask.ptParent

        .check_ticks:
        mov     edi,dword[esi+64h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.ptInterpData
        cmp     dword[edi+DynCubeObjInterpData_s.nTicks],1
        jb      .back

        .get_pointers:
        lea     eax,[ebx+20h] ;ptPolyList->tDynCubeObj.tQObj.tPos
        mov     ecx,dword[ebp+24h] ;ptShadow->ptPos
        mov     edx,eax

        .calc_oldpos:
        fld     qword[eax]
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vX]
        fsub    qword[esi+20h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vX
        fstp    qword[edx]
        fld     qword[eax+8]
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vY]
        fsub    qword[esi+20h+8] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vY
        fstp    qword[edx+8]
        fld     qword[eax+10h]
        fadd    qword[edi+DynCubeObjInterpData_s.tOldPos.vZ]
        fsub    qword[esi+20h+10h] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tPos.vZ
        fstp    qword[edx+10h]

        .calc_interp_pos:
        ccall   Flow_CalcInterpolatedPos,eax,ecx,edx,FALSE

        .back:
        pop     ebp
        xor     eax,eax
        jmp     near PATCHER_JUMP_TRAP ;loc_4E0C8F
        .fixup1 = $-4

proc Flow_UpdateCInput c ptInputPort

        .update_hp_devices: ; update high priority devices (mouse)
        call    near PATCHER_CALL_TRAP ;Mouse_Update:0x0048FC20
        .fixup1 = $-4

        .record_mouse_buttons:
        ccall   Mouse_WriteBufferedButtons

        .end:
        ret
endp

proc Flow_UpdateInputOnRun c ptInputPort

        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_RUN

        .update_mouse_phases:
        ccall   Mouse_UpdatePhaseInputs

        .update_inputport:
        ccall   InputPort_UpdateOnRun,dword[ptInputPort]

        .end:
        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_NONE
        ret
endp

proc Flow_UpdateInputOnInterp c ptInputPort

        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP

        .update_mouse_phases:
        ccall   Mouse_UpdatePhaseInputs

        .update_inputport:
        ccall   InputPort_UpdateOnInterp,dword[ptInputPort]

        .end:
        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_NONE
        ret
endp

proc Flow_UpdateInputOnDraw c ptInputPort

        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_DRAW

        .update_mouse_phases:
        ccall   Mouse_UpdatePhaseInputs

        .update_inputport:
        ccall   InputPort_UpdateOnDraw,dword[ptInputPort]

        .end:
        mov     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_NONE
        ret
endp

proc InputOptions_UpdateMouseSensitivity c

        push    ebx

        .get_config_ptr:
        call    near PATCHER_CALL_TRAP ;Config_GetActivePlayerProfile:0x00406220
        .fixup1 = $-4
        mov     ebx,eax

        .clamp_sens:
        ;mov     ecx,dword[ebx+53Ch] ;ptPlayerProfile->tInputOptions.vMouseSensitivity
        ;fld     dword[ebx+53Ch] ;ptPlayerProfile->tInputOptions.vMouseSensitivity
        .lerp_sens:
        fld     dword[InputOptions_vMaxMouseSensMult]
        fsub    dword[InputOptions_vMinMouseSensMult]
        fmul    dword[ebx+53Ch] ;ptPlayerProfile->tInputOptions.vMouseSensitivity
        fadd    dword[InputOptions_vMinMouseSensMult]
        .get_value:
        push    ecx
        fst     dword[esp]
        pop     ecx
        .clamp_max:
        mov     edx,dword[InputOptions_vMaxMouseSensMult]
        fcom    dword[InputOptions_vMaxMouseSensMult]
        fnstsw  ax
        test    ah,41h
        setne   al
        and     eax,1
        neg     eax
        sub     ecx,edx
        and     ecx,eax
        add     ecx,edx
        .clamp_min:
        mov     edx,dword[InputOptions_vMinMouseSensMult]
        fcomp   dword[InputOptions_vMinMouseSensMult]
        fnstsw  ax
        test    ah,5
        setp    al
        and     eax,1
        neg     eax
        sub     ecx,edx
        and     ecx,eax
        add     ecx,edx

        .save_sensx:
        mov     dword[InputOptions_vCurMouseSensX],ecx

        .save_sensy_ign_inv:
        mov     edx,ecx
        xor     edx,0x80000000 ; sign bit
        mov     dword[InputOptions_vCurMouseSensYIgn],edx

        .save_sensy:
        mov     eax,0x80000000 ; sign bit
        mov     edx,dword[ebx+538h] ;ptPlayerProfile->tInputOptions.isInvertMouse
        neg     edx
        sbb     edx,edx
        and     eax,edx
        xor     ecx,eax
        mov     dword[InputOptions_vCurMouseSensY],ecx

        .apply_custom_mult:
        fld     dword[InputOptions_vCurMouseSensX]
        fmul    dword[Mouse_vCustomSensMultX]
        fstp    dword[InputOptions_vCurMouseSensX]
        fld     dword[InputOptions_vCurMouseSensY]
        fmul    dword[Mouse_vCustomSensMultY]
        fstp    dword[InputOptions_vCurMouseSensY]
        fld     dword[InputOptions_vCurMouseSensYIgn]
        fmul    dword[Mouse_vCustomSensMultY]
        fstp    dword[InputOptions_vCurMouseSensYIgn]

        .end:
        pop     ebx
        ret
endp

proc Mouse_ClearInput c

        xor     eax,eax

        .clear_axis:
        mov     dword[Mouse_nRelPositionX],eax
        mov     dword[Mouse_nRelPositionY],eax

        .clear_input:
        mov     dword[PATCHER_ADDR_TRAP],eax ;Mouse_tMouse.bButton:0x00C28F8C
        .fixup1 = $-4

        .check_wininput:
        cmp     dword[PATCHER_ADDR_TRAP],FALSE ;AppContext_tAppContext.isWinMessageInput:0x005C8BE0
        .fixup2 = $-1-4
        jne     .end

        .clear_wininput:
        mov     dword[PATCHER_ADDR_TRAP],eax ;Mouse_nLButtonDown:0x005C8E10
        .fixup3 = $-4
        mov     dword[PATCHER_ADDR_TRAP],eax ;Mouse_nRButtonDown:0x005C8E0C
        .fixup4 = $-4
        mov     dword[PATCHER_ADDR_TRAP],eax ;Mouse_nMButtonDown:0x005C8E18
        .fixup5 = $-4
        mov     dword[PATCHER_ADDR_TRAP],eax ;Mouse_nMouseWheel:0x005C8E08
        .fixup6 = $-4

        .end:
        ret
endp

loc_48FED0: ; Mouse_WinProcCB

        .uMsg = 8

        .check_wininput:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;AppContext_tAppContext.isWinMessageInput:0x005C8BE0
        .fixup1 = $-4
        test    eax,eax
        jz      .end

        .get_msg:
        mov     eax,dword[esp+.uMsg]

        .check_activate:
        cmp     eax,WM_ACTIVATE
        je      .wm_activate

        .back:
        add     eax,-201h
        jmp     near PATCHER_JUMP_TRAP ;loc_48FED9
        .fixup2 = $-4

        .wm_activate:
        ccall   Mouse_ClearInput

        .end:
        mov     eax,TRUE
        retn    0

loc_48FC7B: ; Mouse_Update

        .sMouseState.lX = -14h
        .sMouseState.lY = -14h+4

        .check_locked:
        cmp     byte[Mouse_IsLocked],FALSE
        jne     .locked

        .save_pos:
        mov     ecx,dword[Mouse_nRelPositionX]
        mov     edx,dword[Mouse_nRelPositionY]
        add     ecx,dword[esp+18h+.sMouseState.lX]
        add     edx,dword[esp+18h+.sMouseState.lY]
        mov     dword[Mouse_nRelPositionX],ecx
        mov     dword[Mouse_nRelPositionY],edx

        .back:
        jmp     near PATCHER_JUMP_TRAP ;loc_48FC9B
        .fixup1 = $-4

        .locked:
        ccall   Mouse_ClearInput

        .end:
        pop     esi
        add     esp,14h
        ret     0

proc Mouse_WriteBufferedButtons c

        .write_mouse_buffered_buttons:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Mouse_tMouse.bButton:0x00C28F8C
        .fixup1 = $-4
        or      dword[Mouse_bButtonAcc],eax  

        .end:
        ret
endp

proc Mouse_ReadBufferedButtons c

        .check_interp: ; skip buffered button handling if interp is disabled
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .end

        .check_render_fps: ; skip buffered buttons handling if render fps < glogic fps
        mov     ecx,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup1 = $-4
        ;cmp     dword[ecx+44h],0 ;ptFlow->nFramesSinceLastTick
        cmp     dword[ecx+44h],eax ;ptFlow->nFramesSinceLastTick
        je      .end

        .read_mouse_buffered_buttons:
        mov     edx,dword[Mouse_bButtonAcc]
        mov     dword[PATCHER_ADDR_TRAP],edx ;Mouse_tMouse.bButton:0x00C28F8C
        .fixup2 = $-4

        .reset_mouse_buffered_buttons:
        ;mov     dword[Mouse_bButtonAcc],0
        mov     dword[Mouse_bButtonAcc],eax

        .end:
        ret
endp

proc Mouse_UpdatePhaseInputs c

        push    ebx ebp esi edi

        .get_phase:
        mov     eax,dword[Flow_nCurrentPhase]
        lea     ecx,[eax-1]
        cmp     ecx,3-1
        ja      .end

        .conv_to_mask:
        sbb     edx,edx
        add     eax,edx
        inc     eax ; 1 -> 1, 2 -> 2, 3 -> 4

        .loop_init:
        mov     ebx,1
        xor     ebp,ebp
        fild    dword[Mouse_nRelPositionX]
        fmul    dword[Mouse_vScaleFactorInv]
        fild    dword[Mouse_nRelPositionY]
        fmul    dword[Mouse_vScaleFactorInv]
        fmul    dword[Display_vAspectRatio]
        mov     dword[Mouse_nRelPositionX],ebp
        mov     dword[Mouse_nRelPositionY],ebp

        .loop_body:
        fld     dword[Mouse_avAnalogX_Acc+(ebx-1)*4]
        fadd    st0,st2 ;ScaledRelPosX
        fstp    dword[Mouse_avAnalogX_Acc+(ebx-1)*4]
        fld     dword[Mouse_avAnalogY_Acc+(ebx-1)*4]
        fadd    st0,st1 ;ScaledRelPosY
        fstp    dword[Mouse_avAnalogY_Acc+(ebx-1)*4]

        .get_pointers:
        mov     esi,dword[Mouse_apvAnalogX_Tbl+(ebx-1)*4]
        mov     edi,dword[Mouse_apvAnalogY_Tbl+(ebx-1)*4]

        .check_matching:
        test    ebx,eax
        jz      .phase_not_matched

        .phase_matched:
        mov     ecx,dword[Mouse_avAnalogX_Acc+(ebx-1)*4]
        mov     edx,dword[Mouse_avAnalogY_Acc+(ebx-1)*4]
        mov     dword[esi],ecx
        mov     dword[edi],edx

        .zero_acc:
        mov     dword[Mouse_avAnalogX_Acc+(ebx-1)*4],ebp
        mov     dword[Mouse_avAnalogY_Acc+(ebx-1)*4],ebp
        jmp     .loop_next

        .phase_not_matched:
        mov     dword[esi],ebp
        mov     dword[edi],ebp

        .loop_next:
        inc     ebx
        cmp     ebx,7
        jbe     .loop_body

        .loop_end:
        fstp    dword[Mouse_vAnalogY] ; same as Mouse_vAnalogY_M111
        fstp    dword[Mouse_vAnalogX] ; same as Mouse_vAnalogX_M111

        .end:
        pop     edi esi ebp ebx
        ret
endp

proc InputPort_RunHandler_NEW c ptInputPort

        .reset_playerinput:
        mov     dword[HumanPlayerInput_IsRunning],FALSE

        .update_lp_devices: ; update low priority devices (keyboard, joypad)
        call    near PATCHER_CALL_TRAP ;Keyboard_Update:0x00490230
        .fixup1 = $-4
        call    near PATCHER_CALL_TRAP ;Joypad_Update:0x00509CF0
        .fixup2 = $-4

        .update_mouse_buttons:
        ccall   Mouse_ReadBufferedButtons

        .update_sens_mult:
        ccall   InputOptions_UpdateMouseSensitivity

        .update_inputport:
        ccall   InputPort_Update,dword[ptInputPort]

        .end:
        ret
endp

proc InputPort_Update c ptInputPort

        push    ebx esi edi
        mov     ebx,dword[ptInputPort]

        .loop_init:
        xor     esi,esi
        xor     edi,edi

        .loop_body:
        lea     eax,[PATCHER_ADDR_TRAP+edi] ;InputPort.atInputPort[i]:0x00BC20A0
        .fixup1 = $-4

        .check_active:
        cmp     dword[eax],FALSE ;InputPort.atInputPort[i].isActive
        je      .loop_next

        .update_input:
        mov     dword[PATCHER_ADDR_TRAP],esi ;InputPort_eCurrentPort:0x00A5EF9C
        .fixup2 = $-4
        add     eax,50h ;&InputPort.atInputPort[i].tInput
        push    ebx
        push    eax
        call    near PATCHER_CALL_TRAP ;Input_Run:0x00507EC0
        .fixup3 = $-4
        add     esp,2*4

        .loop_next:
        inc     esi
        add     edi,176 ;sizeof(InputPort_s)
        cmp     esi,4
        jl      .loop_body

        .end:
        pop      edi esi ebx
        ret
endp

proc InputPort_UpdateOnRun c ptInputPort

        push    esi edi

        .get_cur_port:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;InputPort_eCurrentPort:0x00A5EF9C
        .fixup1 = $-4

        .is_port_0:
        test    eax,eax
        jnz     .end

        .get_analog_device:
        imul    eax,176 ;sizeof(InputPort_s)
        mov     eax,dword[PATCHER_ADDR_TRAP+eax] ;InputPort.atInputPort[InputPort_eCurrentPort].eAnalogInputPortDevice:0x00BC20AC
        .fixup2 = $-4

        .is_mouse:
        cmp     eax,3 ;INPUTPORT_DEVICE_MOUSE
        jne     .end

        .update_mouse: ; TODO: clamp values to -1.0 ~ 1.0?
        mov     ecx,dword[Mouse_vAnalogX_M100]
        mov     edx,dword[Mouse_vAnalogY_M100]
        mov     esi,dword[Mouse_vAnalogX_M110]
        mov     edi,dword[Mouse_vAnalogY_M110]
        mov     dword[InputPort_P0Input_vAnalogX_M100],ecx
        mov     dword[InputPort_P0Input_vAnalogY_M100],edx
        mov     dword[InputPort_P0Input_vAnalogX_M110],esi
        mov     dword[InputPort_P0Input_vAnalogY_M110],edi
        mov     ecx,dword[Mouse_vAnalogX_M101]
        mov     edx,dword[Mouse_vAnalogY_M101]
        mov     esi,dword[Mouse_vAnalogX_M111]
        mov     edi,dword[Mouse_vAnalogY_M111]
        mov     dword[InputPort_P0Input_vAnalogX_M101],ecx
        mov     dword[InputPort_P0Input_vAnalogY_M101],edx
        mov     dword[InputPort_P0Input_vAnalogX_M111],esi
        mov     dword[InputPort_P0Input_vAnalogY_M111],edi

        .end:
        pop     edi esi
        ret
endp

proc InputPort_UpdateOnInterp c ptInputPort

        push    esi edi

        .get_cur_port:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;InputPort_eCurrentPort:0x00A5EF9C
        .fixup1 = $-4

        .is_port_0:
        test    eax,eax
        jnz     .end

        .get_analog_device:
        imul    eax,176 ;sizeof(InputPort_s)
        mov     eax,dword[PATCHER_ADDR_TRAP+eax] ;InputPort.atInputPort[InputPort_eCurrentPort].eAnalogInputPortDevice:0x00BC20AC
        .fixup2 = $-4

        .is_mouse:
        cmp     eax,3 ;INPUTPORT_DEVICE_MOUSE
        jne     .end

        .update_mouse: ; TODO: clamp values to -1.0 ~ 1.0?
        mov     ecx,dword[Mouse_vAnalogX_M010]
        mov     edx,dword[Mouse_vAnalogY_M010]
        mov     esi,dword[Mouse_vAnalogX_M110]
        mov     edi,dword[Mouse_vAnalogY_M110]
        mov     dword[InputPort_P0Input_vAnalogX_M010],ecx
        mov     dword[InputPort_P0Input_vAnalogY_M010],edx
        mov     dword[InputPort_P0Input_vAnalogX_M110],esi
        mov     dword[InputPort_P0Input_vAnalogY_M110],edi
        mov     ecx,dword[Mouse_vAnalogX_M011]
        mov     edx,dword[Mouse_vAnalogY_M011]
        mov     esi,dword[Mouse_vAnalogX_M111]
        mov     edi,dword[Mouse_vAnalogY_M111]
        mov     dword[InputPort_P0Input_vAnalogX_M011],ecx
        mov     dword[InputPort_P0Input_vAnalogY_M011],edx
        mov     dword[InputPort_P0Input_vAnalogX_M111],esi
        mov     dword[InputPort_P0Input_vAnalogY_M111],edi

        .end:
        pop     edi esi
        ret
endp

proc InputPort_UpdateOnDraw c ptInputPort

        push    esi edi

        .get_cur_port:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;InputPort_eCurrentPort:0x00A5EF9C
        .fixup1 = $-4

        .is_port_0:
        test    eax,eax
        jnz     .end

        .get_analog_device:
        imul    eax,176 ;sizeof(InputPort_s)
        mov     eax,dword[PATCHER_ADDR_TRAP+eax] ;InputPort.atInputPort[InputPort_eCurrentPort].eAnalogInputPortDevice:0x00BC20AC
        .fixup2 = $-4

        .is_mouse:
        cmp     eax,3 ;INPUTPORT_DEVICE_MOUSE
        jne     .end

        .update_mouse: ; TODO: clamp values to -1.0 ~ 1.0?
        mov     ecx,dword[Mouse_vAnalogX_M001]
        mov     edx,dword[Mouse_vAnalogY_M001]
        mov     esi,dword[Mouse_vAnalogX_M101]
        mov     edi,dword[Mouse_vAnalogY_M101]
        mov     dword[InputPort_P0Input_vAnalogX_M001],ecx
        mov     dword[InputPort_P0Input_vAnalogY_M001],edx
        mov     dword[InputPort_P0Input_vAnalogX_M101],esi
        mov     dword[InputPort_P0Input_vAnalogY_M101],edi
        mov     ecx,dword[Mouse_vAnalogX_M011]
        mov     edx,dword[Mouse_vAnalogY_M011]
        mov     esi,dword[Mouse_vAnalogX_M111]
        mov     edi,dword[Mouse_vAnalogY_M111]
        mov     dword[InputPort_P0Input_vAnalogX_M011],ecx
        mov     dword[InputPort_P0Input_vAnalogY_M011],edx
        mov     dword[InputPort_P0Input_vAnalogX_M111],esi
        mov     dword[InputPort_P0Input_vAnalogY_M111],edi

        .end:
        pop     edi esi
        ret
endp

loc_4ED420: ; InputPort_InputHandler

        .vAnalogX = -10h
        .vAnalogY = -0Ch
        .vAnalogButton1 = -8
        .vAnalogButton0 = -4
        .ptInput = 4

        .add_analog_values:
        fadd    dword[PATCHER_ADDR_TRAP+ecx] ;InputPort.atInputPort0.vX:0x00BC20B0
        .fixup1 = $-4
        fstp    dword[esp+20h+.vAnalogX]
        fld     dword[esp+20h+.vAnalogY]
        fadd    dword[PATCHER_ADDR_TRAP+ecx] ;InputPort.atInputPort0.vY:0x00BC20B4
        .fixup2 = $-4
        fstp    dword[esp+20h+.vAnalogY]
        fld     dword[esp+20h+.vAnalogButton0]
        fadd    dword[PATCHER_ADDR_TRAP+ecx] ;InputPort.atInputPort0.v0:0x00BC20B8
        .fixup3 = $-4
        fstp    dword[esp+20h+.vAnalogButton0]
        fld     dword[esp+20h+.vAnalogButton1]
        fadd    dword[PATCHER_ADDR_TRAP+ecx] ;InputPort.atInputPort0.v1:0x00BC20BC
        .fixup4 = $-4
        fstp    dword[esp+20h+.vAnalogButton1]

        .get_device_type:
        mov     ebp,dword[PATCHER_ADDR_TRAP+ecx] ;InputPort.atInputPort[InputPort_eCurrentPort].eAnalogInputPortDevice:0x00BC20AC
        .fixup5 = $-4

        .is_joypad:
        cmp     ebp,2 ;INPUTPORT_DEVICE_JOYPAD
        jne     .get_input_ptr

        .check_analogx_min:
        fld     dword[FPU_CONSTS.flt__1_0]
        fcomp   dword[esp+20h+.vAnalogX]
        fnstsw  ax
        test    ah,41h
        jnz     .check_analogx_max
        mov     dword[esp+20h+.vAnalogX],-1.0
        jmp     .check_analogy_min

        .check_analogx_max:
        fld     dword[FPU_CONSTS.flt_1_0]
        fcomp   dword[esp+20h+.vAnalogX]
        fnstsw  ax
        test    ah,5
        jp      .check_analogy_min
        mov     dword[esp+20h+.vAnalogX],1.0

        .check_analogy_min:
        fld     dword[FPU_CONSTS.flt__1_0]
        fcomp   dword[esp+20h+.vAnalogY]
        fnstsw  ax
        test    ah,41h
        jnz     .check_analogy_max
        mov     dword[esp+20h+.vAnalogY],-1.0
        jmp     .check_analog0_min

        .check_analogy_max:
        fld     dword[FPU_CONSTS.flt_1_0]
        fcomp   dword[esp+20h+.vAnalogY]
        fnstsw  ax
        test    ah,5
        jp      .check_analog0_min
        mov     dword[esp+20h+.vAnalogY],1.0

        .check_analog0_min:
        fld     dword[FPU_CONSTS.flt_0_0]
        fcomp   dword[esp+20h+.vAnalogButton0]
        fnstsw  ax
        test    ah,41h
        jnz     .check_analog0_max
        mov     dword[esp+20h+.vAnalogButton0],0.0
        jmp     .get_input_ptr

        .check_analog0_max:
        fld     dword[FPU_CONSTS.flt_1_0]
        fcomp   dword[esp+20h+.vAnalogButton0]
        fnstsw  ax
        test    ah,5
        jp      .get_input_ptr
        mov     dword[esp+20h+.vAnalogButton0],1.0

        .get_input_ptr:
        mov     esi,dword[esp+20h+.ptInput]

        .save_analog_buttons: ; shouldnt this be skipped for mouse?
        mov     eax,dword[esp+20h+.vAnalogButton0]
        mov     ecx,dword[esp+20h+.vAnalogButton1]
        mov     dword[esi+0Ch],eax ;ptInput->vAnalogButton0
        mov     dword[esi+10h],ecx ;ptInput->vAnalogButton1

        .save_current_buttons:
        ;mov     ebx,dword[esp+20h+.bCurrentButtonLO]
        mov     dword[esi+1Ch],ebx ;ptInput->bCurrentButton

        .save_analog_values:
        mov     eax,dword[esp+20h+.vAnalogX]
        mov     ecx,dword[esp+20h+.vAnalogY]
        mov     dword[esi+4],eax ;ptInput->vAnalogX
        mov     dword[esi+8],ecx ;ptInput->vAnalogY

        .end:
        pop     edi
        pop     esi
        pop     ebp
        pop     ebx
        add     esp,10h
        retn    0

proc HumanPlayer_GetMouseDeltaXForPhase c bPhaseMask

        .get_mask_value:
        mov     eax,dword[bPhaseMask]
        dec     eax
        cmp     eax,8-1
        jae     .zero

        .get_delta:
        mov     eax,dword[Mouse_apvAnalogX_Tbl+eax*4]
        fld     dword[eax]
        fmul    dword[InputOptions_vCurMouseSensX]
        ret

        .zero:
        fldz
        ret
endp

proc HumanPlayer_GetMouseDeltaYForPhase c bPhaseMask

        .get_mask_value:
        mov     eax,dword[bPhaseMask]
        dec     eax
        cmp     eax,8-1
        jae     .zero

        .get_delta:
        mov     eax,dword[Mouse_apvAnalogY_Tbl+eax*4]
        fld     dword[eax]
        fmul    dword[InputOptions_vCurMouseSensY]
        ret

        .zero:
        fldz
        ret
endp

proc HumanPlayer_GetMouseDeltaYForPhaseNoInv c bPhaseMask ; ignore invert mouse setting

        .get_mask_value:
        mov     eax,dword[bPhaseMask]
        dec     eax
        cmp     eax,8-1
        jae     .zero

        .get_delta:
        mov     eax,dword[Mouse_apvAnalogY_Tbl+eax*4]
        fld     dword[eax]
        fmul    dword[InputOptions_vCurMouseSensYIgn]
        ret

        .zero:
        fldz
        ret
endp

proc HumanPlayerInput_GetChannel0 c ptHumanPlayer

        .check_channellock:
        cmp     dword[HumanPlayerInput_IsRunning],FALSE
        je      .zero
        mov     eax,dword[ptHumanPlayer]
        cmp     byte[eax+250h],FALSE ;ptHumanPlayer->isLockChannel
        jne     .zero

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .check_phase_interp_off

        .check_phase_interp_on:
        mov     eax,dword[Flow_nCurrentPhase]
        cmp     eax,NFL_FLOW_PHASE_RUN
        je      .get_analogx_p1_interp_on
        cmp     eax,NFL_FLOW_PHASE_INTERP
        je      .get_analogx_p2_interp_on
        fldz
        ret

        .get_analogx_p1_interp_on:
        mov     eax,dword[ptHumanPlayer]
        fld     dword[eax+1B0h] ;ptHumanPlayer->avChannel[0]
        fsub    dword[HumanPlayerInput_vChannel0]
        ret

        .get_analogx_p2_interp_on:
        ccall   HumanPlayer_GetMouseDeltaXForPhase,NFL_FLOW_PHASE_MASK_INTERP
        ret

        .check_phase_interp_off:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_RUN
        je      .get_analogx_p1_interp_off
        fldz
        ret

        .get_analogx_p1_interp_off:
        mov     eax,dword[ptHumanPlayer]
        fld     dword[eax+1B0h] ;ptHumanPlayer->avChannel[0]
        ret

        .zero:
        fldz
        ret
endp

proc HumanPlayerInput_GetChannel1 c ptHumanPlayer

        .check_channellock:
        cmp     dword[HumanPlayerInput_IsRunning],FALSE
        je      .zero
        mov     eax,dword[ptHumanPlayer]
        cmp     byte[eax+250h],FALSE ;ptHumanPlayer->isLockChannel
        jne     .zero

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .check_phase_interp_off

        .check_phase_interp_on:
        mov     eax,dword[Flow_nCurrentPhase]
        cmp     eax,NFL_FLOW_PHASE_RUN
        je      .get_analogy_p1_interp_on
        cmp     eax,NFL_FLOW_PHASE_INTERP
        je      .get_analogy_p2_interp_on
        fldz
        ret

        .get_analogy_p1_interp_on:
        mov     eax,dword[ptHumanPlayer]
        fld     dword[eax+1B4h] ;ptHumanPlayer->avChannel[1]
        fsub    dword[HumanPlayerInput_vChannel1]
        ret

        .get_analogy_p2_interp_on:
        ccall   HumanPlayer_GetMouseDeltaYForPhase,NFL_FLOW_PHASE_MASK_INTERP
        ret

        .check_phase_interp_off:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_RUN
        je      .get_analogy_p1_interp_off
        fldz
        ret

        .get_analogy_p1_interp_off:
        mov     eax,dword[ptHumanPlayer]
        fld     dword[eax+1B4h] ;ptHumanPlayer->avChannel[1]
        ret

        .zero:
        fldz
        ret
endp

loc_45E07E: ; HumanPlayerInput_ReadChannels

        .var_8 = -8

        mov     edi,edx

        .get_deltax:
        ccall   HumanPlayer_GetMouseDeltaXForPhase,NFL_FLOW_PHASE_MASK_RUN
        fstp    dword[esi] ;avChannel[0]

        .get_deltay:
        ccall   HumanPlayer_GetMouseDeltaYForPhase,NFL_FLOW_PHASE_MASK_RUN
        fstp    dword[esi+4] ;avChannel[1]

        .save_deltas_backup:
        mov     eax,dword[esi]
        mov     ecx,dword[esi+4]
        mov     dword[HumanPlayerInput_vChannel0],eax
        mov     dword[HumanPlayerInput_vChannel1],ecx
        mov     dword[HumanPlayerInput_IsRunning],TRUE

        .back:
        mov     edx,edi
        mov     edi,dword[PATCHER_ADDR_TRAP] ;dword_BC210C:0x00BC210C
        .fixup1 = $-4
        mov     eax,edi
        and     eax,1
        mov     dword[esp+14h+.var_8+4],ebx
        jmp     near PATCHER_JUMP_TRAP ;loc_45E09D
        .fixup2 = $-4

loc_45E0E4: ; HumanPlayerInput_ReadChannels

        .var_8 = -8

        ; do nothing, skip invert mouse and sensitivity changes

        .back:
        mov     edx,edi
        mov     dword[esp+14h+.var_8+4],ebx
        and     edx,100h
        mov     eax,edi
        mov     dword[esp+14h+.var_8],edx
        and     eax,4000h
        mov     ecx,edi
        mov     edx,edi
        and     ecx,200h
        and     edx,400h
        jmp     near PATCHER_JUMP_TRAP ;loc_45E159
        .fixup1 = $-4

loc_4612D7: ; Human_UpdateBody

        fcomp   dword[ebp+1E4h]
        fnstsw  ax
        push    esi
        movzx   esi,ax

        .is_player:
        mov     ax,word[PATCHER_ADDR_TRAP] ;HumanPlayer_eQTaskType:0x005385B0
        .fixup1 = $-4
        cmp     ax,word[ebx+1Ch] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tQTask.eQTaskType
        jne     .get_analogx

        .get_analogx_player:
        ccall   HumanPlayerInput_GetChannel0,ebx
        jmp     .back

        .get_analogx:
        fld     dword[ebx+1B0h] ;ptHuman->avChannel[0]

        .back:
        mov     eax,esi
        pop     esi
        xor     ecx,ecx
        jmp     near PATCHER_JUMP_TRAP ;loc_4612E5
        .fixup2 = $-4

loc_464826: ; HumanView_UpdateView

        .a2 = 8

        ;test    ah,40h
        ;jz      .zoomed

        .is_player:
        mov     ax,word[PATCHER_ADDR_TRAP] ;HumanPlayer_eQTaskType:0x005385B0
        .fixup1 = $-4
        cmp     ax,word[esi+1Ch] ;ptHuman->tBoneDynCubeObj.tModelObj.tDynCubeObj.tQObj.tQTask.eQTaskType
        jne     .get_analogy

        .get_analogy_player:
        ccall   HumanPlayerInput_GetChannel1,esi
        jmp     .back

        .get_analogy:
        fld     dword[esi+1B4h] ;ptHuman->avChannel[1]

        .back:
        fmul    qword[PATCHER_ADDR_TRAP] ;dbl_5335C0:0x005335C0 -> 0.5f
        .fixup2 = $-4
        fstp    dword[esp+10h+.a2]
        jmp     near PATCHER_JUMP_TRAP ;loc_46484D
        .fixup3 = $-4

loc_483455: ; HumanCamera_MovementControlInput

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .check_phase_interp_off

        .check_phase_interp_on:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        jne     .zero_analogy_p2

        .get_analogy_p2:
        ccall   HumanPlayer_GetMouseDeltaYForPhase,NFL_FLOW_PHASE_MASK_INTERP
        jmp     .back

        .zero_analogy_p2:
        fldz
        jmp     .back

        .check_phase_interp_off:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_RUN
        jne     .zero_analogy_p1

        .get_analogy_p1:
        ccall   HumanPlayer_GetMouseDeltaYForPhase,NFL_FLOW_PHASE_MASK_RUN
        jmp     .back

        .zero_analogy_p1:
        fldz
        ;jmp     .back

        .back:
        fadd    st0,st0 ; x2 sensitivity seems to match 1st person sensitivity
        jmp     near PATCHER_JUMP_TRAP ;loc_48346D
        .fixup1 = $-4

loc_4834AB: ; HumanCamera_MovementControlInput

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .check_phase_interp_off

        .check_phase_interp_on:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        jne     .zero_analogx_p2

        .get_analogx_p2:
        ccall   HumanPlayer_GetMouseDeltaXForPhase,NFL_FLOW_PHASE_MASK_INTERP
        jmp     .back

        .zero_analogx_p2:
        fldz
        jmp     .back

        .check_phase_interp_off:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_RUN
        jne     .zero_analogx_p1

        .get_analogx_p1:
        ccall   HumanPlayer_GetMouseDeltaXForPhase,NFL_FLOW_PHASE_MASK_RUN
        jmp     .back

        .zero_analogx_p1:
        fldz
        ;jmp     .back

        .back:
        fadd    st0,st0 ; x2 sensitivity seems to match 1st person sensitivity
        fchs ; direction is inverted for some reason
        jmp     near PATCHER_JUMP_TRAP ;loc_4834B7
        .fixup1 = $-4

loc_483E57: ; HumanCamera_MovementControlInput

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .check_phase_interp_off

        .check_phase_interp_on:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        jne     .zero_analogx_p2

        .get_analogx_p2:
        ccall   HumanPlayer_GetMouseDeltaXForPhase,NFL_FLOW_PHASE_MASK_INTERP
        jmp     .back

        .zero_analogx_p2:
        fldz
        jmp     .back

        .check_phase_interp_off:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_RUN
        jne     .zero_analogx_p1

        .get_analogx_p1:
        ccall   HumanPlayer_GetMouseDeltaXForPhase,NFL_FLOW_PHASE_MASK_RUN
        jmp     .back

        .zero_analogx_p1:
        fldz
        ;jmp     .back

        .back:
        fadd    st0,st0 ; x2 sensitivity seems to match 1st person sensitivity
        fchs ; direction is inverted for some reason
        jmp     near PATCHER_JUMP_TRAP ;loc_483E63
        .fixup1 = $-4

loc_483E67: ; HumanCamera_DeathCameraControlInput

        .check_interp:
        ccall   Flow_IsInterpSuppressed
        test    eax,eax
        jnz     .check_phase_interp_off

        .check_phase_interp_on:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_INTERP
        jne     .zero_analogy_p2

        .get_analogy_p2:
        ccall   HumanPlayer_GetMouseDeltaYForPhase,NFL_FLOW_PHASE_MASK_INTERP
        jmp     .back

        .zero_analogy_p2:
        fldz
        jmp     .back

        .check_phase_interp_off:
        cmp     dword[Flow_nCurrentPhase],NFL_FLOW_PHASE_RUN
        jne     .zero_analogy_p1

        .get_analogy_p1:
        ccall   HumanPlayer_GetMouseDeltaYForPhase,NFL_FLOW_PHASE_MASK_RUN
        jmp     .back

        .zero_analogy_p1:
        fldz
        ;jmp     .back

        .back:
        fadd    st0,st0 ; x2 sensitivity seems to match 1st person sensitivity
        jmp     near PATCHER_JUMP_TRAP ;loc_483E73
        .fixup1 = $-4
