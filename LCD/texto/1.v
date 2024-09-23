module LCD1602_controller #(
    // Parámetros de configuración
    parameter num_commands = 4,                 // Número de comandos que se enviarán al LCD
    parameter num_data_all = 32,                // Número total de datos a enviar (incluye ambas líneas del LCD)
    parameter num_data_perline = 16,            // Número de datos por línea (16 caracteres por línea en un LCD 16x2)
    parameter COUNT_MAX = 800000                // Máximo valor del contador para generar un pulso de reloj (ajusta el tiempo)
)(
    input clk,                                  // Reloj de entrada
    input reset,                                // Señal de reinicio
    input ready_i,                              // Señal de listo para comenzar
    output reg rs,                              // Registro para seleccionar comando o datos
    output reg rw,                              // Registro de lectura/escritura
    output enable,                              // Señal de habilitación
    output reg [7:0] data                       // Datos a enviar al LCD
);

    // Definición de los estados del controlador
    localparam IDLE = 3'b000;                    // Estado de reposo (espera)
    localparam CMD1 = 3'b001;                    // Estado de envío de comandos iniciales
    localparam DATA_1L = 3'b010;                 // Estado de envío de datos de la primera línea
    localparam CMD2 = 3'b011;                    // Estado de envío de comandos adicionales (segunda línea)
    localparam DATA_2L = 3'b100;                 // Estado de envío de datos de la segunda línea

    reg [2:0] fsm_state;                         // Estado actual de la máquina de estados
    reg [2:0] next;                              // Próximo estado
    reg clk_16ms;                                // Reloj de 16ms
    reg [$clog2(COUNT_MAX)-1:0] counter;         // Contador para generar el reloj de 16ms

    // Comandos de configuración del LCD
    localparam CLEAR_DISPLAY = 8'h01;            // Comando para limpiar la pantalla
    localparam SHIFT_CURSOR_RIGHT = 8'h06;       // Comando para mover el cursor a la derecha
    localparam DISPON_CURSOROFF = 8'h0C;         // Comando para encender la pantalla y apagar el cursor
    localparam DISPON_CURSORBLINK = 8'h0E;       // Comando para encender la pantalla y hacer que el cursor parpadee
    localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;// Configuración para 2 líneas, modo 8 bits
    localparam LINES2_MATRIX5x8_MODE4bit = 8'h28;// Configuración para 2 líneas, modo 4 bits
    localparam LINES1_MATRIX5x8_MODE8bit = 8'h30;// Configuración para 1 línea, modo 8 bits
    localparam LINES1_MATRIX5x8_MODE4bit = 8'h20;// Configuración para 1 línea, modo 4 bits
    localparam START_2LINE = 8'hC0;              // Comando para iniciar la segunda línea

    // Contadores para los comandos y los datos
    reg [$clog2(num_commands):0] command_counter; // Contador para el número de comandos enviados
    reg [$clog2(num_data_perline):0] data_counter;// Contador para el número de datos enviados por línea

    // Memorias para almacenar comandos y datos a enviar
    reg [7:0] data_memory [0: num_data_all-1];   // Memoria para almacenar los datos a enviar al LCD
    reg [7:0] config_memory [0:num_commands-1];  // Memoria para almacenar los comandos de configuración del LCD

    // Inicialización de registros
    integer i;
    initial begin
        fsm_state <= IDLE;                       // Estado inicial en reposo
        command_counter <= 'b0;                  // Inicializa el contador de comandos
        data_counter <= 'b0;                     // Inicializa el contador de datos
        rs <= 'b0;                               // Inicializa el registro de comando/dato
        rw <= 0;                                 // Inicializa el registro de lectura/escritura
        data <= 'b0;                             // Inicializa el registro de datos
        clk_16ms <= 0;                           // Inicializa el reloj de 16ms
        counter <= 0;                            // Inicializa el contador
        $readmemh("path_to_data.txt", data_memory); // Carga los datos desde un archivo externo
        // Configuración de comandos para inicializar el LCD
        config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
        config_memory[1] <= SHIFT_CURSOR_RIGHT;
        config_memory[2] <= DISPON_CURSOROFF;
        config_memory[3] <= CLEAR_DISPLAY;
    end

    // Generación de un reloj de 16ms basado en el contador
    always @(posedge clk) begin
        if (counter == COUNT_MAX-1) begin
            clk_16ms <= ~clk_16ms;               // Invertir el reloj cada COUNT_MAX ciclos
            counter <= 0;                        // Reiniciar el contador
        end else begin
            counter <= counter + 1;              // Incrementar el contador
        end
    end

    // Cambio de estado de la máquina de estados en cada flanco del reloj de 16ms
    always @(posedge clk_16ms) begin
        if(reset == 0) begin
            fsm_state <= IDLE;                   // Si se reinicia, volver al estado IDLE
        end else begin
            fsm_state <= next;                   // Avanzar al próximo estado
        end
    end

    // Lógica combinacional para determinar el próximo estado
    always @(*) begin
        case(fsm_state)
            IDLE: begin
                next <= (ready_i) ? CMD1 : IDLE; // Si está listo, avanzar al estado CMD1, de lo contrario, permanecer en IDLE
            end
            CMD1: begin 
                next <= (command_counter == num_commands) ? DATA_1L : CMD1; // Si se enviaron todos los comandos, pasar a DATA_1L
            end
            DATA_1L: begin
                if (data_counter == num_data_perline) begin // Si se enviaron todos los datos de la primera línea
                    if (config_memory[0] == LINES2_MATRIX5x8_MODE8bit) begin
                        next <= CMD2; // Si se usa modo de 2 líneas, pasar al estado CMD2
                    end else begin
                        next <= IDLE; // De lo contrario, volver a IDLE
                    end
                end else next = DATA_1L; // Permanecer en DATA_1L si aún no se han enviado todos los datos
            end
            CMD2: begin 
                next <= DATA_2L; // Después de CMD2, pasar a enviar datos de la segunda línea
            end
            DATA_2L: begin
                next <= (data_counter == num_data_perline) ? IDLE : DATA_2L; // Si se enviaron todos los datos de la segunda línea, volver a IDLE
            end
            default: next = IDLE; // Estado por defecto es IDLE
        endcase
    end

    // Lógica secuencial para manejar los registros y las señales de salida
    always @(posedge clk_16ms) begin
        if (reset == 0) begin
            command_counter <= 'b0;              // Reiniciar el contador de comandos
            data_counter <= 'b0;                 // Reiniciar el contador de datos
            data <= 'b0;                         // Reiniciar el registro de datos
            $readmemh("path_to_data.txt", data_memory); // Recargar los datos desde el archivo externo
        end
        else begin
            case (next)
                IDLE: begin
                    command_counter <= 'b0;      // Reiniciar el contador de comandos
                    data_counter <= 'b0;         // Reiniciar el contador de datos
                    data <= 'b0;                 // Reiniciar el registro de datos
                    rs <= 'b0;                   // Reiniciar el registro de comando/dato
                end
                CMD1: begin
                    command_counter <= command_counter + 1; // Incrementar el contador de comandos
                    rs <= 0;                                // Señalar que se está enviando un comando
                    data <= config_memory[command_counter]; // Cargar el comando desde la memoria de configuración
                end
                DATA_1L: begin
                    data_counter <= data_counter + 1; // Incrementar el contador de datos
                    rs <= 1;                          // Señalar que se están enviando datos
                    data <= data_memory[data_counter]; // Cargar los datos desde la memoria de datos
                end
                CMD2: begin
                    data_counter <= 'b0;              // Reiniciar el contador de datos para la segunda línea
                    rs <= 0; 
                    data <= START_2LINE;              // Comando para iniciar la segunda línea
                end
                DATA_2L: begin
                    data_counter <= data_counter + 1; // Incrementar el contador de datos para la segunda línea
                    rs <= 1;                          // Señalar que se están enviando datos
                    data <= data_memory[num_data_perline + data_counter];
            end
        endcase
    end
end

assign enable = clk_16ms;

endmodule