module core (
    input  logic        clk,
    input  logic        rst,
    output logic [63:0] result
);
    // Control signals
    logic        rst_sync;      // Synchronized reset
    logic        execute_en;    // Execution enable
    
    // PC signals
    logic [63:0] pc_next;
    logic [63:0] pc_out;
    
    // Instruction and result
    logic [31:0] instruction;
    logic [63:0] alu_result;
    
    // Synchronize reset to clock domain
    always_ff @(posedge clk) begin
        rst_sync <= rst;
    end
    
    // Execution enable logic - stays low during reset
    assign execute_en = ~rst_sync;
    
    // PC control logic
    assign pc_next = execute_en ? (pc_out + 4) : 64'h0;
    logic [4:0] rd, rs1, rs2;
    logic [63:0] imm;
    logic [2:0] funct3;
    logic [6:0] funct7, opcode;
    logic [2:0] format;
    // Instruction decoder
    i_decoder decoder (
        .instruction(instruction),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .imm(imm),
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .format(format)
    );

    // PC module instance
    pc pc_inst (
        .clk(clk),
        .reset(rst_sync),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );
    
    // Instruction memory instance
    inst_memory inst_mem (
        .pc(pc_out),
        .instruction(instruction)
    );
    
    // Core execute unit instance
    core_execute_unit exec_unit (
        .clk(clk),
        .rst(rst_sync),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .imm(imm),
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .format(format),
        .result(alu_result)
    );
    
    // Output result only when executing
    assign result = execute_en ? alu_result : 64'b0;
    
endmodule
