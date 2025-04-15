module control_unit2(
  input [2:0]a,
  input [3:0]count, 
  output reg [3:0]c
);
    
  always @ (*) begin
   c[0] = ~a[2] & a[1] & ~a[0] | ~a[2] & ~a[1] & a[0] | ~a[2] & a[1] & a[0];
   c[1] = a[2] & ~a[1] & ~a[0] | a[2] & ~a[1] & a[0] | a[2] & a[1] & ~a[0];
   c[2] = count[0] | count[1] | count[2] | count[3];
   c[3] = c[2];
  
end
endmodule 

module SRT2Divider(
    input clk,
    input rst,
    input [7:0] A,  
    input [7:0] B,   
    output reg [7:0] C,  
    output reg [7:0] R 
);

    reg [8:0] P;            
    reg [3:0] count; 
    reg [7:0] A_prim, A_temp, B_temp;
    wire [3:0]c;
    reg [2:0] k;
    
    control_unit2 ctrl2(
      .a(P[8:6]),
      .count(count),
      .c(c)
      );                        

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
          P = 9'd0;
          A_temp = A;
          B_temp = B;
          A_prim = 8'd0;
          k = 3'd0;
          count = 4'd1000;
          C = 8'd0;
          R = 8'd0;
          repeat (8) begin
              if(~B_temp[7]) begin
                P = P << 1;
                P[0] = A_temp[7];
                A_temp = A_temp << 1;
                A_temp[0] = B_temp[7];
                B_temp = B_temp << 1;
                k = k + 1;
                
              end
            end
        end else begin
          $display("%4b", count);
          if(c[2]) begin
             
            P = P << 1;
            P[0] = A_temp[7];
            A_temp = A_temp << 1;
            A_prim = A_prim << 1;
            count = count - 1; 
                  
            if(c[0]) begin
                P = P - {1'b0, B_temp}; 
                A_temp[0] = 1;
              end
               
            if(c[1]) begin
                P = P + {1'b0, B_temp};  
                A_prim[0] = 1;
              end
                
        end
      if(~c[3]) begin
        if(P[8]) begin
          P = P + {1'b0, B_temp};
          A_prim = A_prim + 1; 
        end
        C = A_temp - A_prim;
        R = P >> k;
      end
    end
  end

endmodule

module TopModule();
    reg [7:0] A, B;
    wire [7:0] C, R;

    localparam CLK_PERIOD = 100;
    localparam RUNNING_CYCLES = 10;
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
        
        
        /*#(CLK_PERIOD*10);
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
        
        #(CLK_PERIOD*10);*/
    end
    
    localparam RST_DURATION = 4;
    initial begin
      rst = 1'b0;
      #RST_DURATION rst = 1'd1;
      /*repeat (2*RUNNING_CYCLES/8) begin
        #(CLK_PERIOD*10) rst = 1'b0;
        #RST_DURATION rst = 1'd1;
      end*/
    end
    
    initial begin
      clk = 1'b0;
      repeat (2*RUNNING_CYCLES) #(CLK_PERIOD/2) clk = ~clk;
    end
  
    
endmodule
