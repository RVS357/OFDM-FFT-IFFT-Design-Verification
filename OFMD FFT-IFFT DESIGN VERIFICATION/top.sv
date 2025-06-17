package ofdm_pkg;

import uvm_pkg::*;
`include "ofdm_seq_item.sv"
`include "ofdm_seq.sv"
`include "ofdm_sequencer.sv"
`include "driver1.sv"
`include "encoder.sv"
`include "ifft1.sv"
`include "monitor1.sv"
`include "agent1.sv"
`include "reference.sv"
`include "scoreboard.sv"
`include "environment1.sv"
`include "test1.sv"
    

endpackage : ofdm_pkg

import uvm_pkg::*;
import ofdm_pkg::*;

`include "ofdm_intf.sv"

module top();

reg Clk, Reset;
ofdm_intf vif(Clk, Reset);

	initial begin
		Clk=0;
		Reset=1;
        #15;
        Reset = 0;
		repeat(100000000) begin
		    #5 Clk=1;
		    #5 Clk=0;
		end
		$display("\n\n\nRan out of clocks\n\n\n");
		$finish;
	end

    ofdmdec d1(
        .Clk(Clk), 
        .Reset(Reset), 
        .Pushin(vif.Pushin), 
        .FirstData(vif.FirstData), 
        .DinR(vif.DinR), 
        .DinI(vif.DinI), 
        .PushOut(vif.PushOut), 
        .DataOut(vif.DataOut)
    );

initial begin
  uvm_config_db#(virtual ofdm_intf)::set(null,"*","vif",vif);
  run_test("test1");
end

endmodule
