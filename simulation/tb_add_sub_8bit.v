`timescale 1ns/1ps
module tb_add_sub_8bit;
    reg clk;
    reg [7:0] A, B;
    reg Sel, AddSub;
    wire [7:0] Z;
    wire Overflow, Carryout;

    // Instantiate DUT
    add_sub_8bit DUT (
        .clk(clk),
        .A(A),
        .B(B),
        .Sel(Sel),
        .AddSub(AddSub),
        .Z(Z),
        .Overflow(Overflow),
        .Carryout(Carryout)
    );

    // Clock generator: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // In ra console khi có thay đổi
    initial begin
        $display("Time(ns)\tSel\tAddSub\tA\tB\tZ\tCarry\tOverflow");
        $monitor("%0dns\t%b\t%b\t%d\t%d\t%d\t%b\t%b",
                 $time, Sel, AddSub, A, B, Z, Carryout, Overflow);
    end

    // Simulation scenario
    initial begin
        $dumpfile("add_sub_8bit.vcd");   // output waveform file
        $dumpvars(0, tb_add_sub_8bit);

        // Case 1: Add
        A = 8'd25; B = 8'd10; Sel = 0; AddSub = 0; #20;

        // Case 2: Subtract
        A = 8'd40; B = 8'd15; Sel = 0; AddSub = 1; #20;

        // Case 3: Accumulate mode (add)
        Sel = 1; B = 8'd5; AddSub = 0; #20;

        // Case 4: Subtract in accumulate mode
        Sel = 1; B = 8'd3; AddSub = 1; #20;

        $display("=== Simulation Finished ===");
        $finish;
    end
endmodule
