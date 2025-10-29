// ARMv8 assembly with no NEON optimization, only algorithm
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
    mov     w2, #0xFFFFFFFF // set initial crc value
    cbz     x1, crc_done        // if x1 (remaining length of data) == 0, go to done, otherwise start byte loop

crc_byte_loop:
    ldrb    w3, [x0], #1    // load byte and increment pointer
    eor     w2, w2, w3      // crc ^= data[i]
    mov     w4, #8          // set counter to 8, then start bit loop

crc_bit_loop:
    and     w5, w2, #1      // crc & 1 (result in w5)
    cbz     w5, else        // if == 0 then go to else
    mov     w6, #0xEDB88320 // put polynomial in register
    lsr     w2, w2, #1      // shift crc by 1
    eor     w2, w2, w6      // xor crc with polynomial
    b       bit_loop_comp   // handle loop repetition logic

else:
    lsr     w2, w2, #1      // shift right 1 bit

bit_loop_comp:
    subs    w4, w4, #1      // decrement bit counter by 1
    bne     crc_bit_loop    // repeat loop if w4 != 0
    subs    x1, x1, #1      // decrement byte counter by 1
    bne crc_byte_loop       // repeat byte loop if x1 != 0 (no data left), otherwise go to done

crc_done:
    mvn     w0, w2          // invert bits in crc
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