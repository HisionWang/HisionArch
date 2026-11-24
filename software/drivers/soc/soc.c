#include "soc.h"

void soc_uart_init(void) {
    /* Reset RX/TX FIFO, leave interrupts disabled; baud is a Vivado IP setting. */
    soc_write32(HISION_UART_BASE + HISION_UART_CONTROL_OFFSET, 3);
}
void soc_putchar(char ch) {
    while (soc_read32(HISION_UART_BASE + HISION_UART_STATUS_OFFSET) & 8) { }
    soc_write32(HISION_UART_BASE + HISION_UART_TX_OFFSET, (unsigned char)ch);
}
void soc_puts(const char *text) {
    while (*text) {
        if (*text == '\n') soc_putchar('\r');
        soc_putchar(*text++);
    }
}
int soc_getchar_nonblock(void) {
    if (!(soc_read32(HISION_UART_BASE + HISION_UART_STATUS_OFFSET) & 1)) return -1;
    return soc_read32(HISION_UART_BASE + HISION_UART_RX_OFFSET) & 0xff;
}
void soc_led_write(uint32_t lit_mask) {
    uint32_t cfg = soc_read32(HISION_SYSCTRL_BASE + HISION_SYS_BOARD_IO_OFFSET);
    unsigned width = cfg & 0xff;
    uint32_t mask = width >= 32 ? UINT32_MAX : (UINT32_C(1) << width) - 1;
    if (cfg & 0x100) lit_mask = ~lit_mask;
    soc_write32(HISION_GPIO_BASE + HISION_GPIO_DATA_OFFSET, lit_mask & mask);
}
