`timescale 1ns/1ps
module fir_fifo_system_tb;
    localparam CLK_PERIOD_128 = 7.8125;
    localparam CLK_PERIOD_64 = 15.625;
    logic clk_128MHz = 0;
    logic clk_64MHz = 0;
    logic resetn = 0;
    logic [31:0] S_AXIS_0_tdata;
    logic S_AXIS_0_tlast, S_AXIS_0_tvalid, S_AXIS_0_tready;
    logic [31:0] M_AXIS_0_tdata;
    logic M_AXIS_0_tlast, M_AXIS_0_tvalid, M_AXIS_0_tready;


    // design_1_wrapper dut(.*);
    
    fir_fifo_system_wrapper dut(.*);

    initial forever
        #(CLK_PERIOD_128/2) clk_128MHz <= ~clk_128MHz;
    
    initial forever
         #(CLK_PERIOD_64/2) clk_64MHz <= ~clk_64MHz;
    
    initial begin
        repeat(2) @(posedge clk_128MHz);
        resetn <= 1;

        wait(dut.fir_fifo_system_i.fir_filter_axis_wrap_0.resetn == 1);
        repeat(4) @(posedge clk_64MHz);
        @(posedge clk_64MHz);
        M_AXIS_0_tready <= 1;
        S_AXIS_0_tvalid <= 1;
        S_AXIS_0_tlast  <= 0;
        S_AXIS_0_tdata  <= 32'h7fff;

        @(posedge clk_64MHz)
        M_AXIS_0_tready <= 1;
        S_AXIS_0_tvalid <= 1;
        S_AXIS_0_tlast  <= 0;
        S_AXIS_0_tdata  <= 32'd0;

        repeat(49) @(posedge clk_64MHz);
        M_AXIS_0_tready <= 1;
        S_AXIS_0_tvalid <= 1;
        S_AXIS_0_tlast  <= 1;
        S_AXIS_0_tdata  <= 32'd0;

        @(posedge clk_64MHz);
        M_AXIS_0_tready <= 1;
        S_AXIS_0_tvalid <= 0;
        S_AXIS_0_tlast  <= 0;
        S_AXIS_0_tdata  <= 32'd0;

        repeat(4) @(posedge clk_64MHz);
        M_AXIS_0_tready <= 1;
        S_AXIS_0_tvalid <= 0;
        S_AXIS_0_tlast  <= 0;
        S_AXIS_0_tdata  <= 32'd0;

        // $finish();

    end
endmodule