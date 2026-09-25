;------------------------------------------------------------
; version detection functions
;------------------------------------------------------------

proc Patcher_GetCurVersionID

        mov     eax,dword[Patcher_uiCurVersionID]
        ret
endp

proc Patcher_GetCurPMIHandle

        mov     eax,dword[Patcher_pCurPMIHandle]
        ret
endp

proc Patcher_GetPMIFromVersionID uiVersionID

        xor     eax,eax
        mov     ecx,dword[uiVersionID]
        mov     edx,buildarray
        cmp     ecx,dword[edx+PATCHER_BUILD_ARRAY.num_entries]
        jae     .end
        imul    ecx,ecx,sizeof.PATCHER_BUILD_ENTRY
        add     ecx,edx
        mov     eax,dword[ecx+PATCHER_BUILD_ENTRY.ppmi]
        .end:
        ret
endp

proc Patcher_GetPMIRelocValue pPMI

        mov     eax,dword[pPMI]
        mov     eax,dword[eax+PATCHER_MODULE_INFO.uiRelocValue]
        ret
endp

;------------------------------------------------------------
; trap handling functions
;------------------------------------------------------------ 

proc Patcher_InstallAddrTrap

        locals
                szErrorCap      du 'Patcher Error',0
                szErrorText     du 'Addr Trap is already set!',0
        endl

        xor     eax,eax

        .check_arready_installed:
        cmp     dword[Patcher_bAddrTrapInstalled],eax
        jne     .error

        .check_veh:
        cmp     dword[AddVectoredExceptionHandler],eax
        je      .no_veh

        .register_veh:
        invoke  AddVectoredExceptionHandler,TRUE,Patcher_UnpatchedAddressHandler
        test    eax,eax
        jz      .no_veh

        .ok:
        mov     dword[Patcher_bAddrTrapInstalled],TRUE
        ret

        .no_veh:
        ;mov     dword[Patcher_bAddrTrapInstalled],FALSE
        ret

        .error:
        lea     eax,[szErrorText]
        lea     ecx,[szErrorCap]
        invoke  MessageBox,NULL,eax,ecx,MB_OK+MB_ICONERROR

        .exit:
        int3
        invoke  ExitProcess,-1 ;EXIT_FAILURE
endp

proc Patcher_UnpatchedAddressHandler pExceptionPointers

        locals
                szErrorText     rw 256
                szErrorCap      du 'Patcher Error',0
                szAccessTrapFmt du 'An unpatched PATCH_ADDR_TRAP fixup was accessed!',13,10,13,10,\
                                   'Access Type: %s',13,10,\
                                   'Instruction Pointer (EIP): 0x%08X',13,10,\
                                   'Top of Stack [ESP]: 0x%08X',0
                szExecTrapFmt   du 'An unpatched PATCH_ADDR_TRAP fixup was executed!',13,10,13,10,\
                                   'Access Type: %s',13,10,\
                                   'Faulting Target Address: 0x%08X',13,10,\
                                   'Top of Stack [ESP]: 0x%08X',0
                szReadOp        du 'READ',0
                szWriteOp       du 'WRITE',0
                szExecOp        du 'EXECUTE (CALL/JMP)',0
        endl

        push    ebx esi edi

        .get_pointers:
        mov     esi,dword[pExceptionPointers]
        mov     edi,dword[esi+4] ;pExceptionPointers->ContextRecord
        mov     esi,dword[esi] ;pExceptionPointers->ExceptionRecord

        .get_info:
        mov     eax,dword[esi] ;pExceptionRecord.ExceptionCode
        mov     ecx,dword[esi+18h] ;pExceptionRecord.ExceptionInformation[1]
        mov     edx,dword[esi+0Ch] ;pExceptionRecord.ExceptionAddress

        .check_exception_code:
        cmp     eax,0xC0000005 ;EXCEPTION_ACCESS_VIOLATION
        jne     .continue_search

        .check_trap_value:
        cmp     ecx,PATCHER_ADDR_TRAP
        je      .init_fmt

        .continue_search:
        xor     eax,eax ;EXCEPTION_CONTINUE_SEARCH
        pop     edi esi ebx
        ret

        .init_fmt:
        mov     eax,dword[edi+0xC4] ; pContextRecord.Esp
        mov     eax,dword[eax]

        .check_fmt_type:
        ;cmp     dword[esi+14h],8
        cmp     ecx,edx ; ExceptionInformation[1] == ExceptionAddress
        je      .get_access_type_exec

        .get_access_type_rw:
        lea     edi,[szAccessTrapFmt]
        mov     ecx,dword[esi+14h] ;pExceptionRecord.ExceptionInformation[0]
        neg     ecx
        sbb     ecx,ecx
        lea     ebx,[szReadOp]
        lea     esi,[szWriteOp]
        sub     esi,ebx
        and     esi,ecx
        add     ebx,esi
        jmp     .do_fmt

        .get_access_type_exec:
        lea     edi,[szExecTrapFmt]
        lea     ebx,[szExecOp]
        ;mov     edx,ecx

        .do_fmt:
        lea     esi,[szErrorText]
        cinvoke wsprintf,esi,edi,ebx,edx,eax

        .show_msgbox:
        lea     ecx,[szErrorText]
        lea     edx,[szErrorCap]
        invoke  MessageBox,NULL,ecx,edx,MB_OK+MB_ICONERROR

        .end:
        int3
        invoke  ExitProcess,-1
