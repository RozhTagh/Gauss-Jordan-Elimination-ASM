.data
    margin:     .zero   4
    array:      .zero   8008000
    answer:     .zero   8000
    i_var:      .zero   4
    j_var:      .zero   4
    k_var:      .zero   4
    x_var:      .zero   4
    pivot_row:  .zero   4
    foundnz:    .zero   4
    epsilon:    .double 0.0000001
    factor:     .double 0.0
    sum:        .double 0.0
    message:    .string "impossible"
    message1:    .string "impossible"
    message2:    .string "impossible"
    message3:    .string "impossible"

    print_int_format:     .asciz "%d"
    print_int_format1:     .asciz "%d"
    print_int_format2:     .asciz "%d"
    print_int_format3:     .asciz "%d"

    read_int_format:      .asciz "%d"
    read_int_format1:      .asciz "%d"
    read_int_format2:      .asciz "%d"
    read_int_format3:      .asciz "%d"

    read_double_format:   .asciz "%lf"
    read_double_format1:   .asciz "%lf"
    read_double_format2:   .asciz "%lf"
    read_double_format3:   .asciz "%lf"

    print_double_format:  .asciz "%.3f"
    print_double_format1:  .asciz "%.3f"
    print_double_format2:  .asciz "%.3f"
    print_double_format3:  .asciz "%.3f"

.text
.globl asm_main

partial_pivot:
    stmg     %r11, %r15, -40(%r15)
    lay      %r15, -200(%r15)
    # ---------------------------

    xr      %r7, %r7    
    larl    %r6, i_var
    st      %r7, 0(6)       # set i_var to 0
outer_loop:
    larl    %r6, i_var
    l       %r7, 0(6)       # i_var in r7
    larl    %r6, pivot_row
    st      %r7, 0(6)       # set pivot row to i

    larl    %r6, i_var
    l       %r7, 0(6)
    ahi     %r7, 1          # i+1 in r7
    larl    %r6, j_var
    st      %r7, 0(6)       # set j_var to i+1

    larl    %r6, margin
    l       %r7, 0(6)       # margin in r7
    larl    %r6, j_var
    l       %r8, 0(6)       # j in r8
    cr      %r8, %r7
    jl      inner_loop
    j       check_singular

inner_loop:
    larl    %r6, margin
    l       %r7, 0(6)
    ahi     %r7, 1          # margin+1 in r7
    larl    %r6, j_var
    m       %r6, 0(6)       # j*(margin+1) in r7
    larl    %r6, i_var
    a       %r7, 0(6)       # j*(margin+1) + i in r7
    mhi     %r7, 8          # first index in r7

    larl    %r6, margin
    l       %r9, 0(6)
    ahi     %r9, 1          # margin+1 in r9
    larl    %r6, pivot_row
    m       %r8, 0(6)       # pivot_row*(margin+1) in r9
    larl    %r6, i_var
    a       %r9, 0(6)       # pivot_row*(margin+1) + i in r9
    mhi     %r9, 8          # second index in r9

    larl    %r6, array
    ar      %r6, %r7    
    ld      %f0, 0(6)       # array[j][i] in f0
    lpdfr   %f0, %f0        # fabs in f0

    larl    %r6, array
    ar      %r6, %r9
    ld      %f2, 0(6)       # array[pivot_row][i] in f2
    lpdfr   %f2, %f2        # fabs int f2

    kdbr    %f0, %f2
    jle     continue1
    larl    %r6, j_var
    l       %r7, 0(6)       # j_var in r7
    larl    %r6, pivot_row
    st      %r7, 0(6)       # pivot_row = j

continue1:
    larl    %r6, j_var
    l       %r7, 0(6)
    ahi     %r7, 1
    st      %r7, 0(6)       # increment j
    larl    %r6, margin
    l       %r8, 0(6)       # margin in r8
    cr      %r7, %r8        # compare j with margin
    jl      inner_loop

check_singular:
    larl    %r6, foundnz
    xr      %r7, %r7
    st      %r7, 0(6)       # foundnz = 0

    larl    %r6, i_var
    l       %r7, 0(6)       # i_var in r7
    larl    %r6, x_var
    st      %r7, 0(6)       # x_var = i
