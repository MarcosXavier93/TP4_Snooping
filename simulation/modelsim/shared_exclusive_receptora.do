onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Snooping/bit_escolha
add wave -noupdate /Snooping/estado
add wave -noupdate /Snooping/receptor_bus
add wave -noupdate /Snooping/estado_prox_receptor
add wave -noupdate /Snooping/estado_wb_receptor
add wave -noupdate /Snooping/aborta_acesso_mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {993 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {1149 ps}
view wave 
wave clipboard store
wave create -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps sim:/Snooping/bit_escolha 
wave create -driver freeze -pattern clock -initialvalue HiZ -period 100ps -dutycycle 50 -starttime 0ps -endtime 1000ps sim:/Snooping/op 
wave create -driver freeze -pattern counter -startvalue 0 -endvalue 1 -type Range -direction Up -period 500ps -step 1 -repeat forever -starttime 0ps -endtime 1000ps sim:/Snooping/estado_op 
wave create -driver freeze -pattern constant -value 00 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern constant -value 01 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern constant -value 10 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern constant -value 01 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern constant -value 00 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern constant -value 1 -starttime 0ps -endtime 1000ps sim:/Snooping/bit_escolha 
wave create -driver freeze -pattern constant -value 01 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern constant -value 00 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern counter -startvalue 00 -endvalue 11 -type Range -direction Up -period 300ps -step 1 -repeat forever -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/receptor_bus 
wave create -driver freeze -pattern counter -startvalue 00 -endvalue 11 -type Range -direction Up -period 250ps -step 1 -repeat forever -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/receptor_bus 
wave create -driver freeze -pattern counter -startvalue 00 -endvalue 11 -type Range -direction Up -period 50ps -step 1 -repeat forever -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/receptor_bus 
wave create -driver freeze -pattern constant -value 00 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern constant -value 01 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern constant -value 10 -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern counter -startvalue 01 -endvalue 10 -type Range -direction Up -period 50ps -step 1 -repeat forever -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern counter -startvalue 01 -endvalue 10 -type Range -direction Up -period 500ps -step 1 -repeat forever -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
wave create -driver freeze -pattern counter -startvalue 00 -endvalue 11 -type Range -direction Up -period 100ps -step 1 -repeat forever -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/receptor_bus 
WaveExpandAll -1
wave create -driver freeze -pattern counter -startvalue 01 -endvalue 10 -type Range -direction Up -period 50ps -step 1 -repeat forever -range 1 0 -starttime 0ps -endtime 1000ps sim:/Snooping/estado 
WaveExpandAll -1
WaveCollapseAll -1
wave clipboard restore
