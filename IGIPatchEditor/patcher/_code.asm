proc Patcher_Init ptFilePatcher

        push    ebx
        mov     ebx,dword[ptFilePatcher]

        .init_struct:
        mov     dword[ebx+FILEPATCHER.tT1.eOpenState],PT_OPEN_NOT
        mov     dword[ebx+FILEPATCHER.tT1.hFileHandle],INVALID_HANDLE_VALUE
        mov     dword[ebx+FILEPATCHER.tT1.uiFileSizeLO],0
        mov     dword[ebx+FILEPATCHER.tT1.uiFileSizeHI],0
        mov     dword[ebx+FILEPATCHER.tT1.pxMemBuffer],NULL

        .init_extra:
        mov     dword[ebx+FILEPATCHER.tT1.tExtra.eVersionID],-1
        mov     dword[ebx+FILEPATCHER.tT1.tExtra.eProtected],-1
        mov     dword[ebx+FILEPATCHER.tT1.tExtra.ePatched],-1
        mov     dword[ebx+FILEPATCHER.tT1.tExtra.eLAAFlag],-1

        .end:
        pop     ebx
        ret
endp

proc Patcher_IsFileOpen ptFilePatcher

        mov     ecx,dword[ptFilePatcher]

        .check_open:
        xor     eax,eax
        cmp     dword[ecx+FILEPATCHER.tT1.eOpenState],PT_OPEN_NOT
        setne   al

        .end:
        ret
endp

proc Patcher_LoadFile ptFilePatcher,pszFilename

        locals
                uiFileSizeLO rd 1
                uiFileSizeHI rd 1
        endl

        push    ebx
        mov     ebx,dword[ptFilePatcher]

        .check_already_open:
        cmp     dword[ebx+FILEPATCHER.tT1.eOpenState],PT_OPEN_NOT
        jne     .error

        .do_open:
        mov     dword[ebx+FILEPATCHER.tT1.eOpenState],PT_OPEN_ING
        invoke  CreateFile,dword[pszFilename],GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
        cmp     eax,INVALID_HANDLE_VALUE
        je      .error
        mov     dword[ebx+FILEPATCHER.tT1.hFileHandle],eax

        .get_size:
        lea     ecx,[uiFileSizeLO]
        lea     edx,[uiFileSizeHI]
        stdcall GetFileSizeByHandle,eax,ecx,edx
        test    eax,eax
        jz      .error

        .check_size:
        mov     ecx,dword[uiFileSizeLO]
        mov     edx,dword[uiFileSizeHI]
        test    edx,edx
        jnz     .error
        test    ecx,ecx
        jz      .error
        mov     dword[ebx+FILEPATCHER.tT1.uiFileSizeLO],ecx
        mov     dword[ebx+FILEPATCHER.tT1.uiFileSizeHI],edx

        .do_read:
        stdcall Patcher_ReadFile,ebx
        test    eax,eax
        jz      .error

        .do_check:
        stdcall Patcher_CheckExtraData,ebx
        test    eax,eax
        jz      .error

        .close_handle:
        stdcall Patcher_CloseHandle,ebx

        .done:
        mov     dword[ebx+FILEPATCHER.tT1.eOpenState],PT_OPEN_RDY
        mov     eax,TRUE

        .end:
        pop     ebx
        ret

        .error:
        stdcall Patcher_DeInit,ebx,dword[pszFilename]
        xor     eax,eax
        jmp     .end
endp

proc Patcher_ReadFile ptFilePatcher

        push    ebx
        mov     ebx,dword[ptFilePatcher]

        .alloc_mem:
        stdcall MemAlloc,dword[ebx+FILEPATCHER.tT1.uiFileSizeLO]
        mov     dword[ebx+FILEPATCHER.tT1.pxMemBuffer],eax

        .read_file:
        mov     ecx,dword[ebx+FILEPATCHER.tT1.uiFileSizeLO]
        lea     edx,[ptFilePatcher] ;lpNumberOfBytesRead
        invoke  ReadFile,dword[ebx+FILEPATCHER.tT1.hFileHandle],eax,ecx,edx,NULL
        test    eax,eax
        setnz   al
        and     eax,TRUE

        .end:
        pop     ebx
        ret
