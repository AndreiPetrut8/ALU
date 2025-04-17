module control_unit2(
  input [2:0]a,
  input [3:0]count, 
  output reg [3:0]c
);
    
  always @ (*) begin
   c[0] = ~a[2] & a[1] & ~a[0] | ~a[2] & ~a[1] & a[0] | ~a[2] & a[1] & a[0];
   c[1] = a[2] & ~a[1] & ~a[0] | a[2] & ~a[1] & a[0] | a[2] & a[1] & ~a[0];
   c[2] = count[3];
   c[3] = count[0] & ~count[1] & ~count[2] & count[3];
  
end
endmodule 

module SRT2Divider(
    input clk,
    input rst,
    input [7:0] A,  
    input [7:0] B,   
    output [7:0] C,  
    output [7:0] R 
);

     reg [8:0] next_P;
    reg [7:0] next_A_prim, next_A_temp, next_B_temp;
    reg [3:0] next_count;
    reg [7:0] next_C, next_R;
    reg [2:0] k;
    reg next_en;
    reg en;

    wire [8:0] P;
    wire [7:0] A_temp, B_temp, A_prim;
    wire [3:0] count;

    wire [3:0] c;
    
    register #(9) reg_P (.clk(clk), .rst(rst), .en(1'b1), .d(next_P), .q(P));
    register #(8) reg_A_temp (.clk(clk), .rst(rst), .en(1'b1), .d(next_A_temp), .q(A_temp));
    register #(8) reg_B_temp (.clk(clk), .rst(rst), .en(1'b1), .d(next_B_temp), .q(B_temp));
    register #(8) reg_A_prim (.clk(clk), .rst(rst), .en(1'b1), .d(next_A_prim), .q(A_prim));
    register #(4) reg_count (.clk(clk), .rst(rst), .en(1'b1), .d(next_count), .q(count));
    register #(8) reg_C (.clk(clk), .rst(rst), .en(en), .d(next_C), .q(C));
    register #(8) reg_R (.clk(clk), .rst(rst), .en(en), .d(next_R), .q(R));
    
    control_unit2 ctrl2(
      .a(P[8:6]),
      .count(count),
      .c(c)
      );                        

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
          next_P = 9'd0;
          next_A_temp = A;
          next_B_temp = B;
          next_A_prim = 8'd0;
          k = 3'd0;
          next_count = 4'b0000;
          next_C = 8'd0;
          next_R = 8'd0;
          next_en  = 1'b1;
          repeat (8) begin
               if(~next_B_temp[7]) begin
                next_P = next_P << 1;
                next_P[0] = next_A_temp[7];
                next_A_temp = next_A_temp << 1;
                next_A_temp[0] = next_B_temp[7];
                next_B_temp = next_B_temp << 1;
                k = k + 1;
              end
            end
        end else begin
          $display("%4b", count);
          next_P = P;
          next_A_temp = A_temp;
          next_B_temp = B_temp;
          next_A_prim = A_prim;
          next_count = count;
          next_C = C;
          next_R = R;
          
          if(~c[2]) begin
             
            next_P = P << 1;
            next_P[0] = A_temp[7];
            next_A_temp = A_temp << 1;
            next_A_prim = A_prim << 1;
            next_count = count + 1; 

            if(c[0]) begin
              next_P = next_P - {1'b0, B_temp}; 
              next_A_temp[0] = 1;
            end
            if(c[1]) begin
              next_P = next_P + {1'b0, B_temp};  
              next_A_prim[0] = 1;
            end
          end
          if(~c[3] & c[2])
            next_count = count + 1;
          if(c[2]) begin
            if(P[8]) begin
              next_P = P + {1'b0, B_temp};
              next_A_prim = A_prim + 1; 
            end
            next_C = A_temp - A_prim;
            next_R = P >> k;
            
          end
          if(c[3])
            next_en = 1'b0;
    end
    en = next_en;
  end

endmodule

/*module TopModule();
    reg [7:0] A, B;
    wire [7:0] C, R;

    localparam CLK_PERIOD = 100;
    localparam RUNNING_CYCLES = 40;
    reg clk, rst;
    
    SRT2Divider div (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .C(C),
        .R(R)
    );

    
    initial begin
        A = 127;   
        B = 25;     
        
        
        #(CLK_PERIOD*10);
        A = 120;
        B = 15;
        
        #(CLK_PERIOD*10);
        A = 250;
        B = 5;
        
        #(CLK_PERIOD*10);
        A = 55;
        B = 7;
        
        #(CLK_PERIOD*10);
        A = 18;
        B = 3;
        
        #(CLK_PERIOD*10);
    end
    
    localparam RST_DURATION = 4;
    initial begin
      rst = 1'b0;
      #RST_DURATION rst = 1'd1;
      repeat (2*RUNNING_CYCLES/8) begin
        #(CLK_PERIOD*10) rst = 1'b0;
        #RST_DURATION rst = 1'd1;
      end
    end
    
    initial begin
      clk = 1'b0;
      repeat (2*RUNNING_CYCLES) #(CLK_PERIOD/2) clk = ~clk;
    end
  
    
endmodule*/
