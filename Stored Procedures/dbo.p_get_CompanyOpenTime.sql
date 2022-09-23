SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[p_get_CompanyOpenTime]
	@companyid	VARCHAR(8), 
	@tripdate	DATETIME ,
	@opendate	DATETIME OUTPUT,
	@closedate	DATETIME OUTPUT
AS
CREATE TABLE #temphours (
	windowday	VARCHAR(6),
	windowstart	DATETIME,
        windowend	DATETIME,
	windowsort	INTEGER
)
CREATE TABLE #tempweek (
	windowday	VARCHAR(6),
	beginday	SMALLINT,
	begindate	DATETIME,
	endday		SMALLINT,
	enddate		DATETIME
)

DECLARE @tripday	INTEGER,
        @triphours	INTEGER,
        @tripminutes	INTEGER,
        @stringdate	VARCHAR(20),
        @begindate	DATETIME,
        @enddate	DATETIME,
	@beginday	INTEGER,
	@endday		INTEGER,
	@previousday	INTEGER,
 	@windowday	VARCHAR(6),
        @windowstart	DATETIME,
        @windowend	DATETIME,
	@lastwindowday	VARCHAR(6),
	@counter	INTEGER

INSERT INTO #temphours (windowday, windowsort, windowstart, windowend)
   SELECT windowday,
          CASE windowday WHEN 'WEEK' THEN 1
                         WHEN 'MTWTF' THEN 2
                         WHEN 'SS' THEN 3
                         WHEN 'SUN' THEN 4
                         WHEN 'MON' THEN 5
                         WHEN 'TUE' THEN 6
                         WHEN 'WED' THEN 7
                         WHEN 'THU' THEN 8
                         WHEN 'FRI' THEN 9
                         WHEN 'SAT' THEN 10
          END,
          windowstart,
          windowend
     FROM company_hourswindow
    WHERE cmp_id = @CompanyID AND 
          WindowType = 'OPEN'

