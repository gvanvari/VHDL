library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- only 4 hex digits (16 bits) can be displayed on seven segment display on FPGA.
-- But our output is of 64 bits so we will have to toggle 2 switches to display 1 complete 64 bit output.
-- we will get 64 bit output from encryption or decryption module. 
entity outputProcessor is
port (
	clock : in std_logic;
	halfSel : in std_logic_vector(1 downto 0);
	input : in std_logic_vector (63 downto 0);
	currentValue : out std_logic_vector(0 to 6);
	digit3en, digit2en, digit1en, digit0en, dot : out std_logic
	);
end outputProcessor;

architecture outputProcessor of outputProcessor is

	component digitConverter is
	port (
		digitIn : in std_logic_vector(0 to 3);
		digitOut : out std_logic_vector(0 to 6)
		);
	end component digitConverter;
	
-- internal signals
	signal selectedDigit : std_logic_vector (0 to 3);
	signal currentHalf : std_logic_vector (15 downto 0);
	
begin

	converter: digitConverter port map (digitIn => selectedDigit, digitOut => currentValue);
	
-- no decimal point is required in this case
	dot <= '1';
	
-- select requested 16-bit from 64-bit input
-- input is broken down to 4 pieces
	process (halfsel, input)
	begin
			case halfSel is
				when "00" => currentHalf <= input (15 downto 0);
				when "01" => currentHalf <= input (31 downto 16);
				when "10" => currentHalf <= input (47 downto 32);
				when "11" => currentHalf <= input (63 downto 48);
				when others => currentHalf <= input(15 downto 0);
			end case;
	end process;
	
	
-- switch to next digit depending on constant rate
	process (clock)
		constant switchRate : integer := 100000;
		variable counter : integer := switchRate;
		variable nextDigit : integer := 0;
		
	begin		
		-- check for switch (this is done so that we can see the output which is not flickering)
		if (clock'event and clock = '1') then
			if (counter /= switchRate) then
				counter := counter + 1;
			
			else
				-- reset counter and switch digit
				counter := 0;
				-- the 64 bit input which was broken in to 4 pieces each of 16 bit is again broken
                -- down to 4 pieces of 4 bits each. We need 4 bits to represent hex number.
                -- these 4 bit will be index for the digitconverter ROM which which will give
                -- corresponding output of a, b, c , d, e, f.
                -- selected digit is an internal signal which will be fed into digitconverter ROM
				if (nextDigit = 0) then
					-- light up digit 0 (from left to right the 4th 7 segment display is enabled)
					digit3en <= '1'; -- disable digit 3 (MS digit)
					digit2en <= '1'; -- disable digit 2
					digit1en <= '1'; -- disable digit 1
					digit0en <= '0'; -- enable digit 0 (LS digit)
					
					selectedDigit <= currentHalf (3 downto 0);
				--end if;
							
				elsif (nextDigit = 1) then
					-- light up digit 1 (from left to right the 3rd 7 segment display is enabled)
					digit3en <= '1'; -- disable digit 3 (MS digit)
					digit2en <= '1'; -- disable digit 2
					digit1en <= '0'; -- enable digit 1
					digit0en <= '1'; -- disable digit 0 (LS digit)
					
					selectedDigit <= currentHalf (7 downto 4);
				--end if;
					
				elsif (nextDigit = 2) then
					-- light up digit 2 (from left to right the 2nd 7 segment display is enabled)
					digit3en <= '1'; -- disable digit 3 (MS digit)
					digit2en <= '0'; -- enable digit 2
					digit1en <= '1'; -- disable digit 1
					digit0en <= '1'; -- disable digit 0 (LS digit)
					
					selectedDigit <= currentHalf (11 downto 8);
				--end if;
					
				else
					-- light up digit 3 (from left to right the 1st 7 segment display is enabled)
					digit3en <= '0'; -- enable digit 3 (MS digit)
					digit2en <= '1'; -- disable digit 2
					digit1en <= '1'; -- disable digit 1
					digit0en <= '1'; -- disable digit 0 (LS digit)
					
					selectedDigit <= currentHalf (15 downto 12);
				end if;
				
				
				if (nextDigit = 3) then
					nextDigit := 0;
				else
					nextDigit := nextDigit + 1;
				end if;
				
			end if;
		end if;
		
	end process;

end outputProcessor;