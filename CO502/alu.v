module alu(DATA1,DATA2,SELECT,RESULT);//module declaration
    input[31:0] DATA1,DATA2;//set 2 8bit inputs data1&data2
    input[4:0] SELECT;//set select as input with 3bit 
    /*The alu operation was selected by this SELECT input value
      000->loadi,mov
      001->add,sub
      010->and
      011->or
      1XX->reserved*/
    output reg[31:0] RESULT;//set 8bit output
    wire [31:0] FORW, ADS , ANS, ORR , Res;//set 8bit outputs for sub modules and for the  reserved one
    /*This alu consist 4 operations for efficency all 4 operations are done in separate 4 modules 
    in same time.Then the RESULT value is assign only one output of that 4 opetrations which suitable to the 
    SELECT signal*/
    //calling sub modules
    FOWARD foward_1(DATA1,DATA2,FORW);
    ADds add_1(DATA1,DATA2,ADS);
    ANds and_1(DATA1,DATA2,ANS);
    ORr or_1(DATA1,DATA2,ORR);
    
    //choosing the correct output respective to SELECT signal
    always @ (SELECT or DATA1 or DATA2)
    begin 
      if(SELECT==3'b000)begin
           assign RESULT=FORW;//for SELECT is 000 RESULT = DATA2
        end
        else if(SELECT==3'b001)begin
           assign RESULT=ADS;//for SELECT is 001 RESULT = DATA1+DATA2
        end
        else if(SELECT==3'b010)begin
           assign RESULT=ANS;//for SELECT is 010 RESULT= DATA1 & DATA2
        end
        else if(SELECT==3'b011)begin
           assign RESULT=ORR;//for SELECT is 011 RESULT = DATA1 | DATA2
        end
        //else condition is not implement to manage the 1XX input combinations 
    end    
endmodule 

module FOWARD(Da1,Da2,Rslt);//SUB MODULE OF ALU:MOVE DATA2 VALUE TO THE RESULT
    input [7:0] Da1,Da2;
    output [7:0] Rslt;
    assign #1 Rslt=Da2;//assign result(FROW) as data2
endmodule

module ADds(Da1,Da2,Rslt);//SUB MODULE OF ALU:ADD DATA1 VALUE AND DATA2 VALUE
    input [7:0]Da1,Da2;
    output [7:0] Rslt;
    assign #2 Rslt=Da1+Da2;//assign result(ADS) as data1 + data2
endmodule

module ANds(Da1,Da2,Rslt);//SUB MODULE OF ALU:DO AND OPERATION WITH VALUES OF DATA1 AND DATA2
    input [7:0]Da1,Da2;
    output [7:0] Rslt;
    assign #1 Rslt=Da1&Da2;//assign result(ANS) of and operation with data1 & data2
endmodule

module ORr(Da1,Da2,Rslt);//SUB MODULE OF ALU:DO OR OPERATION WITH VALUES OF DATA1 AND DATA2
    input [7:0]Da1,Da2;
    output [7:0] Rslt;
    assign #1 Rslt=Da1 | Da2; //assign result(ORR) of or operation with data1 & data2
endmodule