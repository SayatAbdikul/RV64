#include "Vpc.h"
#include "verilated.h"
#include <iostream>
#include <cstdint>
#include <iomanip>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vpc* dut = new Vpc;
    
    // Initialize and reset
    dut->reset = 1;
    dut->clk = 0;
    dut->eval();
    dut->reset = 0;
    for(int i = 0; i < 22; ++i) {
        // Set PC FIRST
        dut->pc_next = i * 4;  // Set new address BEFORE evaluation
        
        // Evaluate to get instruction
        dut->clk = 1;
        dut->eval();
        dut->clk = 0;
        dut->eval();
        std::cout << "PC: 0x"<<dut->pc_out<<std::endl;

    }

    delete dut;
    return 0;
}