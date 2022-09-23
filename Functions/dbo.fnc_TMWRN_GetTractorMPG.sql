SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create FUNCTION [dbo].[fnc_TMWRN_GetTractorMPG] 
	(
		@Tractor varchar(8)	-- Tractor Number
	)
RETURNS float
AS

/*
This function returns an estimate of the miles per gallon for the supplied truck ID.

This function uses 
1. tractor mpg from tractorprofile masterfile 
OR
2. fuel purchases from the fuelpurchased table and miles from the stops table to calculate a MPG value 
OR
3. a default constant value of 5.5 mpg

There is also a High/Low Sanity Check.  If the calculated MPG is greater than 7.0 or less than 4.0 the function returns the default constant value of 5.5 MPG.
*/

BEGIN
	declare @MPG float,
			@DateStart datetime,
			@DateEnd datetime,
			@TotalMiles float,
			@TotalGallons float,
			@SanityCheckHigh float,
			@SanityCheckLow float

	set @TotalGallons = 0
	set @SanityCheckHigh = 7.0
	set @SanityCheckLow = 4.0

	If IsNull((Select trc_mpg from tractorprofile where trc_number = @Tractor),0) > 0
		begin
			Select @MPG = trc_mpg from tractorprofile where trc_number = @Tractor
		end
	Else
		begin
			select @TotalGallons = @TotalGallons + (fp_quantity * IsNull((select unc_factor from UnitConversion where unc_from = fp_uom AND unc_to = 'GAL'),1))
			from fuelpurchased
			where trc_number = @Tractor

			select @DateStart = IsNull(min(fp_date),'1950-1-1')
			from fuelpurchased
			where trc_number = @Tractor

			select @DateEnd = IsNull(max(fp_date),'2049-12-31')
			from fuelpurchased
			where trc_number = @Tractor

			select @TotalMiles = sum(stp_lgh_mileage)
			from stops join legheader on stops.lgh_number = legheader.lgh_number
			where lgh_startdate >= @DateStart
				AND lgh_enddate <= @DateEnd
				AND lgh_tractor = @Tractor
				AND NOT stp_lgh_mileage is NULL

			If	(IsNull(@TotalGallons,0) <= 0)
					OR
				(IsNull(@TotalMiles,0) <= 0)
					Select @MPG = 5.5
			Else
				Select @MPG = @TotalMiles / @TotalGallons

			
			If	(IsNull(@MPG,0) > @SanityCheckHigh) 
					OR 
				(IsNull(@MPG,0) < @SanityCheckLow)
					Select @MPG = 5.5

		end
	
	Return @MPG 
	
END

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_GetTractorMPG] TO [public]
GO
