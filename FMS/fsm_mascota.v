module fsm_mascota(
    input clk,
    input reset,
    input A,  // Entrada para transición de estados
    input B,  // Entrada para modificar variable en el estado actual
    input C,  // Entrada para transición de estados en el sentido contrario
    input test,
    input [2:0] color, // entrada de 3 bits que representa el color leido por el sensor
    input [1:0] time_control,  // entrada de 2 bits para modificar el contador de tiempo
    input luz,// entrada de luz del sensor // negada (hay luz = 0 |no hay luz=1) 
    output reg [2:0] output1,
    output reg [2:0] output2,
	 output reg [2:0] comida_color_out
);
////estados de la maquina
//    parameter INIT = 6;//inicio
//    parameter S0 = 0;//
//    parameter S1 = 1;//comer 
//    parameter S2 = 2;//dormir
//    parameter S3 = 3;//jugar
//    parameter S4 = 4;//salud
//    parameter S5 = 5;//tieso 
//    parameter S6 = 7;//mimir
    parameter INIT = 0;//inicio
    parameter S0 = 1;//
    parameter S1 = 2;//comer 
    parameter S2 = 3;//dormir
    parameter S3 = 4;//jugar
    parameter S4 = 5;//salud
    parameter S5 = 6;//tieso 
    parameter S6 = 7;//mimir
    reg [2:0] current_state;
	 reg [2:0] next_state;
    reg [2:0] var_S0, var_S1, var_S2, var_S3, var_S4;

    // Temporizador y parámetros de decremento
    reg [33:0] timer;
    reg [1:0] dzzzd;
    reg [33:0] decrement_interval;
    //parameter BASE_INTERVAL = 32'd31; /// TESTBENCH
    parameter BASE_INTERVAL = 32'd4294967295;  // Intervalo base para disminuir variables 4294967295 para 80 seg
    reg decremento;

    reg [1:0] comida_color = 2'b00;
	 reg [7:0] vida_prom;
	initial begin 
//  next_state <= 0;   
//	 current_state <= 0;
	//timer <= 0;
	 vida_prom <= 35;
	 dzzzd <= 0;
	 end 


    // Ajuste del intervalo de tiempo según time_control //se desplaza un bit a la derecha en cada caso lo que 
    //equivale a dividir por 2 el tiempo de espera
    always @(*) begin
        case (time_control)
            2'b00: decrement_interval = BASE_INTERVAL;       // Tiempo base
            2'b01: decrement_interval = BASE_INTERVAL >> 1;  // Doble de rápido
            2'b10: decrement_interval = BASE_INTERVAL >> 2;  // Doble de lento
            2'b11: decrement_interval = BASE_INTERVAL >> 3;  // Cuatro veces más lento
        endcase
    end

    // Registro de estado
    always @(posedge clk) begin
        if (reset == 0)
			current_state <= INIT;
        else
            current_state <= next_state;
    end

    // Calcular el promedio de las variables


    // Lógica combinacional para transiciones de estado
    always @(*) begin
        case (current_state)
            INIT: next_state = (A || B || C) ? S0 : INIT;
            S0: next_state = (vida_prom < 3 && test == 0) ? S5 : (A ? S1 : (C ? S4 : S0));  // Transición a S5 si promedio < 5
            S1: next_state = (vida_prom < 3 && test == 0) ? S5 : (A ? S2 : (C ? S0 : S1));  // Transición a S5 si promedio < 5
            S2: next_state = (vida_prom < 3 && test == 0) ? S5 : (B && luz ? S6 : (A ? S3 : (C ? S1 : S2)));  // Transición a S5 si promedio < 5
            S3: next_state = (vida_prom < 3 && test == 0) ? S5 : (A ? S4 : (C ? S2 : S3));  // Transición a S5 si promedio < 5
            S4: next_state = (vida_prom < 3 && test == 0) ? S5 : (A ? S0 : (C ? S3 : S4));  // Transición a S5 si promedio < 5
            S6: next_state = (A || C || var_S2 == 7 || luz == 0) ? S2 : S6;  // Transición de regreso a S2 desde S6
//            default: next_state = INIT;  // Valor por defecto en caso de un estado no definido
        endcase
    end

