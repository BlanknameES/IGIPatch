;------------------------------------------------------------
; fileapi.h
;------------------------------------------------------------

proc GetFileSizeByHandle hFile,lpFileSizeLow,lpFileSizeHigh

        push    esi edi
        invoke  SetLastError,0
        lea     eax,[hFile]
        invoke  GetFileSize,dword[eax],eax
        mov     esi,eax          ; esi = uiFileSizeLow
        mov     edi,dword[hFile] ; edi = uiFileSizeHigh
        sub     eax,INVALID_FILE_SIZE
        jz      .end
        invoke  GetLastError
        cmp     eax,1   ; NO_ERROR = 0
        sbb     ecx,ecx ; ecx = GetLastError() == NO_ERROR ? -1 : 0
        mov     eax,ecx
        neg     eax     ; eax = GetLastError() == NO_ERROR
        and     esi,ecx ; uiFileSizeLow &= ecx
        and     edi,ecx ; uiFileSizeHigh &= ecx
        .end:
        mov     ecx,dword[lpFileSizeLow]
        mov     edx,dword[lpFileSizeHigh]
        mov     dword[ecx],esi
        mov     dword[edx],edi
        pop     edi esi
        ret
endp

;------------------------------------------------------------
; custom memory management functions
;------------------------------------------------------------

proc MemInit bMT

        xor     eax,eax
        mov     ecx,dword[bMT]
        test    ecx,ecx
        setz    al
        invoke  HeapCreate,eax,0x1000,0
        mov     dword[hHeap],eax
        test    eax,eax
        jz      .error0
        ret
        .error0:
        stdcall MemError,0,dword[esp+4]
endp

proc MemAlloc nSize

        mov     eax,dword[nSize]
        test    eax,eax
        jz      .end
        invoke  HeapAlloc,dword[hHeap],0,eax
        test    eax,eax
        jz      .error1
        .end:
        ret
        .error1:
        stdcall MemError,1,dword[esp+4]
endp

proc MemFree lpMem

        mov     eax,dword[lpMem]
        test    eax,eax
        jz      .end
        invoke  HeapFree,dword[hHeap],0,eax
        test    eax,eax
        jz      .error2
        .end:
        ret
        .error2:
        stdcall MemError,2,dword[esp+4]
endp

proc MemResize lpMem,nSize

        mov     edx,dword[lpMem]
        mov     ecx,dword[nSize]
        lea     eax,[ecx+edx]
        test    eax,eax
        jz      .end
        test    ecx,ecx
        jz      .free
        test    edx,edx
        jz      .alloc
        invoke  HeapReAlloc,dword[hHeap],0,edx,ecx
        test    eax,eax
        jz      .error3
        .end:
        ret
        .error3:
        stdcall MemError,3,dword[esp+4]

        .alloc:
        invoke  HeapAlloc,dword[hHeap],0,ecx
        test    eax,eax
        jz      .end
        ret
        .error1:
        stdcall MemError,1,dword[esp+4]

        .free:
        invoke  HeapFree,dword[hHeap],0,edx
        test    eax,eax
        jz     .error2
        ret
        .error2:
        stdcall MemError,2,dword[esp+4]
endp

proc MemErrorW ErrorCode,ErrorOffset

        locals
                msgbuf rw 32
                capbuf rw 32
                errcap du 'Heap Error Code: 0x%08X',0
                errmsg du 'Virtual Address: 0x%08X',0
        endl

        lea     esi,[msgbuf]
        lea     edi,[capbuf]
        and     word[esi],0
        and     word[edi],0
        sub     dword[ErrorOffset],5
        lea     eax,[errcap]
        cinvoke wsprintfW,esi,eax,dword[ErrorCode]
        lea     eax,[errmsg]
        cinvoke wsprintfW,edi,eax,dword[ErrorOffset]
        invoke  MessageBox,0,edi,esi,MB_OK+MB_ICONERROR
        invoke  ExitProcess,0xFF
endp

;------------------------------------------------------------
; custom data patching functions
;------------------------------------------------------------

proc DCopyPatchList lpBaseAddress,lpPatchList,nIndex

        locals
                nDataCount rd 1
        endl

        push    ebx esi edi
        mov     ecx,dword[lpPatchList]
        mov     eax,dword[ecx] ; num patches
        test    eax,eax
        jz      .end
        mov     ebx,eax
        lea     esi,[ecx+8] ; first patch ptr
        mov     edi,dword[lpBaseAddress]
        mov     ecx,dword[ecx+4]
        mov     dword[nDataCount],ecx
        .rep:
        mov     ecx,dword[esi+4] ; patch size
        mov     eax,dword[nIndex]
        imul    ecx
        mov     edx,ecx
        lea     ecx,[esi+8+eax] ; patch data + offset
        mov     eax,edi
        add     eax,dword[esi] ; patch addr
        stdcall CopyMemory,eax,ecx,edx
        mov     eax,dword[esi+4] ; patch size
        mov     ecx,dword[nDataCount]
        imul    ecx
        lea     esi,[esi+4+4+eax] ; next patch ptr
        dec     ebx
        jnz     .rep
        mov     eax,TRUE
        .end:
        pop     edi esi ebx
        ret
endp

proc DCompPatchList lpBaseAddress,lpPatchList,nIndex

        locals
                bIsEqual rd 1
                nDataCount rd 1
        endl

        push    ebx esi edi
        mov     ecx,dword[lpPatchList]
        mov     eax,dword[ecx] ; num patches
        test    eax,eax
        jz      .end
        mov     dword[bIsEqual],TRUE
        mov     ebx,eax
        lea     esi,[ecx+8] ; first patch ptr
        mov     edi,dword[lpBaseAddress]
        mov     ecx,dword[ecx+4]
        mov     dword[nDataCount],ecx
        .rep:
        mov     ecx,dword[esi+4] ; patch size
        mov     eax,dword[nIndex]
        imul    ecx
        mov     edx,ecx
        lea     ecx,[esi+8+eax] ; patch data + offset
        mov     eax,edi
        add     eax,dword[esi] ; patch addr
        stdcall EqualMemory,eax,ecx,edx
        and     dword[bIsEqual],eax
        mov     eax,dword[esi+4] ; patch size
        mov     ecx,dword[nDataCount]
        imul    ecx
        lea     esi,[esi+4+4+eax] ; next patch ptr
        dec     ebx
        jnz     .rep
        mov     eax,dword[bIsEqual]
        .end:
        pop     edi esi ebx
        ret
endp
