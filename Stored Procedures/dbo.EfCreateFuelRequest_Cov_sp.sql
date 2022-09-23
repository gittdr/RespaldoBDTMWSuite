SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[EfCreateFuelRequest_Cov_sp] (@lgh_number as integer)
AS

/*	
*	PTS 59362- DJM - 10/4/2011 - Create geofuelrequestrecords for the proper trips
*	
*/
Declare @tractor	as	varchar(13),
	@driver			as	varchar(13),
	@trc_cmp		as	varchar(6),
	@drv_cmp		as	varchar(6)
	
	
	
	select @trc_cmp = legheader.trc_company 
	from legheader
	where legheader.lgh_number = @lgh_number
	
	select @drv_cmp = legheader.mpp_company
	from legheader
	where legheader.lgh_number = @lgh_number
	
	-- Create the request for the Proper Drivers.
	if @drv_cmp = '002' OR @drv_cmp = '001'
		exec create_fueloptrequest_sp @lgh_number

GO
GRANT EXECUTE ON  [dbo].[EfCreateFuelRequest_Cov_sp] TO [public]
GO
