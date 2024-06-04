 module uart_test;
 reg rst, clk;
 reg uart_tx_en;
 reg [6:0] uart_tx_data;
 reg uart_rxd;
 wire uart_txd; //송신 데이터 TX --> RX
 wire [6:0] uart_rx_data; //송신 데이터
/* 초기화 후 uart_tx_en을 1로 넣어준 후, uart_tx_data에 값을 넣어준다. 데이터가 8bit이상이 넘어감으로 #8680
 0;을 쉬어주고 넘어간다. */ 
initial begin
 clk = 1'b0;
 rst = 1'b0;
 uart_rxd = 1'b0;
 uart_tx_en = 1'b0;
 #10;
 rst = 1'b1;
 #10;
 rst = 1'b0;
 //#10000;
 uart_tx_en = 1'b1;
 //uart_tx_data = 8'b10110010;
 #10;
 uart_tx_en = 1'b0;
 #520800;
 uart_tx_data = 7'b1011010;
 #520800;
 uart_tx_en = 1'b1;
 #10;
 uart_tx_en = 1'b0;
 uart_tx_data = 7'b1011010;
 #50;
 $stop;
 end
 //clk표현
always begin
 #5;
 clk = ~clk;
 end
 uart_top top_inst(clk,rst,uart_tx_en,uart_tx_data,uart_txd,uart_rxd,uart_rx_data);
 endmodule
