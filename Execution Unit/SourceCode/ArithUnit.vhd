Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all; -- This is for or_reduce (or gate for bits of the same vector)


Entity ArithUnit is
	Generic ( N : natural := 64 );
	Port ( A, B : in std_logic_vector( N-1 downto 0 );
	AddY, Y : out std_logic_vector( N-1 downto 0 );
	-- Control signals
	AddnSub, ExtWord : in std_logic := '0';
	-- Status signals
	Cout, Ovfl, Zero, AltB, AltBu : out std_logic );
End Entity ArithUnit;


Architecture arithBehaviour of ArithUnit is
	
	Signal Bsig, AddYsig: std_logic_vector( N-1 downto 0 ):= (others => '0');
	Signal C0, Ovflsig, Coutsig: std_logic := '0';

Begin


	Bsig <= NOT B when AddnSub = '1' else B; -- Invert B if subtraction is desired
	C0 <= '1' when AddnSub = '1' else '0'; -- Set Cin as '1' to act as the added 1 for 2's comp
	
	AddInst: ENTITY WORK.Adder(Ripple) generic map(N => N) port map(A => A, B => Bsig, Cin => C0, Y => AddYSig, Cout => Coutsig, Ovfl => Ovflsig);	
	--Zero <= '1' when unsigned(AddYsig) = 0 else '0';
	Zero <= NOT or_reduce(AddYsig); -- NOR gate for bits of the same vector
	AltB <= Ovflsig XOR AddYsig(N-1);  
	AltBu <= NOT Coutsig;
	
	Ovfl <= Ovflsig;
	AddY <= AddYsig;
	Cout <= Coutsig;
	Y <= AddYsig when ExtWord = '0' else ((N-1 downto N/2 => AddYsig((N/2)-1)) & AddYsig((N/2)-1 downto 0));

End arithBehaviour;