//`include "color_sensor2.v"
`timescale 1ns/1ps

module tb_color_sensor();

    reg clk;              // Reloj de la simulación
    reg rst;              // Reset del sistema
    reg sensor_out;       // Señal simulada del sensor TCS3200
    wire [15:0] red_norm, green_norm, blue_norm; // Valores normalizados de los colores
    wire [1:0] s2_s3;     // Señal de control de filtro del sensor

    // Instancia del módulo color_sensor
    color_sensor2 uut (
        .clk(clk),
        .rst(rst),
        .sensor_out(sensor_out),
        .red_norm(red_norm),
        .green_norm(green_norm),
        .blue_norm(blue_norm),
        .s2_s3(s2_s3)
    );

    // Generación del reloj (periodo de 20ns)
    always #5 clk = ~clk;

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
        repeat(100) begin
            #50 sensor_out = ~sensor_out;
        end
        repeat(100) begin
            #50 sensor_out = ~sensor_out;
        end

        // Filtro azul
        repeat(200) begin
            #25 sensor_out = ~sensor_out;
        end

        // Sin filtro (luz clara)
        repeat(500 ) begin
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
        $monitor("Time: %0dns, Red Norm: %d, Green Norm: %d, Blue Norm: %d, S2_S3: %b", 
                 $time, red_norm, green_norm, blue_norm, s2_s3);
    end

//endmodule

/*module tb_color_sensor();

    reg clk;              // Reloj de la simulación
    reg rst;              // Reset del sistema
    reg sensor_out;       // Señal simulada del sensor TCS3200
    wire [15:0] red_norm, green_norm, blue_norm; // Valores normalizados de los colores
    wire [1:0] s2_s3;     // Señal de control de filtro del sensor

    // Instancia del módulo color_sensor
    color_sensor2 uut (
        .clk(clk),
        .rst(rst),
        .sensor_out(sensor_out),
        .red_norm(red_norm),
        .green_norm(green_norm),
        .blue_norm(blue_norm),
        .s2_s3(s2_s3)
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
        // Filtro rojo
        repeat(50) begin
            #20 sensor_out = ~sensor_out; // Generar pulsos
        end

        // Filtro verde
        repeat(50) begin
            #20 sensor_out = ~sensor_out;
        end

        // Filtro azul
        repeat(50) begin
            #20 sensor_out = ~sensor_out;
        end

        // Sin filtro (luz clara)
        repeat(50) begin
            #20 sensor_out = ~sensor_out;
        end

        // Terminar la simulación
        #1000;
        $finish;
    end

    // Monitor para observar los valores de salida
    initial begin
        $monitor("Time: %0dns, Red Norm: %d, Green Norm: %d, Blue Norm: %d, S2_S3: %b", 
                 $time, red_norm, green_norm, blue_norm, s2_s3);
    end
*/
initial begin: TEST_CASE

        $dumpfile("color.vcd");
        $dumpvars(-1,uut);
        #(480000) $finish;
		
    end
endmodule