check_nz_loop:
    larl    %r6, margin
    l       %r7, 0(6)
    ahi     %r7, 1          # margin+1 in r7
    larl    %r6, x_var
    m       %r6, 0(6)       # x*(margin+1) in r7
    larl    %r6, i_var
    a       %r7, 0(6)       # x*(margin+1) + i in r7
    mhi     %r7, 8          # index in r7

    larl    %r6, array
    ar      %r6, %r7
    ld      %f0, 0(6)
    lpdfr   %f0, %f0        # fabs(array[x][x]) in f0
    
    larl    %r6, epsilon
    ld      %f2, 0(6)       # epsilon in f2
    kdbr    %f0, %f2        # compare with epsilon
    jle     not_found
    larl    %r6, foundnz
    l       %r7, 0(6)
    ahi     %r7, 1
    st      %r7, 0(6)       # foundnz += 1
not_found:
    larl    %r6, x_var
    l       %r7, 0(6)       # x_var in r7
    ahi     %r7, 1
    st      %r7, 0(6)       # x_var += 1
    larl    %r6, margin
    l       %r8, 0(6)       # margin in r8
    cr      %r7, %r8        # compare x_var with margin
    jl      check_nz_loop

    larl    %r6, foundnz
    l       %r7, 0(6)       # foundnz in r7
    chi     %r7, 0
    je      return

continue2:
    larl    %r6, pivot_row
    l       %r7, 0(6)       # pivor_row in r7
    larl    %r6, i_var
    l       %r8, 0(6)       # i_var in r8
    cr      %r7, %r8
    je      continue3
    larl    %r6, i_var
    l       %r7, 0(6)       # i_var in r7
    larl    %r6, j_var
    st      %r7, 0(6)       # j_var = i

swap_loop:
    larl    %r6, margin
    l       %r7, 0(6)
    ahi     %r7, 1          # margin+1 in r7
    larl    %r6, i_var
    m       %r6, 0(6)       # i*(margin+1) in r7
    larl    %r6, j_var
    a       %r7, 0(6)       # i*(margin+1) in r7
    mhi     %r7, 8          # first index in r7

    larl    %r6, margin
    l       %r9, 0(6)
    ahi     %r9, 1          # margin+1 in r9
    larl    %r6, pivot_row
    m       %r8, 0(6)       # pivot_row*(margin+1) in r9
    larl    %r6, j_var
    a       %r9, 0(6)       # pivot_row*(margin+1) + j in r9
    mhi     %r9, 8          # second index in r9

    larl    %r6, array
    ar      %r6, %r7
    ld      %f0, 0(6)       # array[i][j] in f0

    larl    %r6, array
    ar      %r6, %r9
    ld      %f2, 0(6)       # array[pivot_row][j] in f2

    larl    %r6, array
    ar      %r6, %r9
    std     %f0, 0(6)       # swap 
    larl    %r6, array
    ar      %r6, %r7
    std     %f2, 0(6)       # swap

    larl    %r6, j_var
    l       %r7, 0(6)
    ahi     %r7, 1
    st      %r7, 0(6)       # increment j
    larl    %r6, margin
    l       %r8, 0(6)       # margin in r8
    cr      %r7, %r8
    jle     swap_loop

continue3:
    larl    %r6, i_var
    l       %r7, 0(6)
    ahi     %r7, 1          # i+1 in r7
    larl    %r6, j_var
    st      %r7, 0(6)       # j = i+1
    larl    %r6, margin
    l       %r8, 0(6)       # margin in r8
    cr      %r7, %r8
    jl      factor_loop
    j       return

factor_loop:
    larl    %r6, margin
    l       %r7, 0(6)
    ahi     %r7, 1          # margin+1 in r7
    larl    %r6, j_var
    m       %r6, 0(6)       # j*(margin+1) in r7
    larl    %r6, i_var
    a       %r7, 0(6)       # j*(margin+1) + i in r7
    mhi     %r7, 8          # first index in r7

    larl    %r6, margin
    l       %r9, 0(6)
    ahi     %r9, 1          # margin+1 in r9
    larl    %r6, i_var
    m       %r8, 0(6)       # i*(margin+1) in r9
    larl    %r6, i_var
    a       %r9, 0(6)       # i*(margin+1) + i in r9
    mhi     %r9, 8          # second index in r9

    larl    %r6, array
    ar      %r6, %r7
    ld      %f0, 0(6)       # A[j][i] in f0
    larl    %r6, array
    ar      %r6, %r9
    ld      %f2, 0(6)       # A[i][i] in f2

    ddbr    %f0, %f2
    larl    %r6, factor
    std     %f0, 0(6)

    larl    %r6, i_var
    l       %r7, 0(6)
    larl    %r6, k_var
    st      %r7, 0(6)       # k_var = i
