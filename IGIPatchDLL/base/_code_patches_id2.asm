proc ApplyPatches_ID2 ; IGI.exe v1.0 (region: japan)

        push    ebx
        mov     ebx,1

        ; workaround for undefined symbol error
        mov     eax,PatchTrap

        .nocdcheck:
        cmp     dword[ini_opts_nocdcheck],0
        je      .timerspatch

        ; J_Open
        stdcall GetRealAddress,PMI_IGIExe,0x004060E2
        lea     ecx,[eax+5]
        stdcall MPatchCodeCave,eax,ecx,5
        and     ebx,eax

        ; Game_RunHandler
        stdcall GetRealAddress,PMI_IGIExe,0x00415D09
        stdcall MPatchWord,eax,0x0D89
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00415D0B
        stdcall MPatchDword,eax,0x00539580 ;Game_iMissionID
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00415D0F
        stdcall MPatchWord,eax,0xC483
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00415D11
        stdcall MPatchByte,eax,0x0C
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00415D12
        lea     ecx,[eax+5+0x00000049]
        stdcall MPatchCodeCave,eax,ecx,5+0x00000049
        and     ebx,eax

        ; Game_CreateHandler
        stdcall GetRealAddress,PMI_IGIExe,0x004158B1
        lea     ecx,[eax+5+0x0000004C]
        stdcall MPatchCodeCave,eax,ecx,5+0x0000004C
        and     ebx,eax

        ; Flow_CreateHandler
        stdcall GetRealAddress,PMI_IGIExe,0x00402207
        stdcall MPatchWord,eax,0xC483
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00402209
        stdcall MPatchByte,eax,0x08
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0040220A
        lea     ecx,[eax+5+0x0000004A]
        stdcall MPatchCodeCave,eax,ecx,5+0x0000004A
        and     ebx,eax

        ; MenuManager_New
        stdcall GetRealAddress,PMI_IGIExe,0x00418777
        stdcall MPatchWord,eax,0x9D89
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418779
        stdcall MPatchDword,eax,0x00002838
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041877D
        stdcall MPatchWord,eax,0x8588
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041877F
        stdcall MPatchDword,eax,0x000026C3
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418783
        lea     ecx,[eax+5+0x0000004B]
        stdcall MPatchCodeCave,eax,ecx,5+0x0000004B
        and     ebx,eax

        .timerspatch:
        cmp     dword[ini_opts_timerspatch],0
        je      .windowedfix

        ; Improved timer resolution
        stdcall GetRealAddress,PMI_IGIExe,0x00490790
        stdcall MPatchCodeCave,eax,Timer_Open_CodeCave,6+5+1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004907A0
        stdcall MPatchCodeCave,eax,Timer_Read_CodeCave,6+6+1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004B0130
        stdcall MPatchAddress,Timer_GetPerformanceCounter.fixup1,eax,1
        and     ebx,eax

        .windowedfix:
        cmp     dword[ini_opts_windowedfix],0
        je      .cursorfix

        ; hide windows cursor in windowed mode
        stdcall GetRealAddress,PMI_IGIExe,0x00494749
        stdcall MPatchByte,eax,0x00
        and     ebx,eax

        .cursorfix:
        cmp     dword[ini_opts_cursorfix],0
        je      .borderless

        ; fix cursor precision in fullscreen for menus
        stdcall GetRealAddress,PMI_IGIExe,0x004248B0
        stdcall MPatchAddress,eax,Cursor_RunHandler,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C2944C ;Mouse_tMouse.bButton
        stdcall MPatchAddress,Cursor_RunHandler.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29004 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29008 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C80F4 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8130 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00582168 ;Cursor_nMouseX
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0058216C ;Cursor_nMouseY
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00492029
        stdcall MPatchCodeCave,eax,loc_491BE9,0x00492032-0x00492029
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8130 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,loc_491BE9.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C80F4 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,loc_491BE9.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00492032
        stdcall MPatchAddress,loc_491BE9.fixup3,eax,1
        and     ebx,eax

        .borderless:
        cmp     dword[ini_opts_borderless],0
        je      .resolutions

        ; add borderless command-line param
        stdcall GetRealAddress,PMI_IGIExe,0x0048FB54
        stdcall MPatchCodeCave,eax,loc_48F724,0x0048FB5A-0x0048FB54
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F790 ;AppMain_ParseCmdLineArgs
        stdcall MPatchAddress,loc_48F724.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048FB5A
        stdcall MPatchAddress,loc_48F724.fixup2,eax,1
        and     ebx,eax

        ; add borderless window mode support
        stdcall GetRealAddress,PMI_IGIExe,0x0048FB89
        stdcall MPatchCodeCave,eax,loc_48F759,0x0048FB97-0x0048FB89
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048FB97
        stdcall MPatchAddress,loc_48F759.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00495456
        stdcall MPatchCodeCave,eax,loc_494FB6,0x00495468-0x00495456
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00495468
        stdcall MPatchAddress,loc_494FB6.fixup1,eax,1
        and     ebx,eax

        ; scale window to desktop resolution
        stdcall GetRealAddress,PMI_IGIExe,0x00491FBC
        stdcall MPatchAddress,eax,AppContext_IsNotWindowed,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8130 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,AppContext_IsNotWindowed.fixup1,eax,0
        and     ebx,eax

        ; fix decentered loading screen due to scaling
        stdcall GetRealAddress,PMI_IGIExe,0x0048A8E6
        stdcall MPatchCodeCave,eax,loc_48A466,0x0048A919-0x0048A8E6
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A919
        stdcall MPatchAddress,loc_48A466.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A92D
        stdcall MPatchCodeCave,eax,loc_48A4AD,0x0048A933-0x0048A92D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A933
        stdcall MPatchAddress,loc_48A4AD.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A98D
        stdcall MPatchCodeCave,eax,loc_48A50D,0x0048A9BE-0x0048A98D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A9BE
        stdcall MPatchAddress,loc_48A50D.fixup1,eax,1
        and     ebx,eax

        .resolutions:
        cmp     dword[ini_opts_resolutions],0
        je      .widescreen

        stdcall GetScreenBitsPerPixel
        mov     dword[Config_nScreenBPP],eax

        ; rewrite Config_EnumDisplayModeCB
        stdcall GetRealAddress,PMI_IGIExe,0x00402FBE
        stdcall MPatchAddress,eax,Config_EnumDisplayModeCB,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00566BBC ;Config_nNumDisplayDevices
        stdcall MPatchAddress,Config_EnumDisplayModeCB.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00566BC0 ;&Config_atDisplayDevice
        stdcall MPatchAddress,Config_EnumDisplayModeCB.fixup2,eax,0
        and     ebx,eax

        ; fix listbox item id
        stdcall GetRealAddress,PMI_IGIExe,0x00403E2E
        stdcall MPatchCodeCave,eax,loc_40449E,0x00403E40-0x00403E2E
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403E40
        stdcall MPatchAddress,loc_40449E.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403EB6
        stdcall MPatchCodeCave,eax,loc_404526,0x00403EE6-0x00403EB6
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403F20 ;Config_GetActiveGraphicOptions
        stdcall MPatchAddress,loc_404526.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403EE6
        stdcall MPatchAddress,loc_404526.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403F9C
        stdcall MPatchCodeCave,eax,loc_40460C,0x00403FD3-0x00403F9C
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403FE1
        stdcall MPatchAddress,loc_40460C.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403FD3
        stdcall MPatchAddress,loc_40460C.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403FE1
        stdcall MPatchCodeCave,eax,loc_404651,0x00403FFF-0x00403FE1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00566B90 ;sdefault
        stdcall MPatchAddress,loc_404651.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403FFF
        stdcall MPatchAddress,loc_404651.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405421
        stdcall MPatchCodeCave,eax,loc_405A91,0x00405457-0x00405421
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405465
        stdcall MPatchAddress,loc_405A91.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405457
        stdcall MPatchAddress,loc_405A91.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405469
        stdcall MPatchCodeCave,eax,loc_405AD9,0x0040547D-0x00405469
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0040547D
        stdcall MPatchAddress,loc_405AD9.fixup1,eax,1
        and     ebx,eax

        .widescreen:
        cmp     dword[ini_opts_widescreen],0
        je      .debugpatch

        ; disable screen stretching
        stdcall GetRealAddress,PMI_IGIExe,0x00492180
        stdcall MPatchCodeCave,eax,Display_GetAspectRatio_CodeCave,0x004921A9-0x00492180
        and     ebx,eax

        ; Display_SetMode - save aspect ratio
        stdcall GetRealAddress,PMI_IGIExe,0x0049207F
        stdcall MPatchCodeCave,eax,loc_491C3F,0x00492085-0x0049207F
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00492085
        stdcall MPatchAddress,loc_491C3F.fixup1,eax,1
        and     ebx,eax

        ; QCamera_Set - fix FOV
        stdcall GetRealAddress,PMI_IGIExe,0x004DA270
        stdcall MPatchCodeCave,eax,QCamera_Set_CodeCave,0x004DA278-0x004DA270
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004DA278
        stdcall MPatchAddress,QCamera_Set_CodeCave.fixup1,eax,1
        and     ebx,eax

        ; ViewportQTask_New - fix FOV
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E8A10
        ;stdcall MPatchCodeCave,eax,ViewportQTask_New_CodeCave,0x004E8A18-0x004E8A10
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E8A00 ;sub_4E8100
        ;stdcall MPatchAddress,ViewportQTask_New_CodeCave.fixup1,eax,1
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E8A18
        ;stdcall MPatchAddress,ViewportQTask_New_CodeCave.fixup2,eax,1
        ;and     ebx,eax

        ; HumanCamera_RunHandler - fix object FOV
        stdcall GetRealAddress,PMI_IGIExe,0x004827E9
        stdcall MPatchCodeCave,eax,loc_482859,0x004827EF-0x004827E9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004827EF
        stdcall MPatchAddress,loc_482859.fixup1,eax,1
        and     ebx,eax

        .debugpatch:
        cmp     dword[ini_opts_debugpatch],0
        je      .end

        ; init debug command-line params
        stdcall GetRealAddress,PMI_IGIExe,0x0048FAA4
        stdcall MPatchCodeCave,eax,loc_48F674,0x0048FAA9-0x0048FAA4
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048FAA9
        stdcall MPatchAddress,loc_48F674.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C7FB0 ;GameFunctions_isEnableDebugKeys
        stdcall MPatchAddress,GameFunctions_SetEnableDebugKeys.fixup1,eax,0
        and     ebx,eax

        ; parse debug command-line params
        stdcall GetRealAddress,PMI_IGIExe,0x0048FB08
        stdcall MPatchCodeCave,eax,loc_48F6D8,0x0048FB10-0x0048FB08
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F790 ;AppMain_ParseCmdLineArgs
        stdcall MPatchAddress,loc_48F6D8.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048FB10
        stdcall MPatchAddress,loc_48F6D8.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F670 ;AppContext_SetLightmapsUsed
        stdcall MPatchAddress,Main_ParseNoLightmapsCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F690 ;AppContext_SetTerrainLightmapsUsed
        stdcall MPatchAddress,Main_ParseNoTerrainLightmapCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F610 ;AppContext_SetDebugtextState
        stdcall MPatchAddress,Main_ParseDebugTextCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F5D0 ;AppContext_SetDebugged
        stdcall MPatchAddress,Main_ParseDebugCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8330 ;AppContext_isFixmeSmall
        stdcall MPatchAddress,Main_ParseSmallCB.fixup1,eax,0
        and     ebx,eax

        ; replace font
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E81E5
        ;stdcall MPatchAddress,eax,debugfont,0
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E8306
        ;stdcall MPatchAddress,eax,debugfont,0
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E8454
        ;stdcall MPatchAddress,eax,debugfont,0
        ;and     ebx,eax

        ; disable requirement of completing all 14 missions
        stdcall GetRealAddress,PMI_IGIExe,0x00488FC2
        stdcall MPatchByte,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048901A
        stdcall MPatchByte,eax,0
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     ebx
        ret
endp
