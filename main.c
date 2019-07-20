#include "config_ports.h"


void flush_isr(void);
void level_isr(void);
void counter_isr(void);
void __interrupt(high_priority) chk_isr(void) {
    if(INTCONbits.INT0IF == 1) {
        flush_isr();
    } else if(INTCON3bits.INT1IF == 1) {
        INTCON3bits.INT1F = 0;
        level_isr();
        INTCONbits.GIE = 1;
    } else if(INTCONbits.TMR0IF == 1) {
        counter_isr();
    }
    return;
}


int main(void) {
    
    input_config();
    output_config();
    interrupt_config();
    timer_config();
    PORTA = 0x00;
    PORTB = 0x00;
    PORTC = 0x00;
    while(1) {
        BLINK = ~BLINK;
        __delay_ms(2000);
    }
    return 0;
}


void open_valve() {
    OPEN = 1;
    TMR0H = 0xFF;
    TMR0L = 0xCF;
    T0CONbits.TMR0ON = 1;
    return;
}

void close_valve() {
    OPEN = 0;
    FLUSH = 0;
    TMR0H = 0xFF;
    TMR0L = 0xCF;
    T0CONbits.TMR0ON = 0;
    return;
}


void flush_isr(void) {
    FLUSH = 1;
    INTCONbits.INT0IF = 0;
    INTCONbits.GIE = 1;
    open_valve();
    return;
}

void level_isr(void) {
    __delay_ms(200);
    if(PORTBbits.RB1  == 0) {
        FAULT = 1;
        OKAY = 0;
    } else if(PORTBbits.RB1 == 1) {
        FAULT = 0;
        OKAY = 1;
    }
    return;
}

void counter_isr(void) {
    close_valve();
    INTCONbits.TMR0IF = 0;
    INTCONbits.GIE = 1;
    return;
}
