SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   Function [dbo].[fnc_TMWRN_FuelSurcharge] 
(
	@Mode varchar(255) = 'Order',
	@MilesToAllocate int = Null,
	@MoveMiles int = Null,
	@MoveNumber int = Null,
	@OrderHeaderNumber int = Null,
	@LegHeaderNumber int = Null,
	@InvoiceHeaderNumber int = Null
) 

Returns money 
As
Begin 

Declare @FuelSurcharge money
Declare @PercenttoAllocate float 
                   

If @Mode <> 'Invoice' 
Begin 



                        SELECT @FuelSurcharge =  
                                                        
                                IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)

                        FROM    invoicedetail (NOLOCK) Inner Join chargetype (NOLOCK) On invoicedetail.cht_itemcode=chargetype.cht_itemcode 

                                                       Inner Join orderheader (NOLOCK) On orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber 

                        WHERE 
                                ( 
                                   ((@Mode = 'Movement' or @Mode='LegHeader' or @Mode='Stops') And orderheader.mov_number = @MoveNumber And orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber )

                                    Or 
                                   (@Mode = 'Order' And invoicedetail.ord_hdrnumber = @OrderHeaderNumber)                 
                                )                                       
                                AND 
                                ( 
                                        Upper(chargetype.cht_itemcode) like 'FUEL%' 
                                        OR 
                                        CharIndex('FUEL', cht_description)>0 
                                ) 
                                and ivd_charge is Not Null 
End 
Else 
Begin --Must be Invoice Level join on getting Fuel Surcharge

                               SELECT @FuelSurcharge = 
                                IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
                                                        
                                

                        FROM    invoicedetail (NOLOCK) Inner Join chargetype (NOLOCK) On invoicedetail.cht_itemcode=chargetype.cht_itemcode 

                                                       Inner Join invoiceheader (NOLOCK) On invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 

                        WHERE 
                                ( 
                                 invoicedetail.ivh_hdrnumber = @InvoiceHeaderNumber 
                                )                                       
                                AND 
                                ( 
                                        Upper(chargetype.cht_itemcode) like 'FUEL%' 
                                        OR 
                                        CharIndex('FUEL', cht_description)>0 
                                )
                                and ivd_charge is Not Null 

End


--Allocate Fuel Surcharge back to the segment or a portion of a segment
If (@Mode = 'Segment' or @Mode = 'Stops') 
Begin 
                If @MilesToAllocate Is Null And @MoveMiles Is Null 
                        Begin 
				--We are adding 25 miles to all
				--zero mile legheaders (that way at least some revenue can be allocated back)                           
				Set @MilesToAllocate = dbo.TMWRN_LegHeaderMiles (@LegHeaderNumber,25)

				Set @MoveMiles = dbo.TMWRN_MoveMiles(@MoveNumber,default,25)
				
				
                        End             
                

		IF (@MoveMiles>0)
			BEGIN
				Set @PercentToAllocate =
					@MilesToAllocate/@MoveMiles
			END 

			Set @FuelSurcharge = @PercentToAllocate * @FuelSurcharge 


End 


Return @FuelSurcharge 

End                





GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_FuelSurcharge] TO [public]
GO
