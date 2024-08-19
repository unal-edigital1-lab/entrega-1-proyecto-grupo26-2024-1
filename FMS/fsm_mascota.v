module fsm_mascota (clk,reset,A,B,C,output1,output2);
    input  clk;
    input  reset;
    input  A;       // Entrada para transición de estados
    input  B;       // Entrada para modificar variable en el estado actual
    input  C;         // Nueva entrada para transición de estados en el sentido contrario
    //salidas
    output reg [7:0] output1;  
    output reg [3:0] output2;


    parameter S0=0;
    parameter S1=1;
    parameter S2=2;
    parameter S3=3;
    parameter S4=4;

    reg [0:2] state_t, current_state, next_state;
    
    reg [3:0] var_S0, var_S1, var_S2, var_S3, var_S4;

    // Registro de estado
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Lógica combinacional para transiciones de estado 1 sentido
/*     always @(posedge clk) begin
        case (current_state)
            S0: next_state = A ? S1 : S0;
            S1: next_state = A ? S2 : S1;
            S2: next_state = A ? S3 : S2;
            S3: next_state = A ? S4 : S3;
            S4: next_state = A ? S0 : S4;
            default: next_state = S0;
        endcase
    end */

    // Lógica combinacional para determinar el siguiente estado
    always @(posedge clk) begin
        case (current_state)
            S0: next_state = A ? S1 : (C ? S4 : S0);  // Cambia a S4 si C está activo
            S1: next_state = A ? S2 : (C ? S0 : S1);  // Cambia a S0 si C está activo
            S2: next_state = A ? S3 : (C ? S1 : S2);  // Cambia a S1 si C está activo
            S3: next_state = A ? S4 : (C ? S2 : S3);  // Cambia a S2 si C está activo
            S4: next_state = A ? S0 : (C ? S3 : S4);  // Cambia a S3 si C está activo
            default: next_state = S0;  // Valor por defecto en caso de un estado no definido
        endcase
    end


    // Modificación de variables por estado
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            var_S0 <= 8'b0;
            var_S1 <= 8'b0;
            var_S2 <= 8'b0;
            var_S3 <= 8'b0;
            var_S4 <= 8'b0;
        end
        else if (B) begin
            case (current_state)
                S0: var_S0 <= var_S0 + 1;
                S1: var_S1 <= var_S1 + 1;
                S2: var_S2 <= var_S2 + 1;
                S3: var_S3 <= var_S3 + 1;
                S4: var_S4 <= var_S4 + 1;
            endcase
        end
    end

    // Lógica para las salidas
    always @(*)begin
        case (current_state)
            S0: begin
                output1 = var_S0; 
                output2 = S0;
            end
            S1: begin
                output1 = var_S1;
                output2 = S1;
            end
            S2: begin
                output1 = var_S2;
                output2 = S2;
            end
            S3: begin
                output1 = var_S3; 
                output2 = S3;
            end
            S4: begin
                output1 = var_S4;
                output2 = S4;
            end
            //default: output1 = 8'b1;
        endcase
    end


endmodule
