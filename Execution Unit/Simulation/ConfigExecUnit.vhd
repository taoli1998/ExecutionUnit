-- Functional Simulation
Configuration FuncExecUnitSim of TBExecUnit is
	for behaveTB
		for DUT : ExecUnit use entity 
				work.ExecUnit(execBehaviour);
		end for;
	end for;
End Configuration FuncExecUnitSim;

-- Timing Simulation
Configuration TimeExecUnitSim of TBExecUnit is
	for behaveTB
		for DUT : ExecUnit use entity 
				work.ExecUnit(structure);
		end for;
	end for;
End Configuration TimeExecUnitSim;