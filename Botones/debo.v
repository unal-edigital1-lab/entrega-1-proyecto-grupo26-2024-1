module debounce1 
   (
    input wire clk, reset,  // Señal de reloj y reset
    input wire sw,           // Entrada del botón o switch a debouncing
    input wire mode,         // Selección de modo: normal o largo
    output reg db_level,     // Salida de nivel estabilizado
    output reg db_tick       // Salida de pulso cuando se detecta un cambio de estado
   );

   // Parámetros para los estados de la FSM
   localparam  [1:0]
               zero  = 2'b00,  // Estado inicial, botón suelto
               wait1 = 2'b01,  // Espera para confirmar que el botón ha sido presionado
               one   = 2'b10,  // Estado botón presionado
               wait0 = 2'b11;  // Espera para confirmar que el botón ha sido soltado

   // Parámetro para el tamaño del contador ajustable
   // Se utiliza un solo contador que se ajusta en función del modo
   reg [22:0] q_reg, q_next;  // Contador de 23 bits, suficiente para manejar ambos tiempos
   wire [22:0] count_max = (mode ? 23'd5 : 23'd10);  // Selección del tiempo de debounce según el modo
   reg [1:0] state_reg, state_next;  // Registro y siguiente estado de la FSM

   // Bloque de control de la FSM y el contador
   always @(posedge clk or negedge reset) begin
      if (!reset) begin
         state_reg <= zero;   // Reset del estado a 'zero'
         q_reg <= 0;          // Reset del contador
      end else begin
         state_reg <= state_next;  // Actualización del estado
         q_reg <= q_next;          // Actualización del contador
      end
   end

   // Lógica combinacional para el siguiente estado y el contador
   always @(*) begin
      q_next = q_reg;       // Inicializa el siguiente valor del contador
      state_next = state_reg;  // Inicializa el siguiente estado
      db_tick = 1'b0;       // Inicializa el tick a 0 por defecto

      case (state_reg)
         zero: begin
            db_level = 1'b0;  // Salida de nivel bajo (botón no presionado)
            if (sw) begin
               state_next = wait1;  // Cambio de estado cuando se detecta un cambio de 'sw'
               q_next = count_max;  // Reinicia el contador al máximo valor
               q_reg =count_max;
            end
         end
         wait1: begin
            db_level = 1'b0;  // Salida de nivel bajo durante la espera
            if (sw && q_reg > 0)
               q_next = q_reg - 1;  // Decrementa el contador mientras 'sw' sigue activo
            else if (q_reg == 0) begin
               state_next = one;    // Si el contador llega a 0, confirma el cambio de estado
               db_tick = 1'b1;      // Genera un tick indicando el cambio de estado
            end
            else
               state_next = zero;   // Si 'sw' se desactiva, regresa a 'zero'
         end
         one: begin
            db_level = 1'b1;  // Salida de nivel alto (botón presionado)
            if (!sw) begin
               state_next = wait0;  // Cambio de estado cuando 'sw' se suelta
               q_next = count_max;  // Reinicia el contador
            end
         end
         wait0: begin
            db_level = 1'b1;  // Mantiene el nivel alto durante la espera
            if (!sw && q_reg > 0)
               q_next = q_reg - 1;  // Decrementa el contador mientras 'sw' sigue inactivo
            else if (q_reg == 0)
               state_next = zero;   // Si el contador llega a 0, confirma el regreso al estado 'zero'
         end
         default: state_next = zero;  // Estado por defecto (cubre posibles errores)
      endcase
   end

endmodule

module debounce
   (
    input wire clk, reset,
    input wire sw,
    output reg db_level, db_tick
   );

   // symbolic state declaration
   localparam  [1:0]
               zero  = 2'b00,
               wait0 = 2'b01,
               one   = 2'b10,
               wait1 = 2'b11;

   // number of counter bits (2^N * 20ns = 40ms)
   localparam N = 4;  // Ajustar para el tiempo deseado

   // signal declaration
   reg [N-1:0] q_reg, q_next;
   reg [1:0] state_reg, state_next;

   // body
   always @(posedge clk or posedge reset)
   begin
      if (reset)
      begin
         state_reg <= zero;
         q_reg <= 0;
      end
      else
      begin
         state_reg <= state_next;
         q_reg <= q_next;
      end
   end

   always @*
   begin
      state_next = state_reg;
      q_next = q_reg;
      db_tick = 1'b0;
      case (state_reg)
         zero:
            begin
               db_level = 1'b0;
               if (sw)
               begin
                  state_next = wait1;
                  q_next = {N{1'b1}}; // load 1..1
               end
            end
         wait1:
            begin
               db_level = 1'b0;
               if (sw)
               begin
                  q_next = q_reg - 1;
                  if (q_next==0)
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
                  q_next = {N{1'b1}}; // load 1..1
               end
            end
         wait0:
            begin
               db_level = 1'b1;
               if (~sw)
               begin
                  q_next = q_reg - 1;
                  if (q_next==0)
                     state_next = zero;
               end
               else
                  state_next = one;
            end
         default: state_next = zero;
      endcase
   end

endmodule