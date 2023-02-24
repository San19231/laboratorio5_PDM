;Archivo:    main.s
;Dispositivo: pic16f887
;Autor: Edgar Sandoval
;Compilador: pic-as(v2.35), MPLAB V6.00
;Programa: Laboatorio#5


PROCESSOR 16F887
    
; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>
PSECT udata_shr
 var:	 DS 1
 flags:  DS 1
 nibble: DS 2
 disp:   DS 2
 cant:	 DS 1
 uni:  DS 1
 dece:  DS 1
 cen:  DS 1
 unidades: DS 1
 decenas: DS 1
 centenas: DS 1  
 w_temp: DS 1
 s_temp: DS 1
input_b	macro
    banksel TRISB
    movlw   0xFF
    movwf   TRISB
    movlw   0b01111111
    andwf	OPTION_REG
    movlw   0xFF
    movwf	WPUB
    endm
reset_tmr0 macro
 banksel PORTA
 movlw	180
 movwf	TMR0
 bcf	T0IF
 endm
PSECT resVect, class=CODE,abs, delta=2
ORG 00h
// vector reset
resetVec:
    PAGESEL main
    goto main
    
PSECT code, delta=2,abs
ORG 04h // posicion del codigo interrupciones
push:
    movwf w_temp
    swapf STATUS,W
    movwf s_temp
isr:
    btfsc   RBIF
    call    inc_dec
    btfsc   T0IF
    call    inter_tmr0
pop:
    swapf   s_temp,w
    movwf   STATUS
    swapf   w_temp, F
    swapf   w_temp, W
    retfie
    
//subrutinas    
inc_dec:
   banksel  PORTA
   btfss    PORTB,0
   incf	    PORTA
   btfss    PORTB,1
   decf	    PORTA
   bcf	    RBIF
   return
   
inter_tmr0:
    reset_tmr0
    clrf    PORTD
    btfss   flags,0
    goto disp0
    btfss   flags,1
    goto disp1
    btfss   flags,2
    goto disp2
    btfss   flags,3
    goto disp3
    btfss   flags,4
    goto disp4
disp0:
    movf    disp,W
    movwf   PORTC
    bsf	    PORTD,4
    bsf	    flags,0
    return
disp1:
    movf    disp + 1,W
    movwf   PORTC
    bsf	    PORTD,3
    bsf	    flags,1
    return
disp2:
    movf    centenas,w
    movwf   PORTC
    bsf	    PORTD,0
    bsf	    flags,2
    return
disp3:
    movf    decenas,w
    movwf   PORTC
    bsf	    PORTD,1
    bsf	    flags,3
    return
disp4:
    movf    unidades,w
    movwf   PORTC
    bsf	    PORTD,2
    clrf    flags
    return
PSECT code, delta=2,abs
ORG 100h // posicion del codigo   
table:
    clrf    PCLATH 
    bsf	    PCLATH,0
    andwf   0x0f
    addwf   PCL
    retlw   0b00111111; 0
    retlw   0b00000110;	1
    retlw   0b01011011;	2
    retlw   0b01001111;	3
    retlw   0b01100110;	4
    retlw   0b01101101;	5
    retlw   0b01111101;	6
    retlw   0b00000111;	7
    retlw   0b01111111;	8
    retlw   0b01100111;	9
    retlw   0b01110111; 10(A)
    retlw   0b01111100; 11(b)
    retlw   0b00111001;	12(C)
    retlw   0b01011110;	13(d)
    retlw   0b01111001;	14(E)
    retlw   0b01110001;	15(F)
main:
    call    conf_pin
    call    conf_reloj
    call    conf_tmr0
    bsf	    GIE
    //config interrupt on change
    bsf	    RBIE
    bcf	    RBIF
    //tmr0
    bsf	    T0IE
    banksel PORTA
loop:
    call    sep_nibbles
    call    a_displays
    movf    PORTA,w
    movwf    var
    movf    PORTA,w
    movwf   cant
    call    cont_cen
    call    cont_dec
    call    cont_uni
    call    show_disp
    goto    loop
   
conf_pin:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    banksel TRISA
    clrf    TRISA
    clrf    TRISB
    bsf	    TRISB,0
    bsf	    TRISB,1
    bcf	    OPTION_REG,7
    bsf	    WPUB,0
    bsf	    WPUB,1
    bsf	    IOCB,0
    bsf	    IOCB,1
    clrf    TRISC
    clrf    TRISD
    bsf	    TRISD,5
    bsf	    TRISD,6
    bsf	    TRISD,7
    input_b
    banksel PORTA
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    return
conf_reloj:
    banksel OSCCON
    bsf	    IRCF2
    bsf	    IRCF1
    bcf	    IRCF0
    bsf	    SCS
    return
conf_tmr0:
    banksel TRISB
    bcf	    T0CS
    bcf	    PSA
    bsf	    PS2
    bsf	    PS1
    bcf	    PS0
    reset_tmr0
    return
sep_nibbles:
    movf    var,w
    andlw   0x0f
    movwf   nibble
    swapf   var,w
    andlw   0x0f
    movwf   nibble+1
    return
a_displays:
    movf    nibble,w
    call    table
    movwf   disp
    movf    nibble+1,w
    call    table
    movwf   disp+1
    return
cont_cen:
    clrf    cen
    movlw   100
    subwf   cant,F
    btfss   STATUS,0
    goto    $+3
    incf    cen
    goto    $-5
    return
cont_dec:
    movlw   100
    addwf   cant
    clrf    dece
    movlw   10
    subwf   cant,F
    btfss   STATUS,0
    goto    $+3
    incf    dece
    goto    $-5
    return
cont_uni:
    movlw   10
    addwf   cant
    clrf    uni
    movf    cant,w
    movwf   uni
    return
show_disp:
    movf    cen,w
    call    table
    movwf   centenas
    movf    dece,w
    call    table
    movwf   decenas
    movf    uni,w
    call    table
    movwf   unidades
    return
END
    
    