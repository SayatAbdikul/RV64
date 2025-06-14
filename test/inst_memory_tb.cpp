#include "Vinst_memory.h"
#include "verilated.h"
#include <iostream>
#include <cstdint>
#include <iomanip>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vinst_memory* dut = new Vinst_memory;
    
    // Initialize and reset
    dut->pc = 0;
    dut->eval();
    
    for(int i = 0; i < 22; ++i) {
        // Set PC FIRST
        dut->pc = i * 4;  // Set new address BEFORE evaluation
        
        // Evaluate to get instruction
        dut->eval();
        
        std::cout << "PC: 0x" << std::hex << std::setw(8) << std::setfill('0') 
                  << dut->pc << " -> Instruction: 0x" << std::setw(8) 
                  << dut->instruction << std::dec << std::endl;
    }
    
    delete dut;
    return 0;
}