# Mini RISC 
a RISC processor, designed and programmed by myself and Vasanthi BNS for a university project

Project was made using Vivado and the project should be opened in it.  

# Overview
Uses a custom instruction set as can be seen in [Mini RISC op codes.pdf](https://github.com/officiallyaninja/MINI_RISC_PROPERLY/blob/59dff11e22ae1e22a35e4b42eecb8255afa137f5/Mini%20RISC%20op%20codes.pdf)
All opcodes and instruction formats were designed from scratch.

Implemented using Verilog.

# Files  
Relevant files can be all found in MINI_RISC_PROPERLY/MINI_RISC_PROPERLY.srcs/sources_1/new/  

## ALU  
The arithmetic and logical unit
performs it's behaviour using combinational logic 
has an input for the previous state of flags and an output for the next state of the flags.  

flags are
- Carry Flag (C)
- Overflow Flag (V)
- Compare Flag (CMP)
- Equal Flag (Eq)
- IO Flag (IO)
- Parity Flag (P) 
- Negative Flag (N)

## Control Unit
has a signal indicating whether the output of ALU is to be used.

## Memory
represents the data memory that stores data used by the program,
as well as the instruction memory which holds the instructions of the program. 

## Parameters
holds all the constants and parameters that are used throughout the codebase.  

## Processor
The core of the project — this module simulates a custom RISC processor. It handles fetching, decoding, and executing instructions based on the self-designed opcode and instruction set architecture.

## Program Counter
Keeps track of the address of the current instruction being executed. It increments after each instruction fetch or jumps to a target address during branch or jump operations.

## Register File
Implements a simple general-purpose register set. Provides read and write access to registers used by the processor during ALU operations, memory access, and data movement instructions. Can read from 2 registers and write to 2 registers per cycle.
