Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- do we need this?


Entity ShiftUnit is
	Generic ( N : natural := 64 );
	Port ( A, B, C : in std_logic_vector( N-1 downto 0 );
	Y : out std_logic_vector( N-1 downto 0 );
	ShiftFN : in std_logic_vector( 1 downto 0 );
	ExtWord : in std_logic );
End Entity ShiftUnit;


Architecture barrelShifter of ShiftUnit is
	
	Signal SwapWord: std_logic;
	Signal ShiftCount: unsigned( 5 downto 0 );
	Signal Asig, SLLsig, SRLsig, SRAsig, SLLorCmux, SLLExtmux, SRLorSRAmux, SRLExtmux: std_logic_vector( N-1 downto 0 );

Begin

	-- Swap upper and lower 32 bits of a 64 bit operand when ExtWord and ShiftFN(1) (right shift) are true
	SwapWord <= ExtWord and ShiftFN(1); 
	Asig <= A when SwapWord = '0' else (A((N/2)-1 downto 0) & A(N-1 downto N/2)); -- SwapWord MUX
	
	-- "Mask" we only need 5 LSB for 32-bit shift, or 6 LSB for 64-bit shift
	ShiftCount <= unsigned('0' & B(4 downto 0)) when ExtWord = '1' else unsigned(B(5 downto 0));

	-- instantiates the three types of barrel shifters for different shift operations
	ShiftLL: ENTITY WORK.SLL64(shiftLL) generic map(N => N) port map(X => Asig, Y => SLLsig, ShiftCount => ShiftCount);
	ShiftRL: ENTITY WORK.SRL64(shiftRL) generic map(N => N) port map(X => Asig, Y => SRLsig, ShiftCount => ShiftCount);
	ShiftRA: ENTITY WORK.SRA64(shiftRA) generic map(N => N) port map(X => Asig, Y => SRAsig, ShiftCount => ShiftCount);

	SLLorCmux <= C when ShiftFN(0) = '0' else SLLsig; -- SLL or C mux
	SLLExtmux <= SLLorCmux when ExtWord = '0' else ((N-1 downto N/2 => SLLorCmux((N/2)-1)) & SLLorCmux((N/2)-1 downto 0)); -- Sign extend lower 32 bits
	SRLorSRAmux <= SRLsig when ShiftFN(0) = '0' else SRAsig; -- SRL or SRA mux
	SRLExtmux <= SRLorSRAmux when ExtWord = '0' else ((N-1 downto N/2 => SRLorSRAmux(N-1)) & SRLorSRAmux(N-1 downto N/2)); -- Sign extend upper 32 bits
	
	Y <= SLLExtmux when ShiftFN(1) = '0' else SRLExtmux; 

End barrelShifter;