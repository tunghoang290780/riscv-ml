top_tb_name = tb

RTL = axi4/rtl/axi4_slave.sv
INF = axi4/rtl/design.sv
TST = axi4/uvm/axi4_test.sv
TB =  axi4/uvm/tb.sv

FILE_PATHS= axi4/uvm/axi4_transaction.sv \
			axi4/uvm/axi4_sequencer.sv \
			axi4/uvm/axi4_sequence.sv \
			axi4/uvm/axi4_subscriber.sv \
			axi4/uvm/axi4_scoreboard.sv \
			axi4/uvm/axi4_monitor.sv \
			axi4/uvm/axi4_driver.sv \
			axi4/uvm/axi4_agent.sv \
			axi4/uvm/axi4_env.sv

work = work

run_compile:
	xvlog -work $(work) -i . -sv $(INF) $(RTL) $(FILE_PATHS) $(TST) $(TB) -L uvm
	xelab work.$(top_tb_name) -s $(top_tb_name)_sim -L uvm -timescale 1ns/1ps -debug all

run_sim:
	xsim -runall -log session.log $(top_tb_name)_sim -testplusarg "UVM_TESTNAME=axi4_test"

run_sim_wave:
	xsim -wdb sim.wdb -log session.log -t run_all.tcl $(top_tb_name)_sim -testplusarg "UVM_TESTNAME=axi4_test"
	xsim sim.wdb -gui

clean:
	rm -rf modelsim.* transcript* vlog.* work 
	rm -rf vsim.wlf *.log *hbs *Xil xsim.dir .Xil
	rm -rf *.jou *.pb
	rm -rf *.wdb
	rm -rf *.vcd
	rm -rf *.covdb
	clear

run_all:
	make clean
	make run_compile
	make run_sim

run_gui:
	make clean
	make run_compile
	make run_sim
	make run_sim_wave