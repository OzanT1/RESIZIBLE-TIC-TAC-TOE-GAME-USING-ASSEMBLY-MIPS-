    .data
gameRules: .asciiz "To make a move, enter row index and column index (starting from 0) one by one respectively.\n"
prompt: .asciiz "Enter a number between 3 and 5 to select the size of the gameboard: "
invalid: .asciiz "Invalid input. Please try again.\n"
matrix: .space 25   # Assuming maximum matrix size of 5x5 (25 bytes)
newline: .asciiz "\n"
gameOverMessage: .asciiz "Game Over. Winner is: "

playerXTurnMessage: .asciiz "Player X's turn:\n"
playerOTurnMessage: .asciiz "Player O's turn:\n"

    .text
    .globl main

main:
    #Display the game rules
    li $v0, 4
    la $a0, gameRules
    syscall

    # Prompt user to enter a size
    li $v0, 4
    la $a0, prompt
    syscall

    # Read user input
    li $v0, 5
    syscall

    # Validate user input
    move $t0, $v0    # Move user input to $t0 for validation

    li $t1, 3        # Minimum allowed value
    li $t2, 5        # Maximum allowed value

    blt $t0, $t1, invalid_input   # If input < 3, branch to invalid_input
    bgt $t0, $t2, invalid_input   # If input > 5, branch to invalid_input

    # Fill the matrix's elements with '-'
    move $s0, $t0           # store matrix size in s0
    mul $t3, $t0, $t0       # Calculate the total number of elements in the matrix.
    la $t4, matrix          # Load the base address of the matrix
    li $t5, 45              # ASCII code for '-'

    loop_init_matrix:
        # Store '-' in each element of the matrix. t4 is offset and t3 is the size counter.
        sb $t5, 0($t4)

        # Move to the next element
        addi $t4, $t4, 1

        # Decrement counter
        subi $t3, $t3, 1

        # Check if we have initialized all elements
        bne $t3, $zero, loop_init_matrix

    # Matrix filled with '-'
    # Call the drawBoard function to print the matrix
    move $a0, $t0   # Number of rows
    move $a1, $t0   # Number of columns
    la $a2, matrix  # Base address of the matrix

    jal drawBoard
    
gameLoop:

    li $v0, 4
    la $a0, playerXTurnMessage  # Display player X turn message
    syscall
    
    li $v0, 5    # Read row index to make a move
    syscall
    move $t0, $v0  # t0 has row index
    
    li $v0, 5  # Read column index to make a column
    syscall
    move $t1, $v0  # t1 has column index
    
    move $a0, $t0
    move $a1, $t1
    move $a2, $s0
    jal doMoveX
    
    
    # Call three win check functions
    move $a0, $s0   # Number of rows
    move $a1, $s0   # Number of columns
    la $a2, matrix  # Base address of the matrix
    jal checkWinRowsX
    
    move $a0, $s0   # Number of rows
    move $a1, $s0   # Number of columns
    la $a2, matrix  # Base address of the matrix
    jal checkWinColumnsX
    
    move $a0, $s0
    jal checkWinDiagonalsX
    
    move $a0, $s0   # Number of rows
    move $a1, $s0   # Number of columns
    la $a2, matrix  # Base address of the matrix
    jal drawBoard
    
    li $v0, 4
    la $a0, playerOTurnMessage    # Display player O turn message
    syscall
    
    li $v0, 5   # Read row index to make a move
    syscall
    move $t0, $v0  # t0 has row index
    
    li $v0, 5   # Read row index to make a move
    syscall
    move $t1, $v0  # t1 has column index
    
    move $a0, $t0
    move $a1, $t1
    move $a2, $s0
    jal doMoveO
    
    move $a0, $s0   # Number of rows
    move $a1, $s0   # Number of columns
    la $a2, matrix  # Base address of the matrix
    jal checkWinRowsO
    
    move $a0, $s0   # Number of rows
    move $a1, $s0   # Number of columns
    la $a2, matrix  # Base address of the matrix
    jal checkWinColumnsO
    
    move $a0, $s0
    jal checkWinDiagonalsO
    
    move $a0, $s0   # Number of rows
    move $a1, $s0   # Number of columns
    la $a2, matrix  # Base address of the matrix
    jal drawBoard
    
    j gameLoop
    
    # Exit the program. Not necessary but good practice
    li $v0, 10
    syscall

invalid_input:
    # Display error message for invalid input
    li $v0, 4
    la $a0, invalid
    syscall

    j main
    
# Function to draw the board
drawBoard:
    # Arguments:
    # $a0: Number of rows
    # $a1: Number of columns
    # $a2: Base address of the matrix

    # Loop over the rows
    move $t1, $a0           # Counter for the rows
    loop_draw_row:
        # Loop over the columns
        move $t2, $a1       # Counter for the columns
        loop_draw_col:
            # Load the element from the matrix
            lb $t3, ($a2)

            # Print the element
            li $v0, 11
            move $a0, $t3
            syscall

            # Increment the base address of the matrix
            addiu $a2, $a2, 1

            # Decrement the column counter
            subiu $t2, $t2, 1

            # Check if we have reached the end of the row
            bne $t2, $zero, loop_draw_col

        # Print a new line
        li $v0, 4
        la $a0, newline
        syscall

        # Decrement the row counter
        subiu $t1, $t1, 1

        # Check if we have reached the end of the board
        bne $t1, $zero, loop_draw_row

    
    jr $ra

