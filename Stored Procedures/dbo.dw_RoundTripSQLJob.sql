SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 3

CREATE PROCEDURE [dbo].[dw_RoundTripSQLJob]

AS

/*
This stored procedure runs the cache build procs
*/

	--Standard Setting
	SET NOCOUNT ON

	Declare @NextRTDefinition varchar(255)
	Declare @DateStart datetime
	Declare @DateEnd datetime
	Declare @DaysToProcessRange int
	Declare @DaysToClear int


	Set @NextRTDefinition = ''
/*
	select @DaysToClear = DateDiff(d,min(rt_StartDate),GetDate()) + 2
	from DW_RTLegCache
	where rt_Status = 'InProcess'

	Set @DaysToProcessRange = @DaysToClear + 2

	Set @DateStart = DateAdd(d,-@DaysToProcessRange,Convert(datetime,Ceiling(Convert(float,GetDate()))))
	Set @DateEnd = Convert(datetime,Ceiling(Convert(float,GetDate())))
*/

	While NOT @NextRTDefinition is NULL
		Begin
			Select @NextRTDefinition = Min(rt_DefName)
			From DW_RTDefinitions
			Where rt_DefName > @NextRTDefinition
			AND rt_Active = 1

			Set @DaysToProcessRange =	
				(
					Select rt_MaxTimeFrameInDays 
					from DW_RTDefinitions 
					Where rt_DefName = @NextRTDefinition
				)
										
			Set @DaysToProcessRange = @DaysToProcessRange + 5	-- extra buffer to span long weekends

			Set @DateStart = DateAdd(d,-@DaysToProcessRange,Convert(datetime,Floor(Convert(float,GetDate()))))
			Set @DateEnd = Convert(datetime,Ceiling(Convert(float,GetDate())))

			If NOT @NextRTDefinition is NULL
				Begin
--					Print 'Clearing recent data ... ' + @NextRTDefinition + Convert(Varchar,GetDate(),120)
--					Delete from DW_RTLegCache Where rt_DefName = @NextRTDefinition AND rt_EndDate > DateAdd(d,-@DaysToClear,@DateEnd)
					Print 'Doing ... ' + @NextRTDefinition + ' Cache Update ' + Convert(Varchar,GetDate(),120)
					Exec dbo.dw_RoundTripCacheBuild @NextRTDefinition, @DateStart, @DateEnd
				End
		End

GO
GRANT EXECUTE ON  [dbo].[dw_RoundTripSQLJob] TO [public]
GO
