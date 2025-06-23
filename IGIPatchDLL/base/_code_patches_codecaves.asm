;--------------------------------------------------
; cursor fix
;--------------------------------------------------

proc Cursor_GetFullscreenCursorPos c hWnd

        locals
                Pos POINT
        endl

        push    ebx
        lea     ebx,[Pos]
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
                Cursor_PosX rd 1
                Cursor_PosY rd 1
        endl

        .get_pos:
        mov     ecx,dword[PATCH_TEMP_ADDR] ;Cursor_nMouseX:0x0057BC58
        .fixup1 = $-4
        mov     edx,dword[PATCH_TEMP_ADDR] ;Cursor_nMouseY:0x0057BC5C
        .fixup2 = $-4

        cmp     dword[AppContext_tAppContext2.isBorderless],0
        je      .end

        .save_pos:
        mov     dword[Cursor_PosX],ecx
        mov     dword[Cursor_PosY],edx

        .scale_posx:
        fild    dword[Cursor_PosX]
        fmul    dword[Cursor_XSensMult]
        fistp   dword[Cursor_PosX]

        .scale_posy:
        fild    dword[Cursor_PosY]
        fmul    dword[Cursor_YSensMult]
        fistp   dword[Cursor_PosY]

        .load_pos:
        mov     ecx,dword[Cursor_PosX]
        mov     edx,dword[Cursor_PosY]

        .end:
        mov     eax,1
        ret
endp

proc Cursor_CalcCursorPos c

        mov     eax,dword[PATCH_TEMP_ADDR] ;AppContext_tAppContext.hWnd:0x005C8BC4
        .fixup1 = $-4

        cmp     dword[PATCH_TEMP_ADDR],0 ;AppContext_tAppContext.isFullscreen:0x005C8C00
        .fixup2 = $-1-4
        je      .windowed

        .fullscreen:
        ccall   Cursor_GetFullscreenCursorPos,eax
        ret

        .windowed:
        ccall   Cursor_GetWindowedCursorPos,eax
        ret
endp

proc Cursor_UpdatePosition c

        push    ebx esi edi
        mov     ebx,ecx

        ccall   Cursor_CalcCursorPos
        test    eax,eax
        jz      .end
        mov     esi,ecx
        mov     edi,edx

        .clamp_posx:
        cmp     esi,0x80000000
        sbb     eax,eax
        and     esi,eax
        mov     eax,dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup1 = $-4
        dec     eax
        cmp     esi,eax
        sbb     ecx,ecx
        and     esi,ecx
        mov     edx,eax
        not     ecx
        and     edx,ecx
        or      esi,edx

        .clamp_posy:
        cmp     edi,0x80000000
        sbb     eax,eax
        and     edi,eax
        mov     eax,dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup2 = $-4
        dec     eax
        cmp     edi,eax
        sbb     ecx,ecx
        and     edi,ecx
        mov     edx,eax
        not     ecx
        and     edx,ecx
        or      edi,edx

        .set_pos:
        mov     dword[ebx+24h],esi ;this->nX
        mov     dword[ebx+28h],edi ;this->nY

        .end:
        pop     edi esi ebx
        ret
endp

proc Cursor_RunHandler c this

        push    ebx
        mov     ebx,dword[this]
        mov     ecx,ebx
        ccall   Cursor_UpdatePosition
        mov     eax,dword[ebx+3Ch] ;this->isButtonDown
        mov     edx,dword[PATCH_TEMP_ADDR] ;Mouse_tMouse_bButton:0x00C28F8C
        .fixup1 = $-4
        and     edx,1
        mov     dword[ebx+38h],eax ;this->isPrevButtonDown
        mov     dword[ebx+3Ch],edx ;this->isButtonDown
        pop     ebx
        ret
endp

