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

        .windowedfix:
        cmp     dword[ini_opts_windowedfix],0
        je      .cursorfix

        ; hide windows cursor in windowed mode
        stdcall GetRealAddress,PMI_IGIExe,0x004942D9
        stdcall MPatchByte,eax,0x00
        and     ebx,eax

        .cursorfix:
        cmp     dword[ini_opts_cursorfix],0
        je      .end

        ; fix cursor precision in fullscreen for menus
        stdcall GetRealAddress,PMI_IGIExe,0x00424BC0
        stdcall MPatchAddress,eax,Cursor_RunHandler,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28F8C
        stdcall MPatchAddress,Cursor_RunHandler.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8C00
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8BC4
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC58
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC5C
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup4,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B44
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup5,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B48
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup6,eax,0
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     ebx
        ret
endp
