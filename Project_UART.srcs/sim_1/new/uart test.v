 module uart_test;
 reg rst, clk;
 reg uart_tx_en;
 reg [6:0] uart_tx_data;
 reg uart_rxd;
 wire uart_txd; //�۽� ������ TX --> RX
 wire [6:0] uart_rx_data; //�۽� ������
/* �ʱ�ȭ �� uart_tx_en�� 1�� �־��� ��, uart_tx_data�� ���� �־��ش�. �����Ͱ� 8bit�̻��� �Ѿ���� #8680
 0;�� �����ְ� �Ѿ��. */ 
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
 //clkǥ��
always begin
 #5;
 clk = ~clk;
 end
 uart_top top_inst(clk,rst,uart_tx_en,uart_tx_data,uart_txd,uart_rxd,uart_rx_data);
 endmodule
