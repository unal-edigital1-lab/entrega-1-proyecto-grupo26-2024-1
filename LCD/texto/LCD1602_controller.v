//module LCD1602_controller#(
//    parameter num_commands = 4, num_data_all = 80,  num_data_perline = 20, COUNT_MAX = 800000)(
//    input clk,            
//    input reset,          
//    input ready_i,
//    output reg rs,        
//    output reg rw,
//    output enable,    
//    output reg [7:0] data
//);
//
//// Definir los estados del controlador
//localparam IDLE = 3'b000;
//localparam CMD1 = 3'b001;
//localparam DATA_1L = 3'b010;
//localparam CMD2 = 3'b011;
//localparam DATA_2L = 3'b100;
//localparam CMD3 = 3'b101; // Nuevo estado para escribir en la línea 3
//localparam DATA_3L = 3'b110;
//localparam CMD4 = 3'b111; // Nuevo estado para escribir en la línea 4
//localparam DATA_4L = 4'b1000;
//
//reg [3:0] fsm_state;//registro estado actual 
//reg [3:0] next;//registro siguiente estado
//reg clk_16ms;
//reg [$clog2(COUNT_MAX)-1:0] counter;
//
//// Comandos de configuración
//localparam CLEAR_DISPLAY = 8'h01;
//localparam SHIFT_CURSOR_RIGHT = 8'h06;
//localparam DISPON_CURSOROFF = 8'h0C;
//localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;
//localparam START_2LINE = 8'hC0;  // Dirección de la línea 2
//localparam START_3LINE = 8'h94;  // Dirección de la línea 3
//localparam START_4LINE = 8'hD4;  // Dirección de la línea 4
//
//// Definir un contador para controlar el envío de comandos
//reg [$clog2(num_commands):0] command_counter;
//// Definir un contador para controlar el envío de datos
//reg [$clog2(num_data_perline):0] data_counter;
//
//// Banco de registros
//reg [7:0] data_memory [0: num_data_all-1];
//reg [7:0] config_memory [0:num_commands-1]; 
//
//
//initial begin
//    fsm_state <= IDLE;
//    command_counter <= 'b0;
//    data_counter <= 'b0;
//    rs <= 'b0;
//    rw <= 0;
//    data <= 'b0;
//    clk_16ms <= 0;
//    counter <= 0;
//    $readmemh("C:/Users/Brayan/Desktop/2024-1/digital/LCD/texto/data.txt", data_memory);    
//    config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
//    config_memory[1] <= SHIFT_CURSOR_RIGHT;
//    config_memory[2] <= DISPON_CURSOROFF;
//    config_memory[3] <= CLEAR_DISPLAY;
//end
//
//always @(posedge clk) begin
//    if (counter == COUNT_MAX-1) begin
//        clk_16ms <= ~clk_16ms;
//        counter <= 0;
//    end else begin
//        counter <= counter + 1;
//    end
//end
//
//always @(posedge clk_16ms)begin
//    if(reset == 0)begin
//        fsm_state <= IDLE;
//    end else begin
//        fsm_state <= next;
//    end
//end
//
//always @(*) begin
//    case(fsm_state)
//        IDLE: begin
//            next <= (ready_i)? CMD1 : IDLE;
//        end
//        CMD1: begin 
//            next <= (command_counter == num_commands)? DATA_1L : CMD1;
//        end
//        DATA_1L: begin
//            if (data_counter == num_data_perline) begin
//                next <= CMD2;
//            end else next = DATA_1L;
//        end
//        CMD2: begin 
//            next <= DATA_2L;
//        end
//        DATA_2L: begin
//            if (data_counter == num_data_perline) begin
//                next <= CMD3;
//            end else next = DATA_2L;
//        end
//        CMD3: begin
//            next <= DATA_3L;
//        end
//        DATA_3L: begin
//            if (data_counter == num_data_perline) begin
//                next <= CMD4;
//            end else next = DATA_3L;
//        end
//        CMD4: begin
//            next <= DATA_4L;
//        end
//        DATA_4L: begin
//            next <= (data_counter == num_data_perline)? IDLE : DATA_4L;
//        end
//        default: next = IDLE;
//    endcase
//end
//
//// Asignar el estado inicial
//always @(posedge clk_16ms) begin
//    if (reset == 0) begin
//        command_counter <= 'b0;
//        data_counter <= 'b0;
//        data <= 'b0;
//        $readmemh("C:/Users/Brayan/Desktop/2024-1/digital/LCD/texto/data.txt", data_memory);
//    end else begin
//        case (next)
//            IDLE: begin
//                command_counter <= 'b0;
//                data_counter <= 'b0;
//                data <= 'b0;
//                rs <= 'b0;
//            end
//            CMD1: begin
//                command_counter <= command_counter + 1;
//                rs <= 0; 
//                data <= config_memory[command_counter];
//            end
//            DATA_1L: begin
//                data_counter <= data_counter + 1;
//                rs <= 1; 
//                data <= data_memory[data_counter];
//            end
//            CMD2: begin
//                data_counter <= 'b0;
//                rs <= 0; 
//                data <= START_2LINE;
//            end
//            DATA_2L: begin
//                data_counter <= data_counter + 1;
//                rs <= 1; 
//                data <= data_memory[num_data_perline + data_counter];
//            end
//            CMD3: begin
//                data_counter <= 'b0;
//                rs <= 0;
//                data <= START_3LINE;
//            end
//            DATA_3L: begin
//                data_counter <= data_counter + 1;
//                rs <= 1;
//                data <= data_memory[2 * num_data_perline + data_counter];
//            end
//            CMD4: begin
//                data_counter <= 'b0;
//                rs <= 0;
//                data <= START_4LINE;
//            end
//            DATA_4L: begin
//                data_counter <= data_counter + 1;
//                rs <= 1;
//                data <= data_memory[3 * num_data_perline + data_counter];
//            end
//        endcase
//    end
//end
//
//assign enable = clk_16ms;
//
//endmodule
//
//
////
////module LCD1602_controller#(
////    parameter num_commands = 4, num_data_all = 80,  num_data_perline = 40, COUNT_MAX = 800000)(
////    input clk,            
////    input reset,          
////    input ready_i,
////    output reg rs,        
////    output reg rw,
////    output enable,    
////    output reg [7:0] data
////);
////
////// Definir los estados del controlador
////localparam IDLE = 3'b000;
////localparam CMD1 = 3'b001;
////localparam DATA_1L = 3'b010;
////localparam CMD2 = 3'b011;
////localparam DATA_2L = 3'b100;
////
////reg [2:0] fsm_state;//registro estado actual 
////reg [2:0] next;//registro siguiente estado
////reg clk_16ms;
////reg [$clog2(COUNT_MAX)-1:0] counter;
////
////// Comandos de configuración
////localparam CLEAR_DISPLAY = 8'h01;
////localparam SHIFT_CURSOR_RIGHT = 8'h06;
////localparam DISPON_CURSOROFF = 8'h0C;
////localparam DISPON_CURSORBLINK = 8'h0E;
////localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;
////localparam LINES2_MATRIX5x8_MODE4bit = 8'h28;
////localparam LINES1_MATRIX5x8_MODE8bit = 8'h30;
////localparam LINES1_MATRIX5x8_MODE4bit = 8'h20;
////localparam START_2LINE = 8'hC0;
////
////
////// Definir un contador para controlar el envío de comandos
////reg [$clog2(num_commands):0] command_counter;
////// Definir un contador para controlar el envío de datos
////reg [$clog2(num_data_perline):0] data_counter;
////
////// Banco de registros
////reg [7:0] data_memory [0: num_data_all-1];
////reg [7:0] config_memory [0:num_commands-1]; 
////
////integer i;
////
////initial begin
////    fsm_state <= IDLE;
////    command_counter <= 'b0;
////    data_counter <= 'b0;
////    rs <= 'b0;
////    rw <= 0;
////    data <= 'b0;
////    clk_16ms <= 0;
////    counter <= 0;
////    $readmemh("C:/Users/Brayan/Desktop/2024-1/digital/LCD/texto/data.txt", data_memory);    
////	config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
////	config_memory[1] <= SHIFT_CURSOR_RIGHT;
////	config_memory[2] <= DISPON_CURSOROFF;
////	config_memory[3] <= CLEAR_DISPLAY;
////end
////
////always @(posedge clk) begin
////    if (counter == COUNT_MAX-1) begin
////        clk_16ms <= ~clk_16ms;
////        counter <= 0;
////    end else begin
////        counter <= counter + 1;
////    end
////end
////
////
////always @(posedge clk_16ms)begin
////    if(reset == 0)begin
////        fsm_state <= IDLE;
////    end else begin
////        fsm_state <= next;
////    end
////end
////
////always @(*) begin
////    case(fsm_state)
////        IDLE: begin
////            next <= (ready_i)? CMD1 : IDLE;
////        end
////        CMD1: begin 
////            next <= (command_counter == num_commands)? DATA_1L : CMD1;
////        end
////        DATA_1L:begin
////            if (data_counter == num_data_perline) begin
////				if (config_memory[0] == LINES2_MATRIX5x8_MODE8bit) begin
////				    next <= CMD2;
////				end else begin
////					next <= IDLE;
////				end
////            end else next = DATA_1L;
////        end
////        CMD2: begin 
////            next <= DATA_2L;
////        end
////		DATA_2L: begin
////			next <= (data_counter == num_data_perline)? IDLE : DATA_2L;
////		end
////        default: next = IDLE;
////    endcase
////end
////
////// Asignar el estado inicial
////always @(posedge clk_16ms) begin
////    if (reset == 0) begin
////        command_counter <= 'b0;
////        data_counter <= 'b0;
////		  data <= 'b0;
////        $readmemh("C:/Users/Brayan/Desktop/2024-1/digital/LCD/texto/data.txt", data_memory);
////    end else begin
////        case (next)
////            IDLE: begin
////                command_counter <= 'b0;
////                data_counter <= 'b0;
////                data <= 'b0;
////                rs <= 'b0;
////            end
////            CMD1: begin
////                command_counter <= command_counter + 1;
////				rs <= 0; 
////			    data <= config_memory[command_counter];
////            end
////            DATA_1L: begin
////                data_counter <= data_counter + 1;
////                rs <= 1; 
////				data <= data_memory[data_counter];
////            end
////            CMD2: begin
////                data_counter <= 'b0;
////				rs <= 0; data <= START_2LINE;
////            end
////			DATA_2L: begin
////                data_counter <= data_counter + 1;
////                rs <= 1; 
////				data <= data_memory[num_data_perline + data_counter];
////            end
////        endcase
////    end
////end
////
////assign enable = clk_16ms;
////
////endmodule
module LCD1602_controller#(
    parameter num_commands = 4, num_data_all = 5120,  num_data_perline = 20, COUNT_MAX = 800000)(
    input clk,            
    input reset,          
    input ready_i,
    input [2:0] message_select,  // Entrada de 3 bits para seleccionar el mensaje
    input [2:0] memory_select,   // Entrada de 3 bits para seleccionar la memoria
    input [2:0] variable_a, // Entrada menor a 10
	 input [2:0] variable_b, // Otra entrada menor a 10
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

reg [3:0] fsm_state; // Estado actual de la FSM
reg [3:0] next;      // Siguiente estado de la FSM
reg clk_16ms;
reg [$clog2(COUNT_MAX)-1:0] counter;
reg configuracion_ready;  // Variable para controlar la configuración

// Comandos de configuración
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;
localparam START_2LINE = 8'hC0;  // Dirección de la línea 2
localparam START_3LINE = 8'h94;  // Dirección de la línea 3
localparam START_4LINE = 8'hD4;  // Dirección de la línea 4

// Contadores para controlar el envío de comandos y datos
reg [$clog2(num_commands):0] command_counter;
reg [$clog2(num_data_perline):0] data_counter;

// Memorias para datos y configuraciones
reg [7:0] data_memory [0: num_data_all-1];
reg [7:0] config_memory [0:num_commands-1]; 

// Variables para seleccionar el punto de inicio de los datos
reg [9:0] start_address;
reg [12:0] memory_offset; // Offset para la memoria seleccionada

// Inicialización de variables
initial begin
    fsm_state <= IDLE;
    command_counter <= 'b0;
    data_counter <= 'b0;
    rs <= 'b0;
    rw <= 0;
    data <= 'b0;
    clk_16ms <= 0;
    counter <= 0;
    configuracion_ready <= 0;
    $readmemh("C:/Users/Brayan/Desktop/2024-1/digital/LCD/texto/data.txt", data_memory);    
    config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
    config_memory[1] <= SHIFT_CURSOR_RIGHT;
    config_memory[2] <= DISPON_CURSOROFF;
    config_memory[3] <= CLEAR_DISPLAY;
end

// Generación de reloj de 16 ms
always @(posedge clk) begin
    if (counter == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        counter <= 0;
    end else begin
        counter <= counter + 1;
    end
end

// Máquina de estados principal
always @(posedge clk_16ms) begin
    if(reset == 0) begin
        fsm_state <= IDLE;
        //configuracion_ready <= 0; // Resetear la configuración
    end else begin
        fsm_state <= next;
    end
end

// Lógica para la selección del punto de inicio según el mensaje y la memoria
always @(*) begin
    case (message_select)
        3'b000: start_address <= 0;    // Mensaje 1
        3'b001: start_address <= 80;   // Mensaje 2
        3'b010: start_address <= 160;  // Mensaje 3
        3'b011: start_address <= 240;  // Mensaje 4
        3'b100: start_address <= 320;  // Mensaje 5
        3'b101: start_address <= 400;  // Mensaje 6
        3'b110: start_address <= 480;  // Mensaje 7
        3'b111: start_address <= 560;  // Mensaje 8
        default: start_address = 0;    // Por defecto, Mensaje 1
    endcase

    // Ajustar el offset de la memoria seleccionada
    case (memory_select)
        3'b000: memory_offset <= 0;
        3'b001: memory_offset <= 640;
        3'b010: memory_offset <= 1280;
        3'b011: memory_offset <= 1920;
        3'b100: memory_offset <= 2560;
        3'b101: memory_offset <= 3200;
        3'b110: memory_offset <= 3840;
        3'b111: memory_offset <= 4480;
        default: memory_offset <= 0;
    endcase
end

// Trancisiones de la Máquina de estados
always @(*) begin
    case(fsm_state)
        IDLE: begin
            next <= (ready_i)? CMD1 : IDLE;
        end


        CMD1: begin
            if (!configuracion_ready) begin
                next <= (command_counter == num_commands)? DATA_1L : CMD1;
            end else begin
                next <= DATA_1L; // Si ya se configuró, saltar a DATA_1L
            end
        end
        DATA_1L: begin
            next <= (data_counter == num_data_perline)? CMD2 : DATA_1L;
        end
        CMD2: begin
            next <= DATA_2L;
        end
        DATA_2L: begin
            next <= (data_counter == num_data_perline)? CMD3 : DATA_2L;
        end
        CMD3: begin
            next <= DATA_3L;
        end
        DATA_3L: begin
            next <= (data_counter == num_data_perline)? CMD4 : DATA_3L;
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

// Lógica para la asignación de comandos y datos
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
        data <= 'b0;
        configuracion_ready <= 0;
    end 
	 else begin
        case (next)
            IDLE: begin
                command_counter <= 'b0;
                data_counter <= 'b0;
                data <= 'b0;
                rs <= 'b0;
            end

            CMD1: begin
                if (!configuracion_ready) begin
                    command_counter <= command_counter + 1;
                    rs <= 0; 
                    data <= config_memory[command_counter];
                    if (command_counter == num_commands - 1) begin
                        configuracion_ready <= 1;  // Marcar configuración como lista
                    end
                end
            end
            DATA_1L:
				begin
                data_counter <= data_counter + 1;
                rs <= 1; 
                if (data_counter == 18) begin
                    data <= variable_a + 8'h30; // Mostrar variable_a como ASCII
                end else if (data_counter == 19) begin
                    data <= variable_b + 8'h30; // Mostrar variable_b como ASCII
                end else begin
                    data <= data_memory[memory_offset + start_address + data_counter]; // Mostrar mensaje
                end
            end

            CMD2: begin
                data_counter <= 'b0;
                rs <= 0; 
                data <= START_2LINE;
            end
            DATA_2L: begin
                data_counter <= data_counter + 1;
                rs <= 1; 
                data <= data_memory[memory_offset + start_address + num_data_perline + data_counter];
            end
            CMD3: begin
                data_counter <= 'b0;
                rs <= 0;
                data <= START_3LINE;
            end
            DATA_3L: begin
                data_counter <= data_counter + 1;
                rs <= 1;
                data <= data_memory[memory_offset + start_address + 2 * num_data_perline + data_counter];
            end
            CMD4: begin
                data_counter <= 'b0;
                rs <= 0;
                data <= START_4LINE;
            end
            DATA_4L: begin
                data_counter <= data_counter + 1;
                rs <= 1;
                data <= data_memory[memory_offset + start_address + 3 * num_data_perline + data_counter];
            end
        endcase
    end
end

assign enable = clk_16ms;

endmodule
