module invPD ( clk, rst, ready, inP, out_invP ) ;

input                   clk;
input                   rst;
output                  ready;
input       [64:0]   inP;
output reg  [64:0]   out_invP;

reg [64:0]   tmpPbuf;
reg [64:0]   next_tmpPbuf;
reg [64:0]   sumP;
reg [64:0]   next_sumP;

reg [64:0]   next_invP;

reg [6:0]   counter;
reg [6:0]   next_counter;

assign ready = (counter == 65);
assign sumPp = sumP[counter];

always @ (*) begin
    if(rst) begin
        next_counter = 7'h01;
        next_tmpPbuf = { inP[63:0], 1'b0 };
        next_sumP = inP;
        next_invP = { 1'b1, 64'b0 };
    end else begin
        if(ready) begin
            next_counter = counter;
            next_tmpPbuf = tmpPbuf;
            next_sumP = sumP;
            next_invP = out_invP;
        end else begin
            next_counter = counter + 7'h01;
            next_tmpPbuf = { tmpPbuf[63:0], 1'b0 };
            next_sumP = ((sumPp) ? tmpPbuf : 65'b0) + sumP;
            next_invP = { sumPp, out_invP[64:1] };
        end
    end
end

always @ (posedge clk) begin
    counter <= next_counter;
    tmpPbuf <= next_tmpPbuf;
    sumP <= next_sumP;
    out_invP <= next_invP;
end

endmodule

