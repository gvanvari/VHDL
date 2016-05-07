LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;

PACKAGE rc5_pkg IS
	type rom_s is array (0 to 25) of std_logic_vector(31 downto 0);
	type rom_l is array (0 to 3) of std_logic_vector(31 downto 0);
	type rom_ukey is array (0 to 1) of std_logic_vector(127 downto 0);
END rc5_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

USE	WORK.RC5_PKG.ALL;

entity top_module is
port (key_vld: in std_logic;
	--key_sel: in std_logic; ??
	clk_in, dir, clear : in std_logic;
	--inputSel : in std_logic_vector (1 downto 0); ??
    --halfSel  : in std_logic_vector (1 downto 0);
	validin	: in std_logic;
	validout: out std_logic;
	--currentValue : out std_logic_vector(0 to 6);
	output: out std_logic_vector(63 downto 0);
	--digit3en, digit2en, digit1en, digit0en, dot : out std_logic
	);
end top_module;

architecture top_module of top_module is


	-- components
	component source is
	port (
		sel : in std_logic_vector (1 downto 0);
		output : out std_logic_vector(63 downto 0)
		);
	end component source;
	
    component rc5_key is
	port(key_sel: 	in std_logic;
		 key_vld:   in std_logic;
		 --skey_addr: in std_logic_vector(4 downto 0);
		 clr:	in std_logic;
		 clk: 	in std_logic;
         skey_out: 	out rom_s;
         key_rdy: out std_logic
         );
    end component rc5_key;
    
   component RC5_encrypt is
   port ( 	
		clr: IN STD_LOGIC;  
		clk: IN STD_LOGIC;  
		di_vld: IN STD_LOGIC;  
		din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0); 
		do_rdy: OUT STD_LOGIC;
		skey: in rom_s
		);
   end component RC5_encrypt;
   
   component RC5_decrypt is
   port (  
		clr: IN STD_LOGIC;  
		clk: IN STD_LOGIC;  
		di_vld: IN STD_LOGIC;  
		din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0); 
		do_rdy: OUT STD_LOGIC;
		skey: in rom_s
		);
   end component RC5_decrypt;	
	
	-- component outputProcessor is
	-- port (
		-- clock : in std_logic;
		-- halfSel : in std_logic_vector(1 downto 0);
		-- input : in std_logic_vector (63 downto 0);
		-- currentValue : out std_logic_vector(0 to 6);
		-- digit3en, digit2en, digit1en, digit0en, dot : out std_logic
		-- );
	-- end component outputProcessor;
		
	-- internal signals
    signal encryptval, decryptval : std_logic_vector(63 downto 0);
	 signal cryptedVal: std_logic_vector(63 downto 0);
	 signal Selectedin : std_logic_vector (63 downto 0);
    signal key_ready : std_logic;
	 signal validout_en, validout_de: std_logic;
    signal skey_out_wire: STD_LOGIC_VECTOR(127 downto 0);
	 signal clock :std_logic;
begin


process(clear, clk_in)
begin
	if(clear = '1') then
		clock <= '0';
	elsif (clk_in'event and clk_in ='1') then
		clock<= not clock;
	end if;
end process;

-- named association is used in portmapping
	sourceOfData: 	source port map (sel => inputSel, output => Selectedin);
	
	encryptor:	RC5_encrypt port map (din => Selectedin, clr => clear, clk => clock, di_vld => key_ready, dout => encryptval, do_rdy => validout_en, skey => skey_out_wire);
   
   decryptor:	RC5_decrypt port map (din => Selectedin, clr => clear, clk => clock, di_vld => key_ready, dout => decryptval, do_rdy => validout_de, skey =>skey_out_wire);                          
   -- displayDriver:	outputProcessor port map (clock => clk_in, halfSel => halfSel, input => cryptedVal,
									-- currentValue => currentValue, digit3en => digit3en,
										-- digit2en => digit2en, digit1en => digit1en,
									-- digit0en => digit0en, dot => dot);

   key_generator:  rc5_key port map (key_vld => key_vld, key_sel => key_sel, clr => clear, clk => clock, key_rdy => key_ready, skey_out => skey_out_wire);
    
   with dir select
        cryptedVal <= encryptval when '0',
                    decryptval when others;
   with dir select
        validout <= validout_en when '0',
                    validout_de when others;

   output <= cryptedVal;
end top_module;