# Function to check if there is a win in rows for X
checkWinRowsX:
    # Arguments:
    # $a0: Number of rows
    # $a1: Number of columns
    # $a2: Base address of the matrix

    li $t0, 120              # ASCII code for 'x'
    
    
    # Loop over the rows
    move $t1, $a0           # Counter for the rows
    loop_check_row:
    li $t4, 0 		     # Counter for consecutives
        # Loop over the columns
        move $t2, $a1       # Counter for the columns
        loop_check_col:
            # Load the element from the matrix
            lb $t3, ($a2)
            
            bne $t3, $t0, else
            
            addi $t4, $t4, 1
            move $a3, $t0
            beq $t4, $a1, gameOver
            
            else:
            
           
            # Increment the base address of the matrix
            addiu $a2, $a2, 1

            # Decrement the column counter
            subiu $t2, $t2, 1

            # Check if we have reached the end of the row
            bne $t2, $zero, loop_check_col

        # Decrement the row counter
        subiu $t1, $t1, 1

        # Check if we have reached the end of the board
        bne $t1, $zero, loop_check_row

    
    jr $ra

# Function to check if there is a win in rows for O
checkWinRowsO:
    # Arguments:
    # $a0: Number of rows
    # $a1: Number of columns
    # $a2: Base address of the matrix

    li $t0, 111              # ASCII code for 'o'
    
    
    # Loop over the rows
    move $t1, $a0           # Counter for the rows
    loop_check_row2:
    li $t4, 0 		     # Counter for consecutives
        # Loop over the columns
        move $t2, $a1       # Counter for the columns
        loop_check_col2:
            # Load the element from the matrix
            lb $t3, ($a2)
            
            bne $t3, $t0, else1
            
            addi $t4, $t4, 1
            move $a3, $t0
            beq $t4, $a1, gameOver
            
            else1:
            
           
            # Increment the base address of the matrix
            addiu $a2, $a2, 1

            # Decrement the column counter
            subiu $t2, $t2, 1

            # Check if we have reached the end of the row
            bne $t2, $zero, loop_check_col2

        
        # Decrement the row counter
        subiu $t1, $t1, 1

        # Check if we have reached the end of the board
        bne $t1, $zero, loop_check_row2

    
    jr $ra


# Function to check if there is a win in columns for X
checkWinColumnsX:
    # Arguments:
    # $a0: Number of rows
    # $a1: Number of columns
    # $a2: Base address of the matrix

    li $t0, 120              # ASCII code for 'x'
    
    # Loop over the columns
    move $t2, $a1           # Counter for the columns
    loop_check_col1:
    li $t4, 0 		         # Counter for consecutives
        # Loop over the rows
        move $t1, $a0       # Counter for the rows
        move $s3, $a2           # Store the base address of the matrix in $s3
        loop_check_row1:
            # Load the element from the matrix
            lb $t3, ($s3)
            
            bne $t3, $t0, else_col
            
            addi $t4, $t4, 1
            move $a3, $t0
            beq $t4, $a0, gameOver   # If there is a win, branch to gameOver
            
            else_col:
            
            # Increment the base address of the matrix to move to the next element in the column
            add $s3, $s3, $a0

            # Decrement the row counter
            subiu $t1, $t1, 1

            # Check if we have reached the end of the column
            bne $t1, $zero, loop_check_row1

        # Move back to the beginning of the column
        subu $s3, $s3, $a0
        
        addi $a2, $a2, 1    # To go to the next column

        # Decrement the column counter
        subiu $t2, $t2, 1

        # Check if we have checked all columns
        bne $t2, $zero, loop_check_col1

    
    jr $ra


# Function to check if there is a win in columns for O
checkWinColumnsO:
    # Arguments:
    # $a0: Number of rows
    # $a1: Number of columns
    # $a2: Base address of the matrix

    li $t0, 111              # ASCII code for 'o'
    
    # Loop over the columns
    move $t2, $a1           # Counter for the columns
    loop_check_col3:
    li $t4, 0 		         # Counter for consecutives
        # Loop over the rows
        move $t1, $a0       # Counter for the rows
        move $s3, $a2           # Store the base address of the matrix in $s3
        loop_check_row3:
            # Load the element from the matrix
            lb $t3, ($s3)
            
            bne $t3, $t0, else_col1
            
            addi $t4, $t4, 1
            move $a3, $t0
            beq $t4, $a0, gameOver   # If there is a win, branch to gameOver
            
            else_col1:
            
            # Increment the base address of the matrix to move to the next element in the column
            add $s3, $s3, $a0

            # Decrement the row counter
            subiu $t1, $t1, 1

            # Check if we have reached the end of the column
            bne $t1, $zero, loop_check_row3

        # Move back to the beginning of the column
        subu $s3, $s3, $a0
        
        addi $a2, $a2, 1

        # Decrement the column counter
        subiu $t2, $t2, 1

        # Check if we have checked all columns
        bne $t2, $zero, loop_check_col3

    
    jr $ra

