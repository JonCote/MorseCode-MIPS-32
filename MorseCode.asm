.text


main:	



# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# Jonathan Cote V00962634


	## Test code that calls procedure for part A
	#jal save_our_souls

	## morse_flash test for part B
	# addi $a0, $zero, 0x42   # dot dot dash dot
	# jal morse_flash
	 
	# addi $a0, $zero, 0xff   # space
	# jal morse_flash
	
	## morse_flash test for part B
	# addi $a0, $zero, 0x37   # dash dash dash
	# jal morse_flash
		
	## morse_flash test for part B
	# addi $a0, $zero, 0x32  	# dot dash dot
	# jal morse_flash
			
	## morse_flash test for part B
	# addi $a0, $zero, 0x11   # dash
	# jal morse_flash	
	
	# flash_message test for part C
	# la $a0, test_buffer
	# jal flash_message
	
	# letter_to_code test for part D
	# the letter 'P' is properly encoded as 0x46.
	# addi $a0, $zero, 'P'
	# jal letter_to_code
	
	# letter_to_code test for part D
	# the letter 'A' is properly encoded as 0x21
	# addi $a0, $zero, 'A'
	# jal letter_to_code
	
	# letter_to_code test for part D
	# the space' is properly encoded as 0xff
	# addi $a0, $zero, ' '
	# jal letter_to_code
	
	# encode_message test for part E
	# The outcome of the procedure is here
	# immediately used by flash_message
	# la $a0, message07
	# la $a1, buffer01
	# jal encode_message
	# la $a0, buffer01
	# jal flash_message
	
	
	# Proper exit from the program.
	addi $v0, $zero, 10
	syscall

	
	
###########
# PROCEDURE: save_our_souls
# Display SOS in morse code
# 
# Stack Frame:
# | $s2 | 12
# | $s1 | 8
# | $s0 | 4
# | $ra | 0
# ------------
# $s2 hold index for control loop 
# $s1 index for dot/dash loop
# $s0 stop point for dot/dash loop

save_our_souls:  # morse code for SOS: Dot Dot Dot Dash Dash Dash Dot Dot Dot
	addi $sp, $sp, -16
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	or $s0, $zero, 3		# range
	or $s2, $zero, $zero		# controller index

control:				# controls if 3 dots, 3 dashes, or wrap up happens 
	or $s1, $zero, $zero 		# index
	beq $s2, 0, dotloop
	beq $s2, 1, dashloop
	beq $s2, 2, dotloop
	beq $s2, 3, sosdone

sagmentcomplete:			# increments controller index so next process can run
	addi $s2, $s2, 1
	b control


dotloop:				
	beq $s0, $s1, sagmentcomplete
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	addi $s1, $s1, 1
	b dotloop


dashloop:
	beq $s0, $s1, sagmentcomplete	
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	addi $s1, $s1, 1
	b dashloop
			
sosdone:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra


# PROCEDURE: Morse_flash
# input: $a0 holding one byte to be converted to morse code
# Purpose: flash morse code of input
#
# Stack Frame:
# | $s3 | 16
# | $s2 | 12
# | $s1 | 8
# | $s0 | 4
# | $ra | 0
# ------------
# $s3 holds mask for low nybble
# $s2 flash counter 
# $s1 hold low nybble
# $s0 holds high nybble
morse_flash:
	addi $sp, $sp, -20
	sw $s3, 16($sp)
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)

	# number of flashes is the value of high nybble (4 most significant bits)
	# dot or dash (1 for dash 0 for dot) low nybble (4 least significant bits)
	# start from most significant bit in low nybble

	#check if 0xff
	beq $a0, 0xff, flash_space
	
	# get high nybble value
	and $s0, $a0, 0xf0			# extract most significant 4 bits to determine high nybble
	srl $s0, $s0, 4				# shift so value is easier to analyse
	beq $s0, $zero, flash_done		# if 0 means no flashes so finish
	
	# get low nybble value
	and $s1, $a0, 0x0f			# extract least significant 4 bits to determine low nybble
	
	or $s2, $zero, $zero			
	or $t0, $zero, 1
	or $s3, $zero, 1
	
