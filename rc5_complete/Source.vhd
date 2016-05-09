library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE	WORK.RC5_PKG.ALL;

-- we are making this ROM since we cannot give a 64 bit input to FPGA through buttons and switches.
-- 2 switches can be toggled to give 4 inputs to FPGA which are stored in ROM

entity source is
port(
    sel : in std_logic_vector (1 downto 0);
	output : out std_logic_vector(63 downto 0)
	);
end source;

architecture source of source is

	-- ROM type, 4 entries 64-bit each
	type ROM is array (0 to 3) of std_logic_vector (63 downto 0);
	
	-- ROM content
	constant testData : ROM := ROM '(
	X"1010054600000000", X"1010054600000001",  
	X"23957A0F7FB30520", X"f3ba73df8ea4686d" 
	);
begin
	
	process (sel)
	begin
		case sel is
			when "00" => output <= testData(0);
			when "01" => output <= testData(1);
			when "10" => output <= testData(2);	
			when "11" => output <= testData(3);
			when others => output <= testData(0);
		end case;			
	end process;

end source;