proc Cursor_UpdateSensMult c nWindowSizeX,nWindowSizeY

        locals
                Screen_SizeX rd 1
                Screen_SizeY rd 1
        endl

        invoke  GetSystemMetrics,SM_CXSCREEN
        mov     dword[Screen_SizeX],eax
        invoke  GetSystemMetrics,SM_CYSCREEN
        mov     dword[Screen_SizeY],eax

        .posx_ratio:
        fld1
        fimul   dword[nWindowSizeX]
        fidiv   dword[Screen_SizeX]
        fstp    dword[Cursor_XSensMult]

        .scale_ratio:
        fld1
        fimul   dword[nWindowSizeY]
        fidiv   dword[Screen_SizeY]
        fstp    dword[Cursor_YSensMult]

        .end:
        ret
endp

loc_491BE9:

        cmp     dword[PATCH_TEMP_ADDR],0 ;AppContext_tAppContext.isFullscreen:0x005C8C00
        .fixup1 = $-1-4
        jne     .back
        cmp     dword[AppContext_tAppContext2.isBorderless],0
        je      .back

        .update:
        ccall   Cursor_UpdateSensMult,dword[ebp+4],dword[ebp+8]

        .back:
        mov     eax,dword[PATCH_TEMP_ADDR] ;AppContext_tAppContext.hWnd:0x005C8BC4
        .fixup2 = $-4
        push    0
        push    0xFFFFFFF0
        jmp     near PATCH_TEMP_PROC ;loc_491BF2
        .fixup3 = $-4

;--------------------------------------------------
; Improved timer resolution
;--------------------------------------------------

proc CheckAPIAvailable_QPC c

        invoke  QueryPerformanceFrequency,Timer_lpCount
        test    eax,eax
        jz      .end
        mov     dword[bIsAPIAvailable_QPC],1
        .end:
        ret
endp

proc CheckAPIAvailable_tGT c

        locals
                ptimecaps rd 2
                sizeof.ptimecaps = 8
        endl

        lea     eax,[ptimecaps]
        mov     dword[eax],1 ; assume wPeriodMin is 1ms by default
        invoke  timeGetDevCaps,eax,sizeof.ptimecaps
        test    eax,eax
        jnz     .end ; MMSYSERR_NOERROR = 0
        mov     dword[bIsAPIAvailable_tGT],1
        .end:
        mov     ecx,dword[ptimecaps] ; wPeriodMin
        mov     dword[uiMaxSysTimerRes],ecx
        ret
endp

Timer_GetPerformanceCounter: ; copied from IGI2

        .time = -8

        sub     esp,8
        lea     eax,[esp+8+.time]
        push    eax
        call    dword[QueryPerformanceCounter]
        test    eax,eax
        jz      .loc_43800E
        mov     ecx,dword[esp+8+.time+4]
        mov     edx,dword[esp+8+.time]
        push    ebx
        push    ebp
        mov     ebp,dword[Timer_lpCount]
        push    esi
        push    edi
        mov     edi,dword[Timer_lpCount+4]
        push    edi
        push    ebp
        push    ecx
        push    edx
        call    __alldvrm
        push    0
        push    1000
        push    ebx
        push    ecx
        mov     esi,eax
        mov     dword[esp+28h+.time+4],edx
        call    __allmul
        push    edi
        push    ebp
        push    edx
        push    eax
        call    __alldiv
        imul    esi,1000
        pop     edi
        add     eax,esi
        pop     esi
        pop     ebp
        pop     ebx
        add     esp,8
        retn    0
        .loc_43800E:
        push    cstrTimerAPIError_QPC
        call    near PATCH_TEMP_PROC ;_LDebug_Error:0x004AF7B0
        .fixup1 = $-4
        add     esp,4
        .abort: ; IGI1 does not use abort()
        jmp     .abort

proc Timer_GetSystemTime c

        push    esi edi
        mov     esi,dword[uiMaxSysTimerRes]
        invoke  timeBeginPeriod,esi
        invoke  timeGetTime
        mov     edi,eax
        invoke  timeEndPeriod,esi
        mov     eax,edi
        pop     edi esi
        ret
endp

Timer_Open_CodeCave:

        ccall   CheckAPIAvailable_QPC
        ccall   CheckAPIAvailable_tGT

        .qpc:
        cmp     dword[bIsAPIAvailable_QPC],0
        je      .tgt
        ccall   Timer_GetPerformanceCounter
        jmp     .end

        .tgt:
        cmp     dword[bIsAPIAvailable_tGT],0
        je      .gtc
        ccall   Timer_GetSystemTime
        jmp     .end

        .gtc:
        invoke  GetTickCount

        .end:
        mov     dword[Timer_nStartTime],eax
        retn    0

