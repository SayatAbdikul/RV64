module register_file (
    input logic clk,
    input logic rst,
    input logic [4:0] rs1, // Read register 1 address
    input logic [4:0] rs2, // Read register 2 address
    input logic [4:0] rd, // Write register address
    input logic [63:0] write_data, // Data to write
    input logic write_enable, // Register write enable
    output logic [63:0] read_data1, // Data from read register 1
    output logic [63:0] read_data2 // Data from read register 2
);
    
    // Register file array
    logic [63:0] registers [31:0];
    
    // Read operation
    always_comb begin
        read_data1 = registers[rs1];
        read_data2 = registers[rs2];
    end
    
    // Write operation
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers to zero on reset signal
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 64'b0;
            end
        end else if (write_enable && rd != 5'b00000) begin
            // Write data to the specified register if reg_write is enabled and not writing to x0
            registers[rd] <= write_data;
        end
    end
    
endmodule
