.section .rodata
fmt:
    .string "CRC = %08X\n"

BUFFER_SIZE = 10485760       // 10 * 1024 * 1024
POLY        = 0xEDB88320

.section .bss
    .align 3
buffer:
    .skip BUFFER_SIZE          // reserve buffer

.section .text
.global main
.extern malloc
.extern printf

// ------------------------------
// uint8_t *create_buffer(void)
// ------------------------------
create_buffer:
    stp     x29, x30, [sp, -16]!   // prologue
    mov     x0, #BUFFER_SIZE       // malloc size
    bl      malloc                 // call malloc
    mov     x1, x0                 // x1 = buffer pointer
    mov     x2, #0                 // i = 0

create_loop:
    cmp     x2, #BUFFER_SIZE
    b.ge    create_done

    // buf[i] = (i * 29 + 13) & 0xFF
    mov     x3, x2
    mov     x4, #29
    mul     x3, x3, x4
    add     x3, x3, #13
    and     w3, w3, #0xFF
    strb    w3, [x1, x2]          // store byte
    add     x2, x2, #1
    b       create_loop

create_done:
    mov     x0, x1                 // return buffer pointer
    ldp     x29, x30, [sp], 16
    ret

// ------------------------------
// uint32_t run_crc(uint8_t *data, size_t len)
// ------------------------------
run_crc:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    mov     x2, #0xFFFFFFFF        // crc = 0xFFFFFFFF
    mov     x3, #0                 // i = 0

crc_outer_loop:
    cmp     x3, x1                 // i < len?
    b.ge    crc_done

    ldrb    w4, [x0, x3]           // data[i]
    eor     w2, w2, w4             // crc ^= data[i]

    mov     x5, #0                 // j = 0

crc_inner_loop:
    cmp     x5, #8
    b.ge    crc_inner_done

    and     w6, w2, #1             // check lowest bit
    cbz     w6, crc_shift_only

    // crc = (crc >> 1) ^ POLY
    lsr     w2, w2, #1
    mov     w6, #POLY
    eor     w2, w2, w6
    b       crc_inner_next

crc_shift_only:
    lsr     w2, w2, #1

crc_inner_next:
    add     x5, x5, #1
    b       crc_inner_loop

crc_inner_done:
    add     x3, x3, #1
    b       crc_outer_loop

crc_done:
    mvn     w0, w2                 // return ~crc
    ldp     x29, x30, [sp], 16
    ret

// ------------------------------
// int main(void)
// ------------------------------
main:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    bl      create_buffer          // x0 = buffer pointer
    mov     x1, x0                 // save buffer pointer
    mov     x0, x1                 // arg0 = buffer
    mov     x1, #BUFFER_SIZE       // arg1 = length
    bl      run_crc                // call run_crc
    mov     w1, w0                 // crc
    ldr     x0, =fmt
    bl      printf

    ldp     x29, x30, [sp], 16
    mov     w0, #0
    ret
