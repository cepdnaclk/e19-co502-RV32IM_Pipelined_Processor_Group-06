`timescale 1ns / 1ps

// Define a module called "DATA_MEMORY"
module DATA_MEMORY (CLK, RESET, WRITE, READ, ADDR, DATA_IN, DATA_OUT);

    // Inputs and Outputs
    input CLK;
    input RESET;
    input [1:0] WRITE, READ;
    input [31:0] ADDR, DATA_IN;
    output reg [31:0] DATA_OUT;

    reg [31:0] mem [0:1023];  // 4KB word-addressable memory
    integer i;

    // Write Operation
    always @(posedge CLK) begin
        if (!RESET) begin  // Fixed: Active low reset logic
            case (WRITE)
                2'b01: begin  // Byte write
                    case (ADDR[1:0])
                        2'b00: mem[ADDR[11:2]][7:0]   <= DATA_IN[7:0];
                        2'b01: mem[ADDR[11:2]][15:8]  <= DATA_IN[7:0];
                        2'b10: mem[ADDR[11:2]][23:16] <= DATA_IN[7:0];
                        2'b11: mem[ADDR[11:2]][31:24] <= DATA_IN[7:0];
                    endcase
                end
                2'b10: begin  // Half-word write
                    if (ADDR[0] == 1'b0) begin  // Half-word aligned
                        case (ADDR[1])
                            1'b0: mem[ADDR[11:2]][15:0]  <= DATA_IN[15:0];
                            1'b1: mem[ADDR[11:2]][31:16] <= DATA_IN[15:0];
                        endcase
                    end
                end
                2'b11: begin  // Word write
                    if (ADDR[1:0] == 2'b00) begin  // Word aligned
                        mem[ADDR[11:2]] <= DATA_IN;
                    end
                end
            endcase
        end
    end

    // Read Operation
    always @(*) begin
        if (RESET) begin
            for (i=0; i<256; i=i+1)
                mem[i] = 32'b0;
            DATA_OUT = 32'd0;
        end else begin
            case (READ)
                2'b01: begin  // Byte read
                    case (ADDR[1:0])
                        2'b00: DATA_OUT = {24'b0, mem[ADDR[11:2]][7:0]};
                        2'b01: DATA_OUT = {24'b0, mem[ADDR[11:2]][15:8]};
                        2'b10: DATA_OUT = {24'b0, mem[ADDR[11:2]][23:16]};
                        2'b11: DATA_OUT = {24'b0, mem[ADDR[11:2]][31:24]};
                    endcase
                end
                2'b10: begin  // Half-word read
                    if (ADDR[0] == 1'b0) begin
                        case (ADDR[1])
                            1'b0: DATA_OUT = {16'b0, mem[ADDR[11:2]][15:0]};
                            1'b1: DATA_OUT = {16'b0, mem[ADDR[11:2]][31:16]};
                        endcase
                    end else begin
                        DATA_OUT = 32'd0;
                    end
                end
                2'b11: begin  // Word read
                    if (ADDR[1:0] == 2'b00) begin
                        DATA_OUT = mem[ADDR[11:2]];
                    end else begin
                        DATA_OUT = 32'd0;
                    end
                end
                default: DATA_OUT = 32'd0;
            endcase
        end
    end

    // Initialize memory for testing
    initial begin
        mem[0] = 32'h00000000;
        mem[1] = 32'h12345678;
        mem[2] = 32'hABCDEF00;
        mem[3] = 32'hDEADBEEF;
        mem[4] = 32'hCAFEBABE;
    end

endmodule
