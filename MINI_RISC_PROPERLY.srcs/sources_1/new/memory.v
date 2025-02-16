`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.02.2025 09:26:39
// Design Name: 
// Module Name: memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module memory 
  # (parameter ADDR_WIDTH = 11,  // adress is 11 bits
     parameter DATA_WIDTH = 16,  // data is 16 bits
     // 4Kb memory with 16 bit word size implies 2048 words (2^11)
     parameter DEPTH = 2**ADDR_WIDTH     
    )
  (
  input clk,
  input write_en,
  input [ADDR_WIDTH-1:0] address,
  input [DATA_WIDTH-1:0] data_in,
  output [DATA_WIDTH-1:0] read_data
  );  

  reg [DATA_WIDTH-1:0] mem[0:DEPTH-1]; // 11 bits to index
  
  
  assign read_data = mem[address];
	always @(posedge clk) begin
    if (write_en)
      mem[address] <= data_in;
	end


 endmodule 
