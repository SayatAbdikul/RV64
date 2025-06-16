module branch (
    input logic [2:0] format,
    input logic [63:0] imm,          // Immediate offset
    input logic [63:0] a,             // First operand (rs1)
    input logic [63:0] b,             // Second operand (rs2)
    input logic [63:0] pc,            // Current PC (MUST BE ADDED)
    input logic [2:0] funct3,         // Function code
    output logic branch_taken,        // Branch taken signal
    output logic [63:0] branch_target // Branch target address
);

    always_comb begin
        branch_taken = 1'b0;
        branch_target = 64'b0;

        if (format == 3'b011) begin // B-type format
            case (funct3)
                3'b000: branch_taken = (a == b);                  // BEQ
                3'b001: branch_taken = (a != b);                  // BNE
                3'b100: branch_taken = ($signed(a) < $signed(b)); // BLT
                3'b101: branch_taken = ($signed(a) >= $signed(b));// BGE
                3'b110: branch_taken = (a < b);                   // BLTU
                3'b111: branch_taken = (a >= b);                  // BGEU
                default: branch_taken = 1'b0;
            endcase

            // Calculate target relative to CURRENT PC
            branch_target = branch_taken ? (pc + imm) : (pc + 4);
        end
        else begin
            // Not a branch - continue sequential execution
            branch_taken = 1'b0;
            branch_target = pc + 4;
        end
    end
endmodule
