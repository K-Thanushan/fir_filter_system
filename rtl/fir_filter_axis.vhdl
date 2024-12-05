-- Use Standard Library
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_pkg.all;
use work.fir_fixed_generics_package.all;
use work.fixed_to_signed_package.all;

--Entity
entity fir_filter_axis is
    generic(
        ORDER              : integer := ORDER;
        AXIS_WIDTH         : integer := AXIS_WIDTH;
        BIT_WIDTH          : integer := BIT_WIDTH;
        FRACTIONAL_WIDTH   : integer := FRACTIONAL_WIDTH;
        COEFFICIENT_WIDTH  : integer := COEFFICIENT_WIDTH;
        COEFFICIENT_NUMBER : integer := COEFFICIENT_NUMBER;
        PIPE_DELAY         : integer := PIPE_DELAY
    );
    port (
        clk                  : in  std_logic;
        reset                : in  std_logic;

        s_axis_filter_tvalid : in  std_logic;
        s_axis_filter_tready : out std_logic;
        s_axis_filter_tlast  : in  std_logic;
        s_axis_filter_tdata  : in  signed(AXIS_WIDTH - 1 downto 0);
        
        m_axis_filter_tvalid : out std_logic;
        m_axis_filter_tready : in  std_logic;
        m_axis_filter_tlast  : out std_logic;
        m_axis_filter_tdata  : out signed(AXIS_WIDTH - 1 downto 0)
    );
end entity fir_filter_axis;

-- Architecture
architecture firaxis of fir_filter_axis is
    signal axis_last_shift  : std_logic_vector(PIPE_DELAY - 1 downto 0);
    signal enable_in        : std_logic;
    signal x                : signed(BIT_WIDTH - 1 downto 0);
    signal y                : signed(BIT_WIDTH - 1 downto 0);
    signal y_valid          : std_logic;
    signal last_reg         : std_logic;
    signal count_valid      : signed(FIFO_DELAY-1 downto 0);

    component fir_filter_fixed
        generic(
            ORDER              : integer := ORDER;
            BIT_WIDTH          : integer := BIT_WIDTH;
            FRACTIONAL_WIDTH   : integer := FRACTIONAL_WIDTH;
            COEFFICIENT_WIDTH  : integer := COEFFICIENT_WIDTH;
            COEFFICIENT_NUMBER : integer := COEFFICIENT_NUMBER
        );
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            enable : in  std_logic;
            x_valid: in  std_logic;
            x      : in  signed(BIT_WIDTH - 1 downto 0);
            y_valid: out std_logic;
            y      : out signed(BIT_WIDTH - 1 downto 0)
        );
    end component;
    begin
        x <= resize(s_axis_filter_tdata, x'length);
        -- enable_in <= '1' when (m_axis_filter_tready = '1') else '0';
        s_axis_filter_tready <= m_axis_filter_tready;
        
        enable_process : process (last_reg, s_axis_filter_tvalid,m_axis_filter_tready,s_axis_filter_tlast)
        begin
            if (m_axis_filter_tready = '1' and s_axis_filter_tvalid = '1') then
                enable_in <= '1';
            elsif (m_axis_filter_tready = '1' and s_axis_filter_tvalid = '0') then
                enable_in <= last_reg;
            else
                enable_in <= '0';
            end if;
        end process;

        count_valid_process : process (clk)
        begin
            if (rising_edge(clk)) then
                if (reset = '1') then
                    count_valid <= (others => '0');
                else
                    if ((count_valid < FIFO_DELAY) and (y_valid = '1')) then
                        count_valid <= count_valid + 1;
                    else
                        count_valid <= to_signed(1, count_valid'length);
                    end if;
                end if;
            end if;
        end process;

        
        axis_process : process(clk)
        begin
            if (rising_edge(clk)) then
                if (reset = '1') then
                    axis_last_shift  <= (others => '0');
                else
                    if (s_axis_filter_tvalid = '1' and m_axis_filter_tready = '1') then
                        axis_last_shift(0)                         <= s_axis_filter_tlast;
                        axis_last_shift(PIPE_DELAY - 1 downto 1)   <= axis_last_shift(PIPE_DELAY - 2 downto 0);
                    elsif (m_axis_filter_tready = '1' and s_axis_filter_tvalid = '0') then
                        if (last_reg = '1') then
                            axis_last_shift(0)                         <= s_axis_filter_tlast;
                            axis_last_shift(PIPE_DELAY - 1 downto 1)   <= axis_last_shift(PIPE_DELAY - 2 downto 0);
                        else
                            axis_last_shift  <= axis_last_shift;
                        end if;
                    else
                        axis_last_shift  <= axis_last_shift;
                    end if;
                end if;
            end if;
        end process;
        
        last_process : process (clk)
        begin
            if rising_edge(clk) then
                if (reset = '1') then
                    last_reg <= '0';
                else
                    if (axis_last_shift(PIPE_DELAY-1) = '0') then
                        last_reg <= s_axis_filter_tlast;
                    else
                        last_reg <= '0';
                    end if;
                end if;
            end if;
        end process;

        FIR_FILTER : entity work.fir_filter_fixed
        generic map(
            ORDER              => ORDER,
            BIT_WIDTH          => BIT_WIDTH,
            FRACTIONAL_WIDTH   => FRACTIONAL_WIDTH,
            COEFFICIENT_WIDTH  => COEFFICIENT_WIDTH,
            COEFFICIENT_NUMBER => COEFFICIENT_NUMBER
        )
        port map (
            clk => clk,
            reset => reset,
            enable => enable_in,
            x_valid => s_axis_filter_tvalid,
            x      => x,
            y_valid => y_valid,
            y      => y
            -- last   => last_reg
        );
        
        m_axis_filter_tvalid <= '1' when (((y_valid = '1') and (count_valid = to_signed(1, count_valid'length))) or (last_reg = '1')) else '0';
        m_axis_filter_tlast  <= axis_last_shift(PIPE_DELAY - 1);
        m_axis_filter_tdata  <= resize(y, m_axis_filter_tdata'length);
end firaxis;