Timer_Read_CodeCave: ; TODO: check time wrap

        .qpc:
        cmp     dword[bIsAPIAvailable_QPC],0
        je      .tgt
        ccall   Timer_GetPerformanceCounter
        jmp     .end

        .tgt:
        cmp     dword[bIsAPIAvailable_tGT],0
        je      .gtc
        ccall   Timer_GetSystemTime
        jmp     .end

        .gtc:
        invoke  GetTickCount

        .end:
        sub     eax,dword[Timer_nStartTime]
        retn    0

;--------------------------------------------------
; borderless window patch
;--------------------------------------------------

proc AppContext_SetBorderless c isBorderless

        xor     eax,eax
        cmp     dword[isBorderless],0
        setne   al
        mov     dword[AppContext_tAppContext2.isBorderless],eax
        ret
endp

proc AppContext_IsBorderless c

        mov     eax,dword[AppContext_tAppContext2.isBorderless]
        ret
endp

proc Main_ParseBorderlessCB c

        ccall   AppContext_SetBorderless,1
        ret
endp

loc_48F724:

        .init_borderless:
        ccall   AppContext_SetBorderless,0

        .parse_borderless:
        push    Main_ParseBorderlessCB
        push    cstrBorderless
        call    near PATCH_TEMP_PROC ;AppMain_ParseCmdLineArgs:0x0048F360
        .fixup1 = $-4
        add     esp,4*2

        .back:
        mov     esi,dword[GetSystemMetrics]
        jmp     near PATCH_TEMP_PROC ;loc_48F72A
        .fixup2 = $-4

loc_48F759:

        test    eax,eax ; eax = AppContext_IsFullscreen()
        jz      .windowed

        .fullscreen:
        mov     eax,dword[dwFullscreenStyle]
        jmp     .back

        .windowed:
        cmp     dword[AppContext_tAppContext2.isBorderless],0
        jne     .windowed_borderless

        .windowed_border:
        mov     eax,dword[dwWindowedStyle]
        jmp     .back

        .windowed_borderless:
        mov     eax,dword[dwBorderlessStyle]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_48F767
        .fixup1 = $-4

loc_494FB6:

        test    eax,eax ; eax = AppContext_IsFullscreen()
        jz      .windowed

        .fullscreen:
        mov     eax,dword[dwFullscreenStyle]
        jmp     .back

        .windowed:
        cmp     dword[AppContext_tAppContext2.isBorderless],0
        jne     .windowed_borderless

        .windowed_border:
        mov     eax,dword[dwWindowedStyle]
        jmp     .back

        .windowed_borderless:
        mov     eax,dword[dwBorderlessStyle]

        .back:
        lea     edx,[esp+14h-10h]
        jmp     near PATCH_TEMP_PROC ;loc_494FC8
        .fixup1 = $-4

proc AppContext_IsNotWindowed c

        mov     eax,dword[PATCH_TEMP_ADDR] ;AppContext_tAppContext.isFullscreen:0x005C8C00
        .fixup1 = $-4
        or     eax,dword[AppContext_tAppContext2.isBorderless]
        ret
endp

loc_48A466:

        .progressbar_posx:
        ccall   AppContext_IsNotWindowed
        test    eax,eax
        jz      .progressbar_posx_windowed
        .progressbar_posx_borderless:
        invoke  GetSystemMetrics,SM_CXSCREEN
        jmp     .progressbar_posx_set
        .progressbar_posx_windowed:
        mov     eax,dword[ebx+4]
        .progressbar_posx_set:
        sub     eax,640
        cdq
        sub     eax,edx
        sar     eax,1
        add     eax,40
        mov     dword[esi+8],eax

        .progressbar_posy:
        ccall   AppContext_IsNotWindowed
        test    eax,eax
        jz      .progressbar_posy_windowed
        .progressbar_posy_borderless:
        invoke  GetSystemMetrics,SM_CYSCREEN
        jmp     .progressbar_posy_set
        .progressbar_posy_windowed:
        mov     eax,dword[ebx+8]
        .progressbar_posy_set:
        sub     eax,480
        cdq
        sub     eax,edx
        sar     eax,1
        add     eax,440
        mov     dword[esi+0Ch],eax

        .back:
        lea     ecx,[esi+10h]
        push    0Ah
        push    230h
        push    ecx
        jmp     near PATCH_TEMP_PROC ;loc_48A499
        .fixup1 = $-4

