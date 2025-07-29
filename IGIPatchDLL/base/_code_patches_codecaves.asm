;--------------------------------------------------
; cursor fix
;--------------------------------------------------

proc Cursor_GetFullscreenCursorPos c hWnd

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
        mov     ecx,dword[PATCH_TEMP_ADDR] ;Cursor_nMouseX:0x0057BC58
        .fixup1 = $-4
        mov     edx,dword[PATCH_TEMP_ADDR] ;Cursor_nMouseY:0x0057BC5C
        .fixup2 = $-4

        cmp     dword[AppContext_tAppContext2.isBorderless],0
        je      .end

        .save_pos:
        mov     dword[Cursor_Pos+POINT.x],ecx
        mov     dword[Cursor_Pos+POINT.y],edx

        .scale_posx:
        fild    dword[Cursor_Pos+POINT.x]
        fmul    dword[Cursor_XSensMult]
        fistp   dword[Cursor_Pos+POINT.x]

        .scale_posy:
        fild    dword[Cursor_Pos+POINT.y]
        fmul    dword[Cursor_YSensMult]
        fistp   dword[Cursor_Pos+POINT.y]

        .load_pos:
        mov     ecx,dword[Cursor_Pos+POINT.x]
        mov     edx,dword[Cursor_Pos+POINT.y]

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
                Screen_Size POINT
        endl

        cmp     dword[PATCH_TEMP_ADDR],0 ;AppContext_tAppContext.isFullscreen:0x005C8C00
        .fixup1 = $-1-4
        jne     .end
        cmp     dword[AppContext_tAppContext2.isBorderless],0
        je      .end

        .get_screen_size_borderless:
        invoke  GetSystemMetrics,SM_CXSCREEN
        mov     dword[Screen_Size+POINT.x],eax
        invoke  GetSystemMetrics,SM_CYSCREEN
        mov     dword[Screen_Size+POINT.y],eax

        .posx_ratio:
        fld1
        fimul   dword[nWindowSizeX]
        fidiv   dword[Screen_Size+POINT.x]
        fstp    dword[Cursor_XSensMult]

        .posy_ratio:
        fld1
        fimul   dword[nWindowSizeY]
        fidiv   dword[Screen_Size+POINT.y]
        fstp    dword[Cursor_YSensMult]

        .end:
        ret
endp

loc_491BE9: ; Display_SetMode

        .update:
        ccall   Cursor_UpdateSensMult,dword[ebp+4],dword[ebp+8]

        .back:
        mov     eax,dword[PATCH_TEMP_ADDR] ;AppContext_tAppContext.hWnd:0x005C8BC4
        .fixup1 = $-4
        push    0
        push    0xFFFFFFF0
        jmp     near PATCH_TEMP_PROC ;loc_491BF2
        .fixup2 = $-4

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

proc SetScreenColorDepth

        push    esi edi

        mov     eax,dword[ini_sett_resolutionsbpp]
        cmp     eax,-1
        je      .auto_detect
        cmp     eax,16
        jge     .end

        .default:
        mov     eax,32
        jmp     .end

        .auto_detect: ; TODO: use EnumDisplaySettings instead?
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
        mov     dword[Config_nScreenBPP],eax
        pop     edi esi
        ret

        .error:
        invoke  MessageBoxA,0,cstrGetBPPError,0,MB_OK+MB_ICONERROR
        .abort: ; IGI1 does not use abort()
        jmp     .abort
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

proc SetDisplayAspectRatio nWidth,nHeight

        .store_aspect_ratio:
        fild    dword[nWidth]
        fidiv   dword[nHeight]
        fst     dword[Display_vAspectRatio]
        fmul    dword[Display_vAspectRatio34]
        fstp    dword[Display_vRelAspectRatio]

        .store_aspect_ratio_inverted:
        fld1
        fdiv    dword[Display_vRelAspectRatio]
        fstp    dword[Display_vInvAspectRatio]

        .end:
        ret
endp

loc_491C3F: ; Display_SetMode

        invoke  SetFocus

        stdcall SetDisplayAspectRatio,dword[ebp+4],dword[ebp+8]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_48285F
        .fixup1 = $-4

