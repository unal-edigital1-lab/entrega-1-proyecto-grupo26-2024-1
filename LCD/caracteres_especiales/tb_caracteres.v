`timescale 1ns / 1ps
//`include "path_to_data.txt"
`include "lcd1602_cust_char.v"


module tb_caracteres();
    reg clk;
    reg rst;
    reg ready_i;
    wire rs;
    wire rw;
    wire enable;
    wire [7:0] data;
    lcd1602_cust_char #(3, 64, 8, 8, 80) uut (
        .clk(clk),
        .reset(rst),
        .ready_i(ready_i),
        .rs(rs),
        .rw(rw),
        .enable(enable),
        .data(data)
    );

    initial begin
        clk = 0;
        rst = 1;
        ready_i = 1;


        #1000000000 $finish;
    end

    always #10 clk = ~clk;

    initial begin: TEST_CASE
        $dumpfile("LCD1602_controller_TB.vcd");
        $dumpvars(-1, uut);
        #(10000000) $finish;
    end


endmodule
