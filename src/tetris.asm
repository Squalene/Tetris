  ;; game state memory location
  .equ T_X, 0x1000                  ; falling tetrominoe position on x
  .equ T_Y, 0x1004                  ; falling tetrominoe position on y
  .equ T_type, 0x1008               ; falling tetrominoe type
  .equ T_orientation, 0x100C        ; falling tetrominoe orientation
  .equ SCORE,  0x1010               ; score
  .equ GSA, 0x1014                  ; Game State Array starting address
  .equ SEVEN_SEGS, 0x1198           ; 7-segment display addresses
  .equ LEDS, 0x2000                 ; LED address
  .equ RANDOM_NUM, 0x2010           ; Random number generator address
  .equ BUTTONS, 0x2030              ; Buttons addresses

  ;; type enumeration
  .equ C, 0x00
  .equ B, 0x01
  .equ T, 0x02
  .equ S, 0x03
  .equ L, 0x04

  ;; GSA type
  .equ NOTHING, 0x0
  .equ PLACED, 0x1
  .equ FALLING, 0x2

  ;; orientation enumeration
  .equ N, 0
  .equ E, 1
  .equ So, 2
  .equ W, 3
  .equ ORIENTATION_END, 4

  ;; collision boundaries
  .equ COL_X, 4
  .equ COL_Y, 3

  ;; Rotation enumeration
  .equ CLOCKWISE, 0
  .equ COUNTERCLOCKWISE, 1

  ;; Button enumeration
  .equ moveL, 0x01
  .equ rotL, 0x02
  .equ reset, 0x04
  .equ rotR, 0x08
  .equ moveR, 0x10
  .equ moveD, 0x20

  ;; Collision return ENUM
  .equ W_COL, 0
  .equ E_COL, 1
  .equ So_COL, 2
  .equ OVERLAP, 3
  .equ NONE, 4

  ;; start location
  .equ START_X, 6
  .equ START_Y, 1

  ;; game rate of tetrominoe falling down (in terms of game loop iteration)
  .equ RATE, 5

  ;; standard limits
  .equ X_LIMIT, 12
  .equ Y_LIMIT, 8

;Not display score at the end
main:

	addi sp,sp,0x2000
	main_push:
		addi sp, sp, -16
		stw ra, 12(sp)
		stw s0, 8(sp);RATE cst
		stw s1, 4(sp);RATE counter
		stw s2, 0(sp);can move down
	
		main_init:
			addi s0,zero,5 #s0 = 5 (constant)
			call reset_game

		
		main_until_overlaping_init_tetromino_begin:
				
			main_move_one_step_down_until_collision_begin:

				add s1,zero,zero #s1 = 0 (counter)
			
				main_retrieve_input_begin:
				beq s1,s0,main_retrieve_input_end ;while i<RATE
				
					call draw_gsa
					call display_score
					addi a0,zero,NOTHING
					call draw_tetromino ;remove the falling tetromino from the GSA
					call wait
					call get_input ;v0<- action required
					beq v0,zero,main_retrieve_input_no_input
						add a0,zero,v0
						call act ;move according to the button pressed
					main_retrieve_input_no_input:
					addi a0,zero,FALLING
					call draw_tetromino
					addi s1,s1,1 ;counter++
				jmpi main_retrieve_input_begin
				main_retrieve_input_end:
				addi a0,zero,NOTHING
				call draw_tetromino ;remove the falling tetromino from the GSA
				addi a0,zero,moveD
				call act
				add s2,zero,v0 #s2=v0 (can move down): 0:success, 1:failure
				addi a0,zero,FALLING
				call draw_tetromino
				beq s2,zero,main_move_one_step_down_until_collision_begin
			main_move_one_step_down_until_collision_end:
				
			addi a0,zero,PLACED
			call draw_tetromino ;add the falling tetromino in the GSA as a placed
			
			
			main_while_full_line_begin:
				call detect_full_line
				addi t0,zero,8
				beq v0,t0,main_while_full_line_end
					add a0,zero,v0
					call remove_full_line
					call increment_score
					call display_score
					jmpi main_while_full_line_begin
	
			main_while_full_line_end:
			
			call generate_tetromino
			addi a0,zero,OVERLAP
			call detect_collision
			addi t0,zero,NONE
			bne v0,t0,main_collision ;if v0!=None=>collision
			main_no_collision:
				addi a0,zero,FALLING
				call draw_tetromino
				jmpi main_until_overlaping_init_tetromino_begin
			main_collision:
			;GAME OVER

		main_until_overlaping_init_tetromino_end:
	
	jmpi main_init ;restart the game 
	main_end:

		ldw s2, 0(sp)
		ldw s1, 4(sp)
		ldw s0, 8(sp)
		ldw ra, 12(sp)
		addi sp, sp, 16
	
	break 


font_data:
    .word 0xFC  ; 0
    .word 0x60  ; 1
    .word 0xDA  ; 2
    .word 0xF2  ; 3
    .word 0x66  ; 4
    .word 0xB6  ; 5
    .word 0xBE  ; 6
    .word 0xE0  ; 7
    .word 0xFE  ; 8
    .word 0xF6  ; 9

