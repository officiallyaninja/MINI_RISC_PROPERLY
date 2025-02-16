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


module ALU_with_reg_tb;

  `include "parameters.v"
  reg clk;
  //ALU
  reg [4:0] opcode; 	// from instruction register
  reg [3:0] bit_position;	// set the bit in the postion given by this input

  wire [15:0] operand_1; 	// reg_arg_2 in control unit
  wire [15:0] operand_2; 	// reg_arg_3 in control unit

  // Reg file
  reg [15:0] result_0; 	// to the data_in_0
  reg [15:0] result_1; 	// to the data_in_1
  reg [15:0] flag_reg;

  reg [1:0] write_en;		// Read/ Write signal, conected to control unit
  reg [2:0] read_addr_0;	// Register Select for reading data, read port 0
  reg [2:0] read_addr_1;	// Register Select for reading data, read port 1
  reg [2:0] reg_write_addr_0;	// Register Select for writing data 
  reg [2:0] reg_write_addr_1;	// Register Select for writing data 
  ALU alu (
    .clk(clk),
    .opcode(opcode),
    .operand_1(operand_1),
    .operand_2(operand_2),
    .bit_position(bit_position),
    .result_0(result_0),
    .result_1(result_1),
    .flag_reg(flag_reg)
  );
 reg_file reg_file (
  .clk(clk),
  .rst(0),
  .write_en(write_en),
  .read_addr_0(read_addr_0),
  .read_addr_1(read_addr_1),
  .reg_write_addr_0(reg_write_addr_0),
  .reg_write_addr_1(reg_write_addr_1),
  .data_in_0(result_1),
  .data_in_1(result_1),
  .read_data_0(operand_1),
  .read_data_1(operand_2)
);

  integer num_failures;
  initial begin
      num_failures = 0;
      clk = 0;
      forever #5 clk = ~clk;
  end
  
  // Test stimulus
  initial begin
    //expect to be false
    verify_reg_val(REG0, 1);
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
        num_failures = num_failures + 1;
        $display("expected %h, but got %h", expected, operand_1);
      end
    end
  endtask


  task do_op;
    input [1:0] en;
    input [4:0] op_c;
    input [2:0] reg1;
    input [2:0] reg2;
    input [2:0] res1;
    input [2:0] res2;
    begin
      write_en <= en;
      opcode <= op_c;
      read_addr_0 <= reg1;
      read_addr_1 <= reg2;
      reg_write_addr_0 <= res1;
      reg_write_addr_1 <= res2;
    end 
  endtask

endmodule

