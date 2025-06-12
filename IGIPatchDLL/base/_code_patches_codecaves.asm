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
        fimul   dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B48
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
        call    near PATCH_TEMP_PROC ;_LDebug_Error:0x004444E0
        .fixup1 = $-4
        add     esp,4
        jmp     near PATCH_TEMP_PROC ;_abort:0x005F5484
        .fixup2 = $-4

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
