class ofdm_sequencer extends uvm_sequencer # (ofdm_seq_item);
`uvm_component_utils(ofdm_sequencer)


function new ( string name = "ofdm_sequencer", uvm_component par = null);
super.new( name, par);
`uvm_info("seqr","inside seqr new function", UVM_MEDIUM) 
endfunction : new



endclass :ofdm_sequencer