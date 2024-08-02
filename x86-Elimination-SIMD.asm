%macro      before_call   0
    movaps  [rsp], xmm0
    movaps  [rsp+16], xmm1
    movaps  [rsp+32], xmm2
    movaps  [rsp+48], xmm3
%endmacro

%macro      after_call   0
    movaps  xmm3, [rsp+48]
    movaps  xmm2, [rsp+32]
    movaps  xmm1, [rsp+16]
    movaps  xmm0, [rsp]
%endmacro


segment .data
    array:    times  1001000   dq 0 
    answer:   times  1000   dq 0
    epsilon:  dq     0.000001
    factor:   dq     0
    sum:      dq     0
    high:     dq     0
    low:      dq     0
    message:  db     "imposible", 0

    print_int_format:      db  "%ld"
    read_int_format:       db  "%ld", 0
    read_double_format:    db  "%lf", 0       ; Format string for fscanf with %lf specifier
    print_double_format:   db  "%.3lf ", 0     ; Format string for fprintf with %lf specifier


segment .text
    extern printf
    extern putchar
    extern puts
    extern scanf
    global asm_main


fabs:    ; input in xmm0
    movsd   xmm3, xmm0
    pcmpeqd xmm3, xmm3
    psrld   xmm3, 1
    andps   xmm0, xmm3
    ret
    

partial_pivot:      ; n in r14
    mov     r12, 0      ; i
outer_loop:
    mov     r15, r12    ; pivot row
    mov     r13, 1
    add     r13, r12    ; j
    cmp     r13, r14
    jl      inner_loop
    jmp     check_singular

inner_loop:
    mov     rax, r13
    add     r14, 1
    imul    r14         ; calculate j*(n+1)
    sub     r14, 1
    add     rax, r12
    mov     rbx, rax    ; first index in rbx

    mov     rax, r15
    add     r14, 1
    imul    r14         ; calcuate pivot_row*(n+1)
    sub     r14, 1
    add     rax, r12
    mov     rdx, rax    ; second index in rdx

    movsd   xmm1,[array+rbx*8]
    movsd   xmm2,[array+rdx*8]

    movsd   xmm0, xmm1
    call    fabs
    movsd   xmm1, xmm0
    movsd   xmm0, xmm2
    call    fabs
    movsd   xmm2, xmm0

    comisd  xmm1, xmm2
    jbe     continue1
    mov     r15, r13    ; pivot_row = j

continue1:
    add     r13, 1
    cmp     r13, r14    ; compare j with n
    jl      inner_loop

check_singular:
    mov     rsi, 0      ; foundnz
    mov     rdi, r12    ; x = i
check_nz_loop:
    mov     rax, rdi
    add     r14, 1
    imul    r14         ; calculate x*(n+1)
    sub     r14, 1
    add     rax, r12    ; x*(n+1) + i
    mov     rbx, rax

    movsd   xmm0,[array+rbx*8]
    call    fabs
    movsd   xmm1, [epsilon]
    comisd  xmm0, xmm1
    jbe     not_found
    mov     rsi, 1
not_found:
    add     rdi, 1
    cmp     rdi, r14
    jl      check_nz_loop

    cmp     rsi, 0
    jne     continue2
    ret                 ; matrix is singular

continue2:
    cmp     r15, r12    ; compare pivot_row and i
    je      continue3

initialize_swap_loop:
    mov     r13, r12    ; j
    mov     rsi, r14
    sub     rsi, r12
    add     rsi, 1      ; n-i+1 in rsi

    mov     rdi, rsi
    shr     rdi, 2
    shl     rdi, 2

    ; be andaze rdi/4 swap loop
    ; be andaze rsi - rdi one by one

    sub     rsi, rdi    ; one by one count
    mov     rax, rdi
    mov     rbx, 4
    cqo
    idiv    rbx
    mov     rdi, rax    ; four by four count

swap_loop:
    cmp     rdi, 0
    jle     swap_one_by_one

    mov     rax, r12
    add     r14, 1
    imul    r14         ; calculate i*(n+1)
    sub     r14, 1
    add     rax, r13    ; add with j
    mov     rbx, rax    ; first index in rbx

    mov     rax, r15
    add     r14, 1
    imul    r14         ; calculate pivot_row*(n+1)
    sub     r14, 1
    add     rax, r13    ; add with j
    mov     rdx, rax    ; second index in rdx

    vmovupd     ymm0,[array+rbx*8]
    vmovupd     ymm1,[array+rdx*8]
    vmovupd    [array+rbx*8], ymm1
    vmovupd    [array+rdx*8], ymm0

    add     r13, 4
    sub     rdi, 1
    jmp     swap_loop

