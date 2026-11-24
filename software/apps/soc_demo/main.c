#include "soc.h"

int main(void) {
    soc_uart_init();
    soc_led_write(0);
    soc_puts("HisionArch / miniXiangShan CPU SoC\n");
    soc_puts("DDR boot via JTAG. UART echo ready; LED0 is the heartbeat.\n");
    uint32_t clock_hz = soc_read32(HISION_SYSCTRL_BASE + HISION_SYS_CLOCK_HZ_OFFSET);
    uint64_t interval = clock_hz / 2;
    if (!interval) interval = 1;
    uint64_t previous = soc_cycles();
    uint32_t led = 0;
    for (;;) {
        int ch = soc_getchar_nonblock();
        if (ch >= 0) soc_putchar((char)ch);
        uint64_t now = soc_cycles();
        if (now - previous >= interval) {
            previous = now;
            led ^= 1;
            soc_led_write(led);
        }
    }
}
