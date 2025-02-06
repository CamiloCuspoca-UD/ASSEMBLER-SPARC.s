# SPARC.s y seguidor de línea
En este repositorio está el cálculo de velocidades, quiz antes del paro, y código del proyecto seguidor de línea con Cámara 0V7670.

Los integrantes del grupo, para el seguidor de línea:
Juan Camilo Cuspoca Delgado - 20212005043, 
Julian Mateo Torres - 20201005091, 
Estefanía Polo Molano - 20212005090

Tiempo de Carrera: 1:08 minutos.

Link de drive con video (que ya fue enviado por medio de Whatsapp) y fotos del resultado final: 
https://drive.google.com/drive/folders/1_sKNeG81EkXQwphDv-SlUQ_QDOl-67Su?usp=sharing 

Descripción del código:
1. Se importan librerías para poder proporcionar diferentes funciones, entre ellas están: time, pwmio, board, busio y adafruit_ov7670.

2. Se realiza una configuración inicial de la cámara OV7670, para ello, se configuran los pines para la creación del bus I2C, se realiza la instancia de la cámara por medio de pines para el control de la cámara y ubicar las señales suministradas por la cámara. También, se configura la resolución y espacio de color, para nuestro caso fue de 1/16 para facilitar el manejo de datos y la velocidad de procesamiento, utilizamos el formato YUV el cual indica los datos que se capturan.

3. Se configuran los motores, de esta manera, se dejan a una frecuencia de 1000Hz, se configuran las salidas PWM para controlar el movimiento de los motores hacia adelante y hacia los lados.

4. Se crean funciones para controlar los motores teniendo en cuenta el duty cycle, de esta manera el carro es capaz de moverse hacia adelante, hacia la derecha, hacia la izquierda o detenerse.

5. Se normalizan los valores negativos, con lo que se asume que los valores de la fila son negativos o cero. Así, se identifican valores máximos y mínimos y conseguir que si hay una diferencia se mapee cada valor a un nuevo rango entre 0 y 1. De esta forma se resaltan las variaciones de intensidad. Además, realiza un promedio ponderado por medio del "peso". Para este caso especificamos diferentes valores los cuales se traducen como un cambio en la pista, la sección negra puede desplazarse a la derecha o a la izquierda, seguir centrada o incluso asumir que está perdido.

6. Utiliza una memoria para recordar la posición previa en la que estaba y así replantear su rumbo, para ello, se mantiene un historial de las últimas posiciones detectadas, si se excede el tamaño máximo se eliminan los elementos más antiguos.

7. La lógica principal plantea una captura de imagen, luego analiza las 3 filas que le determinamos y así promediar las posiciones, de esta manera el carro es capaz de tomar posiciones y se concluyen en 3 casos. El primero, es para ir adelante. El segundo, para girar a la derecha. El tercero, es por si no se cumple nada de lo anterior, en este último caso se inicia con la rutina de búsqueda.

Esta rutina lo que realiza es alternar giros entre izquierda y derecha cada tiempo determinado para encontrar nuevamente la línea negra. Al detectar nuevamente la línea, detiene la búsqueda y reanuda el movimiento hacia adelante
