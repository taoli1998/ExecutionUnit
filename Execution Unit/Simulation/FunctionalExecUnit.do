quit -sim
transcript file FuncExecUnitTranscript.txt
transcript on

vcom -work work -2008 -explicit -stats=none ../SourceCode/LogicUnit.vhd
vcom -work work -2008 -explicit -stats=none ../SourceCode/Adder.vhd
vcom -work work -2008 -explicit -stats=none ../SourceCode/ArithUnit.vhd
vcom -work work -2008 -explicit -stats=none ../SourceCode/SLL64.vhd
vcom -work work -2008 -explicit -stats=none ../SourceCode/SRL64.vhd
vcom -work work -2008 -explicit -stats=none ../SourceCode/SRA64.vhd
vcom -work work -2008 -explicit -stats=none ../SourceCode/ShiftUnit.vhd
vcom -work work -2008 -explicit -stats=none ../SourceCode/ExecUnit.vhd
vcom -work work -2008 -explicit -stats=none TBExecUnit.vhd
vcom -work work -2008 -explicit -stats=time,-cmd,msg ConfigExecUnit.vhd

vsim -gui work.FuncExecUnitSim -t 100ps

transcript off
do wave.do
transcript on

restart -f
run 12000 ns
transcript off
transcript file ""