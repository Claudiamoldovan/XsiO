.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date

titlu DB "X si 0", 0
area_width EQU 400 
area_height EQU 300 
area DD 0
matrice DD 9 dup(0)
X0 DD 100 
Y0 DD 100 
X DD 0
Y DD 0
game_width EQU 40 
game_height EQU 39 
culoare DD 0
verificare DD 0
mutari DD 9   
zero EQU 0
arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
symbol_width EQU 10
symbol_height EQU 20

include digits.inc
include letters.inc
include symbol.inc

.code

		
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] 
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
	mov eax, 26
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] 
	mov eax, [ebp+arg4]
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] 
	shl eax, 2 
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 000107 
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0fbfbfch    
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

vertical_line macro x, y
LOCAL line_loop, final
	pusha
	xor eax, eax
	mov eax, x
	mov ebx, area_width
	mul ebx
	add eax, y
	shl eax, 2
	mov ecx, 0
line_loop:
	add eax, 1599
	mov ebx, [area]
	add ebx, ecx
	mov dword ptr [ebx+eax], 000107
	inc ecx
	inc ecx
	cmp ecx, 120
	je final
	loop line_loop
final:
	popa
endm

horizontal_line macro x, y
local line_loop, final
	pusha
	mov eax, 0
	mov eax, x
	mov ebx, area_width
	mul ebx
	add eax, y
	shl eax, 2
	mov ecx, 0
line_loop:
	mov ebx, [area]
	add ebx, ecx
	mov dword ptr [ebx+eax], 000107
	inc ecx
	inc ecx
	cmp ecx, 480
	je final
	loop line_loop
final:
	popa
endm

desenare_X_O proc   
	push ebp
	mov ebp,esp
	pusha
desenare_X:
	mov eax, [ebp + arg1]  
	cmp eax, 'X'
	jne desenare_O
	sub eax, 'X'
	lea esi, X_O
	mov culoare, 000107
	jmp deseneaza_X_O
desenare_O:
	mov eax, 1   
	mov culoare, 000107 
	lea esi, X_O
deseneaza_X_O:
	mov ebx, game_height
	mul ebx
	mov ebx, game_height
	mul ebx
	add esi, eax
	mov ecx, game_height
linii_X_O:
	mov edi, [ebp+arg2] 
	mov eax, [ebp+arg4]
	add eax, game_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3]
	shl eax, 2 
	add edi, eax
	push ecx
	mov ecx, game_height
coloane_X_O:
	cmp byte ptr [esi], 0
	je pixel_alb_X_O
	mov edx, culoare
	mov dword ptr [edi], edx
	jmp pixel_next_X_O
pixel_alb_X_O:
	mov dword ptr [edi], 0fbfbfch 
pixel_next_X_O:
	inc esi
	add edi, 4
	loop coloane_X_O
	pop ecx
	loop linii_X_O
	popa
	mov esp, ebp
	pop ebp
	ret
	desenare_X_O endp


make_text_macro_X_O macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call desenare_X_O
	add esp, 16
endm

matrice_X_O proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	mov eax, [ebp+arg1]
	mov ebx, 4
	mul ebx
	mov esi, eax			
	mov eax, [ebp+arg2]
	mul ebx
	mov ebx, eax
	mov eax, 3				
	mul ebx
	mov ebx, eax
	mov eax, matrice[ebx+esi]	
	cmp eax, 0 
	jne exit_matrice
	mov ecx, [ebp+arg3] 
	cmp ecx, 0 
	jne X_urmator
O_urmator:
	mov eax, 2
	mov matrice[ebx+esi], eax
	mov eax, 0
	jmp iesire
X_urmator:
	mov eax, 1
	mov matrice[ebx+esi], eax
	mov eax, 0
	jmp iesire
exit_matrice:
	mov edx, 1			
	sub edx, verificare
	mov verificare, edx
iesire:
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret
matrice_X_O endp	

win_linie proc
	push ebp
	mov ecx, 3					
	first_loop:
		mov ebp, ecx
		mov ebx, ecx			
		dec ebx
		mov eax, 4
		mul ebx
		mov ebx, 3
		mul ebx
		mov ebx, eax
		mov ecx, 2
		mov edi, matrice[ebx + 8]
	second_loop:
			mov eax, 4		
			dec ecx
			mul ecx
			inc ecx
			mov esi, eax
			mov edx, matrice[ebx + esi]
			cmp edi, edx
			jne nu
			loop second_loop
		cmp edi, 0
		je nu
		cmp edi, 1
		je castiga_X
castiga_O:
		mov eax, 2
		jmp final
castiga_X:
		mov eax, 1
		jmp final
nu:
		mov ecx, ebp
		loop first_loop
		mov eax, 0
final:
	pop ebp
	ret
win_linie endp

