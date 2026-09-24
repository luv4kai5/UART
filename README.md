# Universal Asynchronous Receiver Transmitter

* It is a hardware communication protocol that involves asynchronous (the R.X. and T.X. have individual clocks, but no shared clock) serial data communication with a configurable baud rate.

* Baud rate is the symbols being sent per unit time. Bit rate is bits being sent per unit time. In UART, symbol = 1 bit, so baud rate = bit rate.

* There are 2 UART devices. The data bus sends data in parallel to device 1, which converts it to serial data and transmits it over the transmitting line to be received at the receiver of device 2 serially, which again converts it to parallel data being written into the data bus. The baud rate has to be the same for both devices.

* Possible baud rates:

  * 9600
  * 19200
  * 38400
  * 57600
  * 115200
  * 230400
  * 460800
  * 921600
  * 1000000
  * 1500000

* This protocol sends the data in the hardware line between the two devices in the form of a data packet. The data is wrapped around with start bit, parity bit and stop bit.

  * So basically the transmission line is at voltage high (1) when it's not transmitting data. When the transmitting device wants to send data, it changes the voltage from high to low for 1 clock cycle. When the receiver detects this start bit (1 bit), it starts to read the data at the frequency of baud rate.
  * Data frame (5–9 bits): LSB is sent first and also the data frame can be 9 bits if no parity bit is sent.
  * Parity Bit (0–1 bit): When the receiver has read the data, it counts the number of 1's in the data frame. It is implied that if the number of 1's in the data frame is even, parity bit = 0, otherwise the parity bit for odd number of 1's should = 1. If this is not the case, receiver knows that the data sent is wrong, got manipulated during transmission through electromagnetic radiation, mismatched baud rates or other factors.
  * Stop bit (1 to 2 bits): To signal the end of the data packet, T.X. drives the T.X. line to one.

## Frame Protocol

Frame protocol defines a custom structure for UART messages so that the receiver can identify and validate the intended data. Designers can define headers, trailers and CRC according to their application.

* Header 1 (H1 is `0xAB`) and Header 2 (H2 is `0xCD`): Header is the unique identifier that determines if you are communicating with the correct device.
* CMD (Command): Defines what action/message the device wants to communicate.
* DL (Data Length): Specifies the number of data bytes in the frame; varies with the command.
* Data (Payload): Actual information being transferred between devices.
* Trailer (T1, T2): Special bytes added at the end of the frame to identify the frame ending. Example: T1 = `0xE1`, T2 = `0xE2`.
* CRC (Cyclic Redundancy Check): Error-detection method. Receiver calculates CRC and compares it with the transmitted CRC; matching CRC → data is likely correct.

## Use Cases of UART

* **Debugging/Manufacturing** → problem finding, some device's internal information can be displayed on a PC through UART.
* **Updates** → device can be given new data/software.
* **Verification** → check whether the design is correct or not.

## 8-N-1

* 8-N-1 => 8 data bits, no parity bit, and 1 stop bit.
* 9600 baud rate means 9600 bits are transmitted per second.
* Time between the transmission of each bit:

```text
1 / 9600 = 104.17 microseconds
```

* Since 10 bits are sent in a frame — 1 start bit, 1 stop bit, and 8 data bits — it takes:

```text
10 × 104.17 µs = 1.04 ms
```

## UART Tx

Our UART Tx consists of many blocks:

* **FSM** → tells us what stage we are in (Idle, Start, Data, Stop).
* **Baud Counter** → our system clock is very fast compared to our baud rate, so we need a counter that, when ticked to the number of clocks:

```text
System Clock Rate / Baud Rate
```

tells us when we can change our bit in the TX line or the time we can send a fresh bit in the TX line.

* **Bit Counter** → tells us which bit to send into the TX line when the baud counter has ticked.
* **Shift Register** → in order to move to the desired bit and choose it to send to the TX line, we need a shift register.

## UART Transmitter FSM

The UART transmitter is controlled using a Finite State Machine (FSM) that defines which stage of transmission is currently active.

### TX States

* **IDLE:** No transmission is active. `TX = 1`. Counters remain/reset at 0.
* **START:** `TX = 0` for one complete bit period. The baud counter measures this period.
* **DATA:** The 8 data bits are transmitted LSB first. The bit counter tracks which data bit is being transmitted.
* **STOP:** `TX = 1` for one complete bit period. After this, the transmitter returns to IDLE.

### Counters

* **Baud Counter:** Counts system-clock cycles until one UART bit period is completed. It resets after reaching its limit.
* **Bit Counter:** Tracks the current data bit (0 to 7) and advances whenever one bit period is completed.
