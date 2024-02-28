.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Proiect",0
area_width EQU 670
area_height EQU 810
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20

include digits.inc
include letters.inc

button1_x EQU 310    ;sus
button1_y EQU 620
button1_size equ 40

button2_x EQU 350      ;dreapta
button2_y EQU 660
button2_size equ 40

button3_x EQU 270       ;stanga
button3_y EQU 660
button3_size equ 40

button4_x EQU 310       ;jos  
button4_y EQU 700
button4_size equ 40

button5_x EQU 310        ;mijloc
button5_y EQU 660
button5_size equ 40


x_soarece dd 95
y_soarece dd 50
x_soarece1 dd 85
y_soarece1 dd 50

.code
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	cmp byte ptr [esi], 2
	je simbol_pixel_culoare
	cmp byte ptr [esi], 3
	je simbol_pixel_culoare
	cmp byte ptr [esi], 4
	je simbol_pixel_culoare
	cmp byte ptr [esi], 5
	je simbol_pixel_culoare
	cmp byte ptr [esi], 6
	je simbol_pixel_alb
	cmp byte ptr [esi], 7
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0F1948Ah    
	jmp simbol_pixel_next
simbol_pixel_culoare:
	mov dword ptr [edi], 0C70039h    
	jmp simbol_pixel_next
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

line_horizontal macro x, y, len, color
local bucla_line
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_line
endm

line_vertical macro x, y, len, color
local bucla_line
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, area_width * 4
	loop bucla_line
endm

dreptunghi macro x, y, lungime, latime, color
local bucla_line, bucla_line1
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, lungime
bucla_line:
	mov esi, ecx
	mov ecx, latime
	bucla_line1:
	mov dword ptr[eax], color
	add eax, area_width * 4
	loop bucla_line1
	sub eax, area_width * 4 * latime
	add eax, 4
	mov ecx, esi
	loop bucla_line
endm

