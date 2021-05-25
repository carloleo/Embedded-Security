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

fullHashDES test_hash (
     .clk           (clk)
    ,.rst_n         (rst_n)
    ,.M_valid		(M_valid)
    ,.C_in 			(C_in)  
    ,.M 			(M)
    ,.hash_ready 	(hash_ready)
    ,.digest 		(digest)
  );
  


logic [0 : 31] i;  


initial begin
	#12.8 rst_n = 1'b1;
	-> reset_deassertion;
end

initial begin

C_in = 64'd50;

fork

	begin: TEST1
		M_valid = 1'b0;
		
		@(reset_deassertion);
		@(posedge clk);
		
		for(i=0;i<C_in;i++)begin
			M_valid = 1'b1;
			M = i;
			@(posedge clk);
			M_valid = 1'b0;
			@(posedge clk);
		end
		
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

