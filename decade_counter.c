#include <avr/io.h>
#include <util/delay.h>

int main(void) {
    // Configure DDRD: Pins PD2..PD5 as inputs (0), PD6..PD7 as outputs (1)
    DDRD &= ~((1 << DDD2) | (1 << DDD3) | (1 << DDD4) | (1 << DDD5));
    DDRD |= (1 << DDD6) | (1 << DDD7);

    // Configure DDRB: Pins PB0, PB1, PB5 as outputs (1)
    DDRB |= (1 << DDB0) | (1 << DDB1) | (1 << DDB5);

    // Initialize clock signal (PB5) low
    PORTB &= ~(1 << PORTB5);

    while (1) {
        // Read input states A, B, C, D from PIND (PD2..PD5)
        uint8_t input_port = PIND;
        uint8_t A = (input_port >> DDD2) & 0x01;
        uint8_t B = (input_port >> DDD3) & 0x01;
        uint8_t C = (input_port >> DDD4) & 0x01;
        uint8_t D = (input_port >> DDD5) & 0x01;

        // Apply K-Map Boolean Logic
        uint8_t W = !A;
        uint8_t X = (B & !A) | (!D & !B & A);
        uint8_t Y = (C & !A) | (C & !B) | (!C & B & A);
        uint8_t Z = (D & !A) | (A & B & C);

        // Map W -> PD6, X -> PD7
        uint8_t portd_val = (W << PORTD6) | (X << PORTD7);
        PORTD = (PORTD & 0x3F) | portd_val;

        // Map Y -> PB0, Z -> PB1
        uint8_t portb_val = (Y << PORTB0) | (Z << PORTB1);
        PORTB = (PORTB & 0xFC) | portb_val;

        // Trigger Clock Rising Edge (PB5 / D13)
        PORTB |= (1 << PORTB5);
        _delay_ms(500);

        // Reset Clock Signal Low
        PORTB &= ~(1 << PORTB5);
        _delay_ms(500);
    }

    return 0;
}
