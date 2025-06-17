🔧 128-point FFT & Slicing Block for OFDM Receiver – FPGA Implementation
This project implements a 128-point complex FFT and slicing block for a simplified OFDM (Orthogonal Frequency Division Multiplexing) communication system, optimized for FPGA. It performs spectral bin analysis and bit slicing from modulated waveforms, enabling demodulation of frequency-domain symbols into digital bitstreams.

✅ System Overview
The system processes complex-valued I/Q input samples from an OFDM decoder, applies a 128-point FFT, and slices the resulting frequency-domain amplitudes to decode digital data encoded over 24 OFDM tones.

📐 Key Features
128-point Complex FFT using fixed-point (1.15) signed inputs.

Input Ports:

DinR, DinI: Real/Imaginary 16-bit values in 1.15 format.

PushIn, FirstData: Handshaking signals to delineate FFT frames.

Output Ports:

DataOut (48 bits): Output digital bits (2 bits per tone, 24 tones).

PushOut: Indicates output validity.

📊 Modulation Scheme
2-bit quantization per tone → 4 energy levels:
00 = 0%, 01 = 33%, 10 = 66%, 11 = 100%

Tone mapping:

Active tones: FFT bins 4 to 52 (even only, 24 total)

Reference tones: Bins 55 or 57 are used to determine full-scale reference amplitude

⚙️ Slicing Algorithm
FFT outputs are converted to magnitude:
Mag = sqrt(Re² + Im²)

Each bin’s magnitude is compared to full-scale (from bin 55 or 57):

< 25% → 00

25% – 49% → 01

50% – 74% → 10

75%+ → 11

📤 Output Format
One FFT block produces 48 bits (24 tones × 2 bits)

DataOut is delivered in sync with PushOut, starting with bin 4 → bin 52

🛠️ Design Constraints
Designed to operate under synchronous system clock (Clk)

Supports asynchronous reset

Timing and pipelining optimized for FPGA synthesis

Fully synthesizable RTL (tested on Vivado with 1 ns cycle time)

📁 Files & Structure
RTL modules: FFT wrapper, slicer, controller

Testbench with sample I/Q inputs simulating OFDM waveform

Post-synthesis verification with fixed-point test vectors

🧪 Verification
Tested with synthetic IFFT waveforms generated from 2-bit encoded tones

Verified energy slicing against known bit patterns

Correct 48-bit outputs confirmed over multiple test cases

🛜 Applications
OFDM demodulators

Software-defined radio (SDR) front ends

Spectrum analyzers

Digital communications training modules