swap_one_by_one:
    cmp     rsi, 0
    jle     continue3

    mov     rax, r12
    add     r14, 1
    imul    r14         ; calculate i*(n+1)
    sub     r14, 1
    add     rax, r13    ; add with j
    mov     rbx, rax    ; first index in rbx

    mov     rax, r15
    add     r14, 1
    imul    r14         ; calculate pivot_row*(n+1)
    sub     r14, 1
    add     rax, r13    ; add with j
    mov     rdx, rax    ; second index in rdx

    movsd   xmm0,[array+rbx*8]    ; array[i][j]
    movsd   xmm1,[array+rdx*8]    ; array[pivot_row][j]
    movsd  [array+rbx*8], xmm1    ; swap
    movsd  [array+rdx*8], xmm0    ; swap

    add     r13, 1
    sub     rsi, 1
    jmp     swap_one_by_one

continue3:
    mov     r13, r12
    add     r13, 1      ; j=i+1
    cmp	    r13, r14
    jl      factor_loop
    ret
    
factor_loop:
    mov     rax, r13
    add     r14, 1
    imul    r14         ; calculate j*(n+1)
    sub     r14, 1
    add     rax, r12
    mov     rbx, rax    ; first index in rbx

    mov     rax, r12
    add     r14, 1
    imul    r14         ; calculate i*(n+1)
    sub     r14, 1
    add     rax, r12
    mov     rdx, rax    ; second index in rdx

    movsd       xmm0,[array+rbx*8]
    movsd       xmm1,[array+rdx*8]
    divsd       xmm0, xmm1  ; factor in xmm0 

    mov         rbx, 0
factor_mov_loop:
    movsd      [factor+rbx*8], xmm0
    add         rbx, 1
    cmp         rbx, 4
    jl          factor_mov_loop

initialize_minus_loop:
    mov         r15, r12    ; k
    mov         rsi, r14
    sub         rsi, r12
    add         rsi, 1      ; n-k+1 in rsi
    
    mov         rdi, rsi
    shr         rdi, 2
    shl         rdi, 2

    ; be andaze rdi/4 minus loop
    ; be andaze rsi - rdi one by one

    sub         rsi, rdi    ; one by one count
    mov         rax, rdi
    mov         rbx, 4
    cqo
    idiv        rbx
    mov         rdi, rax    ; four by four count

minus_loop:
    cmp         rdi, 0
    jle         minus_one_by_one

    mov         rax, r13
    add         r14, 1
    imul        r14         ; calculate j*(n+1)
    sub         r14, 1
    add         rax, r15    ; j*(n+1) + k
    mov         rbx, rax    ; first index in rbx

    mov         rax, r12
    add         r14, 1
    imul        r14         ; calculate i*(n+1)
    sub         r14, 1
    add         rax, r15    ; i*(n+1) + k
    mov         rdx, rax    ; second index in rdx

    vmovupd     ymm1,[array+rbx*8]
    vmovupd     ymm2,[array+rdx*8]
    vmovupd     ymm3, [factor]

    vmulpd      ymm2, ymm2, ymm3
    vsubpd      ymm1, ymm1, ymm2

    mov         rax, r13
    add         r14, 1
    imul        r14         ; calculate j*(n+1)
    sub         r14, 1
    add         rax, r15    ; j*(n+1) + k
    mov         rbx, rax    ; first index in rbx
    vmovupd    [array+rbx*8], ymm1

    add         r15, 4
    sub         rdi, 1
    jmp         minus_loop

minus_one_by_one:
    cmp         rsi, 0
    jle         continue4

    mov         rax, r13
    add         r14, 1
    imul        r14         ; calculate j*(n+1)
    sub         r14, 1
    add         rax, r15    ; j*(n+1) + k
    mov         rbx, rax    ; first index in rbx

    mov         rax, r12
    add         r14, 1
    imul        r14         ; calculate i*(n+!)
    sub         r14, 1
    add         rax, r15    ; i*(n+1)+k
    mov         rdx, rax    ; second index in rdx

    movsd       xmm1,[array+rbx*8]   ; array[j][k] in xmm1
    movsd       xmm2,[array+rdx*8]   ; array[i][k] in xmm2

    mulsd       xmm2, xmm0           ; calculate factor * array[i][k]
    subsd       xmm1, xmm2           ; sub multiplication from array[j][k]

    mov         rax, r13
    add         r14, 1
    imul        r14         ; calculate j*(n+1)
    sub         r14, 1
    add         rax, r15
    mov         rbx, rax    ; first index in rbx
    movsd      [array+rbx*8], xmm1  ; store in array[j][k]

    add     r15, 1
    sub     rsi, 1
    jmp     minus_one_by_one

continue4:
    add     r13, 1
    cmp     r13, r14
    jl      factor_loop

    add     r12, 1
    cmp     r12, r14    ; compare i with n
    jl      outer_loop
    ret


backSubstitute:
    mov     r12, r14
    sub     r12, 1      ; i

back_outer_loop:
    xorpd   xmm0, xmm0  ; sum
    mov     r13, r12
    add     r13, 1      ; j
    cmp	    r13, r14
    jl      sum_calculation_initialize
    jmp     back_continue

