;------------------------------------------------------------
; ID 1 = IGI.exe v1.0 (Region: USA)
;------------------------------------------------------------

proc Patcher_ApplyPatches_ID1 uiRelocValue1,uiRelocValue2

        push    ebx esi edi
        mov     ebx,TRUE
        mov     esi,dword[uiRelocValue1]
        mov     edi,dword[uiRelocValue2]

        ; proxy hooks
        stdcall Patcher_ApplyProxyHooks_ID1,esi,edi
        and     ebx,eax

        ; shared functions
        stdcall Patcher_PatchSharedFuncs_ID1,esi,edi
        and     ebx,eax

        ; regular patches
        stdcall Patcher_ApplyRegularPatches_ID1,esi,edi
        and     ebx,eax

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp

proc Patcher_ApplyProxyHooks_ID1 uiRelocValue1,uiRelocValue2

        push    ebx esi edi
        mov     ebx,TRUE
        mov     esi,dword[uiRelocValue1]
        mov     edi,dword[uiRelocValue2]

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp

proc Patcher_PatchSharedFuncs_ID1 uiRelocValue1,uiRelocValue2

        push    ebx esi edi
        mov     ebx,TRUE
        mov     esi,dword[uiRelocValue1]
        mov     edi,dword[uiRelocValue2]

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp

proc Patcher_ApplyRegularPatches_ID1 uiRelocValue1,uiRelocValue2

        push    ebx esi edi
        mov     ebx,TRUE
        mov     esi,dword[uiRelocValue1]
        mov     edi,dword[uiRelocValue2]

        .end:
        mov     eax,ebx
        pop     edi esi ebx
        ret
endp
