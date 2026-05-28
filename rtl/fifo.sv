module fifo (
    input [31:0] data_in,
    input push,
    pop,
    clk,
    reset,
    output logic [31:0] data_out,
    output bit empty,
    full
);
  reg [3:0] index_push;
  reg [3:0] index_pop;
  logic [2:0] count;
  logic [31:0] fifo_reg[0:6];
  always @(posedge clk or negedge reset) begin
    if (~reset) begin
      foreach (fifo_reg[i]) fifo_reg[i] = 32'b0;
      index_push = 4'b0;
      index_pop = 4'b0;
      count = 3'd0;
      full = 1'b0;
      empty = 1'b1;
    end else begin
      if (push) begin
        if (index_push == 3'd7) index_push = 3'd0;
        if (count < 3'd7) begin
          fifo_reg[index_push] = data_in;
          index_push = index_push + 3'b1;
          count++;
          full  = 1'b0;
          empty = 1'b0;
        end
        if (count == 3'd7) begin
          full  = 1'b1;
          //           if (index_push >= 6) index_push = 0;
          empty = 1'b0;
        end
      end
      if (pop) begin
        if (index_pop == 3'd7) index_pop = 3'd0;
        if (count != 4'b0) begin
          data_out = fifo_reg[index_pop];
          fifo_reg[index_pop] = 32'b0;
          index_pop = index_pop + 3'b1;
          count--;
          empty = 1'b0;
          full  = 1'b0;
        end
      end
      if (count == 0) begin
        full  = 1'b0;
        //         if (index_pop >= 6) index_pop = 0;
        empty = 1'b1;
      end
    end
  end
endmodule
