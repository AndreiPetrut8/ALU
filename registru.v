module dff_en_reset(
  input clk,
  input rst,
  input en,
  input d,
  output reg q
);

  always @(posedge clk or negedge rst) begin
    if (~rst)
      q <= 1'b0;
    else if (en)
      q <= d;
  end

endmodule

module register #(parameter w = 8)(
  input clk,
  input rst,
  input en,
  input [w-1:0] d,
  output [w-1:0] q
);

  genvar i;
  generate
    for (i = 0; i < w; i = i + 1) begin : dff_gen
      dff_en_reset dff_inst (
        .clk(clk),
        .rst(rst),
        .en(en),
        .d(d[i]),
        .q(q[i])
      );
    end
  endgenerate

endmodule