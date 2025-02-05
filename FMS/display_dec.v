`timescale 1ns / 1ps
//`include "BCDtoSSeg.v"
module display_dec(
	//ENTRADAS
   input [7:0] numA,//ENTRADA 8 BIT (numero a representar)A
	input [7:0] numB,//ENTRADA 8 BIT (numero a representar)B
   input clk, // ENTRADA RELOJ 
	input rst, //RESET
   //SALIDAS 
	output [0:6] sseg,//SALIDA A 7 SEGMENTOS 
   output reg [7:0] an,//SALIDA REGISTRADA DE KATODOS (SE MANTIENE HASTA EL PROXIMO FRANCO DE SUBIDA)
	output led);


reg [3:0]bcd=0;
// instancia del modulo BCDtoSSeg
BCDtoSSeg bcdtosseg(.BCD(bcd), .SSeg(sseg));//
reg [31:0] cfreq=0;
wire enable;

// Divisor de frecuecia

assign enable = cfreq[16];
assign led =enable;

always @(posedge clk) begin // ACTIVA EL BLOQUE CUANDO HAY UN FRANCO DE SUBIDA 
  if(rst==0) begin
		cfreq <= 0;
	end else begin
		cfreq <=cfreq+1;
	end
end


reg [3:0] count =0;
always @(posedge enable) begin // se activa el bloque cuando se tiene un fraco de subida
		if(rst==0) begin // si reset esta activo apaga todos los segmentos del display
			count<= 0;
			an<=8'b11111111; 
		end else begin 
			count<= count+1;
			case (count) //6 casos posibles pues en cada instante solo se prende un segmento 
				4'h0: begin bcd <= numA % 10;   an<=8'b11111110; end //seg 1 unidades
				4'h1: begin bcd <= (numA/10)%10;   an<=8'b11111101; end //seg 2 decenas 
				4'h2: begin bcd <= (numA/100)%10;  an<=8'b11111011; end //seg 3 centenas 
				4'h3 :begin	bcd <= (4'ha); an<=8'b11110111; end //Señalador del dato A
				4'h4: begin bcd <= numB % 10;   an<=8'b11101111; end //seg 1 unidades
				4'h5: begin bcd <= (numB/10)%10;   an<=8'b11011111; end //seg 2 decenas 
				4'h6: begin bcd <= (numB/100)%10;  an<=8'b10111111; end //seg 3 centenas
				4'h7 :begin	bcd <= (11); an<=8'b01111111; end //Señalador del dato B
			endcase
		end
end

endmodule
