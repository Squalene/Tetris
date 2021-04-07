#########TESTS#################
test_template:
	addi sp,sp,-4
	stw ra,0(sp)		
 

	ldw ra,0(sp)
	addi sp,sp,4
	ret
	
test_blinking_led:

	addi sp,sp,-4
	stw ra,0(sp)		
 
	test_blinking_led_while_true:
		call clear_leds

		call wait

		addi a0,zero,5
		addi a1,zero,5
		call set_pixel
		
		call wait

	jmpi test_blinking_led_while_true	

	ldw ra,0(sp)
	addi sp,sp,4
	ret

test_part4:

	addi sp,sp,-8
	stw ra,0(sp)
	stw	s0,4(sp);for i	
 	

	addi s0,zero,6 ; i for from 6 to 0
	test_part4_for:

		blt s0,zero,test_part4_for_end
		
		add a0,zero,s0
		add a1,zero,s0
		addi a2,zero,PLACED 
		call set_gsa
		
		add a0,zero,s0
		add a1,zero,s0
		call get_gsa

		addi s0,s0,-1
	test_part4_for_end:	

	ldw ra,0(sp)
	ldw s0,4(sp)
	addi sp,sp,8
	ret
	
test_part5:


	addi sp,sp,-4
	stw ra,0(sp)		
 	
	addi a0, zero, 0xB
	addi a1, zero, 0
	addi a2, zero, FALLING
	call set_gsa
	addi a0, zero, 0xB
	addi a1, zero, 1
	addi a2, zero, FALLING
	call set_gsa
	addi a0, zero, 0xB
	addi a1, zero, 2
	addi a2, zero, FALLING
	call set_gsa
	addi a0, zero, 0xB
	addi a1, zero, 3
	addi a2, zero, FALLING
	call set_gsa
	addi a0, zero, 0xB	
	addi a1, zero, 4
	addi a2, zero, FALLING
	call set_gsa
	addi a0, zero, 0xB
	addi a1, zero, 5
	addi a2, zero, FALLING
	call set_gsa
	addi a0, zero, 0xB
	addi a1, zero, 6
	addi a2, zero, FALLING
	call set_gsa
	addi a0, zero, 0xB
	addi a1, zero, 7
	addi a2, zero, FALLING
	call set_gsa

	call draw_gsa

	ldw ra,0(sp)
	addi sp,sp,4
	ret
	

test_part6:

	addi sp,sp,-4
	stw ra,0(sp)		
 	
	addi t0, zero, T
	stw t0, T_type(zero)
	addi t0, zero, So
	stw t0, T_orientation(zero)
	addi t0, zero, 5
	stw t0, T_X(zero)
	addi t0, zero, 4
	stw t0, T_Y(zero)

	addi a0, zero, FALLING
	call draw_tetromino

	call draw_gsa

	ldw ra,0(sp)
	addi sp,sp,4
	ret

test_part7:
	addi sp,sp,-4
	stw ra,0(sp)	

	## NEED TO MODIFY MANUALLY IN THE SIMULATION "uart: receive" and put a value to make it work!!!
	call generate_tetromino

	addi a0, zero, FALLING
	call draw_tetromino

	call draw_gsa
 

	ldw ra,0(sp)
	addi sp,sp,4
	ret

test_part8:
	addi sp,sp,-4
	stw ra,0(sp)

	addi t0, zero, 6
    stw t0, T_X(zero)
    addi t0, zero, 5
    stw t0, T_Y(zero)
    addi t0, zero, B
    stw t0, T_type(zero)
    addi t0, zero, So
    stw t0, T_orientation(zero)
    addi a0, zero, PLACED
    call draw_tetromino
    call draw_gsa

    addi t0, zero, 10
    stw t0, T_X(zero)
    addi t0, zero, 5
    stw t0, T_Y(zero)
    addi t0, zero, T
    stw t0, T_type(zero)
    addi t0, zero, So
    stw t0, T_orientation(zero)

    addi a0, zero, E_COL
    call detect_collision

	ldw ra,0(sp)
	addi sp,sp,4
	ret

test_part9_rotate:
	addi sp,sp,-4
	stw ra,0(sp)
	
	addi t0, zero, 3
    stw t0, T_X(zero)
    addi t0, zero, 3
    stw t0, T_Y(zero)
    addi t0, zero, B
    stw t0, T_type(zero)
    addi t0, zero, So
    stw t0, T_orientation(zero)
    addi a0, zero, PLACED
    call draw_tetromino
    call draw_gsa

	addi a0,zero,NOTHING
	call draw_tetromino 
	addi a0,zero,rotR
	call rotate_tetromino ;rotate right
 	call draw_tetromino
	call draw_gsa
	
	addi a0,zero,NOTHING
	call draw_tetromino 
	addi a0,zero,rotL
	call rotate_tetromino ;rotate left
	addi a0,zero,FALLING
	call draw_tetromino
	call draw_gsa
	
	addi a0,zero,NOTHING;erase falling tetromino
	call draw_tetromino 
	addi a0,zero,rotL
	call rotate_tetromino ;rotate left
	addi a0,zero,FALLING
	call draw_tetromino
	call draw_gsa

	addi a0,zero,NOTHING;erase falling tetromino
	call draw_tetromino 
	addi a0,zero,rotL
	call rotate_tetromino ;rotate left
	addi a0,zero,FALLING
	call draw_tetromino
	call draw_gsa

	addi a0,zero,NOTHING;erase falling tetromino
	call draw_tetromino 
	addi a0,zero,rotL
	call rotate_tetromino ;rotate left
	addi a0,zero,FALLING
	call draw_tetromino
	call draw_gsa

	addi a0,zero,NOTHING;erase falling tetromino
	call draw_tetromino 
	addi a0,zero,rotL
	call rotate_tetromino ;rotate left
	addi a0,zero,FALLING
	call draw_tetromino
	call draw_gsa

	addi a0,zero,NOTHING
	call draw_tetromino 
	addi a0,zero,rotR
	call rotate_tetromino ;rotate right
	addi a0,zero,FALLING
 	call draw_tetromino
	call draw_gsa

	ldw ra,0(sp)
	addi sp,sp,4
	ret


