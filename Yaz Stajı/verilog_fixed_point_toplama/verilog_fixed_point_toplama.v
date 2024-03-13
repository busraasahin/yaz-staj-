module fixed_point_toplama(
	input signed [7:0] a, 
	input signed [7:0] b,
	output reg signed [8:0] sonuc1
    );
	
	always @(*) begin
		
		if (a[7] ^ b[7] == 1'b1) begin
		
			sonuc1 = a + b;
			
			sonuc1[8] = sonuc1[7];
			
		end
		else begin
			
			sonuc1 = a + b;
		
		end
		
	end
	
endmodule

