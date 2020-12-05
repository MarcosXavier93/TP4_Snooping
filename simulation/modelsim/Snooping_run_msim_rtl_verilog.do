transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Marcos/Documents/TP4_Beatriz_MarcosJunio {C:/Users/Marcos/Documents/TP4_Beatriz_MarcosJunio/memoria.v}
vlog -vlog01compat -work work +incdir+C:/Users/Marcos/Documents/TP4_Beatriz_MarcosJunio {C:/Users/Marcos/Documents/TP4_Beatriz_MarcosJunio/Snooping.v}

