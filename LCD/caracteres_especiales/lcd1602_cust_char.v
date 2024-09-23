module lcd1602_cust_char #(parameter num_commands = 3, 
                                      num_data_all = 64,  // Total de datos para caracteres personalizados (8 caracteres x 8 bytes)
                                      char_data = 8, 
                                      num_cgram_addrs = 8,  // Número de direcciones CGRAM (8 caracteres personalizados)
                                      COUNT_MAX = 800000)(
    input clk,            
    input reset,          
    input ready_i,
    output reg rs,        
    output reg rw,
    output enable,    
    output reg [7:0] data
);

// Definir los estados de la máquina de estados (FSM)
localparam IDLE = 0;
localparam INIT_CONFIG = 1;
localparam CLEAR_COUNTERS0 = 2;
localparam CREATE_CHARS = 3;
localparam CLEAR_COUNTERS1 = 4;
localparam SET_CURSOR_AND_WRITE = 5;
//// comandos de la LCD (createchars_task)
localparam SET_CGRAM_ADDR = 0;
localparam WRITE_CHARS = 1;
localparam SET_CURSOR = 2;
localparam WRITE_LCD = 3;

// Direcciones de escritura de la CGRAM para 8 caracteres
localparam CGRAM_ADDR0 = 8'h40;
localparam CGRAM_ADDR1 = 8'h48;
localparam CGRAM_ADDR2 = 8'h50;
localparam CGRAM_ADDR3 = 8'h58;
localparam CGRAM_ADDR4 = 8'h60;
localparam CGRAM_ADDR5 = 8'h68;
localparam CGRAM_ADDR6 = 8'h70;
localparam CGRAM_ADDR7 = 8'h78;

reg [3:0] fsm_state;  // Estado actual de la FSM
reg [3:0] next;  // Siguiente estado de la FSM
reg clk_16ms;  // Reloj dividido a 16ms

// Definir un contador para el divisor de frecuencia
reg [$clog2(COUNT_MAX)-1:0] counter_div_freq;

// Comandos de configuración del LCD
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;

// Definir contadores para diferentes propósitos
reg [$clog2(num_commands):0] command_counter;  // Contador de comandos
reg [$clog2(num_data_all):0] data_counter;  // Contador de datos
reg [$clog2(char_data):0] char_counter;  // Contador de caracteres
reg [$clog2(num_cgram_addrs):0] cgram_addrs_counter;  // Contador de direcciones CGRAM

// Banco de registros para comandos y datos
reg [7:0] data_memory [0: num_data_all-1];  // Memoria para datos de caracteres personalizados
reg [7:0] config_memory [0:num_commands-1];  // Memoria para comandos de configuración
reg [7:0] cgram_addrs [0: num_cgram_addrs-1];  // Memoria para direcciones CGRAM

reg [1:0] create_char_task;  // Tarea actual de creación de caracteres
reg init_config_executed;  // Bandera para indicar si la configuración inicial ha sido ejecutada
wire done_cgram_write;  // Señal para indicar la finalización de la escritura en CGRAM
reg done_lcd_write;  // Señal para indicar la finalización de la escritura en LCD

// Inicialización de registros y memoria
initial begin
    fsm_state <= IDLE;
    data <= 'b0;
    command_counter <= 'b0;
    data_counter <= 'b0;
    rw <= 0;
    rs <= 0;
    clk_16ms <= 'b0;
    counter_div_freq <= 'b0;
    init_config_executed <= 'b0;
    cgram_addrs_counter <= 'b0; 
    char_counter <= 'b0;
    done_lcd_write <= 1'b0; 

    create_char_task <= SET_CGRAM_ADDR;

    // Leer datos de caracteres personalizados desde un archivo
    $readmemb("C:/Users/Brayan/Desktop/2024-1/digital/LCD/caracteres_especiales/PRUEBA.txt", data_memory);    
    
    // Inicializar comandos de configuración
    config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
    config_memory[1] <= DISPON_CURSOROFF;
    config_memory[2] <= CLEAR_DISPLAY;

    // Inicializar direcciones CGRAM
    cgram_addrs[0] <= CGRAM_ADDR0;
    cgram_addrs[1] <= CGRAM_ADDR1;
    cgram_addrs[2] <= CGRAM_ADDR2;
    cgram_addrs[3] <= CGRAM_ADDR3;
    cgram_addrs[4] <= CGRAM_ADDR4;
    cgram_addrs[5] <= CGRAM_ADDR5;
    cgram_addrs[6] <= CGRAM_ADDR6;
    cgram_addrs[7] <= CGRAM_ADDR7;
end

