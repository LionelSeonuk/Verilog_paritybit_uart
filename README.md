# Parity bit UART
Implementation that adds parity bits to ensure data integrity of UART, a serial communication protocol

![image](https://github.com/LionelSeonuk/Verilog_paritybit_uart/assets/167200555/0c4dc52d-0b5e-416f-819a-62e08dfbebd6)
![image](https://github.com/LionelSeonuk/Verilog_paritybit_uart/assets/167200555/b59d26e1-ed31-46fb-8a00-d972dfb2d8e6)
![image](https://github.com/LionelSeonuk/Verilog_paritybit_uart/assets/167200555/4d45af43-a804-4a57-bb1b-2bb5601efc8e)


![image](https://github.com/LionelSeonuk/Verilog_paritybit_uart/assets/167200555/bb4e2198-28e5-4378-9598-a520e1ff362e)
![image](https://github.com/LionelSeonuk/Verilog_paritybit_uart/assets/167200555/c994c348-d652-471f-b87f-1ed60d69d15d)

![image](https://github.com/LionelSeonuk/Verilog_paritybit_uart/assets/167200555/ac58a9c2-318a-4f85-8809-28de61a45042)
# Code Explain
```verilog
module uart_tx (
 input clk,
 input rst,
 input uart_tx_en, //전송 버튼, debouncer입력으로
input [7:0] uart_tx_data, //송신할 8비트 data
 output reg tx_busy, //idle 상태가 아닐 때 '1'
 output reg uart_txd //송신 데이터
);
reg [3:0] c_state; 
reg [3:0] n_state; 
reg [9:0] counter;
 parameter idle_st = 4'd0 , start_st = 4'd1,bit0_st=4'd2, bit1_st=4'd3, bit2_st=4'd4, 
bit3_st=4'd5, bit4_st=4'd6, bit5_st=4'd7, bit6_st=4'd8, bit7_st=4'd9, 
stop_st = 4'd10;
 always @(posedge clk or posedge rst) begin
 if (rst) c_state <= idle_st;
 else begin
 if ( uart_start_pulse  == 1) c_state <= start_st;
  else if (counter == 867)
  c_state <= n_state;
 end
 end
 always @(posedge clk or posedge rst)begin
          if(rst) counter <= 0;
   else begin 
   if( counter == 867) counter <=0;
   else if (uart_start_pulse == 1'b1) counter <= 0;
   else counter <= counter + 1;
   end
   end 
 always @(*) begin
 case (c_state)
idle_st: begin tx_busy = 0; uart_txd = 1'b1; if(uart_start_pulse == 1'b1) n_state = start_st; 
         else n_state = idle_st;  end 
start_st: begin tx_busy = 1; uart_txd = 1'b0; n_state = bit0_st; end
bit0_st: begin tx_busy = 1; uart_txd = uart_tx_data[0]; n_state =bit1_st; end
bit1_st: begin tx_busy = 1; uart_txd = uart_tx_data[1]; n_state = bit2_st; end
bit2_st: begin tx_busy = 1; uart_txd = uart_tx_data[2]; n_state =bit3_st; end
bit3_st: begin tx_busy = 1; uart_txd = uart_tx_data[3]; n_state =bit4_st; end
bit4_st: begin tx_busy = 1; uart_txd = uart_tx_data[4]; n_state = bit5_st; end
bit5_st: begin tx_busy = 1; uart_txd = uart_tx_data[5]; n_state =bit6_st; end
bit6_st: begin tx_busy = 1; uart_txd = uart_tx_data[6]; n_state = bit7_st; end
bit7_st: begin tx_busy = 1; uart_txd = uart_tx_data[7]; n_state = stop_st; end
stop_st: begin tx_busy = 1; uart_txd = 1; n_state=idle_st; end
default: begin if (uart_txd == 1 ) begin tx_busy = 0; n_state = idle_st; end 
                        else begin tx_busy = 1; n_state = bit0_st; end end
endcase
end  
debounce debounce_inst (clk, rst, uart_tx_en, , uart_start_pulse);
endmodule
```
### UART TX
1. Reg setting parameter is 11, so 4 bit c_state, n_state, counter = 867, counter to hand over state. Write counters in 10 bits for generation.
2. I made it to be c_state <= idle_st when rst is 1, and c_state when uart_start_pulse is 1, c_state<=start_st.c_state<=n_state when counter reaches 867.
3. The combination circuit for determining the next state of the c_state and the combination circuit for determining the output, uart_start_pulse is 1 in the idle_st state.
4. Created to be n_state = start_st. Otherwise, idle_st is maintained. Default is u.
5. When the state of art_txd reaches 1, tx_busy becomes 0, n_st <= idle_st. bit0_st to bit7_store uart_txd<= uart_tx_dat[0-7] and n_state are designed to receive the following bits.
6. Tx_busy is 0, tx_busy when idle. tx_busy made me send 1 when I send the data.
```verilog
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
```
### UART RX
1. I created a sequential circuit to control the c_state output. When rst value becomes 1, c_state<=idle_st, (uart_rxd == 0 & rx_busy = 0), the state was changed to c_state <= start_st. And I wrote the code so that the c_state becomes <= n_state when counter == 5207.
2. In order to initialize the value of uart_rx_data, we used sequential circuits and connected them to the output as they were.
3. In the state of start_st, sequential circuits that determine the next state of c_state, and sequential circuits that determine the output, we made uart_rx_change[0] receive the value of uart_rxd, otherwise maintain idle_st. In the default state, if uart_rxd receives 1, rx_busy is made to be 0, and n_state <= idle_st.
4. bit0_st ~ bi6_st : uart_rx_change <= uart_tx_data[0~6] , parity bit : ^(uart_rx_change[7:1]), uart_rx_data: uart_rx_data <={uart_rx_change[8], uart_rx_change[7:1]}
