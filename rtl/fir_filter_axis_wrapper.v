`timescale 1ns/1ps

module fir_filter_axis_wrapper #(
    parameter ORDER             = 50,
              AXIS_WIDTH        = 16,
              BIT_WIDTH         = 16,
              FRACTIONAL_WIDTH  = 15,
              COEFFICIENT_WIDTH = 16
) (
    input  wire                 clk,
    input  wire                 resetn,

    input  wire                 s_axis_filter_tvalid,
    input  wire                 s_axis_filter_tlast,
    output wire                 s_axis_filter_tready,
    input  wire [AXIS_WIDTH-1:0] s_axis_filter_tdata,

    output wire                 m_axis_filter_tvalid,
    input  wire                 m_axis_filter_tready,
    output wire                 m_axis_filter_tlast,
    output wire [AXIS_WIDTH-1:0] m_axis_filter_tdata
);
    localparam COEFFICIENT_NUMBER = $rtoi($floor(ORDER/2));
    localparam PIPE_DELAY         = COEFFICIENT_NUMBER + 4;

    fir_filter_axis #(
        .ORDER(ORDER),    
        .AXIS_WIDTH(AXIS_WIDTH),
        .BIT_WIDTH(BIT_WIDTH),
        .FRACTIONAL_WIDTH(FRACTIONAL_WIDTH),
        .COEFFICIENT_WIDTH(COEFFICIENT_WIDTH),
        .COEFFICIENT_NUMBER(COEFFICIENT_NUMBER),
        .PIPE_DELAY(PIPE_DELAY)
    ) fir_filter (
        .clk(clk),
        .reset(~resetn),
        .s_axis_filter_tvalid(s_axis_filter_tvalid),
        .s_axis_filter_tready(s_axis_filter_tready),
        .s_axis_filter_tlast(s_axis_filter_tlast),
        .s_axis_filter_tdata(s_axis_filter_tdata),
        .m_axis_filter_tvalid(m_axis_filter_tvalid),
        .m_axis_filter_tready(m_axis_filter_tready),
        .m_axis_filter_tlast(m_axis_filter_tlast),
        .m_axis_filter_tdata(m_axis_filter_tdata)
    );

endmodule