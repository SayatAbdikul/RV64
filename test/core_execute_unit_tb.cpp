#include "Vcore_execute_unit.h"
#include "verilated.h"
#include <iostream>
#include <vector>
#include <iomanip>

void apply_instruction(Vcore_execute_unit* top, uint32_t instr, const std::string& name) {
    top->instruction = instr;
    top->clk = 1;
    top->eval();
    top->clk = 0;
    top->eval();
    std::cout << name << " -> result: " << top->result << std::endl;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcore_execute_unit* top = new Vcore_execute_unit;

    // Reset
    top->clk = 0;
    top->rst = 1;
    top->eval();
    top->clk = 1;
    top->eval();
    top->clk = 0;
    top->rst = 0;
    top->eval();

    // Instruction set: {hex, name}
    std::vector<std::pair<uint32_t, std::string>> instructions = {
        {0x00A00093, "ADDI x1, x0, 10"},
        {0x00500113, "ADDI x2, x0, 5"},
        {0xFFD00193, "ADDI x3, x0, -3"},
        {0x01408213, "ADDI x4, x1, 20"},
        {0x00208333, "ADD x6, x1, x2"}, //...
        {0x40208233, "SUB x7, x1, x2"},
        {0x0020F433, "AND x8, x1, x2"},
        {0x0020E4B3, "OR x9, x1, x2"},
        {0x0030C533, "XOR x10, x1, x3"},
        {0x001125B3, "SLT x11, x2, x1"},
        {0x00313633, "SLTU x12, x2, x3"},
        {0x001115B3, "SLL x13, x2, x1"},
        {0x001155B3, "SRL x14, x2, x1"},
        {0x4021D7B3, "SRA x15, x3, x2"},
        {0x00221413, "SLLI x16, x2, 2"},
        {0x0010D893, "SRLI x17, x1, 1"},
        {0x4011D913, "SRAI x18, x3, 1"},
        {0x0060FA93, "ANDI x21, x1, 6"},
        {0x0010EB13, "ORI x22, x1, 1"},
        {0x0070CB93, "XORI x23, x1, 7"},
        {0x0001AC13, "SLTI x24, x3, 0"},
        {0x0001BC93, "SLTIU x25, x3, 0"},
    };

    std::cout << "=== Executing all instructions ===\n";
    for (const auto& [instr, name] : instructions) {
        apply_instruction(top, instr, name);
    }

    delete top;
    return 0;
}
