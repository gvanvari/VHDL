library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VComponents.all;

entity fft_main is
PORT (
    clk,clr : IN STD_LOGIC;
    instantiate : IN STD_LOGIC;
    ready : OUT STD_LOGIC;
    --inp_sel : IN std_logic_vector(1 downto 0); inp_sel modified to input for reading files for making testbench file
    xn_re : in std_logic_vector(31 downto 0);
    xn_im : in std_logic_vector(31 downto 0);
    xk_index: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    xk_re : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    xk_im : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
end fft_main;

architecture Behavioral of fft_main is
type state_type is (ST_IDLE,ST_START,ST_INPUT,ST_COMPUTE,ST_UNLOAD,ST_WAIT,ST_OUTPUT);
signal state: state_type; 
SIGNAL fwd_inv: std_logic:='1';
SIGNAL rfd,edone,dv,busy,done,start,fwd_inv_we: std_logic;
SIGNAL unload: STD_LOGIC:='0';
SIGNAL xn_index: STD_LOGIC_VECTOR(4 DOWNTO 0);
signal i_cnt: std_logic_vector(4 downto 0):="00000";
signal j_cnt: std_logic_vector(4 downto 0):="11111";
--signal xn_re,xn_im: std_logic_vector(31 downto 0);
COMPONENT fft_lower
  PORT (
    clk : IN STD_LOGIC;
    start : IN STD_LOGIC;
    unload : IN STD_LOGIC;
    xn_re : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    xn_im : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    fwd_inv : IN STD_LOGIC;
    fwd_inv_we : IN STD_LOGIC;
    rfd : OUT STD_LOGIC;
    xn_index : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    busy : OUT STD_LOGIC;
    edone : OUT STD_LOGIC;
    done : OUT STD_LOGIC;
    dv : OUT STD_LOGIC;
    xk_index : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    xk_re : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    xk_im : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
  end COMPONENT;
  
-- input rom not required when we ready input values from file during for testbench  
-- COMPONENT input_ROM
  -- PORT(
    -- i: IN STD_LOGIC_VECTOR(4 downto 0);
    -- inp_sel : IN std_logic_vector(1 downto 0);
    -- o_i: OUT STD_LOGIC_VECTOR(31 downto 0);
    -- o_r: OUT STD_LOGIC_VECTOR(31 downto 0));
   -- end COMPONENT;
begin
fft_instance : fft_lower
  PORT MAP (
    clk => clk,
    start => start,
    unload => unload,
    xn_re => xn_re,
    xn_im => xn_im,
    fwd_inv => fwd_inv,
    fwd_inv_we => fwd_inv_we,
    rfd => rfd,
    xn_index => xn_index,
    busy => busy,
    edone => edone,
    done => done,
    dv => dv,
    xk_index => xk_index,
    xk_re => xk_re,
    xk_im => xk_im);
    
--input_rom_instance : input_ROM
  -- PORT MAP (
    -- i => j_cnt,
    -- o_r => xn_re,
    -- o_i => xn_im,
    -- inp_sel => inp_sel);
    
PROCESS(clk,clr,start,xn_index,edone,i_cnt) BEGIN
IF (clr = '1') then state <= ST_IDLE;
elsif(clk = '1' and clk'event) then
case state is
when ST_IDLE => if (instantiate = '1') then state <= ST_START; end if;
when ST_START=> state <= ST_INPUT;
when ST_INPUT => if (xn_index >= "11111") then state <= ST_COMPUTE; end if;
when ST_COMPUTE=> if (edone = '1') then state <= ST_UNLOAD; end if;
when ST_UNLOAD => state <= ST_WAIT;
when ST_WAIT => if (i_cnt >= "10000") then state <= ST_OUTPUT; end if;
when ST_OUTPUT => state <= ST_OUTPUT;
end case;
end if;
END PROCESS;

process(clk) BEGIN
if (clk = '1' and clk'event) then
if (state = ST_WAIT) then i_cnt <= i_cnt +'1';
else i_cnt <= "00000";
end if;
end if; 
END PROCESS;

process(clk) BEGIN
if (clk = '1' and clk'event) then
if (state = ST_UNLOAD) then unload <= '1';
else unload <= '0';
end if;
end if; 
END PROCESS;

process(clk) BEGIN
if (clk = '1' and clk'event) then
if (state = ST_START) then start <= '1';
else start <= '0';
end if;
end if; 
END PROCESS;

process(clk) BEGIN
if (clk = '1' and clk'event) then
if (state = ST_START) then fwd_inv_we <= '1';
else fwd_inv_we <= '0';
end if;
end if; 
END PROCESS;

process(clk) BEGIN
if (clk = '1' and clk'event) then
if (state = ST_INPUT) then j_cnt <= j_cnt + "00001";
else j_cnt <= "11111";
end if;
end if; 
END PROCESS;

process(clk) BEGIN
if (clk = '1' and clk'event) then
if (i_cnt = "10000") then ready <= '1';
else ready <= '0';
end if;
end if; 
END PROCESS;
end Behavioral;
