SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create FUNCTION [dbo].[fnc_TMWRN_GetEstTripTime] 
	(
		@DateStart datetime,
		@DateEnd datetime,
		@TotalMiles float,
		@StopCount float = 2.0,
		@Tractor varchar(8),
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
			@CalcSpeed float

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
	Select @ActualTime = Round((Round(Cast(@DateEnd - @DateStart as Float),2)+@RoundingFactor)*(10/@MinDayBlock),-1)/(10/@MinDayBlock)

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
			If DatePart(dw,@DateEnd) < DatePart(dw,@DateStart)
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
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_GetEstTripTime] TO [public]
GO
