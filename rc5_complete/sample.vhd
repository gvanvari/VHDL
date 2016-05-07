library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rotateTop is
port (
	clock, dir, clear : in std_logic;
	inputSel, halfSel  : in std_logic_vector (1 downto 0);
	validin	: in std_logic;
	validout: out std_logic;
	currentValue : out std_logic_vector(0 to 6);
	digit3en, digit2en, digit1en, digit0en, dot : out std_logic
	);
end rotateTop;

architecture rotateTop of rotateTop is

	-- components
	component source is
	port (
		sel : in std_logic_vector (1 downto 0);
		output : out std_logic_vector(63 downto 0)
		);
	end component source;
	
   component RC5_encrypt is
   port ( 	
		clr: IN STD_LOGIC;  
		clk: IN STD_LOGIC;  
		di_vld: IN STD_LOGIC;  
		din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0); 
		do_rdy: OUT STD_LOGIC
		);
   end component RC5_encrypt;
   
   component RC5_decrypt is
   port (  
		clr: IN STD_LOGIC;  
		clk: IN STD_LOGIC;  
		di_vld: IN STD_LOGIC;  
		din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0); 
		do_rdy: OUT STD_LOGIC
		);
   end component RC5_decrypt;	
	
	component outputProcessor is
	port (
		clock : in std_logic;
		halfSel : in std_logic_vector(1 downto 0);
		input : in std_logic_vector (63 downto 0);
		currentValue : out std_logic_vector(0 to 6);
		digit3en, digit2en, digit1en, digit0en, dot : out std_logic
		);
	end component outputProcessor;
		
	-- internal signals
    signal encryptval, decryptval : std_logic_vector(63 downto 0);
	signal Selectedin, cryptedVal : std_logic_vector (63 downto 0);
	signal validout_en, validout_de: std_logic;
	
	
	
begin

	sourceOfData: 	source port map (sel => inputSel, output => Selectedin);
	
	encryptor:	RC5_encrypt port map (din => Selectedin, clr => clear, clk => clock,
										di_vld => validin , dout => encryptval, do_rdy => validout_en);
   
   decryptor:	RC5_decrypt port map (din => Selectedin, clr => clear, clk => clock,
										di_vld => validin, dout => decryptval, do_rdy => validout_de);                          
                              
	
	displayDriver:	outputProcessor port map (clock => clock, halfSel => halfSel, input => cryptedVal,
										currentValue => currentValue, digit3en => digit3en,
										digit2en => digit2en, digit1en => digit1en,
										digit0en => digit0en, dot => dot);

   with dir select
        cryptedVal <= encryptval when '0',
                    decryptval when others;
   with dir select
        validout <= validout_en when '0',
                    validout_de when others;

end rotateTop;