flash_mask_maker:				# generates mask dependend on high nybble value.
	beq $s0, $t0, flash_control
	
	sll $s3, $s3, 1
	addi $t0, $t0, 1
	b flash_mask_maker


flash_control:					# determine if dot or dash then go to that area
	beq $s2, $s0, flash_done
	and $t0, $s1, $s3
	
	beq $t0, 0, flash_dot
	beq $t0, $s3, flash_dash
	
		
				
flash_sagmentcomplete:				# shift low nybble left for masking, keeps count of flashes performed
	sll $s1, $s1, 1
	addi $s2, $s2, 1
	b flash_control



flash_dot:						# flash a dot then go to flash_sagmentcomplete
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	b flash_sagmentcomplete


flash_dash:						# flash a dash then go to flash_sagmentcomplete
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	b flash_sagmentcomplete


flash_space:						# special case: display off for 3 calls of delay_long if 0xff
	jal delay_long
	jal delay_long
	jal delay_long
	b flash_done

flash_done:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra


###########
# PROCEDURE: flash_message
# input: $a0 holding data-memory address
# Purpose: flash morse code message at data address
#
# Stack Frame:
# | $s1 | 8
# | $s0 | 4
# | $ra | 0
# ------------
# $s1 holds address for data
# $s0 holds bit from address to be flashed
flash_message:
	addi $sp, $sp, -12
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	or $s1, $a0, $zero
	
msg_loop:
	lbu $s0, 0($s1)
	beq $s0, 0, msg_done
	or $a0, $zero, $s0			
	jal morse_flash
	addi $s1, $s1, 1
	b msg_loop


msg_done:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
	
###########
# PROCEDURE: letter_to_code
# input: $a0 holding data-memory address
# return: morse one-byte equivalent stored in $v0
# Purpose: convert letter to its morse one-byte equivalent
letter_to_code:
	# Take $a0 holding a ASCII letter UPPER CASE ONLY
	# Convert letter from $a0 to its 8 bit representation using data provided in codes section
	# Codes are aligned with 8 byte boundary
	
	beq $a0, ' ', ltc_space			# deal with space input
	
	subi $t0, $a0, 65			# get letter offset
	la $t1, codes				# load codes data address
	
	mul $t0, $t0, 8				# shift amount to get to letter location
	add $t1, $t1, $t0			# change address to equal letter by adding the offset
	addi $t1, $t1, 1			# deal with letter in first 8 bits
	
	or $t3, $zero, $zero			# big nybble
	or $t5, $zero, $zero			# little nybble
	or $t4, $zero, 1			# mask for little nybble
	
ltc_loop:
	lb $t2, 0($t1)
	beq $t2, $zero, ltc_done
	addi $t3, $t3, 16
	beq $t2, '-', ltc_dash
	beq $t2, '.', ltc_dot
	b ltc_loop
	
ltc_dash:
	sll $t5, $t5, 1
	or $t5, $t5, $t4
	addi $t1, $t1, 1 
	b ltc_loop

ltc_dot:
	sll $t5, $t5, 1
	addi $t1, $t1, 1
	b ltc_loop

ltc_space:				
	or $t3, $zero, 0xff
	or $t5, $zero, $zero
	b ltc_done
	
ltc_done:
	or $v0, $t3, $t5	
	jr $ra	


###########
# PROCEDURE: encode_message
# input: $a0 holding data-memory address of message
#	 $a1 holding data-memory address for encoded message
# Purpose: encode message to its set of morse one-byte equivalents 
#
# Stack Frame:
# | $s1 | 8
# | $s0 | 4
# | $ra | 0
# ------------
# $s1 holds address for encoded message
# $s0 holds message address
encode_message:
	addi $sp, $sp, -12
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)

	# msg to encode in $a0, register to save encoding in $a1
	
	or $s0, $a0, $zero		
	or $s1, $a1, $zero		
	

