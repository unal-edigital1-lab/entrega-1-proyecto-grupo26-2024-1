module color_identifier1(
    input [15:0] red_norm,    // Valor normalizado del componente rojo
    input [15:0] green_norm,  // Valor normalizado del componente verde
    input [15:0] blue_norm,   // Valor normalizado del componente azul
    output reg [2:0] color    // Salida de 3 bits que representa el color
);

    // Define los umbrales para cada componente de color
    localparam RED_THRESHOLD   = 16'd80;  // Ajusta el umbral según sea necesario
    localparam GREEN_THRESHOLD = 16'd80;  // Ajusta el umbral según sea necesario
    localparam BLUE_THRESHOLD  = 16'd80;  // Ajusta el umbral según sea necesario

    always @(*) begin
        // Inicializa el color a 0 (todo apagado)
        color = 3'b111;

        // Comparar el valor normalizado del rojo
        if (red_norm > RED_THRESHOLD) begin
            color[0] = 1'b0;  // Establece el primer bit si el rojo está por encima del umbral
        end

        // Comparar el valor normalizado del verde
        if (green_norm > GREEN_THRESHOLD) begin
            color[1] = 1'b0;  // Establece el segundo bit si el verde está por encima del umbral
        end

        // Comparar el valor normalizado del azul
        if (blue_norm > BLUE_THRESHOLD) begin
            color[2] = 1'b0;  // Establece el tercer bit si el azul está por encima del umbral
        end
    end

endmodule


module color_identifier (
    input [15:0] red_norm,   // Valor normalizado del componente rojo
    input [15:0] green_norm, // Valor normalizado del componente verde
    input [15:0] blue_norm,  // Valor normalizado del componente azul
    output reg [2:0] color   // Salida de color identificada (3 bits)
);

    // Variables de umbral para cada color
    reg [15:0] threshold_red;
    reg [15:0] threshold_green;
    reg [15:0] threshold_blue;

    initial begin
        // Valores iniciales de los umbrales (ajustables)
        threshold_red = 16'd80;
        threshold_green = 16'd50;
        threshold_blue = 16'd55;
    end

    // Comparador de color
    always @(*) begin
        // Comparación para identificar el color
        if (red_norm < threshold_red && green_norm < threshold_green && blue_norm < threshold_blue) begin
            color = 3'b000;  // Negro
        end
        else if (red_norm > threshold_red && green_norm > threshold_green && blue_norm > threshold_blue) begin
            color = 3'b111;  // Blanco
        end
        else if (red_norm > threshold_red) begin
            if (blue_norm > threshold_blue) begin
                color = ~3'b101;  // Magenta (Rojo + Azul)
            end else if (green_norm > threshold_green) begin
                color = ~3'b110;  // Amarillo (Rojo + Verde)
            end else begin
                color = ~3'b100;  // Rojo
            end
        end
        else if (green_norm > threshold_green) begin
            if (blue_norm > threshold_blue) begin
                color = ~3'b011;  // Cyan (Verde + Azul)
            end else begin
                color = ~3'b010;  // Verde
            end
        end
        else if (blue_norm > threshold_blue) begin
            color = ~3'b001;  // Azul
        end else begin
            color = 3'b000;  // Por defecto, negro
        end
    end

endmodule









//module color_identifier1(
//    input [15:0] red_norm,    // Valor normalizado del componente rojo
//    input [15:0] green_norm,  // Valor normalizado del componente verde
//    input [15:0] blue_norm,   // Valor normalizado del componente azul
//    output reg [2:0] color    // Salida de 3 bits que representa el color
//);
//
//
//
//
//    always @(*) 
//    begin
//        // Comparadores directos para identificar los colores
//        if (red_norm < 16'd300 && green_norm < 16'd250 && blue_norm < 16'd200) begin
//            color = 3'b000;  // Negro
//            end
//        
//        
//		  else if (red_norm > 16'd800 && green_norm > 16'd500 && blue_norm > 16'd550) begin
//            color = 3'b111;  // Blanco
//            end 
//        
//        
//		  
//		  else if (red_norm > 16'd800 ) begin
//            
//				if(blue_norm > 16'd550) begin
//                color = ~3'b101;  // Magenta (Rojo + Azul)
//            end
//            
//				
//				else if(green_norm > 16'd500)begin
//                color = ~3'b110;  // Amarillo (Rojo + Verde) 
//            end
//            else begin
//            color = ~3'b100;  // Rojo 
//            end
//            end 
//
//        
//		  else if (green_norm > 16'd500) begin
//            if(blue_norm > 16'd550)begin
//                color = ~3'b011;  // Cyan (Verde + Azul)
//                end
//            else begin
//                color = ~3'b010;  // Verde
//                end 
//            end 
//        
//        
//		  
//		  else if (blue_norm > 16'd550) begin
//            color = ~3'b001;  // Azul
//            end 
//        
//    end
//
//	 
////	 always @(*) begin
////        // Comparadores directos para identificar los colores
////        if (red_norm < 16'd100 && green_norm < 16'd100 && blue_norm < 16'd100) begin
////            color = 3'b000;  // Negro
////        end else if (red_norm > 16'd900 && green_norm > 16'd900 && blue_norm > 16'd900) begin
////            color = 3'b111;  // Blanco
////        end else if (red_norm > 16'd700 && green_norm < 16'd300 && blue_norm < 16'd300) begin
////            color = 3'b100;  // Rojo
////        end else if (green_norm > 16'd700 && red_norm < 16'd300 && blue_norm < 16'd300) begin
////            color = 3'b010;  // Verde
////        end else if (blue_norm > 16'd700 && red_norm < 16'd300 && green_norm < 16'd300) begin
////            color = 3'b001;  // Azul
////        end else if (red_norm > 16'd700 && green_norm > 16'd700 && blue_norm < 16'd300) begin
////            color = 3'b110;  // Amarillo (Rojo + Verde)
////        end else if (red_norm > 16'd700 && blue_norm > 16'd700 && green_norm < 16'd300) begin
////            color = 3'b101;  // Magenta (Rojo + Azul)
////        end else if (green_norm > 16'd700 && blue_norm > 16'd700 && red_norm < 16'd300) begin
////            color = 3'b011;  // Cian (Verde + Azul)
////        end else begin
////            color = 3'b000;  // Por defecto, Negro
////        end
////    end
////	 
//	 
//endmodule