proc Display_GetAspectRatio c ; currently unused

        fld     dword[Display_vAspectRatio]
        ret
endp

proc Display_GetRelAspectRatio c ; get aspect ratio relative to 4:3

        fld     dword[Display_vRelAspectRatio]
        ret
endp

proc Display_GetInvAspectRatio c ; get inverted aspect ratio relative to 4:3

        fld     dword[Display_vInvAspectRatio]
        ret
endp

TransContext_Create_CodeCave:

        .vFOVX = 10h

        .set_vfovx:
        call    Display_GetRelAspectRatio
        fmul    dword[esp+34h+.vFOVX]
        fstp    dword[ebx+40h] ; ptTransContext->vFOVX = Display_GetRelAspectRatio() * vFOVX;

        .set_vfovy:
        fld     dword[Display_vAspectRatio34]
        fmul    dword[esp+34h+.vFOVX]
        fstp    dword[ebx+44h] ; ptTransContext->vFOVY = Display_vAspectRatio34 * vFOVX);

        .set_vscreenfovx:
        fld     dword[PATCH_TEMP_ADDR] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth:0x00BCABC8
        .fixup1 = $-4
        fdiv    dword[ebx+40h]
        fstp    dword[ebx+48h] ; ptTransContext->vScreenFOVX = RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth / ptTransContext->vFOVX;

        .set_vscreenfovy:
        fld     dword[ebx+48h]
        fstp    dword[ebx+4Ch] ; ptTransContext->vScreenFOVY = ptTransContext->vScreenFOVX;

        .set_vscreenoriginx:
        fld     dword[PATCH_TEMP_ADDR] ;ptTransContext->vScreenOriginX = RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vX:0x00BCABB8
        .fixup2 = $-4
        fadd    dword[PATCH_TEMP_ADDR] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth:0x00BCABC8
        .fixup3 = $-4
        fstp    dword[ebx+50h] ; ptTransContext->vScreenOriginX = RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vX + RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth;

        .set_vscreenoriginy:
        fld     dword[PATCH_TEMP_ADDR] ;ptTransContext->vScreenOriginX = RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vY:0x00BCABBC
        .fixup4 = $-4
        fadd    dword[PATCH_TEMP_ADDR] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfHeight:0x00BCABCC
        .fixup5 = $-4
        fstp    dword[ebx+54h] ; ptTransContext->vScreenOriginY = RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vY + RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfHeight;

        .set_isdraw:
        mov     dword[ebx+58h],1 ; ptTransContext->isDraw = 1;

        .set_elayer:
        mov     dword[ebx+60h],1 ; ptTransContext->eLayer = isDrawTRANSCONTEXT_LAYER_MIDDLE;

        .end:
        pop     edi
        pop     esi
        pop     ebx
        add     esp,28h
        retn    0

loc_49E02E: ; Direct3DRender_DrawRigidMesh

        .var224 = -224h
        .tNewTransContext = -190h
        .tNewTransContext.vFOVX = -190h+40h
        .tNewTransContext.vFOVY = -190h+44h
        .tNewTransContext.vScreenFOVX = -190h+48h
        .tNewTransContext.vScreenFOVY = -190h+4Ch
        .tNewTransContext.eLayer = -190h+60h

        .get_vfovx:
        mov     eax,dword[ebx+0ECh]
        fld     dword[PATCH_TEMP_ADDR+eax*4] ;Mesh3D_avOverrideFOV:0x00B81700
        .fixup1 = $-4
        fstp    dword[esp+238h+.var224]

        .set_vfovx:
        call    Display_GetRelAspectRatio
        fmul    dword[esp+238h+.var224]
        fstp    dword[esp+238h+.tNewTransContext.vFOVX]

        .set_vfovy:
        fld     dword[Display_vAspectRatio34]
        fmul    dword[esp+238h+.var224]
        fstp    dword[esp+238h+.tNewTransContext.vFOVY]

        .set_vscreenfovx:
        fld     dword[PATCH_TEMP_ADDR] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth:0x00BCABC8
        .fixup2 = $-4
        fdiv    dword[esp+238h+.tNewTransContext.vFOVX]
        fstp    dword[esp+238h+.tNewTransContext.vScreenFOVX]

        .set_vscreenfovy:
        fld     dword[esp+238h+.tNewTransContext.vScreenFOVX]
        fstp    dword[esp+238h+.tNewTransContext.vScreenFOVY]

        .set_elayer:
        mov     dword[esp+238h+.tNewTransContext.eLayer],0 ; tNewTransContext.eLayer = TRANSCONTEXT_LAYER_FRONT;

        .set_context:
        lea     ecx,[esp+238h+.tNewTransContext]
        push    ecx
        call    near PATCH_TEMP_PROC ;TransContext_SetActiveTransContext:0x00497E70
        .fixup3 = $-4
        add     esp,4

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_49E0B1
        .fixup4 = $-4

