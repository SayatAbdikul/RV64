module pc (
    input  logic clk,
    input  logic reset,
    input  logic [63:0] pc_next,
    output logic [63:0] pc_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 64'h0000_0000_0000_0000;  // Reset vector
        else
            pc_out <= pc_next;
    end
endmodule
