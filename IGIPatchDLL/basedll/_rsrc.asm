;------------------------------------------------------------
; resource directory
;------------------------------------------------------------

directory       RT_VERSION,versions

;------------------------------------------------------------
; resource list
;------------------------------------------------------------

resource versions,\
                IDV_MAIN,LANG_NEUTRAL,version_info

;------------------------------------------------------------
; resource: version_info
;------------------------------------------------------------

versioninfoex version_info,\
                VER_FILEVERSION,VER_PRODUCTVERSION,VER_FILEFLAGSMASK,VER_FILEFLAGS,VER_FILEOS,VER_FILETYPE,VER_FILESUBTYPE,VER_LANGID,VER_CHARSETID,\
                'FileDescription',<FileDescription>,\
                'FileVersion',<FileVersion>,\
                'ProductName',<ProductName>,\
                'ProductVersion',<ProductVersion>,\
                'LegalCopyright',<LegalCopyright>,\
                'OriginalFilename',<OriginalFileName>
