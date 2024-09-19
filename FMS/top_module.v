/*`include "fsm_mascota.v"
`include "display_dec.v"

module top_module (
    input clk,         // Reloj
    input rst,         // Reset
    input A,           // Entrada para la FSM
    input B,           // Entrada para la FSM
    input C,           // Entrada para la FSM

    input [1:0] time_control,  // Entrada de 2 bits para modificar el contador de tiempo en la FSM
    output [0:6] sseg, // Salida a 7 segmentos
    output [7:0] an,   // Salida registrada de cátodos
    output led         // LED para el indicador de habilitación
);

    // Señales para conectar las salidas de la FSM con las entradas del display
    wire [7:0] fsm_output1;  // Salida de 8 bits de la FSM
    wire [3:0] fsm_output2;  // Salida de 4 bits de la FSM

    // Instancia de la FSM
    fsm_mascota fsm (
        .clk(clk),
        .reset(rst),
        .A(A),
        .B(B),
        .C(C),
        .test(test),
        .luz(luz),
        .time_control(time_control),
        .output1(fsm_output1),
        .output2(fsm_output2)
    );

    // Instancia del módulo de visualización
    display_dec display (
        .clk(clk),
        .rst(rst),
        .numA(fsm_output1),      // Conectando la salida de la FSM a numA del display
        .numB({4'b0000, fsm_output2}),  // Conectando la salida de la FSM a numB del display, llenando con ceros los 4 bits superiores
        .sseg(sseg),
        .an(an),
        .led(led)
    );

endmodule

//`include "fsm_mascota.v"
//`include "display_dec.v"

module top_module (
    input clk,         // Reloj
    //input rst,         // Reset
    input A,           // Entrada para la FSM
    input B,           // Entrada para la FSM
    input C,           // Entrada para la FSM

    output [6:0] sseg, // Salida a 7 segmentos
    output [7:0] an,   // Salida registrada de cátodos
    output led         // LED para el indicador de habilitación
);

    // Señales para conectar las salidas de la FSM con las entradas del display
    wire [7:0] fsm_output1;  // Salida de 8 bits de la FSM
    wire [3:0] fsm_output2;  // Salida de 4 bits de la FSM

    // Señales internas con valores constantes
    wire [1:0] time_control = 2'b10;  // Establecer valor fijo para el control del tiempo
    wire luz = 1'b0;  // Establecer valor fijo para la señal luz
    wire test = 1'b0; // Ejemplo de valor fijo para test (ajustar según necesidades)
	 wire rst =1'b0;
		
    // Instancia de la FSM
    fsm_mascota fsm (
        .clk(clk),
        .reset(rst),
        .A(A),
        .B(B),
        .C(C),
        .test(test),
        .luz(luz),
        .time_control(time_control),
        .output1(fsm_output1),
        .output2(fsm_output2)
    );
    
    // Instancia del módulo de visualización
    display_dec display (
        .clk(clk),
        .rst(rst),
        .numA(fsm_output1),      // Conectando la salida de la FSM a numA del display
        .numB({4'b0000, fsm_output2}),  // Conectando la salida de la FSM a numB del display, llenando con ceros los 4 bits superiores
        .sseg(sseg),
        .an(an),
        .led(led)
    );

endmodule
*/
//`include "fsm_mascota.v"
//`include "display_dec.v"

