`timescale 1ns / 1ps

module tb_floating;

  reg clk=0;
  reg [31:0] bolunen;
  reg [31:0] bolen;
  wire [31:0] sonuc;

  floating uut (
    .clk(clk),
    .bolunen(bolunen),
    .bolen(bolen),
    .sonuc(sonuc)
    );

   always begin
    #10 clk = ~clk; 
   end

    initial begin
    bolunen = 32'b1_10000011_01000000000000000000000; 
    bolen   = 32'b0_10000001_01000000000000000000000;
    #4000;

    bolunen = 32'b0_10000011_00001010101010101010101; //16.6
    bolen   = 32'b0_10000000_10000000000000000000000; //3
    #4000;

    bolunen = 32'b0_10001000_00101000000000000000000; //592
    bolen   = 32'b0_01111100_10011001100110011001101; //0.2
    #4000;

    bolunen = 32'b1_10000011_10010000000000000000000; //-25
    bolen   = 32'b1_10000000_10000000000000000000000; //-3
    #4000;

    bolunen = 32'b0_00000000_00000000000000000000000; //0
    bolen   = 32'b1_10000010_10000000000000000000000; //-12
    #4000;

    end
endmodule