endp

proc Patcher_TrapUnpatchedCall

        locals
                szErrorText     rw 128
                szErrorCap      du 'Patcher Error', 0
                szErrorTextFmt  du 'An unpatched PATCH_CALL_TRAP fixup was executed!',13,10,13,10,\
                                   'Caller Return Address [ESP]: 0x%08X',0
        endl

        .fmt_msg:
        lea     eax,[szErrorText]
        lea     ecx,[szErrorTextFmt]
        mov     edx,dword[ebp+4] ; caller return address
        cinvoke wsprintf,eax,ecx,edx

        .show_msg:
        lea     eax,[szErrorText]
        lea     ecx,[szErrorCap]
        invoke  MessageBox,NULL,eax,ecx,MB_OK+MB_ICONERROR

        .exit:
        int3
        invoke  ExitProcess,-1 ;EXIT_FAILURE
endp

proc Patcher_TrapUnpatchedJump

        locals
                szErrorText     du 'An unpatched PATCH_JUMP_TRAP fixup was executed!',0
                szErrorCap      du 'Patcher Error', 0
        endl

        .show_msg:
        lea     eax,[szErrorText]
        lea     ecx,[szErrorCap]
        invoke  MessageBox,NULL,eax,ecx,MB_OK+MB_ICONERROR

        .exit:
        int3
        invoke  ExitProcess,-1 ;EXIT_FAILURE
endp

;------------------------------------------------------------
; custom memory patching functions
;------------------------------------------------------------ 

proc Patcher_WriteByteReloc pDstAddr,uiDstAddrReloc,ucByte

        mov     eax,dword[pDstAddr]
        add     eax,dword[uiDstAddrReloc]
        lea     ecx,[ucByte]
        stdcall Patcher_CopyMemory,eax,ecx,1
        ret
endp

proc Patcher_WriteWordReloc pDstAddr,uiDstAddrReloc,usWord

        mov     eax,dword[pDstAddr]
        add     eax,dword[uiDstAddrReloc]
        lea     ecx,[usWord]
        stdcall Patcher_CopyMemory,eax,ecx,2
        ret
endp

proc Patcher_WriteDwordReloc pDstAddr,uiDstAddrReloc,uiDword

        mov     eax,dword[pDstAddr]
        add     eax,dword[uiDstAddrReloc]
        lea     ecx,[uiDword]
        stdcall Patcher_CopyMemory,eax,ecx,4
        ret
endp

proc Patcher_WriteAddressReloc pDstAddr,uiDstAddrReloc,pNewAddr,uiNewAddrReloc,bRelAddr

        locals
                pNewAddrAbs dd ?
        endl

        push    ebx
        mov     eax,dword[pDstAddr]
        add     eax,dword[uiDstAddrReloc]
        mov     edx,dword[pNewAddr]
        add     edx,dword[uiNewAddrReloc]
        mov     ecx,edx
        sub     ecx,eax
        sub     ecx,4
        cmp     dword[bRelAddr],1
        sbb     ebx,ebx
        xor     edx,ecx
        and     edx,ebx
        xor     edx,ecx
        mov     dword[pNewAddrAbs],edx
        lea     ecx,[pNewAddrAbs]
        stdcall Patcher_CopyMemory,eax,ecx,4
        pop     ebx
        ret
