;------------------------------------------------------------
;======================> FASM 1.73.35 <======================
;------------------------------------------------------------
;
;  IGIPatchDLL by Blankname
;
;------------------------------------------------------------

include '.\basedll\includes.inc'
include '.\inifile\includes.inc'
include '.\patcher\includes.inc'
include '.\patches\includes.inc'
include '.\basedll\macros.inc'
include '.\basedll\variables.inc'
include '.\basedll\rsrc.inc'

;------------------------------------------------------------

format PE GUI 4.0 DLL at 0x00400000 as 'dll'
entry DllEntryPoint 

section '.code' code readable executable
include '.\basedll\_code.asm'
include '.\basedll\_code_utils.asm'
include '.\inifile\_code.asm'
include '.\inifile\_code_utils.asm'
include '.\patcher\_code.asm'
include '.\patcher\_code_utils.asm'
include '.\patches\_code.asm'
include '.\patches\_code_applypatches_id0.asm'
include '.\patches\_code_applypatches_id1.asm'
include '.\patches\_code_applypatches_id2.asm'
include '.\patches\_code_mainhooks.asm'
include '.\patches\_code_sharedfuncs.asm'

section '.rdata' data readable
include '.\basedll\_rdata.asm'
include '.\inifile\_rdata.asm'
include '.\patcher\_rdata.asm'
include '.\patches\_rdata.asm'

section '.data' data readable writeable
include '.\basedll\_data.asm'
include '.\inifile\_data.asm'
include '.\patcher\_data.asm'
include '.\patches\_data.asm'

section '.bss' readable writeable
include '.\basedll\_bss.asm'
include '.\inifile\_bss.asm'
include '.\patcher\_bss.asm'
include '.\patches\_bss.asm'

section '.idata' import data readable
include '.\basedll\_idata.asm'

section '.edata' export data readable
include '.\basedll\_edata.asm'

section '.rsrc' resource data readable
include '.\basedll\_rsrc.asm'

section '.reloc' fixups data readable discardable
include '.\basedll\_reloc.asm'
