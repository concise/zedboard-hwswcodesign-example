module dsquare (
    clk,
    rst,
    d2_ready,
    prime,
    d2
) ;

input               clk;
input               rst;
output              d2_ready;
input   [1039:0]    prime;
output  [1039:0]    d2;

reg     [1039:0]    d2_reg;
reg     [11:0]      count;
reg     [3:0]       slowcount;

wire    [1039:0]    diff_p;

assign d2_ready = ~(|count);
assign d2 = d2_reg[1039:0];

minusP minusP_0 ( .clk(clk), .inC({d2_reg, 1'b0}), .inP(prime), .outCP(diff_p) );

always @ (posedge clk) begin
    if(rst) begin
        count <= 1040 * 2;
        d2_reg <= { 1039'b0, 1'b1 };
        slowcount <= 4'd1;
    end else begin
        if(|count) begin
            slowcount <= slowcount + 4'd1;
            if(~|slowcount) begin
                count <= count - 1;
                d2_reg <= diff_p;
            end else begin
                d2_reg <= d2_reg;
                count <= count;
            end
        end else begin
            d2_reg <= d2_reg;
            count <= count;
        end
    end
end

endmodule

