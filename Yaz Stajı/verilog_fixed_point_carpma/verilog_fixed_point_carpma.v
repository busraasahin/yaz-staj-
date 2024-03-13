`timescale 1ns / 1ps

module multx(

	input signed  [7:0] carpilan,
	input signed  [7:0] carpan,
	input clk,
	output [15:0] sonuc2  
	
	);
  
	reg [7:0] durum = 0;
	reg [15:0] sonuc1;
	reg [15:0] sonuc = 0;
	integer  i = 0; // 
	integer  k = 0;
	
	//  carpilan 1011_0000
	// carpan    1101_0000
	

always @(posedge clk) begin  

    case(durum)
	
        0:begin
		
			if (carpan[i]==0) begin // carpanin i. bitinin sifir olmasi durumu
			
				durum<=1;
			
			end
			
			else begin // carpanin i. bitinin 1 olmasi durumu
			
				sonuc1 = carpilan;
				durum <= 2; // durum 2'ye gidilir
				
			end
			
		end
		
        1:begin // carpanin i. biti sifir durumu
	  
            if (i == 7) begin // carpanin son biti 0
		    
                //
			 	
            end
		    
            else begin // bit sifir oldugu icin sola kaydirma miktarini tasiyan i degerini arttirmak yeterli olacaktir. 
		    
                 i = i + 1;
                 durum <= 0;
			 	
            end
		   
        end
    
        2:begin // carpanin i. biti bir olma durumu
	  
			if (i == 7) begin // carpanin son biti bir
		  
				sonuc1 = ~sonuc1 + 1'b1; // carpanin son biti 1 oldugu icin son islemde two's complement alinir.
				durum <= 4;
			
			end
          
            else begin // carpanin son bitinden onceki bitlerin bir olmasi
		  
				k = i+7; // genisletmenin kacinci bitten baslayacak degeri
				sonuc1 = sonuc1 << i;
				durum<=3;
			
            end
			
		end 
        
        3:begin // case yapisiyla dongu yaparak k--15 arasi bitlerin atanmasi.
		
            if (k == 15) begin
		   
				i = i + 1;
				sonuc = sonuc1 + sonuc;
				durum <= 0;
			 
            end
			
            else begin
		   
				sonuc1[k+1] = sonuc1[k];
				k = k+1;
				durum <= 3;
			 
          end
			
        end 
          
        4:begin
		 
                sonuc1 = sonuc1 << i;
                durum <= 5;
			 
        end 
           
        5:begin
		
				sonuc1[15] = sonuc1[14];
				sonuc = sonuc1 + sonuc;
				durum <= 6;
			 
        end  
		6:begin
			//
		
		end	
           
    endcase 
    
    end
	
   assign sonuc2 = sonuc;
   
endmodule 
