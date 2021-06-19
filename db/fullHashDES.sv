    /*
    * @brief: main module 
    */
    
    module fullHashDES(
        input clk,
        input M_valid,
        input rst_n,
        input [63 : 0] C_in, 
        input [7 : 0] M,
        output reg hash_ready,
        output reg [31 : 0] digest_out
    );
    //digest init values
    localparam h0_value = 4'h4;
    localparam h1_value = 4'hB;
    localparam h2_value = 4'h7;
    localparam h3_value = 4'h1;
    localparam h4_value = 4'hD;
    localparam h5_value = 4'hF;
    localparam h6_value = 4'h0;
    localparam h7_value = 4'h3;

    //remaining bytes to process
    reg [63 : 0] counter;
    //store input message length
    reg [63 : 0] C;
    //determines if the circuit waits for a new message or a new byte of the current one
    reg state;
    //store message byte to process
    reg [7 : 0] M_r;
    //feedback wire
    wire [7 : 0] [3 : 0] H_main_w_o;
    //contain hash chunks bits
    reg [7 : 0] [3 : 0]  H_main;
    //contain result of hashRound_final instance
    reg [31 : 0] digest;
    //store M_valid to know if the mainHashIteration result on M_r has to be considerd valid 
    reg M_valid_r;

    //control signals
    assign compute_state = counter > 0 && state === 1;
    assign init_state = state === 0 && M_valid;
    assign final_state = state === 1 && counter === 0;  



    mainHashIteration main(
        .M(M_r), 
        .h(H_main),
        .h_out(H_main_w_o)
    );

    
    hashRound_final hashRound_f(
        .C (C), 
        .h(H_main), 
        .digest(digest)
    );


    //state machine 
    always @(posedge clk or negedge rst_n) begin
        
        if (!rst_n) begin //set idle state
            hash_ready <= 0;
            state <= 0;
        end else if(init_state) begin //initializing digest computation
            counter <= C_in;
            C <= C_in;
            state <= 1;
            hash_ready <= 0;
            M_r <= M;
            M_valid_r <= M_valid;
            H_main[0] <= h0_value;
            H_main[1] <= h1_value;
            H_main[2] <= h2_value;
            H_main[3] <= h3_value;
            H_main[4] <= h4_value;
            H_main[5] <= h5_value;
            H_main[6] <= h6_value;
            H_main[7] <= h7_value;
        end else if(compute_state) begin 
            if(M_valid_r === 1)begin //if sampled message byte is valid then hash function chunks are updated
                counter <= counter - 1; 
                H_main <= H_main_w_o;
            end
            M_r <= M; //keep sampling
            M_valid_r <= M_valid;
        end else if(final_state) begin //sampling hashRound_f result and set the output as ready
            hash_ready <= 1; 
            state <= 0;
            digest_out <= digest;
        end else begin //nop
            #0;
        end
    end
endmodule

