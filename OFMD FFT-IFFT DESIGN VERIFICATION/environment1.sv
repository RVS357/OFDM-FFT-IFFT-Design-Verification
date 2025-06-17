class environment1 extends uvm_env;
`uvm_component_utils(environment1)

agent1 agent;
scoreboard sbd;
monitor1 mon_out;
//ofdm_monitor_in mon_in;
reference refm;

function new ( string name = "environment1", uvm_component parent = null);
super.new( name,parent);
`uvm_info("env","inside new function",UVM_MEDIUM)
endfunction :  new

function void build_phase (uvm_phase phase);
  super.build_phase(phase);
    `uvm_info("env","buildphase in environment " , UVM_MEDIUM);
    agent = agent1::type_id::create("agent",this);
     mon_out = monitor1::type_id::create("mon_out", this);
     sbd = scoreboard::type_id::create ("sbd", this);
     refm = reference::type_id::create("refm",this);
  uvm_top.print_topology();
endfunction: build_phase


function void connect_phase (uvm_phase phase);
    `uvm_info("env_msg","connectphase in environment" , UVM_MEDIUM);
    agent.drv.refm_port.connect(refm.refm_imp);
    refm.refm_put.connect(sbd.sc_fifo.analysis_export);
    mon_out.mon_port.connect(sbd.sc_fifo.analysis_export);
    
    
    
endfunction: connect_phase


endclass :environment1
