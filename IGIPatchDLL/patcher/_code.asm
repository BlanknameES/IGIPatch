proc StartPatch

        push    ebx

        ; verify dll was not already loaded
        cmp     dword[hThisExe],INVALID_HANDLE_VALUE
        jne     .msg_already_loaded

        ; get process handle
        invoke  GetModuleHandle,NULL
        mov     dword[hThisExe],eax

        ; dynamic linking initialization
        stdcall App_InitRunTimeDynamicLinking

        ; load ini settings
        stdcall IniFile_LoadSettings,dword[hThisDLL],IniFile
        cmp     dword[IniFile.Patch.Enabled],FALSE
        je      .msg_patch_disabled

        ; find matching version id
        stdcall Patcher_FindMatchingVersionID,buildarray
        mov     dword[Patcher_uiCurVersionID],eax
        cmp     eax,-1
        je      .msg_unknown_version

        ; get PMI handle matching version id
        stdcall Patcher_GetPMIFromVersionID,eax
        mov     dword[Patcher_pCurPMIHandle],eax

        ; update current module data
        stdcall Patcher_RebasePMI,eax

        ; apply patches
        stdcall Patcher_ApplyPatches,dword[Patcher_uiCurVersionID],dword[Patcher_pCurPMIHandle]
        mov     ebx,eax

        ; show patching result
        stdcall Patcher_DMessageBoxByResult,NULL,eax,wszPDPatchingSuccess,wszPDCapInfo,wszPDPatchingFailure,wszPDCapError

        .check_result:
        test    ebx,ebx
        jz      .end

        ; load plugins
        stdcall Patcher_LoadPlugins

        ; show plugins result
        ;stdcall Patcher_DMessageBoxByResult,NULL,eax,wszPDPluginsLoaded,wszPDCapInfo,wszPDPluginsFailed,wszPDCapError

        .end:
        pop     ebx
        ret

        .msg_already_loaded:
        stdcall Patcher_DMessageBox,NULL,wszPDPatchAlrLoaded,wszPDCapWarn,MB_OK+MB_ICONWARNING
        jmp     .end

        .msg_patch_disabled:
        stdcall Patcher_DMessageBox,NULL,wszPDPatchDisabled,wszPDCapWarn,MB_OK+MB_ICONWARNING
        jmp     .end

        .msg_unknown_version:
        stdcall Patcher_DMessageBox,NULL,wszPDUnknownVersion,wszPDCapError,MB_OK+MB_ICONERROR
        jmp     .end
endp

proc Patcher_FindMatchingVersionID pBuildArray

        locals
                dwCurBaseAddr dd ?
        endl

        push    ebx esi edi

        .loop_init:
        mov     eax,dword[hThisExe]
        mov     dword[dwCurBaseAddr],eax
        xor     ebx,ebx ;uiVersionID
        mov     edi,dword[pBuildArray]
        mov     esi,dword[edi+PATCHER_BUILD_ARRAY.num_entries]
        test    esi,esi
        jz      .error

        .loop_body:
        mov     eax,dword[dwCurBaseAddr]
        mov     ecx,dword[edi+PATCHER_BUILD_ARRAY.entry_id0.ppmi]
        mov     edx,dword[ecx+PATCHER_MODULE_INFO.dwDefBaseAddr]
        sub     eax,edx
        add     eax,dword[edi+PATCHER_BUILD_ARRAY.entry_id0.addr]
        mov     ecx,dword[edi+PATCHER_BUILD_ARRAY.entry_id0.pstr]
        mov     edx,dword[edi+PATCHER_BUILD_ARRAY.entry_id0.size]
        stdcall EqualMemory,eax,ecx,edx ; NOTE: not safe
        test    eax,eax
        jnz     .end

        .loop_next:
        add     ebx,1
        add     edi,sizeof.PATCHER_BUILD_ENTRY
        sub     esi,1
        jnz     .loop_body

        .error:
        or      ebx,-1

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp

proc Patcher_RebasePMI pPMI

        push    ebx
        mov     ebx,dword[pPMI]

        .calc_data:
        mov     eax,dword[ebx+PATCHER_MODULE_INFO.dwDefBaseAddr]
        mov     ecx,dword[hThisExe] ;dwCurBaseAddr
        mov     edx,ecx
        sub     edx,eax

        .update_vars:
        mov     dword[ebx+PATCHER_MODULE_INFO.dwDefBaseAddr],eax
        mov     dword[ebx+PATCHER_MODULE_INFO.dwCurBaseAddr],ecx
        mov     dword[ebx+PATCHER_MODULE_INFO.uiRelocValue],edx

        .end:
        pop     ebx
        ret
endp

proc Patcher_LoadPlugins

        locals
                wszPluginsDir rw MAX_PATH
                wszTempPath rw MAX_PATH
                hFindData WIN32_FIND_DATAW
                hCurPlugin dd ?
                wszAppendDir du '.\plugins\',0,0 ; (11+1)*2 bytes
                wszSearchFmt du '.\*.dll',0 ; 8*2 bytes
                szProcName db 'LoadPlugin',0,0 ; 11+1 bytes
        endl

        push    ebx esi edi
        lea     esi,[wszPluginsDir]
        lea     edi,[wszTempPath] ; module path / search path / plugin path

        .build_plugins_dir:
        stdcall GetModuleFileNameSafe,NULL,edi,MAX_PATH
        test    eax,eax
        jz      .end
        invoke  PathCanonicalize,esi,edi
        test    eax,eax
        jz      .end
        invoke  PathRemoveFileSpec,esi
        test    eax,eax
        jz      .end
        lea     eax,[wszAppendDir]
        invoke  PathAppend,esi,eax
        test    eax,eax
        jz      .end

        .build_search_path:
        lea     eax,[wszSearchFmt]
        invoke  PathCombine,edi,esi,eax
        test    eax,eax
        jz      .end

        .loop_init:
        lea     eax,[hFindData]
        invoke  FindFirstFile,edi,eax
        mov     ebx,eax
        cmp     eax,INVALID_HANDLE_VALUE
        je      .end

        .loop_body:
        cmp     dword[hFindData.cFileName],0x0000002E ;'.',0
        je      .loop_next
        cmp     dword[hFindData.cFileName],0x002E002E ;'..'
        jne     .build_plugin_path
        cmp     word[hFindData.cFileName],0x0000 ;0
        je      .loop_next
        test    dword[hFindData.dwFileAttributes],FILE_ATTRIBUTE_DIRECTORY
        jnz     .loop_next
        .build_plugin_path:
        lea     eax,[hFindData.cFileName]
        invoke  PathCombine,edi,esi,eax
        test    eax,eax
        jz      .loop_next
        invoke  LoadLibrary,edi
        test    eax,eax
        jz      .loop_next
        mov     dword[hCurPlugin],eax
        lea     ecx,[szProcName]
        invoke  GetProcAddress,eax,ecx
        test    eax,eax
        jnz     .load_plugin
        invoke  FreeLibrary,dword[hCurPlugin]
        jmp     .loop_next
        .load_plugin:
        ;stdcall eax,dword[hThisDLL]
        ccall   eax,dword[hThisDLL]

        .loop_next:
        lea     eax,[hFindData]
        invoke  FindNextFile,ebx,eax
        test    eax,eax
        jnz     .loop_body

        .loop_end:
        invoke  FindClose,ebx

        .end:
        mov     eax,TRUE
        pop     edi esi ebx
        ret
endp