/*
* @brief: DES s-box implementation 
*/
module Sbox (
    input [5 : 0] in,
    output reg [3 : 0] out
);
    reg [1 : 0] row ;
    reg [3 : 0] colum;
    always @(*) begin
        row = {in[5], in[0]};
        colum = in[4 : 1];
        case (colum)
            4'b0000 : case (row)
                        2'b00 :  out = 4'b0010; 
                        2'b01 :  out = 4'b1110;
                        2'b10 :  out = 4'b0100;
                        2'b11 :  out = 4'b1011;
                    endcase
            4'b0001 : case (row)
                        2'b00 :  out = 4'b1100; 
                        2'b01 :  out = 4'b1011;
                        2'b10 :  out = 4'b0010;
                        2'b11 :  out = 4'b1000;
                    endcase
            4'b0010 : case (row)
                        2'b00 :  out = 4'b0100; 
                        2'b01 :  out = 4'b0010;
                        2'b10 :  out = 4'b0001;
                        2'b11 :  out = 4'b1100;
                    endcase
            4'b0011 : case (row)
                        2'b00 :  out = 4'b0001; 
                        2'b01 :  out = 4'b1100;
                        2'b10 :  out = 4'b1011;
                        2'b11 :  out = 4'b0111;
                    endcase
            4'b0100 : case (row)
                        2'b00 :  out = 4'b0111;
                        2'b01 :  out = 4'b0100;
                        2'b10 :  out = 4'b1100;
                        2'b11 :  out = 4'b0001;
                    endcase
            4'b0101 : case (row)
                        2'b00 :  out = 4'b1010; 
                        2'b01 :  out = 4'b0111;
                        2'b10 :  out = 4'b1101;
                        2'b11 :  out = 4'b1110;
                    endcase
            4'b0110 : case (row)
                        2'b00 :  out = 4'b1011;
                        2'b01 :  out = 4'b1101;
                        2'b10 :  out = 4'b0111;
                        2'b11 :  out = 4'b0010;
                    endcase
            4'b0111 : case (row)
                        2'b00 :  out = 4'b0110;
                        2'b01 :  out = 4'b0001;
                        2'b10 :  out = 4'b1000;
                        2'b11 :  out = 4'b1101;
                    endcase
            4'b1000 : case (row)
                        2'b00 :  out = 4'b1000; 
                        2'b01 :  out = 4'b0101;
                        2'b10 :  out = 4'b1111;
                        2'b11 :  out = 4'b0110;
                    endcase
            4'b1001 : case (row)
                        2'b00 :  out = 4'b0101;
                        2'b01 :  out = 4'b0000;
                        2'b10 :  out = 4'b1001;
                        2'b11 :  out = 4'b1111;
                    endcase
            4'b1010 : case (row)
                        2'b00 :  out = 4'b0011;
                        2'b01 :  out = 4'b1111;
                        2'b10 :  out = 4'b1100;
                        2'b11 :  out = 4'b0000;
                    endcase
            4'b1011 : case (row)
                        2'b00 :  out = 4'b1111; 
                        2'b01 :  out = 4'b1100;
                        2'b10 :  out = 4'b0101;
                        2'b11 :  out = 4'b1001;
                    endcase
            4'b1100 :  case (row)
                        2'b00 :  out = 4'b1101;
                        2'b01 :  out = 4'b0011;
                        2'b10 :  out = 4'b0110;
                        2'b11 :  out = 4'b1100;
                    endcase
            4'b1101 :  case (row)
                        2'b00 :  out = 4'b0000; 
                        2'b01 :  out = 4'b1001;
                        2'b10 :  out = 4'b0011;
                        2'b11 :  out = 4'b0100;
                    endcase
            4'b1110 : case (row)
                        2'b00 :  out = 4'b1110; 
                        2'b01 :  out = 4'b1000;
                        2'b10 :  out = 4'b0000;
                        2'b11 :  out = 4'b0101;
                    endcase
            4'b1111 : case (row)
                        2'b00 :  out = 4'b1001;
                        2'b01 :  out = 4'b0110;
                        2'b10 :  out = 4'b1110;
                        2'b11 :  out = 4'b0011;
                    endcase 
        endcase
    end
endmodule


/*
* @brief: compute main round
*/
module hashRound (
    input [3 : 0] s_value, //Sbox output
    input [7 : 0] [3 : 0] h, //hash values of previous round
    output reg [7 : 0] [3 : 0]  h_out //hash values of current round
);

reg [3 : 0] tmp; 

    always @(*) begin
           
        //h[0]
        tmp = h[1] ^ s_value;
        h_out[0] = tmp;
        //h[1]
        tmp = h[2] ^ s_value;
        h_out[1] = tmp;
        //h[2]
        tmp = h[3] ^ s_value;
        h_out[2] = (tmp << 1) | (tmp >> 3);
        //h[3]
        tmp = h[4] ^ s_value;
        h_out[3] = (tmp << 1) | (tmp >> 3);
        //h[4]
        tmp = h[5] ^ s_value;
        h_out[4] = (tmp << 2) | (tmp >> 2);
        //h[5]
        tmp = h[6] ^ s_value;
        h_out[5] = (tmp << 2) | (tmp >> 2);
        //h[6]
        tmp = h[7] ^ s_value;
        h_out[6] = (tmp << 3) | (tmp >> 1);
        //h[7]      
        tmp = h[0] ^ s_value;
        h_out[7] = (tmp << 3) | (tmp >> 1);
        
    end
endmodule


/*
*   @brief: compute final round
*/
module hashRound_final (
    input [63 : 0] C, //message size 
    input [7 : 0] [3 : 0] h, //main hash iterations result values 
    output reg [31 : 0] digest //final digest
);
reg [7 : 0] [3 : 0]  s_value;
reg [7 : 0] Ci;
reg [7 : 0] [5 : 0] idx ;
reg [3 : 0] tmp;
reg [7 : 0] [3 : 0] h_out;

Sbox sbox1 (
    .in (idx[0]),
    .out(s_value[0])
);

