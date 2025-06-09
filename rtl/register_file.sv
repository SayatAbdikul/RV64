module register_file (
    input logic clk,
    input logic rst,
    input logic [4:0] rs1,
    input logic [4:0] rs2, 
    input logic [4:0] rd,
    input logic [63:0] write_data,
    input logic write_enable,
    output logic [63:0] read_data1,
    output logic [63:0] read_data2
);
    
    logic [63:0] registers [31:0];
    
    // Read operation - registered to hold values stable during cycle
    always_comb begin
        read_data1 = registers[rs1];
        read_data2 = registers[rs2];
    end
    
    // Write operation  
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 64'b0;
            end
        end else if (write_enable && rd != 5'b0) begin
            //$display("Writing to register %d with data %0d", rd, write_data);
            registers[rd] <= write_data;
        end
    end
    
endmodule
