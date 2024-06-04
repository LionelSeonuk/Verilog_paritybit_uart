module tx_test;
reg clk;
reg rst; 
reg uart_tx_en; 
reg [6:0] uart_tx_data; 
wire tx_busy; 
wire uart_txd;

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
        $stop;
end
uart_tx tx0(clk,rst,uart_tx_en,uart_tx_data,tx_busy,uart_txd);
endmodule