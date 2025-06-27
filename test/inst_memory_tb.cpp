#include "Vram.h"
#include "verilated.h"
#include <iostream>
#include <cstdint>
#include <iomanip>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vram* dut = new Vram;
    
    // Initialize and reset
    dut->inst_addr = 0;
    dut->data_addr = 0;
    dut->data_in = 0;
    dut->we = 0;
    dut->clk = 1;
    dut->eval();
    dut->clk = 0;  // Reset clock to 0
    dut->eval();  // Evaluate the reset state
    for(int i = 0; i < 22; ++i) {
        dut->clk = 1;
        dut->inst_addr = i * 4;  // 0, 4, 8, 12,...
        
        dut->eval();
        
        std::cout << "PC: 0x" << std::hex << std::setw(8) 
                << dut->inst_addr << " -> Instruction: 0x" << std::setw(8) 
                << dut->inst_out << std::endl;
                
        dut->clk = 0;
        dut->eval();
    }
    
    delete dut;
    return 0;
}