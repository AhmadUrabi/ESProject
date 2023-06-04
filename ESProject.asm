
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;ESProject.c,13 :: 		void interrupt(void)
;ESProject.c,16 :: 		if (INTCON & 0x04)
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt0
;ESProject.c,18 :: 		TMR0 = 248;
	MOVLW      248
	MOVWF      TMR0+0
;ESProject.c,19 :: 		Mcntr++;
	INCF       _Mcntr+0, 1
	BTFSC      STATUS+0, 2
	INCF       _Mcntr+1, 1
;ESProject.c,20 :: 		INTCON = INTCON & 0xFB; // clear T0IF
	MOVLW      251
	ANDWF      INTCON+0, 1
;ESProject.c,21 :: 		}
L_interrupt0:
;ESProject.c,24 :: 		if (PIR1 & 0x04)
	BTFSS      PIR1+0, 2
	GOTO       L_interrupt1
;ESProject.c,26 :: 		if (HL) { // Manage High Signal
	MOVF       _HL+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt2
;ESProject.c,27 :: 		CCPR1H = angle >> 8;
	MOVF       _angle+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;ESProject.c,28 :: 		CCPR1L = angle;
	MOVF       _angle+0, 0
	MOVWF      CCPR1L+0
;ESProject.c,29 :: 		HL = 0;         // next time low
	CLRF       _HL+0
;ESProject.c,30 :: 		CCP1CON = 0x09; // next time Falling edge
	MOVLW      9
	MOVWF      CCP1CON+0
;ESProject.c,31 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;ESProject.c,32 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;ESProject.c,33 :: 		}
	GOTO       L_interrupt3
L_interrupt2:
;ESProject.c,35 :: 		CCPR1H = (40000 - angle) >> 8;
	MOVF       _angle+0, 0
	SUBLW      64
	MOVWF      R3+0
	MOVF       _angle+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      156
	MOVWF      R3+1
	MOVF       R3+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;ESProject.c,36 :: 		CCPR1L = (40000 - angle);
	MOVF       R3+0, 0
	MOVWF      CCPR1L+0
;ESProject.c,37 :: 		CCP1CON = 0x08; // next time rising edge
	MOVLW      8
	MOVWF      CCP1CON+0
;ESProject.c,38 :: 		HL = 1;         // next time High
	MOVLW      1
	MOVWF      _HL+0
;ESProject.c,39 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;ESProject.c,40 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;ESProject.c,41 :: 		}
L_interrupt3:
;ESProject.c,43 :: 		PIR1 = PIR1 & 0xFB; // clear CCP1IF
	MOVLW      251
	ANDWF      PIR1+0, 1
;ESProject.c,44 :: 		}
L_interrupt1:
;ESProject.c,47 :: 		if (PIR1 & 0x01)
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt4
;ESProject.c,49 :: 		PIR1 = PIR1 & 0xFE;
	MOVLW      254
	ANDWF      PIR1+0, 1
;ESProject.c,50 :: 		}
L_interrupt4:
;ESProject.c,51 :: 		}
L_end_interrupt:
L__interrupt17:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;ESProject.c,53 :: 		void main()
;ESProject.c,56 :: 		TRISA = 0x0F; // RA0, RA1, RA2, RA3 as input
	MOVLW      15
	MOVWF      TRISA+0
;ESProject.c,57 :: 		TRISC = 0x00; // RC0, RC1, RC2, RC3 as output (Only RC2 is used)
	CLRF       TRISC+0
;ESProject.c,60 :: 		HL = 1;
	MOVLW      1
	MOVWF      _HL+0
;ESProject.c,62 :: 		OPTION_REG = 0x87; // Fosc/4 with 256 prescaler => increment every 0.5us*256=128us ==> overflow 8count*128us=1ms to overflow
	MOVLW      135
	MOVWF      OPTION_REG+0
