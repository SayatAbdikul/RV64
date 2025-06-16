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
    logic [4:0] rd, rs1, rs2;
    logic [63:0] imm;
    logic [2:0] funct3;
    logic [6:0] funct7, opcode;
    logic [2:0] format;
    logic branch_taken; // Branch taken signal
    // Instruction decoder
    branch branch_inst (
        .format(format),
        .imm(imm),
        .funct3(funct3),
        .a(reg_read_data1),
        .b(reg_read_data2),
        .pc(pc_out),
        .branch_taken(branch_taken),
        .branch_target(pc_next)
    );
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
    logic [63:0] reg_read_data1, reg_read_data2;
    logic [63:0] wr_data; // Write data to register file
    // ALU result assignment
    assign wr_data = alu_result; // For this example, we write ALU result back to register file
    // Register file instance
    register_file reg_file (
        .clk(clk),
        .rst(rst_sync),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(wr_data),
        .write_enable(~branch_taken),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );
    // Core execute unit instance
    core_execute_unit exec_unit (
        .reg_read_data1(reg_read_data1),
        .reg_read_data2(reg_read_data2),
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
