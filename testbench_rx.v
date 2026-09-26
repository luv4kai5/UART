module testbench_rx;


reg clk,rst,rg,tx_start;
reg[7:0] tx_data;
wire tx;
wire [7:0]rx_data;
wire rx_valid;
uart_tx tx1(tx, tx_data, tx_start, clk, rst);
uart_rx rx1(rx_valid,rx_data,clk,tx);

initial
begin
    clk=1'b0;
    rst=1'b1;
    tx_start=1'b0;
    tx_data=8'b0;
    #7 rst=1'b0;
end

always
begin
    #5 clk=~clk;
end

initial
begin
    $dumpfile("rx.vcd");
    $dumpvars(0,testbench_rx);
    $monitor(" At time t=%0t, tx=%b, state=%b, baud_counter=%d, bit_counter=%d, rx_valid=%b, rx_data=%b ", $time, tx, tx1.state, tx1.baud_counter, tx1.bit_counter, rx_valid, rx_data);
    #10 tx_start=1; 
    tx_data=8'b10101000; 
    #10 tx_start=0;
    #910000 $finish; 

end
endmodule