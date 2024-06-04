module uart_rx (
    input clk,
    input rst,
    input uart_rxd, //���� ������
    output reg rx_busy, //idle ���°� �ƴҶ� '1'
    output reg [7:0] uart_rx_data //������ 7��Ʈ data, 1��Ʈ parity 
 );

    reg [3:0] c_state, n_state;
    reg [12:0] counter;
    reg [9:0] uart_rx_change; 

    parameter idle_st = 4'd0, start_st = 4'd1, bit0_st = 4'd2, bit1_st = 4'd3, bit2_st = 4'd4, bit3_st = 4'd5, bit4_st = 4'd6, bit5_st = 4'd7, bit6_st = 4'd8, parity_st = 4'd9, stop1_st = 4'd10, stop2_st = 4'd11;
/* c_state ����� �����ϱ� ���� ���� ȸ�θ� �ۼ��Ͽ����ϴ�. rst ���� 1�� �Ǹ� c_state<=idle_st, (uart_rxd == 0 && rx_busy = 0) �� ��, c_state <= start_st�� ���·� �ٲپ�����ϴ�. �׸��� counter == 5207�� �Ǿ��� �� c_state�� <= n_state�� �ǵ��� �ڵ带 �ۼ��߽��ϴ�. */
    always @(posedge clk or posedge rst) begin
 if (rst) c_state <= idle_st;
 else begin 
if(uart_rxd ==0 && rx_busy == 0) c_state <= start_st;
 else if( counter == 5207) c_state <= n_state;
 end 
end

 always @(posedge clk or posedge rst)begin
          if(rst) counter <= 0;
   else begin 
   if( counter == 5207) counter <=0;
   else counter <= counter + 1;
   end
   end
/*uart_rx_data�� ���� �ʱ�ȭ ���ֱ� ���� ���� ȸ�θ� ����ϰ� �״�� ������� �����߽��ϴ�. c_state�� ���� ���¸� �������ִ� ���� ȸ��, ����� �������ִ� ���� ȸ�� start_st ���¿��� uart_rx_um[0]�� uart_rxd�� ���� �ް� �ƴ϶�� idle_st�� �����ϵ��� ��������ϴ�. default ���¿��� uart_rxd�� 1�� ������ rx_busy�� 0, n_state <= idle_st�� �ǵ��� ��������ϴ�. bit0_st ~ bi6_st�� uart_rx_um <= uart_tx_dat[0~6] ���� �޵��� �����, parity bit�� ^(uart_rx_um[7:1]) �޵��� ��������ϴ�. n_state�� ���� bit�� �޵��� �����߽��ϴ�. �׸��� ������ stop_st���� uart_rx_data <={uart_rx_um[8], uart_rx_um[7:1]}; �� ���� �޾Ƽ� �ʿ��� �����͸� �����߽��ϴ�. rx_busy�� idle�� �� 0, rx_busy�� �����͸� �ް� ���� �� 1�� ������ ��������ϴ�. */
    
 always @(posedge clk or posedge rst) begin
        if (rst) begin
            uart_rx_data <= 0;
        end else begin
            case (c_state)
                idle_st: begin rx_busy <= 0; if (uart_rxd == 0) begin n_state <= start_st;rx_busy <= 1;end end
                start_st: begin rx_busy <= 1; n_state <= bit0_st;end
                bit0_st: begin rx_busy <= 1;uart_rx_change[0] <= uart_rxd; n_state <= bit1_st; end
                bit1_st: begin rx_busy <= 1;uart_rx_change[1] <= uart_rxd; n_state <= bit2_st; end
                bit2_st: begin rx_busy <= 1;uart_rx_change[2] <= uart_rxd; n_state <= bit3_st; end
                bit3_st: begin rx_busy <= 1;uart_rx_change[3] <= uart_rxd; n_state <= bit4_st; end
                bit4_st: begin rx_busy <= 1;uart_rx_change[4] <= uart_rxd; n_state <= bit5_st;end
                bit5_st: begin rx_busy <= 1;uart_rx_change[5] <= uart_rxd; n_state <= bit6_st;end
                bit6_st: begin rx_busy <= 1;uart_rx_change[6] <= uart_rxd; n_state <= parity_st;end
                parity_st: begin rx_busy <= 1;uart_rx_change[7] <= ~^(uart_rx_change[6:0]); n_state <= stop1_st;end
                stop1_st: begin rx_busy <= 1;n_state <= stop2_st;end
                stop2_st: begin rx_busy <= 1;uart_rx_data <= { uart_rx_change[7],uart_rx_change[6:0]};rx_busy <= 0; n_state <= idle_st;
                end
                default: n_state <= idle_st;
            endcase
        end
    end
endmodule