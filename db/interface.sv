
module fullHashDES (
    input clk,
    input M_valid,
    input rst_n,
    input [63 : 0] C_in, //length 
    input [7 : 0] M,
    output reg hash_ready,
    output reg [32 : 0] digest
);
//constants 
localparam h0_value = 4'h4;
localparam h1_value = 4'hB;
localparam h2_value = 4'h7;
localparam h3_value = 4'h1;
localparam h4_value = 4'hD;
localparam h5_value = 4'hF;
localparam h6_value = 4'h0;
localparam h7_value = 4'h3;

//how much message byte has been processed at given moment
reg [63 : 0] counter;
//to save input message length
reg [63 : 0] C;
//to store h[i] values
reg [3 : 0] h [0 : 7]; 
//circuit state
reg state;
//message reduction to 6 bit
wire [5 : 0] M6;
//s-box input at last round
wire [5 : 0] C6 [0 : 7];
//to store h[i] values
wire [3 : 0] H_main_w_o [0 : 7];
reg [3 : 0] H_main [0 : 7];


hashRound hashRound_i (
    .idx (M6),
    .h (H_main ),
    .h_out(H_main_w_o)
);
/*hashRound_final hashRound_f(
    .idx (C6),
    .h(H_main),
    .h_out(digest)
)*/
localparam h0_value = 4'h4;
localparam h1_value = 4'hB;
localparam h2_value = 4'h7;
localparam h3_value = 4'h1;
localparam h4_value = 4'hD;
localparam h5_value = 4'hF;
localparam h6_value = 4'h0;
localparam h7_value = 4'h3;



assign M6 = {M[3] ^ M[2],M[1],M[0],M[7],M[6],M[5] ^ M[4]};

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
            counter <= 0;
            hash_ready <= 0;
            state <= 0;
            H_main[0] <= h0_value;
            H_main[1] <= h1_value;
            H_main[2] <= h2_value;
            H_main[3] <= h3_value;
            H_main[4] <= h4_value;
            H_main[5] <= h5_value;
            H_main[6] <= h6_value;
            H_main[7] <= h7_value;
    end else if(!state && M_valid) begin
        counter <= C_in - 1'd1;
        C <= C_in;
        H_main <= H_main_w_o;
    end else if(!state && M_valid && counter > 1'd0) begin
        counter <= counter - 1'd1;
        H_main <= H_main_w_o;
    end else if(state && counter === 1'd0) //test final round
        digest <= H_main;
        counter <= 0;
        state <= 0;
        H_main[0] <= h0_value;
        H_main[1] <= h1_value;
        H_main[2] <= h2_value;
        H_main[3] <= h3_value;
        H_main[4] <= h4_value;
        H_main[5] <= h5_value;
        H_main[6] <= h6_value;
        H_main[7] <= h7_value;

        hash_ready = 1'd1; //after other assign
 end




    
endmodule


module Sbox (
    input [5 : 0] in,
    output reg [3 : 0] out
);
    //
    reg [1 : 0] row ;
    reg [3 : 0] colum;
    /*assign row = {in[5], in[0]};
    assign colum = in[4 : 1]; if decleare them wire */
    always @(*) begin
          row = {in[5], in[0]};
          colum = in[4 : 1];
        /*assign row = {in[5], in[0]}
        assign colum = in[4 : 1 ];*/
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
            4'b0010 : case (row)
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
    

module hashRound (
    input [5 : 0] idx, //S-box input
    input [3 : 0] h [0 : 7],
    output reg [3 : 0] h_out [0 : 7] //8 signal of 4 bits
);
wire [3 : 0] s_value;
reg [3 : 0] tmp;
Sbox sbox (
    .in (idx),
    .out(s_value)
);
    always @(*) begin
        //h[0]
        tmp = h[1] ^ s_value;
        h_out[0] = tmp;
        //h[1]
        tmp = h[2] ^ s_value;
        h_out[1] = tmp;
        //h[2]
        tmp = h[3] ^ s_value;
        h_out[2] = tmp << 1;
        //3
        tmp = h[4] ^ s_value;
        h_out[3] = tmp << 1;
        //4
        tmp = h[5] ^ s_value;
        h_out[4] = tmp << 2;
        //5
        tmp = h[6] ^ s_value;
        h_out[5] = tmp << 2;
        //6
        tmp = h[7] ^ s_value;
        h_out[6] = tmp << 3;
        //7
        tmp = h[0] ^ s_value;
        h_out[7] = tmp << 3;
        
    end
endmodule

/*module hashRound_final (
    input [5 : 0] idx [0 : 7], //S-box input
    input [3 : 0] h [0 : 7],
    output [3 : 0] h_out [0 : 7] //8 signal of 4 bits
);
    
endmodule*/
