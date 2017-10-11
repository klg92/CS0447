.include "led_keypad.asm"
.include "syscalls.asm"

.data
	last_tick_time: .word 0
	wall: .ascii "7"
	#array of the board
	board: .byte 0:4096
	#the game map
	#NOTE: game map is SOLELY for PROGRAMMER CONVINIENCE
	game_map: .ascii "0000000000070000000700000000000000000000000000000000000000000055"
			 "0000000000070022200700000000000000000000000000000000000000000000"
			 "0000000000070022200700000000000000000000000000000000000000000000"
			 "0000000000070000000700000000000000000000000000000000000000000000"
			 "0000000000070000000700000000000000000000000000000000000000000000"
			 "0000000000070000000700000000000000000000000000000000000000000000"
			 "0000000000070000000700000000000000000000000000000000000000000000"
			 "0000000000070000000700000000000000000000000000000000000000000000"
			 "0000000000077555777700000000000000000000000000000000000000000000"
			 "0000000000000000000700000000000000000000000000000000000000000000"
			 "0000000000000000000100000000000000000000000000000000000000000000"
			 "0000000000000000000100000000000000000000000000000000000000000000"
			 "0000000000000000000100000000000000000000000000000000000000000000"
			 "0000000000000000000700000000000000000000000000000000000000000000"
			 "0000000000000000000700000000000000000000000000000000000000000000"
			 "0000000000000000000777777777777777777777777777777777777777777777"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000044"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000000000000000000000000000000000000000000000"
			 "0000000000000000000000777777777777777777777777777777777777777777"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000700000000000000000000000000000000000000000"
			 "0000000000000000000000400000000000000000000000000000000000000000"
			 "0000000000000000000000400000000000000000000000000000000000000000"
			 "0000000000000000000000400000000000000000000000000000000000000011"
			 
.text
.globl main
main:
	jal save_board
	jal draw_board
	jal save_board
	jal draw_keys
	#draw player to 0,0
	li $s0, 0
	li $s1, 0
	li $a0, 0
	li $a1, 0
	li $a2, COLOR_MAGENTA
	jal Display_SetLED
	jal draw_dragon
	
	
	#timing loop
	li $v0, sys_time
	syscall
	la $t0, last_tick_time
	sw $a0, 0($t0)

game_loop:
	#update game
	jal move_player
	jal roam_dragon
	li $a0, 0
	li $a1, 4
	li $v0, 42
	syscall
	li $a1, 3
	blt $a0, $a1, on
	off:
	jal draw_keys_off
	j done
	on:
	jal draw_keys
	done:
	jal wait_loop
	
#loop to keep time properly according to tick	
wait_loop:
	li $v0, sys_time
	syscall
	la $t0, last_tick_time
	lw $t0, 0($t0)
	sub $t1, $a0, $t0
	blt $t1, 100, wait_loop
	la $t0, last_tick_time
	sw $a0, 0($t0)
	j game_loop

