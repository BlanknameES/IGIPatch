proc IniFile_LoadSettings hModule,pIniFile

        push    ebx
        mov     ebx,dword[pIniFile]

        ; initialize settings
        stdcall IniFile_InitSettings,ebx

        ; get filename
        lea     eax,[ebx+INIFILE.Filename]
        stdcall IniFile_GetSettingsFileName,dword[hModule],eax
        neg     eax
        sbb     ecx,ecx
        and     byte[ebx+INIFILE.Filename],cl

        ; read settings
        stdcall IniFile_ReadSettings,ebx

        ; verify read setting
        stdcall IniFile_VerifySettings,ebx

        .end:
        mov     eax,TRUE
        pop     ebx
        ret
endp

proc IniFile_InitSettings pIniFile

        push    ebx
        mov     ebx,dword[pIniFile]

        ; patch
        mov     dword[ebx+INIFILE.Patch.Enabled],TRUE
        mov     dword[ebx+INIFILE.Patch.Debug],FALSE

        ; modules
        mov     dword[ebx+INIFILE.Modules.CDCheckPatch],TRUE
        mov     dword[ebx+INIFILE.Modules.TimerTaskPatch],TRUE
        mov     dword[ebx+INIFILE.Modules.MouseCursorPatch],TRUE
        mov     dword[ebx+INIFILE.Modules.BorderlessPatch],TRUE
        mov     dword[ebx+INIFILE.Modules.DisplayModesFix],TRUE
        mov     dword[ebx+INIFILE.Modules.WidescreenPatch],TRUE
        mov     dword[ebx+INIFILE.Modules.DebugFeaturesPatch],TRUE
        mov     dword[ebx+INIFILE.Modules.MainMenuPatch],TRUE
        mov     dword[ebx+INIFILE.Modules.DPIAwarenessPatch],TRUE
        mov     dword[ebx+INIFILE.Modules.NewFPSLimiterPatch],TRUE

        ; settings (BorderlessPatch)
        mov     dword[ebx+INIFILE.BLP.WindowScalingMode],1

        ; settings (WidescreenPatch)
        mov     dword[ebx+INIFILE.WSP.ViewportScalingMode],0
        mov     dword[ebx+INIFILE.WSP.ViewportFOVPercent],100

        ; settings (DebugFeaturesPatch)
        mov     dword[ebx+INIFILE.DFP.AllowMultiInstance],FALSE

        ; settings (MainMenuPatch)
        mov     dword[ebx+INIFILE.MMP.MainMenuScreenWidth],-1
        mov     dword[ebx+INIFILE.MMP.MainMenuScreenHeight],-1
        mov     dword[ebx+INIFILE.MMP.MainMenuScreenBPP],-1
        mov     dword[ebx+INIFILE.MMP.MMBackgroundColorR],0x00
        mov     dword[ebx+INIFILE.MMP.MMBackgroundColorG],0x00
        mov     dword[ebx+INIFILE.MMP.MMBackgroundColorB],0x00
        mov     dword[ebx+INIFILE.MMP.MMBackgroundScalingMode],1
        mov     dword[ebx+INIFILE.MMP.MMBackgroundFXEnabled],TRUE

        ; settings (NewFPSLimiterPatch)
        mov     dword[ebx+INIFILE.NFL.TimingAPIID],1
        mov     dword[ebx+INIFILE.NFL.InputUpdateRate],-1
        mov     dword[ebx+INIFILE.NFL.MaxRenderFPS],-1
        mov     dword[ebx+INIFILE.NFL.EnableInterpolation],TRUE
        mov     dword[ebx+INIFILE.NFL.ShowFPSCounter],FALSE
        mov     dword[ebx+INIFILE.NFL.MouseSensMultX],100
        mov     dword[ebx+INIFILE.NFL.MouseSensMultY],100
        mov     dword[ebx+INIFILE.NFL.MaxMouseSensMult],100

        .end:
        pop     ebx
        ret
endp

