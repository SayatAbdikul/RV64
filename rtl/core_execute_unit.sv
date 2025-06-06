module core_execute_unit (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instruction,
    output logic [63:0] result  // Changed to 64-bit for RV64
);
    // Signal declarations
    logic [4:0]  rd, rs1, rs2;
    logic [63:0] imm;
    logic [2:0]  funct3;
    logic [6:0]  funct7, opcode;
    logic [2:0]  format;  // Fixed to 3-bit width
    
    logic [63:0] a, b;          // ALU inputs
    logic [63:0] reg_read_data1; // From register file
    logic [63:0] reg_read_data2; // From register file
    logic [4:0]  alu_sel;       // ALU operation selector
    
    // Instantiate instruction decoder
    i_decoder decoder (
        .instruction(instruction),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .imm(imm),
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),  // Not used in this module
        .format(format)
    );
    
    // Instantiate register file (64-bit registers)
    register_file reg_file (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(result),     // 64-bit result
        .write_enable(1'b1),     // Always write back for now
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );
    
    // Operand selection mux
    always_comb begin
        a = reg_read_data1;  // Always use rs1 value
        
        // Select between register rs2 or immediate
        if (format == 3'b001) begin  // I-type
            b = imm;
        end else begin                // R-type/others
            b = reg_read_data2;
        end
    end

    // ALU control logic
    always_comb begin
        alu_sel = 5'b11111;  // Default invalid operation
        
        case(format) 
            3'b000: begin // R-type
                case(funct3)
                    3'b000: begin
                        if(opcode == 7'b0110011) begin
                            alu_sel = (funct7 == 7'b0000000) ? 5'b00000 : 5'b00001; // ADD or SUB
                        end else if(opcode == 7'b0111011) begin
                            alu_sel = (funct7 == 7'b0000000) ? 5'b01010 : 5'b01011; // ADDW or SUBW
                        end
                    end
                    3'b001: begin
                        if(opcode == 7'b0110011) begin
                            alu_sel = 5'b00111; // SLL
                        end else if(opcode == 7'b0111011) begin
                            alu_sel = 5'b01100; // SLLW
                        end
                    end
                    3'b010: alu_sel = 5'b00101; // SLT
                    3'b011: alu_sel = 5'b00110; // SLTU
                    3'b100: alu_sel = 5'b00100; // XOR
                    3'b101: begin
                        if(opcode == 7'b0110011) begin
                            alu_sel = (funct7 == 7'b0000000) ? 5'b01000 : 5'b01001; // SRL or SRA
                        end else if(opcode == 7'b0111011) begin
                            alu_sel = (funct7 == 7'b0000000) ? 5'b01101 : 5'b01110; // SRLW or SRAW
                        end
                    end
                    3'b110: alu_sel = 5'b00101; // OR
                    3'b111: alu_sel = 5'b00010; // AND
                endcase
            end
            
            3'b001: begin // I-type
                case(funct3)
                    3'b000: alu_sel = opcode == 7'b0010011 ? 5'b00000 : 5'b01010; // ADDI or ADDIW
                    3'b001: alu_sel = opcode == 7'b0010011 ? 5'b00111 : 5'b01100; // SLLI or SLLIW
                    3'b010: alu_sel = 5'b00101; // SLTI
                    3'b011: alu_sel = 5'b00110; // SLTIU
                    3'b100: alu_sel = 5'b00100; // XORI
                    3'b101: begin
                        if(opcode == 7'b0010011) begin
                            alu_sel = (funct7 == 7'b0000000) ? 5'b01000 : 5'b01001; // SRLI or SRAI
                        end else if(opcode == 7'b0011011) begin
                            alu_sel = (funct7 == 7'b0000000) ? 5'b01101 : 5'b01110; // SRLIW or SRAIW
                        end
                    end
                    3'b110: alu_sel = 5'b00011; // ORI
                    3'b111: alu_sel = 5'b00010; // ANDI
                endcase
            end
            
            default: begin // Other formats (S, B, U, J)
                alu_sel = 5'b11111; // No operation for unsupported formats
            end
        endcase
    end

    // Instantiate ALU (64-bit)
    alu alu_instance (
        .a(a),
        .b(b),
        .sel(alu_sel),
        .result(result)
    );

endmodule