endp

proc Patcher_CheckExtraData ptFilePatcher

        push    ebx
        mov     ebx,dword[ptFilePatcher]

        .check_format:
        stdcall Patcher_CheckValidFormat,ebx
        test    eax,eax
        jz      .end

        .check_version:
        stdcall Patcher_CheckEDataVersion,ebx

        .check_extradata:
        stdcall Patcher_CheckEDataLAAFlag,ebx
        stdcall Patcher_CheckEDataPatched,ebx

        .done:
        mov     eax,TRUE

        .end:
        pop     ebx
        ret
endp

proc Patcher_SaveFile ptFilePatcher,pszFilename,uiIndex

        locals
                uiFileSizeLO rd 1
                uiFileSizeHI rd 1
        endl

        push    ebx
        mov     ebx,dword[ptFilePatcher]

        .check_not_open:
        cmp     dword[ebx+FILEPATCHER.tT1.eOpenState],PT_OPEN_NOT
        je      .error

        .do_open:
        mov     dword[ebx+FILEPATCHER.tT1.eOpenState],PT_OPEN_ING
        invoke  CreateFile,dword[pszFilename],GENERIC_WRITE,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
        cmp     eax,INVALID_HANDLE_VALUE
        je      .error
        mov     dword[ebx+FILEPATCHER.tT1.hFileHandle],eax

        .get_size:
        lea     ecx,[uiFileSizeLO]
        lea     edx,[uiFileSizeHI]
        stdcall GetFileSizeByHandle,eax,ecx,edx
        test    eax,eax
        jz      .error

        .check_size:
        mov     ecx,dword[ebx+FILEPATCHER.tT1.uiFileSizeLO]
        mov     edx,dword[ebx+FILEPATCHER.tT1.uiFileSizeHI]
        cmp     dword[uiFileSizeLO],ecx
        jne     .error
        cmp     dword[uiFileSizeHI],edx
        jne     .error

        .do_apply:
        stdcall Patcher_ApplyExtraData,ebx,dword[uiIndex]
        test    eax,eax
        jz      .error

        .do_write:
        stdcall Patcher_WriteFile,ebx
        test    eax,eax
        jz      .error

        .close_handle:
        stdcall Patcher_CloseHandle,ebx

        .done:
        mov     dword[ebx+FILEPATCHER.tT1.eOpenState],PT_OPEN_RDY
        mov     eax,TRUE

        .end:
        pop     ebx
        ret

        .error:
        stdcall Patcher_CloseHandle,ebx
        xor     eax,eax
        jmp     .end
endp

proc Patcher_WriteFile ptFilePatcher

        push    ebx
        mov     ebx,dword[ptFilePatcher]

        ;.set_pointer:
        ;invoke  SetFilePointerEx,dword[ebx+FILEPATCHER.tT1.hFileHandle],0,0,NULL,FILE_BEGIN
        ;sub     eax,INVALID_SET_FILE_POINTER
        ;jz      .end

        .write_file:
        mov     eax,dword[ebx+FILEPATCHER.tT1.pxMemBuffer]
        mov     ecx,dword[ebx+FILEPATCHER.tT1.uiFileSizeLO]
        lea     edx,[ptFilePatcher] ;lpNumberOfBytesRead
        invoke  WriteFile,dword[ebx+FILEPATCHER.tT1.hFileHandle],eax,ecx,edx,NULL
        test    eax,eax
        setnz   al
        and     eax,TRUE

        .end:
        pop     ebx
        ret
endp

proc Patcher_ApplyExtraData ptFilePatcher,uiIndex ; TODO: update checksum

        push    ebx
        mov     ebx,dword[ptFilePatcher]

        .apply_extradata:
        stdcall Patcher_ApplyEDataLAAFlag,ebx
        stdcall Patcher_ApplyEDataPatches,ebx,dword[uiIndex]

        .done:
        mov     eax,TRUE

        .end:
        pop     ebx
        ret
endp

