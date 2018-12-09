`default_nettype none

module top (
	input  clk,
    output ws_data
);

  localparam NUM_LEDS = 8;

  reg reset = 1;
  always @(posedge clk)
    reset <= 0;

  reg [14:0] count = 0;
  reg clk_1 = 1'b0;

  reg [7:0] green = 8'h10;
  reg [7:0] blue = 8'h10;
  reg [7:0] red = 8'h10;
  wire [23:0] rgb_colour = {green, red, blue};
  reg [7:0] wheel = 0;

  reg [24 * NUM_LEDS - 1:0] led_rgb_data = 0;
  reg [3:0] led_num = 0;

  always @(posedge clk) begin
    count <= count + 1;
    if (&count) begin
      clk_1 <= ~clk_1;
    end
  end

  always @(posedge clk_1) begin
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

    led_num <= led_num + 1;
    led_rgb_data[24 * led_num +: 24] <= rgb_colour;

    if (led_num == NUM_LEDS) begin
      wheel <= wheel + 1;
      led_num <= 0;
    end
  end


  ws2812 #(.NUM_LEDS(NUM_LEDS)) ws2812_inst(.data(ws_data), .clk(clk), .reset(reset), .packed_rgb_data(led_rgb_data));

endmodule
