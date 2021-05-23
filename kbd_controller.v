module kbd_controller (reset, clk, ps2clk, ps2data, height, width, rev, fl);

    input      reset, clk, ps2clk, ps2data;
    output     height;
    output     width;
    output     rev;
    output     fl;
    reg  [7:0] scancode;
    reg        fl, rev;
    reg  [9:0] width;
    reg  [8:0] height;
    reg  [9:0] swap;
    reg        explode;
    reg [31:0] divider;

                                                    // Synchronize ps2clk to local clock and check for falling edge
    reg  [7:0] ps2clksamples;                       // Stores last 8 ps2clk samples
    wire       fall_edge;                           // indicates a falling_edge at ps2clk
    reg  [9:0] shift;                               // Stores a serial package, excluding the stop bit
    reg  [3:0] cnt;                                 // Used to count the ps2data samples stored so far
    reg        f0;                                  // Used to indicate that f0 was encountered earlier

    parameter V_ROWS   = 400;
    parameter H_PIXELS = 640;
    parameter CYCLES = 50000000;

    initial begin
        width  <= 10'd20;
        height <= 9'd10;
        divider<= 32'b0;
        fl     <= 1'b0;                             // flash mode OFF
        rev    <= 1'b0;                             // reverse image OFF
        explode<= 1'b0;                             // explode mode OFF
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ps2clksamples <= 8'd0;
        end
        else begin
            ps2clksamples <= {ps2clksamples[7:0], ps2clk};
        end
    end

    assign fall_edge = (ps2clksamples[7:4] == 4'hF) & (ps2clksamples[3:0] == 4'h0);

/*
    A simple FSM is implemented here. Grab a whole package,
    check its parity validity and output it in the scancode
    only if the previous read value of the package was F0
    that is, we only trace when a button is released, NOT when it is
    pressed.
*/

    always @ (posedge clk or posedge reset) begin
        if (explode == 1) begin
            if (divider == CYCLES - 1) begin
                divider = 32'b0;
                if ((width + 10'd20 >= H_PIXELS) || (height + 9'd20 >= V_ROWS)) begin
                    width  = 10'd20;
                    height = 9'd10;
                end
                else begin
                    width  = width + 10'd10;
                    height = height + 9'd10;
                end
            end
            else begin
                divider = divider + 32'b1;
            end
        end
        if (reset) begin
            divider  = 32'b0;
            explode  = 1'b0;
            cnt     <= 4'd0;
            scancode = 8'd0;
            shift   <= 10'd0;
            f0       = 1'b0;
            height   = 9'd10;
            width    = 10'd20;
            fl       = 1'd0;                        // flash mode OFF
            rev      = 1'd0;                        // reverse image OFF
        end
        else if (fall_edge) begin
            if (cnt == 4'd10) begin                 // we just received what should be the stop bit
                cnt <= 0;
                if ((shift[0] == 0) && (ps2data == 1) && (^shift[9:1]==1)) begin
                                                    // A well received serial packet
                    if (f0) begin                   // following a scancode of f0. So a key is released ! 
                        scancode = shift[8:1];
                        f0 = 0;
                        case(scancode)
                            8'h75: height = ( height <= V_ROWS - 9'd20 )   ? height +  9'd10 : height;
                            8'h72: height = ( height >= 9'd20 )            ? height -  9'd10 : height;
                            8'h6B: width  = ( width <= H_PIXELS - 10'd20 ) ? width  + 10'd10 : width;
                            8'h74: width  = ( width >= 10'd30 )            ? width  - 10'd10 : width;
                            8'h24: explode= ~explode;
                            8'h4D: begin
                                swap = width;
                                if (swap < V_ROWS) begin
                                    width  = height;
                                    height = swap;
                                end
                            end
                            8'h2B: fl  = ~fl;
                            8'h2D: rev = ~rev;
                        endcase
                    end
                    else if (shift[8:1] == 8'hF0) begin
                        f0 = 1'b1;
                    end
                end                                 // All other packets have to do with key presses and are ignored
            end
            else begin
                shift <= {ps2data, shift[9:1]};     // Shift right since LSB first is transmitted
                cnt   <= cnt+1;
            end
        end
    end
endmodule
