`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.02.2025 11:47:45
// Design Name: 
// Module Name: ALU_tb
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

module ALU_tb();
    // Inputs
    reg clk;
    reg [4:0] opcode;
    reg [15:0] operand_1;
    reg [15:0] operand_2;
    reg [3:0] bit_position;
    
    // Outputs
    wire [15:0] result_0;
    wire [15:0] result_1;
    wire [15:0] flag_reg;
   
    ALU dut (
        .clk(clk),
        .opcode(opcode),
        .operand_1(operand_1),
        .operand_2(operand_2),
        .bit_position(bit_position),
        .result_0(result_0),
        .result_1(result_1),
        .flag_reg(flag_reg)
    );
   

    integer num_failures;
    // Clock generation
    initial begin
        num_failures = 0;
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        opcode = 0;
        operand_1 = 0;
        operand_2 = 0;
        bit_position = 0;
        
        // Wait for 100 ns for global reset
        #100;
        

	/* Syntax: test_case (input [64:0] test_name; input [4:0] test_opcode; 
			      input [15:0] test_op1; input [15:0] test_op2; input [3:0] test_bit_pos;) */
        // Test ADD operation
        // Normal addition
        test_case("ADD - Normal", 5'b00000, 16'd10, 16'd20, 4'd0);
        // Addition with carry
        test_case("ADD - Carry", 5'b00000, 16'hFFFF, 16'd1, 4'd0);
        // Addition with overflow
        test_case("ADD - Overflow", 5'b00000, 16'h7FFF, 16'h7FFF, 4'd0);
        
        // Test MUL operation
        test_case("MUL - Normal", 5'b00001, 16'd10, 16'd20, 4'd0);
        test_case("MUL - Large", 5'b00001, 16'hFFFF, 16'h2, 4'd0);
        
        // Test SUB operation
        test_case("SUB - Normal", 5'b00010, 16'd20, 16'd10, 4'd0);
        test_case("SUB - Negative", 5'b00010, 16'd40, 16'd29, 4'd0);
        
        // Test DIV operation
        test_case("DIV - Normal", 5'b00011, 16'd20, 16'd5, 4'd0);
        test_case("DIV - By Zero", 5'b00011, 16'd20, 16'd0, 4'd0);
        
        // Test logical operations
        test_case("NOT", 5'b00100, 16'hAAAA, 16'd0, 4'd0);
        test_case("AND", 5'b00101, 16'hAAAA, 16'h5555, 4'd0);
        test_case("OR", 5'b00110, 16'hAAAA, 16'h5555, 4'd0);
        test_case("XOR", 5'b00111, 16'hAAAA, 16'h5555, 4'd0);
        
        // Test INC operation
        test_case("INC - Normal", 5'b01000, 16'd10, 16'd0, 4'd0);
        test_case("INC - Overflow", 5'b01000, 16'hFFFF, 16'd0, 4'd0);
        
        // Test CMP operation
        test_case("CMP - Equal", 5'b01001, 16'd10, 16'd10, 4'd0);
        test_case("CMP - Greater", 5'b01001, 16'd20, 16'd10, 4'd0);
        test_case("CMP - Less", 5'b01001, 16'd10, 16'd20, 4'd0);
        
        // Test rotation operations
        test_case("RR", 5'b01010, 16'hAAAA, 16'd0, 4'd0);
        test_case("RL", 5'b01011, 16'hAAAA, 16'd0, 4'd0);
        
        // Test bit operations
        test_case("SETB", 5'b01100, 16'h0000, 16'd0, 4'd8);
        test_case("CLRB", 5'b01101, 16'hFFFF, 16'd0, 4'd8);

        // Test setting different flag bits
        test_case("SETF - Carry Flag", 5'b01110, 16'h0000, 16'h0000, 4'd0);
        test_case("SETF - Zero Flag", 5'b01110, 16'h0000, 16'h0000, 4'd7);
        test_case("SETF - Negative Flag", 5'b01110, 16'h0000, 16'h0000, 4'd6);
        test_case("SETF - General Purpose Flag", 5'b01110, 16'h0000, 16'h0000, 4'd4);
        
        $display("\n=== Test Summary ===");
        if (num_failures == 0)
            $display("All tests passed successfully!");
        else
            $display("Some tests failed.");
        // End simulation
        #100 $finish;
    end
    
    // Task to run test cases
    task test_case;
        input [255:0] test_name;
        input [4:0] test_opcode;
        input [15:0] test_op1;
        input [15:0] test_op2;
        input [3:0] test_bit_pos;
        reg failed;
        reg [31:0] expected_mul;
        reg [15:0] expected_div, expected_mod;
        begin
            failed = 0;
            $display("\nRunning test: %s", test_name);
            @(negedge clk);
            opcode = test_opcode;
            operand_1 = test_op1;
            operand_2 = test_op2;
            bit_position = test_bit_pos;
            
            @(posedge clk);
            #1; // Wait for outputs to stabilize
            case(test_opcode)
                5'b00000: begin // ADD
                    if(result_0 !== test_op1 + test_op2) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("ADD operation failed:");
                        $display("Expected: %h, Got: %h", test_op1 + test_op2, result_0);
                        $display("Carry flag: %b", flag_reg[0]);
                    end
                end
                
                5'b00001: begin // MUL
                    expected_mul = test_op1 * test_op2;
                    if(result_0 !== expected_mul[15:0] || result_1 !== expected_mul[31:16]) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("MUL operation failed:");
                        $display("Expected: %h%h, Got: %h%h", expected_mul[31:16], expected_mul[15:0], result_1, result_0);
                    end
                end
                
                5'b00010: begin // SUB
                    if(result_0 !== test_op1 - test_op2) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("SUB operation failed:");
                        $display("Expected: %h, Got: %h", test_op1 - test_op2, result_0);
                        $display("Borrow flag: %b", flag_reg[0]);
                    end
                end
                
                5'b00011: begin // DIV
                    if(test_op2 != 0) begin
                        expected_div = test_op1 / test_op2;
                        expected_mod = test_op1 % test_op2;
                        if(result_0 !== expected_div || result_1 !== expected_mod) begin
                            failed = 1;
                            $display("\nFAILURE in %s:", test_name);
                            $display("DIV operation failed:");
                            $display("Expected quotient: %h, Got: %h", expected_div, result_0);
                            $display("Expected remainder: %h, Got: %h", expected_mod, result_1);
                        end
                    end else if(result_0 !== 16'hFFFF || !flag_reg[1]) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("DIV by zero handling failed");
                    end
                end
                
                5'b00100: begin // NOT
                    if(result_0 !== ~test_op1) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("NOT operation failed:");
                        $display("Expected: %h, Got: %h", ~test_op1, result_0);
                    end
                end
                
                5'b00101: begin // AND
                    if(result_0 !== (test_op1 & test_op2)) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("AND operation failed:");
                        $display("Expected: %h, Got: %h", test_op1 & test_op2, result_0);
                    end
                end
                
                5'b00110: begin // OR
                    if(result_0 !== (test_op1 | test_op2)) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("OR operation failed:");
                        $display("Expected: %h, Got: %h", test_op1 | test_op2, result_0);
                    end
                end
                
                5'b00111: begin // XOR
                    if(result_0 !== (test_op1 ^ test_op2)) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("XOR operation failed:");
                        $display("Expected: %h, Got: %h", test_op1 ^ test_op2, result_0);
                    end
                end
                
                5'b01000: begin // INC
                    if(result_0 !== test_op1 + 16'h0001) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("INC operation failed:");
                        $display("Expected: %h, Got: %h", test_op1 + 16'h0001, result_0);
                        $display("Overflow flag: %b", flag_reg[1]);
                    end
                end
                
                5'b01001: begin // CMP
                    if((test_op1 == test_op2 && !flag_reg[3]) ||
                       (test_op1 > test_op2 && !flag_reg[2]) ||
                       (test_op1 < test_op2 && !flag_reg[0])) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("CMP flags incorrect:");
                        $display("Expected: Equal=%b, Greater=%b, Less=%b",
                               test_op1 == test_op2,
                               test_op1 > test_op2,
                               test_op1 < test_op2);
                        $display("Got flags: %b", flag_reg);
                    end
                end
                
                5'b01010: begin // RR
                    if(result_0 !== {test_op1[0], test_op1[15:1]}) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("RR operation failed:");
                        $display("Expected: %h, Got: %h", {test_op1[0], test_op1[15:1]}, result_0);
                    end
                end
                
                5'b01011: begin // RL
                    if(result_0 !== {test_op1[14:0], test_op1[15]}) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("RL operation failed:");
                        $display("Expected: %h, Got: %h", {test_op1[14:0], test_op1[15]}, result_0);
                    end
                end
                
                5'b01100: begin // SETB
                    if(result_0 !== (test_op1 | (16'b1 << test_bit_pos))) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("SETB operation failed:");
                        $display("Expected: %h, Got: %h", test_op1 | (16'b1 << test_bit_pos), result_0);
                    end
                end
                
                5'b01101: begin // CLRB
                    if(result_0 !== (test_op1 & ~(16'b1 << test_bit_pos))) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("CLRB operation failed:");
                        $display("Expected: %h, Got: %h", test_op1 & ~(16'b1 << test_bit_pos), result_0);
                    end
                end
                
                5'b01110: begin // SETF
                    if(!flag_reg[test_bit_pos]) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("SETF operation failed:");
                        $display("Flag bit %d not set", test_bit_pos);
                    end
                end
                
                5'b01111: begin // SWAP
                    if(result_0 !== {test_op1[7:0], test_op1[15:8]}) begin
                        failed = 1;
                        $display("\nFAILURE in %s:", test_name);
                        $display("SWAP operation failed:");
                        $display("Expected: %h, Got: %h", {test_op1[7:0], test_op1[15:8]}, result_0);
                    end
                end
            endcase
            
                if(failed) begin
                  num_failures = num_failures + 1;
                end
        end
    endtask
    
    // Wave dump
    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, ALU_tb);
    end
    
endmodule
