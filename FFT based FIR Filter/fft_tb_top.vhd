library UNISIM;
use UNISIM.VComponents.all;
library std; 


library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_textio.all;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_unsigned.all;
library std; 
use std.textio.all;

entity fft_tb_top is
end fft_tb_top;

architecture fft_tb_top_arch of fft_tb_top is

component top_module is
PORT (
    clk,clr,begin_process : IN STD_LOGIC;
    inputi: in std_logic_vector(31 downto 0);
    inputr: in std_logic_vector(31 downto 0);
    out_sel : IN std_logic_vector(4 downto 0);
    output_re, output_im : out STD_LOGIC_VECTOR(31 downto 0));   
end component top_module;

component fft_driver is 
port (
    clk,clr,begin_process : out STD_LOGIC;
    inputi: out std_logic_vector(31 downto 0);
    inputr: out std_logic_vector(31 downto 0);
    out_sel : out std_logic_vector(4 downto 0)
    );
end component fft_driver;

component fft_checker is 
port (
	output_re, output_im : in STD_LOGIC_VECTOR(31 downto 0)
	);
end component fft_checker;

signal clk,clr,begin_process : STD_LOGIC;
signal inputi: std_logic_vector(31 downto 0);
signal inputr: std_logic_vector(31 downto 0);
signal out_sel : std_logic_vector(4 downto 0);
signal output_re, output_im : STD_LOGIC_VECTOR(31 downto 0); 
 
begin
	
	UUT: top_module port map ( clk => clk,clr => clr,begin_process => begin_process,inputi => inputi, inputr => inputr, out_sel => out_sel, output_re => output_re, output_im => output_im);

	checker: fft_checker port map (output_re => output_re, output_im => output_im );

	driver: fft_driver port map (clk => clk,clr => clr,begin_process => begin_process, inputi => inputi, inputr => inputr, out_sel => out_sel);

end fft_tb_top_arch;

