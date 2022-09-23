SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_PurgeSkyBitzTTITables]
       @NumberOfDays int = NULL
as
/*

	Purpose: This procedure will purge old records from the tables related to the SkyBitz Poller
	Tables: tti_gls_sensor and tti_gls_data
	PTS 53306 - JAT
	Date: 07/26/2011
	-- Skybitz stores its data in tables begining
	--   with tti_ (tti_gls_data, tti_gls_sensor).
	-- This routine will purge the tables back the number
	-- of days entered as the single parameter of the proc
	-- 
	-- Only delete 10,000 rows max from each of the
	--  tables if there are more than 10,000
	--  indicated for delete

*/

SET NOCOUNT ON

Declare @numberOfSensorRows int
Declare @numberOfDataRows int
IF EXISTS 
	(	
		SELECT * 
		FROM sys.objects 
		WHERE object_id = OBJECT_ID(N'[dbo].[tti_gls_sensor]')
	)
	and
	(
		@NumberOfDays >= 7
	)
begin
	-- Get the number of records that could be deleted
	select @numberOfSensorRows = COUNT(*)
	from dbo.tti_gls_sensor (NOLOCK)
	where DateDiff(day,DTCreated,CURRENT_TIMESTAMP) > @NumberOfDays
			
	select @numberOfSensorRows as TotalNumberOfRowsElegible
	
	if (@numberOfSensorRows <= 10000)
		-- There are less than 10,000 rows identified to be deleted
		BEGIN
		SELECT Convert(varchar,@numberOfSensorRows) +':rows purged from tti_gls_sensor'
			delete from dbo.tti_gls_sensor
				where DateDiff(day,DTCreated,CURRENT_TIMESTAMP) > @NumberOfDays
		END
	ELSE
		BEGIN
		-- There are More than 10,000 rows identified to be deleted
		-- only delete 10,000 of the records at a time if there are more than 10,000
			SELECT 'Limited purge from "tti_gls_sensor" of 10,000 records'
			delete from tti_gls_sensor
				where GlsSN in	(
									select top 10000 GlsSN
										from tti_gls_sensor (NOLOCK)
											where DateDiff(day,DTCreated,CURRENT_TIMESTAMP) > @NumberOfDays
											order by DTCreated desc
								)
		END
end
-- 
-- Purge tti_gls_data
-- 
IF EXISTS
	(
		SELECT * 
		FROM sys.objects 
		WHERE object_id = OBJECT_ID(N'[dbo].[tti_gls_data]')
	)
	and
	(
		@NumberOfDays >= 7
	)
BEGIN
	-- Get the number of records that could be deleted
	select @numberOfDataRows = COUNT(*)
		from dbo.tti_gls_data
			where DateDiff(day,DTCreated,CURRENT_TIMESTAMP) > @NumberOfDays
	IF (@numberOfDataRows <= 10000)
		BEGIN
		SELECT CONVERT(varchar,@numberOfDataRows) + ':rows purged from tti_gls_data'
			-- There are less than 10,000 rows identified to be deleted
			delete from dbo.tti_gls_data
				where DateDiff(day,DTCreated,CURRENT_TIMESTAMP) > @NumberOfDays
		END
	ELSE
		BEGIN
		-- There are More than 10,000 rows identified to be deleted
		-- only delete 10,000 of the records at a time if there are more than 10,000
		SELECT 'Limited purge from [tti_gls_data] of 10,000 records'
			delete from tti_gls_data
				where SN in	(
									select top 10000 SN
										from tti_gls_data (NOLOCK)
											where DateDiff(day,DTCreated,CURRENT_TIMESTAMP) > @NumberOfDays
											order by DTCreated desc
								)
		END
END
GO
GRANT EXECUTE ON  [dbo].[tm_PurgeSkyBitzTTITables] TO [public]
GO
