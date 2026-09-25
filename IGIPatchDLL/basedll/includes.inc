include 'win32w.inc'

;------------------------------------------------------------
; Unicode
;------------------------------------------------------------

GetOrLoadLibrary equ GetOrLoadLibraryW
GetModuleFileNameSafe equ GetModuleFileNameSafeW
PathAppend equ PathAppendW
PathCanonicalize equ PathCanonicalizeW
PathCombine equ PathCombineW
PathRemoveFileSpec equ PathRemoveFileSpecW
PathRenameExtension equ PathRenameExtensionW

;------------------------------------------------------------
; VERSIONINFO
;------------------------------------------------------------

VS_FF_RELEASE                   = 0x00000000 ; non-standard
VS_FF_DEBUG                     = 0x00000001
VS_FF_PRERELEASE                = 0x00000002
VS_FF_PATCHED                   = 0x00000004
VS_FF_PRIVATEBUILD              = 0x00000008
VS_FF_INFOINFERRED              = 0x00000010
VS_FF_SPECIALBUILD              = 0x00000020
VS_FFI_FILEFLAGSMASK            = 0x0000003F
