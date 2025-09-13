
// Simple C program that calls assembly function
// This demonstrates C+assembly integration in RISC-V
#include <stdint.h>

// Functions defined in C and Assembly
extern int sum_to_n(int n);
// TEA functions in Assembly
extern void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4]);
extern void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4]);
// TEA functions in C
extern void tea_encrypt(uint32_t v[2], const uint32_t key[4]);
extern void tea_decrypt(uint32_t v[2], const uint32_t key[4]);

// Simple implementation of basic functions since we're in bare-metal environment
void print_char(char c) {
    // In a real bare-metal environment, this would write to UART
    // For now, this is just a placeholder
    volatile char *uart = (volatile char*)0x10000000;
    *uart = c;
}

void print_number(int num) {
    if (num == 0) {
        print_char('0');
        return;
    }
    
    if (num < 0) {
        print_char('-');
        num = -num;
    }
    
    char buffer[10];
    int i = 0;
    
    while (num > 0) {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    }
    
    // Print digits in reverse order
    while (i > 0) {
        print_char(buffer[--i]);
    }
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

void print_unsigned(uint32_t num) {
    if (num == 0) {
        print_char('0');
        return;
    }
    char buffer[10];
    int i = 0;
    while (num > 0) {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    }
    while (i > 0) {
        print_char(buffer[--i]);
    }
}


// print a 64-bit (8 bytes) block in hexadecimal
void print_block_hex(uint32_t v[2]) {
    for (int i = 0; i < 2; i++) {
        for (int j = 28; j >= 0; j -= 4) {
            uint8_t nibble = (v[i] >> j) & 0xF;
            print_char(nibble < 10 ? '0' + nibble : 'A' + (nibble - 10));
        }
        print_char(' ');
    }
}

// Procees a string block: padding, encryption, decryption
void process_string(const char* str, uint32_t key[4]) {
    print_string("Original block: ");
    print_string(str);
    print_string("\n");

    int len = 0;
    while (str[len]) len++;
    int blocks = (len + 7) / 8;

    for (int b = 0; b < blocks; b++) {
        uint8_t block[8] = {0};
        for (int i = 0; i < 8; i++) {
            int idx = b * 8 + i;
            if (idx < len) block[i] = str[idx];
        }
        uint32_t v[2];
        v[0] = ((uint32_t)block[0]) | ((uint32_t)block[1] << 8) | ((uint32_t)block[2] << 16) | ((uint32_t)block[3] << 24);
        v[1] = ((uint32_t)block[4]) | ((uint32_t)block[5] << 8) | ((uint32_t)block[6] << 16) | ((uint32_t)block[7] << 24);

        print_string("Block: ");
        print_block_hex(v);
        print_string("\n");

        tea_encrypt_asm(v, key);
        print_string("Encrypted: ");
        print_block_hex(v);
        print_string("\n");

        tea_decrypt_asm(v, key);
        print_string("Decrypted: ");

        //Show padding with '_' character
        for (int i = 0; i < 4; i++) {
            char c = (v[0] >> (i * 8)) & 0xFF;
            if (c == 0) print_char('_');
            else print_char(c);
        }
        for (int i = 0; i < 4; i++) {
            char c = (v[1] >> (i * 8)) & 0xFF;
            if (c == 0) print_char('_');
            else print_char(c);
        }
        print_string("\n");
    }
}


void main() {
    //----------------Tests TEA functions in C---------//
    /*
    // Test TEA encryption/decryption (C)
    uint32_t v[2] = {12345, 67890}; // Bloque de datos
    uint32_t key[4] = {1, 2, 3, 4}; // Clave de 128 bits

    print_string("Testing TEA encryption/decryption (C):\n");
    print_string("Original: ");
    print_unsigned(v[0]);
    print_string(", ");
    print_unsigned(v[1]);
    print_string("\n");

    tea_encrypt(v, key);

    print_string("Encrypted: ");
    print_unsigned(v[0]);
    print_string(", ");
    print_unsigned(v[1]);
    print_string("\n");

    tea_decrypt(v, key);

    print_string("Decrypted: ");
    print_unsigned(v[0]);
    print_string(", ");
    print_unsigned(v[1]);
    print_string("\n");

    // Test TEA encryption/decryption (ASM)
    uint32_t v_asm[2] = {12345, 67890};

    print_string("\nTesting TEA encryption/decryption (ASM):\n");
    print_string("Original: ");
    print_unsigned(v_asm[0]);
    print_string(", ");
    print_unsigned(v_asm[1]);
    print_string("\n");

    tea_encrypt_asm(v_asm, key);

    print_string("Encrypted: ");
    print_unsigned(v_asm[0]);
    print_string(", ");
    print_unsigned(v_asm[1]);
    print_string("\n");

    tea_decrypt_asm(v_asm, key);

    print_string("Decrypted: ");
    print_unsigned(v_asm[0]);
    print_string(", ");
    print_unsigned(v_asm[1]);
    print_string("\n");
    */

    
    //-------------Tests TEA functions in ASM with padding--------- //
    //Test 1: Bloque unico
    print_string("\nTest 1: Unique block\n");
    const char* prueba1 = "HOLA1234";
    uint32_t clave1[4] = {0x12345678, 0x9ABCDEF0, 0xFEDCBA98, 0x76543210};
    process_string(prueba1, clave1);

    //Test 2: Multiples bloques
    print_string("\nTest 2: MMultiple blocks\n");
    const char* prueba2 = "Mensaje de prueba para TEA";
    uint32_t clave2[4] = {0xA1B2C3D4, 0x1A2B3C4D, 0xDEADBEEF, 0xCAFEBABE};
    process_string(prueba2, clave2);        

   //Test blocks 

   print_string("\n Other Tests blocks\n");
    const char* test_strings[] = {
        "Hello world",
        "TEA RISC-V",
        "12345678",
        "Long test to show padding",
        "31/08/1997/02/08/2014",
        "@#$&/()=?¿!¡*+~^[]{}<>;:.,-_"
    };
    int num_tests = 6;
    uint32_t key[4] = {1, 2, 3, 4}; // key 128
    for (int t = 0; t < num_tests; t++) {
        print_string("\n-----------\n");
        process_string(test_strings[t], key);
    }

    // Infinite loop to keep program running
    while (1) {
        __asm__ volatile ("nop");
    }
}