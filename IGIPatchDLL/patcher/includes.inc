;------------------------------------------------------------
; version detection structs
;------------------------------------------------------------

struct PATCHER_BUILD_ENTRY

        addr            dd ?
        pstr            dd ?
        size            dd ?
        ppmi            dd ?
ends

struct PATCHER_BUILD_ARRAY

        entry_id0       PATCHER_BUILD_ENTRY
        entry_id1       PATCHER_BUILD_ENTRY
        entry_id2       PATCHER_BUILD_ENTRY
        num_entries     dd (sizeof.PATCHER_BUILD_ARRAY - 1*4) / sizeof.PATCHER_BUILD_ENTRY
ends

struct PATCHER_MODULE_INFO

        dwDefBaseAddr   dd ?
        dwCurBaseAddr   dd ?
        uiRelocValue    dd ?
ends

;------------------------------------------------------------
; trap handling definitions
;------------------------------------------------------------

define PATCHER_ADDR_TRAP    0xDEADC0DE
define PATCHER_CALL_TRAP    Patcher_TrapUnpatchedCall
define PATCHER_JUMP_TRAP    Patcher_TrapUnpatchedJump

;------------------------------------------------------------
; custom memory patching definitions
;------------------------------------------------------------

define PATCHER_ALIGN_OPCODE 0x90 ; 0x90 (NOP) or 0xCC (int3)