enc_loop:
	lb $t0, 0($s0)
	beq $t0, $zero, enc_done
	or $a0, $zero, $t0
	jal letter_to_code
	sb $v0, 0($s1)
	addi $s1, $s1, 1
	addi $s0, $s0, 1
	
	b enc_loop

	
enc_done:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	jr $ra

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

#############################################
# DO NOT MODIFY ANY OF THE CODE / LINES BELOW

###########
# PROCEDURE
seven_segment_on:
	la $t1, 0xffff0010     # location of bits for right digit
	addi $t2, $zero, 0xff  # All bits in byte are set, turning on all segments
	sb $t2, 0($t1)         # "Make it so!"
	jr $31


###########
# PROCEDURE
seven_segment_off:
	la $t1, 0xffff0010	# location of bits for right digit
	sb $zero, 0($t1)	# All bits in byte are unset, turning off all segments
	jr $31			# "Make it so!"
	

###########
# PROCEDURE
delay_long:
	add $sp, $sp, -4	# Reserve 
	sw $a0, 0($sp)
	addi $a0, $zero, 600
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31

	
###########
# PROCEDURE			
delay_short:
	add $sp, $sp, -4
	sw $a0, 0($sp)
	addi $a0, $zero, 200
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31




#############
# DATA MEMORY
.data
codes:
	.byte 'A', '.', '-', 0, 0, 0, 0, 0
	.byte 'B', '-', '.', '.', '.', 0, 0, 0
	.byte 'C', '-', '.', '-', '.', 0, 0, 0
	.byte 'D', '-', '.', '.', 0, 0, 0, 0
	.byte 'E', '.', 0, 0, 0, 0, 0, 0
	.byte 'F', '.', '.', '-', '.', 0, 0, 0
	.byte 'G', '-', '-', '.', 0, 0, 0, 0
	.byte 'H', '.', '.', '.', '.', 0, 0, 0
	.byte 'I', '.', '.', 0, 0, 0, 0, 0
	.byte 'J', '.', '-', '-', '-', 0, 0, 0
	.byte 'K', '-', '.', '-', 0, 0, 0, 0
	.byte 'L', '.', '-', '.', '.', 0, 0, 0
	.byte 'M', '-', '-', 0, 0, 0, 0, 0
	.byte 'N', '-', '.', 0, 0, 0, 0, 0
	.byte 'O', '-', '-', '-', 0, 0, 0, 0
	.byte 'P', '.', '-', '-', '.', 0, 0, 0
	.byte 'Q', '-', '-', '.', '-', 0, 0, 0
	.byte 'R', '.', '-', '.', 0, 0, 0, 0
	.byte 'S', '.', '.', '.', 0, 0, 0, 0
	.byte 'T', '-', 0, 0, 0, 0, 0, 0
	.byte 'U', '.', '.', '-', 0, 0, 0, 0
	.byte 'V', '.', '.', '.', '-', 0, 0, 0
	.byte 'W', '.', '-', '-', 0, 0, 0, 0
	.byte 'X', '-', '.', '.', '-', 0, 0, 0
	.byte 'Y', '-', '.', '-', '-', 0, 0, 0
	.byte 'Z', '-', '-', '.', '.', 0, 0, 0
	
message01:	.asciiz " A A A"
message02:	.asciiz "SOS"
message03:	.asciiz "WATERLOO"
message04:	.asciiz "DANCING QUEEN"
message05:	.asciiz "CHIQUITITA"
message06:	.asciiz "THE WINNER TAKES IT ALL"
message07:	.asciiz "MAMMA MIA"
message08:	.asciiz "TAKE A CHANCE ON ME"
message09:	.asciiz "KNOWING ME KNOWING YOU"
message10:	.asciiz "FERNANDO"

buffer01:	.space 128
buffer02:	.space 128
test_buffer:	.byte  0xff 0x30 0x37 0x30    # This is SOS