always @(posedge clk) begin
		  vida_prom = (var_S0 + var_S1 + var_S2 + var_S3 + var_S4);
        if (timer < decrement_interval)begin
            timer = timer + 1;
            decremento = 1'b0 ;
        end
        else begin 
        timer <= 0 ;
        decremento = 1'b1 ;
        end  
end 
	 // Modificación de variables por estado
always @(negedge clk) begin// Inicialización de las variables en el estado INIT
    if (next_state == INIT) begin
        var_S0 <= 3'd7;
        var_S1 <= 3'd7;
        var_S2 <= 3'd7;
        var_S3 <= 3'd7;
        var_S4 <= 3'd7;
    end 

    if (next_state != S6 && next_state != INIT)begin
        // Incrementar el temporizador en cada ciclo de reloj
        if (decremento == 1 && test == 0)begin
            // Reducir las variables cuando el temporizador alcanza el intervalo
            if (var_S0 > 0) begin
                var_S0 <= var_S0 - 1;end
            if (var_S1 > 0)begin 
                var_S1 <= var_S1 - 1;end
            if (var_S2 > 0)begin 
                var_S2 <= var_S2 - 1;end
            if (var_S3 > 0)begin 
                var_S3 <= var_S3 - 1;end
            if (var_S4 > 0)begin 
                var_S4 <= var_S4 - 1;end            
		end 
	end

    /// estado 6
    if (next_state == S6) begin
        if(decremento == 1)begin
            if(dzzzd < 3)begin
                dzzzd <= dzzzd + 1;
                end
            else begin
                dzzzd <= 0;
                var_S2 <= 7;
                //next_state = S2;
                if (var_S4 < 7) begin // MODIFICA LA SALUD
                var_S4 <= var_S4 + 1;end
            end
        end         
    end

        // Modificación de variables con la entrada B
    if (B) begin
        if(test == 0)begin
            case (next_state)
                S0 : begin
					if(var_S0 < 7)begin
                    var_S0 <= var_S0 + 1;
                    end
				end
                S1 : begin
					if(var_S1 < 7 && var_S1 > 0)begin
                        if(comida_color==color)begin
                            var_S1 <= var_S1 + 1;
                            comida_color <= comida_color + 1;
                        end
                        else begin
                            var_S1 <= var_S1 - 1; 
					        if (comida_color < 6)begin
                                comida_color <= comida_color + 1;
                            end
					        else begin 
					            comida_color <=1;
                            end 
                            if(var_S4 > 0)begin
                                var_S4 <= var_S4 - 1;end
                        end
                    end
							end
                
					 S3 : begin
				    if(var_S3 < 7)begin 
                        var_S3 <= var_S3 + 1;
                        if(var_S1 > 0 && var_S2 > 0)begin
                        var_S1 <= var_S1 - 1;
                        var_S2 <= var_S2 - 1 ;end 
                    end
				end
                S4 : begin
					if(var_S4 < 7)begin 
                        var_S4 <= var_S4 + 1;
                    end
				end	
            endcase 
        end 
		else begin
            case (next_state)
                S0: var_S0 <= var_S0 + 1;
                S1: var_S1 <= var_S1 + 1;
                S2: var_S2 <= var_S2 + 1;
                S3: var_S3 <= var_S3 + 1;
                S4: var_S4 <= var_S4 + 1;
            endcase
        end
    end
end

    // Lógica para las salidas
    always @(*) begin
        case (next_state)
            INIT:begin
                output1 <= 0;
                output2 <= 0;
            end
            S0: begin
                output1 <= var_S0;
                output2 <= S0;
            end
            S1: begin
                output1 <= var_S1;
                output2 <= S1;
					 comida_color_out <= comida_color;
            end
            S2: begin
                output1 <= var_S2;
                output2 <= S2;
            end
            S3: begin
                output1 <= var_S3;
                output2 <= S3;
            end
            S4: begin
                output1 <= var_S4;
                output2 <= S4;
            end
            S5: begin
                output1 <= 0;  // Definir las salidas según lo que S5 deba hacer
                output2 <= S5;
            end
            S6: begin
                output1 <= 0;
                output2 <= S6;
            end
        endcase
    end

