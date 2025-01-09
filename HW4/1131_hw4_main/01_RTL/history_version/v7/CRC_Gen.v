// given 8+3=11 bit dividend, return 3 bit remainder
// generator polynomial = x^3 + x^2 + x
// refernece: https://www.youtube.com/watch?v=AxQi7m-Hrj0
module CRC_Gen(
input   [10:0] crc_dividend_in,
output   [2:0] crc_remainder_out);

assign crc_remainder_out[2] =  crc_dividend_in[9] ^ crc_dividend_in[8] ^ crc_dividend_in[6] ^ crc_dividend_in[5] ^ crc_dividend_in[3] ^ crc_dividend_in[2];
assign crc_remainder_out[1] =  crc_dividend_in[10] ^ crc_dividend_in[9] ^ crc_dividend_in[7] ^ crc_dividend_in[6] ^ crc_dividend_in[4] ^ crc_dividend_in[3] ^ crc_dividend_in[1];
assign crc_remainder_out[0] =  crc_dividend_in[0];

endmodule