loc_48A4AD:

        .background_size:
        ccall   AppContext_IsNotWindowed
        test    eax,eax
        jz      .background_size_windowed
        .background_size_borderless:
        invoke  GetSystemMetrics,SM_CXSCREEN
        mov     ebx,eax ; trash ebx
        invoke  GetSystemMetrics,SM_CYSCREEN
        mov     edx,eax
        mov     eax,ebx
        jmp     .back
        .background_size_windowed:
        mov     edx,dword[ebx+8]
        mov     eax,dword[ebx+4]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_48A4B3
        .fixup1 = $-4

loc_48A50D:

        .logo_posx:
        ccall   AppContext_IsNotWindowed
        test    eax,eax
        jz      .logo_posx_windowed
        .logo_posx_borderless:
        invoke  GetSystemMetrics,SM_CXSCREEN
        jmp     .logo_posx_set
        .logo_posx_windowed:
        mov     eax,dword[ebx+4]
        .logo_posx_set:
        sub     eax,640
        cdq
        sub     eax,edx
        sar     eax,1
        mov     dword[esp+48h+4],eax
        fild    dword[esp+48h+4]
        fstp    dword[ebp+4]

        .logo_posy:
        ccall   AppContext_IsNotWindowed
        test    eax,eax
        jz      .logo_posy_windowed
        .logo_posy_borderless:
        invoke  GetSystemMetrics,SM_CYSCREEN
        jmp     .logo_posy_set
        .logo_posy_windowed:
        mov     eax,dword[ebx+8]
        .logo_posy_set:
        sub     eax,480
        cdq
        sub     eax,edx
        sar     eax,1
        mov     dword[esp+48h+4],eax
        fild    dword[esp+48h+4]
        fstp    dword[ebp+8]

        .back:
        push    ebp
        jmp     near PATCH_TEMP_PROC ;loc_48A53E
        .fixup1 = $-4

;--------------------------------------------------
; display modes patch
;--------------------------------------------------

proc GetScreenBitsPerPixel

        push    esi edi
        invoke  GetDC,0
        test    eax,eax
        jz      .error
        mov     esi,eax
        invoke  GetDeviceCaps,esi,12 ;BITSPIXEL
        mov     edi,eax
        invoke  ReleaseDC,0,esi
        test    eax,eax
        jz      .error
        mov     eax,edi
        .end:
        pop     edi esi
        ret

        .error:
        invoke  MessageBoxA,0,cstrGetBPPError,0,MB_OK+MB_ICONERROR
        jmp     .error ; loop
endp

