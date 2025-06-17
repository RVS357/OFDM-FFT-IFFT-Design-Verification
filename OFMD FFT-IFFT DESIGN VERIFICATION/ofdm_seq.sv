class ofdm_seq extends uvm_sequence#(ofdm_seq_item);

  `uvm_object_utils(ofdm_seq)
  ofdm_seq_item m1;
   
  function new(string name = "ofdm_seq");
    super.new(name);
    `uvm_info("seq","inside seq new function", UVM_MEDIUM);
  endfunction
  
  
  virtual task body();
    m1 = ofdm_seq_item::type_id::create("m1");
    repeat(50000) begin
      start_item(m1);
      m1.randomize();  
      $display("-----------data_in %0h----------" ,m1.Data_in);
      finish_item(m1);
  end
  #20000;

  `uvm_info("seq"," seq BODY function ran successfully", UVM_MEDIUM);
  
  endtask

endclass :  ofdm_seq
