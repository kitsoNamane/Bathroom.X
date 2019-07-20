/* 
 * File:   ulcd.h
 * Author: kitso
 *
 * Created on July 20, 2019, 1:12 PM
 */

#ifndef ULCD_H
#define	ULCD_H

void lcd_reset(void) {
    LCD = 0xFF;
    __delay_ms(20);
    LCD = 0x03 + EN;
    LCD = 0x03;
    __delay_ms(10);
    LCD = 0x03 + EN;
    LCD = 0x03;
    __delay_ms(1);
    LCD = 0x03 + EN;
    LCD = 0x03;
    __delay_ms(1);
    LCD = 0x02 + EN;
    LCD = 0x02;
    __delay_ms(1);
    return;
}

void lcd_init(void) {
    lcd_reset();
    lcd_cmd(0x28);
    lcd_cmd(0x0C);
    lcd_cmd(0x06);
    lcd_cmd(0x80);
    return;
}

void lcd_cmd(char cmd) {
    LCD = ((cmd >> 4) & 0x0F) | EN;
    LCD = ((cmd >> 4) & 0x0F);

    LCD = (cmd & 0x0F) | EN;
    LCD = (cmd & 0x0F);

    __delay_us(200);
    __delay_us(200);
    return;
}

void lcd_data(unsigned char dat) {
    LCD = (((dat >> 4) & 0x0F) | EN | RS);
    LCD = (((dat >> 4) & 0x0F) | RS);

    LCD = ((dat & 0x0F)) | EN | RS;
    LCD = ((dat & 0x0F)) | RS;

    __delay_us(200);
    __delay_us(200);
    return;
}

#endif	/* ULCD_H */

