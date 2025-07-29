proc ApplyPatches_ID1 ; IGI.exe v1.0 (Region: USA)

        push    ebx
        mov     ebx,1

        ; workaround for undefined symbol error
        mov     eax,PatchTrap

        .dpiawareness: ; high priority
        cmp     dword[ini_opts_dpiawareness],0
        je      .nocdcheck

        stdcall SetDPIAwareness

        .nocdcheck:
        cmp     dword[ini_opts_nocdcheck],0
        je      .timerspatch

        ; J_Open
        stdcall GetRealAddress,PMI_IGIExe,0x004060B2
        lea     ecx,[eax+5]
        stdcall MPatchCodeCave,eax,ecx,5
        and     ebx,eax

        ; Game_RunHandler
        stdcall GetRealAddress,PMI_IGIExe,0x00416339
        stdcall MPatchWord,eax,0x0D89
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041633B
        stdcall MPatchDword,eax,0x00539568 ;Game_iMissionID
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041633F
        stdcall MPatchWord,eax,0xC483
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00416341
        stdcall MPatchByte,eax,0x0C
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00416342
        lea     ecx,[eax+5+0x00000049]
        stdcall MPatchCodeCave,eax,ecx,5+0x00000049
        and     ebx,eax

        ; Game_CreateHandler
        stdcall GetRealAddress,PMI_IGIExe,0x00415FD1
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
        stdcall GetRealAddress,PMI_IGIExe,0x00418D97
        stdcall MPatchWord,eax,0x9D89
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418D99
        stdcall MPatchDword,eax,0x00002838
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418D9D
        stdcall MPatchWord,eax,0x8588
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418D9F
        stdcall MPatchDword,eax,0x000026C3
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418DA3
        lea     ecx,[eax+5+0x0000004B]
        stdcall MPatchCodeCave,eax,ecx,5+0x0000004B
        and     ebx,eax

        .timerspatch:
        cmp     dword[ini_opts_timerspatch],0
        je      .windowedfix

        ; Improved timer resolution
        stdcall GetRealAddress,PMI_IGIExe,0x004901D0
        stdcall MPatchCodeCave,eax,Timer_Open_CodeCave,6+5+1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004901E0
        stdcall MPatchCodeCave,eax,Timer_Read_CodeCave,6+6+1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004AF640
        stdcall MPatchAddress,Timer_GetPerformanceCounter.fixup1,eax,1
        and     ebx,eax

        .windowedfix:
        cmp     dword[ini_opts_windowedfix],0
        je      .cursorfix

        ; hide windows cursor in windowed mode
        stdcall GetRealAddress,PMI_IGIExe,0x00494169
        stdcall MPatchByte,eax,0x00
        and     ebx,eax

        .cursorfix:
        cmp     dword[ini_opts_cursorfix],0
        je      .borderless

        ; fix cursor precision in fullscreen for menus
        stdcall GetRealAddress,PMI_IGIExe,0x00583818 ;Cursor_nMouseX
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0058381C ;Cursor_nMouseY
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C9314 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C9350 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A4 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A8 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00424F20
        stdcall MPatchAddress,eax,Cursor_RunHandler,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C296EC ;Mouse_tMouse.bButton
        stdcall MPatchAddress,Cursor_RunHandler.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C9350 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,Cursor_UpdateSensMult.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491A79
        stdcall MPatchCodeCave,eax,loc_491BE9,0x00491A82-0x00491A79
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C9314 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,loc_491BE9.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491A82
        stdcall MPatchAddress,loc_491BE9.fixup2,eax,1
        and     ebx,eax

        .borderless:
        cmp     dword[ini_opts_borderless],0
        je      .resolutions

        ; add borderless command-line param
        stdcall GetRealAddress,PMI_IGIExe,0x0048F594
        stdcall MPatchCodeCave,eax,loc_48F724,0x0048F59A-0x0048F594
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F1D0 ;AppMain_ParseCmdLineArgs
        stdcall MPatchAddress,loc_48F724.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F59A
        stdcall MPatchAddress,loc_48F724.fixup2,eax,1
        and     ebx,eax

        ; add borderless window mode support
        stdcall GetRealAddress,PMI_IGIExe,0x0048F5C9
        stdcall MPatchCodeCave,eax,loc_48F759,0x0048F5D7-0x0048F5C9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F5D7
        stdcall MPatchAddress,loc_48F759.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00494E46
        stdcall MPatchCodeCave,eax,loc_494FB6,0x00494E58-0x00494E46
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00494E58
        stdcall MPatchAddress,loc_494FB6.fixup1,eax,1
        and     ebx,eax

        ; scale window to desktop resolution
        stdcall GetRealAddress,PMI_IGIExe,0x00491A0C
        stdcall MPatchAddress,eax,AppContext_IsNotWindowed,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C9350 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,AppContext_IsNotWindowed.fixup1,eax,0
        and     ebx,eax

        ; fix decentered loading screen due to scaling
        stdcall GetRealAddress,PMI_IGIExe,0x0048A2D6
        stdcall MPatchCodeCave,eax,loc_48A466,0x0048A309-0x0048A2D6
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A309
        stdcall MPatchAddress,loc_48A466.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A31D
        stdcall MPatchCodeCave,eax,loc_48A4AD,0x0048A323-0x0048A31D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A323
        stdcall MPatchAddress,loc_48A4AD.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A37D
        stdcall MPatchCodeCave,eax,loc_48A50D,0x0048A3AE-0x0048A37D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048A3AE
        stdcall MPatchAddress,loc_48A50D.fixup1,eax,1
        and     ebx,eax

        .resolutions:
        cmp     dword[ini_opts_resolutions],0
        je      .widescreen

        stdcall SetScreenColorDepth

        ; rewrite Config_EnumDisplayModeCB
        stdcall GetRealAddress,PMI_IGIExe,0x00402F8E
        stdcall MPatchAddress,eax,Config_EnumDisplayModeCB,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005683E0 ;Config_nNumDisplayDevices
        stdcall MPatchAddress,Config_EnumDisplayModeCB.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005683E8 ;&Config_atDisplayDevice
        stdcall MPatchAddress,Config_EnumDisplayModeCB.fixup2,eax,0
        and     ebx,eax

        ; fix listbox item id
        stdcall GetRealAddress,PMI_IGIExe,0x00403DFE
        stdcall MPatchCodeCave,eax,loc_40449E,0x00403E10-0x00403DFE
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403E10
        stdcall MPatchAddress,loc_40449E.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403E86
        stdcall MPatchCodeCave,eax,loc_404526,0x00403EB6-0x00403E86
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403EF0 ;Config_GetActiveGraphicOptions
        stdcall MPatchAddress,loc_404526.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403EB6
        stdcall MPatchAddress,loc_404526.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403F6C
        stdcall MPatchCodeCave,eax,loc_40460C,0x00403FA3-0x00403F6C
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403FB1
        stdcall MPatchAddress,loc_40460C.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403FA3
        stdcall MPatchAddress,loc_40460C.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403FB1
        stdcall MPatchCodeCave,eax,loc_404651,0x00403FCF-0x00403FB1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005683C4 ;sdefault
        stdcall MPatchAddress,loc_404651.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00403FCF
        stdcall MPatchAddress,loc_404651.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004053F1
        stdcall MPatchCodeCave,eax,loc_405A91,0x00405427-0x004053F1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405435
        stdcall MPatchAddress,loc_405A91.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405427
        stdcall MPatchAddress,loc_405A91.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00405439
        stdcall MPatchCodeCave,eax,loc_405AD9,0x0040544D-0x00405439
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0040544D
        stdcall MPatchAddress,loc_405AD9.fixup1,eax,1
        and     ebx,eax

        .widescreen:
        cmp     dword[ini_opts_widescreen],0
        je      .debugpatch

        ; Display_SetMode - save aspect ratio
        stdcall GetRealAddress,PMI_IGIExe,0x00491ACF
        stdcall MPatchCodeCave,eax,loc_491C3F,0x00491AD5-0x00491ACF
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491AD5
        stdcall MPatchAddress,loc_491C3F.fixup1,eax,1
        and     ebx,eax

        ; TransContext_Create
        stdcall GetRealAddress,PMI_IGIExe,0x00497C77
        stdcall MPatchCodeCave,eax,TransContext_Create_CodeCave,0x00497CE5-0x00497C77
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB328 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB318 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vX
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB328 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB31C ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vY
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup4,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB32C ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfHeight
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup5,eax,0
        and     ebx,eax

        ; Direct3DRender_DrawRigidMesh
        stdcall GetRealAddress,PMI_IGIExe,0x0049DEBE
        stdcall MPatchCodeCave,eax,loc_49E02E,0x0049DF41-0x0049DEBE
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81E60 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49E02E.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB328 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49E02E.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00497D00 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49E02E.fixup3,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049DF41
        stdcall MPatchAddress,loc_49E02E.fixup4,eax,1
        and     ebx,eax

        ; Direct3DRender_DrawSortedFaceGroup_Rigid
        stdcall GetRealAddress,PMI_IGIExe,0x0049EE9D
        stdcall MPatchCodeCave,eax,loc_49F00D,0x0049EF33-0x0049EE9D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB240 ;TransContext_tActiveTransContext
        stdcall MPatchAddress,loc_49F00D.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81E60 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49F00D.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB328 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49F00D.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00497D00 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49F00D.fixup4,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049EF33
        stdcall MPatchAddress,loc_49F00D.fixup5,eax,1
        and     ebx,eax

        ; Direct3DRender_DrawSortedFaceGroup_Lightmap
        stdcall GetRealAddress,PMI_IGIExe,0x0049F43F
        stdcall MPatchCodeCave,eax,loc_49F5AF,0x0049F4D5-0x0049F43F
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB240 ;TransContext_tActiveTransContext
        stdcall MPatchAddress,loc_49F5AF.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81E60 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49F5AF.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB328 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49F5AF.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00497D00 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49F5AF.fixup4,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049F4D5
        stdcall MPatchAddress,loc_49F5AF.fixup5,eax,1
        and     ebx,eax

        ; Direct3DRender_DrawBoneMesh
        stdcall GetRealAddress,PMI_IGIExe,0x0049F61B
        stdcall MPatchCodeCave,eax,loc_49F78B,0x0049F69F-0x0049F61B
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81E60 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49F78B.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB328 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49F78B.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00497D00 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49F78B.fixup3,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049F69F
        stdcall MPatchAddress,loc_49F78B.fixup4,eax,1
        and     ebx,eax

        ; ComputerObject_ProjectRotatedPos
        stdcall GetRealAddress,PMI_IGIExe,0x004679A6
        stdcall MPatchCodeCave,eax,loc_4675E6,0x004679AC-0x004679A6
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004679AC
        stdcall MPatchAddress,loc_4675E6.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004679B1
        stdcall MPatchAddress,eax,Display_GetInvAspectRatio,1
        and     ebx,eax

        ; ComputerObject_ProjectWorldPos
        stdcall GetRealAddress,PMI_IGIExe,0x00467A70
        stdcall MPatchCodeCave,eax,loc_4676B0,0x00467A78-0x00467A70
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00467A78
        stdcall MPatchAddress,loc_4676B0.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00467A8F
        stdcall MPatchAddress,eax,Display_GetInvAspectRatio,1
        and     ebx,eax

        ; ComputerMap_Trace
        stdcall GetRealAddress,PMI_IGIExe,0x0046A8F2
        stdcall MPatchAddress,eax,Display_GetRelAspectRatio,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046A910
        stdcall MPatchCodeCave,eax,loc_46A550,0x0046A917-0x0046A910
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046A917
        stdcall MPatchAddress,loc_46A550.fixup1,eax,1
        and     ebx,eax

        ; Computer_RunHandler - set scalex to Display_GetAspectRatio()
        stdcall GetRealAddress,PMI_IGIExe,0x0046C144
        stdcall MPatchCodeCave,eax,loc_46BD84,0x0046C14A-0x0046C144
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046C14A
        stdcall MPatchAddress,loc_46BD84.fixup1,eax,1
        and     ebx,eax

        ; Mesh3D_GetRigidMeshLOD - fix rendering distance
        stdcall GetRealAddress,PMI_IGIExe,0x004CEB04
        stdcall MPatchCodeCave,eax,loc_4CFE74,0x004CEB0A-0x004CEB04
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4CFE74.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEB0A
        stdcall MPatchAddress,loc_4CFE74.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEB25
        stdcall MPatchCodeCave,eax,loc_4CFE95,0x004CEB2B-0x004CEB25
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4CFE95.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEB2B
        stdcall MPatchAddress,loc_4CFE95.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEB42
        stdcall MPatchCodeCave,eax,loc_4CFEB2,0x004CEB48-0x004CEB42
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4CFEB2.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEB48
        stdcall MPatchAddress,loc_4CFEB2.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEB82
        stdcall MPatchCodeCave,eax,loc_4CFEF2,0x004CEB88-0x004CEB82
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4CFEF2.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEB88
        stdcall MPatchAddress,loc_4CFEF2.fixup2,eax,1
        and     ebx,eax

        ; Mesh3D_GetBoneMeshLOD - fix rendering distance
        stdcall GetRealAddress,PMI_IGIExe,0x004CED27
        stdcall MPatchCodeCave,eax,loc_4D0097,0x004CED2D-0x004CED27
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D0097.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CED2D
        stdcall MPatchAddress,loc_4D0097.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CED47
        stdcall MPatchCodeCave,eax,loc_4D00B7,0x004CED4D-0x004CED47
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D00B7.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CED4D
        stdcall MPatchAddress,loc_4D00B7.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CED64
        stdcall MPatchCodeCave,eax,loc_4D00D4,0x004CED6A-0x004CED64
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D00D4.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CED6A
        stdcall MPatchAddress,loc_4D00D4.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CED9A
        stdcall MPatchCodeCave,eax,loc_4D010A,0x004CEDA0-0x004CED9A
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D010A.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEDA0
        stdcall MPatchAddress,loc_4D010A.fixup2,eax,1
        and     ebx,eax

        ; Mesh3D_GetSplineMeshLOD - fix rendering distance
        stdcall GetRealAddress,PMI_IGIExe,0x004CEF6D
        stdcall MPatchCodeCave,eax,loc_4D02DD,0x004CEF73-0x004CEF6D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D02DD.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEF73
        stdcall MPatchAddress,loc_4D02DD.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEF8D
        stdcall MPatchCodeCave,eax,loc_4D02FD,0x004CEF93-0x004CEF8D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D02FD.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEF93
        stdcall MPatchAddress,loc_4D02FD.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEFAA
        stdcall MPatchCodeCave,eax,loc_4D031A,0x004CEFB0-0x004CEFAA
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D031A.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEFB0
        stdcall MPatchAddress,loc_4D031A.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEFE0
        stdcall MPatchCodeCave,eax,loc_4D0350,0x004CEFE6-0x004CEFE0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCB284 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D0350.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CEFE6
        stdcall MPatchAddress,loc_4D0350.fixup2,eax,1
        and     ebx,eax

        .debugpatch:
        cmp     dword[ini_opts_debugpatch],0
        je      .mainmenures

        ; init debug command-line params
        stdcall GetRealAddress,PMI_IGIExe,0x0048F4E4
        stdcall MPatchCodeCave,eax,loc_48F674,0x0048F4E9-0x0048F4E4
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F4E9
        stdcall MPatchAddress,loc_48F674.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057B8E4 ;GameFunctions_isEnableDebugKeys
        stdcall MPatchAddress,GameFunctions_SetEnableDebugKeys.fixup1,eax,0
        and     ebx,eax

        ; parse debug command-line params
        stdcall GetRealAddress,PMI_IGIExe,0x0048F548
        stdcall MPatchCodeCave,eax,loc_48F6D8,0x0048F550-0x0048F548
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F1D0 ;AppMain_ParseCmdLineArgs
        stdcall MPatchAddress,loc_48F6D8.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F550
        stdcall MPatchAddress,loc_48F6D8.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F0B0 ;AppContext_SetLightmapsUsed
        stdcall MPatchAddress,Main_ParseNoLightmapsCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F0D0 ;AppContext_SetTerrainLightmapsUsed
        stdcall MPatchAddress,Main_ParseNoTerrainLightmapCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F050 ;AppContext_SetDebugtextState
        stdcall MPatchAddress,Main_ParseDebugTextCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0048F010 ;AppContext_SetDebugged
        stdcall MPatchAddress,Main_ParseDebugCB.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C9550 ;AppContext_isFixmeSmall
        stdcall MPatchAddress,Main_ParseSmallCB.fixup1,eax,0
        and     ebx,eax

        ; replace font
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E7655
        ;stdcall MPatchAddress,eax,debugfont,0
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E7776
        ;stdcall MPatchAddress,eax,debugfont,0
        ;and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x004E78C4
        ;stdcall MPatchAddress,eax,debugfont,0
        ;and     ebx,eax

        ; disable requirement of completing all 14 missions
        stdcall GetRealAddress,PMI_IGIExe,0x00415092
        stdcall MPatchByte,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004150EA
        stdcall MPatchByte,eax,0
        and     ebx,eax

        .mainmenures:
        cmp     dword[ini_opts_mainmenures],0
        je      .end

        stdcall SetMainMenuResolution

        ; MenuManager_New - custom main menu resolution
        stdcall GetRealAddress,PMI_IGIExe,0x00418BD8
        stdcall MPatchCodeCave,eax,loc_418B38,0x00418BF0-0x00418BD8
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418BF0
        stdcall MPatchAddress,loc_418B38.fixup1,eax,1
        and     ebx,eax

        ; MenuManager_New - fix background color
        stdcall GetRealAddress,PMI_IGIExe,0x00418C7F
        stdcall MPatchCodeCave,eax,loc_418BDF,0x00418C88-0x00418C7F
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491920
        stdcall MPatchAddress,loc_418BDF.fixup1,eax,1 ;Display_SetMode
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491CE0 ;Display_SetBackgroundColourFn
        stdcall MPatchAddress,loc_418BDF.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418C88
        stdcall MPatchAddress,loc_418BDF.fixup3,eax,1
        and     ebx,eax

        ; MenuScreen_UpdateInternalDataHandler - fix decentered EU logo
        stdcall GetRealAddress,PMI_IGIExe,0x00421E99
        stdcall MPatchCodeCave,eax,loc_421AB9,0x00421EA1-0x00421E99
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005837C8 ;dword_57BC0C
        stdcall MPatchAddress,loc_421AB9.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00421EC2
        stdcall MPatchAddress,loc_421AB9.fixup2,eax,1
        and     ebx,eax

        ; MenuScreen_UpdateInternalDataHandler - fix logo position
        stdcall GetRealAddress,PMI_IGIExe,0x00421ECC
        stdcall MPatchCodeCave,eax,loc_421AEC,0x00421F33-0x00421ECC
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004B6D20 ;Picture_GetWidth
        stdcall MPatchAddress,loc_421AEC.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00533504 ;flt_533504
        stdcall MPatchAddress,loc_421AEC.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491B60 ;Display_GetActiveMode
        stdcall MPatchAddress,loc_421AEC.fixup3,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC0C ;dword_57BC0C
        stdcall MPatchAddress,loc_421AEC.fixup4,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004B6D30 ;Picture_GetHeight
        stdcall MPatchAddress,loc_421AEC.fixup5,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00533504 ;flt_533504
        stdcall MPatchAddress,loc_421AEC.fixup6,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491B60 ;Display_GetActiveMode
        stdcall MPatchAddress,loc_421AEC.fixup7,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00421F33
        stdcall MPatchAddress,loc_421AEC.fixup8,eax,1
        and     ebx,eax

        ; BackgroundFX_DrawAllObjects - fix background fx position/scale
        stdcall GetRealAddress,PMI_IGIExe,0x0041D18D
        stdcall MPatchAddress,eax,BackgroundFX_CreateMatrix,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041D1DD
        stdcall MPatchAddress,eax,BackgroundFX_CreateMatrix,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041D227
        stdcall MPatchAddress,eax,BackgroundFX_CreateMatrix,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A4 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,BackgroundFX_GetMatrixScaleXMul.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A8 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,BackgroundFX_GetMatrixScaleYMul.fixup1,eax,0
        and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x00C292A4 ;Display_tActiveMode.nWidth
        ;stdcall MPatchAddress,BackgroundFX_CreateMatrix.fixup1,eax,0
        ;and     ebx,eax

        ; TypeWriterBox_DrawHandler - fix credits rect position
        stdcall GetRealAddress,PMI_IGIExe,0x0041E114
        stdcall MPatchCodeCave,eax,loc_41A8A4,0x0041E11A-0x0041E114
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A4 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,loc_41A8A4.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A8 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,loc_41A8A4.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041E11A
        stdcall MPatchAddress,loc_41A8A4.fixup3,eax,1
        and     ebx,eax

        ; InputBox_Draw - fix input boxes position
        stdcall GetRealAddress,PMI_IGIExe,0x00419893
        stdcall MPatchCodeCave,eax,loc_41D7A3,0x004198AA-0x00419893
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A4 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,loc_41D7A3.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A8 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,loc_41D7A3.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004198AA
        stdcall MPatchAddress,loc_41D7A3.fixup3,eax,1
        and     ebx,eax

        ; add picture scaling function fom IGI2
        stdcall GetRealAddress,PMI_IGIExe,0x004B5260 ;QSprite_Register4AZ
        stdcall MPatchAddress,Q3DPicture_RegisterSize.fixup1,eax,1
        and     ebx,eax

        ; scale main menu background picture
        stdcall GetRealAddress,PMI_IGIExe,0x00422096
        stdcall MPatchCodeCave,eax,loc_421CB6,0x0042209F-0x00422096
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A8 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,loc_421CB6.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C292A4 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,loc_421CB6.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0042209F
        stdcall MPatchAddress,loc_421CB6.fixup3,eax,1
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     ebx
        ret
endp
