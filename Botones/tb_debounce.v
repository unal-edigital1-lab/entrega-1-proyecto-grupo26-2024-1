`include "debo.v"
module debounce_tb;

   reg clk_tb, reset_tb, sw_tb;
   wire db_level_tb, db_tick_tb;

   // Instancia del módulo debounce
   debounce uut(
      .clk(clk_tb),
      .reset(reset_tb),
      .sw(sw_tb),
      //.mode(mode_tb),
      .db_level(db_level_tb),
      .db_tick(db_tick_tb)
   );

   // Generar señal de reloj
   always #1 clk_tb = ~clk_tb;

   initial begin
      // Inicialización
      clk_tb = 0;
      reset_tb = 0;
      sw_tb = 0;


      // Secuencia de prueba
      // Resetear el sistema
      #10 reset_tb = 1;
      #20 reset_tb = 0;

      // Simular un cambio en el botón (rebote)
      #30 sw_tb = 1;
      #40 sw_tb = 0;
      #50 sw_tb = 1;
      #60 sw_tb = 0;

      // Cambiar el modo

      // Simular otro cambio en el botón
      #80 sw_tb = 1;
      #100 sw_tb = 0;
      #120 sw_tb = 1;

      // Finalizar simulación
      #200 $stop;
   end
    initial begin: TEST_CASE
        $dumpfile("TB-debounce.vcd");
        $dumpvars(-1, uut);
        #(100000000) $finish;
    end
endmodule
