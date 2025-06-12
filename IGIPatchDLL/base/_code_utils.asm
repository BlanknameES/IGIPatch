proc wcsnlen c wcs,num

        xor     eax,eax
        mov     ecx,dword[num]
        jecxz   .end
        push    edi
        mov     edi,dword[wcs]
        mov     edx,ecx
        repne   scasw
        sbb     eax,eax
        not     eax
        inc     ecx
        and     ecx,eax
        sub     edx,ecx
        mov     eax,edx
        pop     edi
        .end:
        ret
endp

;--------------------------------------------------

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

;--------------------------------------------------

proc lstrlennA lpString,iMaxLength

        xor     eax,eax
        mov     ecx,dword[iMaxLength]
        jecxz   .end
        push    edi
        mov     edi,dword[lpString]
        mov     edx,ecx
        repne   scasb
        sbb     ecx,-1
        sub     edx,ecx
        mov     eax,edx
        pop     edi
        .end:
        ret
endp

;--------------------------------------------------

proc GetModuleFileNameSafeW hModule,lpFilename,nSize

        locals
                TmpFilename rw MAX_PATH
        endl

        push    ebx esi edi
        xor     ebx,ebx
        mov     esi,dword[nSize]
        mov     edi,dword[lpFilename]
        cmp     esi,ebx
        je      .end
        cmp     edi,ebx
        je      .end
        and     word[edi],bx
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

proc GetModuleInfo hModule,lpmodinfo,cb

        push    ebx
        invoke  GetModuleHandle,dword[hModule]
        test    eax,eax
        jz      .end
        mov     ebx,eax
        invoke  GetCurrentProcess
        invoke  GetModuleInformation,eax,ebx,dword[lpmodinfo],dword[cb]
        .end:
        pop     ebx
        ret
endp

;--------------------------------------------------

__alldvrm:

        .arg_0 = 4
        .arg_4 = 8
        .arg_8 = 0Ch
        .arg_C = 10h

        push    edi
        push    esi
        push    ebp
        xor     edi,edi
        xor     ebp,ebp
        mov     eax,dword[esp+0Ch+.arg_4]
        or      eax,eax
        jge     .loc_688AF4
        inc     edi
        inc     ebp
        mov     edx,dword[esp+0Ch+.arg_0]
        neg     eax
        neg     edx
        sbb     eax,0
        mov     dword[esp+0Ch+.arg_4],eax
        mov     dword[esp+0Ch+.arg_0],edx
        .loc_688AF4:
        mov     eax,dword[esp+0Ch+.arg_C]
        or      eax,eax
        jge     .loc_688B10
        inc     edi
        mov     edx,dword[esp+0Ch+.arg_8]
        neg     eax
        neg     edx
        sbb     eax,0
        mov     dword[esp+0Ch+.arg_C],eax
        mov     dword[esp+0Ch+.arg_8],edx
        .loc_688B10:
        or      eax,eax
        jnz     .loc_688B3C
        mov     ecx,dword[esp+0Ch+.arg_8]
        mov     eax,dword[esp+0Ch+.arg_4]
        xor     edx,edx
        div     ecx
        mov     ebx,eax
        mov     eax,dword[esp+0Ch+.arg_0]
        div     ecx
        mov     esi,eax
        mov     eax,ebx
        mul     dword[esp+0Ch+.arg_8]
        mov     ecx,eax
        mov     eax,esi
        mul     dword[esp+0Ch+.arg_8]
        add     edx,ecx
        jmp     .loc_688B83
        .loc_688B3C:
        mov     ebx,eax
        mov     ecx,dword[esp+0Ch+.arg_8]
        mov     edx,dword[esp+0Ch+.arg_4]
        mov     eax,dword[esp+0Ch+.arg_0]
        .loc_688B4A:
        shr     ebx,1
        rcr     ecx,1
        shr     edx,1
        rcr     eax,1
        or      ebx,ebx
        jnz     .loc_688B4A
        div     ecx
        mov     esi,eax
        mul     dword[esp+0Ch+.arg_C]
        mov     ecx, eax
        mov     eax,dword[esp+0Ch+.arg_8]
        mul     esi
        add     edx,ecx
        jb      .loc_688B78
        cmp     edx,dword[esp+0Ch+.arg_4]
        ja      .loc_688B78
        jb      .loc_688B81
        cmp     eax,dword[esp+0Ch+.arg_0]
        jbe     .loc_688B81
        .loc_688B78:
        dec     esi
        sub     eax,dword[esp+0Ch+.arg_8]
        sbb     edx,dword[esp+0Ch+.arg_C]
        .loc_688B81:
        xor     ebx,ebx
        .loc_688B83:
        sub     eax,dword[esp+0Ch+.arg_0]
        sbb     edx,dword[esp+0Ch+.arg_4]
        dec     ebp
        jns     .loc_688B95
        neg     edx
        neg     eax
        sbb     edx,0
        .loc_688B95:
        mov     ecx,edx
        mov     edx,ebx
        mov     ebx,ecx
        mov     ecx,eax
        mov     eax,esi
        dec     edi
        jnz     .loc_688BA9
        neg     edx
        neg     eax
        sbb     edx,0
        .loc_688BA9:
        pop     ebp
        pop     esi
        pop     edi
        retn    10h

