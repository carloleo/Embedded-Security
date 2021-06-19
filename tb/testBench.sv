/*
* module test 
*/

module testBench;

reg clk = 1'b0;
always #10 clk = !clk;

reg rst_n = 1'b0;
event reset_deassertion;

reg M_valid;
reg hash_ready;
reg [63 : 0] C_in;
reg [7 : 0] M;
reg [31 : 0] digest;

//module instancing
fullHashDES test_hash (
     .clk           (clk)
    ,.rst_n         (rst_n)
    ,.M_valid		(M_valid)
    ,.C_in 			(C_in)  
    ,.M 			(M)
    ,.hash_ready 	(hash_ready)
    ,.digest_out 		(digest)
  );

    initial begin
        #12.8 rst_n = 1'b1;
        -> reset_deassertion;
    end

    initial begin
        //utility 
        reg [63 : 0] compare;
        logic[15:0] i;
        //expected values
        localparam expected_empty_digest = 32'h956F7883 ;
        localparam expected_digest = 32'h2dd99066;
        begin: TEST_EMPTY
            $display("EMPTY TEST BEGIN");
            @(reset_deassertion); //waiting for reset deassertion
            @(posedge clk); //wainting for positive clock edge
            M_valid = 1'b1;
            C_in = 64'd0;
            @(posedge clk);
            M_valid = 1'b0;
            @(posedge clk);
            @(posedge clk);
            if(hash_ready)begin //testing of expected behaviour the digest must be ready
                $display("Digest empty test: %h", digest);
                $display("test result [ %s ] ", expected_empty_digest === digest ? "Successful" : "Failure" );
                $display("EMPTY TEST END");
            end
        end:  TEST_EMPTY
        begin: TEST_ONE_CHAR
            $display("ONE CHAR TEST BEGIN");
            @(posedge clk);
            M_valid = 1'b1;
            C_in = 64'd1;
            M = 8'd65; // A
            @(posedge clk);
            M_valid = 1'b0;
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            if(hash_ready)begin //testing of expected behaviour the digest must be ready
                $display("Digest one char test: %h", digest); //expected digest pre-computed value by paper and pen
                $display("test result [ %s ] ", expected_digest === digest ? "Successful" : "Failure" );
            end
            $display("ONE CHAR TEST END");
        end: TEST_ONE_CHAR 

        begin: TEST_HASH
            $display("SAME MESSAGE SAME HASH BEGIN");
            @(posedge clk);
            C_in = 64'd756;
            for (i = 0; i < C_in ; i++) begin
                M = i;
                M_valid = 1'b1;
                @(posedge clk);
            end
            M_valid = 1'b0;
            @(posedge clk)
            @(posedge clk)
            @(posedge clk);
            if(hash_ready)begin //testing of expected behaviour the digest must be ready
                $display("FIRST DIGEST %h ", digest);
                compare = digest;
            end
            @(posedge clk);
            C_in = 64'd756; 
            for ( i = 0; i < C_in ; i++) begin 
                M = i;
                M_valid = 1'b1;
                @(posedge clk)
                M_valid = 1'b0;
                @(posedge clk);
                @(posedge clk);
            end
             @(posedge clk);
            if(hash_ready) begin//testing of expected behaviour the digest must be ready
                $display("SECOND DIGEST %h", digest); //same digest expected
                $display("test result [ %s ]", compare === digest ? "Successful" : "Failure" );
                $display("SAME MESSAGE SAME HASH END");
            end
            @(posedge clk);
            $display("CHANGED MESSAGE CHANGED HASH BEGIN");
            C_in = 64'd755;//one message byte is being changed
            for (i  = 0 ; i < C_in ; i++ ) begin
                M = i;
                M_valid = 1'b1;
                @(posedge clk);
            end
            M_valid = 1'b0;
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            if(hash_ready) begin //testing of expected behaviour the digest must be ready
                $display("DIGEST CHANGED: %h", digest);//different hash expected
                $display("test result  [ %s ]", compare === digest ? "Failure" : "Successful" );
                $display("CHANGED MESSAGE CHANGED HASH END");
            end
        end: TEST_HASH
        begin: TEST_LONG_MESSAGE
            $display("LONG_MESSAGE BEGIN");
            @(posedge clk);
            C_in = 64'd5073;
            M_valid = 1'b1;
            for (i  = 0 ; i < C_in ; i++ ) begin
                M = i;
                @(posedge clk);
            end
            M_valid = 1'b0;
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            if(hash_ready) begin //testing of expected behaviour the digest must be ready
                $display("Digest computed: %h", digest);
                $display("LONG_MESSAGE END");
            end
        end:  TEST_LONG_MESSAGE
        $stop;
    end
endmodule
