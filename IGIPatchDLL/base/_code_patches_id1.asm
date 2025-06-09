proc ApplyPatches_ID1 ; outdated

        push    ebx
        mov     ebx,1

        ; workaround for undefined symbol error
        mov     eax,PatchTrap

        .nocdcheck:
        cmp     dword[ini_opts_nocdcheck],0
        je      .timerspatch

        ; TODO

        .timerspatch:
        cmp     dword[ini_opts_timerspatch],0
        je      .end

        ; Improved timer resolution
        stdcall GetRealAddress,PMI_IGIExe,0x004901D0
        stdcall MPatchCodeCave,eax,Timer_Open_CodeCave,6+5+1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004901E0
        stdcall MPatchCodeCave,eax,Timer_Read_CodeCave,6+6+1
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     ebx
        ret
endp