// Divisor de frecuencia para generar el reloj de 16ms
always @(posedge clk) begin
    if (counter_div_freq == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        counter_div_freq <= 0;
    end else begin
        counter_div_freq <= counter_div_freq + 1;
    end
end

// Control de la FSM con el reloj de 16ms
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next;
    end
end

// Lógica combinacional para determinar el próximo estado de la FSM
always @(*) begin
    case(fsm_state)
        IDLE: begin
            next <= (ready_i)? ((init_config_executed)? CREATE_CHARS : INIT_CONFIG) : IDLE;
        end
        INIT_CONFIG: begin 
            next <= (command_counter == num_commands)? CLEAR_COUNTERS0 : INIT_CONFIG;
        end
        CLEAR_COUNTERS0: begin
            next <= CREATE_CHARS;
        end
        CREATE_CHARS: begin
            next <= (done_cgram_write)? CLEAR_COUNTERS1 : CREATE_CHARS;
        end
        CLEAR_COUNTERS1: begin
            next <= SET_CURSOR_AND_WRITE;
        end
        SET_CURSOR_AND_WRITE: begin 
            next <= (done_lcd_write)? CLEAR_COUNTERS0 : SET_CURSOR_AND_WRITE;
        end
        default: next = IDLE;
    endcase
end

// Lógica secuencial para realizar las tareas en cada estado
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        // Reiniciar contadores y señales
        command_counter <= 'b0;
        data_counter <= 'b0;
        data <= 'b0;
        char_counter <= 'b0;
        init_config_executed <= 'b0;
        cgram_addrs_counter <= 'b0;
        done_lcd_write <= 'b0;
        // Recargar datos de caracteres personalizados
        $readmemb("C:/Users/Brayan/Desktop/2024-1/digital/LCD/caracteres_especiales/PRUEBA.txt", data_memory);
    end else begin
        case (next)
            IDLE: begin
                char_counter <= 'b0;
                command_counter <= 'b0;
                data_counter <= 'b0;
                rs <= 'b0;
                cgram_addrs_counter <= 'b0;
                done_lcd_write <= 'b0;
            end
            INIT_CONFIG: begin
                rs <= 'b0;
                command_counter <= command_counter + 1;
                data <= config_memory[command_counter];
                if (command_counter == num_commands - 1) begin
                    init_config_executed <= 'b1;
                end
            end
            CLEAR_COUNTERS0: begin
                data_counter <= 'b0;
                char_counter <= 'b0;
                create_char_task <= SET_CGRAM_ADDR;
                cgram_addrs_counter <= 'b0;
                done_lcd_write <= 'b0;
                rs <= 'b0;
                data <= 'b0;
            end
            CREATE_CHARS: begin
                case (create_char_task)
                    SET_CGRAM_ADDR: begin
                        rs <= 'b0;
                        data <= cgram_addrs[cgram_addrs_counter];
                        create_char_task <= WRITE_CHARS;
                    end
                    WRITE_CHARS: begin
                        rs <= 'b1;
                        data <= data_memory[data_counter];
                        data_counter <= data_counter + 1;
                        if (char_counter == char_data - 1) begin
                            char_counter <= 'b0;
                            create_char_task <= SET_CGRAM_ADDR;
                            cgram_addrs_counter <= cgram_addrs_counter + 1;
                        end else begin
                            char_counter <= char_counter + 1;
                        end
                    end
                endcase
            end
            CLEAR_COUNTERS1: begin
                data_counter <= 'b0;
                char_counter <= 'b0;
                create_char_task <= SET_CURSOR;
                cgram_addrs_counter <= 'b0;
            end
            SET_CURSOR_AND_WRITE: begin
                case (create_char_task)
                    SET_CURSOR: begin
                        rs <= 'b0;
                        data <= (cgram_addrs_counter > 3) ? 8'h80 + (cgram_addrs_counter % 4) + 8'h40 : 8'h80 + (cgram_addrs_counter % 4);
                        create_char_task <= WRITE_LCD;
                    end
                    WRITE_LCD: begin
                        rs <= 'b1;
                        data <= 8'h00 + cgram_addrs_counter;
                        if (cgram_addrs_counter == num_cgram_addrs - 1) begin
                            cgram_addrs_counter <= 'b0;
                            done_lcd_write <= 'b1;
                        end else begin
                            cgram_addrs_counter <= cgram_addrs_counter + 1;
                        end
                        create_char_task <= SET_CURSOR;
                    end
                endcase
            end
        endcase
    end
end

assign enable = clk_16ms;
assign done_cgram_write = (data_counter == num_data_all - 1) ? 'b1 : 'b0;

endmodule
