;------------------------------------------------------------
; Unicode
;------------------------------------------------------------

MemError equ MemErrorW

;------------------------------------------------------------
; GetFileSize
;------------------------------------------------------------

INVALID_FILE_SIZE       = 0xFFFFFFFF

;------------------------------------------------------------
; PE validation
;------------------------------------------------------------

IMAGE_DOS_SIGNATURE     = 0x5A4D ; MZ
IMAGE_OS2_SIGNATURE     = 0x454E ; NE
IMAGE_OS2_SIGNATURE_LE  = 0x454C ; LE
IMAGE_VXD_SIGNATURE     = 0x454C ; LE
IMAGE_NT_SIGNATURE      = 0x00004550 ; PE

IMAGE_FILE_MACHINE_I386 = 0x014C

IMAGE_FILE_EXECUTABLE_IMAGE     = 0x0002
IMAGE_FILE_LARGE_ADDRESS_AWARE  = 0x0020
IMAGE_FILE_32BIT_MACHINE        = 0x0100
IMAGE_FILE_DLL                  = 0x2000

IMAGE_NT_OPTIONAL_HDR32_MAGIC   = 0x010B

struct IMAGE_DOS_HEADER

       e_magic          dw ?
       e_cblp           dw ?
       e_cp             dw ?
       e_crlc           dw ?
       e_cparhdr        dw ?
       e_minalloc       dw ?
       e_maxalloc       dw ?
       e_ss             dw ?
       e_sp             dw ?
       e_csum           dw ?
       e_ip             dw ?
       e_cs             dw ?
       e_lfarlc         dw ?
       e_ovno           dw ?
       e_res            dw 4 dup (?)
       e_oemid          dw ?
       e_oeminfo        dw ?
       e_res2           dw 10 dup (?)
       e_lfanew         dd ?
ends

struct IMAGE_FILE_HEADER

       Machine                  dw ?
       NumberOfSections         dw ?
       TimeDateStamp            dd ?
       PointerToSymbolTable     dd ?
       NumberOfSymbols          dd ?
       SizeOfOptionalHeader     dw ?
       Characteristics          dw ?
ends

struct IMAGE_DATA_DIRECTORY

       VirtualAddress   dd ?
       Size             dd ?
ends

IMAGE_NUMBEROF_DIRECTORY_ENTRIES = 16

struct IMAGE_OPTIONAL_HEADER32

        Magic                           dw ?
        MajorLinkerVersion              db ?
        MinorLinkerVersion              db ?
        SizeOfCode                      dd ?
        SizeOfInitializedData           dd ?
        SizeOfUninitializedData         dd ?
        AddressOfEntryPoint             dd ?
        BaseOfCode                      dd ?
        BaseOfData                      dd ?
        ImageBase                       dd ?
        SectionAlignment                dd ?
        FileAlignment                   dd ?
        MajorOperatingSystemVersion     dw ?
        MinorOperatingSystemVersion     dw ?
        MajorImageVersion               dw ?
        MinorImageVersion               dw ?
        MajorSubsystemVersion           dw ?
        MinorSubsystemVersion           dw ?
        Win32VersionValue               dd ?
        SizeOfImage                     dd ?
        SizeOfHeaders                   dd ?
        CheckSum                        dd ?
        Subsystem                       dw ?
        DllCharacteristics              dw ?
        SizeOfStackReserve              dd ?
        SizeOfStackCommit               dd ?
        SizeOfHeapReserve               dd ?
        SizeOfHeapCommit                dd ?
        LoaderFlags                     dd ?
        NumberOfRvaAndSizes             dd ?
        DataDirectory                   IMAGE_DATA_DIRECTORY
                                        rb sizeof.IMAGE_DATA_DIRECTORY * (IMAGE_NUMBEROF_DIRECTORY_ENTRIES-1)
ends

struct IMAGE_NT_HEADERS32

       Signature        dd ?
       FileHeader       IMAGE_FILE_HEADER
       OptionalHeader   IMAGE_OPTIONAL_HEADER32
ends

;------------------------------------------------------------
; File patcher
;------------------------------------------------------------

PT_OPEN_NOT = 0
PT_OPEN_ING = 1
PT_OPEN_RDY = 2

TD_VER_ID0 = 0 ; IGI.exe v1.0 (EU)
TD_VER_ID1 = 1 ; IGI.exe v1.0 (USA)
TD_VER_ID2 = 2 ; IGI.exe v1.0 (JAP)

struct TARGETDATA

        eVersionID      dd ?
        eProtected      dd ?
        eLAAFlag        dd ?
        ePatched        dd ?
ends

struct PATCHERTARGET

        eOpenState      dd ?
        hFileHandle     dd ?
        uiFileSizeLO    dd ?
        uiFileSizeHI    dd ?
        pxMemBuffer     dd ?
        tExtra          TARGETDATA
ends

struct FILEPATCHER

        tT1             PATCHERTARGET
ends
