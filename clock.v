module cnt4 ( reset, clk, enable, clkdiv4 );
    input  wire reset;
    input  wire clk;
    input  wire enable;
    output wire clkdiv4;

    reg [1:0] cnt;

    assign clkdiv4 = (cnt == 2'b11);
    always @ (posedge reset or posedge clk) begin
        if (reset) begin
            cnt <= 0;
        end
        else if (enable) begin
            if (clkdiv4) begin
                cnt <= 0;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end
endmodule

module TwentyFiveMHertz ( reset, clk, pulse );
    input  wire reset;
    input  wire clk;
    output wire pulse;

    wire clk25MHz;

    cnt4 vga_freq ( reset, clk, 1'b1, clk25MHz );

    assign pulse = clk25MHz;
endmodule

/*

In this example, we are going to use this clock divider to implement a signal of exactly .5 Hz frequency. 
First, we will need to calculate the constant. 
As an example, the input clock frequency of the Spartan3 is 100 MHz. We want our `flash` to be .5 Hz. 
So it should take 200000000 clock cycles before `flash` goes to '1' and returns to '0'. 
In another words, it takes 100000000 clock cycles for `flash` to flip its value. 
So the constant we need to choose here is 100000000.

*/

module HalfHertz( reset, clk, flash );

	input  wire reset;
    input  wire clk;
    output reg flash; 

    parameter CYCLES = 100000000;

    reg [31:0] count = 32'b0;
 
    always @ (posedge reset or posedge clk) begin
        if (reset == 1'b1) begin
            count <= 32'b0;
            flash <= 1'b0;
        end 
        else if (count == CYCLES - 1) begin
            count <= 32'b0;
            flash <= ~flash;
        end 
        else begin
            count <= count + 1;
            flash <= flash;
        end    
    end

endmodule
