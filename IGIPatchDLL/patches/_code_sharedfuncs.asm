;------------------------------------------------------------
; shared functions
;------------------------------------------------------------

proc LDebug_AbortWithError c pStr

        .show_error:
        push    dword[pStr]
        call    near PATCHER_CALL_TRAP ;LDebug_Error:0x004AF7B0
        .fixup1 = $-4
        add     esp,4

        .abort: ; IGI lacks abort() function
        jmp     .abort
endp

align 16
Game_IsPaused:

        .get_game_ptr:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Game_ptGame:0x0057BABC
        .fixup1 = $-4
        test    eax,eax
        jz      .end

        .get_is_paused:
        movsx   eax,byte[eax+0E0h] ;Game_ptGame->isPaused

        .end:
        retn    0

align 16
Flow_GetTicks:

        .get_ticks:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;Flow_ptFlow:0x00567C8C
        .fixup1 = $-4
        mov     eax,dword[eax+34h] ;ptFlow->nTicks

        .end:
        retn    0

proc AnimController_GetTPFValue c

        .get:
        mov     eax,dword[PATCHER_ADDR_TRAP] ;AnimController_vTicksPerFrame:0x00A54658
        .fixup1 = $-4

        .end:
        ret
endp

proc AnimController_SetTPFValue c vTPF

        mov     eax,dword[vTPF]

        .set:
        mov     dword[PATCHER_ADDR_TRAP],eax ;AnimController_vTicksPerFrame:0x00A54658
        .fixup1 = $-4

        .end:
        ret
endp

DebugText_printf_NEW: ; identical to the original

        .zFormat = 4
        .pArgList = 8

        .check_enabled:
        mov     al,byte[PATCHER_ADDR_TRAP] ;DebugText_isEnabled:0x00A5EA75
        .fixup1 = $-4
        test    al,al
        jz      .end

        .print:
        mov     ecx,dword[esp+.zFormat]
        mov     edx,dword[PATCHER_ADDR_TRAP] ;DebugText_ptWindow:0x00A5EBD0
        .fixup2 = $-4
        lea     eax,[esp+.pArgList]
        push    eax
        push    ecx
        push    edx
        call    near PATCHER_CALL_TRAP ;TextWindow_vprintf:0x004E76E0
        .fixup3 = $-4
        add     esp,3*4

        .end:
        retn    0
