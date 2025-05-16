 module TRI_MUX(Answer,Input1,Input2,Input3,Select);
    input [31:0] Input1,Input2,Input3;
    input [1:0] Select; 

    output reg [31:0] Answer;

    always @ (Input1,Input2,Select)
    begin
        case(Select)
            00 : assign Answer = Input1;
            01 : assign Answer = Input2;
            10 : assign Answer = Input3;
            11 : assign Answer = 0b00000000;

        endcase
    end
endmodule


