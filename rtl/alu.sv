module alu #(
    parameter DATA_WIDTH = 64, 
              WORD_WIDTH = 32 // Operation code width
) (
    input logic [DATA_WIDTH-1:0] a,
    input logic [DATA_WIDTH-1:0] b,
    input logic [4:0] sel, // 5-bit operation select
    output logic [DATA_WIDTH-1:0] result
);
// ALU operations
localparam ADD = 5'b00000;
localparam SUB = 5'b00001;
localparam AND = 5'b00010;
localparam OR = 5'b00011;
localparam XOR = 5'b00100;
localparam SLT = 5'b00101;
localparam SLTU = 5'b00110;
localparam SLL = 5'b00111;
localparam SRL = 5'b01000;
localparam SRA = 5'b01001;
localparam ADDW = 5'b01010;
localparam SUBW = 5'b01011;
localparam SLLW = 5'b01100;
localparam SRLW = 5'b01101;
localparam SRAW = 5'b01110;
logic [DATA_WIDTH-1:0] add_res;
logic [DATA_WIDTH-1:0] sub_res;
logic [DATA_WIDTH-1:0] sll_res;
logic [DATA_WIDTH-1:0] srl_res;
logic [DATA_WIDTH-1:0] sra_res;
logic [WORD_WIDTH-1:0] sllw_res;
logic [WORD_WIDTH-1:0] srlw_res;
logic [WORD_WIDTH-1:0] sraw_res;
assign add_res = a + b; // Add operation
assign sub_res = $unsigned( $signed(a) - $signed(b) ); // Subtract operation
assign sll_res = a << b[5:0]; // Logical left shift
assign srl_res = a >> b[5:0]; // Logical left shift
assign sra_res = $signed(a) >>> b[4:0]; // Arithmetic right shift
assign sllw_res = a[31:0] << b[4:0]; // Logical word left shift
assign srlw_res = a[31:0] >> b[4:0]; // Logical left shift
assign sraw_res = $signed(a[31:0]) >>> b[4:0]; // Arithmetic right shift
always_comb begin
    // $display("ALU operation selected: %0b", sel);
    case (sel)
        ADD: begin
            result = add_res;
            //$display("ALU ADD operation: %0d + %0d = %0d", a, b, result);
        end // Add operation
        SUB: begin
            result = sub_res;
            //$display("ALU SUB operation: %0d - %0d = %0d", a, b, result);
        end
        AND: begin
            result = a & b;
            $display("ALU AND operation: %0d & %0d = %0d", a, b, result);
        end
        OR:  begin
            result = a | b;
            //$display("ALU OR operation: %0d | %0d = %0d", a, b, result);
        end
        XOR: begin
            result = a ^ b;
            //$display("ALU XOR operation: %0d ^ %0d = %0d", a, b, result);
        end
        SLT: begin
            result = ($signed(a) < $signed(b)) ? 1 : 0; // Set less than
            //$display("ALU SLT operation: %0d < %0d = %0d", a, b, result);
        end
        SLTU: begin
            result = (a < $unsigned($signed(b))) ? 1 : 0; // Set less than unsigned
            $display("ALU SLTU operation: %0d < %0d = %0d", a, $unsigned($signed(b)), result);
        end
        SLL: begin
            result = sll_res; // Logical left shift
            //$display("ALU SLL operation: %0d << %0d = %0d", a, b[5:0], result);
        end
        SRL: begin
            result = srl_res; // Logical right shift
            //$display("ALU SRL operation: %0d >> %0d = %0d", a, b[5:0], result);
        end
        SRA: begin
            result = sra_res; // Arithmetic right shift
            //$display("ALU SRA operation: %0d >>> %0d = %0d", a, b[5:0], result);
        end
        ADDW: result = { {32{add_res[31]}}, add_res[31:0]}; // Add word
        SUBW: result = { {32{sub_res[31]}}, sub_res[31:0]}; // Subtract word
        SLLW: result = { {32{sllw_res[31]}}, sllw_res}; // Shift left logical word
        SRLW: result = { {32{srlw_res[31]}}, srlw_res}; // Shift right logical word
        SRAW: result = { {32{sraw_res[31]}}, sraw_res}; // Shift right arithmetic word
        default: result = 0; // Default case to avoid latches
    endcase
end
    
endmodule
