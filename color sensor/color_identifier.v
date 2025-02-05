module color_identifier(
    input [15:0] red_norm,    // Valor normalizado del componente rojo
    input [15:0] green_norm,  // Valor normalizado del componente verde
    input [15:0] blue_norm,   // Valor normalizado del componente azul
    output reg [2:0] color    // Salida de 3 bits que representa el color
);

    always @(*) begin
        if (red_norm < 16'd150 && green_norm < 16'd150 && blue_norm < 16'd150) begin
            color = ~3'b000;  // Negro
        end 
		  
		  else if (red_norm > 16'd600 && green_norm > 16'd600 && blue_norm > 16'd600) begin
            color = ~3'b111;  // Blanco
        end 
		  ////////////rojo 
		  else if (red_norm > green_norm && red_norm > blue_norm) begin
            if (green_norm > blue_norm) 
                color = ~3'b110;  // Amarillo (Rojo + Verde)
            else
                color = ~3'b100;  // Rojo            
        end
		  /////////////verde
		  else if (green_norm > red_norm && green_norm > blue_norm) begin
            if (red_norm > blue_norm)
                color = ~3'b110;  // Amarillo (Rojo + Verde)
            else
                color = ~3'b010;  // Verde
        end 
		  /////////////azul
		  else if (blue_norm > red_norm && blue_norm > green_norm) begin
            if (red_norm > green_norm)
                color = ~3'b101;  // Magenta (Rojo + Azul)
            else
                color = ~3'b001;  // Azul
        end else begin
            color = ~3'b011;  // Cian (Verde + Azul)
        end
    end

endmodule
