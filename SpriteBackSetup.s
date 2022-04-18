LoadPalettes:
    LDA PaletteData, X
    STA $2007 ; $3F00, $3F01, $3F02 => $3F1F
    INX
    CPX #$20
    BNE LoadPalettes    

    ; Initialize world to point to world data
    LDA #<WorldData
    STA world
    LDA #>WorldData
    STA world+1

    ; setup address in PPU for nametable data
    BIT $2002
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00
    LDY #$00
LoadWorld:
    LDA (world), Y
    STA $2007
    INY
    CPX #$03
    BNE :+
    CPY #$C0
    BEQ DoneLoadingWorld
:
    CPY #$00
    BNE LoadWorld
    INX
    INC world+1
    JMP LoadWorld

DoneLoadingWorld:
    LDX #$00

SetAttributes:
    LDA #$55
    STA $2007
    INX
    CPX #$40
    BNE SetAttributes

    LDX #$00
    LDY #$00    

LoadSprites:
    LDA SpriteData, X
    STA $0200, X 
    INX
    CPX #$20
    BNE LoadSprites    

; Enable interrupts
    CLI
    LDA #%10010000 ; enable NMI change background to use second chr set of tiles ($1000)
    STA $2000
    ; Enabling sprites and background for left-most 8 pixels
    ; Enable sprites and background
    LDA #%00011110
    STA $2001