SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*****************************************************************************
!!!!!!!! ATTENTION!!!!!!!

There is another copy of this stored proc checked into the TMWSuite VSS db.

MAKE SURE TO MODIFY BOTH VERSIONS TO KEEP IN SYNCH AND CHECK INTO VSS.

NEVER ALTER ONLY ONE VERSION AND CHECK INTO VSS.
!!!!!!!! ATTENTION!!!!!!!
*****************************************************************************/

CREATE PROCEDURE [dbo].[tmail_mergedatetime] (@datefield varchar(30), @timefield varchar(30), @Result datetime out, @RefDate datetime = NULL, @ErrText varchar(254) = NULL OUT )

AS

SET NOCOUNT ON
	
	DECLARE @WorkCount int, @WorkDay datetime
	-- Can parse legal datetimes in either field, or legal date in date field and legal time
	-- in time field.  If both fields individually are valid dates, but they are not 
	-- together, then a legal datetime will be built from the date portion of datefield, 
	-- and the time portion of timefield.
	SELECT @datefield = isnull(@datefield, ''), @timefield = isnull(@timefield, ''), @RefDate = ISNULL(@RefDate, GETDATE())
	if isdate(@datefield + ' ' + @timefield) <> 0
		BEGIN
		SELECT @Result = CONVERT(datetime, @datefield + ' ' + @timefield)
		END
	else if isdate(@datefield) <> 0 and isdate(@timefield) <> 0
		BEGIN
		SELECT @WorkCount = DATEDIFF(dd, '20000101', @datefield)
		SELECT @Result = DATEADD(dd, @WorkCount, '20000101')
		SELECT @WorkCount = DATEDIFF(dd, '20000101', @timefield)
		SELECT @WorkDay = DATEADD(dd, @WorkCount, '20000101')
		SELECT @WorkCount = DATEDIFF(ss, @WorkDay, @timefield)
		SELECT @Result = DATEADD(ss, @WorkCount, @Result)
		END
	ELSE
		BEGIN
		IF @ErrText IS NULL
			BEGIN
			RAISERROR ('(TMWERROR:999)Bad Date/Time: %s/%s', 16, 1, @datefield, @timefield)
			RETURN
			END
		ELSE
			BEGIN
			SELECT @ErrText = '(TMWERROR:999)Bad Date/Time: ' + isnull(@datefield, '(null)') +'/' + isnull(@timefield, '(null)')
			RETURN
			END
		END
	if @Result < '19010101'
		BEGIN
		-- Looks like no date was provided, find closest time to given refdate.
		SELECT @WorkCount = DATEDIFF(dd, '19000101', @Result)
		SELECT @Result = DATEADD(dd, -@WorkCount, @Result)
		SELECT @WorkCount = DATEDIFF(dd, '19000101', @RefDate)
		SELECT @Result = DATEADD(dd, @WorkCount, @Result)
		SELECT @WorkCount = DATEDIFF(ss, @RefDate, @Result)
		IF @WorkCount < -43200 -- more than 1/2 day in the past, would be closer if we move it up a day.
			BEGIN
			SELECT @Result = DATEADD(dd, 1, @Result)
			END
		ELSE IF @WorkCount > 43200 -- more than 1/2 day in the future, would be closer if we move it back a day.
			BEGIN
			SELECT @Result = DATEADD(dd, -1, @Result)
			END
		END
GO
GRANT EXECUTE ON  [dbo].[tmail_mergedatetime] TO [public]
GO
