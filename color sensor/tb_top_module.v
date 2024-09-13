`timescale 1ns/1ps
`include "top_module.v"

module tb_top_module();
    reg clk;               // Reloj de la simulación
    reg rst;               // Reset del sistema
    reg sensor_out;        // Señal simulada del sensor TCS3200
    wire [2:0] color;      // Salida del color identificado
    wire [1:0] s2_s3;      // Señal de control de filtro del sensor
    wire [2:0] led_s0_s1;  // Señales LED (fijas en 00)

    // Instancia del módulo top
    top_module uut(
        .clk(clk),
        //.rst(rst),
        .sensor_out(sensor_out),
        .color(color),
        .s2_s3(s2_s3),
        .led_s0_s1(led_s0_s1)
    );

    // Generación del reloj (periodo de 20ns)
    always #10 clk = ~clk;

    // Simulación de la señal del sensor
    initial begin
                // Inicialización
        clk = 0;
        rst = 1;
        sensor_out = 0;

        // Reset del sistema
        #20;
        rst = 0;
        #20;

        // Simulación de la señal del sensor para los diferentes filtros de color
        // Filtro rojo (por tiempo prolongado)
        repeat(100) begin
            #50 sensor_out = ~sensor_out; // Generar pulsos
        end
        // Filtro azul
        repeat(100) begin
            #50 sensor_out = ~sensor_out;
        end
        // Sin filtro (luz clara)
        repeat(125 ) begin
            #40 sensor_out = ~sensor_out;
        end
        // Filtro verde
        repeat(200) begin
            #25 sensor_out = ~sensor_out;
        end
                // Filtro rojo (por tiempo prolongado)
        repeat(100) begin
            #50 sensor_out = ~sensor_out; // Generar pulsos
        end

        // Filtro verde
        repeat(1000) begin
            #50 sensor_out = ~sensor_out;
        end
        repeat(100) begin
            #50 sensor_out = ~sensor_out;
        end

        // Filtro azul
        repeat(2000) begin
            #25 sensor_out = ~sensor_out;
        end

        // Sin filtro (luz clara)
        repeat(5000 ) begin
            #10 sensor_out = ~sensor_out;
        end
        #10;
        sensor_out=0;
        // Terminar la simulación
        #7000;
        $finish;
    end

    // Monitor para observar los valores de salida
    initial begin
        $monitor("Time: %0dns, Color: %b, S2_S3: %b, LED_S0_S1: %b", 
                 $time, color, s2_s3, led_s0_s1);
    end
    initial begin: TEST_CASE
        $dumpfile("tb_top.vcd");
        $dumpvars(-1,uut);
        #(4800000) $finish;
		
    end

endmodule