draw proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	dreptunghi 0, 0, 670, 810, 0F1948Ah
	;contur labirint
			dreptunghi 120, 30, 500, 20, 581845h   ;sus
			dreptunghi 50, 30, 20, 480, 581845h   ;stanga
			dreptunghi 600, 50, 20, 480, 581845h  ;dreapta
			dreptunghi 50, 510, 490, 20, 581845h   ;jos
	
	;linii labirint:
			dreptunghi 215, 45, 20, 150, 581845h
			dreptunghi 390, 50, 20, 80, 581845h
			dreptunghi 250, 400, 20, 120, 581845h
			dreptunghi 440, 400, 20, 120, 581845h
			dreptunghi 70, 290, 80, 20, 581845h
			dreptunghi 130, 190, 160, 20, 581845h
			dreptunghi 115, 110, 20, 100, 581845h
			dreptunghi 115, 110, 60, 20, 581845h
			dreptunghi 205, 210, 20, 100, 581845h
			dreptunghi 290, 190, 20, 170, 581845h
			dreptunghi 115, 350, 195, 20, 581845h
			dreptunghi 150, 350, 20, 120, 581845h
			dreptunghi 210, 290, 40, 20, 581845h
			dreptunghi 300, 330, 150, 20, 581845h
			dreptunghi 340, 345, 20, 100, 581845h
			dreptunghi 320, 440, 80, 20, 581845h
			dreptunghi 410, 400, 120, 20, 581845h
			dreptunghi 210, 440, 50, 20, 581845h
			dreptunghi 510, 275, 20, 140, 581845h
			dreptunghi 360, 260, 170, 20, 581845h
			dreptunghi 340, 100, 20, 200, 581845h
			dreptunghi 270, 130, 80, 20, 581845h
			dreptunghi 270, 80, 20, 60, 581845h
			dreptunghi 350, 190, 180, 20, 581845h
			dreptunghi 480, 100, 20, 100, 581845h
			dreptunghi 460, 100, 20, 20, 581845h
			dreptunghi 550, 130, 60, 20, 581845h
			dreptunghi 510, 450, 90, 20, 581845h
			dreptunghi 520, 370, 50, 20, 581845h
			dreptunghi 560, 300, 50, 20, 581845h
			dreptunghi 560, 220, 50, 20, 581845h
			dreptunghi 130, 270, 20, 20, 581845h
			dreptunghi 450, 240, 20, 20, 581845h
			dreptunghi 390, 210, 20, 20, 581845h
	
	;lava		
			dreptunghi 135, 170, 80, 20, 0FF5733h
			dreptunghi 360, 170, 120, 20, 0FF5733h
			dreptunghi 410, 50, 190, 20, 0FF5733h
			dreptunghi 290, 110, 50, 20, 0FF5733h
			dreptunghi 270, 490, 170, 20, 0FF5733h
			dreptunghi 360, 280, 150, 20, 0FF5733h
			dreptunghi 460, 120, 20, 50, 0FF5733h
			dreptunghi 490, 280, 20, 120, 0FF5733h
			dreptunghi 70, 310, 20, 200, 0FF5733h
			dreptunghi 225, 210, 20, 80, 0FF5733h
			dreptunghi 70, 270, 60, 20, 0FF5733h
			dreptunghi 580, 150, 20, 70, 0FF5733h
			dreptunghi 310, 350, 30, 20, 0FF5733h
	
	;butoane
			dreptunghi 310, 620, 40, 40, 0C70039h  ;sus
			dreptunghi 350, 660, 40, 40, 0C70039h  ;dreapta
			dreptunghi 270, 660, 40, 40, 0C70039h  ;stanga
			dreptunghi 310, 700, 40, 40, 0C70039h  ;jos
			dreptunghi 310, 660, 40, 40, 581845h  ;mijloc
			
	;sageti	
			make_text_macro 'C', area, 326, 630
			make_text_macro 'J', area, 367, 670
			make_text_macro 'K', area, 285, 670
			make_text_macro 'D', area, 326, 710
			
			make_text_macro 'X', area, 85, 50
			make_text_macro 'Y', area, 95, 50
			
	;contur butoane
			line_vertical button1_x, button1_y, button1_size, 581845h      ;sus
			line_vertical button1_x + button1_size, button1_y, button1_size, 581845h
			line_horizontal button1_x, button1_y, button1_size, 581845h  
			line_horizontal button1_x, button1_y + button1_size, button1_size, 581845h
			
			line_vertical button2_x, button2_y, button2_size, 581845h       ;dreapta
			line_vertical button2_x + button2_size, button2_y, button2_size, 581845h
			line_horizontal button2_x, button2_y, button2_size, 581845h  
			line_horizontal button2_x, button2_y + button2_size, button2_size, 581845h
			
			line_vertical button3_x, button3_y, button3_size, 581845h       ;stanga
			line_vertical button3_x + button3_size, button3_y, button3_size, 581845h
			line_horizontal button3_x, button3_y, button3_size, 581845h  
			line_horizontal button3_x, button3_y + button3_size, button3_size, 581845h
			
			line_vertical button4_x, button4_y, button4_size, 581845h       ;jos
			line_vertical button4_x + button4_size, button4_y, button4_size, 581845h
			line_horizontal button4_x, button4_y, button4_size, 581845h  
			line_horizontal button4_x, button4_y + button4_size, button4_size, 581845h
			
			line_vertical button5_x, button5_y, button5_size, 581845h       ;mijloc 
			line_vertical button5_x + button5_size, button5_y, button5_size, 581845h
			line_horizontal button5_x, button5_y, button5_size, 581845h  
			line_horizontal button5_x, button5_y + button5_size, button5_size, 581845h
	
	jmp afisare_litere
	
evt_click:

button1_sus:
	mov eax, [ebp+arg2]                      
	cmp eax, button1_x
	jl buton_stanga
	cmp eax, button1_x + button1_size
	jg buton_dreapta
	mov eax, [ebp+arg3]
	cmp eax, button1_y
	jl button_fail
	cmp eax, button1_y + button1_size
	jg buton_jos
	
	make_text_macro ' ', area, x_soarece1, y_soarece1
	make_text_macro ' ', area, x_soarece, y_soarece
	
	sub y_soarece,10
	sub y_soarece1,10
	mov edi, area ; pointer la matricea de pixeli
	mov eax, y_soarece ; pointer la coord y
	mov ebx, area_width
	mul ebx
	add eax, x_soarece ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	cmp dword ptr[edi], 581845h
	jne lava
	add y_soarece, 10
	add y_soarece1, 10
	jmp afis
	
lava:
	cmp dword ptr[edi], 0FF5733h
	jne afis
	mov y_soarece, 50
	mov x_soarece, 95
	mov y_soarece1, 50
	mov x_soarece1, 85
	
afis:
	make_text_macro 'X', area, x_soarece1, y_soarece1
	make_text_macro 'Y', area, x_soarece,y_soarece
	jmp afisare_litere

buton_dreapta:	
	mov eax, [ebp+arg2]                      
	cmp eax, button2_x + button2_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button2_y
	jl button_fail
	cmp eax, button2_y + button2_size
	jg button_fail
	
	make_text_macro ' ', area, x_soarece1, y_soarece1
	make_text_macro ' ', area, x_soarece, y_soarece
	
	add x_soarece,10
	add x_soarece1,10
	mov edi, area ; pointer la matricea de pixeli
	mov eax, y_soarece ; pointer la coord y
	mov ebx, area_width
	mul ebx
	add eax, x_soarece ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	cmp dword ptr[edi], 581845h
	jne lava1
	sub x_soarece, 10
	sub x_soarece1, 10
	jmp afis1
	
