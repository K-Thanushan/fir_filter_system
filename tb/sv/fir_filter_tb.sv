`timescale 1ns/1ps

module fir_filter_tb;
    localparam n=2, w_x=8, w_h=8, w_y = w_x + w_h + n;
    localparam clk_period = 10;
    localparam c_e = (n+1)*w_h;
    logic signed [w_x-1:0] x;
    logic signed [c_e-1:0] Hz;
    logic signed [w_y-1:0] y;
    logic clk=0, reset;

    fir_filter_parameterized #(
        .n(n),
        .w_x(w_x),
        .w_h(w_h)
    ) dut(
        .clk(clk),
        .reset(reset),
        .x(x),
        .Hz(Hz),
        .y(y)
    );

    initial forever
        #(clk_period/2) clk <= ~clk;
    
    initial begin
        @(posedge clk);
        reset <= 1;
        repeat(2) @(posedge clk);
        reset <= 0;
        x <= 8'd1;
        Hz <= 24'h010203; //64'h0001000200030004;
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