loc_49F00D: ; Direct3DRender_DrawSortedFaceGroup_Rigid

        .var244 = -244h
        .tNewTransContext = -224h
        .tNewTransContext.vFOVX = -224h+40h
        .tNewTransContext.vFOVY = -224h+44h
        .tNewTransContext.vScreenFOVX = -224h+48h
        .tNewTransContext.vScreenFOVY = -224h+4Ch
        .tNewTransContext.eLayer = -224h+60h
        .tOldTransContext = -13Ch

        .copy_context1:
        mov     ecx,42
        mov     esi,PATCH_TEMP_ADDR ;TransContext_tActiveTransContext:0x00BCAAE0
        .fixup1 = $-4
        lea     edi,[esp+298h+.tOldTransContext]
        rep     movsd

        .copy_context2:
        mov     ecx,42
        lea     esi,[esp+298h+.tOldTransContext]
        lea     edi,[esp+298h+.tNewTransContext]
        rep     movsd

        .get_vfovx:
        fld     dword[PATCH_TEMP_ADDR] ;Mesh3D_avOverrideFOV:0x00B81700
        .fixup2 = $-4
        fstp    dword[esp+298h+.var244]

        .set_vfovx:
        call    Display_GetRelAspectRatio
        fmul    dword[esp+298h+.var244]
        fstp    dword[esp+298h+.tNewTransContext.vFOVX]

        .set_vfovy:
        fld     dword[Display_vAspectRatio34]
        fmul    dword[esp+298h+.var244]
        fstp    dword[esp+298h+.tNewTransContext.vFOVY]

        .set_vscreenfovx:
        fld     dword[PATCH_TEMP_ADDR] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth:0x00BCABC8
        .fixup3 = $-4
        fdiv    dword[esp+298h+.tNewTransContext.vFOVX]
        fstp    dword[esp+298h+.tNewTransContext.vScreenFOVX]

        .set_vscreenfovy:
        fld     dword[esp+298h+.tNewTransContext.vScreenFOVX]
        fstp    dword[esp+298h+.tNewTransContext.vScreenFOVY]

        .set_elayer:
        mov     dword[esp+298h+.tNewTransContext.eLayer],0 ; tNewTransContext.eLayer = TRANSCONTEXT_LAYER_FRONT;

        .set_context:
        lea     eax,[esp+298h+.tNewTransContext]
        push    eax
        call    near PATCH_TEMP_PROC ;TransContext_SetActiveTransContext:0x00497E70
        .fixup4 = $-4
        add     esp,4

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_49F0A3
        .fixup5 = $-4

