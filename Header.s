;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Header Settings For Starter NES roms 
; this is boiler plate Setup 


.segment "HEADER"

NES_MAPPER = 0                        ; 0 = NROM
NES_MIRROR = 1                         ; 0 = horizontal mirroring, 1 = vertical mirroring
NES_SRAM   = 0                         ; 1 = battery backed SRAM at $6000-7FFF

.byte 'N', 'E', 'S', $1A                ; ID
.byte $02                               ; 16k PRG chunk count
.byte $01                               ; 8k CHR chunk count
.byte NES_MIRROR | (NES_SRAM << 1) | ((NES_MAPPER & $f) << 4)
.byte (NES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0    ; padding