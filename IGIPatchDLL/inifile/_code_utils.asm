proc IniFile_GetSettingsFileNameW hModule,pszIniFileName

        locals
                szModuleFilename rw MAX_PATH
                szNewExtension du '.ini',0
        endl

        lea     eax,[szModuleFilename]
        stdcall GetModuleFileNameSafeW,dword[hModule],eax,MAX_PATH
        test    eax,eax
        jz      .end
        lea     eax,[szModuleFilename]
        lea     ecx,[szNewExtension]
        stdcall PathCopyWithNewExtensionW,dword[pszIniFileName],eax,ecx
        cmp     eax,1
        sbb     eax,eax
        add     eax,1
        .end:
        ret
endp

proc IniFile_ReadIntSetting pIniFile,pszSecName,pszKeyName,pIniSetting

        push    ebx
        mov     eax,dword[pIniFile]
        mov     ebx,dword[pIniSetting]
        add     ebx,eax
        add     eax,INIFILE.Filename
        invoke  GetPrivateProfileInt,dword[pszSecName],dword[pszKeyName],dword[ebx],eax
        mov     dword[ebx],eax
        pop     ebx
        ret
endp

proc IniFile_ReadStrSetting pIniFile,pszSecName,pszKeyName,pIniSetting,uiMaxSize ; TODO: IniFile_ReadQuotedStrSetting

        locals
                szReturnedString rw MAX_PATH
        endl

        push    esi edi
        mov     eax,dword[pIniFile]
        mov     esi,dword[pIniSetting]
        lea     edi,[szReturnedString]
        add     esi,eax
        add     eax,INIFILE.Filename
        invoke  GetPrivateProfileString,dword[pszSecName],dword[pszKeyName],NULL,edi,MAX_PATH,eax
        test    eax,eax
        jz      .end
        inc     eax
        stdcall IniFile_WStr2CStr,esi,dword[uiMaxSize],edi,eax
        .end:
        pop     edi esi
        ret
endp

proc IniFile_BooleanizeSetting pIniFile, pIniSetting

        xor     eax,eax
        mov     ecx,dword[pIniFile]
        add     ecx,dword[pIniSetting]
        mov     edx,dword[ecx]
        test    edx,edx
        setne   al
        mov     dword[ecx],eax
        ret
endp

proc IniFile_WStr2CStr pCStr,uiCStrSize,pWStr,uiWStrSize

        push    ebx esi edi
        mov     esi,dword[pWStr]
        mov     edi,dword[pCStr]
        mov     ebx,dword[uiCStrSize]
        test    edi,edi
        jz      .end
        test    ebx,ebx
        jz      .end
        invoke  WideCharToMultiByte,CP_ACP,0,esi,dword[uiWStrSize],edi,ebx,NULL,NULL
        and     byte[edi+ebx-1],0
        .end:
        pop     edi esi ebx
        ret
endp
