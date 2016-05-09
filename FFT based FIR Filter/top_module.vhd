library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VComponents.all;


entity top_module is
PORT (
    clk,clr,begin_process : IN STD_LOGIC;
    --filter : IN std_logic; -- defined as signal for test bench'0'
    --inp_sel : IN std_logic_vector(1 downto 0); inp_sel modified to input for reading files for making testbench file
    inputi: in std_logic_vector(31 downto 0);
    inputr: in std_logic_vector(31 downto 0);
    out_sel : IN std_logic_vector(4 downto 0);
    output_re, output_im : out STD_LOGIC_VECTOR(31 downto 0));    
end top_module;

architecture Behavioral of top_module is
COMPONENT fft_main
  PORT (
    clk,clr : IN STD_LOGIC;
    instantiate : IN STD_LOGIC;
    ready : OUT STD_LOGIC;
    --inp_sel : IN std_logic_vector(1 downto 0); inp_sel modified to input for reading files for making testbench file
    xn_re : in std_logic_vector(31 downto 0);
    xn_im : in std_logic_vector(31 downto 0);
    xk_index: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    xk_re : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    xk_im : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
end COMPONENT;

COMPONENT ifft_main
PORT (
    clk,clr : IN STD_LOGIC;
    instantiate : IN STD_LOGIC;
    xn_re : in STD_LOGIC_VECTOR(31 DOWNTO 0);
    xn_im : in STD_LOGIC_VECTOR(31 DOWNTO 0);
    ready : OUT STD_LOGIC;
    xk_index: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    xk_re : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    xk_im : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
end COMPONENT;

COMPONENT filter_rom
PORT (
    i: IN STD_LOGIC_VECTOR(4 downto 0);
    filter: IN STD_LOGIC;
    o: OUT STD_LOGIC_VECTOR(31 downto 0));
end COMPONENT;

COMPONENT multiplier
Port ( x : in  STD_LOGIC_VECTOR (31 downto 0);
           y : in  STD_LOGIC_VECTOR (31 downto 0);
           z : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

SIGNAL filter: std_logic := '0';
SIGNAL ready1,ready2,instantiate1,instantiate2,clr1,clr2 : STD_LOGIC;
SIGNAL fft_index,ifft_index : STD_LOGIC_VECTOR(4 downto 0);
SIGNAL i_cnt : STD_LOGIC_VECTOR(9 downto 0);
SIGNAL f_cnt : STD_LOGIC_VECTOR(4 downto 0);
SIGNAL ifft_re,ifft_im,out_re,out_im: STD_LOGIC_VECTOR (31 downto 0);
SIGNAL xk_re,xk_im,filter_value : STD_LOGIC_VECTOR(31 DOWNTO 0);
type state_type is (ST_IDLE,ST_START_FFT,ST_MULTIPLY,ST_IFFT,ST_OUTPUT_READY,ST_LIMBO);
signal state: state_type; 

signal final_re0 : std_logic_vector(31 downto 0);
signal final_re1 : std_logic_vector(31 downto 0);
signal final_re2 : std_logic_vector(31 downto 0);
signal final_re3 : std_logic_vector(31 downto 0);
signal final_re4 : std_logic_vector(31 downto 0);
signal final_re5 : std_logic_vector(31 downto 0);
signal final_re6 : std_logic_vector(31 downto 0);
signal final_re7 : std_logic_vector(31 downto 0);
signal final_re8 : std_logic_vector(31 downto 0);
signal final_re9 : std_logic_vector(31 downto 0);
signal final_re10 : std_logic_vector(31 downto 0);
signal final_re11 : std_logic_vector(31 downto 0);
signal final_re12 : std_logic_vector(31 downto 0);
signal final_re13 : std_logic_vector(31 downto 0);
signal final_re14 : std_logic_vector(31 downto 0);
signal final_re15 : std_logic_vector(31 downto 0);
signal final_re16 : std_logic_vector(31 downto 0);
signal final_re17 : std_logic_vector(31 downto 0);
signal final_re18 : std_logic_vector(31 downto 0);
signal final_re19 : std_logic_vector(31 downto 0);
signal final_re20 : std_logic_vector(31 downto 0);
signal final_re21 : std_logic_vector(31 downto 0);
signal final_re22 : std_logic_vector(31 downto 0);
signal final_re23 : std_logic_vector(31 downto 0);
signal final_re24 : std_logic_vector(31 downto 0);
signal final_re25 : std_logic_vector(31 downto 0);
signal final_re26 : std_logic_vector(31 downto 0);
signal final_re27 : std_logic_vector(31 downto 0);
signal final_re28 : std_logic_vector(31 downto 0);
signal final_re29 : std_logic_vector(31 downto 0);
signal final_re30 : std_logic_vector(31 downto 0);
signal final_re31 : std_logic_vector(31 downto 0);

signal final_im0 : std_logic_vector(31 downto 0);
signal final_im1 : std_logic_vector(31 downto 0);
signal final_im2 : std_logic_vector(31 downto 0);
signal final_im3 : std_logic_vector(31 downto 0);
signal final_im4 : std_logic_vector(31 downto 0);
signal final_im5 : std_logic_vector(31 downto 0);
signal final_im6 : std_logic_vector(31 downto 0);
signal final_im7 : std_logic_vector(31 downto 0);
signal final_im8 : std_logic_vector(31 downto 0);
signal final_im9 : std_logic_vector(31 downto 0);
signal final_im10 : std_logic_vector(31 downto 0);
signal final_im11 : std_logic_vector(31 downto 0);
signal final_im12 : std_logic_vector(31 downto 0);
signal final_im13 : std_logic_vector(31 downto 0);
signal final_im14 : std_logic_vector(31 downto 0);
signal final_im15 : std_logic_vector(31 downto 0);
signal final_im16 : std_logic_vector(31 downto 0);
signal final_im17 : std_logic_vector(31 downto 0);
signal final_im18 : std_logic_vector(31 downto 0);
signal final_im19 : std_logic_vector(31 downto 0);
signal final_im20 : std_logic_vector(31 downto 0);
signal final_im21 : std_logic_vector(31 downto 0);
signal final_im22 : std_logic_vector(31 downto 0);
signal final_im23 : std_logic_vector(31 downto 0);
signal final_im24 : std_logic_vector(31 downto 0);
signal final_im25 : std_logic_vector(31 downto 0);
signal final_im26 : std_logic_vector(31 downto 0);
signal final_im27 : std_logic_vector(31 downto 0);
signal final_im28 : std_logic_vector(31 downto 0);
signal final_im29 : std_logic_vector(31 downto 0);
signal final_im30 : std_logic_vector(31 downto 0);
signal final_im31 : std_logic_vector(31 downto 0);

begin
fft_main_instance : fft_main
  PORT MAP (clk => clk, clr => clr1, instantiate => instantiate1, ready => ready1, xk_index => fft_index, xk_re => xk_re, xk_im =>xk_im,xn_re => inputr, xn_im=> inputi);
ifft_main_instance : ifft_main
  PORT MAP (clk => clk, clr => clr2, instantiate => instantiate2, ready => ready2, xn_re => ifft_re, xn_im =>ifft_im, xk_index => ifft_index, xk_re => out_re, xk_im =>out_im);
filter_input : filter_ROM
PORT MAP (i => f_cnt, o => filter_value, filter => filter);
fft_multiply_re : multiplier
  PORT MAP (x =>xk_re , y =>filter_value , z => ifft_re);
fft_multiply_im : multiplier
  PORT MAP (x =>xk_im , y => filter_value , z => ifft_im);

PROCESS(clk) BEGIN
IF (clr = '1') then state <= ST_IDLE;
elsif(clk = '1' and clk'event) then
case state is
when ST_IDLE => if (begin_process = '1') then state <= ST_START_FFT; end if;
when ST_START_FFT =>  if (ready1 = '1') then state <= ST_MULTIPLY; end if;
when ST_MULTIPLY => if (f_cnt >= "11111") then state <= ST_IFFT; end if;
when ST_IFFT=> if (ready2 = '1') then state <= ST_OUTPUT_READY; end if;
when ST_OUTPUT_READY => if (ifft_index >= "11111") then state <= ST_LIMBO; end if;
when ST_LIMBO => state <= ST_LIMBO;
end case;
end if;
END PROCESS;

PROCESS(clk) BEGIN
if (clk = '1' and clk'event) then
if (state = ST_START_FFT) then 
i_cnt <= i_cnt + "0000000001";
else i_cnt <= "0000000000";
end if;
end if;
END PROCESS;

PROCESS(clk) BEGIN
if (clk = '1' and clk'event) then
if (i_cnt = X"137") then clr2 <= '1';
else clr2 <= '0';
end if;
end if;
END PROCESS;

PROCESS(clk) BEGIN
if (clk = '1' and clk'event) then
if (i_cnt = X"139") then instantiate2 <= '1';
else instantiate2 <= '0';
end if;
end if;
END PROCESS;

PROCESS(clk) BEGIN
if (clk = '1' and clk'event) then
if (i_cnt = "0000000001") then clr1 <= '1';
else clr1 <= '0';
end if;
end if;
END PROCESS;

PROCESS(clk) BEGIN
if (clk = '1' and clk'event) then
if (i_cnt = "0000000011") then instantiate1 <= '1';
else instantiate1 <= '0';
end if;
end if;
END PROCESS;

PROCESS(clk) BEGIN
if (clk = '1' and clk'event) then
if (state = ST_MULTIPLY) then f_cnt <= f_cnt + "00001";
else f_cnt <= "00000";
end if;
end if;
END PROCESS;

PROCESS(clk) BEGIN
if (clk = '1' and clk'event) then
if (state = ST_OUTPUT_READY) then
case ifft_index is
when "00000"  => final_re0 <= out_re;
when "00001"  => final_re1 <= out_re;
when "00010"  => final_re2 <= out_re;
when "00011"  => final_re3 <= out_re;
when "00100"  => final_re4 <= out_re;
when "00101"  => final_re5 <= out_re;
when "00110"  => final_re6 <= out_re;
when "00111"  => final_re7 <= out_re;
when "01000"  => final_re8 <= out_re;
when "01001"  => final_re9 <= out_re;
when "01010"  => final_re10 <= out_re;
when "01011"  => final_re11 <= out_re;
when "01100"  => final_re12 <= out_re;
when "01101"  => final_re13 <= out_re;
when "01110"  => final_re14 <= out_re;
when "01111"  => final_re15 <= out_re;
when "10000"  => final_re16 <= out_re;
when "10001"  => final_re17 <= out_re;
when "10010"  => final_re18 <= out_re;
when "10011"  => final_re19 <= out_re;
when "10100"  => final_re20 <= out_re;
when "10101"  => final_re21 <= out_re;
when "10110"  => final_re22 <= out_re;
when "10111"  => final_re23 <= out_re;
when "11000"  => final_re24 <= out_re;
when "11001"  => final_re25 <= out_re;
when "11010"  => final_re26 <= out_re;
when "11011"  => final_re27 <= out_re;
when "11100"  => final_re28 <= out_re;
when "11101"  => final_re29 <= out_re;
when "11110"  => final_re30 <= out_re;
when others  => final_re31 <= out_re;
end case;
end if;
end if;
END PROCESS;

PROCESS(clk) BEGIN
if (clk = '1' and clk'event) then
if (state = ST_OUTPUT_READY) then
case ifft_index is
when "00000"  => final_im0 <= out_im;
when "00001"  => final_im1 <= out_im;
when "00010"  => final_im2 <= out_im;
when "00011"  => final_im3 <= out_im;
when "00100"  => final_im4 <= out_im;
when "00101"  => final_im5 <= out_im;
when "00110"  => final_im6 <= out_im;
when "00111"  => final_im7 <= out_im;
when "01000"  => final_im8 <= out_im;
when "01001"  => final_im9 <= out_im;
when "01010"  => final_im10 <= out_im;
when "01011"  => final_im11 <= out_im;
when "01100"  => final_im12 <= out_im;
when "01101"  => final_im13 <= out_im;
when "01110"  => final_im14 <= out_im;
when "01111"  => final_im15 <= out_im;
when "10000"  => final_im16 <= out_im;
when "10001"  => final_im17 <= out_im;
when "10010"  => final_im18 <= out_im;
when "10011"  => final_im19 <= out_im;
when "10100"  => final_im20 <= out_im;
when "10101"  => final_im21 <= out_im;
when "10110"  => final_im22 <= out_im;
when "10111"  => final_im23 <= out_im;
when "11000"  => final_im24 <= out_im;
when "11001"  => final_im25 <= out_im;
when "11010"  => final_im26 <= out_im;
when "11011"  => final_im27 <= out_im;
when "11100"  => final_im28 <= out_im;
when "11101"  => final_im29 <= out_im;
when "11110"  => final_im30 <= out_im;
when others  => final_im31 <= out_im;
end case;
end if;
end if;
END PROCESS;

with out_sel select
output_re <= final_re0 when "00000", 
final_re1 when "00001", 
final_re2 when "00010", 
final_re3 when "00011", 
final_re4 when "00100", 
final_re5 when "00101", 
final_re6 when "00110", 
final_re7 when "00111", 
final_re8 when "01000", 
final_re9 when "01001", 
final_re10 when "01010", 
final_re11 when "01011", 
final_re12 when "01100", 
final_re13 when "01101", 
final_re14 when "01110", 
final_re15 when "01111", 
final_re16 when "10000", 
final_re17 when "10001", 
final_re18 when "10010", 
final_re19 when "10011", 
final_re20 when "10100", 
final_re21 when "10101", 
final_re22 when "10110", 
final_re23 when "10111", 
final_re24 when "11000", 
final_re25 when "11001", 
final_re26 when "11010", 
final_re27 when "11011", 
final_re28 when "11100", 
final_re29 when "11101", 
final_re30 when "11110", 
final_re31 when others;

with out_sel select
output_im <= final_im0 when "00000", 
final_im1 when "00001", 
final_im2 when "00010", 
final_im3 when "00011", 
final_im4 when "00100", 
final_im5 when "00101", 
final_im6 when "00110", 
final_im7 when "00111", 
final_im8 when "01000", 
final_im9 when "01001", 
final_im10 when "01010", 
final_im11 when "01011", 
final_im12 when "01100", 
final_im13 when "01101", 
final_im14 when "01110", 
final_im15 when "01111", 
final_im16 when "10000", 
final_im17 when "10001", 
final_im18 when "10010", 
final_im19 when "10011", 
final_im20 when "10100", 
final_im21 when "10101", 
final_im22 when "10110", 
final_im23 when "10111", 
final_im24 when "11000", 
final_im25 when "11001", 
final_im26 when "11010", 
final_im27 when "11011", 
final_im28 when "11100", 
final_im29 when "11101", 
final_im30 when "11110", 
final_im31 when others;

end Behavioral;
