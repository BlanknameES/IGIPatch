;------------------------------------------------------------
; version detection constants
;------------------------------------------------------------

buildarray              PATCHER_BUILD_ARRAY \
                        <0x00541ECC,buildentry_id0_cstr,sizeof.buildentry_id0_cstr,PMI_IGI_Exe>,\
                        <0x00542624,buildentry_id1_cstr,sizeof.buildentry_id1_cstr,PMI_IGI_Exe>,\
                        <0x00540DC8,buildentry_id2_cstr,sizeof.buildentry_id2_cstr,PMI_IGI_Exe>

buildentry_id0_cstr     db 'IGIMUTEX',0
buildentry_id1_cstr     db 'IGIMUTEX',0
buildentry_id2_cstr     db 'IGIMUTEX',0

;------------------------------------------------------------
; debug strings
;------------------------------------------------------------

wszPDCapInfo            du SubProjectName,': Info',0
wszPDCapWarn            du SubProjectName,': Warning',0
wszPDCapError           du SubProjectName,': Error',0

wszPDPatchDisabled      du 'Patch is not enabled.',0
wszPDUnknownVersion     du 'Unknown/unsupported version.',0
wszPDPatchingSuccess    du 'Patching completed.',0
wszPDPatchingFailure    du 'Patching failed.',0
;wszPDPluginsLoaded      du 'Loaded all plugins successfully.',0
;wszPDPluginsFailed      du 'Failed to load plugins.',0
