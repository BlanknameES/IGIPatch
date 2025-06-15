;--------------------------------------------------
; cursor fix
;--------------------------------------------------

proc Cursor_GetFullscreenCursorPos hWnd

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

proc Cursor_GetWindowedCursorPos hWnd

        locals
                PosX rd 1
                PosY rd 1
                ScreenSizeX rd 1
                ScreenSizeY rd 1
        endl

        .get_pos:
        mov     ecx,dword[PATCH_TEMP_ADDR] ;Cursor_nMouseX:0x0057BC58
        .fixup1 = $-4
        mov     edx,dword[PATCH_TEMP_ADDR] ;Cursor_nMouseY:0x0057BC5C
        .fixup2 = $-4

        cmp     dword[AppContext_tAppContext2.isBorderless],0
        je      .end

        .save_pos:
        mov     dword[PosX],ecx
        mov     dword[PosY],edx

        .scale_posx:
        fild    dword[PosX]
        fimul   dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup3 = $-4
        invoke  GetSystemMetrics,SM_CXSCREEN
        mov     dword[ScreenSizeX],eax
        fidiv   dword[ScreenSizeX]
        fistp   dword[PosX]

        .scale_posy:
        fild    dword[PosY]
        fimul   dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nHeight:0x00C28B48
        .fixup4 = $-4
        invoke  GetSystemMetrics,SM_CYSCREEN
        mov     dword[ScreenSizeY],eax
        fidiv   dword[ScreenSizeY]
        fistp   dword[PosY]

        .load_pos:
        mov     ecx,dword[PosX]
        mov     edx,dword[PosY]

        .end:
        mov     eax,1
        ret
endp

proc Cursor_CalcCursorPos

        mov     eax,dword[PATCH_TEMP_ADDR] ;AppContext_tAppContext.hWnd:0x005C8BC4
        .fixup1 = $-4

        cmp     dword[PATCH_TEMP_ADDR],0 ;AppContext_tAppContext.isFullscreen:0x005C8C00
        .fixup2 = $-1-4
        je      .windowed

        .fullscreen:
        stdcall Cursor_GetFullscreenCursorPos,eax
        ret

        .windowed:
        stdcall Cursor_GetWindowedCursorPos,eax
        ret
endp

proc Cursor_UpdatePosition

        push    ebx esi edi
        mov     ebx,ecx

        stdcall Cursor_CalcCursorPos
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
        stdcall Cursor_UpdatePosition
        mov     eax,dword[ebx+3Ch] ;this->isButtonDown
        mov     edx,dword[PATCH_TEMP_ADDR] ;Mouse_tMouse_bButton:0x00C28F8C
        .fixup1 = $-4
        and     edx,1
        mov     dword[ebx+38h],eax ;this->isPrevButtonDown
        mov     dword[ebx+3Ch],edx ;this->isButtonDown
        pop     ebx
        ret
endp

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
        .abort: ; IGI 1 does not use abort()
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
; borderless window
;--------------------------------------------------

proc Main_ParseBorderlessCB c

        mov     dword[AppContext_tAppContext2.isBorderless],1
        ret
endp

proc AppContext_SetBorderless c isBorderless

        movsx   eax,byte[isBorderless]
        mov     dword[AppContext_tAppContext2.isBorderless],eax
        ret
endp

proc AppContext_IsBorderless c

        mov     eax,dword[AppContext_tAppContext2.isBorderless]
        ret
endp

loc_48F674:

        ccall   AppContext_SetBorderless,0

        .back:
        mov     ecx,48
        jmp     near PATCH_TEMP_PROC ;loc_48F679
        .fixup1 = $-4

loc_48F6D8:

        push    Main_ParseBorderlessCB
        push    cstrBorderless
        call    near PATCH_TEMP_PROC ;AppMain_ParseCmdLineArgs:0x0048F360
        .fixup1 = $-4
        add     esp,4*2

        .back:
        lea     edx,[esp+49Ch-45Ch]
        lea     eax,[esp+49Ch-464h]
        jmp     near PATCH_TEMP_PROC ;loc_48F6E0
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
        mov     eax,dword[ebx+4]
        cmp     dword[AppContext_tAppContext2.isBorderless],0
        je      .progressbar_posx_set
        invoke  GetSystemMetrics,SM_CXSCREEN
        .progressbar_posx_set:
        sub     eax,640
        cdq
        sub     eax,edx
        sar     eax,1
        add     eax,40
        mov     dword[esi+8],eax

        .progressbar_posy:
        mov     eax,dword[ebx+8]
        cmp     dword[AppContext_tAppContext2.isBorderless],0
        je      .progressbar_posy_set
        invoke  GetSystemMetrics,SM_CYSCREEN
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