--If no company hours are on file, set genesis and apocalypse and return
IF (SELECT COUNT(*) FROM #temphours) = 0
BEGIN
   SET @opendate = '1950-01-01 00:00:00'
   SET @closedate = '2049-12-31 23:59:59'
   RETURN
END

--Cycle through all of the rows from the company_hourswindow table and 
--create a full weeks worth of open and close times. 
DECLARE createweek CURSOR FOR
   SELECT windowday, windowstart, windowend
     FROM #temphours
   ORDER BY windowsort, windowend

OPEN createweek

SET @lastwindowday = ''
FETCH NEXT FROM createweek INTO @windowday, @windowstart, @windowend

WHILE @@FETCH_STATUS = 0
BEGIN
   IF @windowday = 'WEEK'
   BEGIN 
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (1, @windowstart, 1, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (2, @windowstart, 2, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (3, @windowstart, 3, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (4, @windowstart, 4, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (5, @windowstart, 5, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (6, @windowstart, 6, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (7, @windowstart, 7, @windowend)
   END
 
   IF @windowday = 'MTWTF'
   BEGIN
      IF @windowday <> @lastwindowday AND @lastwindowday <> ''
      BEGIN
         DELETE FROM #tempweek
            WHERE beginday IN (2, 3, 4, 5, 6)
      END
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (2, @windowstart, 2, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (3, @windowstart, 3, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (4, @windowstart, 4, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (5, @windowstart, 5, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (6, @windowstart, 6, @windowend)
   END

   IF @windowday = 'SS' 
   BEGIN
      IF @windowday <> @lastwindowday AND @lastwindowday <> ''
      BEGIN
         DELETE FROM #tempweek
            WHERE beginday IN (7, 1)
      END
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (7, @windowstart, 7, @windowend)
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (1, @windowstart, 1, @windowend)
   END

   IF @windowday = 'SUN'
   BEGIN
      IF @windowday <> @lastwindowday AND @lastwindowday <> ''
      BEGIN
         DELETE FROM #tempweek
            WHERE beginday = 1
      END
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (1, @windowstart, 1, @windowend)
   END

   IF @windowday = 'MON'
   BEGIN
      IF @windowday <> @lastwindowday AND @lastwindowday <> ''
      BEGIN
         DELETE FROM #tempweek
            WHERE beginday = 2
      END
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (2, @windowstart, 2, @windowend)
   END

   IF @windowday = 'TUE'
   BEGIN
      IF @windowday <> @lastwindowday AND @lastwindowday <> ''
      BEGIN
         DELETE FROM #tempweek
            WHERE beginday = 3
      END
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (3, @windowstart, 3, @windowend)
   END

   IF @windowday = 'WED'
   BEGIN
      IF @windowday <> @lastwindowday AND @lastwindowday <> ''
      BEGIN
         DELETE FROM #tempweek
            WHERE beginday = 4
      END
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (4, @windowstart, 4, @windowend)
   END

   IF @windowday = 'THU'
   BEGIN
      IF @windowday <> @lastwindowday AND @lastwindowday <> ''
      BEGIN
         DELETE FROM #tempweek
            WHERE beginday = 5
      END
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (5, @windowstart, 5, @windowend)
   END

   IF @windowday = 'FRI'
   BEGIN
      IF @windowday <> @lastwindowday AND @lastwindowday <> ''
      BEGIN
         DELETE FROM #tempweek
            WHERE beginday = 6
      END
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (6, @windowstart, 6, @windowend)
   END

   IF @windowday = 'SAT'
   BEGIN
      IF @windowday <> @lastwindowday AND @lastwindowday <> ''
      BEGIN
         DELETE FROM #tempweek
            WHERE beginday = 7
      END
      INSERT INTO #tempweek (beginday, begindate, endday, enddate)
                     VALUES (7, @windowstart, 7, @windowend)
   END
   
   SET @lastwindowday = @windowday

   FETCH NEXT FROM createweek INTO @windowday, @windowstart, @windowend 

END

CLOSE createweek
DEALLOCATE createweek

-- If shift spans midnight, set the beginday to the previous day.
UPDATE #tempweek
   SET beginday = beginday - 1
 WHERE endday > 1 AND
       (DATEPART(hh, enddate) - DATEPART(hh, begindate)) < 0
UPDATE #tempweek
   SET beginday = 7
 WHERE endday = 1 AND
       (DATEPART(hh, enddate) - DATEPART(hh, begindate)) < 0

--Set working variables for finding the open/close times for this @tripdate
SET @tripday = DATEPART(dw, @tripdate)
IF @tripday > 1
   SET @previousday = @tripday - 1
IF @tripday = 1
   SET @previousday = 7
SET @triphours = DATEPART(hh, @tripdate)
SET @tripminutes = DATEPART(mi, @tripdate)
SET @stringdate = CONVERT(VARCHAR(20), @tripdate, 101)

--Look for a valid open and close time for this company on this date.
SELECT @begindate = begindate,
       @enddate = enddate,
       @beginday = beginday,
       @endday = endday
  FROM #tempweek
 WHERE (beginday = @tripday AND
        (@triphours > DATEPART(hh, begindate) OR (@triphours = DATEPART(hh, begindate) AND @tripminutes >= DATEPART(mi, begindate))) AND
        (@triphours < DATEPART(hh, enddate) OR (@triphours = DATEPART(hh, enddate) AND @tripminutes <= DATEPART(mi, enddate)))) OR
       (beginday = @previousday AND
        endday = @tripday AND
        (@triphours < DATEPART(hh, enddate) or (@triphours = DATEPART(hh, enddate) AND @tripminutes <= DATEPART(mi, enddate))))

IF @begindate IS NOT NULL
BEGIN
   IF DATEPART(hh, @begindate) < DATEPART(hh, @enddate) OR
     (DATEPART(hh, @begindate) = DATEPART(hh, @enddate) AND DATEPART(mi, @begindate) <= DATEPART(mi, @enddate))
   BEGIN
      SET @opendate = @stringdate + ' ' + CONVERT(VARCHAR(10), @begindate, 108)
      SET @closedate = @stringdate + ' ' + CONVERT(VARCHAR(10), @enddate, 108)
   END
   IF DATEPART(hh, @begindate) > DATEPART(hh, @enddate) OR 
     (DATEPART(hh, @begindate) = DATEPART(hh, @enddate) AND DATEPART(mi, @begindate) > DATEPART(mi, @enddate))
   BEGIN
      IF @beginday = @tripday
      BEGIN
         SET @opendate = @stringdate + ' ' + CONVERT(VARCHAR(10), @begindate, 108)
         SET @closedate = @stringdate + ' ' + CONVERT(VARCHAR(10), @enddate, 108)
         SET @closedate = DATEADD(dd, 1, @closedate)
      END
      IF @endday = @tripday
      BEGIN
         SET @opendate = @stringdate + ' ' + CONVERT(VARCHAR(10), @begindate, 108)
         SET @opendate = DATEADD(dd, -1, @opendate)
         SET @closedate = @stringdate + ' ' + CONVERT(VARCHAR(10), @enddate, 108)
      END
   END
      
   RETURN
END

-- No open time was found for the input trip date, find the next available open time.
SET @counter = 1
WHILE @counter <= 7
BEGIN
   IF @counter = 1
   BEGIN
      SELECT TOP 1 @begindate = begindate,
             @enddate = enddate,
             @beginday = beginday,
             @endday = endday
        FROM #tempweek
       WHERE beginday = @tripday AND
            (@triphours < DATEPART(hh, begindate) OR (@triphours = DATEPART(hh, begindate) AND @tripminutes < DATEPART(mi, begindate)))
      ORDER BY DATEPART(hh, begindate)

      IF @begindate IS NOT NULL
      BEGIN
         IF DATEPART(hh, @begindate) < DATEPART(hh, @enddate) OR
           (DATEPART(hh, @begindate) = DATEPART(hh, @enddate) AND DATEPART(mi, @begindate) <= DATEPART(mi, @enddate))
         BEGIN
            SET @opendate = @stringdate + ' ' + CONVERT(VARCHAR(10), @begindate, 108)
            SET @closedate = @stringdate + ' ' + CONVERT(VARCHAR(10), @enddate, 108)
            RETURN
         END
         IF DATEPART(hh, @begindate) > DATEPART(hh, @enddate) OR 
           (DATEPART(hh, @begindate) = DATEPART(hh, @enddate) AND DATEPART(mi, @begindate) > DATEPART(mi, @enddate))
         BEGIN
            SET @opendate = @stringdate + ' ' + CONVERT(VARCHAR(10), @begindate, 108)
            SET @closedate = @stringdate + ' ' + CONVERT(VARCHAR(10), @enddate, 108)
            SET @closedate = DATEADD(dd, 1, @closedate)
            RETURN
         END
      END
   END

   IF @counter > 1
   BEGIN
      SELECT TOP 1 @begindate = begindate,
             @enddate = enddate,
             @beginday = beginday,
             @endday = endday
        FROM #tempweek
       WHERE beginday = @tripday
      ORDER BY DATEPART(hh, begindate)
  
      IF @begindate IS NOT NULL
      BEGIN
         IF DATEPART(hh, @begindate) < DATEPART(hh, @enddate) OR
           (DATEPART(hh, @begindate) = DATEPART(hh, @enddate) AND DATEPART(mi, @begindate) <= DATEPART(mi, @enddate))
         BEGIN
            SET @opendate = @stringdate + ' ' + CONVERT(VARCHAR(10), @begindate, 108)
            SET @opendate = DATEADD(dd, @counter - 1, @opendate)
            SET @closedate = @stringdate + ' ' + CONVERT(VARCHAR(10), @enddate, 108)
            SET @closedate = DATEADD(dd, @counter - 1, @closedate)
            RETURN
         END
         IF DATEPART(hh, @begindate) > DATEPART(hh, @enddate) OR 
           (DATEPART(hh, @begindate) = DATEPART(hh, @enddate) AND DATEPART(mi, @begindate) > DATEPART(mi, @enddate))
         BEGIN
            SET @opendate = @stringdate + ' ' + CONVERT(VARCHAR(10), @begindate, 108)
            SET @opendate = DATEADD(dd, @counter - 1, @opendate)
            SET @closedate = @stringdate + ' ' + CONVERT(VARCHAR(10), @enddate, 108)
            SET @closedate = DATEADD(dd, 1, @closedate)
            SET @closedate = DATEADD(dd, @counter - 1, @closedate)
            RETURN
         END
      END
   END

   SET @counter = @counter + 1
   IF @counter > 7
      BREAK

   IF @tripday < 7
      SET @tripday = @tripday + 1
   ELSE
      SET @tripday = 1

END

IF @begindate IS NULL
BEGIN
   SET @opendate = '1950-01-01 00:00:00'
   SET @closedate = '2049-12-31 23:59:59'
END

GO
GRANT EXECUTE ON  [dbo].[p_get_CompanyOpenTime] TO [public]
GO
