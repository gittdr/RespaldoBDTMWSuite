SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TotRevForMove]
(
	@MoveNumber int,
	@IncludeChargeTypeListOnly varchar(255),
	@ExcludeBillToIDList varchar(255)
)

--Revision History
--1. Added Currency Converting Logic Ver 5.4 LBK
 

RETURNS Money
AS
BEGIN

	Declare @LghMiles float
	Declare @MovMiles float
	Declare @PercentMilesThisSeg float
	Declare @OrdHdrnumber int
	Declare @OrdRev money
	Declare @CountLegHeaderNoMiles int

	Declare @AllocatedRev money
	Declare @IncludeChargesOnly money


	Set @IncludeChargeTypeListOnly= ',' + ISNULL(@IncludeChargeTypeListOnly,'') + ','
	Set @ExcludeBillToIDList = ',' + LTRIM(RTRIM(ISNULL(@ExcludeBillToIDList, ''))) + ','

			SET @IncludeChargesOnly =  
						ISNULL((SELECT SUM(ISNULL(dbo.fnc_convertcharge(
								id.ivd_charge, oh.ord_currency, 'Revenue', oh.ord_hdrnumber, oh.ord_currencydate, oh.ord_startdate, 
								ord_completiondate,default,default,default,default,default,default,default,default),0))
							FROM invoicedetail id (NOLOCK), orderheader oh (NOLOCK), chargetype (NOLOCK)
							WHERE oh.mov_number = @MoveNumber
								AND id.ord_hdrnumber = oh.ord_hdrnumber
								AND (@IncludeChargeTypeListOnly =',,' or (CHARINDEX(',' + RTRIM( id.cht_itemcode ) + ',', @IncludeChargeTypeListOnly) > 0))
								-- Don't add if @IncludeChargeTypeListOnly is blank.
								AND id.ivd_charge IS NOT NULL
								And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ord_billto ) + ',', @ExcludeBillToIDList) > 0)) 
								And ChargeType.cht_itemcode = Id.cht_itemcode
								And ChargeType.cht_basis = 'Acc'
						), 0)	 	
					



			--2000 and higher Currency Convert Code
			Set @OrdRev = (select convert(money,sum(IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0))) from InvoiceHeader(NOLOCK) where mov_number=@MoveNumber and ivh_invoicestatus <> 'CAN' And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) > 0)))

			if ( ISNULL(@OrdRev,0)=0)
			BEGIN
				--Set @OrdRev =(select sum(ord_charge) from Orderheader(NOLOCK) where mov_number=@MoveNumber and (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD' or orderheader.ord_status = 'ICO'))
        			--2000 and higher Currency Convert Code
				--Get the currency flag based on order number
				Set @OrdRev =(select convert(money,sum(IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))) from Orderheader(NOLOCK) where mov_number=@MoveNumber And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ord_billto ) + ',', @ExcludeBillToIDList) > 0)))
				--			Set @OrdRev =(select convert(money,sum(IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))) from Orderheader(NOLOCK) where mov_number=@MoveNumber and (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD' or orderheader.ord_status = 'ICO'
			END
			
			Set @OrdRev = (@OrdRev + @IncludeChargesOnly)

	Return @OrdRev


END

GO
GRANT EXECUTE ON  [dbo].[fnc_TotRevForMove] TO [public]
GO