#move player function. 
#IMPORTANT: $s0 is left-->right, $s1 is up-->down. $s2 is last key pressed
move_player:
	#enter function
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#get the last key pressed
	jal Input_GetKeypress
	
	#if it's not zero store it in $s2
	bgt $v0, $0, notzero
	
	finish:
	#compare the last key pressed $s2 to constants given in led_keypad.asm and branch to appropriate label
	li $v1, KEY_U
	beq $s2, $v1, up
	li $v1, KEY_D
	beq $s2, $v1, down
	li $v1, KEY_L
	beq $s2, $v1, left
	li $v1, KEY_R
	beq $s2, $v1, right
	
	
	up:
	#if we're at the top already don't bother moving up
	beq $s1, 0, end
	move $a0, $s1
	la $t7, 64
	subi $a0, $a0, 1
	mult $a0, $t7
	mflo $a0
	add $a0, $a0, $s0
	jal determine_collision
	jal save_board
	beq $v0, 1, end
	#color the old position black again
	move $a0, $s0
	move $a1, $s1
	li $a2, COLOR_BLACK
	jal Display_SetLED
	
	#modify register holding y coordinate
	addi $s1, $s1, -1
	
	#color the new position magenta to denote player
	move $a0, $s0
	move $a1, $s1
	li $a2, COLOR_MAGENTA
	jal Display_SetLED
	
	#end function
	j end
	
	down:
	#if we're at the bottom already don't bother moving down
	beq $s1, 63, end
	move $a0, $s1
	la $t7, 64
	addi $a0, $a0, 1
	mult $a0, $t7
	mflo $a0
	add $a0, $a0, $s0
	jal determine_collision
	jal save_board
	beq $v0, 1, end
	
	move $a0, $s0
	move $a1, $s1
	li $a2, COLOR_BLACK
	jal Display_SetLED
	
	#modify register holding y coordinate
	addi $s1, $s1, 1
	move $a0, $s0
	move $a1, $s1
	li $a2, COLOR_MAGENTA
	jal Display_SetLED
	j end
	
	left:
	#if we're at the leftmost already don't bother moving left
	beq $s0, 0, end
	move $a0, $s1
	la $t7, 64
	mult $a0, $t7
	mflo $a0
	add $a0, $a0, $s0
	subi $a0, $a0, 1
	jal determine_collision
	jal save_board
	beq $v0, 1, end
	
	move $a0, $s0
	move $a1, $s1
	li $a2, COLOR_BLACK 
	jal Display_SetLED
	
	#modify register holding x coordinate
	addi $s0, $s0, -1
	move $a0, $s0
	move $a1, $s1
	li $a2, COLOR_MAGENTA
	jal Display_SetLED
	j end
	
	right:
	#if we're at the rightmost already don't bother moving right
	beq $s0, 63, end
	move $a0, $s1
	la $t7, 64
	mult $a0, $t7
	mflo $a0
	add $a0, $a0, $s0
	addi $a0, $a0, 1
	jal determine_collision
	jal save_board
	beq $v0, 1, end
	
	move $a0, $s0
	move $a1, $s1
	li $a2, COLOR_BLACK 
	jal Display_SetLED
	
	#modify register holding x coordinate
	addi $s0, $s0, 1
	move $a0, $s0
	move $a1, $s1
	li $a2, COLOR_MAGENTA
	jal Display_SetLED
	j end
	
	#store last key pressed in $s2 so the person keeps moving when nothing is pressed
	notzero:
	move $s2, $v0
	j finish
	
	#exit the function
	end:
	jal check_dragon_collision
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#save individual bytes to wall colors	
save_board:
	#enter the function
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#put board's contents into t0
	la $t0, board
	#make all these bytes white
	li $t1, COLOR_WHITE
	li $t2, COLOR_GREEN
	li $t3, COLOR_BLUE
	li $t4, COLOR_RED
	li $t5, COLOR_ORANGE
	sb $t1, 11($t0)
	sb $t1, 19($t0)
	sb $t1, 75($t0)
	
	#chest part 1
	sb $t5, 78($t0)
	sb $t5, 79($t0)
	sb $t5, 80($t0)
	
	sb $t1, 83($t0)
	sb $t1, 139($t0)
	
	#chest part 2
	sb $t5, 142($t0)
	sb $t5, 143($t0)
	sb $t5, 144($t0)
	
	sb $t1, 147($t0)
	sb $t1, 203($t0)
	sb $t1, 211($t0)
	sb $t1, 267($t0)
	sb $t1, 275($t0)
	sb $t1, 331($t0)
	sb $t1, 339($t0)
	sb $t1, 395($t0)
	sb $t1, 403($t0)
	sb $t1, 459($t0)
	sb $t1, 467($t0)
	sb $t1, 523($t0)
	sb $t1, 524($t0)
	
	#create blue door
	sb $t3, 525($t0)
	sb $t3, 526($t0)
	sb $t3, 527($t0)
	
	#resume white wall creation
	sb $t1, 528($t0)
	sb $t1, 529($t0)
	sb $t1, 530($t0)
	sb $t1, 531($t0)
	sb $t1, 595($t0)
	
	#create red door
	sb $t4, 659($t0)
	sb $t4, 723($t0)
	sb $t4, 787($t0)
	
	#white walls again
	sb $t1, 851($t0)
	sb $t1, 915($t0)
	sb $t1, 979($t0)
	sb $t1, 980($t0)
	sb $t1, 981($t0)
	sb $t1, 982($t0)
	sb $t1, 983($t0)
	sb $t1, 984($t0)
	sb $t1, 985($t0)
	sb $t1, 986($t0)
	
	sb $t1, 987($t0)
	sb $t1, 988($t0)
	sb $t1, 989($t0)
	sb $t1, 990($t0)
	sb $t1, 991($t0)
	sb $t1, 992($t0)
	sb $t1, 993($t0)
	sb $t1, 994($t0)
	sb $t1, 995($t0)
	sb $t1, 996($t0)
	sb $t1, 997($t0)
	sb $t1, 998($t0)
	sb $t1, 999($t0)
	sb $t1, 1000($t0)
	sb $t1, 1001($t0)
	sb $t1, 1002($t0)
	sb $t1, 1003($t0)
	sb $t1, 1004($t0)
	sb $t1, 1005($t0)
	sb $t1, 1006($t0)
	sb $t1, 1007($t0)
	sb $t1, 1008($t0)
	sb $t1, 1009($t0)
	sb $t1, 1010($t0)
	sb $t1, 1011($t0)
	sb $t1, 1012($t0)
	sb $t1, 1013($t0)
	sb $t1, 1014($t0)
	sb $t1, 1015($t0)
	sb $t1, 1016($t0)
	sb $t1, 1017($t0)
	sb $t1, 1018($t0)
	sb $t1, 1019($t0)
	sb $t1, 1020($t0)
	sb $t1, 1021($t0)
	sb $t1, 1022($t0)
	sb $t1, 1023($t0)
	sb $t1, 2390($t0)
	sb $t1, 2391($t0)
	sb $t1, 2392($t0)
	sb $t1, 2393($t0)
	sb $t1, 2394($t0)
	sb $t1, 2395($t0)
	sb $t1, 2396($t0)
	sb $t1, 2397($t0)
	sb $t1, 2398($t0)
	sb $t1, 2399($t0)
	sb $t1, 2400($t0)
	sb $t1, 2401($t0)
	sb $t1, 2402($t0)
	sb $t1, 2403($t0)
	sb $t1, 2404($t0)
	sb $t1, 2405($t0)
	sb $t1, 2406($t0)
	sb $t1, 2407($t0)
	sb $t1, 2408($t0)
	sb $t1, 2409($t0)
	sb $t1, 2410($t0)
	sb $t1, 2411($t0)
	sb $t1, 2412($t0)
	sb $t1, 2413($t0)
	sb $t1, 2414($t0)
	sb $t1, 2415($t0)
	sb $t1, 2416($t0)
	sb $t1, 2417($t0)
	sb $t1, 2418($t0)
	sb $t1, 2419($t0)
	sb $t1, 2420($t0)
	sb $t1, 2421($t0)
	sb $t1, 2422($t0)
	sb $t1, 2423($t0)
	sb $t1, 2424($t0)
	sb $t1, 2425($t0)
	sb $t1, 2426($t0)
	sb $t1, 2427($t0)
	sb $t1, 2428($t0)
	sb $t1, 2429($t0)
	sb $t1, 2430($t0)
	sb $t1, 2431($t0)
	sb $t1, 2454($t0)
	sb $t1, 2518($t0)
	sb $t1, 2582($t0)
	sb $t1, 2646($t0)
	sb $t1, 2710($t0)
	sb $t1, 2774($t0)
	sb $t1, 2838($t0)
	sb $t1, 2902($t0)
	sb $t1, 2966($t0)
	sb $t1, 3030($t0)
	sb $t1, 3094($t0)
	sb $t1, 3158($t0)
	sb $t1, 3222($t0)
	sb $t1, 3286($t0)
	sb $t1, 3350($t0)
	sb $t1, 3414($t0)
	sb $t1, 3478($t0)
	sb $t1, 3414($t0)
	sb $t1, 3542($t0)
	sb $t1, 3606($t0)
	sb $t1, 3670($t0)
	sb $t1, 3734($t0)
	sb $t1, 3798($t0)
	sb $t1, 3862($t0)
	
	#create green door
	sb $t2, 3926($t0)
	sb $t2, 3990($t0)
	sb $t2, 4054($t0)
	#exit the function
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
#loops through board array 4096 times and sets proper led to value inside each byte
draw_board:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $s0, 0 #s0: y
	la $s3, board
	forY:
	li $s1, 0 #s1: x
	forX:
	move $a0, $s1
	move $a1, $s0
	#load first byte
	lb $a2, 0($s3)
	jal Display_SetLED
	#make the second byte the first byte for the loop to c
	addi $s3, $s3, 1
	addi $s1, $s1, 1
	blt $s1, 64, forX
	addi $s0, $s0, 1
	blt $s0, 64, forY
	la $s3, board
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

