//
// physical validation for lab5
//
module lab5_pv (input clk, SW0, SW1, KEY0, SW2, SW3, SW4, output logic [6:0] SevSeg5, SevSeg4, SevSeg3, SevSeg2, SevSeg1, SevSeg0, output logic LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7);
logic clkin, FreqDivClk, Cout, OF;
logic [1:0] State;
logic [3:0] OPCODE;
logic [6:0] SevSegOPCODE;
logic [7:0] PC, Alu_out, W_Reg;
logic [21:0] count;
logic [7:0] Name [3:0];
logic [6:0] SevSegName [3:0];
logic [6:0] SevSegPC [1:0];
logic [6:0] SevSegW [1:0];
logic [6:0] SevSegALU [1:0];
assign Name[3] = "C";
assign Name[2] = "r";
assign Name[1] = "u";
assign Name[0] = "z";
Dreg #(22) D4 (clk, SW0, 1'b1, (count == 22'd2500000)? 22'd0 : count + 22'd1, count);
Dreg #(1) D5 ((count == 22'd2500000)? 1'b1 : 1'b0, SW0, 1'b1, ~FreqDivClk, FreqDivClk);
assign clkin = (SW1 == 1'b1)? KEY0 : FreqDivClk;
lab5 L2 (clkin, SW0, OPCODE, State, PC, Alu_out, W_Reg, Cout, OF);
assign {LED7,LED6,LED5,LED4,LED3,LED2,LED1,LED0} = OPCODE;
assign SevSeg5 = ({SW4,SW3,SW2} == 3'b000)? SevSegName[3] : 7'b1111111;
assign SevSeg4 = ({SW4,SW3,SW2} == 3'b000)? SevSegName[2] : 7'b1111111;
assign SevSeg3 = ({SW4,SW3,SW2} == 3'b000)? SevSegName[1] : 7'b1111111;
assign SevSeg2 = ({SW4,SW3,SW2} == 3'b000)? SevSegName[0] : 7'b1111111;
assign SevSeg1 = ({SW4,SW3,SW2} == 3'b110)? SevSegPC[1] : ({SW4,SW3,SW2} == 3'b101)? SevSegW[1] : ({SW4,SW3,SW2} == 3'b011)? SevSegALU[1] : 7'b1111111;
assign SevSeg0 = ({SW4,SW3,SW2} == 3'b110)? SevSegPC[0] : ({SW4,SW3,SW2} == 3'b101)? SevSegW[0] : ({SW4,SW3,SW2} == 3'b011)? SevSegALU[0] : ({SW4,SW3,SW2} == 3'b111)? SevSegOPCODE : 7'b1111111;
ASCII27Seg A1 (Name[0], SevSegName[0]);
ASCII27Seg A2 (Name[1], SevSegName[1]);
ASCII27Seg A3 (Name[2], SevSegName[2]);
ASCII27Seg A4 (Name[3], SevSegName[3]);
Hex7Seg H1 (PC[7:4], SevSegPC[1]);
Hex7Seg H2 (PC[3:0], SevSegPC[0]);
Hex7Seg H3 (W_Reg[7:4], SevSegW[1]);
Hex7Seg H4 (W_Reg[3:0], SevSegW[0]);
Hex7Seg H5 (Alu_out[7:4], SevSegALU[1]);
Hex7Seg H6 (Alu_out[3:0], SevSegALU[0]);
Hex7Seg H7 (OPCODE, SevSegOPCODE);
endmodule