proc Config_EnumDisplayModeCB c ptDisplayMode ; fixed multiple issues: buffer overflow, incorrect signedness and invalid pointer

        locals
                nNumDisplayDevices rd 1
        endl

        push    ebx esi edi
        mov     esi,dword[ptDisplayMode]

        .check_valid:
        cmp     byte[esi+1Ch],0 ;ptDisplayMode.zDeviceIdentifier[0]
        je      .end
        cmp     dword[esi+4],640 ;ptDisplayMode.nWidth
        jb      .end
        cmp     dword[esi+8],480 ;ptDisplayMode.nHeight
        jb      .end
        mov     eax,dword[esi+10h] ;ptDisplayMode.nDepth
        cmp     eax,dword[Config_nScreenBPP] ; we only got 64 entries available, so display modes with low BPP are filtered out
        jne     .end
        mov     ecx,dword[PATCH_TEMP_ADDR] ;Config_nNumDisplayDevices:0x00567C90
        .fixup1 = $-4
        test    ecx,ecx
        jz      .end

        .loop_init:
        xor     ebx,ebx
        mov     dword[nNumDisplayDevices],ecx
        mov     edi,PATCH_TEMP_ADDR ;&Config_atDisplayDevice:0x00567C98
        .fixup2 = $-4
        .loop_body:
        lea     eax,[esi+1Ch] ;&ptDisplayMode.zDeviceIdentifier
        ccall   strncmp,eax,edi,128
        test    eax,eax
        jnz     .loop_update
        mov     eax,dword[edi+100h+12*MAXDISPLAYMODES] ;Config_atDisplayDevice[i].nNumDisplayModes
        cmp     eax,MAXDISPLAYMODES
        jae     .loop_update
        .add_displaymode:
        lea     ecx,[eax+eax*2]
        lea     ecx,[edi+100h+ecx*4] ;&Config_atDisplayDevice[i].tDisplayModeList[Config_atDisplayDevice[i].nNumDisplayModes]
        mov     edx,dword[esi+4] ;ptDisplayMode.nWidth
        mov     dword[ecx],edx ;ptConfigDisplayMode.nWidth
        mov     edx,dword[esi+8] ;ptDisplayMode.nHeight
        mov     dword[ecx+4],edx ;ptConfigDisplayMode.nHeight
        mov     edx,dword[esi+10h] ;ptDisplayMode.nBitsPerPixel
        mov     dword[ecx+8],edx ;ptConfigDisplayMode.nDepth
        inc     eax
        mov     dword[edi+100h+12*MAXDISPLAYMODES],eax ;Config_atDisplayDevice.nNumDisplayModes
        .loop_update:
        inc     ebx
        add     edi,sizeof.Config_atDisplayDevice/MAXDISPLAYDEVICES ; edi = &Config_atDisplayDevice[i]
        cmp     ebx,dword[nNumDisplayDevices]
        jb      .loop_body

        .end:
        pop     edi esi ebx
        ret
endp

loc_40449E: ; Config_FillScreenResolutionListBox

        .mode_to_id:
        mov     edx,dword[esi]
        and     edx,0xFFFF
        mov     ecx,dword[esi+4]
        shl     ecx,16
        or      edx,ecx

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4044B0
        .fixup1 = $-4

loc_404526: ; Config_GraphicOptionsSetResolution

        call    near PATCH_TEMP_PROC ;Config_GetActiveGraphicOptions:0x00404590
        .fixup1 = $-4

        .id_to_mode:
        mov     edx,esi
        shr     edx,16
        mov     ecx,esi
        and     ecx,0xFFFF

        .set_mode:
        mov     dword[eax],ecx
        mov     dword[eax+4],edx
        push    dword[Config_nScreenBPP]
        pop     dword[eax+8]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_404556
        .fixup2 = $-4

loc_40460C: ; Config_GraphicOptionsGetResolution

        ;mov     eax,ebp ;Config_tConfig.atPlayerProfile[i].tGraphicOptions.nDisplayWidth
        mov     ecx,dword[esp+30h-20h] ;Config_tConfig.atPlayerProfile[i].tGraphicOptions.nDisplayHeight
        mov     edx,dword[esp+30h-1Ch] ;Config_tConfig.atPlayerProfile[i].tGraphicOptions.nDisplayDepth
        cmp     dword[esi],ebp ;Config_GetActiveGraphicOptions.nWidth
        jne     .back
        cmp     dword[esi+4],ecx ;Config_GetActiveGraphicOptions.nHeight
        jne     .back
        cmp     dword[esi+8],edx ;Config_GetActiveGraphicOptions.nDepth
        jne     .back
        cmp     dword[Config_nScreenBPP],edx
        jne     .back

        .matched:
        mov     ebx,esi
        jmp     near PATCH_TEMP_PROC ;loc_404651
        .fixup1 = $-4

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_404643
        .fixup2 = $-4