#determine if the player will collide into something
determine_collision:
	#enter the function
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#a0 contains the coordinate of the space the player is going to move to
	#s3 contains the board, add allows us to go to the a0-th byte in the board
	add $s3, $s3, $a0
	#load the a0-th byte and compare it's contents to a wall
	jal determine_key
	lb $t1, 0($s3)
	la $a0, ($t1)
	beq $t1, COLOR_WHITE, wall2
	beq $t1, COLOR_GREEN, green_door
	beq $t1, COLOR_BLUE, blue_door
	beq $t1, COLOR_RED, red_door
	beq $t1, COLOR_ORANGE, end_game
	j none
	
	#modify v0 to return whether we collided into something or not
	wall2:
	li $v0, 1
	j end2
	
	
	#EXPLANATION: the $s7 register will have a number added to it whenever a key is picked up. green=3, blue =4, red=5.
	#if s7 is not one of the proper numbers for each color, treat it as a wall.
	green_door:
	blt $s7, 3, wall2
	beq $s7, 4, wall2
	beq $s7, 5, wall2
	beq $s7, 6, wall2
	beq $s7, 9, wall2
	beq $s7, 10, wall2
	beq $s7, 11, wall2
	bgt $s7, 12, wall2
	jal remove_green_door
	j end2
	
	blue_door: 
	blt $s7, 4, wall2
	beq $s7, 5, wall2
	beq $s7, 6, wall2
	beq $s7, 8, wall2
	beq $s7, 10, wall2
	beq $s7, 11, wall2
	bgt $s7, 12, wall2
	jal remove_blue_door
	j end2
	
	red_door:
	blt $s7, 5, wall2
	beq $s7, 6, wall2
	beq $s7, 7, wall2
	beq $s7, 10, wall2
	beq $s7, 11, wall2
	bgt $s7, 12, wall2
	jal remove_red_door
	j end2
	
	none:
	li $v0, 0
	j end2
	
	#exit the function and reset $s3 to the proper contents of the board
	end2:
	la $s3, board
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
draw_keys:
	#enter function
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	#don't draw it again if we picked it up
	beq $s7, 5, next
	beq $s7, 8, next
	beq $s7, 9, next
	beq $s7, 12, next
	#draw the keys, straightforward code
	li $a0, 63
	li $a1, 63
	li $a2, COLOR_RED
	jal Display_SetLED
	li $a0, 62
	li $a1, 63
	li $a2, COLOR_RED
	jal Display_SetLED
	next:
	#don't draw it again if we picked it up
	beq $s7, 3, next2
	beq $s7, 7, next2
	beq $s7, 8, next2
	beq $s7, 12, next2
	li $a0, 63
	li $a1, 30
	li $a2, COLOR_GREEN
	jal Display_SetLED
	li $a0, 62
	jal Display_SetLED
	next2:
	#don't draw it again if we picked it up
	beq $s7, 4, end123456
	beq $s7, 7, end123456
	beq $s7, 9, end123456
	beq $s7, 12, end123456
	li $a0, 63
	li $a1, 0
	li $a2, COLOR_BLUE
	jal Display_SetLED
	li $a0, 62
	jal Display_SetLED
	
	#exit function
	end123456:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

