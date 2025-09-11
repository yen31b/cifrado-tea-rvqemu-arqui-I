#define DELTA 0x9e3779b9
#include <stdint.h>

void tea_encrypt(uint32_t v[2], const uint32_t key[4]) {
    uint32_t v0 = v[0], v1 = v[1];
    uint32_t sum = 0;
    for (int i = 0; i < 32; ++i) {
        sum += DELTA;
        v0 += ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1]);
        v1 += ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3]);
    }
    v[0] = v0;
    v[1] = v1;
}

void tea_decrypt(uint32_t v[2], const uint32_t key[4]) {
    uint32_t v0 = v[0], v1 = v[1];
    uint32_t sum = DELTA * 32;
    for (int i = 0; i < 32; ++i) {
        v1 -= ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3]);
        v0 -= ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1]);
        sum -= DELTA;
    }
    v[0] = v0;
    v[1] = v1;
}