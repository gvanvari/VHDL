library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rc5_tb is
end rc5_tb;

architecture rc5_tb_arch of rc5_tb is

component top_module is
port ( clk_in, dir, clear : in std_logic;
      key_vld, di_vld: in std_logic;
	  key: in std_logic_vector(127 downto 0); --
	  --validin	: in std_logic;
      input : in std_logic_vector(63 downto 0); --
	  validout: out std_logic;
	  output: out std_logic_vector(63 downto 0)
	);
end component top_module;

component rc5_driver is 
port (key_vld, di_vld: out std_logic;
      key: out std_logic_vector(127 downto 0); --
      clk_in, dir, clear : out std_logic;
	  --validin	: out std_logic;
      input : out std_logic_vector(63 downto 0) --
	);
end component rc5_driver;

component rc5_checker is 
port (
	  output1: IN	STD_LOGIC_VECTOR(63 DOWNTO 0)
      );
end component rc5_checker;

Signal key_vld_wire, di_vld: std_logic;
Signal key_wire: std_logic_vector(127 downto 0);
signal clk_in_wire, dir_wire, clear_wire : std_logic;
signal validin_wire: std_logic;
signal validout_wire: std_logic;
signal output_wire: std_logic_vector(63 downto 0);
signal input_wire: std_logic_vector(63 downto 0);

begin
	
	UUT: top_module port map (key_vld => key_vld_wire, key =>key_wire, clk_in => clk_in_wire, dir => dir_wire, clear => clear_wire, validout => validout_wire, output => output_wire,input => input_wire, di_vld => di_vld);

	checker: rc5_checker port map (output1 => output_wire);

	driver: rc5_driver port map (key_vld => key_vld_wire, key =>key_wire, clk_in=>clk_in_wire, dir => dir_wire, clear=> clear_wire, input => input_wire, di_vld => di_vld);

end rc5_tb_arch;

