library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
-- this module takes a hex number as input and outputs a sequence of 1s and 0s which will enable leds on the seven segment display.
-- each of the 16 Hex values from 0 to F has a corresponding 7 bit sequence of 1s and 0s.
-- the seven bits are a,b,c,d,e,f,g. this makes one seven segment display.

entity digitConverter is
port (
	digitIn : in std_logic_vector(0 to 3);
	digitOut : out std_logic_vector(0 to 6)
	);
end digitConverter;

architecture digitConverter of digitConverter is

-- ROM type, 16 entries 7-bit each
	type ROM is array (0 to 15) of std_logic_vector (0 to 6);
	
	constant conversionTable : ROM := ROM '(
	"0000001",	-- 0
	"1001111",	-- 1
	"0010010",	-- 2
	"0000110",	-- 3
	"1001100",	-- 4
	"0100100",	-- 5
	"0100000",	-- 6
	"0001111",	-- 7
	"0000000",	-- 8
	"0000100",	-- 9
	"0001000",	-- A
	"1100000",	-- B
	"0110001",	-- C
	"1000010",	-- D
	"0110000",	-- E
	"0111000"	-- F
	);

begin	
	process (digitIn)
-- the hex number is converted to integer. This integer serves as the index value in ROM.			
	begin
		digitOut <= conversionTable(conv_integer(digitIn));
	end process;

end digitConverter;
