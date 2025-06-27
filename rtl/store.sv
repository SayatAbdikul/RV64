module store #(
    parameter N = 13 // Data width for memory operations
)
 (
    input logic [2:0] format, // Instruction format
    input logic [63:0] imm, // Immediate value
    input logic [63:0] reg1, // Source register 1 (base address)
    input logic [63:0] reg2, // Source register 2 (data to store)
    input logic [2:0] funct3, // Function code for the store operation
    output logic mem_write_en, // Memory write enable signal
    output logic [N-1:0] mem_addr, // Memory address for the store operation
    output logic [63:0] mem_data // Data to be written to memory
);

    always_comb begin
        mem_addr = 0; // Default address
        mem_data = 64'b0; // Default data
        if (format == 3'b010) begin // S-type instruction
            mem_write_en = 1'b1; // Enable memory write
            mem_addr = {reg1 + imm}[N-1:0]; // Calculate memory address

            case(funct3)
            // S-type instructions
                3'b011: begin // SD (Store Doubleword)
                    mem_data = reg2; // Data to store
                end
                3'b010: begin // SW (Store Word)
                    mem_data = {32'b0, reg2[31:0]}; // Data to store
                end
                3'b001: begin // SH (Store Halfword)
                    mem_data = {48'b0, reg2[15:0]}; // Store lower halfword
                end
                3'b000: begin // SB (Store Byte)
                    mem_data = {56'b0, reg2[7:0]}; // Store lower byte
                end
                default: begin
                    mem_data = 64'b0; // Default case
                end
            endcase

        end else begin
            mem_write_en = 1'b0; // Disable memory write for other formats
        end
    end

endmodule
