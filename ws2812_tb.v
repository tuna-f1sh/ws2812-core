module test;

  reg clk = 0;
  reg reset = 1;
  reg [3:0] led_mask = {1'b0, 1'b1, 1'b0, 1'b1};
  reg write = 0;
  reg [23:0] rgb_data = 0;

  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);
     $dumpvars(1,ws2812_inst.led_reg[0]);
     $dumpvars(1,ws2812_inst.led_reg[1]);
     # 20
     reset <= 0;
     # 10
     rgb_data <= 24'hAA_CC_DD;
     write <= 1;
     # 2;
     write <= 0;


     repeat (6) begin
         wait(ws2812_inst.led_counter == 0);
         wait(ws2812_inst.state == 1);
     end

     $finish;
  end

  ws2812 #(.NUM_LEDS(4))  ws2812_inst(.clk(clk), .reset(reset), .rgb_colour(rgb_data), .led_mask(led_mask), .write(write));
  /* Make a regular pulsing clock. */
  always #1 clk = !clk;

endmodule // test