__allmul:

        .arg_0 = 4
        .arg_4 = 8
        .arg_8 = 0Ch
        .arg_C = 10h

        mov     eax,dword[esp+.arg_4]
        mov     ecx,dword[esp+.arg_C]
        or      ecx,eax
        mov     ecx,dword[esp+.arg_8]
        jnz     .hard
        mov     eax,dword[esp+.arg_0]
        mul     ecx
        retn    10h
        .hard:
        push    ebx
        mul     ecx
        mov     ebx,eax
        mov     eax,dword[esp+4+.arg_0]
        mul     dword[esp+4+.arg_C]
        add     ebx,eax
        mov     eax,dword[esp+4+.arg_0]
        mul     ecx
        add     edx,ebx
        pop     ebx
        retn    10h

__alldiv:

        .arg_0 = 4
        .arg_4 = 8
        .arg_8 = 0Ch
        .arg_C = 10h

        push    edi
        push    esi
        push    ebx
        xor     edi,edi
        mov     eax,dword[esp+0Ch+.arg_4]
        or      eax,eax
        jge     .loc_688A41
        inc     edi
        mov     edx,dword[esp+0Ch+.arg_0]
        neg     eax
        neg     edx
        sbb     eax,0
        mov     dword[esp+0Ch+.arg_4],eax
        mov     dword[esp+0Ch+.arg_0],edx
        .loc_688A41:
        mov     eax,dword[esp+0Ch+.arg_C]
        or      eax,eax
        jge     .loc_688A5D
        inc     edi
        mov     edx,dword[esp+0Ch+.arg_8]
        neg     eax
        neg     edx
        sbb     eax,0
        mov     dword[esp+0Ch+.arg_C],eax
        mov     dword[esp+0Ch+.arg_8],edx
        .loc_688A5D:
        or      eax,eax
        jnz     .loc_688A79
        mov     ecx,dword[esp+0Ch+.arg_8]
        mov     eax,dword[esp+0Ch+.arg_4]
        xor     edx,edx
        div     ecx
        mov     ebx,eax
        mov     eax,dword[esp+0Ch+.arg_0]
        div     ecx
        mov     edx,ebx
        jmp     .loc_688ABA
        .loc_688A79:
        mov     ebx,eax
        mov     ecx,dword[esp+0Ch+.arg_8]
        mov     edx,dword[esp+0Ch+.arg_4]
        mov     eax,dword[esp+0Ch+.arg_0]
        .loc_688A87:
        shr     ebx,1
        rcr     ecx,1
        shr     edx,1
        rcr     eax,1
        or      ebx,ebx
        jnz     .loc_688A87
        div     ecx
        mov     esi,eax
        mul     dword[esp+0Ch+.arg_C]
        mov     ecx,eax
        mov     eax,dword[esp+0Ch+.arg_8]
        mul     esi
        add     edx,ecx
        jb      .loc_688AB5
        cmp     edx,dword[esp+0Ch+.arg_4]
        ja      .loc_688AB5
        jb      .loc_688AB6
        cmp     eax,dword[esp+0Ch+.arg_0]
        jbe     .loc_688AB6
        .loc_688AB5:
        dec     esi
        .loc_688AB6:
        xor     edx,edx
        mov     eax,esi
        .loc_688ABA:
        dec     edi
        jnz     .loc_688AC4
        neg     edx
        neg     eax
        sbb     edx,0
        .loc_688AC4:
        pop     ebx
        pop     esi
        pop     edi
        retn    10h

