.section .text
.globl tea_encrypt_asm

; Encrypt function
tea_encrypt_asm:
    addi    sp, sp, -16         # Reserva espacio en stack
    sw      s0, 0(sp)
    sw      s1, 4(sp)
    sw      s2, 8(sp)
    sw      s3, 12(sp)

    mv      s0, a0              # s0 = v (puntero a datos)
    mv      s1, a1              # s1 = key (puntero a clave)
    li      s2, 0               # s2 = sum = 0
    li      s3, 32              # s3 = contador de iteraciones

    lw      t0, 0(s0)           # t0 = v0 = v[0]
    lw      t1, 4(s0)           # t1 = v1 = v[1]

loop_encrypt:
    li      t2, 0x9e3779b9      # t2 = DELTA
    add     s2, s2, t2          # sum += DELTA

    # v0 += ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])
    sll     t3, t1, 4           # t3 = v1 << 4
    lw      t4, 0(s1)           # t4 = key[0]
    add     t3, t3, t4          # t3 = (v1 << 4) + key[0]
    add     t4, t1, s2          # t4 = v1 + sum
    xor     t3, t3, t4          # t3 = ... ^ (v1 + sum)
    srl     t4, t1, 5           # t4 = v1 >> 5
    lw      t5, 4(s1)           # t5 = key[1]
    add     t4, t4, t5          # t4 = (v1 >> 5) + key[1]
    xor     t3, t3, t4          # t3 = ... ^ ((v1 >> 5) + key[1])
    add     t0, t0, t3          # v0 += ...

    # v1 += ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])
    sll     t3, t0, 4           # t3 = v0 << 4
    lw      t4, 8(s1)           # t4 = key[2]
    add     t3, t3, t4          # t3 = (v0 << 4) + key[2]
    add     t4, t0, s2          # t4 = v0 + sum
    xor     t3, t3, t4          # t3 = ... ^ (v0 + sum)
    srl     t4, t0, 5           # t4 = v0 >> 5
    lw      t5, 12(s1)          # t5 = key[3]
    add     t4, t4, t5          # t4 = (v0 >> 5) + key[3]
    xor     t3, t3, t4          # t3 = ... ^ ((v0 >> 5) + key[3])
    add     t1, t1, t3          # v1 += ...

    addi    s3, s3, -1          # contador--
    bnez    s3, loop_encrypt

    sw      t0, 0(s0)           # v[0] = v0
    sw      t1, 4(s0)           # v[1] = v1

    lw      s0, 0(sp)
    lw      s1, 4(sp)
    lw      s2, 8(sp)
    lw      s3, 12(sp)
    addi    sp, sp, 16
    ret

;Decrypt function

.globl tea_decrypt_asm

tea_decrypt_asm:
    addi    sp, sp, -16         # Reserva espacio en stack
    sw      s0, 0(sp)
    sw      s1, 4(sp)
    sw      s2, 8(sp)
    sw      s3, 12(sp)

    mv      s0, a0              # s0 = v (puntero a datos)
    mv      s1, a1              # s1 = key (puntero a clave)
    li      s3, 32              # s3 = contador de iteraciones

    li      t2, 0x9e3779b9      # t2 = DELTA
    li      t3, 32
    mul     s2, t2, t3          # s2 = sum = DELTA * 32

    lw      t0, 0(s0)           # t0 = v0 = v[0]
    lw      t1, 4(s0)           # t1 = v1 = v[1]

loop_decrypt:
    # v1 -= ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])
    sll     t4, t0, 4           # t4 = v0 << 4
    lw      t5, 8(s1)           # t5 = key[2]
    add     t4, t4, t5          # t4 = (v0 << 4) + key[2]
    add     t5, t0, s2          # t5 = v0 + sum
    xor     t4, t4, t5          # t4 = ... ^ (v0 + sum)
    srl     t5, t0, 5           # t5 = v0 >> 5
    lw      t6, 12(s1)          # t6 = key[3]
    add     t5, t5, t6          # t5 = (v0 >> 5) + key[3]
    xor     t4, t4, t5          # t4 = ... ^ ((v0 >> 5) + key[3])
    sub     t1, t1, t4          # v1 -= ...

    # v0 -= ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])
    sll     t4, t1, 4           # t4 = v1 << 4
    lw      t5, 0(s1)           # t5 = key[0]
    add     t4, t4, t5          # t4 = (v1 << 4) + key[0]
    add     t5, t1, s2          # t5 = v1 + sum
    xor     t4, t4, t5          # t4 = ... ^ (v1 + sum)
    srl     t5, t1, 5           # t5 = v1 >> 5
    lw      t6, 4(s1)           # t6 = key[1]
    add     t5, t5, t6          # t5 = (v1 >> 5) + key[1]
    xor     t4, t4, t5          # t4 = ... ^ ((v1 >> 5) + key[1])
    sub     t0, t0, t4          # v0 -= ...

    li      t4, 0x9e3779b9      # t4 = DELTA
    sub     s2, s2, t4          # sum -= DELTA

    addi    s3, s3, -1          # contador--
    bnez    s3, loop_decrypt

    sw      t0, 0(s0)           # v[0] = v0
    sw      t1, 4(s0)           # v[1] = v1

    lw      s0, 0(sp)
    lw      s1, 4(sp)
    lw      s2, 8(sp)
    lw      s3, 12(sp)
    addi    sp, sp, 16
    ret