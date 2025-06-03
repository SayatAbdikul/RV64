#include "Vregister_file.h"
#include "verilated.h"
#include "verilated_vcd_c.h"  // For VCD tracing

#include <iostream>

void toggle_clock(Vregister_file* rf, VerilatedVcdC* tfp, int& sim_time) {
    rf->clk = 1;
    rf->eval();
    tfp->dump(sim_time++);

    rf->clk = 0;
    rf->eval();
    tfp->dump(sim_time++);
}


int sim_time = 0;
int main(int argc, char** argv){
    Verilated::commandArgs(argc, argv);
    Vregister_file* rf = new Vregister_file;
    Verilated::traceEverOn(true);  // Enable tracing globally
    VerilatedVcdC* tfp = new VerilatedVcdC;
    rf->trace(tfp, 99);           // Trace 99 levels deep
    tfp->open("waveform.vcd");    // Output VCD file name
    rf->rst = 1;
    toggle_clock(rf, tfp, sim_time);
    rf->rst = 0;
    toggle_clock(rf, tfp, sim_time);


    // Reset test
    for(int i=0; i<32; i++){
        rf->rs1 = i;
        rf->rs2 = i;
        rf->write_data = 0;
        toggle_clock(rf, tfp, sim_time);
        assert(rf->read_data1 == 0 && "Read data1 should be 0 on reset");
        assert(rf->read_data2 == 0 && "Read data2 should be 0 on reset");
    }
    std::cout << "Reset test passed!" << std::endl;


    // Write and read test
    for(int i=0; i<32; i++){
        rf->rd = i;
        rf->write_data = i * 123 + 15; // Write some data
        rf->write_enable = 1; // Enable write
        toggle_clock(rf, tfp, sim_time);
    }
    for(int i=1; i<32; i++){
        rf->rs1 = i;
        rf->rs2 = i;
        toggle_clock(rf, tfp, sim_time);
        assert(rf->read_data1 == i * 123 + 15 && "Read data1 should match written data");
        assert(rf->read_data2 == i * 123 + 15 && "Read data2 should match written data");
    }


    // Test reading from register 0
    rf->rs1 = 0; // Test reading from register 0
    rf->rs2 = 0; // Test reading from register 0
    toggle_clock(rf, tfp, sim_time);
    assert(rf->read_data1 == 0 && "Read data1 from register 0 should be 0");
    assert(rf->read_data2 == 0 && "Read data2 from register 0 should be 0");


    std::cout << "Write and read test passed!" << std::endl;
    tfp->close();
    delete rf;
    delete tfp;
    
}