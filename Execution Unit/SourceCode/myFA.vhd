library ieee;
use ieee.std_logic_1164.all;

Entity myFA is
	port(aFA, bFA, cin : in std_logic;
			sFA, coFA : out std_logic);
End myFA;
			
Architecture FABehave of myFA Is
Begin
	sFA <= (aFA XOR bFA) XOR cin;
	coFA <= ((aFA XOR bFA) AND cin) OR (aFA AND bFA);
End FABehave;

-- this entity would act as a sub component to the carry-select adder network