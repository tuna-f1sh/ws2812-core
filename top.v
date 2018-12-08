`default_nettype none

module top (
  input  clk,
  output ws_data);

  localparam NUM_LEDS = 4;

  reg reset = 1;
  always @(posedge clk)
    reset <= 0;

  reg [20:0] count = 0;
  reg clk_1 = 1'b0;

  reg [7:0] green = 8'h10;
  reg [7:0] blue = 8'h10;
  reg [7:0] red = 8'h10;
  wire [23:0] rgb_colour = {green, red, blue};
  reg [7:0] wheel = 0;

  /* reg [NUM_LEDS - 1:0] led_mask = 1; */
  reg [NUM_LEDS - 1:0] led_mask = {1'b0, 1'b1, 1'b0, 1'b1};

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

    led_mask <= led_mask << 1;
    if (led_mask == (1 << NUM_LEDS - 1)) begin
      led_mask <= 1;
      wheel <= wheel + 1;
    end
  end

  ws2812 #(.NUM_LEDS(NUM_LEDS)) ws2812_inst(.data(ws_data), .clk(clk), .reset(reset), .led_mask(led_mask), .rgb_colour(rgb_colour), .write(clk_1));

endmodule
