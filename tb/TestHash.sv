module Test;

reg clk = 1'b0;
always #10 clk = !clk;

reg rst_n = 1'b0;
event reset_deassertion;
  
  

reg M_valid;
reg hash_ready;
reg [63 : 0] C_in;
reg [7 : 0] M;
reg [31 : 0] digest;
reg [7 : 0] txt [0 : 27];

fullHashDES test_hash (
     .clk           (clk)
    ,.rst_n         (rst_n)
    ,.M_valid		(M_valid)
    ,.C_in 			(C_in)  
    ,.M 			(M)
    ,.hash_ready 	(hash_ready)
    ,.digest_final 		(digest)
  );
  


logic [0 : 31] i;  


initial begin
	#12.8 rst_n = 1'b1;
	-> reset_deassertion;
end

initial begin

C_in = 64'd28;

txt[0] = 8'b01001101;
txt[1] = 8'b01100101;
txt[2] = 8'b01110011;
txt[3] = 8'b01110011;
txt[4] = 8'b01100001;
txt[5] = 8'b01100111;
txt[6] = 8'b01100111;
txt[7] = 8'b01101001;
txt[8] = 8'b01101111;
txt[9] = 8'b00100000;
txt[10] = 8'b01101001;
txt[11] = 8'b01101110;
txt[12] = 8'b00100000;
txt[13] = 8'b01100011;
txt[14] = 8'b01101000;
txt[15] = 8'b01101001;
txt[16] = 8'b01100001;
txt[17] = 8'b01110010;
txt[18] = 8'b01101111;
txt[19] = 8'b00100000;
txt[20] = 8'b01100100;
txt[21] = 8'b01101001;
txt[22] = 8'b00100000;
txt[23] = 8'b01110000;
txt[24] = 8'b01110010;
txt[25] = 8'b01101111;
txt[26] = 8'b01110110;
txt[27] = 8'b01100001;


fork

	begin: TEST1
		M_valid = 1'b0;
		
		@(reset_deassertion);
		@(posedge clk);
		
		for(i=0;i<C_in;i++)begin
			M_valid = 1'b1;
			M = txt[i];
			@(posedge clk);
			//M_valid = 1'b0;
			//@(posedge clk);
		end


		M_valid = 1'b0;

		@(posedge clk);
		@(posedge clk);

		if(hash_ready)begin
			$display("Digest: %b", digest);
		end

			
	
	end:TEST1
join

$stop;

end

endmodule
// -----------------------------------------------------------------------------

// 1001 0101 1100 0101 1000 0111 1101 0111

// 1111 0110 0101 1100 1110 1011 0100 0000




/*module Test;
	
	reg [3 : 0] H_main [0 : 7];
	reg [31 : 0] digest;
	reg [63 : 0] C;

	localparam h0_value = 4'h4;
	localparam h1_value = 4'hB;
	localparam h2_value = 4'h7;
	localparam h3_value = 4'h1;
	localparam h4_value = 4'hD;
	localparam h5_value = 4'hF;
	localparam h6_value = 4'h0;
	localparam h7_value = 4'h3;

	hashRound_final h_final(
		.C (C),
    	.h(H_main),
    	.digest(digest)
	);

	
	initial begin


	fork

		begin: TEST1
			C = 64'd0;
			H_main[0] = h0_value;
			H_main[1] = h1_value;
			H_main[2] = h2_value;
			H_main[3] = h3_value;
			H_main[4] = h4_value;
			H_main[5] = h5_value;
			H_main[6] = h6_value;
			H_main[7] = h7_value;		
			$display("digest: %b", digest);


		end:TEST1
	join

	end


endmodule*/

