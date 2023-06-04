#line 1 "C:/Users/ahmad.marwan/Desktop/Project/ESProject.c"

unsigned int angle;
unsigned char HL;
unsigned int Mcntr;
unsigned int ldr1_value;
unsigned int ldr2_value;
unsigned int lightThreshold;


void myDelay(unsigned int x);
unsigned int ADCRead();

void interrupt(void)
{

 if (INTCON & 0x04)
 {
 TMR0 = 248;
 Mcntr++;
 INTCON = INTCON & 0xFB;
 }


 if (PIR1 & 0x04)
 {
 if (HL) {
 CCPR1H = angle >> 8;
 CCPR1L = angle;
 HL = 0;
 CCP1CON = 0x09;
 TMR1H = 0;
 TMR1L = 0;
 }
 else {
 CCPR1H = (40000 - angle) >> 8;
 CCPR1L = (40000 - angle);
 CCP1CON = 0x08;
 HL = 1;
 TMR1H = 0;
 TMR1L = 0;
 }

 PIR1 = PIR1 & 0xFB;
 }


 if (PIR1 & 0x01)
 {
 PIR1 = PIR1 & 0xFE;
 }
}

void main()
{

 TRISA = 0x0F;
 TRISC = 0x00;


 HL = 1;

 OPTION_REG = 0x87;
 TMR0 = 248;


 CCP1CON = 0x08;
 T1CON = 0x01;
 PIE1 = PIE1 | 0x04;
 CCPR1H = 3000 >> 8;
 CCPR1L = 3000;


 INTCON = 0xF0;


 ADCON1 = 0xC8;
 ADCON0 = 0x41;

 TMR1H = 0;
 TMR1L = 0;


 angle = 3000;
#line 93 "C:/Users/ahmad.marwan/Desktop/Project/ESProject.c"
 while (1)
 {

 ADCON0 = ADCON0 & 0xC7;
 ldr1_value = ADCRead();


 ADCON0 = ADCON0 & 0xC7;
 ADCON0 = ADCON0 | 0x08;
 ldr2_value = ADCRead();

 lightThreshold = 20;


 if (ldr1_value > ldr2_value + lightThreshold)
 {
 if (angle - 50 > 2250)
 {
 angle -= 50;
 };
 }
 else if (ldr2_value > ldr1_value + lightThreshold)
 {
 if (angle + 50 < 3750)
 {
 angle += 50;
 }
 }


 myDelay(200);
 }
}

void myDelay(unsigned int x)
{
 Mcntr = 0;
 while (Mcntr < x){};
}

unsigned int ADCRead()
{
 myDelay(30);
 ADCON0 = ADCON0 | 0x04;
 while (ADCON0 & 0x04){};
 return ((ADRESH << 8) | ADRESL);
}
