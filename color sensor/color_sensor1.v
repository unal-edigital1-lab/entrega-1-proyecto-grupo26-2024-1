module color_sensor1 (
    input clk,           // Reloj principal del sistema
    input rst,           // Reset
    input sensor_out,    // Señal de salida del sensor (pin OUT)
    output reg [1:0] s2_s3,  // Selección de color (para S2 y S3)
    output reg [15:0] red_norm,   // Valor normalizado de rojo
    output reg [15:0] green_norm, // Valor normalizado de verde
    output reg [15:0] blue_norm   // Valor normalizado de azul
);

    reg [31:0] counter;      // Contador para medir la frecuencia
    reg [31:0] freq_red, freq_green, freq_blue, freq_clear;  // Frecuencia para cada color y el valor sin filtro
    reg [1:0] state;         // FSM para cambiar entre los colores
    reg [15:0] red, green, blue;  // Almacena valores originales de cada color

    // Máquina de estados para seleccionar el color y obtener el valor sin filtro
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            s2_s3 <= 2'b00;  // Empezar midiendo el rojo
        end else begin
            case (state)
                0: begin // Medir rojo
                    s2_s3 <= 2'b00;  // Seleccionar filtro rojo
                    freq_red <= counter;
                    state <= 1;
                end
                1: begin // Medir verde
                    s2_s3 <= 2'b11;  // Seleccionar filtro verde
                    freq_green <= counter;
                    state <= 2;
                end
                2: begin // Medir azul
                    s2_s3 <= 2'b01;  // Seleccionar filtro azul
                    freq_blue <= counter;
                    state <= 3;
                end
                3: begin // Medir valor sin filtro
                    s2_s3 <= 2'b10;  // Sin filtro (valor claro)
                    freq_clear <= counter;
                    state <= 0;
                end
            endcase
        end
    end

    // Contador para medir la frecuencia de salida del sensor
    always @(posedge sensor_out or posedge rst) begin
        if (rst) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    // Normalización de los valores de color
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            red <= 0;
            green <= 0;
            blue <= 0;
            red_norm <= 0;
            green_norm <= 0;
            blue_norm <= 0;
        end else begin
            // Almacenar valores originales
            red <= freq_red;
            green <= freq_green;
            blue <= freq_blue;

            // Normalizar colores usando el valor sin filtro (evitar división por cero)
            if (freq_clear != 0) begin
                red_norm <= (red * 16'd1000) / freq_clear;    // Normalizado en porcentaje
                green_norm <= (green * 16'd1000) / freq_clear;
                blue_norm <= (blue * 16'd1000) / freq_clear;
            end else begin
                red_norm <= 0;
                green_norm <= 0;
                blue_norm <= 0;
            end
        end
    end

endmodule