loc_404651: ; Config_GraphicOptionsGetResolution

        test    ebx,ebx
        jz      .default_mode_to_id

        .mode_to_id:
        mov     eax,dword[ebx]
        and     eax,0xFFFF
        mov     ecx,dword[ebx+4]
        shl     ecx,16
        or      eax,ecx
        jmp     .back

        .default_mode_to_id:
        mov     eax,640
        and     eax,0xFFFF
        mov     ecx,480
        shl     ecx,16
        or      eax,ecx

        .back:
        mov     dword[esp+30h-18h+10h],PATCH_TEMP_ADDR ;sdefault:0x00567C74
        .fixup1 = $-4
        lea     esi,[esp+30h-18h]
        jmp     near PATCH_TEMP_PROC ;loc_40466F
        .fixup2 = $-4

loc_405A91: ; Config_VerifyGraphicConfig

        mov     edx,dword[esp+24h-8] ;Config_tConfig.atPlayerProfile[i].tGraphicOptions.nDisplayWidth
        mov     ecx,dword[esp+24h-4] ;Config_tConfig.atPlayerProfile[i].tGraphicOptions.nDisplayHeight
        ;mov     eax,ebp ;Config_tConfig.atPlayerProfile[i].tGraphicOptions.nDisplayDepth
        cmp     dword[esi],ebp ;Config_GetActiveGraphicOptions.nWidth
        jne     .back
        cmp     dword[esi+4],ecx ;Config_GetActiveGraphicOptions.nHeight
        jne     .back
        cmp     dword[esi+8],edx ;Config_GetActiveGraphicOptions.nDepth
        jne     .back
        cmp     dword[Config_nScreenBPP],edx
        jne     .back

        .matched:
        mov     ebx,esi
        jmp     near PATCH_TEMP_PROC ;loc_405AD5
        .fixup1 = $-4

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_405AC7
        .fixup2 = $-4

loc_405AD9: ; Config_VerifyGraphicConfig

        test    ebx,ebx
        jz      .copy_default

        .copy:
        mov     eax,dword[ebx]
        mov     ecx,dword[ebx+4]
        mov     dword[edx],eax
        mov     dword[edx+4],ecx
        push    dword[ebx+8]
        pop     dword[edx+8]
        jmp     .back

        .copy_default:
        mov     dword[edx],640
        mov     dword[edx+4],480
        push    dword[Config_nScreenBPP]
        pop     dword[edx+8]

        .back:
        mov     eax,dword[esp+24h-10h]
        jmp     near PATCH_TEMP_PROC ;loc_405AED
        .fixup1 = $-4

;--------------------------------------------------
; widescreen patch
;--------------------------------------------------

proc Display_GetAspectRatio_CodeCave c ; disable screen stretching

        fld1
        ret
endp

proc SetDisplayAspectRatio nWidth,nHeight

        locals
                v43Width dd 4.0
                v43Height dd 3.0
        endl

        .aspect_ratio:
        fild    dword[nWidth]
        fidiv   dword[nHeight]
        fstp    dword[Display_vAspectRatio]

        .rel_aspect_ratio:
        fild    dword[nWidth]
        fmul    dword[v43Height]
        fild    dword[nHeight]
        fmul    dword[v43Width]
        fdivp   st1,st0
        fstp    dword[Display_vRelAspectRatio]

        .end:
        ret
endp

loc_491C3F: ; Display_SetMode

        invoke  SetFocus

        stdcall SetDisplayAspectRatio,dword[ebp+4],dword[ebp+8]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_48285F
        .fixup1 = $-4

QCamera_Set_CodeCave:

        fld     dword[esp+10h]
        fmul    dword[Display_vRelAspectRatio]
        fstp    dword[esp+10h]

        .back:
        mov     edx,dword[esp+4]
        mov     eax,dword[esp+1Ch]
        jmp     near PATCH_TEMP_PROC ;loc_4D9878
        .fixup1 = $-4

ViewportQTask_New_CodeCave:

        fld     dword[esp+30h]
        fmul    dword[Display_vRelAspectRatio]
        fstp    dword[esp+30h]

        .back:
        push    esi
        push    0
        call    near PATCH_TEMP_PROC ;sub_4E8100:0x004E8100
        .fixup1 = $-4
        jmp     near PATCH_TEMP_PROC ;loc_4E8118
        .fixup2 = $-4

