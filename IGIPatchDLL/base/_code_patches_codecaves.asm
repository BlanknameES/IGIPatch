;--------------------------------------------------
; cursor fix
;--------------------------------------------------

proc GetWndCursorPos hWnd

        locals
                Pos POINT
        endl

        push    ebx
        lea     ebx,[Pos]
        invoke  GetCursorPos,ebx
        test    eax,eax
        jz      .end
        invoke  ScreenToClient,dword[hWnd],ebx
        test    eax,eax
        jz      .end
        .end:
        ;test    eax,eax
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

proc Cursor_UpdatePosition

        push    ebx esi edi
        mov     ebx,ecx

        cmp     dword[PATCH_TEMP_ADDR],0 ;AppContext.isFullscreen:0x005C8C00
        .fixup1 = $-1-4
        je      .windowed

        .fullscreen:
        mov     eax,dword[PATCH_TEMP_ADDR] ;AppContext.hWnd:0x005C8BC4
        .fixup2 = $-4
        stdcall GetWndCursorPos,eax
        test    eax,eax
        jz      .end
        mov     esi,ecx
        mov     edi,edx
        jmp     .clamp_posx

        .windowed:
        mov     esi,dword[PATCH_TEMP_ADDR] ;Cursor_nMouseX:0x0057BC58
        .fixup3 = $-4
        mov     edi,dword[PATCH_TEMP_ADDR] ;Cursor_nMouseY:0x0057BC5C
        .fixup4 = $-4

        .clamp_posx:
        cmp     esi,0x80000000
        sbb     eax,eax
        and     esi,eax
        mov     eax,dword[PATCH_TEMP_ADDR] ;Display_tActiveMode.nWidth:0x00C28B44
        .fixup5 = $-4
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
        .fixup6 = $-4
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

proc CheckAPIAvailable_QPC

        invoke  QueryPerformanceFrequency,ui64QPCFrequency
        test    eax,eax
        jz      .end
        mov     dword[bIsAPIAvailable_QPC],1
        .end:
        and     dword[bIsAPIAvailable_QPC],0 ; not implemented yet, disabled for now
        ret
endp

proc CheckAPIAvailable_tGT

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

proc CheckAPIAvailable_GTC64 ; TODO

        and     dword[bIsAPIAvailable_GTC64],0 ; not implemented yet
        .end:
        ret
endp

proc Timer_GetPerformanceCounter ; TODO

        xor     eax,eax
        ret
endp

proc Timer_GetSystemTime

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

proc Timer_GetTickCount64 ; TODO

        xor     eax,eax
        ;cdq
        ret
endp

Timer_Open_CodeCave: ; TODO: change Timer_nStartTime to 64 bits

        stdcall CheckAPIAvailable_QPC
        stdcall CheckAPIAvailable_tGT
        stdcall CheckAPIAvailable_GTC64

        .qpc:
        cmp     dword[bIsAPIAvailable_QPC],0
        je      .tgt
        stdcall Timer_GetPerformanceCounter
        jmp     .end

        .tgt:
        cmp     dword[bIsAPIAvailable_tGT],0
        je      .gtc64
        stdcall Timer_GetSystemTime
        jmp     .end

        .gtc64:
        cmp     dword[bIsAPIAvailable_GTC64],0
        je      .gtc
        stdcall Timer_GetTickCount64
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
        stdcall Timer_GetPerformanceCounter
        jmp     .end

        .tgt:
        cmp     dword[bIsAPIAvailable_tGT],0
        je      .gtc64
        stdcall Timer_GetSystemTime
        jmp     .end

        .gtc64:
        cmp     dword[bIsAPIAvailable_GTC64],0
        je      .gtc
        stdcall Timer_GetTickCount64
        jmp     .end

        .gtc:
        invoke  GetTickCount

        .end:
        sub     eax,dword[Timer_nStartTime]
        retn    0
