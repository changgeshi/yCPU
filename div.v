`include"defines.h"

module div(
    input wire clk,
    input wire rst,
    input wire signed_div_i,
    input wire[`RegBus] opdata1_i,
    input wire[`RegBus] opdata2_i,
    input wire start_i,
    input wire annul_i,
    output reg[`DoubleRegBus] result_o,
    output reg ready_o
);

wire[32:0] div_temp;
reg[5:0] cnt;
reg[64:0] dividend;
reg[1:0] state;
reg[`RegBus] divisor;
reg[`RegBus] temp_op1;
reg[`RegBus] temp_op2;

assign div_temp = {1'b0, dividend[63:32] } - {1'b0, divisor};

always@(posedge clk) begin
    if(rst == `RstEnable) begin
        state <= `DivFree;
        ready_o <= `DivResultNotReady;
        result_o <= {`ZeroWord, `ZeroWord};
    end else begin
        case(state)
            `DivFree : begin
                if(start_i == `DivStart && annul_i == 1'b0) begin
                    if(opdata2_i == `ZeroWord) begin
                        state <= `DivByZero;
                    end else begin
                        state <= `DivOn;
                        cnt <= 6'b000000;
                        if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1) begin
                            temp_op1 = ~opdata1_i + 1;
                        end else begin
                            temp_op1 = opdata1_i;
                        end

                        if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1) begin
                            temp_op2 = ~opdata2_i + 1;
                        end else begin
                            temp_op2 = opdata2_i;
                        end
                        dividend <= {`ZeroWord, `ZeroWord};
                        dividend[32:1] <= temp_op1;
                        divisor <= temp_op2;
                    end
                end else begin
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord, `ZeroWord};
                end
            end //end DivFree
            `DivByZero: begin
                dividend <= {`ZeroWord, `ZeroWord};
                state <= `DivEnd;
            end //end DivByZero
            `DivOn: begin
                if(annul_i == 1'b0) begin
                    if(cnt != 6'b100000) begin
                        if(div_temp[32] == 1'b1) begin
                            dividend <= {dividend[63:0], 1'b0};
                        end else begin
                            dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
                        end 
                        cnt <= cnt+1;
                    end else begin
                        if((signed_div_i == 1'b1)&&
                            ((opdata1_i[31]^opdata2_i[31]) == 1'b1)) begin
                            dividend[31:0] <= (~dividend[31:0] + 1);
                        end
                        if((signed_div_i == 1'b1) && 
                            ((opdata1_i[31]^dividend[64])==1'b1)) begin
                            dividend[64:33] <= (~dividend[64:33]+1);
                        end
                        state <= `DivEnd;
                        cnt <= 6'b000000;
                    end
                end else begin
                    state <= `DivFree;
                end
            end// DivOn
            `DivEnd : begin
                result_o <= {dividend[64:33], dividend[31:0]};
                ready_o <= `DivResultReady;
                if(start_i == `DivStop) begin
                    state <= `DivFree;
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord, `ZeroWord};
                end
            end //DivEnd
        endcase
    end
end

endmodule