C_N_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

C_N_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0xFFFFFFFF

C_E_X:
  .word 0x01
  .word 0x00
  .word 0x01

C_E_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

C_So_X:
  .word 0x01
  .word 0x00
  .word 0x01

C_So_Y:
  .word 0x00
  .word 0x01
  .word 0x01

C_W_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0xFFFFFFFF

C_W_Y:
  .word 0x00
  .word 0x01
  .word 0x01

B_N_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x02

B_N_Y:
  .word 0x00
  .word 0x00
  .word 0x00

B_E_X:
  .word 0x00
  .word 0x00
  .word 0x00

B_E_Y:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x02

B_So_X:
  .word 0xFFFFFFFE
  .word 0xFFFFFFFF
  .word 0x01

B_So_Y:
  .word 0x00
  .word 0x00
  .word 0x00

B_W_X:
  .word 0x00
  .word 0x00
  .word 0x00

B_W_Y:
  .word 0xFFFFFFFE
  .word 0xFFFFFFFF
  .word 0x01

T_N_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_N_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0x00

T_E_X:
  .word 0x00
  .word 0x01
  .word 0x00

T_E_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_So_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_So_Y:
  .word 0x00
  .word 0x01
  .word 0x00

T_W_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0x00

T_W_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_N_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_N_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

S_E_X:
  .word 0x00
  .word 0x01
  .word 0x01

S_E_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_So_X:
  .word 0x01
  .word 0x00
  .word 0xFFFFFFFF

S_So_Y:
  .word 0x00
  .word 0x01
  .word 0x01

S_W_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

S_W_Y:
  .word 0x01
  .word 0x00
  .word 0xFFFFFFFF

L_N_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x01

L_N_Y:
  .word 0x00
  .word 0x00
  .word 0xFFFFFFFF

L_E_X:
  .word 0x00
  .word 0x00
  .word 0x01

L_E_Y:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x01

L_So_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0xFFFFFFFF

L_So_Y:
  .word 0x00
  .word 0x00
  .word 0x01

L_W_X:
  .word 0x00
  .word 0x00
  .word 0xFFFFFFFF

L_W_Y:
  .word 0x01
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

DRAW_Ax:                        ; address of shape arrays, x axis
    .word C_N_X
    .word C_E_X
    .word C_So_X
    .word C_W_X
    .word B_N_X
    .word B_E_X
    .word B_So_X
    .word B_W_X
    .word T_N_X
    .word T_E_X
    .word T_So_X
    .word T_W_X
    .word S_N_X
    .word S_E_X
    .word S_So_X
    .word S_W_X
    .word L_N_X
    .word L_E_X
    .word L_So_X
    .word L_W_X

DRAW_Ay:                        ; address of shape arrays, y_axis
    .word C_N_Y
    .word C_E_Y
    .word C_So_Y
    .word C_W_Y
    .word B_N_Y
    .word B_E_Y
    .word B_So_Y
    .word B_W_Y
    .word T_N_Y
    .word T_E_Y
    .word T_So_Y
    .word T_W_Y
    .word S_N_Y
    .word S_E_Y
    .word S_So_Y
    .word S_W_Y
    .word L_N_Y
    .word L_E_Y
    .word L_So_Y
    .word L_W_Y





## PARTIE 3 ##


#Set all LEDS to 0
; BEGIN:clear_leds
clear_leds:
	stw zero,LEDS(zero)
	stw zero,LEDS+4(zero)
	stw zero,LEDS+8(zero)
	ret
; END:clear_leds


#Set one LED to 1
;Args:
	; -a0: the pixel’s x-coordinate
	; -a1: the pixel’s y-coordinate

; BEGIN:set_pixel
set_pixel: 
	;t0<- load concerned word at address LED+(a0/4)
	ldw t0,LEDS(a0)

	addi t2, zero,3; mask 00...011
	and t2,t2,a0; t2<-x%4
	slli t2,t2,3; t2<-8*(x%4)
	add t2,t2,a1; t2<-8*(x%4)+y

	; create a mask with single 1 at proper position  
	addi t1,zero,1
	sll t1, t1, t2

	; set the proper bit of t0 to 1
	or t0,t0,t1

	; replace the word with its new updated version in the RAM
	stw t0,LEDS(a0)
	ret 
; END:set_pixel


#add a delay of 0.2s
; BEGIN:wait
wait:

	addi t0,zero,0 ;initialize t0 to 0:counter
	addi t1,zero,1 ;initialize t1 to 2^20
	slli t1, t1, 20

	wait_loop:
		beq t0,t1,wait_end ; while counter!=2^20
		addi t0,t0,1 ;t0+=1
		jmpi wait_loop

	wait_end:
		ret
; END:wait




## PARTIE 4 ##


#This procedure gets as argument a location (x, y) and reports whether this location is inside the GSA or not
;Args:
	;a0: pixel’s x-coordinate
	;a1: pixel’s y-coordinate
;Return:
	;v0: 1 if out of GSA,0 if in GSA

