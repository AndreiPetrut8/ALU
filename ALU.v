module ALU();

    reg clk, rst;
    localparam CLK_PERIOD = 100;
    localparam RUNNING_CYCLES = 40;
    reg [7:0] A, B;
    reg Cin;
    wire [7:0] Sum;
    wire Cout;
    reg space1;
    reg [7:0] A1, B1;
    reg Bin;
    wire [7:0] Diff;
    wire Bout;
    reg space2;
    reg [7:0]  A2, B2;
    wire [15:0] Out;
    reg space3;
    reg [7:0] A3, B3;
    wire [7:0] C, R; 
    CarrySkipAdder8bit csa (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );
    
    CarrySkipSubtractor8bit csa2 (
        .A(A1),
        .B(B1),
        .Bin(Bin),
        .Diff(Diff),
        .Bout(Bout)
    );
    
    BoothRadix4Multiplier rad (
        .clk(clk),
        .rst(rst),
        .Q(A2),
        .M(B2),
        .A(Out)
    );
    
    SRT2Divider div (
        .clk(clk),
        .rst(rst),
        .A(A3),
        .B(B3),
        .C(C),
        .R(R)
    );
  
    //integer i ;
    initial begin
    {A , B, Cin} = {8'd100, 8'd24, 1'b0};
    {A1 , B1, Bin} = {8'd100, 8'd24, 1'b0};
    {A2 , B2} = {8'd100, 8'd24};
    {A3 , B3} = {8'd12, 8'd10};
    #(CLK_PERIOD*12);
    /*for(i=1; i<8; i=i+1) begin
      #(CLK_PERIOD*12); 
      A = i;
      B = i + 8;
      A1 = A + B;
      B1 = i+8;
      A2 = i;
      B2 = i+8;
      A3 = A2*B2;
      B3 = i+8;
    end*/
    end  
    
    initial begin
      clk = 1'b0;
      repeat (2*RUNNING_CYCLES) #(CLK_PERIOD/2) clk = ~clk;
    end
  
    localparam RST_DURATION = 2;
    initial begin
      rst = 1'b0;
      #RST_DURATION rst = 1'd1;
      /*repeat (2*RUNNING_CYCLES/8) begin
      #(CLK_PERIOD*12) rst = 1'b0;
      #RST_DURATION rst = 1'd1;
      end*/
    end 
    
endmodule