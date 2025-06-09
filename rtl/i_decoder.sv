module i_decoder (
    input logic [31:0] instruction,   // Input instruction
    output logic [4:0] rd,            // Destination register
    output logic [4:0] rs1,           // Source register 1
    output logic [4:0] rs2,           // Source register 2
    output logic [63:0] imm,          // Immediate value (sign-extended)
    output logic [2:0] funct3,        // Function code
    output logic [6:0] funct7,        // Function code extension
    output logic [6:0] opcode,        // Opcode
    output logic [2:0] format         // Format type (R=0, I=1, S=2, B=3, U=4, J=5)
);

    // Instruction fields
    logic [6:0] opcode_val;
    assign opcode_val = instruction[6:0];

    always_comb begin
        // Default values
        rd = 5'b0;
        rs1 = 5'b0;
        rs2 = 5'b0;
        funct3 = 3'b0;
        funct7 = 7'b0;
        imm = 64'b0;
        format = 3'b111;  // Invalid format
        opcode = opcode_val;
        case (opcode_val)
            // R-type (ADD, SUB, etc.)
            7'b0110011: begin
                format = 3'b000;  // R-type
                rd = instruction[11:7];
                //$display("the R-type instruction is %h, the rd is %d", instruction, rd);
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                funct3 = instruction[14:12];
                funct7 = instruction[31:25];
            end
            // I-type (ADDI, LW, JALR)
            7'b0010011, 7'b0000011, 7'b1100111: begin
                format = 3'b001;  // I-type
                rd = instruction[11:7];
                rs1 = instruction[19:15];
                funct3 = instruction[14:12];
                funct7 = instruction[31:25];  // For shift operations
                imm = {{52{instruction[31]}}, instruction[31:20]};  // Sign-extend 12-bit
            end
            
            // S-type (SW, SH, SW, SD)
            7'b0100011: begin
                format = 3'b010;  // S-type
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                funct3 = instruction[14:12];
                // Immediate: [31:25] + [11:7]
                imm = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            // B-type (BEQ, BNE)
            7'b1100011: begin
                format = 3'b011;  // B-type
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                funct3 = instruction[14:12];
                // Immediate: [31] + [7] + [30:25] + [11:8] + 1b0
                imm = {{51{instruction[31]}}, instruction[31], instruction[7], 
                      instruction[30:25], instruction[11:8], 1'b0};
            end
            
            // U-type (LUI, AUIPC)
            7'b0110111, 7'b0010111: begin
                format = 3'b100;  // U-type
                rd = instruction[11:7];
                // Immediate: [31:12] << 12
                imm = {{32{instruction[31]}}, instruction[31:12], 12'b0};
            end
            
            // J-type (JAL)
            7'b1101111: begin
                format = 3'b101;  // J-type
                rd = instruction[11:7];
                // Immediate: [31] + [19:12] + [20] + [30:21] + 1b0
                imm = {{43{instruction[31]}}, instruction[31], instruction[19:12], 
                      instruction[20], instruction[30:21], 1'b0};
            end
            
            // RV64I specific
            7'b0011011: begin // ADDIW, SLLIW, etc.
                format = 3'b001;  // I-type
                rd = instruction[11:7];
                rs1 = instruction[19:15];
                funct3 = instruction[14:12];
                funct7 = instruction[31:25];  // For shift operations
                imm = {{52{instruction[31]}}, instruction[31:20]};  // Sign-extend
            end
            
            7'b0111011: begin // ADDW, SUBW, etc.
                format = 3'b000;  // R-type
                rd = instruction[11:7];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                funct3 = instruction[14:12];
                funct7 = instruction[31:25];
            end
            default: begin
                format = 3'b111;  // Invalid format
            end
        endcase
    end
endmodule