minus_loop:
    larl    %r6, margin
    l       %r7, 0(6)
    ahi     %r7, 1          # margin+1 in r7
    larl    %r6, i_var
    m       %r6, 0(6)       # i*(margin+1) in r7
    larl    %r6, k_var
    a       %r7, 0(6)       # i*(margin+1) + k in r7
    mhi     %r7, 8          # first index in r7

    larl    %r6, margin
    l       %r9, 0(6)
    ahi     %r9, 1          # margin+1 in r9
    larl    %r6, j_var
    m       %r8, 0(6)       # j*(margin+1) in r9
    larl    %r6, k_var
    a       %r9, 0(6)       # j*(margin+1) + k in r9
    mhi     %r9, 8          # second index in r9

    larl    %r6, array
    ar      %r6, %r7
    ld      %f0, 0(6)       # array[i][k] in f0
    larl    %r6, factor
    ld      %f2, 0(6)       # factor in f2
    mdbr    %f0, %f2        # factor * array[i][k] in f0

    larl    %r6, array
    ar      %r6, %r9
    ld      %f2, 0(6)       # array[j][k] in f2
    sdbr    %f2, %f0        # array[j][k] - factor * array[i][k] in f2
    
    larl    %r6, array
    ar      %r6, %r9
    std     %f2, 0(6)

    larl    %r6, k_var
    l       %r7, 0(6)
    ahi     %r7, 1
    st      %r7, 0(6)
    larl    %r6, margin
    l       %r8, 0(6)
    cr      %r7, %r8
    jle     minus_loop

    larl    %r6, j_var
    l       %r7, 0(6)
    ahi     %r7, 1
    st      %r7, 0(6)       # j += 1
    larl    %r6, margin
    l       %r8, 0(6)
    cr      %r7, %r8
    jl      factor_loop

    larl    %r6, i_var
    l       %r7, 0(6)
    ahi     %r7, 1
    st      %r7, 0(6)       # increment i
    larl    %r6, margin
    l       %r8, 0(6)       # margin in r8
    cr      %r7, %r8
    jl      outer_loop

return:
    # ---------------------------	
    lay     %r15, 200(%r15)
    lmg     %r11, %r15, -40(%r15)
    br      %r14



backSubstitute:
    stmg     %r11, %r15, -40(%r15)
    lay      %r15, -200(%r15)
    # ---------------------------

    larl    %r6, margin
    l       %r7, 0(6)
    la      %r8, 1
    sr      %r7, %r8        # i_var-1 in r7
    larl    %r6, i_var
    st      %r7, 0(6)       # i_var = margin-1

back_outer_loop:
    lzdr    %f0
    larl    %r6, sum
    std     %f0, 0(6)       # sum = 0

    larl    %r6, i_var
    l       %r7, 0(6)
    la      %r9, 1
    ar      %r7, %r9        # i_var+1 in r7
    larl    %r6, j_var
    st      %r7, 0(6)       # j_var = i_var+1
    larl    %r6, margin
    l       %r8, 0(6)       # margin in r8
    cr      %r7, %r8
    jl      back_inner_loop
    j       back_continue

back_inner_loop:
    larl    %r6, margin
    l       %r7, 0(6)
    ahi     %r7, 1          # margin+1 in r7
    larl    %r6, i_var
    m       %r6, 0(6)       # i*(margin+1) in r7
    larl    %r6, j_var
    a       %r7, 0(6)       # i*(margin+1) + j in r7
    mhi     %r7, 8          # first index in r7

    larl    %r6, j_var
    l       %r8, 0(6)       # j_var in r8
    mhi     %r8, 8          # second index in r8

    larl    %r6, array
    ar      %r6, %r7
    ld      %f0, 0(6)       # array[i][j] in f0

    larl    %r6, answer
    ar      %r6, %r8
    mdb     %f0, 0(6)       # array[i][j] * answer[j] in f0

    larl    %r6, sum
    adb     %f0, 0(6)
    std     %f0, 0(6)       # sum += array[i][j] * answer[j]

    larl    %r6, j_var
    l       %r7, 0(6)
    la      %r9, 1
    ar      %r7, %r9
    st      %r7, 0(6)       # j_var += 1
    larl    %r6, margin
    l       %r8, 0(6)       # margin in r8
    cr      %r7, %r8
    jl      back_inner_loop

