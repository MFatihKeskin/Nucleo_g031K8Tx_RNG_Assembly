/* asm.s
*
* Prepared by:
* MUHAMMET FATİH KESKİN - 2020
* Randomized Counter
*
*/

.syntax unified
.cpu cortex-m0plus
.fpu softvfp
.thumb
/* make linker see this */
.global Reset_Handler
/* get these from linker script */
.word _sdata
.word _edata
.word _sbss
.word _ebss
/* define peripheral addresses from RM0444 page 57, Tables 3-4 */
.equ RCC_BASE, (0x40021000) // RCC base address
.equ RCC_IOPENR, (RCC_BASE + (0x34)) // RCC IOPENR register 
offset
.equ GPIOA_BASE, (0x50000000) // GPIOA base address
.equ GPIOA_MODER, (GPIOA_BASE + (0x00)) // GPIOA MODER 
register offset
.equ GPIOA_ODR, (GPIOA_BASE + (0x14)) // GPIOA ODR register 
offset
.equ GPIOA_IDR, (GPIOA_BASE + (0x10)) // GPIOA IDR register 
offset
.equ GPIOB_BASE, (0x50000400) // GPIOB base 
address
.equ GPIOB_MODER, (GPIOB_BASE + (0x00)) // GPIOB MODER 
register offset
.equ GPIOB_ODR, (GPIOB_BASE + (0x14))// GPIOB ODR register 
offset
/* vector table, +1 thumb mode */
.section .vectors
vector_table:
.word _estack /* Stack pointer */
.word Reset_Handler +1 /* Reset handler */
.word Default_Handler +1 /* NMI handler */
.word Default_Handler +1 /* HardFault handler */
/* add rest of them here if needed *//* reset handler */
.section .text
Reset_Handler:
/* set stack pointer */
ldr r0, =_estack
mov sp, r0
/* initialize data and bss
* not necessary for rom only code
* */
bl init_data
/* call main */
bl main
/* trap if returned */
b .
/* initialize data and bss sections */
.section .text
init_data:
/* copy rom to ram */
ldr r0, =_sdata
ldr r1, =_edata
ldr r2, =_sidata
movs r3, #0
b LoopCopyDataInit
CopyDataInit:
ldr r4, [r2, r3]
str r4, [r0, r3]
adds r3, r3, #4
LoopCopyDataInit:
adds r4, r0, r3
cmp r4, r1
bcc CopyDataInit
/* zero bss */
ldr r2, =_sbss
ldr r4, =_ebss
movs r3, #0
b LoopFillZerobss
FillZerobss:
str r3, [r2]
adds r2, r2, #4
LoopFillZerobss:
cmp r2, r4
bcc FillZerobss
bx lr/* default handler */
.section .text
Default_Handler:
b Default_Handler
/* main function */
.section .text
main:
push {lr}
/* enable GPIOA clock, bit0 on IOPENR */
ldr r6, =RCC_IOPENR
ldr r5, [r6]
/* movs expects imm8, so this should be fine */
movs r4, 0x3 //A and B ports active
orrs r5, r5, r4
str r5, [r6]
/*enable a lot of the pins for prevent disruption */
 ldr r6, =GPIOA_MODER
 ldr r5, [r6]
 ldr r4,=# 0x3FFFFF
 mvns r4,r4
 ands r5,r5,r4
 ldr r4,=# 0x15555 //All A port is active for warranty
 orrs r5, r5, r4
 str r5,[r6]
/* enable a lot of the pins for prevent disruption*/
 ldr r6, =GPIOB_MODER
 ldr r5, [r6]
 ldr r4,=# 0x3FFFFF
 mvns r4,r4
 ands r5,r5,r4
 ldr r4,=# 0x15555
 orrs r5, r5, r4
 str r5,[r6]