determine_key:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	blt $s0, 62, end3
	#branch to respective code for each key 
	beq $s1, 63, red_key
	beq $s1, 30, green_key
	beq $s1, 0, blue_key
	j end3
		
	red_key:
	#make sure we don't add twice
	beq $s7, 5, end3
	beq $s7, 8, end3
	beq $s7, 9, end3
	beq $s7, 12, end3
	
	#color positions of key black again
	addi $s7, $s7, 5
	li $a0, 63
	li $a1, 63
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a0, 62
	li $a1, 63
	li $a2, COLOR_BLACK
	jal Display_SetLED
	j end3
	
	green_key:
	#make sure we don't add twice
	beq $s7, 3, end3
	beq $s7, 7, end3
	beq $s7, 8, end3
	beq $s7, 12, end3
	#key positions black again
	addi $s7, $s7, 3
	li $a0, 63
	li $a1, 30
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a0, 62
	jal Display_SetLED
	j end3
	
	blue_key:
	#make sure we don't add twice
	beq $s7, 4, end3
	beq $s7, 7, end3
	beq $s7, 9, end3
	beq $s7, 12, end3
	#make key position black
	addi $s7, $s7, 4
	li $a0, 63
	li $a1, 0
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a0, 62
	jal Display_SetLED
	j end3
	
	end3:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

