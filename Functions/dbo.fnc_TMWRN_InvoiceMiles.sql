SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

Create FUNCTION [dbo].[fnc_TMWRN_InvoiceMiles]
(	
	@InvoiceHeaderNumber varchar(10) = Null,
	@OrderHeaderNumber varchar(10) = Null,
	@MoveNumber int = Null,
	@BillToID varchar(10) = Null,
	@LoadStatus varchar(255)='ALL',
	@StopStatusList varchar(255) = '',
	@BilledMilesOnly char(1)= 'N', --choices Y or N
	@NonBilledMilesOnly char(1) = 'N' --choices Y or N
)

RETURNS int
AS
BEGIN

	Declare @Miles int
	Declare @BilledMiles int
	Declare @TravelMiles int

	SELECT @StopStatusList = Case When Left(@StopStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@StopStatusList, ''))) + ',' Else @StopStatusList End

	--ONLY Give Miles to the First Invoice And Unique BillTo When going for billed miles on an order
	--ONLY Give Miles to the First Invoice When going for travel miles 
	If @OrderHeaderNumber <> 0 
		And @InvoiceHeaderNumber = 
			(
				select min(ivh_hdrnumber) 
				from  invoiceheader (NOLOCK) 
				where ivh_invoicestatus <> 'CAN' 
				and invoiceheader.ord_hdrnumber = @OrderHeaderNumber
				And 
					(
						(@BilledMilesOnly = 'Y' and ivh_billto = @BillToID) 
							Or 
						(@BilledMilesOnly = 'N')
					) 
			) 
		Begin
			If @BilledMilesOnly = 'Y' OR @NonBilledMilesOnly = 'Y'
				Begin
					Set @BilledMiles = ISNULL	(	(	Select Sum(IsNull(stp_ord_mileage,0))
		  												From Stops (NOLOCK)
														Where  
															(
																(@OrderHeaderNumber Is Not Null and stops.ord_hdrnumber = @OrderHeaderNumber)
																	Or
																(@MoveNumber Is Not Null and stops.mov_number = @MoveNumber)
															)
														And
			 												(
			   													(@LoadStatus = 'ALL')
        		   													Or
			   													(@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
		           													Or
																(@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
			 												 )
			 											And (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
													 ),0)

					If @BilledMilesOnly = 'N'	-- @BilledMilesOnly takes precedence; this is only reason to return @NonBilledMilesOnly
						Begin
							Set @TravelMiles = ISNULL	(	(	Select Sum(IsNull(stp_lgh_mileage,0))
		  														From Stops (NOLOCK)
																Where  stops.mov_number = @MoveNumber
																And
			 														(
			   															(@LoadStatus = 'ALL')
        		   															Or
			   															(@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
		           															Or
																		(@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
			 														 )
			 													And (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
															),0)
							Set @Miles = 
								Case When @TravelMiles >= @BilledMiles Then
									@TravelMiles - @BilledMiles
								Else
									0
								End
						End
					Else
						Begin
							Set @Miles = @BilledMiles
						End
				End
			Else	-- not worried about billable/unbillable
				Begin
					Set @Miles = ISNULL	(	(	Select Sum(IsNull(stp_lgh_mileage,0))
	  											From Stops (NOLOCK)
												Where  stops.mov_number = @MoveNumber
												And
		 											(
		   												(@LoadStatus = 'ALL')
    		   												Or
		   												(@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
	           												Or
														(@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
		 											 )
		 										And (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
											),0)
				End
		End

			--If it is a supplemental invoice then take miles 
			--as is on the Invoice (more then likely it will be 0)
	Else If @OrderHeaderNumber = 0 
		Begin
			Select @Miles = (select IsNull(ivh_totalmiles,0) from invoiceheader (NOLOCK) where ivh_invoicestatus <> 'CAN' and invoiceheader.ivh_hdrnumber = @InvoiceHeaderNumber)
		End
	Else --Any subsequent invoices for billto return zero so we don't duplicate		       
		Begin
			Select @Miles = 0 
		End


	Return @Miles


END


GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_InvoiceMiles] TO [public]
GO
