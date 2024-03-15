`timescale 1ns / 1ps

module floating(
input clk ,
input [31:0] bolunen , // A
input [31:0] bolen   , // B
output  [31:0] sonuc         
   );  

   reg [31:0] sonuc_x   ;
   reg [7:0] exp_a      ;
   reg [7:0] exp_b      ;
   reg [7:0] exp_sonuc  ;
   reg [7:0] exp_sonuc1;
   reg [23:0] mantissa_a = 24'b111111111111111111111111 ; // !!!!
   reg [23:0] mantissa_b = 24'b111111111111111111111111 ; // !!!!
   reg [24:0] mantissa_sonuc;
   
   reg [31:0] bolunenx ;
   reg [31:0] bolenx ;
   
   reg [31:0] NaN   =  31'b11111111_11111111111111111111111; 
   reg [30:0] inf   =  31'b11111111_00000000000000000000000;
   reg [31:0] sifir =  31'b00000000_00000000000000000000000;
   
   integer sayac = 0 ;
   reg sonuc_sign;
   reg [48:0] bolme_yazmaci= 49'b0_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000; //!!!
   reg [48:0] bolen_yazmaci=49'b0_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000; //!!!
   reg [48:0] bolen_yazmaci_tersi;
   
   
   integer count=0;
   
   localparam MANTISSA_ATAMA     = 4'b0000;
   localparam EXP_ATAMA          = 4'b0001;
   localparam OZEL_DURUMLAR      = 4'b0010;
   localparam YAZMAC_ATAMA       = 4'b0011;
   localparam BOLEN_TERSI_ALMA   = 4'b0100;
   localparam BOLME_1            = 4'b0101;
   localparam BOLME_2            = 4'b0110;
   localparam LSB_ATAMA          = 4'b0111;
   localparam YENI_BOLME_YAZMACI = 4'b1000;
   localparam SON_EXP            = 4'b1001;
   localparam SONUC_BIRLESTIRME  = 4'b1010;
   localparam VERILERI_ALMA      = 4'b1011;
   
   reg [7:0] durum = VERILERI_ALMA ;
   
   always@(posedge clk )begin  
        sayac <= sayac + 1; 
        case(durum)
           VERILERI_ALMA : begin
                bolenx = bolen;
                bolunenx = bolunen;
                durum <= MANTISSA_ATAMA;
           end
            
           MANTISSA_ATAMA: begin
                if ( (bolunenx !== 32'bx_xxxxxxxx_xxxxxxxxxxxxxxxxxxxxxxx) && (bolenx !== 32'bx_xxxxxxxx_xxxxxxxxxxxxxxxxxxxxxxx) )begin
                    exp_a             <=  bolunenx[30:23];
                    mantissa_a[22:0] <=  bolunenx[22:0];

                    exp_b      <=  bolenx[30:23];
                    mantissa_b[22:0] <=  bolenx[22:0];
                    
                    durum <= EXP_ATAMA ;
                end
           end
            
           EXP_ATAMA : begin    
                exp_sonuc <=  exp_a-exp_b;
                sonuc_sign   <=  bolenx[31] ^ bolunenx[31];  
                durum <= OZEL_DURUMLAR;  
           end
 
           OZEL_DURUMLAR: begin 
                if (bolenx[30:0] == sifir )begin //BÖLEN = 0
                    sonuc_x <= {sonuc_sign,NaN};
                end 
                else if ( ( bolenx[30:0] == inf) && ( bolunenx[30:0] == inf || bolunenx[30:0] == 0 ) )begin 
                     sonuc_x <= {sonuc_sign,NaN};
                end   
                else if((bolunenx[30:0] == inf) &&  ((bolenx[30:0] !=sifir) || (bolenx[30:0] != inf) ))begin  
                     sonuc_x <= {sonuc_sign,inf};   
                end
                else if ((bolunenx[30:0] != sifir && bolunenx[30:0] != inf )&& (bolenx[30:0] == inf)) begin 
                     sonuc_x <= {1'b0,sifir}; 
                end 
                else if ( bolunenx[30:0] == sifir && ((bolenx[30:0] !=sifir) || (bolenx[30:0] != inf)) ) begin
                    sonuc_x <= {1'b0,sifir};
                end
                else begin 
                     durum <= YAZMAC_ATAMA;
                end 
           end
            
           YAZMAC_ATAMA:begin
                bolme_yazmaci[23:0]<= mantissa_a;
                bolen_yazmaci[47:24]<= mantissa_b;
                durum <= BOLEN_TERSI_ALMA; 
           end
              
           BOLEN_TERSI_ALMA:begin
                bolen_yazmaci_tersi<= 0 - bolen_yazmaci;
                durum<=BOLME_1;
             end
            
           BOLME_1:begin 
               if(count<48) begin
                  bolme_yazmaci<=bolme_yazmaci<<1;
                  durum<= BOLME_2;
               end
               
               else begin
                  mantissa_sonuc[23:0]<= bolme_yazmaci[23:0];
                  count=0;
                  durum<=SON_EXP;
               end
               
               if(count==24) begin
                  mantissa_sonuc[24]<=bolme_yazmaci[0]; 
               end
           end  
             
           BOLME_2: begin
                    bolme_yazmaci<=bolme_yazmaci+bolen_yazmaci_tersi;
                    durum <= LSB_ATAMA;
                end
                
           LSB_ATAMA:begin    
                if (bolme_yazmaci[48]==1) begin    
                     bolme_yazmaci[0]<=1'b0; 
                     durum <= YENI_BOLME_YAZMACI;       
                end
                else begin
                     bolme_yazmaci[0]<=1'b1;
                     durum <= BOLME_1 ;
                end
                
                count = count+1;
           end
           
           YENI_BOLME_YAZMACI: begin
                bolme_yazmaci <= bolme_yazmaci + bolen_yazmaci; 
                durum <= BOLME_1;
           end
           
           SON_EXP:begin
              if(mantissa_sonuc[24]==0) begin
                  mantissa_sonuc=mantissa_sonuc<<1;
                  count=count+1;
              end
              else begin 
                //sonuc_x[22:0]  <= mantissa_sonuc[23:1];
                exp_sonuc1<=exp_sonuc-count+127; 
                durum <= SONUC_BIRLESTIRME;
              end
           end
            
           SONUC_BIRLESTIRME:begin  
               sonuc_x={sonuc_sign,exp_sonuc1,mantissa_sonuc[23:1]};
               durum <=12;
           end
            
           12:begin
               bolunenx = 32'bx_xxxxxxxx_xxxxxxxxxxxxxxxxxxxxxxx;
               bolenx = 32'bx_xxxxxxxx_xxxxxxxxxxxxxxxxxxxxxxx;
               count=0;
               mantissa_a = 24'b111111111111111111111111 ; // !!!!
               mantissa_b = 24'b111111111111111111111111 ; // !!!!
               bolme_yazmaci= 49'b0_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000; //!!!
               bolen_yazmaci=49'b0_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000; //!!!
               durum <= VERILERI_ALMA;
           end
         endcase   
   end
   assign sonuc=sonuc_x;
endmodule