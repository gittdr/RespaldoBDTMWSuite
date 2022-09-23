SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE                   FUNCTION [dbo].[TMWSSRS_fnc_allocatedTotFuelRevByMiles]
	(@lgh_number int)

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


Set @IncludeAllOrderStatuses = 'TRUE'--IsNull((select gi_value from MR_GeneralInfo where gi_key = 'IncludeAllOrderStatusesRevVsPayReportWizard'),'False')

Set @LghMiles=
	ISNULL(
		(Select Sum(IsNull(Case When stp_lgh_mileage < 0 Then 0 Else stp_lgh_mileage End,0))
		From Stops WITH (NOLOCK)
		where 
			stops.lgh_number=@lgh_number
		)
	,0)
Set @MoveNumber =(Select mov_number from legheader WITH (NOLOCK) where lgh_number=@lgh_number)

Set @CountLegHeaderNoMiles = (select count(distinct CountLegHeadersNoMiles.lgh_number)

	from (

		select   lgh_number
		from     stops 
		where    @MoveNumber = stops.mov_number
		group by stops.lgh_number
		having   IsNull(sum(IsNull(Case When stp_lgh_mileage < 0 Then 0 Else stp_lgh_mileage End,0)),0) = 0 


     	      ) as CountLegHeadersNoMiles)


Set @MovMiles =
	IsNull((Select Sum(IsNull(Case When stp_lgh_mileage < 0 Then 0 Else stp_lgh_mileage End,0))
	From Stops WITH (NOLOCK)
	where 
		stops.mov_number=@MoveNumber
	),0)

--Adds 25 miles per legheader if they are zero 
If (@CountLegHeaderNoMiles > 0)
Begin
	Set @MovMiles = (@MovMiles + (25 * @CountLegHeaderNoMiles))
End

--Set LegHeader 25 miles so we can allocate some revenue 
--back to the driver,tractor or trip segment
If (@LghMiles = 0) 
Begin
	Set @LghMiles = 25
End

Set @PercentMilesThisSeg =0


IF (@MovMiles>0)
BEGIN
	Set @PercentMilesThisSeg =
		@LghMiles/@MovMiles
END 
Set @MoveNumber =(Select mov_number from legheader WITH (NOLOCK) where lgh_number=@lgh_number)		
--Set @OrdRev =(select sum(ivh_totalcharge) from Invoiceheader WITH (NOLOCK) where mov_number=@MoveNumber and ivh_invoicestatus <> 'CAN')

Set @OrdRev = (
			--BASE LEVEL SQL
                        --SELECT  isNull(sum(ivd_charge),0.00)
			
                        --SQL 2000 or higher SQL
			SELECT 	convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',ivd_number,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00)))	

			FROM 
				Invoiceheader
				join invoicedetail on Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
				join chargetype on invoicedetail.cht_itemcode=chargetype.cht_itemcode
			WHERE 
				Invoiceheader.mov_number =@MoveNumber
				And
				(invoiceheader.ivh_invoicestatus <> 'CAN')
								
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
	--Set @OrdRev =(select sum(ord_totalcharge) from Orderheader WITH (NOLOCK) where mov_number=@MoveNumber and (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD'))
	Set @OrdRev = 
	(	SELECT  --BASE LEVEL SQL 
                        --isNull(sum(ivd_charge),0.00)
				
		        --SQL 2000 or higher SQL
			convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00)))	
		       
			FROM 	orderheader
				join invoicedetail on invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber
				join chargetype on 	invoicedetail.cht_itemcode=chargetype.cht_itemcode
			WHERE 
				orderheader.mov_number = @MoveNumber
				And
				(
				  (@IncludeAllOrderStatuses = 'True' And ord_status <> 'CAN')
				  OR
				  (@IncludeAllOrderStatuses = 'False' And (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD' or orderheader.ord_status = 'ICO'))
				 )
			      
				
				
				--not exists (select * from invoiceheader where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
				--AND
				
				
				/*Bkeeton 10/29/2002 Changed And To Or  */
			
				AND 
				(
					Upper(chargetype.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
				)
				and ivd_charge is Not Null
		)
			
	
END


Set  @AllocatedRev = @OrdRev * @PercentMilesThisSeg
Return @AllocatedRev


END




GO
GRANT EXECUTE ON  [dbo].[TMWSSRS_fnc_allocatedTotFuelRevByMiles] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWSSRS_fnc_allocatedTotFuelRevByMiles] TO [public]
GO
