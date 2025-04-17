module control_unit(
  
  input [2:0]a,
  input [3:0]count, 
  output reg [5:0]c
);
    
  always @ (*) begin
   c[0] = ~a[2] & a[1] & ~a[0] | ~a[2] & ~a[1] & a[0];
   c[1] = ~a[2] & a[1] & a[0];
   c[2] = a[2] & ~a[1] & ~a[0];
   c[3] = a[2] & ~a[1] & a[0] | a[2] & a[1] & ~a[0];
   c[4] = count[3];
   c[5] = count[3] & count[1];
  
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
    reg next_en;
    reg en;


    wire [8:0] A_reg, Q_temp;
    wire [3:0] count;
    wire [5:0] c; 
    
    register #(9) reg_A (.clk(clk), .rst(rst), .en(1'b1), .d(next_A_reg), .q(A_reg));
    register #(9) reg_Q (.clk(clk), .rst(rst), .en(1'b1), .d(next_Q_temp), .q(Q_temp));
    register #(4) reg_count (.clk(clk), .rst(rst), .en(1'b1), .d(next_count), .q(count));
    register #(16) reg_A_out (.clk(clk), .rst(rst), .en(en), .d(next_A_out), .q(A));
    
    control_unit ctrl(
      
      .a(Q_temp[2:0]),
      .count(count),
      .c(c)
      );     

     always @(posedge clk or negedge rst) begin
        
        next_A_reg = A_reg;
        next_Q_temp = Q_temp;
        next_count = count;
        next_A_out = A;
        
        if (~rst) begin
          next_A_reg = 9'd0;
          next_Q_temp = {Q, 1'b0};
          next_count = 4'd0;
          next_A_out = 16'd0;
           next_en      = 1'b1;
          
        end else begin
            $display("%4b", count);
             
            if(~c[4]) begin 
            
            if(c[0]) 
                next_A_reg = A_reg + {M[7], M};                
            if(c[1])  
                next_A_reg = A_reg + {M, 1'b0};
            if(c[2])
                next_A_reg = A_reg - {M, 1'b0};
            if(c[3])  
                next_A_reg = A_reg - {M[7], M};    
           
            next_Q_temp = Q_temp >> 2;
            next_Q_temp[8:7] = next_A_reg[1:0];
            next_A_reg = next_A_reg >> 2;
            next_A_reg[8:7] = {next_A_reg[6], next_A_reg[6]};
            next_count = count + 2;
            
            end
            if(~c[5] & c[4])
              next_count = count + 2;
            if(c[4]) begin
              next_A_out = (A_reg[7]) ? ~({~A_reg[7],A_reg[6:0], Q_temp[8:1]}-1) : {A_reg[7:0], Q_temp[8:1]};
            end
            if(c[5])
              next_en = 1'b0;
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
  {A , B} = {8'd10, 8'd12};
  for(i=1; i<8; i=i+1) begin
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
  repeat (2*RUNNING_CYCLES/8) begin
  #(CLK_PERIOD*12) rst = 1'b0;
  #RST_DURATION rst = 1'd1;
end
  end

endmodule*/