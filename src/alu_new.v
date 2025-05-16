module ALU(DATA1, DATA2, RESULT, SELECT, EQUAL, SIGNEDLT, UNSIGNEDLT);
    input[31:0] DATA1, DATA2;   // defining variables to get the input values
    input[4:0] SELECT;          // variable to store the ALU opcode
    output reg[31:0] RESULT;    // variable to store the result of the ALU
    output EQUAL, SIGNEDLT, UNSIGNEDLT; // defining output signals

// defining variables to store the results of each airthmatic operation
    wire[31:0]  AND_RES,    // and operation
                OR_RES,     // or operation
                XOR_RES,    // xor operation 
                ADD_RES,    // addition operation
                SUB_RES,    // subtraction
                SLL_RES,    // shift left logical
                SRL_RES,    // shift right logical
                SRA_RES,    // shift right airthmatic
                FWD_RES,    // forward operation
                MUL_RES,    // multiplication
                MULH_RES,   // multiplication higher signed * signed
                MULHU_RES,  // multiplication higher unsigned * unsigned
                MULHSU_RES, // multiplication higher signed * unsigned
                DIV_RES,    // division
                DIVU_RES,       // unsigned division
                REM_RES,    // signed remainder
                REMU_RES,    // unsigned remainder
                SLT_RES,    // less than
                SLTU_RES;   // less than unsigned

    wire [63:0] MULTIPICATION; 

    // operating bitwise operations with 3 time unit delay

    //R type instructions
    assign  #1 AND_RES = DATA1 & DATA2;
    assign  #1 OR_RES = DATA1 | DATA2;
    assign  #1 XOR_RES = DATA1 ^ DATA2;
    assign  #2 ADD_RES = DATA1 + DATA2;
    assign  #2 SUB_RES = DATA1 - DATA2;

    // forwading operation
    assign  #3 FWD_RES = DATA2;
    

    // shift operations
    assign  #1 SLL_RES = DATA1 << DATA2;
    assign  #1 SRL_RES = DATA1 >> DATA2;
    assign  #1 SRA_RES = DATA1 >>> DATA2;

    // multipication operation
    assign  #3 MUL_RES = DATA1 * DATA2;
    //assign  MULTIPICATION = DATA1 * DATA2; // FOR A RESULT OF UPPER 32 BITS
    assign  #3 MULH_RES = $signed(DATA1) * $signed(DATA2);
    assign  #3 MULHU_RES = $unsigned(DATA1) * $unsigned(DATA2);
    assign  #3 MULHSU_RES = $signed(DATA1) * $unsigned(DATA2);

    // division operation
    assign  #3 DIV_RES = DATA1 / DATA2;
    assign  #3 DIVU_RES = $unsigned(DATA1) / $unsigned(DATA2);


    // remainder operations
    assign  #3 REM_RES = $signed(DATA1) % $signed(DATA2);
    assign  #3 REMU_RES = $unsigned(DATA1) % $unsigned(DATA2);

    // set the output value according to the comparison of DATA1 and DATA2
    assign  #1 SLT_RES = ($signed(DATA1) < $signed(DATA2)) ? 32'd1 : 32'd0;
    assign  #1 SLTU_RES = ($unsigned(DATA1) < $unsigned(DATA2)) ? 32'd1 : 32'd0;


    always@(*)
    begin
        case(SELECT)
        5'b00000: RESULT = FWD_RES;  
        5'b00001: RESULT = ADD_RES; 
        5'b00010: RESULT = SUB_RES; 
        5'b00011: RESULT = SLL_RES;
        5'b00100: RESULT = SLT_RES;
        5'b00101: RESULT = SLTU_RES;
        5'b00110: RESULT = XOR_RES;
        5'b00111: RESULT = SRL_RES;
        5'b01000: RESULT = SRA_RES;
        5'b01001: RESULT = OR_RES;
        5'b01010: RESULT = AND_RES;
        5'b01011: RESULT = MUL_RES;
        5'b01100: RESULT = MULH_RES;
        5'b01101: RESULT = MULHSU_RES;
        5'b01110: RESULT = MULHU_RES;
        5'b01111: RESULT = DIV_RES;
        5'b10000: RESULT = DIVU_RES;
        5'b10001: RESULT = REM_RES;
        5'b10010: RESULT = REMU_RES;
        default:RESULT = 31'd0;
    endcase
    end

    assign EQUAL = ~(|RESULT);      // DATA1 == DATA2
    assign SIGNEDLT = RESULT[31];   // DATA1 < DATA2
    assign UNSIGNEDLT= SLTU_RES[0]; // |DATA1| < |DATA2|

endmodule

