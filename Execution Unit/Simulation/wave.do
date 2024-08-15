onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbexecunit/clock
add wave -noupdate /tbexecunit/nReset
add wave -noupdate /tbexecunit/MeasurementIndex
add wave -noupdate -divider {Results IMPORTANT}
add wave -noupdate -height 45 /tbexecunit/STIMULOUS/compareRes
add wave -noupdate -height 45 /tbexecunit/stableYSig
add wave -noupdate -height 45 /tbexecunit/quietYSig
add wave -noupdate -height 45 /tbexecunit/STIMULOUS/propDelay
add wave -noupdate -divider {ExecUnit Signals}
add wave -noupdate -height 40 -radix hexadecimal /tbexecunit/A
add wave -noupdate -height 40 -radix hexadecimal /tbexecunit/B
add wave -noupdate -height 40 -radix hexadecimal /tbexecunit/Y
add wave -noupdate -height 40 -radix hexadecimal /tbexecunit/tbCompareY
add wave -noupdate -height 30 /tbexecunit/Zero
add wave -noupdate -height 30 /tbexecunit/AltB
add wave -noupdate -height 30 /tbexecunit/AltBu
add wave -noupdate -divider {Instruction Signals}
add wave -noupdate -radix hexadecimal -childformat {{/tbexecunit/FuncClass(1) -radix hexadecimal} {/tbexecunit/FuncClass(0) -radix hexadecimal}} -subitemconfig {/tbexecunit/FuncClass(1) {-height 15 -radix hexadecimal} /tbexecunit/FuncClass(0) {-height 15 -radix hexadecimal}} /tbexecunit/FuncClass
add wave -noupdate -radix hexadecimal /tbexecunit/ShiftFN
add wave -noupdate -radix hexadecimal /tbexecunit/LogicFN
add wave -noupdate /tbexecunit/AddnSub
add wave -noupdate /tbexecunit/ExtWord
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5054400 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 258
configure wave -valuecolwidth 126
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {5028500 ps} {5117200 ps}
