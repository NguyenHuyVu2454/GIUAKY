//==============================
// Top-level module for DE2 board
//==============================
module top_add_sub_8bit (
    input  [15:0] SW,       // SW[7:0] = A, SW[15:8] = B
    input  [3:0]  KEY,      // KEY[0]=Add/Sub, KEY[1]=Sel, KEY[3]=Clock
    output [6:0]  HEX0,     // A lower
    output [6:0]  HEX1,     // A upper
    output [6:0]  HEX2,     // B lower
    output [6:0]  HEX3,     // B upper
    output [6:0]  HEX4,     // Z lower
    output [6:0]  HEX5,     // Z upper
    output [7:0]  LEDR,     // Result in binary
    output [1:0]  LEDG      // LEDG[0]=Overflow, LEDG[1]=Carryout
);

    wire [7:0] A, B, Z;
    wire Sel, AddSub, clk;
    wire Overflow, Carryout;

    assign A = SW[7:0];
    assign B = SW[15:8];
    assign AddSub = KEY[0];
    assign Sel = KEY[1];
    assign clk = ~KEY[3];   // KEY active-low, đảo lại để có xung clock dương

    // Instantiate main adder/subtractor
    add_sub_8bit core (
        .clk(clk),
        .A(A),
        .B(B),
        .Sel(Sel),
        .AddSub(AddSub),
        .Z(Z),
        .Overflow(Overflow),
        .Carryout(Carryout)
    );

    // Hiển thị kết quả
    assign LEDR = Z;
    assign LEDG[0] = Overflow;
    assign LEDG[1] = Carryout;

    // Hiển thị lên 7-seg
    hex7seg h0(A[3:0], HEX0);
    hex7seg h1(A[7:4], HEX1);
    hex7seg h2(B[3:0], HEX2);
    hex7seg h3(B[7:4], HEX3);
    hex7seg h4(Z[3:0], HEX4);
    hex7seg h5(Z[7:4], HEX5);

endmodule


//==============================
// Core logic 8-bit adder/subtractor with accumulator
//==============================
module add_sub_8bit (
    input clk,
    input [7:0] A, B,
    input Sel,       // 0: A ± B, 1: Z ± B (accumulate)
    input AddSub,    // 0: Add, 1: Sub
    output reg [7:0] Z,
    output reg Overflow,
    output reg Carryout
);
    reg [7:0] Areg, Breg, Zreg;
    reg SelR, AddSubR;
    wire [7:0] G, H, M;
    wire carryin, carryout;
    wire over_flow;

    // Đưa dữ liệu vào thanh ghi tại cạnh dương xung clock
    always @(posedge clk) begin
        Areg <= A;
        Breg <= B;
        SelR <= Sel;
        AddSubR <= AddSub;
    end

    assign carryin = AddSubR;
    assign H = Breg ^ {8{AddSubR}};  // đảo bit B khi trừ
    assign G = SelR ? Zreg : Areg;   // chọn A hoặc Z (accumulate)
    assign {carryout, M} = G + H + carryin;

    // Phát hiện overflow
    assign over_flow = (G[7] & H[7] & ~M[7]) | (~G[7] & ~H[7] & M[7]);

    // Ghi kết quả vào Zreg
    always @(posedge clk) begin
        Zreg <= M;
        Z <= Zreg;
        Overflow <= over_flow;
        Carryout <= carryout;
    end
endmodule


//==============================
// 7-segment decoder module
//==============================
module hex7seg (
    input [3:0] hex,
    output reg [6:0] seg
);
    always @(*) begin
        case (hex)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
