library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_UNSIGNED.all;
USE	WORK.RC5_PKG.ALL;

entity rc5_key is
	port(key : in std_logic_vector(127 downto 0);
		 key_vld:   in std_logic;
		 --skey_addr: in std_logic_vector(4 downto 0);
		 clr:	in std_logic;
		 clk: 	in std_logic;
         skey_out: 	out rom_s;
         key_rdy: out std_logic
         );
end rc5_key;

architecture rc5_key_arch of rc5_key is

type statetype is (st_idle, st_key_in, st_key_exp, st_ready);
signal state: statetype;

signal i_cnt: std_logic_vector(4 downto 0);
signal j_cnt: std_logic_vector(1 downto 0);
signal k_cnt: std_logic_vector(6 downto 0);
signal a, b, a_circ, b_circ, temp: std_logic_vector(31 downto 0);
signal a_reg, b_reg: std_logic_vector(31 downto 0);
--signal key: rom_ukey;

signal l: rom_l;
signal s: rom_s;
--constant ukey: std_logic_vector:= x"00000000000000000000000000000000";


begin
--skey_out<=s(conv_integer(skey_addr));

--process(key_sel)
    --begin

-- case key_sel is 
-- when '0' => key <= ukey(0);
-- when '1' => key <= ukey(1);
-- when others => key <= ukey(0);
-- end case;
-- end process;	 
	 
