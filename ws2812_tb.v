module test;

  reg clk = 0;
  reg reset = 1;
  reg [24 * 4 - 1:0] rgb_data = 0;
  reg [7:0] red = 0;
  reg [7:0] green = 0;
  reg [7:0] blue = 0;
  integer i;

  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);
     # 20
     reset <= 0;
     # 10
     rgb_data[24 * 0 +: 24] <= 24'hFF_FF_FF;
     # 10;
     /* rgb_data[23 * 3 +: 24] <= 24'h00_FF_00; */
     /* # 10; */
     /* for (i=0; i<4; i=i+1) */
     /* rgb_data[23 * 1 +: 24] <= {green, red, blue}; */

     repeat (12) begin
         wait(ws2812_inst.led_counter == 0);
         wait(ws2812_inst.state == 1);
     end

     $finish;
  end

  ws2812 #(.NUM_LEDS(4))  ws2812_inst(.clk(clk), .reset(reset), .packed_rgb_data(rgb_data));
  /* Make a regular pulsing clock. */
  always #1 begin
    clk <= !clk;
    /* red <= red + 1; */
    /* blue <= blue + 1; */
    /* green <= green + 1; */
  end

endmodule // test

