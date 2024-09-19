module color_sensor3(
    input clk,             // Reloj principal
    input rst,             // Reset del sistema
    input sensor_out,      // Señal de salida del sensor TCS3200
    output reg [15:0] red_norm,    // Valor normalizado del componente rojo
    output reg [15:0] green_norm,  // Valor normalizado del componente verde
    output reg [15:0] blue_norm,   // Valor normalizado del componente azul
    output reg luz,        // Salida que indica si la luz es mayor a cierto valor
    output reg [1:0] s2_s3 // Señales de control del sensor (S2 y S3)
);

    reg [20:0] red_count = 0;
    reg [20:0] green_count = 0;
    reg [20:0] blue_count = 0;
    reg [20:0] clear_count = 0;
    reg [2:0] state = 0;
    reg [31:0] time_counter = 0;  // Contador de tiempo en cada estado
    reg [16:0] red_value, green_value, blue_value;  // Valores temporales
    reg [16:0] clear_value; // Valor temporal para la luz
    reg sensor_out_prev;  // Registro para detectar flancos de subida

    localparam S_RED = 2'b00;
    localparam S_GREEN = 2'b01;
    localparam S_BLUE = 2'b10;
    localparam S_CLEAR = 2'b11;
    localparam S_NORMALIZE = 3'b100;  // Estado para la normalización
    localparam TIME_LIMIT = 32'd5000000; // Duración en cada estado (ajustable)
    localparam LUZ_THRESHOLD = 29'd100; // Umbral para la medición de luz

    // FSM para cambiar entre los filtros de color o medición de luz clara
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_RED;
            s2_s3 <= 2'b00;
            time_counter <= 0;
            sensor_out_prev <= 0;
            clear_value <= 0;
        end else begin
            if (time_counter >= TIME_LIMIT) begin
                time_counter <= 0; // Reiniciar contador de tiempo

                case (state)
                    S_RED: begin
                        s2_s3 <= 2'b11;  // Filtro verde
                        state <= S_GREEN;
                    end
                    S_GREEN: begin
                        s2_s3 <= 2'b01;  // Filtro azul
                        state <= S_BLUE;
                    end
                    S_BLUE: begin
                        s2_s3 <= 2'b10;  // Sin filtro (luz clara)
                        state <= S_CLEAR;
                    end
                    S_CLEAR: begin
                        clear_value <= clear_count;  // Guardar el valor de luz
                        state <= S_NORMALIZE;  // Ir a la normalización
                    end
                    S_NORMALIZE: begin
                        state <= S_RED;  // Volver a comenzar el ciclo
                    end
                endcase
            end else begin
                time_counter <= time_counter + 1; // Incrementar el contador de tiempo
            end
            sensor_out_prev <= sensor_out;  // Almacenar el valor actual de sensor_out
        end
    end

    // Contadores para cada componente de color y luz (solo flancos de subida)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            red_count <= 0;
            green_count <= 0;
            blue_count <= 0;
            clear_count <= 0;
        end 
		  else begin
            case (state)
                S_RED: begin
                    if (sensor_out && !sensor_out_prev) begin  // Detectar flanco de subida
                        red_count <= red_count + 1;
                    end
                end
                S_GREEN: begin
                    if (sensor_out && !sensor_out_prev) begin  // Detectar flanco de subida
                        green_count <= green_count + 1;
                    end
                end
                S_BLUE: begin
                    if (sensor_out && !sensor_out_prev) begin  // Detectar flanco de subida
                        blue_count <= blue_count + 1;
                    end
                end
                S_CLEAR: begin
                    if (sensor_out && !sensor_out_prev) begin  // Detectar flanco de subida
                        clear_count <= clear_count + 1;
                    end
                end
                S_NORMALIZE: begin
                    // Guardar los valores normalizados una vez completadas las lecturas
                    if (clear_count > 0) begin
                        red_value <= (red_count * 100) / clear_count;
                        green_value <= (green_count * 131) / clear_count;
                        blue_value <= (blue_count * 130) / clear_count;
                    end else begin
                        red_value <= 0;
                        green_value <= 0;
                        blue_value <= 0;
                    end

                    //Reiniciar los contadores
                    if(time_counter >= TIME_LIMIT)begin
                    red_count <= 0;
                    green_count <= 0;
                    blue_count <= 0;
                    clear_count <= 0;
                    //time_counter <= TIME_LIMIT;
                    end
                end
            endcase
        end
    end

    // Comparación del valor de luz y asignación de la salida luz
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            luz <= 0;
        end else if (clear_value > LUZ_THRESHOLD) begin
            luz <= 1'b0;  // Activar si la luz es mayor al umbral
        end else begin
            luz <= 1'b1;  // Desactivar si la luz es menor al umbral
        end
    end

    // Asignar las salidas normalizadas solo en el estado de normalización
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            red_norm <= 0;
            green_norm <= 0;
            blue_norm <= 0;
        end else if (state == S_NORMALIZE) begin
            red_norm <= red_value;
            green_norm <= green_value;
            blue_norm <= blue_value;
        end
    end

endmodule
