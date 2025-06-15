#include "Vcore.h"
#include "verilated.h"
#include <iostream>
#include <cstdint>
#include <iomanip>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcore* dut = new Vcore;
    dut->rst = 1;
    dut->clk = 0;
    dut->eval();
    dut->clk = 1;
    dut->eval();
    dut->clk = 0;
    dut->eval();

    // Deassert reset
    dut->rst = 0;
    for(int i = 0; i < 22; ++i) {
        dut->clk = 1; // Set clock high
        dut->eval(); // Evaluate the design
        dut->clk = 0; // Set clock low
        dut->eval(); // Evaluate again to propagate changes
        std::cout << "the result in decimal is: " << dut->result << std::endl;
    }

    delete dut;
    return 0;
}