loc_49F5AF: ; Direct3DRender_DrawSortedFaceGroup_Lightmap

        .var1AC = -1ACh
        .tNewTransContext = -190h
        .tNewTransContext.vFOVX = -190h+40h
        .tNewTransContext.vFOVY = -190h+44h
        .tNewTransContext.vScreenFOVX = -190h+48h
        .tNewTransContext.vScreenFOVY = -190h+4Ch
        .tNewTransContext.eLayer = -190h+60h
        .tOldTransContext = -0A8h

        .copy_context1:
        mov     ecx,42
        mov     esi,PATCH_TEMP_ADDR ;TransContext_tActiveTransContext:0x00BCAAE0
        .fixup1 = $-4
        lea     edi,[esp+200h+.tOldTransContext]
        rep     movsd

        .copy_context2:
        mov     ecx,42
        lea     esi,[esp+200h+.tOldTransContext]
        lea     edi,[esp+200h+.tNewTransContext]
        rep     movsd

        .get_vfovx:
        fld     dword[PATCH_TEMP_ADDR] ;Mesh3D_avOverrideFOV:0x00B81700
        .fixup2 = $-4
        fstp    dword[esp+200h+.var1AC]

        .set_vfovx:
        call    Display_GetRelAspectRatio
        fmul    dword[esp+200h+.var1AC]
        fstp    dword[esp+200h+.tNewTransContext.vFOVX]

        .set_vfovy:
        fld     dword[Display_vAspectRatio34]
        fmul    dword[esp+200h+.var1AC]
        fstp    dword[esp+200h+.tNewTransContext.vFOVY]

        .set_vscreenfovx:
        fld     dword[PATCH_TEMP_ADDR] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth:0x00BCABC8
        .fixup3 = $-4
        fdiv    dword[esp+200h+.tNewTransContext.vFOVX]
        fstp    dword[esp+200h+.tNewTransContext.vScreenFOVX]

        .set_vscreenfovy:
        fld     dword[esp+200h+.tNewTransContext.vScreenFOVX]
        fstp    dword[esp+200h+.tNewTransContext.vScreenFOVY]

        .set_elayer:
        mov     dword[esp+200h+.tNewTransContext.eLayer],0 ; tNewTransContext.eLayer = TRANSCONTEXT_LAYER_FRONT;

        .set_context:
        lea     eax,[esp+200h+.tNewTransContext]
        push    eax
        call    near PATCH_TEMP_PROC ;TransContext_SetActiveTransContext:0x00497E70
        .fixup4 = $-4
        add     esp,4

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_49F645
        .fixup5 = $-4

loc_49F78B: ; Direct3DRender_DrawBoneMesh

        .var1D4 = -1D4h
        .tNewTransContext = -190h
        .tNewTransContext.vFOVX = -190h+40h
        .tNewTransContext.vFOVY = -190h+44h
        .tNewTransContext.vScreenFOVX = -190h+48h
        .tNewTransContext.vScreenFOVY = -190h+4Ch
        .tNewTransContext.eLayer = -190h+60h

        .get_vfovx:
        mov     eax,dword[ebp+0D4h]
        fld     dword[PATCH_TEMP_ADDR+eax*4] ;Mesh3D_avOverrideFOV:0x00B81700
        .fixup1 = $-4
        fstp    dword[esp+1E4h+.var1D4]

        .set_vfovx:
        call    Display_GetRelAspectRatio
        fmul    dword[esp+1E4h+.var1D4]
        fstp    dword[esp+1E4h+.tNewTransContext.vFOVX]

        .set_vfovy:
        fld     dword[Display_vAspectRatio34]
        fmul    dword[esp+1E4h+.var1D4]
        fstp    dword[esp+1E4h+.tNewTransContext.vFOVY]

        .set_vscreenfovx:
        fld     dword[PATCH_TEMP_ADDR] ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth:0x00BCABC8
        .fixup2 = $-4
        fdiv    dword[esp+1E4h+.tNewTransContext.vFOVX]
        fstp    dword[esp+1E4h+.tNewTransContext.vScreenFOVX]

        .set_vscreenfovy:
        fld     dword[esp+1E4h+.tNewTransContext.vScreenFOVX]
        fstp    dword[esp+1E4h+.tNewTransContext.vScreenFOVY]

        .set_elayer:
        mov     dword[esp+1E4h+.tNewTransContext.eLayer],0 ; tNewTransContext.eLayer = TRANSCONTEXT_LAYER_FRONT;

        .set_context:
        lea     ecx,[esp+1E4h+.tNewTransContext]
        push    ecx
        call    near PATCH_TEMP_PROC ;TransContext_SetActiveTransContext:0x00497E70
        .fixup3 = $-4
        add     esp,4

        .back:
        mov     esi,dword[esp+1E4h-1CCh]
        jmp     near PATCH_TEMP_PROC ;loc_49F80F
        .fixup4 = $-4

