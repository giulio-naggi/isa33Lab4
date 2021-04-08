library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flipflop is 
	port(CLK: in std_logic;
		IN_DATA: in std_logic;
		OUT_DATA: out std_logic);
end entity;

architecture behavioral of flipflop is
begin
	reg: process (CLK)
    begin  -- process IR_P
      if CLK'event and CLK = '1' then  -- rising clock edge
        OUT_DATA <= IN_DATA;
      end if;
    end process;
end architecture;