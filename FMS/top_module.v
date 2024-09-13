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
module top_module (
    input clk,         // Reloj
    //input rst,         // Reset
    input A,           // Entrada para la FSM
    input B,           // Entrada para la FSM
    input C,           // Entrada para la FSM

    //input [1:0] time_control,  // Entrada de 2 bits para modificar el contador de tiempo en la FSM
    output [6:0] sseg, // Salida a 7 segmentos
    output [7:0] an,   // Salida registrada de cátodos
    output led         // LED para el indicador de habilitación
);

    // Señales para conectar las salidas de la FSM con las entradas del display
    wire [7:0] fsm_output1;  // Salida de 8 bits de la FSM
    wire [3:0] fsm_output2;  // Salida de 4 bits de la FSM
	 
	     // Señales para la salida del anti-rebote
    wire db_A_level, db_A_tick;
    wire db_B_level, db_B_tick;
    wire db_C_level, db_C_tick;

    // Instanciar el módulo debounce para el botón A
    debounce db_A (
        .clk(clk),
        .reset(reset),
        .sw(A),
		  .mode(1'b0),
        .db_level(db_A_level),
        .db_tick(db_A_tick)
    );

    // Instanciar el módulo debounce para el botón B
    debounce db_B (
        .clk(clk),
        .reset(reset),
        .sw(B),
		  .mode(1'b0),
        .db_level(db_B_level),
        .db_tick(db_B_tick)
    );

    // Instanciar el módulo debounce para el botón C
    debounce db_C (
        .clk(clk),
        .reset(reset),
        .sw(C),
		  .mode(1'b1),
        .db_level(db_C_level),
        .db_tick(db_C_tick)
    );
//
//    // Señales debounced
//    wire debounced_A;
//    wire debounced_B;
//    wire debounced_C;

    // Instanciar el módulo de anti-rebote para cada entrada
//    debounce_better_version debounce_A (
//        .pb_1(A),
//        .clk(clk),
//        //.mode_select(1'b0), // Seleccionar modo si es necesario
//        .pb_out(debounced_A)
//    );
//
//    debounce_better_version debounce_B (
//        .pb_1(B),
//        .clk(clk),
//        //.mode_select(1'b0), // Seleccionar modo si es necesario
//        .pb_out(debounced_B)
//    );
//
//    debounce_better_version debounce_C (
//        .pb_1(C),
//        .clk(clk),
//        //.mode_select(1'b1), // Seleccionar modo si es necesario
//        .pb_out(debounced_C)
//    );

    // Instancia de la FSM
    fsm_mascota fsm (
        .clk(clk),
        .reset(1'b0),
		  .A(db_A_tick),  // Conectar la salida del debounce A a la entrada A de la FSM
        .B(db_B_tick),  // Conectar la salida del debounce B a la entrada B de la FSM
        .C(db_C_tick),  // Conectar la salida del debounce C a la entrada C de la FSM
//        .A(debounced_A),  // Conectar las señales debounced a la FSM
//        .B(debounced_B),
//        .C(debounced_C),
        .test(1'b0),      // Asume que test es 0 en este contexto; ajusta si es necesario
        .color(2'b00),   // Asume un valor de color por defecto; ajusta según tu lógica
        .time_control(2'b10),
        .luz(1'b1),      // Asume que luz es 0 en este contexto; ajusta si es necesario
        .output1(fsm_output1),
        .output2(fsm_output2)
    );
    
    // Instancia del módulo de visualización
    display_dec display (
        .clk(clk),
        .rst(1'b0),
        .numA(fsm_output1),      // Conectando la salida de la FSM a numA del display
        .numB({4'b0000, fsm_output2}),  // Conectando la salida de la FSM a numB del display, llenando con ceros los 4 bits superiores
        .sseg(sseg),
        .an(an),
        .led(led)
    );

endmodule
