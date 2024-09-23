`timescale 1ns / 1ps
`include "LCD1602_controller1.v"


module lcd1602_TB();
    reg clk;
    reg rst;
    reg ready_i;
    reg message_select;

    LCD1602_controller1 #(4, 240, 20, 50) uut (
        .clk(clk),
        .reset(rst),
        .ready_i(ready_i),
        .message_select(message_select)
    );

    initial begin
        clk = 0;
        rst = 1;
        ready_i = 1;
        message_select=0;
        #10 rst = 0;
        #10 rst = 1;
        //#10 rst = 0;
         #300000;
        # 10;
        message_select=001;
        //#100 rst = 0;
        //#10 rst = 1;
        //#10 rst = 0;
        #300000;
        $finish;
    end

    always #10 clk = ~clk;

    initial begin: TEST_CASE
        $dumpfile("LCD1602_controller_TB.vcd");
        $dumpvars(-1, uut);
        #(1000000) $finish;
    end


endmodule