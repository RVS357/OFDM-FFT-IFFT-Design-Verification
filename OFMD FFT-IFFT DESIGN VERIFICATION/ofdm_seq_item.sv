class ofdm_seq_item extends uvm_sequence_item;

`uvm_object_utils(ofdm_seq_item)

// Inputs
 logic Clk;
 logic Reset;
 bit Pushin;
 bit FirstData;
 reg signed [16:0] DinR;
 reg signed [16:0] DinI;
 rand bit [47:0] Data_in;
 
 // Outputs
 bit PushOut;
 reg [47:0] DataOut;
 real result [128];
 logic [47:0] result1;
 reg signed [16:0]  output_fixR[128];
 reg signed [16:0]  output_fixI[128];
 


typedef   struct  {
    real r, i;
    } complex_num;
                                            
    complex_num output_complex[128], output_timeD[128];   
    
function new (string name = "ofdm_seq_item");    
    super.new(name);
endfunction: new

endclass : ofdm_seq_item