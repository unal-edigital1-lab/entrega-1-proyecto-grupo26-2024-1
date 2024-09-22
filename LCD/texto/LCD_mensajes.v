module LCD1602_controller#(
    parameter num_commands = 4, num_data_all = 560,  num_data_perline = 20, COUNT_MAX = 800000)(
    input clk,            
    input reset,          
    input ready_i,
    input [2:0] message_select, // Entrada de 3 bits para seleccionar el mensaje
    output reg rs,        
    output reg rw,
    output enable,    
    output reg [7:0] data
);

// Definir los estados del controlador
localparam IDLE = 4'b0000;
localparam CMD1 = 4'b0001;
localparam DATA_1L = 4'b0010;
localparam CMD2 = 4'b0011;
localparam DATA_2L = 4'b0100;
localparam CMD3 = 4'b0101; 
localparam DATA_3L = 4'b0110;
localparam CMD4 = 4'b0111;
localparam DATA_4L = 4'b1000;

reg [3:0] fsm_state;//registro estado actual 
reg [3:0] next;//registro siguiente estado
reg clk_16ms;
reg [$clog2(COUNT_MAX)-1:0] counter;

// Comandos de configuración
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;
localparam START_2LINE = 8'hC0;  // Dirección de la línea 2
localparam START_3LINE = 8'h94;  // Dirección de la línea 3
localparam START_4LINE = 8'hD4;  // Dirección de la línea 4

// Definir un contador para controlar el envío de comandos
reg [$clog2(num_commands):0] command_counter;
// Definir un contador para controlar el envío de datos
reg [$clog2(num_data_perline):0] data_counter;

// Banco de registros
reg [7:0] data_memory [0: num_data_all-1];
reg [7:0] config_memory [0:num_commands-1]; 

// Variable para controlar el punto de inicio de los datos
reg [9:0] start_address; // Se ajusta según el mensaje seleccionado

initial begin
    fsm_state <= IDLE;
    command_counter <= 'b0;
    data_counter <= 'b0;
    rs <= 'b0;
    rw <= 0;
    data <= 'b0;
    clk_16ms <= 0;
    counter <= 0;
    $readmemh("C:/Users/Brayan/Desktop/2024-1/digital/LCD/texto/data.txt", data_memory);    
    config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
    config_memory[1] <= SHIFT_CURSOR_RIGHT;
    config_memory[2] <= DISPON_CURSOROFF;
    config_memory[3] <= CLEAR_DISPLAY;
end
// reloj 16 m 
always @(posedge clk) begin
    if (counter == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        counter <= 0;
    end else begin
        counter <= counter + 1;
    end
end

always @(posedge clk_16ms) begin
    if(reset == 0) begin
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next;
    end
end

// Selección del punto de inicio según el mensaje
always @(*) begin
    case (message_select)
        3'b000: start_address <= 0;    // Mensaje 1
        3'b001: start_address <= 80;   // Mensaje 2
        3'b010: start_address <= 160;  // Mensaje 3
        3'b011: start_address <= 240;  // mensaje 4
        3'b100: start_address <= 320;  // Mensaje 5
        3'b101: start_address <= 400;  // Mensaje 6
        3'b110: start_address <= 480;  // Mensaje 7
        3'b111: start_address <= 560;  // Mensaje 8

        // Agrega más mensajes según sea necesario
        default: start_address = 0;   // Por defecto, Mensaje 1
    endcase
end

always @(*) begin
    case(fsm_state)
        IDLE: begin
            next <= (ready_i)? CMD1 : IDLE;
        end
        CMD1: begin 
            next <= (command_counter == num_commands)? DATA_1L : CMD1;
        end
        DATA_1L: begin
            if (data_counter == num_data_perline) begin
                next <= CMD2;
            end else next = DATA_1L;
        end
        CMD2: begin 
            next <= DATA_2L;
        end
        DATA_2L: begin
            if (data_counter == num_data_perline) begin
                next <= CMD3;
            end else next = DATA_2L;
        end
        CMD3: begin
            next <= DATA_3L;
        end
        DATA_3L: begin
            if (data_counter == num_data_perline) begin
                next <= CMD4;
            end else next = DATA_3L;
        end
        CMD4: begin
            next <= DATA_4L;
        end
        DATA_4L: begin
            next <= (data_counter == num_data_perline)? IDLE : DATA_4L;
        end
        default: next = IDLE;
    endcase
end

// Asignar el estado inicial
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
        data <= 'b0;
        $readmemh("C:/Users/Brayan/Desktop/2024-1/digital/LCD/texto/data.txt", data_memory);
    end else begin
        case (next)
            IDLE: begin
                command_counter <= 'b0;
                data_counter <= 'b0;
                data <= 'b0;
                rs <= 'b0;
            end
            CMD1: begin
                command_counter <= command_counter + 1;
                rs <= 0; 
                data <= config_memory[command_counter];
            end
            DATA_1L: begin
                data_counter <= data_counter + 1;
                rs <= 1; 
                data <= data_memory[start_address + data_counter]; // Inicio ajustado según message_select
            end
            CMD2: begin
                data_counter <= 'b0;
                rs <= 0; 
                data <= START_2LINE;
            end
            DATA_2L: begin
                data_counter <= data_counter + 1;
                rs <= 1; 
                data <= data_memory[start_address + num_data_perline + data_counter];
            end
            CMD3: begin
                data_counter <= 'b0;
                rs <= 0;
                data <= START_3LINE;
            end
            DATA_3L: begin
                data_counter <= data_counter + 1;
                rs <= 1;
                data <= data_memory[start_address + 2 * num_data_perline + data_counter];
            end
            CMD4: begin
                data_counter <= 'b0;
                rs <= 0;
                data <= START_4LINE;
            end
            DATA_4L: begin
                data_counter <= data_counter + 1;
                rs <= 1;
                data <= data_memory[start_address + 3 * num_data_perline + data_counter];
            end
        endcase
    end
end

assign enable = clk_16ms;

endmodule