test_part9_act:

	addi sp,sp,-4
	stw ra,0(sp)

	;(7,7)
	addi a0,zero,7 ;X_position
	addi a1,zero,7 ;Y_position
	addi a2,zero,PLACED ;Type of cell
	call set_gsa
	call draw_gsa

	;(7,5)
	addi a0,zero,7 ;X_position
	addi a1,zero,5 ;Y_position
	addi a2,zero,PLACED ;Type of cell
	call set_gsa
	call draw_gsa

	;bar in (1,1) down
	addi t0, zero, 1
    stw t0, T_X(zero)
    addi t0, zero, 1
    stw t0, T_Y(zero)
    addi t0, zero, B
    stw t0, T_type(zero)
    addi t0, zero, E
    stw t0, T_orientation(zero)
    addi a0, zero, PLACED
    call draw_tetromino
    call draw_gsa

	addi a0,zero,NOTHING
	call draw_tetromino 
	call draw_gsa
	addi a0,zero,moveD
	call act
	addi a0,zero,FALLING
	call draw_tetromino
	call draw_gsa

	addi a0,zero,NOTHING
	call draw_tetromino 	
	call draw_gsa
	addi a0,zero,moveL
	call act
	addi a0,zero,FALLING
	call draw_tetromino
	call draw_gsa

	addi a0,zero,NOTHING
	call draw_tetromino 	
	call draw_gsa
	addi a0,zero,moveR
	call act
	addi a0,zero,FALLING
	call draw_tetromino
	call draw_gsa

	addi a0,zero,NOTHING
	call draw_tetromino 
	call draw_gsa
	addi a0,zero,rotR
	call act
	addi a0,zero,FALLING
	call draw_tetromino
	call draw_gsa
	
	
	ldw ra,0(sp)
	addi sp,sp,4
	ret

test_part10:
	addi sp,sp,-4
	stw ra,0(sp)

	call get_input

	ldw ra,0(sp)
	addi sp,sp,4
	ret

test_part11_1:
	addi sp,sp,-4
	stw ra,0(sp)
	
	;Set the whole line 4 to 1 (PLACED)
	addi s1, zero, 11 #s1 = 11 (x-counter)
	test_part11_1_loop_start:
		add a0, s1, zero
		addi a1, zero, 4
		addi a2, zero, PLACED
		call set_gsa
		addi s1, s1, -1
		bge s1, zero, test_part11_1_loop_start
	test_part11_1_loop_end:	

	;Set the whole line 7 to 1 (PLACED)
	addi s1, zero, 11 #s1 = 11 (x-counter)
	test_part11_1_loop2_start:
		add a0, s1, zero
		addi a1, zero, 7
		addi a2, zero, PLACED
		call set_gsa
		addi s1, s1, -1
		bge s1, zero, test_part11_1_loop2_start
	test_part11_1_loop2_end:	
	
	call draw_gsa
	call detect_full_line


	ldw ra,0(sp)
	addi sp,sp,4
	ret

test_part11_2:
	addi sp,sp,-4
	stw ra,0(sp)

	;Set the whole line 4 to 1 (PLACED)
	addi t1, zero, 11 #s1 = 11 (x-counter)
	test_part11_2_loop_start:
		add a0, t1, zero
		addi a1, zero, 4
		addi a2, zero, PLACED
		call set_gsa
		addi t1, t1, -1
		bge t1, zero, test_part11_2_loop_start


	test_part11_2_loop_end:

	; Place some points
	addi a0, zero, 5
	addi a1, zero, 1
	addi a2, zero, PLACED
	call set_gsa

	addi a0, zero, 5
	addi a1, zero, 6
	addi a2, zero, PLACED
	call set_gsa

	addi a0, zero, 2
	addi a1, zero, 1
	addi a2, zero, PLACED
	call set_gsa

	addi a0, zero, 2
	addi a1, zero, 0
	addi a2, zero, PLACED
	call set_gsa
	
	call draw_gsa
	call detect_full_line
	add a0, v0, zero
	call remove_full_line
	call draw_gsa


	ldw ra,0(sp)
	addi sp,sp,4
	ret

	test_part12_1:

	addi sp,sp,-4
	stw ra,0(sp)

	addi t0,zero,638
	stw t0,SCORE(zero)
	call increment_score
	call increment_score

	addi t0,zero,9999
	stw t0,SCORE(zero)
	call increment_score


	ldw ra,0(sp)
	addi sp,sp,4
	ret

		