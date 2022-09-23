SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE                   FUNCTION [dbo].[fnc_TotFuelSurchargeForOrder]
	(@ord_hdrnumber int)

RETURNS Money
AS
BEGIN

Declare @LghMiles float
Declare @MovMiles float
Declare @MoveNumber Int
Declare @PercentMilesThisSeg float
Declare @OrdHdrnumber int
Declare @OrdRev money
Declare @CountLegHeaderNoMiles int
Declare @IncludeAllOrderStatuses varchar(10)

Declare @AllocatedRev money


Set @IncludeAllOrderStatuses = IsNull((select gi_value from MR_GeneralInfo where gi_key = 'IncludeAllOrderStatusesRevVsPayReportWizard'),'False')

Set @OrdRev = (
			--BASE LEVEL SQL
                        --SELECT  isNull(sum(ivd_charge),0.00)
			
                        --SQL 2000 or higher SQL
			SELECT 	convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',ivd_number,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00)))	

			FROM 
				Invoiceheader,
				invoicedetail, 
				chargetype
			WHERE 
				Invoiceheader.ord_hdrnumber = @ord_hdrnumber
				And
				(invoiceheader.ivh_invoicestatus <> 'CAN')
				AND
				Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
				AND 
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				AND 
				(
					Upper(chargetype.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
				)
				and ivd_charge is Not Null
			)

       

if ( ISNULL(@OrdRev,0)=0)
BEGIN
	--Set @OrdRev =(select sum(ord_totalcharge) from Orderheader(NOLOCK) where mov_number=@MoveNumber and (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD'))
	Set @OrdRev = 
	(	SELECT  --BASE LEVEL SQL 
                        --isNull(sum(ivd_charge),0.00)
				
		        --SQL 2000 or higher SQL
			convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00)))	
		       
			FROM 	orderheader,
				invoicedetail, 
				chargetype
			WHERE 
				orderheader.ord_hdrnumber = @ord_hdrnumber
				And
				(
				  (@IncludeAllOrderStatuses = 'True' And ord_status <> 'CAN')
				  OR
				  (@IncludeAllOrderStatuses = 'False' And (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD' or orderheader.ord_status = 'ICO'))
				 )
			      
				And
				
				--not exists (select * from invoiceheader where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
				--AND
				invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber
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
			
	



END

Return @OrdRev


END



















GO
