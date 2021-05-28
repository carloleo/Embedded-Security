
module ivan_fhash_checks;

  reg clk = 1'b0;
  always #5 clk = !clk;
  
  reg rst_n = 1'b0;
  event reset_deassertion;
  
  initial begin
    #12.8 rst_n = 1'b1;
    -> reset_deassertion;
  end
  
  reg M_valid;
  wire hash_ready;
  reg [63 : 0] C_in;
  reg [7 : 0] M;
  wire [32 : 0] digest_out;


fullHashDES full_hash(
    .clk (clk),
    .M_valid (M_valid),
    .rst_n (rst_n),
    .C_in (C_in),  
    .M (M),
    .hash_ready (hash_ready),
    .digest (digest_out)
);
  
reg [32 : 0] digest1;
reg [32 : 0] digest2;
reg [32 : 0] digest3;
reg [32 : 0] digest4;
reg [32 : 0] digest5;
  
  
  initial begin
    @(reset_deassertion);
  
    
    begin: STIMULI_1R
      C_in = 1'd26;
      for(byte i = 1'b0; i < 26; i++) begin
        M = i;
        M_valid = 1'b1;
      end

      @(posedge clk);
        if (hash_ready) begin
          digest1 = digest_out;
        end

      C_in = 1'd25;
      for(byte i = 1'b0; i < 25; i++) begin
        M = i;
        M_valid = 1'b1;
      end

      @(posedge clk);
        if (hash_ready) begin
          digest2 = digest_out;
        end

      C_in = 1'd26;
      for(byte i = 1'b0; i < 26; i++) begin
        M = i;
        M_valid = 1'b1;
      end

      @(posedge clk);
        if (hash_ready) begin
          digest3 = digest_out;
        end
    end: STIMULI_1R
    
    begin: CHECK_1R
      @(posedge clk);
      $display("digest1 %b %b %b %b %b %b %b %b", digest1[0], digest1[1], digest1[2], digest1[3], digest1[4], digest1[5], digest1[6], digest1[7]);
      $display("digest2 %b %b %b %b %b %b %b %b", digest2[0], digest2[1], digest2[2], digest2[3], digest2[4], digest2[5], digest2[6], digest2[7]);
      $display("digest3 %b %b %b %b %b %b %b %b", digest3[0], digest3[1], digest3[2], digest3[3], digest3[4], digest3[5], digest3[6], digest3[7]);
    end: CHECK_1R


    begin: STIMULI_2R

        C_in = 1'd10;
        for(byte i = 1'b0; i < 20; i= i + 2) begin
          M = i;
          M_valid = 1'b1;
        end

        @(posedge clk);
          if (hash_ready) begin
            digest4 = digest_out;
          end
        
        
        C_in = 1'd10;
        for(byte i = 1'b0; i < 20; i++) begin
          M = i;
          M_valid = ~i[0];
        end

        @(posedge clk);
          if (hash_ready) begin
            digest5 = digest_out;
            M_valid = 1'b0;
          end

        
    end: STIMULI_2R
    
    begin: CHECK_2R
      @(posedge clk);
      $display("digest4 %b %b %b %b %b %b %b %b", digest4[0], digest4[1], digest4[2], digest4[3], digest4[4], digest4[5], digest4[6], digest4[7]);
      $display("digest5 %b %b %b %b %b %b %b %b", digest5[0], digest5[1], digest5[2], digest5[3], digest5[4], digest5[5], digest5[6], digest5[7]);
    end: CHECK_2R

    begin: STIMULI_3R
        
        byte message [1] = {1'd1};
        C_in = 1'd1;
        for(byte i = 1'b0; i < 20; i= i + 2) begin
          M = i;
          M_valid = 1'b1;
        end

        @(posedge clk);
          if (hash_ready) begin
            digest4 = digest_out;
          end
        
        
    end: STIMULI_3R
    
    begin: CHECK_3R
      @(posedge clk);
      $display("digest4 %b %b %b %b %b %b %b %b", digest4[0], digest4[1], digest4[2], digest4[3], digest4[4], digest4[5], digest4[6], digest4[7]);
    end: CHECK_3R
  end   
endmodule
