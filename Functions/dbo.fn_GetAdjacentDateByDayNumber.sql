SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetAdjacentDateByDayNumber]
( @anyDate        DATETIME
, @whichDayNumber INT
)
RETURNS DATETIME

AS

/**
 *
 * NAME:
 * dbo.fn_GetAdjacentDateByDayNumber
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function to Return Adjacent Day Number for a given Date; 1=Sunday and 7=Saturday
 *
 * RETURNS:
 *
 * DATETIME
 *
 * PARAMETERS:
 * 001 - @anyDate          DATETIME
 * 002 - @whichDayNumber   INT
 *
 * REVISION HISTORY:
 * PTS 90961 SPN Created 09/09/2015
 *
 **/

BEGIN

   DECLARE @RetVal         DATETIME
   DECLARE @CurDayNumber   INT

   IF @whichDayNumber < 1 OR @whichDayNumber > 7
      SELECT @whichDayNumber = 1

   SELECT @RetVal = @anyDate
   SELECT @CurDayNumber = 0

   WHILE @CurDayNumber <> @whichDayNumber
   BEGIN
      SELECT @CurDayNumber = DATEPART(WEEKDAY,@RetVal)
      IF @CurDayNumber <> @whichDayNumber
         SELECT @RetVal = DATEADD(dd, -1, @RetVal)
   END

   Return @RetVal
END
GO
GRANT EXECUTE ON  [dbo].[fn_GetAdjacentDateByDayNumber] TO [public]
GO
