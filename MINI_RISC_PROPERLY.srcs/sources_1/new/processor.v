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
  // special regs
  reg clk;
  reg rst;
  reg [15:0] flag;
  reg [15:0] instruction_mem[0:MEMORY_DEPTH-1];  // 11 bits to index
  reg [10:0] branch_reg;

  // alias
  wire [15:0] instruction_reg;
  wire [4:0] opcode;

  wire [7:0] immediate_byte;
  wire [2:0] reg_sel_write_0;
  wire [2:0] reg_sel_read_0;
  wire [2:0] reg_sel_read_1;
 //wire [2:0] reg_sel_write_1


  // connections
  wire [15:0] reg_file_out_0;
  wire [15:0] reg_file_out_1;
  wire [10:0] instruction_addr;

  // assignemtents
  assign immediate_byte = instruction_reg[7:0];
  assign reg_sel_write_0 = instruction_reg[10:8];
  assign reg_sel_read_0 = instruction_reg[7:5];
  assign reg_sel_read_1 = instruction_reg[4:2];
 //assign reg_sel_write_1


  assign instruction_reg = instruction_mem[instruction_addr];
  assign opcode = instruction_reg[15:11];


  //MUXed
  reg [15:0] reg_file_data_in_0;
  reg [0:1] reg_file_write_en_0;



  // control signals
   wire Alu_control;
   wire Alu_output_control;  // always 0 when alu is 0
   wire Reg_bit_control;
   wire Flag_control;
   wire Ram_control;
   wire Reg_control;
   wire Immediate_control;

  control_unit cu (
    .clk(clk),
    .opcode(opcode),
    .Alu(Alu_control),
    .Alu_output(Alu_output_control),  // always 0 when alu is 0
    .Reg_bit(Reg_bit_control),
    .Flag(Flag_control),
    .Ram(Ram_control),
    .Reg(Reg_control),
    .Immediate(Immediate_control)
 );


  program_counter pc (
     .clk(clk),
     .rst(rst),
     .inc(1'b1),
     .branch_en(0),  // TODO
     .branch_addr(branch_reg),
     .current_addr(instruction_addr)
  );

  reg_file reg_file (
      .clk(clk),
      .rst(rst),
      .write_en_0(reg_file_write_en_0), //TODO
      .write_en_1(2'b00), //TODO
      .read_addr_0(reg_sel_read_0),
      .read_addr_1(reg_sel_read_1),
      .reg_write_addr_0(reg_sel_write_0),
      .reg_write_addr_1(3'bXXX), //TODO
      .data_in_0(reg_file_data_in_0), //TODO
      .data_in_1(16'bX), //TODO
      .read_data_0(reg_file_out_0),
      .read_data_1(reg_file_out_1)
  );



  // reg_file_data_in_0
  always @(posedge clk) begin
    if (Immediate_control) begin
      if (opcode == LBL) begin
       reg_file_write_en_0 = 2'b01;
       reg_file_data_in_0 = {8'b0, immediate_byte};
      end else if (opcode == LBH) begin
       reg_file_write_en_0 = 2'b10;
       reg_file_data_in_0 = {immediate_byte, 8'b0};
      end else begin
        $fatal;
      end
    end
  end

  // // reg_file_write_en_0
  // always @(posedge clk) begin
  //   if (Immediate_control) begin
  //     if (opcode == LBL) begin
  //      reg_file_write_en_0 = 2'b01;
  //     end else if (opcode == LBH) begin
  //      reg_file_write_en_0 = 2'b10;
  //     end else begin
  //       $fatal;
  //     end
  //   end
  // end

  integer num_failures;
  initial begin
    num_failures = 0;
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test block
  initial begin
    load_test_2;
    reset;
    #100 $display("finished!");
    $finish;
  end


  task reset;
    begin
    rst = 0;
    @(posedge clk);
    rst = 1;
    @(posedge clk);
    rst = 0;
    @(posedge clk);
    end

  endtask

  task load_test_1;
    begin
      instruction_mem[0] = {LBL, REG0, 8'hFF};
      instruction_mem[1] = {LBL, REG1, 8'hFF};
      instruction_mem[2] = {LBL, REG2, 8'hFF};
      instruction_mem[3] = {LBH, REG0, 8'hFF};
      instruction_mem[4] = {LBH, REG1, 8'hFF};
      instruction_mem[5] = {LBH, REG2, 8'hFF};
    end
  endtask

  task load_test_2;
    begin
      instruction_mem[0] = {LBL, REG0, 8'h01};
      instruction_mem[1] = {LBL, REG1, 8'h02};
      instruction_mem[2] = {LBL, REG2, 8'hF3};
      instruction_mem[3] = {LBH, REG0, 8'hF4};
      instruction_mem[4] = {LBH, REG1, 8'hF5};
      instruction_mem[5] = {LBH, REG2, 8'hF6};
    end
  endtask
  // task verify_reg_val;
  //   input [2:0] reg_sel;
  //   input [15:0] expected;
  //   begin
  //     reg_write_en <= 0;
  //     read_addr_0  <= reg_sel;
  //     read_addr_1  <= reg_sel;
  //     @(posedge clk);
  //     if (operand_1 !== expected) begin
  //       num_failures <= num_failures + 1;
  //       $display("expected %h, but got %h", expected, operand_1);
  //     end
  //   end
  // endtask

endmodule