remove_green_door:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t1, COLOR_BLACK
	la $t0, board
	
	#change bytes with door back to 0
	sb $t1, 3926($t0)
	sb $t1, 3990($t0)
	sb $t1, 4054($t0)
	
	#color respective places black
	li $a0, 22
	li $a1, 61
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a1, 62
	jal Display_SetLED
	li $a1, 63
	jal Display_SetLED
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
remove_red_door:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t1, COLOR_BLACK
	la $t0, board
	
	#change bytes with door back to 0
	sb $t1, 659($t0)
	sb $t1, 723($t0)
	sb $t1, 787($t0)
	
	#color respective places black
	li $a0, 19
	li $a1, 10
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a1, 11
	jal Display_SetLED
	li $a1, 12
	jal Display_SetLED
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
remove_blue_door:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t1, COLOR_BLACK
	la $t0, board
	
	#change bytes with door back to 0
	sb $t1, 525($t0)
	sb $t1, 526($t0)
	sb $t1, 527($t0)
	
	#color respective places black
	li $a0, 13
	li $a1, 8
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a0, 14
	jal Display_SetLED
	li $a0, 15 
	jal Display_SetLED
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

draw_dragon:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#draw the 4 spaces of the dragon's starting position
	li $a0, 33
	li $a1, 55
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	
	#store the first coordinate's x and y in these registers for collisio
	li $s4, 33
	li $s5, 55
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
roam_dragon:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a0, 0
	li $a1, 4
	li $v0, 42
	syscall
	
	beq $a0, 0, down2
	beq $a0, 1, left2
	beq $a0, 2, right2 
	beq $a0, 3, up2
	
	up2:
	#make sure we don't go off the screen
	beq $s5, 0, end4
	#collision
	addi $s5, $s5, -1
	jal dragon_collision
	addi $s5, $s5, 1
	beq $v0, 1, end4
	#color in old spaces black again
	move $a0, $s4
	move $a1, $s5
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_BLACK
	jal Display_FillRect
	
	#color in new spaces yellows
	addi $s5, $s5, -1
	move $a0, $s4
	move $a1, $s5
	la $a2, 2
	la $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	j end4
	
	down2:
	#don't go off screen
	beq $s5, 62, end4
	#collision
	addi $s5, $s5, 1
	jal dragon_collision
	addi $s5, $s5, -1
	beq $v0, 1, end4
	#old spaces black
	move $a0, $s4
	move $a1, $s5
	la $a2, 2
	la $a3, 2
	li $v0, COLOR_BLACK
	jal Display_FillRect
	
	#new spaces yellow
	addi $s5, $s5, 1
	move $a0, $s4
	move $a1, $s5
	la $a2, 2
	la $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	j end4
	
	left2:
	#don't go off screen
	beq $s4, 0, end4
	#collision
	addi $s4, $s4, -1
	jal dragon_collision
	addi $s4, $s4, 1
	beq $v0, 1, end4
	#old spaces black
	move $a0, $s4
	move $a1, $s5
	la $a2, 2
	la $a3, 2
	li $v0, COLOR_BLACK
	jal Display_FillRect
	
	#new spaces yellow
	addi $s4, $s4, -1
	move $a0, $s4
	move $a1, $s5
	la $a2, 2
	la $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	j end4
	
	right2:
	#don't go off screen
	beq $s4, 62, end4
	#collision
	addi $s4, $s4, 1
	jal dragon_collision
	addi $s4, $s4, -1
	beq $v0, 1, end4
	#old spaces black
	move $a0, $s4
	move $a1, $s5
	la $a2, 2
	la $a3, 2
	li $v0, COLOR_BLACK
	jal Display_FillRect
	
	#new spaces yellow
	addi $s4, $s4, 1
	move $a0, $s4
	move $a1, $s5
	la $a2, 2
	la $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	j end4
	
	end4:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#check if the dragon collides with non-player object when going up	
