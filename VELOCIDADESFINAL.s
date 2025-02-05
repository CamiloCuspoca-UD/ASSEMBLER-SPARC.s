.include "macros.s"  !

.global _start  ! Definir punto de entrada

L_value:    .word 1            ! Distancia entre las ruedas (L = 1)
dt_value:   .word 1            ! Intervalo de tiempo (dt = 1 para simplificar)
theta:      .word 0            ! Angulo inicial (0 rad)
x_pos:      .word 0            ! Posicion inicial X
y_pos:      .word 0            ! Posicion inicial Y

velocidades: 
    .word 1, 1
    .word 1, 2
    .word 2, 1
fin_velocidades:

_start:
    set     velocidades, %l0       ! %l0 apunta al inicio de la lista de velocidades
    set     fin_velocidades, %l1   ! %l1 apunta al final de la lista

    set     theta, %l4             ! Direccion de theta en %l4
    set     x_pos, %l5             ! Direccion de x_pos en %l5
    set     y_pos, %l6             ! Direccion de y_pos en %l6

loop:
    cmp     %l0, %l1               ! Comparar si hemos llegado al final de la lista
    be      end_program            ! Si llegamos al final, salir del bucle
    nop

    ld      [%l0], %l2             ! Cargar v_left en %l2
    ld      [%l0 + 4], %l3         ! Cargar v_right en %l3

    ! Calcular v = (v_left + v_right) / 2
    add     %l2, %l3, %l7          ! %l7 = v_left + v_right
    sra     %l7, 1, %l7            ! %l7 = (v_left + v_right) / 2

    ! Calcular omega = (v_right - v_left) / L
    sub     %l3, %l2, %l3          ! %l3 = v_right - v_left (L=1, no necesita dividir)

    ! Guardar registros en la pila antes de modificar
    sub     %sp, 8, %sp
    st      %l6, [%sp + 0]
    st      %l7, [%sp + 4]

    ! Actualizar theta: theta += omega * dt
    ld      [%l4], %l6             ! Cargar theta actual en %l6
    MULSCC  %l3, 1, %l3            ! omega * dt (dt=1)
    add     %l6, %l3, %l6          ! theta = theta + omega * dt
    st      %l6, [%l4]             ! Guardar theta actualizado

    ! Calcular x += v * cos(theta) * dt
    ld      [%l5], %l6             ! Cargar x actual en %l6
    ! Aproximacion: cos(theta) aprox 1
    MULSCC  %l7, 1, %l7            ! v * dt (dt=1)
    add     %l6, %l7, %l6          ! x = x + v * dt
    st      %l6, [%l5]             ! Guardar x actualizado

    ! Calcular y += v * sin(theta) * dt
    ld      [%l6], %l7             ! Cargar y actual en %l7
    ! Aproximacionn: sin(theta) â‰ˆ theta
    MULSCC  %l7, %l6, %l7          ! v * sin(theta) * dt  v * theta
    add     %l7, %l6, %l7          ! y = y + v * sin(theta) * dt
    st      %l7, [%l6]             ! Guardar y actualizado

    ! Restaurar registros de la pila
    ld      [%sp + 0], %l6
    ld      [%sp + 4], %l7
    add     %sp, 8, %sp

    add     %l0, 8, %l0            ! Avanzar al siguiente par de velocidades
    ba      loop
    nop

end_program:
    ! Alternativa a `ta 0`: Bucle infinito para detener ejecucion
halt:
    ba      halt
    nop

