module ma (
    clk,
    start,
    inA,
    inB,
    inP,
    inPH,
    outC,
    ready
);

input               clk;
input               start;
input   [1039:0]    inA;
input   [1039:0]    inB;
input   [1039:0]    inP;
input   [64:0]      inPH;
output  [1040:0]    outC;
output              ready;

reg     [1169:0]    regS;
reg     [1169:0]    regT;
reg     [64:0]      regZ;
wire    [64:0]      regZ_next;
reg     [4:0]       round;
reg     [3:0]       count;
    
wire    [64:0]      M1in1;
wire    [64:0]      M1in2;
wire    [129:0]     M1out;
wire    [64:0]      M2in1;
wire    [64:0]      M2in2;
wire    [129:0]     M2out;
wire    [129:0]     N1in1;
wire    [129:0]     N1in2;
wire    [194:0]     N1out;
wire    [129:0]     N2in1;
wire    [129:0]     N2in2;
wire    [194:0]     N2out;

assign ready = (round == 5'b11111);
assign outC = ready ? regT[1105:65] : 1041'b0;

assign M1out = M1in1 * M1in2;
assign M2out = M2in1 * M2in2;
assign N1out = { 65'b0, M1out } + { 65'b0, N1in1 } + { 65'b0, N1in2 };
assign N2out = { 65'b0, M2out } + { 65'b0, N2in1 } + { 65'b0, N2in2 };
assign regZ_next = (66'h200000000_00000000 - regS[64:0]) * inPH;
assign M1in1 = inA[count*65+:65];
assign M1in2 = inB[round*65+:65];
assign N1in1 = (count==0) ? regT[194:65] : {regT[(count+2)*65+:65], regS[count*65+:65]};
assign N1in2 = (count==0) ? 130'b0 : {regS[(count+1)*65+:65], 65'b0};
assign M2in1 = (count==0) ? inP[974:910] : 
               (count==1) ? inP[1039:975] : inP[(count-2)*65+:65];
assign M2in2 = regZ;
assign N2in1 = (count==0) ? {regS[1039:975], regT[974:910]} : 
               (count==1) ? {regS[1104:1040], regT[1039:975]} :
               (count==2) ? regS[129:0] : {regS[(count-1)*65+:65], regT[(count-2)*65+:65]};
assign N2in2 = (count==0) ? { 64'b0, regT[975], 65'b0} :
               (count==1) ? { 64'b0, regT[1040], 65'b0} :
               (count==2) ? 130'b0 : { 64'b0, regT[(count-1)*65], 65'b0};

always @ (posedge clk) begin 
    if (start) begin
        regZ <= 65'b0;
    end
    else if (count==1) begin
        regZ <= regZ_next;
    end
end

always @ (posedge clk) begin
    if (start) begin
        regS <= 1169'b0;
    end
    else if (round<16) begin
        case (count)
            default : regS[count*65+:195] <= N1out;
        endcase
    end
end

always @ (posedge clk) begin
    if (start) begin
        regT <= 1169'b0;
    end
    else if (round<17) begin
        if (round==0) begin
            case (count)
                0       : ;
                1       : ;
                default : regT[(count-2)*65+:195] <= N2out;
            endcase
        end
        else begin
            case (count)
                0       : regT[1104:910]          <= N2out;
                1       : regT[1169:975]          <= N2out;
                default : regT[(count-2)*65+:195] <= N2out;
            endcase
        end
    end
end

always @ (posedge clk) begin
    if (start) begin
        count <= 0;
        round <= 0;
    end
    else begin
        if (round==16) begin
            if (count==1) begin
                round <= 5'b11111;
            end
            else begin
                count <= count + 1;
            end
        end
        else if (!ready) begin
            if (count==15) begin
                count <= 0;
                round <= round + 1;
            end
            else begin
                count <= count + 1;
            end
        end
    end
end

endmodule

