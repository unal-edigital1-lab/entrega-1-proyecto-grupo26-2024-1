# Entrega 1 del proyecto WP01
## 1.Objetivo 
Desarrollar un sistema de Tamagotchi en FPGA (Field-Programmable Gate Array) que simule el cuidado de una mascota virtual. El diseño incorporará una lógica de estados para reflejar las diversas necesidades y condiciones de la mascota, junto con mecanismos de interacción a través de sensores y botones que permitan al usuario cuidar adecuadamente de ella.


## 2. Especificación de los sistemas que conforman el proyecto

### 2.1 Botones 

La interacción usuario-sistema se realizará mediante los siguientes botones configurados:

Reset: Reestablece el Tamagotchi a un estado inicial conocido al mantener pulsado el botón durante al menos 5 segundos. Este estado inicial simula el despertar de la mascota con salud óptima.

Test: Activa el modo de prueba al mantener pulsado por al menos 5 segundos, permitiendo al usuario navegar entre los diferentes estados del Tamagotchi con cada pulsación.

Navegación (2): Permiten desplazarse entre pantallas(Estados) del Tamagotchi.En el modo Test funcionan de la misma manera

Selección : Al pulsarse permite al usuario unicamente aumentar el valor del sistema de puntos del respectivo estado (subir la puntuación) hasta el valor máximo y luego se detiene. En el modo test una vez que llega al máximo, si se vuelve a pulsar va al valor mínimo de la puntuación y empieza a aumentar (Puntuación rotativa).

Acelerado de Tiempo (Acel): Al presionarse le permite al usuario aumentar el tiempo en el que transcurren los eventos del tamagotchi. 


### 2.2 Sistema de Sensado

Para integrar al Tamagotchi con el entorno real y enriquecer la experiencia de interacción, se incorporará al menos un sensor que modifique el comportamiento de la mascota virtual en respuesta a estímulos externos. Los sensores permitirán simular condiciones ambientales y actividades que afecten directamente el bienestar de la mascota. Los siguientes son ejemplos de sensores y sus aplicaciones potenciales:

Sensor de Color: Permite al Tamagotchi “alimentarse” de colores específicos presentes en su entorno, cada uno asociado a diferentes tipos de nutrientes o efectos:
Nutrición Variada: La identificación de diferentes colores se traduce en una variedad de alimentos consumidos, impactando positiva o negativamente en la salud y el estado anímico del Tamagotchi.


### 2.3 Sistema de Visualización

Pantalla LCD: Esencial para representar visualmente el estado actual del Tamagotchi, incluyendo emociones y necesidades básicas. También sirve para  mostrar niveles y puntuaciones específicas, como el nivel de hambre o felicidad.

## 3. Arquitectura del Sistema

### 3.1 Diagramas de Bloques 
BORRAR (Incluiría un diagrama básico que muestre la FPGA, la pantalla, los botones de entrada y cualquier otro componente clave).
#### 3.1.1 Caja Negra




#### 3.1.2 Funcional



### 3.2 Descripción de Componentes



### 3.3 Interfaces 

Comunicación entre la FPGA y la pantalla. Entradas digitales para los botones. Comunicación entre la FPGA y el sensor.


## 4 Especificaciones de Diseño Detalladas

### 4.1 Modos de operación
#### 4.1.1 Modo Test
El modo Test permite a los usuarios y desarrolladores validar la funcionalidad del sistema y sus estados sin necesidad de seguir el flujo de operación normal. En este modo, se pueden forzar transiciones de estado específicas mediante interacciones simplificadas, como pulsaciones cortas de botones, para verificar las respuestas del sistema y la visualización. Este modo es esencial durante la fase de desarrollo para pruebas rápidas y efectivas de nuevas características o para diagnóstico de problemas.

Activación: Se ingresa al modo Test manteniendo pulsado el botón “Test” por un periodo de 5 segundos.
Funcionalidad: Permite la navegación manual entre los estados del Tamagotchi, ignorando los temporizadores o eventos aleatorios, para observar directamente las respuestas y animaciones asociadas.

#### 4.1.2 Modo Normal 
El Modo Normal es el estado de operación estándar del Tamagotchi, donde la interacción y respuesta a las necesidades de la mascota virtual dependen enteramente de las acciones del usuario.

Activación: El sistema arranca por defecto en el Modo Normal tras el encendido o reinicio del dispositivo. No requiere una secuencia de activación especial, ya que es el modo de funcionamiento predeterminado.

Funcionalidad: Los usuarios interactúan con la mascota a través de botones y, potencialmente, sensores para satisfacer sus necesidades básicas. La mascota transita entre diferentes estados (por ejemplo, Hambriento, Feliz, Dormido, Enfermo) en respuesta a las acciones del usuario y al paso del tiempo. El sistema proporciona retroalimentación inmediata sobre las acciones mediante la visualización.

#### 4.1.3 Modo Aceleración 
El modo Aceleración incrementa la velocidad a la que transcurren los eventos y el paso del tiempo dentro de la simulación del Tamagotchi, permitiendo a los usuarios experimentar ciclos de vida más rápidos y evaluar cómo las interacciones afectan al estado de la mascota en un periodo comprimido.

Activación: Se activa pulsando el botón dedicado a “Aceleración de Tiempo”, con cada pulsación aumentando la velocidad de simulación (por ejemplo, 2x, 4x, 8x, x16).
Funcionalidad: Todos los temporizadores internos y los ciclos de eventos operan a una velocidad incrementada, acelerando la necesidad de interacciones como alimentar, jugar o curar.

### 4.2 Estados y Transiciones

#### 4.2.1 Estados

El Tamagotchi operará a través de una serie de estados que reflejan las necesidades físicas y emocionales de la mascota virtual, a saber:

Hambriento: Este estado alerta sobre la necesidad de alimentar a la mascota. La falta de atención a esta necesidad puede desencadenar un estado de enfermedad.

Diversión: Denota la necesidad de entretenimiento de la mascota. La inactividad prolongada puede llevar a estados de aburrimiento o tristeza.

Descansar: Identifica cuando la mascota requiere reposo para recuperar energía, especialmente después de períodos de actividad intensa o durante la noche, limitando la interacción del usuario durante estas fases.

Salud: va a niveles de enfermo por el descuido en el cuidado de la mascota, requiriendo intervenciones específicas para su recuperación.

Feliz: Refleja el bienestar general de la mascota como resultado de satisfacer adecuadamente sus necesidades básicas.

#### 4.2.2 Transiciones

#### Temporizadores
Se implementarán temporizadores para simular el avance temporal, afectando las necesidades básicas del Tamagotchi. A medida que el tiempo progresa, ciertas necesidades como el hambre incrementarán de forma gradual, requiriendo intervención del usuario para suministrar alimento a la mascota y mantener su estado de salud óptimo.

#### Interacciones y Eventos Aleatorios

Las transiciones entre diferentes estados de la mascota se desencadenarán por interacciones directas del usuario, utilizando botones y sensores. Estas acciones permitirán al usuario influir activamente en el bienestar y comportamiento de la mascota virtual.

#### Sistema de Niveles o Puntos

Se desarrollará un sistema de niveles o puntuación que reflejará la calidad del cuidado proporcionado al Tamagotchi. Aspectos como el nivel de hambre y felicidad fluctuarán en una escala de 1 a 5, donde acciones positivas como alimentar o interactuar con la mascota incrementarán dichos niveles, mientras que la inactividad o negligencia resultará en su disminución. Este mecanismo brindará retroalimentación constante al usuario sobre la condición actual de la mascota virtual.