; BEGIN:in_gsa
in_gsa:

	cmpgei t0, a0, X_LIMIT
	cmpgei t1, a1, Y_LIMIT  
	or t0,t0,t1
	cmplt t1,a0,zero
	or t0,t0,t1
	cmplt t1,a1,zero
	or v0,t0,t1
	ret
; END:in_gsa


# returns the value p of the element at location (x, y) in the GSA
;Args:
	;a0: pixel’s x-coordinate
	;a1: pixel’s y-coordinate
;Return:
	;v0: Element at location (x, y) in the GSA

; BEGIN:get_gsa
get_gsa:

	slli t0,a0,3; t0<-8*x
	add t0,t0,a1; t0<-8*x +y
	slli t0,t0,2

	ldw v0, GSA(t0); get word
	ret
; END:get_gsa


#sets the location (x, y) in the GSA to p
;Args:
	;a0: pixel’s x-coordinate
	;a1: pixel’s y-coordinate
	;a2: pixel’s value p

; BEGIN:set_gsa
set_gsa:

	slli t0,a0,3 ; t0<-8*x
	add t0,t0,a1 ; t0<-8*x +y
	slli t0,t0,2

	stw a2, GSA(t0)
	ret
; END:set_gsa




## Partie 5 ##


; take what is in the GSA and make the LED display consistent with it

; BEGIN:draw_gsa
draw_gsa:

	draw_gsa_init:
		addi sp,sp,-12
		stw ra, 0(sp)
		stw s0, 4(sp);x
		stw s1, 8(sp);y
		call clear_leds
		addi s0,zero,11;x<-11
	draw_gsa_loop_x:
		blt s0,zero,draw_gsa_loop_x_end;if x<0
		
		addi s1,zero,7;y<-7		
		draw_gsa_loop_y:
			blt s1,zero,draw_gsa_loop_y_end;if y<0
				add a0,s0,zero;a0<-x :arg for get_gsa
				add a1,s1,zero;a1<-y :arg for get_gsa
				call get_gsa;gsa (a0,a1) value goes in v0
				draw_gsa_if_nothing:
					addi t0,zero,NOTHING
					beq v0,t0,draw_gsa_if_nothing_skip;if nothing, pixel value stays 0
						add a0,s0,zero;a0<-x :arg for set_pixel
						add a1,s1,zero;a1<-y :arg for set_pixel
						call set_pixel ;set pixel(a0,a1)
				draw_gsa_if_nothing_skip:

				addi s1,s1,-1;y<-y-1
				jmpi draw_gsa_loop_y
		draw_gsa_loop_y_end:

		addi s0,s0,-1;x<-x-1
		jmpi draw_gsa_loop_x
	draw_gsa_loop_x_end:
		

	draw_gsa_end:

		ldw ra, 0(sp)
		ldw s0, 4(sp)
		ldw s1, 8(sp)
		addi sp,sp,12
		ret 
; END:draw_gsa





## PARTIE 6 ##


#Read TX, TY, Torientation, Ttype from the RAM and set the corresponding GSA elements of the tetromino to the correct value
;Args:
	;a0: GSA valuep, such that p∈{NOTHING, PLACED, FALLING}

; BEGIN:draw_tetromino
draw_tetromino:
	draw_tetromino_push: ;Push the elements in the stack
		addi sp, sp, -28
		stw ra, 24(sp)
		stw s0, 20(sp)
		stw s1, 16(sp)
		stw s2, 12(sp)
		stw s3, 8(sp)
		stw s4, 4(sp)
		stw s5, 0(sp)
	draw_tetromino_initialise:
		add s5, a0, zero ; s5= a0 (GSA value)
	draw_tetromino_load: ;Load every useful elements from the memory
		ldw s0, T_X(zero)
		ldw s1, T_Y(zero)
		ldw t0, T_type(zero)
		ldw t1, T_orientation(zero)
	draw_tetromino_load_shape_array:
		slli t0, t0, 4  	;t0 = 16*types
		slli t1, t1, 2  	;t1 = 4*orientation
		add t0, t0, t1 		;t0 = 16*types + 4*orientation
		ldw s2, DRAW_Ax(t0) ;s2 = x_offset_array_memory
		ldw s3, DRAW_Ay(t0) ;s3 = y_offset_array_memory
	draw_tetromino_set_corresponding_gsa:
		draw_tetromino_set_anchor_point:
			add a0, s0, zero
			add a1, s1, zero
			add a2, s5, zero
			call set_gsa
			addi s4, zero, 8 ; s4 = 8 (counter for the loop)
		draw_tetromino_set_other_points:
			blt s4, zero, draw_tetromino_fin
			add t0, s2, s4
			add t1, s3, s4
			ldw a0, 0(t0)
			add a0, a0, s0
			ldw a1, 0(t1)
			add a1, a1, s1
			add a2, s5, zero
			call set_gsa
			addi s4, s4, -4
			jmpi draw_tetromino_set_other_points
	draw_tetromino_fin:
		ldw s5, 0(sp)
		ldw s4, 4(sp)
		ldw s3, 8(sp)
		ldw s2, 12(sp)
		ldw s1, 16(sp)
		ldw s0, 20(sp)
		ldw ra, 24(sp)
		addi sp, sp, 28
		ret