// Definición del módulo top con anti-rebote
//module top_module (
//    input clk,         // Reloj
//    input rst,         // Reset
//    input A,           // Entrada para la FSM
//    input B,           // Entrada para la FSM
//    input C,           // Entrada para la FSM
//
//    //input [1:0] time_control,  // Entrada de 2 bits para modificar el contador de tiempo en la FSM
//    output [6:0] sseg, // Salida a 7 segmentos
//    output [7:0] an,   // Salida registrada de cátodos
//    output led         // LED para el indicador de habilitación
//);
//
//    // Señales para conectar las salidas de la FSM con las entradas del display
//    wire [7:0] fsm_output1;  // Salida de 8 bits de la FSM
//    wire [3:0] fsm_output2;  // Salida de 4 bits de la FSM
//	 
//	     // Señales para la salida del anti-rebote
//    wire db_A_level, db_A_tick;
//    wire db_B_level, db_B_tick;
//    wire db_C_level, db_C_tick;
//	 wire db_rst_level, db_rst_tick;
//
//    // Instanciar el módulo debounce para el botón A
//    debounce db_A (
//        .clk(clk),
//        .reset(reset),
//        .sw(A),
//		  .mode(1'b0),
//        .db_level(db_A_level),
//        .db_tick(db_A_tick)
//    );
//
//    // Instanciar el módulo debounce para el botón B
//    debounce db_B (
//        .clk(clk),
//        .reset(reset),
//        .sw(B),
//		  .mode(1'b0),
//        .db_level(db_B_level),
//        .db_tick(db_B_tick)
//    );
//
//    // Instanciar el módulo debounce para el botón C
//    debounce db_C (
//        .clk(clk),
//        .reset(reset),
//        .sw(C),
//		  .mode(1'b0),
//        .db_level(db_C_level),
//        .db_tick(db_C_tick)
//    );
//	 
//	     debounce db_rst (
//        .clk(clk),
//        .reset(reset),
//        .sw(rst),
//		  .mode(1'b1),
//        .db_level(db_rst_level),
//        .db_tick(db_rst_tick)
//    );
//	 
//	 
////////////
////    // Señales debounced
////    wire debounced_A;
////    wire debounced_B;
////    wire debounced_C;
//
//    // Instanciar el módulo de anti-rebote para cada entrada
////    debounce_better_version debounce_A (
////        .pb_1(A),
////        .clk(clk),
////        //.mode_select(1'b0), // Seleccionar modo si es necesario
////        .pb_out(debounced_A)
////    );
////
////    debounce_better_version debounce_B (
////        .pb_1(B),
////        .clk(clk),
////        //.mode_select(1'b0), // Seleccionar modo si es necesario
////        .pb_out(debounced_B)
////    );
////
////    debounce_better_version debounce_C (
////        .pb_1(C),
////        .clk(clk),
////        //.mode_select(1'b1), // Seleccionar modo si es necesario
////        .pb_out(debounced_C)
////    );
//
//    // Instancia de la FSM
//    fsm_mascota fsm (
//        .clk(clk),
//        .reset(rst),
//		  .A(db_A_tick),  // Conectar la salida del debounce A a la entrada A de la FSM
//        .B(db_B_tick),  // Conectar la salida del debounce B a la entrada B de la FSM
//        .C(db_C_tick),  // Conectar la salida del debounce C a la entrada C de la FSM
////        .A(debounced_A),  // Conectar las señales debounced a la FSM
////        .B(debounced_B),
////        .C(debounced_C),
//        .test(1'b0),      // Asume que test es 0 en este contexto; ajusta si es necesario
//        .color(2'b00),   // Asume un valor de color por defecto; ajusta según tu lógica
//        .time_control(2'b10),
//        .luz(1'b1),      // Asume que luz es 0 en este contexto; ajusta si es necesario
//        .output1(fsm_output1),
//        .output2(fsm_output2)
//    );
//    
//    // Instancia del módulo de visualización
//    display_dec display (
//        .clk(clk),
//        .rst(1'b0),
//        .numA(fsm_output1),      // Conectando la salida de la FSM a numA del display
//        .numB({4'b0000, fsm_output2}),  // Conectando la salida de la FSM a numB del display, llenando con ceros los 4 bits superiores
//        .sseg(sseg),
//        .an(an),
//        .led(led)
//    );
//
//endmodule
/////////////////////////////////////top con color 

module top_module (
    input clk,         // Reloj
    input rst,         // Reset
    input A,           // Entrada para la FSM
    input B,           // Entrada para la FSM
    input C,           // Entrada para la FSM
    input sensor_out,  // Entrada del sensor de color TCS3200
	output [2:0] led_s0_s1,   // control led y s0 s1
	output [1:0] s2_s3,
    output [6:0] sseg, // Salida a 7 segmentos
    output [7:0] an,   // Salida registrada de cátodos
    output led,        // LED para el indicador de habilitación
    output [2:0] color, // Salida del color detectado
    output luz,         // Salida de la señal de luz detectada
	output [7:0] lcd_data,
    output lcd_rs,
    output lcd_rw,
    output lcd_enable
);

    // Señales para conectar las salidas de la FSM con las entradas del display
    wire [7:0] fsm_output1;  // Salida de 8 bits de la FSM
    wire [3:0] fsm_output2;  // Salida de 4 bits de la FSM

    // Señales para la salida del anti-rebote
    wire db_A_level, db_A_tick;
    wire db_B_level, db_B_tick;
    wire db_C_level, db_C_tick;
    wire db_rst_level, db_rst_tick;

    // Señales de control del sensor de color
    //wire [1:0] s2_s3;
    //wire [2:0] led_s0_s1;

    // Instanciar el módulo debounce para el botón A
