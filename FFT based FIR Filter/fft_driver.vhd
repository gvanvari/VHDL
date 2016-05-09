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

entity fft_driver is 
port (
    clk,clr,begin_process : out STD_LOGIC;
    inputi: out std_logic_vector(31 downto 0);
    inputr: out std_logic_vector(31 downto 0);
    out_sel : out std_logic_vector(4 downto 0)
    );
end fft_driver;

architecture fft_driver_arch of fft_driver is 

constant period : time := 100 ns; 

signal clk_in: std_logic;
signal clear: std_logic;
signal begin_process_in: std_logic;
signal out_sel1: std_logic_vector(4 downto 0);

begin 

process
begin 
clk_in <= '1';
loop
    wait for (period/2);
    clk_in <= not clk_in;
    end loop;
    wait;
end process;
clk <= clk_in;
    
process 
begin 
    wait for (1*period);
	clear <= '1';
	wait for (1*period);
	clear <= '0';
    wait for (728*period);
	wait;
end process;
clr <= clear;

process 
begin 
    wait for (3*period);
	begin_process_in <= '1';
	wait for (1*period);
	begin_process_in <= '0';
    wait for (726*period);
	wait;
end process;
begin_process <= begin_process_in;

process

    file in_handle_r: TEXT;
    file in_handle_i: TEXT;
    variable line_ptr_r : Line;
    variable line_ptr_i : Line;           
    variable in_check_r : std_logic_vector (31 downto 0);
	variable in_check_i : std_logic_vector (31 downto 0);
    variable good: boolean;
       
begin
   	 
	file_open(in_handle_r,"Signal_BPF_re.txt",read_mode);
	file_open(in_handle_i,"Signal_BPF_im.txt",read_mode);
	  
	 loop 
		if endfile(in_handle_r) then 
			assert false report "End of file encountered, Done" severity note; 
			exit;
		end if;
		
		readline(in_handle_r,line_ptr_r);
		next when line_ptr_r'length = 0; 
        hread(line_ptr_r, in_check_r, good);
        assert good report "Text I/O read error" severity error;
		
		if endfile(in_handle_i) then 
			assert false report "End of file encountered, Done" severity note; 
			exit;
		end if;
		
		readline(in_handle_i,line_ptr_i);
		next when line_ptr_i'length = 0; 
        hread(line_ptr_i,in_check_i , good);
        assert good report "Text I/O read error" severity error;
		
		 inputr <= in_check_r;
		 inputi <= in_check_i;
		
		--wait for (100*period);
	end loop;
	wait;
end process;


process
begin 
out_sel1 <= "00000";
wait for (632*period);
loop
    wait for ( 2 * period);
    out_sel1 <= out_sel1 + "00001";
    wait for (1 * period);
end loop;
    wait;
end process;
out_sel <= out_sel1;

end fft_driver_arch;						