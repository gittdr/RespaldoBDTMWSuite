SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  This function is a copy of fnc_allocatedTotOrdRevByMiles. It is needed for the Driver Management tab on Driver 
  Profile in TMW Operations. Since there is no guarantee that all clients will have fnc_allocatedTotOrdRevByMiles, 
  this copy was made so that all clients will have this function.

  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  ----------------------------------------
  05/09/2017   Cory Sellers     NSUITE-201262  Initial Release
  
********************************************************************************************************************/

CREATE FUNCTION [dbo].[udf_DRVMgmt_allocatedTotOrdRevByMiles]
	(@lgh_number int)

--Revision History
--1. Added Currency Converting Logic Ver 5.4 LBK
 

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
Declare @AllocatedRev money
Declare @targeted_currency varchar(200)
Declare @IncludeAllOrderStatuses varchar(10)

Set @IncludeAllOrderStatuses = 'False'--IsNull((select gi_value from MR_GeneralInfo where gi_key = 'IncludeAllOrderStatusesRevVsPayReportWizard'),'False')

Set @targeted_currency = 'None'--(select ses_value from MR_SessionID where ses_key = 'ActiveTargetedCurrency' and ses_SPID = @@SPID )




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

-- as 'Total Revenue',
IF (@MovMiles>0)
BEGIN
	Set @PercentMilesThisSeg =
		@LghMiles/@MovMiles
END 
Set @MoveNumber =(Select mov_number from legheader WITH (NOLOCK) where lgh_number=@lgh_number)		

--If the user has specified to convert to a currency
--then utilize the currency conversion code

--@targeted_currency = 'None' or 
If RTrim(@targeted_currency)='' Or @targeted_currency Is Null
Begin

	Set @OrdRev = IsNull((select sum(IsNull(ivh_totalcharge,0)) from Invoiceheader WITH (NOLOCK) where mov_number=@MoveNumber and ivh_invoicestatus <> 'CAN'),0)
	
End
Else
Begin
	--User must want currency conversion and taxes to be taken out
	Set @OrdRev = IsNull((select convert(money,sum(IsNull(dbo.udf_DRVMgmt_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0))) from InvoiceHeader WITH (NOLOCK) where mov_number=@MoveNumber and ivh_invoicestatus <> 'CAN'),0)

End


if ( ISNULL(@OrdRev,0)=0)
BEGIN

	If RTrim(@targeted_currency)='' Or @targeted_currency Is Null
	Begin
		Set @OrdRev =(select convert(money,sum(IsNull(ord_totalcharge,0))) from Orderheader WITH (NOLOCK) where mov_number=@MoveNumber and 
				(
				  (@IncludeAllOrderStatuses = 'True' And ord_status <> 'CAN')
				  OR
				  (@IncludeAllOrderStatuses = 'False' And (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD' or orderheader.ord_status = 'ICO'))
				)
			    )


	End
	Else
	Begin
		Set @OrdRev =(select convert(money,sum(IsNull(dbo.udf_DRVMgmt_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))) from Orderheader WITH (NOLOCK) where mov_number=@MoveNumber and 
				(
				  (@IncludeAllOrderStatuses = 'True' And ord_status <> 'CAN')
				  OR
				  (@IncludeAllOrderStatuses = 'False' And (ord_status = 'STD' or ord_status = 'CMP' or ord_status = 'PKD' or orderheader.ord_status = 'ICO'))
				)
			    )
	End

END
Set  @AllocatedRev = @OrdRev * @PercentMilesThisSeg
Return @AllocatedRev


END

GO
GRANT EXECUTE ON  [dbo].[udf_DRVMgmt_allocatedTotOrdRevByMiles] TO [public]
GO
