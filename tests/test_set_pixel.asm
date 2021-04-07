.equ LEDS, 0x2000                 ; LED address

main :

addi t0, zero, 4

stw  t0,LEDS(zero)
call clear_leds

addi a0,zero,0
addi a1,zero,1
call set_pixel

addi a0,zero,1
addi a1,zero,2
call set_pixel

addi a0,zero,2
addi a1,zero,3
call set_pixel

addi a0,zero,3
addi a1,zero,4
call set_pixel

addi a0,zero,4
addi a1,zero,5
call set_pixel

addi a0,zero,5
addi a1,zero,6
call set_pixel

addi a0,zero,6
addi a1,zero,7
call set_pixel

addi a0,zero,0
addi a1,zero,0
call set_pixel

addi a0,zero,11
addi a1,zero,7
call set_pixel




break


;Set one LED to 1
;Args:
; -a0: the pixel’s x-coordinate
; -a1: the pixel’s y-coordinate.
; BEGIN:set_pixel
set_pixel: 
;t0<- load concerned word at address LED+(a0/4)
ldw t0,LEDS(a0)


addi t2, zero,3;;mask 00...011
and t2,t2,a0;; t2<-x%4

slli t2,t2,3;;t2<-8*(x%4)

add t2,t2,a1;;;;t2<-8*(x%4)+y

;; create a mask with single 1 at position y 
addi t1,zero,1
sll t1, t1, t2

;; set the proper bit of t0 to 1
or t0,t0,t1

;; replace the word with its new updated version in the RAM
stw t0,LEDS(a0)
ret
; END:set_pixel

clear_leds:
stw zero,LEDS(zero)
stw zero,LEDS+4(zero)
stw zero,LEDS+8(zero)
ret