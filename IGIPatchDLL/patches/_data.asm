;------------------------------------------------------------
; proxy hooks
;------------------------------------------------------------

Display_nScreenWidth        dd 640
Display_nScreenHeight       dd 480
Display_nCurrentWidth       dd 640 ; Display_tActiveMode.nWidth is not updated fast enough
Display_nCurrentHeight      dd 480 ; Display_tActiveMode.nHeight is not updated fast enough
Display_nRealWidthRatio     dd 1.0 ; current mode width to real screen width ratio
Display_nRealHeightRatio    dd 1.0 ; current mode height to real screen height ratio
Display_vAspectRatio        dd 1.3333334 ; 4:3
Display_vAspectRatioInv     dd 0.75 ; 1 / (4:3)
Display_vRelAspectRatio     dd 1.0 ; 4:3 * Display_vAspectRatio34
Display_vRelAspRatioInv     dd 1.0 ; 1 / (4:3 * Display_vAspectRatio34)
Display_nCurrentRefreshRate dd 60

CutScene_isRunning          dd FALSE

;AnimController_nTicksPerFrame   dd 160 ; 4800.0 / 30
AnimController_vTicksPerFrameIn dd 0.00625 ; 1.0 / AnimController_nTicksPerFrame

;------------------------------------------------------------
; shared functions
;------------------------------------------------------------

;------------------------------------------------------------
; CDCheckPatch
;------------------------------------------------------------

;------------------------------------------------------------
; TimerTaskPatch
;------------------------------------------------------------

Timer_IsAPIAva_tGT      dd FALSE
Timer_IsAPIAva_QPC      dd FALSE
Timer_IsAPIAva_GTC      dd FALSE
Timer_nMaxSysRes        dd 0 ; tGT only
Timer_nFrequency        dq 0 ; QPC only
Timer_IsFreq10MHz       dd FALSE ; QPC only
Timer_pfnGetCounter     dd NULL
Timer_nStartTime        dd 0

;------------------------------------------------------------
; MouseCursorPatch
;------------------------------------------------------------

;------------------------------------------------------------
; BorderlessPatch
;------------------------------------------------------------

Main_tWindowPosRect     RECT 0,0,0,0

;------------------------------------------------------------
; DisplayModesFix
;------------------------------------------------------------

;------------------------------------------------------------
; WidescreenPatch
;------------------------------------------------------------

Viewport_vFOVMul        dd 1.0

;------------------------------------------------------------
; DebugFeaturesPatch
;------------------------------------------------------------

;------------------------------------------------------------
; MainMenuPatch
;------------------------------------------------------------

;------------------------------------------------------------
; NewFPSLimiterPatch
;------------------------------------------------------------

; new accurate timer system
AccTimer_nTimingAPI             dd 0 ; 0 = timeGetTime, 1 = QueryPerformanceCounter
AccTimer_bAvailableAPI          dd 0 ; 0 = none, 1 = timeGetTime, 2 = QueryPerformanceCounter
AccTimer_pfnGetCounter          dd NULL
AccTimer_pfnCalcParams          dd NULL
AccTimer_nSysRes_ms             dd 0 ; TODO: add ini setting?
align 8
AccTimer_vFrequency             dq 0.0
AccTimer_vPeriod                dq 0.0 ; inverse of AccTimer_nFrequency
AccTimer_nFrequency             dq 0
AccTimer_nLastCounter32         dd 0 ; only ever used by timeGetTime
AccTimer_nWrapCounterHI         dd 0 ; only ever used by timeGetTime
align 8
AccTimer_vToSecsConvMult        dq 0.0
AccTimer_vToMillisConvMult      dq 0.0
AccTimer_nStartTime             dq 0

; Flow_t vars
Flow_eDrawInterpolateQTaskEvent dd 255
Flow_ptDrawInterpolateQTaskList dd NULL

; Flow_t external struct members
Flow_nSuspendRefCount           dd 0
Flow_nStartTime                 dq 0
Flow_nSkipTime                  dq 0
Flow_nSuspendTime               dq 0
Flow_nRefreshRate               dd -1

; Flow_RunHandler static vars
Flow_nCurrentPhase              dd 0
Flow_nCurrentInputRate          dd 0
Flow_nCurrentFrequency          dd 0
Flow_nCurrentRefreshRate        dd 0
Flow_vCurrentGLogicFPS          dd 0.0
Flow_vCurrentRenderFPS          dd 0.0
Flow_nCInputTimestep            dq 0
;Flow_vGLogicTimestep            dq 0.0
Flow_nGLogicTimestep            dq 0
Flow_nGLogicTimestepAdd         dd 0
Flow_vGLogicTimestepAcc         dq 0.0
Flow_vGLogicTimestepAccAdd      dd 0.0
;Flow_vRenderTimestep            dq 0.0
Flow_nRenderTimestep            dq 0
Flow_nRenderTimestepAdd         dd 0
Flow_vRenderTimestepAcc         dq 0.0
Flow_vRenderTimestepAccAdd      dd 0.0
Flow_nCInputLastTime            dq 0
Flow_nGLogicUpdateTime          dq 0
Flow_nGLogicLastTime            dq 0
Flow_nGLogicDeltaTime           dq 0
;Flow_nRenderUpdateTime          dq 0
Flow_nRenderLastTime            dq 0
Flow_nRenderDeltaTime           dq 0
Flow_vDrawDeltaTime             dq 0.0
Flow_isForbidDrawOneTick        dd FALSE

