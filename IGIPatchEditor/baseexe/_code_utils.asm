;------------------------------------------------------------
; wdm.h
;------------------------------------------------------------

proc CopyMemory Destination,Source,Length

        push    esi edi
        mov     ecx,dword[Length]
        mov     esi,dword[Source]
        mov     edi,dword[Destination]
        mov     edx,ecx
        shr     ecx,2
        rep     movsd
        mov     ecx,edx
        and     ecx,3
        rep     movsb
        pop     edi esi
        ret
endp

proc EqualMemory Source1,Source2,Length

        push    esi edi
        xor     eax,eax
        mov     ecx,dword[Length]
        mov     esi,dword[Source2]
        mov     edi,dword[Source1]
        mov     edx,ecx
        shr     ecx,2
        repe    cmpsd
        sete    al
        mov     ecx,edx
        and     ecx,3
        repe    cmpsb
        sete    cl
        and     al,cl
        pop     edi esi
        ret
endp

proc ZeroMemory Destination,Length

        push    edi
        mov     ecx,dword[Length]
        mov     edx,ecx
        xor     eax,eax
        shr     ecx,2
        mov     edi,dword[Destination]
        rep     stosd
        mov     ecx,edx
        and     ecx,3 
        rep     stosb               
        pop     edi
        ret
endp

;------------------------------------------------------------
; libloaderapi.h
;------------------------------------------------------------

proc GetOrLoadLibraryW lpModuleName,hLibToFree

        push    esi edi
        mov     esi,dword[lpModuleName]
        mov     edi,dword[hLibToFree]

        .init_lib2free:
        mov     dword[edi],0

        .get_module:
        invoke  GetModuleHandleW,esi
        test    eax,eax
        jnz     .end

        .load_lib:
        invoke  LoadLibraryW,esi
        test    eax,eax
        jz      .end

        .set_lib2free:
        mov     dword[edi],eax

        .end:
        pop     edi esi
        ret
endp

proc GetFuncAddress hModule,lpProcName,lpfnProcAddr

        .check_null:
        mov     eax,dword[hModule]
        test    eax,eax
        jz      .set_proc

        .get_addr:
        invoke  GetProcAddress,eax,dword[lpProcName]

        .set_proc:
        mov     ecx,dword[lpfnProcAddr]
        mov     dword[ecx],eax

        .end:
        ret
endp

proc FreeLoadedLibrary hLibModule

        .check_null:
        mov     eax,dword[hLibModule]
        test    eax,eax
        jz      .end

        .free_lib:
        invoke  FreeLibrary,eax

        .end:
        ret
endp

proc GetModuleFileNameSafeW hModule,lpFilename,nSize

        locals
                TmpFilename rw MAX_PATH
        endl

        push    ebx esi edi
        xor     ebx,ebx
        mov     esi,dword[nSize]
        mov     edi,dword[lpFilename]
        and     word[edi],bx
        test    esi,esi
        je      .end
        lea     eax,[TmpFilename]
        invoke  GetModuleFileNameW,dword[hModule],eax,esi
        mov     ebx,eax
        lea     ecx,[eax-1]
        dec     esi
        cmp     ecx,esi
        sbb     edx,edx
        and     ebx,edx
        and     word[edi],dx
        lea     ecx,[eax*2+2]
        lea     eax,[TmpFilename]
        stdcall CopyMemory,edi,eax,ecx
        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp

;------------------------------------------------------------
; shlwapi.h
;------------------------------------------------------------

proc PathIsFile pszPath

        xor     eax,eax
        mov     ecx,dword[pszPath]
        test    ecx,ecx
        jz      .end
        cmp     word[ecx],ax
        je      .end
        invoke  GetFileAttributesW,ecx
        xor     ecx,ecx
        test    eax,FILE_ATTRIBUTE_DIRECTORY
        setz    cl
        cmp     eax,INVALID_FILE_ATTRIBUTES
        sbb     eax,eax
        and     eax,ecx  
        .end:
        ret
endp

;------------------------------------------------------------
; winuser.h
;------------------------------------------------------------

proc GetChildID hWnd

        invoke  GetDlgCtrlID,dword[hWnd]
        ret
endp

proc GetChild hWnd,nCtrlID

        invoke  GetDlgItem,dword[hWnd],dword[nCtrlID]
        ret
endp

;------------------------------------------------------------
; App custom functions
;------------------------------------------------------------

proc GetPrimaryScreenSize uiMode,pPoint

        locals
                TempRect RECT
        endl

        push    ebx esi edi

        .check_mode:
        mov     eax,dword[uiMode]
        cmp     eax,0
        je      .mode_0
        cmp     eax,1
        je      .mode_1
        cmp     eax,2
        je      .mode_2
        cmp     eax,3
        je      .mode_3
        cmp     eax,4
        je      .mode_4
        jmp     .end

        .mode_0:
        lea     ebx,[TempRect]
        invoke  SystemParametersInfoA,SPI_GETWORKAREA,0,ebx,0
        test    eax,eax
        setnz   al
        and     eax,1
        mov     esi,dword[ebx+RECT.right]
        sub     esi,dword[ebx+RECT.left]
        mov     edi,dword[ebx+RECT.bottom]
        sub     edi,dword[ebx+RECT.top]
        jmp     .fill_point

        .mode_1:
        mov     ebx,TRUE
        invoke  GetSystemMetrics,SM_CXFULLSCREEN
        mov     esi,eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  GetSystemMetrics,SM_CYFULLSCREEN
        mov     edi,eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        mov     eax,ebx
        jmp     .fill_point

        .mode_2:
        invoke  GetDC,NULL
        test    eax,eax
        jz      .end
        mov     ebx,eax
        invoke  GetDeviceCaps,ebx,HORZRES
        mov     esi,eax
        invoke  GetDeviceCaps,ebx,VERTRES
        mov     edi,eax
        invoke  ReleaseDC,NULL,ebx
        test    eax,eax
        jz      .end
        mov     eax,TRUE
        jmp     .fill_point

        .mode_3:
        lea     ebx,[TempRect]
        invoke  GetDesktopWindow
        invoke  GetWindowRect,eax,ebx
        test    eax,eax
        setnz   al
        and     eax,1
        mov     esi,dword[ebx+RECT.right]
        sub     esi,dword[ebx+RECT.left]
        mov     edi,dword[ebx+RECT.bottom]
        sub     edi,dword[ebx+RECT.top]
        jmp     .fill_point

        .mode_4:
        mov     ebx,TRUE
        invoke  GetSystemMetrics,SM_CXSCREEN
        mov     esi,eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        invoke  GetSystemMetrics,SM_CYSCREEN
        mov     edi,eax
        neg     eax
        sbb     ecx,ecx
        and     ebx,ecx
        mov     eax,ebx
        jmp     .fill_point

        .fill_point:
        test    eax,eax
        jz      .end
        mov     ebx,dword[pPoint]
        mov     dword[ebx+POINT.x],esi
        mov     dword[ebx+POINT.y],edi

        .end:
        pop     edi esi ebx
        ret
endp

proc DisableWindowTheme hWnd,bUseDefault

        .check_proc:
        mov     eax,dword[SetWindowTheme]
        test    eax,eax
        jnz     .check_mode
        ret

        .check_mode:
        cmp     dword[bUseDefault],FALSE
        je      .off

        .on:
        stdcall eax,dword[hWnd],NULL,NULL
        ret

        .off:
        lea     ecx,[bUseDefault] ; used as null terminated string
        stdcall eax,dword[hWnd],ecx,ecx
        ret
endp
