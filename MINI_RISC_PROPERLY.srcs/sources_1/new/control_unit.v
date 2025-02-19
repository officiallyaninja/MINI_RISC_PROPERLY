module control_unit (
    input wire clk,
    input wire [4:0] opcode,  // from instruction register
    output wire Alu,
    output wire Alu_output,  // always 0 when alu is 0
    output wire Reg_bit,
    output wire Flag,
    output wire Ram,
    output wire Reg,
    output wire Immediate
);
  `include "parameters.v"

  assign Immediate = (opcode == LBL || opcode == LBH);
endmodule

