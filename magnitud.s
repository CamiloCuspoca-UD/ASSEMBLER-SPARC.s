.include "macros.s"
.global _start
.global vector_magnitude_squared

_start:
    SETHI %hi(vector), %l0
    OR %l0, %lo(vector), %l0
    SETHI %hi(result), %l1
    OR %l1, %lo(result), %l1

    call vector_magnitude_squared
    nop

halt:
    ba halt
    nop

vector_magnitude_squared:
    sub %sp, 16, %sp
    st %l0, [%sp + 0]
    st %l1, [%sp + 4]
    st %l2, [%sp + 8]
    st %l3, [%sp + 12]

    ld [%l0], %l2
    ld [%l0 + 4], %l3
    ld [%l0 + 8], %l4

    MULSCC %l2, %l2, %l2
    MULSCC %l3, %l3, %l3
    MULSCC %l4, %l4, %l4

    add %l2, %l3, %l5
    add %l5, %l4, %l5

    st %l5, [%l1]

    ld [%sp + 0], %l0
    ld [%sp + 4], %l1
    ld [%sp + 8], %l2
    ld [%sp + 12], %l3
    add %sp, 16, %sp

    retl
    nop

vector:
    .word 3
    .word 4
    .word 5

result:
    .word 0




