SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE                   FUNCTION [dbo].[fnc_TotFuelSurchargeForInvoice]
	(@ivh_hdrnumber int)

RETURNS Money
AS
BEGIN

Declare @OrdRev money

	--Set @OrdRev =(select sum(ord_totalcharge) from Orderheader(NOLOCK) where mov_number=@MoveNumber and (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD'))
	Set @OrdRev = 
	(	SELECT  --BASE LEVEL SQL 
                        --isNull(sum(ivd_charge),0.00)
				
		        --SQL 2000 or higher SQL
			convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',ivd_number,ivh_currencydate,ivh_shipdate,ivh_deliverydate,default,default,default,default,default,default,default,default),0.00)))	
		       
			FROM 	
				invoicedetail (NOLOCK), 
				invoiceheader (NOLOCK),
				chargetype (NOLOCK)
			WHERE 
				invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
				and
				invoicedetail.ivh_hdrnumber = @ivh_hdrnumber	
				And
				/*Bkeeton 10/29/2002 Changed And To Or  */
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				AND 
				(
					Upper(chargetype.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
				)
				and ivd_charge is Not Null
		)
			


Return @OrdRev


END



















GO
