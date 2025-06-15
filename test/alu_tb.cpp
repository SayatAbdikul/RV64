#include "Valu.h"
#include "verilated.h"
#include <iostream>
#include <cstdint>
#include <cassert>
#include <random>

const int num_tests = 10;

// Define opcodes (match with your Verilog ALU)
const int ADD  = 0b00000;
const int SUB  = 0b00001;
const int AND  = 0b00010;
const int OR   = 0b00011;
const int XOR  = 0b00100;
const int SLT  = 0b00101;
const int SLTU = 0b00110;
const int SLL  = 0b00111;
const int SRL  = 0b01000;
const int SRA  = 0b01001;
const int ADDW = 0b01010;
const int SUBW = 0b01011;
const int SLLW = 0b01100;
const int SRLW = 0b01101;
const int SRAW = 0b01110;

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Valu* alu = new Valu;
    srand(time(nullptr));

    std::random_device rd;
    std::mt19937_64 gen(rd());
    std::uniform_int_distribution<uint64_t> dist64;
    std::uniform_int_distribution<uint32_t> dist32;

    auto test_bin_op = [&](const char* name, int opcode, auto expected_fn) {
        alu->sel = opcode;
        std::cout << "Testing " << name << " operation..." << std::endl;
        for (int i = 0; i < num_tests; ++i) {
            uint64_t a = dist64(gen);
            uint64_t b = dist64(gen);
            alu->a = a;
            alu->b = b;
            alu->eval();
            uint64_t expected = expected_fn(a, b);
            std::cout << "Testing " << name << ": a = " << a << ", b = " << b << std::endl;
            std::cout << "Result: " << alu->result << std::endl;
            std::cout << "Expected: " << expected << std::endl;
            std::cout << "------------------------" << std::endl;
            assert(alu->result == expected && name);
        }
    };

    test_bin_op("ADD", ADD, [](uint64_t a, uint64_t b) { return a + b; });
    test_bin_op("SUB", SUB, [](uint64_t a, uint64_t b) { return a - b; });
    test_bin_op("AND", AND, [](uint64_t a, uint64_t b) { return a & b; });
    test_bin_op("OR",  OR,  [](uint64_t a, uint64_t b) { return a | b; });
    test_bin_op("XOR", XOR, [](uint64_t a, uint64_t b) { return a ^ b; });
    test_bin_op("SLT", SLT, [](uint64_t a, uint64_t b) { return (int64_t)a < (int64_t)b ? 1 : 0; });
    test_bin_op("SLTU", SLTU, [](uint64_t a, uint64_t b) { return a < b ? 1 : 0; });
    test_bin_op("SLL", SLL, [](uint64_t a, uint64_t b) { return a << (b & 0x3F); });
    test_bin_op("SRL", SRL, [](uint64_t a, uint64_t b) { return a >> (b & 0x3F); });
    test_bin_op("SRA", SRA, [](uint64_t a, uint64_t b) {
        int64_t signed_a = static_cast<int64_t>(a);
        uint8_t shift_amt = b & 0x3F;
        return static_cast<uint64_t>(signed_a >> shift_amt);
    });
    auto test_word_op = [&](const char* name, int opcode, auto expected_fn) {
        alu->sel = opcode;
        for (int i = 0; i < num_tests; ++i) {
            int32_t a32 = dist32(gen);
            int32_t b32 = dist32(gen);
            alu->a = static_cast<int64_t>(a32);
            alu->b = static_cast<int64_t>(b32);
            alu->eval();
            std::cout << "Testing " << name << ": a = " << a32 << ", b = " << b32 << std::endl;
            std::cout << "Result: " << alu->result << std::endl;
            std::cout << "Expected: " << expected_fn(a32, b32) << std::endl;
            std::cout << "------------------------" << std::endl;
            int64_t expected = expected_fn(a32, b32);
            assert(static_cast<int64_t>(alu->result) == expected && name);
        }
    };

    test_word_op("ADDW", ADDW, [](int32_t a, int32_t b) {
        return static_cast<int64_t>(static_cast<int32_t>(a + b));
    });

    test_word_op("SUBW", SUBW, [](int32_t a, int32_t b) {
        return static_cast<int64_t>(static_cast<int32_t>(a - b));
    });

    test_word_op("SLLW", SLLW, [](int32_t a, int32_t b) {
        return static_cast<int64_t>(static_cast<int32_t>(a << (b & 0x1F)));
    });

    test_word_op("SRLW", SRLW, [](int32_t a, int32_t b) {
        return static_cast<int64_t>(static_cast<int32_t>(static_cast<uint32_t>(a) >> (b & 0x1F)));
    });

    test_word_op("SRAW", SRAW, [](int32_t a, int32_t b) {
        return static_cast<int64_t>(static_cast<int32_t>(a >> (b & 0x1F)));
    });

    std::cout << "✅ All ALU tests passed!" << std::endl;
    delete alu;
    return 0;
}