;ESProject.c,63 :: 		TMR0 = 248;        // Start from 248, will count to 255 and overflow to 0, then interrupt will occur
	MOVLW      248
	MOVWF      TMR0+0
;ESProject.c,66 :: 		CCP1CON = 0x08;
	MOVLW      8
	MOVWF      CCP1CON+0
;ESProject.c,67 :: 		T1CON = 0x01;      // TMR1 On Fosc/4 (inc 0.5uS) with 0 prescaler (TMR1 overflow after 0xFFFF counts ==65535)==> 32.767ms
	MOVLW      1
	MOVWF      T1CON+0
;ESProject.c,68 :: 		PIE1 = PIE1 | 0x04; // Enable CCP1 interrupts
	BSF        PIE1+0, 2
;ESProject.c,69 :: 		CCPR1H = 3000 >> 8;
	MOVLW      11
	MOVWF      CCPR1H+0
;ESProject.c,70 :: 		CCPR1L = 3000;
	MOVLW      184
	MOVWF      CCPR1L+0
;ESProject.c,73 :: 		INTCON = 0xF0; // enable TMR0 overflow, TMR1 overflow, External interrupts and peripheral interrupts;
	MOVLW      240
	MOVWF      INTCON+0
;ESProject.c,76 :: 		ADCON1 = 0xC8; // Sets all Port A pins as analog input
	MOVLW      200
	MOVWF      ADCON1+0
;ESProject.c,77 :: 		ADCON0 = 0x41;
	MOVLW      65
	MOVWF      ADCON0+0
;ESProject.c,79 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;ESProject.c,80 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;ESProject.c,83 :: 		angle = 3000;
	MOVLW      184
	MOVWF      _angle+0
	MOVLW      11
	MOVWF      _angle+1
;ESProject.c,93 :: 		while (1)
L_main5:
;ESProject.c,96 :: 		ADCON0 = ADCON0 & 0xC7; // Start ADC conversion on LDR1
	MOVLW      199
	ANDWF      ADCON0+0, 1
;ESProject.c,97 :: 		ldr1_value = ADCRead();
	CALL       _ADCRead+0
	MOVF       R0+0, 0
	MOVWF      _ldr1_value+0
	MOVF       R0+1, 0
	MOVWF      _ldr1_value+1
;ESProject.c,100 :: 		ADCON0 = ADCON0 & 0xC7; // Reset channel selection
	MOVLW      199
	ANDWF      ADCON0+0, 1
;ESProject.c,101 :: 		ADCON0 = ADCON0 | 0x08; // Start ADC conversion on LDR2
	BSF        ADCON0+0, 3
;ESProject.c,102 :: 		ldr2_value = ADCRead();
	CALL       _ADCRead+0
	MOVF       R0+0, 0
	MOVWF      _ldr2_value+0
	MOVF       R0+1, 0
	MOVWF      _ldr2_value+1
;ESProject.c,104 :: 		lightThreshold = 20; // Threshold for light difference
	MOVLW      20
	MOVWF      _lightThreshold+0
	MOVLW      0
	MOVWF      _lightThreshold+1
;ESProject.c,107 :: 		if (ldr1_value > ldr2_value + lightThreshold)
	MOVLW      20
	ADDWF      R0+0, 0
	MOVWF      R2+0
	MOVF       R0+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDLW      0
	MOVWF      R2+1
	MOVF       _ldr1_value+1, 0
	SUBWF      R2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main19
	MOVF       _ldr1_value+0, 0
	SUBWF      R2+0, 0
L__main19:
	BTFSC      STATUS+0, 0
	GOTO       L_main7
;ESProject.c,109 :: 		if (angle - 50 > 2250) // 2250 is the minimum angle
	MOVLW      50
	SUBWF      _angle+0, 0
	MOVWF      R1+0
	MOVLW      0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      _angle+1, 0
	MOVWF      R1+1
	MOVF       R1+1, 0
	SUBLW      8
	BTFSS      STATUS+0, 2
	GOTO       L__main20
	MOVF       R1+0, 0
	SUBLW      202
