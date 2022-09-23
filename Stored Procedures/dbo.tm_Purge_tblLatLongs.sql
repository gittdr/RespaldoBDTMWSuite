SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Purge_tblLatLongs]   @DaysToKeep int, 
					@MinPerUnit int
AS

SET NOCOUNT ON

DECLARE @DelDate datetime,
		@LoopId int,
		@MinDate datetime,
		@NbrCheckcalls int,
		@TempDelDate datetime

/**** FOR TEST ONLY ****
DECLARE @DaysToKeep int,
		@MinPerUnit int

SET @DaysToKeep = 5
SET @MinPerUnit = 5
 **** FOR TEST ONLY ****/



SELECT @DelDate = GETDATE() - @DaysToKeep

CREATE TABLE #TempDate (tmpDate datetime)

IF @MinPerUnit <= 0	
	-- Simple case, just delete to date
	DELETE tblLatlongs	
	WHERE DateAndTime <= @DelDate
ELSE
  BEGIN
	-- Process checkcalls, keeping at least @MinPerUnit checkcalls per unit.
	SELECT @LoopId = ISNULL(MIN(Unit),-1)
	FROM tblLatlongs (NOLOCK)

	WHILE @LoopId <> -1
	  BEGIN
		-- Get the date of the record @MinPerUnit from the last
		DELETE #TempDate

		INSERT INTO #TempDate (tmpDate)	EXECUTE dbo.tm_Purge_tblLatLongs_Help @LoopId, @MinPerUnit


		-- Get the earliest day from this group of checkcalls
		SELECT @MinDate = ISNULL(MIN(tmpDate), '20491231')
		FROM #TempDate 

		SELECT @TempDelDate = @DelDate

		IF @MinDate < @DelDate
			SELECT @TempDelDate = @MinDate

		-- Now do the actual deletion of checkcalls
		DELETE tblLatlongs
		WHERE Unit = @LoopId
		  AND DateAndTime < @TempDelDate

		-- Get next tractor to process
		SELECT @LoopId = ISNULL(MIN(Unit),-1)
		FROM tblLatlongs (NOLOCK)
		WHERE Unit > @LoopId	
	  END
  END	-- If not simple case (No @MinPerUnit)
GO
