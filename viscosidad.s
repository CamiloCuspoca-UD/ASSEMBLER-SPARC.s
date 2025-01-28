.include "vectors1.s"  ! Include the vectors file
.include "macros.s"  ! Include the macros file

.global un_paso
.global escala_vect

! ============================
! Realizar un solo paso
! Calcula:
! 1. f = Kv * v
! 2. delta_pos, V = un_paso(v, f, t, m)
! Actualiza:
! - Pos = Pos + delta_pos
! ----------------------------
! Entradas:
! %i0 = número de elementos del vector (tamaño)
! %i1 = dirección de memoria de Pos (posición inicial)
! %i2 = dirección de memoria de V (velocidad inicial)
! %i3 = escalar Kv (constante de fricción viscosa)
! %i4 = escalar t (tiempo del paso)
! %i5 = escalar m (masa del objeto)
! ----------------------------
! Salidas:
! - Actualiza la posición en %i1.
! ============================

un_paso_principal:
    save %sp, -128, %sp       ! Reserva espacio en la pila

    ! Paso 1: Calcular f = Kv * v
    mov %i0, %o0              ! Número de elementos (tamaño del vector)
    mov %i2, %o1              ! Dirección de memoria de v (velocidad)
    mov %i3, %o2              ! Kv (constante de fricción)
    set f, %o3                ! Dirección de memoria de f (resultado de la fuerza)
    call escala_vect          ! Llama a escala_vect para calcular f = Kv * v
    nop                       ! Delay slot

    ! Paso 2: Calcular delta_pos y V (un paso)
    mov %i0, %o0              ! Número de elementos
    mov %i2, %o1              ! Dirección de memoria de v (velocidad)
    set f, %o2                ! Dirección de memoria de f (fuerzas calculadas)
    mov %i4, %o3              ! t (tiempo)
    mov %i5, %o4              ! m (masa)
    set delta_pos, %o5        ! Dirección de memoria de delta_pos (variación de posición)
    set V, %o6                ! Dirección de memoria de V (nueva velocidad)
    call un_paso              ! Llama a un_paso para calcular posición y velocidad
    nop                       ! Delay slot

    ! Paso 3: Actualizar Pos = Pos + delta_pos
    clr %l0                   ! Índice para el bucle (i = 0)
actualiza_pos_loop:
    cmp %l0, %i0              ! ¿i >= número de elementos?
    be un_paso_end            ! Si ya se actualizó todo, salir
    nop

    ld [%i1 + %l0], %l1       ! Cargar Pos[i]
    ld [delta_pos + %l0], %l2 ! Cargar delta_pos[i]
    add %l1, %l2, %l1         ! Pos[i] = Pos[i] + delta_pos[i]
    st %l1, [%i1 + %l0]       ! Guardar Pos[i]

    add %l0, 4, %l0           ! Incrementar índice (4 bytes por elemento)
    ba actualiza_pos_loop     ! Repetir para el siguiente elemento
    nop

un_paso_end:
    ret                       !Según set de instrucciones debería usar: retl
    restore