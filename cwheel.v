module cwheel(
  input clk,
  input [7:0] wheel,
  output [7:0] red,
  output [7:0] green,
  output [7:0] blue);

  reg [7:0] red = 0 ;
  reg [7:0] green = 0;
  reg [7:0] blue = 0;

  always @ (posedge clk) begin
    if (wheel < 85) begin
      red <= (255 - wheel * 3);
      green <= 0;
      blue <= wheel * 3;
    end else if (wheel < 170)  begin
      red <= 0;
      green <= (wheel - 85) * 3;
      blue <= (255 - (wheel - 85) * 3);
    end else begin
      red <= (wheel - 170) * 3;
      green <= (255 - (wheel - 170)* 3);
      blue <= 0;
    end
  end

endmodule
