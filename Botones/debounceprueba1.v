//// Verilog code for button debouncing on FPGA
//// Debouncing module without creating another clock domain
//// by using clock enable signal with two modes
//
//// D-flip-flop with clock enable signal for debouncing module 
//module my_dff_en(input DFF_CLOCK, clock_enable, D, output reg Q = 0);
//    always @ (posedge DFF_CLOCK) begin
//        if(clock_enable == 1)  // Solo actualiza Q cuando el reloj lento está habilitado
//            Q <= D;
//    end
//endmodule
//
//// Slow clock enable for debouncing button with two modes
//module clock_enable(
//    input Clk_50M,
//    input mode_select,          // Señal de selección de modo
//    output slow_clk_en);
//
//    reg [33:0] counter = 0;     // Contador para dividir la frecuencia del reloj
//    reg [33:0] counter_limit = 0;   // Límite del contador dependiendo del modo
//
//    always @(posedge Clk_50M) begin
//        if (mode_select)
//            counter_limit <= 2500000; // Modo 1: Contador más largo (2.5 ms para FPGA)
//        else
//            counter_limit <= 25000000;     // Modo 2: Contador más corto (útil para simulación)
//
//        counter <= (counter >= counter_limit) ? 0 : counter + 1;
//    end
//
//    // Genera la señal de habilitación de reloj lento cuando el contador alcanza el límite
//    assign slow_clk_en = (counter == counter_limit) ? 1'b1 : 1'b0;
//endmodule 
//
//// debounce module to filter out the button bouncing effect
//module debounce_better_version(input pb_1, clk, mode_select, output pb_out);
//    wire slow_clk_en;
//    wire Q1, Q2, Q2_bar, Q0;
//
//    // Instancia del módulo clock_enable para generar la señal de habilitación del reloj lento
//    clock_enable u1(clk, mode_select, slow_clk_en);
//
//    // Tres flip-flops tipo D con habilitación de reloj para almacenar el estado del botón
//    my_dff_en d0(clk, slow_clk_en, pb_1, Q0);
//    my_dff_en d1(clk, slow_clk_en, Q0, Q1);
//    my_dff_en d2(clk, slow_clk_en, Q1, Q2);
//
//    // Genera la señal invertida de Q2
//    assign Q2_bar = ~Q2;
//
//    // Salida debounced del botón (solo se activa cuando Q1 está alto y Q2 está bajo)
//    assign pb_out = Q1 & Q2_bar;
//endmodule


//////////////////////////////////

/*
module debounce (
    input wire clk,        // Reloj del sistema
    input wire rst,        // Reset asíncrono
    input wire btn_in,     // Entrada del botón (sin filtrar)
    output reg btn_out     // Salida debounced
);
    // Parámetros de temporización
    parameter CNT_WIDTH = 26;     // Ancho del contador
    parameter DEBOUNCE_PERIOD = 26'd50000000; // Tiempo de debounce en ciclos de reloj (ajustar según la frecuencia del reloj)

    reg [CNT_WIDTH-1:0] debounce_counter = 0; // Contador de debounce
    reg btn_reg1 = 0;    // Primer registro del botón
    reg btn_reg2 = 0;    // Segundo registro del botón
    reg btn_stable = 0;  // Estado estable del botón

    // Registro del botón y conteo
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_reg1 <= 0;
            btn_reg2 <= 0;
            debounce_counter <= 0;
            btn_stable <= 0;
        end else begin
            btn_reg1 <= btn_in;
            btn_reg2 <= btn_reg1;
            
            if (btn_reg1 == btn_reg2) begin
                // Si el botón está estable
                if (debounce_counter < DEBOUNCE_PERIOD) begin
                    debounce_counter <= debounce_counter + 1;
                end else begin
                    btn_stable <= btn_reg2;
                end
            end else begin
                // Reiniciar el contador si el botón cambia
                debounce_counter <= 0;
            end
            
            btn_out <= btn_stable;
        end
    end
endmodule
*/
/*module debounce_better_version(input pb_1,clk,output pb_out);
wire slow_clk_en;
wire Q1,Q2,Q2_bar,Q0;
clock_enable u1(clk,slow_clk_en);
my_dff_en d0(clk,slow_clk_en,pb_1,Q0);
my_dff_en d1(clk,slow_clk_en,Q0,Q1);
my_dff_en d2(clk,slow_clk_en,Q1,Q2);
assign Q2_bar = ~Q2;
assign pb_out = Q1 & Q2_bar;
endmodule
// Slow clock enable for debouncing button 
module clock_enable(input Clk_100M,output slow_clk_en);
    reg [26:0]counter=0;
    always @(posedge Clk_100M)
    begin
       counter <= (counter>=24999999)?0:counter+1;
    end
    assign slow_clk_en = (counter == 24999999)?1'b1:1'b0;
endmodule
// D-flip-flop with clock enable signal for debouncing module 
module my_dff_en(input DFF_CLOCK, clock_enable,D, output reg Q=0);
    always @ (posedge DFF_CLOCK) begin
  if(clock_enable==1) 
           Q <= D;
    end
endmodule */

/////////////////////3

