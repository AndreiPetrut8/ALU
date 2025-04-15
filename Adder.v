module FullAdder(
    input A,
    input B,
    input Cin,
    output Sum,
    output Cout,
    output Pi
);
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A & B) | (Cin & A) | (Cin & B);
    assign Pi = A | B;
endmodule

module RippleCarryAdder4bit(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout,
    output Ps
);
    wire C1, C2, C3;
    wire [3:0] P;
    
    FullAdder fa0 (.A(A[0]), .B(B[0]), .Cin(Cin), .Sum(Sum[0]), .Cout(C1), .Pi(P[0]));
    FullAdder fa1 (.A(A[1]), .B(B[1]), .Cin(C1), .Sum(Sum[1]), .Cout(C2), .Pi(P[1]));
    FullAdder fa2 (.A(A[2]), .B(B[2]), .Cin(C2), .Sum(Sum[2]), .Cout(C3), .Pi(P[2]));
    FullAdder fa3 (.A(A[3]), .B(B[3]), .Cin(C3), .Sum(Sum[3]), .Cout(Cout), .Pi(P[3]));
    assign Ps = P[0] & P[1] & P[2] & P[3];
    
endmodule

module CarrySkipAdder8bit(
    input [7:0] A,
    input [7:0] B,
    input Cin,
    output [7:0] Sum,
    output Cout
);
    
    wire [3:0] Sum1, Sum2;
    wire C4, CarryBlock, P1, P2;
    
  
    RippleCarryAdder4bit rca1 (
        .A(A[3:0]),
        .B(B[3:0]),
        .Cin(Cin),
        .Sum(Sum1),
        .Cout(C4),
        .Ps(P1)
    );
    
    
    assign CarryBlock = (Cin & P1)|C4;
    
    
    RippleCarryAdder4bit rca2 (
        .A(A[7:4]),
        .B(B[7:4]),
        .Cin(CarryBlock),
        .Sum(Sum2),
        .Cout(Cout),
        .Ps(P2)
    );
    
    assign Sum = {Sum2, Sum1};
    
endmodule

/*module TopModule();
    reg [7:0] A, B;
    reg Cin;
    wire [7:0] Sum;
    wire Cout;
    CarrySkipAdder8bit csa (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );
    integer i ;
    initial begin
    {A , B, Cin} = 0;
  for(i=1; i<8; i=i+1) begin
    #20; 
    A = i;
    B = i + 8;
  end
  #20;
  end

endmodule*/


    