dragon_collision:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#check if the first two coordinates will collide
	li $v0, 0
	move $a0, $s5
	la $t7, 64
	mult $a0, $t7
	mflo $a0
	add $a0, $a0, $s4
	add $s3, $s3, $a0
	lb $t1, 0($s3)
	#don't run over keys
	beq $a0, 63, yes
	beq $a0, 62, yes
	beq $a0, 4095, yes
	beq $a0, 4094, yes
	beq $a0, 1983, yes
	beq $a0, 1984, yes
	#stop if it's not empty
	beq $t1, COLOR_WHITE, yes
	beq $t1, COLOR_GREEN, yes
	beq $t1, COLOR_BLUE, yes
	beq $t1, COLOR_RED, yes
	beq $t1, COLOR_ORANGE, yes
	la $s3, board
	
	move $a0, $s5
	addi $a0, $a0, 1
	la $t7, 64
	mult $a0, $t7
	mflo $a0
	add $a0, $a0, $s4
	add $s3, $s3, $a0
	lb $t1, 0($s3)
	beq $t1, COLOR_WHITE, yes
	beq $t1, COLOR_GREEN, yes
	beq $t1, COLOR_BLUE, yes
	beq $t1, COLOR_RED, yes
	beq $t1, COLOR_ORANGE, yes
	la $s3, board
	
	#same with next two
	move $a0, $s5
	la $t7, 64
	mult $a0, $t7
	mflo $a0
	add $a0, $a0, $s4
	addi $a0, $a0, 1
	add $s3, $s3, $a0
	lb $t1, 0($s3)
	beq $t1, COLOR_WHITE, yes
	beq $t1, COLOR_GREEN, yes
	beq $t1, COLOR_BLUE, yes
	beq $t1, COLOR_RED, yes
	beq $t1, COLOR_ORANGE, yes
	la $s3, board
	
	move $a0, $s5
	addi $a0, $a0, 1
	la $t7, 64
	mult $a0, $t7
	mflo $a0
	add $a0, $a0, $s4
	addi $a0, $a0, 1
	add $s3, $s3, $a0
	lb $t1, 0($s3)
	beq $t1, COLOR_WHITE, yes
	beq $t1, COLOR_GREEN, yes
	beq $t1, COLOR_BLUE, yes
	beq $t1, COLOR_RED, yes
	beq $t1, COLOR_ORANGE, yes
	la $s3, board
	
	j none2
	yes:
	li $v0, 1
	j end1234
	
	none2:
	li $v0, 0
	j end1234
	
	end1234:
	la $s3, board
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#check if the player runs into the dragon
check_dragon_collision:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t0, ($s4)
	la $t1, ($s5)
	#don't end game if player position isn't same as dragon position
	blt $s0, $t0, end2222
	blt $s1, $t1, end2222
	addi $t0, $t0, 1
	bgt $s0, $t0, end2222
	addi $t1, $t1, 1
	bgt $s1, $t1, end2222
	#end game if player position is same as dragon position
	j end_game
	#return to normal if player position isn't same as dragon position.
	end2222:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#turn off the keys to flash	
draw_keys_off:
	#enter function
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#draw the keys, straightforward code
	li $a0, 63
	li $a1, 63
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a0, 62
	li $a1, 63
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a0, 63
	li $a1, 30
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a0, 62
	jal Display_SetLED
	li $a0, 63
	li $a1, 0
	li $a2, COLOR_BLACK
	jal Display_SetLED
	li $a0, 62
	jal Display_SetLED
	
	#exit function
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

end_game:
	#draw all the spaces black
	li $s0, 0 #s0: y
	forY2:
	li $s1, 0 #s1: x
	forX2:
	move $a0, $s1
	move $a1, $s0
	li $a2, COLOR_BLACK
	jal Display_SetLED
	addi $s1, $s1, 1
	blt $s1, 64, forX2
	addi $s0, $s0, 1
	blt $s0, 64, forY2
	
	#end program
	li $v0, 10
	syscall
