library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use std.TEXTIO.all;


entity TBExecUnit is
	generic (N : natural := 64);
end entity TBExecUnit;


architecture behaveTB of TBExecUnit is
	constant TestVectorFile : string := "ExecUnit01.tvs"; -- filename
	file VectorFile : text; -- define file as type text
	signal MeasurementIndex : Integer := 0; -- measurement index for line (and instruction) number of file
	
	constant PreStimTime : time := 1 ns; -- pre-stimulous time similar to setup
	constant PostStimTime : time := 50 ns; -- post-stimulous time similar to hold

	constant ClockPeriod : time := 2 ns;
	constant nResetPeriod : time := 5 ns;

	signal clock, nReset : std_logic := '0'; -- a clock for the ExUnit to follow, and an active low reset line to initiate stimulous
	-- signals for the TB to connect to the ins and outs of the ExUnit
	signal A, B, Y, tbCompareY : std_logic_vector(N-1 downto 0);
	signal FuncClass, LogicFN, ShiftFN : std_logic_vector(1 downto 0);
	signal AddnSub, ExtWord, Zero, AltB, AltBu : std_logic;
	signal YandStatOut : std_logic_vector((N-1)+3 downto 0); 

	signal stableYSig, quietYSig : boolean := false; -- stable and quiet indicators
	
	constant nResetTime : time := 2 ns; -- a reset line to initiate the start of the stimulous process
	constant clockTime : time := 2 ns; -- a the period of the clock
	
	-- bring in ExecUnit component to testbench
	component ExecUnit is
		Port ( A, B : in std_logic_vector(N-1 downto 0);
			FuncClass, LogicFN, ShiftFN : in std_logic_vector(1 downto 0);
			AddnSub, ExtWord : in std_logic := '0';
			Y : out std_logic_vector(N-1 downto 0);
			Zero, AltB, AltBu  : out std_logic);
	end component ExecUnit;
	
begin
	nReset <= '0', '1' after nResetPeriod; -- give nReset the time to change back to non-reset
	clock <= NOT clock after ClockPeriod/2; -- construct the clock based on clock period timing
	
	stableYSig <= Y'stable(PostStimTime); -- set stable Y signal indicator
	quietYSig <= Y'quiet(PostStimTime); -- set quiet Y signal indicator
	
	YandStatOut <= Y & Zero & AltB & AltBu; -- combine Y and Stat to see when all outputs are quiet

DUT: component ExecUnit generic map( N => N ) -- Instantiate ExecUnit as our DUT and do the port mapping
		port map ( A=>A, B=>B,
			FuncClass=>FuncClass, LogicFN=>LogicFN, ShiftFN=>ShiftFN,
			AddnSub=>AddnSub, ExtWord=>ExtWord, Y=>Y,
			Zero=>Zero, AltB=>AltB, AltBu=>AltBu );


STIMULOUS: process is -- Stimulous Process (main process for the testbench)
	variable startTime, endTime, propDelay : time := 0 ns; -- Timing variables
	variable compareRes : std_logic := 'X'; -- variable used to compare Y with tbCompareY result
			
