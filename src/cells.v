/*
This file defines basic logic "cells" (primitives)
that Wokwi uses to map its graphical modules to Verilog HDL.

Not specific to Tiny Tapeout, but very common when exporting
designs from Wokwi.
*/

`define default_netname none   // Prevents creation of implicit nets without declarations (good ASIC practice)

// ======================================================================
// BUFFER cell: simply copies the input to the output
// ======================================================================
(* keep_hierarchy *)
module buffer_cell (
    input  wire in,   // Input signal
    output wire out   // Output signal
    );
    // The buffer does not change the signal, just forwards it
    assign out = in;
endmodule

// ======================================================================
// AND cell: 2-input AND gate
// ======================================================================
(* keep_hierarchy *)
module and_cell (
    input  wire a,    // Input A
    input  wire b,    // Input B
    output wire out   // Output = A AND B
    );

    assign out = a & b;
endmodule

// ======================================================================
// OR cell: 2-input OR gate
// ======================================================================
(* keep_hierarchy *)
module or_cell (
    input  wire a,    // Input A
    input  wire b,    // Input B
    output wire out   // Output = A OR B
    );

    assign out = a | b;
endmodule

// ======================================================================
// XOR cell: 2-input XOR (exclusive OR) gate
// ======================================================================
(* keep_hierarchy *)
module xor_cell (
    input  wire a,    // Input A
    input  wire b,    // Input B
    output wire out   // Output = A XOR B
    );

    assign out = a ^ b;
endmodule

// ======================================================================
// NAND cell: 2-input NAND gate (NOT of AND)
// ======================================================================
(* keep_hierarchy *)
module nand_cell (
    input  wire a,    // Input A
    input  wire b,    // Input B
    output wire out   // Output = NOT (A AND B)
    );

    assign out = !(a & b);
endmodule

// ======================================================================
// NOR cell: 2-input NOR gate (NOT of OR)
// ======================================================================
(* keep_hierarchy *)
module nor_cell (
    input  wire a,    // Input A
    input  wire b,    // Input B
    output wire out   // Output = NOT (A OR B)
    );

    assign out = !(a | b);
endmodule

// ======================================================================
// XNOR cell: 2-input XNOR gate (NOT of XOR)
// Equivalent to “A and B are equal”
// ======================================================================
(* keep_hierarchy *)
module xnor_cell (
    input  wire a,    // Input A
    input  wire b,    // Input B
    output wire out   // Output = NOT (A XOR B)
    );

    assign out = !(a ^ b);
endmodule

// ======================================================================
// NOT cell: inverter
// ======================================================================
(* keep_hierarchy *)
module not_cell (
    input  wire in,   // Input signal
    output wire out   // Output = NOT(in)
    );

    assign out = !in;
endmodule

// ======================================================================
// MUX cell: 2-to-1 multiplexer
// out = a when sel = 0
// out = b when sel = 1
// ======================================================================
(* keep_hierarchy *)
module mux_cell (
    input  wire a,    // Input 0
    input  wire b,    // Input 1
    input  wire sel,  // Select (0 -> a, 1 -> b)
    output wire out   // Output
    );

    assign out = sel ? b : a;
endmodule

// ======================================================================
// DFF cell: simple D-type flip-flop
// No asynchronous reset, just captures D on rising edge of clk
// ======================================================================
(* keep_hierarchy *)
module dff_cell (
    input  wire clk,  // Clock input (active on rising edge)
    input  wire d,    // Data input
    output reg  q,    // Registered output
    output wire notq  // Inverted output
    );

    // notq is always the logical NOT of q
    assign notq = !q;

    // On each rising edge of clk, capture D into Q
    always @(posedge clk)
        q <= d;

endmodule

// ======================================================================
// DFFR cell: D-type flip-flop with asynchronous reset
// When r = 1, q is cleared to 0 immediately (async reset).
// Otherwise, q follows d on the rising edge of clk.
// ======================================================================
(* keep_hierarchy *)
module dffr_cell (
    input  wire clk,  // Clock input (rising edge triggered)
    input  wire d,    // Data input
    input  wire r,    // Asynchronous reset (active high)
    output reg  q,    // Registered output
    output wire notq  // Inverted output
    );

    assign notq = !q;

    always @(posedge clk or posedge r) begin
        if (r)
            q <= 0;   // Asynchronous reset: force q to 0
        else
            q <= d;   // Normal operation: capture d
    end
endmodule

// ======================================================================
// DFFSR cell: D-type flip-flop with asynchronous set and reset
// Priority: reset (r) > set (s) > d
// - If r = 1: q is forced to 0
// - Else if s = 1: q is forced to 1
// - Else: q follows d on rising edge of clk
// ======================================================================
(* keep_hierarchy *)
module dffsr_cell (
    input  wire clk,  // Clock input (rising edge triggered)
    input  wire d,    // Data input
    input  wire s,    // Asynchronous set (active high)
    input  wire r,    // Asynchronous reset (active high)
    output reg  q,    // Registered output
    output wire notq  // Inverted output
    );

    assign notq = !q;

    always @(posedge clk or posedge s or posedge r) begin
        if (r)
            q <= 0;   // Highest priority: reset
        else if (s)
            q <= 1;   // Second: set
        else
            q <= d;   // Otherwise: capture d
    end
endmodule
