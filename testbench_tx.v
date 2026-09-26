module testbench_tx;
reg clk,rst,tx_start;
reg [7:0]tx_data;
wire tx;
uart_tx tx1(tx, tx_data, tx_start, clk, rst);

//clk generation
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
    #5clk=~clk;
end

initial
begin
    $dumpfile("tx.vcd");
    $dumpvars(0,testbench_tx);
    $monitor("time=%0t tx=%b state=%b baud_counter=%d bit_counter=%d",
         $time, tx, tx1.state, tx1.baud_counter, tx1.bit_counter);
    #10 tx_start=1; 
        tx_data=8'b1010100; 
    #10 tx_start=0;
    #1200 $finish;

end

endmodule