L__main20:
	BTFSC      STATUS+0, 0
	GOTO       L_main8
;ESProject.c,111 :: 		angle -= 50;
	MOVLW      50
	SUBWF      _angle+0, 1
	BTFSS      STATUS+0, 0
	DECF       _angle+1, 1
;ESProject.c,112 :: 		};
L_main8:
;ESProject.c,113 :: 		}
	GOTO       L_main9
L_main7:
;ESProject.c,114 :: 		else if (ldr2_value > ldr1_value + lightThreshold)
	MOVF       _lightThreshold+0, 0
	ADDWF      _ldr1_value+0, 0
	MOVWF      R1+0
	MOVF       _ldr1_value+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _lightThreshold+1, 0
	MOVWF      R1+1
	MOVF       _ldr2_value+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main21
	MOVF       _ldr2_value+0, 0
	SUBWF      R1+0, 0
L__main21:
	BTFSC      STATUS+0, 0
	GOTO       L_main10
;ESProject.c,116 :: 		if (angle + 50 < 3750) // 3750 is the maximum angle
	MOVLW      50
	ADDWF      _angle+0, 0
	MOVWF      R1+0
	MOVF       _angle+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	MOVWF      R1+1
	MOVLW      14
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main22
	MOVLW      166
	SUBWF      R1+0, 0
L__main22:
	BTFSC      STATUS+0, 0
	GOTO       L_main11
;ESProject.c,118 :: 		angle += 50;
	MOVLW      50
	ADDWF      _angle+0, 1
	BTFSC      STATUS+0, 0
	INCF       _angle+1, 1
;ESProject.c,119 :: 		}
L_main11:
;ESProject.c,120 :: 		}
L_main10:
L_main9:
;ESProject.c,123 :: 		myDelay(200);
	MOVLW      200
	MOVWF      FARG_myDelay_x+0
	CLRF       FARG_myDelay_x+1
	CALL       _myDelay+0
;ESProject.c,124 :: 		}
	GOTO       L_main5
;ESProject.c,125 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_myDelay:

;ESProject.c,127 :: 		void myDelay(unsigned int x)
;ESProject.c,129 :: 		Mcntr = 0;
	CLRF       _Mcntr+0
	CLRF       _Mcntr+1
;ESProject.c,130 :: 		while (Mcntr < x){}; // Loop until Mcntr reaches x, Mcntr is incremented every 1ms
L_myDelay12:
	MOVF       FARG_myDelay_x+1, 0
	SUBWF      _Mcntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__myDelay24
	MOVF       FARG_myDelay_x+0, 0
	SUBWF      _Mcntr+0, 0
L__myDelay24:
	BTFSC      STATUS+0, 0
	GOTO       L_myDelay13
	GOTO       L_myDelay12
L_myDelay13:
;ESProject.c,131 :: 		}
L_end_myDelay:
	RETURN
; end of _myDelay

_ADCRead:

;ESProject.c,133 :: 		unsigned int ADCRead() // Read ADC value
;ESProject.c,135 :: 		myDelay(30);
	MOVLW      30
	MOVWF      FARG_myDelay_x+0
	MOVLW      0
	MOVWF      FARG_myDelay_x+1
	CALL       _myDelay+0
;ESProject.c,136 :: 		ADCON0 = ADCON0 | 0x04;
	BSF        ADCON0+0, 2
;ESProject.c,137 :: 		while (ADCON0 & 0x04){}; // Wait for ADC conversion to finish
L_ADCRead14:
	BTFSS      ADCON0+0, 2
	GOTO       L_ADCRead15
	GOTO       L_ADCRead14
L_ADCRead15:
;ESProject.c,138 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;ESProject.c,139 :: 		}
L_end_ADCRead:
	RETURN
; end of _ADCRead
