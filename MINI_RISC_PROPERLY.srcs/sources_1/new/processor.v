`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 15.02.2025 19:05:46
// Design Name:
// Module Name: ALU_with_reg_tb
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


module processor;

  `include "parameters.v"
  reg clk;
  reg rst;
  //ALU
  reg [4:0] opcode;
  reg [3:0] bit_position;


  wire [15:0] out_0;  // to the data_in_0
  wire [15:0] out_1;  // to the data_in_1
  wire [15:0] flag;

  reg [1:0] write_en;  // Read/ Write signal, conected to control unit
  reg [2:0] read_addr_0;  // Register Select for reading data, read port 0
  reg [2:0] read_addr_1;  // Register Select for reading data, read port 1
  reg [2:0] reg_write_addr_0;  // Register Select for writing data
  reg [2:0] reg_write_addr_1;  // Register Select for writing data

  reg_file reg_file (
      .clk(clk),
      .rst(rst),
      .write_en(write_en),
      .read_addr_0(read_addr_0),
      .read_addr_1(read_addr_1),
      .reg_write_addr_0(reg_write_addr_0),
      .reg_write_addr_1(reg_write_addr_1),
      .data_in_0(out_0),
      .data_in_1(out_1),
      .read_data_0(operand_1),
      .read_data_1(operand_2)
  );

  integer num_failures;
  initial begin
    num_failures = 0;
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test block
  initial begin
    //expect to be false
    verify_reg_val(REG0, 1);
    $display("finished!");
    #1 $finish;
  end

  task verify_reg_val;
    input [2:0] reg_sel;
    input [15:0] expected;
    begin
      write_en <= 0;
      read_addr_0 <= reg_sel;
      read_addr_1 <= reg_sel;
      @(posedge clk);
      if (operand_1 !== expected) begin
        num_failures <= num_failures + 1;
        $display("expected %h, but got %h", expected, operand_1);
      end
    end
  endtask

endmodule