endmodule
//module fsm_mascota(
//    input clk,
//    input reset,
//    input A,  // Entrada para transición de estados
//    input B,  // Entrada para modificar variable en el estado actual
//    input C,  // Entrada para transición de estados en el sentido contrario
//    input test,
//    input [1:0] color,
//    input [1:0] time_control,  // Nueva entrada de 2 bits para modificar el contador de tiempo
//    input luz,
//	 output reg [2:0] comida_color_out,
//    output reg [2:0] output1,
//    output reg [2:0] output2
//);
////estados de la maquina
//    parameter INIT = 6;//inicio
//    parameter S0 = 0;//
//    parameter S1 = 1;//comer 
//    parameter S2 = 2;//dormir
//    parameter S3 = 3;//jugar
//    parameter S4 = 4;//salud
//    parameter S5 = 5;//tieso 
//    parameter S6 = 7;//mimir
//    reg [2:0] current_state;
//	reg [2:0] next_state;
//    reg [2:0] var_S0, var_S1, var_S2, var_S3, var_S4;
//
//    // Temporizador y parámetros de decremento
//    reg [31:0] timer = 0;
//    reg [1:0] dzzzd = 0;
//    reg [33:0] decrement_interval;
//    parameter BASE_INTERVAL = 33'd4294967295;  // Intervalo base para disminuir variables
//
//    reg [1:0] comida_color = 2'b00;
//
//initial begin 
//    next_state <= 6;   
//    current_state <= 6;
//end
//    // Ajuste del intervalo de tiempo según time_control //se desplaza un bit a la derecha en cada caso lo que 
//    //equivale a dividir por 2 el tiempo de espera
//    always @(*) begin
//        case (time_control)
//            2'b00: decrement_interval = BASE_INTERVAL;       // Tiempo base
//            2'b01: decrement_interval = BASE_INTERVAL >> 1;  // Doble de rápido
//            2'b10: decrement_interval = BASE_INTERVAL >> 2;  // Doble de lento
//            2'b11: decrement_interval = BASE_INTERVAL >> 3;  // Cuatro veces más lento
//        endcase
//    end
//
//    // Registro de estado
//    always @(posedge clk or posedge reset) begin
//        if (reset)begin
//			current_state <= INIT;end
//        else begin
//            current_state <= next_state;end 
//    end
//
//    // Calcular el promedio de las variables
//    wire [5:0] vida_prom;
//    assign vida_prom = (var_S0 + var_S1 + var_S2 + var_S3 + var_S4);
//
//    // Lógica combinacional para transiciones de estado // asigna el valor a next estate
//    always @(posedge clk) begin
//        case (current_state)
//            INIT: next_state = (A || B || C) ? S0 : INIT;
//            S0: next_state = (vida_prom < 5 && test == 0) ? S5 : (A ? S1 : (C ? S4 : S0));  // Transición a S5 si promedio < 5// S1 si A //S4 si C//o se mantiene
//            S1: next_state = (vida_prom < 5 && test == 0) ? S5 : (A ? S2 : (C ? S0 : S1));  // Transición a S5 si promedio < 1 
//            S2: next_state = (vida_prom < 5 && test == 0) ? S5 : (B && luz ? S6 : (A ? S3 : (C ? S1 : S2)));  // Transición a S5 si promedio < 1
//            S3: next_state = (vida_prom < 5 && test == 0) ? S5 : (A ? S4 : (C ? S2 : S3));  // Transición a S5 si promedio < 1
//            S4: next_state = (vida_prom < 5 && test == 0) ? S5 : (A ? S0 : (C ? S3 : S4));  // Transición a S5 si promedio < 1
//            S5: next_state = (reset) ? INIT : S5;  // El estado S5 podría ser un estado final o de alarma
//            S6: next_state = (A || C || var_S2 == 7) ? S2 : S6;  // Transición de regreso a S2 desde S6
////            default: next_state = INIT;  // Valor por defecto en caso de un estado no definido
//        endcase
//    end
//
//
//	 // Modificación de variables por estado
//always @(posedge clk) begin
//    // estado inicial
//    if (current_state == INIT) begin
//        // Inicialización de las variables en el estado INIT
//        var_S0 <= 3'd7;
//        var_S1 <= 3'd7;
//        var_S2 <= 3'd7;
//        var_S3 <= 3'd7;
//        var_S4 <= 3'd7;
//        timer <= 0;
//    end
//
//    if (current_state != S6 && INIT)begin
//        // Incrementar el temporizador en cada ciclo de reloj
//        if (timer < decrement_interval)begin
//            timer <= timer + 1;
//			end
//        //reduccion de variables con el tiempo
//        else begin
//            timer <= 0;  // Reinicia el temporizador cuando alcanza el intervalo
//            // Reducir las variables cuando el temporizador alcanza el intervalo
//                if (var_S0 > 0) begin
//                    var_S0 <= var_S0 - 1;end
//                if (var_S1 > 0)begin 
//                    var_S1 <= var_S1 - 1;end
//                if (var_S2 > 0)begin 
//                    var_S2 <= var_S2 - 1;end
//                if (var_S3 > 0)begin 
//                    var_S3 <= var_S3 - 1;end
//                if (var_S4 > 0)begin 
//                    var_S4 <= var_S4 - 1;end            
//		end 
//		end
//    /// estado 6
//    else begin
//        // Incrementar el temporizador en cada ciclo de reloj
//        if (timer < decrement_interval)begin
//            timer <= timer + 1;
//        end
//
//        //aumento de variables con el tiempo
//        else begin
//            timer <= 0;  // Reinicia el temporizador cuando alcanza el intervalo
//            if(dzzzd < 3)begin
//                dzzzd <= dzzzd + 1;
//                end
//            else begin
//                dzzzd <= 0;
//                var_S2 <= 7;
//                //next_state = S2;
//                if (var_S4 < 7) begin // MODIFICA LA SALUD
//                var_S4 <= var_S4 + 1;end
//            end    
//
//                    
//        end         
//
//    end
//
//        // Modificación de variables con la entrada B
//        if (B) begin
//            if(test == 0)begin
//                case (current_state)
//                    S0 : begin
//						  if(var_S0 < 7)begin
//                        var_S0 <= var_S0 + 1;
//                        end
//								end
//
//                    S1 : begin
//						  if(var_S1 < 7 && var_S1 > 0)begin
//                        if(comida_color==color)begin
//                        var_S1 <= var_S1 + 1;
//                        comida_color <= comida_color + 1;end
//                        else begin
//                        var_S1 <= var_S1 - 1; 
//                        comida_color <= comida_color + 1;
//                        if(var_S4 > 0)begin
//                            var_S4 <= var_S4 - 1;end
//                        end
//                        end
//								end
//                    S3 : begin
//								if(var_S3 < 7)begin 
//                        var_S3 <= var_S3 + 1;
//                        if(var_S1 > 0 && var_S2 > 0)begin
//                        var_S1 <= var_S1 - 1;
//                        var_S2 <= var_S2 - 1 ;end 
//                        end
//								end
//
//                    S4 : begin
//								if(var_S4 < 7)begin 
//                        var_S4 <= var_S4 + 1;
//                        end
//							end	
//                endcase 
//
//            end 
//				else begin
//                case (current_state)
//                S0: var_S0 <= var_S0 + 1;
//                S1: var_S1 <= var_S1 + 1;
//                S2: var_S2 <= var_S2 + 1;
//                S3: var_S3 <= var_S3 + 1;
//                S4: var_S4 <= var_S4 + 1;
//            endcase
//            end
//
//        end
//end
//
//    // Lógica para las salidas
//    always @(*) begin
//        case (current_state)
//            INIT:begin
//                output1 = 200;
//                output2 = 88;
//            end
//            S0: begin
//                output1 = var_S0;
//                output2 = S0;
//            end
//            S1: begin
//                output1 = var_S1;
//                output2 = S1;
//            end
//            S2: begin
//                output1 = var_S2;
//                output2 = S2;
//					 comida_color_out = comida_color;
//            end
//            S3: begin
//                output1 = var_S3;
//                output2 = S3;
//            end
//            S4: begin
//                output1 = var_S4;
//                output2 = S4;
//            end
//            S5: begin
//                output1 = 8'hF;  // Definir las salidas según lo que S5 deba hacer
//                output2 = S5;
//            end
//            S6: begin
//                output1 = 123;
//                output2 = S6;
//            end
//        endcase
//    end
//
//endmodule