proc GetAdjustedObjectFOV vObjectFOV

        fld     dword[vObjectFOV]
        fmul    dword[Display_vRelAspectRatio]
        ret
endp

loc_482859: ; HumanCamera_RunHandler

        stdcall GetAdjustedObjectFOV,dword[esi+0DCh]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_48285F
        .fixup1 = $-4

;--------------------------------------------------
; debug patch
;--------------------------------------------------

proc GameFunctions_SetEnableDebugKeys c isEnableDebugKeys

        xor     eax,eax
        cmp     dword[isEnableDebugKeys],0
        setne   al
        mov     dword[PATCH_TEMP_ADDR],eax ;GameFunctions_isEnableDebugKeys:0x0057B194
        .fixup1 = $-4
        ret
endp

proc AppContext_SetDebugKeysState c isDebugKeys

        xor     eax,eax
        cmp     dword[isDebugKeys],0
        setne   al
        mov     dword[AppContext_tAppContext2.isDebugKeys],eax
        ccall   GameFunctions_SetEnableDebugKeys,eax
        ret
endp

proc AppContext_isDebugKeys c

        mov     eax,dword[AppContext_tAppContext2.isDebugKeys]
        ret
endp

proc Main_ParseNoLightmapsCB c

        push    1
        call    near PATCH_TEMP_PROC ;AppContext_SetLightmapsUsed:0x0048F240
        .fixup1 = $-4
        add     esp,4
        ret
endp

proc Main_ParseNoTerrainLightmapCB c

        push    1
        call    near PATCH_TEMP_PROC ;AppContext_SetTerrainLightmapsUsed:0x0048F260
        .fixup1 = $-4
        add     esp,4
        ret
endp

proc Main_ParseDebugTextCB c

        push    1
        call    near PATCH_TEMP_PROC ;AppContext_SetDebugtextState:0x0048F1E0
        .fixup1 = $-4
        add     esp,4
        ret
endp

proc Main_ParseDebugCB c

        push    1
        call    near PATCH_TEMP_PROC ;AppContext_SetDebugged:0x0048F1A0
        .fixup1 = $-4
        add     esp,4
        ret
endp

proc Main_ParseSmallCB c

        mov     byte[PATCH_TEMP_ADDR],1 ;AppContext_isFixmeSmall:0x005C8E00
        .fixup1 = $-1-4
        ret
endp

proc Main_ParseDebugKeysCB c

        ccall   AppContext_SetDebugKeysState,1
        ret
endp

loc_48F674: ; WinMain

        .init_params:
        ccall   AppContext_SetDebugKeysState,0

        .back:
        mov     ecx,48
        jmp     near PATCH_TEMP_PROC ;loc_48F679
        .fixup1 = $-4

loc_48F6D8: ; WinMain

        mov     ebx,PATCH_TEMP_PROC ;AppMain_ParseCmdLineArgs:0x0048F360
        .fixup1 = $-4

        .parse_params:
        push    Main_ParseNoLightmapsCB
        push    cstrNoLightmaps
        call    ebx ; AppMain_ParseCmdLineArgs()
        add     esp,4*2
        push    Main_ParseNoTerrainLightmapCB
        push    cstrNoTerrainLightmap
        call    ebx ; AppMain_ParseCmdLineArgs()
        add     esp,4*2
        push    Main_ParseDebugTextCB
        push    cstrDebugText
        call    ebx ; AppMain_ParseCmdLineArgs()
        add     esp,4*2
        push    Main_ParseDebugCB
        push    cstrDebug
        call    ebx ; AppMain_ParseCmdLineArgs()
        add     esp,4*2
        push    Main_ParseSmallCB
        push    cstrFixmeSmall
        call    ebx ; AppMain_ParseCmdLineArgs()
        add     esp,4*2
        push    Main_ParseDebugKeysCB
        push    cstrDebugKeys
        call    ebx ; AppMain_ParseCmdLineArgs()
        add     esp,4*2

        .back:
        xor     ebx,ebx
        lea     edx,[esp+49Ch-45Ch]
        lea     eax,[esp+49Ch-464h]
        jmp     near PATCH_TEMP_PROC ;loc_48F6E0
        .fixup2 = $-4
