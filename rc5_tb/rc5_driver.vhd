library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_textio.all;

library std; 
use std.textio.all;

entity rc5_driver is 
port (
     key_vld, di_vld: out std_logic;
	 key: out std_logic_vector(127 downto 0);
	 clk_in, dir, clear : out std_logic;
	 --validin	: out std_logic;
     input: out std_logic_vector(63 downto 0)
	);
end rc5_driver;

architecture rc5_driver_arch of rc5_driver is 

constant period : time := 100 ns; 
--signal di_vld: std_logic;
signal clk_in1: std_logic;
signal clr: std_logic;

begin 

process
begin 
clk_in1 <= '0';
loop
    wait for (period/2);
    clk_in1 <= not clk_in1;
    end loop;
    wait;
end process;
clk_in <= clk_in1;
    
process 
begin 
	clr <= '1';
	wait for (2*period);
	clr <= '0';
	wait;
end process;
clear <= clr;
process

    file inputs : TEXT; -- is in "inputs.txt";		  -- Define the file 'handle'
    file keys : TEXT;   --is in "keys.txt";
    variable Linputs, Lkeys: Line;         -- Define the line buffer
    variable good: boolean;   --status of the read operation

    variable keys_2: std_logic_vector(127 downto 0);
    variable din_2 : std_logic_vector (63 downto 0);
    
       
begin
   	 
	file_open(keys,"rc5_10k_test_vectors_keys.txt",read_mode);
	file_open(inputs,"rc5_10k_test_vectors_ct.txt",read_mode);
	  
	 loop 
		if endfile(keys) then 
			assert false report "End of file encountered, Done" severity note; 
			exit;
		end if;
		
		readline(keys,Lkeys);
		next when Lkeys'length = 0; 
        hread(Lkeys, keys_2, good);
        assert good report "Text I/O read error" severity error;
		
		if endfile(inputs) then 
			assert false report "End of file encountered, Done" severity note; 
			exit;
		end if;
		
		readline(inputs,Linputs);
		next when Linputs'length = 0; 
        hread(Linputs, din_2, good);
        assert good report "Text I/O read error" severity error;
		
		 input <= din_2;
		 key <= keys_2;
		
		wait for (100*period);
		end loop;
		wait;
		end process;
									
process 
begin 
	key_vld <= '1';
	wait;
	end process;

process 
begin  
	loop
         di_vld <= '0';
         wait for (85*period);
         di_vld <= '1';
         wait for (15*period);
         di_vld <= '0';
	 end loop;
	 wait;
	end process;
    
-- validin <= di_vld;

process 
begin 
	dir <= '1';
	wait ;
	end process;	

end rc5_driver_arch;						