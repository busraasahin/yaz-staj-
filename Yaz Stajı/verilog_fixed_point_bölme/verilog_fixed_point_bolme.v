
module bolme(

	input clk,
	input signed [7:0] 		bolunen, 
	input signed [7:0] 		bolen, 
	output signed [15:0] 	kalan, 
	output signed [15:0] 	bolum	

    );
	

	reg signed [15:0] bolen_ = 0;
	reg signed [15:0] kalan_ = 0;
	reg signed [15:0] bolum_ = 0; // 16 bit olarak aldik cunku maximum bolum 16 bit'e kadar cikabiliyor (8/0.0125).
	reg [2:0] durum          = 3'b001; 
	reg [3:0] i              = 0;
	
	
	localparam POS_POS   =  3'b000;
	localparam POS_NEG   =  3'b010;
	localparam NEG_POS   =  3'b100;
	localparam NEG_NEG 	 =  3'b110;
	localparam DURUM_  	 =  3'b001;
	localparam ISLEM 	 =	3'b111;
	localparam FINISH    = 	3'b011;

	
	always @(posedge clk) begin

		case(durum)
		
			POS_POS: begin
				
				kalan_[7:0] 	= bolunen;
				bolen_[15:8] 	= bolen;
				durum 			<= 3'b111;
				
			end
			
			POS_NEG: begin
			
				kalan_[7:0] 	= bolunen;
				bolen_[15:8] 	= ~bolen + 1'b1;
				durum 			<= 3'b111;
				
			end
			
			NEG_POS: begin 
			
				bolen_[15:8] 	=  bolen;   
				kalan_[7:0] 	= ~bolunen  + 1'b1;	
				durum 			<= 3'b111;
				
			end
			
			NEG_NEG: begin
			
				bolen_[15:8] 	= (~bolen) + 1'b1;
				kalan_[7:0] 	= (~bolunen) + 1'b1;	
				durum 			<= 3'b111;
				
			end
				
			ISLEM: begin
					
				if (i < 9) begin
				
					kalan_ = kalan_ - bolen_;
					
					if (kalan_ < 0) begin
						
						kalan_ 		= kalan_ + bolen_;
						bolum_ 		= bolum_ << 1;
						bolum_[4] 	= 1'b0;
						bolen_		= bolen_ >> 1;
						i 			= i + 1;
						durum 		<= 3'b111;
						
					end
					
					
					else begin
						
						bolum_ 		= bolum_ << 1;
						bolum_[4] 	= 1'b1;
						bolen_		= bolen_ >> 1;
						i 			= i + 1;
						durum 		<= 3'b111;
						
					end					
				
				end
				
				else if (i == 9) begin
				
					if (bolunen[7] == 0 && bolen[7] == 0) begin //pos-pos olunca bir sey yapmamiza gerek yok
					
						//
			
					end
					
					else begin
					
						if (bolen[7] == 1 && bolunen[7] == 0) begin // pos-neg olunca yapilacak, biz basta two's complement aldigimiz 
																	// icin pos-pos bolme isleminden sonra pos-neg'e cevirmek icin bolum'un two's complementini almak yeterli.
																	// (ornekler uzerinden cikardigimiz formul)
							bolum_ = ~bolum_ + 1'b1;
							durum <= FINISH;
							
						end
						
						else if (bolen[7] == 0 && bolunen[7] == 1) begin // yine biz pos-pos durumunda bolmeyi yaptigimiz icin (two's complementini aldik neg sayinin)
																		 // bunu pos-neg bolmeye cevirmek icin bolum 1 artirilir ve sonra two's complementi alinir.
																		 // daha sonra kalan yazmacina bolen - kalan_ sonucu aktarilir ve bos duruma gecilir.
																		 // (ornekler uzerinden cikardigimiz formul)
							
							bolum_ 	= bolum_ + 8'b00010000;	
							bolum_ 	= ~bolum_ + 8'b00000001;
							kalan_ 	= bolen - kalan_;
							durum 	<= FINISH;
						
						end
						
						else if (bolen[7] == 1 && bolunen[7] == 1) begin // her iki sayi da neg-neg oldugundan dolayi yine basta two's complementini aldigimizdan 
																		 // pos-pos bolme yapacak (kalan ve bolum pos-pos bolmeye gore gelecek) x
																		 // biz bunu neg-neg durumuna cevirmek icin bolumu bir artirmak
																		 // kalan yazmacina bolen'in two's complementinden kalan yazmacinin cikarildigi sonucu atarsak dogru sonucu verir.
																		 // (ornekler uzerinden cikardigimiz formul)
																		 
							bolum_ 			= bolum_ + 8'b00010000;
							kalan_ 			= (~(bolen) + 8'b00000001) - kalan_;
							kalan_[15:8] 	= 1'b0; // burda bunu yapmamizin sebebi yukaridaki islemde 8 bitten 16 biti cikarinca genisletme bitini 1 olarak aliyor.biz burda 0 yapiyoruz.
							durum 			<= FINISH;

						end
					
					end
				
				end
				
			end
			
			DURUM_: begin
			
				durum = {bolunen[7], bolen[7], 1'b0};
			
			end
			
			FINISH: begin
			
				//
			
			end
	
		endcase
	
	end
	
	assign bolum = bolum_;
	assign kalan = kalan_;

endmodule

// kalan_'in radix'i 4 olarak alinir cunku eger 8 alirsak sayiyi kesirli olarak goruyor ve yanlis cevabi veriyor. kalan_ = [0000_0000][0011_0000]