proc Patcher_DeInit ptFilePatcher,pszFilename

        push    ebx
        mov     ebx,dword[ptFilePatcher]

        .check_handle:
        mov     eax,dword[ebx+FILEPATCHER.tT1.hFileHandle]
        cmp     eax,INVALID_HANDLE_VALUE
        je      .check_mem

        .close_handle:
        invoke  CloseHandle,eax

        .check_mem:
        mov     eax,dword[ebx+FILEPATCHER.tT1.pxMemBuffer]
        test    eax,eax
        jz      .empty_filename

        .free_mem:
        stdcall MemFree,eax

        .empty_filename:
        mov     eax,dword[pszFilename]
        test    eax,eax
        jz      .init
        mov     word[eax],0

        .init:
        stdcall Patcher_Init,ebx

        .end:
        pop     ebx
        ret
endp

proc Patcher_CloseHandle ptFilePatcher

        mov     eax,dword[ptFilePatcher]

        .check_handle:
        mov     eax,dword[eax+FILEPATCHER.tT1.hFileHandle]
        cmp     eax,INVALID_HANDLE_VALUE
        je      .end

        .close_handle:
        invoke  CloseHandle,eax

        .end:
        ret
endp

proc Patcher_CheckValidFormat ptFilePatcher

        push    ebx
        mov     ebx,dword[ptFilePatcher]
        mov     ecx,dword[ebx+FILEPATCHER.tT1.uiFileSizeLO]

        .get_dos_header_addr:
        mov     eax,dword[ebx+FILEPATCHER.tT1.pxMemBuffer]
        cmp     ecx,sizeof.IMAGE_DOS_HEADER
        jb      .invalid
        mov     ebx,eax

        .check_dos_header:
        cmp     word[ebx+IMAGE_DOS_HEADER.e_magic],IMAGE_DOS_SIGNATURE
        jne     .invalid

        .get_nt_headers_addr:
        mov     eax,dword[ebx+IMAGE_DOS_HEADER.e_lfanew]
        test    eax,eax
        jz      .invalid
        lea     edx,[eax+sizeof.IMAGE_NT_HEADERS32]
        cmp     ecx,edx
        jb      .invalid
        add     ebx,eax

        .check_nt_headers:
        cmp     dword[ebx+IMAGE_NT_HEADERS32.Signature],IMAGE_NT_SIGNATURE
        jne     .invalid

        .check_arch:
        cmp     word[ebx+IMAGE_NT_HEADERS32.FileHeader.Machine],IMAGE_FILE_MACHINE_I386
        jne     .invalid
        test    word[ebx+IMAGE_NT_HEADERS32.FileHeader.Characteristics],IMAGE_FILE_32BIT_MACHINE
        jz      .invalid
        cmp     word[ebx+IMAGE_NT_HEADERS32.OptionalHeader.Magic],IMAGE_NT_OPTIONAL_HDR32_MAGIC
        jne     .invalid

        .check_type:
        test    word[ebx+IMAGE_NT_HEADERS32.FileHeader.Characteristics],IMAGE_FILE_EXECUTABLE_IMAGE
        jz      .invalid
        test    word[ebx+IMAGE_NT_HEADERS32.FileHeader.Characteristics],IMAGE_FILE_DLL
        jnz     .invalid

        .valid:
        mov     eax,TRUE
        pop     ebx
        ret

        .invalid:
        xor     eax,eax
        pop     ebx
        ret
endp

proc Patcher_CheckEDataVersion ptFilePatcher ; TODO: use CRC32C?

        push    ebx
        mov     ebx,dword[ptFilePatcher]
        mov     eax,dword[ebx+FILEPATCHER.tT1.pxMemBuffer]
        mov     ecx,dword[ebx+FILEPATCHER.tT1.uiFileSizeLO]
        or      edx,-1

        .check_eu:
        cmp     ecx,1384448
        jne     .check_usa
        cmp     dword[eax+0x00141ECC],'IGIM'
        jne     .check_usa
        mov     edx,TD_VER_ID0
        jmp     .end

        .check_usa:
        cmp     ecx,1388544
        jne     .check_jap
        cmp     dword[eax+0x00142624],'IGIM'
        jne     .check_jap
        mov     edx,TD_VER_ID1
        jmp     .end

        .check_jap:
        cmp     ecx,1384448
        jne     .end
        cmp     dword[eax+0x00140DC8],'IGIM'
        jne     .end
        mov     edx,TD_VER_ID2
        ;jmp     .end

        .end:
        mov     dword[ebx+FILEPATCHER.tT1.tExtra.eVersionID],edx
        xor     ecx,ecx
        cmp     edx,-1
        setne   cl
        sub     ecx,1 ; ecx = (eVersionID == -1) ? -1 : FALSE
        mov     dword[ebx+FILEPATCHER.tT1.tExtra.eProtected],ecx
        pop     ebx
        ret