; END:draw_tetromino




## PARTIE 7 ##


#Read a random number to choose a tetromino and set the corresponding tetromino in memory

; BEGIN:generate_tetromino
generate_tetromino:
	generate_tetromino_initialise:
		addi t0, zero, 5 ;t0=5 (constant to branch if >=5)
	generate_tetromino_generating_loop_start:
		ldw t1, RANDOM_NUM(zero)
		andi t1, t1, 0x7 ;t1%8 (t1 & 00...0111)
		bge t1, t0, generate_tetromino_generating_loop_start
	generate_tetromino_generating_loop_end:
		stw t1, T_type(zero)		; T_type= generatedType
		addi t1, zero, N
		stw t1, T_orientation(zero) ; T_orientation = N
		addi t1, zero, START_X
		stw t1, T_X(zero)			; T_X = 6
		addi t1, zero, START_Y
		stw t1, T_Y(zero)			; T_Y = 1

	ret
; END:generate_tetromino




## PARTIE 8 ##


#Detect colisions
;Args:
	;a0: value of collision we are inquiring about (W_COL, E-COL, So_COL, OVERLAP)
;Return:
	;v0: same as a0 if the collision exists indeed, NONE otherwise

; BEGIN:detect_collision
detect_collision:
	detect_collision_push: ;Push the elements in the stack
		addi sp, sp, -28
		stw ra, 24(sp)
		stw s0, 20(sp)
		stw s1, 16(sp)
		stw s2, 12(sp)
		stw s3, 8(sp)
		stw s4, 4(sp)
		stw s5, 0(sp)
	detect_collision_init:
		add s0, zero, a0   # s0 = colision-type
		add s1, zero, zero ; s1 = 0 (s1 will be the x offset)
		add s2, zero, zero ; s2 = 0 (s2 will be the y offset)
	detect_collision_switch_colision_type:
		addi t0, zero, W_COL ; t0 = W_COL
		beq s0, t0, detect_collision_W_col
		addi t0, zero, E_COL
		beq s0, t0, detect_collision_E_col
		addi t0, zero, So_COL
		beq s0, t0, detect_collision_So_col
		detect_collision_OVERLAP_col:
			jmpi detect_collision_end_switch ; No offset need to be added
		detect_collision_W_col:
			addi s1, s1, -1 ; x offset = -1
			jmpi detect_collision_end_switch
		detect_collision_E_col:
			addi s1, s1, 1  ; x offset = +1
			jmpi detect_collision_end_switch
		detect_collision_So_col:
			addi s2, s2, 1  ; y offset = +1
	detect_collision_end_switch:
	detect_collision_load: ;Load every useful elements from the memory
		ldw t0, T_X(zero)
		add s1, t0, s1 # s1 = x_offset + x_anchor (s1 is the x of the anchor with offset)
		ldw t0, T_Y(zero)
		add s2, t0, s2 # s2 = y_offset + y_anchor (s1 is the y of the anchor with offset)
		ldw t0, T_type(zero)
		ldw t1, T_orientation(zero)
	detect_collision_load_shape_array:
		slli t0, t0, 4  	;t0 = 16*types
		slli t1, t1, 2  	;t1 = 4*orientation
		add t0, t0, t1 		;t0 = 16*types + 4*orientation
		ldw s3, DRAW_Ax(t0) #s3 = x_offset_array_memory
		ldw s4, DRAW_Ay(t0) #s4 = y_offset_array_memory
	detect_collision_with_4_tetromino_location:
		detect_collision_anchor_point:
			add a0, s1, zero ; a0 = anchor_x
			add a1, s2, zero ; a1 = anchor_y
			call in_gsa
			bne v0, zero, detect_collision_collision_exists ; if in_gsa(anchor_x, anchor_y) != 0: go to collision
			add a0, s1, zero ; a0 = anchor_x
			add a1, s2, zero ; a1 = anchor_y
			call get_gsa
			addi t0, zero, PLACED 
			beq v0, t0, detect_collision_collision_exists 	; if get_gsa(anchor_x, anchor_y) == placed: go to collision
			addi s5, zero, 8 #s5 = counter for the loop (8)
		detect_collision_with_3_other_points:
			blt s5, zero, detect_collision_no_colision
			add t0, s3, s5
			add t1, s4, s5
			ldw a0, 0(t0)
			add a0, a0, s1 ;a0 = x_anchor + x_offset_collision + x_offset_type
			ldw a1, 0(t1)
			add a1, a1, s2 ;a1 = y_anchor + y_offset_collision + y_offset_type
			addi sp, sp, -8
			stw a0, 4(sp)
			stw a1, 0(sp)
			call in_gsa
			ldw a1, 0(sp)
			ldw a0, 4(sp)
			addi sp, sp, 8
			bne v0, zero, detect_collision_collision_exists ; if in_gsa(x, y) != 0: go to collision
			call get_gsa
			addi t0, zero, PLACED 
			beq v0, t0, detect_collision_collision_exists 	; if get_gsa(x, y) == placed: go to collision
			addi s5, s5, -4
			jmpi detect_collision_with_3_other_points
	detect_collision_no_colision:
		addi v0, zero, NONE
		jmpi detect_collision_fin
	detect_collision_collision_exists:
		add v0, zero, s0 ; return the collision_type
	detect_collision_fin:
		ldw s5, 0(sp)
		ldw s4, 4(sp)
		ldw s3, 8(sp)
		ldw s2, 12(sp)
		ldw s1, 16(sp)
		ldw s0, 20(sp)
		ldw ra, 24(sp)
		addi sp, sp, 28
		ret
