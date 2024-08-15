library ieee; 
Use ieee.std_logic_1164.all;
--Use std.textio.all;
--Use ieee.numeric_std.all;


Entity LogicUnit is
	Generic ( N : natural := 64 );
	Port ( A, B : in std_logic_vector( N-1 downto 0 );
	Y : out std_logic_vector( N-1 downto 0 );
	LogicFN : in std_logic_vector( 1 downto 0 ) );
End Entity LogicUnit;


Architecture logicBehaviour of LogicUnit is
	
Begin
	
	-- LogicUnit MUX
	with LogicFN select
		Y <= B when "00",
			A XOR B when "01",
			A OR B when "10",
			A AND B when "11",
			(others => '0') when others;
	
End logicBehaviour;