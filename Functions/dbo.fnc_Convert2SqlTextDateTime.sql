SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_Convert2SqlTextDateTime]
( @Input  DATETIME
) RETURNS VARCHAR(MAX)

AS
/**
 *
 * NAME:
 * dbo.fnc_Convert2SqlTextDateTime
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns DateTime as Text for using in Dynamic SQL
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @Input   DATETIME
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/08/2014 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @RetVal VARCHAR(MAX)

   IF @Input IS NULL OR @Input = CONVERT(DATETIME,'1900-01-01')
      SELECT @RetVal = 'NULL'
   ELSE
      SELECT @RetVal = '''' + CONVERT(VARCHAR,@Input) + ''''

   RETURN @RetVal

END
GO
GRANT EXECUTE ON  [dbo].[fnc_Convert2SqlTextDateTime] TO [public]
GO
