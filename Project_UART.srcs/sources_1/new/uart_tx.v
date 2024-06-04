
module uart_tx (
 input clk,
 input rst,
 input uart_tx_en, //전송 버튼, debouncer입력으로
 input [6:0] uart_tx_data, //송신할 7비트 data
 output reg tx_busy, //idle 상태가 아닐 때 '1'
 output reg uart_txd //송신 데이터
);
 /* reg 설정 parameter가 11개이므로 4bit c_state, n_state 생성, counter = 5207일 때 state를 넘겨주는 counter 
생성을 위해 counter를 12비트로 작성  */
reg [3:0] c_state; 
reg [3:0] n_state; 
reg [12:0] counter;

 /*parameter 생성 idle_st = 0, start_st = 1, bit0_st ~ bit6_st = 2 ~ 8까지 지정했습니다. */
parameter idle_st = 4'd0 , start_st = 4'd1,bit0_st=4'd2, bit1_st=4'd3, bit2_st=4'd4, 
bit3_st=4'd5, bit4_st=4'd6, bit5_st=4'd7, bit6_st=4'd8, parity_st = 4'd9, stop1_st = 4'd10,stop2_st = 4'd11;
 /* rst가 1이 될 때 c_state <= idle_st가 되도록 만들었습니다. 그리고 uart_start_pulse가 1이 되었을 때 c_state
 <= start_st가 되도록 만들었습니다. counter가 5207이 될 때 c_state<=n_state */
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
  
/* c_state의 다음 상태를 결정해주는 조합회로, 출력을 결정해주는 조합회로 idle_st 상태에서 uart_start_pulse가 1
이 되면 n_state <= start_st가 되도록 만들었습니다. 아니라면 idle_st를 유지하도록 만들었습니다. default 상태는 u
 art_txd 상태가 1이 되면 tx_busy가 0, n_state <= idle_st가 되도록 만들었습니다. bit0_st ~ bit6_st는 uart_txd 
<= uart_tx_dat[0~7] 까지 받도록 만들고, n_state가 다음 bit을 받도록 설계했습니다. tx_busy는 idle일 때 0, tx_bu
 sy가 데이터를 전송할 때 1을 보내도록 만들었습니다. */
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
  
/* simulation을 위해서 assign uart_start_pulse = uart_tx_en을 사용했습니다. 그리고 실제 사용을 위해서 debou
 nce를 instantiation을 사용해서 uart_tx_en의 신호를 uart_start_pulse로 만들어주는 코드를 사용했습니다. */
//assign uart_start_pulse = uart_tx_en; //for simulation
debounce debounce_inst (clk, rst, uart_tx_en, , uart_start_pulse); //for kit
 endmodule