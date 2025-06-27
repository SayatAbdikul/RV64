module ram #(parameter N = 13, M = 64)(
    input  logic        clk,   // Clock
    input  logic        we,    // Write Enable
    input  logic [N-1:0] inst_addr,  // Instruction address input
    input  logic [N-1:0] data_addr,  // Data address input
    input  logic [M-1:0] data_in,  // Data input
    output logic [31:0] inst_out,  // instruction output (comma added)
    output logic [M-1:0] data_out  // Data output
);

    logic [7:0] mem [0:(2**N)-1];  // Memory array: 2^N locations, 8-bit each
    logic [31:0] inst_mem [0:(2**N/4)-1];  // Memory array: 2^N locations, 32-bit each
    initial begin
        $readmemh("/Users/sayat/Documents/GitHub/RV64/memory/instructions.txt", inst_mem);
        for (int i = 0; i < (2**N/4); i++) begin
            mem[i*4]   = inst_mem[i][31:24];
            mem[i*4+1] = inst_mem[i][23:16];
            mem[i*4+2] = inst_mem[i][15:8];
            mem[i*4+3] = inst_mem[i][7:0];
        end
    end

    always_ff @(posedge clk) begin
        if (we) begin
            for (int i = 0; i < M/8; i++) begin
                mem[data_addr + i[N-1:0]] <= data_in[(i*8) +: 8];  // Write byte i
            end
        end
    end

    final begin
        integer i;
        integer f;
        f = $fopen("data_memory_out.hex", "w");
        for (i = 4096; i < (2**N); i++) begin
            $fdisplay(f, "%h", mem[i]);
        end
        $fclose(f);
    end

    // Read 8 bytes for 64-bit output (little-endian: data_addr = LSB)
    assign data_out = {
        mem[data_addr+7], 
        mem[data_addr+6], 
        mem[data_addr+5], 
        mem[data_addr+4],
        mem[data_addr+3], 
        mem[data_addr+2], 
        mem[data_addr+1], 
        mem[data_addr]
    };
    // Force 4-byte aligned access for instructions

    assign inst_out = {
        mem[inst_addr],
        mem[inst_addr+1],
        mem[inst_addr+2],
        mem[inst_addr+3]
    };
endmodule

