module inst_memory #(parameter MEM_DEPTH = 1024) (
    // verilator lint_off UNUSED
    input  logic [63:0] pc,
    // verilator lint_on UNUSED
    output logic [31:0] instruction
);
    reg [31:0] mem [0:MEM_DEPTH-1];
    logic [9:0] addr; // 10 bits for addressing 1024 locations
    assign addr = pc[11:2]; // Assuming pc is aligned to 4-byte boundaries
    initial begin
    $readmemh("/Users/sayat/Documents/GitHub/RV64/memory/instructions.txt", mem);
end

    assign instruction = mem[addr];
endmodule
