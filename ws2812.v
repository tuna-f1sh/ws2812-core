`default_nettype none

`ifdef FORMAL
    `define NO_MEM_RESET 0
`else
    `define NO_MEM_RESET 1
`endif


module ws2812 (
    input [24 * NUM_LEDS - 1:0] packed_rgb_data,
    input reset,
    input clk,  //12MHz

    output reg data
);
    parameter NUM_LEDS = 8;
    parameter CLK_MHZ = 12;
    localparam LED_BITS = $clog2(NUM_LEDS);

    /*
    great information here:

    * https://cpldcpu.wordpress.com/2014/01/14/light_ws2812-library-v2-0-part-i-understanding-the-ws2812/
    * https://github.com/japaric/ws2812b/blob/master/firmware/README.md

    period 1200ns:
        * t on  800ns
        * t off 400ns

    end of frame/reset is > 50us. I had a bug at 50us, so increased to 65us

    More recent ws2812 parts require reset > 280us. See: https://blog.particle.io/2017/05/11/heads-up-ws2812b-neopixels-are-about-to-change/

    clock period at 12MHz = 83ns:
        * t on  counter = 10, makes t_on  = 833ns
        * t off counter = 5,  makes t_off = 416ns
        * reset is 800 counts             = 65us

    */
    parameter t_on = $rtoi($ceil(CLK_MHZ*900/1000));
    parameter t_off = $rtoi($ceil(CLK_MHZ*350/1000));
    parameter t_reset = $rtoi($ceil(CLK_MHZ*280));
    localparam t_period = $rtoi($ceil(CLK_MHZ*1250/1000));
    localparam COUNT_BITS = $clog2(t_reset);

    initial data = 0;

    wire [24 * NUM_LEDS - 1:0] led_reg;
    assign led_reg = packed_rgb_data;

    reg [LED_BITS-1:0] led_counter = 0;
    reg [COUNT_BITS-1:0] bit_counter = 0;
    reg [4:0] rgb_counter = 0;

    localparam STATE_DATA  = 0;
    localparam STATE_RESET = 1;

    reg [1:0] state = STATE_RESET;

    reg [23:0] led_color = 24'h00_00_00;

    integer i;

    always @(posedge clk)
        // reset
        if(reset) begin
            state <= STATE_RESET;
            bit_counter <= t_reset;
            rgb_counter <= 23;
            led_counter <= NUM_LEDS - 1;
            data <= 0;

        // state machine to generate the data output
        end else case(state)

            STATE_RESET: begin
                // register the input values
                rgb_counter <= 5'd23;
                led_counter <= NUM_LEDS - 1;
                data <= 0;

                bit_counter <= bit_counter - 1;

                if(bit_counter == 0) begin
                    state <= STATE_DATA;
                    bit_counter <= t_period;
                    led_color <= led_reg[23 * led_counter +: 23];
                end
            end

            STATE_DATA: begin
                // output the data
                if(led_color[rgb_counter])
                    data <= bit_counter > (t_period - t_on);
                else
                    data <= bit_counter > (t_period - t_off);

                // count the period
                bit_counter <= bit_counter - 1;

                // after each bit, increment rgb counter
                if(bit_counter == 0) begin
                    bit_counter <= t_period;
                    rgb_counter <= rgb_counter - 1;

                    if(rgb_counter == 0) begin
                        led_counter <= led_counter - 1;
                        bit_counter <= t_period;
                        rgb_counter <= 23;
                        led_color <= led_reg[23 * led_counter +: 23];

                        if(led_counter == 0) begin
                            state <= STATE_RESET;
                            led_counter <= NUM_LEDS - 1;
                            bit_counter <= t_reset;
                        end
                    end
                end 
            end

        endcase

    `ifdef FORMAL
        // start in reset
        initial restrict(reset);

        // past valid signal
        reg f_past_valid = 0;
        always @(posedge clk)
            f_past_valid <= 1'b1;

        // check everything is zeroed on the reset signal
        always @(posedge clk)
            if (f_past_valid)
                if ($past(reset)) begin
                    assert(bit_counter == t_reset);
                    assert(rgb_counter == 23);
                    assert(state == STATE_RESET);
                end

        always @(posedge clk) begin
            assert(bit_counter <= t_reset);
            assert(rgb_counter <= 23);
            assert(led_counter <= NUM_LEDS - 1);

            if(state == STATE_DATA) begin
                assert(bit_counter <= t_period);
                // led counter decrements
                if($past(state) == STATE_DATA && $past(rgb_counter) == 0 && $past(bit_counter) == 0)
                    assert(led_counter == $past(led_counter) - 1);
            end

            if(state == STATE_RESET) begin
                assert(data == 0);
                assert(bit_counter <= t_reset);
            end
        end

    `endif
    
endmodule