win_coloana proc
	push ebp
	mov ecx, 3					
	first_loop:
		mov ebp, ecx
		mov ebx, ecx			
		dec ebx
		mov eax, 4
		mul ebx
		add eax, 24
		mov ecx, 2
		mov edi, matrice[eax]
	second_loop:
			sub eax, 12
			mov edx, matrice[eax]
			cmp edi, edx
			jne nu
			loop second_loop
		cmp edi, 0
		je nu
		cmp edi, 1
		je castiga_X
castiga_O:
		mov eax, 2
		jmp final
castiga_X:
		mov eax, 1
		jmp final
nu:
		mov ecx, ebp
		loop first_loop
		mov eax, 0
final:
	pop ebp
	ret
win_coloana endp

win_diagonala1 proc
	mov edi, matrice[0]
	cmp edi, matrice[16]
	jne nu
	cmp edi, matrice[32]
	jne nu
		cmp edi, 0
		je nu
		cmp edi, 1
		je castiga_X
castiga_O:
		mov eax, 2
		jmp final
castiga_X:
		mov eax, 1
		jmp final
nu:
		mov eax, 0
final:
	ret
win_diagonala1 endp

win_diagonala2 proc
	mov edi, matrice[8]
	cmp edi, matrice[16]
	jne nu
	cmp edi, matrice[24]
	jne nu
		cmp edi, 0
		je nu
		cmp edi, 1
		je castiga_X
castiga_O:
		mov eax, 2
		jmp final
castiga_X:
		mov eax, 1
		jmp final
nu:
		mov eax, 0
final:
	ret
win_diagonala2 endp

winner proc
		call win_linie
		cmp eax, zero
		jne final
		call win_coloana
		cmp eax, zero
		jne final
		call win_diagonala1
		cmp eax, zero
		jne final
		call win_diagonala2
final:
	ret
winner endp

game proc
	push ecx
	mov ebx,[ebp+arg2]		
	mov edx,[ebp+arg3]
	push edx
	push ebx
	add esp, 8
	cmp eax, 0
	je final_game
	mov edx, 1				
	sub edx, verificare
	mov verificare, edx
	xor edx, edx
	mov ecx, game_width
	mov eax, [ebp+arg2]		
	sub eax, X0
	div ecx
	mov X, eax
	mov ecx, game_width
	mul ecx
	mov ebx, eax
	add ebx, X0
	add ebx, 1
	xor edx, edx
	mov eax, [ebp+arg3]
	sub eax, Y0
	div ecx
	mov Y, eax
	mov ecx, game_width
	mul ecx
	add eax, Y0
	add eax, 1
	mov ecx, eax			
	push verificare
	push Y
	push X
	call matrice_X_O
	add esp, 12
	cmp eax, 0				
	jne final_game
	cmp verificare, 1 
	jne draw_0
	make_text_macro_X_O 'X', area, ebx, ecx
	jmp final_game
draw_0:
	make_text_macro_X_O 'O', area, ebx, ecx
final_game:
	pop ecx
	ret
game endp
	
draw proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz titlu_afisare
	
window:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0fbfbfch   
	push area
	call memset
	add esp, 12
	horizontal_line 100, 100
	horizontal_line 140, 100
	horizontal_line 180, 100
	horizontal_line 220, 100
	vertical_line 100, 100
	vertical_line 100, 140
	vertical_line 100, 180
	vertical_line 100, 220
	jmp titlu_afisare
	
evt_click:
	mov ebx,[ebp+arg2]
	mov edx,[ebp+arg3]	
	push edx
	push ebx
	add esp, 8
	mov eax, 99
	cmp eax, 99
	jne window
	mov ecx, mutari 
	
	first_loop:
		call game
		cmp eax, 0
		jne pastrare_mutare				
		dec mutari
		jmp winner_loop
	pastrare_mutare:
		mov ecx, mutari
	winner_loop:
		call winner
		cmp eax, 1
		je X_win
		cmp eax ,2
		je O_win
		
	iesi:	
		jmp titlu_afisare
	 
	
	O_win:
		make_text_macro 'O', area, 120, 230
		make_text_macro ' ', area, 130, 230
		make_text_macro 'W', area, 140, 230
		make_text_macro 'I', area, 150, 230
		make_text_macro 'N', area, 160, 230
		jmp titlu_afisare
	
	X_win:
	
		make_text_macro 'X', area, 120, 230
		make_text_macro ' ', area, 130, 230
		make_text_macro 'W', area, 140, 230
		make_text_macro 'I', area, 150, 230
		make_text_macro 'N', area, 160, 230
		

titlu_afisare:	
	make_text_macro 'X', area, 120, 40
	make_text_macro ' ', area, 130, 40
	make_text_macro 'S', area, 140, 40
	make_text_macro 'I', area, 150, 40
	make_text_macro ' ', area, 160, 40
	make_text_macro 'Y', area, 170, 40

	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:

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
	push offset titlu
	call BeginDrawing
	add esp, 20
	;terminarea programului
	push 0
	call exit
end start