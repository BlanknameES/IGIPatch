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
        stdcall GetRealAddress,PMI_IGIExe,0x00582168 ;Cursor_nMouseX
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0058216C ;Cursor_nMouseY
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C80F4 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8130 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29004 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29008 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004248B0
        stdcall MPatchAddress,eax,Cursor_RunHandler,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C2944C ;Mouse_tMouse.bButton
        stdcall MPatchAddress,Cursor_RunHandler.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8130 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,Cursor_UpdateSensMult.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00492029
        stdcall MPatchCodeCave,eax,loc_491BE9,0x00492032-0x00492029
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C80F4 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,loc_491BE9.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00492032
        stdcall MPatchAddress,loc_491BE9.fixup2,eax,1
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

        ; Display_SetMode - save aspect ratio
        stdcall GetRealAddress,PMI_IGIExe,0x0049207F
        stdcall MPatchCodeCave,eax,loc_491C3F,0x00492085-0x0049207F
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00492085
        stdcall MPatchAddress,loc_491C3F.fixup1,eax,1
        and     ebx,eax

        ; TransContext_Create
        stdcall GetRealAddress,PMI_IGIExe,0x00498757
        stdcall MPatchCodeCave,eax,TransContext_Create_CodeCave,0x004987C5-0x00498757
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA548 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA538 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vX
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA548 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA53C ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vY
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup4,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA54C ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfHeight
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup5,eax,0
        and     ebx,eax

        ; Direct3DRender_DrawRigidMesh
        stdcall GetRealAddress,PMI_IGIExe,0x0049E9AE
        stdcall MPatchCodeCave,eax,loc_49E02E,0x0049EA31-0x0049E9AE
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81080 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49E02E.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA548 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49E02E.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004987E0 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49E02E.fixup3,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049EA31
        stdcall MPatchAddress,loc_49E02E.fixup4,eax,1
        and     ebx,eax

        ; Direct3DRender_DrawSortedFaceGroup_Rigid
        stdcall GetRealAddress,PMI_IGIExe,0x0049F98D
        stdcall MPatchCodeCave,eax,loc_49F00D,0x0049FA23-0x0049F98D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA460 ;TransContext_tActiveTransContext
        stdcall MPatchAddress,loc_49F00D.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81080 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49F00D.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA548 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49F00D.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004987E0 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49F00D.fixup4,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049FA23
        stdcall MPatchAddress,loc_49F00D.fixup5,eax,1
        and     ebx,eax

        ; Direct3DRender_DrawSortedFaceGroup_Lightmap
        stdcall GetRealAddress,PMI_IGIExe,0x0049FF2F
        stdcall MPatchCodeCave,eax,loc_49F5AF,0x0049FFC5-0x0049FF2F
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA460 ;TransContext_tActiveTransContext
        stdcall MPatchAddress,loc_49F5AF.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81080 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49F5AF.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA548 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49F5AF.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004987E0 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49F5AF.fixup4,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049FFC5
        stdcall MPatchAddress,loc_49F5AF.fixup5,eax,1
        and     ebx,eax

        ; Direct3DRender_DrawBoneMesh
        stdcall GetRealAddress,PMI_IGIExe,0x004A010B
        stdcall MPatchCodeCave,eax,loc_49F78B,0x004A018F-0x004A010B
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81080 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49F78B.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCA548 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49F78B.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004987E0 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49F78B.fixup3,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004A018F
        stdcall MPatchAddress,loc_49F78B.fixup4,eax,1
        and     ebx,eax

        ; ComputerObject_ProjectRotatedPos
        stdcall GetRealAddress,PMI_IGIExe,0x004671B6
        stdcall MPatchCodeCave,eax,loc_4675E6,0x004671BC-0x004671B6
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004671BC
        stdcall MPatchAddress,loc_4675E6.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004671C1
        stdcall MPatchAddress,eax,Display_GetInvAspectRatio,1
        and     ebx,eax

        ; ComputerObject_ProjectWorldPos
        stdcall GetRealAddress,PMI_IGIExe,0x00467280
        stdcall MPatchCodeCave,eax,loc_4676B0,0x00467288-0x00467280
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00467288
        stdcall MPatchAddress,loc_4676B0.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046729F
        stdcall MPatchAddress,eax,Display_GetInvAspectRatio,1
        and     ebx,eax

        ; ComputerMap_Trace
        stdcall GetRealAddress,PMI_IGIExe,0x0046A0A2
        stdcall MPatchAddress,eax,Display_GetRelAspectRatio,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046A0C0
        stdcall MPatchCodeCave,eax,loc_46A550,0x0046A0C7-0x0046A0C0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046A0C7
        stdcall MPatchAddress,loc_46A550.fixup1,eax,1
        and     ebx,eax

        ; Computer_RunHandler - set scalex to Display_GetAspectRatio()
        stdcall GetRealAddress,PMI_IGIExe,0x0046B8F4
        stdcall MPatchCodeCave,eax,loc_46BD84,0x0046B8FA-0x0046B8F4
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046B8FA
        stdcall MPatchAddress,loc_46BD84.fixup1,eax,1
        and     ebx,eax

        .debugpatch:
        cmp     dword[ini_opts_debugpatch],0
        je      .mainmenures

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

        .mainmenures:
        cmp     dword[ini_opts_mainmenures],0
        je      .end

        stdcall GetMainMenuResolution
        mov     dword[Display_CustomMMRes],eax
        mov     dword[Display_MMResWidth],ecx
        mov     dword[Display_MMResHeight],edx

        ; MenuManager_New - custom main menu resolution
        stdcall GetRealAddress,PMI_IGIExe,0x004185B8
        stdcall MPatchCodeCave,eax,loc_418B38,0x004185D0-0x004185B8
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004185D0
        stdcall MPatchAddress,loc_418B38.fixup1,eax,1
        and     ebx,eax

        ; MenuManager_New - fix background color
        stdcall GetRealAddress,PMI_IGIExe,0x0041865F
        stdcall MPatchCodeCave,eax,loc_418BDF,0x00418668-0x0041865F
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491ED0
        stdcall MPatchAddress,loc_418BDF.fixup1,eax,1 ;Display_SetMode
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004922B0 ;Display_SetBackgroundColourFn
        stdcall MPatchAddress,loc_418BDF.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418668
        stdcall MPatchAddress,loc_418BDF.fixup3,eax,1
        and     ebx,eax

        ; MenuScreen_UpdateInternalDataHandler - fix decentered EU logo
        stdcall GetRealAddress,PMI_IGIExe,0x004216B9
        stdcall MPatchCodeCave,eax,loc_421AB9,0x004216C1-0x004216B9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00582110 ;dword_57BC0C
        stdcall MPatchAddress,loc_421AB9.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004216E2
        stdcall MPatchAddress,loc_421AB9.fixup2,eax,1
        and     ebx,eax

        ; MenuScreen_UpdateInternalDataHandler - fix logo position
        stdcall GetRealAddress,PMI_IGIExe,0x004216EC
        stdcall MPatchCodeCave,eax,loc_421AEC,0x00421753-0x004216EC
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004B7820 ;Picture_GetWidth
        stdcall MPatchAddress,loc_421AEC.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0053353C ;flt_533504
        stdcall MPatchAddress,loc_421AEC.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00492130 ;Display_GetActiveMode
        stdcall MPatchAddress,loc_421AEC.fixup3,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00582110 ;dword_57BC0C
        stdcall MPatchAddress,loc_421AEC.fixup4,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004B7830 ;Picture_GetHeight
        stdcall MPatchAddress,loc_421AEC.fixup5,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0053353C ;flt_533504
        stdcall MPatchAddress,loc_421AEC.fixup6,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00492130 ;Display_GetActiveMode
        stdcall MPatchAddress,loc_421AEC.fixup7,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00421753
        stdcall MPatchAddress,loc_421AEC.fixup8,eax,1
        and     ebx,eax

        ; BackgroundFX_CreateMatrix - fix background fx position
        stdcall GetRealAddress,PMI_IGIExe,0x0041C3F0
        stdcall MPatchCodeCave,eax,loc_4192E0,0x0041C3F6-0x0041C3F0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29004 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,loc_4192E0.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29008 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,loc_4192E0.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041C3F6
        stdcall MPatchAddress,loc_4192E0.fixup3,eax,1
        and     ebx,eax

        ; TypeWriterBox_DrawHandler - fix credits rect position
        stdcall GetRealAddress,PMI_IGIExe,0x0041D934
        stdcall MPatchCodeCave,eax,loc_41A8A4,0x0041D93A-0x0041D934
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29004 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,loc_41A8A4.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29008 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,loc_41A8A4.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041D93A
        stdcall MPatchAddress,loc_41A8A4.fixup3,eax,1
        and     ebx,eax

        ; InputBox_Draw - fix input boxes position
        stdcall GetRealAddress,PMI_IGIExe,0x00419283
        stdcall MPatchCodeCave,eax,loc_41D7A3,0x0041929A-0x00419283
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29004 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,loc_41D7A3.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C29008 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,loc_41D7A3.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041929A
        stdcall MPatchAddress,loc_41D7A3.fixup3,eax,1
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     ebx
        ret
endp
