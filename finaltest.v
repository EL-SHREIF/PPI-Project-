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