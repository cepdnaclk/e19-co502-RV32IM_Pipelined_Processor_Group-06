 module MUX(Answer,Input1,Input2,Select);
    input [31:0] Input1,Input2;
    input Select; 

    output reg [31:0] Answer;

    always @ (Input1,Input2,Select)
    begin
        case(Select)
            0 : assign Answer = Input1;
            1 : assign Answer = Input2;
        endcase
    end
endmodule