; END:detect_collision




## PARTIE 9 ##


#Change the falling tetromino orientation according to rotation (rotR or rotL)
;Args:
	;a0: rotation_direction (rotR or rotL)

; BEGIN:rotate_tetromino 
rotate_tetromino:
	rotate_tetromino_init:
		addi t0,zero,rotR
		ldw t1, T_orientation(zero);t1<-current tetromnimo orientation
		beq a0,t0,rotate_right ;if a0=rotR
		
	rotate_left:
		addi t0, t1,-1 ;rotate_left is similar to substracting 1 to current orientation
		jmpi rotate_tetromino_end
	rotate_right:
		addi t0,t1,1 ;rotate_right is similar to adding 1 to current orientation
	rotate_tetromino_end:
		andi t0, t0,0x3 ; t0<-t0%4
		stw t0,T_orientation(zero)
		ret
; END:rotate_tetromino 




# Tries,to do the requested action with the tetromino, after having performed some collision detection,
# if it fails, the GSA doesn't change
;Args:
	;a0: value of the action required (moveD, moveL, moveR,rotL,rotR, reset)

;Return:
	;v0: 0 if action could be performed, 1 if action could not be performed

; BEGIN:act
act:
	act_init:
		addi sp, sp, -20
		stw ra, 16(sp)
		stw s0, 12(sp);T_X
		stw s1, 8(sp);T_Y
		stw s2, 4(sp);T_orientation
		stw s3, 0(sp);act direction
		
		ldw s0,T_X(zero);remember them until the end
		ldw s1,T_Y(zero)
		ldw s2,T_orientation(zero)
		add s3,zero,a0 ;direction of the act
		
		addi t0,zero,moveL
		beq a0,t0,act_moveL

		addi t0,zero,moveR
		beq a0,t0,act_moveR

		addi t0,zero,moveD
		beq a0,t0,act_moveD

		addi t0,zero,reset
		beq  a0,t0,act_reset

		addi t0,zero,rotL
		beq  a0,t0, act_rotate

		addi t0,zero,rotR
		beq  a0,t0, act_rotate

		jmpi act_success ; else: doing nothing is a success

	act_moveD:

		addi a0,zero,So_COL
		call detect_collision
		addi t0,zero,NONE
		bne v0,t0,act_failure; if collision
			addi t0,s1,1 ;T_Y+1
			stw t0,T_Y(zero); T_Y<-T_Y+1
			jmpi act_success
		
	act_moveL:
	
		addi a0,zero,W_COL
		call detect_collision
		addi t0,zero,NONE
		bne v0,t0,act_failure; if collision
			addi t0,s0,-1 ;T_X-1
			stw t0,T_X(zero); T_X<-T_X-1
			jmpi act_success
		

	act_moveR:
		addi a0,zero,E_COL
		call detect_collision
		addi t0,zero,NONE
		bne v0,t0,act_failure; if collision
			addi t0,s0,1
			stw t0,T_X(zero) ;T_X<-T_X+1
			jmpi act_success
		

	act_rotate:
	
	add a0,zero,s3 ;a0<-direction the act(rotL or rotR)
	call rotate_tetromino ;T_orientation is now modified
	addi a0,zero,OVERLAP 
	call detect_collision
	addi t0,zero,NONE 
	beq v0,t0,act_success ;if no collision(v0=a0 we sent), keep rotation 

		act_shift:
		addi t0,zero,6
		blt s0,t0,act_shift_right_once;if T_x<6 shift right towards center
		
			act_shift_left_once:
			addi t0,s0,-1 ;t0<-T_X-1
			stw t0,T_X(zero)
			addi a0,zero,OVERLAP
			call detect_collision
			addi t0,zero,NONE 
			beq v0,t0,act_success ;if no collision, keep rotation and shift
			jmpi act_shift_left_twice ; try to make it work with two shifts
			
			act_shift_left_twice:
			addi t0,s0,-2 ;t0<-T_X-2
			stw t0,T_X(zero)
			addi a0,zero,OVERLAP
			call detect_collision
			addi t0,zero,NONE 
			beq v0,t0,act_success ;if no collision, keep rotation and shift
			jmpi act_reset_to_initial ; if doesn't work, reset to initial

			act_shift_right_once:
			addi t0,s0,1 ;t0<-T_X+1
			stw t0,T_X(zero)
			addi a0,zero,OVERLAP
			call detect_collision
			addi t0,zero,NONE 
			beq v0,t0,act_success ;if no collision, keep rotation and shift
			jmpi act_shift_right_twice ; try to make it work with two shifts
			
			act_shift_right_twice:
			addi t0,s0,2 ;t0<-T_X+2
			stw t0,T_X(zero)
			addi a0,zero,OVERLAP
			call detect_collision
			addi t0,zero,NONE 
			beq v0,t0,act_success ;if no collision, keep rotation and shift
			jmpi act_reset_to_initial ; if doesn't work, reset to initial	

	act_success:
		add v0,zero,zero
		jmpi act_end	
	
	act_failure:
		addi v0,zero,1
		jmpi act_end
		
	act_reset_to_initial:;put back the initial value, rotation could not be executed
	
		stw s0,T_X(zero)
		stw s1,T_Y(zero)
		stw s2,T_orientation(zero)	
		jmpi act_failure
		
	act_reset:
		call reset_game
		jmpi act_success 
		 
	act_end:
		
		ldw s3, 0(sp)
		ldw s2, 4(sp)
		ldw s1, 8(sp)
		ldw s0, 12(sp)
		ldw ra, 16(sp)
		addi sp, sp, 20
		ret
