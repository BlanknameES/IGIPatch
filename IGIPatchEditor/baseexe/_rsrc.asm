;------------------------------------------------------------
; resource directory
;------------------------------------------------------------

directory       RT_VERSION,versions,\
                RT_MANIFEST,manifest

;------------------------------------------------------------
; resource list
;------------------------------------------------------------

resource versions,\
                IDV_MAIN,LANG_NEUTRAL,version_info

resource manifest,\
                1,LANG_NEUTRAL,manifest_file

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

;------------------------------------------------------------
; resource: manifest_file
;------------------------------------------------------------

resdata manifest_file
                file 'manifest.xml'
endres
