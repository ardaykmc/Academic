module alucont(aluop1,aluop0,f3,f2,f1,f0,gout,bgez_or_bltz);//Figure 4.12 
input aluop1,aluop0,f3,f2,f1,f0,bgez_or_bltz;
output [3:0] gout;
reg [3:0] gout;
always @(aluop1 or aluop0 or f3 or f2 or f1 or f0 or bgez_or_bltz)
begin
if(~(aluop1|aluop0))gout=4'b0010;//changed
if(aluop0)gout=4'b0110;
if(aluop1)//R-type
begin
	if (~(f3|f2|f1|f0))gout=4'b0010; 	 //function code=0000,ALU control=0010 (add)
	if (f1&f3)gout=4'b0111;			 //function code=1x1x,ALU control=0111 (set on less than)
	if (f1&~(f3))gout=4'b0110;		 //function code=0x10,ALU control=0110 (sub)
	if (f2&f0)gout=4'b0001;			 //function code=x1x1,ALU control=0001 (or)
	if (f2&~(f0))gout=4'b0000;		 //function code=x1x0,ALU control=0000 (and)
	if (~f3&f2&f1&f0)gout=4'b1100;	         //function code=0111,ALU control=1100 (nor)
end
if(~(aluop1|aluop0))//I-type
begin
	if(f3&~(f2|f1|f0))gout=4'b0010;		 //function code=1000,ALU control=0010 (addi)
	if(f3&f2&~(f2|f1))gout=4'b0000;		 //function code=1100,ALU control=0000 (andi)
	if(f3&f2&~f1&f0)gout=4'b0001;		 //function code=1101,ALU control=0001 (ori)
	if(~(f3|f1)&f2&f0)gout=4'b1000;		 //funciton code=0101,ALU control=1000 (bne)
	if(~(f3|f2|f1)&f0&bgez_or_bltz)gout=4'b1001; //function code=0001,ALU control=1001 (bgez)
	if(~(f3|f0)&f2&f1)gout=4'b1101;		 //function code=0110,ALU control=1101 (blez)
	if(~f3&f2&f1&f0)gout=4'b1011;            //function code=0111,ALU control=1011 (bgtz)
	if(~(f3|f2|f1)&f0&~bgez_or_bltz)gout=4'b1110;//function code=0001,ALU control=1110 (bltz)
end
if((~(aluop1|aluop0|f3|f2))&f1&f0)gout=4'b1111;	 //JAL Control

end
endmodule
