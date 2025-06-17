class scoreboard extends uvm_scoreboard;
`uvm_component_utils(scoreboard)

uvm_tlm_analysis_fifo #(ofdm_seq_item) sc_fifo;


function new (string name = "scoreboard", uvm_component par);
  super.new(name,par);

  `uvm_info("sbd","new fn in sbd" , UVM_MEDIUM);
endfunction: new

function void build_phase (uvm_phase phase);
  super.build_phase(phase);
  sc_fifo = new("sc_fifo", this);
  `uvm_info("sbd","buildphase in sbd " , UVM_MEDIUM);
  
endfunction: build_phase

task run_phase(uvm_phase phase);
    ofdm_seq_item m;
    ofdm_seq_item out;
    forever begin
      sc_fifo.get(m);
      sc_fifo.get(out);
      if (m.result1 == out.DataOut) begin
        `uvm_info("SUCCESS", $sformatf("Expected: %h, Actual: %h", m.result1, out.DataOut), UVM_MEDIUM);
    end
    else begin
        `uvm_error("MISMATCH", $sformatf("Expected: %h, Actual: %h", m.result1, out.DataOut));
    end

  end

endtask

endclass : scoreboard;
