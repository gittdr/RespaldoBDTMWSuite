SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_Convert2SqlTextDecimal]
( @Input  DECIMAL(19,6)
) RETURNS VARCHAR(MAX)

AS
/**
 *
 * NAME:
 * dbo.fnc_Convert2SqlTextDecimal
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns Decimal as Text for using in Dynamic SQL
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @Input   DECIMAL(19,6)
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/08/2014 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @RetVal VARCHAR(MAX)

   IF @Input IS NULL
      SELECT @RetVal = 'NULL'
   ELSE
      SELECT @RetVal = CONVERT(VARCHAR,@Input)

   RETURN @RetVal

END
GO
GRANT EXECUTE ON  [dbo].[fnc_Convert2SqlTextDecimal] TO [public]
GO