-- state transition process
process(clr, clk)
begin
	if (clr = '1') then
		state <= st_idle;
	elsif (clk'event and clk = '1') then
		case state is
			when st_idle =>
				if(key_vld = '1') then
					state <= st_key_in;
				end if;
			when st_key_in =>
				state <= st_key_exp;
			when st_key_exp =>
				if (k_cnt = "1001101") then
					state <= st_ready;
				end if;
			when st_ready =>
                    if (key_vld = '0') then
				state <= st_idle;
                end if;
		end case;
	end if;
end process;

WITH state SELECT
    key_rdy <=	'1' WHEN st_ready,
				'0' WHEN OTHERS;

-- i counter counting from 0 to 25
PROCESS(clr, clk)
 BEGIN
    IF(clr='1') THEN
		i_cnt<="00000";
    ELSIF(clk'EVENT AND clk='1') THEN
		IF(state=ST_KEY_EXP) THEN
			IF(i_cnt="11001") THEN
				i_cnt<="00000";
			ELSE
				i_cnt<=i_cnt+'1';
			END IF;
		END IF;
    END IF;
 END PROCESS;
 
 -- j counter counting from 0 to 3
 PROCESS(clr, clk)
 BEGIN
    IF(clr='1') THEN
		j_cnt<="00";
    ELSIF(clk'EVENT AND clk='1') THEN
        IF(state = st_key_exp ) THEN
			IF(j_cnt="11") THEN
				j_cnt<="00";
            ELSE
				j_cnt<=j_cnt+'1';
			END IF;
        END IF;
    END IF;
 END PROCESS;
 
 -- k counter counting from 0 to 77
 PROCESS(clr, clk)
 BEGIN
    IF(clr='1') THEN
		k_cnt<="0000000";
    ELSIF(clk'EVENT AND clk='1') THEN
        IF(state = st_key_exp ) THEN
			IF(k_cnt="1001101") THEN
				k_cnt<="0000000";
            ELSE
				k_cnt<=k_cnt+'1';
			END IF;
        END IF;
    END IF;
 END PROCESS;
 
 --array s
process(clr, clk)
begin
	if (clr = '1') or (state = st_idle) then
		s(0) <= X"b7e15163"; s(1) <= X"5618cb1c"; s(2) <= X"f45044d5";
		s(3) <= X"9287be8e"; s(4) <= X"30bf3847"; s(5) <= X"cef6b200";
		s(6) <= X"6d2e2bb9"; s(7) <= X"0b65a572"; s(8) <= X"a99d1f2b";
		s(9) <= X"47d498e4"; s(10)<= X"e60c129d"; s(11) <= X"84438c56";
		s(12) <= X"227b060f"; s(13) <= X"c0b27fc8"; s(14) <= X"5ee9f981";
		s(15) <= X"fd21733a"; s(16) <= X"9b58ecf3"; s(17) <= X"399066ac";
		s(18) <= X"d7c7e065"; s(19) <= X"75ff5a1e"; s(20) <= X"1436d3d7";
		s(21) <= X"b26e4d90"; s(22) <= X"50a5c749"; s(23) <= X"eedd4102";
		s(24) <= X"8d14babb"; s(25) <= X"2b4c3474";
	elsif (clk'event and clk = '1') then
		if (state = st_key_exp) then
			 s(conv_integer(i_cnt)) <= a_circ;
		end if;
	end if;
end process;

--l array
process(clr, clk)
begin
    if(clr = '1') then
		l(0) <= (others=>'0');
	    l(1) <= (others=>'0');
	    l(2) <= (others=>'0');
	    l(3) <= (others=>'0');
	elsif (clk'event and clk = '1') then
		if(state =  st_key_in) then
			l(0) <= key(31 downto 0);
			l(1) <= key(63 downto 32);
			l(2) <= key(95 downto 64);
			l(3) <= key(127 downto 96);
		elsif(state = st_key_exp) then
			l(conv_integer(j_cnt)) <= b_circ;
		end if;
	end if;
end process;

--A = S[i] = (S[i] + A + B) <<< 3;
a <= s(conv_integer(i_cnt)) + a_reg + b_reg;
a_circ <= a(28 downto 0) & a(31 downto 29);

--B = L[j] = (L[j] + A + B) <<< (A + B);
b <= l(conv_integer(j_cnt)) + a_circ + b_reg;
temp <= a_circ + b_reg;

with temp(4 downto 0) select
	b_circ <= b(30 downto 0) & b(31) when "00001",
		      b(29 downto 0) & b(31 downto 30) when "00010",
			  b(28 downto 0) & b(31 downto 29) when "00011",
			  b(27 downto 0) & b(31 downto 28) when "00100",
			  b(26 downto 0) & b(31 downto 27) when "00101",
			  b(25 downto 0) & b(31 downto 26) when "00110",
			  b(24 downto 0) & b(31 downto 25) when "00111",
			  b(23 downto 0) & b(31 downto 24) when "01000",
			  b(22 downto 0) & b(31 downto 23) when "01001",
			  b(21 downto 0) & b(31 downto 22) when "01010",
			  b(20 downto 0) & b(31 downto 21) when "01011",
			  b(19 downto 0) & b(31 downto 20) when "01100",
			  b(18 downto 0) & b(31 downto 19) when "01101",
			  b(17 downto 0) & b(31 downto 18) when "01110",
			  b(16 downto 0) & b(31 downto 17) when "01111",
			  b(15 downto 0) & b(31 downto 16) when "10000",
			  b(14 downto 0) & b(31 downto 15) when "10001",
			  b(13 downto 0) & b(31 downto 14) when "10010",
			  b(12 downto 0) & b(31 downto 13) when "10011",
			  b(11 downto 0) & b(31 downto 12) when "10100",
			  b(10 downto 0) & b(31 downto 11) when "10101",
			  b(9 downto 0) & b(31 downto 10) when "10110",
			  b(8 downto 0) & b(31 downto 9) when "10111",
			  b(7 downto 0) & b(31 downto 8) when "11000",
			  b(6 downto 0) & b(31 downto 7) when "11001",
			  b(5 downto 0) & b(31 downto 6) when "11010",
			  b(4 downto 0) & b(31 downto 5) when "11011",
			  b(3 downto 0) & b(31 downto 4) when "11100",
			  b(2 downto 0) & b(31 downto 3) when "11101",
			  b(1 downto 0) & b(31 downto 2) when "11110",
	          b(0) & b(31 downto 1) when "11111",
		      b when others;

--a_reg
process(clr, clk)
begin
	if(clr = '1') then
		a_reg <= (others => '0');
	elsif (clk'event and clk ='1') then
		if (state = st_key_exp) then
			a_reg <= a_circ;
		end if;
	end if;
end process;

--b_reg
process(clr, clk)
begin
	if(clr = '1') then
		b_reg <= (others => '0');
	elsif (clk'event and clk ='1') then
		if (state = st_key_exp) then
			b_reg <= b_circ;
		end if;
	end if;
end process;


skey_out <= s;

end rc5_key_arch;