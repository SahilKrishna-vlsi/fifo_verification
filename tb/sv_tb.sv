class data;
  randc logic [31:0] data_in;
  rand logic push;
  rand logic pop;
  bit full;
  bit empty;

  int i = 0;
  int j = 0;
  int count = 0;
  logic [31:0] data_reg[0:6];
  logic [31:0] data_out;

  constraint c_push_pop {
    if (push) pop != 1;
    if (pop) push != 1;
  }
  constraint c_full_empty {
    if (full) push != 1;
    if (empty) pop != 1;
  }

  function void post_randomize();
    $display("time %t data_in:%h pop:%d push:%d", $time, data_in, pop, push);
    if (count == 7) begin
      full  = 1;
      empty = 0;
    end
    if (count == 0) begin
      empty = 1;
      full  = 0;
    end

    if (push) begin
      if (i >= 7) i = 0;
      if (count < 7) begin
        data_reg[i] = data_in;
        i = i + 1;
        count++;
        empty = 0;
      end
    end
    if (pop) begin
      if (j >= 7) j = 0;
      if (count > 0) begin
        data_out = data_reg[j];
        j = j + 1;
        count--;
        full = 0;
      end
    end


  endfunction
endclass

module tb ();
  logic [31:0] data_in;
  logic push, pop, clk, reset;
  logic [31:0] data_out;
  logic [31:0] form_data_pkt_out, form_dut_data_out;
  bit empty, full;
  data d1;

  fifo f1 (
      .data_in(data_in),
      .push(push),
      .pop(pop),
      .clk(clk),
      .reset(reset),
      .data_out(data_out),
      .empty(empty),
      .full(full)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    d1 = new();
    #0 clk = 0;
    reset = 0;
    #1 clk = 0;
    reset = 1;
    #500 $finish;
  end
  always #5 clk = ~clk;
  always @(posedge clk) begin
    d1.randomize();
    data_in = d1.data_in;
    push = d1.push;
    pop = d1.pop;

  end


  always @(posedge clk) begin
    $display("time: %t", $time);
    foreach (f1.fifo_reg[i]) $display("fifo[%d]: %h", i, f1.fifo_reg[i]);
  end
  always @(posedge clk) begin
    if (pop) begin

      @(posedge clk);
      #1;
      form_data_pkt_out <= d1.data_out;
      form_dut_data_out <= data_out;
      if (d1.data_out == data_out) $display("pass");
      else
        $display(
            "j=%d d1.data_out=%h   index_pop=%d data_out=%h",
            d1.j,
            d1.data_out,
            f1.index_pop,
            data_out
        );
    end
  end
endmodule
