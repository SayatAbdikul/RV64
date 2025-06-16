module core_execute_unit (
    input logic [63:0]  reg_read_data1,
    input logic [63:0]  reg_read_data2,
    input logic [63:0] imm,
    input logic [2:0]  funct3,
    input logic [6:0]  funct7,
    input logic [6:0]  opcode,
    input logic [2:0]  format, // Format type (R=0, I=1, S=2, B=3, U=4, J=5)
    output logic [63:0] result
);

    
    logic [63:0] a, b;
    logic [4:0]  alu_sel;
    logic [63:0] result_comb;
    
    // Pipelined write signals
    //logic        wr_en;         // Pipelined write enable
    
    
    
    
    
    // Operand selection
    always_comb begin
        a = reg_read_data1;
        b = (format == 3'b001) ? imm : reg_read_data2;  // I-type uses immediate
    end


    // ALU control logic
    always_comb begin
        alu_sel = 5'b11111;  // Default invalid operation
        //$display("the instruction is %h the opcode is %b, funct3 is %b, funct7 is %b, format is %b", instruction, opcode, funct3, funct7, format);
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
                    3'b100: begin
                        alu_sel = 5'b00100; // XOR
                        //$display("XOR: rs1 = %h, rs2 = %h, rd = %h", rs1, rs2, rd);
                    end
                    3'b101: begin
                        if(opcode == 7'b0110011) begin
                            alu_sel = (funct7 == 7'b0000000) ? 5'b01000 : 5'b01001; // SRL or SRA
                        end else if(opcode == 7'b0111011) begin
                            alu_sel = (funct7 == 7'b0000000) ? 5'b01101 : 5'b01110; // SRLW or SRAW
                        end
                    end
                    3'b110: alu_sel = 5'b00011; // OR
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
// ALU instance
    alu alu_instance (
        .a(a),
        .b(b),
        .sel(alu_sel),
        .result(result_comb)   // Combinational result
    );
    
    //assign wr_en   = (format inside {3'b000, 3'b001}) && (rd != 0);
    assign result  = result_comb;

endmodule
