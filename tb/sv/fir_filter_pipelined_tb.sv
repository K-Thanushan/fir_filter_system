`timescale 1ns/1ps

module fir_filter_pipelined_tb;
    localparam ORDER=9, BIT_WIDTH = 16;
    localparam clk_period = 10;
    logic signed [BIT_WIDTH-1:0] x;
    logic signed [BIT_WIDTH-1:0] y;
    logic clk=0, reset, enable;

    fir_filter_pipelined #(
        .ORDER(ORDER),
        .BIT_WIDTH(BIT_WIDTH)
    ) dut(
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .x(x),
        .y(y)
    );

    initial forever
        #(clk_period/2) clk <= ~clk;
    
    initial begin
        @(posedge clk);
        reset <= 1;
        repeat(2) @(posedge clk);
        reset <= 0;
        enable <= 1;
        x <= 8'd1;
        @(posedge clk);
        x <= 8'd2;
        @(posedge clk);
        x <= 8'd3;
        @(posedge clk);
        x <= 8'd4;
        @(posedge clk);
        x <= 8'd5;
        @(posedge clk);
        x <= 8'd6;
        @(posedge clk);
        x <= 8'd7;
        @(posedge clk);
        x <= 8'd8;
        @(posedge clk);
        x <= 8'd9;
        @(posedge clk);
        x <= 8'd10;
        @(posedge clk);
        x <= 8'd11;
        @(posedge clk);
        x <= 8'd12;
        @(posedge clk);
        x <= 8'd13;
        @(posedge clk);
        x <= 8'd14;
        @(posedge clk);
        x <= 8'd15;
        @(posedge clk);
        x <= 8'd16;
        @(posedge clk);
        x <= 8'd17;
        @(posedge clk);
         x <= 8'd18;
        @(posedge clk);
        x <= 8'd19;
        @(posedge clk);
        x <= 8'd20;
        @(posedge clk);
        x <= 8'd21;
        @(posedge clk);
        $finish();
    end
    
endmodule