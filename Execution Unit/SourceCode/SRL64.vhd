Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


Entity SRL64 is
	Generic ( N : natural := 64 );
	Port ( X : in std_logic_vector( N-1 downto 0 );
	Y : out std_logic_vector( N-1 downto 0 );
	ShiftCount : in unsigned( integer(ceil(log2(real(N))))-1 downto 0 ) );
End Entity SRL64;


Architecture shiftRL of SRL64 is

	Signal Mux1Out, Mux2Out : std_logic_vector(N-1 downto 0);

Begin
    
	--00:SRL(0) 01:SRL(16) 10:SRL(32) 11:SRL(48)
	with ShiftCount(5 downto 4) select
		Mux1Out <= X when "00",
			((N-1 downto (N-1)-15 => '0') & X(N-1 downto 16)) when "01",
			((N-1 downto (N-1)-31 => '0') & X(N-1 downto 32)) when "10",
			((N-1 downto (N-1)-47 => '0') & X(N-1 downto 48)) when "11",
			(others => '0') when others;
    
   --00:SRL(0) 01:SRL(4) 10:SRL(8) 11:SRL(12)
	with ShiftCount(3 downto 2) select
		Mux2Out <= Mux1Out when "00",
			((N-1 downto (N-1)-3 => '0') & Mux1Out(N-1 downto 4)) when "01",
			((N-1 downto (N-1)-7 => '0') & Mux1Out(N-1 downto 8)) when "10",
			((N-1 downto (N-1)-11 => '0') & Mux1Out(N-1 downto 12)) when "11",
			(others => '0') when others;
		
	--00:SRL(0) 01:SRL(1) 10:SRL(2) 11:SRL(3)
	with ShiftCount(1 downto 0) select
		Y <= Mux2Out when "00",
			('0' & Mux2Out(N-1 downto 1)) when "01",
			((N-1 downto (N-1)-1 => '0') & Mux2Out(N-1 downto 2)) when "10",
			((N-1 downto (N-1)-2 => '0') & Mux2Out(N-1 downto 3)) when "11",
			(others => '0') when others;
	
end shiftRL;


