class reference extends uvm_component;
`uvm_component_utils(reference)

uvm_blocking_put_imp #(ofdm_seq_item, reference) refm_imp; 
uvm_analysis_port #(ofdm_seq_item) refm_put;
ofdm_seq_item m;
//temp
real complex_re[128];
longint shift_amount;

// LUTs for twiddle factors
real twr[64];
real twi[64];

// Additional variables for decoding
real decision_points[3];
real full_scale;

function new(string name = "reference", uvm_component parent = null);
    super.new(name, parent);
endfunction
    
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    refm_imp = new("refm_imp", this); 
	refm_put = new("refm_put", this);
    m = new();
    initialize_twiddle_factors();
endfunction

   function void initialize_twiddle_factors();
	
	twr = '{1.0, 0.9987954562051724, 0.9951847266721969, 0.989176509964781, 0.9807852804032304, 
       0.970031253194544, 0.9569403357322088, 0.9415440651830208, 0.9238795325112867, 
	   0.9039892931234433, 0.881921264348355, 0.8577286100002721, 0.8314696123025452, 
	   0.8032075314806449, 0.773010453362737, 0.7409511253549591, 0.7071067811865476, 
	   0.6715589548470183, 0.6343932841636455, 0.5956993044924335, 0.5555702330196023, 
	   0.5141027441932217, 0.4713967368259978, 0.4275550934302822, 0.38268343236508984, 
	   0.33688985339222005, 0.29028467725446233, 0.24298017990326398, 0.19509032201612833, 
	   0.14673047445536175, 0.09801714032956077, 0.049067674327418126, 6.123233995736766e-17, 
	   -0.04906767432741801, -0.09801714032956065, -0.14673047445536164, -0.1950903220161282, 
	   -0.24298017990326387, -0.29028467725446216, -0.33688985339221994, -0.3826834323650897, 
	   -0.42755509343028186, -0.4713967368259977, -0.5141027441932217, -0.555570233019602, 
	   -0.5956993044924334, -0.6343932841636454, -0.6715589548470184, -0.7071067811865475, 
	   -0.7409511253549589, -0.773010453362737, -0.8032075314806448, -0.8314696123025453, 
	   -0.857728610000272, -0.8819212643483549, -0.9039892931234433, -0.9238795325112867, 
	   -0.9415440651830207, -0.9569403357322088, -0.970031253194544, -0.9807852804032304, 
	   -0.989176509964781, -0.9951847266721968, -0.9987954562051724};
	   
    twi = '{0, -0.049067674327418015, -0.0980171403295606, -0.14673047445536175, 
	      -0.19509032201612825, -0.24298017990326387, -0.29028467725446233, 
		  -0.33688985339222005, -0.3826834323650898, -0.4275550934302821, 
		  -0.47139673682599764, -0.5141027441932217, -0.5555702330196022, -0.5956993044924334, 
		  -0.6343932841636455, -0.6715589548470183, -0.7071067811865475, -0.7409511253549591, 
		  -0.773010453362737, -0.8032075314806448, -0.8314696123025452, -0.8577286100002721, 
		  -0.8819212643483549, -0.9039892931234433, -0.9238795325112867, -0.9415440651830208,
		  -0.9569403357322089, -0.970031253194544, -0.9807852804032304, -0.989176509964781, 
		  -0.9951847266721968, -0.9987954562051724, -1.0, -0.9987954562051724, -0.9951847266721969, 
		  -0.989176509964781, -0.9807852804032304, -0.970031253194544, -0.9569403357322089, 
		  -0.9415440651830208, -0.9238795325112867, -0.9039892931234434, -0.881921264348355,
		  -0.8577286100002721, -0.8314696123025455, -0.8032075314806449, -0.7730104533627371,
		  -0.740951125354959, -0.7071067811865476, -0.6715589548470186, -0.6343932841636455, 
		  -0.5956993044924335, -0.5555702330196022, -0.5141027441932218, -0.47139673682599786,
		  -0.42755509343028203, -0.3826834323650899, -0.33688985339222033, -0.2902846772544624,
		  -0.24298017990326407, -0.1950903220161286, -0.1467304744553618, -0.09801714032956083, 
		  -0.049067674327417966};
  endfunction


	
	virtual task put(ref ofdm_seq_item m);
		
        fft_operation(m); 
		decoding(m);
		refm_put.write(m);
	endtask


    virtual function real squareof2(real sq1);
        return sq1 * sq1;
    endfunction

    virtual function real maximum(real a, real b);
        return (a > b) ? a : b;
    endfunction

virtual function integer reversing_bit(integer index, integer num_bits);
    integer reversed_index = 0;
    for (integer i = 0; i < num_bits; i++) begin
        reversed_index = (reversed_index << 1) | (index & 1);
        index = index >> 1;
    end
    return reversed_index;
endfunction



   virtual function void fft_operation(ofdm_seq_item m);
        typedef struct {
            real r, i;
        } complex_type;
		

        complex_type wk[128];  

        int i, ix, bs, i1, i2, tw;
        real tr, ti, vr, vi, ar, ai, br, bi;
        int sp = 2;
        real limit = 1e-12;
 
        for (i = 0; i < 128; i++) begin
            int j = reversing_bit(i, 7); 
            wk[j].r = m.output_timeD[i].r;
            wk[j].i = m.output_timeD[i].i;
        end

        // FFT computation
        for (int k = 0; k < 7; k++) begin
			bs = 0;
			while (bs < 128) begin
				for (ix = bs; ix < bs + sp / 2; ix++) begin
					tw = (ix % (sp / 2)) * (128 / sp);
					i1 = ix;
					i2 = ix + sp / 2;
					tr = twr[tw];
					ti = twi[tw]; 
		
					// Complex multiplication v = wk[i2] * t
					vr = wk[i2].r * tr - wk[i2].i * ti;
					vi = wk[i2].r * ti + wk[i2].i * tr;
		
					// Complex addition and subtraction
					ar = wk[i1].r + vr;
					ai = wk[i1].i + vi;
					br = wk[i1].r - vr;
					bi = wk[i1].i - vi;
		
					wk[i1].r = ar;
					wk[i1].i = ai;
					wk[i2].r = br;
					wk[i2].i = bi;
				end
				bs += sp;
			end
			sp *= 2;
			
		end

        for (int i = 0; i < 128; i++) begin
			m.output_complex[i].r = ($abs(wk[i].r) < limit) ? 0 : wk[i].r;
			m.output_complex[i].i = 0;
			m.result[i] = ($abs(wk[i].r) < limit) ? 0 : wk[i].r;
		end
		
	endfunction  


	virtual function void decoding(ofdm_seq_item m);
		real tpoints[0:3] = '{0.0, 0.333, 0.666, 1.0};
		real full_scale;
		integer bv;
		longint res;
		real fsq;
		longint shift_amount;
		real dec[0:2];
	
		full_scale = maximum(squareof2(m.result[55]), squareof2(m.result[57]));
	
		dec[0] = squareof2(0.166666 * full_scale);
		dec[1] = squareof2((0.166666 + 0.333333) * full_scale);
		dec[2] = squareof2((0.166666 + 0.666666) * full_scale);
	
		for (longint x = 4; x < 52; x = x + 2) begin
			fsq = squareof2(m.result[x]);
			bv = 3;
			for (int dx = 0; dx < 3; dx = dx + 1) begin
				if (fsq < dec[dx]) begin
					bv = dx;
					break;
				end
			end
			shift_amount = x - 4;
			if (shift_amount < $bits(res)) begin
				res |= bv << shift_amount;
			end else begin
				`uvm_error("ERROR",$sformatf(" Shift amount exceeds limit at bin %0d", x));
			end
		end
		m.result1=res;
		$display("Decoded result: %h", m.result1);

	endfunction

endclass : reference
