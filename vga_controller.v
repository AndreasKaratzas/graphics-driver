module vga_controller( pulse25M, pulse05H, reset, height, width, rev, fl, h_sync, v_sync, red, green, blue );
	input        pulse25M, pulse05H, reset;
	input  [9:0] width;
	input  [8:0] height;
	input 		 rev, fl;
	output       h_sync, v_sync;
	output [2:0] red;
	output [2:0] green;
	output [2:0] blue;

	wire         enable_v_counter;
	wire   [9:0] h_count;
	wire   [8:0] v_count;
	wire   [2:0] flash;
	wire   [2:0] reverse;

	wire   [9:0] left, right;
	wire   [8:0] upper, down;

	//horizontal parameters in pixels
	parameter H_FRONT_PORCH  = 16;
	parameter H_SYNC         = 96;
	parameter H_BACK_PORCH   = 48;
	parameter H_PIXELS       = 640;
	parameter H_NON_VISIBLE  = H_FRONT_PORCH + H_SYNC + H_BACK_PORCH;

	//vertical parameters in rows
	parameter V_FRONT_PORCH  = 12;
	parameter V_SYNC         = 2;
	parameter V_BACK_PORCH   = 35;
	parameter V_ROWS         = 400;
	parameter V_NON_VISIBLE  = V_FRONT_PORCH + V_SYNC + V_BACK_PORCH;

	//Pixel and line counters
	horizontal_counter vga_h ( reset, pulse25M, enable_v_counter, h_count );
    vertical_counter   vga_v ( reset, pulse25M, enable_v_counter, v_count );

	//h_sync and v_sync timing
	assign h_sync = ((h_count > H_FRONT_PORCH - 1'b1) && (h_count < H_FRONT_PORCH + H_SYNC )) ? 1'b0 : 1'b1;
   	assign v_sync = ((v_count > V_FRONT_PORCH - 1'b1) && (v_count < V_FRONT_PORCH + V_SYNC )) ? 1'b1 : 1'b0;
	
	assign flash   = {3{fl & pulse05H}};
	assign reverse = {3{rev}};

	assign left  = H_NON_VISIBLE - 1 + H_PIXELS/2 - width/2;
	assign right = H_NON_VISIBLE + H_PIXELS/2     + width/2;
	assign upper = V_NON_VISIBLE - 1 + V_ROWS/2   - height/2;
	assign down  = V_NON_VISIBLE + V_ROWS/2       + height/2;

	assign red   = (
			((h_count > left - 5) && (h_count < right + 5) && (((v_count > upper - 5) && v_count <= upper) || ((v_count < down + 5) && v_count >= down))) ||
			((v_count > upper - 5) && (v_count < down + 5) && (((h_count > left - 5) && h_count <= left) || ((h_count < right + 5) && h_count >= right)))) ? (3'd7) ^ reverse ^ flash : (h_count >= H_NON_VISIBLE && v_count >= V_NON_VISIBLE) ? 3'd0 ^ reverse : 3'd0; 
                
	assign blue  = (
			((h_count > left - 5) && (h_count < right + 5) && (((v_count > upper - 5) && v_count <= upper) || ((v_count < down + 5) && v_count >= down))) ||
			((v_count > upper - 5) && (v_count < down + 5) && (((h_count > left - 5) && h_count <= left) || ((h_count < right + 5) && h_count >= right)))) ? (3'd7) ^ reverse ^ flash : (h_count >= H_NON_VISIBLE && v_count >= V_NON_VISIBLE) ? 3'd0 ^ reverse : 3'd0; 
    
	assign green = (
			((h_count > left - 5) && (h_count < right + 5) && (((v_count > upper - 5) && v_count <= upper) || ((v_count < down + 5) && v_count >= down))) ||
			((v_count > upper - 5) && (v_count < down + 5) && (((h_count > left - 5) && h_count <= left) || ((h_count < right + 5) && h_count >= right)))) ? (3'd7) ^ reverse ^ flash : (h_count >= H_NON_VISIBLE && v_count >= V_NON_VISIBLE) ? 3'd0 ^ reverse : 3'd0; 
	   	   
endmodule	
