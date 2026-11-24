#ifndef HISION_SOC_H
#define HISION_SOC_H
#include <stdint.h>
#include "hision_soc_map.h"

static inline void soc_fence(void) { __asm__ volatile ("fence iorw, iorw" ::: "memory"); }
static inline uint32_t soc_read32(uintptr_t address) {
    soc_fence();
    uint32_t value = *(volatile uint32_t *)address;
    soc_fence();
    return value;
}
static inline void soc_write32(uintptr_t address, uint32_t value) {
    soc_fence();
    *(volatile uint32_t *)address = value;
    soc_fence();
}
static inline uint64_t soc_cycles(void) {
    uint64_t value;
    __asm__ volatile ("rdcycle %0" : "=r"(value));
    return value;
}
void soc_uart_init(void);
void soc_putchar(char ch);
void soc_puts(const char *text);
int soc_getchar_nonblock(void);
void soc_led_write(uint32_t lit_mask);
#endif
