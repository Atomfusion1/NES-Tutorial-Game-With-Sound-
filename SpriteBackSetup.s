; Turn on PPU and Load Data 
    LDA #$02
    STA $4014
    NOP
    ; $3F00
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00
LoadPalettes:
    LDA PaletteData, X
    STA $2007 ; $3F00, $3F01, $3F02 => $3F1F
    INX
    CPX #$20
    BNE LoadPalettes    
    ; Initialize world to point to world data
    ; Load Lower Byte of WorldData Location
    LDA #<WorldData
    STA world
    ; Load Upper Byte of WorldData Location and Save in World+1  
    LDA #>WorldData
    STA world+1
    ; setup address in PPU for nametable data
    BIT $2002   ; This Read Reset 2006 High / Low Byte locations This loaded $2000 into PPU 
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    ; Reset X and Y positions 
    LDX #$00
    LDY #$00
LoadWorld:
    LDA (world), Y
    STA $2007
    INY
    CPX #$03                
    BNE :+                  ; Goes to first : after it 
    CPY #$C0                ; X = 3 and Y = C0
    BEQ DoneLoadingWorld    ; Breaks out of loop 
:                           ; Unnamed Label BNE:+ 
    CPY #$00
    BNE LoadWorld
    INX
    INC world+1     ; High Byte add 1 so same as adding 256 to address 
    JMP LoadWorld   ; Large Loop 
DoneLoadingWorld:

    LDX #$00
SetAttributes:          ; 16x16 PPU Attribute Table 
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