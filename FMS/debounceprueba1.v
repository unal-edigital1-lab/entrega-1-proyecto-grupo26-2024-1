//module debounce1 
//   (
//    input wire clk, reset,  // Señal de reloj y reset
//    input wire sw,           // Entrada del botón o switch a debouncing
//    input wire mode,         // Selección de modo: normal o largo
//    output reg db_level,     // Salida de nivel estabilizado
//    output reg db_tick       // Salida de pulso cuando se detecta un cambio de estado
//   );
//
//   // Parámetros para los estados de la FSM
//   localparam  [1:0]
//               zero  = 2'b00,  // Estado inicial, botón suelto
//               wait1 = 2'b01,  // Espera para confirmar que el botón ha sido presionado
//               one   = 2'b10,  // Estado botón presionado
//               wait0 = 2'b11;  // Espera para confirmar que el botón ha sido soltado
//
//   // Parámetro para el tamaño del contador ajustable
//   // Se utiliza un solo contador que se ajusta en función del modo
//   reg [22:0] q_reg, q_next;  // Contador de 23 bits, suficiente para manejar ambos tiempos
//   wire [22:0] count_max = (mode ? 23'd23 : 23'd21);  // Selección del tiempo de debounce según el modo
//   reg [1:0] state_reg, state_next;  // Registro y siguiente estado de la FSM
//
//   // Bloque de control de la FSM y el contador
//   always @(posedge clk or negedge reset) begin
//      if (!reset) begin
//         state_reg <= zero;   // Reset del estado a 'zero'
//         q_next <= 0;          // Reset del contador
//      end else begin
//         state_reg <= state_next;  // Actualización del estado
//          q_next <= q_reg ;          // Actualización del contador
//      end
//   end
//
//   // Lógica combinacional para el siguiente estado y el contador
//   always @(*) begin
//      q_next = q_reg;       // Inicializa el siguiente valor del contador
//      state_next = state_reg;  // Inicializa el siguiente estado
//      db_tick = 1'b0;       // Inicializa el tick a 0 por defecto
//
//      case (state_reg)
//         zero: begin
//            db_level = 1'b0;  // Salida de nivel bajo (botón no presionado)
//            if (sw) begin
//               state_next = wait1;  // Cambio de estado cuando se detecta un cambio de 'sw'
//               q_next = count_max;  // Reinicia el contador al máximo valor
//               q_reg =count_max;
//            end
//         end
//         wait1: begin
//            db_level = 1'b0;  // Salida de nivel bajo durante la espera
//            if (sw && q_reg > 0)
//               q_next = q_reg - 1;  // Decrementa el contador mientras 'sw' sigue activo
//            else if (q_reg == 0) begin
//               state_next = one;    // Si el contador llega a 0, confirma el cambio de estado
//               db_tick = 1'b1;      // Genera un tick indicando el cambio de estado
//            end
//            else
//               state_next = zero;   // Si 'sw' se desactiva, regresa a 'zero'
//         end
//         one: begin
//            db_level = 1'b1;  // Salida de nivel alto (botón presionado)
//            if (!sw) begin
//               state_next = wait0;  // Cambio de estado cuando 'sw' se suelta
//               q_next = count_max;  // Reinicia el contador
//            end
//         end
//         wait0: begin
//            db_level = 1'b1;  // Mantiene el nivel alto durante la espera
//            if (!sw && q_reg > 0)
//               q_next = q_reg - 1;  // Decrementa el contador mientras 'sw' sigue inactivo
//            else if (q_reg == 0)
//               state_next = zero;   // Si el contador llega a 0, confirma el regreso al estado 'zero'
//         end
//         default: state_next = zero;  // Estado por defecto (cubre posibles errores)
//      endcase
//   end
//
//endmodule

module debounce
   (
    input wire clk, reset,
    input wire sw,
    input wire mode,  // Nueva entrada para seleccionar el modo
    output reg db_level, db_tick
   );

   // Parámetros para los estados
   localparam  [1:0]
               zero  = 2'b00,//0
               wait1 = 2'b01,//1
               one   = 2'b10,//2
               wait0 = 2'b11;//3
               
               //3

   // Parámetros para el tiempo de debounce
   //localparam N_NORMAL = 4;
   localparam N_NORMAL = 21;       // Tiempo de debounce normal
   localparam N_LONG = 20;         // Tiempo de debounce largo (5 segundos)

   // Señales para los contadores y estados
   reg [N_NORMAL-1:0] q_reg_normal, q_next_normal;
   reg [N_LONG-1:0] q_reg_long, q_next_long;
   reg [1:0] state_reg, state_next;

   // Selección del contador en función del modo
   wire [N_NORMAL-1:0] count_normal = (mode ? q_reg_long : q_reg_normal); //// (condición ? valor_si_true : valor_si_false)
   wire [N_NORMAL-1:0] count_next_normal = (mode ? q_next_long : q_next_normal);

   // Configuración del contador
   always @(posedge clk)
   begin
      if (reset == 0) begin
         state_reg = zero;
         q_reg_normal = count_normal;
         q_reg_long = count_normal;
      end
      else begin
         state_reg = state_next;
         q_reg_normal = (mode ? q_reg_normal : count_next_normal);
         q_reg_long = (mode ? count_next_normal : q_reg_long);
      end
   end

   always @(*)
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
					begin
                  state_next = zero;end
            end
         one:
            begin
               db_level = 1'b1;
               if (~sw)
               begin
                  //state_next = zero;
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
               else begin
                  state_next = one;
            end 
				end
         default: state_next = zero;
      endcase
   end

endmodule

// Módulo D-flip-flop con habilitación de reloj
module my_dff_en(input DFF_CLOCK, clock_enable, D, output reg Q = 0);
    always @ (posedge DFF_CLOCK) begin
        if(clock_enable == 1)
            Q <= D;
    end
endmodule

// Módulo de generación de habilitación de reloj lento
module clock_enable(
    input Clk_50M,
    input mode_select,
    output slow_clk_en);

    reg [25:0] counter = 0;
    reg [25:0] counter_limit = 0;

    always @(posedge Clk_50M) begin
        if (mode_select)
            counter_limit <= 125000; // Modo largo (2.5 ms)
        else
            counter_limit <= 5000000;  // Modo corto (simulación rápida)
        counter <= (counter >= counter_limit) ? 0 : counter + 1;
    end
    assign slow_clk_en = (counter == counter_limit) ? 1'b1 : 1'b0;
endmodule

// Módulo antirrebote (debounce)
module debounce_better_version(input pb_1, clk, mode_select, output pb_out);
    wire slow_clk_en;
    wire Q1, Q2, Q2_bar, Q0;

    // Generar la señal de habilitación de reloj lento
    clock_enable u1(clk, mode_select, slow_clk_en);

    // Tres flip-flops D para almacenar el estado del botón
    my_dff_en d0(clk, slow_clk_en, pb_1, Q0);
    my_dff_en d1(clk, slow_clk_en, Q0, Q1);
    my_dff_en d2(clk, slow_clk_en, Q1, Q2);

    // Invertir la salida del tercer flip-flop
    assign Q2_bar = ~Q2;

    // La salida solo es alta si el botón ha sido presionado sin rebote
    assign pb_out = Q1 & Q2_bar & slow_clk_en;
endmodule

