class monitor1 extends uvm_monitor;

`uvm_component_utils(monitor1)

virtual ofdm_intf vif;
ofdm_seq_item out;
uvm_analysis_port #(ofdm_seq_item) mon_port ;


function new (string name = "ofdm_monitor" , uvm_component parent = null);
    super.new(name,parent);
    out = new("out");
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_port = new("mon_port", this);
    if(!uvm_config_db#(virtual ofdm_intf)::get(this, "", "vif", vif))
    `uvm_error("monitor","virtual int failed")

    `uvm_info("monitor", "inside build phase ", UVM_MEDIUM)
endfunction :  build_phase


virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("MONITOR_OUT","RUN PHASE", UVM_NONE);
    out = ofdm_seq_item::type_id::create("ofdm_seq_item", this);
    
forever begin
  @(posedge vif.Clk);  
    if(vif.PushOut == 1)
      begin
        out.PushOut = vif.PushOut;
        out.DataOut = vif.DataOut;
        $display("PushOut %0d    DataOut %0h", out.PushOut ,out.DataOut);
        mon_port.write(out); // calling write function in scoreboard
      end
end
endtask: run_phase

endclass:  monitor1
