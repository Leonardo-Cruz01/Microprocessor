//
// 8-bit microprocessor
//
module lab5 (input clk, reset, output logic [3:0] OPCODE, output logic [1:0] State, output logic [7:0] PC, Alu_out, W_Reg, output logic Cout, OF);
localparam IF = 2'b00, EX = 2'b01, RWB = 2'b10;
logic [15:0] IR;
logic [7:0] A, B;
logic [3:0] RA, RB, RD;
Control C1 (clk, reset, State);
ProgramCounter P1 (clk, reset, (A >= B), PC, W_Reg, OPCODE, State, PC);
ROM R1 (PC, IR);
RegFile F1 (reset, clk, RA, RB, RD, OPCODE, State, W_Reg, A, B);
ALU A1 (clk, reset, RA, RB, RD, OPCODE, A, B, State, Alu_out, W_Reg, Cout, OF);
assign OPCODE = IR[15:12];
assign RA = IR[11:8];
assign RB = IR[7:4];
assign RD = IR[3:0];
//integer fd;
//assign fd = $fopen("Microprocessor.csv");
//always_comb begin
//	if ((PC == 8'd0) && (State == IF) && (clk == 1'b0)) begin
//		$fwrite(fd, "PC,IR,OPCODE,RA,RB,RD,W_Reg,Cout,OF\n");
//	end
//	else if ((State == EX) && (clk == 1'b0)) begin
//		$fwrite(fd, "%h,%h,%h,%h,%h,%h,%h,%h,%h\n", PC, IR, OPCODE, RA, RB, RD, W_Reg, Cout, OF);
//	end
//	else if ((PC == 8'd20) && (State == RWB)) begin
//		$fclose(fd);
//	end
//end
endmodule

//
// ALU with 15 different functions that stores the output in W_Reg
//
module ALU (input clk, reset, input [3:0] RA, RB, RD, OPCODE, input [7:0] A, B, input [1:0] State, output logic [7:0] Alu_out, W_Reg, output logic Cout, OF);
localparam IF = 2'b00, EX = 2'b01, RWB = 2'b10;
logic [7:0] next_W_Reg, AluMUX0, AluMUX1, AluMUX2, AluMUX3,  CoutMUX0, CoutMUX1, CoutMUX2, CoutMUX3, OFMUX0, OFMUX1, OFMUX2, OFMUX3;
MUX161 #(8) A1 (8'd0, {RA,RB}, A + B, A - B, A + RB, A * B, A / B, B - 8'd1, B + 8'd1, ~(A | B), ~(A & B), A ^ B, ~B, {4'd0,RD}, {RA,RB}, 8'd0, OPCODE, Alu_out);
MUX161 #(1) A2 (1'b0, 1'b0, (A + B > 9'd255), 1'b0, (A + RB > 9'd255), 1'b0, 1'b0, 1'b0, (A + 8'd1 > 9'd255), 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, OPCODE, Cout);
MUX161 #(1) A3 (1'b0, 1'b0, (~A[7]^B[7])&Alu_out[7], 1'b0, ~A[7]&Alu_out[7], (A * B > 9'd255), 1'b0, 1'b0, ~A[7]&Alu_out[7], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, OPCODE, OF);
Dreg #(8) D2 (clk, reset, 1'b1, next_W_Reg, W_Reg);
MUX41 #(8) M8 (W_Reg, Alu_out, W_Reg, W_Reg, State, next_W_Reg);
endmodule