proc IniFile_ReadSettings pIniFile

        push    ebx
        mov     ebx,dword[pIniFile]

        ; patch
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_patch,ini_key_enabled,INIFILE.Patch.Enabled
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_patch,ini_key_debug,INIFILE.Patch.Debug

        ; modules
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_cdcheck,INIFILE.Modules.CDCheckPatch
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_timertask,INIFILE.Modules.TimerTaskPatch
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_mousecursor,INIFILE.Modules.MouseCursorPatch
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_borderless,INIFILE.Modules.BorderlessPatch
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_displaymodes,INIFILE.Modules.DisplayModesFix
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_widescreen,INIFILE.Modules.WidescreenPatch
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_debugfeatures,INIFILE.Modules.DebugFeaturesPatch
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_mainmenu,INIFILE.Modules.MainMenuPatch
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_dpiawareness,INIFILE.Modules.DPIAwarenessPatch
        stdcall IniFile_ReadIntSetting,ebx,ini_sec_modules,ini_key_newfpslimiter,INIFILE.Modules.NewFPSLimiterPatch

        ; settings (BorderlessPatch)
        stdcall IniFile_ReadIntSetting,ebx,ini_key_borderless,ini_key_blp_scalingmode,INIFILE.BLP.WindowScalingMode

        ; settings (WidescreenPatch)
        stdcall IniFile_ReadIntSetting,ebx,ini_key_widescreen,ini_key_wsp_vp_scaling,INIFILE.WSP.ViewportScalingMode
        stdcall IniFile_ReadIntSetting,ebx,ini_key_widescreen,ini_key_wsp_vp_fov_per,INIFILE.WSP.ViewportFOVPercent

        ; settings (DebugFeaturesPatch)
        stdcall IniFile_ReadIntSetting,ebx,ini_key_debugfeatures,ini_key_dfp_multiinst,INIFILE.DFP.AllowMultiInstance

        ; settings (MainMenuPatch)
        stdcall IniFile_ReadIntSetting,ebx,ini_key_mainmenu,ini_key_mmp_width,INIFILE.MMP.MainMenuScreenWidth
        stdcall IniFile_ReadIntSetting,ebx,ini_key_mainmenu,ini_key_mmp_height,INIFILE.MMP.MainMenuScreenHeight
        stdcall IniFile_ReadIntSetting,ebx,ini_key_mainmenu,ini_key_mmp_bpp,INIFILE.MMP.MainMenuScreenBPP
        stdcall IniFile_ReadIntSetting,ebx,ini_key_mainmenu,ini_key_mmp_bg_color_r,INIFILE.MMP.MMBackgroundColorR
        stdcall IniFile_ReadIntSetting,ebx,ini_key_mainmenu,ini_key_mmp_bg_color_g,INIFILE.MMP.MMBackgroundColorG
        stdcall IniFile_ReadIntSetting,ebx,ini_key_mainmenu,ini_key_mmp_bg_color_b,INIFILE.MMP.MMBackgroundColorB
        stdcall IniFile_ReadIntSetting,ebx,ini_key_mainmenu,ini_key_mmp_bg_scaling,INIFILE.MMP.MMBackgroundScalingMode
        stdcall IniFile_ReadIntSetting,ebx,ini_key_mainmenu,ini_key_mmp_bg_fx_on,INIFILE.MMP.MMBackgroundFXEnabled

        ; settings (NewFPSLimiterPatch)
        stdcall IniFile_ReadIntSetting,ebx,ini_key_newfpslimiter,ini_key_nfl_timingapi,INIFILE.NFL.TimingAPIID
        stdcall IniFile_ReadIntSetting,ebx,ini_key_newfpslimiter,ini_key_nfl_inputrate,INIFILE.NFL.InputUpdateRate
        stdcall IniFile_ReadIntSetting,ebx,ini_key_newfpslimiter,ini_key_nfl_renderfps,INIFILE.NFL.MaxRenderFPS
        stdcall IniFile_ReadIntSetting,ebx,ini_key_newfpslimiter,ini_key_nfl_en_interp,INIFILE.NFL.EnableInterpolation
        stdcall IniFile_ReadIntSetting,ebx,ini_key_newfpslimiter,ini_key_nfl_fpscounter,INIFILE.NFL.ShowFPSCounter
        stdcall IniFile_ReadIntSetting,ebx,ini_key_newfpslimiter,ini_key_nfl_mousesensx,INIFILE.NFL.MouseSensMultX
        stdcall IniFile_ReadIntSetting,ebx,ini_key_newfpslimiter,ini_key_nfl_mousesensy,INIFILE.NFL.MouseSensMultY
        stdcall IniFile_ReadIntSetting,ebx,ini_key_newfpslimiter,ini_key_nfl_maxmousesen,INIFILE.NFL.MaxMouseSensMult

        .end:
        pop     ebx
        ret
endp

