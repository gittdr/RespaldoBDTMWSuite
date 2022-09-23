SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  FUNCTION [dbo].[TMWSSRS_fnc_allocatedTotOrdLineHaulRevByMiles]
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
		having   sum(IsNull(Case When stp_lgh_mileage < 0 Then 0 Else stp_lgh_mileage End,0)) = 0 


     	      ) as CountLegHeadersNoMiles)


Set @MovMiles =
	(Select Sum(IsNull(Case When stp_lgh_mileage < 0 Then 0 Else stp_lgh_mileage End,0))
	From Stops WITH (NOLOCK)
	where 
		stops.mov_number=@MoveNumber
	)

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
--Base Level Code
--Set @OrdRev =(select sum(ivh_charge) from Invoiceheader WITH (NOLOCK) where mov_number=@MoveNumber and ivh_invoicestatus <> 'CAN')

--2000 and higher Currency Convert Code
Set @OrdRev = (select convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0))) from InvoiceHeader WITH (NOLOCK) where mov_number=@MoveNumber and ivh_invoicestatus <> 'CAN')

if ( ISNULL(@OrdRev,0)=0)
BEGIN
	--Set @OrdRev =(select sum(ord_charge) from Orderheader WITH (NOLOCK) where mov_number=@MoveNumber and (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD' or orderheader.ord_status = 'ICO'))
        --2000 and higher Currency Convert Code
	--Get the currency flag based on order number
	Set @OrdRev =(select convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))) from Orderheader WITH (NOLOCK) where mov_number=@MoveNumber and 
				(
				  (@IncludeAllOrderStatuses = 'True' And ord_status <> 'CAN')
				  OR
				  (@IncludeAllOrderStatuses = 'False' And (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD' or orderheader.ord_status = 'ICO'))
				)
			    )
END
Set  @AllocatedRev = @OrdRev * @PercentMilesThisSeg
Return @AllocatedRev


END

GO
GRANT EXECUTE ON  [dbo].[TMWSSRS_fnc_allocatedTotOrdLineHaulRevByMiles] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWSSRS_fnc_allocatedTotOrdLineHaulRevByMiles] TO [public]
GO
