.section .text
.globl tea_encrypt_asm

# Encrypt function
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

    # Cargar claves en registros antes del bucle
    lw      t2, 0(s1)           # t2 = key[0]
    lw      t3, 4(s1)           # t3 = key[1]
    lw      t4, 8(s1)           # t4 = key[2]
    lw      t5, 12(s1)          # t5 = key[3]

    li      t6, 0x9e3779b9      # t6 = DELTA

loop_encrypt:
    add     s2, s2, t6          # sum += DELTA

    # v0 += ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])
    sll     a2, t1, 4           # a2 = v1 << 4
    add     a2, a2, t2          # a2 = (v1 << 4) + key[0]
    add     a3, t1, s2          # a3 = v1 + sum
    xor     a2, a2, a3          # a2 = ... ^ (v1 + sum)
    srl     a3, t1, 5           # a3 = v1 >> 5
    add     a3, a3, t3          # a3 = (v1 >> 5) + key[1]
    xor     a2, a2, a3          # a2 = ... ^ ((v1 >> 5) + key[1])
    add     t0, t0, a2          # v0 += ...

    # v1 += ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])
    sll     a2, t0, 4           # a2 = v0 << 4
    add     a2, a2, t4          # a2 = (v0 << 4) + key[2]
    add     a3, t0, s2          # a3 = v0 + sum
    xor     a2, a2, a3          # a2 = ... ^ (v0 + sum)
    srl     a3, t0, 5           # a3 = v0 >> 5
    add     a3, a3, t5          # a3 = (v0 >> 5) + key[3]
    xor     a2, a2, a3          # a2 = ... ^ ((v0 >> 5) + key[3])
    add     t1, t1, a2          # v1 += ...

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

#Decrypt function

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

    # Cargar claves en registros antes del bucle
    li      t6, 0x9e3779b9      # t6 = DELTA
    li      t2, 32
    mul     s2, t6, t2          # s2 = sum = DELTA * 32

    lw      t0, 0(s0)           # t0 = v0 = v[0]
    lw      t1, 4(s0)           # t1 = v1 = v[1]

    lw      t2, 0(s1)           # t2 = key[0]
    lw      t3, 4(s1)           # t3 = key[1]
    lw      t4, 8(s1)           # t4 = key[2]
    lw      t5, 12(s1)          # t5 = key[3]

loop_decrypt:
    # v1 -= ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])
    sll     a2, t0, 4           # a2 = v0 << 4
    add     a2, a2, t4          # a2 = (v0 << 4) + key[2]
    add     a3, t0, s2          # a3 = v0 + sum
    xor     a2, a2, a3          # a2 = ... ^ (v0 + sum)
    srl     a3, t0, 5           # a3 = v0 >> 5
    add     a3, a3, t5          # a3 = (v0 >> 5) + key[3]
    xor     a2, a2, a3          # a2 = ... ^ ((v0 >> 5) + key[3])
    sub     t1, t1, a2          # v1 -= ...

    # v0 -= ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])
    sll     a2, t1, 4           # a2 = v1 << 4
    add     a2, a2, t2          # a2 = (v1 << 4) + key[0]
    add     a3, t1, s2          # a3 = v1 + sum
    xor     a2, a2, a3          # a2 = ... ^ (v1 + sum)
    srl     a3, t1, 5           # a3 = v1 >> 5
    add     a3, a3, t3          # a3 = (v1 >> 5) + key[1]
    xor     a2, a2, a3          # a2 = ... ^ ((v1 >> 5) + key[1])
    sub     t0, t0, a2          # v0 -= ...

    sub     s2, s2, t6          # sum -= DELTA

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
    