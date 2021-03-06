module processor;
reg [31:0] pc; //32-bit program counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [31:0] 
dataa,		//Read data 1 output of Register File
datab,		//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
out5,		// jump control
out6,		//jr_control 
out7,		// if it is jal operation pc + 4  should be stored in ra register
sum,		//ALU result
extad,		//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,		//Output of shift left 2 unit
jump_address;	//jump address



wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1,		//Write data input of Register File
register_writer; // writer pc or register address

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [3:0] is_R_type;	//r type [3:0]
wire [3:0] is_I_type;	//I type [29:26]
wire [3:0] selected_type; //control via mult 

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [31:0] jump_location;	//Jump address
wire [3:0] gout;	//Output of ALU control unit

wire zout,	//Zero output of ALU
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
bgez_or_bltz, //Decides between bgez or BLTZ because 
//Control signals
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0,jr_control,immidiate_op,jump,jal_control;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];

 assign jump_location[25:0]=instruc[25:0]; // first 26 bit show jump addres + 4 pc + 2 shift
 assign jump_location[26]=0;
 assign jump_location[27]=0;
 assign jump_location[28]=0;
 assign jump_location[29]=0;
 
 assign is_I_type = instruc[29:26];//function code
 assign is_R_type = instruc[3:0];  // least significand four bit, 31-30 fixed

 assign bgez_or_bltz=instruc[16]; //only difference between bgez and bgtz is 16th bit

// registers

assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2
always @(posedge clk)
 registerfile[register_writer]= regwrite ? out3:registerfile[register_writer];//Write data to register

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]}; //big endian format


wire [4:0] ra; // special purpose register
assign ra = 5'b11111;
//multiplexers
//mux with RegDst control
mult2_to_1_5 mult1(out1, instruc[20:16],instruc[15:11],regdest);

//find the address

mult2_to_1_5 mult5(register_writer, out1, ra, jal_control); 

//mux with immidiate_op
mult2_to_1_32 mult2(out2, datab,extad,immidiate_op);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);

//type selection
mult2_to_1_4 mult6(selected_type, is_I_type, is_R_type, regdest); 

//jump control 
mult2_to_1_32 mult7(out5,out4,jump_address,jump);

//jr control 
mult2_to_1_32 mult8(out6,out5,dataa,jr_control);

//jal_control 
mult2_to_1_32 mult9(out7,dataa,pc+4,jal_control);

// load pc
always @(posedge clk)
pc=out6;

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,out7,out2,zout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,immidiate_op,jump,jal_control);

//Sign extend unit
signext sext(instruc[15:0],extad);

//ALU control unit
alucont acont(aluop1,aluop0,selected_type[3],selected_type[2], selected_type[1], selected_type[0] ,gout, bgez_or_bltz);

//Shift-left 2 unit
shift shift2(sextad,extad);

//Shift-left 
shift shift3(jump_address,jump_location);
assign jump_address[31:28] = adder1out[31:28];

//AND gate
assign pcsrc=branch && zout; 
assign jr_control=regdest && (instruc[3]&~(instruc[0]|instruc[1]|instruc[2]|instruc[4]|instruc[5]));
//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM3.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#480 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule


