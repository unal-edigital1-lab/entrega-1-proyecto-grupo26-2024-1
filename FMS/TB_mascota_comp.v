`include "top_module.v"

module tb_top_module;

    // Definir señales del testbench
    reg clk;
    reg rst;
    reg A;
    reg B;
    reg C;
    reg test;
    reg sensor_out;
    wire [2:0] led_s0_s1;
    wire [1:0] s2_s3;
    wire [6:0] sseg;
    wire [7:0] an;
    wire led;
    wire [2:0] color;
    wire luz;
    wire [7:0] lcd_data;
    wire lcd_rs;
    wire lcd_rw;
    wire lcd_enable;

    // Instanciar el módulo bajo prueba (DUT)
    top_module uut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .C(C),
        .sensor_out(sensor_out),
        .led_s0_s1(led_s0_s1),
        .s2_s3(s2_s3),
        .sseg(sseg),
        .an(an),
        .led(led),
        .color(color),
        .luz(luz),
        .lcd_data(lcd_data),
        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw),
        .lcd_enable(lcd_enable),
        .test(test)
    );

    // Generar un reloj de 50 MHz
    always #1 clk = ~clk;

    // Inicialización
    initial begin
        // Inicializar señales
        clk = 0;
        rst = 1;  // Activar rst
        A = 0;
        B = 0;
        C = 0;
        test =1;
        sensor_out = 0;

        // Simulación de rst
        #100 rst = 0;  // Desactivar rst



        #5 A = 1;
        #5 A = 0;
        # 20;
        #5 A = 1;
        #5 A = 0;

        // Prueba 1: Activar entrada A
        #50 A = 1;
        #50 A = 0;
        
        #50 A = 1;
        #50 A = 0;

        #50 A = 1;
        #50 A = 0;
        // Prueba 2: Activar entrada B
        #50 B = 1;
        #50 B = 0;

        #10 A = 1;
        #10 A = 0;
        
        // Prueba 3: Activar entrada C
        #50 C = 1;
        #50 C = 0;

        #5 A = 1;
        #5 A = 0;

        // Prueba 4: Simular la salida del sensor
        #100 sensor_out = 1;
        #50 sensor_out = 0;
        test =0;


        // Simulación de tiempo extendido para observar resultados
        #500;
         // rst de la FSM
        rst = 1;      // Activa el rst
        #10;
        rst = 0;      // Desactiva el rst

        // Esperar un ciclo de reloj
        #30;

        // Probar transición de estado S0 a S1
        A = 1;          // Activa la entrada A para pasar al siguiente estado
        #10;
        A = 0;          // Desactiva la entrada A
        #30;

        // Modificar variable en estado S1
        B = 1;          // Activa la entrada B para modificar la variable del estado S1
        #10;
        B = 0;          // Desactiva la entrada B
        #60;
        B = 1;          // Activa la entrada B para modificar la variable del estado S4
        #10;
        B = 0;          // Desactiva la entrada B
        #60;
         B = 1;          // Activa la entrada B para modificar la variable del estado S4
        #10;
        B = 0;          // Desactiva la entrada B
        #60;
        B = 1;          // Activa la entrada B para modificar la variable del estado S4
        #10;
        B = 0;          // Desactiva la entrada B
        #60;

        // Probar transición de estado S1 a S2
        A = 1;          // Activa la entrada A para pasar al siguiente estado
        #50;
        A = 0;          // Desactiva la entrada A
        #50;

        // Modificar variable en estado S2
        B = 1;          // Activa la entrada B para modificar la variable del estado S2
        #10;
        B = 0;          // Desactiva la entrada B
        #30;

        // Probar transición de estado S2 a S3
        B = 1;          // Activa la entrada A para pasar al siguiente estado
        #50;
        B = 0;          // Desactiva la entrada A
        #30;

        // Modificar variable en estado S3
        B = 1;          // Activa la entrada B para modificar la variable del estado S3
        #50;
        B = 0;          // Desactiva la entrada B
        #30;

        // Probar transición de estado S3 a S4
        B = 1;          // Activa la entrada A para pasar al siguiente estado
        #50;
        B = 0;          // Desactiva la entrada A
        #30;

        // Modificar variable en estado S4
        B = 1;          // Activa la entrada B para modificar la variable del estado S4
        #50;
        B = 0;          // Desactiva la entrada B
        #30;
         B = 1;          // Activa la entrada B para modificar la variable del estado S4
        #50;
        B = 0;          // Desactiva la entrada B
        #50;
         B = 1;          // Activa la entrada B para modificar la variable del estado S4
        #10;
        B = 0;          // Desactiva la entrada B
        #50;

        // Probar transición de estado S4 a S0 (ciclo completo)
        A = 1;          // Activa la entrada A para regresar al estado inicial
        #10;
        A = 0;          // Desactiva la entrada A
        #30;

// Modificar variable en estado S0
        B = 1;          // Activa la entrada B para modificar la variable del estado S4
        #10;
        B = 0;          // Desactiva la entrada B
        #30;
        B = 1;          // Activa la entrada B para modificar la variable del estado S4
        #10;
        B = 0;          // Desactiva la entrada B
        #30;
        B = 1;          // Activa la entrada B para modificar la variable del estado S4
        #10;
        B = 0;          // Desactiva la entrada B
        #30;
        //prueba C
        C = 1;          // Activa la entrada C para regresar en los estados
        #10;
        C = 0;          // Desactiva la entrada C
        #30;
        C = 1;          // Activa la entrada C para regresar en los estados
        #10;
        C = 0;          // Desactiva la entrada C
        #30;
        C = 1;          // Activa la entrada C para regresar en los estados
        #10;
        C = 0;          // Desactiva la entrada C
        #30;
        C = 1;          // Activa la entrada C para regresar en los estados
        #10;
        C = 0;          // Desactiva la entrada C
        #30;
        C = 1;          // Activa la entrada C para regresar en los estados
        #10;
        C = 0;          // Desactiva la entrada C
        #30;                                
        //prueba rst 
        rst = 1;
        #10
        rst = 0;
        #30;
        
        // Terminar la simulación
        $finish;
    end

    // Mostrar las salidas
    initial begin
        $monitor("Time: %0t | A = %b | B = %b | C = %b | sensor_out = %b | sseg = %b | an = %b | led = %b | color = %b | luz = %b", 
                  $time, A, B, C, sensor_out, sseg, an, led, color, luz);
    end

    initial begin: TEST_CASE
        $dumpfile("TB_comp.vcd");
        $dumpvars(-1, uut);
        #(100000000) $finish;
    end

endmodule
