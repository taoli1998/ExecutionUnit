Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- do we need this?
use ieee.math_real.all; -- do we need this?


Entity SRA64 is
	Generic ( N : natural := 64 );
	Port ( X : in std_logic_vector( N-1 downto 0 );
	Y : out std_logic_vector( N-1 downto 0 );
	ShiftCount : in unsigned( integer(ceil(log2(real(N))))-1 downto 0 ) );
End Entity SRA64;


Architecture shiftRA of SRA64 is

	Signal Mux1Out, Mux2Out : std_logic_vector(N-1 downto 0);

Begin
    
	--00:SRA(0) 01:SRA(16) 10:SRA(32) 11:SRA(48)
	with ShiftCount(5 downto 4) select
		Mux1Out <= X when "00",
			((N-1 downto (N-1)-15 => X(N-1)) & X(N-1 downto 16)) when "01",
			((N-1 downto (N-1)-31 => X(N-1)) & X(N-1 downto 32)) when "10",
			((N-1 downto (N-1)-47 => X(N-1)) & X(N-1 downto 48)) when "11",
			(others => '0') when others;
    
   --00:SRA(0) 01:SRA(4) 10:SRA(8) 11:SRA(12)
	with ShiftCount(3 downto 2) select
		Mux2Out <= Mux1Out when "00",
			((N-1 downto (N-1)-3 => Mux1Out(N-1)) & Mux1Out(N-1 downto 4)) when "01",
			((N-1 downto (N-1)-7 => Mux1Out(N-1)) & Mux1Out(N-1 downto 8)) when "10",
			((N-1 downto (N-1)-11 => Mux1Out(N-1)) & Mux1Out(N-1 downto 12)) when "11",
			(others => '0') when others;
		
	--00:SRA(0) 01:SRA(1) 10:SRA(2) 11:SRA(3)
	with ShiftCount(1 downto 0) select
		Y <= Mux2Out when "00",
			(Mux2Out(N-1) & Mux2Out(N-1 downto 1)) when "01",
			((N-1 downto (N-1)-1 => Mux2Out(N-1)) & Mux2Out(N-1 downto 2)) when "10",
			((N-1 downto (N-1)-2 => Mux2Out(N-1)) & Mux2Out(N-1 downto 3)) when "11",
			(others => '0') when others;
	
End shiftRA;