loc_48A50D:

        .logo_posx:
        mov     eax,dword[ebx+4]
        cmp     dword[AppContext_tAppContext2.isBorderless],0
        je      .logo_posx_set
        invoke  GetSystemMetrics,SM_CXSCREEN
        .logo_posx_set:
        sub     eax,640
        cdq
        sub     eax,edx
        sar     eax,1
        mov     dword[esp+48h+4],eax
        fild    dword[esp+48h+4]
        fstp    dword[ebp+4]

        .logo_posy:
        mov     eax,dword[ebx+8]
        cmp     dword[AppContext_tAppContext2.isBorderless],0
        je      .logo_posy_set
        invoke  GetSystemMetrics,SM_CYSCREEN
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
        add     edi,sizeof.Config_atDisplayDevice/5 ; edi = &Config_atDisplayDevice[i]
        cmp     ebx,dword[nNumDisplayDevices]
        jb      .loop_body

        .end:
        pop     edi esi ebx
        ret
endp

loc_40449E: ; Config_FillScreenResolutionListBox

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
        mov     edx,esi
        shr     edx,16
        mov     ecx,esi
        and     ecx,0xFFFF
        mov     dword[eax],ecx
        mov     dword[eax+4],edx
        push    dword[Config_nScreenBPP]
        pop     dword[eax+8]

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_404556
        .fixup2 = $-4

loc_40460C: ; Config_GraphicOptionsGetResolution

        ;mov     eax,ebp
        mov     ecx,dword[esp+30h-20h]
        mov     edx,dword[Config_nScreenBPP]
        cmp     dword[esi],ebp ;Config_GetActiveGraphicOptions.nWidth
        jne     .back
        cmp     dword[esi+4],ecx ;Config_GetActiveGraphicOptions.Height
        jne     .back
        cmp     dword[esi+8],edx ;Config_GetActiveGraphicOptions.nDepth
        jne     .back

        .found:
        mov     ebx,esi
        jmp     near PATCH_TEMP_PROC ;loc_404651
        .fixup1 = $-4

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_404643
        .fixup2 = $-4

loc_404651: ; Config_GraphicOptionsGetResolution

        xor     eax,eax
        test    ebx,ebx
        jz      .back

        mov     eax,dword[ebx]
        and     eax,0xFFFF
        mov     ecx,dword[ebx+4]
        shl     ecx,16
        or      eax,ecx

        .back:
        mov     dword[esp+30h-18h+10h],PATCH_TEMP_ADDR ;sdefault:0x00567C74
        .fixup1 = $-4
        lea     esi,[esp+30h-18h]
        jmp     near PATCH_TEMP_PROC ;loc_40466F
        .fixup2 = $-4

loc_405A91: ; Config_VerifyGraphicConfig

        ;mov     eax,ebp
        mov     ecx,dword[esp+24h-4]
        mov     edx,dword[esp+24h-8]
        cmp     dword[esi],ebp ;Config_GetActiveGraphicOptions.nWidth
        jne     .back
        cmp     dword[esi+4],ecx ;Config_GetActiveGraphicOptions.Height
        jne     .back
        cmp     dword[esi+8],edx ;Config_GetActiveGraphicOptions.nDepth
        jne     .back

        .found:
        mov     ebx,esi
        jmp     near PATCH_TEMP_PROC ;loc_405AD5
        .fixup1 = $-4

        .back:
        jmp     near PATCH_TEMP_PROC ;loc_405AC7
        .fixup2 = $-4

loc_405AD9: ; Config_VerifyGraphicConfig

        test    ebx,ebx
        jz      .default

        mov     eax,dword[ebx]
        mov     ecx,dword[ebx+4]
        mov     dword[edx],eax
        mov     dword[edx+4],ecx
        push    dword[ebx+8]
        pop     dword[edx+8]
        jmp     .back

        .default:
        mov     dword[edx],640
        mov     dword[edx+4],480
        mov     dword[edx+8],32

        .back:
        mov     eax,dword[esp+24h-10h]
        jmp     near PATCH_TEMP_PROC ;loc_405AED
        .fixup1 = $-4
