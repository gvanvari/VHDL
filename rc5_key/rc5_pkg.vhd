LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;

PACKAGE rc5_pkg IS
	type rom_s is array (0 to 25) of std_logic_vector(31 downto 0);
	type rom_l is array (0 to 3) of std_logic_vector(31 downto 0);
	type rom_ukey is array (0 to 3) of std_logic_vector(127 downto 0);
END rc5_pkg;
