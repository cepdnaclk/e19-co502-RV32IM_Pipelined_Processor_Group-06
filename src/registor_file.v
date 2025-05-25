`timescale 1ns/1ps

module reg_file(IN,OUT1,OUT2,ADDR1,ADDR2,ADDRW,WRITE,CLK,RESET); 
    //declare inputs
	input [4:0] ADDR1,ADDR2,ADDRW;
	/*INADDRESS: range is 0-31 so 5 bit use
	OUT1ADDRESS&OUT2ADDRESS : range is 0-7 so 3bits use*/
	input [31:0] IN;//8bit input
    input WRITE,CLK,RESET;
	//declare outputs
	output [31:0] OUT1,OUT2;
    reg [31:0] REGISTERARRAY[31:0];//make a 8x8 register array
	/*REGISTERARRAY[x]->xth Array of a 8 registers (8bit memory location)
	Therefore channging the value x can acces 8bit memoary 
	for store data or load the data in that location*/ 
    integer bit;//for to use to increment in for loop
    assign #2 OUT1 = REGISTERARRAY[ADDR1]; //data in location out1address value assign to out1
	assign #2 OUT2 = REGISTERARRAY[ADDR2]; //data in location out2address value assign to out2
    //checking signal when positive clock edge and repond to write and read signals
	always @(posedge CLK) 
	begin
		//when write signal is high
		if (WRITE==1) begin 
			#1 REGISTERARRAY[ADDRW] = IN;//store the in value to suitable register
		end
		//when Reset signal high
		else if(RESET==1) begin 
			#1 for(bit=0 ; bit<32 ; bit++) begin 
				//all register values turn to 0
				REGISTERARRAY[bit]=0;
			end //end for loop
		end	
	end
endmodule