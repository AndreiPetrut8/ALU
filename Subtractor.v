module FullSubtractor(
    input A,
    input B,
    input Bin,
    output Diff,
    output Bout,
    output Pi
);
    assign Diff = A ^ B ^ Bin;
    assign Bout = (~A & B) | (~A & Bin) | (B & Bin);
    assign Pi = ~A | B;
endmodule

module RippleBorrowSubtractor4bit(
    input [3:0] A,
    input [3:0] B,
    input Bin,
    output [3:0] Diff,
    output Bout,
    output Ps
);
    wire B1, B2, B3;
    wire [3:0] P;
    
    FullSubtractor fs0 (.A(A[0]), .B(B[0]), .Bin(Bin), .Diff(Diff[0]), .Bout(B1), .Pi(P[0]));
    FullSubtractor fs1 (.A(A[1]), .B(B[1]), .Bin(B1), .Diff(Diff[1]), .Bout(B2), .Pi(P[1]));
    FullSubtractor fs2 (.A(A[2]), .B(B[2]), .Bin(B2), .Diff(Diff[2]), .Bout(B3), .Pi(P[2]));
    FullSubtractor fs3 (.A(A[3]), .B(B[3]), .Bin(B3), .Diff(Diff[3]), .Bout(Bout), .Pi(P[3]));
    assign Ps = P[0] & P[1] & P[2] & P[3];
    
endmodule

module CarrySkipSubtractor8bit(
    input [7:0] A,
    input [7:0] B,
    input Bin,
    output [7:0] Diff,
    output Bout
);
    
    wire [3:0] Diff1, Diff2;
    wire B4, BorrowBlock, P1, P2;
    
    
    RippleBorrowSubtractor4bit rbs1 (
        .A(A[3:0]),
        .B(B[3:0]),
        .Bin(Bin),
        .Diff(Diff1),
        .Bout(B4),
        .Ps(P1)
    );
    
    
    assign BorrowBlock = (Bin & P1) | B4;
    
    
    RippleBorrowSubtractor4bit rbs2 (
        .A(A[7:4]),
        .B(B[7:4]),
        .Bin(BorrowBlock),
        .Diff(Diff2),
        .Bout(Bout),
        .Ps(P2)
    );
    
    assign Diff = (Diff2[3]) ? ~({~Diff2[3],Diff2[2:0], Diff1}-1) : {Diff2, Diff1};
    
endmodule

/*module TopModule();
    reg [7:0] A, B;
    reg Bin;
    wire [7:0] Diff;
    wire Bout;
    CarrySkipSubtractor8bit csa (
        .A(A),
        .B(B),
        .Bin(Bin),
        .Diff(Diff),
        .Bout(Bout)
    );
    integer i ;
    initial begin
    {A , B, Bin} = 0;
  for(i=1; i<8; i=i+1) begin
    #20; 
    A = i;
    B = i+i*2;
  end
  #20;
  end

endmodule*/