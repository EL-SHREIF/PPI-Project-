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
if(RESET) begin //init chip
cwr <= 2'bzzzzzzzz;
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

module internal_bus(buffer,porta,portb,portc,ctrl_sig,A,RD,WR,RESET);
inout[7:0] buffer;
inout[7:0] porta;
inout[7:0] portb;
inout[7:0] portc;
output[7:0] ctrl_sig;
input RD,WR,RESET;
input [1:0] A;
reg[7:0] cwr;
assign porta = (~WR)?buffer:~RD?8'bzzzzzzzz:8'bzzzzzzzz;
assign portb = (~WR)?buffer:~RD?8'bzzzzzzzz:8'bzzzzzzzz;
assign portc = (~WR)?buffer:~RD?8'bzzzzzzzz:8'bzzzzzzzz;
assign ctrl_sig = cwr;
assign buffer = (~RD && A == 2'b00)?porta:(~RD && A == 2'b01)?portb:(~RD && A == 2'b10)?portc:8'bzzzzzzzz;

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
internal_bus InternalBus(internal_bus_buffer,internal_bus_porta,internal_bus_portb,internal_bus_portc,internal_bus_rwctrl,A,RD,WR,RESET);
endmodule 



module TestBench();
wire [7:0] PORTA;
wire [7:0] PORTB;
wire [7:0] PORTC;
wire [7:0] DATA;
reg CS;
reg RESET;
reg WR;
reg RD;
reg [1:0] A;
reg[7:0] dataout;
reg[7:0] aout;
reg[7:0] bout;
reg[7:0] cout;
assign DATA = (~WR && RD)?dataout:(~RD && WR)?8'bzzzzzzzz:8'bzzzzzzzz;
assign PORTA = (~RD && WR)?aout:(~WR && RD)?8'bzzzzzzzz:8'bzzzzzzzz;
assign PORTB = (~RD && WR)?bout:(~WR && RD)?8'bzzzzzzzz:8'bzzzzzzzz;
assign PORTC = (~RD && WR)?cout:(~WR && RD)?8'bzzzzzzzz:8'bzzzzzzzz;

intel8255 mychip(DATA,RD,WR,A,RESET,CS,PORTA,PORTB,PORTC);
initial begin
$monitor ($time ,,, " PORTA = %b   PORTB= %b   PORTC=%b     DATA= %b     RESET= %b    RD=%b     WR= %b      CS=%b      A=%b", PORTA,PORTB,PORTC,DATA,RESET,RD,WR,CS,A);
//RESET
A=2'b11;
WR=1;
RD=0;
RESET=1;
#5
RESET=0;
#5
//RESET
//BSR MODE
CS=0;
WR=0;
RD=1;
//Set
A=2'b11;
dataout= 8'b00000001; 
#5
A=2'b10;
#5
A=2'b11;
dataout= 8'b00000011; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00000101; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00000111; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00001001; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00001011; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00001101; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00001111; 
#5
A=2'b10;
#5
A=2'b11;
#5
//Reset
dataout= 8'b00000000; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00000010; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00000100; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00000110; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00001000; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00001010; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00001100; 
#5
A=2'b10;
#5
A=2'b11;
#5
dataout= 8'b00001110; 
#5
A=2'b10;
#5
A=2'b11;
#5
//////////////////////////////
// i/o mode
//Write on ports
//RESET
A=2'b11;
WR=1;
RD=0;
RESET=1;
#5
RESET=0;
#5
//RESET
WR=0;
RD=1;
A=2'b11;
dataout=8'b10000000; //Port A,B and C are output
#5
A=2'b00; // Data on Port A
dataout=8'b11111111;
#5
A=2'b01; // Data on Port B
dataout=8'b11111111;
#5
A=2'b10; // Data on Port C
dataout=8'b11111111;
#5
/////////Read from ports 
//RESET
A=2'b11;
WR=1;
RD=0;
RESET=1;
#5
RESET=0;
#5
//RESET
RD=1;
WR=0;
A=2'b11;
dataout=8'b10011011; //PORT A, B and C are inputs
#5
A=2'b00;
RD=0;
WR=1;
aout=13;
bout=2'b00110011;
cout=2'b01010101;
#5
A=2'b01; //Read from port B
#5
A=2'b10; //Read from port C
#5

//////////////////////////////////Special Cases
///////////////////Trying to write on ports when CS=1
CS=1;
//RESET
A=2'b11;
WR=1;
RD=0;
RESET=1;
#10
RESET=0;
#10
//RESET
//////////Write on ports
WR=0;
RD=1;
A=2'b11;
dataout=8'b10000000; //Port A,B and C are output
#5
A=2'b00; // Data on Port A
dataout=8'b11111111;
#5
A=2'b01; // Data on Port B
dataout=8'b11111111;
#5
A=2'b10; // Data on Port C
dataout=8'b11111111;
end
endmodule



