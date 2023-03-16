global inverse_permutation

; Wartość INT_MAX. Służy do obliczenia wartości liczby.
%define VAL_MASK 0x7fffffff

; Wartość INT_MAX + 1. Służy do kodowania w najbardziej znaczącym bicie.
%define MEM_MASK 0x80000000

; Argumenty funkcji inverse_permutation:
;       rdi - wartość n
;       rsi - wskaźnik do tablicy p.
inverse_permutation:
        xor     eax, eax ; Ustawienie wyniku na 0.
        mov     r10d, VAL_MASK ; Załadowanie stałych
        mov     r11d, MEM_MASK ; do rejestrów.
        test    rdi, rdi
        jz      .exit0 ; Sprawdzenie, czy n = 0.
        cmp     rdi, r11
        ja      .exit0 ; Sprawdzenie, czy n > INT_MAX + 1.
        dec     rdi ; Zmniejszenie n o 1, dzięki czemu n <= INT_MAX.
        mov     edx, edi ; W edx znajduje się zmienna i = n - 1.
.in_range_loop: ; Sprawdzenie, czy wszystkie wartości p są w przedziale [0, n - 1].
        mov     ecx, dword [rsi + rdx * 4]
        test    ecx, ecx
        js      .exit0 ; Sprawdzenie, czy p[i] < 0.
        cmp     ecx, edi
        jg      .exit0 ; Sprawdzenie, czy p[i] > n - 1.
        test    edx, edx
        jz      .is_permutation ; Jeśli i = 0 to kończymy pętlę.
        dec     edx ; Zmniejszenie i o 1.
        jmp     .in_range_loop
.is_permutation: ; Sprawdzenie, czy w tablicy p nie ma powtórek.
        mov     edx, edi ; W edx znajduje się zmienna i = n - 1.
.is_permutation_loop:
        mov     ecx, dword [rsi + rdx * 4]
        and     ecx, r10d
        mov     r8d, dword [rsi + rcx * 4]
        test    r8d, r11d
        jnz     .rollback ; Sprawdzenie, czy wartość p[i] już wystąpiła.
        xor     dword [rsi + rcx * 4], r11d ; Zaznaczenie, że p[i] wystąpiło.
        test    edx, edx
        jz      .inverse_loop ; Jeśli i = 0 to kończymy pętlę.
        dec     edx ; Zmniejszenie i o 1.
        jmp     .is_permutation_loop
.inverse_loop:
        mov     edx, edi ; Aktualny indeks znajduje się w edx.
        mov     ecx, dword [rsi + rdi * 4]
        mov     r8d, ecx
        and     r8d, r10d ; Aktualna wartość znajduje się w r8d.
        cmp     r8d, ecx
        je      .inverse_loop_decrement
.inverse_loop_cycle:
        mov     ecx, dword [rsi + r8 * 4]
        and     ecx, r10d ; Następna wartość z cyklu znajduje się w ecx.
        mov     dword [rsi + r8 * 4], edx
        mov     edx, r8d
        mov     r8d, ecx
        cmp     edx, edi
        jne     .inverse_loop_cycle
.inverse_loop_decrement:
        test    edi, edi
        jz      .exit1 ; Jeśli n = 0 to kończymy pętle.
        dec     edi ; Zmniejszenie n o 1.
        jmp     .inverse_loop
.rollback: ; Cofnięcie modyfikacji tablicy p.
        mov     r9d, edi ; W r9d znajduje się zmienna j.
.rollback_loop:
        mov     ecx, dword [rsi + r9 * 4]
        and     ecx, r10d
        xor     dword [rsi + rcx * 4], r11d
        dec     r9d ; Zmniejszenie j o 1.
        cmp     r9d, edx ; Jeśli i = j to kończymy pętlę.
        je      .exit0
        jmp     .rollback_loop
.exit0:
        ret
.exit1:
        inc     eax ; Ustawienie wyniku na 1.
        ret
