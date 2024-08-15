Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


Entity Adder is
	Generic ( N : natural := 64 );
	Port ( A, B : in std_logic_vector( N-1 downto 0 );
	Y : out std_logic_vector( N-1 downto 0 );
	-- Control signals
	Cin : in std_logic;
	-- Status signals
	Cout, Ovfl : out std_logic );
End Entity Adder;

Architecture Ripple of Adder is -- UNUSED in ArithUnit architecture beceause of prop delay too high, kept here for record

Signal gen, prop: std_logic_vector(N-1 downto 0 ) := (others => '0'); 
Signal carry: std_logic_vector( N downto 0) := (others => '0'); 

Begin
	gen <= A AND B;
	prop <= A XOR B;
	carry(0) <= Cin; 
	
	CarryNetwork: for i in 0 to N-1 generate -- using generate to create a ripple carry adder chain
		carry(i+1) <= gen(i) OR (prop(i) AND carry(i));  
	end generate CarryNetwork;
	
	Y <= carry(N-1 downto 0) XOR prop;
	Cout <= carry(N);
	Ovfl <= carry(N) XOR carry(N-1);

End Ripple;

Architecture CarrySelect of Adder is -- Optimized adder with way less prop delay, USED in ArithUnit architecture

-- declaring the Full Adder and 2-input MUX as components for easy port mapping
Component myFA is 
port(aFA, bFA, cin : in std_logic;
			sFA, coFA : out std_logic);
End component;

Component myMux is
	Port(A,B : in STD_LOGIC;
	Sel: in STD_LOGIC;
	Z: out STD_LOGIC);
end component;

signal AMux,BMux,C0,C1: std_logic_vector(N-1 downto 0);
signal CarryS : std_logic_vector(N/4 downto 0);
signal CarryNMinus1 : std_logic;

Begin

CarryS(0) <= Cin;

CarrySelectNetwork: for j in 0 to (N/4)-1 generate
--generate 4-bit carry select adders 16 times in the case of N=64
FA1: myFA PORT MAP(A(0+4*j),B(0+4*j),'0' ,AMux(0+4*j),C0(0+4*j));
FA2: myFA PORT MAP(A(1+4*j),B(1+4*j),C0(0+4*j),AMux(1+4*j),C0(1+4*j));
FA3: myFA PORT MAP(A(2+4*j),B(2+4*j),C0(1+4*j),AMux(2+4*j),C0(2+4*j));
FA4: myFA PORT MAP(A(3+4*j),B(3+4*j),C0(2+4*j),AMux(3+4*j),C0(3+4*j));
 
FA5: myFA PORT MAP(A(0+4*j),B(0+4*j),'1' ,BMux(0+4*j),C1(0+4*j));
FA6: myFA PORT MAP(A(1+4*j),B(1+4*j),C1(0+4*j),BMux(1+4*j),C1(1+4*j));
FA7: myFA PORT MAP(A(2+4*j),B(2+4*j),C1(1+4*j),BMux(2+4*j),C1(2+4*j));
FA8: myFA PORT MAP(A(3+4*j),B(3+4*j),C1(2+4*j),BMux(3+4*j),C1(3+4*j));
 
MUX1: myMux PORT MAP(AMux(0+4*j),BMux(0+4*j),CarryS(j),Y(0+4*j));
MUX2: myMux PORT MAP(AMux(1+4*j),BMux(1+4*j),CarryS(j),Y(1+4*j));
MUX3: myMux PORT MAP(AMux(2+4*j),BMux(2+4*j),CarryS(j),Y(2+4*j));
MUX4: myMux PORT MAP(AMux(3+4*j),BMux(3+4*j),CarryS(j),Y(3+4*j));
 
MUX5: myMux PORT MAP(C0(3+4*j),C1(3+4*j),CarryS(j),CarryS(j+1));
End generate CarrySelectNetwork;

OvMux: myMux Port Map(c0(N-2),c1(N-2),CarryS((N/4)-1), CarryNMinus1);
--overflow Mux to fetch the second last carry bit for calculating Ovfl
Cout <= CarryS(N/4);
Ovfl <= CarryS(N/4) XOR CarryNMinus1;


end CarrySelect;