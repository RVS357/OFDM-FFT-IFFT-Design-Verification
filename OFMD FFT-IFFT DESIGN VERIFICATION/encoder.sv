class encoder extends uvm_component;
    `uvm_component_utils(encoder)

    uvm_blocking_put_port #(ofdm_seq_item) e_put_port;
    uvm_blocking_put_imp #(ofdm_seq_item, encoder) d_put_imp; // Interface to accept data

    
     real amp[0:3] = '{0.0, 0.333, 0.666, 1.0}; // it does correct mapping only in this Endian format [3:0]
     

    function new(string name = "encoder", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        d_put_imp = new("d_put_imp", this);  // Setup blocking put interface
        e_put_port = new("e_put_port",this);
    endfunction

    virtual task put(ref ofdm_seq_item m);
        $display(" ---hi I am inside encoder--------");
        $display("Data Input: %0h", m.Data_in);
        encode(m);
        e_put_port.put(m);
         $display("----put imp at ifft ran successfully----");
    endtask


    virtual function void encode(ofdm_seq_item m);
        bit [47:0] data = m.Data_in;
        integer i;
        integer fbin = 4;
      
         typedef   struct  {
      real r;
      real i;
         } temp_complex_1;
           
           temp_complex_1 temp_complex[128];   

        for (i = 0; i < 128; i++) begin
            temp_complex[i].r = 0;
            temp_complex[i].i = 0;
        end

        while (fbin < 52) begin
            int idx = data[1:0]; 
            real xx = amp[idx];  
            data = data >> 2;  
            temp_complex[fbin].r = xx;
            temp_complex[128 - fbin].r = xx;  
            fbin += 2;
        end

        // Set fixed frequencies to 1.0
        temp_complex[55].r = 1.0;
        temp_complex[128 - 55].r = 1.0;
    
       
       for(int a =0; a<128;a++) begin
       m.output_complex[a].r = temp_complex[a].r;
       m.output_complex[a].i = temp_complex[a].i;
       end
    endfunction

endclass :encoder
