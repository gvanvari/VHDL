library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_textio.all;

library std; 
use std.textio.all;

entity rc5_checker is 
	port (
		 output1 : in std_logic_vector (63 downto 0)
		 );
end rc5_checker; 

architecture rc5_checker_arch of rc5_checker is 

constant period : time := 100 ns;

begin 

checking : process 

	file out_handle: TEXT;       
    variable line_ptr : Line;    
    variable good: boolean;      
    variable out_check : std_logic_vector (63 downto 0);
		  
begin 

file_open(out_handle,"rc5_10k_test_vectors_pt.txt",read_mode); 

loop 
wait for (99*period);
    if endfile(out_handle) then 
        assert false report "End of file encountered, Done" severity note; 
        exit;
    end if;
    
    readline(out_handle,line_ptr);
    next when line_ptr'length = 0; 
    hread(line_ptr, out_check, good);
    assert good report "Text I/O read error" severity error;
    
    assert (out_check = output1) report "Check failed!" severity ERROR;
    wait for (1*period);
    end loop;
    
wait;
 end process; 
end rc5_checker_arch;
		
		
		
		
		