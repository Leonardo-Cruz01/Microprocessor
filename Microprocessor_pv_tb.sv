`timescale 1ns/1ps

//
// testbench for the physical validation of lab5
//
module lab5_pv_tb ();
logic clk, SW0, SW1, KEY0, SW2, SW3, SW4, LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7;
logic [6:0] SevSeg5, SevSeg4, SevSeg3, SevSeg2, SevSeg1, SevSeg0;
lab5_pv P1 (clk, SW0, SW1, KEY0, SW2, SW3, SW4, SevSeg5, SevSeg4, SevSeg3, SevSeg2, SevSeg1, SevSeg0, LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7);
initial begin
	SW0 = 1'b1; clk = 1'b0; SW1 = 1'b1; KEY0 = 1'b0; SW4 = 1'b0; SW3 = 1'b0; SW2 = 1'b0; #5;
	SW0 = 1'b0; 
	repeat (223) begin
		KEY0 = 1'b1; #5; KEY0 = 1'b0; #5;
	end
	SW4 = 1'b1; SW3 = 1'b1; SW2 = 1'b0; #5;
	SW4 = 1'b1; SW3 = 1'b0; SW2 = 1'b1; #5;
	SW4 = 1'b0; SW3 = 1'b1; SW2 = 1'b1; #5;
	SW4 = 1'b1; SW3 = 1'b1; SW2 = 1'b1; #5;
	SW4 = 1'b0; SW3 = 1'b0; SW2 = 1'b1; #5;
end
endmodule