; END:act 




## PARTIE 10 ##


#Read the action that needs to be done by reading the buttons in memory.
;Return:
	;v0: action corresponding to the pressed button or 0 if no button is pressed.

; BEGIN:get_input
get_input:
	ldw t0, BUTTONS+4(zero)
	addi t1, zero, 5 ;t1 = 5 : counter for the loop
    addi t2, zero, 1 ;t2 = 00...001: mask
	get_input_loop:
		beq t1, zero, get_input_loop_end
		and t3, t0, t2
		beq t3, t2, get_input_fin ; check if mask = (buttons AND mask) (we compute the AND in case many buttons are pressed simultaneously)
		slli t2, t2, 1 ; shift the mask left by 1
		addi t1, t1, -1 ; decrease the counter
		jmpi get_input_loop
	get_input_loop_end:
		add t2, zero, zero
	get_input_fin:
		add v0, t2, zero
		stw zero, BUTTONS+4(zero) ;Clear edgecapture in memory
		ret
; END:get_input




## PARTIE 11 ##


#Detect the first full line.
;Return:
	;v0: y-coordinate of the full line closest to the top of the game screen or 8, if there are no full lines.

; BEGIN:detect_full_line
detect_full_line:
	detect_full_line_push: ;Push the elements in the stack
		addi sp, sp, -24
		stw ra, 20(sp)
		stw s0, 16(sp)
		stw s1, 12(sp)
		stw s2, 8(sp)
		stw s3, 4(sp)
		stw s4, 0(sp)
	detect_full_line_initialise:
		addi s3, zero, PLACED  #s3 = 1 (only used to check if the element in the gsa is Placed)
		addi s4, zero, Y_LIMIT #s4 = 8 (only used to check if we are finished with our loop)
		add s0, zero, zero     #s0 = 0 : outer-counter (y coordinate)
	detect_full_line_outer_loop_start:
		beq s0, s4, detect_full_line_fin
		addi s1, zero, 11 	   #s1 = 11; inner-counter (x coordinate)
		detect_full_line_inner_loop_start:
			blt s1, zero, detect_full_line_fin ; If we traversed the entire line, it means that the whole line is equal to 1
			add a0, s1, zero
			add a1, s0, zero
			call get_gsa
			bne v0, s3, detect_full_line_inner_loop_end ; If there exists one cell in the gsa that is not equal to 1 (Placed), the line is not full
			addi s1 ,s1, -1
			jmpi detect_full_line_inner_loop_start
		detect_full_line_inner_loop_end:
		addi s0, s0, 1
		jmpi detect_full_line_outer_loop_start
	detect_full_line_fin:
		add v0, s0, zero

		ldw s4, 0(sp)
		ldw s3, 4(sp)
		ldw s2, 8(sp)
		ldw s1, 12(sp)
		ldw s0, 16(sp)
		ldw ra, 20(sp)
		addi sp, sp, 24
		ret
; END:detect_full_line




#Remove a whole line
;Args:
	;a0: y-coordinate of the full line to be removed

