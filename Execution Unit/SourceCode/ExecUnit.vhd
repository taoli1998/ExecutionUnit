Library ieee;
use ieee.std_logic_1164.all;


Entity ExecUnit is
	Generic ( N : natural := 64 );
	Port ( A, B : in std_logic_vector( N-1 downto 0 );
	FuncClass, LogicFN, ShiftFN : in std_logic_vector( 1 downto 0 );
	AddnSub, ExtWord : in std_logic := '0';
	Y : out std_logic_vector( N-1 downto 0 );
	Zero, AltB, AltBu : out std_logic );
End Entity ExecUnit;


Architecture execBehaviour of ExecUnit is

Signal AddResult, ShiftArithResult, LogicResult, AltBOut, AltBuOut : std_logic_vector( N-1 downto 0 ); -- 64-bit signals
Signal AltBResult, AltBuResult : std_logic; -- 1-bit signals

Begin
	-- instantiate the three internal units and port mapping accordingly
	ArithUnit: ENTITY WORK.ArithUnit(arithBehaviour) generic map(N => N) 
		port map(A => A, B => B, AddY => AddResult, Y => open,
				AddnSub => AddnSub, ExtWord => ExtWord,
				Cout => open, Ovfl => open, Zero => Zero, 
				AltB => AltBResult, AltBu => AltBuResult);
				
	ShiftUnit: ENTITY WORK.ShiftUnit(barrelShifter) generic map(N => N)
		port map(A => A, B => B, C => AddResult, Y => ShiftArithResult, ShiftFN => ShiftFN, ExtWord => ExtWord);

	LogicUnit: ENTITY WORK.LogicUnit(logicBehaviour) generic map(N => N)     
		port map(A => A, B => B, Y => LogicResult, LogicFN => LogicFN);

	-- inserts 63 bits of '0' in front of the 1-bit AltBResult and AltBuResult
	AltBOut <= (N-1 downto 1 => '0') & AltBResult;
	AltBuOut <= (N-1 downto 1 => '0') & AltBuResult;
	
	AltB <= AltBResult;
	AltBu <= AltBuResult;

	-- output MUX
	with FuncClass select
		Y <= ShiftArithResult when "00",
			LogicResult when "01",
			AltBOut when "10",
			AltBuOut when "11",
			(others => '0') when others;                              

End execBehaviour;