Sbox sbox2 (
    .in (idx[1]),
    .out(s_value[1])
);

Sbox sbox3 (
    .in (idx[2]),
    .out(s_value[2])
);

Sbox sbox4 (
    .in (idx[3]),
    .out(s_value[3])
);

Sbox sbox5 (
    .in (idx[4]),
    .out(s_value[4])
);

Sbox sbox6 (
    .in (idx[5]),
    .out(s_value[5])
);

Sbox sbox7 (
    .in (idx[6]),
    .out(s_value[6])
);

Sbox sbox8 (
    .in (idx[7]),
    .out(s_value[7])
);

    always @(*) begin
        //h[0]
        Ci = C[63 : 56];
        idx[0] = {Ci[7] ^ Ci[1], Ci[3], Ci[2], Ci[5] ^ Ci[0], Ci[4], Ci[6]};
        tmp = h[1] ^ s_value[0];
        h_out[0] = tmp;
        //h[1]
        Ci = C[55 : 48];
        idx[1] = {Ci[7] ^ Ci[1], Ci[3], Ci[2], Ci[5] ^ Ci[0], Ci[4], Ci[6]};
        tmp = h[2] ^ s_value[1];
        h_out[1] = tmp;
        //h[2]
        Ci = C[47 : 40];
        idx[2] = {Ci[7] ^ Ci[1], Ci[3], Ci[2], Ci[5] ^ Ci[0], Ci[4], Ci[6]};
        tmp = h[3] ^ s_value[2];
        h_out[2] = (tmp << 1) | (tmp >> 3);
        //h[3]
        Ci = C[39 : 32];
        idx[3] = {Ci[7] ^ Ci[1], Ci[3], Ci[2], Ci[5] ^ Ci[0], Ci[4], Ci[6]};
        tmp = h[4] ^ s_value[3];
        h_out[3] = (tmp << 1) | (tmp >> 3);
        //h[4]
        Ci = C[31 : 24];
        idx[4] = {Ci[7] ^ Ci[1], Ci[3], Ci[2], Ci[5] ^ Ci[0], Ci[4], Ci[6]};
        tmp = h[5] ^ s_value[4];
        h_out[4] = (tmp << 2) | (tmp >> 2);
        //h[5]
        Ci = C[23 : 16];
        idx[5] = {Ci[7] ^ Ci[1], Ci[3], Ci[2], Ci[5] ^ Ci[0], Ci[4], Ci[6]};
        tmp = h[6] ^ s_value[5];
        h_out[5] = (tmp << 2) | (tmp >> 2);
        //h[6]
        Ci = C[15 : 8];
        idx[6] = {Ci[7] ^ Ci[1], Ci[3], Ci[2], Ci[5] ^ Ci[0], Ci[4], Ci[6]};
        tmp = h[7] ^ s_value[6];
        h_out[6] = (tmp << 3) | (tmp >> 1);
        //h[7] 
        Ci = C[7 : 0];
        idx[7] = {Ci[7] ^ Ci[1], Ci[3], Ci[2], Ci[5] ^ Ci[0], Ci[4], Ci[6]};     
        tmp = h[0] ^ s_value[7];
        h_out[7] = (tmp << 3) | (tmp >> 1);
        digest = {h_out[0], h_out[1], h_out[2], h_out[3], h_out[4], h_out[5], h_out[6], h_out[7]};
       

    end


endmodule

/*
* @brief: compute four iteration of main round
*/
module mainHashIteration (
    input [7 : 0] M,
    input [7 : 0] [3 : 0] h,
    output [7 : 0] [3 : 0] h_out
);

reg [3 : 0] s_value;
wire [5 : 0] M6;
assign M6 = {M[3] ^ M[2], M[1], M[0], M[7], M[6], M[5] ^ M[4]};
Sbox sbox(
    .in (M6),
    .out (s_value)
);

wire [7 : 0] [3 : 0] h1_out;

hashRound round1 (
    .s_value(s_value),
    .h(h),
    .h_out(h1_out)

);
wire [7 : 0] [3 : 0] h2_out;

hashRound round2 (
    .s_value(s_value),
    .h(h1_out),
    .h_out(h2_out)
);

wire [7 : 0] [3 : 0] h3_out;

hashRound round3 (
    .s_value(s_value),
    .h(h2_out),
    .h_out(h3_out)

);

hashRound round4 (
    .s_value(s_value),
    .h(h3_out),
    .h_out(h_out)
);

    
endmodule