# 128-Point FFT & Slicing Block for OFDM Receiver

This project implements a **128-point complex FFT and slicing block** for a simplified OFDM (Orthogonal Frequency Division Multiplexing) receiver, designed for FPGA. The module converts complex I/Q input samples into frequency-domain bins, slices them according to predefined energy thresholds, and extracts digital symbols.

---

## 📌 System Overview

The design accepts 128 complex samples in 1.15 fixed-point format and performs an FFT to extract energy in 24 even-numbered bins (4 to 52). Two reference tones (bins 55 and 57) are used to approximate full-scale energy. The system slices each tone’s magnitude into 2-bit quantized symbols.

---

## 🔧 Specifications

* **FFT size:** 128-point (complex)
* **Input format:** 16-bit signed fixed-point (1.15) for both real and imaginary parts
* **Active bins:** Even-numbered bins 4 to 52 (24 tones total)
* **Tone encoding:** 2 bits per tone (4 levels: 00, 01, 10, 11)
* **Reference bins:** Bin 55 or 57 (used to determine 100% energy reference)
* **Output size:** 48 bits per FFT frame (24 tones × 2 bits)
* **Clocking:** Positive-edge system clock
* **Reset:** Active-high asynchronous reset

---

## 📤 Output Encoding

Each bin's magnitude is compared against full scale derived from bin 55 or 57:

| Encoded Value | Energy Level | Magnitude Range (% of Full Scale) |
| ------------- | ------------ | --------------------------------- |
| 00            | 0%           | < 25%                             |
| 01            | 33%          | ≥25% and <50%                     |
| 10            | 66%          | ≥50% and <75%                     |
| 11            | 100%         | ≥75%                              |

---

## 🔄 Port Description

| Name        | Dir | Width | Description                           |
| ----------- | --- | ----- | ------------------------------------- |
| `Clk`       | In  | 1     | Positive-edge system clock            |
| `Reset`     | In  | 1     | Active-high asynchronous reset        |
| `PushIn`    | In  | 1     | Indicates valid input data            |
| `FirstData` | In  | 1     | Marks the start of an FFT frame       |
| `DinR`      | In  | 16    | Real part of input (1.15 format)      |
| `DinI`      | In  | 16    | Imaginary part of input (1.15 format) |
| `PushOut`   | Out | 1     | Output valid indicator                |
| `DataOut`   | Out | 48    | 2-bit sliced outputs per FFT bin      |

---

## 🧪 Verification

* Inputs generated from an IFFT of 2-bit encoded bins
* Simulated and validated against expected frequency-domain outputs
* Functional verification performed using testbenches with varying energy levels

---

## 📁 Repository Structure

* `rtl/` – Verilog RTL modules for FFT interface, slicing logic, and controller
* `tb/` – Testbenches and stimulus generation for functional simulation
* `docs/` – Project documentation, diagrams, and this README

---

## 💡 Applications

* OFDM demodulators (e.g., WiFi, LTE baseband chains)
* SDR front-end processing
* Communication system education
* FPGA-based spectrum analysis

---

## ✅ Status

* ✅ Design synthesized in Vivado
* ✅ Verified functionally in simulation
* ✅ Generates correct 48-bit sliced outputs based on FFT analysis
