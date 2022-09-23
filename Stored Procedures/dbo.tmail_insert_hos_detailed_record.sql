SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_insert_hos_detailed_record]	
		@DriverID			varchar(50),
		@CoDriverID			varchar(50),
		@StartTime			datetime,
		@Activity			int,
		@Duration			int,
		@Location			varchar(MAX),
		@Document			varchar(MAX),
		@TractorID			varchar(50),
		@TrailerID			varchar(50),
		@Confirmed			int,
		@Edit				varchar(1),
		@SensorFailure		int,
		@TimeZone			varchar(50),
		@UpdatedOn			datetime,
		@LocalStartTime		datetime,
		@LocalTimeZone		varchar(50)
AS

-- =============================================================================
-- Stored Proc: tmail_insert_hos_detailed_record
-- Author     :	Binghunaiem, Abdullah
-- Create date: 2016.01.13
-- Description:
--      Inserts a recrod into the QHOSDriverLogExportData and remove any duplicates.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      None										--
--
-- Revisions:
-- 01/13/2016 - Abdullah Binghunaiem - PTS 98061: Initial creation.
--
-- =============================================================================
BEGIN

-- Check not nullable parameters for nulls
IF @DriverID IS NULL
BEGIN
	RAISERROR (N'The parameter DriverID cannot be NULL in the stored proc tmail_insert_hos_detailed_record.',10, 1)
END

IF @StartTime IS NULL
BEGIN
	RAISERROR (N'The parameter StartTime cannot be NULL in the stored proc tmail_insert_hos_detailed_record.',10, 1)
END

IF @Activity IS NULL
BEGIN
	RAISERROR (N'The parameter Activity cannot be NULL in the stored proc tmail_insert_hos_detailed_record.',10, 1)
END

IF @Duration IS NULL
BEGIN
	RAISERROR (N'The parameter Duration cannot be NULL in the stored proc tmail_insert_hos_detailed_record.',10, 1)
END

IF @Edit IS NULL
BEGIN
	RAISERROR (N'The parameter Edit cannot be NULL in the stored proc tmail_insert_hos_detailed_record.',10, 1)
END

IF @TimeZone IS NULL
BEGIN
	RAISERROR (N'The parameter TimeZone cannot be NULL in the stored proc tmail_insert_hos_detailed_record.',10, 1)
END

IF @UpdatedOn IS NULL
BEGIN
	RAISERROR (N'The parameter UpdatedOn cannot be NULL in the stored proc tmail_insert_hos_detailed_record.',10, 1)
END

IF @LocalStartTime IS NULL
BEGIN
	RAISERROR (N'The parameter LocalStartTime cannot be NULL in the stored proc tmail_insert_hos_detailed_record.',10, 1)
END

IF @LocalTimeZone IS NULL
BEGIN
	RAISERROR (N'The parameter LocalTimeZone cannot be NULL in the stored proc tmail_insert_hos_detailed_record.',10, 1)
END

-- Let us not insert into the table if we already have the record in
IF NOT EXISTS
	(
		SELECT 1 FROM
			QHOSDriverLogExportData (NOLOCK)
		WHERE
			DriverID = @DriverID
			AND
			StartTime = @StartTime
			AND
			Activity = @Activity
	)
BEGIN
	INSERT INTO QHOSDriverLogExportData
		(
			DriverID,
			CoDriverID,
			StartTime,
			Activity,
			Duration,
			Location,
			Document,
			TractorID,
			TrailerID,
			Confirmed,
			Edit,
			SensorFailure,
			TimeZone,
			UpdatedOn,
			LocalStartTime,
			LocalTimeZone
		) 
		VALUES 
		(
			@DriverID,
			@CoDriverID,
			@StartTime,
			@Activity,
			@Duration,
			@Location,
			@Document,
			@TractorID,
			@TrailerID,
			@Confirmed,
			@Edit,
			@SensorFailure,
			@TimeZone,
			@UpdatedOn,
			@LocalStartTime,
			@LocalTimeZone
		)
	END
END
GO
GRANT EXECUTE ON  [dbo].[tmail_insert_hos_detailed_record] TO [public]
GO
