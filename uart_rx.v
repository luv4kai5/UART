module uart_rx(rx_valid,rx_data,clk,tx);
input clk,tx;
output reg[7:0]rx_data;
output reg rx_valid;
reg [1:0]state;
parameter IDLE=2'b00,
          DETECT_START=2'b01,
          DATA=2'b10,
          STOP=2'b11,
          CLK_FREQ = 100_000_000,  // 100 MHz
          BAUD_RATE = 9600,
          BAUD_LIMIT = (CLK_FREQ / BAUD_RATE) - 1;
reg[13:0]baud_counter;//still enough to store 1.5 baud limit
reg[3:0] bit_counter;

always @(posedge clk)
begin
    case(state)
    IDLE:
        begin
            rx_valid<=0;
            if(tx==0)
                begin
                    state<=DETECT_START;
                    rx_data<=0;
                    bit_counter<=0;
                    baud_counter<=0;
                end
        end
    DETECT_START:
        begin
            baud_counter<=baud_counter+1;
            if(baud_counter==(3*BAUD_LIMIT)/2)
                begin
                    rx_data[bit_counter]<=tx;
                    baud_counter=0;
                    bit_counter<=bit_counter+1;
                    state<=DATA;
                end
        end
    DATA:
        begin
            baud_counter<=baud_counter+1;
            if(baud_counter==BAUD_LIMIT)
                begin
                    rx_data[bit_counter]<=tx;
                    bit_counter<=bit_counter+1;
                    baud_counter<=0;
                end
            if(bit_counter==8)
            begin
                state<=STOP;
            end
        end
    STOP:
        begin
            baud_counter<=baud_counter+1;
            if(baud_counter==BAUD_LIMIT)
                begin
                    if(tx==1)
                    begin
                        rx_valid<=1;
                        bit_counter<=0;
                        baud_counter<=0;
                        state<=IDLE;
                    end
                end
        end
        default:
            begin
                baud_counter<=0;
                bit_counter<=0;
                state<=IDLE;
            end
    endcase
end
endmodule