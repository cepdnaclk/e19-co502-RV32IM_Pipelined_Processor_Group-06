module INSTRUCTION_MEMORY(CLOCK, READ, BLOCK_ADDRESS, READ_INST, BUSYWAIT);

input CLOCK, READ;
input [27:0] BLOCK_ADDRESS;
output reg[127:0] READ_INST;
output reg BUSYWAIT;

reg READACCESS;

// declare memory array of 1024 bytes
reg [7:0] MEM_ARRAY [1023:0];

//Initialize instruction memory
initial
begin
	BUSYWAIT = 0;
	READACCESS = 0;
	// $readmemb("instr_mem.mem", MEM_ARRAY);      // LOAD instructions from instr_mem.mem file
    
    // Sample program given below. You may hardcode your software program here, or load it from a file:
         {MEM_ARRAY[32'd03], MEM_ARRAY[32'd02], MEM_ARRAY[32'd01], MEM_ARRAY[32'd00]} <= 32'b10001111000100001000000010010011;           
         {MEM_ARRAY[32'd07], MEM_ARRAY[32'd06], MEM_ARRAY[32'd05], MEM_ARRAY[32'd04]} <= 32'b00000000000000000000000000000000;           
         {MEM_ARRAY[32'd11], MEM_ARRAY[32'd10], MEM_ARRAY[32'd09], MEM_ARRAY[32'd08]} <= 32'b00000000000000000000000000000000;         
         {MEM_ARRAY[32'd15], MEM_ARRAY[32'd14], MEM_ARRAY[32'd13], MEM_ARRAY[32'd12]} <= 32'b00000000000000001111011000010011;       
         {MEM_ARRAY[32'd19], MEM_ARRAY[32'd18], MEM_ARRAY[32'd17], MEM_ARRAY[32'd16]} <= 32'b00000000000000000000000000000000;       
         {MEM_ARRAY[32'd23], MEM_ARRAY[32'd22], MEM_ARRAY[32'd21], MEM_ARRAY[32'd20]} <= 32'b00000000000000000000000000000000;       
         {MEM_ARRAY[32'd27], MEM_ARRAY[32'd26], MEM_ARRAY[32'd25], MEM_ARRAY[32'd24]} <= 32'b00000000000101100000000010100011;       
         {MEM_ARRAY[32'd31], MEM_ARRAY[32'd30], MEM_ARRAY[32'd29], MEM_ARRAY[32'd28]} <= 32'b00000000000000000000000000000000;      
         {MEM_ARRAY[32'd35], MEM_ARRAY[32'd34], MEM_ARRAY[32'd33], MEM_ARRAY[32'd32]} <= 32'b00000000000000000000000000000000;
         {MEM_ARRAY[32'd39], MEM_ARRAY[32'd38], MEM_ARRAY[32'd37], MEM_ARRAY[32'd36]} <= 32'b11110010001101100000000100000011;
         {MEM_ARRAY[32'd43], MEM_ARRAY[32'd42], MEM_ARRAY[32'd41], MEM_ARRAY[32'd40]} <= 32'b00000000000000000000000000000000;
         {MEM_ARRAY[32'd47], MEM_ARRAY[32'd46], MEM_ARRAY[32'd45], MEM_ARRAY[32'd44]} <= 32'b11110010110000001010000110100011;
         {MEM_ARRAY[32'd51], MEM_ARRAY[32'd50], MEM_ARRAY[32'd49], MEM_ARRAY[32'd48]} <= 32'b11110010001100001010011010000011;
         {MEM_ARRAY[32'd55], MEM_ARRAY[32'd54], MEM_ARRAY[32'd53], MEM_ARRAY[32'd52]} <= 32'b00000000000000000000000000000000;
         {MEM_ARRAY[32'd59], MEM_ARRAY[32'd58], MEM_ARRAY[32'd57], MEM_ARRAY[32'd56]} <= 32'b00000000000000000000000000000000;
         {MEM_ARRAY[32'd63], MEM_ARRAY[32'd62], MEM_ARRAY[32'd61], MEM_ARRAY[32'd60]} <= 32'b11110010110100001010000110100011;

end

//Detecting an incoming memory access
always @(READ)
begin
    BUSYWAIT = (READ)? 1 : 0;
    READACCESS = (READ)? 1 : 0;
end

// reading the memory block from the memory 
always @(posedge CLOCK ) begin
    if (READACCESS) begin
        READ_INST[7:0]      = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b0000}];    // convert byte address into block
        READ_INST[15:8]     = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b0001}];
        READ_INST[23:16]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b0010}];
        READ_INST[31:24]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b0011}];
        READ_INST[39:32]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b0100}];
        READ_INST[47:40]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b0101}];
        READ_INST[55:48]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b0110}];
        READ_INST[63:56]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b0111}];
        READ_INST[71:64]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b1000}];
        READ_INST[79:72]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b1001}];
        READ_INST[87:80]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b1010}];
        READ_INST[95:88]    = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b1011}];
        READ_INST[103:96]   = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b1100}];
        READ_INST[111:104]  = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b1101}];
        READ_INST[119:112]  = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b1110}];
        READ_INST[127:120]  = #40 MEM_ARRAY[{BLOCK_ADDRESS,4'b1111}];

        BUSYWAIT = 0;                      // set the busywait and readaccess to low
        READACCESS = 0;
    end
end

endmodule