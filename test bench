//////////////////////////////////////////////////////////////////////////////////
//
// Module: fp_adder_tb
//
// Description:
// Testbench for the 32-bit IEEE 754 single-precision floating-point adder/subtractor.
//
// This testbench covers a range of scenarios:
// 1.  Normal addition and subtraction.
// 2.  Cases with different exponents requiring mantissa alignment.
// 3.  Cases requiring result normalization.
// 4.  Special cases: Zero, Infinity, and NaN.
// 5.  Overflow and underflow scenarios.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module fp_adder_tb;

    // Inputs
    reg  [31:0] numberA;
    reg  [31:0] numberB;
    reg         A_S; // 0 for Add, 1 for Subtract

    // Output
    wire [31:0] Result;

    // Instantiate the Device Under Test (DUT)
    fp_adder dut (
        .numberA(numberA),
        .numberB(numberB),
        .A_S(A_S),
        .Result(Result)
    );

    // Test sequence
    initial begin
        $display("-----------------------------------------------------");
        $display("Starting Floating Point Adder/Subtractor Testbench");
        $display("-----------------------------------------------------");

        // Test Case 1: Simple Addition (1.5 + 2.75 = 4.25)
        numberA = 32'h3FC00000; // 1.5
        numberB = 32'h40300000; // 2.75
        A_S = 0;
        #10;
        $display("Test 1: 1.5 + 2.75");
        $display("A = %h, B = %h, Result = %h (Expected: 40880000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");


        // Test Case 2: Subtraction (10.0 - 5.5 = 4.5)
        numberA = 32'h41200000; // 10.0
        numberB = 32'h40B00000; // 5.5
        A_S = 1;
        #10;
        $display("Test 2: 10.0 - 5.5");
        $display("A = %h, B = %h, Result = %h (Expected: 40900000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");

        // Test Case 3: Addition with different signs (-12.5 + 4.25 = -8.25)
        numberA = 32'hC1480000; // -12.5
        numberB = 32'h40880000; // 4.25
        A_S = 0;
        #10;
        $display("Test 3: -12.5 + 4.25");
        $display("A = %h, B = %h, Result = %h (Expected: C1040000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");

        // Test Case 4: Subtraction resulting in a negative number (3.0 - 8.5 = -5.5)
        numberA = 32'h40400000; // 3.0
        numberB = 32'h41080000; // 8.5
        A_S = 1;
        #10;
        $display("Test 4: 3.0 - 8.5");
        $display("A = %h, B = %h, Result = %h (Expected: C0B00000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");

        // Test Case 5: Addition requiring normalization (carry out) (1.0 + 1.0 = 2.0)
        numberA = 32'h3F800000; // 1.0
        numberB = 32'h3F800000; // 1.0
        A_S = 0;
        #10;
        $display("Test 5: 1.0 + 1.0 (Normalization)");
        $display("A = %h, B = %h, Result = %h (Expected: 40000000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");
        
        // --- Special Cases ---

        // Test Case 6: Add Zero (15.5 + 0 = 15.5)
        numberA = 32'h41780000; // 15.5
        numberB = 32'h00000000; // 0.0
        A_S = 0;
        #10;
        $display("Test 6: Add Zero (15.5 + 0)");
        $display("A = %h, B = %h, Result = %h (Expected: 41780000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");
        
        // Test Case 7: Subtract Zero (-15.5 - 0 = -15.5)
        numberA = 32'hC1780000; // -15.5
        numberB = 32'h00000000; // 0.0
        A_S = 1;
        #10;
        $display("Test 7: Subtract Zero (-15.5 - 0)");
        $display("A = %h, B = %h, Result = %h (Expected: C1780000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");

        // Test Case 8: Add Infinity (100.0 + Inf = Inf)
        numberA = 32'h42C80000; // 100.0
        numberB = 32'h7F800000; // +Infinity
        A_S = 0;
        #10;
        $display("Test 8: Add Infinity (100.0 + Inf)");
        $display("A = %h, B = %h, Result = %h (Expected: 7F800000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");
        
        // Test Case 9: Subtract Infinity (Inf - Inf = NaN)
        numberA = 32'h7F800000; // +Infinity
        numberB = 32'h7F800000; // +Infinity
        A_S = 1;
        #10;
        $display("Test 9: Subtract Infinity (Inf - Inf)");
        $display("A = %h, B = %h, Result = %h (Expected: 7FC00000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");

        // Test Case 10: Operation with NaN (NaN + 10.0 = NaN)
        numberA = 32'h7FC00001; // NaN
        numberB = 32'h41200000; // 10.0
        A_S = 0;
        #10;
        $display("Test 10: Operation with NaN (NaN + 10.0)");
        $display("A = %h, B = %h, Result = %h (Expected: 7FC00000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");
        
        // Test Case 11: Subtraction resulting in Zero (10.0 - 10.0 = 0.0)
        numberA = 32'h41200000; // 10.0
        numberB = 32'h41200000; // 10.0
        A_S = 1;
        #10;
        $display("Test 11: Subtraction resulting in Zero (10.0 - 10.0)");
        $display("A = %h, B = %h, Result = %h (Expected: 00000000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");
        
        // Test Case 12: Overflow to Infinity
        numberA = 32'h7F7FFFFF; // Max normal number
        numberB = 32'h7F7FFFFF; // Max normal number
        A_S = 0;
        #10;
        $display("Test 12: Overflow to Infinity");
        $display("A = %h, B = %h, Result = %h (Expected: 7F800000)", numberA, numberB, Result);
        $display("-----------------------------------------------------");

        $display("Testbench finished.");
        $finish;
    end

endmodule
