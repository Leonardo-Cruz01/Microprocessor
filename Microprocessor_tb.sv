`timescale 1ns/1ps

//
// testbench for lab5 that runs through the entire program and stores it in Microprocessor.csv
//
module lab5_tb ();
logic clk, reset, Cout, OF;
logic [3:0] OPCODE;
logic [1:0] State;
logic [7:0] PC, Alu_out, W_Reg;
lab5 L1 (clk, reset, OPCODE, State, PC, Alu_out, W_Reg, Cout, OF);
initial begin
	reset = 1'b1; clk = 1'b0; #5;
	reset = 1'b0; 
	repeat (228) begin
		clk = 1'b1; #5; clk = 1'b0; #5;
	end
end
endmodule
