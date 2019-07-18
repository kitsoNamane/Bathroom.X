#include "config.h"

#define _XTAL_FREQ 8000000

#define BLINK PORTBbits.RB2
#define FLUSH PORTBbits.RB3
#define COUNTER PORTBbits.RB4
#define OPEN PORTBbits.RB5
#define FAULT PORTBbits.RB6
#define OKAY PORTBbits.RB7

#define EN PORTCbits.RC0
#define RS PORTCbits.RC1
#define D4 PORTAbits.RA0
#define D5 PORTAbits.RA1
#define D6 PORTAbits.RA2
#define D7 PORTAbits.RA3

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

void input_config(void) {
    TRISBbits.TRISB0 = 1;
    TRISBbits.TRISB1 = 1;
    TRISAbits.TRISA4 = 1;
}

void output_config(void) {
    // configure LCD data output lanes
    TRISAbits.TRISA0 = 0;
    TRISAbits.TRISA1 = 0;
    TRISAbits.TRISA2 = 0;
    TRISAbits.TRISA3 = 0;

    TRISBbits.TRISB2 = 0; // Blink
    TRISBbits.TRISB3 = 0; // Flush
    //TRISBbits.TRISB4 = 0; // Counter
    TRISBbits.TRISB5 = 0; // Open valve
    TRISBbits.TRISB6 = 0; // Fault detected
    TRISBbits.TRISB7 = 0; // Okay

    
    TRISCbits.TRISC0 = 0;
    TRISCbits.TRISC1 = 0;
    TRISCbits.TRISC2 = 0;
    TRISCbits.TRISC6 = 0;
    TRISCbits.TRISC7 = 0;
    return;
}

void interrupt_config(void) {
    // enable INT0, INT1 and TMR0 overflow interrupts
    INTCONbits.INT0IE = 1;
    INTCONbits.TMR0IE = 1;
    INTCON3bits.INT1E = 1;
    
    // interrupt edge trigger selection
    INTCON2bits.INTEDG0 = 1;
    INTCON2bits.INTEDG1 = 1;
    
    // set TMR0 overflow & INT1 interrupt bits to high priority
    INTCON2bits.TMR0IP = 1;
    INTCON3bits.INT1P = 1;
    
    //INTCONbits.TMR0IF = 0;
    //INTCONbits.INT0IF = 0;
    //INTCON3bits.INT1F = 0;
    // Enable Global Interrupts
    INTCONbits.GIE = 1;
    return;
}

void timer_config(void) {
    // configure TMR0 as a counter
    // in 16-bit mode, no prescaler
    // and using RA6/T0CKI as input clock
    T0CONbits.PSA = 1;
    T0CONbits.T0SE = 0;
    T0CONbits.T0CS = 1;
    T0CONbits.T08BIT = 0;
    
    T0CONbits.TMR0ON = 0;
    return;
}


int main(void) {
    input_config();
    output_config();
    interrupt_config();
    timer_config();
    PORTB = 0x00;
    PORTA = 0x00;
    while(1) {
        BLINK = ~BLINK;
        __delay_ms(200);
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
    level_isr();
    INTCONbits.TMR0IF = 0;
    INTCONbits.GIE = 1;
    return;
}


