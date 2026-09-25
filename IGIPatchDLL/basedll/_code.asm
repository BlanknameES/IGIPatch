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

        locals
                DLL_Kernel32 du 'Kernel32.dll',0
                PROC_AddVectoredExceptionHandler db 'AddVectoredExceptionHandler',0
        endl

        push    ebx

        ; Kernel32.dll
        lea     eax,[DLL_Kernel32]
        stdcall GetOrLoadLibrary,eax,Kernel32DLL
        mov     ebx,eax
        lea     eax,[PROC_AddVectoredExceptionHandler]
        stdcall GetFuncAddress,ebx,eax
        mov     dword[AddVectoredExceptionHandler],eax

        .end:
        pop     ebx
        ret
endp
