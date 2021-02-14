module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,immidiate_op,jump_control,jal_control);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,immidiate_op,jump_control,jal_control;
wire rformat,lw,sw,beq,isbranch;
assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign isbranch=~in[5]&~in[4]&~in[3]&(in[2]|in[1]|in[0]); 
assign immidiate_op=in[3]&~(in[5]&in[4]&in[2]&in[1]&in[0]);// third bit contol
assign jump_control=(~(in[5]|in[4]|in[3]|in[2]|in[0])&in[1])|((~(in[5]|in[4]|in[3]|in[2]))&in[1]&in[0]); // jump and jal op gives 1
assign jal_control=((~(in[5]|in[4]|in[3]|in[2]))&in[1]&in[0]); //000011
assign regdest=rformat;
assign alusrc=lw|sw;
assign memtoreg=lw;
assign regwrite=(rformat|immidiate_op|jal_control|lw)&~sw;
assign memread=lw;
assign memwrite=sw;
assign branch=isbranch;
assign aluop1=rformat;
assign aluop2=beq;
endmodule
