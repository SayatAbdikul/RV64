module upper(
    input  logic [63:0] pc,       // Program Counter
    input  logic [19:0] imm,      // Immediate value
    input  logic [6:0]  opcode,   // Opcode
    output logic [63:0] upper_out    // Output result
);
    
    // Sign-extend immediate: {imm, 12'b0} shifted and extended
    
    always_comb begin
        case(opcode)
            7'b0110111: upper_out = {{32{imm[19]}}, imm[19:0], 12'b0};        // LUI
            7'b0010111: upper_out = pc + {{32{imm[19]}}, imm[19:0], 12'b0};   // AUIPC
            default:    upper_out = 64'b0;                              // Default zero
        endcase
    end
endmodule

