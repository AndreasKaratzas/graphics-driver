module top( reset, clk, ps2clk, ps2data, h_sync, v_sync, red, green, blue );
	input        reset, clk, ps2clk, ps2data;
	output       h_sync, v_sync;
	output [2:0] red;
	output [2:0] green;
	output [2:0] blue;
	wire         pulse25M, pulse05H;
	wire   [9:0] width;
	wire   [8:0] height;
	wire         fl, rev, f0;

	TwentyFiveMHertz vga_clk( reset, clk, pulse25M );
	HalfHertz        flsh_clk( reset, clk, pulse05H );
	kbd_controller   kdb_ctrl( reset, clk, ps2clk, ps2data, height, width, rev, fl );
	vga_controller   vga_ctrl( pulse25M, pulse05H, reset, height, width, rev, fl, h_sync, v_sync, red, green, blue );
endmodule
