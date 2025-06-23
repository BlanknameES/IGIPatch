proc ApplyPatches_ID0 ; IGI.exe v1.0 (region: europe)

        push    ebx
        mov     ebx,1

        ; workaround for undefined symbol error
        mov     eax,PatchTrap

        .nocdcheck:
        cmp     dword[ini_opts_nocdcheck],0
        je      .timerspatch

        ; J_Open
        stdcall GetRealAddress,PMI_IGIExe,0x00402C32
        lea     ecx,[eax+5]
        stdcall MPatchCodeCave,eax,ecx,5
        and     ebx,eax

        ; Game_RunHandler
        stdcall GetRealAddress,PMI_IGIExe,0x004162A9
        stdcall MPatchWord,eax,0x0D89
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162AB
        stdcall MPatchDword,eax,0x00539560 ;Game_iMissionID
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162AF
        stdcall MPatchWord,eax,0xC483
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162B1
        stdcall MPatchByte,eax,0x0C
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004162B2
        lea     ecx,[eax+5+0x00000049]
        stdcall MPatchCodeCave,eax,ecx,5+0x00000049
        and     ebx,eax

        ; Game_CreateHandler
        stdcall GetRealAddress,PMI_IGIExe,0x00415F41
        lea     ecx,[eax+5+0x0000004C]
        stdcall MPatchCodeCave,eax,ecx,5+0x0000004C
        and     ebx,eax

        ; Flow_CreateHandler
        stdcall GetRealAddress,PMI_IGIExe,0x004021E7
        stdcall MPatchWord,eax,0xC483
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004021E9
        stdcall MPatchByte,eax,0x08
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004021EA
        lea     ecx,[eax+5+0x0000004A]
        stdcall MPatchCodeCave,eax,ecx,5+0x0000004A
        and     ebx,eax

        ; MenuManager_New
        stdcall GetRealAddress,PMI_IGIExe,0x00418CF7
        stdcall MPatchWord,eax,0x9D89
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418CF9
        stdcall MPatchDword,eax,0x00002838
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418CFD
        stdcall MPatchWord,eax,0x8588
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418CFF
        stdcall MPatchDword,eax,0x000026C3
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418D03
        lea     ecx,[eax+5+0x0000004B]
        stdcall MPatchCodeCave,eax,ecx,5+0x0000004B
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
        stdcall GetRealAddress,PMI_IGIExe,0x004AF7B0
        stdcall MPatchAddress,Timer_GetPerformanceCounter.fixup1,eax,1
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
        stdcall GetRealAddress,PMI_IGIExe,0x00C28F8C ;Mouse_tMouse.bButton
        stdcall MPatchAddress,Cursor_RunHandler.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B44 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B48 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8BC4 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8C00 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC58 ;Cursor_nMouseX
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC5C ;Cursor_nMouseY
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491BE9
        stdcall MPatchCodeCave,eax,loc_491BE9,0x00491BF2-0x00491BE9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8C00 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,loc_491BE9.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8BC4 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,loc_491BE9.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491BF2
        stdcall MPatchAddress,loc_491BE9.fixup3,eax,1
        and     ebx,eax

        .borderless:
        cmp     dword[ini_opts_borderless],0
        je      .resolutions

        ; add borderless command-line param
        stdcall GetRealAddress,PMI_IGIExe,0x0048F724
        stdcall MPatchCodeCave,eax,loc_48F724,0x0048F72A-0x0048F724
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F360 ;AppMain_ParseCmdLineArgs
        stdcall MPatchAddress,loc_48F724.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F72A
        stdcall MPatchAddress,loc_48F724.fixup2,eax,1
        and     ebx,eax

        ; add borderless window mode support
        stdcall GetRealAddress,PMI_IGIExe,0x0048F759
        stdcall MPatchCodeCave,eax,loc_48F759,0x0048F767-0x0048F759
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F767
        stdcall MPatchAddress,loc_48F759.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00494FB6
        stdcall MPatchCodeCave,eax,loc_494FB6,0x00494FC8-0x00494FB6
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00494FC8
        stdcall MPatchAddress,loc_494FB6.fixup1,eax,1
        and     ebx,eax

        ; scale window to desktop resolution
        stdcall GetRealAddress,PMI_IGIExe,0x00491B7C
        stdcall MPatchAddress,eax,AppContext_IsNotWindowed,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8C00 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,AppContext_IsNotWindowed.fixup1,eax,0
        and     ebx,eax

        ; fix decentered loading screen due to scaling
        stdcall GetRealAddress,PMI_IGIExe,0x0048A466
        stdcall MPatchCodeCave,eax,loc_48A466,0x0048A499-0x0048A466
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A499
        stdcall MPatchAddress,loc_48A466.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A4AD
        stdcall MPatchCodeCave,eax,loc_48A4AD,0x0048A4B3-0x0048A4AD
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A4B3
        stdcall MPatchAddress,loc_48A4AD.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A50D
        stdcall MPatchCodeCave,eax,loc_48A50D,0x0048A53E-0x0048A50D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A53E
        stdcall MPatchAddress,loc_48A50D.fixup1,eax,1
        and     ebx,eax

        .resolutions:
        cmp     dword[ini_opts_resolutions],0
        je      .widescreen

        stdcall GetScreenBitsPerPixel
        mov     dword[Config_nScreenBPP],eax

        ; rewrite Config_EnumDisplayModeCB
        stdcall GetRealAddress,PMI_IGIExe,0x0040362E
        stdcall MPatchAddress,eax,Config_EnumDisplayModeCB,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00567C90 ;Config_nNumDisplayDevices
        stdcall MPatchAddress,Config_EnumDisplayModeCB.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00567C98 ;&Config_atDisplayDevice
        stdcall MPatchAddress,Config_EnumDisplayModeCB.fixup2,eax,0
        and     ebx,eax

        ; fix listbox item id
        stdcall GetRealAddress,PMI_IGIExe,0x0040449E
        stdcall MPatchCodeCave,eax,loc_40449E,0x004044B0-0x0040449E
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004044B0
        stdcall MPatchAddress,loc_40449E.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00404526
        stdcall MPatchCodeCave,eax,loc_404526,0x00404556-0x00404526
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00404590 ;Config_GetActiveGraphicOptions
        stdcall MPatchAddress,loc_404526.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00404556
        stdcall MPatchAddress,loc_404526.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0040460C
        stdcall MPatchCodeCave,eax,loc_40460C,0x00404643-0x0040460C
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00404651
        stdcall MPatchAddress,loc_40460C.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00404643
        stdcall MPatchAddress,loc_40460C.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00404651
        stdcall MPatchCodeCave,eax,loc_404651,0x0040466F-0x00404651
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00567C74 ;sdefault
        stdcall MPatchAddress,loc_404651.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0040466F
        stdcall MPatchAddress,loc_404651.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405A91
        stdcall MPatchCodeCave,eax,loc_405A91,0x00405AC7-0x00405A91
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405AD5
        stdcall MPatchAddress,loc_405A91.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405AC7
        stdcall MPatchAddress,loc_405A91.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405AD9
        stdcall MPatchCodeCave,eax,loc_405AD9,0x00405AED-0x00405AD9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405AED
        stdcall MPatchAddress,loc_405AD9.fixup1,eax,1
        and     ebx,eax

        .widescreen:
        cmp     dword[ini_opts_widescreen],0
        je      .debugpatch

        ; disable screen stretching
        stdcall GetRealAddress,PMI_IGIExe,0x00491D40
        stdcall MPatchCodeCave,eax,Display_GetAspectRatio_CodeCave,0x00491D69-0x00491D40
        and     ebx,eax

        ; Display_SetMode - save aspect ratio
        stdcall GetRealAddress,PMI_IGIExe,0x00491C3F
        stdcall MPatchCodeCave,eax,loc_491C3F,0x00491C45-0x00491C3F
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491C45
        stdcall MPatchAddress,loc_491C3F.fixup1,eax,1
        and     ebx,eax

        ; QCamera_Set - fix FOV
        stdcall GetRealAddress,PMI_IGIExe,0x004D9870
        stdcall MPatchCodeCave,eax,QCamera_Set_CodeCave,0x004D9878-0x004D9870
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D9878
        stdcall MPatchAddress,QCamera_Set_CodeCave.fixup1,eax,1
        and     ebx,eax

        ; ViewportQTask_New - fix FOV
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E8110
        ;stdcall MPatchCodeCave,eax,ViewportQTask_New_CodeCave,0x004E8118-0x004E8110
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E8100 ;sub_4E8100
        ;stdcall MPatchAddress,ViewportQTask_New_CodeCave.fixup1,eax,1
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E8118
        ;stdcall MPatchAddress,ViewportQTask_New_CodeCave.fixup2,eax,1
        ;and     ebx,eax

        ; HumanCamera_RunHandler - fix object FOV
        stdcall GetRealAddress,PMI_IGIExe,0x00482859
        stdcall MPatchCodeCave,eax,loc_482859,0x0048285F-0x00482859
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048285F
        stdcall MPatchAddress,loc_482859.fixup1,eax,1
        and     ebx,eax

        .debugpatch:
        cmp     dword[ini_opts_debugpatch],0
        je      .end

        ; init debug command-line params
        stdcall GetRealAddress,PMI_IGIExe,0x0048F674
        stdcall MPatchCodeCave,eax,loc_48F674,0x0048F679-0x0048F674
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F679
        stdcall MPatchAddress,loc_48F674.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057B194 ;GameFunctions_isEnableDebugKeys
        stdcall MPatchAddress,GameFunctions_SetEnableDebugKeys.fixup1,eax,0
        and     ebx,eax

        ; parse debug command-line params
        stdcall GetRealAddress,PMI_IGIExe,0x0048F6D8
        stdcall MPatchCodeCave,eax,loc_48F6D8,0x0048F6E0-0x0048F6D8
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F360 ;AppMain_ParseCmdLineArgs
        stdcall MPatchAddress,loc_48F6D8.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F6E0
        stdcall MPatchAddress,loc_48F6D8.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F240 ;AppContext_SetLightmapsUsed
        stdcall MPatchAddress,Main_ParseNoLightmapsCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F260 ;AppContext_SetTerrainLightmapsUsed
        stdcall MPatchAddress,Main_ParseNoTerrainLightmapCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F1E0 ;AppContext_SetDebugtextState
        stdcall MPatchAddress,Main_ParseDebugTextCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F1A0 ;AppContext_SetDebugged
        stdcall MPatchAddress,Main_ParseDebugCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8E00 ;AppContext_isFixmeSmall
        stdcall MPatchAddress,Main_ParseSmallCB.fixup1,eax,0
        and     ebx,eax

        ; replace font
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E78E5
        ;stdcall MPatchAddress,eax,debugfont,0
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E7A06
        ;stdcall MPatchAddress,eax,debugfont,0
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E7B54
        ;stdcall MPatchAddress,eax,debugfont,0
        ;and     ebx,eax

        ; disable requirement of completing all 14 missions
        stdcall GetRealAddress,PMI_IGIExe,0x00415002
        stdcall MPatchByte,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041505A
        stdcall MPatchByte,eax,0
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     ebx
        ret
endp
