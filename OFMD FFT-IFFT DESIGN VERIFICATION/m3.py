#!/usr/bin/python3

import numpy as np
import matplotlib.pyplot as plt
from scipy import fft
import random

random.seed(123456)

# WARNING -------
# Python works in complex numbers. System Verilog does not!!!
# You can't cut and paste this code and hope it will work on a project!
#
nfract=15
nbits=nfract+8
sf=1<<(nfract)


def conj(x):
    return x.real-x.imag

def ifftwiddle(n):
    """Used to generate test cases"""
    return [np.exp(2.0j*np.pi*k/n) for k in range(n//2)]

def fftwiddle(n):
    """A table of these is provided for implementing the FFT"""
    return [np.exp(-2.0j*np.pi*k/n) for k in range(n//2)]

def asq(n):
    """Used to slice the data (abs without the square root)"""
    return n.real*n.real+n.imag*n.imag

def br(d):
    """Make a bit reversed copy of the input vector.
Used by both the FFT and IFFT (DIT type code)"""
    rv=[0+0j for x in d]
    for ix in range(len(d)):
        wx=ix
        rx=0
        for qq in range(7):
            rx= rx*2
            if wx&1 !=0:
                rx=rx | 1
            wx=wx>>1
#        print(ix,rx)
        rv[ix]=d[rx]
    return rv

tw=fftwiddle(128)
twi=ifftwiddle(128)

def condata(q):
    qr=int(q.real*sf)
    if qr < 0:
        qrs= f"-{nbits}'d{-qr}"
    else:
        qrs= f"{nbits}'d{qr}"
    qi=int(q.imag*sf)
    if qi < 0:
        qis= f"-{nbits}'d{-qi}"
    else:
        qis= f"{nbits}'d{qi}"
    return f"{{{qrs}, {qis}}}"

def dumpt(wa,fn,nm):
    with open(fn,"w") as fo:
        fo.write(f"// output is real, imag\n");
        fo.write(f"// real is rv[{2*nbits-1}:{nbits}]\n")
        fo.write(f"// imag is rv[{nbits-1}:0]\n")
        fo.write(f"function reg [{nbits*2-1}:0] {nm}(reg [5:0] ix);\n")
        fo.write(f"  reg [{nbits*2-1}:0] rv;\n")
        fo.write("  case(ix)\n")
        for ix in range(len(wa)):
            fo.write(f"    {ix} : rv={condata(wa[ix])};\n")
        fo.write("  endcase\n")
        fo.write("  return rv;\n")
        fo.write(f"endfunction : {nm}\n")

dumpt(tw,"fftw.sv","fftwiddle")
#dumpt(twi,"ifftw.sv","ifftwiddle")

def mhx(fd):
    iv=int(fd*sf)
    if iv<0:
        iv=(1<<(nbits))+iv
    return f"{fd:5f} {iv:x}"


def debdata(wa,fn,msg):
    with open(fn,"w") as fo:
        fo.write(f"debug data {msg}\n")
        for ix in range(len(wa)):
            fo.write(f"{ix:3d} {mhx(wa[ix].real)}  {mhx(wa[ix].imag)}\n")

def mjfft(d):
    """A simple FFT algorithm for testing the code"""
    global tw
    wk = br(d)
    spread = 2
    for lvl in range(7):
        bs = 0
#        debdata(wk, f"fft{lvl}.deb", f"fft level {lvl}")
        while bs < 128:
            for ix in range(bs, bs + spread // 2):
                twix = (ix % spread) * (128 // spread)
                i1 = ix
                i2 = ix + spread // 2
                t = tw[twix]
                v = wk[i2] * t
                a = wk[i1] + v
                b = wk[i1] - v
                wk[i1] = a
                wk[i2] = b
            bs += spread
        spread *= 2
#    debdata(wk, "fftresults.deb", "fft results")
    
    # Print all the values of wk
   # for value in wk:
   #     print(value)
    
    return wk

def mjifft(d):
    """IFFT used by the test bench"""
    global twi
    wk=br(d)
    spread=2
    for lvl in range(7):
        bs=0
#        debdata(wk,f"ifft{lvl}.deb",f"IFFT lvl {lvl}")
        while(bs<128):
            for ix in range(bs,bs+spread//2):
                twix=(ix%spread)*(128//spread)
                i1=ix
                i2=ix+spread//2
                t=twi[twix] # uses the IFFT twiddles (Test bench only)
                v=wk[i2]*t
                a=wk[i1]+v
                b=wk[i1]-v
                wk[i1]=a
                wk[i2]=b
            bs+=spread
        spread*=2
    vi=[x/128 for x in wk]      # IFFT is scaled by the block size
    vi=[x.real+0j for x in vi] # real goes to real only (imag around 10^-16)
    return vi


def encbits(d):
    """Encodes 48 bits to frequency amounts"""
    amp = [0.0, 0.333, 0.666, 1.0]
    res = [0+0j for x in range(128)]
    fbin = 4
    while fbin < 52:
        xx = amp[d & 3]
        d >>= 2
        res[fbin] = xx
        res[128-fbin] = xx  # placed in both positive and negative freqs
        fbin += 2
    res[55] = 1.0
    res[128-55] = 1.0
    
    # Display res values
    #print("res values:")
   # for i, val in enumerate(res):
        #print(f"Index {i}: {val.real} + {val.imag}j")
    
    return res

def bdecode(spectrum):
    """ slices the spectrum data back to bits
Uses Freq bin 55 or 57 (Which ever is larger) as the full scale guide tone
Uses the square of values to avoid the square root"""
    tpoints=[0.0,0.333,0.666,1.0]
    full_scale=max(asq(spectrum[55]),asq(spectrum[57]))
    fspoints=[x*full_scale for x in tpoints]  # full scale spectrum
    decision_points=[ asq(0.166666*full_scale),
                      asq( (0.166666+0.333333)*full_scale ),
                      asq( (0.166666+0.666666)*full_scale )]
#    plt.plot([abs(x) for x in spectrum])
#    plt.show()
#    print("fullscale ",full_scale,hex(int(full_scale*sf)))
#    print(decision_points)
#    print([hex(int(x*sf)) for x in decision_points])
    res=0
    for x in range(4,52,2):
        fsq=asq(spectrum[x])
        bv=3
        for dx in range(3):
            if fsq<decision_points[dx]:
                bv=dx
                break
#        print(x,hex(int(fsq*sf)),bv)
        bv=bv<<(x-4)
        res=res|bv
    return res


def tcase(sdata):
# Encode the bits to frequency data
# sdata=0xE23456789F1B
    d=encbits(sdata)


# perform the IFFT. (Both my code, and library code)
#iff=fft.ifft(d) # library ifft used for debug
    mjiff=mjifft(d)
#debdata(mjiff,"iff.deb","ifft")

#plt.plot([x.real for x in iff],"b")
#plt.plot([x.real for x in mjiff],"r")
#plt.show()

#change array to a list (If from system library)
    liff=list(mjiff)

#sampling point (Not on an exact boundry of the FFT/IFFT)
#in a actual system, extra points are transmitted, and the
#receiver selects 128 points from the transmitted data
#this is not part of the project
    mistime=0
#duplicate the IFFT data to represent the pre and post samples
    ffd=(liff+liff+liff)[mistime:mistime+128] # select the points
    ffd=liff
    swffd=ffd
    cswffd=[x for x in swffd] # copy the data in case changed
#debdata(cswffd,"windata.deb","ifft data to dut")
#Stuff below is done by the design, above is done by the test bench

#back=fft.fft(swffd) # library fft (Used for debug)
    myback=mjfft(cswffd) # local algorithm fft
    rdata=bdecode(myback) # turn frequency data to 48 bits
#plt.plot([ asq(myback[x]) for x in range(64) ],"r")
#plt.show()
   # if rdata == sdata:
      # print("sent",hex(sdata),"received",hex(rdata))

def rand48():
    rv=0;
    for i in range(6*2):
        rd=random.randint(0,15)
        rv=rv<<4
        rv=rv|rd
#    print(f"{rv:x}")
    return rd
print("Twiddle factors for FFT (tw):", tw)
print("Twiddle factors for IFFT (twi):", twi)
#tcase(0xE23456789F1B)
#tcase(0x000000000000)
tcase(0x555555555555)
#tcase(0xaaaaaaaaaaaa)
#tcase(0xffffffffffff)
#for qq in range(1000):
 #   tcase(rand48())




