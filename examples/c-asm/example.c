// Simple C program that calls assembly function
// This demonstrates C+assembly integration in RISC-V
#include <stdint.h>

// Functions defined in C and Assembly
extern int sum_to_n(int n);
extern void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4]);
extern void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4]);
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

// Entry point for C program
void main() {
    // Test the assembly function with different values
    /*int test_values[] = {5, 10, 15, 0, -1};
    int num_tests = 5;
    
    print_string("Testing sum_to_n assembly function:\n");
    
    for (int i = 0; i < num_tests; i++) {
        int n = test_values[i];
        int result = sum_to_n(n);
        
        print_string("sum_to_n(");
        print_number(n);
        print_string(") = ");
        print_number(result);
        print_string("\n");
    }
    
    print_string("Tests completed.\n");*/


    // Test TEA encryption/decryption
    uint32_t v[2] = {12345, 67890}; // Bloque de datos
    uint32_t key[4] = {1, 2, 3, 4}; // Clave de 128 bits

    print_string("Testing TEA encryption/decryption:\n");
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
    print_number(v[0]);
    print_string(", ");
    print_number(v[1]);
    print_string("\n");

    
    // Infinite loop to keep program running
    while (1) {
        __asm__ volatile ("nop");
    }
}