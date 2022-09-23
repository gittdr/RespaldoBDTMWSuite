SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnc_TMWRN_GetEstLegTime] 
	(
		@LegNumber int = 0,
		@WorkHours float = 14.0,
		@MinDayBlock float = 0.5,
		@AvgSpeed float = 50.0,
		@PUP_DRP_Time float = 1.50,
		@WorkWeekend varchar(1) = 'N'
	)
RETURNS float
AS
BEGIN

	declare @TimeToRun float,
			@ActualTime float,
			@EstTime float,
			@RoundingFactor float,
			@CalcSpeed float,
			@DateStart datetime,
			@DateEnd datetime,
			@DateNextLegStart datetime,
			@TotalMiles float,
			@StopCount float,
			@Tractor varchar(8)

--	get leg information
	Select @DateStart = lgh_startdate
		,@DateEnd = lgh_enddate
		,@TotalMiles = IsNull((Select sum(stp_lgh_mileage) from stops where stops.lgh_number = @LegNumber),0)
		,@StopCount = IsNull((Select count(*) from stops where stops.lgh_number = @LegNumber AND (stp_type in ('PUP','DRP') OR stp_event in ('DLT','HLT'))),1)
		,@Tractor = lgh_tractor
		,@DateNextLegStart = IsNull((Select lgh_startdate from legheader L2 (NOLOCK) where L2.lgh_number = (Select NextLeg from vw_TMWRN_PrevNextLegs PNL (NOLOCK) where PNL.lgh_number = @LegNumber)),'1950-01-01 00:00:00.000')
	From legheader L1 (NOLOCK) where lgh_number = @LegNumber


-- set a rounding factor appropriate to the choice of minimum time block	
	If @MinDayBlock = 1
		Set @RoundingFactor = 0.499
	Else
	If @MinDayBlock = 0.5
		Set @RoundingFactor = 0.249
	Else
	If @MinDayBlock = 0.33
		Set @RoundingFactor = 0.1649
	Else
	If @MinDayBlock = 0.25
		Set @RoundingFactor = 0.1249
	Else
		begin
			set @MinDayBlock = 0.5
			Set @RoundingFactor = 0.249
		end

-- set an appropriate average speed
	If @TotalMiles > 30
		Set @CalcSpeed = Round(@TotalMiles / (((@TotalMiles - 30)/ @AvgSpeed)+1),0)
	Else
		Set @CalcSpeed = 30

-- Calculate times
--	Select @ActualTime = Round((Round(Cast(@DateEnd - @DateStart as Float),2)+@RoundingFactor)*(10/@MinDayBlock),-1)/(10/@MinDayBlock)
	Select @ActualTime = Round((Round(Cast(@DateNextLegStart - @DateStart as Float),2)+@RoundingFactor)*(10/@MinDayBlock),-1)/(10/@MinDayBlock)

	Select @EstTime = Round((Round((((@StopCount * @PUP_DRP_Time))+(@TotalMiles/@CalcSpeed))/@WorkHours,2)+@RoundingFactor)*(10/@MinDayBlock),-1)/(10/@MinDayBlock)

-- Set the Time to Run
	If @WorkWeekend = 'Y'
		Begin
			If @ActualTime > @EstTime 
				Set @TimeToRun = @ActualTime
			Else
				Set @TimeToRun = @EstTime
		End
	Else
		Begin
--			If DatePart(dw,@DateEnd) < DatePart(dw,@DateStart)
			If DatePart(dw,@DateNextLegStart) < DatePart(dw,@DateStart)
				Set @TimeToRun = @EstTime
			Else
				begin
					If @ActualTime > @EstTime
						Set @TimeToRun = @ActualTime
					Else
						Set @TimeToRun = @EstTime
				end			
		End

	If @Tractor = 'UNKNOWN'
		Set @TimeToRun = 1.0

	Return @TimeToRun 
	
END
GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_GetEstLegTime] TO [public]
GO