loc_4675E6: ; ComputerObject_ProjectRotatedPos

        .vOOZ = 8h

        call    Display_GetInvAspectRatio
        fmul    dword[esp+8+.vOOZ]
        fmul    dword[esi]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4675EC
        .fixup1 = $-4

loc_4676B0: ; ComputerObject_ProjectWorldPos

        .vOOZ = 10h
        .Real32x3_Rotate_tTemp = -0Ch

        call    Display_GetInvAspectRatio
        fmul    dword[esp+10h+.vOOZ]
        fmul    dword[esp+10h+.Real32x3_Rotate_tTemp]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4676B8
        .fixup1 = $-4

loc_46A550: ; ComputerMap_Trace

        .vAspect = -100h
        .var_FC = -0FCh

        fmul    dword[esp+128h+.vAspect]
        fmul    dword[ebp+40h]
        fstp    qword[esp+128h+.var_FC]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_46A557
        .fixup1 = $-4

loc_46BD84: ; Computer_RunHandler

        call    Display_GetRelAspectRatio
        fstp    dword[esi+98h]

        .back:
        fld     dword[esi+10Ch]
        jmp     near PATCH_TEMP_PROC ;loc_46BD8A
        .fixup1 = $-4

loc_4CFE74: ; Mesh3D_GetRigidMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4CFE7A
        .fixup2 = $-4

loc_4CFE95: ; Mesh3D_GetRigidMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4CFE9B
        .fixup2 = $-4

loc_4CFEB2: ; Mesh3D_GetRigidMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4CFEB8
        .fixup2 = $-4

loc_4CFEF2: ; Mesh3D_GetRigidMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4CFEF8
        .fixup2 = $-4

loc_4D0097: ; Mesh3D_GetBoneMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4D009D
        .fixup2 = $-4

loc_4D00B7: ; Mesh3D_GetBoneMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4D00BD
        .fixup2 = $-4

loc_4D00D4: ; Mesh3D_GetBoneMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4D00DA
        .fixup2 = $-4

loc_4D010A: ; Mesh3D_GetBoneMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4D0110
        .fixup2 = $-4

loc_4D02DD: ; Mesh3D_GetSplineMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4D02E3
        .fixup2 = $-4

loc_4D02FD: ; Mesh3D_GetSplineMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4D0303
        .fixup2 = $-4

loc_4D031A: ; Mesh3D_GetSplineMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4D0320
        .fixup2 = $-4

loc_4D0350: ; Mesh3D_GetSplineMeshLOD

        fld     dword[PATCH_TEMP_ADDR] ;TransContext_tActiveTransContext.vFOVY:0x00BCAB24
        .fixup1 = $-4
        fmul    dword[Display_vAspectRatio43]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_4D0356
        .fixup2 = $-4

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

;--------------------------------------------------
; custom main menu resolution
;--------------------------------------------------

proc SetMainMenuResolution

        mov     eax,dword[ini_sett_mainmenuresx]
        mov     ecx,dword[ini_sett_mainmenuresy]
        mov     edx,dword[ini_sett_mainmenuresbpp]

        .check_valid_width:
        cmp     eax,-1
        je      .check_valid_height
        cmp     eax,640
        jge     .check_valid_height
        mov     eax,640

        .check_valid_height:
        cmp     ecx,-1
        je      .check_valid_bpp
        cmp     ecx,480
        jge     .check_valid_bpp
        mov     ecx,480

        .check_valid_bpp:
        cmp     edx,-1
        je      .end
        cmp     edx,16
        jge     .end
        mov     edx,16

        .end:
        mov     dword[Display_MMResWidth],eax
        mov     dword[Display_MMResHeight],ecx
        mov     dword[Display_MMResBPP],edx
        ret
endp