endp

proc Patcher_CheckEDataLAAFlag ptFilePatcher

        push    ebx
        mov     ebx,dword[ptFilePatcher]
        mov     eax,dword[ebx+FILEPATCHER.tT1.pxMemBuffer]

        .check_flag:
        add     eax,dword[eax+IMAGE_DOS_HEADER.e_lfanew]
        xor     edx,edx
        test    word[eax+IMAGE_NT_HEADERS32.FileHeader.Characteristics],IMAGE_FILE_LARGE_ADDRESS_AWARE
        setnz   dl
        mov     dword[ebx+FILEPATCHER.tT1.tExtra.eLAAFlag],edx

        .end:
        pop     ebx
        ret
endp

proc Patcher_ApplyEDataLAAFlag ptFilePatcher

        push    ebx
        mov     ebx,dword[ptFilePatcher]
        mov     eax,dword[ebx+FILEPATCHER.tT1.pxMemBuffer]

        .apply_flag:
        add     eax,dword[eax+IMAGE_DOS_HEADER.e_lfanew]
        movzx   edx,word[eax+IMAGE_NT_HEADERS32.FileHeader.Characteristics]
        and     edx,not IMAGE_FILE_LARGE_ADDRESS_AWARE
        cmp     dword[ebx+FILEPATCHER.tT1.tExtra.eLAAFlag],TRUE
        sbb     ecx,ecx
        not     ecx
        and     ecx,IMAGE_FILE_LARGE_ADDRESS_AWARE
        or      edx,ecx
        mov     word[eax+IMAGE_NT_HEADERS32.FileHeader.Characteristics],dx

        .end:
        pop     ebx
        ret
endp

proc Patcher_CheckEDataPatched ptFilePatcher

        push    ebx esi edi
        mov     ebx,dword[ptFilePatcher]
        ;mov     eax,dword[ebx+FILEPATCHER.tT1.pxMemBuffer]
        mov     ecx,dword[ebx+FILEPATCHER.tT1.tExtra.eVersionID]
        mov     edx,dword[ebx+FILEPATCHER.tT1.tExtra.eProtected]

        .check_protected:
        cmp     edx,FALSE
        jne     .data_invalid

        .check_version:
        cmp     ecx,-1
        je      .data_invalid

        .check_data:
        xor     edi,edi ; nIndex
        mov     esi,dword[patchtbl+ecx*4]
        .loop:
        mov     eax,dword[ebx+FILEPATCHER.tT1.pxMemBuffer]
        stdcall DCompPatchList,eax,esi,edi
        test    eax,eax
        jnz     .done
        add     edi,1
        cmp     edi,1
        jbe     .loop

        .data_invalid:
        jmp     .end

        .done:
        mov     dword[ebx+FILEPATCHER.tT1.tExtra.ePatched],edi

        .end:
        pop     edi esi ebx
        ret
endp

proc Patcher_ApplyEDataPatches ptFilePatcher,uiIndex

        push    ebx
        mov     ebx,dword[ptFilePatcher]
        mov     eax,dword[ebx+FILEPATCHER.tT1.pxMemBuffer]
        mov     ecx,dword[ebx+FILEPATCHER.tT1.tExtra.eVersionID]
        mov     edx,dword[ebx+FILEPATCHER.tT1.tExtra.eProtected]

        .check_protected:
        cmp     edx,FALSE
        jne     .end

        .check_version:
        cmp     ecx,-1
        je      .end

        .apply_patches:
        mov     edx,dword[patchtbl+ecx*4]
        stdcall DCopyPatchList,eax,edx,dword[uiIndex]

        .done:
        mov     ecx,dword[uiIndex]
        mov     dword[ebx+FILEPATCHER.tT1.tExtra.ePatched],ecx

        .end:
        pop     ebx
        ret
endp
