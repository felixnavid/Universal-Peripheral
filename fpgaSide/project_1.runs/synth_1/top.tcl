# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a35ticsg324-1L

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.cache/wt [current_project]
set_property parent.project_path C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part digilentinc.com:arty:part0:1.1 [current_project]
set_property ip_output_repo c:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/ip/blk_mem_gen_0/tempExample.coe
read_verilog -library xil_defaultlib {
  C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/new/slowCounter.v
  C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/new/i2Core.v
  C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/new/i2cDeviceLM75.v
  C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/new/top.v
}
read_ip -quiet C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci
set_property used_in_implementation false [get_files -all c:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_ooc.xdc]
set_property is_locked true [get_files C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]

read_ip -quiet C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci
set_property used_in_implementation false [get_files -all c:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_ooc.xdc]
set_property is_locked true [get_files C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]

foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/constrs_1/imports/Arty/Arty_Master.xdc
set_property used_in_implementation false [get_files C:/Users/Felix/Desktop/Projects/Arty/Project/project_1/project_1.srcs/constrs_1/imports/Arty/Arty_Master.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

synth_design -top top -part xc7a35ticsg324-1L


write_checkpoint -force -noxdef top.dcp

catch { report_utilization -file top_utilization_synth.rpt -pb top_utilization_synth.pb }
