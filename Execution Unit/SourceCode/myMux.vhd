library ieee;
use ieee.std_logic_1164.all;
 
Entity myMux is
	Port(A,B : in STD_LOGIC;
	Sel: in STD_LOGIC;
	Z: out STD_LOGIC);
end myMux;
 
Architecture MuxBehave of myMux is
Begin
	process(A,B,Sel)
	Begin
	if Sel = '0' then
	Z <= A;
	else
	Z <= B;
	end if;
	end process;
end MuxBehave;

-- This entity would act as a sub-component for the carry select adder network