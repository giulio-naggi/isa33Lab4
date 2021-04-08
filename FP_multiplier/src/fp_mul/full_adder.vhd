library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
	 port(	a,b,c_in: in std_logic;
			s,c_out   : out std_logic);
end full_adder;

architecture gate_level of full_adder is

begin

	s <= a xor b xor c_in;
	c_out <= (a and b) or (c_in and a) or (b and c_in);

end gate_level;
