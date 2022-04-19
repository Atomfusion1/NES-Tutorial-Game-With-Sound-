; Basic Memory Reset
RESET:              
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


; First wait for vblank to make sure PPU is ready
vblankwait1:
    BIT $2002
    BPL vblankwait1

    LDX #$00                ; Load Registry X with $00 Hex 
clear_memory:               ; Label 
    LDA #$00                ; Load Registry A with $00 Hex  
    STA $0000, X            ; Store Registry 
    STA $0100, X
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FF        ; This moves all Sprites off Screen 
    STA $0200, X    ; $0200 => $02FF
    INX             ; Add 1 to X 
    CPX #$00
    BNE clear_memory

; second wait for vblank, PPU is ready after this
vblankwait2:
    BIT $2002
    BPL vblankwait2
