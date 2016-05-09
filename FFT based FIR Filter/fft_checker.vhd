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

entity fft_checker is 
	port (
		 output_re, output_im : in STD_LOGIC_VECTOR(31 downto 0)
		 );
end fft_checker; 

architecture fft_checker_arch of fft_checker is 

constant period : time := 100 ns;

begin 

checking : process 

	file out_handle_r: TEXT;
    file out_handle_i: TEXT;
    file out_handle_r_1: TEXT;
    file out_handle_i_1: TEXT;
    variable line_ptr_r : Line;
    variable line_ptr_i : Line;
    variable line_ptr_r_1 : Line;
    variable line_ptr_i_1: Line;           
    variable out_check_r : std_logic_vector (31 downto 0);
	variable out_check_i : std_logic_vector (31 downto 0);
    variable good: boolean;
    variable counter: std_logic_vector(4 downto 0);
    
begin 

file_open(out_handle_r,"Output_BPF_re.txt",read_mode);
file_open(out_handle_i,"Output_BPF_im.txt",read_mode);  
file_open(out_handle_r_1,"Output_BPF_out_r.txt",write_mode);
file_open(out_handle_i_1,"Output_BPF_out_i.txt",write_mode); 

loop

wait for (631*period);
    
    If(counter /= "11111") then
    
    counter :=counter + "00001";
    
        if endfile(out_handle_r) then 
            assert false report "End of file encountered, Done" severity note; 
            exit;
        end if;
        
        readline(out_handle_r,line_ptr_r);
        next when line_ptr_r'length = 0; 
        hread(line_ptr_r, out_check_r, good);
        assert good report "Text I/O read error" severity error;
        
        if endfile(out_handle_i) then 
            assert false report "End of file encountered, Done" severity note; 
            exit;
        end if;
        
        readline(out_handle_i,line_ptr_i);
        next when line_ptr_i'length = 0; 
        hread(line_ptr_i, out_check_i, good);
        assert good report "Text I/O read error" severity error;
        
        wait for (1 * period);
        
        assert (out_check_r = output_re) report "Check failed for real!" severity ERROR;
        
        assert (out_check_i = output_im) report "Check failed for imaginary!" severity ERROR;
        
        hwrite (line_ptr_r_1, output_re);
        writeline (out_handle_r_1, line_ptr_r_1);
        hwrite (line_ptr_r_1, out_check_r);               -- write variable to line
        writeline (out_handle_r_1, line_ptr_r_1);
        
        hwrite (line_ptr_r_1, output_im);
        writeline (out_handle_i_1, line_ptr_i_1);
        hwrite (line_ptr_i_1, out_check_i);               -- write variable to line
        writeline (out_handle_i_1, line_ptr_i_1);
        
        wait for (2*period);
      
	end if;  
end loop;    
wait;
 end process; 
end fft_checker_arch;