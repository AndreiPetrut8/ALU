module control_unit2(
  input [2:0]a,
  input [3:0]count, 
  output reg [3:0]c
);
    
  always @ (*) begin
   c[2] = count[3];
   c[0] = (~a[2] & a[1] & ~a[0] | ~a[2] & ~a[1] & a[0] | ~a[2] & a[1] & a[0]) & ~c[2];
   c[1] = (a[2] & ~a[1] & ~a[0] | a[2] & ~a[1] & a[0] | a[2] & a[1] & ~a[0]) & ~c[2];
   c[3] = ~count[0] & count[1] & ~count[2] & count[3];
  
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

     reg [8:0] next_P, next_B_sum;
    reg [7:0] next_A_prim, next_A_temp, next_B_temp;
    reg [3:0] next_count;
    reg [7:0] next_C, next_R;
    reg [2:0] k;
    reg next_en;
    reg en;

    wire [8:0] P, B_sum;
    wire [7:0] A_temp, B_temp, A_prim, P_temp;
    wire [3:0] count;
wire Cout;

    wire [3:0] c;
    
    register #(9) reg_P (.clk(clk), .rst(rst), .en(1'b1), .d(next_P), .q(P));
    register #(8) reg_A_temp (.clk(clk), .rst(rst), .en(1'b1), .d(next_A_temp), .q(A_temp));
    register #(8) reg_B_temp (.clk(clk), .rst(rst), .en(1'b1), .d(next_B_temp), .q(B_temp));
    register #(9) reg_B_sum (.clk(clk), .rst(rst), .en(1'b1), .d(next_B_sum), .q(B_sum));
    register #(8) reg_A_prim (.clk(clk), .rst(rst), .en(1'b1), .d(next_A_prim), .q(A_prim));
    register #(4) reg_count (.clk(clk), .rst(rst), .en(1'b1), .d(next_count), .q(count));
    register #(8) reg_C (.clk(clk), .rst(rst), .en(en), .d(next_C), .q(C));
    register #(8) reg_R (.clk(clk), .rst(rst), .en(en), .d(next_R), .q(R));
    
    control_unit2 ctrl2(
      .a({Cout^P[8]^B_sum[8], P_temp[7:6]}),
      .count(count),
      .c(c)
      );   

    CarrySkipAdder8bit csa (

        .A(P[7:0]),
        .B(B_sum[7:0]),
        .Cin(1'b0),
        .Sum(P_temp),
        .Cout(Cout)
    );  

	                   

    always @(negedge clk or negedge rst) begin
 //$display("A = %b, B = %b, SUM = %b, count = %b, c = %b", P, B_sum, {Cout^P[8]^B_sum[8], P_temp}, count, c);
	
        if(~rst) begin
          next_P = 9'd0;
          next_A_temp = A;
          next_B_temp = B;
	  next_B_sum = 8'b0;
          next_A_prim = 8'd0;
          k = 3'd0;
          next_count = 4'b0000;
          next_C = 8'd0;
          next_R = 8'd0;
          next_en  = 1'b1;
          repeat (8) begin
              
                next_P = {next_P[7:0], next_A_temp[7]} & {9{~next_B_temp[7]}} | next_P & {9{next_B_temp[7]}};
                k = (k + 1) & {3{~next_B_temp[7]}} | k & {3{next_B_temp[7]}};
                next_A_temp = {next_A_temp[6:0], next_B_temp[7]} & {8{~next_B_temp[7]}} | next_A_temp & {8{next_B_temp[7]}};
                next_B_temp = {next_B_temp[6:0], 1'b0}& {8{~next_B_temp[7]}} | next_B_temp & {8{next_B_temp[7]}};
             
		

            end
	
        end else begin
          
          
	  next_B_sum = {1'b1, (~B_temp)+1} & {9{c[0]}} | {1'b0,B_temp} & {8{c[1]}} | {1'b0,B_temp} & {8{c[2] & P[8]}};
	

	next_A_temp = A_temp;
          next_B_temp = B_temp;
	  
          next_A_prim = A_prim;
          next_count = count;
          next_C = C;
          next_R = R;
          
	
            next_P = {P_temp, A_temp[7]} & {9{~c[2]}} | P_temp & {9{c[2]}};

            
         

            next_A_temp = {next_A_temp[6:0], 1'b1&c[0]}  & {8{~c[2]}} | next_A_temp & {8{c[2]}}; 
            next_A_prim = {next_A_prim[6:0], 1'b1&c[1]}  & {8{~c[2]}} | next_A_prim & {8{c[2]}};
            next_count = (count + 1) & {4{~c[2]}} | count & {4{c[2]}}; 
          
            next_count = (count + 1) & {4{~c[3] & c[2]}} | next_count & {4{c[3] | ~c[2]}};
       
            
            next_C = (A_temp - A_prim) & {8{c[2]}} | next_C & {8{~c[2]}};
            next_R = {P>>k} & {8{c[2]}} | next_R & {8{~c[2]}};
 
          
            next_en = c[3];
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