sum_calculation_initialize:
    mov     rsi, r14
    sub     rsi, r12
    sub     rsi, 1      ; n-i-1 in rsi

    mov     rdi, rsi
    shr     rdi, 2
    shl     rdi, 2

    ; be andaze rdi/4 sum_calculation_loop
    ; be andaze rsi - rdi sum_calculation_one_by_one

    sub     rsi, rdi    ; one by one count
    mov     rax, rdi
    mov     rbx, 4
    cqo
    idiv    rbx
    mov     rdi, rbx    ; four by four count

sum_calculation_loop:
    cmp     rdi, 0
    jle     sum_calculation_one_by_one

    mov     rax, r12
    add     r14, 1
    imul    r14         ; calculate i*(n+1)
    sub     r14, 1
    add     rax, r13
    mov     rbx, rax    ; i*(n+1) + j
    mov     rdx, r13    ; j

    vmovupd     ymm2,[array+rbx*8]
    vmovupd     ymm3,[answer+rdx*8]
    vmulpd      ymm2, ymm2, ymm3    ; result in xmm2

    addsd   xmm0, xmm2              ; add with low value of xmm2
    shufpd  xmm2, xmm2, 1           ; shuffles high value of xmm2 with low value
    addsd   xmm0, xmm2
    
    add     r13, 4
    sub     rdi, 1
    jmp     sum_calculation_loop

sum_calculation_one_by_one:
    cmp     rsi, 0
    jle     back_continue

    mov     rax, r12
    add     r14, 1
    imul    r14         ; calculate i*(n+1)
    sub     r14, 1
    add     rax, r13
    mov     rbx, rax    ; i*(n+1) + j
    mov     rdx, r13    ; j

    movsd   xmm1,[array+rbx*8]  ; array[i][j] in xmm1
    mulsd   xmm1,[answer+rdx*8]
    addsd   xmm0, xmm1
    
    add     r13, 1
    sub     rsi, 1
    jmp     sum_calculation_one_by_one

back_continue:
    mov     rax, r12
    add     r14, 1
    imul    r14         ; calculate i*(n+1)
    sub     r14, 1
    add     rax, r14
    mov     rbx, rax    ; i*(n+1) + n

    mov     rax, r12
    add     r14, 1
    imul    r14         ; calculate i*(n+1)
    sub     r14, 1
    add     rax, r12 
    mov     rdx, rax    ; i*(n+1) + i

    movsd   xmm1,[array+rbx*8]      ; A[i][n] in xmm1
    movsd   xmm2,[array+rdx*8]      ; A[i][i] in xmm2
    subsd   xmm1, xmm0              ; A[i][n] - sum
    divsd   xmm1, xmm2
    mov     rbx, r12
    movsd  [answer+rbx*8], xmm1

    sub     r12, 1
    cmp     r12, 0
    jge     back_outer_loop
    ret


asm_main:
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    ; -------------------------

    call    read_int
    mov     r14, rax    ; margin
    add     r14, 1
    imul    r14
    sub     r14, 1
    mov     r12, rax    ; read counter = n(n+1)
    
    mov     r13, 0      ; array pointer
read_loop:
    call    read_double
    movsd  [array+r13*8], xmm0
    add     r13, 1
    sub     r12, 1
    cmp     r12, 0
    jnz     read_loop

    call    partial_pivot
    cmp     rsi, 0
    je      singular
    call    backSubstitute

    mov     r13, 0
print_loop:
    movsd       xmm0,[answer+r13*8]
    call        print_double
    add         r13, 1
    cmp         r13, r14
    jl          print_loop
    call        print_nl
    jmp         end

singular:
    mov     rdi, message
    call    print_string  

end:

    ; --------------------------

    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


print_string:
    sub rsp, 8
    call puts
    add rsp, 8 ; clearing local variables from stack
    ret

print_nl:
    sub rsp, 8
    mov rdi, 10
    call putchar
    add rsp, 8 ; clearing local variables from stack
    ret

print_double:
    sub rsp, 8
    mov rdi, print_double_format   ; Load the format string
    mov rax, 1       ; number of vector registers used
    mov rsi, rsp     ; second argument address of the double
    movsd [rsp], xmm0  ; Move the double from xmm0 to the stack
    call printf
    add rsp, 8
    ret

read_double:
    sub rsp, 8
    mov rdi, read_double_format  ; Load the format string
    mov rsi, rsp    ; second argument address of the double
    xor rax, rax    ; number of vector registers useed
    call scanf
    movsd   xmm0, [rsp] ; move value from stack to xmm0
    add rsp, 8
    ret

read_int:
    sub rsp, 8
    mov rsi, rsp
    mov rdi, read_int_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call scanf
    mov rax, [rsp]
    add rsp, 8 ; clearing local variables from stack
    ret


