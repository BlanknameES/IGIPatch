proc ApplyPatches_ID0

        push    ebx
        mov     ebx,1

        ; workaround for undefined symbol error
        mov     eax,PatchTrap

        .nocdcheck:
        cmp     dword[ini_opts_nocdcheck],0
        je      .timerspatch

        ; check 1
        stdcall GetRealAddress,PMI_IGIExe,0x00402C32
        stdcall MPatchByte,eax,0x90
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00402C33
        stdcall MPatchDword,eax,0x90909090
        and     ebx,eax

        ; check 2
        stdcall GetRealAddress,PMI_IGIExe,0x004021E7
        stdcall MPatchWord,eax,0xC483
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004021E9
        stdcall MPatchByte,eax,0x08
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004021EA
        stdcall MPatchByte,eax,0xE9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004021EB
        stdcall MPatchDword,eax,0x0000004A
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004021EF
        stdcall MPatchWord,eax,0x9090
        and     ebx,eax

        ; check 3
        stdcall GetRealAddress,PMI_IGIExe,0x00415F41
        stdcall MPatchByte,eax,0xE9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00415F42
        stdcall MPatchDword,eax,0x0000004C
        and     ebx,eax

        ; check 4
        stdcall GetRealAddress,PMI_IGIExe,0x004162A9
        stdcall MPatchDword,eax,0x95600D89
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162AD
        stdcall MPatchWord,eax,0x0053
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162AF
        stdcall MPatchWord,eax,0xC483
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162B1
        stdcall MPatchByte,eax,0x0C
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162B2
        stdcall MPatchByte,eax,0xE9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162B3
        stdcall MPatchDword,eax,0x00000049
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162B7
        stdcall MPatchWord,eax,0x9090
        and     ebx,eax

        ; check 5
        stdcall GetRealAddress,PMI_IGIExe,0x00418CF7
        stdcall MPatchDword,eax,0x28389D89
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418CFB
        stdcall MPatchDword,eax,0x85880000
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418CFF
        stdcall MPatchDword,eax,0x000026C3
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418D03
        stdcall MPatchByte,eax,0xE9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418D04
        stdcall MPatchDword,eax,0x0000004B
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418D08
        stdcall MPatchDword,eax,0x90909090
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418D0C
        stdcall MPatchByte,eax,0x90
        and     ebx,eax

        .timerspatch:
        cmp     dword[ini_opts_timerspatch],0
        je      .windowedfix

        ; Improved timer resolution
        stdcall GetRealAddress,PMI_IGIExe,0x00490360
        stdcall MPatchCodeCave,eax,Timer_Open_CodeCave,6+5+1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00490370
        stdcall MPatchCodeCave,eax,Timer_Read_CodeCave,6+6+1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004444E0
        stdcall MPatchAddress,Timer_GetPerformanceCounter.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005F5484
        stdcall MPatchAddress,Timer_GetPerformanceCounter.fixup2,eax,1
        and     ebx,eax

        .windowedfix:
        cmp     dword[ini_opts_windowedfix],0
        je      .cursorfix

        ; hide windows cursor in windowed mode
        stdcall GetRealAddress,PMI_IGIExe,0x004942D9
        stdcall MPatchByte,eax,0x00
        and     ebx,eax

        .cursorfix:
        cmp     dword[ini_opts_cursorfix],0
        je      .borderless

        ; fix cursor precision in fullscreen for menus
        stdcall GetRealAddress,PMI_IGIExe,0x00424BC0
        stdcall MPatchAddress,eax,Cursor_RunHandler,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28F8C
        stdcall MPatchAddress,Cursor_RunHandler.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B44
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B48
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8BC4
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8C00
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC58
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC5C
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B44
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B48
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup4,eax,0
        and     ebx,eax

        .borderless:
        cmp     dword[ini_opts_borderless],0
        je      .end

        ; add borderless command line command and initialize
        stdcall GetRealAddress,PMI_IGIExe,0x0048F674
        stdcall MPatchCodeCave,eax,loc_48F674,5
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F679
        stdcall MPatchAddress,loc_48F674.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F6D8
        stdcall MPatchCodeCave,eax,loc_48F6D8,4+4
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F360
        stdcall MPatchAddress,loc_48F6D8.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F6E0
        stdcall MPatchAddress,loc_48F6D8.fixup2,eax,1
        and     ebx,eax

        ; add borderless screen mode support
        stdcall GetRealAddress,PMI_IGIExe,0x0048F759
        stdcall MPatchCodeCave,eax,loc_48F759,2+2+5+5
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F767
        stdcall MPatchAddress,loc_48F759.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00494FB6
        stdcall MPatchCodeCave,eax,loc_494FB6,2+2+4+5+5
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00494FC8
        stdcall MPatchAddress,loc_494FB6.fixup1,eax,1
        and     ebx,eax

        ; scale window to desktop resolution
        stdcall GetRealAddress,PMI_IGIExe,0x00491B7C
        stdcall MPatchAddress,eax,AppContext_IsNotWindowed,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8C00
        stdcall MPatchAddress,AppContext_IsNotWindowed.fixup1,eax,0
        and     ebx,eax

        ; fix decentered loading screen due to scaling
        stdcall GetRealAddress,PMI_IGIExe,0x0048A466
        stdcall MPatchCodeCave,eax,loc_48A466,0x0048A499-0x0048A466
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A499
        stdcall MPatchAddress,loc_48A466.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A50D
        stdcall MPatchCodeCave,eax,loc_48A50D,0x0048A53E-0x0048A50D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A53E
        stdcall MPatchAddress,loc_48A50D.fixup1,eax,1
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     ebx
        ret
endp
