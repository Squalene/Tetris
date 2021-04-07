main:

	whiletrue:

		call clear_leds

		call wait

		addi a0,zero,5
		addi a1,zero,5
		call set_pixel
		
		call wait

		jmpi whiletrue
		


break

;Set all LEDS to 0
; BEGIN:clear_leds
clear_leds:
stw zero,LEDS(zero)
stw zero,LEDS+4(zero)
stw zero,LEDS+8(zero)
	ret
; END:clear_leds

;Set one LED to 1
;Args:
; -a0: the pixel’s x-coordinate
; -a1: the pixel’s y-coordinate.
; BEGIN:set_pixel
set_pixel: 
;t0<- load concerned word at address LED+(a0/4)
ldw t0,LEDS(a0)

addi t2, zero,3 ; mask 00...011
and t2,t2,a0 ; t2<-x%4
slli t2,t2,3 ; t2<-8*(x%4)
add t2,t2,a1 ; t2<-8*(x%4)+y

; create a mask with single 1 at proper position  
addi t1,zero,1
sll t1, t1, t2

; set the proper bit of t0 to 1
or t0,t0,t1

; replace the word with its new updated version in the RAM
stw t0,LEDS(a0)
ret
; END:set_pixel

;add a delay of 0.2s
; BEGIN:wait

wait:

	addi t0,zero,0 ;;initialize t0 to 0:counter
	addi t1,zero,4 ;;initialize t1 to 2^20

	loop:
		beq t0,t1,end ;; while counter!=2^20
		addi t0,t0,1 ;;t0+=1
		jmpi loop

	end:
	ret

; END:wait

.equ LEDS, 0x2000 