//module debounce
//   (
//    input wire clk, reset,
//    input wire sw,
//    output reg db_level, db_tick
//   );
//
//   // symbolic state declaration
//   localparam  [1:0]
//               zero  = 2'b00,
//               wait0 = 2'b01,
//               one   = 2'b10,
//               wait1 = 2'b11;
//
//   // number of counter bits (2^N * 20ns = 40ms)
//   localparam N = 22;  // Ajustar para el tiempo deseado
//
//   // signal declaration
//   reg [N-1:0] q_reg, q_next;
//   reg [1:0] state_reg, state_next;
//
//   // body
//   always @(posedge clk or posedge reset)
//   begin
//      if (reset)
//      begin
//         state_reg <= zero;
//         q_reg <= 0;
//      end
//      else
//      begin
//         state_reg <= state_next;
//         q_reg <= q_next;
//      end
//   end
//
//   always @*
//   begin
//      state_next = state_reg;
//      q_next = q_reg;
//      db_tick = 1'b0;
//      case (state_reg)
//         zero:
//            begin
//               db_level = 1'b0;
//               if (sw)
//               begin
//                  state_next = wait1;
//                  q_next = {N{1'b1}}; // load 1..1
//               end
//            end
//         wait1:
//            begin
//               db_level = 1'b0;
//               if (sw)
//               begin
//                  q_next = q_reg - 1;
//                  if (q_next==0)
//                  begin
//                     state_next = one;
//                     db_tick = 1'b1;
//                  end
//               end
//               else
//                  state_next = zero;
//            end
//         one:
//            begin
//               db_level = 1'b1;
//               if (~sw)
//               begin
//                  state_next = wait0;
//                  q_next = {N{1'b1}}; // load 1..1
//               end
//            end
//         wait0:
//            begin
//               db_level = 1'b1;
//               if (~sw)
//               begin
//                  q_next = q_reg - 1;
//                  if (q_next==0)
//                     state_next = zero;
//               end
//               else
//                  state_next = one;
//            end
//         default: state_next = zero;
//      endcase
//   end
//
//endmodule

///////////////////////////////////////////////////////////////

module debounce
   (
    input wire clk, reset,
    input wire sw,
    input wire mode,  // Nueva entrada para seleccionar el modo
    output reg db_level, db_tick
   );

   // Parámetros para los estados
   localparam  [1:0]
               zero  = 2'b00,
               wait0 = 2'b01,
               one   = 2'b10,
               wait1 = 2'b11;

   // Parámetros para el tiempo de debounce
   localparam N_NORMAL = 23;       // Tiempo de debounce normal
   localparam N_LONG = 26;         // Tiempo de debounce largo (5 segundos)

   // Señales para los contadores y estados
   reg [N_NORMAL-1:0] q_reg_normal, q_next_normal;
   reg [N_LONG-1:0] q_reg_long, q_next_long;
   reg [1:0] state_reg, state_next;

   // Selección del contador en función del modo
   wire [N_NORMAL-1:0] count_normal = (mode ? q_reg_long : q_reg_normal);
   wire [N_NORMAL-1:0] count_next_normal = (mode ? q_next_long : q_next_normal);

   // Configuración del contador
   always @(posedge clk or posedge reset)
   begin
      if (reset)
      begin
         state_reg <= zero;
         q_reg_normal <= 0;
         q_reg_long <= 0;
      end
      else
      begin
         state_reg <= state_next;
         q_reg_normal <= (mode ? q_reg_normal : count_next_normal);
         q_reg_long <= (mode ? count_next_normal : q_reg_long);
      end
   end

   always @*
   begin
      state_next = state_reg;
      q_next_normal = (mode ? q_reg_long : q_reg_normal);
      q_next_long = (mode ? q_reg_long : q_reg_normal);
      db_tick = 1'b0;
      case (state_reg)
         zero:
            begin
               db_level = 1'b0;
               if (sw)
               begin
                  state_next = wait1;
                  if (mode)
                     q_next_long = {N_LONG{1'b1}}; // Contador largo para 5 segundos
                  else
                     q_next_normal = {N_NORMAL{1'b1}}; // Contador normal
               end
            end
         wait1:
            begin
               db_level = 1'b0;
               if (sw)
               begin
                  q_next_normal = q_reg_normal - 1;
                  q_next_long = q_reg_long - 1;
                  if (count_normal == 0)
                  begin
                     state_next = one;
                     db_tick = 1'b1;
                  end
               end
               else
                  state_next = zero;
            end
         one:
            begin
               db_level = 1'b1;
               if (~sw)
               begin
                  state_next = wait0;
                  if (mode)
                     q_next_long = {N_LONG{1'b1}}; // Contador largo para 5 segundos
                  else
                     q_next_normal = {N_NORMAL{1'b1}}; // Contador normal
               end
            end
         wait0:
            begin
               db_level = 1'b1;
               if (~sw)
               begin
                  q_next_normal = q_reg_normal - 1;
                  q_next_long = q_reg_long - 1;
                  if (count_normal == 0)
                     state_next = zero;
               end
               else
                  state_next = one;
            end
         default: state_next = zero;
      endcase
   end

endmodule
