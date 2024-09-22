// Módulo debounce: Filtra los rebotes de los botones, evitando que los cambios de estado no deseados se registren.
module debounce
   (
    input wire clk, reset,   // Señales de reloj y reset
    input wire sw,           // Señal de entrada del botón (sin debounce)
    input wire mode,         // Modo para seleccionar entre debounce normal o largo
    output reg db_level,     // Estado filtrado del botón (con debounce)
    output reg db_tick       // Pulso que indica cuando el botón cambia de estado
   );

   // Parámetros para definir los diferentes estados del sistema
   localparam  [1:0]
               zero  = 2'b00,   // Estado cuando el botón no está presionado
               wait0 = 2'b01,   // Espera antes de cambiar al estado zero
               one   = 2'b10,   // Estado cuando el botón está presionado
               wait1 = 2'b11;   // Espera antes de cambiar al estado one

   // Parámetros para definir el tiempo de debounce normal y largo
   localparam N_NORMAL = 23;     // Tiempo de debounce normal (por defecto)
   localparam N_LONG = 26;       // Tiempo de debounce largo (5 segundos)

   // Registros para los contadores y estados
   reg [N_NORMAL-1:0] q_reg_normal, q_next_normal; // Contadores para debounce normal
   reg [N_LONG-1:0] q_reg_long, q_next_long;       // Contadores para debounce largo
   reg [1:0] state_reg, state_next;               // Estado actual y siguiente

   // Selección del contador basado en el modo (normal o largo)
   wire [N_NORMAL-1:0] count_normal = (mode ? q_reg_long : q_reg_normal);
   wire [N_NORMAL-1:0] count_next_normal = (mode ? q_next_long : q_next_normal);

   // Configuración del contador y los estados
   always @(posedge clk or posedge reset)
   begin
      if (reset)  // Si se activa el reset, se inicializan los estados y contadores
      begin
         state_reg <= zero;
         q_reg_normal <= 0;
         q_reg_long <= 0;
      end
      else  // De lo contrario, se actualizan los estados y contadores
      begin
         state_reg <= state_next;
         q_reg_normal <= (mode ? q_reg_normal : count_next_normal);
         q_reg_long <= (mode ? count_next_normal : q_reg_long);
      end
   end

   // Lógica del estado siguiente y del contador
   always @*
   begin
      state_next = state_reg;       // Mantiene el estado actual por defecto
      q_next_normal = (mode ? q_reg_long : q_reg_normal); // Actualiza los contadores
      q_next_long = (mode ? q_reg_long : q_reg_normal);
      db_tick = 1'b0;               // El pulso de cambio de estado es por defecto 0
      case (state_reg)
         zero:  // Estado cuando el botón no está presionado
            begin
               db_level = 1'b0;
               if (sw)  // Si el botón se presiona
               begin
                  state_next = wait1;  // Cambia al estado de espera antes de pasar a one
                  if (mode)  // Si está en modo largo
                     q_next_long = {N_LONG{1'b1}}; // Inicializa el contador largo
                  else  // Si está en modo normal
                     q_next_normal = {N_NORMAL{1'b1}}; // Inicializa el contador normal
               end
            end
         wait1:  // Espera antes de pasar al estado one
            begin
               db_level = 1'b0;
               if (sw)  // Si el botón sigue presionado
               begin
                  q_next_normal = q_reg_normal - 1;  // Decrementa el contador normal
                  q_next_long = q_reg_long - 1;      // Decrementa el contador largo
                  if (count_normal == 0)  // Si el contador llega a 0
                  begin
                     state_next = one;   // Cambia al estado one
                     db_tick = 1'b1;     // Genera un pulso indicando el cambio de estado
                  end
               end
               else
                  state_next = zero;  // Si el botón se libera, regresa a zero
            end
         one:  // Estado cuando el botón está presionado
            begin
               db_level = 1'b1;
               if (~sw)  // Si el botón se libera
               begin
                  state_next = wait0;  // Cambia al estado de espera antes de pasar a zero
                  if (mode)  // Si está en modo largo
                     q_next_long = {N_LONG{1'b1}}; // Inicializa el contador largo
                  else  // Si está en modo normal
                     q_next_normal = {N_NORMAL{1'b1}}; // Inicializa el contador normal
               end
            end
         wait0:  // Espera antes de pasar al estado zero
            begin
               db_level = 1'b1;
               if (~sw)  // Si el botón sigue liberado
               begin
                  q_next_normal = q_reg_normal - 1;  // Decrementa el contador normal
                  q_next_long = q_reg_long - 1;      // Decrementa el contador largo
                  if (count_normal == 0)  // Si el contador llega a 0
                     state_next = zero;   // Cambia al estado zero
               end
               else
                  state_next = one;  // Si el botón se presiona nuevamente, regresa a one
            end
         default: state_next = zero;  // Estado por defecto
      endcase
   end

endmodule

// Módulo superior donde se instancian los botones con el debounce
module top_module(
    input wire clk, reset,            // Señales de reloj y reinicio para el sistema
    input wire btn_nav1, btn_nav2,     // Entradas de los botones de navegación
    input wire btn_select, btn_test,   // Entradas de los botones de selección y test
    input wire btn_reset, btn_accel,   // Entradas de los botones de reset y aceleración
    input wire mode,                   // Modo de debounce (normal o largo)
    output wire db_nav1, db_nav2,       // Salidas del estado filtrado para los botones de navegación
    output wire db_select, db_test,     // Salidas del estado filtrado para los botones de selección y test
    output wire db_reset, db_accel,     // Salidas del estado filtrado para los botones de reset y aceleración
    output wire tick_nav1, tick_nav2,   // Pulsos cuando los botones de navegación cambian de estado
    output wire tick_select, tick_test, // Pulsos cuando los botones de selección y test cambian de estado
    output wire tick_reset, tick_accel  // Pulsos cuando los botones de reset y aceleración cambian de estado
);

    // Instancia de debounce para el botón de navegación 1
    debounce debounce_btn_nav1 (
        .clk(clk),          // Señal de reloj
        .reset(reset),      // Señal de reinicio
        .sw(btn_nav1),      // Entrada del botón de navegación 1 sin debounce
        .mode(0),        // Selección del modo (debounce normal o largo)
        .db_level(db_nav1), // Estado filtrado del botón de navegación 1
        .db_tick(tick_nav1) // Pulso cuando el botón de navegación 1 cambia de estado
    );

    // Instancia de debounce para el botón de navegación 2
    debounce debounce_btn_nav2 (
        .clk(clk),          // Señal de reloj
        .reset(reset),      // Señal de reinicio
        .sw(btn_nav2),      // Entrada del botón de navegación 2 sin debounce
        .mode(0),        // Selección del modo (debounce normal o largo)
        .db_level(db_nav2), // Estado filtrado del botón de navegación 2
        .db_tick(tick_nav2) // Pulso cuando el botón de navegación 2 cambia de estado
    );

    // Instancia de debounce para el botón de selección
    debounce debounce_btn_select (
        .clk(clk),           // Señal de reloj
        .reset(reset),       // Señal de reinicio
        .sw(btn_select),     // Entrada del botón de selección sin debounce
        .mode(0),         // Selección del modo (debounce normal o largo)
        .db_level(db_select),// Estado filtrado del botón de selección
        .db_tick(tick_select)// Pulso cuando el botón de selección cambia de estado
    );

    // Instancia de debounce para el botón de test
    debounce debounce_btn_test (
        .clk(clk),           // Conexión de la señal de reloj
        .reset(reset),       // Conexión de la señal de reinicio
        .sw(btn_test),       // Conexión de la entrada del botón de test sin debounce
        .mode(1),         // Selección del modo (debounce normal o largo)
        .db_level(db_test),  // Salida del estado filtrado del botón de test
        .db_tick(tick_test)  // Pulso cuando el botón de test cambia de estado
    );

    // Instancia de debounce para el botón de reset
    debounce debounce_btn_reset (
        .clk(clk),           // Conexión de la señal de reloj
        .reset(reset),       // Conexión de la señal de reinicio
        .sw(btn_reset),      // Conexión de la entrada del botón de reset sin debounce
        .mode(1),         // Selección del modo (debounce normal o largo)
        .db_level(db_reset), // Salida del estado filtrado del botón de reset
        .db_tick(tick_reset) // Pulso cuando el botón de reset cambia de estado
    );

    // Instancia de debounce para el botón de aceleración
    debounce debounce_btn_accel (
        .clk(clk),           // Conexión de la señal de reloj
        .reset(reset),       // Conexión de la señal de reinicio
        .sw(btn_accel),      // Conexión de la entrada del botón de aceleración sin debounce
        .mode(0),         // Selección del modo (debounce normal o largo)
        .db_level(db_accel), // Salida del estado filtrado del botón de aceleración
        .db_tick(tick_accel) // Pulso cuando el botón de aceleración cambia de estado
    );

endmodule