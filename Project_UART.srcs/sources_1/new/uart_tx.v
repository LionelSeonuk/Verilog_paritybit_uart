
module uart_tx (
 input clk,
 input rst,
 input uart_tx_en, //���� ��ư, debouncer�Է�����
 input [6:0] uart_tx_data, //�۽��� 7��Ʈ data
 output reg tx_busy, //idle ���°� �ƴ� �� '1'
 output reg uart_txd //�۽� ������
);
 /* reg ���� parameter�� 11���̹Ƿ� 4bit c_state, n_state ����, counter = 5207�� �� state�� �Ѱ��ִ� counter 
������ ���� counter�� 12��Ʈ�� �ۼ�  */
reg [3:0] c_state; 
reg [3:0] n_state; 
reg [12:0] counter;

 /*parameter ���� idle_st = 0, start_st = 1, bit0_st ~ bit6_st = 2 ~ 8���� �����߽��ϴ�. */
parameter idle_st = 4'd0 , start_st = 4'd1,bit0_st=4'd2, bit1_st=4'd3, bit2_st=4'd4, 
bit3_st=4'd5, bit4_st=4'd6, bit5_st=4'd7, bit6_st=4'd8, parity_st = 4'd9, stop1_st = 4'd10,stop2_st = 4'd11;
 /* rst�� 1�� �� �� c_state <= idle_st�� �ǵ��� ��������ϴ�. �׸��� uart_start_pulse�� 1�� �Ǿ��� �� c_state
 <= start_st�� �ǵ��� ��������ϴ�. counter�� 5207�� �� �� c_state<=n_state */
 always @(posedge clk or posedge rst) begin
 if (rst) c_state <= idle_st;
 else begin
 if ( uart_start_pulse  == 1) c_state <= start_st;
  else if (counter == 5207)
  c_state <= n_state;
 end
 end

 always @(posedge clk or posedge rst)begin
          if(rst) counter <= 0;
 else begin 
 if( counter == 5207) counter <=0;
 else if (uart_start_pulse == 1'b1) counter <= 0;//
 else counter <= counter + 1;
 end
 end 

always @(posedge clk or posedge rst) begin
    if (rst) begin
        parity_bit <= 0;
    end else if (c_state == bit6_st) begin
        parity_bit <= (^(uart_tx_data[6:0]))?1'b1:1'b0;
    end
end
  
/* c_state�� ���� ���¸� �������ִ� ����ȸ��, ����� �������ִ� ����ȸ�� idle_st ���¿��� uart_start_pulse�� 1
�� �Ǹ� n_state <= start_st�� �ǵ��� ��������ϴ�. �ƴ϶�� idle_st�� �����ϵ��� ��������ϴ�. default ���´� u
 art_txd ���°� 1�� �Ǹ� tx_busy�� 0, n_state <= idle_st�� �ǵ��� ��������ϴ�. bit0_st ~ bit6_st�� uart_txd 
<= uart_tx_dat[0~7] ���� �޵��� �����, n_state�� ���� bit�� �޵��� �����߽��ϴ�. tx_busy�� idle�� �� 0, tx_bu
 sy�� �����͸� ������ �� 1�� �������� ��������ϴ�. */
 always @(*) begin
 case (c_state)
idle_st: begin tx_busy = 0; uart_txd = 1'b1; if(uart_start_pulse == 1'b1) n_state = start_st; else n_state = idle_st;  end 
start_st: begin tx_busy = 1;uart_txd = 1'b0;            n_state = bit0_st; end
bit0_st: begin tx_busy = 1; uart_txd = uart_tx_data[0]; n_state =bit1_st; end
bit1_st: begin tx_busy = 1; uart_txd = uart_tx_data[1]; n_state = bit2_st; end
bit2_st: begin tx_busy = 1; uart_txd = uart_tx_data[2]; n_state =bit3_st; end
bit3_st: begin tx_busy = 1; uart_txd = uart_tx_data[3]; n_state =bit4_st; end
bit4_st: begin tx_busy = 1; uart_txd = uart_tx_data[4]; n_state = bit5_st; end
bit5_st: begin tx_busy = 1; uart_txd = uart_tx_data[5]; n_state =bit6_st; end
bit6_st: begin tx_busy = 1; uart_txd = uart_tx_data[6]; n_state = parity_st; end
parity_st: begin tx_busy = 1; uart_txd = 1; n_state=stop1_st; end
stop1_st: begin tx_busy = 1; uart_txd = 1; n_state=stop2_st; end
stop2_st: begin tx_busy = 1; uart_txd = 1; n_state=idle_st; end
default: begin if (uart_txd == 1 ) begin tx_busy = 0; n_state = idle_st; end 
else begin tx_busy = 1; n_state = bit0_st; end end
 endcase
 end 
  
/* simulation�� ���ؼ� assign uart_start_pulse = uart_tx_en�� ����߽��ϴ�. �׸��� ���� ����� ���ؼ� debou
 nce�� instantiation�� ����ؼ� uart_tx_en�� ��ȣ�� uart_start_pulse�� ������ִ� �ڵ带 ����߽��ϴ�. */
//assign uart_start_pulse = uart_tx_en; //for simulation
debounce debounce_inst (clk, rst, uart_tx_en, , uart_start_pulse); //for kit
 endmodule