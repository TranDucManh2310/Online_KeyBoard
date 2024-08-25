.eqv KEY_CODE       0xFFFF0004   # Địa chỉ chứa mã ASCII từ bàn phím
.eqv KEY_READY      0xFFFF0000   # Địa chỉ chứa trạng thái sẵn sàng của bàn phím (1 nếu có mã mới)
.eqv DISPLAY_CODE   0xFFFF000C   # Địa chỉ để ghi mã ASCII để hiển thị
.eqv DISPLAY_READY  0xFFFF0008   # Địa chỉ chứa trạng thái sẵn sàng của màn hình (1 nếu sẵn sàng hiển thị)

.data
menu:      .asciiz "-----------------------------------------------------------------------\n1.Hien thi DCE\n2.Sua de chi con lai vien khong có mau so o giua va hien thi\n3.Hay sua va hoan doi vi tri cua cac chu thanh DEC roi hien thi voi mau so o giua moi\n4.Hay nhap ban phim cho ki tu mau cho D C E roi hien thi\n5.Thoat\n"
input_msg: .asciiz "Hay nhap lua chon cua ban: "
invalid_msg: .asciiz "Lua chon phai tu 1 den 5\n"
newline:   .asciiz "\n"
buffer:    .space 5    
image:	.asciiz	"                                           *************       \n**************                            *3333333333333*      \n*222222222222222*                         *33333********       \n*22222******222222*                       *33333*              \n*22222*      *22222*                      *33333********       \n*22222*       *22222*      *************  *3333333333333*      \n*22222*       *22222*    **11111*****111* *33333********       \n*22222*       *22222*  **1111**       **  *33333*              \n*22222*      *222222*  *1111*             *33333********       \n*22222*******222222*  *11111*             *3333333333333*      \n*2222222222222222*    *11111*              *************       \n***************       *11111*                                  \n      ---              *1111**                                 \n    / o o \\             *1111****   *****                      \n    \\   > /              **111111***111*                       \n     -----                 ***********    dce.hust.edu.vn      \n"
original_image:.asciiz	"                                           *************       \n**************                            *3333333333333*      \n*222222222222222*                         *33333********       \n*22222******222222*                       *33333*              \n*22222*      *22222*                      *33333********       \n*22222*       *22222*      *************  *3333333333333*      \n*22222*       *22222*    **11111*****111* *33333********       \n*22222*       *22222*  **1111**       **  *33333*              \n*22222*      *222222*  *1111*             *33333********       \n*22222*******222222*  *11111*             *3333333333333*      \n*2222222222222222*    *11111*              *************       \n***************       *11111*                                  \n      ---              *1111**                                 \n    / o o \\             *1111****   *****                      \n    \\   > /              **111111***111*                       \n     -----                 ***********    dce.hust.edu.vn      \n"               
prompt:    .asciiz "Nhap ky tu mau cho D, C, E: "

.text
.globl main

main:
    # Begin infinite loop
    loop:
        # Print menu
        li $v0, 4
        la $a0, menu
        syscall
        
        # Prompt for input
        li $v0, 4
        la $a0, input_msg
        syscall
        
        # Read integer input
        li $v0, 5
        syscall
        move $t0, $v0  # Move input value to $t0
        
        # Process input
        beq $t0, 1, option1
        beq $t0, 2, option2
        beq $t0, 3, option3
        beq $t0, 4, option4
        beq $t0, 5, option5
        blt $t0, 1, invalid_option
        bgt $t0, 5, invalid_option
        j loop  # Go back to loop if input does not match any option
        invalid_option:
        li $v0, 4
        la $a0, invalid_msg
        syscall
        j loop  # Go back to loop
        
    # Option 1: Display DCE
    option1:
       j display_image

    # Option 2: Modify and display
    option2:
        jal modify_image
        j display_image  # Go to display_image after modification
    
    # Option 3: Swap and display
# Option 3: Swap and display '3' and '1' from image
option3 :
li  $s0, 0      # index of the order of lines

loop_3:
    la  $a0, image 
    beq $s0, 16, end_program  # if reach the 16th line, task is completed
    sll $s1, $s0, 6
    add $s1, $s1, $a0  # $s1 is the first character of the ($s0+1)th line

print_E3:
    addi $s2, $s1, 42  # print E, from the 43th character of the line
    jal  print_21_character

print_C3:
    addi $s2, $s1, 21  # print C, from the 22th character of the line
    jal  print_21_character

print_D3:
    addi $s2, $s1, 0   # print D, from the 1th character of the line
    jal  print_21_character

    # Print 'new line'
    li   $a0, 10       # newline character
    li   $t1, 0xFFFF000C  # address of the display data register
    sb   $a0, 0($t1)   # store byte to display data register

    addi $s0, $s0, 1   # advance line
    j    loop_3

print_21_character:
    li   $t0, 1        # index of the order of character in a line
