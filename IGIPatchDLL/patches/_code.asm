proc Patcher_ApplyPatches uiVersionID,pPMI

        ; setup traps
        stdcall Patcher_InstallAddrTrap
        ForceDefineSymbol Patcher_TrapUnpatchedCall
        ForceDefineSymbol Patcher_TrapUnpatchedJump

        ; get reloc value
        stdcall Patcher_GetPMIRelocValue,dword[pPMI]
        mov     ecx,eax

        .check_versionid:
        xor     eax,eax
        mov     edx,dword[uiVersionID]
        cmp     edx,0
        je      .id0
        cmp     edx,1
        je      .id1
        cmp     edx,2
        je      .id2
        ret

        .id0:
        stdcall Patcher_ApplyPatches_ID0,ecx,eax
        ret

        .id1:
        stdcall Patcher_ApplyPatches_ID1,ecx,eax
        ret

        .id2:
        stdcall Patcher_ApplyPatches_ID2,ecx,eax
        ret
endp
