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
; Setup Timers for NMI Seconds 
    LDX HalfTimer
    INX
    STX HalfTimer
    CPX #$1E
    BNE :+
    LDX #$01
    STX HalfTimer
    :
    CLC                   ; make sure the carry flag is clear
    LDA NMITimer
    ADC #$01
    STA NMITimer
    CMP #$3C
    BNE :+
    LDA #$01
    STA NMITimer
    CLC
    LDA SecTimer
    ADC #$01
    STA SecTimer

    :
    ;LDA #$00
    ;STA $2003       ; set the low byte (00) of the RAM address
    LDA #$02
    STA $4014       ; set the high byte (02) of the RAM address, start the transfer
    
    ; Read Controller Input 
    JSR ReadController1

    ; Set Scroll Location
    bit $2002 ; This Read Reset 2007 High / Low Byte locations
    LDA playerx
    STA $2005   ; Set the X Cordinant
    LDA #$00    
    STA $2005   ; Set the Y cordinant 
    LDX playerx
    CPX #$FE
    BNE Skip1 
; if else setup
        ADC #$01
        STA playerx
        LDX Scroll
        CPX #$00
        BNE Flip
        LDX #$01
        STX Scroll
        LDA #%10010001 ; Scroll Frame Position +256
        STA $2000
        JMP Skip2
        Flip:
        LDX #$00
        STX Scroll
        LDA #%10010000 ; Scroll Frame Position +256
        STA $2000
        Skip2:
            ; Set Scroll Location
    BIT $2002 ; This Read Reset 2007 High / Low Byte locations
    LDA playerx
    STA $2005   ; Set the X Cordinant
    LDA #$00    
    STA $2005   ; Set the Y cordinant 
    Skip1:
    ; Moving Sprites Check 

    LDA Moving
    CMP #$01
    BNE Out3
; (If {} else if {} else )
    CLC ; clear carry 
    LDA HalfTimer
    ADC #$F5 ; Greater than 
    BCS :+   ; Branch on Carry Set 
        LDA #<SpriteData3 ; Setup Pointer low byte
        STA world
        LDA #>SpriteData3 ; setup pointer high byte 
        STA world+1
        JMP Out
    :
    CLC ; clear carry 
    LDA HalfTimer
    ADC #$EB
    BCS :+
        LDA #<SpriteData2 ; Setup Pointer 
        STA world
        LDA #>SpriteData2
        STA world+1
        JMP Out
    :
        LDA #<SpriteData1 ; Setup Pointer 
        STA world
        LDA #>SpriteData1
        STA world+1
    Out:
    JMP Out4
; Standing 
    Out3: 
        LDA #<SpriteData2 ; Setup Pointer 
        STA world
        LDA #>SpriteData2
        STA world+1
        JMP Out
    Out4:
    
    LDA HalfTimer
    AND #$01
    CMP #$01
    BNE :+
        LDA #<SpriteDataFire1 ; Setup Pointer 
        STA Sprite
        LDA #>SpriteDataFire1
        STA Sprite+1
    JMP Out2
    :
        LDA #<SpriteDataFire2 ; Setup Pointer 
        STA Sprite
        LDA #>SpriteDataFire2
        STA Sprite+1
    Out2:
        LDY #$00    
        LoadSprites1: ; Load 8x8 or 8x16 (PPU OAM)
            LDA (world), Y ; Pointer Must use Y 
            STA $0200, Y ; Increment with Y  SpriteData Format Y, Tile, Pal, X 
            INY
            CPY #$20
            BNE LoadSprites1
    LDA FireBall
    CMP #$01
    BNE :+
            LDY #$00
        LoadSprites2: ; Load 8x8 or 8x16 (PPU OAM)
            LDA (Sprite), Y
            STA $0220, Y ; Second Sprite load 4 bytes 
            INY
            CPY #$04
            BNE LoadSprites2    
    :
        LDA #<SpriteEnemy1 ; Setup Pointer 
        STA Sprite
        LDA #>SpriteEnemy1
        STA Sprite+1

        LDY #$00
