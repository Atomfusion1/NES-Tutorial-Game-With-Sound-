; DECLARE SOME VARIABLES HERE
; zeropage ram is the first memory area, (thus the name) and is faster to load from than normal memory 
; This is why it is usually reserved for things that require speedy execution.
; Example = player_x:       .res 1  ; .rs 1 means reserve one byte of space  

.segment "ZEROPAGE" ; LSB 0 - FF Start at 00

loopCount:      .res 1 ; count the loop
playerx:        .res 1 ; players x pos
playervx:       .res 1 ; players x vel
playery:        .res 1 ; players y pos
playervy:       .res 1 ; player  y vel (negative is up)
controller1:    .res 1 ; controller 1 button vector
controller2:    .res 1 ; controller 1 button vector 

gravity:        .res 1 ; gravity
ground:         .res 1 ; y value of the ground
inAir:          .res 1 

enemyx:         .res 1
enemyy:         .res 1

backgroundLo:   .res 1
backgroundHi:   .res 1
counterLo:      .res 1
counterHi:      .res 1
world:          .res 2  ; 16 Bit Value (High/Low Bits need to be inserted )
player_x:       .res 1  ; .rs 1 means reserve one byte of space  
player_y:       .res 1  ; 

