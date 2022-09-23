SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 01/03/01 MZ: Created to purge the checkcall table, keeping @DaysToKeep
		days of checkcalls and optionally (disable with -1) keeping at least @MinPerUnit
		checkcalls, even if earlier than the @DaysToKeep limit. 

   2/10/2016 JJN: Added to delete where UpdatedBy is 'TMAIL', 'QCTTAPP', 'QCApplication', 'QCCERAPP', 'QCTrailerTracks' and ckc_event is 'TRP'
*/

CREATE PROCEDURE [dbo].[tmail_purge_checkcalls]    @DaysToKeep int, 
					@MinPerUnit int
AS

SET NOCOUNT ON 

DECLARE @DelDate datetime,
	@LoopId varchar(20),
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
       DELETE checkcall
       WHERE ckc_date <= @DelDate
         AND ckc_updatedby IN ('TMAIL', 'QCTTAPP', 'QCApplication', 'QCCERAPP', 'QCTrailerTracks') --PTS88009 JJN - Add more types of Checkcall records to delete.
ELSE
  BEGIN
       -- First process tractor checkcalls
       SELECT @LoopId = ISNULL(MIN(ckc_tractor),'-1')
       FROM checkcall (NOLOCK)
       WHERE ckc_asgntype = 'DRV'
         AND ckc_event = 'TRP'
         AND ckc_updatedby IN ('TMAIL', 'QCTTAPP', 'QCApplication', 'QCCERAPP', 'QCTrailerTracks') --PTS88009 JJN - Add more types of Checkcall records to delete.

       WHILE @LoopId <> '-1'
         BEGIN
              -- Get the date of the record @MinPerUnit from the last
              DELETE #TempDate

              INSERT INTO #TempDate (tmpDate)   EXECUTE dbo.tmail_purge_checkcalls_Help @LoopID, @MinPerUnit, 0

              -- Get the earliest day from this group of checkcalls
              SELECT @MinDate = ISNULL(MIN(tmpDate), '20491231')
              FROM #TempDate 

              IF (@MinDate >= @DelDate)
                     SELECT @TempDelDate = @DelDate  -- Plenty of records, so delete to GetDate() - @DaysToKeep
              ELSE
                     SELECT @TempDelDate = @MinDate  -- Not enough checkcalls, so keep @MinPerUnit

              -- Now do the actual deletion of checkcalls
              DELETE checkcall
              WHERE ckc_tractor = @LoopId
                AND ckc_date < @TempDelDate
                AND ckc_asgntype = 'DRV'
                AND ckc_event = 'TRP'
                AND ckc_updatedby IN ('TMAIL', 'QCTTAPP', 'QCApplication', 'QCCERAPP', 'QCTrailerTracks') --PTS88009 JJN - Add more types of Checkcall records to delete.

              -- Get next tractor to process
              SELECT @LoopId = ISNULL(MIN(ckc_tractor),'-1')
              FROM checkcall (NOLOCK)
              WHERE ckc_asgntype = 'DRV'
                AND ckc_event = 'TRP'
                AND ckc_updatedby IN ('TMAIL', 'QCTTAPP', 'QCApplication', 'QCCERAPP', 'QCTrailerTracks') --PTS88009 JJN - Add more types of Checkcall records to delete.
                AND ckc_tractor > @LoopId 
         END

-- Now process trailer checkcalls 
       SELECT @LoopId = ISNULL(MIN(ckc_asgnid),'-1')
       FROM checkcall (NOLOCK)
       WHERE ckc_asgntype = 'TRL'
         AND ckc_event = 'TRL'
         AND ckc_updatedby IN ('TMAIL', 'QCTTAPP', 'QCApplication', 'QCCERAPP', 'QCTrailerTracks') --PTS88009 JJN - Add more types of Checkcall records to delete.

       WHILE @LoopId <> '-1'
         BEGIN
              -- Get the date of the record @MinPerUnit from the last
              DELETE #TempDate

              INSERT INTO #TempDate (tmpDate) EXECUTE dbo.tmail_purge_checkcalls_Help @LoopID, @MinPerUnit, 1

              -- Get the earliest day from this group of checkcalls
              SELECT @MinDate = ISNULL(MIN(tmpDate), '20491231')
              FROM #TempDate 

              IF (@MinDate >= @DelDate)
                     SELECT @TempDelDate = @DelDate  -- Plenty of records, so delete to GetDate() - @DaysToKeep
              ELSE
                     SELECT @TempDelDate = @MinDate  -- Not enough checkcalls, so keep @MinPerUnit

              -- Now do the actual deletion of checkcalls
              DELETE checkcall
              WHERE ckc_asgnid = @LoopId
                AND ckc_date < @TempDelDate
                AND ckc_asgntype = 'TRL'
                AND ckc_event = 'TRL'
                AND ckc_updatedby IN ('TMAIL', 'QCTTAPP', 'QCApplication', 'QCCERAPP', 'QCTrailerTracks') --PTS88009 JJN - Add more types of Checkcall records to delete.

              -- Get next trailer to process
              SELECT @LoopId = ISNULL(MIN(ckc_asgnid),'-1')
              FROM checkcall
              WHERE ckc_asgntype = 'TRL'
                AND ckc_event = 'TRL'
                AND ckc_updatedby IN ('TMAIL', 'QCTTAPP', 'QCApplication', 'QCCERAPP', 'QCTrailerTracks') --PTS88009 JJN - Add more types of Checkcall records to delete.
                AND ckc_asgnid > @LoopId
         END
  END  -- If not simple case (@MinPerUnit = -1)
GO
GRANT EXECUTE ON  [dbo].[tmail_purge_checkcalls] TO [public]
GO
