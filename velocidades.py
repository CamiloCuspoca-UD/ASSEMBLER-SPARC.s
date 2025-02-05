import math

def calcular_posiciones(velocidades_ruedas, L, dt):
    x, y = 0.0, 0.0  # Posición inicial
    theta = 0.0      # Ángulo inicial
    posiciones = [(x, y)]

    for v_left, v_right in velocidades_ruedas:
        v = (v_left + v_right) / 2.0               # Velocidad lineal
        omega = (v_right - v_left) / L             # Velocidad angular

        theta += omega * dt                        # Actualizar ángulo
        x += v * math.cos(theta) * dt              # Actualizar posición X
        y += v * math.sin(theta) * dt              # Actualizar posición Y

        posiciones.append((x, y))                  # Guardar posición

    return posiciones

# Ejemplo de uso
velocidades = [(1.0, 1.0), (1.0, 2.0), (2.0, 1.0)]  # Velocidades de las ruedas
L = 1.0  # Distancia entre ruedas
dt = 0.1  # Intervalo de tiempo

posiciones = calcular_posiciones(velocidades, L, dt)
print(posiciones)