back_continue:
    larl    %r6, margin
    l       %r7, 0(6)
    ahi     %r7, 1          # margin+1 in r7
    larl    %r6, i_var
    m       %r6, 0(6)       # i*(margin+1) in r7
    larl    %r6, margin
    a       %r7, 0(6)       # i*(margin+1) + margin in r7
    mhi     %r7, 8          # first index in r7

    larl    %r6, margin
    l       %r9, 0(6)
    ahi     %r9, 1          # margin+1 in r9
    larl    %r6, i_var
    m       %r8, 0(6)       # i*(margin+1) in r9
    larl    %r6, i_var
    a       %r9, 0(6)       # i*(margin+1) + i in r9
    mhi     %r9, 8          # second index in r9

    larl    %r6, array
    ar      %r6, %r7
    ld      %f0, 0(6)       # array[i][margin] in f0

    larl    %r6, array
    ar      %r6, %r9
    ld      %f2, 0(6)       # array[i][i] in f2

    larl    %r6, sum
    ld      %f4, 0(6)       # sum in f4

    sdbr    %f0, %f4        # array[i][n] - sum in f0
    ddbr    %f0, %f2        # (array[i][n] - sum) / array[i][i] in f0

    larl    %r6, i_var
    l       %r7, 0(6)       # i in r7
    mhi     %r7, 8
    larl    %r6, answer
    ar      %r6, %r7
    std     %f0, 0(6)       # store f0 in answer[i]

    larl    %r6, i_var
    l       %r7, 0(6)
    la      %r9, 1
    sr      %r7, %r9
    st      %r7, 0(6)       # i_var -= 1
    chi     %r7, 0
    jnl     back_outer_loop

    # ---------------------------	
    lay     %r15, 200(%r15)
    lmg     %r11, %r15, -40(%r15)
    br      %r14


asm_main:
    stmg     %r11, %r15, -40(%r15)
    lay      %r15, -200(%r15)
    # ---------------------------	

    brasl   %r14, read_int
    lr      %r7, %r2    # margin
    larl    %r6, margin
    st      %r7, 0(6)

    ahi     %r7, 1        # margin+1 in r7
    l       %r8, 0(6)     # margin in r8
    mr      %r6, %r8      # margin(margin+1) in r7
    la      %r10, 8       # increment
    larl    %r6, array    # array address

input_loop:
    brasl   %r14, read_double
    std     %f0, 0(6)
    ar      %r6, %r10
    bctr    %r7, 0
    chi     %r7, 0
    jne     input_loop

    brasl   14, partial_pivot
    
    larl    %r6, foundnz
    l       %r7, 0(6)
    xr      %r8, %r8
    cr      %r7, %r8
    jz      singular
    
    brasl   14, backSubstitute

    larl    %r6, margin
    l       %r7, 0(6)       # n in r7
    la      %r10, 8
    larl    %r6, answer
output_loop:
    ld      %f0, 0(6)
    brasl   14, print_double
    brasl   14, print_nl
    ar      6, 10
    bctr    7, 0
    chi     7, 0
    jne     output_loop
    j       end

singular:
    larl    %r6, message
    lr      %r2, %r6
    brasl   14, print_string

end:

    # ---------------------------	
    lay     %r15, 200(%r15)
    lmg     %r11, %r15, -40(%r15)
    br      %r14


print_nl:
    stg     %r14, -8(%r15)
    lay     %r15, -168(%r15)
    la      %r2,  10
    brasl   %r14, putchar
    lay     %r15, 168(%r15)
    lg      %r14, -8(%r15)
    br      %r14

	
print_string:
    stg     %r14, -8(%r15)
    lay     %r15, -168(%r15)
    brasl   %r14, puts
    lay     %r15, 168(%r15)
    lg      %r14, -8(%r15)
    br      %r14

read_int:
    stg     %r14, -8(%r15)
    lay     %r15, -168(%r15)
    lay     %r3,  0(%r15)
    larl    %r2,  read_int_format
    brasl   %r14, scanf
    l       %r2,  0(%r15)
    lay     %r15, 168(%r15)
    lg      %r14, -8(%r15)
    br      %r14

read_double:  # moves double to f0
    stg     %r14, -8(%r15)
    lay     %r15, -168(%r15)
    larl    %r2,  read_double_format
    brasl   %r14, scanf
    lay     %r15, 168(%r15)
    lg      %r14, -8(%r15)
    br      %r14

print_double:  # print double in f0
    stg     %r14, -8(%r15)
    lay     %r15, -168(%r15)
    larl    %r2,  print_double_format
    brasl   %r14, printf
    lay     %r15, 168(%r15)
    lg      %r14, -8(%r15)
    br      %r14