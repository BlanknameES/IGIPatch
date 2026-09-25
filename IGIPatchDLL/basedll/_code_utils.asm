;------------------------------------------------------------
; wdm.h
;------------------------------------------------------------

proc CopyMemory Destination,Source,Length

        push    esi edi
        mov     esi,dword[Source]
        mov     edi,dword[Destination]
        mov     ecx,dword[Length]
        test    ecx,ecx
        jz      .end
        mov     edx,ecx
        shr     ecx,2
        rep     movsd
        mov     ecx,edx
        and     ecx,3
        rep     movsb
        .end:
        pop     edi esi
        ret
endp

proc EqualMemory Source1,Source2,Length ; NOTE: unsafe if length is different on both sources

        push    esi edi
        mov     eax,TRUE
        mov     esi,dword[Source2]
        mov     edi,dword[Source1]
        mov     ecx,dword[Length]
        test    ecx,ecx
        jz      .end
        mov     edx,ecx
        shr     ecx,2
        repe    cmpsd
        sete    al
        neg     eax
        mov     ecx,edx
        and     ecx,3
        and     ecx,eax ; if cmpsd fails -> ecx = 0, ZF = 1
        repe    cmpsb
        sete    cl
        and     eax,ecx
        .end:
        pop     edi esi
        ret
endp

proc FillMemory Destination,Length,Fill

        push    edi
        mov     edi,dword[Destination]
        mov     eax,dword[Fill]
        mov     ecx,dword[Length]
        test    ecx,ecx
        jz      .end
        mov     ah,al
        mov     dx,ax
        shl     eax,16
        mov     ax,dx
        mov     edx,ecx
        shr     ecx,2
        rep     stosd
        mov     ecx,edx
        and     ecx,3
        rep     stosb
        .end:
        pop     edi
        ret
endp

proc ZeroMemory Destination,Length

        push    edi
        mov     edi,dword[Destination]
        mov     ecx,dword[Length]
        test    ecx,ecx
        jz      .end
        mov     edx,ecx
        xor     eax,eax
        shr     ecx,2
        rep     stosd
        mov     ecx,edx
        and     ecx,3 
        rep     stosb               
        .end:
        pop     edi
        ret
endp

;------------------------------------------------------------
; winbase.h
;------------------------------------------------------------

proc lstrlennW lpString,iMaxLength

        push    edi
        xor     eax,eax
        mov     edi,dword[lpString]
        test    edi,edi
        jz      .end
        mov     ecx,dword[iMaxLength]
        test    ecx,ecx
        jz      .end
        mov     edx,ecx
        repne   scasw
        sbb     ecx,-1
        sub     edx,ecx
        mov     eax,edx
        .end:
        pop     edi
        ret
endp

;------------------------------------------------------------
; libloaderapi.h
;------------------------------------------------------------

proc GetOrLoadLibraryW hLibModule,hLoadedLib

        push    esi edi
        mov     esi,dword[hLibModule]
        mov     edi,dword[hLoadedLib]

        .init_handle:
        mov     dword[edi],NULL

        .get_module:
        invoke  GetModuleHandleW,esi
        test    eax,eax
        jnz     .end

        .load_lib:
        invoke  LoadLibraryW,esi
        test    eax,eax
        jz      .end

        .set_handle:
        mov     dword[edi],eax

        .end:
        pop     edi esi
        ret
endp

proc GetFuncAddress hModule,lpProcName

        .check_null:
        mov     eax,dword[hModule]
        test    eax,eax
        jz      .end

        .get_addr:
        invoke  GetProcAddress,eax,dword[lpProcName]

        .end:
        ret
endp

proc GetModuleFileNameSafeW hModule,lpFilename,nSize

        push    esi edi
        xor     eax,eax
        mov     esi,dword[nSize]
        mov     edi,dword[lpFilename]
        test    esi,esi
        jz      .end
        invoke  GetModuleFileNameW,dword[hModule],edi,esi
        cmp     eax,esi
        sbb     ecx,ecx
        and     eax,ecx
        .end:
        pop     edi esi
        ret
endp

;------------------------------------------------------------
; shlwapi.h
;------------------------------------------------------------

proc PathCopyWithNewExtensionW pszDest,pszPath,pszExt

        push    esi edi
        mov     esi,dword[pszPath]
        stdcall lstrlennW,esi,MAX_PATH
        cmp     eax,MAX_PATH
        sbb     ecx,ecx
        and     eax,ecx
        jz      .end
        mov     edi,dword[pszDest]
        lea     eax,[eax*2+1*2]
        stdcall CopyMemory,edi,esi,eax
        invoke  PathRenameExtensionW,edi,dword[pszExt]
        .end:
        pop     edi esi
        ret
endp

;------------------------------------------------------------
; string.h
;------------------------------------------------------------

proc strncmp c str1,str2,num ; NOTE: not safe

        xor     eax,eax
        mov     ecx,dword[num]
        jecxz   .end
        push    esi edi
        mov     edi,dword[str1]
        mov     edx,ecx
        repne   scasb
        sub     edx,ecx
        mov     esi,dword[str1]
        mov     edi,dword[str2]
        mov     ecx,edx
        repe    cmpsb
        mov     al,byte[esi-1]
        sub     al,byte[edi-1]
        movsx   eax,al
        pop     edi esi
        .end:
        ret
endp

proc strncpy c destination,source,num

        push    esi edi
        mov     ecx,dword[num]
        test    ecx,ecx
        mov     edx,ecx
        mov     edi,dword[source]
        xor     eax,eax
        repne   scasb
        sub     edx,ecx
        mov     esi,dword[source]
        mov     edi,dword[destination]
        mov     ecx,edx
        shr     ecx,2
        rep     movsd
        mov     ecx,edx
        and     ecx,3
        rep     movsb
        mov     ecx,dword[num]
        sub     ecx,edx
        mov     edx,ecx
        shr     ecx,2
        rep     stosd
        mov     ecx,edx
        and     ecx,3 
        rep     stosb
        .end:
        mov     eax,dword[destination]
        pop     edi esi
        ret
endp

proc strnlen c str,num

        push    edi
        xor     eax,eax
        mov     ecx,dword[num]
        test    ecx,ecx
        jz      .end
        mov     edi,dword[str]
        mov     edx,ecx
        repne   scasb
        sbb     eax,eax
        not     eax
        sub     edx,ecx
        add     eax,edx
        .end:
        pop     edi
        ret
endp