; BEGIN:remove_full_line
remove_full_line:
	remove_full_line_push: ;Push the elements in the stack
		addi sp, sp, -16
		stw ra, 12(sp)
		stw s0, 8(sp)
		stw s1, 4(sp)
		stw s2, 0(sp)
	remove_full_line_initialize:
		add s0, a0, zero #s0 = y-coordinate
	remove_full_line_blinking:
		addi a1, zero, NOTHING
		call set_gsa_line
		call draw_gsa ; switch the line off
		call wait
		add a0, s0, zero
		addi a1, zero, PLACED
		call set_gsa_line
		call draw_gsa ; switch the line on
		call wait
		add a0, s0, zero
		addi a1, zero, NOTHING
		call set_gsa_line
		call draw_gsa ; switch the line off (second time)
		call wait
		add a0, s0, zero
		addi a1, zero, PLACED
		call set_gsa_line
		call draw_gsa ; switch the line on (second time)
		call wait
		add a0, s0, zero
		addi a1, zero, NOTHING
		call set_gsa_line
		call draw_gsa ; switch the line off (third and last time)
	
	; Shift down every row between 0 and y-1 by one line
	remove_full_line_gsa_line_down_shifted:
		addi s1, s0, -1 	  #s1 = y-1 (it will be the y counter)
		remove_full_line_gsa_line_down_shifted_outer_loop_start:
			addi s2, zero, 11 #s2 = 11 (it will be the x counter)
			remove_full_line_gsa_line_down_shifted_inner_loop_start:	
				add a0, s2, zero
				add a1, s1, zero
				call get_gsa
				add a0, s2, zero
				addi a1, s1, 1
				add a2, v0, zero
				call set_gsa
				addi s2, s2, -1
				bge s2, zero, remove_full_line_gsa_line_down_shifted_inner_loop_start
			remove_full_line_gsa_line_down_shifted_inner_loop_end:
			addi s1, s1, -1
			bge s1, zero, remove_full_line_gsa_line_down_shifted_outer_loop_start
		remove_full_line_gsa_line_down_shifted_outer_loop_end:
	
	; Set the whole first line to 0
	remove_full_line_remove_first_row:
		addi s1, zero, 11 #s1 = 11 (x-counter)
		remove_full_line_remove_first_row_loop_start:
			add a0, s1, zero
			add a1, zero, zero
			addi a2, zero, NOTHING
			call set_gsa
			addi s1, s1, -1
			bge s1, zero, remove_full_line_remove_first_row_loop_start
		remove_full_line_remove_first_row_loop_end:					

	remove_full_line_fin:
		ldw s2, 0(sp)
		ldw s1, 4(sp)
		ldw s0, 8(sp)
		ldw ra, 12(sp)
		addi sp, sp, 16
		ret
; END:remove_full_line




## PARTIE 12 ##  


#Increase the score by one
; BEGIN:increment_score
increment_score:
	ldw t0, SCORE(zero)
	addi t1, zero, 9999 ;t1 = 9999
	increment_score_check_9999:
		beq  t0, t1, increment_score_fin ; if Score = 9999, keep it to this value
		addi t0, t0, 1
	increment_score_fin:
		stw t0, SCORE(zero)
		ret
; END:increment_score




#Show the score on the 7-segment display.
; BEGIN:display_score
display_score:
	ldw t0, SCORE(zero) #t0 = score

	display_score_zero_segment:
		display_score_zero_segment_initialize:
			addi t1, zero ,1000  #t1 = 1000 (constant)
			add t2, zero, zero #t2 = 0 (counter)
		display_score_zero_segment_find_number_of_thousands:
			blt t0, t1, display_score_zero_segment_set_segment
			addi t2, t2, 1
			sub t0, t0, t1
			jmpi display_score_zero_segment_find_number_of_thousands
		display_score_zero_segment_set_segment:
			slli t2, t2, 2 ; t2 = counter * 4
			ldw t2, font_data(t2) ; t2 = right value of the segment
			stw t2, SEVEN_SEGS(zero) ;Seven_segment[0] = t2

	display_score_first_segment:
		display_score_first_segment_initialize:
			addi t1, zero ,100  #t1 = 100 (constant)
			add t2, zero, zero #t2 = 0 (counter)
		display_score_first_segment_find_number_of_hundreds:
			blt t0, t1, display_score_first_segment_set_segment
			addi t2, t2, 1
			sub t0, t0, t1
			jmpi display_score_first_segment_find_number_of_hundreds
		display_score_first_segment_set_segment:
			slli t2, t2, 2 ; t2 = counter * 4
			ldw t2, font_data(t2) ; t2 = right value of the segment
			stw t2, SEVEN_SEGS+4(zero) ;Seven_segment[1] = t2

	display_score_second_segment:
		display_score_second_segment_initialize:
			addi t1, zero ,10  #t1 = 10 (constant)
			add t2, zero, zero #t2 = 0 (counter)
		display_score_second_segment_find_number_of_tens:
			blt t0, t1, display_score_second_segment_set_segment
			addi t2, t2, 1
			sub t0, t0, t1
			jmpi display_score_second_segment_find_number_of_tens
		display_score_second_segment_set_segment:
			slli t2, t2, 2 ; t2 = counter * 4
			ldw t2, font_data(t2) ; t2 = right value of the segment
			stw t2, SEVEN_SEGS+8(zero) ;Seven_segment[2] = t2
	
	display_score_third_segment:
			slli t0, t0, 2 ; t0 = reste * 4
			ldw t0, font_data(t0) ; t2 = right value of the segment
			stw t0, SEVEN_SEGS+12(zero) ;Seven_segment[3] = t2
		ret
; END:display_score




## PARTIE 13 ##

#Resets the game to its default state

; BEGIN:reset_game
reset_game:
	
	addi sp, sp, -4
	stw ra, 0(sp)
	
 	stw zero,SCORE(zero);reset score to 0
	call reset_gsa ;set all values in gsa to NOTHING
	call generate_tetromino ;generate a random tetromino with anchor point at (6,1)
	call display_score
	addi a0,zero,FALLING
	call draw_tetromino 
	call draw_gsa
	
	ldw ra,0(sp)
	addi sp, sp, 4
	ret
