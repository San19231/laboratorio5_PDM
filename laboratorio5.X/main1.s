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
  
reset_tmr0 macro tmr_var
     banksel    TMR0
    movlw	    tmr_var
    movwf	    TMR0
    bcf	    T0IF
endm
PSECT udata_shr
    w_temp: DS 1
    s_temp: DS 1
PSECT	udata_bank0
    cero:	DS 1
    dividendo:	DS 1
    centenas:	DS 1
    decenas:	DS 1
    unidades:	DS 1
    banderas:	DS 3
    display:	DS 3
PSECT resvect, class=code,abs ,delta=2
ORG 00h
    resetVec:
    PAGESEL main
    goto main
PSECT intvect, class=code,abs,delta=2
ORG 04H
push:
    movwf w_temp
    swapf STATUS,W
    movwf s_temp
isr:
    reset_tmr0	217
    call    mostrar_valor
pop:
    swapf   s_temp,w
    movwf   STATUS
    swapf   w_temp, F
    swapf   w_temp, W
    retfie
    
 