;--------------------------------------------------

proc PatchTrap

        push     dword[esp+4]
        pop      dword[0xDEADC0DE]
        .addr = $ - 4
        ;TODO: show warning?
        invoke   ExitProcess,-1 ;EXIT_FAILURE
endp

proc GetRealAddress pPMI,pBaseAddress

        mov     eax,dword[pBaseAddress]
        mov     ecx,dword[pPMI]
        sub     eax,dword[ecx+PATCHMODULEINFO.dwDefImageBase]
        add     eax,dword[ecx+PATCHMODULEINFO.dwCurImageBase]
        ret
endp

proc MPatchByte pBaseAddress,uByte

        lea     eax,[uByte]
        stdcall MPatchBuffer,dword[pBaseAddress],eax,1
        ret
endp

proc MPatchWord pBaseAddress,uWord

        lea     eax,[uWord]
        stdcall MPatchBuffer,dword[pBaseAddress],eax,2
        ret
endp

proc MPatchDword pBaseAddress,uDword

        lea     eax,[uDword]
        stdcall MPatchBuffer,dword[pBaseAddress],eax,4
        ret
endp

proc MPatchAddress pBaseAddress,pDestAddress,bRelAddr

        push    ebx
        mov     eax,dword[pBaseAddress]
        lea     ecx,[eax+4]
        lea     edx,[pDestAddress]
        neg     dword[bRelAddr]
        sbb     ebx,ebx
        and     ecx,ebx
        sub     dword[edx],ecx
        stdcall MPatchBuffer,eax,edx,4
        pop     ebx
        ret
endp

proc MPatchCodeCave pBaseAddress,pCodeCave,nSize

        push    ebx esi
        mov     ebx,dword[nSize]
        xor     eax,eax
        cmp     ebx,5
        jb      .end
        mov     esi,dword[pBaseAddress]
        lea     eax,[nSize] ;use nSize to store bytes
        mov     byte[eax],0xE9
        stdcall MPatchBuffer,esi,eax,1
        test    eax,eax
        jz      .end
        inc     esi
        stdcall MPatchAddress,esi,dword[pCodeCave],1
        test    eax,eax
        jz      .end
        sub     ebx,5
        jz      .end
        add     esi,4
        mov     byte[nSize],0x90 ;0xCC
        .loop:
        lea     eax,[nSize]
        stdcall MPatchBuffer,esi,eax,1
        test    eax,eax
        jz      .end
        inc     esi
        dec     ebx
        jnz     .loop
        .end:
        pop     esi ebx
        ret
endp

proc MPatchBuffer pBaseAddress,pBuffer,nSize

        push    ebx esi edi
        mov     ebx,dword[nSize]
        mov     esi,dword[pBaseAddress]
        mov     edi,dword[pBuffer]
        xor     eax,eax
        cmp     ebx,eax
        je      .end
        lea     eax,[nSize] ;store lpflOldProtect at nSize
        invoke  VirtualProtect,esi,ebx,PAGE_EXECUTE_READWRITE,eax
        test    eax,eax
        jz      .end
        invoke  GetCurrentProcess
        invoke  WriteProcessMemory,eax,esi,edi,ebx,0
        mov     edi,eax
        lea     eax,[nSize]
        invoke  VirtualProtect,esi,ebx,dword[eax],eax
        test    eax,eax
        jz      .end
        test    edi,edi
        setnz   cl
        movzx   eax,cl
        .end:
        pop     edi esi ebx
        ret
endp