loc_418B38: ; MenuManager_New

        .var_118 = -118h
        .var_114 = -114h
        .var_10C = -10Ch

        mov     eax,dword[Display_MMResWidth]
        mov     ecx,dword[Display_MMResHeight]
        mov     edx,dword[Display_MMResBPP]

        .check_res_width:
        cmp     eax,-1
        jne     .check_res_height

        .set_res_width_mirrored:
        mov     eax,dword[ebx+0Ch]

        .check_res_height:
        cmp     ecx,-1
        jne     .check_res_bpp

        .set_res_height_mirrored:
        mov     ecx,dword[ebx+10h]

        .check_res_bpp:
        cmp     edx,-1
        jne     .set_mode

        .set_res_bpp_mirrored:
        mov     edx,dword[ebx+14h]

        .set_mode:
        mov     dword[esp+130h+.var_118],eax ;tDisplayMode.nWidth
        mov     dword[esp+130h+.var_114],ecx ;tDisplayMode.nHeight
        mov     dword[esp+130h+.var_10C],edx ;tDisplayMode.nBitsPerPixel

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_418B50
        .fixup1 = $-4

loc_418BDF: ; MenuManager_New

        add     esp,4*2
        push    edx
        call    near PATCH_TEMP_PROC ;Display_SetMode:0x00491A90
        .fixup1 = $-4
        add     esp,4
        push    0
        push    0
        push    0
        call    near PATCH_TEMP_PROC ;Display_SetBackgroundColourFn:0x00491E70
        .fixup2 = $-4
        add     esp,4*3

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_418BE8
        .fixup3 = $-4

loc_421AB9: ; MenuScreen_UpdateInternalDataHandler

        .set_eulogo_width_offset:
        mov     dword[PATCH_TEMP_ADDR],18 ;dword_57BC0C:0x0057BC0C
        .fixup1 = $-4-4

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_421AE2
        .fixup2 = $-4

loc_421AEC: ; MenuScreen_UpdateInternalDataHandler

        .get_logo_width:
        ;mov     eax,dword[esi+98h]
        push    eax
        call    near PATCH_TEMP_PROC ;Picture_GetWidth:0x004B6E70
        .fixup1 = $-4
        add     esp,4
        mov     dword[esp+10h+4],eax
        fild    dword[esp+10h+4]
        fmul    dword[PATCH_TEMP_ADDR] ;flt_533504:0x00533504
        .fixup2 = $-4
        fistp   dword[esp+10h-8] ;nLogoHalfWidth

        .get_logo_posx:
        call    near PATCH_TEMP_PROC ;Display_GetActiveMode:0x00491CF0
        .fixup3 = $-4
        mov     eax,dword[eax+4]
        sar     eax,1
        add     eax,dword[PATCH_TEMP_ADDR] ;dword_57BC0C:0x0057BC0C
        .fixup4 = $-4
        sub     eax,dword[esp+10h-8] ;nLogoHalfWidth
        mov     dword[esp+10h+4],eax
        fild    dword[esp+10h+4]

        .update_logo_posx:
        mov     eax,dword[esi+98h]
        fstp    dword[eax+4]

        .get_logo_height:
        mov     eax,dword[esi+98h]
        push    eax
        call    near PATCH_TEMP_PROC ;Picture_GetHeight:0x004B6E80
        .fixup5 = $-4
        add     esp,4
        mov     dword[esp+10h+4],eax
        fild    dword[esp+10h+4]
        fmul    dword[PATCH_TEMP_ADDR] ;flt_533504:0x00533504
        .fixup6 = $-4
        fistp   dword[esp+10h-8] ;nLogoHalfHeight

        .get_logo_posy:
        call    near PATCH_TEMP_PROC ;Display_GetActiveMode:0x00491CF0
        .fixup7 = $-4
        mov     eax,dword[eax+8]
        sar     eax,1
        sub     eax,(480/2)+40 ;nLogoOffsetY
        add     eax,dword[esp+10h-8] ;nLogoHalfHeight
        mov     dword[esp+10h+4],eax
        fild    dword[esp+10h+4]

        .update_logo_posy:
        mov     eax,dword[esi+98h]
        fstp    dword[eax+8]

        .set_logo_unknown:
        mov     edx,dword[esi+98h]
        mov     dword[edx+20h],edi

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_421B53
        .fixup8 = $-4

