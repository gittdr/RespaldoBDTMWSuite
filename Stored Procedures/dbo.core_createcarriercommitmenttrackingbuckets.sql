SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_createcarriercommitmenttrackingbuckets] (@carrierlanecommitmentid INTEGER,
                                                                  @thedate                 DATETIME)
AS
DECLARE @CommitmentNumber INTEGER,
        @CommitmentPeriod VARCHAR(50),
        @EffectiveDate    DATETIME,
        @ExpiresDate      DATETIME,
        @StartDate        DATETIME,
        @NextStartDate    DATETIME,
        @BasePerDay       INTEGER,
        @Remainder        INTEGER,
        @count            SMALLINT

CREATE TABLE #tempdatebucket (
   tdb_id	INTEGER IDENTITY(0, 1),
   bucketdate	DATETIME
)

CREATE TABLE #tempcommitmentbucket (
   bucketnumber	INTEGER,
   needstarget	INTEGER,
   bucketdate	DATETIME
)

CREATE TABLE #temptargetbucket (
   targetnumber INTEGER IDENTITY(0, 1),
   bucketdate   DATETIME
)

SELECT @commitmentnumber = clc.commitmentnumber,
       @commitmentperiod = clc.commitmentperiod,
       @effectivedate = clc.effectivedate,
       @expiresdate = clc.expiresdate
  FROM core_carrierlanecommitment clc
 WHERE clc.carrierlanecommitmentid = @carrierlanecommitmentid

-- Get the start date of the period
-- The number produced by the weekday (dw) datepart depends on the value set by SET DATEFIRST, which sets the first day of the week.
-- See: http://msdn2.microsoft.com/en-us/library/aa258265(SQL.80).aspx
IF @commitmentperiod = 'W'
   SET @startdate = DATEADD(DAY, 1 - DATEPART(DW, @thedate), @thedate)
IF @commitmentperiod = 'M'
   SET @startdate = CAST(CAST(YEAR(@thedate) AS VARCHAR) + '-' + CAST(MONTH(@thedate) AS VARCHAR) + '-1' AS DATETIME)

-- Make sure we got a valid commitment period
IF @startdate IS NULL
BEGIN
   RAISERROR ('Unknown commitment period creating daily commitment-tracking buckets', 12, 1)
   GOTO EndProc
END

-- Get the start date of the next period
IF @commitmentperiod = 'W'
   SET @nextstartdate = DATEADD(DAY, 7, @startdate)
IF @commitmentperiod = 'M'
   SET @nextstartdate = DATEADD(MONTH, 1, @startdate)

SET @count = 0
WHILE @count <= 30
BEGIN
   INSERT INTO #tempdatebucket (bucketdate)
                      VALUES (DATEADD(DAY, @count, @startdate))
   SET @count = @count + 1
END

-- Now remove invalid days and identify buckets which need targets
INSERT INTO #tempcommitmentbucket
   SELECT tdb_id,
          CASE
             WHEN ((DATEPART(WEEKDAY, bucketdate) = 1 OR DATEPART(WEEKDAY, bucketdate) = 7)) THEN 0
             ELSE 1
          END,
          bucketdate
     FROM #tempdatebucket
    WHERE bucketdate >= @startdate AND
          bucketdate < @nextstartdate AND
          bucketdate >= @effectivedate AND
          bucketdate <= @expiresdate

DROP TABLE #tempdatebucket

-- Get and number the buckets requiring targets
INSERT INTO #temptargetbucket (bucketdate)
   SELECT bucketdate
     FROM #tempcommitmentbucket
    WHERE needstarget > 0

-- Get the target per-day amount, and the number of remainder days
SELECT @baseperday = @commitmentnumber / SUM(needstarget) 
  FROM #tempcommitmentbucket

SELECT @remainder = @commitmentnumber % SUM(needstarget)
  FROm #tempcommitmentbucket

-- Ensure the buckets don't already exist
IF EXISTS (SELECT *
             FROM core_carriercommitmentbuckets
            WHERE carrierlanecommitmentid = @carrierlanecommitmentid AND
                  ccb_date >= @startdate AND
                  ccb_date < @nextstartdate)
BEGIN
   DROP TABLE #tempcommitmentbucket
   DROP TABLE #temptargetbucket
   GOTO EndProc
END

-- Add 'em to the bucket table
INSERT INTO dbo.core_carriercommitmentbuckets
   SELECT @carrierlanecommitmentid,
          tcb.bucketdate,
          0,
          0,
          CASE
             WHEN ttb.targetnumber + 1 <= @remainder THEN @baseperday + 1
             ELSE @baseperday
          END * tcb.needstarget
     FROM #tempcommitmentbucket tcb LEFT JOIN #temptargetbucket ttb ON tcb.bucketdate = ttb.bucketdate

DROP TABLE #tempcommitmentbucket
DROP TABLE #temptargetbucket

EndProc:

GO
GRANT EXECUTE ON  [dbo].[core_createcarriercommitmenttrackingbuckets] TO [public]
GO
