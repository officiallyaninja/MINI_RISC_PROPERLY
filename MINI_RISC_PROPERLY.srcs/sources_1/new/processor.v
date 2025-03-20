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
  // register that gets upper mul bits
  // and the remainder of div
  localparam ALU_EXTRA_OUTPUT_REG = 3'b001; 
  // special regs
  reg clk;
  reg rst;
  reg [15:0] flag;
  reg [15:0] instruction_mem[0:MEMORY_DEPTH-1];  // 11 bits to index
  reg [10:0] branch_reg;
  reg branch_en;

  reg [15:0] input_reg;
  reg [15:0] output_reg;

  // alias
  wire [15:0] instruction_reg;
  wire [4:0] opcode;

  wire [7:0] immediate_byte;
  wire [2:0] reg_sel_write_0;
  wire [2:0] reg_sel_read_0;
  wire [2:0] reg_sel_read_1;
  wire [3:0] bit_pos;
  wire [10:0] branch_addr;

  // connections
  wire [15:0] reg_file_out_0;
  wire [15:0] reg_file_out_1;
  wire [15:0] ram_out;
  wire [10:0] instruction_addr;
  wire [15:0] alu_result_0;
  wire [15:0] alu_result_1;
  wire [15:0] alu_flag_out;

  //MUXed
  reg [15:0] reg_file_data_in_0;
  reg [0:1] reg_file_write_en_0;

  // assignemtents
  assign instruction_reg = instruction_mem[instruction_addr];
  assign opcode = instruction_reg[15:11];

  assign immediate_byte = instruction_reg[7:0];
  assign reg_sel_write_0 = instruction_reg[10:8];
  assign reg_sel_read_0 = instruction_reg[7:5];
  assign reg_sel_read_1 = instruction_reg[4:2];
  assign bit_pos = instruction_reg[4:1];
  assign branch_addr = instruction_reg[10:0];


  // control signals
   wire alu_output_control;
   wire bit_control;

  control_unit cu (
    .clk(clk),
    .opcode(opcode),
    .alu_output(alu_output_control)
 );


  program_counter pc (
     .clk(clk),
     .rst(rst),
     .inc(1'b1),
     .branch_en(branch_en),
     .branch_addr(branch_reg),
     .current_addr(instruction_addr)
  );

  reg_file reg_file (
      .clk(clk),
      .rst(rst),
      .write_en_0(reg_file_write_en_0),
      .write_en_1((opcode == MUL) || (opcode == DIV) ? 2'b11 : 2'b00),
      .read_addr_0(reg_sel_read_0),
      .read_addr_1(reg_sel_read_1),
      .reg_write_addr_0(reg_sel_write_0),
      .reg_write_addr_1(ALU_EXTRA_OUTPUT_REG),
      .data_in_0(reg_file_data_in_0),
      .data_in_1(alu_result_1), 
      .read_data_0(reg_file_out_0),
      .read_data_1(reg_file_out_1)
  );


   memory ram (
     .clk(clk),
     .write_en(opcode == STORE),
     .address(reg_file_out_0),
     .data_in(reg_file_out_1),
     .read_data(ram_out) 
   );


   ALU alu (
     .opcode(opcode),  
     .operand_1(reg_file_out_0),  
     .operand_2(reg_file_out_1), 
     .bit_position(bit_pos),

     .result_0(alu_result_0),  
     .result_1(alu_result_1), 
     .current_flags(flag),
     .next_flags(alu_flag_out)
   );


  always @(posedge clk) begin

   reg_file_write_en_0 = 2'b00;
   reg_file_data_in_0 = 16'bx;
   branch_en = 0;

    if (opcode == HALT) $finish; // TODO: also set inc to 0

    if (opcode == LOAD ) begin
      reg_file_write_en_0 = 2'b11;
      reg_file_data_in_0 = ram_out;
    end

    if (opcode == LBL) begin
     reg_file_write_en_0 = 2'b01;
     reg_file_data_in_0 = {8'b0, immediate_byte};
    end
    if (opcode == LBH) begin
     reg_file_write_en_0 = 2'b10;
     reg_file_data_in_0 = {immediate_byte, 8'b0};
    end
    if (opcode == MOV) begin 
      reg_file_write_en_0 = 2'b11;
      reg_file_data_in_0 = reg_file_out_0;
    end

    if (alu_output_control) begin
      reg_file_write_en_0 = 2'b11;
      reg_file_data_in_0 = alu_result_0;
    end

    if (opcode == LOADBR) begin
      branch_reg = branch_addr;
    end

    if (opcode == JF) begin
      branch_en = flag[bit_pos];
    end

    if (opcode == MOVOUT) begin
      output_reg = reg_file_out_0;
    end
    if (opcode == MOVIN) begin
      reg_file_write_en_0 = 2'b11;
      reg_file_data_in_0 = input_reg;
    end
    if (opcode == MOVB) begin
      flag[4] = input_reg[bit_pos];
    end

  if (reg_file_write_en_0 != 2'b00 && reg_file_data_in_0 == 16'bx) $fatal;

  flag = alu_flag_out;
  end

  initial begin
    clk = 0;
    forever #5 clk = ~clk; end

  // Test block
  initial begin
    input_reg = 6;
    IO_test_inc;
    reset;
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
      $display("load test 1");
      instruction_mem[0] = {LBL, REG0, 8'hFF};
      instruction_mem[1] = {LBL, REG1, 8'hFF};
      instruction_mem[2] = {LBL, REG2, 8'hFF};
      instruction_mem[3] = {LBH, REG0, 8'hFF};
      instruction_mem[4] = {LBH, REG1, 8'hFF};
      instruction_mem[5] = {LBH, REG2, 8'hFF};
      instruction_mem[6] = {HALT, 11'bx};
    end
  endtask

  task load_test_2;
    begin
      $display("load test 2");
      instruction_mem[0] = {LBL, REG0, 8'h01};
      instruction_mem[1] = {LBL, REG1, 8'h02};
      instruction_mem[2] = {LBL, REG2, 8'hF3};
      instruction_mem[3] = {LBH, REG0, 8'hF4};
      instruction_mem[4] = {LBH, REG1, 8'hF5};
      instruction_mem[5] = {LBH, REG2, 8'hF6};
      instruction_mem[6] = {HALT, 11'bx};
    end
  endtask

  task mov_test_1;
    begin
      $display("mov test 1");
      instruction_mem[0] = {LBL, REG0, 8'h01};
      instruction_mem[1] = {LBL, REG1, 8'h02};
      instruction_mem[2] = {LBL, REG2, 8'hF3};
      instruction_mem[3] = {LBH, REG0, 8'hF1};
      instruction_mem[4] = {LBH, REG1, 8'hF2};
      instruction_mem[5] = {LBH, REG2, 8'hF3};
      instruction_mem[6] = {MOV, REG7, REG0, 5'bx};
      instruction_mem[7] = {MOV, REG6, REG1, 5'bx};
      instruction_mem[8] = {MOV, REG5, REG2, 5'bx};
      instruction_mem[9] = {HALT, 11'bx};
    end
  endtask

  task load_store_test;
  begin
  $display("load_store_test");
    instruction_mem[0] = {LBH, REG0, 8'd1};
    instruction_mem[1] = {LBL, REG0, 8'd1};
    instruction_mem[2] = {LBH, REG1, 8'd255};
    instruction_mem[3] = {LBL, REG1, 8'd255};
    instruction_mem[4] = {LBH, REG2, 8'd2};
    instruction_mem[5] = {LBL, REG2, 8'd2};
    instruction_mem[6] = {STORE, 3'bx, REG2, REG1, 2'bx};
    instruction_mem[7] = {LOAD, REG3, REG2, 5'bx};
    instruction_mem[8] = {HALT, 11'bx};
  end
  endtask

  task alu_test_inc;
  begin
  $display("alu_test_inc");
    instruction_mem[0] = {LBH, REG0, 8'd255};      
    instruction_mem[1] = {LBL, REG0, 8'd16};      
    instruction_mem[2] = {INC, REG1, REG0, 5'bx};
    instruction_mem[3] = {INC, REG2, REG1, 5'bx};
    instruction_mem[4] = {INC, REG3, REG2, 5'bx};
    instruction_mem[5] = {INC, REG4, REG3, 5'bx};
    instruction_mem[6] = {INC, REG5, REG4, 5'bx};
    instruction_mem[7] = {INC, REG6, REG5, 5'bx};
    instruction_mem[8] = {INC, REG7, REG6, 5'bx};
    instruction_mem[9] = {HALT, 11'bx};
  end
  endtask


  task alu_test_add_1;
  begin
  $display("alu_test_add_1");
    instruction_mem[0] = {LBH, REG0, 8'd0};
    instruction_mem[1] = {LBL, REG0, 8'd1};
    instruction_mem[2] = {ADD, REG1, REG0, REG0, 2'bx};
    instruction_mem[3] = {ADD, REG2, REG1, REG0, 2'bx};
    instruction_mem[4] = {ADD, REG3, REG2, REG0, 2'bx};
    instruction_mem[5] = {ADD, REG4, REG3, REG0, 2'bx};
    instruction_mem[6] = {ADD, REG5, REG4, REG0, 2'bx};
    instruction_mem[7] = {ADD, REG6, REG5, REG0, 2'bx};
    instruction_mem[8] = {ADD, REG7, REG6, REG0, 2'bx};
    instruction_mem[9] = {HALT, 11'bx};
  end
  endtask


  task alu_test_add_2;
  begin
  $display("alu_test_add_2");
    instruction_mem[0] = {LBH, REG0, 8'd0};
    instruction_mem[1] = {LBL, REG0, 8'd1};
    instruction_mem[2] = {ADD, REG1, REG0, REG0, 2'bx};
    instruction_mem[3] = {ADD, REG2, REG1, REG1, 2'bx};
    instruction_mem[4] = {ADD, REG3, REG2, REG2, 2'bx};
    instruction_mem[5] = {ADD, REG4, REG3, REG3, 2'bx};
    instruction_mem[6] = {ADD, REG5, REG4, REG4, 2'bx};
    instruction_mem[7] = {ADD, REG6, REG5, REG5, 2'bx};
    instruction_mem[8] = {ADD, REG7, REG6, REG6, 2'bx};
    instruction_mem[9] = {HALT, 11'bx};
  end
  endtask

  task alu_test_bit;
  begin
  $display("alu_test_bit");
    instruction_mem[0] = {SETB, REG0, REG0, 4'd0, 1'bx};
    instruction_mem[1] = {SETB, REG1, REG1, 4'd1, 1'bx};
    instruction_mem[2] = {SETB, REG2, REG2, 4'd2, 1'bx};
    instruction_mem[3] = {SETB, REG3, REG3, 4'd3, 1'bx};
    instruction_mem[4] = {SETB, REG4, REG4, 4'd4, 1'bx};
    instruction_mem[5] = {SETB, REG5, REG5, 4'd5, 1'bx};
    instruction_mem[6] = {SETB, REG6, REG6, 4'd6, 1'bx};
    instruction_mem[7] = {SETB, REG7, REG7, 4'd7, 1'bx};
    instruction_mem[8] = {HALT, 11'bx};
  end
  endtask

  task alu_test_mul;
  begin
  $display("alu_test_mul");
    instruction_mem[0] = {LBH, REG0, 8'd0};
    instruction_mem[1] = {LBL, REG0, 8'd10};
    instruction_mem[2] = {LBH, REG1, 8'd0};
    instruction_mem[3] = {LBL, REG1, 8'd32};
    instruction_mem[4] = {MUL, REG0, REG0, REG1, 2'bx};
    instruction_mem[5] = {HALT, 11'bx};
  end
  endtask

  task alu_test_branch;
  begin
  $display("alu_test_branch");
    instruction_mem[0] = {LBH, REG7, 8'd0};
    instruction_mem[1] = {LBL, REG7, 8'd30};
    instruction_mem[2] = {LOADBR, 11'd3};
    instruction_mem[3] = {STORE, 3'bx, REG6, REG6, 2'bx};
    instruction_mem[4] = {INC, REG6, REG6, 5'bx};
    instruction_mem[5] = {CMP, 3'bx, REG6, REG7, 2'bx};
    instruction_mem[6] = {CPLF, 6'bx, 4'd3, 1'bx};
    instruction_mem[7] = {JF, 6'bx, 4'd3, 1'bx};
    instruction_mem[8] = {HALT, 11'bx};
  end
  endtask

  task IO_test_inc;
  begin
  $display("IO_test_inc");
    instruction_mem[0] = {MOVIN, REG0, 8'bx}; 
    instruction_mem[1] = {INC, REG0, REG0, 5'bx};   
    instruction_mem[2] = {MOVOUT, 3'bx, REG0, 5'bx};
    instruction_mem[3] = {HALT, 11'bx};
  end
  endtask

endmodule