endp

proc Patcher_WriteHookReloc pDstAddr,uiDstAddrReloc,pNewAddr,uiNewAddrReloc,uiSize

        locals
                ucByte db ?
        endl

        push    ebx esi edi
        mov     ebx,dword[uiSize]
        xor     eax,eax
        cmp     ebx,5
        jb      .end
        mov     edi,dword[pDstAddr]
        mov     esi,dword[uiDstAddrReloc]
        lea     eax,[edi+esi]
        lea     ecx,[ucByte]
        mov     byte[ecx],0xE9
        stdcall Patcher_CopyMemory,eax,ecx,1
        test    eax,eax
        jz      .end
        inc     edi
        stdcall Patcher_WriteAddressReloc,edi,esi,dword[pNewAddr],dword[uiNewAddrReloc],TRUE
        test    eax,eax
        jz      .end
        sub     ebx,5
        jz      .end
        add     edi,4
        lea     eax,[edi+esi]
        stdcall Patcher_FillMemory,eax,PATCHER_ALIGN_OPCODE,ebx
        .end:
        pop     edi esi ebx
        ret
endp

proc Patcher_FillMemoryWithNOPsReloc pDstAddr,uiDstAddrReloc,uiSize

        mov     eax,dword[pDstAddr]
        add     eax,dword[uiDstAddrReloc]
        mov     ecx,dword[uiSize]
        stdcall Patcher_FillMemory,eax,0x90,ecx
        ret
endp

proc Patcher_CopyMemory pDstAddr,pSrcAddr,uiSize

        push    ebx esi edi
        mov     ebx,dword[uiSize]
        mov     esi,dword[pSrcAddr]
        mov     edi,dword[pDstAddr]
        xor     eax,eax
        cmp     ebx,eax
        je      .end
        lea     ecx,[uiSize] ; store lpflOldProtect at uiSize
        invoke  VirtualProtect,edi,ebx,PAGE_EXECUTE_READWRITE,ecx
        test    eax,eax
        jz      .end
        stdcall CopyMemory,edi,esi,ebx
        lea     eax,[uiSize]
        invoke  VirtualProtect,edi,ebx,dword[eax],eax
        cmp     eax,1
        sbb     eax,eax
        add     eax,1
        .end:
        pop     edi esi ebx
        ret
endp

proc Patcher_FillMemory pDstAddr,ucFill,uiSize

        push    ebx esi edi
        mov     ebx,dword[uiSize]
        mov     esi,dword[ucFill]
        mov     edi,dword[pDstAddr]
        xor     eax,eax
        cmp     ebx,eax
        je      .end
        lea     ecx,[uiSize] ; store lpflOldProtect at uiSize
        invoke  VirtualProtect,edi,ebx,PAGE_EXECUTE_READWRITE,ecx
        test    eax,eax
        jz      .end
        stdcall FillMemory,edi,ebx,esi
        lea     eax,[uiSize]
        invoke  VirtualProtect,edi,ebx,dword[eax],eax
        cmp     eax,1
        sbb     eax,eax
        add     eax,1
        .end:
        pop     edi esi ebx
        ret
endp

;------------------------------------------------------------
; debug functions
;------------------------------------------------------------

proc Patcher_DMessageBox hWnd,lpText,lpCaption,uType

        .check_debug:
        cmp     dword[IniFile.Patch.Debug],FALSE
        je      .end

        .msgbox:
        invoke  MessageBox,dword[hWnd],dword[lpText],dword[lpCaption],dword[uType]

        .end:
        ret
endp

proc Patcher_DMessageBoxByResult hWnd,bSuccess,lpTextS,lpCaptionS,lpTextF,lpCaptionF

        .check_debug:
        cmp     dword[IniFile.Patch.Debug],FALSE
        jne     .check_value
        ret

        .check_value:
        cmp     dword[bSuccess],FALSE
        je      .error

        .ok:
        invoke  MessageBox,dword[hWnd],dword[lpTextS],dword[lpCaptionS],MB_OK+MB_ICONINFORMATION
        ret

        .error:
        invoke  MessageBox,dword[hWnd],dword[lpTextF],dword[lpCaptionF],MB_OK+MB_ICONERROR
        ret
endp
