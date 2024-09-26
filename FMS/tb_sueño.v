
`timescale 1ns / 1ps
`include "fsm_mascota.v"

module fsm_mascota_tb;

    // Entradas
    reg clk;
    reg reset;
    reg A;
    reg B;
    reg C;
    reg test;
    reg [1:0] color;
    reg [1:0] time_control;
    reg luz;

    // Salidas
    wire [7:0] output1;
    wire [3:0] output2;

    // Instantiate the Unit Under Test (UUT)
    fsm_mascota uut (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .C(C),
        .test(test),
        .color(color),
        .luz(luz),
        .time_control(time_control),
        .output1(output1),
        .output2(output2)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        A = 0;
        B = 0;
        C = 0;
        test = 0;
        color = 2'b00;
        time_control = 2'b00;
        luz = 0;

        // Apply reset
        #10 reset = 0;
        #300;
        //avanza al 3 estado 
        A=1;
        #10;
        A=0;
        #10;
        uut.var_S2 = 0;
        A=1;
        #10;
        A=0;
        #10;
        A=1;
        #10;
        A=0;
        #10;
        //intento de dormir 
        B=1;
        #10;
        B=0;
        #10;
        B=1;
        #10;
        B=0;
        #100;
        luz=1;
        B=1;
        #10;
        B=0;
        #10;






        // Finalize simulation
        #1000 $finish;
    end
initial begin: TEST_CASE
        $dumpfile("fsm_mascota_tb3.vcd");
        $dumpvars(-1,uut);
        #(280000) $finish;
		
    end

endmodule
