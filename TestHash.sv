module Test;

  reg clk = 1'b0;
  always #10 clk = !clk;
  
  reg rst_n = 1'b0;
  event reset_deassertion;
  
  
  

reg M_valid;
reg hash_ready;
reg [63 : 0] C_in;
reg [7 : 0] M;
reg [32 : 0] digest;

  fullHash test_hash (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.M_valid			(M_valid)
    ,.C_in 			(C_in)  
    ,.M 			(M)
    ,.hash_ready 		(hash_ready)
    ,.digest 			(digest)
  );
  


logic [0 : 31] i;  



initial begin

#12.8 rst_n = 1'b1;
-> reset_deassertion;
$display("inizio");
M_valid = 1'b1;

C_in = 4'd15;

fork

begin: TEST1
@(reset_deassertion);
@(posedge clk);

for(i=0;i<15;i++)begin
	M = i;
	$display("M: %b",M);
	
end
end:TEST1

join

fork
begin:CHECK1
@(posedge clk);

if(hash_ready)begin
	$display("Digest: %b", digest);
end

end:CHECK1

join

$stop;

end

endmodule
// -----------------------------------------------------------------------------


