module debounce
   (
    input wire clk, reset,     // Entrada del reloj (clk) y del reset (para reiniciar el estado)
    input wire sw,             // Entrada del interruptor que se está filtrando (debouncing)
    input wire mode,           // Nueva entrada para seleccionar el modo de debounce (normal o largo)
    output reg db_level,       // Salida que indica el estado filtrado del interruptor
    output reg db_tick         // Salida que genera un pulso cuando se detecta un cambio de estado (de rebote filtrado)
   );

   // Definición de parámetros para los estados de la máquina de estados
   localparam  [1:0]
               zero  = 2'b00,  // Estado cuando el interruptor está liberado (no presionado)
               wait0 = 2'b01,  // Estado de espera para confirmar que el interruptor ha sido liberado sin rebotes
               one   = 2'b10,  // Estado cuando el interruptor está presionado
               wait1 = 2'b11;  // Estado de espera para confirmar que el interruptor ha sido presionado sin rebotes

   // Parámetros que definen el tiempo de debounce:
   localparam N_NORMAL = 23;   // Tiempo de debounce "normal" (representa un contador de 2^23 ciclos)
   localparam N_LONG = 26;     // Tiempo de debounce "largo" (representa un contador de 2^26 ciclos, unos 5 segundos)

   // Registros para los contadores y los estados de la máquina de estados
   reg [N_NORMAL-1:0] q_reg_normal, q_next_normal;  // Registro y valor siguiente para el contador de debounce normal
   reg [N_LONG-1:0] q_reg_long, q_next_long;        // Registro y valor siguiente para el contador de debounce largo
   reg [1:0] state_reg, state_next;                 // Registros para los estados actuales y siguientes de la máquina de estados

   // Selección del contador en función del modo seleccionado (normal o largo)
   wire [N_NORMAL-1:0] count_normal = (mode ? q_reg_long : q_reg_normal);   // Selecciona entre el contador normal o largo
   wire [N_NORMAL-1:0] count_next_normal = (mode ? q_next_long : q_next_normal);  // Selecciona el valor siguiente del contador

   // Siempre que ocurre un flanco ascendente del reloj o del reset
   always @(posedge clk or posedge reset)
   begin
      if (reset)  // Si se activa el reset, se reinician los registros
      begin
         state_reg <= zero;   // Reinicia la máquina de estados al estado 'zero'
         q_reg_normal <= 0;   // Reinicia el contador normal
         q_reg_long <= 0;     // Reinicia el contador largo
      end
      else
      begin
         state_reg <= state_next;   // Actualiza el estado actual al siguiente
         // Actualiza los contadores en función del modo seleccionado (normal o largo)
         q_reg_normal <= (mode ? q_reg_normal : count_next_normal);  // Si está en modo largo, deja el contador normal sin cambiar
         q_reg_long <= (mode ? count_next_normal : q_reg_long);      // Si está en modo normal, deja el contador largo sin cambiar
      end
   end

   // Lógica combinacional que determina el siguiente estado de la máquina de estados y el valor de los contadores
   always @*
   begin
      state_next = state_reg;    // Inicializa el siguiente estado al estado actual por defecto
      q_next_normal = (mode ? q_reg_long : q_reg_normal);  // Selecciona el contador correspondiente según el modo
      q_next_long = (mode ? q_reg_long : q_reg_normal);    // Selecciona el contador correspondiente según el modo
      db_tick = 1'b0;   // Inicializa db_tick a 0 (sin pulso), se activará solo si hay un cambio válido en el estado del interruptor

      // Máquina de estados que maneja el comportamiento del debounce
      case (state_reg)
         zero:    // Estado cuando el interruptor está liberado (no presionado)
            begin
               db_level = 1'b0;    // db_level indica que el interruptor está en bajo (no presionado)
               if (sw)  // Si se detecta que el interruptor fue presionado (sw = 1)
               begin
                  state_next = wait1;   // Cambia el estado a 'wait1', esperando a que se confirme la presión sin rebotes
                  if (mode)  // Si está en modo largo
                     q_next_long = {N_LONG{1'b1}}; // Carga el valor máximo en el contador largo (inicia el conteo de debounce)
                  else  // Si está en modo normal
                     q_next_normal = {N_NORMAL{1'b1}}; // Carga el valor máximo en el contador normal
               end
            end
         wait1:   // Estado de espera para confirmar la presión del interruptor (debouncing)
            begin
               db_level = 1'b0;    // db_level sigue indicando que el interruptor no está presionado (se mantiene en bajo)
               if (sw)  // Si el interruptor sigue presionado
               begin
                  q_next_normal = q_reg_normal - 1;  // Decrementa el contador normal
                  q_next_long = q_reg_long - 1;      // Decrementa el contador largo
                  if (count_normal == 0)  // Si el contador (normal o largo) llega a 0, significa que el debounce ha terminado
                  begin
                     state_next = one;   // Cambia al estado 'one', confirmando que el interruptor está presionado
                     db_tick = 1'b1;     // Genera un pulso en db_tick para indicar que hubo un cambio de estado válido
                  end
               end
               else
                  state_next = zero;  // Si el interruptor se libera antes de que termine el debounce, regresa al estado 'zero'
            end
         one:   // Estado cuando el interruptor está presionado
            begin
               db_level = 1'b1;    // db_level indica que el interruptor está presionado (nivel alto)
               if (~sw)  // Si se detecta que el interruptor fue liberado (sw = 0)
               begin
                  state_next = wait0;  // Cambia al estado 'wait0', esperando confirmar la liberación sin rebotes
                  if (mode)  // Si está en modo largo
                     q_next_long = {N_LONG{1'b1}}; // Carga el valor máximo en el contador largo (inicia el conteo de debounce)
                  else  // Si está en modo normal
                     q_next_normal = {N_NORMAL{1'b1}}; // Carga el valor máximo en el contador normal
               end
            end
         wait0:   // Estado de espera para confirmar la liberación del interruptor (debouncing)
            begin
               db_level = 1'b1;    // db_level sigue indicando que el interruptor está presionado (se mantiene en alto)
               if (~sw)  // Si el interruptor sigue liberado
               begin
                  q_next_normal = q_reg_normal - 1;  // Decrementa el contador normal
                  q_next_long = q_reg_long - 1;      // Decrementa el contador largo
                  if (count_normal == 0)  // Si el contador llega a 0, el debounce ha terminado
                     state_next = zero;   // Regresa al estado 'zero', confirmando la liberación del interruptor
               end
               else
                  state_next = one;  // Si el interruptor vuelve a ser presionado antes de terminar el debounce, regresa al estado 'one'
            end
         default: state_next = zero;  // Estado por defecto es 'zero'
      endcase
   end

endmodule