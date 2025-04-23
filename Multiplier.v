module control_unit(
  
  input [2:0]a,
  input [3:0]count, 
  output reg [6:0]c
);
    
  always @ (*) begin
   c[4] = (count[3] & (count[1] | count[2]));
   c[0] = (~a[2] & a[1] & ~a[0] | ~a[2] & ~a[1] & a[0]) & ~c[4];
   c[1] = (~a[2] & a[1] & a[0]) & ~c[4];
   c[2] = (a[2] & ~a[1] & ~a[0]) & ~c[4];
   c[3] = (a[2] & ~a[1] & a[0] | a[2] & a[1] & ~a[0]) & ~c[4];
   c[5] = count[3] & count[2];
  
end
endmodule 

module BoothRadix4Multiplier(
    input clk,
    input rst,
    input [7:0] Q,     
    input [7:0] M,     
    output [15:0] A    
);

    reg [8:0] next_A_reg, next_Q_temp;
    reg [3:0] next_count;
    reg [15:0] next_A_out;
    reg [8:0] next_M_temp;
    reg next_en;
    reg en;



    wire [8:0] A_reg, Q_temp, M_temp;
    wire [7:0] A_temp;
    wire [3:0] count;
    wire [6:0] c; 
    wire Cout;
    
    register #(9) reg_A (.clk(clk), .rst(rst), .en(1'b1), .d(next_A_reg), .q(A_reg));
    register #(9) reg_Q (.clk(clk), .rst(rst), .en(1'b1), .d(next_Q_temp), .q(Q_temp));
    register #(4) reg_count (.clk(clk), .rst(rst), .en(1'b1), .d(next_count), .q(count));
    register #(16) reg_A_out (.clk(clk), .rst(rst), .en(en), .d(next_A_out), .q(A));
    register #(9) reg_M (.clk(clk), .rst(rst), .en(1'b1), .d(next_M_temp), .q(M_temp));
    
    control_unit ctrl(
      
      .a(Q_temp[2:0]),
      .count(count),
      .c(c)
      ); 

    CarrySkipAdder8bit csa (

        .A(A_reg[7:0]),
        .B(M_temp[7:0]),
        .Cin(1'b0),
        .Sum(A_temp),
        .Cout(Cout)
    );    

     always @(negedge clk or negedge rst) begin
        
        next_M_temp = ({M[7], M} & {9{c[0]}}) | ({M, 1'b0} & {9{c[1]}}) | ({~{M, 1'b0}+1} & {9{c[2]}}) | ({~{M[7], M}+1} & {9{c[3]}});
        next_Q_temp = Q_temp;
        next_count = count;
        next_A_out = A;
	next_A_reg = {Cout^A_reg[8]^M_temp[8], A_temp} & {9{~c[4]}} | A_reg & {9{c[4]}};
        
        if (~rst) begin
          next_A_reg = 9'd0;
          next_Q_temp = {Q, 1'b0};
          next_count = 4'd0;
          next_A_out = 16'd0;
	  next_M_temp = 9'b0;
          next_en      = 1'b1;
          
        end else begin
            //$display("A = %b, B = %b, SUM = %b, count = %b, c = %b", A_reg, Q_temp, M_temp, count, c);

             
           
            next_Q_temp = ({next_A_reg[1:0], Q_temp[8:2]} & {9{~c[4]}}) | (Q_temp & {9{c[4]}});          
            next_A_reg = ({next_A_reg[8], next_A_reg[8], next_A_reg[8:2]} & {9{~c[4]}}) | (next_A_reg & {9{c[4]}});
            next_count = ((count + 2) & {4{~c[4]}}) | (count & {4{c[4]}});
            
		next_en = c[5];
              next_count = ((count + 2) & {4{~c[5] & c[4]}}) | (next_count & {4{c[5] | ~c[4]}});
            
              next_A_out = ((A_reg[7]) ? ~({~A_reg[7],A_reg[6:0], Q_temp[8:1]}-1) : {A_reg[7:0], Q_temp[8:1]} & {16{c[4]}}) | (next_A_out & {16{~c[4]}});
            
            
              
    end
    en = next_en;
  end
      

endmodule

/*module TopModule();
    reg clk, rst;
    reg [7:0] A, B;
    wire [15:0] Out;
    localparam CLK_PERIOD = 100;
    localparam RUNNING_CYCLES = 100;
    BoothRadix4Multiplier rad (
        .clk(clk),
        .rst(rst),
        .Q(A),
        .M(B),
        .A(Out)
    );
  integer i ;
  initial begin
  {A , B} = {8'd35, 8'd23};
  /*for(i=1; i<8; i=i+1) begin
    #(CLK_PERIOD*12);
    A = i;
    B = i-8;
  end
  #(CLK_PERIOD);
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
end
  end

endmodule*/