proc BackgroundFX_GetMatrixScaleXMul c

        locals
                vOldWidth dd 640.0
        endl

        fild    dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup1 = $-4
        fdiv    dword[vOldWidth]
        ret
endp

proc BackgroundFX_GetMatrixScaleYMul c

        locals
                nOldHeight dd 480.0
        endl

        fild    dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup1 = $-4
        fdiv    dword[nOldHeight]
        ret
endp

proc BackgroundFX_CreateMatrix c ptMatrix,vAngle,vScale,vPivotX,vPivotY ; changed to scale with resolution, does not stretch/shrink horizontally

        locals
                vScaleXMul rd 1
                vScaleYMul rd 1
                ;vOldWidth dd 640.0
                ;vFloat05 dd 0.5
        endl

        push    ebx
        mov     ebx,dword[ptMatrix]
        ccall   BackgroundFX_GetMatrixScaleXMul
        fstp    dword[vScaleXMul]
        ccall   BackgroundFX_GetMatrixScaleYMul
        fstp    dword[vScaleYMul]

        .apply_scale_mul:
        fld     dword[vPivotX]
        fmul    dword[vScaleXMul]
        fstp    dword[vPivotX]
        fld     dword[vPivotY]
        fmul    dword[vScaleYMul]
        fstp    dword[vPivotY]
        fld     dword[vScale]
        fmul    dword[vScaleYMul]
        fstp    dword[vScale]

        ;.adjust_posx: ; center horizontally
        ;fld     dword[vOldWidth]
        ;fmul    dword[vScaleYMul]
        ;fisubr  dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B44
        ;.fixup1 = $-4
        ;fmul    dword[vFloat05]
        ;fadd    dword[vPivotX]
        ;fstp    dword[vPivotX]

        .fill_struct:
        fld     dword[vAngle]
        fcos
        fmul    dword[vScale]
        fstp    dword[ebx]
        fld     dword[vAngle]
        fsin
        fld     st
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
        mov     eax,dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup1 = $-4
        sar     eax,1
        sub     eax,(640/2) ;nHalfWidth
        mov     dword[esi+4],eax
        fiadd   dword[esi+4]
        fstp    dword[esi+4]

        .adjust_posy:
        fld     dword[esi+8]
        mov     eax,dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup2 = $-4
        sar     eax,1
        sub     eax,(480/2) ;nHalfHeight
        mov     dword[esi+8],eax
        fiadd   dword[esi+8]
        fstp    dword[esi+8]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_41A8AA
        .fixup3 = $-4

loc_41D7A3: ; InputBox_Draw

        .adjust_posx:
        mov     eax,dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup1 = $-4
        sar     eax,1
        sub     eax,(640/2) ;nHalfWidth
        add     eax,dword[esi+20h]
        add     eax,2
        mov     dword[esp+1A4h-190h],eax

        .adjust_posy:
        mov     eax,dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup2 = $-4
        sar     eax,1
        sub     eax,(480/2) ;nHalfHeight
        add     eax,dword[esi+24h]
        add     eax,2
        mov     dword[esp+1A4h-194h],eax

        .back:
        lea     edi,dword[esi+54h]
        jmp     near PATCH_TEMP_PROC ;loc_41D7BA
        .fixup3 = $-4

