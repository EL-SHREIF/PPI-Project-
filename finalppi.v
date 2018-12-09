`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:06:43 11/28/2018 
// Design Name: 
// Module Name:    finalppi 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
/*Input portd output internal_bus at low rw_ctrl_logic
output portd and input internal_bus at high rw_ctrl_logic*/
module data_bus_buffer(portd,rw_ctrl_logic,internal_bus);
inout[7:0] portd;
inout[7:0]internal_bus;
input rw_ctrl_logic;
reg[7:0] out;
assign portd = rw_ctrl_logic?out:8'bzzzzzzzz;
assign internal_bus = rw_ctrl_logic?8'bzzzzzzzz:portd;
always@(*) begin
if (rw_ctrl_logic) begin
out <= internal_bus;
end
end
endmodule
 
module read_write_ctrl_logic(ctrl_sig,RD,WR,A,RESET,CS,rw_ctrl_dbuffer,porta,portb,portc);
input RD,WR,RESET,CS;
input[1:0] A;
input[7:0] ctrl_sig;
output rw_ctrl_dbuffer;
output[1:0] porta,portc,portb;
reg[7:0] cwr;
reg[1:0] rega,regb,regc;
reg regbuff;
 
assign rw_ctrl_dbuffer = regbuff;
assign porta = rega;
assign portb = regb;
assign portc = regc;
 
always@(*) begin
if(RESET && ~CS) begin //init chip
cwr <= 8'bzzzzzzzz;
rega<=2'b11;
regb<=2'b11;
regc<=2'b11;
end
if(~CS && ~RESET) begin //Chips is selected
if(A==2'b11) begin
regbuff <= 0;
cwr<=ctrl_sig;
//BSR MODE DETECTION
////////////////////////////////////
if(cwr[7] === 0) begin //BSR
regc<=2'b10; //bsr_sig
rega<=2'b11;regb<=2'b11; //disable
end
////////////////////////////
end
if(cwr[7] === 1) begin
case(A)
2'b00 : begin //PORTA Selected
if(cwr[4]) begin rega<=2'b00;regbuff<=1; end //Input
else if (~cwr[4]) begin rega<=2'b01;regbuff<=0; end //Output
 
end
2'b01 : begin //PORTB Selected
if(cwr[1]) begin regb<=2'b00;regbuff<=1; end //Input
else if (~cwr[1]) begin regb<=2'b01;regbuff<=0; end //Output
 
end
2'b10 : begin //PORTC Selected
if(cwr[0] && cwr[3]) begin regc<=2'b00;regbuff<=1; end //Input
else if (~cwr[0] && ~cwr[3]) begin regc<=2'b01;regbuff<=0; end //Output
 
end
endcase
end
end //Chip if end
end //always end
endmodule
 
module PORTA(rw_ctrl_logic,porta,internal_bus,A);
inout[7:0] porta;
inout[7:0] internal_bus;
input[1:0] rw_ctrl_logic;
reg[7:0] out;
input[1:0] A;
assign porta = (rw_ctrl_logic == 2'b01)?out:8'bzzzzzzzz;
assign internal_bus = (rw_ctrl_logic == 2'b01)?8'bzzzzzzzz:porta;
always@(*) begin
if (rw_ctrl_logic == 2'b01 && A==2'b00) begin
out <= internal_bus ;
end
end
endmodule
 
module PORTB(rw_ctrl_logic,portb,internal_bus,A);
inout[7:0] portb;
inout[7:0] internal_bus;
input[1:0] rw_ctrl_logic;
reg[7:0] out;
input[1:0] A;
assign portb = (rw_ctrl_logic == 2'b01)?out:8'bzzzzzzzz;
assign internal_bus = (rw_ctrl_logic == 2'b01)?8'bzzzzzzzz:portb;
always@(*) begin
if (rw_ctrl_logic == 2'b01 && A==2'b01) begin
out <= internal_bus ;
end
end
endmodule
 
module PORTC(rw_ctrl_logic,portc,internal_bus,A);
inout[7:0] portc;
inout[7:0] internal_bus;
input[1:0] rw_ctrl_logic;
reg[7:0] out;
input[1:0] A;
assign portc = (rw_ctrl_logic == 2'b01 || rw_ctrl_logic == 2'b10)?out:8'bzzzzzzzz;
assign internal_bus = (rw_ctrl_logic == 2'b01 || rw_ctrl_logic == 2'b10)?8'bzzzzzzzz:portc;
always@(*) begin
if (rw_ctrl_logic == 2'b01 && A==2'b10) begin
out <= internal_bus;
end
else if (rw_ctrl_logic == 2'b10 && A==2'b10) begin
case(internal_bus[3:1])
0: out[0] <= internal_bus[0];
1: out[1] <= internal_bus[0];
2: out[2] <= internal_bus[0];
3: out[3] <= internal_bus[0];
4: out[4] <= internal_bus[0];
5: out[5] <= internal_bus[0];
6: out[6] <= internal_bus[0];
7: out[7] <= internal_bus[0];
endcase
end
end
endmodule
 
module internal_bus(buffer,porta,portb,portc,ctrl_sig,A,RD,WR,CS);
inout[7:0] buffer;
inout[7:0] porta;
inout[7:0] portb;
inout[7:0] portc;
output[7:0] ctrl_sig;
input RD,WR,CS;
input [1:0] A;
reg[7:0] cwr;
assign porta = CS?8'bzzzzzzzz:(~WR)?buffer:~RD?8'bzzzzzzzz:8'bzzzzzzzz;
assign portb = CS?8'bzzzzzzzz:(~WR)?buffer:~RD?8'bzzzzzzzz:8'bzzzzzzzz;
assign portc = CS?8'bzzzzzzzz:(~WR)?buffer:~RD?8'bzzzzzzzz:8'bzzzzzzzz;
assign ctrl_sig = cwr;
assign buffer = CS?8'bzzzzzzzz:(~RD && A == 2'b00)?porta:(~RD && A == 2'b01)?portb:(~RD && A == 2'b10)?portc:8'bzzzzzzzz;
 
always@(*) begin
if(A == 2'b11 && ~WR && RD) begin
cwr = buffer;
end
end
endmodule
 
module intel8255(PORTD,RD,WR,A,RESET,CS,PORTA,PORTB,PORTC);
inout[7:0] PORTD;
inout[7:0] PORTA;
inout[7:0] PORTB;
inout[7:0] PORTC;
input RD,WR,RESET,CS;
input [1:0] A;
wire rw_ctrl_logic;
wire[1:0] rw_ctrl_porta,rw_ctrl_portb,rw_ctrl_portc;
wire[7:0] internal_bus_buffer,internal_bus_rwctrl,internal_bus_porta,internal_bus_portb,internal_bus_portc;
 
 
data_bus_buffer DataBusBuffer(PORTD,rw_ctrl_logic,internal_bus_buffer);
read_write_ctrl_logic ReadWriteControlLogic(internal_bus_rwctrl,RD,WR,A,RESET,CS,rw_ctrl_logic,rw_ctrl_porta,rw_ctrl_portb,rw_ctrl_portc);
PORTA portA(rw_ctrl_porta,PORTA,internal_bus_porta,A);
PORTB portB(rw_ctrl_portb,PORTB,internal_bus_portb,A);
PORTC portC(rw_ctrl_portc,PORTC,internal_bus_portc,A);
internal_bus InternalBus(internal_bus_buffer,internal_bus_porta,internal_bus_portb,internal_bus_portc,internal_bus_rwctrl,A,RD,WR,CS);
endmodule