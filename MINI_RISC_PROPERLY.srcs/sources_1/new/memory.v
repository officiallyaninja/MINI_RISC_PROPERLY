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

module memory (
    input clk,
    input write_en,
    input [ADDR_WIDTH-1:0] address,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] read_data
);
  `include "parameters.v"

  reg [DATA_WIDTH-1:0] mem[0:MEMORY_DEPTH-1];  // 11 bits to index


  assign read_data = mem[address];
  always @(posedge clk) begin
    if (write_en) mem[address] <= data_in;
  end


endmodule
