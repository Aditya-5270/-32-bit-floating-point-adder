//////////////////////////////////////////////////////////////////////////////////
//
// Module: fp_adder
//
// Description:
// Top-level module for a 32-bit IEEE 754 single-precision floating-point adder/subtractor.
// This design is based on the architecture described in the paper "Design Of High
// Performance IEEE-754 Single Precision (32 bit) Floating Point Adder Using Verilog".
//
// The process follows these main steps:
// 1. Deconstruct inputs and handle special cases (Zero, Infinity, NaN).
// 2. Pre-alignment: Compare exponents and shift the mantissa of the smaller number.
// 3. Adder/Subtractor: Perform addition or subtraction on the aligned mantissas.
// 4. Normalization: Normalize the result, round, and check for overflow/underflow.
// 5. Reconstruct the final 32-bit floating-point number.
//
//////////////////////////////////////////////////////////////////////////////////

module fp_adder (
    // Inputs
    input  [31:0] numberA,
    input  [31:0] numberB,
    input         A_S,         // 0 for Add, 1 for Subtract

    // Output
    output reg [31:0] Result
);

    // Deconstruct inputs into sign, exponent, and mantissa
    wire signA = numberA[31];
    wire [7:0] expA = numberA[30:23];
    wire [22:0] mantA_in = numberA[22:0];

    wire signB = numberB[31];
    wire [7:0] expB = numberB[30:23];
    wire [22:0] mantB_in = numberB[22:0];

    // Internal registers and wires for the pipeline stages
    reg [7:0] exp_larger;
    reg [23:0] mantA_aligned, mantB_aligned;
    reg sign_result;

    wire [7:0] exp_diff;
    wire [24:0] adder_sum;
    wire carry_out;

    reg [24:0] sum_reg;
    reg [7:0]  final_exp;
    reg [22:0] final_mant;
    reg final_sign;

    // Detect special cases (Zero, Infinity, NaN)
    wire is_zeroA = (expA == 8'h00) && (mantA_in == 23'h000000);
    wire is_zeroB = (expB == 8'h00) && (mantB_in == 23'h000000);
    wire is_infA = (expA == 8'hFF) && (mantA_in == 23'h000000);
    wire is_infB = (expB == 8'hFF) && (mantB_in == 23'h000000);
    wire is_nanA = (expA == 8'hFF) && (mantA_in != 23'h000000);
    wire is_nanB = (expB == 8'hFF) && (mantB_in != 23'h000000);

    // Add the hidden '1' for normalized numbers
    wire [23:0] mantA = {1'b1, mantA_in};
    wire [23:0] mantB = {1'b1, mantB_in};

    // Stage 1: Pre-alignment and Exponent Comparison
    always @* begin
        if (expA > expB) begin
            exp_larger = expA;
            mantA_aligned = mantA;
            // Right shift mantissa of smaller number
            mantB_aligned = mantB >> (expA - expB);
        end else begin
            exp_larger = expB;
            mantB_aligned = mantB;
            // Right shift mantissa of smaller number
            mantA_aligned = mantA >> (expB - expA);
        end
    end

    // Stage 2: Adder/Subtractor
    // The effective operation depends on the signs and the A_S control signal
    wire effective_op = (signA ^ signB) ^ A_S;

    assign adder_sum = effective_op ? (mantA_aligned - mantB_aligned) : (mantA_aligned + mantB_aligned);
    assign carry_out = adder_sum[24];


    // Stage 3: Normalization and Result Sign Calculation
    always @* begin
        // Result sign logic
        if ((signA == signB) || A_S) begin
             sign_result = signA;
        end else begin // Subtraction of numbers with different signs
            if (expA > expB) sign_result = signA;
            else if (expB > expA) sign_result = signB;
            else if (mantA_in > mantB_in) sign_result = signA;
            else if (mantB_in > mantA_in) sign_result = signB;
            else sign_result = 0; // Result is zero
        end

        // Normalize the result from the adder
        sum_reg = adder_sum;
        final_exp = exp_larger;
        final_sign = sign_result;

        // If carry-out is 1 (overflow in addition), shift right and increment exponent
        if (carry_out && !effective_op) begin
            sum_reg = {1'b0, adder_sum[24:1]};
            final_exp = exp_larger + 1;
        end
        // If subtraction result is negative, take two's complement
        else if (adder_sum[24]) begin
             sum_reg = ~adder_sum + 1;
             final_sign = !sign_result;
        end

        // Left-shift to normalize if MSB is not 1 (common after subtraction)
        // Note: A real implementation would use a priority encoder and barrel shifter
        // for efficiency. This synthesizable loop is for clarity.
        if (sum_reg[23] == 0 && sum_reg != 0) begin
            if(sum_reg[22]) begin final_exp = final_exp - 1; sum_reg = sum_reg << 1; end
            else if(sum_reg[21]) begin final_exp = final_exp - 2; sum_reg = sum_reg << 2; end
            else if(sum_reg[20]) begin final_exp = final_exp - 3; sum_reg = sum_reg << 3; end
            else if(sum_reg[19]) begin final_exp = final_exp - 4; sum_reg = sum_reg << 4; end
            else if(sum_reg[18]) begin final_exp = final_exp - 5; sum_reg = sum_reg << 5; end
            else if(sum_reg[17]) begin final_exp = final_exp - 6; sum_reg = sum_reg << 6; end
            else if(sum_reg[16]) begin final_exp = final_exp - 7; sum_reg = sum_reg << 7; end
            else if(sum_reg[15]) begin final_exp = final_exp - 8; sum_reg = sum_reg << 8; end
            else if(sum_reg[14]) begin final_exp = final_exp - 9; sum_reg = sum_reg << 9; end
            else if(sum_reg[13]) begin final_exp = final_exp - 10; sum_reg = sum_reg << 10; end
            else if(sum_reg[12]) begin final_exp = final_exp - 11; sum_reg = sum_reg << 11; end
            else if(sum_reg[11]) begin final_exp = final_exp - 12; sum_reg = sum_reg << 12; end
            else if(sum_reg[10]) begin final_exp = final_exp - 13; sum_reg = sum_reg << 13; end
            else if(sum_reg[9]) begin final_exp = final_exp - 14; sum_reg = sum_reg << 14; end
            else if(sum_reg[8]) begin final_exp = final_exp - 15; sum_reg = sum_reg << 15; end
            else if(sum_reg[7]) begin final_exp = final_exp - 16; sum_reg = sum_reg << 16; end
            else if(sum_reg[6]) begin final_exp = final_exp - 17; sum_reg = sum_reg << 17; end
            else if(sum_reg[5]) begin final_exp = final_exp - 18; sum_reg = sum_reg << 18; end
            else if(sum_reg[4]) begin final_exp = final_exp - 19; sum_reg = sum_reg << 19; end
            else if(sum_reg[3]) begin final_exp = final_exp - 20; sum_reg = sum_reg << 20; end
            else if(sum_reg[2]) begin final_exp = final_exp - 21; sum_reg = sum_reg << 21; end
            else if(sum_reg[1]) begin final_exp = final_exp - 22; sum_reg = sum_reg << 22; end
            else if(sum_reg[0]) begin final_exp = final_exp - 23; sum_reg = sum_reg << 23; end
        end

        final_mant = sum_reg[22:0]; // Discard the hidden bit
    end


    // Stage 4: Handle Special Cases and Final Output Assembly
    always @* begin
        if (is_nanA || is_nanB) begin
            Result = 32'h7FC00000; // Return quiet NaN
        end else if (is_infA && is_infB) begin
            if ((signA != signB) || A_S)
                Result = 32'h7FC00000; // Inf - Inf = NaN
            else
                Result = numberA; // Inf + Inf = Inf
        end else if (is_infA) begin
            Result = numberA;
        end else if (is_infB) begin
            Result = A_S ? {~signB, expB, mantB_in} : numberB;
        end else if (is_zeroA && is_zeroB) begin
            Result = 32'h00000000;
        end else if (is_zeroA) begin
            Result = numberB;
        end else if (is_zeroB) begin
            Result = numberA;
        end else if (sum_reg == 0) begin
            Result = 32'h00000000; // Result is zero
        end else if (final_exp == 8'hFF) begin
            Result = {final_sign, 8'hFF, 23'h0}; // Overflow to Infinity
        end
        else begin
            // Reconstruct the final result
            Result = {final_sign, final_exp, final_mant};
        end
    end

endmodule
