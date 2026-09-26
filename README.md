# Universal Asynchronous Receiver Transmitter (UART) 📡

## Overview

UART is a hardware communication protocol for asynchronous serial data transmission. The transmitter and receiver use independent clocks operating at the same baud rate (bits per second).

**Key Characteristics:**
- 🔄 Asynchronous: No shared clock between TX and RX
- 📊 Serial: One bit transmitted at a time
- ⚡ Configurable baud rates: 9600, 19200, 38400, 57600, 115200, 230400, etc.
- 🟢 Simple: Requires only two wires (TX and RX)

---

## UART Frame Format (8-N-1)

The standard frame consists of **10 bits total:**

| Component | Bits | Details |
|-----------|------|---------|
| START | 1 | TX line goes LOW (1→0) to signal frame start |
| DATA | 8 | LSB transmitted first |
| STOP | 1 | TX line goes HIGH to signal frame end |

**⏱️ Timing at 9600 Baud:**
- Bit period: 1 / 9600 = **104.17 µs**
- Complete frame: 10 bits × 104.17 µs = **~1.04 ms**

---

## Implementation Details

### Baud Counter 🕐
- Counts system clock cycles within one UART bit period
- Formula: `BAUD_LIMIT = (System_Clock / Baud_Rate) - 1`
- Example (100 MHz clock, 9600 baud): `BAUD_LIMIT = 10,415`

### Bit Counter 📍
- Tracks the current data bit being transmitted/received (0-7)

### FSM (Finite State Machine) ⚙️
- Controls the transmission/reception state
- 4 states: IDLE, START, DATA, STOP

---

## UART TX FSM Stages 📤

### State 0: IDLE (2'b00)
- TX output = HIGH (idle state)
- Counters = 0
- ⏳ Waiting for `tx_start` signal to initiate transmission

### State 1: START (2'b01)
- TX output = LOW (START bit)
- Load `tx_data` into internal shift register
- Count BAUD_LIMIT cycles
- → Transition to DATA state when complete

### State 2: DATA (2'b10)
- TX output = data_register[bit_counter] (LSB first)
- Count BAUD_LIMIT cycles for each bit
- Increment bit_counter after each bit period
- → Transition to STOP state when all 8 bits sent

### State 3: STOP (2'b11)
- TX output = HIGH (STOP bit)
- Count BAUD_LIMIT cycles
- ✅ Return to IDLE state when complete

---

## UART RX FSM Stages 📥

### State 0: IDLE (2'b00)
- rx_valid = LOW
- 👂 Listening for falling edge on RX line (1→0)
- Counters = 0

### State 1: DETECT_START (2'b01)
- Count 1.5 × BAUD_LIMIT cycles (sample at middle of START bit)
- 📍 Sample first data bit: `rx_data[0] = RX`
- → Transition to DATA state

### State 2: DATA (2'b10)
- Sample one data bit every BAUD_LIMIT cycles
- 📝 Store in `rx_data[bit_counter]`
- Increment bit_counter after each sample
- → Transition to STOP state when all 8 bits received

### State 3: STOP (2'b11)
- ✓ Verify STOP bit (RX must be HIGH)
- If valid: assert `rx_valid` (pulse for 1 cycle)
- → Return to IDLE state

---

## Configuration 🎯

- ⏱️ Clock Frequency: 100 MHz
- 📡 Baud Rate: 9600 baud
- 🔢 BAUD_LIMIT: 10,415 cycles
- ⏳ Bit Period: 104.17 µs
- 📊 Frame Period: 1.04 ms (10 bits)

- 📦 Data Format: 8-N-1 (8 data bits, No parity, 1 stop bit)
- ↙️ Bit Order: LSB first

---

## Use Cases 💡

- **🐛 Debugging & Verification:** Display device information on a PC
- **💾 Firmware Updates:** Program new software into devices
- **🔗 Serial Communication:** Inter-device data transfer (PC↔FPGA, sensor interfaces, etc.)