//
// reset resets RF to 0, clk is the clock
// RA is an address at which value A is stored, RB is an address at which value B is stored
// RD is an address at which you store D
// OPCODE is the opcode
// current_state is the current state
// RF_data_in is D in the flow chart
// RF_data_out0 is A, RF_data_out1 is B
//
module RegFile (input reset, clk, input [3:0] RA, input [3:0] RB, input [3:0] RD, input [3:0] OPCODE, input [1:0] current_state, input [7:0] RF_data_in, output logic [7:0] RF_data_out0, output logic [7:0] RF_data_out1);
localparam IF = 2'b00, EX = 2'b01, RWB = 2'b10;
logic [7:0] RF [15:0];
always_ff @ (posedge clk or posedge reset) begin
	if (reset) begin
		RF_data_out0 <= 8'd0;
		RF_data_out1 <= 8'd0;
		for (int i=0; i<16; i=i+1)
			RF[i] <= 8'd0;
	end
	else begin
		RF_data_out0 <= RF[RA];
		RF_data_out1 <= RF[RB];
		if ((current_state == RWB) && (OPCODE < 4'b1101)) begin
			RF[RD] <= RF_data_in;
		end
	end
end
endmodule

//
// determines the next value of PC depending on OPCODE
//
module ProgramCounter (input clk, reset, Comp, input [7:0] PCin, D, input [3:0] OPCODE, input [1:0] State, output [7:0] PCout);
localparam IF = 2'b00, EX = 2'b01, RWB = 2'b10;
logic [7:0] Next_PC;
Dreg #(8) D1 (clk, reset, 1'b1, Next_PC, PCout);
MUX41 #(8) M7 (PCin, PCin, ((OPCODE == 4'b1101) && Comp)? PCin + D : (OPCODE == 4'b1110)? D : (OPCODE == 4'b1111)? PCin : PCin + 8'd1, PCin, State, Next_PC);
endmodule

//
// The ROM is where the program is held
//
module ROM (input [7:0] PC, output logic [15:0] IR);
logic [15:0] mem [20:0];
assign mem[0] = 16'h1000;
assign mem[1] = 16'h1011;
assign mem[2] = 16'h1002;
assign mem[3] = 16'h10A3;
assign mem[4] = 16'hD236;
assign mem[5] = 16'h2014;
assign mem[6] = 16'h4100;
assign mem[7] = 16'h4401;
assign mem[8] = 16'h8022;
assign mem[9] = 16'hE040;
assign mem[10] = 16'h4405;
assign mem[11] = 16'h6536;
assign mem[12] = 16'h5637;
assign mem[13] = 16'h3538;
assign mem[14] = 16'h4329;
assign mem[15] = 16'h709A;
assign mem[16] = 16'h70AB;
assign mem[17] = 16'hBB8C;
assign mem[18] = 16'h9C1D;
assign mem[19] = 16'hC0DF;
assign mem[20] = 16'hF000;
assign IR = mem[PC];
endmodule

//
// state controller of the microprocessor
//
module Control (input clk, reset, output logic [1:0] State);
localparam IF = 2'b00, EX = 2'b01, RWB = 2'b10;
logic [1:0] next_State;
Dreg #(2) D3 (clk, reset, 1'b1, next_State, State);
MUX41 #(2) M1 (EX, RWB, IF, IF, State, next_State);
endmodule

//
// D register
//
module Dreg #(parameter n = 4) (input clk, reset, enable, input [n-1:0] D, output logic [n-1:0] Q);
always_ff @ (posedge clk or posedge reset)
	if (reset)
		Q <= {n{1'b0}};
	else if (enable)
		Q <= D;
endmodule

//
// 16:1 MUX
//
module MUX161 #(parameter n = 4) (input [n-1:0] A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, input [3:0] S, output logic [n-1:0] Y);
logic [n-1:0] partialMUX0, partialMUX1, partialMUX2, partialMUX3;
MUX41 #(n) M2 (A, B, C, D, S[1:0], partialMUX0);
MUX41 #(n) M3 (E, F, G, H, S[1:0], partialMUX1);
MUX41 #(n) M4 (I, J, K, L, S[1:0], partialMUX2);
MUX41 #(n) M5 (M, N, O, P, S[1:0], partialMUX3);
MUX41 #(n) M6 (partialMUX0, partialMUX1, partialMUX2, partialMUX3, S[3:2], Y);
endmodule

//
// 4:1 MUX
//
module MUX41 #(parameter n = 4) (input [n-1:0] A, B, C, D, input [1:0] S, output logic [n-1:0] Y);
always_comb begin
	Y = A;
	case (S)
		2'b00 : Y = A;
		2'b01 : Y = B;
		2'b10 : Y = C;
		2'b11 : Y = D;
		default : Y = A;
	endcase
end
endmodule

//
// hex to 7-segment display
//
module Hex7Seg (input [3:0] Hex, output logic [6:0] HexSeg);
	always_comb begin
		HexSeg = 7'd0;
		case (Hex)
//						Numbers
//				0
			4'h0 : HexSeg = 7'b100_0000;
//				1
			4'h1 : HexSeg = 7'b111_1001;
//				2
			4'h2 : HexSeg = 7'b010_0100;
//				3
			4'h3 : HexSeg = 7'b011_0000;
//				4
			4'h4 : HexSeg = 7'b001_1001;
//				5
			4'h5 : HexSeg = 7'b001_0010;
//				6
			4'h6 : HexSeg = 7'b000_0010;
//				7
			4'h7 : HexSeg = 7'b111_1000;
//				8
			4'h8 : HexSeg = 7'b000_0000;
//				9
			4'h9 : HexSeg = 7'b001_0000;
//				A
			4'hA : HexSeg = 7'b000_1000;
//				B
			4'hB : HexSeg = 7'b000_0011;
//				C
			4'hC : HexSeg = 7'b100_0110;
//				D
			4'hD : HexSeg = 7'b010_0001;
//				E
			4'hE : HexSeg = 7'b000_0110;
//				F
			4'hF : HexSeg = 7'b000_1110;
//				turn all the bits off by default
			default : HexSeg = 7'b111_1111;
		endcase
	end
endmodule

//
//ascii to 7segment display conversion
//
module ASCII27Seg(input[7:0] AsciiCode, output reg [6:0] HexSeg);
	always_comb begin
		HexSeg = 7'd0;	// initialization of HexSeg, not optional
//		$display("AsciiCode %b", AsciiCode);
		case (AsciiCode)
//				A
			8'h41 : HexSeg = 7'b000_1000;
//				a
			8'h61 : HexSeg = 7'b000_1000;
//				B
			8'h42 : HexSeg = 7'b000_0011;
//				b
			8'h62 : HexSeg = 7'b000_0011;
//				C
			8'h43 : HexSeg = 7'b100_0110;
//				c
			8'h63 : HexSeg = 7'b100_0110;
//				D
			8'h44 : HexSeg = 7'b010_0001;
//				d
			8'h64 : HexSeg = 7'b010_0001;
//				E
			8'h45 : HexSeg = 7'b000_0110;
//				e
			8'h65 : HexSeg = 7'b000_0110;
//				F
			8'h46 : HexSeg = 7'b000_1110;
//				f
			8'h66 : HexSeg = 7'b000_1110;
//				G
			8'h47 : HexSeg = 7'b001_0000;
//				g
			8'h67 : HexSeg = 7'b001_0000;
//				H
			8'h48 : HexSeg = 7'b000_1001;
//				h
			8'h68 : HexSeg = 7'b000_1001;
//				I
			8'h49 : HexSeg = 7'b100_1111;
//				i
			8'h69 : HexSeg = 7'b100_1111;
//				J
			8'h4A : HexSeg = 7'b110_0001;
//				j
			8'h6A : HexSeg = 7'b110_0001;
//				K
			8'h4B : HexSeg = 7'b000_1001;
//				k
			8'h6B : HexSeg = 7'b000_1001;
//				L
			8'h4C : HexSeg = 7'b100_0111;
//				l
			8'h6C : HexSeg = 7'b100_0111;
//				M
			8'h4D : HexSeg = 7'b110_1010;
//				m
			8'h6D : HexSeg = 7'b110_1010;
//				N
			8'h4E : HexSeg = 7'b010_1011;
//				n
			8'h6E : HexSeg = 7'b010_1011;
//				O
			8'h4F : HexSeg = 7'b100_0000;
//				o
			8'h6F : HexSeg = 7'b100_0000;
//				P
			8'h50 : HexSeg = 7'b000_1100;
//				p
			8'h70 : HexSeg = 7'b000_1100;
//				Q
			8'h51 : HexSeg = 7'b001_1000;
//				q
			8'h71 : HexSeg = 7'b001_1000;
//				R
			8'h52 : HexSeg = 7'b010_1111;
//				r
			8'h72 : HexSeg = 7'b010_1111;
//				S
			8'h53 : HexSeg = 7'b001_0010;
//				s
			8'h73 : HexSeg = 7'b001_0010;
//				T
			8'h54 : HexSeg = 7'b000_0111;
//				t
			8'h74 : HexSeg = 7'b000_0111;
//				U
			8'h55 : HexSeg = 7'b100_0001;
//				u
			8'h75 : HexSeg = 7'b100_0001;
//				V
			8'h56 : HexSeg = 7'b110_0011;
//				v
			8'h76 : HexSeg = 7'b110_0011;
//				W
			8'h57 : HexSeg = 7'b101_0101;
//				w
			8'h77 : HexSeg = 7'b101_0101;
//				X
			8'h58 : HexSeg = 7'b000_1001;
//				x
			8'h78 : HexSeg = 7'b000_1001;
//				Y
			8'h59 : HexSeg = 7'b001_0001;
//				y
			8'h79 : HexSeg = 7'b001_0001;
//				Z
			8'h5A : HexSeg = 7'b010_0100;
//				z
			8'h7A : HexSeg = 7'b010_0100;
//				0
			8'h30 : HexSeg = 7'b100_0000;
//				1
			8'h31 : HexSeg = 7'b111_1001;
//				2
			8'h32 : HexSeg = 7'b010_0100;
//				3
			8'h33 : HexSeg = 7'b011_0000;
//				4
			8'h34 : HexSeg = 7'b001_1001;
//				5
			8'h35 : HexSeg = 7'b001_0010;
//				6
			8'h36 : HexSeg = 7'b000_0010;
//				7
			8'h37 : HexSeg = 7'b111_1000;
//				8
			8'h38 : HexSeg = 7'b000_0000;
//				9
			8'h39 : HexSeg = 7'b001_0000;
//				turn all the bits off by default
			default : HexSeg = 7'b111_1111;
		endcase
	end
endmodule
