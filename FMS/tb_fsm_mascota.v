`include "fsm_mascota.v"

`timescale 1ns / 1ps
module tb_fsm_mascota;

    // Declaración de señales para la FSM
    reg clk;
    reg reset;
    reg A;
    reg B;
    reg C;
    wire [7:0] output1;
    wire [3:0] output2;

    // Instanciación de la FSM
    fsm_mascota uut (.clk(clk),  .reset(reset), .A(A), .B(B), .C(C), .output1(output1), .output2(output2));

    // Generación del reloj (clock)
    always #5 clk = ~clk;
    // Procedimiento inicial para configurar y ejecutar las pruebas
    initial begin
        // Inicialización de las señales
        clk = 0;
        reset = 0;
        A = 0;
        B = 0;
        C = 0;


        // Reset de la FSM
        reset = 1;      // Activa el reset
        #10;
        reset = 0;      // Desactiva el reset

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
        #30;
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

        // Probar transición de estado S1 a S2
        A = 1;          // Activa la entrada A para pasar al siguiente estado
        #10;
        A = 0;          // Desactiva la entrada A
        #30;

        // Modificar variable en estado S2
        B = 1;          // Activa la entrada B para modificar la variable del estado S2
        #10;
        B = 0;          // Desactiva la entrada B
        #30;

        // Probar transición de estado S2 a S3
        A = 1;          // Activa la entrada A para pasar al siguiente estado
        #10;
        A = 0;          // Desactiva la entrada A
        #30;

        // Modificar variable en estado S3
        B = 1;          // Activa la entrada B para modificar la variable del estado S3
        #10;
        B = 0;          // Desactiva la entrada B
        #30;

        // Probar transición de estado S3 a S4
        A = 1;          // Activa la entrada A para pasar al siguiente estado
        #10;
        A = 0;          // Desactiva la entrada A
        #30;

        // Modificar variable en estado S4
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
        //prueba reset 
        reset = 1;
        #10
        reset = 0;
        #30;
        // Finalización de la simulación
        $stop;
    end
    initial begin: TEST_CASE
        $dumpfile("fsm_mascota_tb.vcd");
        $dumpvars(-1,uut);
        #(1000) $finish;
		
    end


endmodule
