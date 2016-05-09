library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.all;

entity filter_ROM is
PORT (
    i: IN STD_LOGIC_VECTOR(4 downto 0);
    filter: IN STD_LOGIC;
    o: OUT STD_LOGIC_VECTOR(31 downto 0));
end filter_ROM;

architecture Behavioral of filter_ROM is
TYPE marray is array(0 to 31) of std_logic_vector(31 downto 0);
-- filter1 bf coefficients
CONSTANT filter1 : marray:=(X"ba2b0258",X"bb026197" , X"b9935f4d" , X"ba9e6767", X"bc18fc1a" , X"bc155932" , X"3c539037" , X"3cda33f7", X"3be4dd18", X"3b55c761", X"3d3269e3", X"3cbd08fe", X"bdfa6915", X"be512c0a", X"bcacfaf5", X"3e811ed4", X"3e811ed4", X"bcacfaf5", X"be512c0a", X"bdfa6915", X"3cbd08fe", X"3d3269e3", X"3b55c761", X"3be4dd18", X"3cda33f7", X"3c539037", X"bc155932", X"bc18fc1a", X"ba9e6767", X"b9935f4d", X"bb026197", X"ba2b0258");

CONSTANT filter2 : marray:=(X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000",X"3c800000");

begin
with filter select
o <= filter1(conv_integer(i)) when '1',
filter2(conv_integer(i)) when others;
end Behavioral;
