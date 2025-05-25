`timescale 1ps/1ps

module INSTRUCTION_MEMORY(CLK,rst,A,RD);

  input CLK,rst;
  input [31:0]A;
  output [31:0]RD;

  reg [31:0] mem [1023:0];
  
//   assign RD = (rst == 1'b0) ? {32{1'b0}} : mem[A[31:2]];
  assign RD = mem[A[31:0]];
  // always @ (posedge CLK) begin
  //       if (~rst)
  //           assign RD = mem[A[31:2]];
  // end

  initial begin
    $readmemh("memfile.hex",mem);
  end

  initial begin
    mem[0] = 32'h00C4A303;
    mem[1] = 32'h00832383;
    // mem[0] = 32'h0064A423;
    // mem[1] = 32'h00B62423;
    // mem[0] = 32'h0062E233;
    // mem[1] = 32'h00B62423;

  end

endmodule