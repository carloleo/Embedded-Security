/*
    messaggio vuoto
    messaggio in input coninuo e con pausa 
    stesso messaggio stessa digest consecutivamente
    diverso messaggio diversa digest
    variabalità hash -> messaggio con 1 byte in meno -> digest differente
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

fullHashDES test_hash (
     .clk           (clk)
    ,.rst_n         (rst_n)
    ,.M_valid		(M_valid)
    ,.C_in 			(C_in)  
    ,.M 			(M)
    ,.hash_ready 	(hash_ready)
    ,.digest_final 		(digest)
  );

    initial begin
        #12.8 rst_n = 1'b1;
        -> reset_deassertion;
    end

    initial begin
        //inizializzazione delle variabili
        reg [63 : 0] compare;
        logic[8:0] i = 0;
        /*begin: TEST_EMPTY
            @(reset_deassertion);
            @(posedge clk);
            M_valid = 1'b1;
            C_in = 64'd0;
            @(posedge clk);
            M_valid = 1'b0;
            @(posedge clk);
            if(hash_ready)begin
                $display("Digest: %b", digest);
            end
        end:  TEST_EMPTY*/

        begin: TEST_ONE_CHAR
            //@(reset_deassertion);
            @(posedge clk);
            M_valid = 1'b1;
            C_in = 64'd1;
            M = 8'd65;
            @(posedge clk);
            M_valid = 1'b0;
            @(posedge clk);
            @(posedge clk);
            if(hash_ready)begin
                $display("Digest: %h", digest);
            end
        end: TEST_ONE_CHAR

        begin: TEST_HASH
            $display("SAME MESSAGE SAME HASH BEGIN");
            @(posedge clk);
            C_in = 64'd50;
            for ( i = 0; i < 64'd50 ; i++) begin
                M = i;
                M_valid = 1'b1;
                @(posedge clk);
            end
            M_valid = 1'b0;
            @(posedge clk)
            @(posedge clk)
            if(hash_ready)begin
                $display("FIRST DIGEST %h ", digest);
                compare = digest;
            end
            @(posedge clk);
            C_in = 64'd50;
            for ( i = 0; i < 64'd50 ; i++) begin
                M = i;
                M_valid = 1'b1;
                @(posedge clk)
                M_valid = 1'b0;
                @(posedge clk);
                @(posedge clk);
            end
            M_valid = 1'b0;
            @(posedge clk);
            @(posedge clk);
            if(hash_ready) begin
                $display("SECOND DIGEST %h", digest);
                $display("result [ %s ]", compare === digest ? "Successful" : "Failure" );
                $display("SAME MESSAGE SAME HASH END");
            end
            @(posedge clk);
            $display("CHANGED MESSAGE CHANGED HASH BEGIN");
            C_in = 64'd49;
            for (i  = 0 ; i < 64'd49 ; i++ ) begin
                M = i;
                M_valid = 1'b1;
                @(posedge clk);
            end
            M_valid = 1'b0;
            @(posedge clk);
            @(posedge clk);
            if(hash_ready) begin
                $display("Digest changed: %h", digest);
                $display("test  %s", compare === digest ? "Failure" : "Successful" );
                $display("CHANGED MESSAGE CHANGED HASH END");
            end
        end: TEST_HASH

        $stop;
    end
endmodule
