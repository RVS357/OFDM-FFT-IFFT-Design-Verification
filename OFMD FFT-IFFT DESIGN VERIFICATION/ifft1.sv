class ifft1 extends uvm_component;

`uvm_component_utils(ifft1)

uvm_blocking_put_imp #(ofdm_seq_item, ifft1) e_put_imp; 
uvm_analysis_port #(ofdm_seq_item) f_analysis_port;

// LUTs for twiddle factors
real twr[64];
real twi[64];

 function new(string name = "ifft1", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    
  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     e_put_imp = new("e_put_imp", this);  // Setup blocking put interface
     f_analysis_port = new("f_analysis_port", this); 
     initialize_twiddle_factors();
endfunction

   function void initialize_twiddle_factors();
    
   twr = '{1, 0.9987954562051724, 0.9951847266721969, 0.989176509964781, 
          0.9807852804032304, 0.970031253194544, 0.9569403357322088, 0.9415440651830208, 
          0.9238795325112867, 0.9039892931234433, 0.881921264348355, 0.8577286100002721, 
          0.8314696123025452, 0.8032075314806449, 0.773010453362737, 0.7409511253549591, 
          0.7071067811865476, 0.6715589548470183, 0.6343932841636455, 0.5956993044924335, 
          0.5555702330196023, 0.5141027441932217, 0.4713967368259978, 0.4275550934302822, 
          0.38268343236508984, 0.33688985339222005, 0.29028467725446233, 0.24298017990326398, 
          0.19509032201612833, 0.14673047445536175, 0.09801714032956077, 0.049067674327418126, 
          6.123233995736766e-17, -0.04906767432741801, -0.09801714032956065, 
          -0.14673047445536164, -0.1950903220161282, -0.24298017990326387, 
          -0.29028467725446216, -0.33688985339221994, -0.3826834323650897, 
          -0.42755509343028186, -0.4713967368259977, -0.5141027441932217, 
          -0.555570233019602, -0.5956993044924334, -0.6343932841636454, 
          -0.6715589548470184, -0.7071067811865475, -0.7409511253549589, 
          -0.773010453362737, -0.8032075314806448, -0.8314696123025453, 
          -0.857728610000272, -0.8819212643483549, -0.9039892931234433, 
          -0.9238795325112867, -0.9415440651830207, -0.9569403357322088, 
          -0.970031253194544, -0.9807852804032304, -0.989176509964781, 
          -0.9951847266721968, -0.9987954562051724};
    
    twi = '{0, 0.049067674327418015, 0.0980171403295606, 0.14673047445536175, 
          0.19509032201612825, 0.24298017990326387, 0.29028467725446233, 0.33688985339222005, 
          0.3826834323650898, 0.4275550934302821, 0.47139673682599764, 0.5141027441932217, 
          0.5555702330196022, 0.5956993044924334, 0.6343932841636455, 0.6715589548470183, 
          0.7071067811865475, 0.7409511253549591, 0.773010453362737, 0.8032075314806448, 
          0.8314696123025452, 0.8577286100002721, 0.8819212643483549, 0.9039892931234433, 
          0.9238795325112867, 0.9415440651830208, 0.9569403357322089, 0.970031253194544, 
          0.9807852804032304, 0.989176509964781, 0.9951847266721968, 0.9987954562051724, 
          1, 0.9987954562051724, 0.9951847266721969, 0.989176509964781, 
          0.9807852804032304, 0.970031253194544, 0.9569403357322089, 0.9415440651830208, 
          0.9238795325112867, 0.9039892931234434, 0.881921264348355, 0.8577286100002721, 
          0.8314696123025455, 0.8032075314806449, 0.7730104533627371, 0.740951125354959, 
          0.7071067811865476, 0.6715589548470186, 0.6343932841636455, 0.5956993044924335, 
          0.5555702330196022, 0.5141027441932218, 0.47139673682599786, 0.42755509343028203, 
          0.3826834323650899, 0.33688985339222033, 0.2902846772544624, 0.24298017990326407, 
          0.1950903220161286, 0.1467304744553618, 0.09801714032956083, 0.049067674327417966};
   endfunction
   
    virtual task put(ref ofdm_seq_item m2);
        $display(" -------- YOU ARE IN IFFT TESTBENCH ------- ");
        ifft_operation(m2);
        convert_to_fixed_point(m2);
        #200;
        f_analysis_port.write(m2);
    endtask
    
   function integer reversing_bit(integer in);     
    integer rev_i = 0;   
    for (int j = 0; j < 7; j++) begin      
    rev_i = (rev_i << 1) | (in & 1);      
    in = in >> 1;      
    end     
    return rev_i; 
   endfunction

 function void ifft_operation(ofdm_seq_item m2);

        typedef struct {
            real r, i;
        } comp;

        comp temp;
        comp wk [128];	// working array

		int ix, bs, i1, i2, tw;
		real tr, ti, vr, vi, ar, ai, br, bi;
		int sp = 2;
        real limit = 1e-15; // to remove imag

       for (int i = 0; i < 128; i++) begin
            int j = reversing_bit(i);
            wk[j].r = m2.output_complex[i].r;
            wk[j].i = m2.output_complex[i].i;
        end

        for (int k = 0; k < 7; k++) begin
            int bs = 0;
			while (bs < 128) begin
                for (ix = bs; ix < bs + sp/2; ix++) begin
                    
                    // performing same operations as in python code.
                    
                    tw = (ix % sp) * (128 / sp);
                    i1 = ix;
                    i2 = ix + sp/2;
                    tr = twr[tw];
                    ti = twi[tw];

                    vr = wk[i2].r * tr - wk[i2].i * ti;
                    vi = wk[i2].r * ti + wk[i2].i * tr;

					ar = wk[i1].r + vr;
					ai = wk[i1].i + vi;
					br = wk[i1].r - vr;
					bi = wk[i1].i - vi;

					wk[i1].r = ar;
					wk[i1].i = (ai < limit && ai > -limit) ? 0 : ai;
					wk[i2].r = br;
					wk[i2].i = (bi < limit && bi > -limit) ? 0 : bi;
                end
                bs += sp;
            end
            sp *= 2;
        end

        for (int i = 0; i < 128; i++) begin
            m2.output_timeD[i].r = wk[i].r / 128;
            m2.output_timeD[i].i = wk[i].i / 128;
			
        end

        for (int j = 0; j < 128; j++) begin           
            m2.output_timeD[j].i = ($abs(m2.output_timeD[j].i) < limit) ? 0 : m2.output_timeD[j].i;
        end

 endfunction : ifft_operation

function convert_to_fixed_point(ofdm_seq_item m2);

    int q;
    int fraction = 15;  

    real temp_fixRA[128];
    int temp_fixRB[128];

    real temp_fixIA[128];
    int temp_fixIB[128];

    for (q = 0; q < 128; q++) begin
        // real to fixed
        temp_fixRA[q] = m2.output_timeD[q].r * (2 ** fraction);
        temp_fixIA[q] = m2.output_timeD[q].i * (2 ** fraction);

        // to int
        temp_fixRB[q] = $rtoi(temp_fixRA[q]);
        temp_fixIB[q] = $rtoi(temp_fixIA[q]);

        // output assignment
        m2.output_fixR[q] = temp_fixRB[q];
        m2.output_fixI[q] = temp_fixIB[q];
    end


endfunction : convert_to_fixed_point


endclass