button_ctrl:
/*ctrl button connected to PA1 in IDR.*/
ldr r6, =GPIOA_IDR
ldr r5, [r6]
lsrs r5, r5, #1
movs r4, #0x1
ands r5, r5, r4 //input mode 00
cmp r5, #0x1
beq second_counter //if button was pressed go to 
second_counter
b school_id // if button was not pressed branch to 
school_num
random_number_generated: //its end of the 165. line
 ldr r0, =#0x4093 //I choose school id last 4 digit
 movs r1, #0x8 //random number for muls
 ldr r2, =#0x1453 //conquest of İstanbul but its can random :)) ldr r7, =#0x270F //top boundary 9999
 muls r0, r0, r1
average_with_subs:
 subs r0, r0, r2 //to perform the division by simply 
subtracting.
 cmp r7, r0//If I were to assign a counter register, it would be 
a complete division.
 blt average_with_subs // the first time it is less than the 
upper limit will be my random count
 str r0, [r3]
ldr r1,= #4000000
bl delay
/*second_counter for displaying the number in digit1*/
second_counter: // seconds counter (saniye sayacı)
/*enable PA0, PA5, PA6, PA7 pins*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0xE1
str r5, [r6]
/*light up the numbers in range (9,0)*/
/* turn on led connected to PB0,PB1,PB2,PB3,PB5,PB6 in ODR */
ldr r4,= #4000
myrand_number_print: //7376
// When I assigned the A pins sequentially, the board was 
debugging.(I tried 3-4 times)
// It's a bit complicated but I used it because I didn't get 
debug errors on these pins
//light up digit1 connected to PA7 for random numbers first 
digit
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80
str r5, [r6]
// 7
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0xF8
str r5, [r6]
/*small delay to ensure continuity*/
ldr r1,= #400
bl delay
/*light up digit2 connected to PA6 for random numbers 2. 
digit*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x40
str r5, [r6]// 3
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0xB0
str r5, [r6]
/*small delay to ensure continuity*/
ldr r1,= #400
bl delay
/*light up digit3 connected to PA0 for random numbers 3. 
digit*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x1
str r5, [r6]
// 7
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0xF8
str r5, [r6]
/*small delay to ensure continuity*/
ldr r1,= #400
bl delay
/*light up digit4 connected to PA5 for random numbers 4. 
digit*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x20
str r5, [r6]
// 6
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x02
str r5, [r6]
/*small delay to ensure continuity*/
ldr r1,= #2000
bl delay
subs r4, r4, #1
cmp r4, #0
bne myrand_number_print
//standart counter is start here.
//The pins that will be active for each number were activated 
and then the value was sent from the B pins.
//I started from 7 at most because I know that the random 
number is counted and I now know that the random number is 7376.
/*enable first digit*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80
str r5, [r6]/* turn on led connected to PB0,PB1,PB2 */
// 7
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0xF8
str r5, [r6]
ldr r1,= #600000
bl delay
bl milisecond_counter
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80
str r5, [r6]
ldr r1,= #600000
bl delay
/* turn on led connected to PB0,PB2,PB3,PB4,PB5,PB6 in ODR */
// 6
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x02
str r5, [r6]
ldr r1,= #600000
bl delay
bl milisecond_counter
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80
str r5, [r6]
ldr r1,= #600000
bl delay
/* turn on led connected to PB0,PB2,PB3,PB5,PB6 */
// 5
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x12
str r5, [r6]
ldr r1,= #600000
bl delay
bl milisecond_counter
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80str r5, [r6]
ldr r1,= #600000
bl delay
/* turn on led connected to PB1,PB2,PB5,PB6*/
// 4
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x19
str r5, [r6]
ldr r1,= #600000
bl delay
bl milisecond_counter
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80
str r5, [r6]
ldr r1,= #600000
bl delay
/* turn on led connected to PB0,PB1,PB2,PB3,PB6*/
// 3
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0xB0
str r5, [r6]
ldr r1,= #600000
bl delay
bl milisecond_counter
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80
str r5, [r6]
ldr r1,= #600000
bl delay
/* turn on led connected to PB0,PB1,PB3,PB4,PB6 */
// 2
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x24
str r5, [r6]
ldr r1,= #600000
bl delay
bl milisecond_counterldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80
str r5, [r6]
ldr r1,= #600000
bl delay
/* turn on led connected to PB1,PB2 */
// 1
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0xF9
str r5, [r6]
ldr r1,= #600000
bl delay
bl milisecond_counter
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80
str r5, [r6]
ldr r1,= #600000
bl delay
/* turn on led connected to PB0,PB1,PB2,PB3,PB4,PB5 */
// 0
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x40
str r5, [r6]
ldr r1,= #600000
bl delay
bl milisecond_counter
// When the counter is 0000, it will stay on the screen for 
at least 1 second
/*enable the digits for 0000*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0xE1
str r5, [r6]
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x140
str r5, [r6]
/*display 0000 and wait a more than 1 second*/ldr r1,= #10000000
bl delay
b button_ctrl // branch to button_ctrl function, for 
checking the next command which is taken from the board*/
milisecond_counter:
push {r0-r7,lr} //register saving
/*enable milisecond digit, and disable digit1*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x61
str r5, [r6]
/*I did not separate the digits. If you want to separate, 3 
more loops of the same should be made. So as far as I learned, his 
memory is not enough.
//In this case too, the code approaches 1000 lines and gives 
an error _edata, _ebuss, _estack.
// For this topic GO TO: ELM335 Q&A links: 
https://teams.microsoft.com/l/message/19:220f63c72b904e889f7e7203b4
89eb21@thread.tacv2/1606033851623?groupId=4e42fafc-3dbf-47c2-864
/*same process at second_counter*/
// 9
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x10
str r5, [r6]
ldr r1,= #400000
bl delay
// 8
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x00
str r5, [r6]
ldr r1,= #400000
bl delay
// 7
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0xF8
str r5, [r6]
ldr r1,= #400000
bl delay
// 6
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x02str r5, [r6]
ldr r1,= #400000
bl delay
// 5
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x12
str r5, [r6]
ldr r1,= #400000
bl delay
// 4
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x19
str r5, [r6]
ldr r1,= #400000
bl delay
// 3
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0xB0
str r5, [r6]
ldr r1,= #400000
bl delay
// 2
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x24
str r5, [r6]
ldr r1,= #400000
bl delay
// 1
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0xF9
str r5, [r6]
ldr r1,= #400000
bl delay
// 0
ldr r6, =GPIOB_ODR
ldr r5, [r6]
ldr r5, =#0x40
str r5, [r6]ldr r1,= #400000
bl delay
pop {r0-r7,pc} // register saving
/*For displaying my school number, school_num funciton works*/
school_id:
 /* light up digit1 connected to PA7*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x80
str r5, [r6]
/*school numbers first digit of last 4 digits*/
ldr r6, =GPIOB_ODR //4
ldr r5, [r6]
ldr r5, =#0x19
str r5, [r6]
/*small delay to ensure continuity*/
ldr r1,= #500
bl delay
/*light up digit2 connected to PA6*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x40
str r5, [r6]
/*school numbers first digit of last 4 digits*/
ldr r6, =GPIOB_ODR // 0
ldr r5, [r6]
ldr r5, =#0x40
str r5, [r6]
/*small delay to ensure continuity*/
ldr r1,= #500
bl delay
/*light up digit3 connected to PA0*/
ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x1
str r5, [r6]
/*my school numbers third digit*/
ldr r6, =GPIOB_ODR // 9
ldr r5, [r6]
ldr r5, =#0x10
str r5, [r6]
/*small delay to ensure continuity*/
ldr r1,= #500
bl delay
/*light up digit4 connected to PA5*/ldr r6, =GPIOA_ODR
ldr r5, [r6]
ldr r5, =#0x20
str r5, [r6]
/*my school numbers last digit*/
ldr r6, =GPIOB_ODR // 3
ldr r5, [r6]
ldr r5, =#0xB0
str r5, [r6]
/*small delay to ensure continuity*/
ldr r1,= #500
bl delay
b button_ctrl// branch to button_ctrl function, for checking 
the next command*/
pop {pc}
delay: //usual delay label
subs r1,r1,#1
bne delay
bx lr
/* for(;;); */
b .
/* this should never get executed */
nop