loop_21_character:
    bgt  $t0, 21, back # if reach the 21th character, jump back

    lb   $a0, 0($s2)   # load character to print
    li   $t1, 0xFFFF000C  # address of the display data register
    sb   $a0, 0($t1)   # store byte to display data register

    addi $s2, $s2, 1   # advance to next character
    addi $t0, $t0, 1
    j    loop_21_character
back:
    jr   $ra

end_program:
j loop 
    # Option 4: Input and display
    option4:
        jal input_colors
        j display_image  # Go to display_image after inputting colors

    # Option 5: Exit
    option5:
        li $v0, 10
        syscall

# Function to modify image to only show the outline
modify_image:
    la $t0, image
    li $t2, '2'           # Ký tự cần thay thế
    li $t3, '3'           # Ký tự cần thay thế
    li $t4, '1'           # Ký tự cần thay thế
    li $t5, ' '           # Ký tự thay thế

modify_loop:
    lb $t1, 0($t0)        # Đọc một byte từ chuỗi
    beq $t1, $zero, modify_end  # Nếu là ký tự null, kết thúc
    beq $t1, $t2, replace_2 # Nếu là ký tự '2', thay thế
    beq $t1, $t3, replace_3 # Nếu là ký tự '3', thay thế
    beq $t1, $t4, replace_1 # Nếu là ký tự '1', thay thế
    j next_char

replace_2:
    sb $t5, 0($t0)        # Thay thế bằng khoảng trắng
    j next_char

replace_3:
    sb $t5, 0($t0)        # Thay thế bằng khoảng trắng
    j next_char

replace_1:
    sb $t5, 0($t0)        # Thay thế bằng khoảng trắng

next_char:
    addi $t0, $t0, 1      # Tăng địa chỉ chuỗi
    j modify_loop         # Quay lại vòng lặp

modify_end:
    jr $ra                # Quay lại hàm gọi

# Function to input colors for D, C, E and display
input_colors:
    li $v0, 4             # Syscall để in chuỗi
    la $a0, prompt        # Địa chỉ của chuỗi prompt
    syscall

    li $v0, 12            # Syscall để đọc ký tự
    syscall               # Gọi syscall
    move $t5, $v0         # Lưu ký tự màu cho D

    li $v0, 12            # Syscall để đọc ký tự
        syscall               # Gọi syscall
    move $t6, $v0         # Lưu ký tự màu cho C

    li $v0, 12            # Syscall để đọc ký tự
    syscall               # Gọi syscall
    move $t7, $v0         # Lưu ký tự màu cho E

    la $t0, image

color_loop:
    lb $t1, 0($t0)        # Đọc một byte từ chuỗi
    beq $t1, $zero, color_end   # Nếu là ký tự null, kết thúc
    beq $t1, '2', color_d
    beq $t1, '1', color_c
    beq $t1, '3', color_e
    j next_color

color_d:
    sb $t5, 0($t0)        # Thay thế D bằng ký tự màu
    j next_color

color_c:
    sb $t6, 0($t0)        # Thay thế C bằng ký tự màu
    j next_color

color_e:
    sb $t7, 0($t0)        # Thay thế E bằng ký tự màu

next_color:
    addi $t0, $t0, 1      # Tăng địa chỉ chuỗi
    j color_loop          # Quay lại vòng lặp

color_end:
    jr $ra                # Quay lại hàm gọi

# Function to display the modified image and restore the original
display_image:
     la $a0, image
      li   $k0, DISPLAY_CODE       # Địa chỉ hiển thị mã ASCII
    li   $k1, DISPLAY_READY      # Địa chỉ kiểm tra màn hình sẵn sàng
    loopforprint:
    lb   $t0, 0($a0)             # Đọc một ký tự từ chuỗi
    beq  $t0, $zero, end         # Nếu gặp ký tự null (kết thúc chuỗi), thoát vòng lặp

WaitForDis:
    lw   $t1, 0($k1)             # Đọc giá trị DISPLAY_READY
    beq  $t1, $zero, WaitForDis  # Nếu DISPLAY_READY == 0, tiếp tục chờ

    sb   $t0, 0($k0)             # Ghi ký tự vào địa chỉ DISPLAY_CODE để hiển thị
    nop

    addi $a0, $a0, 1             # Chuyển đến ký tự tiếp theo trong chuỗi
    j    loopforprint                    # Quay lại vòng lặp

end:
    nop                          # Kết thúc chương trình

    # Restore the original image
    la $t0, original_image
    la $t1, image

restore_loop:
    lb $t2, 0($t0)        # Đọc một byte từ chuỗi gốc
    beq $t2, $zero, restore_end  # Nếu là ký tự null, kết thúc
    sb $t2, 0($t1)        # Sao chép byte vào chuỗi image
    addi $t0, $t0, 1      # Tăng địa chỉ chuỗi gốc
    addi $t1, $t1, 1      # Tăng địa chỉ chuỗi image
    j restore_loop        # Quay lại vòng lặp

restore_end:
    j loop  # Go back to loop
