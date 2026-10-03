;------------------------------------------------------------
;======================> FASM 1.73.35 <======================
;------------------------------------------------------------
;
;  IGIPatchEditor by Blankname
;
;------------------------------------------------------------

include '.\baseexe\includes.inc'
include '.\patcher\includes.inc'
include '.\baseexe\macros.inc'
include '.\baseexe\variables.inc'
include '.\baseexe\rsrc.inc'

;------------------------------------------------------------

format PE GUI 4.0 NX at 0x00400000 as 'exe'
entry start

section '.code' code readable executable
include '.\baseexe\_code.asm'
include '.\baseexe\_code_utils.asm'
include '.\patcher\_code.asm'
include '.\patcher\_code_utils.asm'

section '.idata' import data readable
include '.\baseexe\_idata.asm'

;section '.edata' export data readable
;include '.\baseexe\_edata.asm'

section '.rdata' data readable
include '.\baseexe\_rdata.asm'
include '.\patcher\_rdata.asm'

section '.data' data readable writeable
include '.\baseexe\_data.asm'
;include '.\patcher\_data.asm'

section '.bss' readable writeable
include '.\baseexe\_bss.asm'
include '.\patcher\_bss.asm'

section '.rsrc' resource data readable
include '.\baseexe\_rsrc.asm'

section '.reloc' fixups data readable discardable
include '.\baseexe\_reloc.asm'
