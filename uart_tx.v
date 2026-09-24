module uart_tx(tx, tx_data, tx_start, clk, rst);

input clk, tx_start,rst;
// the system clock, and the start/request signal, 
//which tells to start the transmission of data.
input [7:0] tx_data;
//the 8 data bit the transmitter wants to send serially to reciever
output tx;
 //the tx line, which has one bit at a time (since its a serial communication)

reg [1:0]state; //remembers which state the transmitter is in.
parameter IDLE=2'b00,
          START=2'b01,
          DATA=2'b10,
          STOP=2'b11,
          BAUD_LIMIT = 5207;

reg[12:0]baud_counter;
//counts system-clock cycles within one UART bit period
//13 bits because 2^13=8162 qen 50MHz/9600 ~ 5208
reg[2:0]bit_counter;

reg[7:0]data_register;
//to hold the byte we are transmitting since halway through the external circuit may change
always @(posedge clk)
begin

//reset basically resets the transmission line, brings the counter to idle state.
        state<=IDLE;
        baud_counter<=0;
        bit_counter<=0;
        data_register<=0;
        tx<=1;
    end

    else
//else if its not reset, we focus on our fsm
    begin
//every time the positive edge comes of system clk, our baud counter increments
    baud_counter<=baud_counter+1;
    case(state)

    IDLE:
    // in idle state, if the tx_start sends a signal, the baud_counter and bit_counter, resets
    //state moves to start and the data gets loaded in the data_register
    begin
        if(tx_start)
        begin
        data_register<=tx_data;
        bit_counter<=0;
        baud_counter<=0;
        state<=START;
        end
    end
// in start state, the tx line gets 0, and when baud counter reaches its limit,
// state is shifted to data
//aslo the baudcounter is reset.
    START:
    begin
        tx<=0;
        if(baud_counter==BAUD_LIMIT)
        begin
            state<=DATA;
            baud_counter<=0;  
        end
    end
// in data state, tx gets the dataregister[bit counter value]
// the baud counter reaches the limit and the bit counter increments, the baud counter resets
// also if the bit counter reaches 7, state is shifted to stop state, bit counter is reset.
    DATA:
    begin
        tx<=data_register[bit_counter];
        if(baud_counter==BAUD_LIMIT)
        begin
        baud_counter<=0;
            if(bit_counter==7)
            begin
                bit_counter<=0;
                state<=STOP;
            end

            else
            begin
                bit_counter<=bit_counter+1;
            end
        end   
    end
//in stop state, the tx line is set to 1, when the baud counter hits its limit, its reset 
//and state is sent to ifle
    STOP:
    begin
        tx<=1;
        if(baud_counter==BAUD_LIMIT)
        begin 
            baud_counter<=0;     
            state<=IDLE;
        end
    end
    default:
    begin
        bit_counter<=0;
        baud_counter<=0;
        state<=IDLE;
    end
    endcase
end
endmodule