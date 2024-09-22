module top_module(
    input wire clk, reset,            // Señal de reloj y reinicio para el sistema
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
        .clk(clk),          // Conexión de la señal de reloj
        .reset(reset),      // Conexión de la señal de reinicio
        .sw(btn_nav1),      // Conexión de la entrada del botón de navegación 1 sin debounce
        .mode(0),        // Selección del modo (debounce normal o largo)
        .db_level(db_nav1), // Salida del estado filtrado del botón de navegación 1
        .db_tick(tick_nav1) // Pulso cuando el botón de navegación 1 cambia de estado
    );

    // Instancia de debounce para el botón de navegación 2
    debounce debounce_btn_nav2 (
        .clk(clk),          // Conexión de la señal de reloj
        .reset(reset),      // Conexión de la señal de reinicio
        .sw(btn_nav2),      // Conexión de la entrada del botón de navegación 2 sin debounce
        .mode(0),        // Selección del modo (debounce normal o largo)
        .db_level(db_nav2), // Salida del estado filtrado del botón de navegación 2
        .db_tick(tick_nav2) // Pulso cuando el botón de navegación 2 cambia de estado
    );

    // Instancia de debounce para el botón de selección
    debounce debounce_btn_select (
        .clk(clk),           // Conexión de la señal de reloj
        .reset(reset),       // Conexión de la señal de reinicio
        .sw(btn_select),     // Conexión de la entrada del botón de selección sin debounce
        .mode(0),         // Selección del modo (debounce normal o largo)
        .db_level(db_select),// Salida del estado filtrado del botón de selección
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