//    debounce db_A (
//        .clk(clk),
//        .reset(rst),
//        .sw(A),
//        .mode(1'b0),
//        .db_level(db_A_level),
//        .db_tick(db_A_tick)
//    );
//
//    // Instanciar el módulo debounce para el botón B
//    debounce db_B (
//        .clk(clk),
//        .reset(rst),
//        .sw(B),
//        .mode(1'b0),
//        .db_level(db_B_level),
//        .db_tick(db_B_tick)
//    );

    // Instanciar el módulo debounce para el botón C
//    debounce db_C (
//        .clk(clk),
//        .reset(rst),
//        .sw(C),
//        .mode(1'b0),
//        .db_level(db_C_level),
//        .db_tick(db_C_tick)
//    );

		antirebote anti_A(
		.boton(A),
		.clk(clk),
		.botondebounced(db_A_tick)
		);
		
		antirebote anti_B(
		.boton(B),
		.clk(clk),
		.botondebounced(db_B_tick)
		);
		
		antirebote anti_C(
		.boton(C),
		.clk(clk),
		.botondebounced(db_C_tick)
		);
		//rst
		antirebote anti_rst(
		.boton(rst),
		.clk(clk),
		.botondebounced(db_rst_tick)
		);
		
    // Debounce para el reset
//    debounce db_rst (
//        .clk(clk),
//        .reset(rst),
//        .sw(rst),
//        .mode(1'b1),
//        .db_level(db_rst_level),
//        .db_tick(db_rst_tick)
//    );

    // Instancia de la FSM
    fsm_mascota fsm (
        .clk(clk),
        .reset(db_rst_tick),
        .A(db_A_tick),  // Conectar la salida del debounce A a la entrada A de la FSM
        .B(db_B_tick),  // Conectar la salida del debounce B a la entrada B de la FSM
        .C(db_C_tick),  // Conectar la salida del debounce C a la entrada C de la FSM
        .test(1'b0),    
        .color(color),   // Conectar la salida del sensor de color a la entrada de color de la FSM
        .time_control(2'b10),
        .luz(luz),       // Conectar la salida luz del sensor de color a la entrada luz de la FSM
        .output1(fsm_output1),
        .output2(fsm_output2)
    );
    
    // Instancia del módulo de visualización
    display_dec display (
        .clk(clk),
        .rst(1'b0),
        .numA(fsm_output1),
        .numB({4'b0000, fsm_output2}),
        .sseg(sseg),
        .an(an),
        .led(led)
    );

    // Instancia del módulo top_module_color
    top_module_color color_sensor (
        .clk(clk),
        .sensor_out(sensor_out),
        .color(color),            // Salida de color de 3 bits conectada a la FSM
        .s2_s3(s2_s3),            // Señales de control del sensor de color
        .led_s0_s1(led_s0_s1),    // Señales de control LED
        .luz(luz)                 // Salida de luz conectada a la FSM
    );
	 
	 //// instancia lcd
	 LCD1602_controller #(
        .num_commands(4), 
        .num_data_all(5120),
        .num_data_perline(20),
        .COUNT_MAX(800000)
    ) u_lcd_controller (
        .clk(clk),
        .reset(1'b1),
        .ready_i(1'b1), 
        .message_select(fsm_output1),  // Conectado desde la FSM
		.memory_select(fsm_output2),
		.variable_a(fsm_output1),
		.variable_b(fsm_output2),
        .rs(lcd_rs),
        .rw(lcd_rw),
        .enable(lcd_enable),
        .data(lcd_data)
    );

	 


endmodule
