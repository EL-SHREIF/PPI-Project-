`timescale 1ns / 1ps
module ppichip(
    input CS,
    input RD,
    input WR,
    input [1:0] A,
    input reset,
    inout [7:0] PORT_A,
    inout [7:0] PORT_B,
    inout [7:0] PORT_C,
	 inout [7:0] Buffer_D
    );
//define case as the case of the port if it's 1 for input or 0 for output 
//initially they are inputs 
reg case_A=1'b1;
reg case_B=1'b1;
reg case_Cu=1'b1;//because we have 2 parts of port C
reg case_Cl=1'b1;
//define registers for each port 
reg [7:0] port_a=8'bxxxx_xxxx;
reg [7:0] port_b=8'bxxxx_xxxx;
reg [7:0] port_c=8'bxxxx_xxxx;
reg [7:0] data_bus;
reg [1:0] port;
assign data_bus = (port==2'b00)? PORT_A : (port==2'b01)? PORT_B : (port==2'b10)? PORT_C : Buffer_D;  
always@(CS,reset,RD,WR,A)
if(CS==0)//check if the chip is enabled 
begin
if (reset) // we reset all ports to be input 
begin case_A <= 1; case_B <= 1; case_Cu <= 1; case_Cl <= 1;  end
else if (RD==0) //we will read something and put it on data bus
begin
case (A)
0: port<=00;
1: port<=01;
2: port<=10;
endcase 
end
else if(WR==0)//to assign a value to output 
begin 
case (A)
0: port_a <=  Buffer_D ;
1: port_b <=  Buffer_D ;
2: port_c <=  Buffer_D ;
3://play in modes 
begin
if(Buffer_D[7]==0)//BSR mode
begin
port_c[{Buffer_D[3],Buffer_D[2],Buffer_D[1]}]<=Buffer_D[0];
case_Cu<=1'b0;
case_Cl<=1'b0;
end
if(Buffer_D[7]==1 && Buffer_D[6]==0 && Buffer_D[5]==0 && Buffer_D[2]==0)//I/O mode 
begin
if(Buffer_D[4]== 1'b0)begin case_A<=1'b0; end else begin case_A<=1'b1; end 
if(Buffer_D[3]== 1'b0)begin case_Cu<=1'b0; end else begin case_Cu<=1'b1; end 
if(Buffer_D[1]== 1'b0)begin case_B<=1'b0; end else begin case_B<=1'b1; end 
if(Buffer_D[0]== 1'b0)begin case_Cl<=1'b0; end else begin case_Cl<=1'b1; end 
end
end
endcase
end
end
assign PORT_A=(case_A==1'b1)? 8'b zzzz_zzzz : port_a;
assign PORT_B=(case_B==1'b1)? 8'b zzzz_zzzz : port_b;
assign PORT_C[7:4]=(case_Cu==1'b1)? 4'b zzzz : port_c[7:4];
assign PORT_C[3:0]=(case_Cl==1'b1)? 4'b zzzz : port_c[3:0];
assign Buffer_D =  data_bus;
endmodule
