SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_get_payroll_beginend]
( @anyDateOfaMonth   DATETIME
, @BeginOrEnd        CHAR(1)
, @whichWeekDay      INT
)
RETURNS DATETIME

AS

/**
 *
 * NAME:
 * dbo.fn_get_payroll_beginend
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function to Return Beginning or End Week Day for a given month for the purpose of Payroll
 *
 * RETURNS:
 *
 * DATETIME
 *
 * PARAMETERS:
 * 001 - @anyDateOfaMonth   DATETIME
 * 002 - @BeginOrEnd        CHAR(1)
 * 003 - @whichWeekDay      INT
 *
 * REVISION HISTORY:
 * PTS 63639 SPN Created 08/16/2012
 *
 **/

BEGIN

   DECLARE @RetVal      DATETIME

   DECLARE @monthBegin  DATETIME
   DECLARE @monthEnd    DATETIME

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

   IF IsNull(@whichWeekDay,0) > 7 OR IsNull(@whichWeekDay,0) <= 0
      SELECT @whichWeekDay = 7

   IF @BeginOrEnd = 'B'
      BEGIN
         SELECT @RetVal = MIN(thisDate) FROM @t_DatesOfMonth WHERE DATEPART(WEEKDAY,thisDate) = @whichWeekDay
         --Not first day of this month then go back 7 days to bring in the last week of previous month into current month begin date
         IF DATEPART(d,@RetVal) <> 1
         BEGIN
            SELECT @RetVal = DATEADD(DAY,-7,@RetVal)
         END
      END
   ELSE
      BEGIN
         SELECT @RetVal  = MAX(thisDate) FROM @t_DatesOfMonth WHERE DATEPART(WEEKDAY,thisDate) = @whichWeekDay
      END

   Return @RetVal
END
GO
GRANT EXECUTE ON  [dbo].[fn_get_payroll_beginend] TO [public]
GO
