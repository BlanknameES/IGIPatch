proc DllEntryPoint hinstDLL,fdwReason,lpvReserved

        mov     eax,DLL_PROCESS_ATTACH ; DLL_PROCESS_ATTACH = 1
        cmp     dword[fdwReason],eax
        jne     .end
        stdcall DllMain,dword[hinstDLL],eax,dword[lpvReserved]
        .end:
        ret
endp

proc DllMain hinstDLL,fdwReason,lpvReserved

        mov     ecx,dword[hinstDLL]
        mov     dword[hThisDLL],ecx
        mov     eax,TRUE
        .end:
        ret
endp

proc App_InitRunTimeDynamicLinking

        push    ebx

        .kernell32_dll: ; Kernel32.dll
        stdcall GetOrLoadLibrary,DLL_Kernel32,Kernel32DLL
        mov     ebx,eax
        stdcall GetFuncAddress,ebx,PROC_AddVectoredExceptionHandler,AddVectoredExceptionHandler

        .user32_dll: ; User32.dll
        stdcall GetOrLoadLibrary,DLL_User32,User32DLL
        mov     ebx,eax
        stdcall GetFuncAddress,ebx,PROC_SetProcessDPIAware,SetProcessDPIAware

        .end:
        pop     ebx
        ret
endp