-- Create variables to store parsed data from file into
	variable LineBuffer : line;
	variable AVar, BVar, YVar : std_logic_vector(N-1 downto 0);
	variable AddnSubVar, ExtWordVar, ZeroVar, AltBVar, AltBuVar : std_logic;
	variable FuncClassVar, LogicFNVar, ShiftFNVar : std_logic_vector(1 downto 0);
			
	begin
		wait until nReset = '1'; -- wait until the active low reset line pulls high to start the process
		--wait for 10 ns; -- give some delay for line to 
		file_open( VectorFile, TestVectorFile, read_mode );
		report "Opening test vector list from: " & TestVectorFile;
		while NOT endfile( VectorFile ) loop -- loop through file until the end
			-- Initialize all tb signals as unknown (X)
			A <= (others => 'X');
			B <= (others => 'X');
			FuncClass <= "XX";
			LogicFN <= "XX";
			ShiftFN <= "XX";
			AddnSub <= 'X';
			ExtWord <= 'X';
			ZeroVar := 'X';
			AltBVar := 'X';
			AltBuVar := 'X';
			compareRes := 'X';
			
			MeasurementIndex <= MeasurementIndex + 1; -- incremement the measurement index so we can keep track of our line number
			
			wait for PreStimTime; -- wait for pre-stimulous, then begin file reading and ExUnit actions

			readline(VectorFile, LineBuffer); -- read current line in the vector file
		
			-- Parse the data from LineBuffer into appropriate variables
			hread(LineBuffer, Avar);
			hread(LineBuffer, Bvar);
			read(LineBuffer, FuncClassvar(1));
			read(LineBuffer, FuncClassvar(0));
			read(LineBuffer, LogicFNvar(1));
			read(LineBuffer, LogicFNvar(0));
			read(LineBuffer, ShiftFNvar(1));
			read(LineBuffer, ShiftFNvar(0));
			read(LineBuffer, AddnSubvar);
			read(LineBuffer, ExtWordvar);
			hread(LineBuffer, Yvar);
			read(LineBuffer, Zerovar);
			read(LineBuffer, AltBvar);
			read(LineBuffer, AltBuvar);

			StartTime := NOW; -- Start the timer for propogation delay measurement
			compareRes := '1'; -- Set comparison flag to true, it is easier to interpret what doesn't match this way

			-- Pass the line-read variables to the TB signals that interact with the ExUnit
			A <= AVar;
			B <= BVar;
			FuncClass <= FuncClassVar;
			LogicFN <= LogicFNVar;
			ShiftFN <= ShiftFNVar;
			AddnSub <= AddnSubVar;
			ExtWord <= ExtWordVar;
			tbCompareY <= YVar;

			wait until YandStatOut'Stable(PostStimTime) = true; -- Wait until all output signals are stable...
			EndTime := NOW; -- ...then capture the end time to complete the propogation delay measurement
			
			-- Propogation delay measurement that includes when the outputs were last active
			PropDelay := EndTime - StartTime - YandStatOut'Last_Active;
			-- Report the propogation delay of the current measurement instruction
			report "   Measurement Index: " & to_string(MeasurementIndex) & "  --  Propagation Delay = " & to_string(PropDelay);
		
			if Y /= tbCompareY then -- if the output Y and known Y do not match, compareRes is false and assert the error
				compareRes := '0';			
				assert Y = tbCompareY report "Y /= Expected Y for Measurement Index: " & to_string(MeasurementIndex) & CR &
					"  Y = " & to_hstring(Y) & CR & "Y = tbCompareY" & to_hstring(tbCompareY) severity error;
			end If;
			
			if Zero /= ZeroVar then -- if the output zero flag and known flag do not match, compareRes is false and assert the error
				compareRes := '0';			
				assert Zero = ZeroVar report "Zero Flag Incorrect for Measurement Index: " & to_string(MeasurementIndex) & CR &
					"  Zero = " & to_string(Zero) & CR & "ZeroVar = " & to_string(ZeroVar) severity error;
			end if;
			if AddnSubVar = '1' and ExtWordVar = '0' then -- check if we are doing a 64-bit subtraction (used for branch conditions)
				if AltB /= AltBVar then -- if the output AltB flag and known flag do not match, compareRes is false and assert the error
					compareRes := '0';			
					assert AltB = AltBVar report "A less than B Flag Incorrect for Measurement Index: " & to_string(MeasurementIndex) & CR &
						"  AltB = " & to_string(AltB) & CR & "AltBVar = " & to_string(AltBVar) severity error;
				end if;
				if AltBu /= AltBuVar then -- if the output AltBu flag and known flag do not match, compareRes is false and assert the error
					compareRes := '0';			
					assert AltBu = AltBuVar report "A less than B Unsigned Flag Incorrect for Measurement Index: " & to_string(MeasurementIndex) & CR &
						"  AltBu = " & to_string(AltBu) & CR & "AltBuVar = " & to_string(AltBuVar) severity error;
				end if;
			end if;
			
			
		wait until clock = '1'; -- wait until next rising edge to begin next instruction
		end loop;
		
		report "TestVector Finished, Closing File and Ending Simulation";
		file_close( VectorFile );
		wait;
	end process STIMULOUS;
		
end architecture behaveTB;
