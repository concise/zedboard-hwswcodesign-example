module minusP ( clk, inC, inP, outCP ) ;

    input clk;
    input [1040:0] inC;
    input [1039:0] inP;
    output [1039:0] outCP;

    wire [1039:0] inPnot;
    reg [16:0] carries;
    reg [1039:0] outCPcandidate;

    integer i;

    assign inPnot = ~inP;
    assign outCP = carries[16] ? inC : outCPcandidate;

    always @ (posedge clk) begin
        carries[0] <= 1'b1;
    end

    always @ (posedge clk) begin
        for(i = 0; i < 15; i = i + 1) begin
            { carries[i+1], outCPcandidate[65*i+:65] } <=
                { 1'b0, inC[65*i+:65] } + { 1'b0, inPnot[65*i+:65] } + { 65'b0, carries[i] } ;
        end
        { carries[16], outCPcandidate[1039:975] } <= inC[1040:975] + {1'b1, inPnot[1039:975] } + { 65'b0, carries[15] };
    end

endmodule

