RESET:
; Basic Memory Reset
    SEI           ; disable IRQs
    CLD		    ; disable decimal mode
    LDX #$40
    STX $4017	    ; disable APU frame IRQ
    LDX #$ff 	    ; Set up stack
    TXS		    ;  .
    INX		    ; now X = 0
    STX $2000	    ; disable NMI
    STX $2001 	; disable rendering
    STX $4010 	; disable DMC IRQs


; first wait for vblank to make sure PPU is ready
vblankwait1:
    BIT $2002
    BPL vblankwait1

clear_memory:
    lda #$00
    STA $0000, X
    STA $0100, X
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FF        ; This moves all Sprites off Screen 
    STA $0200, X    ; $0200 => $02FF
    LDA #$00
    INX
    BNE clear_memory

; second wait for vblank, PPU is ready after this
vblankwait2:
    BIT $2002
    BPL vblankwait2

    LDA #$02
    STA $4014
    NOP
    ; $3F00
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00