`timescale 1ns / 1ps


	module floating_carpma #(

	parameter N_BIT 		= 64, // 16 32 64 128
	parameter EXPONENT 		= 11,  // 32 --> 8  		64 --> 11
	parameter DURUM 		= 128, // 32 --> 64 		64 --> 128
	parameter FRACTION      = 52, // 32 --> 23 			64 --> 52
	parameter DURUM_UST_BIT = 105, // 32 --> 47 		64 --> 105
	parameter BIAS 			= 1023 // 32 --> 127		64 --> 1023
	
	)
																
    (																							
																								
	input 		clk,	
	input 		[N_BIT-1:0] carpan, 	 // 32														
	input 		[N_BIT-1:0] carpilan,	 // 32														
	output 		[N_BIT-1:0] sonuc 		// 32															
	
    );																								
	

	wire [FRACTION:0] deger1 = {1'b1, carpan[FRACTION-1:0]};
	wire [FRACTION:0] deger2 = {1'b1, carpilan[FRACTION-1:0]};
	reg 		[DURUM-1:0] durum = 64'bx; 		// 64														
	reg 		[N_BIT-1:0] sonuc_; 		// 32															
	reg signed  [EXPONENT-1:0] carpan_us; 	// 8														
	reg signed  [EXPONENT-1:0] carpilan_us; // 8													
	reg signed  [EXPONENT-1:0] toplam_us;	// 8													
	reg signed  [EXPONENT:0] toplam_us2; 	// 9 EXPONENT TOPLAMI										
	wire 	    [DURUM_UST_BIT:0] carpim_fraction; // 48											
															

    fixed_carpma uut1 (
    
     .carpilan(deger1),
     .carpan(deger2),
     .clk(clk),
     .sonuc2(carpim_fraction)  
    
    );																						// DURUM{1'bz, EXPONENT'd1, FRACTION'd0, 1'bz, EXPONENT'd1, FRACTION'd0};
																											
	localparam DURUM_KONTROL 	= 64'bx; //bakilacak												
	localparam SIFIR_SIFIR	 	= {1'bz, {EXPONENT{1'd0}}, {FRACTION{1'd0}}, 1'bz, {EXPONENT{1'd0}}, {FRACTION{1'd0}}}; // 64'bz0000000000000000000000000000000z0000000000000000000000000000000;
	localparam SONSUZ_SIFIR  	= {1'bz, {EXPONENT{1'd1}}, {FRACTION{1'd0}}, 1'bz, {EXPONENT{1'd0}}, {FRACTION{1'd0}}}; // DURUM{1'bz, EXPONENT'd1, FRACTION'd0, 1'bz, EXPONENT'd0, FRACTION'd0};
	localparam SIFIR_SONSUZ 	= {1'bz, {EXPONENT{1'd0}}, {FRACTION{1'd0}}, 1'bz, {EXPONENT{1'd1}}, {FRACTION{1'd0}}};
	localparam SONSUZ_SONSUZ  	= {1'bz, {EXPONENT{1'd1}}, {FRACTION{1'd0}}, 1'bz, {EXPONENT{1'd1}}, {FRACTION{1'd0}}};	

	
	always @(posedge clk) begin

		case (durum)
			
			DURUM_KONTROL: begin
			
				durum = {1'bz, carpan[N_BIT-2:0], 1'bz, carpilan[N_BIT-2:0]}; //0000000000000000000000000000000000000.......1
			
			end
			
			SIFIR_SIFIR: begin
			
				sonuc_ = {N_BIT{1'b0}};
			
			end
			
			SONSUZ_SIFIR: begin
			
				sonuc_ = {1'bz, {EXPONENT{1'b1}}, {FRACTION{1'b1}}};
			
			end
			
			SIFIR_SONSUZ: begin
			
				sonuc_ = {1'bz, {EXPONENT{1'b1}}, {FRACTION{1'b1}}};
			
			end
			
			SONSUZ_SONSUZ:begin 
			
				if (carpan[N_BIT-1] ^ carpilan[N_BIT-1] == 1) begin // 31
				
					sonuc_ = {1'b1, {EXPONENT{1'b1}}, {FRACTION{1'b0}}};
					
				end
				
				else begin
				
					sonuc_ = {1'b0, {EXPONENT{1'b1}}, {FRACTION{1'b0}}};
				
				end
			
			end
			
			default: begin
			
				if (durum[DURUM-2:DURUM-1-EXPONENT] == {EXPONENT{1'b1}} && durum[DURUM-2-EXPONENT:N_BIT] == {FRACTION{1'b0}} && durum[N_BIT-2:FRACTION] != {EXPONENT{1'b1}}) begin // SONSUZ_SAYI 
			
					if (carpan[N_BIT-1] ^ carpilan[N_BIT-1] == 1) begin
				
						sonuc_ = {1'b1, {EXPONENT{1'b1}}, {FRACTION{1'b0}}};
					
					end
					
					else begin
					
						sonuc_ = {1'b0, {EXPONENT{1'b1}}, {FRACTION{1'b0}}};
					
					end
		
				end 
														
				else if (durum[N_BIT-2:FRACTION] == {EXPONENT{1'd1}} && durum[FRACTION-1:0] == {FRACTION{1'd0}} && durum[DURUM-2:DURUM-1-EXPONENT] != {EXPONENT{1'd1}})  begin // SAYI_SONSUZ
				
					if (carpan[N_BIT-1] ^ carpilan[N_BIT-1] == 1) begin
				
						sonuc_ = {1'b1, {EXPONENT{1'b1}}, {FRACTION{1'b0}}};
					
					end
					
					else begin
					
						sonuc_ = {1'b0, {EXPONENT{1'b1}}, {FRACTION{1'b0}}};
					
					end
				
				end
							// 63:32  127:64 //{1'bz,{(n_bit-1){1'd0}}                62 - 52                
				else if ( durum[DURUM-2:N_BIT] == {(N_BIT-1){1'b0}} && durum[N_BIT-2:FRACTION] != {EXPONENT{1'b1}}) begin // SIFIR_SAYI
					
					sonuc_ = {N_BIT{1'b0}};
					
				end
							// 62:0
				else if (durum[N_BIT-2:0] == {(N_BIT-1){1'b0}} && durum[DURUM-2:DURUM-1-EXPONENT] != {EXPONENT{1'b1}}) begin // SAYI_SIFIR
					

					sonuc_ = {N_BIT{1'b0}};
				
				end
								//64-2:64-1-8 62:55		128-2:128-1-11	126:116		// 54:32    115:64						//     62-52
				else if (durum[DURUM-2:DURUM-1-EXPONENT] == {EXPONENT{1'd1}} && durum[DURUM-2-EXPONENT:N_BIT] != {FRACTION{1'd0}} || durum[N_BIT-2:FRACTION] == {EXPONENT{1'd1}} && durum[FRACTION-1:0] != {FRACTION{1'd0}}) begin // NaN-bagimsiz
					
					sonuc_ = {1'b0, {EXPONENT{1'b1}}, {FRACTION{1'b1}}};
					
				end
					
				else begin // SAYI_SAYI  
				
					carpan_us 					= carpan[N_BIT-2:FRACTION] - BIAS;  // 
					carpilan_us 				= carpilan[N_BIT-2:FRACTION] - BIAS; // 
					// carpim_fraction			    = {1'b1, carpan[FRACTION-1:0]} * {1'b1, carpilan[FRACTION-1:0]}; // hata!
					toplam_us  					= carpan_us + carpilan_us + carpim_fraction[DURUM_UST_BIT]; //; 7
					// 1.1001x2^7 hidden number fraction carpim 2^(toplam us)
					toplam_us2 					= toplam_us + BIAS; 
					
					if (carpan[N_BIT-1] ^ carpilan[N_BIT-1] == 1) begin
						
						if (carpim_fraction[DURUM_UST_BIT] == 0) begin // 100000000
						
							sonuc_ = {1'b1, toplam_us2[EXPONENT-1:0], carpim_fraction[DURUM_UST_BIT-2:FRACTION]}; //0_00000000_0000000000000000000000000
							
						end
						
						else begin
						
							sonuc_ = {1'b1, toplam_us2[EXPONENT-1:0], carpim_fraction[DURUM_UST_BIT-1:FRACTION+1]};
						
						end
						
					end
					
					else begin
						
						if (carpim_fraction[DURUM_UST_BIT] == 0) begin
						
							sonuc_ = {1'b0, toplam_us2[EXPONENT-1:0], carpim_fraction[DURUM_UST_BIT-2:FRACTION]};
							
						end
						
						else begin
						
							sonuc_ = {1'b0, toplam_us2[EXPONENT-1:0], carpim_fraction[DURUM_UST_BIT-1:FRACTION+1]};
						
						end
						
					end
				
				end
			
			end
		
		endcase
		
	end
	
	assign sonuc = sonuc_;

endmodule