; END:reset_game



##################################################################################################
############################################ HELPERS #############################################
##################################################################################################

; BEGIN:helper


#sets all values in the gsa to NOTHING (0)
reset_gsa:
	reset_gsa_init:
		addi sp,sp,-12
		stw ra, 0(sp)
		stw s0, 4(sp);x
		stw s1, 8(sp);y
		addi s0,zero,11;x<-11
	reset_gsa_loop_x:
		blt s0,zero,reset_gsa_loop_x_end ;if x<0
		addi s1,zero,7;y<-7		
		reset_gsa_loop_y:
			blt s1,zero,reset_gsa_loop_y_end ;if y<0
				add a0,s0,zero;a0<-x :arg for set_gsa
				add a1,s1,zero;a1<-y :arg for set_gsa
				addi a2,zero,NOTHING ;a2<-type nothing:arg for set_gsa
				call set_gsa;gsa[a0,a1]<-a2 
				addi s1,s1,-1;y<-y-1
				jmpi reset_gsa_loop_y
		reset_gsa_loop_y_end:
		addi s0,s0,-1;x<-x-1
		jmpi reset_gsa_loop_x
	reset_gsa_loop_x_end:
	reset_gsa_end:
		ldw ra, 0(sp)
		ldw s0, 4(sp)
		ldw s1, 8(sp)
		addi sp,sp,12
		ret 

#Set a whole line in the gsa in PLACED or NOTHING
;Args:
	; -a0: line's y-coordinate
	; -a1: value to put in the gsa: 1 (PLACED) or 0 (NOTHING) 
set_gsa_line:
	set_gsa_line_push: ;Push the elements in the stack
		addi sp, sp, -16
		stw ra, 12(sp)
		stw s0, 8(sp)
		stw s1, 4(sp)
		stw s2, 0(sp)
	set_gsa_line_initialize:
		add s0, a0, zero  #s0 = y-coordinate
		addi s1, zero, 11 #s1 = 11 (counter for the x-coordinate)
		add s2, a1, zero  #s2 = 1 if on, 0 if off
		set_gsa_line_loop_start:
			add a0, s1, zero
			add a1, s0, zero
			add a2, s2, zero
			call set_gsa
			addi s1, s1, -1
			bge s1, zero, set_gsa_line_loop_start
		set_gsa_line_loop_end:
	set_gsa_line_fin:
		ldw s2, 0(sp)
		ldw s1, 4(sp)
		ldw s0, 8(sp)
		ldw ra, 12(sp)
		addi sp, sp, 16
		ret

#Switch a whole line on or off depending on the argument.
;Args:
	; -a0: line's y-coordinate
	; -a1: 1 (PLACED) if on, 0 (NOTHING) if off

switch_line:
	switch_line_push: ;Push the elements in the stack
		addi sp, sp, -16
		stw ra, 12(sp)
		stw s0, 8(sp)
		stw s1, 4(sp)
		stw s2, 0(sp)
	switch_line_initialize:
		add s0, a0, zero  #s0 = y-coordinate
		addi s1, zero, 11 #s1 = 11 (counter for the x-coordinate)
		add s2, a1, zero  #s2 = 1 if on, 0 if off
		switch_line_loop_start:
			add a0, s1, zero
			add a1, s0, zero
			beq s2, zero, switch_line_switch_off
			call set_pixel
			switch_line_finish_loop:
			addi s1, s1, -1
			bge s1, zero, switch_line_loop_start
		switch_line_loop_end:
		jmpi switch_line_fin
	switch_line_switch_off:
		call switch_off_pixel
		jmpi switch_line_finish_loop
	switch_line_fin:
		ldw s2, 0(sp)
		ldw s1, 4(sp)
		ldw s0, 8(sp)
		ldw ra, 12(sp)
		addi sp, sp, 16
		ret


#Set one LED to 0
;Args:
	; -a0: the pixel’s x-coordinate
	; -a1: the pixel’s y-coordinate

switch_off_pixel: 
	;t0<- load concerned word at address LED+(a0/4)
	ldw t0,LEDS(a0)
	switch_off_pixel_get_right_coordinate:
		addi t2, zero,3; mask 00...011
		and t2,t2,a0; t2<-x%4
		slli t2,t2,3; t2<-8*(x%4)
		add t2,t2,a1; t2<-8*(x%4)+y
	switch_off_pixel_create_mask:
		addi t1,zero,1
		sll t1, t1, t2
		nor t1, t1, zero ; create a mask with single 0 at proper position and all 1 elsewhere
	switch_off_pixel_replace_memory:
	and t0,t0,t1 ; set the proper bit of t0 to 0
	stw t0,LEDS(a0)	; replace the word with its new updated version in the RAM
	ret


########TEST################

test_template:
	addi sp,sp,-4
	stw ra,0(sp)		
 

	ldw ra,0(sp)
	addi sp,sp,4
	ret


test_part13:

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

	call increment_score
	call increment_score
	call increment_score

	call reset_game
	
	ldw ra,0(sp)
	addi sp,sp,4
	ret


; END:helper
