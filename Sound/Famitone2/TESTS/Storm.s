;this file for FamiTone2 library generated by text2data tool

Storm_music_data:
	.byte 1
	.word @instruments
	.word @samples-3
	.word @song0ch0,@song0ch1,@song0ch2,@song0ch3,@song0ch4,307,256 ; New song

@instruments:
	.byte $30 ;instrument $00
	.word @env1,@env0,@env0
	.byte $00

@samples:
@env0:
	.byte $c0,$00,$00
@env1:
	.byte $cb,$03,$c0,$00,$02


; New song
@song0ch0:
	.byte $fb,$01
	.byte $fd
	.word @song0ch0loop

; New song
@song0ch1:
	.byte $fd
	.word @song0ch1loop

; New song
@song0ch2:
	.byte $fd
	.word @song0ch2loop

; New song
@song0ch3:
	.byte $fd
	.word @song0ch3loop

; New song
@song0ch4:
	.byte $fd
	.word @song0ch4loop
