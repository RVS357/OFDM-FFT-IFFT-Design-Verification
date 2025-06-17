class agent1 extends uvm_agent;

  `uvm_component_utils(agent1)
   
   driver1 drv;
   ofdm_sequencer seqr;
   encoder enc;
   ifft1 ifft;
  
   
  function new(string name = "agent1", uvm_component parent);
  super.new(name, parent);
     `uvm_info("agent","Inside new fn of agent",UVM_MEDIUM)
  endfunction
    
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = driver1::type_id::create("drv",this);
    seqr = ofdm_sequencer::type_id::create("seqr",this);
    enc = encoder::type_id::create("enc",this);
    ifft = ifft1::type_id::create("ifft",this);
   
    `uvm_info("agent","Inside build phase of agent",UVM_MEDIUM)
  endfunction
  
  
    function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     `uvm_info("agent","Inside connect phase of agent",UVM_MEDIUM)
     drv.seq_item_port.connect(seqr.seq_item_export);  // seqr to driver connection
     drv.d_put_port.connect(enc.d_put_imp);    // drv to encoder connection 
     enc.e_put_port.connect(ifft.e_put_imp);   //encoder to ifft connection
     ifft.f_analysis_port.connect(drv.f_fifo.analysis_export);   //ifft to driver connection
     
  endfunction: connect_phase
  
  
 endclass : agent1
  