LoadSprites3: ; Load 8x8 or 8x16 (PPU OAM)
    
    LDA (Sprite), Y
    STA $0224, Y ; Second Sprite load 4 bytes 
    INY
    LDA (Sprite), Y
    STA $0224, Y ; Second Sprite load 4 bytes 
    INY
    LDA (Sprite), Y
    STA $0224, Y ; Second Sprite load 4 bytes 
    INY
    LDA (Sprite), Y
    SBC playerx
    STA $0224, Y ; Second Sprite load 4 bytes 
    INY
    CPY #$18
    BNE LoadSprites3 

    ; Projectile Movement 
    LDA FireBall
    CMP #$01
    BNE :+
        CLC
        LDA FireBallX
        ADC #$08
        STA FireBallX
        BCC :+
        LDA #$00
        STA FireBall
        LDA #$FF 
        STA FireBallX
        STA FireBallY
    :

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
    LDA FireBallX
    CMP #$FF
    BEQ :+
    STA $0223
    :


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
    LDA FireBallY
    CMP #$FF
    BEQ :+
    STA $0220
    :

; Call Music once per update 
    JSR FamiToneUpdate 
    RTI ; Interrupt Return.. RTS for normal Returns 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End NMI 
    
PaletteData:
; 1-4 color pallet $10,$29,$1A,$0F next 4 color $10,$36,$17,$0f etc. $22 = blue $10 = grey
; first byte $10 Should be the same in all of them and is the background color 
;Background
    .byte $31,$27,$37,$2d, $31,$34,$14,$2d, $31,$37,$16,$0f, $31,$09,$19,$0f
;Forground Sprites data
    .byte $31,$27,$37,$2d, $31,$34,$14,$2d, $31,$06,$16,$26, $31,$09,$19,$0f

    ;.byte $10,$16,$27,$18, $10,$1A,$30,$27, $10,$16,$30,$27, $10,$0F,$36,$17  ;sprite palette data

; Background Data in binary file 32 x 30 grid of data 
; https://hexed.it/ Settings: Bytes per row 32, Show 0x00 bytes as space .. Welcome Background 
; ; NES Screen Tool https://forums.nesdev.org/viewtopic.php?t=15648
.segment "RODATA" 
WorldData1:
    .incbin "world2.bin" ; Binary File hexed.it

WorldData2:
    .incbin "world3.nam" ; Binary File hexed.it
;    .include "World2.s"

AttributeTable:
	.byte $55,$55,$55,$55,$55,$55,$55,$55, $55,$55,$55,$55,$55,$55,$55,$55
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa, $aa,$aa,$aa,$aa,$2a,$0a,$0a,$0a
	.byte $00,$00,$00,$00,$aa,$aa,$00,$00, $c0,$ff,$30,$00,$08,$02,$00,$00
	.byte $af,$af,$af,$a0,$a0,$a0,$a0,$a0, $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a

; Sprite Location Data In Binary 
    SpriteData1:
;Man    Y pos, Tile, Sprite (1-4), X pos
	.byte   $00,$00,$00,$00 
	.byte   $00,$01,$00,$08
    .byte   $08,$02,$00,$08
    .byte   $08,$03,$00,$08
    .byte   $16,$04,$00,$00
	.byte   $16,$05,$00,$08
    .byte   $24,$06,$00,$00
	.byte   $24,$07,$00,$00
	
    SpriteData2:
;Man    Y pos, Tile, Sprite (1-4), X pos
	.byte   $00,$00,$00,$00 
	.byte   $00,$01,$00,$08
    .byte   $08,$02,$00,$08
    .byte   $08,$03,$00,$08
    .byte   $16,$14,$00,$00
	.byte   $16,$15,$00,$08
    .byte   $24,$16,$00,$00
	.byte   $24,$17,$00,$00

    SpriteData3:
;Man    Y pos, Tile, Sprite (1-4), X pos
	.byte   $00,$00,$00,$00 
	.byte   $00,$01,$00,$08
    .byte   $08,$02,$00,$08
    .byte   $08,$03,$00,$08
    .byte   $16,$0C,$00,$00
	.byte   $16,$0D,$00,$08
    .byte   $24,$0E,$00,$00
	.byte   $24,$0F,$00,$00

    SpriteDataFire1:
	.byte   $FF,$64,$02,$FF 
    SpriteDataFire2:
    .byte   $FF,$65,$02,$FF 

    SpriteEnemy1:
    .byte   $70,$FC,$01,$90 
    .byte   $70,$A5,$01,$98 
    .byte   $78,$A6,$01,$90 
    .byte   $78,$A7,$01,$98 
    .byte   $80,$A8,$01,$90 
    .byte   $80,$A9,$01,$98 
	

; Sprite Data Edit in yy-chr
.segment "CHARS"
    .incbin "hellones.chr"