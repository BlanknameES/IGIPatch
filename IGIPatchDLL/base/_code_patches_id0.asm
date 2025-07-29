proc ApplyPatches_ID0 ; IGI.exe v1.0 (Region: Europe)

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
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC58 ;Cursor_nMouseX
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC5C ;Cursor_nMouseY
        stdcall MPatchAddress,Cursor_GetWindowedCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8BC4 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8C00 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,Cursor_CalcCursorPos.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B44 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B48 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,Cursor_UpdatePosition.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00424BC0
        stdcall MPatchAddress,eax,Cursor_RunHandler,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28F8C ;Mouse_tMouse.bButton
        stdcall MPatchAddress,Cursor_RunHandler.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8C00 ;AppContext_tAppContext.isFullscreen
        stdcall MPatchAddress,Cursor_UpdateSensMult.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491BE9
        stdcall MPatchCodeCave,eax,loc_491BE9,0x00491BF2-0x00491BE9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x005C8BC4 ;AppContext_tAppContext.hWnd
        stdcall MPatchAddress,loc_491BE9.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491BF2
        stdcall MPatchAddress,loc_491BE9.fixup2,eax,1
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

        stdcall SetScreenColorDepth

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

        ; Display_SetMode - save aspect ratio
        stdcall GetRealAddress,PMI_IGIExe,0x00491C3F
        stdcall MPatchCodeCave,eax,loc_491C3F,0x00491C45-0x00491C3F
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491C45
        stdcall MPatchAddress,loc_491C3F.fixup1,eax,1
        and     ebx,eax

        ; TransContext_Create
        stdcall GetRealAddress,PMI_IGIExe,0x00497DE7
        stdcall MPatchCodeCave,eax,TransContext_Create_CodeCave,0x00497E55-0x00497DE7
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCABC8 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCABB8 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vX
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCABC8 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCABBC ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vY
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup4,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCABCC ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfHeight
        stdcall MPatchAddress,TransContext_Create_CodeCave.fixup5,eax,0
        and     ebx,eax

        ; Direct3DRender_DrawRigidMesh
        stdcall GetRealAddress,PMI_IGIExe,0x0049E02E
        stdcall MPatchCodeCave,eax,loc_49E02E,0x0049E0B1-0x0049E02E
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81700 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49E02E.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCABC8 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49E02E.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00497E70 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49E02E.fixup3,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049E0B1
        stdcall MPatchAddress,loc_49E02E.fixup4,eax,1
        and     ebx,eax

        ; Direct3DRender_DrawSortedFaceGroup_Rigid
        stdcall GetRealAddress,PMI_IGIExe,0x0049F00D
        stdcall MPatchCodeCave,eax,loc_49F00D,0x0049F0A3-0x0049F00D
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAAE0 ;TransContext_tActiveTransContext
        stdcall MPatchAddress,loc_49F00D.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81700 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49F00D.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCABC8 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49F00D.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00497E70 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49F00D.fixup4,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049F0A3
        stdcall MPatchAddress,loc_49F00D.fixup5,eax,1
        and     ebx,eax

        ; Direct3DRender_DrawSortedFaceGroup_Lightmap
        stdcall GetRealAddress,PMI_IGIExe,0x0049F5AF
        stdcall MPatchCodeCave,eax,loc_49F5AF,0x0049F645-0x0049F5AF
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAAE0 ;TransContext_tActiveTransContext
        stdcall MPatchAddress,loc_49F5AF.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81700 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49F5AF.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCABC8 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49F5AF.fixup3,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00497E70 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49F5AF.fixup4,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049F645
        stdcall MPatchAddress,loc_49F5AF.fixup5,eax,1
        and     ebx,eax

        ; Direct3DRender_DrawBoneMesh
        stdcall GetRealAddress,PMI_IGIExe,0x0049F78B
        stdcall MPatchCodeCave,eax,loc_49F78B,0x0049F80F-0x0049F78B
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00B81700 ;Mesh3D_avOverrideFOV
        stdcall MPatchAddress,loc_49F78B.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCABC8 ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        stdcall MPatchAddress,loc_49F78B.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00497E70 ;TransContext_SetActiveTransContext
        stdcall MPatchAddress,loc_49F78B.fixup3,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0049F80F
        stdcall MPatchAddress,loc_49F78B.fixup4,eax,1
        and     ebx,eax

        ; ComputerObject_ProjectRotatedPos
        stdcall GetRealAddress,PMI_IGIExe,0x004675E6
        stdcall MPatchCodeCave,eax,loc_4675E6,0x004675EC-0x004675E6
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004675EC
        stdcall MPatchAddress,loc_4675E6.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004675F1
        stdcall MPatchAddress,eax,Display_GetInvAspectRatio,1
        and     ebx,eax

        ; ComputerObject_ProjectWorldPos
        stdcall GetRealAddress,PMI_IGIExe,0x004676B0
        stdcall MPatchCodeCave,eax,loc_4676B0,0x004676B8-0x004676B0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004676B8
        stdcall MPatchAddress,loc_4676B0.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004676CF
        stdcall MPatchAddress,eax,Display_GetInvAspectRatio,1
        and     ebx,eax

        ; ComputerMap_Trace
        stdcall GetRealAddress,PMI_IGIExe,0x0046A532
        stdcall MPatchAddress,eax,Display_GetRelAspectRatio,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046A550
        stdcall MPatchCodeCave,eax,loc_46A550,0x0046A557-0x0046A550
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046A557
        stdcall MPatchAddress,loc_46A550.fixup1,eax,1
        and     ebx,eax

        ; Computer_RunHandler - set scalex to Display_GetAspectRatio()
        stdcall GetRealAddress,PMI_IGIExe,0x0046BD84
        stdcall MPatchCodeCave,eax,loc_46BD84,0x0046BD8A-0x0046BD84
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0046BD8A
        stdcall MPatchAddress,loc_46BD84.fixup1,eax,1
        and     ebx,eax

        ; Mesh3D_GetRigidMeshLOD - fix rendering distance
        stdcall GetRealAddress,PMI_IGIExe,0x004CFE74
        stdcall MPatchCodeCave,eax,loc_4CFE74,0x004CFE7A-0x004CFE74
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4CFE74.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CFE7A
        stdcall MPatchAddress,loc_4CFE74.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CFE95
        stdcall MPatchCodeCave,eax,loc_4CFE95,0x004CFE9B-0x004CFE95
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4CFE95.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CFE9B
        stdcall MPatchAddress,loc_4CFE95.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CFEB2
        stdcall MPatchCodeCave,eax,loc_4CFEB2,0x004CFEB8-0x004CFEB2
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4CFEB2.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CFEB8
        stdcall MPatchAddress,loc_4CFEB2.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CFEF2
        stdcall MPatchCodeCave,eax,loc_4CFEF2,0x004CFEF8-0x004CFEF2
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4CFEF2.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004CFEF8
        stdcall MPatchAddress,loc_4CFEF2.fixup2,eax,1
        and     ebx,eax

        ; Mesh3D_GetBoneMeshLOD - fix rendering distance
        stdcall GetRealAddress,PMI_IGIExe,0x004D0097
        stdcall MPatchCodeCave,eax,loc_4D0097,0x004D009D-0x004D0097
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D0097.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D009D
        stdcall MPatchAddress,loc_4D0097.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D00B7
        stdcall MPatchCodeCave,eax,loc_4D00B7,0x004D00BD-0x004D00B7
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D00B7.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D00BD
        stdcall MPatchAddress,loc_4D00B7.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D00D4
        stdcall MPatchCodeCave,eax,loc_4D00D4,0x004D00DA-0x004D00D4
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D00D4.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D00DA
        stdcall MPatchAddress,loc_4D00D4.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D010A
        stdcall MPatchCodeCave,eax,loc_4D010A,0x004D0110-0x004D010A
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D010A.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D0110
        stdcall MPatchAddress,loc_4D010A.fixup2,eax,1
        and     ebx,eax

        ; Mesh3D_GetSplineMeshLOD - fix rendering distance
        stdcall GetRealAddress,PMI_IGIExe,0x004D02DD
        stdcall MPatchCodeCave,eax,loc_4D02DD,0x004D02E3-0x004D02DD
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D02DD.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D02E3
        stdcall MPatchAddress,loc_4D02DD.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D02FD
        stdcall MPatchCodeCave,eax,loc_4D02FD,0x004D0303-0x004D02FD
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D02FD.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D0303
        stdcall MPatchAddress,loc_4D02FD.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D031A
        stdcall MPatchCodeCave,eax,loc_4D031A,0x004D0320-0x004D031A
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D031A.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D0320
        stdcall MPatchAddress,loc_4D031A.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D0350
        stdcall MPatchCodeCave,eax,loc_4D0350,0x004D0356-0x004D0350
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00BCAB24 ;TransContext_tActiveTransContext.vFOVY
        stdcall MPatchAddress,loc_4D0350.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004D0356
        stdcall MPatchAddress,loc_4D0350.fixup2,eax,1
        and     ebx,eax

        .debugpatch:
        cmp     dword[ini_opts_debugpatch],0
        je      .mainmenures

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

        .mainmenures:
        cmp     dword[ini_opts_mainmenures],0
        je      .end

        stdcall SetMainMenuResolution

        ; MenuManager_New - custom main menu resolution
        stdcall GetRealAddress,PMI_IGIExe,0x00418B38
        stdcall MPatchCodeCave,eax,loc_418B38,0x00418B50-0x00418B38
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418B50
        stdcall MPatchAddress,loc_418B38.fixup1,eax,1
        and     ebx,eax

        ; MenuManager_New - fix background color
        stdcall GetRealAddress,PMI_IGIExe,0x00418BDF
        stdcall MPatchCodeCave,eax,loc_418BDF,0x00418BE8-0x00418BDF
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491A90
        stdcall MPatchAddress,loc_418BDF.fixup1,eax,1 ;Display_SetMode
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491E70 ;Display_SetBackgroundColourFn
        stdcall MPatchAddress,loc_418BDF.fixup2,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00418BE8
        stdcall MPatchAddress,loc_418BDF.fixup3,eax,1
        and     ebx,eax

        ; MenuScreen_UpdateInternalDataHandler - fix decentered EU logo
        stdcall GetRealAddress,PMI_IGIExe,0x00421AB9
        stdcall MPatchCodeCave,eax,loc_421AB9,0x00421AC1-0x00421AB9
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC0C ;dword_57BC0C
        stdcall MPatchAddress,loc_421AB9.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00421AE2
        stdcall MPatchAddress,loc_421AB9.fixup2,eax,1
        and     ebx,eax

        ; MenuScreen_UpdateInternalDataHandler - fix logo position
        stdcall GetRealAddress,PMI_IGIExe,0x00421AEC
        stdcall MPatchCodeCave,eax,loc_421AEC,0x00421B53-0x00421AEC
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004B6E70 ;Picture_GetWidth
        stdcall MPatchAddress,loc_421AEC.fixup1,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00533504 ;flt_533504
        stdcall MPatchAddress,loc_421AEC.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491CF0 ;Display_GetActiveMode
        stdcall MPatchAddress,loc_421AEC.fixup3,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0057BC0C ;dword_57BC0C
        stdcall MPatchAddress,loc_421AEC.fixup4,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004B6E80 ;Picture_GetHeight
        stdcall MPatchAddress,loc_421AEC.fixup5,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00533504 ;flt_533504
        stdcall MPatchAddress,loc_421AEC.fixup6,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00491CF0 ;Display_GetActiveMode
        stdcall MPatchAddress,loc_421AEC.fixup7,eax,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00421B53
        stdcall MPatchAddress,loc_421AEC.fixup8,eax,1
        and     ebx,eax

        ; BackgroundFX_DrawAllObjects - fix background fx position/scale
        stdcall GetRealAddress,PMI_IGIExe,0x0041989D
        stdcall MPatchAddress,eax,BackgroundFX_CreateMatrix,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x004198ED
        stdcall MPatchAddress,eax,BackgroundFX_CreateMatrix,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00419937
        stdcall MPatchAddress,eax,BackgroundFX_CreateMatrix,1
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B44 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,BackgroundFX_GetMatrixScaleXMul.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B48 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,BackgroundFX_GetMatrixScaleYMul.fixup1,eax,0
        and     ebx,eax
        ;stdcall GetRealAddress,PMI_IGIExe,0x00C28B44 ;Display_tActiveMode.nWidth
        ;stdcall MPatchAddress,BackgroundFX_CreateMatrix.fixup1,eax,0
        ;and     ebx,eax

        ; TypeWriterBox_DrawHandler - fix credits rect position
        stdcall GetRealAddress,PMI_IGIExe,0x0041A8A4
        stdcall MPatchCodeCave,eax,loc_41A8A4,0x0041A8AA-0x0041A8A4
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B44 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,loc_41A8A4.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B48 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,loc_41A8A4.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041A8AA
        stdcall MPatchAddress,loc_41A8A4.fixup3,eax,1
        and     ebx,eax

        ; InputBox_Draw - fix input boxes position
        stdcall GetRealAddress,PMI_IGIExe,0x0041D7A3
        stdcall MPatchCodeCave,eax,loc_41D7A3,0x0041D7BA-0x0041D7A3
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B44 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,loc_41D7A3.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B48 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,loc_41D7A3.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x0041D7BA
        stdcall MPatchAddress,loc_41D7A3.fixup3,eax,1
        and     ebx,eax

        ; add picture scaling function fom IGI2
        stdcall GetRealAddress,PMI_IGIExe,0x004B53B0 ;QSprite_Register4AZ
        stdcall MPatchAddress,Q3DPicture_RegisterSize.fixup1,eax,1
        and     ebx,eax

        ; scale main menu background picture
        stdcall GetRealAddress,PMI_IGIExe,0x00421CB6
        stdcall MPatchCodeCave,eax,loc_421CB6,0x00421CBF-0x00421CB6
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B48 ;Display_tActiveMode.nHeight
        stdcall MPatchAddress,loc_421CB6.fixup1,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00C28B44 ;Display_tActiveMode.nWidth
        stdcall MPatchAddress,loc_421CB6.fixup2,eax,0
        and     ebx,eax
        stdcall GetRealAddress,PMI_IGIExe,0x00421CBF
        stdcall MPatchAddress,loc_421CB6.fixup3,eax,1
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     ebx
        ret
endp
