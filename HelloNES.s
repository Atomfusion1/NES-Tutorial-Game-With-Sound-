;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Header Settings For Starter NES roms this is boiler plate 
; Compile with ca65
; .\cc65\bin\ca65 helloNES.asm -o helloNES.o --debug-info
; .\cc65\bin\ld65 helloNES.o -o helloNES.nes -t nes --dbgfile helloNES.dbg
; Basic NMOS 6502 http://www.6502.org/tutorials/6502opcodes.html
; Start Tutorial Warning they are in NESASM https://nerdy-nights.nes.science/
; https://github.com/ddribin/nerdy-nights
; https://github.com/JamesSheppardd/Nerdy-Nights-ca65-Translation
; 

; Start the NES header
.include "Header.s"

; Load Zero Page Variables 
.include "Variables.s"

; Setup Interrupts (CPU Hardware Timer essentially)
.segment "VECTORS"
    ; Non-maskable Interrupt NMI (NTSC = 60 Times per Second)
    ; Connected to the PPU and detects Vertical Blanking 
    ; Put Game code here you get 24000 cycles (keep it fast)
    .addr NMI
    ; When the processor first turns on or is reset, it will jump to the label reset:
    .addr RESET
    ; External interrupt IRQ (unused)
    .addr 0 ; MMC3 use etc. 

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"


; Setup Sound Engine (more info in SoundSetup.s)
.include "SoundSetup.s"

; Basic Reset Call and Memory Setup
.include "Reset.s"

; Setup Background and Forground Sprites 
.include "SpriteBackSetup.s"

; Jump to intialize Sound SoundSetup.s
JSR Famitone_Init

; Controller Code for Checking Inputs 
.include "Controller.s"

; This is where the NES is while its waiting for the Graphics to finish, one frame then trigger NMI 
Loop:
    JMP Loop ; This protects from entering into NMI before

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is where you do everything to control the game
NMI:
    ;LDA #$00
    ;STA $2003       ; set the low byte (00) of the RAM address
    LDA #$02
    STA $4014       ; set the high byte (02) of the RAM address, start the transfer
    
    ; Read Controller Input 
    JSR ReadController1

; Player Movement Sprite X Position 
    LDA playerx
    STA $0203
    STA $020B
    STA $0213
    STA $021B
    TAX
    CLC
    ADC #$08
    STA $0207
    STA $020F
    STA $0217
    STA $021F
    STX playerx

; Player Movement Sprite Y Position
    LDA playery
    STA $0200
    STA $0204
    TAX
    CLC
    ADC #$08
    STA $0208
    STA $020C
    CLC
    ADC #$08    
    STA $0210
    STA $0214
    CLC
    ADC #$08    
    STA $0218
    STA $021C
    STX playery

; Call Music once per update 
    JSR FamiToneUpdate 
    RTI ; Interrupt Return.. RTS for normal Returns 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End NMI 
    

    
PaletteData:
; 1-4 color pallet $10,$29,$1A,$0F next 4 color $10,$36,$17,$0f etc. $22 = blue $10 = grey
; first byte $10 Should be the same in all of them and is the background color 
    .byte $10,$29,$1A,$0F,$10,$36,$17,$0f,$10,$30,$21,$0f,$10,$27,$17,$0F  ;background palette data
    .byte $10,$16,$27,$18,$10,$1A,$30,$27,$10,$16,$30,$27,$10,$0F,$36,$17  ;sprite palette data

; Background Data in binary file 32 x 30 grid of data 
; https://hexed.it/ Settings: Bytes per row 32, Show 0x00 bytes as space .. Welcome Background 
; ; NES Screen Tool https://forums.nesdev.org/viewtopic.php?t=15648
WorldData:
;    .incbin "world2.bin" ; Binary File hexed.it
    .include "World.s"


; Sprite Location Data In Binary 
SpriteData:
;Man    Y pos, Tile, ? , X pos
    .byte $08, $00, $00, $08
    .byte $08, $01, $00, $10
    .byte $10, $02, $00, $08
    .byte $10, $03, $00, $10
    .byte $18, $04, $00, $08
    .byte $18, $05, $00, $10
    .byte $20, $06, $00, $08
    .byte $20, $07, $00, $10

; Sprite Data Edit in yy-chr
.segment "CHARS"
    .incbin "hellones.chr"