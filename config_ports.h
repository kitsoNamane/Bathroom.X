/* 
 * File:   config_ports.h
 * Author: kitso
 *
 * Created on July 20, 2019, 1:07 PM
 */

#ifndef CONFIG_PORTS_H
#define	CONFIG_PORTS_H

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
#endif	/* CONFIG_PORTS_H */

