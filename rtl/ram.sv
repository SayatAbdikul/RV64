module ram #(parameter N = 20, M = 32)(
    input  logic        clk,   // Clock
    input  logic        we,    // Write Enable
    input  logic [N-1:0] adr,  // Address input
    input  logic [M-1:0] din,  // Data input
    output logic [M-1:0] dout  // Data output
);

    logic [M-1:0] mem [0:(2**N)-1];  // Memory array: 2^N locations, M-bit each
    initial begin
        $readmemh("/Users/sayat/Documents/GitHub/RV64/memory/instructions.txt", mem);  // for instruction preload
    end
    
    always_ff @(posedge clk) begin
        if (we)
            mem[adr] <= din;  // Write on rising edge if write-enable is high
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

    assign dout = mem[adr];  // Read is always available (combinational)

endmodule