proc Q3DPicture_RegisterSize c ptStaticTilemap,vX,vY,vWidth,vHeight,nDepth ; copied from IGI2

        locals
                _ptQTilemap rd 1
                vY3 rd 1
                vXStep rd 1
                vXTemp rd 1
                y rd 1
                vYStep rd 1
        endl

        push    esi
        mov     esi,dword[ptStaticTilemap]
        push    edi
        mov     edi,dword[vX]
        mov     ecx,dword[esi]
        mov     dword[vXTemp],edi
        xor     edi,edi
        mov     dword[_ptQTilemap],ecx
        movsx   eax,word[ecx+4]
        mov     dword[ptStaticTilemap],eax
        mov     dword[y],edi
        fild    dword[ptStaticTilemap]
        movsx   edx,word[ecx+6]
        fdivr   dword[vWidth]
        mov     dword[ptStaticTilemap],edx
        cmp     edx,edi
        fstp    dword[vXStep]
        fild    dword[ptStaticTilemap]
        mov     dword[ptStaticTilemap],edi
        fdivr   dword[vHeight]
        fstp    dword[vYStep]
        jle     .loc_60B3F6
        push    ebx
        .loc_60B337:
        mov     edx,dword[vXTemp]
        xor     ebx,ebx
        test    eax,eax
        mov     dword[vX],edx
        jle     .loc_60B3D9
        mov     eax,dword[ptStaticTilemap]
        mov     edi,dword[vY]
        ;lea     edx,dword[ecx+eax*2+10h]
        lea     edx,dword[ecx+eax*1+10h]
        mov     dword[vWidth],edx
        .loc_60B354:
        mov     eax,dword[vWidth]
        ;mov     ax,word[eax]
        ;test    ax,ax
        mov     al,byte[eax]
        test    al,al
        jz      .loc_60B3BC
        fld     dword[vYStep]
        fadd    dword[vY]
        mov     ecx,dword[nDepth]
        mov     edx,dword[esi+24h]
        ;and     eax,0FFFFh
        and     eax,0FFh
        push    ecx             ; nDepth
        mov     ecx,dword[esi+0Ch]
        dec     eax
        fstp    dword[vY3]
        fld     dword[vXStep]
        fadd    dword[vX]
        push    edx             ; bQGraphicFlags
        mov     edx,dword[esi+1Ch]
        push    eax             ; nFrame
        mov     eax,dword[esi+10h]
        push    eax             ; vZ
        mov     eax,dword[esi+18h]
        fstp    dword[vHeight]
        push    ecx             ; vA
        mov     ecx,dword[esi+14h]
        push    edx             ; vB1
        push    eax             ; vG1
        mov     eax,dword[vY3]
        push    ecx             ; vR1
        mov     ecx,dword[vHeight]
        mov     edx,dword[esi]
        push    eax             ; vY4
        push    ecx             ; vX4
        push    eax             ; vY3
        mov     eax,dword[vX]
        push    eax             ; vX3
        push    edi             ; vY2
        push    ecx             ; vX2
        push    edi             ; vY1
        push    eax             ; vX1
        mov     eax,dword[edx+8]
        push    eax             ; ptQSprite
        call    near PATCH_TEMP_PROC ;QSprite_Register4AZ:0x004B53B0
        .fixup1 = $-4
        mov     ecx,dword[vHeight]
        add     esp,44h
        mov     dword[vX],ecx
        mov     ecx,dword[_ptQTilemap]
        .loc_60B3BC:
        mov     eax,dword[vWidth]
        mov     edx,dword[ptStaticTilemap]
        ;add     eax,2
        add     eax,1
        inc     ebx
        mov     dword[vWidth],eax
        inc     edx
        movsx   eax,word[ecx+4]
        cmp     ebx,eax
        mov     dword[ptStaticTilemap],edx
        jl      .loc_60B354
        .loc_60B3D9:
        fld     dword[vYStep]
        fadd    dword[vY]
        mov     edx,dword[y]
        movsx   edi,word[ecx+6]
        fstp    dword[vY]
        inc     edx
        cmp     edx,edi
        mov     dword[y],edx
        jl      .loc_60B337
        pop     ebx
        .loc_60B3F6:
        pop     edi
        pop     esi
        ret
endp

loc_421CB6: ; MenuScreen_DrawHandler

        push    -1 ; nDepth
        fild    dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup1 = $-4
        push    ecx
        fstp    dword[esp] ; vHeight
        fild    dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup2 = $-4
        push    ecx
        fstp    dword[esp] ; vWidth
        push    0 ; vY
        push    0 ; vX
        push    esi
        call    Q3DPicture_RegisterSize
        add     esp,18h

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_421CBF
        .fixup3 = $-4

;--------------------------------------------------
; dpi awareness patch
;--------------------------------------------------

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
