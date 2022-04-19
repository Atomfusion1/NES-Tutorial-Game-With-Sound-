;;;;;;;;;;;;;;;;;;;
; Add ReadController1 or ReadController2 to NMI Routine to get Controller Fuctions 
; Im sure there are better ways to do this but This currently works 
; You must add / copy paste for ReadController2 change 1 to 2 
;
;

ReadController1:
  JSR LatchController
  JSR PollController
  JSR ReadLeft1
  JSR ReadRight1
  JSR ReadUp1
  JSR ReadDown1
  JSR ReadSelect1
  JSR ReadStart1
  JSR ReadB1
  JSR ReadA1
  RTS           ; Return to Caller

; tell both the controllers to latch buttons
LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       
  RTS
;;;;;;;;;;;;;;;;;;
; Read controller input into byte vector
; 76543210
; ||||||||
; |||||||+- RIGHT button
; ||||||+-- LEFT Button
; |||||+--- DOWN Button
; ||||+---- UP Button
; |||+----- START Button
; ||+------ SELECT Button
; |+------- B Button
; +-------- A Button
; Player 1 Read 
PollController:
  LDX #$00            ; 8 buttons total
PollControllerLoop:
  LDA $4016           ; player 1 - A 
  LSR A               ; shift right
  ROL controller1     ; rotate left button vector in mem location $0003
  INX
  CPX #$08
  BNE PollControllerLoop
  RTS
; Player 2 Read
  LDX #$00            ; 8 buttons total
PollControllerLoop2:
  LDA $4017           ; player 1 - A 
  LSR A               ; shift right
  ROL controller2     ; rotate left button vector in mem location $0003
  INX
  CPX #$08
  BNE PollControllerLoop2
  RTS

; Player 1 Values 
ReadRight1: 
  LDA controller1       ; controller1 1 - A button
  AND #%00000001        ; only look at bit 0
  BEQ ReadRightDone1    ; branch to ReadADone if button is NOT pressed (0)
                        ; add instructions here to do something when button IS pressed (1)
  LDA $0203             ; load sprite X position
  CLC                   ; make sure the carry flag is clear
  LDA playerx 
  ADC #$02
  STA playerx
ReadRightDone1:         ; handling this button is done
  RTS
  

ReadLeft1: 
  LDA controller1     ; controller1 1 - B button
  AND #%00000010      ; only look at bit 0
  BEQ ReadLeftDone1   ; branch to ReadBDone if button is NOT pressed (0)
                      ; add instructions here to do something when button IS pressed (1)
  LDA $0203           ; load sprite X position
  CLC
  LDA playerx
  ADC #$FE 
  STA playerx
ReadLeftDone1:        ; handling this button is done
  RTS

ReadUp1:
  LDA controller1     ; controller1 1 - A button
  AND #%00001000      ; only look at bit 0
  BEQ ReadUpDone1     ; branch to ReadADone if button is NOT pressed (0)
                      ; add instructions here to do something when button IS pressed (1)
  LDA $0203           ; load sprite X position
  CLC
  LDA playery
  ADC #$FE 
  STA playery 
ReadUpDone1:          ; handling this button is done
  RTS

ReadDown1:
  LDA controller1     ; controller1 1 - A button
  AND #%00000100      ; only look at bit 0
  BEQ ReadDownDone1     ; branch to ReadADone if button is NOT pressed (0)
                      ; add instructions here to do something when button IS pressed (1)
  LDA $0203             ; load sprite X position
  CLC                   ; make sure the carry flag is clear
  LDA playery 
  ADC #$02
  STA playery  
ReadDownDone1:          ; handling this button is done
  RTS

ReadStart1:
  LDA controller1     ; controller1 1 - A button
  AND #%00100000      ; only look at bit 0
  BEQ ReadStartDone1     ; branch to ReadADone if button is NOT pressed (0)
                      ; add instructions here to do something when button IS pressed (1)
  ; Play Sound fx
  LDX #0 
  LDA #0
  JSR FamiToneSfxPlay     
  ; Stop Music 
  JSR FamiToneMusicStop  
ReadStartDone1:          ; handling this button is done
  RTS

ReadSelect1:
  LDA controller1     ; controller1 1 - A button
  AND #%00010000      ; only look at bit 0
  BEQ ReadSelectDone1     ; branch to ReadADone if button is NOT pressed (0)
                      ; add instructions here to do something when button IS pressed (1)
  ; play song #0
	lda #0 
	jsr FamiToneMusicPlay   
ReadSelectDone1:          ; handling this button is done
  RTS

ReadB1:
  LDA controller1     ; controller1 1 - A button
  AND #%01000000      ; only look at bit 0
  BEQ ReadBDone1     ; branch to ReadADone if button is NOT pressed (0)
                      ; add instructions here to do something when button IS pressed (1)
  ; Play sfx 
  LDX #0 
  LDA #5
  JSR FamiToneSfxPlay     
ReadBDone1:          ; handling this button is done
  RTS

ReadA1: 
  LDA controller1       ; controller1 1 - B button
  AND #%10000000  ; only look at bit 0
  BEQ ReadADone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1) 
  LDX #0 
  LDA #1
  JSR FamiToneSfxPlay  

  ;LDA inAir
  ;CMP #$01
  ;BEQ ReadADone

  ;LDA ground
  ;STA playery
  ;LDA #$FA
  ;STA playervy

  ;LDA #$01
  ;STA inAir
ReadADone:        ; handling this button is done
  RTS
