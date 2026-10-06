;------------------------------------------------------------
; ID 0 = IGI.exe v1.0 (Region: Europe)
;------------------------------------------------------------

proc Patcher_ApplyPatches_ID0 uiRelocValue1,uiRelocValue2

        push    ebx esi edi
        mov     ebx,TRUE
        mov     esi,dword[uiRelocValue1]
        mov     edi,dword[uiRelocValue2]

        ; proxy hooks
        stdcall Patcher_ApplyProxyHooks_ID0,esi,edi
        and     ebx,eax

        ; shared functions
        stdcall Patcher_PatchSharedFuncs_ID0,esi,edi
        and     ebx,eax

        ; regular patches
        stdcall Patcher_ApplyRegularPatches_ID0,esi,edi
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp

proc Patcher_ApplyProxyHooks_ID0 uiRelocValue1,uiRelocValue2

        push    ebx esi edi
        mov     ebx,TRUE
        mov     esi,dword[uiRelocValue1]
        mov     edi,dword[uiRelocValue2]

        ; [WidescreenPatch, NewFPSLimiterPatch, MouseCursorPatch]
        ; Display_SetMode - save width, height and aspect ratio from current active display mode
        stdcall Patcher_WriteHookReloc,0x00491C05,esi,loc_491C05,edi,0x00491C0D-0x00491C05
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_491C05.fixup1,edi,0x00491C0D,esi,TRUE
        and     ebx,eax

        ; [BorderlessPatch, DebugFeaturesPatch, NewFPSLimiterPatch]
        ; WinMain - init command-line commands
        stdcall Patcher_WriteHookReloc,0x0048F674,esi,loc_48F674,edi,0x0048F679-0x0048F674
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48F674.fixup1,edi,0x0048F679,esi,TRUE
        and     ebx,eax

        ; [BorderlessPatch, DebugFeaturesPatch, NewFPSLimiterPatch]
        ; WinMain - parse command-line commands
        stdcall Patcher_WriteHookReloc,0x0048F6D8,esi,loc_48F6D8,edi,0x0048F6E0-0x0048F6D8
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48F6D8.fixup1,edi,0x0048F360,esi,FALSE ;AppMain_ParseCmdLineArgs
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48F6D8.fixup2,edi,0x0048F6E0,esi,TRUE
        and     ebx,eax

        ; [NewFPSLimiterPatch]
        ; Direct3D_CreateDevice - save refresh rate from current set mode
        stdcall Patcher_WriteHookReloc,0x004942F3,esi,loc_4942F3,edi,0x004942FC-0x004942F3
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4942F3.fixup1,edi,0x004942FC,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x0049432E,esi,loc_49432E,edi,0x00494336-0x0049432E
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49432E.fixup1,edi,0x0049467C,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49432E.fixup2,edi,0x00494336,esi,TRUE
        and     ebx,eax

        ; [NewFPSLimiterPatch]
        ; CutScene_RunHandler - save CutScene_isRunning
        stdcall Patcher_WriteHookReloc,0x004F5245,esi,loc_4F5245,edi,0x004F524C-0x004F5245
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4F5245.fixup1,edi,0x004F524C,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4F5245.fixup2,edi,0x004F5261,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004F525B,esi,loc_4F525B,edi,0x004F5261-0x004F525B
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4F525B.fixup1,edi,0x004F5261,esi,TRUE
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp

proc Patcher_PatchSharedFuncs_ID0 uiRelocValue1,uiRelocValue2

        push    ebx esi edi
        mov     ebx,TRUE
        mov     esi,dword[uiRelocValue1]
        mov     edi,dword[uiRelocValue2]

        ; LDebug_AbortWithError
        ForceDefineSymbol LDebug_AbortWithError
        stdcall Patcher_WriteAddressReloc,LDebug_AbortWithError.fixup1,edi,0x004AF7B0,esi,TRUE ;LDebug_Error
        and     ebx,eax

        ; Game_IsPaused
        ForceDefineSymbol Game_IsPaused
        stdcall Patcher_WriteAddressReloc,Game_IsPaused.fixup1,edi,0x0057BABC,esi,FALSE ;Game_ptGame
        and     ebx,eax

        ; Flow_GetTicks (TODO: Flow_GetPlayTicks/Flow_GetPausedTicks)
        ForceDefineSymbol Flow_GetTicks
        stdcall Patcher_WriteAddressReloc,Flow_GetTicks.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax

        ; AnimController_GetTPFValue
        ForceDefineSymbol AnimController_GetTPFValue
        stdcall Patcher_WriteAddressReloc,AnimController_GetTPFValue.fixup1,edi,0x00A54658,esi,FALSE ;AnimController_nTicksPerFrame
        and     ebx,eax

        ; AnimController_SetTPFValue
        ForceDefineSymbol AnimController_SetTPFValue
        stdcall Patcher_WriteAddressReloc,AnimController_SetTPFValue.fixup1,edi,0x00A54658,esi,FALSE ;AnimController_nTicksPerFrame
        and     ebx,eax

        ; DebugText_printf_NEW
        ForceDefineSymbol DebugText_printf_NEW
        stdcall Patcher_WriteAddressReloc,DebugText_printf_NEW.fixup1,edi,0x00A5EA75,esi,FALSE ;DebugText_isEnabled
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,DebugText_printf_NEW.fixup2,edi,0x00A5EBD0,esi,FALSE ;DebugText_ptWindow
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,DebugText_printf_NEW.fixup3,edi,0x004E76E0,esi,TRUE ;TextWindow_vprintf
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp

