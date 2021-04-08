module DUT(dut_if.port_in in_inter, dut_if.port_out out_inter, output enum logic [1:0] {INITIAL,WAIT,SEND} state);
    
    FPmul adder_under_test(.FP_A(in_inter.A),.FP_B(in_inter.B),.clk(in_inter.clk),.RST_n(!in_inter.rst),.FP_Z(out_inter.data));
	
	int i = 0;
    int j = 0;
	\\int TEST = 0;
	
    always_ff @(posedge in_inter.clk)
    begin
        if(in_inter.rst) begin
            in_inter.ready <= 0;
            out_inter.data <= 'x;
            out_inter.valid <= 0;
            state <= INITIAL;
        end
        else case(state)
                INITIAL: begin
					if (j==0) begin
					in_inter.ready <= 1;
					state <= INITIAL;
					j++;
					end
					else if (j == 1) begin
						in_inter.ready <= 0;
						\\$display("\n-------------------TEST:%d------------------\n", TEST);
						\\TEST++;
						$display("MUL: input A = %f, input B = %f",$bitstoshortreal(in_inter.A),$bitstoshortreal(in_inter.B));
						$display("MUL: input A = %b, input B = %b",in_inter.A,in_inter.B);
						state <= INITIAL;
						j++;
					end
					else if (j < 8) begin
					in_inter.ready <= 0;
					state <= INITIAL;
					j++;
					end
					else begin
						in_inter.ready <= 0;
						$display("MUL: output OUT = %f",$bitstoshortreal(out_inter.data));
						$display("MUL: output OUT = %b",out_inter.data);
						out_inter.valid <= 1;
						state <= SEND;
					end
                end
                
                WAIT: begin
					if(i >=4) begin
						if(in_inter.valid) begin
							in_inter.ready <= 0;
							$display("MUL: output OUT = %f",$bitstoshortreal(out_inter.data));
							$display("MUL: output OUT = %b",out_inter.data);
							out_inter.valid <= 1;
							state <= SEND;
							i = 0;
						end
						
					end
					else begin
						if (i==0) begin
							\\$display("\n-------------------TEST:%d------------------\n", TEST);
							\\TEST++;
							$display("MUL: input A = %f, input B = %f",$bitstoshortreal(in_inter.A),$bitstoshortreal(in_inter.B));
							$display("MUL: input A = %b, input B = %b",in_inter.A,in_inter.B);
						end
						i++;
						state <= WAIT;
						in_inter.ready <= 0;
					end
                end
                
                SEND: begin
                    if(out_inter.ready) begin
                        out_inter.valid <= 0;
                        in_inter.ready <= 1;
                        state <= WAIT;
                    end
                end
        endcase
    end
endmodule: DUT
