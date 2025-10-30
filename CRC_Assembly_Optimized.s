// ARMv8 assembly with NEON optimization (crc32b)
.global main
.extern printf  // same functions as in C, better comparison
.extern exit
.extern malloc

.section .rodata
format:
    .asciz "CRC32 result = 0x%08X\n"    // match what's written in C

buffer_size:
    .quad 10485760          // 10 * 1024 * 1024 = 10MB

.section .text
// create_buffer()
create_buffer:              // return pointer in x0
    ldr     x0, =buffer_size
    ldr     x0, [x0]        // x0 = buffer_size
    bl      malloc          // malloc 10MB
    mov     x19, x0         // put pointer to buffer in x19
    mov     x20, #0         // set loop counter

fill_loop:
    ldr     x1, =buffer_size
    ldr     x1, [x1]        // x1 = buffer_size
    cmp     x20, x1         // is counter == buffer_size
    bge     fill_loop_comp

    // (i * 29 + 13)
    mov     x2, #29
    mul     x3, x20, x2
    add     x3, x3, #13
    and     x3, x3, #0xFF   // 8 bit mask 
    strb    w3, [x19, x20]  // store in array at location x20

    add     x20, x20, #1    // increment counter
    b       fill_loop

fill_loop_comp:
    mov     x0, x19         // return pointer in x0
    ret


// run_crc()
run_crc:
    mov     w2, #0
    mvn     w2, w2
    cbz     x1, crc_done

crc_loop:
    ldrb    w3, [x0], #1    // load and increment   
    crc32c  w2, w2, w3      // run crc
    subs    x1, x1, #1      // decrement length
    b.ne    crc_loop        // repeat until complete

crc_done:
    mvn     w0, w2          // invert result
    ret


// main()
main:
    // generate buffer
    bl      create_buffer
    mov     x19, x0         // save buffer pointer
    ldr     x1, =buffer_size
    ldr     x1, [x1]

    // run crc  (place in w0)
    mov     x0, x19         // get length buffer length for argument
    bl      run_crc         // run crc
    mov     w21, w0         // store result in w21 (later moved to w1 for call)

    // display with printf
    ldr     x0, =format
    mov     w1, w21
    bl      printf

    mov     w0, #0           // exit(0)
    bl      exit