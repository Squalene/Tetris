.equ LEDS,0x2000

main :

addi t0, zero, 4

stw  t0,LEDS(zero)
call clear_leds

break

clear_leds:
stw zero,LEDS(zero)
stw zero,LEDS+4(zero)
stw zero,LEDS+8(zero)
ret