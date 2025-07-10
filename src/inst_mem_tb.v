`timescale 1ns/1ps

module inst_mem_tb();
    reg CLK,rst;
    reg [31:0] A;
    wire [31:0] RD;

    INSTRUCTION_MEMORY instr_mem (
        .CLK(CLK),
        .rst(rst),
        .A(A),
        .RD(RD)
    );

     initial begin
        $display("reset|A|RD");
        $monitor("%0t | %h | %h|%h ", 
            $time, rst,A,RD);

        A = 32'h00000000;
        #100;
        A = 32'h00000001; 

        $finish;
    end

endmodule