proc IniFile_VerifySettings pIniFile

        push    ebx esi edi
        mov     ebx,dword[pIniFile]

        ; patch
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Patch.Enabled
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Patch.Debug

        ; modules
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.CDCheckPatch
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.TimerTaskPatch
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.MouseCursorPatch
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.BorderlessPatch
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.DisplayModesFix
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.WidescreenPatch
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.DebugFeaturesPatch
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.MainMenuPatch
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.DPIAwarenessPatch
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.Modules.NewFPSLimiterPatch

        ; settings (BorderlessPatch)
        .blp_adj_scalingmode: ; valid range: 0 to 1; set to 1 if out of range
        mov     eax,dword[ebx+INIFILE.BLP.WindowScalingMode]
        cmp     eax,1+1
        sbb     ecx,ecx
        sub     eax,1
        and     eax,ecx
        add     eax,1
        mov     dword[ebx+INIFILE.BLP.WindowScalingMode],eax

        ; settings (WidescreenPatch)
        .wsp_adj_scalingmode: ; valid range: 0 to 1; set to 0 if out of range
        mov     eax,dword[ebx+INIFILE.WSP.ViewportScalingMode]
        cmp     eax,1+1
        sbb     ecx,ecx
        and     eax,ecx
        mov     dword[ebx+INIFILE.WSP.ViewportScalingMode],eax
        .wsp_clamp_fov: ; valid range: 60 to 150
        mov     eax,dword[ebx+INIFILE.WSP.ViewportFOVPercent]
        cmp     eax,60+1
        sbb     ecx,ecx
        not     ecx
        and     eax,ecx
        sub     eax,150
        sbb     ecx,ecx
        and     eax,ecx
        add     eax,150
        mov     dword[ebx+INIFILE.WSP.ViewportFOVPercent],eax
        .wsp_conv_fov: ; convert integer percentage to float multiplier
        fild    dword[ebx+INIFILE.WSP.ViewportFOVPercent]
        fdiv    dword[FPU_CONSTS.inifile.flt_100_0]
        fstp    dword[Viewport_vFOVMul]
        ; TODO: pixel perfect scaling factor?
        ; float fov_default_rad = 60.0f * (3.14159265f / 180.0f) * 0.5f; // Default 60° half-angle in radians
        ; float fov_custom_rad  = (60.0f * (fov_percent / 100.0f)) * (3.14159265f / 180.0f) * 0.5f;
        ; float Viewport_vFOVTanMul = tanf(fov_custom_rad) / tanf(fov_default_rad);

        ; settings (BorderlessPatch)
        .blp_set_multiinst:
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.DFP.AllowMultiInstance

        ; settings (MainMenuPatch)
        .mmp_get_mode:
        mov     eax,dword[ebx+INIFILE.MMP.MainMenuScreenWidth]
        mov     ecx,dword[ebx+INIFILE.MMP.MainMenuScreenHeight]
        mov     edx,dword[ebx+INIFILE.MMP.MainMenuScreenBPP]
        .mmp_adj_width: ; valid values: -1 or >= 640; set to 640 if out of range
        add     eax,1
        cmp     eax,0x80000000+1
        sbb     esi,esi
        sub     eax,1
        and     eax,esi
        add     eax,-640
        sbb     esi,esi
        and     eax,esi
        add     eax,640
        .mmp_adj_height: ; valid values: -1 or >= 480; set to 480 if out of range
        add     ecx,1
        cmp     ecx,0x80000000+1
        sbb     esi,esi
        sub     ecx,1
        and     ecx,esi
        add     ecx,-480
        sbb     esi,esi
        and     ecx,esi
        add     ecx,480
        .mmp_adj_bpp: ; valid values: -1 or >= 16; set to 16 if out of range
        add     edx,1
        cmp     edx,0x80000000+1
        sbb     esi,esi
        sub     edx,1
        and     edx,esi
        add     edx,-16
        sbb     esi,esi
        and     edx,esi
        add     edx,16
        .mmp_set_mode:
        mov     dword[ebx+INIFILE.MMP.MainMenuScreenWidth],eax
        mov     dword[ebx+INIFILE.MMP.MainMenuScreenHeight],ecx
        mov     dword[ebx+INIFILE.MMP.MainMenuScreenBPP],edx
        .mmp_adj_bgcolors: ; valid range: 0 ~ 255; set to 0 if out of range
        mov     eax,dword[ebx+INIFILE.MMP.MMBackgroundColorR]
        mov     ecx,dword[ebx+INIFILE.MMP.MMBackgroundColorG]
        mov     edx,dword[ebx+INIFILE.MMP.MMBackgroundColorB]
        cmp     eax,256
        sbb     esi,esi
        and     eax,esi
        cmp     ecx,256
        sbb     esi,esi
        and     ecx,esi
        cmp     edx,256
        sbb     esi,esi
        and     edx,esi
        mov     dword[ebx+INIFILE.MMP.MMBackgroundColorR],eax
        mov     dword[ebx+INIFILE.MMP.MMBackgroundColorG],ecx
        mov     dword[ebx+INIFILE.MMP.MMBackgroundColorB],edx
        .mmp_adj_bg_scaling: ; valid range: 0 to 2; set to 1 if out of range
        mov     eax,dword[ebx+INIFILE.MMP.MMBackgroundScalingMode]
        cmp     eax,2+1
        sbb     ecx,ecx
        sub     eax,1
        and     eax,ecx
        add     eax,1
        mov     dword[ebx+INIFILE.MMP.MMBackgroundScalingMode],eax
        .mmp_set_bg_fx:
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.MMP.MMBackgroundFXEnabled

        ; settings (NewFPSLimiterPatch)
        .nfp_adj_timingapi: ; valid range: 0 or 1; set to 1 if out of range
        mov     eax,dword[ebx+INIFILE.NFL.TimingAPIID]
        cmp     eax,1+1
        sbb     ecx,ecx
        sub     eax,1
        and     eax,ecx
        add     eax,1
        mov     dword[AccTimer_nTimingAPI],eax
        .nfp_adj_inputrate: ; valid range: -1 or any non negative number; set to -1 if out of range
        mov     eax,dword[ebx+INIFILE.NFL.InputUpdateRate]
        add     eax,1
        cmp     eax,0x80000000+1
        sbb     ecx,ecx
        and     eax,ecx
        sub     eax,1
        mov     dword[ebx+INIFILE.NFL.InputUpdateRate],eax
        .nfp_adj_renderfps: ; valid range: -1 or any non negative number; set to -1 if out of range
        mov     eax,dword[ebx+INIFILE.NFL.MaxRenderFPS]
        add     eax,1
        cmp     eax,0x80000000+1
        sbb     ecx,ecx
        and     eax,ecx
        sub     eax,1
        mov     dword[ebx+INIFILE.NFL.MaxRenderFPS],eax
        .nfp_set_interpolation:
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.NFL.EnableInterpolation
        .nfp_set_fpscounter:
        stdcall IniFile_BooleanizeSetting,ebx,INIFILE.NFL.ShowFPSCounter
        .nfp_clamp_sensx: ; valid range: 1 to 10'000 (0.01x to 100x)
        mov     eax,dword[ebx+INIFILE.NFL.MouseSensMultX]
        cmp     eax,1+1
        sbb     ecx,ecx
        not     ecx
        and     eax,ecx
        sub     eax,10000
        sbb     ecx,ecx
        and     eax,ecx
        add     eax,10000
        mov     dword[ebx+INIFILE.NFL.MouseSensMultX],eax
        .nfp_conv_sensx: ; convert integer percentage to float multiplier
        fild    dword[ebx+INIFILE.NFL.MouseSensMultX]
        fdiv    dword[FPU_CONSTS.inifile.flt_100_0]
        fstp    dword[Mouse_vCustomSensMultX]
        .nfp_clamp_sensy: ; valid range: 1 to 10'000 (0.01x to 100x)
        mov     eax,dword[ebx+INIFILE.NFL.MouseSensMultY]
        cmp     eax,1+1
        sbb     ecx,ecx
        not     ecx
        and     eax,ecx
        sub     eax,10000
        sbb     ecx,ecx
        and     eax,ecx
        add     eax,10000
        mov     dword[ebx+INIFILE.NFL.MouseSensMultY],eax
        .nfp_conv_sensy: ; convert integer percentage to float multiplier
        fild    dword[ebx+INIFILE.NFL.MouseSensMultY]
        fdiv    dword[FPU_CONSTS.inifile.flt_100_0]
        fstp    dword[Mouse_vCustomSensMultY]
        .nfp_conv_minsens: ; convert integer percentage to float multiplier
        mov     dword[InputOptions_vMinMouseSensMult],0.05
        .nfp_clamp_maxsens: ; valid range: 5 to 10'000 (0.05x to 100x)
        mov     eax,dword[ebx+INIFILE.NFL.MaxMouseSensMult]
        cmp     eax,5+1
        sbb     ecx,ecx
        not     ecx
        and     eax,ecx
        sub     eax,10000
        sbb     ecx,ecx
        and     eax,ecx
        add     eax,10000
        mov     dword[ebx+INIFILE.NFL.MaxMouseSensMult],eax
        .nfp_conv_maxsens: ; convert integer percentage to float multiplier
        fild    dword[ebx+INIFILE.NFL.MaxMouseSensMult]
        fdiv    dword[FPU_CONSTS.inifile.flt_100_0]
        fstp    dword[InputOptions_vMaxMouseSensMult]

        .end:
        pop     edi esi ebx
        ret
endp
