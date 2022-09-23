SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_get_FirstFullWeek_BeginEnd]
( @anyDateOfaMonth   DATETIME
, @BeginOrEnd        CHAR(1)
, @WeekBeginsDayNo   INT
, @WeekEndsDayNo     INT
)
RETURNS DATETIME

AS

/**
 *
 * NAME:
 * dbo.fn_get_FirstFullWeek_BeginEnd
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function to Return First Full Week Begin/End Date for a given month
 *
 * RETURNS:
 *
 * DATETIME
 *
 * PARAMETERS:
 * 001 - @anyDateOfaMonth   DATETIME
 * 002 - @BeginOrEnd        CHAR(1)
 * 003 - @WeekBeginsDayNo   INT
 * 004 - @WeekEndsDayNo     INT
 *
 * REVISION HISTORY:
 * PTS 63639 SPN Created 08/16/2012
 *
 **/

BEGIN

   DECLARE @RetVal					DATETIME

	DECLARE @FirstWeekBeginDate	DATETIME
	DECLARE @FirstWeekEndDate		DATETIME
	
   DECLARE @monthBegin				DATETIME
   DECLARE @monthEnd					DATETIME

   DECLARE @t_DatesOfMonth TABLE
   ( sn        INT IDENTITY(1,1)
   , thisDate  DATETIME
   )

   SELECT @monthBegin = DATEADD(MONTH,DATEDIFF(MONTH,0,@anyDateOfaMonth),0)
   SELECT @monthEnd   = DATEADD(MONTH,1,@monthBegin)

   WHILE @monthBegin < @monthEnd
   BEGIN
      INSERT INTO @t_DatesOfMonth(thisDate)
      SELECT @monthBegin
      SET @monthBegin = DATEADD(DAY,1,@monthBegin)
   END

   IF IsNull(@WeekBeginsDayNo,0) > 7 OR IsNull(@WeekBeginsDayNo,0) <= 0
      SELECT @WeekBeginsDayNo = 2

   IF IsNull(@WeekEndsDayNo,0) > 7 OR IsNull(@WeekEndsDayNo,0) <= 0
      SELECT @WeekEndsDayNo = 7

   SELECT @FirstWeekBeginDate = MIN(thisDate) FROM @t_DatesOfMonth WHERE DATEPART(WEEKDAY,thisDate) = @WeekBeginsDayNo
   SELECT @FirstWeekEndDate   = MIN(thisDate) FROM @t_DatesOfMonth WHERE DATEPART(WEEKDAY,thisDate) = @WeekEndsDayNo AND thisDate > @FirstWeekBeginDate

   IF @BeginOrEnd = 'B'
      SELECT @RetVal = @FirstWeekBeginDate
   ELSE
      SELECT @RetVal = @FirstWeekEndDate

   Return @RetVal
END
GO
GRANT EXECUTE ON  [dbo].[fn_get_FirstFullWeek_BeginEnd] TO [public]
GO
