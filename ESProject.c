// Value Initializations
unsigned int angle;
unsigned char HL;
unsigned int Mcntr;
unsigned int ldr1_value;
unsigned int ldr2_value;
unsigned int lightThreshold;

// Function Prototypes
void myDelay(unsigned int x);
unsigned int ADCRead();

void interrupt(void)
{
  //TMR0 overflow
  if (INTCON & 0x04)
  { // will get here every 1ms
    TMR0 = 248;
    Mcntr++;
    INTCON = INTCON & 0xFB; // clear T0IF
  }

  // CCP1 interrupt
  if (PIR1 & 0x04)
  {
    if (HL) { // Manage High Signal
      CCPR1H = angle >> 8;
      CCPR1L = angle;
      HL = 0;         // next time low
      CCP1CON = 0x09; // next time Falling edge
      TMR1H = 0;
      TMR1L = 0;
    }
    else { // Manage Low Signal
      CCPR1H = (40000 - angle) >> 8;
      CCPR1L = (40000 - angle);
      CCP1CON = 0x08; // next time rising edge
      HL = 1;         // next time High
      TMR1H = 0;
      TMR1L = 0;
    }

    PIR1 = PIR1 & 0xFB; // clear CCP1IF
  }

  // TMR1 overflow
  if (PIR1 & 0x01)
  {
    PIR1 = PIR1 & 0xFE;
  }
}

void main()
{
  // Configure LDR pin directions
  TRISA = 0x0F; // RA0, RA1, RA2, RA3 as input
  TRISC = 0x00; // RC0, RC1, RC2, RC3 as output (Only RC2 is used)

  // HL = 1; Start with high signal
  HL = 1;

  OPTION_REG = 0x87; // Fosc/4 with 256 prescaler => increment every 0.5us*256=128us ==> overflow 8count*128us=1ms to overflow
  TMR0 = 248;        // Start from 248, will count to 255 and overflow to 0, then interrupt will occur

  // Configure CCP1
  CCP1CON = 0x08;
  T1CON = 0x01;      // TMR1 On Fosc/4 (inc 0.5uS) with 0 prescaler (TMR1 overflow after 0xFFFF counts ==65535)==> 32.767ms
  PIE1 = PIE1 | 0x04; // Enable CCP1 interrupts
  CCPR1H = 3000 >> 8;
  CCPR1L = 3000;

  // Configure interrupts
  INTCON = 0xF0; // enable TMR0 overflow, TMR1 overflow, External interrupts and peripheral interrupts;

  // Initialize ADC
  ADCON1 = 0xC8; // Sets all Port A pins as analog input
  ADCON0 = 0x41;

  TMR1H = 0;
  TMR1L = 0;

  // Initialize servo to 40 degrees
  angle = 3000;

  /*
  20ms period
  Neutral: 40 degrees
  Duty Cycle: 0.5ms - 2.5ms
  Angle: 0 - 270

  */

  while (1)
  {
    // Read analog values from LDR1
    ADCON0 = ADCON0 & 0xC7; // Start ADC conversion on LDR1
    ldr1_value = ADCRead();

    // Read analog values from LDR2
    ADCON0 = ADCON0 & 0xC7; // Reset channel selection
    ADCON0 = ADCON0 | 0x08; // Start ADC conversion on LDR2
    ldr2_value = ADCRead();

    lightThreshold = 20; // Threshold for light difference

    // Determine the direction with the most light
    if (ldr1_value > ldr2_value + lightThreshold)
    {
      if (angle - 50 > 2250) // 2250 is the minimum angle
      {
        angle -= 50;
      };
    }
    else if (ldr2_value > ldr1_value + lightThreshold)
    {
      if (angle + 50 < 3750) // 3750 is the maximum angle
      {
        angle += 50;
      }
    }

    // Delay before reading the LDRs again
    myDelay(200);
  }
}

void myDelay(unsigned int x)
{
  Mcntr = 0;
  while (Mcntr < x){}; // Loop until Mcntr reaches x, Mcntr is incremented every 1ms
}

unsigned int ADCRead() // Read ADC value
{
  myDelay(30);
  ADCON0 = ADCON0 | 0x04;
  while (ADCON0 & 0x04){}; // Wait for ADC conversion to finish
  return ((ADRESH << 8) | ADRESL);
}
