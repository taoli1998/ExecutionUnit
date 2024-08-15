Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


Entity SLL64 is
	Generic ( N : natural := 64 );
	Port ( X : in std_logic_vector( N-1 downto 0 );
	Y : out std_logic_vector( N-1 downto 0 );
	ShiftCount : in unsigned( integer(ceil(log2(real(N))))-1 downto 0 ) );
End Entity SLL64;


Architecture shiftLL of SLL64 is

	Signal Mux1Out, Mux2Out : std_logic_vector(N-1 downto 0);

Begin
    
	--00:SLL(0) 01:SLL(16) 10:SLL(32) 11:SLL(48)
	with ShiftCount(5 downto 4) select
		Mux1Out <= X when "00",
			(X((N-1)-16 downto 0) & (15 downto 0 => '0')) when "01",
			(X((N-1)-32 downto 0) & (31 downto 0 => '0')) when "10",
			(X((N-1)-48 downto 0) & (47 downto 0 => '0')) when "11",
			(others => '0') when others;
    
   --00:SLL(0) 01:SLL(4) 10:SLL(8) 11:SLL(12)
	with ShiftCount(3 downto 2) select
		Mux2Out <= Mux1Out when "00",
			(Mux1Out((N-1)-4 downto 0) & (3 downto 0 => '0')) when "01",
			(Mux1Out((N-1)-8 downto 0) & (7 downto 0 => '0')) when "10",
			(Mux1Out((N-1)-12 downto 0) & (11 downto 0 => '0')) when "11",
			(others => '0') when others;
		
	--00:SLL(0) 01:SLL(1) 10:SLL(2) 11:SLL(3)
	with ShiftCount(1 downto 0) select
		Y <= Mux2Out when "00",
			(Mux2Out((N-1)-1 downto 0) & ('0')) when "01",
			(Mux2Out((N-1)-2 downto 0) & (1 downto 0 => '0')) when "10",
			(Mux2Out((N-1)-3 downto 0) & (2 downto 0 => '0')) when "11",
			(others => '0') when others;
	
end shiftLL;
