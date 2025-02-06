import time
import pwmio
import board
import busio
from adafruit_ov7670 import OV7670, OV7670_SIZE_DIV16, OV7670_COLOR_YUV

# Configuración de la cámara OV7670
cam_bus = busio.I2C(board.GP21, board.GP20)
cam = OV7670(
    cam_bus,
    data_pins=[
        board.GP0, board.GP1, board.GP2, board.GP3,
        board.GP4, board.GP5, board.GP6, board.GP7
    ],
    clock=board.GP8,
    vsync=board.GP13,
    href=board.GP12,
    mclk=board.GP9,
    shutdown=board.GP15,
    reset=board.GP14,
)
cam.size = OV7670_SIZE_DIV16
cam.colorspace = OV7670_COLOR_YUV
cam.flip_y = True

# Configuración de los motores
Motor_A_Forward = pwmio.PWMOut(board.GP16, frequency=1000)
Motor_A_Backward = pwmio.PWMOut(board.GP17, frequency=1000)
Motor_B_Forward = pwmio.PWMOut(board.GP18, frequency=1000)
Motor_B_Backward = pwmio.PWMOut(board.GP19, frequency=1000)

# Funciones para controlar los motores
def stop_motors():
    Motor_A_Forward.duty_cycle = 0
    Motor_A_Backward.duty_cycle = 0
    Motor_B_Forward.duty_cycle = 0
    Motor_B_Backward.duty_cycle = 0

def move_forward(speed):
    Motor_A_Forward.duty_cycle = speed
    Motor_B_Forward.duty_cycle = speed
    Motor_A_Backward.duty_cycle = 0
    Motor_B_Backward.duty_cycle = 0
    
def turn_left(Speed):    
    Motor_A_Forward.duty_cycle = 0
    Motor_A_Backward.duty_cycle = Speed
    Motor_B_Forward.duty_cycle = Speed
    Motor_B_Backward.duty_cycle = 0

def turn_right(Speed): 
    Motor_A_Forward.duty_cycle = Speed
    Motor_A_Backward.duty_cycle = 0
    Motor_B_Forward.duty_cycle = 0
    Motor_B_Backward.duty_cycle = Speed

# Normalización de valores negativos
def normalize_row(row):
    min_val = min(row)
    max_val = 0  # Máximo es 0 porque los valores son negativos o 0
    if max_val == min_val:
        return [0 for _ in row]
    return [(val - min_val) / (max_val - min_val) for val in row]

# Memoria de la posición
last_known_positions = []

def update_memory_position(position, max_memory=5):
    last_known_positions.append(position)
    if len(last_known_positions) > max_memory:
        last_known_positions.pop(0)
    return last_known_positions[-1] if last_known_positions else None

# Seguimiento de posición basada en pesos
def track_position(row):
    columns = [i - len(row) // 2 for i in range(len(row))]
    weighted_sum = sum(value * col for value, col in zip(row, columns))
    total_weight = sum(abs(value) for value in row)  # Suma solo valores negativos
    if total_weight == 0:
        return None  # Indica pérdida de pista
    return weighted_sum / total_weight

# Lógica principal
while True:
    buf = bytearray(2 * cam.width * cam.height)
    cam.capture(buf)

    # Analizamos tres filas: las primeras tres del buffer
    rows_to_analyze = [
        0,           # Primera fila
        1,           # Segunda fila
        2,           # Tercera fila
    ]

    positions = []
    for idx, row_idx in enumerate(rows_to_analyze):
        row = [buf[2 * (row_idx * cam.width + i)] for i in range(cam.width)]
        normalized_row = normalize_row(row)
        position = track_position(normalized_row)
        positions.append(position)
        label = f"Fila {row_idx + 1}"
        print(f"{label}: {position}")

    # Combinar posiciones detectadas
    valid_positions = [pos for pos in positions if pos is not None]
    if valid_positions:
        average_position = sum(valid_positions) / len(valid_positions)
    else:
        average_position = None
        

    # Manejo de posiciones
    if average_position is not None and 0.1 <= average_position < 3 and positions[0] is not None:
        print(f"Sector negro detectado: {average_position:.2f} | Dirección: Adelante-abc")
        move_forward(20000)
        last_known_positions = []  # Reset de memoria al estar en pista
        # Cambios: Verificar si únicamente la fila superior arroja None
    elif positions[1] is None and positions[2] is None and positions[0]>3:
        print("Solo la fila superior perdió pista. Girando a la derecha...")
        turn_right(18000)
        continue  # Volver al inicio del bucle para verificar de nuevo
    else:
        print("Sector perdido. Buscando pista...")
        stop_motors()

        # Búsqueda con alternancia de giros
        searching = True
        search_start_time = time.monotonic()
        while searching:
            elapsed_time = time.monotonic() - search_start_time

            if elapsed_time < 0.75:  # Girar a la izquierda
                print("Girando lentamente a la izquierda...")
                turn_left(18000)
            elif elapsed_time < 1.75:  # Girar a la derecha
                print("Girando lentamente a la derecha...")
                turn_right(18000)
            else:  # Reiniciar alternancia
                search_start_time = time.monotonic()

            # Capturar nuevos datos de la cámara
            buf = bytearray(2 * cam.width * cam.height)
            cam.capture(buf)
            row = [buf[2 * (rows_to_analyze[1] * cam.width + i)] for i in range(cam.width)]
            normalized_row = normalize_row(row)

            if any(value < 0 for value in normalized_row):  # Pista negra encontrada
                print("Sector negro encontrado. Deteniéndose y avanzando...")
                stop_motors()
                time.sleep(0.5)  # Pausa antes de avanzar
                move_forward(20000)
                searching = False  # Terminar búsqueda