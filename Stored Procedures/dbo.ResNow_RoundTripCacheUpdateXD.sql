SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[ResNow_RoundTripCacheUpdateXD]

AS

/*
This stored procedure runs the cache build and measurement backfill procs
*/

	--Standard Setting
	SET NOCOUNT ON

	Declare @NextRTDefinition varchar(255)
	Declare @DateStart datetime
	Declare @DateEnd datetime
	Declare @BackFillDays int

	Select @BackFillDays = SettingValue 
	from MetricGeneralSettings
	Where SettingName = 'OvernightBackfillDays'

	Set @NextRTDefinition = ''
	Set @DateStart = DateAdd(d,-9,GetDate())
	Set @DateEnd = DateAdd(d,1,GetDate())


	While NOT @NextRTDefinition is NULL
		Begin
			Select @NextRTDefinition = Min(rt_DefName)
			From Metric_RTDefinitions
			Where rt_DefName > @NextRTDefinition

			If NOT @NextRTDefinition is NULL
				Begin
					Print 'Doing ... ' + @NextRTDefinition + ' Cache Update ' + Convert(Varchar,GetDate(),120)
					Exec dbo.ResNow_RoundTripCacheBuildXD @NextRTDefinition, @DateStart, @DateEnd
					Print 'Doing ... ' + @NextRTDefinition + ' Cache Backfill ' + Convert(Varchar,GetDate(),120)
					Exec dbo.ResNow_RoundTripCacheBackfillXD @NextRTDefinition, @BackFillDays
				End
		End
GO
GRANT EXECUTE ON  [dbo].[ResNow_RoundTripCacheUpdateXD] TO [public]
GO
