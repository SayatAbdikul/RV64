#include "Vcore_execute_unit.h"
#include "verilated.h"
#include <iostream>
int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vcore_execute_unit* top = new Vcore_execute_unit;

    // Reset the module
    top->clk = 0;
    top->rst = 1;
    top->eval();
    top->clk = 1;
    top->eval();
    top->clk = 0;
    top->rst = 0;
    top->eval();


    // === Test 2: I-type ADDI ===
    // opcode=0010011 funct3=000 imm=100
    uint32_t imm = 100;
    // ADDI x1, x1, 100
    uint32_t addi_instr = (imm << 20) | (1 << 15) | (0b000 << 12) | (1 << 7) | 0b0010011;

    top->instruction = addi_instr;
    top->eval();

    std::cout << "I-type ADDI result: " << top->result << std::endl;

    top->instruction = addi_instr;
    top->eval();
    top->clk = 1; top->eval();  // rising edge
    top->clk = 0; top->eval();

    std::cout << "I-type ADDI result: " << top->result << std::endl;
    // Clean up
        // === Test 1: R-type ADD x1 = x2 + x3 ===
    // Manually pre-load registers if needed (modify register_file to allow init in test or add preload logic).
    // ADD x1, x2, x3: opcode=0110011 funct3=000 funct7=0000000
    // Encoding: funct7(7) | rs2(5) | rs1(5) | funct3(3) | rd(5) | opcode(7)
    // Example: ADD x1, x2, x3 => rd=1, rs1=2, rs2=3
    uint32_t add_instr = (0b0000000 << 25) | (3 << 20) | (2 << 15) | (0b000 << 12) | (1 << 7) | 0b0110011;

    top->instruction = add_instr;
    top->eval();
    top->clk = 1; top->eval();  // rising edge
    top->clk = 0; top->eval();

    std::cout << "R-type ADD result: " << top->result << std::endl;
    delete top;
    return 0;
}
