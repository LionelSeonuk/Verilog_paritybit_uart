module rx_test;
reg clk;
reg rst; 
reg uart_tx_en; 
reg [6:0] uart_tx_data; 
wire [7:0] uart_rx_data; 
wire tx_busy, rx_busy;
wire uart_d;

always begin
    #5 clk = ~clk;
end

initial begin
        clk = 0;
        rst = 1;
        uart_tx_en = 0;
        uart_tx_data = 0;
        #10000;
        uart_tx_data = 7'b1100111;
        #10; rst = 0;
        #10; uart_tx_en = 1;
        #10; uart_tx_en = 0;
        #5208;
        #5208;

        uart_tx_data = 7'b1100110;
        #10; uart_tx_en = 1;
        #10; uart_tx_en = 0;
        #5208;
        #5208;

        uart_tx_data = 7'b1010110;
        #10; uart_tx_en = 1;
        #10; uart_tx_en = 0;
        #5208;
        #5208;
end
uart_tx tx0(clk, rst, uart_tx_en, uart_tx_data, tx_busy, uart_d);
uart_rx rx0(clk, rst, uart_d, rx_busy, uart_rx_data);
endmodule