proc Patcher_ApplyRegularPatches_ID0 uiRelocValue1,uiRelocValue2

        push    ebx esi edi
        mov     ebx,TRUE
        mov     esi,dword[uiRelocValue1]
        mov     edi,dword[uiRelocValue2]

        ;------------------------------------------------------------
        ; DPIAwarenessPatch - high priority
        ;------------------------------------------------------------

        .dpiawareness:
        cmp     dword[IniFile.Modules.DPIAwarenessPatch],FALSE
        je      .cdcheck

        stdcall SetDPIAwareness

        ;------------------------------------------------------------
        ; CDCheckPatch
        ;------------------------------------------------------------

        .cdcheck:
        cmp     dword[IniFile.Modules.CDCheckPatch],FALSE
        je      .timertask

        ; J_Open
        stdcall Patcher_WriteHookReloc,0x00402C32,esi,0x00402C37,esi,5
        and     ebx,eax

        ; Game_RunHandler
        stdcall Patcher_WriteHookReloc,0x004162A9,esi,loc_4162A9,edi,0x00416300-0x004162A9
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4162A9.fixup1,edi,0x00539560,esi,FALSE ;Game_iMissionID
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4162A9.fixup2,edi,0x00416300,esi,TRUE
        and     ebx,eax

        ; Game_CreateHandler
        stdcall Patcher_WriteHookReloc,0x00415F41,esi,0x00415F92,esi,5
        and     ebx,eax

        ; Flow_CreateHandler
        stdcall Patcher_WriteHookReloc,0x004021E7,esi,loc_4021E7,edi,0x00402239-0x004021E7
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4021E7.fixup1,edi,0x00402239,esi,TRUE
        and     ebx,eax

        ; MenuManager_New
        stdcall Patcher_WriteHookReloc,0x00418CF7,esi,loc_418CF7,edi,0x00418D53-0x00418CF7
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_418CF7.fixup1,edi,0x00418D53,esi,TRUE
        and     ebx,eax

        ;------------------------------------------------------------
        ; TimerTaskPatch
        ;------------------------------------------------------------

        .timertask:
        cmp     dword[IniFile.Modules.TimerTaskPatch],FALSE
        je      .mousecursor

        ; Timer_Open
        stdcall Patcher_WriteHookReloc,0x00490360,esi,Timer_Open_NEW,edi,0x00490370-0x00490360
        and     ebx,eax

        ; Timer_Read
        stdcall Patcher_WriteHookReloc,0x00490370,esi,Timer_Read_NEW,edi,0x00490380-0x00490370
        and     ebx,eax

        ; Timer_Close
        stdcall Patcher_WriteAddressReloc,0x0053249F+1,esi,Timer_Close_NEW,edi,TRUE
        and     ebx,eax

        ;------------------------------------------------------------
        ; MouseCursorPatch
        ;------------------------------------------------------------

        .mousecursor:
        cmp     dword[IniFile.Modules.MouseCursorPatch],FALSE
        je      .borderless

        ; Direct3D_CreateDevice - hide windows cursor in windowed mode
        stdcall Patcher_WriteHookReloc,0x004942D8,esi,0x004942E0,esi,0x004942E0-0x004942D8
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x00494305,esi,0x0049430D,esi,0x0049430D-0x00494305
        and     ebx,eax

        ; Cursor_GetWindowedCursorPos
        stdcall Patcher_WriteAddressReloc,Cursor_GetWindowedCursorPos.fixup1,edi,0x0057BC58,esi,FALSE ;Cursor_nMouseX
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Cursor_GetWindowedCursorPos.fixup2,edi,0x0057BC5C,esi,FALSE ;Cursor_nMouseY
        and     ebx,eax

        ; Cursor_GetCursorPos
        stdcall Patcher_WriteAddressReloc,Cursor_GetCursorPos.fixup1,edi,0x005C8BC4,esi,FALSE ;AppContext_tAppContext.hWnd
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Cursor_GetCursorPos.fixup2,edi,0x005C8C00,esi,FALSE ;AppContext_tAppContext.isFullscreen
        and     ebx,eax

        ; Cursor_UpdatePosition
        stdcall Patcher_WriteAddressReloc,Cursor_UpdatePosition.fixup1,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Cursor_UpdatePosition.fixup2,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax

        ; Cursor_Open - point to the new Cursor_RunHandler_NEW function
        stdcall Patcher_WriteAddressReloc,0x00424BBF+1,esi,Cursor_RunHandler_NEW,edi,FALSE
        and     ebx,eax

        ; Cursor_RunHandler_NEW - rewritten function
        stdcall Patcher_WriteAddressReloc,Cursor_RunHandler_NEW.fixup1,edi,0x00C28F8C,esi,FALSE ;Mouse_tMouse.bButton
        and     ebx,eax

        ;------------------------------------------------------------
        ; BorderlessPatch
        ;------------------------------------------------------------

        .borderless:
        cmp     dword[IniFile.Modules.BorderlessPatch],FALSE
        je      .displaymodes

        ; Main_InitBorderlessPatchCmds called by ApplyProxyHooks
        ; Main_ParseBorderlessPatchCmds called by ApplyProxyHooks

        ; AppContext_SetWindowMode
        stdcall Patcher_WriteAddressReloc,AppContext_SetWindowMode.fixup1,edi,0x005C8C00,esi,FALSE ;AppContext_tAppContext.isFullscreen
        and     ebx,eax

        ; AppContext_GetWindowMode
        stdcall Patcher_WriteAddressReloc,AppContext_GetWindowMode.fixup1,edi,0x005C8C00,esi,FALSE ;AppContext_tAppContext.isFullscreen
        and     ebx,eax

        ; WinMain - window creation
        stdcall Patcher_WriteByteReloc,0x0048F6F3,esi,0x90 ; NOP
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x0048F724,esi,loc_48F724,edi,0x0048F781-0x0048F724
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48F724.fixup1,edi,0x00541D68,esi,FALSE ;zClassName
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48F724.fixup2,edi,0x0048F790,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48F724.fixup3,edi,0x0048F781,esi,TRUE
        and     ebx,eax

        ; Display_SetMode - resolution change
        stdcall Patcher_WriteHookReloc,0x00491B7B,esi,loc_491B7B,edi,0x00491C05-0x00491B7B
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_491B7B.fixup1,edi,0x0048F0A0,esi,TRUE ;AppContext_GethWnd
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_491B7B.fixup2,edi,0x00491C05,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteByteReloc,0x00491C13+1,esi,SWP_SHOWWINDOW+SWP_DRAWFRAME+SWP_NOZORDER ;SWP_FRAMECHANGED
        and     ebx,eax

        ; Direct3D_WinProcCB - window resizing
        stdcall Patcher_WriteHookReloc,0x00494FB1,esi,loc_494FB1,edi,0x00494FC8-0x00494FB1
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_494FB1.fixup1,edi,0x00494FC8,esi,TRUE
        and     ebx,eax

        ; LoadingScreen_New - scale loading screen properly
        stdcall Patcher_WriteHookReloc,0x0048A452,esi,loc_48A452,edi,0x0048A499-0x0048A452
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48A452.fixup1,edi,0x0048A499,esi,TRUE
        and     ebx,eax

        ; LoadingScreen_New - scale loading screen properly
        stdcall Patcher_WriteHookReloc,0x0048A4AD,esi,loc_48A4AD,edi,0x0048A4B3-0x0048A4AD
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48A4AD.fixup1,edi,0x0048A4B3,esi,TRUE
        and     ebx,eax

        ; LoadingScreen_New - scale loading screen properly
        stdcall Patcher_WriteHookReloc,0x0048A50D,esi,loc_48A50D,edi,0x0048A53E-0x0048A50D
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48A50D.fixup1,edi,0x0048A53E,esi,TRUE
        and     ebx,eax

        ; TODO: call ChangeDisplaySettings with CDS_FULLSCREEN; topmost exstyle; add alt+enter functionality?

        ;------------------------------------------------------------
        ; DisplayModesFix
        ;------------------------------------------------------------

        .displaymodes:
        cmp     dword[IniFile.Modules.DisplayModesFix],FALSE
        je      .widescreen

        ; Direct3D_EnumDisplayModesCB - skip unnecessary null string checks that uses incorrect type casting
        stdcall Patcher_FillMemoryWithNOPsReloc,0x0049272B,esi,2
        and     ebx,eax
        stdcall Patcher_WriteByteReloc,0x00492737,esi,0xEB ; jnz -> jmp
        and     ebx,eax
        stdcall Patcher_FillMemoryWithNOPsReloc,0x00492769,esi,2
        and     ebx,eax
        stdcall Patcher_WriteByteReloc,0x0049276D,esi,0xEB ; jnz -> jmp
        and     ebx,eax

        ; Config_FillDisplayDevices - un-inlined code from Config_Open turned into a function
        stdcall Patcher_WriteAddressReloc,Config_FillDisplayDevices.fixup1,edi,0x005382E8,esi,FALSE ;"No D3D drivers..."
        and     ebx,eax

        ; Config_Open - init new display devices struct
        stdcall Patcher_WriteHookReloc,0x004035F5,esi,loc_4035F5,edi,0x0040362D-0x004035F5
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4035F5.fixup1,edi,0x0040362D,esi,TRUE
        and     ebx,eax

        ; Config_Open - redirect to Config_EnumDisplayModeCB_NEW
        stdcall Patcher_WriteAddressReloc,0x0040362D+1,esi,Config_EnumDisplayModeCB_NEW,edi,FALSE
        and     ebx,eax

        ; Config_Open - call to Config_UpdateDevicesDefMode
        stdcall Patcher_WriteHookReloc,0x00403642,esi,loc_403642,edi,0x00403647-0x00403642
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_403642.fixup1,edi,0x004B0F90,esi,TRUE ;RenderMode_PopRenderMode
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_403642.fixup2,edi,0x00403647,esi,TRUE
        and     ebx,eax

        ; Config_FillRenderDeviceListBox
        stdcall Patcher_WriteHookReloc,0x004046A0,esi,Config_FillRenderDeviceListBox_NEW,edi,0x00404710-0x004046A0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_FillRenderDeviceListBox_NEW.fixup1,edi,0x004A53B3,esi,TRUE ;_sprintf
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_FillRenderDeviceListBox_NEW.fixup2,edi,0x004A53B3,esi,TRUE ;_sprintf
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_FillRenderDeviceListBox_NEW.fixup3,edi,0x004A53B3,esi,TRUE ;_sprintf
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_FillRenderDeviceListBox_NEW.fixup4,edi,0x0041F2D0,esi,TRUE ;ListBox_AddItem
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_FillRenderDeviceListBox_NEW.fixup5,edi,0x00567C74,esi,FALSE ;sdefault
        and     ebx,eax

        ; Config_GraphicOptionsGetDevice
        stdcall Patcher_WriteHookReloc,0x00404710,esi,Config_GraphicOptionsGetDevice_NEW,edi,0x004047F0-0x00404710
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsGetDevice_NEW.fixup1,edi,0x00404590,esi,TRUE ;Config_GetActiveGraphicOptions
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsGetDevice_NEW.fixup2,edi,0x00567C74,esi,FALSE ;sdefault
        and     ebx,eax

        ; Config_GraphicOptionsSetDevice
        stdcall Patcher_WriteHookReloc,0x004047F0,esi,Config_GraphicOptionsSetDevice_NEW,edi,0x004048B0-0x004047F0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsSetDevice_NEW.fixup1,edi,0x004B8A20,esi,TRUE ;Script_EvalArgInt
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsSetDevice_NEW.fixup2,edi,0x00404590,esi,TRUE ;Config_GetActiveGraphicOptions
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsSetDevice_NEW.fixup3,edi,0x00567C74,esi,FALSE ;sdefault
        and     ebx,eax

        ; Config_FillScreenResolutionListBox
        stdcall Patcher_WriteHookReloc,0x00404450,esi,Config_FillScreenResolutionListBox_NEW,edi,0x00404510-0x00404450
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_FillScreenResolutionListBox_NEW.fixup1,edi,0x004B8A20,esi,TRUE ;Script_EvalArgInt
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_FillScreenResolutionListBox_NEW.fixup2,edi,0x004A53B3,esi,TRUE ;_sprintf
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_FillScreenResolutionListBox_NEW.fixup3,edi,0x0041F2D0,esi,TRUE ;ListBox_AddItem
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_FillScreenResolutionListBox_NEW.fixup4,edi,0x00567C74,esi,FALSE ;sdefault
        and     ebx,eax

        ; Config_GraphicOptionsSetResolution
        stdcall Patcher_WriteHookReloc,0x00404510,esi,Config_GraphicOptionsSetResolution_NEW,edi,0x00404590-0x00404510
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsSetResolution_NEW.fixup1,edi,0x004B8A20,esi,TRUE ;Script_EvalArgInt
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsSetResolution_NEW.fixup2,edi,0x00404590,esi,TRUE ;Config_GetActiveGraphicOptions
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsSetResolution_NEW.fixup3,edi,0x00567C74,esi,FALSE ;sdefault
        and     ebx,eax

        ; Config_GraphicOptionsGetResolution
        stdcall Patcher_WriteHookReloc,0x004045B0,esi,Config_GraphicOptionsGetResolution_NEW,edi,0x004046A0-0x004045B0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsGetResolution_NEW.fixup1,edi,0x004B8A20,esi,TRUE ;Script_EvalArgInt
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsGetResolution_NEW.fixup2,edi,0x00404590,esi,TRUE ;Config_GetActiveGraphicOptions
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_GraphicOptionsGetResolution_NEW.fixup3,edi,0x00567C74,esi,FALSE ;sdefault
        and     ebx,eax

        ; Config_VerifyGraphicConfig
        stdcall Patcher_WriteHookReloc,0x00405980,esi,Config_VerifyGraphicConfig_NEW,edi,0x00405B30-0x00405980
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Config_VerifyGraphicConfig_NEW.fixup1,edi,0x00BC2380,esi,FALSE ;Config_tConfig
        and     ebx,eax

        ; TODO: remove device if it contains no modes
        ; set default displaymode for Direct3D_SetMode, Config_ResetGraphicOptions

        ;------------------------------------------------------------
        ; WidescreenPatch
        ;------------------------------------------------------------

        .widescreen:
        cmp     dword[IniFile.Modules.WidescreenPatch],FALSE
        je      .debugfeatures

        ; TransContext_UpdateFOVData - helper function to set fov vars based on rendering mode
        stdcall Patcher_WriteAddressReloc,TransContext_UpdateFOVData.fixup1,edi,0x00BCABA0,esi,FALSE ;RenderContext_tActiveRenderContext
        and     ebx,eax

        ; TransContext_Create - set viewport rendering mode
        stdcall Patcher_WriteHookReloc,0x00497DE7,esi,loc_497DE7,edi,0x00497E55-0x00497DE7
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_497DE7.fixup1,edi,0x00BCABB8,esi,FALSE ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vX
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_497DE7.fixup2,edi,0x00BCABC8,esi,FALSE ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_497DE7.fixup3,edi,0x00BCABBC,esi,FALSE ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_497DE7.fixup4,edi,0x00BCABCC,esi,FALSE ;RenderContext_tActiveRenderContext.tClippingWindow.tClippingRect.vHalfHeight
        and     ebx,eax

        ; Direct3DRender_DrawRigidMesh - set viewport rendering mode
        stdcall Patcher_WriteHookReloc,0x0049E006,esi,loc_49E006,edi,0x0049E0B1-0x0049E006
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49E006.fixup1,edi,0x00BCAAE0,esi,FALSE ;TransContext_tActiveTransContext
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49E006.fixup2,edi,0x00B81700,esi,FALSE ;Mesh3D_avOverrideFOV
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49E006.fixup3,edi,0x00497E70,esi,TRUE ;TransContext_SetActiveTransContext
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49E006.fixup4,edi,0x0049E0B1,esi,TRUE
        and     ebx,eax

        ; Direct3DRender_DrawSortedFaceGroup_Rigid - set viewport rendering mode
        stdcall Patcher_WriteHookReloc,0x0049F00D,esi,loc_49F00D,edi,0x0049F0A3-0x0049F00D
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F00D.fixup1,edi,0x00BCAAE0,esi,FALSE ;TransContext_tActiveTransContext
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F00D.fixup2,edi,0x00B81700,esi,FALSE ;Mesh3D_avOverrideFOV
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F00D.fixup3,edi,0x00497E70,esi,TRUE ;TransContext_SetActiveTransContext
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F00D.fixup4,edi,0x0049F0A3,esi,TRUE
        and     ebx,eax

        ; Direct3DRender_DrawSortedFaceGroup_Lightmap - set viewport rendering mode
        stdcall Patcher_WriteHookReloc,0x0049F5AF,esi,loc_49F5AF,edi,0x0049F645-0x0049F5AF
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F5AF.fixup1,edi,0x00BCAAE0,esi,FALSE ;TransContext_tActiveTransContext
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F5AF.fixup2,edi,0x00B81700,esi,FALSE ;Mesh3D_avOverrideFOV
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F5AF.fixup3,edi,0x00497E70,esi,TRUE ;TransContext_SetActiveTransContext
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F5AF.fixup4,edi,0x0049F645,esi,TRUE
        and     ebx,eax

        ; Direct3DRender_DrawBoneMesh - set viewport rendering mode
        stdcall Patcher_WriteHookReloc,0x0049F766,esi,loc_49F766,edi,0x0049F80F-0x0049F766
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F766.fixup1,edi,0x00BCAAE0,esi,FALSE ;TransContext_tActiveTransContext
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F766.fixup2,edi,0x00B81700,esi,FALSE ;Mesh3D_avOverrideFOV
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F766.fixup3,edi,0x00497E70,esi,TRUE ;TransContext_SetActiveTransContext
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F766.fixup4,edi,0x0049F80F,esi,TRUE
        and     ebx,eax

        ; ComputerObject_ProjectRotatedPos - fix aspect ratio
        stdcall Patcher_WriteHookReloc,0x004675B0,esi,ComputerObject_ProjectRotatedPos_NEW,edi,0x00467620-0x004675B0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,ComputerObject_ProjectRotatedPos_NEW.fixup1,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,ComputerObject_ProjectRotatedPos_NEW.fixup2,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,ComputerObject_ProjectRotatedPos_NEW.fixup3,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,ComputerObject_ProjectRotatedPos_NEW.fixup4,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax

        ; ComputerObject_ProjectWorldPos - fix aspect ratio
        stdcall Patcher_WriteHookReloc,0x00467620,esi,ComputerObject_ProjectWorldPos_NEW,edi,0x004676F1-0x00467620
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,ComputerObject_ProjectWorldPos_NEW.fixup1,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,ComputerObject_ProjectWorldPos_NEW.fixup2,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,ComputerObject_ProjectWorldPos_NEW.fixup3,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,ComputerObject_ProjectWorldPos_NEW.fixup4,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax

        ; ComputerMap_Trace - fix aspect ratio
        stdcall Patcher_WriteHookReloc,0x0046A531,esi,loc_46A531,edi,0x0046A59A-0x0046A531
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46A531.fixup1,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46A531.fixup2,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46A531.fixup3,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46A531.fixup4,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46A531.fixup5,edi,0x0046A59A,esi,TRUE
        and     ebx,eax

        ; Computer_RunHandler - fix aspect ratio
        stdcall Patcher_WriteHookReloc,0x0046BD84,esi,loc_46BD84,edi,0x0046BD8A-0x0046BD84
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46BD84.fixup1,edi,0x0046BD8A,esi,TRUE
        and     ebx,eax

        ; TODO: vert- compatibility

        ; ModelObj_GetLOD (aka Mesh3D_GetRigidMeshLOD) - fix lod quality and rendering distance
        stdcall Patcher_WriteHookReloc,0x004CFE74,esi,loc_4CFE74,edi,0x004CFE7A-0x004CFE74
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4CFE74.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4CFE74.fixup2,edi,0x004CFE7A,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004CFE95,esi,loc_4CFE95,edi,0x004CFE9B-0x004CFE95
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4CFE95.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4CFE95.fixup2,edi,0x004CFE9B,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004CFEB2,esi,loc_4CFEB2,edi,0x004CFEB8-0x004CFEB2
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4CFEB2.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4CFEB2.fixup2,edi,0x004CFEB8,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004CFEF2,esi,loc_4CFEF2,edi,0x004CFEF8-0x004CFEF2
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4CFEF2.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4CFEF2.fixup2,edi,0x004CFEF8,esi,TRUE
        and     ebx,eax

        ; Mesh3D_GetBoneMeshLOD - fix lod quality and rendering distance
        stdcall Patcher_WriteHookReloc,0x004D0097,esi,loc_4D0097,edi,0x004D009D-0x004D0097
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D0097.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D0097.fixup2,edi,0x004D009D,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004D00B7,esi,loc_4D00B7,edi,0x004D00BD-0x004D00B7
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D00B7.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D00B7.fixup2,edi,0x004D00BD,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004D00D4,esi,loc_4D00D4,edi,0x004D00DA-0x004D00D4
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D00D4.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D00D4.fixup2,edi,0x004D00DA,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004D010A,esi,loc_4D010A,edi,0x004D0110-0x004D010A
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D010A.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D010A.fixup2,edi,0x004D0110,esi,TRUE
        and     ebx,eax

        ; Mesh3D_GetSplineMeshLOD - fix lod quality and rendering distance
        stdcall Patcher_WriteHookReloc,0x004D02DD,esi,loc_4D02DD,edi,0x004D02E3-0x004D02DD
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D02DD.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D02DD.fixup2,edi,0x004D02E3,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004D02FD,esi,loc_4D02FD,edi,0x004D0303-0x004D02FD
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D02FD.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D02FD.fixup2,edi,0x004D0303,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004D031A,esi,loc_4D031A,edi,0x004D0320-0x004D031A
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D031A.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D031A.fixup2,edi,0x004D0320,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004D0350,esi,loc_4D0350,edi,0x004D0356-0x004D0350
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D0350.fixup1,edi,0x00BCAB24,esi,FALSE ;TransContext_tActiveTransContext.vFOVY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D0350.fixup2,edi,0x004D0356,esi,TRUE
        and     ebx,eax

        ;------------------------------------------------------------
        ; DebugFeaturesPatch
        ;------------------------------------------------------------

        .debugfeatures:
        cmp     dword[IniFile.Modules.DebugFeaturesPatch],FALSE
        je      .mainmenu

        ; Main_InitDebugFeatPatchCmds called by ApplyProxyHooks
        ; Main_ParseDebugFeatPatchCmds called by ApplyProxyHooks

        ; GameFunctions_SetEnableDebugKeys
        stdcall Patcher_WriteAddressReloc,GameFunctions_SetEnableDebugKeys.fixup1,edi,0x0057B194,esi,FALSE ;GameFunctions_isEnableDebugKeys
        and     ebx,eax

        ; Main_ParseNoLightmapsCB
        stdcall Patcher_WriteAddressReloc,Main_ParseNoLightmapsCB.fixup1,edi,0x0048F240,esi,TRUE ;AppContext_SetLightmapsUsed
        and     ebx,eax

        ; Main_ParseNoTerrainLightmapCB
        stdcall Patcher_WriteAddressReloc,Main_ParseNoTerrainLightmapCB.fixup1,edi,0x0048F260,esi,TRUE ;AppContext_SetTerrainLightmapsUsed
        and     ebx,eax

        ; Main_ParseDebugTextCB
        stdcall Patcher_WriteAddressReloc,Main_ParseDebugTextCB.fixup1,edi,0x0048F1E0,esi,TRUE ;AppContext_SetDebugtextState
        and     ebx,eax

        ; Main_ParseDebugCB
        stdcall Patcher_WriteAddressReloc,Main_ParseDebugCB.fixup1,edi,0x0048F1A0,esi,TRUE ;AppContext_SetDebugged
        and     ebx,eax

        ; Main_ParseSmallCB
        stdcall Patcher_WriteAddressReloc,Main_ParseSmallCB.fixup1,edi,0x005C8E00,esi,FALSE ;AppContext_isFixmeSmall
        and     ebx,eax

        ; DebugText_Open - replace font
        ;stdcall Patcher_WriteAddressReloc,0x004E78E4+1,esi,debugfont,edi,FALSE
        ;and     ebx,eax

        ; sub_4E79A0 - replace font
        ;stdcall Patcher_WriteAddressReloc,0x004E7A05+1,esi,debugfont,edi,FALSE
        ;and     ebx,eax

        ; DebugText_Close - replace font
        ;stdcall Patcher_WriteAddressReloc,0x004E7B53+1,esi,debugfont,edi,FALSE
        ;and     ebx,eax

        ; GameFunctions_IsDebugKeyPressed - remove requirement of completing all 14 missions
        stdcall Patcher_WriteByteReloc,0x00414FFC+6,esi,0
        and     ebx,eax

        ; GameFunctions_IsDebugKeyPressedOnce - remove requirement of completing all 14 missions
        stdcall Patcher_WriteByteReloc,0x00415054+6,esi,0
        and     ebx,eax

        ; WinMain - allow multiinstance
        stdcall Patcher_WriteHookReloc,0x0048F53F,esi,loc_48F53F,edi,0x0048F544-0x0048F53F
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48F53F.fixup1,edi,0x0048F578,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48F53F.fixup2,edi,0x0048F544,esi,TRUE
        and     ebx,eax

        ;------------------------------------------------------------
        ; MainMenuPatch
        ;------------------------------------------------------------

        .mainmenu:
        cmp     dword[IniFile.Modules.MainMenuPatch],FALSE
        je      .newfpslimiter

        ; MenuManager_New - custom main menu resolution
        stdcall Patcher_WriteHookReloc,0x00418B38,esi,loc_418B38,edi,0x00418B50-0x00418B38
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_418B38.fixup1,edi,0x00418B50,esi,TRUE
        and     ebx,eax

        ; MenuManager_New - change background color (only visible if bg pic does not fully cover the client area)
        stdcall Patcher_WriteHookReloc,0x00418BDB,esi,loc_418BDB,edi,0x00418BE8-0x00418BDB
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_418BDB.fixup1,edi,0x00491A90,esi,TRUE ;Display_SetMode
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_418BDB.fixup2,edi,0x00491E70,esi,TRUE ;Display_SetBackgroundColourFn
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_418BDB.fixup3,edi,0x00418BE8,esi,TRUE
        and     ebx,eax

        ; MenuManager_New - add BackgroundFX switch
        stdcall Patcher_WriteHookReloc,0x00418CB5,esi,loc_418CB5,edi,0x00418CC1-0x00418CB5
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_418CB5.fixup1,edi,0x004199D0,esi,TRUE ;BackgroundFX_New
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_418CB5.fixup2,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_418CB5.fixup3,edi,0x00418CC1,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteByteReloc,0x00418CD3+2,esi,1*4 ; fix esp value
        and     ebx,eax

        ; MenuScreen_UpdateInternalDataHandler - fix decentered EU logo
        stdcall Patcher_WriteHookReloc,0x00421AB9,esi,loc_421AB9,edi,0x00421AC1-0x00421AB9
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AB9.fixup1,edi,0x0057BC0C,esi,FALSE ;dword_57BC0C
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AB9.fixup2,edi,0x00421AE2,esi,TRUE
        and     ebx,eax

        ; MenuScreen_UpdateInternalDataHandler - fix logo position
        stdcall Patcher_WriteHookReloc,0x00421AEC,esi,loc_421AEC,edi,0x00421B53-0x00421AEC
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AEC.fixup1,edi,0x004B6E70,esi,TRUE ;Picture_GetWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AEC.fixup2,edi,0x00533504,esi,FALSE ;flt_533504
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AEC.fixup3,edi,0x00491CF0,esi,TRUE ;Display_GetActiveMode
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AEC.fixup4,edi,0x0057BC0C,esi,FALSE ;dword_57BC0C
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AEC.fixup5,edi,0x004B6E80,esi,TRUE ;Picture_GetHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AEC.fixup6,edi,0x00533504,esi,FALSE ;flt_533504
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AEC.fixup7,edi,0x00491CF0,esi,TRUE ;Display_GetActiveMode
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421AEC.fixup8,edi,0x00421B53,esi,TRUE
        and     ebx,eax

        ; MenuScreen_UpdateInternalDataHandler - fix parameters for background picture drawing
        stdcall Patcher_WriteHookReloc,0x00421B5D,esi,loc_421B5D,edi,0x00421BC2-0x00421B5D
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421B5D.fixup1,edi,0x004B6E70,esi,TRUE ;Picture_GetWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421B5D.fixup2,edi,0x004B6E80,esi,TRUE ;Picture_GetHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421B5D.fixup3,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421B5D.fixup4,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421B5D.fixup5,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421B5D.fixup6,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421B5D.fixup7,edi,0x00421BC2,esi,TRUE
        and     ebx,eax

        ; Q3DPicture_RegisterSize - implement picture scaling function fom IGI2
        stdcall Patcher_WriteAddressReloc,Q3DPicture_RegisterSize.fixup1,edi,0x004B53B0,esi,TRUE ;QSprite_Register4AZ
        and     ebx,eax

        ; MenuScreen_DrawHandler - draw background picture with custom scaling mode
        stdcall Patcher_WriteHookReloc,0x00421CB6,esi,loc_421CB6,edi,0x00421CBF-0x00421CB6
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421CB6.fixup1,edi,0x004B6E60,esi,TRUE ;Picture_Register
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421CB6.fixup2,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421CB6.fixup3,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_421CB6.fixup4,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax

        ; BackgroundFX_DrawAllObjects - fix background fx position/scale
        stdcall Patcher_WriteAddressReloc,0x0041989D,esi,BackgroundFX_CreateMatrix_NEW,edi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,0x004198ED,esi,BackgroundFX_CreateMatrix_NEW,edi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,0x00419937,esi,BackgroundFX_CreateMatrix_NEW,edi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,BackgroundFX_CreateMatrix_NEW.fixup1,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,BackgroundFX_CreateMatrix_NEW.fixup2,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax

        ; TypeWriterBox_DrawHandler - fix credits rect position
        stdcall Patcher_WriteHookReloc,0x0041A8A4,esi,loc_41A8A4,edi,0x0041A8AA-0x0041A8A4
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_41A8A4.fixup1,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_41A8A4.fixup2,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_41A8A4.fixup3,edi,0x0041A8AA,esi,TRUE
        and     ebx,eax

        ; InputBox_DrawHandler - fix input boxes position
        stdcall Patcher_WriteHookReloc,0x0041D7A3,esi,loc_41D7A3,edi,0x0041D7BA-0x0041D7A3
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_41D7A3.fixup1,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_41D7A3.fixup2,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_41D7A3.fixup3,edi,0x0041D7BA,esi,TRUE
        and     ebx,eax

        ; Cursor_CreateHandler - fix cursor not being properly centered
        stdcall Patcher_WriteHookReloc,0x00424C20,esi,loc_424C20,edi,0x00424C2E-0x00424C20
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_424C20.fixup1,edi,0x00C28B44,esi,FALSE ;Display_tActiveMode.nWidth
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_424C20.fixup2,edi,0x00C28B48,esi,FALSE ;Display_tActiveMode.nHeight
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_424C20.fixup3,edi,0x00424C2E,esi,TRUE
        and     ebx,eax

        ;------------------------------------------------------------
        ; NewFPSLimiterPatch
        ;------------------------------------------------------------

        .newfpslimiter:
        cmp     dword[IniFile.Modules.NewFPSLimiterPatch],FALSE
        je      .minorbugs

        ; Main_InitNewFPSLimPatchCmds called by ApplyProxyHooks
        ; Main_ParseNewFPSLimPatchCmds called by ApplyProxyHooks

        ; B_Open - open accurate timer
        stdcall Patcher_WriteAddressReloc,0x00532473+1,esi,AccTimer_Open,edi,TRUE
        and     ebx,eax

        ; B_Close - close accurate timer
        stdcall Patcher_WriteAddressReloc,0x0053249A+1,esi,AccTimer_Close,edi,TRUE
        and     ebx,eax

        ; Flow_Open - set alloc mem for new members (TODO)
        ;stdcall PatchDwordReloc,0x00401FCA+1,esi,100+(0*4)
        ;and     ebx,eax

        ; Flow_CreateHandler - init new members
        stdcall Patcher_WriteHookReloc,0x004020B0,esi,loc_4020B0,edi,0x004020C9-0x004020B0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4020B0.fixup1,edi,0x005362F4,esi,FALSE ;'LOCAL:config.qsc'
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4020B0.fixup2,edi,0x004020C9,esi,TRUE
        and     ebx,eax

        ; Flow_ResetTimings - new function to reset flow timings
        ;stdcall Patcher_WriteAddressReloc,Flow_ResetTimings.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        ;and     ebx,eax

        ; Flow_SetFrequency - init new members
        stdcall Patcher_WriteHookReloc,0x00402820,esi,Flow_SetFrequency_NEW,edi,0x00402870-0x00402820
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_SetFrequency_NEW.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_SetFrequency_NEW.fixup2,edi,0x004E6030,esi,TRUE ;SoundSys_SetFrequency
        and     ebx,eax

        ; Movie_IsPlaying_NEW
        stdcall Patcher_WriteAddressReloc,Movie_IsPlaying_NEW.fixup1,edi,0x005C8E71,esi,FALSE ; some movie related var
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Movie_IsPlaying_NEW.fixup2,edi,0x005C8E70,esi,FALSE ; some movie related var
        and     ebx,eax

        ; World_ResetTracedLines
        stdcall Patcher_WriteAddressReloc,World_ResetTracedLines.fixup1,edi,0x00A4438C,esi,FALSE ;World_nTraceLines
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,World_ResetTracedLines.fixup2,edi,0x00A44390,esi,FALSE ;World_nTraceLinesActual
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,World_ResetTracedLines.fixup3,edi,0x00A44394,esi,FALSE ;World_nLineOfSights
        and     ebx,eax

        ; DebugText_Reset
        stdcall Patcher_WriteAddressReloc,DebugText_Reset.fixup1,edi,0x004E7BB0,esi,TRUE ;DebugText_Clear
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,DebugText_Reset.fixup2,edi,0x004E7B80,esi,TRUE ;DebugText_SetCursor
        and     ebx,eax

        ; Flow_IsUnlimitedFPS
        stdcall Patcher_WriteAddressReloc,Flow_IsUnlimitedFPS.fixup1,edi,0x005C8E00,esi,FALSE ;AppContext_isFixmeSmall
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_IsUnlimitedFPS.fixup2,edi,0x00A70C5B,esi,FALSE ;ScreenGrab_isRecord
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_IsUnlimitedFPS.fixup3,edi,0x00A70C5A,esi,FALSE ;ScreenGrab_isGrabSingle
        and     ebx,eax

        ; Flow_IsFPSLocked
        stdcall Patcher_WriteAddressReloc,Flow_IsFPSLocked.fixup1,edi,0x005C8BFC,esi,FALSE ;AppContext_tAppContext.isActive
        and     ebx,eax

        ; Flow_RunChildren - rewrite inlined code as standalone function
        stdcall Patcher_WriteAddressReloc,Flow_RunChildren.fixup1,edi,0x00AFA6E0,esi,FALSE ;QTask_atProtectedQTaskStack
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_RunChildren.fixup2,edi,0x00AFA7E0,esi,FALSE ;QTask_nProtectedQTaskStackOffset
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_RunChildren.fixup3,edi,0x00A96AE0,esi,FALSE ;QTask_aatQTaskFinalEvent
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_RunChildren.fixup4,edi,0x00A96AE0,esi,FALSE ;QTask_aatQTaskFinalEvent
        and     ebx,eax

        ; Flow_InterpChildren - new function to execute interpolation task list
        stdcall Patcher_WriteAddressReloc,Flow_InterpChildren.fixup1,edi,0x00A96AE0,esi,FALSE ;QTask_aatQTaskFinalEvent
        and     ebx,eax

        ; Flow_DrawChildren - rewrite inlined code as standalone function
        stdcall Patcher_WriteAddressReloc,Flow_DrawChildren.fixup1,edi,0x00AFA6E0,esi,FALSE ;QTask_atProtectedQTaskStack
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_DrawChildren.fixup2,edi,0x00AFA7E0,esi,FALSE ;QTask_nProtectedQTaskStackOffset
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_DrawChildren.fixup3,edi,0x005488C8,esi,FALSE ;Screen_eDrawQTaskEvent
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Flow_DrawChildren.fixup4,edi,0x00A96AE0,esi,FALSE ;QTask_aatQTaskFinalEvent
        and     ebx,eax

        ; Flow_RunHandler - rewrite fps limiter
        stdcall Patcher_WriteHookReloc,0x00402260,esi,loc_402260,edi,0x0040262E-0x00402260
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_402260.fixup1,edi,0x0040262E,esi,TRUE
        and     ebx,eax

        ; Flow_CalcAnimsSpeed - calculate anims speed multiplier to scale with interpolation
        stdcall Patcher_WriteAddressReloc,Flow_CalcAnimsSpeed.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax

        ; Flow_UpdateFPSCounter - draw fps counters
        stdcall Patcher_WriteAddressReloc,Flow_UpdateFPSCounter.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax

        ; Flow_Open - allocate interpolation task event/list
        stdcall Patcher_WriteHookReloc,0x00402065,esi,loc_402065,edi,0x00402070-0x00402065
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_402065.fixup1,edi,0x00567C7C,esi,FALSE ;Flow_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_402065.fixup2,edi,0x00401810,esi,TRUE ;QTask_NewQTaskEventNoContextFn
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_402065.fixup3,edi,0x004C1800,esi,TRUE ;QTaskList_New
        and     ebx,eax

        ; Flow_Close - deallocate interpolation task event/list
        stdcall Patcher_WriteHookReloc,0x004027E0,esi,loc_4027E0,edi,0x004027F0-0x004027E0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4027E0.fixup1,edi,0x004C1830,esi,TRUE ;QTaskList_Delete
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4027E0.fixup2,edi,0x004018E0,esi,TRUE ;QTask_DeleteQTaskEventNoContext
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4027E0.fixup3,edi,0x00567C7C,esi,FALSE ;Flow_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4027E0.fixup4,edi,0x00401A20,esi,TRUE ;QTask_DeleteQTaskType
        and     ebx,eax

        ; Cursor_Open - add interpolation handler
        stdcall Patcher_WriteHookReloc,0x00424C08,esi,loc_424C08,edi,0x00424C10-0x00424C08
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_424C08.fixup1,edi,0x0057BC60,esi,FALSE ;Cursor_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_424C08.fixup2,edi,0x00401530,esi,TRUE ;QTask_LinkQTaskEventHandlerNoContextFn
        and     ebx,eax

        ; Cursor_DrawInterpolateHandler - new interpolation handler
        stdcall Patcher_WriteAddressReloc,Cursor_DrawInterpolateHandler.fixup1,edi,0x00424CE0,esi,TRUE ;Cursor_RunHandler
        and     ebx,eax

        ; Cursor_RunHandler - do not update buttons down state on interpolation
        stdcall Patcher_WriteHookReloc,0x00424DEA,esi,loc_424DEA,edi,0x00424DF0-0x00424DEA
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_424DEA.fixup1,edi,0x00424DF0,esi,TRUE
        and     ebx,eax

        ; Cursor_Open - redirect nullsub to Cursor_DeleteHandler_NEW
        stdcall Patcher_WriteAddressReloc,0x00424BD3+1,esi,Cursor_DeleteHandler_NEW,edi,FALSE
        and     ebx,eax

        ; Cursor_CreateHandler - register interpolation list
        stdcall Patcher_WriteHookReloc,0x00424C3B,esi,loc_424C3B,edi,0x00424C40-0x00424C3B
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_424C3B.fixup1,edi,0x004C1790,esi,TRUE ;QTaskList_Register
        and     ebx,eax

        ; Cursor_DeleteHandler_NEW - unregister interpolation list
        stdcall Patcher_WriteAddressReloc,Cursor_DeleteHandler_NEW.fixup1,edi,0x004C17C0,esi,TRUE ;QTaskList_Remove
        and     ebx,eax

        ; HumanPlayer_Open - add interpolation handler
        stdcall Patcher_WriteHookReloc,0x0041006B,esi,loc_41006B,edi,0x00410070-0x0041006B
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_41006B.fixup1,edi,0x005385B0,esi,FALSE ;HumanPlayer_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_41006B.fixup2,edi,0x00401530,esi,TRUE ;QTask_LinkQTaskEventHandlerNoContextFn
        and     ebx,eax

        ; HumanPlayer_DrawInterpolateHandler - new interpolation handler
        stdcall Patcher_WriteAddressReloc,HumanPlayer_DrawInterpolateHandler.fixup1,edi,0x004610C0,esi,TRUE ;Human_UpdateBody
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,HumanPlayer_DrawInterpolateHandler.fixup2,edi,0x00464800,esi,TRUE ;HumanView_UpdateView
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,HumanPlayer_DrawInterpolateHandler.fixup3,edi,0x00464BD0,esi,TRUE ;HumanView_UpdateBody
        and     ebx,eax

        ; HumanCamera_Open - add interpolation handler
        stdcall Patcher_WriteHookReloc,0x00482642,esi,loc_482642,edi,0x00482650-0x00482642
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_482642.fixup1,edi,0x00540990,esi,FALSE ;HumanCamera_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_482642.fixup2,edi,0x00401530,esi,TRUE ;QTask_LinkQTaskEventHandlerNoContextFn
        and     ebx,eax

        ; HumanCamera_DrawInterpolateHandler - new interpolation handler
        stdcall Patcher_WriteAddressReloc,HumanCamera_DrawInterpolateHandler.fixup1,edi,0x00A96AE0,esi,FALSE ;QTask_aatQTaskFinalEvent
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,HumanCamera_DrawInterpolateHandler.fixup2,edi,0x00A96AE0,esi,FALSE ;QTask_aatQTaskFinalEvent
        and     ebx,eax

        ; HumanCamera_CreateHandler - register interpolation list
        stdcall Patcher_WriteHookReloc,0x004826F5,esi,loc_4826F5,edi,0x00482700-0x004826F5
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4826F5.fixup1,edi,0x004C1790,esi,TRUE ;QTaskList_Register
        and     ebx,eax

        ; HumanCamera_DeleteHandler - unregister interpolation list
        stdcall Patcher_WriteHookReloc,0x00484CEB,esi,loc_484CEB,edi,0x00484CF0-0x00484CEB
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_484CEB.fixup1,edi,0x004C17C0,esi,TRUE ;QTaskList_Remove
        and     ebx,eax

        ; StationaryGun_Open - add interpolation handler
        stdcall Patcher_WriteHookReloc,0x00474186,esi,loc_474186,edi,0x00474190-0x00474186
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_474186.fixup1,edi,0x005BE388,esi,FALSE ;StationaryGun_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_474186.fixup2,edi,0x00401530,esi,TRUE ;QTask_LinkQTaskEventHandlerNoContextFn
        and     ebx,eax

        ; StationaryGun_CreateHandler - register interpolation list
        stdcall Patcher_WriteHookReloc,0x00473EB8,esi,loc_473EB8,edi,0x00473ED0-0x00473EB8
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_473EB8.fixup1,edi,0x004C1790,esi,TRUE ;QTaskList_Register
        and     ebx,eax

        ; StationaryGun_DeleteHandler - unregister interpolation list
        stdcall Patcher_WriteHookReloc,0x0047497B,esi,loc_47497B,edi,0x00474980-0x0047497B
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_47497B.fixup1,edi,0x004C17C0,esi,TRUE ;QTaskList_Remove
        and     ebx,eax

        ; StationaryGun_RunHandler - save StationaryGun_isUsedByPlayer
        stdcall Patcher_WriteHookReloc,0x00474195,esi,loc_474195,edi,0x0047419A-0x00474195
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_474195.fixup1,edi,0x005385B0,esi,FALSE ;HumanPlayer_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_474195.fixup2,edi,0x004028B0,esi,TRUE ;Flow_GetTicks
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_474195.fixup3,edi,0x0047419A,esi,TRUE
        and     ebx,eax

        ; VUMeter_Update - fix fx bars update rate when using binoculars
        stdcall Patcher_WriteHookReloc,0x004719D3,esi,loc_4719D3,edi,0x004719D8-0x004719D3
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4719D3.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4719D3.fixup2,edi,0x004719D8,esi,TRUE
        and     ebx,eax

        ; Gun_WeaponFireHandler - fix bugged muzzle flash due to being tied to frames instead of ticks
        stdcall Patcher_WriteAddressReloc,0x00479695+1,esi,Flow_GetTicks,edi,TRUE
        and     ebx,eax

        ; GunFlame_MagicObjEnterHandler - fix bugged muzzle flash due to being tied to frames instead of ticks
        stdcall Patcher_WriteAddressReloc,0x004778EF+1,esi,Flow_GetTicks,edi,TRUE
        and     ebx,eax

        ; HumanView_UpdateBody - save Game_GetRandomState seed
        stdcall Patcher_WriteHookReloc,0x00464C28,esi,loc_464C28,edi,0x00464C2E-0x00464C28
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464C28.fixup1,edi,0x00416D20,esi,TRUE ;Game_GetRandomState
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464C28.fixup2,edi,0x00464C2E,esi,TRUE
        and     ebx,eax

        ; HumanView_UpdateBody - redirect Game_GetRandomState calls to HumanView_GetUpdateBodyRndState
        stdcall Patcher_WriteAddressReloc,0x00464C3F+1,esi,HumanView_GetUBRandomState,edi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,0x00464C6A+1,esi,HumanView_GetUBRandomState,edi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,0x00464C91+1,esi,HumanView_GetUBRandomState,edi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,0x00464D1F+1,esi,HumanView_GetUBRandomState,edi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,0x00464D4A+1,esi,HumanView_GetUBRandomState,edi,TRUE
        and     ebx,eax

        ; HumanView_UpdateBody - fix shake duration during interpolation
        stdcall Patcher_WriteHookReloc,0x00464D72,esi,loc_464D72,edi,0x00464D78-0x00464D72
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464D72.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464D72.fixup2,edi,0x00464DE2,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464D72.fixup3,edi,0x00464D78,esi,TRUE
        and     ebx,eax

        ; HumanView_UpdateBody - fix landing impact speed during interpolation
        stdcall Patcher_WriteHookReloc,0x00464E1B,esi,loc_464E1B,edi,0x00464E21-0x00464E1B
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464E1B.fixup1,edi,0x005334A8,esi,FALSE ;flt_5334A8
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464E1B.fixup2,edi,0x00464E2D,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464E1B.fixup3,edi,0x00464E2D,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464E1B.fixup4,edi,0x00464E21,esi,TRUE
        and     ebx,eax

        ; HumanView_UpdateBody - fix view model retraction speed on collision during interpolation
        stdcall Patcher_WriteHookReloc,0x00465102,esi,loc_465102,edi,0x00465108-0x00465102
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_465102.fixup1,edi,0x005339D8,esi,FALSE ;flt_5339D8
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_465102.fixup2,edi,0x005339D4,esi,FALSE ;flt_5339D4
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_465102.fixup3,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_465102.fixup4,edi,0x004651F8,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_465102.fixup5,edi,0x00465108,esi,TRUE
        and     ebx,eax

        ; HumanView_UpdateBody - fix object alpha/gamma speed during interpolation
        stdcall Patcher_WriteHookReloc,0x00465251,esi,loc_465251,edi,0x00465257-0x00465251
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_465251.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_465251.fixup2,edi,0x0046534D,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_465251.fixup3,edi,0x00465257,esi,TRUE
        and     ebx,eax

        ; HumanView_UpdateBody - update animcontroller with the right speed during interpolation
        stdcall Patcher_WriteHookReloc,0x0046553F,esi,loc_46553F,edi,0x0046555F-0x0046553F
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46553F.fixup1,edi,0x005385B0,esi,FALSE ;HumanPlayer_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46553F.fixup2,edi,0x004D3210,esi,TRUE ;AnimController_Step
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46553F.fixup3,edi,0x0046555F,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46553F.fixup4,edi,0x0046560D,esi,TRUE
        and     ebx,eax

        ; HumanView_UpdateView - skip updating debug zoom level during interpolation
        stdcall Patcher_WriteHookReloc,0x0046491B,esi,loc_46491B,edi,0x00464921-0x0046491B
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46491B.fixup1,edi,0x00464989,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_46491B.fixup2,edi,0x00464921,esi,TRUE
        and     ebx,eax

        ; Human_GetHumanCameraInfoHandler - skip checking debug keys during interpolation
        stdcall Patcher_WriteHookReloc,0x0045FD58,esi,loc_45FD58,edi,0x0045FD5E-0x0045FD58
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_45FD58.fixup1,edi,0x0045FD85,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_45FD58.fixup2,edi,0x0045FD5E,esi,TRUE
        and     ebx,eax

        ; Human_printf - skip priting text every frame
        stdcall Patcher_WriteHookReloc,0x00460C80,esi,loc_460C80,edi,0x00460C85-0x00460C80
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_460C80.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_460C80.fixup2,edi,0x00460C85,esi,TRUE
        and     ebx,eax

        ; HumanCamera_ThirdPersonControlInput - skip debug keys check during interpolation
        stdcall Patcher_WriteHookReloc,0x00482C31,esi,loc_482C31,edi,0x00482C3F-0x00482C31
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_482C31.fixup1,edi,0x00414FD0,esi,TRUE ;GameFunctions_IsDebugKeyPressed
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_482C31.fixup2,edi,0x00482C3F,esi,TRUE
        and     ebx,eax

        ; HumanCamera_MovementControlInput - skip debug keys check during interpolation
        stdcall Patcher_WriteHookReloc,0x00483415,esi,loc_483415,edi,0x0048341F-0x00483415
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_483415.fixup1,edi,0x00483455,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_483415.fixup2,edi,0x00414FD0,esi,TRUE ;GameFunctions_IsDebugKeyPressed
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_483415.fixup3,edi,0x0048341F,esi,TRUE
        and     ebx,eax

        ; HumanCamera_DeathCameraControlInput - skip debug keys check during interpolation
        stdcall Patcher_WriteHookReloc,0x00483E17,esi,loc_483E17,edi,0x00483E21-0x00483E17
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_483E17.fixup1,edi,0x00483E57,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_483E17.fixup2,edi,0x00414FD0,esi,TRUE ;GameFunctions_IsDebugKeyPressed
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_483E17.fixup3,edi,0x00483E21,esi,TRUE
        and     ebx,eax

        ; HumanCamera_ControlListInput - skip debug keys check during interpolation
        stdcall Patcher_WriteHookReloc,0x004828D0,esi,loc_4828D0,edi,0x004828DA-0x004828D0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4828D0.fixup1,edi,0x00415020,esi,TRUE ;GameFunctions_IsDebugKeyPressedOnce
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4828D0.fixup2,edi,0x004828DA,esi,TRUE
        and     ebx,eax

        ; DynCubeObj_AllocInterpData - function to automatically allocate/init the interp buffer
        stdcall Patcher_WriteAddressReloc,DynCubeObj_AllocInterpData.fixup1,edi,0x004B0C60,esi,TRUE ;Mem_AllocFn
        and     ebx,eax

        ; DynCubeObj_DeallocInterpData - function to automatically deallocate/init the interp buffer
        stdcall Patcher_WriteAddressReloc,DynCubeObj_DeallocInterpData.fixup1,edi,0x004B0D10,esi,TRUE ;Mem_DeAllocFn
        and     ebx,eax

        ; Human_CreateHandler - alloc interp data
        stdcall Patcher_WriteHookReloc,0x0045ECC0,esi,loc_45ECC0,edi,0x0045ECD0-0x0045ECC0
        and     ebx,eax

        ; Human_DeleteHandler - dealloc interp data
        stdcall Patcher_WriteHookReloc,0x0045EFC5,esi,loc_45EFC5,edi,0x0045EFD0-0x0045EFC5
        and     ebx,eax

        ; Human_RunHandler - update interp data
        stdcall Patcher_WriteHookReloc,0x0045EEA0,esi,loc_45EEA0,edi,0x0045EEA9-0x0045EEA0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_45EEA0.fixup1,edi,0x0045EEA9,esi,TRUE
        and     ebx,eax

        ; HumanView_Open - redirect generic _RunHandler to HumanView_RunHandler
        stdcall Patcher_WriteAddressReloc,0x00464292+1,esi,HumanView_RunHandler_NEW,edi,FALSE
        and     ebx,eax

        ; HumanView_CreateHandler - alloc interp data
        stdcall Patcher_WriteHookReloc,0x00464466,esi,loc_464466,edi,0x00464470-0x00464466
        and     ebx,eax

        ; HumanView_DeleteHandler - dealloc interp data
        stdcall Patcher_WriteHookReloc,0x00464470,esi,loc_464470,edi,0x00464475-0x00464470
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464470.fixup1,edi,0x00464475,esi,TRUE
        and     ebx,eax

        ; HumanView_RunHandler_NEW - update interp data
        stdcall Patcher_WriteAddressReloc,HumanView_RunHandler_NEW.fixup1,edi,0x00488707,esi,TRUE
        and     ebx,eax

        ; Gun_CreateHandler - alloc interp data
        stdcall Patcher_WriteHookReloc,0x004785E5,esi,loc_4785E5,edi,0x004785F0-0x004785E5
        and     ebx,eax

        ; Gun_DeleteHandler - dealloc interp data
        stdcall Patcher_WriteHookReloc,0x004788C6,esi,loc_4788C6,edi,0x004788D0-0x004788C6
        and     ebx,eax

        ; Gun_RunHandler - update interp data
        stdcall Patcher_WriteHookReloc,0x00478649,esi,loc_478649,edi,0x0047864F-0x00478649
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_478649.fixup1,edi,0x0047864F,esi,TRUE
        and     ebx,eax

        ; Door_CreateHandler - alloc interp data
        stdcall Patcher_WriteHookReloc,0x00446AAF,esi,loc_446AAF,edi,0x00446AC0-0x00446AAF
        and     ebx,eax

        ; Door_DeleteHandler - dealloc interp data
        stdcall Patcher_WriteHookReloc,0x00446B49,esi,loc_446B49,edi,0x00446B50-0x00446B49
        and     ebx,eax

        ; Door_RunHandler - update interp data
        stdcall Patcher_WriteHookReloc,0x00446D1F,esi,loc_446D1F,edi,0x00446D27-0x00446D1F
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_446D1F.fixup1,edi,0x00446D27,esi,TRUE
        and     ebx,eax

        ; Elevator_CreateHandler - alloc interp data
        stdcall Patcher_WriteHookReloc,0x0043D273,esi,loc_43D273,edi,0x0043D280-0x0043D273
        and     ebx,eax

        ; Elevator_DeleteHandler - dealloc interp data
        stdcall Patcher_WriteHookReloc,0x0043DD90,esi,loc_43DD90,edi,0x0043DDA0-0x0043DD90
        and     ebx,eax

        ; Elevator_RunHandler - update interp data
        stdcall Patcher_WriteHookReloc,0x0043D28A,esi,loc_43D28A,edi,0x0043D290-0x0043D28A
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_43D28A.fixup1,edi,0x0043D290,esi,TRUE
        and     ebx,eax

        ; Switch_CreateHandler - alloc interp data
        stdcall Patcher_WriteHookReloc,0x004450DD,esi,loc_4450DD,edi,0x004450F0-0x004450DD
        and     ebx,eax

        ; Switch_DeleteHandler - dealloc interp data
        stdcall Patcher_WriteHookReloc,0x004452D1,esi,loc_4452D1,edi,0x004452E0-0x004452D1
        and     ebx,eax

        ; Switch_RunHandler - update interp data
        stdcall Patcher_WriteHookReloc,0x004450F4,esi,loc_4450F4,edi,0x004450F9-0x004450F4
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4450F4.fixup1,edi,0x004450F9,esi,TRUE
        and     ebx,eax

        ; GunCasing_CreateHandler - alloc interp data
        stdcall Patcher_WriteHookReloc,0x004782C1,esi,loc_4782C1,edi,0x004782D0-0x004782C1
        and     ebx,eax

        ; GunCasing_DeleteHandler - dealloc interp data
        stdcall Patcher_WriteHookReloc,0x00478505,esi,loc_478505,edi,0x00478510-0x00478505
        and     ebx,eax

        ; GunCasing_RunHandler - update interp data
        stdcall Patcher_WriteHookReloc,0x004782D0,esi,loc_4782D0,edi,0x004782D7-0x004782D0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4782D0.fixup1,edi,0x004782D7,esi,TRUE
        and     ebx,eax

        ; QTask_IsRDCOTaskTypeInterpolable - checks if specified RigidDynCubeObj is interpolable
        stdcall Patcher_WriteAddressReloc,QTask_IsRDCOTaskTypeInterpolable.fixup1,edi,0x005BE3C6,esi,FALSE ;Gun_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,QTask_IsRDCOTaskTypeInterpolable.fixup2,edi,0x00A774B0,esi,FALSE ;PhysicsObj_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,QTask_IsRDCOTaskTypeInterpolable.fixup3,edi,0x00401CF0,esi,TRUE ;QTask_IsQTaskTypeDerived
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,QTask_IsRDCOTaskTypeInterpolable.fixup4,edi,0x0057C1C0,esi,FALSE ;Door_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,QTask_IsRDCOTaskTypeInterpolable.fixup5,edi,0x0057C108,esi,FALSE ;Elevator_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,QTask_IsRDCOTaskTypeInterpolable.fixup6,edi,0x0057C1B8,esi,FALSE ;Switch_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,QTask_IsRDCOTaskTypeInterpolable.fixup7,edi,0x005BE3C4,esi,FALSE ;GunCasing_eQTaskType
        and     ebx,eax

        ; QTask_IsBDCOTaskTypeInterpolable - checks if specified BoneDynCubeObj is interpolable
        stdcall Patcher_WriteAddressReloc,QTask_IsBDCOTaskTypeInterpolable.fixup1,edi,0x005BDAF8,esi,FALSE ;Human_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,QTask_IsBDCOTaskTypeInterpolable.fixup2,edi,0x00401CF0,esi,TRUE ;QTask_IsQTaskTypeDerived
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,QTask_IsBDCOTaskTypeInterpolable.fixup3,edi,0x005BDC40,esi,FALSE ;HumanView_eQTaskType
        and     ebx,eax

        ; Flow_CalcInterpolatedPosByVel - new function to calculate pos interpolation using velocity (backward extrapolation?)
        stdcall Patcher_WriteAddressReloc,Flow_CalcInterpolatedPosByVel.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        ;stdcall Patcher_WriteAddressReloc,Flow_CalcInterpolatedPosByVel32.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        ;and     ebx,eax

        ; Flow_CalcInterpolatedPos - new function to calculate pos interpolation
        stdcall Patcher_WriteAddressReloc,Flow_CalcInterpolatedPos.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        ;stdcall Patcher_WriteAddressReloc,Flow_CalcInterpolatedPos32.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        ;and     ebx,eax

        ; ViewportQTask_DrawHandler - interpolate (camera)
        stdcall Patcher_WriteHookReloc,0x004E7F50,esi,loc_4E7F50,edi,0x004E7F62-0x004E7F50
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4E7F50.fixup1,edi,0x00540990,esi,FALSE ;HumanCamera_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4E7F50.fixup2,edi,0x004E7F62,esi,TRUE
        and     ebx,eax

        ; HumanView_EnterHandler - interpolate (1st person view model)
        stdcall Patcher_WriteHookReloc,0x004644EE,esi,loc_4644EE,edi,0x004644F3-0x004644EE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4644EE.fixup1,edi,0x004D9610,esi,TRUE ;BoneDynCubeObj_GetQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4644EE.fixup2,edi,0x004644F3,esi,TRUE
        and     ebx,eax

        ; Human_gun_event_related_3 - interpolate (1st person gun model part 1)
        stdcall Patcher_WriteHookReloc,0x00460133,esi,loc_460133,edi,0x00460139-0x00460133
        and     ebx,eax

        ; Human_gun_event_related_3 - interpolate (1st person gun model part 1)
        stdcall Patcher_WriteHookReloc,0x00460187,esi,loc_460187,edi,0x004601A0-0x00460187
        and     ebx,eax

        ; Human_gun_event_related_4 - interpolate (1st person gun model part 2)
        stdcall Patcher_WriteHookReloc,0x00460202,esi,loc_460202,edi,0x0046020C-0x00460202
        and     ebx,eax

        ; Human_gun_event_related_5 - interpolate (1st person gun model part 3)
        stdcall Patcher_WriteHookReloc,0x00460272,esi,loc_460272,edi,0x0046027C-0x00460272
        and     ebx,eax

        ; RigidDynCubeObj_EnterHandler - interpolate (RigidDynCubeObj entities)
        stdcall Patcher_WriteHookReloc,0x004A01DC,esi,loc_4A01DC,edi,0x004A01F0-0x004A01DC
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4A01DC.fixup1,edi,0x00B46D14,esi,FALSE ;Mesh3D_eDrawRigidMeshRenderModeMethod
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4A01DC.fixup2,edi,0x00A94E84,esi,FALSE ;RenderMode_tActiveRenderMode.apfRenderModeMethod
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4A01DC.fixup3,edi,0x004A01F0,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteByteReloc,0x004A01F7+3,esi,64h-40h ; fix esp offset value
        and     ebx,eax
        stdcall Patcher_WriteByteReloc,0x004A0207+3,esi,64h-28h ; fix esp offset value
        and     ebx,eax
        stdcall Patcher_WriteByteReloc,0x004A0210+2,esi,0*0 ; fix adjusted esp value
        and     ebx,eax

        ; BoneDynCubeObj_EnterHandler - interpolate (BoneDynCubeObj entities)
        stdcall Patcher_WriteHookReloc,0x005124EB,esi,loc_5124EB,edi,0x0051250D-0x005124EB
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_5124EB.fixup1,edi,0x00B81880,esi,FALSE ;Mesh3D_eDrawBoneMeshRenderModeMethod
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_5124EB.fixup2,edi,0x00A94E84,esi,FALSE ;RenderMode_tActiveRenderMode.apfRenderModeMethod
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_5124EB.fixup3,edi,0x0051250D,esi,TRUE
        and     ebx,eax

        ; Direct3DRender_DrawRigidMesh - read interpolated pos from second context
        stdcall Patcher_WriteHookReloc,0x0049E0B1,esi,loc_49E0B1,edi,0x0049E0BA-0x0049E0B1
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49E0B1.fixup1,edi,0x00BCAB08,esi,FALSE ;TransContext_tActiveTransContext.tPos.vX
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49E0B1.fixup2,edi,0x0049E0BA,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteWordReloc,0x0049E0BE+1,esi,0x0847 ; qword[ebx+28h] -> qword[edi+8]
        and     ebx,eax
        stdcall Patcher_WriteWordReloc,0x0049E0CB+1,esi,0x1047 ; qword[ebx+30h] -> qword[edi+10h]
        and     ebx,eax

        ; Direct3DRender_DrawRigidMesh - read interpolated pos from second context
        stdcall Patcher_WriteHookReloc,0x0049E272,esi,loc_49E272,edi,0x0049E27B-0x0049E272
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49E272.fixup1,edi,0x00BCAB08,esi,FALSE ;TransContext_tActiveTransContext.tPos.vX
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49E272.fixup2,edi,0x0049E27B,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteWordReloc,0x0049E27B+1,esi,0x0847 ; qword[ebx+28h] -> qword[edi+8]
        and     ebx,eax
        stdcall Patcher_WriteWordReloc,0x0049E284+1,esi,0x1047 ; qword[ebx+30h] -> qword[edi+10h]
        and     ebx,eax

        ; Direct3DRender_DrawBoneMesh - read interpolated pos from second context
        stdcall Patcher_WriteHookReloc,0x0049F80F,esi,loc_49F80F,edi,0x0049F815-0x0049F80F
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_49F80F.fixup1,edi,0x0049F815,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteWordReloc,0x0049F834+1,esi,0x0847 ; qword[ebp+28h] -> qword[edi+8]
        and     ebx,eax
        stdcall Patcher_WriteWordReloc,0x0049F841+1,esi,0x1047 ; qword[ebp+30h] -> qword[edi+10h]
        and     ebx,eax

        ; Shadow_MagicObjEnterHandler - interpolate
        stdcall Patcher_WriteHookReloc,0x004E0C8A,esi,loc_4E0C8A,edi,0x004E0C8F-0x004E0C8A
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4E0C8A.fixup1,edi,0x004E0C8F,esi,TRUE
        and     ebx,eax

        ; sub_4D4B60 - interpolate anims
        stdcall Patcher_WriteHookReloc,0x004D4B95,esi,loc_4D4B95,edi,0x004D4B9B-0x004D4B95
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4D4B95.fixup1,edi,0x004D4B9B,esi,TRUE
        and     ebx,eax

        ; Flow_UpdateCInput - new function to handle short interval input updates
        stdcall Patcher_WriteAddressReloc,Flow_UpdateCInput.fixup1,edi,0x0048FC20,esi,TRUE ;Mouse_Update
        and     ebx,eax

        ; InputOptions_UpdateMouseSensitivity - updates mouse sensitivity multiplier variable
        stdcall Patcher_WriteAddressReloc,InputOptions_UpdateMouseSensitivity.fixup1,edi,0x00406220,esi,TRUE ;Config_GetActivePlayerProfile
        and     ebx,eax

        ; Mouse_ClearInput - new function to clear mouse input
        stdcall Patcher_WriteAddressReloc,Mouse_ClearInput.fixup1,edi,0x00C28F8C,esi,FALSE ;Mouse_tMouse.bButton
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Mouse_ClearInput.fixup2,edi,0x005C8BE0,esi,FALSE ;AppContext_tAppContext.isWinMessageInput
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Mouse_ClearInput.fixup3,edi,0x005C8E10,esi,FALSE ;Mouse_nLButtonDown
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Mouse_ClearInput.fixup4,edi,0x005C8E0C,esi,FALSE ;Mouse_nRButtonDown
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Mouse_ClearInput.fixup5,edi,0x005C8E18,esi,FALSE ;Mouse_nMButtonDown
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Mouse_ClearInput.fixup6,edi,0x005C8E08,esi,FALSE ;Mouse_nMouseWheel
        and     ebx,eax

        ; Mouse_WinProcCB - fix mouse motion/buttons getting stuck when window gets out of focus
        stdcall Patcher_WriteHookReloc,0x0048FED0,esi,loc_48FED0,edi,0x0048FED9-0x0048FED0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48FED0.fixup1,edi,0x005C8BE0,esi,FALSE ;AppContext_tAppContext.isWinMessageInput
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48FED0.fixup2,edi,0x0048FED9,esi,TRUE
        and     ebx,eax

        ; Mouse_Update - fix mouse sensitivity being tied to fps / add option for custom mouse sensitivty multiplier / add IsLocked support
        stdcall Patcher_WriteHookReloc,0x0048FC7B,esi,loc_48FC7B,edi,0x0048FC9B-0x0048FC7B
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_48FC7B.fixup1,edi,0x0048FC9B,esi,TRUE
        and     ebx,eax

        ; Mouse_WriteBufferedButtons - writes mouse button clicks into a accumulator
        stdcall Patcher_WriteAddressReloc,Mouse_WriteBufferedButtons.fixup1,edi,0x00C28F8C,esi,FALSE ;Mouse_tMouse.bButton
        and     ebx,eax

        ; Mouse_ReadBufferedButtons - reads mouse button clicks from the accumulator
        stdcall Patcher_WriteAddressReloc,Mouse_ReadBufferedButtons.fixup1,edi,0x00567C8C,esi,FALSE ;Flow_ptFlow
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,Mouse_ReadBufferedButtons.fixup2,edi,0x00C28F8C,esi,FALSE ;Mouse_tMouse.bButton
        and     ebx,eax

        ; InputPort_Open - rewrite function
        stdcall Patcher_WriteAddressReloc,0x004ED527+1,esi,InputPort_RunHandler_NEW,edi,FALSE
        and     ebx,eax

        ; InputPort_RunHandler_NEW
        stdcall Patcher_WriteAddressReloc,InputPort_RunHandler_NEW.fixup1,edi,0x00490230,esi,TRUE ;Keyboard_Update
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,InputPort_RunHandler_NEW.fixup2,edi,0x00509CF0,esi,TRUE ;Joypad_Update
        and     ebx,eax

        ; InputPort_Update - new function equivalent to InputPort_RunHandler minus the per-device update calls
        stdcall Patcher_WriteAddressReloc,InputPort_Update.fixup1,edi,0x00BC20A0,esi,FALSE ;InputPort.atInputPort[0]
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,InputPort_Update.fixup2,edi,0x00A5EF9C,esi,FALSE ;InputPort_eCurrentPort
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,InputPort_Update.fixup3,edi,0x00507EC0,esi,TRUE ;Input_Run
        and     ebx,eax

        ; InputPort_UpdateOnRun - new function to update analog x/y from current phase
        stdcall Patcher_WriteAddressReloc,InputPort_UpdateOnRun.fixup1,edi,0x00A5EF9C,esi,FALSE ;InputPort_eCurrentPort
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,InputPort_UpdateOnRun.fixup2,edi,0x00BC20AC,esi,FALSE ;InputPort.atInputPort[0].eAnalogInputPortDevice
        and     ebx,eax

        ; InputPort_UpdateOnInterp - new function to update analog x/y from current phase
        stdcall Patcher_WriteAddressReloc,InputPort_UpdateOnInterp.fixup1,edi,0x00A5EF9C,esi,FALSE ;InputPort_eCurrentPort
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,InputPort_UpdateOnInterp.fixup2,edi,0x00BC20AC,esi,FALSE ;InputPort.atInputPort[0].eAnalogInputPortDevice
        and     ebx,eax

        ; InputPort_UpdateOnDraw - new function to update analog x/y from current phase
        stdcall Patcher_WriteAddressReloc,InputPort_UpdateOnDraw.fixup1,edi,0x00A5EF9C,esi,FALSE ;InputPort_eCurrentPort
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,InputPort_UpdateOnDraw.fixup2,edi,0x00BC20AC,esi,FALSE ;InputPort.atInputPort[0].eAnalogInputPortDevice
        and     ebx,eax

        ; InputPort_InputHandler - point to Mouse_vAnalogX/Y
        stdcall Patcher_WriteAddressReloc,0x004ED0C1+1,esi,Mouse_vAnalogY,edi,FALSE
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,0x004ED0C8+2,esi,Mouse_vAnalogX,edi,FALSE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004ED420,esi,loc_4ED420,edi,0x004ED510-0x004ED420
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4ED420.fixup1,edi,0x00BC20B0,esi,FALSE ;InputPort.atInputPort[0].vX
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4ED420.fixup2,edi,0x00BC20B4,esi,FALSE ;InputPort.atInputPort[0].vY
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4ED420.fixup3,edi,0x00BC20B8,esi,FALSE ;InputPort.atInputPort[0].v0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4ED420.fixup4,edi,0x00BC20BC,esi,FALSE ;InputPort.atInputPort[0].v1
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4ED420.fixup5,edi,0x00BC20AC,esi,FALSE ;InputPort.atInputPort[0].eAnalogInputPortDevice
        and     ebx,eax

        ; HumanPlayerInput_ReadChannels - apply correct per-phase mouse delta
        stdcall Patcher_WriteHookReloc,0x0045E07E,esi,loc_45E07E,edi,0x0045E09D-0x0045E07E
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_45E07E.fixup1,edi,0x00BC210C,esi,FALSE ;dword_BC210C
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_45E07E.fixup2,edi,0x0045E09D,esi,TRUE
        and     ebx,eax

        ; HumanPlayerInput_ReadChannels - apply correct per-phase mouse delta
        stdcall Patcher_WriteHookReloc,0x0045E0E4,esi,loc_45E0E4,edi,0x0045E159-0x0045E0E4
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_45E0E4.fixup1,edi,0x0045E159,esi,TRUE
        and     ebx,eax

        ; Human_UpdateBody - apply correct per-phase mouse delta
        stdcall Patcher_WriteHookReloc,0x004612D7,esi,loc_4612D7,edi,0x004612E5-0x004612D7
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4612D7.fixup1,edi,0x005385B0,esi,FALSE ;HumanPlayer_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4612D7.fixup2,edi,0x004612E5,esi,TRUE
        and     ebx,eax

        ; HumanView_UpdateView - apply correct per-phase mouse delta
        stdcall Patcher_WriteHookReloc,0x00464826,esi,loc_464826,edi,0x0046484D-0x00464826
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464826.fixup1,edi,0x005385B0,esi,FALSE ;HumanPlayer_eQTaskType
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464826.fixup2,edi,0x005335C0,esi,FALSE ;dbl_5335C0
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_464826.fixup3,edi,0x0046484D,esi,TRUE
        and     ebx,eax

        ; HumanCamera_MovementControlInput - apply correct per-phase mouse delta
        stdcall Patcher_WriteHookReloc,0x00483455,esi,loc_483455,edi,0x0048346D-0x00483455
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_483455.fixup1,edi,0x0048346D,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x004834AB,esi,loc_4834AB,edi,0x004834B7-0x004834AB
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_4834AB.fixup1,edi,0x004834B7,esi,TRUE
        and     ebx,eax

        ; HumanCamera_DeathCameraControlInput - apply correct per-phase mouse delta
        stdcall Patcher_WriteHookReloc,0x00483E57,esi,loc_483E57,edi,0x00483E63-0x00483E57
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_483E57.fixup1,edi,0x00483E63,esi,TRUE
        and     ebx,eax
        stdcall Patcher_WriteHookReloc,0x00483E67,esi,loc_483E67,edi,0x00483E73-0x00483E67
        and     ebx,eax
        stdcall Patcher_WriteAddressReloc,loc_483E67.fixup1,edi,0x00483E73,esi,TRUE
        and     ebx,eax

        ;------------------------------------------------------------
        ; MinorBugFixes (TODO)
        ;------------------------------------------------------------

        .minorbugs:
        ;cmp     dword[IniFile.Modules.MinorBugFixes],FALSE
        ;je      .end

        ; fix inconsistent zoom level
        stdcall Patcher_WriteDwordReloc,0x00533A80,esi,1.0416667 ; 1.0 / 0.96 = 1.0416667 (used to be 1.04, which is wrong)
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp
