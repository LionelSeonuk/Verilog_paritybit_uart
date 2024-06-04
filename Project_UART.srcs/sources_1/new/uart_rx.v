module uart_rx (
    input clk,
    input rst,
    input uart_rxd, //수신 데이터
    output reg rx_busy, //idle 상태가 아닐때 '1'
    output reg [7:0] uart_rx_data //수신한 7비트 data, 1비트 parity 
 );

    reg [3:0] c_state, n_state;
    reg [12:0] counter;
    reg [9:0] uart_rx_change; 

    parameter idle_st = 4'd0, start_st = 4'd1, bit0_st = 4'd2, bit1_st = 4'd3, bit2_st = 4'd4, bit3_st = 4'd5, bit4_st = 4'd6, bit5_st = 4'd7, bit6_st = 4'd8, parity_st = 4'd9, stop1_st = 4'd10, stop2_st = 4'd11;
/* c_state 출력을 조절하기 위한 순차 회로를 작성하였습니다. rst 값이 1이 되면 c_state<=idle_st, (uart_rxd == 0 && rx_busy = 0) 일 때, c_state <= start_st의 상태로 바꾸어줬습니다. 그리고 counter == 5207이 되었을 때 c_state가 <= n_state가 되도록 코드를 작성했습니다. */
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
/*uart_rx_data의 값을 초기화 해주기 위해 순차 회로를 사용하고 그대로 출력으로 연결했습니다. c_state의 다음 상태를 결정해주는 순차 회로, 출력을 결정해주는 순차 회로 start_st 상태에서 uart_rx_um[0]이 uart_rxd의 값을 받고 아니라면 idle_st를 유지하도록 만들었습니다. default 상태에선 uart_rxd가 1을 받으면 rx_busy가 0, n_state <= idle_st가 되도록 만들었습니다. bit0_st ~ bi6_st는 uart_rx_um <= uart_tx_dat[0~6] 까지 받도록 만들고, parity bit는 ^(uart_rx_um[7:1]) 받도록 만들었습니다. n_state가 다음 bit을 받도록 설계했습니다. 그리고 마지막 stop_st에선 uart_rx_data <={uart_rx_um[8], uart_rx_um[7:1]}; 로 값을 받아서 필요한 데이터를 추출했습니다. rx_busy는 idle일 때 0, rx_busy가 데이터를 받고 있을 때 1을 갖도록 만들었습니다. */
    
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