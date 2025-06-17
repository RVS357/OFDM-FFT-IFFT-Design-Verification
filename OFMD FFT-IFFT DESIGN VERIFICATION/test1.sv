class test1 extends uvm_test;
`uvm_component_utils(test1)
environment1 env;
ofdm_seq seq;

function new ( string name ="test1", uvm_component parent =  null);
super.new(name,parent);
`uvm_info("test","Inside test new function", UVM_MEDIUM)
endfunction: new


function void build_phase( uvm_phase phase);
super.build_phase(phase);
env =  environment1::type_id::create("env",this);
seq = ofdm_seq::type_id::create("seq");
`uvm_info("test","Inside test build phase",UVM_MEDIUM)
endfunction : build_phase



task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
seq.start(env.agent.seqr);
phase.drop_objection(this);
`uvm_info("test","Inside test run phase",UVM_MEDIUM)
endtask : run_phase

endclass : test1