; temp workaround
StationaryGun_isUsedByPlayer    dd FALSE

; used for interpolated shaking calculations
HumanView_anUBRandomState       dd 3 dup (0)

; ViewportQTask static vars
ViewportQTask_ptLastSetQCamera  dd NULL

; HumanView static vars
HumanView_tInterpPos            real64x3_t 0.0,0.0,0.0

; new function parameters passed indirectly
Direct3DRender_tDrawRigidMeshContext2 DrawRigidMeshContext2_t FALSE,0,<0.0,0.0,0.0>
Direct3DRender_tDrawBoneMeshContext2 DrawBoneMeshContext_t FALSE,0,<0.0,0.0,0.0>
;Direct3DRender_tDrawSplineMeshContext2 DrawSplineMeshContext2_t FALSE,0,<0.0,0.0,0.0>

Mouse_nRelPositionX             dd 0
Mouse_nRelPositionY             dd 0
Mouse_vCustomSensMultX          dd 1.0
Mouse_vCustomSensMultY          dd 1.0
Mouse_bButtonAcc                dd 0 ; buffered buttons swap

; TODO: rename to simply Mouse_
Mouse_tMouse_IsLocked           db FALSE
align 4
Mouse_tMouse_vAnalogX           dd 0.0
Mouse_tMouse_vAnalogY           dd 0.0
Mouse_tMouse_vAnalogX_M100      dd 0.0 ; NFL_FLOW_PHASE_MASK_RUN
Mouse_tMouse_vAnalogY_M100      dd 0.0
Mouse_tMouse_vAnalogX_M010      dd 0.0 ; NFL_FLOW_PHASE_MASK_INTERP
Mouse_tMouse_vAnalogY_M010      dd 0.0
Mouse_tMouse_vAnalogX_M110      dd 0.0 ; NFL_FLOW_PHASE_MASK_RUN + NFL_FLOW_PHASE_MASK_INTERP
Mouse_tMouse_vAnalogY_M110      dd 0.0
Mouse_tMouse_vAnalogX_M001      dd 0.0 ; NFL_FLOW_PHASE_MASK_DRAW
Mouse_tMouse_vAnalogY_M001      dd 0.0
Mouse_tMouse_vAnalogX_M101      dd 0.0 ; NFL_FLOW_PHASE_MASK_RUN + NFL_FLOW_PHASE_MASK_DRAW
Mouse_tMouse_vAnalogY_M101      dd 0.0
Mouse_tMouse_vAnalogX_M011      dd 0.0 ; NFL_FLOW_PHASE_MASK_INTERP + NFL_FLOW_PHASE_MASK_DRAW
Mouse_tMouse_vAnalogY_M011      dd 0.0
Mouse_tMouse_vAnalogX_M111      dd 0.0 ; NFL_FLOW_PHASE_MASK_RUN + NFL_FLOW_PHASE_MASK_INTERP + NFL_FLOW_PHASE_MASK_DRAW
Mouse_tMouse_vAnalogY_M111      dd 0.0
Mouse_tMouse_avAnalogX_Acc      dd 7 dup (0.0)
Mouse_tMouse_avAnalogY_Acc      dd 7 dup (0.0)

InputPort_P0Input_vAnalogX_M100 dd 0.0
InputPort_P0Input_vAnalogY_M100 dd 0.0
InputPort_P0Input_vAnalogX_M010 dd 0.0
InputPort_P0Input_vAnalogY_M010 dd 0.0
InputPort_P0Input_vAnalogX_M110 dd 0.0
InputPort_P0Input_vAnalogY_M110 dd 0.0
InputPort_P0Input_vAnalogX_M001 dd 0.0
InputPort_P0Input_vAnalogY_M001 dd 0.0
InputPort_P0Input_vAnalogX_M101 dd 0.0
InputPort_P0Input_vAnalogY_M101 dd 0.0
InputPort_P0Input_vAnalogX_M011 dd 0.0
InputPort_P0Input_vAnalogY_M011 dd 0.0
InputPort_P0Input_vAnalogX_M111 dd 0.0
InputPort_P0Input_vAnalogY_M111 dd 0.0

HumanPlayerInput_IsRunning      dd FALSE
HumanPlayerInput_vChannel0      dd 0.0
HumanPlayerInput_vChannel1      dd 0.0
;HumanPlayerInput_vLastChannel0  dd 0.0 ; TODO
;HumanPlayerInput_vLastChannel1  dd 0.0 ; TODO

InputOptions_vCurMouseSensX     dd 0.4
InputOptions_vCurMouseSensY     dd 0.4
InputOptions_vCurMouseSensYIgn  dd 0.4 ; InputOptions_vCurMouseSensY with invert mouse option ignored
InputOptions_vMinMouseSensMult  dd 0.05
InputOptions_vMaxMouseSensMult  dd 1.0