# Function to check if there is a win in diagonals for X
checkWinDiagonalsX:
    #Arguments:
    # $a0: size of matrix
    
    la $a2, matrix
    li $t0, 120              # ASCII code for 'x'
    
    li $t4, 0 		# Consecutive counter
    move $t2, $a0	# t2 = Counter for the loop
    
    move $t5, $a0 
    addi $t5, $t5, 1   # now t5 has how many bytes we need to go for the next element
    
    check_diagX1:
    
    lb $t3, ($a2)
    
    bne $t3, $t0, else_diagX1
    addi $t4, $t4, 1
    
    move $a3, $t0
    beq $t4, $a0, gameOver
    
    else_diagX1:
    
    add $a2, $a2, $t5  # locating the address of next element
    
    subi $t2, $t2, 1
    
    bne $t2, $zero, check_diagX1
    
    # Now start checking for the other diagonal
    # $a0: size of matrix
    
    la $a2, matrix

    li $t4, 0 		# Consecutive counter
    move $t2, $a0	# t2 = Counter for the loop
    
    move $t5, $a0 
    subi $t5, $t5, 1   # now t5 has how many bytes we need to go for the next element
    add $a2, $a2, $t5  # now pointer ($a2) is on the first element which is the top right corner in the square matrix.
    check_diagX2:
    
    lb $t3, ($a2)
    
    bne $t3, $t0, else_diagX2
    addi $t4, $t4, 1
    
    move $a3, $t0
    beq $t4, $a0, gameOver
    
    else_diagX2:
    
    add $a2, $a2, $t5  # locating the address of next element
    
    subi $t2, $t2, 1
    
    bne $t2, $zero, check_diagX2
 
    jr $ra
    
checkWinDiagonalsO:
    #Arguments:
    # $a0: size of matrix
    
    la $a2, matrix
    li $t0, 111              # ASCII code for 'o'
    
    li $t4, 0 		# Consecutive counter
    move $t2, $a0	# t2 = Counter for the loop
    
    move $t5, $a0 
    addi $t5, $t5, 1   # now t5 has how many bytes we need to go for the next element
    
    check_diagO1:
    
    lb $t3, ($a2)
    
    bne $t3, $t0, else_diagO1
    addi $t4, $t4, 1
    
    move $a3, $t0
    beq $t4, $a0, gameOver
    
    else_diagO1:
    
    add $a2, $a2, $t5  # locating the address of next element
    
    subi $t2, $t2, 1
    
    bne $t2, $zero, check_diagO1
    
    # Now start checking the other diagonal
    # $a0: size of matrix
    
    la $a2, matrix

    li $t4, 0 		# Consecutive counter
    move $t2, $a0	# t2 = Counter for the loop
    
    move $t5, $a0 
    subi $t5, $t5, 1   # now t5 has how many bytes we need to go for the next element
    add $a2, $a2, $t5  # now pointer ($a2) is on the first element which is the top right corner in the square matrix.
    check_diagO2:
    
    lb $t3, ($a2)
    
    bne $t3, $t0, else_diagO2
    addi $t4, $t4, 1
    
    move $a3, $t0
    beq $t4, $a0, gameOver
    
    else_diagO2:
    
    add $a2, $a2, $t5  # locating the address of next element
    
    subi $t2, $t2, 1
    
    bne $t2, $zero, check_diagO2
 
    jr $ra
    
    

gameOver:  # $a3: Winner ASCII value

    move $t0, $a3
    
    li $v0, 4
    la $a0, gameOverMessage
    syscall
    
    li $v0, 11
    move $a0, $t0	# Print winner character
    syscall
    
    li $v0, 10		# Exit program
    syscall
    
doMoveX:
    # Arguments:
    
    # $a0: row index
    # $a1: column index
    # $a2: size of matrix
    
    li $t0, 120      # ASCII code for 'x'
    
    # Calculating the addres of the element in a AxA square matrix:    Matrix[i][j] = A*i + j
    mul $t2, $a2, $a0
    add $t2, $t2, $a1  # Now, t2 has offset
    
    sb $t0, matrix($t2)  # Replace the indexed element with the ASCII code of 'x'
    
    jr $ra

doMoveO:
    # Arguments:
    
    # $a0: row index
    # $a1: column index
    # $a2: size of matrix
    
    li $t0, 111      # ASCII code for 'o'
    
    # Calculating the addres of the element in a AxA square matrix:    Matrix[i][j] = A*i + j
    mul $t2, $a2, $a0
    add $t2, $t2, $a1  # Now, t2 has offset
    
    sb $t0, matrix($t2)  # Replace the indexed element with the ASCII code of 'o'
    
    jr $ra








