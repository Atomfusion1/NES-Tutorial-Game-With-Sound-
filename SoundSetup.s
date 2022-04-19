;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sound Setup
; Use Readme Files in Sound 
; Enable to turn on Famitone5 . Only use 5 or 2 noth both 
Famitone5 = 1   
; Enable to Turn on Famitone2 
;Famitone2 = 1 


; Includes to use Famitone2 (Pick One)
.IFDEF Famitone2
    .include ".\Sound\Famitone2\ASM\famitone2.s"
    .include ".\Sound\Famitone2\text2data\FF1.s"
    .include ".\Sound\Famitone2\nsf2data\ralph4_sfx.s"

    ; Famitone2 Library (Faster/Smaller)
    ; 
    Famitone_Init:
    ; Change Music Data here 
    ; -Notes limited to C-1 through D-6
        LDX #<FF1_music_data ;low
        LDY #>FF1_music_data ;high
        LDA #1 ;NTSC = 1, PAL = 0
        JSR FamiToneInit
        ; Set SFX famitone2 data pointer (first Program line in *name*sfx.s file )
        ;LDX #<sfx_data ;low
        ;LDY #>sfx_data ;high
        ;JSR FamiToneSfxInit
        RTS
.ENDIF

; Includes to use Famitone5
.IFDEF Famitone5
    .include ".\Sound\Famitone5\famitone5.s"
    .include ".\Sound\Famitone5\text2data\ralph4_music.s"
    .include ".\Sound\Famitone5\nsf2data\ralph4_sfx.s"

    ; Famitone5 Library (Larger / More Options/Effects)
    ;	-volume column support
    ;	-full note range
    ;	-1xx,2xx,3xx,4xx,Qxx,Rxx effects
    ;	-duty cycle envelopes
    ;	-sound fx > 256 bytes
    Famitone_Init:
        ; set music data pointer
        ldx #<ralph4_music_music_data ;low
        ldy #>ralph4_music_music_data ;high
        lda #1 ;NTSC = 1, PAL = 0
        jsr FamiToneInit
        ; Set SFX Famitone5 data pointer / ini Note Famitone5 uses Sounds not SFX_data in Famitone2
        LDX #<sounds ;low
        LDY #>sounds ;high
        JSR FamiToneSfxInit
        RTS
.ENDIF