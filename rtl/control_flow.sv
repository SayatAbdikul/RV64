// controls flow of execution based on branch and jump instructions
module control_flow (
    input logic [2:0] format,
    input logic [63:0] imm,          // Immediate offset
    input logic [63:0] a,             // First operand (rs1)
    input logic [63:0] b,             // Second operand (rs2)
    input logic [63:0] pc,            // Current PC
    input logic [2:0] funct3,         // Function code
    input logic [6:0] opcode,         // Added to identify jump instructions
    output logic flow_change,         // Renamed (was branch_taken)
    output logic [63:0] next_pc       // Renamed (was branch_target)
);

    always_comb begin
        flow_change = 1'b0;
        next_pc = pc + 4;  // Default to next sequential instruction

        case (format)
            // B-type branch instructions
            3'b011: begin
                case (funct3)
                    3'b000: flow_change = (a == b);                  // BEQ
                    3'b001: flow_change = (a != b);                  // BNE
                    3'b100: flow_change = ($signed(a) < $signed(b)); // BLT
                    3'b101: flow_change = ($signed(a) >= $signed(b));// BGE
                    3'b110: flow_change = (a < b);                   // BLTU
                    3'b111: flow_change = (a >= b);                  // BGEU
                    default: flow_change = 1'b0;
                endcase

                if (flow_change) begin
                    next_pc = pc + imm;
                end
            end
            
            // J-type instructions (JAL)
            3'b101: begin
                flow_change = 1'b1;
                if (opcode == 7'b1100111) begin  // JALR
                    flow_change = 1'b1;
                    next_pc = (a + imm) & ~64'd1;
                end else begin  // JAL
                    next_pc = pc + imm;  // PC-relative jump
                end
            end
            
            default: ; // Other instructions use default PC+4
        endcase
    end
endmodule
