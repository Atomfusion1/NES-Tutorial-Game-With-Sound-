; Turn on PPU and Load Data 
    LDA #$02
    STA $4014
    NOP     ; Busy CPU while waiting for PPU 
    ; $3F00 PPU Address Register and write twice MSB Universal Background Color
    LDA #$3F
    STA $2006 ;PPU Address Register
    LDA #$00
    STA $2006

    LDX #$00
LoadPalettes:
; 2 Sets of pallets 
    LDA PaletteData, X
    STA $2007 ; $3F00, $3F01, $3F02 => $3F1F ; auto inc. per write 
    INX
    CPX #$20
    BNE LoadPalettes 
    
    ; Initialize world to point to world data
    ; Load Lower Byte of WorldData Location
    LDA #<WorldData1 ; Setup Pointer 
    STA world
    ; Load Upper Byte of WorldData Location and Save in World+1  
    LDA #>WorldData1
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
    LDA (world), Y ; User Pointer 
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
    ; the last 64 bytes in a bin file created from NESST has the attribute table in it so lets load it in also 
    Attributes:
        LDA (world), Y
        STA $2007
        INY
        CPX #$03                
        BNE :+                  ; Goes to first : after it 
        CPY #$C0                ; X = 3 and Y = C0
        BEQ DoneLoadingAttributes    ; Breaks out of loop 
    :                           ; Unnamed Label BNE:+ 
        CPY #$00
        BNE Attributes
    DoneLoadingAttributes:

    ; Initialize world to point to world data
    ; Load Lower Byte of WorldData Location
    LDA #<WorldData2
    STA world
    ; Load Upper Byte of WorldData Location and Save in World+1  
    LDA #>WorldData2
    STA world+1
    ; setup address in PPU for nametable data
;    BIT $2002   ; This Read Reset 2006 High / Low Byte locations This loaded $2000 into PPU 
;    LDA #$20
;    STA $2006
;    LDA #$00
;    STA $2006

    ; Reset X and Y positions 
    LDX #$00
    LDY #$00
LoadWorld1:
    LDA (world), Y
    STA $2007
    INY
    CPX #$03                
    BNE :+                  ; Goes to first : after it 
    CPY #$C0                ; X = 3 and Y = C0
    BEQ DoneLoadingWorld1    ; Breaks out of loop 
:                           ; Unnamed Label BNE:+ 
    CPY #$00
    BNE LoadWorld1
        INX
        INC world+1     ; High Byte add 1 so same as adding 256 to address 
        JMP LoadWorld1   ; Large Loop 
    DoneLoadingWorld1:
    ; the last 64 bytes in a bin file created from NESST has the attribute table in it so lets load it in also 
    Attributes1:
        LDA (world), Y
        STA $2007
        INY
        CPX #$03                
        BNE :+                  ; Goes to first : after it 
        CPY #$C0                ; X = 3 and Y = C0
        BEQ DoneLoadingAttributes1    ; Breaks out of loop 
    :                           ; Unnamed Label BNE:+ 
        CPY #$00
        BNE Attributes1
    DoneLoadingAttributes1:


; Enable interrupts
    CLI
;   VPHB SINN = 
;   *  |        Generate NMI at start of VBI
;      *        Background Table address $1000
    LDA #%10010000 ; enable NMI change background to use second chr set of tiles ($1000)
    STA $2000
    ; Enabling sprites and background for left-most 8 pixels
    ; Enable sprites and background
;   BGRs bMmG = Eblue, Egreen, Ered, Show Sprites, Show background, show sprites, show back, greyscale 
    LDA #%00011110
    STA $2001