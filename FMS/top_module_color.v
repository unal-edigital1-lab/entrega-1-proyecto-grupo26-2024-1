//`include "color_sensor3.v"
//`include "color_identifier1.v"

module top_module_color(
    input clk,            // Reloj principal
    //input rst,            // Reset
    input sensor_out,     // Señal de salida del sensor TCS3200
    output [2:0] color,   // Salida de 3 bits que representa el color
    output [1:0] s2_s3,   // Señales de control del sensor de color (S2 y S3)
    output [2:0] led_s0_s1, // Señales de control LED (S0 y S1)
	 output luz
);

    // Señales intermedias
    wire [15:0] red_norm, green_norm, blue_norm;

    // Señales de control LED siempre en 00
    assign led_s0_s1 = 2'b111;

    // Instancia del módulo color_sensor
    color_sensor3 sensor_inst (
        .clk(clk),
        .rst(1'b1),
        .sensor_out(sensor_out),
        .s2_s3(s2_s3),            // Señal de control S2-S3 conectada al sensor
        //.mode(mode),
		  .red_norm(red_norm),       // Valor normalizado del componente rojo
        .green_norm(green_norm),   // Valor normalizado del componente verde
        .blue_norm(blue_norm),      // Valor normalizado del componente azul
		  .luz(luz)
    );

    // Instancia del módulo color_identifier
    color_identifier identifier_inst (
        .red_norm(red_norm),
        .green_norm(green_norm),
        .blue_norm(blue_norm),
        .color(color)              // Salida de 3 bits que representa el color
    );

endmodule