lava1:
	cmp dword ptr[edi], 0FF5733h
	jne afis1
	mov y_soarece, 50
	mov x_soarece, 95
	mov y_soarece1, 50
	mov x_soarece1, 85
	
	afis1:
	make_text_macro 'X', area, x_soarece1, y_soarece1
	make_text_macro 'Y', area, x_soarece,y_soarece
	jmp afisare_litere

buton_stanga:	
	mov eax, [ebp+arg2]                      
	cmp eax, button3_x
	jl button_fail
	mov eax, [ebp+arg3]
	cmp eax, button3_y
	jl button_fail
	cmp eax, button3_y + button3_size
	jg button_fail
	
	make_text_macro ' ', area, x_soarece1, y_soarece1
	make_text_macro ' ', area, x_soarece, y_soarece
	
	sub x_soarece,10
	sub x_soarece1,10
	mov edi, area ; pointer la matricea de pixeli
	mov eax, y_soarece1 ; pointer la coord y
	mov ebx, area_width
	mul ebx
	add eax, x_soarece1 ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	cmp dword ptr[edi], 581845h
	jne lava2
	add x_soarece, 10
	add x_soarece1, 10
	jmp afis2
	
lava2:
	cmp dword ptr[edi], 0FF5733h
	jne afis2
	mov y_soarece, 50
	mov x_soarece, 95
	mov y_soarece1, 50
	mov x_soarece1, 85
	
	afis2:
	make_text_macro 'X', area, x_soarece1, y_soarece1
	make_text_macro 'Y', area, x_soarece,y_soarece
	jmp afisare_litere
	
buton_jos:
	mov eax, [ebp+arg2]                      
	cmp eax, button4_x
	jl button_fail
	cmp eax, button4_x + button4_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button4_y
	jl button_fail
	cmp eax, button4_y + button4_size
	jg button_fail
	
	make_text_macro ' ', area, x_soarece1, y_soarece1
	make_text_macro ' ', area, x_soarece, y_soarece
	
	add y_soarece,20
	add y_soarece1,20
	
	cmp y_soarece, 510
	jl cont
	cmp x_soarece1,540
	jl cont
	; make_text_macro 'D', area, 270, 560
	; make_text_macro 'O', area, 280, 560
	; make_text_macro 'N', area, 290, 560
	; make_text_macro 'E', area, 300, 560
	
	cont:
	mov edi, area ; pointer la matricea de pixeli
	mov eax, y_soarece ; pointer la coord y
	mov ebx, area_width
	mul ebx
	add eax, x_soarece ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	cmp dword ptr[edi], 581845h
	jne lava3
	sub y_soarece, 10
	sub y_soarece1, 10
	jmp afis3
	
lava3:
	cmp dword ptr[edi], 0FF5733h
	jne afis3
	mov y_soarece, 50
	mov x_soarece, 95
	mov y_soarece1, 50
	mov x_soarece1, 85
	jmp afis4
afis3:
sub y_soarece, 10
	sub y_soarece1, 10
	afis4:

	make_text_macro 'X', area, x_soarece1, y_soarece1
	make_text_macro 'Y', area, x_soarece,y_soarece
	jmp afisare_litere
	
button_fail:	
	make_text_macro ' ', area, 533, 624
	make_text_macro ' ', area, 533, 624
	jmp afisare_litere
	
evt_timer:
	inc counter
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
			make_text_macro 'A', area, 280, 0
			make_text_macro 'B', area, 290, 0
			make_text_macro 'M', area, 300, 0
			make_text_macro 'A', area, 310, 0
			make_text_macro 'Z', area, 320, 0
			make_text_macro 'E', area, 330, 0
			make_text_macro 'B', area, 340, 0
			make_text_macro 'I', area, 350, 0
			make_text_macro 'N', area, 360, 0
			make_text_macro 'G', area, 370, 0
			
			make_text_macro 'S', area, 70, 30
			make_text_macro 'T', area, 80, 30
			make_text_macro 'A', area, 90, 30
			make_text_macro 'R', area, 100, 30
			make_text_macro 'T', area, 110, 30
			
			make_text_macro 'F', area, 540, 510
			make_text_macro 'I', area, 550, 510
			make_text_macro 'N', area, 560, 510
			make_text_macro 'I', area, 570, 510
			make_text_macro 'S', area, 580, 510
			make_text_macro 'H', area, 590, 510
			
			
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
