module uart_top(
	input clk, 
	input rst, 

	// tx
	input uart_tx_en, 
	input [6:0] uart_tx_data, 
	output uart_txd,
	
	//rx 
	input uart_rxd, 
	output [7:0] uart_rx_data
);
uart_tx tx_inst(clk, rst, uart_tx_en, uart_tx_data, , uart_txd);
uart_rx rx_inst(clk, rst, uart_rxd, , uart_rx_data);
endmodule