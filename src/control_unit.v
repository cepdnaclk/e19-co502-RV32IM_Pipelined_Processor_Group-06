`timescale 1ns / 1ps
// module for the control unit
module CONTROL_UNIT(INSTRUCTION, ALUOP, IMME_SELECT, MUX1_SELECT, MUX2_SELECT, BR_SEL, WRITEENABLE, MEM_READ, MEM_WRITE);


    // Inputs
    // INSTRUCTION: 32-bit instruction word
    
    // Outputs
    // ALUOP: 5-bit signal to control the ALU operation
    // MUX3_SELECT: 2-bit signal to select input for MUX3
    // IMME_SELECT: 3-bit signal to select type of immediate value
    // MUX1_SELECT: 1-bit signal to select input for MUX1
    // MUX2_SELECT: 1-bit signal to select input for MUX2
    // MUX4_SELECT: 1-bit signal to select input for MUX4
    // MEMREAD: 1-bit signal to enable memory read
    // MEMWRITE: 1-bit signal to enable memory write
    // BRANCH: 1-bit signal to enable branching
    // JUMP: 1-bit signal to enable jumping
    // WRITEENABLE: 1-bit signal to enable register writeback

    input [31:0] INSTRUCTION;
    output reg[4:0] ALUOP;
    output reg [2:0] IMME_SELECT;
    output reg MUX1_SELECT, MUX2_SELECT,WRITEENABLE;
    output reg [2:0] BR_SEL;
    //wire [6:0] opcode = INSTRUCTION[6:0];
    //wire [2:0] funct3 = INSTRUCTION[14:12];
    //wire [6:0] funct7 = INSTRUCTION[31:25];
    output reg [1:0] MEM_WRITE,MEM_READ;
    

// Assign signals from instruction word
    wire [6:0] OPCODE = INSTRUCTION[6:0];
    wire [2:0] FUNCTION3 = INSTRUCTION[14:12];
    wire [6:0] FUNCTION7 = INSTRUCTION[31:25];

    
   always @(OPCODE, FUNCTION3, FUNCTION7) begin
        case(OPCODE)
            7'b0110011:begin #1
                IMME_SELECT = 3'bxxx;
                MUX1_SELECT = 1'b0;
                MUX2_SELECT = 1'b0;
                WRITEENABLE = 1'b1;
                MEM_READ = 2'b00;
                MEM_WRITE = 2'b00;
                BR_SEL = 3'b000; 

               case({FUNCTION7, FUNCTION3})
                    10'b0000000000: ALUOP = 5'b00001;      //ADD   
                    10'b0100000000: ALUOP = 5'b00010;      //SUB       
                    10'b0000000001: ALUOP = 5'b00011;      //SLL     
                    10'b0000000010: ALUOP = 5'b00100;      //SLT    
                    10'b0000000011: ALUOP = 5'b00101;      //SLTU        
                    10'b0000000100: ALUOP = 5'b00110;      //XOR          
                    10'b0000000101: ALUOP = 5'b00111;      //SRL     
                    10'b0100000101: ALUOP = 5'b01000;      //SRA     
                    10'b0000000110: ALUOP = 5'b01001;      //OR         
                    10'b0000000111: ALUOP = 5'b01010;      //AND     
                    10'b0000001000: ALUOP = 5'b01011;      //MUL     
                    10'b0000001001: ALUOP = 5'b01100;      //MULH          
                    10'b0000001010: ALUOP = 5'b01101;      //MULHSU   
                    10'b0000001011: ALUOP = 5'b01110;      //MULHU           
                    10'b0000001100: ALUOP = 5'b01111;      //DIV      
                    10'b0000001101: ALUOP = 5'b10000;      //DIVU          
                    10'b0000001110: ALUOP = 5'b10001;      //REM        
                    10'b0000001111: ALUOP = 5'b10010;      //REMU   
            endcase 
            end

        endcase
    
   end


endmodule
