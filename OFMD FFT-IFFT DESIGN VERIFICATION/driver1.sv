class driver1 extends uvm_driver #(ofdm_seq_item);  

`uvm_component_utils(driver1)

ofdm_seq_item m2;
uvm_blocking_put_port #(ofdm_seq_item) d_put_port;
uvm_blocking_put_port #(ofdm_seq_item) refm_port;
uvm_tlm_analysis_fifo #(ofdm_seq_item) f_fifo;
virtual ofdm_intf vif;

 
function new (string name = "driver1", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("driver", "inside driver new function", UVM_MEDIUM)
endfunction : new

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ofdm_intf)::get(this, "", "vif", vif))
        `uvm_error("driver", "virtual interface failed to get from config DB")
    d_put_port = new("d_put_port", this);
    f_fifo = new("f_fifo", this);
    refm_port = new("refm_port", this);
    m2 = new("m2");
endfunction: build_phase

task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
    seq_item_port.get_next_item(m2);

    `uvm_info("driver", "calling encoder class", UVM_MEDIUM)

    d_put_port.put(m2);

    refm_port.put(m2);

    f_fifo.get(m2);

    m2.FirstData = 1; 
    m2.Pushin= 1;

    for(int i = 0; i < 128; i++) begin
    #5;
        m2.DinR = m2.output_fixR[i];
    if (i < 128)  begin
        vif.Pushin = m2.Pushin;
        vif.DinR <= m2.DinR;
        vif.DinI <= 0;    
        vif.FirstData = m2.FirstData;
    end  
        @ (posedge vif.Clk);
        #1;
    end

        m2.FirstData = 0;
        m2.Pushin = 0;
        vif.Pushin = m2.Pushin;
        vif.FirstData = m2.FirstData;
      

   // calcdinr(m2);
    #5000;
    seq_item_port.item_done();
   
    `uvm_info("driver", "completed processing OFDM message", UVM_MEDIUM)
    end
endtask

endclass: driver1
